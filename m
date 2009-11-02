From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] ifb: RCU locking avoids touching dev refcount
Date: Mon, 02 Nov 2009 22:14:03 +0100
Message-ID: <4AEF4B9B.7000205@gmail.com>
References: <4AEE71EC.7040208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:62764 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755082AbZKBVOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 16:14:34 -0500
Received: by bwz27 with SMTP id 27so6796041bwz.21
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2009 13:14:38 -0800 (PST)
In-Reply-To: <4AEE71EC.7040208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote, On 11/02/2009 06:45 AM:

> Avoids touching dev refcount in hotpath
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  drivers/net/ifb.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
> index 030913f..69c2566 100644
> --- a/drivers/net/ifb.c
> +++ b/drivers/net/ifb.c
> @@ -98,13 +98,15 @@ static void ri_tasklet(unsigned long dev)
>  		stats->tx_packets++;
>  		stats->tx_bytes +=skb->len;
>  
> -		skb->dev = dev_get_by_index(&init_net, skb->iif);
> +		rcu_read_lock();
> +		skb->dev = dev_get_by_index_rcu(&init_net, skb->iif);
>  		if (!skb->dev) {
> +			rcu_read_unlock();
>  			dev_kfree_skb(skb);
>  			stats->tx_dropped++;
>  			break;
>  		}
> -		dev_put(skb->dev);
> +		rcu_read_unlock();

I wonder if this rcu_read_unlock() isn't too early here. I know, it
functionally fully replaces the old method, but as a whole it looks
strange:

>                 rcu_read_lock();
>                 skb->dev = dev_get_by_index_rcu(&init_net, skb->iif);
>                 if (!skb->dev) {
>                         rcu_read_unlock();
>                         dev_kfree_skb(skb);
>                         stats->tx_dropped++;
>                         break;
>                 }
>                 rcu_read_unlock();
>                 skb->iif = _dev->ifindex;
> 
>                 if (from & AT_EGRESS) {
>                         dp->st_rx_frm_egr++;
>                         dev_queue_xmit(skb);
>                 } else if (from & AT_INGRESS) {
>                         dp->st_rx_frm_ing++;
>                         skb_pull(skb, skb->dev->hard_header_len);


So, how is skb->dev protected here, above and below? It seems these
rcu read blocks need extending, don't they?

Jarek P.

>                         netif_rx(skb);
>                 } else
>                         BUG();
>         }
