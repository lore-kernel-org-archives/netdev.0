From: Jon Loeliger <jdl@jdl.com>
Subject: Re: [PATCH RFC] gianfar: Do not call skb recycling with disabled IRQs
Date: Fri, 06 Nov 2009 14:38:06 -0600
Message-ID: <E1N6VZO-00077V-Hi@jdl.com>
References: <20091104225711.GA30844@oksana.dev.rtsoft.ru> <E1N62ti-0003iS-K2@jdl.com> <20091105142028.GB17171@oksana.dev.rtsoft.ru> <E1N63WM-0003xK-PN@jdl.com> <E1N64UY-00049g-Hb@jdl.com> <20091105165738.GA31923@oksana.dev.rtsoft.ru> <9F4C7D19E8361D4C94921B95BE08B81B950713@zin33exm22.fsl.freescale.net> <E1N66Jp-0004Y0-8Q@jdl.com> <20091105175316.GA27099@oksana.dev.rtsoft.ru>
Cc: Kumar Gopalpet-B05799 <B05799@freescale.com>,
	linuxppc-dev@ozlabs.org, Jason Wessel <jason.wessel@windriver.com>,
	Fleming Andy-AFLEMING <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from jdl.com ([208.123.74.7]:35912 "EHLO jdl.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759717AbZKFUiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Nov 2009 15:38:19 -0500
In-reply-to: <20091105175316.GA27099@oksana.dev.rtsoft.ru> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Here is the patch on top of the Linus' git tree, if you haven't
> already 'back-ported' the previous patch.

This back-ported patch has been running in my (2.6.31) kernel
for a couple days now without showing any sign of problem.

Maybe throw a

Tested-by: Jon Loeliger <jdl@jdl.com>

at it?

jdl



> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> index 5bf31f1..5dca99c 100644
> --- a/drivers/net/gianfar.c
> +++ b/drivers/net/gianfar.c
> @@ -1274,7 +1274,6 @@ static int gfar_start_xmit(struct sk_buff *skb, struct 
> net_device *dev)
>  	u32 lstatus;
>  	int i;
>  	u32 bufaddr;
> -	unsigned long flags;
>  	unsigned int nr_frags, length;
>  
>  	base = priv->tx_bd_base;
> @@ -1298,14 +1297,11 @@ static int gfar_start_xmit(struct sk_buff *skb, struc
> t net_device *dev)
>  	/* total number of fragments in the SKB */
>  	nr_frags = skb_shinfo(skb)->nr_frags;
>  
> -	spin_lock_irqsave(&priv->txlock, flags);
> -
>  	/* check if there is space to queue this packet */
>  	if ((nr_frags+1) > priv->num_txbdfree) {
>  		/* no space, stop the queue */
>  		netif_stop_queue(dev);
>  		dev->stats.tx_fifo_errors++;
> -		spin_unlock_irqrestore(&priv->txlock, flags);
>  		return NETDEV_TX_BUSY;
>  	}
>  
> @@ -1403,9 +1399,6 @@ static int gfar_start_xmit(struct sk_buff *skb, struct 
> net_device *dev)
>  	/* Tell the DMA to go go go */
>  	gfar_write(&priv->regs->tstat, TSTAT_CLEAR_THALT);
>  
> -	/* Unlock priv */
> -	spin_unlock_irqrestore(&priv->txlock, flags);
> -
>  	return NETDEV_TX_OK;
>  }
>  
> @@ -1915,17 +1908,14 @@ static int gfar_poll(struct napi_struct *napi, int bu
> dget)
>  	struct net_device *dev = priv->ndev;
>  	int tx_cleaned = 0;
>  	int rx_cleaned = 0;
> -	unsigned long flags;
>  
>  	/* Clear IEVENT, so interrupts aren't called again
>  	 * because of the packets that have already arrived */
>  	gfar_write(&priv->regs->ievent, IEVENT_RTX_MASK);
>  
> -	/* If we fail to get the lock, don't bother with the TX BDs */
> -	if (spin_trylock_irqsave(&priv->txlock, flags)) {
> -		tx_cleaned = gfar_clean_tx_ring(dev);
> -		spin_unlock_irqrestore(&priv->txlock, flags);
> -	}
> +	netif_tx_lock_bh(priv->ndev);
> +	tx_cleaned = gfar_clean_tx_ring(dev);
> +	netif_tx_unlock_bh(priv->ndev);
>  
>  	rx_cleaned = gfar_clean_rx_ring(dev, budget);
>  
> 
> -- 
> Anton Vorontsov
> email: cbouatmailru@gmail.com
> irc://irc.freenode.net/bd2
