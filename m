From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] af_packet: account for VLAN when checking packet size
Date: Mon, 11 Oct 2010 16:03:02 +0200
Message-ID: <1286805782.2737.25.camel@edumazet-laptop>
References: <20101011131500.GA12342@orbit.nwl.cc>
	 <1286803522-16478-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	johann.baudy@gnu-log.net
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34682 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754787Ab0JKODM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 10:03:12 -0400
Received: by wwj40 with SMTP id 40so3781400wwj.1
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 07:03:10 -0700 (PDT)
In-Reply-To: <1286803522-16478-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 octobre 2010 =C3=A0 15:25 +0200, Phil Sutter a =C3=A9crit :
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  net/packet/af_packet.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 9a17f28..ad37754 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -56,6 +56,7 @@
>  #include <linux/in.h>
>  #include <linux/inet.h>
>  #include <linux/netdevice.h>
> +#include <linux/if_arp.h>
>  #include <linux/if_packet.h>
>  #include <linux/wireless.h>
>  #include <linux/kernel.h>
> @@ -983,6 +984,11 @@ static int tpacket_snd(struct packet_sock *po, s=
truct msghdr *msg)
> =20
>  	reserve =3D dev->hard_header_len;
> =20
> +	/* allow VLAN packets when device supports them */
> +	if (likely(dev->type =3D=3D ARPHRD_ETHER) &&
> +	    likely(!(dev->features & NETIF_F_VLAN_CHALLENGED)))
> +		reserve +=3D VLAN_HLEN;
> +
>  	err =3D -ENETDOWN;
>  	if (unlikely(!(dev->flags & IFF_UP)))
>  		goto out_put;

If we dont test ETH_P_8021Q protocol here, we allow sending 1504 bytes
frames for MTU=3D1500

Should we really care ?

If not, just do

reserve =3D dev->hard_header_len + VLAN_HLEN;



