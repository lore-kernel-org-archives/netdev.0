From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] network: Allow af_packet to transmit +4 bytes for
 VLAN packets.
Date: Fri, 11 Feb 2011 07:57:26 +0100
Message-ID: <1297407446.2493.5.camel@edumazet-laptop>
References: <1297375149-18458-1-git-send-email-greearb@candelatech.com>
	 <1297375149-18458-2-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59150 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260Ab1BKG5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 01:57:33 -0500
Received: by bwz15 with SMTP id 15so2930691bwz.19
        for <netdev@vger.kernel.org>; Thu, 10 Feb 2011 22:57:32 -0800 (PST)
In-Reply-To: <1297375149-18458-2-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 10 f=C3=A9vrier 2011 =C3=A0 13:59 -0800, greearb@candelatech.c=
om a
=C3=A9crit :
> From: Ben Greear <greearb@candelatech.com>
>=20
> This allows user-space to send a '1500' MTU VLAN packet on a
> 1500 MTU ethernet frame.  The extra 4 bytes of a VLAN header is
> not usually charged against the MTU when other parts of the
> network stack is transmitting vlans...
>=20
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 91cb1d7... ef7f378... M	net/packet/af_packet.c
>  net/packet/af_packet.c |   31 +++++++++++++++++++++++++++++--
>  1 files changed, 29 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 91cb1d7..ef7f378 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -466,7 +466,7 @@ retry:
>  	 */
> =20
>  	err =3D -EMSGSIZE;
> -	if (len > dev->mtu + dev->hard_header_len)
> +	if (len > dev->mtu + dev->hard_header_len + VLAN_HLEN)
>  		goto out_unlock;
> =20
>  	if (!skb) {
> @@ -497,6 +497,19 @@ retry:
>  		goto retry;
>  	}
> =20
> +	if (len > (dev->mtu + dev->hard_header_len)) {
> +		/* Earlier code assumed this would be a VLAN pkt,
> +		 * double-check this now that we have the actual
> +		 * packet in hand.
> +		 */
> +		struct ethhdr *ehdr;
> +		skb_reset_mac_header(skb);
> +		ehdr =3D eth_hdr(skb);
> +		if (ehdr->h_proto !=3D htons(ETH_P_8021Q)) {
> +			err =3D -EMSGSIZE;
> +			goto out_unlock;

This would leak skb.

> +		}
> +	}
> =20
>  	skb->protocol =3D proto;
>  	skb->dev =3D dev;


