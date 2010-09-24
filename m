From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: reset skb queue mapping when rx'ing over tunnel
Date: Fri, 24 Sep 2010 04:06:00 +0200
Message-ID: <1285293960.2380.23.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1009231415290.25121@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, chavey@google.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44996 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754843Ab0IXCGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 22:06:12 -0400
Received: by fxm3 with SMTP id 3so495866fxm.19
        for <netdev@vger.kernel.org>; Thu, 23 Sep 2010 19:06:11 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1009231415290.25121@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 23 septembre 2010 =C3=A0 14:19 -0700, Tom Herbert a =C3=A9crit=
 :
> Reset queue mapping when an skb is reentering the stack via a tunnel.
> On second pass, the queue mapping from the original device is no
> longer valid.
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
> diff --git a/include/net/dst.h b/include/net/dst.h
> index 81d1413..0238650 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -242,6 +242,7 @@ static inline void skb_tunnel_rx(struct sk_buff *=
skb, struct net_device *dev)
>  	dev->stats.rx_packets++;
>  	dev->stats.rx_bytes +=3D skb->len;
>  	skb->rxhash =3D 0;
> +	skb_set_queue_mapping(skb, 0);
>  	skb_dst_drop(skb);
>  	nf_reset(skb);
>  }
> --

Hmm...

This would need to be reverted later when tunnels are updated to be
multiqueue aware ? I made an attempt with GRE some days ago.

I dont understand why this patch is needed, since get_rps_cpu() has a
check anyway

        if (skb_rx_queue_recorded(skb)) {
                u16 index =3D skb_get_rx_queue(skb);
                if (unlikely(index >=3D dev->num_rx_queues)) {
                        WARN_ONCE(dev->num_rx_queues > 1, "%s received =
packet "
                                "on queue %u, but number of RX queues i=
s %u\n",
                                dev->name, index, dev->num_rx_queues);
                        goto done;
                }
                rxqueue =3D dev->_rx + index;
        } else
                rxqueue =3D dev->_rx;



