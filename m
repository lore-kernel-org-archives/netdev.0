From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bridge: Pseudo-header required for the checksum of
 ICMP6 header of MLD
Date: Wed, 24 Aug 2011 09:18:27 +0200
Message-ID: <1314170307.4478.28.camel@edumazet-laptop>
References: <4E5495EA.1080906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ang Way Chuang <wcang79@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49462 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988Ab1HXHSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 03:18:32 -0400
Received: by wyg24 with SMTP id 24so614840wyg.19
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2011 00:18:31 -0700 (PDT)
In-Reply-To: <4E5495EA.1080906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 24 ao=C3=BBt 2011 =C3=A0 15:10 +0900, Ang Way Chuang a =C3=A9=
crit :
> Just saw Eric's patch for icmp6_type. Suspect this patch may have iss=
ue for reference
> of ip6h after pskb_trim_rcsum()?
>=20

I dont think so, because ip6h is against skb header, not skb2 one.


> Checksum of ICMPv6 is not properly computed because the pseudo header=
 is not used.
> Thus, the MLD packet gets dropped by the bridge. This patch fixes the=
 problem for my
> testbed. This bug was made visible by commit ff9a57a62afbbe2d0f3a09af=
321f1fd7645f38a.
>=20
> This patch has been tested on 3.0.3. Due to lack of understanding on =
the checksum
> optimization and multicast snooping of the kernel stack, can someone =
please verify the
> correctness of this patch?
>=20
> Signed-off-by: Ang Way Chuang <wcang@sfc.wide.ad.jp>
> ---
> index 2d85ca7..bbf361b 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -1528,9 +1528,12 @@ static int br_multicast_ipv6_rcv(struct net_br=
idge *br,
>  			break;
>  		/*FALLTHROUGH*/
>  	case CHECKSUM_NONE:
> -		skb2->csum =3D 0;
> -		if (skb_checksum_complete(skb2))
> +		if (!skb_csum_unnecessary(skb2) && csum_ipv6_magic(&ip6h->saddr,
> +			&ip6h->daddr, skb2->len, IPPROTO_ICMPV6,
> +			skb_checksum(skb2, 0, skb2->len, 0))) {
> +			err =3D -EINVAL;
>  			goto out;
> +		}
>  	}
> =20
>  	err =3D 0;
> ---


Sorry, I cannot comment on this, checksum games are hard :(
