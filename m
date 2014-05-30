From: Stefan Bader <stefan.bader@canonical.com>
Subject: Re: [PATCH net-next] xen-netfront: try linearizing SKB if it occupies
 too many slots
Date: Fri, 30 May 2014 14:28:17 +0200
Message-ID: <53887961.9030502@canonical.com>
References: <1400238496-2471-1-git-send-email-wei.liu2@citrix.com> <1400245474.7973.154.camel@edumazet-glaptop2.roam.corp.google.com> <20140516131145.GK18551@zion.uk.xensource.com> <1400250068.7973.171.camel@edumazet-glaptop2.roam.corp.google.com> <20140516143653.GL18551@zion.uk.xensource.com> <1400253739.7973.183.camel@edumazet-glaptop2.roam.corp.google.com> <20140516153452.GM18551@zion.uk.xensource.com> <53763CD1.6060500@citrix.com> <53883C18.2050708@canonical.com> <20140530121141.GA2655@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="M1hLuGTekmESx6BKTAMQ7Q3AD7SxrSK4x"
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	xen-devel@lists.xen.org, David Vrabel <david.vrabel@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:47210 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932375AbaE3M2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 08:28:23 -0400
In-Reply-To: <20140530121141.GA2655@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--M1hLuGTekmESx6BKTAMQ7Q3AD7SxrSK4x
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 30.05.2014 14:11, Wei Liu wrote:
> On Fri, May 30, 2014 at 10:06:48AM +0200, Stefan Bader wrote:
> [...]
>> I had been idly wondering about this onwards. And trying to understand=
 the whole
>> skb handling environment, I tried to come up with some idea as well. I=
t may be
>> totally stupid and using the wrong assumptions. It seems to work in th=
e sense
>> that things did not blow up into my face immediately and somehow I did=
 not see
>> dropped packages due to the number of slots either.
>> But again, I am not sure I am doing the right thing. The idea was to j=
ust try to
>> get rid of so many compound pages (which I believe are the only ones t=
hat can
>> have an offset big enough to allow some alignment savings)...
>>
>> -Stefan
>>
>=20
> Thanks. I think the general idea is OK, but it still involves
> unnecessary page allocation. We don't actually need to get rid of
> compound page by replacing it with a new page, we just need to make sur=
e
> the data inside is aligned.
>=20
> If you look at xennet_make_frags, it only grants the 4K page which
> contains data. I presume a simple memove would be better than alloc_pag=
e
> + memcpy. What do you think?
>=20
> Like:
>    memmove(page_address(fpage), page_address(fpage)+offset, size);
>    frag->page_offset =3D 0;

I was hesitating to do that as I could not really tell whether I can make=
 any
assumptions about those memory areas. So my cautious guess was to leave t=
he
original pages alone altogether (maybe whoever owns those has something
important in the starting area). If I did it right, my new page potential=
ly
could be a smaller allocation unit than the original, since I only ask fo=
r
something big enough to hold the frag size (ignoring a potential offset o=
ver
full 4K areas).

-Stefan
>=20
> Wei.
>=20
>>
>> From 8571b106643b32296e58526e2fbe97c330877ac8 Mon Sep 17 00:00:00 2001=

