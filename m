From: Daniel Turull <daniel.turull@gmail.com>
Subject: Re: [PATCH] pktgen: fix transmission headers with frags=0
Date: Mon, 14 Mar 2011 15:13:57 +0100
Message-ID: <4D7E22A5.1000708@gmail.com>
References: <4D7E167E.2090807@gmail.com> <1300110977.3423.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Robert Olsson <robert@herjulf.net>,
	Jens Laas <jens.laas@its.uu.se>,
	Voravit Tanyingyong <voravit@kth.se>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51197 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753745Ab1CNOOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 10:14:08 -0400
Received: by fxm17 with SMTP id 17so2929645fxm.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 07:14:07 -0700 (PDT)
In-Reply-To: <1300110977.3423.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/14/2011 02:56 PM, Eric Dumazet wrote:
> Le lundi 14 mars 2011 =C3=A0 14:22 +0100, Daniel Turull a =C3=A9crit =
:
>> The headers of pktgen were incorrectly added in a pktgen packet
>> without frags (frags=3D0). There was an offset in the pktgen headers=
=2E
>>
>> The cause was in reusing the pgh variable as a return variable in sk=
b_put
>> when adding the payload to the skb.
>>
>> A rename of the variable is done.
>>
>> Signed-off-by: Daniel Turull <daniel.turull@gmail.com>
>> ---
>> The PKTGEN magic (be9b e955) now starts in the correct offset.
>> Before the patch, it was starting at the end of the packet (be9b)
>>
>=20
> not exactly, but offseted  +16 bytes
> (sizeof(struct pktgen_hdr))
True, I shouldn't say end.

>=20
>> Capture from tcpdump:
>>
>> before patch:
>> 14:57:37.854812 IP 10.0.0.2.discard > 10.254.254.84.discard: UDP, le=
ngth 18
>> 	0x0000:  001b 2157 ed84 001b 215d 01d0 0800 4500
>> 	0x0010:  002e 0004 0000 2011 8767 0a00 0002 0afe
>> 	0x0020:  fe54 0009 0009 001a 0000 0000 0000 b072
>> 	0x0030:  9102 00ea ffff 0010 0000 be9b
>>
>> after patch:
>> 14:44:32.896048 IP 10.0.0.2.discard > 10.217.234.56.discard: UDP, le=
ngth 18
>> 	0x0000:  001b 2157 ed84 001b 215d 01d0 0800 4500
>> 	0x0010:  002e 0000 0000 2011 9bac 0a00 0002 0ad9
>> 	0x0020:  ea38 0009 0009 001a 0000 be9b e955 0000
>> 	0x0030:  0001 4d7e 1b09 0005 5f23 af00
>>
>> ---
>> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
>> index f0aec6c..5baa9d9 100644
>> --- a/net/core/pktgen.c
>> +++ b/net/core/pktgen.c
>> @@ -2615,13 +2615,14 @@ static void pktgen_finalize_skb(struct pktge=
n_dev *pkt_dev, struct sk_buff *skb,
>>  {
>>  	struct timeval timestamp;
>>  	struct pktgen_hdr *pgh;
>> +	void *data;
>> =20
>>  	pgh =3D (struct pktgen_hdr *)skb_put(skb, sizeof(*pgh));
>>  	datalen -=3D sizeof(*pgh);
>> =20
>>  	if (pkt_dev->nfrags <=3D 0) {
>> -		pgh =3D (struct pktgen_hdr *)skb_put(skb, datalen);
>> -		memset(pgh + 1, 0, datalen);
>> +		data =3D skb_put(skb, datalen);
>> +		memset(data + 1, 0, datalen);
>>  	} else {
>>  		int frags =3D pkt_dev->nfrags;
>>  		int i, len;
>> --
>=20
> Good catch !
>=20
> Hmm this patch is not correct, why memset(data + 1, ...) ?

I kept the +1 as it was in the original code, but I supposed it can be =
avoided.

> Also, this patch is needed for net-next-2.6 only
> (bug introduced by commit 26ad787962ef84677a48c560
> (pktgen: speedup fragmented skbs)
>=20
> I would avoid the "void *data;" declaration and just use following :
>=20
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index f0aec6c..f727c83 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -2620,7 +2620,7 @@ static void pktgen_finalize_skb(struct pktgen_d=
ev *pkt_dev, struct sk_buff *skb,
>  	datalen -=3D sizeof(*pgh);
> =20
>  	if (pkt_dev->nfrags <=3D 0) {
> -		pgh =3D (struct pktgen_hdr *)skb_put(skb, datalen);
> +		skb_put(skb, datalen);
>  		memset(pgh + 1, 0, datalen);
>  	} else {
>  		int frags =3D pkt_dev->nfrags;
>=20
>=20
>=20
> or even :
>=20
> 		memset(skb_put(skb, datalen), 0, datalen);
>=20
I think that the second is better and more compact.

Do I resend the new patch?

>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

