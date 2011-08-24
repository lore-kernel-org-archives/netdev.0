From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv6 multicast snooping behaviour on 2.6.39-rc2 and later
Date: Wed, 24 Aug 2011 09:22:34 +0200
Message-ID: <1314170554.4478.30.camel@edumazet-laptop>
References: <4E5367CA.3090005@sfc.wide.ad.jp>
	 <1314093424.2219.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E539DA8.1070504@sfc.wide.ad.jp>
	 <1314105027.2219.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4E53B360.8090107@sfc.wide.ad.jp> <4E53E237.1060401@sfc.wide.ad.jp>
	 <CAAM7YAmht5FFTTFHrDUXAXHD5h5gzn1GrtEbHkQfbaoCwccG0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ang Way Chuang <wcang@sfc.wide.ad.jp>, netdev@vger.kernel.org,
	Linus =?ISO-8859-1?Q?L=FCssing?= <linus.luessing@web.de>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "Yan, Zheng" <yanzheng@21cn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45401 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753681Ab1HXHWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 03:22:39 -0400
Received: by wyg24 with SMTP id 24so616832wyg.19
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2011 00:22:38 -0700 (PDT)
In-Reply-To: <CAAM7YAmht5FFTTFHrDUXAXHD5h5gzn1GrtEbHkQfbaoCwccG0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 24 ao=C3=BBt 2011 =C3=A0 15:04 +0800, Yan, Zheng a =C3=A9cr=
it :
> On Wed, Aug 24, 2011 at 1:24 AM, Ang Way Chuang <wcang@sfc.wide.ad.jp=
> wrote:
> > This is what I found so far from debugging.
> >
> > The packet is not forwarded due to the failed checksum at
> > br_multicast.c:1533
> >
> >        case CHECKSUM_NONE:
> >                skb2->csum =3D 0;
> >                if (skb_checksum_complete(skb2))
> >                        goto out;
> >        }
> >
> > Contrary to description of commit ff9a57a6, when the patch of commi=
t
> > ff9a57a6 is applied,
> > pskb_trim_rcsum is never called at all on my testbed. When commit f=
f9a57a6
> > is reverted,
> > pskb_trim_rcsum will be called. The difference is:
> >
> > with commit ff9a57a6,
> >   pskb_trim_rcsum is never called, br_multicast_ipv6_rcv returns -E=
INVAL
> > which causes
> >   br_handle_frame_finish to drop the packet
> >
> > without commit ff9a57a6,
> >   pskb_trim_rcsum is called overwriting err with 0. br_multicast_ip=
v6_rcv
> > still fails on the
> >   same line (skb_checksum_complete). But the difference is err is s=
et to 0
> > this time. Thereby,
> >   allowing the packet to be forwarded.
> >
> > Anyway, I don't think the behaviour is correct with or without comm=
it
> > ff9a57a6
> >
> >
>=20
> Looks like a checksum calculation bug. Please try below patch, Thanks=
=2E
>=20
> ---
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 2d85ca7..22d2d1a 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -1520,16 +1520,23 @@ static int br_multicast_ipv6_rcv(struct net_b=
ridge *br,
>  		err =3D pskb_trim_rcsum(skb2, len);
>  		if (err)
>  			goto out;
> +		err =3D -EINVAL;
>  	}
>=20
> +	ip6h =3D ipv6_hdr(skb2);
> +
>  	switch (skb2->ip_summed) {
>  	case CHECKSUM_COMPLETE:
> -		if (!csum_fold(skb2->csum))
> +		if (!csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr, skb2->len,
> +					IPPROTO_ICMPV6, skb2->csum))
>  			break;
>  		/*FALLTHROUGH*/
>  	case CHECKSUM_NONE:
> -		skb2->csum =3D 0;
> -		if (skb_checksum_complete(skb2))
> +		skb2->csum =3D ~csum_unfold(csum_ipv6_magic(&ip6h->saddr,
> +							&ip6h->daddr,
> +							skb2->len,
> +							IPPROTO_ICMPV6, 0));
> +		if (__skb_checksum_complete(skb2))
>  			goto out;
>  	}
>=20
> ---


We also could reuse/factorize code, say the one from icmpv6_rcv()
