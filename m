From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/4] net: systemport: fix transmit locking
 scheme
Date: Fri, 6 Jun 2014 09:29:55 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725866E@AcuExch.aculab.com>
References: <1401988938-25940-1-git-send-email-f.fainelli@gmail.com>
 <1401988938-25940-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>
To: 'Florian Fainelli' <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38364 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751883AbaFFJa2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 05:30:28 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20892-05 for <netdev@vger.kernel.org>;
 Fri,  6 Jun 2014 10:30:19 +0100 (BST)
In-Reply-To: <1401988938-25940-2-git-send-email-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli
> Our transmit locking scheme did not account for the TX ring full
> interrupt. If a TX ring full interrupt fires while we are attempting to
> transmit, we will cause a deadlock to occur. Fix this by making sure
> that we properly disable interrupts while acquiring the spinlock.

Presumably you mean a 'TX complete' interrupt?

It ought to be possible to arrange the logic so that you don't
need to disable interrupts for the entirety of the tx reclaim 
and tx setup code.

If you have an absolutely accurate count of the number of
tx descriptors required, even the tx setup code probably only needs
the ring's lock while it advances the write pointer.
It can fill in the ring entries after releasing the lock.

	David

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bcmsysport.c | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
> index 25982b02f0ea..4dfc93fe9744 100644
> --- a/drivers/net/ethernet/broadcom/bcmsysport.c
> +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
> @@ -637,10 +637,11 @@ static unsigned int bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
>  					   struct bcm_sysport_tx_ring *ring)
>  {
>  	unsigned int released;
> +	unsigned long flags;
> 
> -	spin_lock(&ring->lock);
> +	spin_lock_irqsave(&ring->lock, flags);
>  	released = __bcm_sysport_tx_reclaim(priv, ring);
> -	spin_unlock(&ring->lock);
> +	spin_unlock_irqrestore(&ring->lock, flags);
> 
>  	return released;
>  }
> @@ -822,6 +823,7 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
>  	struct netdev_queue *txq;
>  	struct dma_desc *desc;
>  	unsigned int skb_len;
> +	unsigned long flags;
>  	dma_addr_t mapping;
>  	u32 len_status;
>  	u16 queue;
> @@ -831,8 +833,8 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
>  	txq = netdev_get_tx_queue(dev, queue);
>  	ring = &priv->tx_rings[queue];
> 
> -	/* lock against tx reclaim in BH context */
> -	spin_lock(&ring->lock);
> +	/* lock against tx reclaim in BH context and TX ring full interrupt */
> +	spin_lock_irqsave(&ring->lock, flags);
>  	if (unlikely(ring->desc_count == 0)) {
>  		netif_tx_stop_queue(txq);
>  		netdev_err(dev, "queue %d awake and ring full!\n", queue);
> @@ -914,7 +916,7 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
> 
>  	ret = NETDEV_TX_OK;
>  out:
> -	spin_unlock(&ring->lock);
> +	spin_unlock_irqrestore(&ring->lock, flags);
>  	return ret;
>  }
> 
> --
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
