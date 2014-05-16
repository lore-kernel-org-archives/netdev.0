From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: [Xen-devel] xen-netfront possibly rides the rocket too often
Date: Fri, 16 May 2014 12:09:50 +0200
Message-ID: <5375E3EE.6010306@canonical.com>
References: <537262AB.5010408@canonical.com> <5373C8D4.2010803@citrix.com>	<1400143605.1006.1.camel@kazak.uk.xensource.com>	<20140515110410.GD1117@zion.uk.xensource.com>	<5374AF88.2070608@canonical.com> <20140516094842.GA18551@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="FraVcAvnBHdAf8pmBb1Dq2EBrUASnpU6G"
Cc: xen-devel@lists.xenproject.org,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	netdev <netdev@vger.kernel.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:44826 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756014AbaEPKKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 06:10:06 -0400
In-Reply-To: <20140516094842.GA18551@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--FraVcAvnBHdAf8pmBb1Dq2EBrUASnpU6G
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 16.05.2014 11:48, Wei Liu wrote:
> On Thu, May 15, 2014 at 02:14:00PM +0200, Stefan Bader wrote:
> [...]
>>> Wei.
>>>
>> Reading more of the code I would agree. The definition of MAX_SKB_FRAG=
S (at
>> least now with compound pages) cannot be used in any way to derive the=
 number of
>> 4k slots a transfer will require.
>>
>> Zoltan already commented on worst cases. Not sure it would get as bad =
as that or
>> "just" 16*4k frags all in the middle of compound pages. That would the=
n end in
>> around 33 or 34 slots, depending on the header.
>>
>> Zoltan wrote:
>>> I think the worst case scenario is when every frag and the linear buf=
fer contains 2 bytes,
>>> which are overlapping a page boundary (that's (17+1)*2=3D36 so far), =
plus 15 of
>> them have a 4k
>>> page in the middle of them, so, a 1+4096+1 byte buffer can span over =
3 page.
>>> That's 51 individual pages.
>>
>> I cannot claim to really know what to expect worst case. Somewhat I wa=
s thinking
>> of a
>> worst case of (16+1)*2, which would be inconvenient enough.
>>
>> So without knowing exactly how to do it, but as Ian said it sounds bes=
t to come
>> up with some sort of exception coalescing in cases the slot count goes=
 over 18
>> and we know the data size is below 64K.
>>
>=20
> I took a stab at it this morning and came up with this patch. Ran
> redis-benchmark, it seemed to fix that for me -- only saw one "failed t=
o
> linearize skb" during
>=20
>   redis-benchmark -h XXX -d 1000 -t lrange
>=20
> And before this change, a lot of "rides rocket" were triggered.
>=20
> Thought?

It appears at least to me as something that nicely makes use of existing =
code. I
was wondering about what could or could not be used. Trying to get ones h=
ead
around the whole thing is kind of a lot to look at.

The change at least looks straight forward enough.

-Stefan
>=20
> ---8<---
> From 743495a2b2d338fc6cfe9bfd4b6e840392b87f4a Mon Sep 17 00:00:00 2001
> From: Wei Liu <wei.liu2@citrix.com>
> Date: Fri, 16 May 2014 10:39:01 +0100
> Subject: [PATCH] xen-netfront: linearize SKB if it occupies too many sl=
ots
>=20
> Some workload, such as Redis can generate SKBs which make use of compou=
nd
> pages. Netfront doesn't quite like that because it doesn't want to send=

> exessive slots to the backend as backend might deem it malicious. On th=
e
> flip side these packets are actually legit, the size check at the
> beginning of xennet_start_xmit ensures that packet size is below 64K.
>=20
> So we linearize SKB if it occupies too many slots. If the linearization=

> fails then the SKB is dropped.
>=20
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netfront.c |   18 +++++++++++++++---
>  1 file changed, 15 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 895355d..0361fc5 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -573,9 +573,21 @@ static int xennet_start_xmit(struct sk_buff *skb, =
struct net_device *dev)
>  	slots =3D DIV_ROUND_UP(offset + len, PAGE_SIZE) +
>  		xennet_count_skb_frag_slots(skb);
>  	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
> -		net_alert_ratelimited(
> -			"xennet: skb rides the rocket: %d slots\n", slots);
> -		goto drop;
> +		if (skb_linearize(skb)) {
> +			net_alert_ratelimited(
> +				"xennet: failed to linearize skb, skb dropped\n");
> +			goto drop;
> +		}
> +		data =3D skb->data;
> +		offset =3D offset_in_page(data);
> +		len =3D skb_headlen(skb);
> +		slots =3D DIV_ROUND_UP(offset + len, PAGE_SIZE) +
> +			xennet_count_skb_frag_slots(skb);
> +		if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
> +			net_alert_ratelimited(
> +				"xennet: still too many slots after linerization: %d", slots);
> +			goto drop;
> +		}
>  	}
> =20
>  	spin_lock_irqsave(&np->tx_lock, flags);
>=20



--FraVcAvnBHdAf8pmBb1Dq2EBrUASnpU6G
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCgAGBQJTdeP4AAoJEOhnXe7L7s6j+RwQAKQtm2jjLNjsXx9vwJkyopzS
7/okCAZkUQroiDLYUBEKL/1W1KFKC1bvGXUdYRI6JcqmQqE2bXVY4hYGtq3lw5SV
aL+iqDmJuoLwxmiRFkc/sbZGgLUUwJ8Xe42AEStunyreLOs8fZZFr+AgiDpqI2dP
wdX7A13GufcglpfHir4Lb7KGasFk6EzVenuV2cCM2P6P0DYHf4StUEY0XowmKlhR
8ta7Phq7JWEey6FftHzMAUz+CRKBkNqLF3wM8/01RMBa7Cb2oyjulFA72YfKXu2z
2oRUI3VfTCKKkiS0RrTHIITqAD+f+SnEVoXQsVBjNQELJyu39otEcgJLX7+nJQPz
w38Q26yhJfKtMFS6s725rg7b0a/Ht1yMYW+x9KmLIVTzTk7wlepe5gOlwavpSIzj
wIgKfKwS1asTQMQaVt7oFUka+Mu+EKDSve8qVXTWGERS2qE0w5DCaaDJkMwhAADT
bHK0AMWqPr5wHSO5C8IIRCLHL704czLU1qX9kiWSscBSgLsS8NO+agDnxtFG1zoQ
XheQSd/IsIulwGkjpMqbAdzGPtOEQ9vR0AANQ3VD15itBlLYyFlDoEhiReoEEqqt
FAndA4cUzykGKFzKrDLBzLRdWlKYoCpdn5jrl1dBWsTY2b0v8uqXfrSaGQ4TCIRl
segDozQI2f6mSixeou5r
=YaXE
-----END PGP SIGNATURE-----

--FraVcAvnBHdAf8pmBb1Dq2EBrUASnpU6G--