>> From: Stefan Bader <stefan.bader@canonical.com>
>> Date: Thu, 29 May 2014 12:18:01 +0200
>> Subject: [PATCH] xen-netfront: Align frags to fit max slots
>>
>> In cases where the frags in a skb require more than MAX_SKB_FRAGS + 1
>> (=3D 18) 4K pages of grant pages, try to reduce the footprint by movin=
g
>> the data to new pages and have it aligned to the beginning.
>> Then replace the page in the frag and release the old one. This sure i=
s
>> more expensive in compute but should happen not too often and sounds
>> better than to just drop the packet in that case.
>>
>> Signed-off-by: Stefan Bader <stefan.bader@canonical.com>
>> ---
>>  drivers/net/xen-netfront.c | 65 +++++++++++++++++++++++++++++++++++++=
++++++---
>>  1 file changed, 62 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>> index 158b5e6..ad71e5c 100644
>> --- a/drivers/net/xen-netfront.c
>> +++ b/drivers/net/xen-netfront.c
>> @@ -544,6 +544,61 @@ static int xennet_count_skb_frag_slots(struct sk_=
buff *skb)
>>  	return pages;
>>  }
>>
>> +/*
>> + * Align data to new pages in order to save slots required to
>> + * transmit this buffer.
>> + * @skb - socket buffer
>> + * @target - number of pages to save
>> + * returns the number of pages the fragments have been reduced of
>> + */
>> +static int xennet_align_frags(struct sk_buff *skb, int target)
>> +{
>> +	int i, frags =3D skb_shinfo(skb)->nr_frags;
>> +	int reduced =3D 0;
>> +
>> +	for (i =3D 0; i < frags; i++) {
>> +		skb_frag_t *frag =3D skb_shinfo(skb)->frags + i;
>> +		struct page *fpage =3D skb_frag_page(frag);
>> +		struct page *npage;
>> +		unsigned long size;
>> +		unsigned long offset;
>> +		gfp_t gfp;
>> +		int order;
>> +
>> +		if (!PageCompound(fpage))
>> +			continue;
>> +
>> +		size =3D skb_frag_size(frag);
>> +		offset =3D frag->page_offset & ~PAGE_MASK;
>> +
>> +		/*
>> +		 * If the length of data in the last subpage of a compound
>> +		 * page is smaller than the offset into the first data sub-
>> +		 * page, we can save a subpage by copying data around.
>> +		 */
>> +		if ( ((offset + size) & ~PAGE_MASK) > offset )
>> +			continue;
>> +
>> +		gfp =3D GFP_ATOMIC | __GFP_COLD;
>> +		order =3D PFN_UP(size);
>> +		if (order)
>> +			gfp |=3D __GFP_COMP | __GFP_NOWARN;
>> +
>> +		npage =3D alloc_pages(gfp, order);
>> +		if (!npage)
>> +			break;
>> +		memcpy(page_address(npage), skb_frag_address(frag), size);
>> +		frag->page.p =3D npage;
>> +		frag->page_offset =3D 0;
>> +		put_page(fpage);
>> +
>> +		if (++reduced >=3D target)
>> +			break;
>> +	}
>> +
>> +	return reduced;
>> +}
>> +
>>  static int xennet_start_xmit(struct sk_buff *skb, struct net_device *=
dev)
>>  {
>>  	unsigned short id;
>> @@ -573,9 +628,13 @@ static int xennet_start_xmit(struct sk_buff *skb,=
 struct
>> net_device *dev)
>>  	slots =3D DIV_ROUND_UP(offset + len, PAGE_SIZE) +
>>  		xennet_count_skb_frag_slots(skb);
>>  	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
>> -		net_alert_ratelimited(
>> -			"xennet: skb rides the rocket: %d slots\n", slots);
>> -		goto drop;
>> +		slots -=3D xennet_align_frags(skb, slots - (MAX_SKB_FRAGS + 1));
>> +		if (slots > MAX_SKB_FRAGS + 1) {
>> +			net_alert_ratelimited(
>> +				"xennet: skb rides the rocket: %d slots\n",
>> +				slots);
>> +			goto drop;
>> +		}
>>  	}
>>
>>  	spin_lock_irqsave(&np->tx_lock, flags);
>> --=20
>> 1.9.1
>>
>>
>>
>=20
>=20



--M1hLuGTekmESx6BKTAMQ7Q3AD7SxrSK4x
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCgAGBQJTiHlhAAoJEOhnXe7L7s6jSBkP/RvTGk7FJlrPFhfAyGWfqICf
VRQtClc+7saPszGkRe85PKf3yag5tb7RygKFJJYRcZpIddR9KC8O9fcCHhbnZp38
fNdq9Ge5jmbiXAaT9j6deMRJyf/EKZPq1YQl4505IGfEKBJTYHWb9OXRE0svYIhY
qPJQEp0iSzf5QRseA7d21Gv7T8cVBOgtaOY6JNJ04KPqzAyQgYbA8KenMiuIBzUZ
bnF55c8o2c5RAC69/bTSKr3X0GsRYbeDSU8285zggaufvCsZu/BmeaYrrRPJPRxq
KKBKmmaywmDTeqF+hOgDXREWuu7l7FhdRzcKyUa3FnJL6rFKvhfh224l/Qijqk1U
vIiCtBOkMIFr4HPTIb+VUNn7FLRO/yD3K/o2X6HeO6gW/05XWedv90NN7pCjNPFp
irXLgGDAUk6pX8f5zRuyHKOHZSGH0u4DW/JmRSF8yfXJGcERze76GLHaQzzcprWJ
NCoT0svnDwJqEsfM9bn/xeOhD38/FN9kYM+ObX+9t6sbu0p+Nl43vPirPaYCkIuG
qB34UkffWyvAIStU+NEuwIoGQ6N2P5ROFkshkb6sUhLb5gIU04nRIiK30tyzF9PI
HJ0LNF96JFv47BHTjpiNqOzSFIX5xGOhTKnfXesRcDOBi89q+WA9W1q76wxc9dV9
mqB3C/3r9WX1I4Yrjj8p
=CVts
-----END PGP SIGNATURE-----

--M1hLuGTekmESx6BKTAMQ7Q3AD7SxrSK4x--
