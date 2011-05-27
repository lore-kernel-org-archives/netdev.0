From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 v2] af-packet:  Add flag to distinguish VID 0 from
 no-vlan.
Date: Fri, 27 May 2011 05:46:34 +0200
Message-ID: <1306467994.2543.62.camel@edumazet-laptop>
References: <1306454141-1634-1-git-send-email-greearb@candelatech.com>
	 <1306454141-1634-2-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62718 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753731Ab1E0Dqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 23:46:38 -0400
Received: by wwa36 with SMTP id 36so1428558wwa.1
        for <netdev@vger.kernel.org>; Thu, 26 May 2011 20:46:37 -0700 (PDT)
In-Reply-To: <1306454141-1634-2-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 26 mai 2011 =C3=A0 16:55 -0700, greearb@candelatech.com a =C3=A9=
crit :
> From: Ben Greear <greearb@candelatech.com>
>=20
> Currently, user-space cannot determine if a 0 tcp_vlan_tci
> means there is no VLAN tag or the VLAN ID was zero.
>=20
> Add flag to make this explicit.  User-space can check for
> TP_STATUS_VLAN_VALID || tp_vlan_tci > 0, which will be backwards
> compatible. Older could would have just checked for tp_vlan_tci,
> so it will work no worse than before.
>=20
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> v2:  add logic to tpacket_rcv too.
>=20
> :100644 100644 72bfa5a... 6d66ce1... M	include/linux/if_packet.h
> :100644 100644 f9b807d... 9c2d068... M	net/packet/af_packet.c
>  include/linux/if_packet.h |    1 +
>  net/packet/af_packet.c    |   14 ++++++++++++--
>  2 files changed, 13 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
> index 72bfa5a..6d66ce1 100644
> --- a/include/linux/if_packet.h
> +++ b/include/linux/if_packet.h
> @@ -70,6 +70,7 @@ struct tpacket_auxdata {
>  #define TP_STATUS_COPY		0x2
>  #define TP_STATUS_LOSING	0x4
>  #define TP_STATUS_CSUMNOTREADY	0x8
> +#define TP_STATUS_VLAN_VALID   0x10 /* auxdata has valid tp_vlan_tci=
 */
> =20
>  /* Tx ring - header status */
>  #define TP_STATUS_AVAILABLE	0x0
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index f9b807d..9c2d068 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -818,7 +818,12 @@ static int tpacket_rcv(struct sk_buff *skb, stru=
ct net_device *dev,
>  			getnstimeofday(&ts);
>  		h.h2->tp_sec =3D ts.tv_sec;
>  		h.h2->tp_nsec =3D ts.tv_nsec;
> -		h.h2->tp_vlan_tci =3D vlan_tx_tag_get(skb);
> +		if (vlan_tx_tag_present(skb)) {
> +			h.h2->tp_vlan_tci =3D vlan_tx_tag_get(skb);
> +			status |=3D TP_STATUS_VLAN_VALID;
> +		}
> +		else
> +			h.h2->tp_vlan_tci =3D 0;

	if (...) {
		...
	} else {
		...
	}

>  		hdrlen =3D sizeof(*h.h2);
>  		break;
>  	default:
> @@ -1763,7 +1768,12 @@ static int packet_recvmsg(struct kiocb *iocb, =
struct socket *sock,
>  		aux.tp_snaplen =3D skb->len;
>  		aux.tp_mac =3D 0;
>  		aux.tp_net =3D skb_network_offset(skb);
> -		aux.tp_vlan_tci =3D vlan_tx_tag_get(skb);
> +		if (vlan_tx_tag_present(skb)) {
> +			aux.tp_vlan_tci =3D vlan_tx_tag_get(skb);
> +			aux.tp_status |=3D TP_STATUS_VLAN_VALID;
> +		}
> +		else
> +			aux.tp_vlan_tci =3D 0;

Same codingstyle comment here.

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks


