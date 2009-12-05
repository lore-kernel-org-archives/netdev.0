From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
Date: Sun, 06 Dec 2009 07:25:56 +1100
Message-ID: <1260044756.2076.1321.camel@pasglop>
References: <20091204211737.26998.58504.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Asier Llano <a.llano@ziv.es>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, linuxppc-dev@ozlabs.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20091204211737.26998.58504.stgit@angua>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-12-04 at 14:20 -0700, Grant Likely wrote:
> From: Asier Llano Palacios <asierllano@gmail.com>
> 
> net/mpc5200: Fix locking on fec_mpc52xx driver
> 
> Fix the locking scheme on the fec_mpc52xx driver.  This device can
> receive IRQs from three sources; the FEC itself, the tx DMA, and the
> rx DMA.  Mutual exclusion was handled by taking a spin_lock() in the
> critical regions, but because the handlers are run with IRQs enabled,
> spin_lock() is insufficient and the driver can end up interrupting
> a critical region anyway from another IRQ.

 .../...

I would suggest a simpler locking strategy.

The network stack is going to provide you with a lock already which is
the tx queue lock. It's going to be taken for you in start_xmit.

That gives you a simple locking against tx using existing network stack
lock unlock primitives

Everything else should happen within NAPI poll.

The trick then is to not need locking in your interrupt handlers. You
shouldn't need locking to schedule NAPI which is all they should do for
normal tx/rx interrupts. For errors, just kick a workqueue.

>From that work queue, you can stop NAPI and stop the TX while you do
your chip reset etc...

Something like what tg3 does:

static inline void tg3_netif_stop(struct tg3 *tp)
{
        tp->dev->trans_start = jiffies; /* prevent tx timeout */
        tg3_napi_disable(tp);
        netif_tx_disable(tp->dev);
}

You may want to be careful about potential calls to some of your other
network callbacks tho, such as set_multicast.. I don't think the
network stack will shield you there and set_multicast, last I looked,
was called in a context where you can't use a mutex. But that gives you
the basic locking strategy for your driver without adding an unnecessary
spinlock to your fast path.

Cheers,
Ben.

> Asier Llano discovered that this occurs when an error IRQ is raised
> in the middle of handling rx irqs which resulted in an sk_buff memory
> leak.
> 
> In addition, locking is spotty at best in the driver and inspection
> revealed quite a few places with insufficient locking.
> 
> This patch is based on Asier's initial work, but reworks a number of
> things so that locks are held for as short a time as possible, so
> that spin_lock_irqsave() is used everywhere, and so the locks are
> dropped when calling into the network stack (because the lock only
> protects the hardware interface; not the network stack).
> 
> Boot tested on a lite5200 with an NFS root.  Has not been performance
> tested.
> 
> Signed-off-by: Asier Llano <a.llano@ziv.es>
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
> ---
> 
> Asier, can you please test this?  It took me a while to respond to
> your initial post because I was concerned about some of the latency
> issues, and I was concerned about disabling IRQs for long periods in
> the RX handler.  I think it should be good now, but it needs testing.
> 
> Cheers,
> g.
> 
>  drivers/net/fec_mpc52xx.c |  121 +++++++++++++++++++++++----------------------
>  1 files changed, 62 insertions(+), 59 deletions(-)
> 
> diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
> index 66dace6..4889b4d 100644
> --- a/drivers/net/fec_mpc52xx.c
> +++ b/drivers/net/fec_mpc52xx.c
> @@ -85,11 +85,15 @@ MODULE_PARM_DESC(debug, "debugging messages level");
>  
>  static void mpc52xx_fec_tx_timeout(struct net_device *dev)
>  {
> +	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
> +	unsigned long flags;
> +
>  	dev_warn(&dev->dev, "transmit timed out\n");
>  
> +	spin_lock_irqsave(&priv->lock, flags);
>  	mpc52xx_fec_reset(dev);
> -
>  	dev->stats.tx_errors++;
> +	spin_unlock_irqrestore(&priv->lock, flags);
>  
>  	netif_wake_queue(dev);
>  }
> @@ -135,28 +139,32 @@ static void mpc52xx_fec_free_rx_buffers(struct net_device *dev, struct bcom_task
>  	}
>  }
>  
> +static void
> +mpc52xx_fec_rx_submit(struct net_device *dev, struct sk_buff *rskb)
> +{
> +	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
> +	struct bcom_fec_bd *bd;
> +
> +	bd = (struct bcom_fec_bd *) bcom_prepare_next_buffer(priv->rx_dmatsk);
> +	bd->status = FEC_RX_BUFFER_SIZE;
> +	bd->skb_pa = dma_map_single(dev->dev.parent, rskb->data,
> +				    FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
> +	bcom_submit_next_buffer(priv->rx_dmatsk, rskb);
> +}
> +
>  static int mpc52xx_fec_alloc_rx_buffers(struct net_device *dev, struct bcom_task *rxtsk)
>  {
> -	while (!bcom_queue_full(rxtsk)) {
> -		struct sk_buff *skb;
> -		struct bcom_fec_bd *bd;
> +	struct sk_buff *skb;
>  
> +	while (!bcom_queue_full(rxtsk)) {
>  		skb = dev_alloc_skb(FEC_RX_BUFFER_SIZE);
> -		if (skb == NULL)
> +		if (!skb)
>  			return -EAGAIN;
>  
>  		/* zero out the initial receive buffers to aid debugging */
>  		memset(skb->data, 0, FEC_RX_BUFFER_SIZE);
> -
> -		bd = (struct bcom_fec_bd *)bcom_prepare_next_buffer(rxtsk);
> -
> -		bd->status = FEC_RX_BUFFER_SIZE;
> -		bd->skb_pa = dma_map_single(dev->dev.parent, skb->data,
> -				FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
> -
> -		bcom_submit_next_buffer(rxtsk, skb);
> +		mpc52xx_fec_rx_submit(dev, skb);
>  	}
> -
>  	return 0;
>  }
>  
> @@ -328,13 +336,12 @@ static int mpc52xx_fec_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  				    DMA_TO_DEVICE);
>  
>  	bcom_submit_next_buffer(priv->tx_dmatsk, skb);
> +	spin_unlock_irqrestore(&priv->lock, flags);
>  
>  	if (bcom_queue_full(priv->tx_dmatsk)) {
>  		netif_stop_queue(dev);
>  	}
>  
> -	spin_unlock_irqrestore(&priv->lock, flags);
> -
>  	return NETDEV_TX_OK;
>  }
>  
> @@ -359,9 +366,9 @@ static irqreturn_t mpc52xx_fec_tx_interrupt(int irq, void *dev_id)
>  {
>  	struct net_device *dev = dev_id;
>  	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
> +	unsigned long flags;
>  
> -	spin_lock(&priv->lock);
> -
> +	spin_lock_irqsave(&priv->lock, flags);
>  	while (bcom_buffer_done(priv->tx_dmatsk)) {
>  		struct sk_buff *skb;
>  		struct bcom_fec_bd *bd;
> @@ -372,11 +379,10 @@ static irqreturn_t mpc52xx_fec_tx_interrupt(int irq, void *dev_id)
>  
>  		dev_kfree_skb_irq(skb);
>  	}
> +	spin_unlock_irqrestore(&priv->lock, flags);
>  
>  	netif_wake_queue(dev);
>  
> -	spin_unlock(&priv->lock);
> -
>  	return IRQ_HANDLED;
>  }
>  
> @@ -384,67 +390,60 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
>  {
>  	struct net_device *dev = dev_id;
>  	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
> +	struct sk_buff *rskb; /* received sk_buff */
> +	struct sk_buff *skb;  /* new sk_buff to enqueue in its place */
> +	struct bcom_fec_bd *bd;
> +	u32 status, physaddr;
> +	int length;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&priv->lock, flags);
>  
>  	while (bcom_buffer_done(priv->rx_dmatsk)) {
> -		struct sk_buff *skb;
> -		struct sk_buff *rskb;
> -		struct bcom_fec_bd *bd;
> -		u32 status;
>  
>  		rskb = bcom_retrieve_buffer(priv->rx_dmatsk, &status,
> -				(struct bcom_bd **)&bd);
> -		dma_unmap_single(dev->dev.parent, bd->skb_pa, rskb->len,
> -				 DMA_FROM_DEVICE);
> +					    (struct bcom_bd **)&bd);
> +		physaddr = bd->skb_pa;
>  
>  		/* Test for errors in received frame */
>  		if (status & BCOM_FEC_RX_BD_ERRORS) {
>  			/* Drop packet and reuse the buffer */
> -			bd = (struct bcom_fec_bd *)
> -				bcom_prepare_next_buffer(priv->rx_dmatsk);
> -
> -			bd->status = FEC_RX_BUFFER_SIZE;
> -			bd->skb_pa = dma_map_single(dev->dev.parent,
> -					rskb->data,
> -					FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
> -
> -			bcom_submit_next_buffer(priv->rx_dmatsk, rskb);
> -
> +			mpc52xx_fec_rx_submit(dev, rskb);
>  			dev->stats.rx_dropped++;
> -
>  			continue;
>  		}
>  
>  		/* skbs are allocated on open, so now we allocate a new one,
>  		 * and remove the old (with the packet) */
>  		skb = dev_alloc_skb(FEC_RX_BUFFER_SIZE);
> -		if (skb) {
> -			/* Process the received skb */
> -			int length = status & BCOM_FEC_RX_BD_LEN_MASK;
> -
> -			skb_put(rskb, length - 4);	/* length without CRC32 */
> -
> -			rskb->dev = dev;
> -			rskb->protocol = eth_type_trans(rskb, dev);
> -
> -			netif_rx(rskb);
> -		} else {
> +		if (!skb) {
>  			/* Can't get a new one : reuse the same & drop pkt */
> -			dev_notice(&dev->dev, "Memory squeeze, dropping packet.\n");
> +			dev_notice(&dev->dev, "Low memory - dropped packet.\n");
> +			mpc52xx_fec_rx_submit(dev, rskb);
>  			dev->stats.rx_dropped++;
> -
> -			skb = rskb;
> +			continue;
>  		}
>  
> -		bd = (struct bcom_fec_bd *)
> -			bcom_prepare_next_buffer(priv->rx_dmatsk);
> +		/* Enqueue the new sk_buff back on the hardware */
> +		mpc52xx_fec_rx_submit(dev, skb);
>  
> -		bd->status = FEC_RX_BUFFER_SIZE;
> -		bd->skb_pa = dma_map_single(dev->dev.parent, skb->data,
> -				FEC_RX_BUFFER_SIZE, DMA_FROM_DEVICE);
> +		/* Process the received skb - Drop the spin lock while
> +		 * calling into the network stack */
> +		spin_unlock_irqrestore(&priv->lock, flags);
>  
> -		bcom_submit_next_buffer(priv->rx_dmatsk, skb);
> +		dma_unmap_single(dev->dev.parent, physaddr, rskb->len,
> +				 DMA_FROM_DEVICE);
> +		length = status & BCOM_FEC_RX_BD_LEN_MASK;
> +		skb_put(rskb, length - 4);	/* length without CRC32 */
> +		rskb->dev = dev;
> +		rskb->protocol = eth_type_trans(rskb, dev);
> +		netif_rx(rskb);
> +
> +		spin_lock_irqsave(&priv->lock, flags);
>  	}
>  
> +	spin_unlock_irqrestore(&priv->lock, flags);
> +
>  	return IRQ_HANDLED;
>  }
>  
> @@ -454,6 +453,7 @@ static irqreturn_t mpc52xx_fec_interrupt(int irq, void *dev_id)
>  	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
>  	struct mpc52xx_fec __iomem *fec = priv->fec;
>  	u32 ievent;
> +	unsigned long flags;
>  
>  	ievent = in_be32(&fec->ievent);
>  
> @@ -471,9 +471,10 @@ static irqreturn_t mpc52xx_fec_interrupt(int irq, void *dev_id)
>  		if (net_ratelimit() && (ievent & FEC_IEVENT_XFIFO_ERROR))
>  			dev_warn(&dev->dev, "FEC_IEVENT_XFIFO_ERROR\n");
>  
> +		spin_lock_irqsave(&priv->lock, flags);
>  		mpc52xx_fec_reset(dev);
> +		spin_unlock_irqrestore(&priv->lock, flags);
>  
> -		netif_wake_queue(dev);
>  		return IRQ_HANDLED;
>  	}
>  
> @@ -768,6 +769,8 @@ static void mpc52xx_fec_reset(struct net_device *dev)
>  	bcom_enable(priv->tx_dmatsk);
>  
>  	mpc52xx_fec_start(dev);
> +
> +	netif_wake_queue(dev);
>  }
>  
> 
> 
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev
