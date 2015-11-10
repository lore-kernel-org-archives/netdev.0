From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v5] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Wed, 11 Nov 2015 00:34:48 +0100
Message-ID: <20151110233448.GA8646@electric-eye.fr.zoreil.com>
References: <1447172063-27234-1-git-send-email-mans@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	slash.tmp@free.fr
To: Mans Rullgard <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1447172063-27234-1-git-send-email-mans@mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mans Rullgard <mans@mansr.com> :
> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
> new file mode 100644
> index 0000000..11cd389
> --- /dev/null
> +++ b/drivers/net/ethernet/aurora/nb8800.c
[...]
> +static int nb8800_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
[...]
> +
> +	netdev_sent_queue(dev, skb->len);
> +
> +	smp_mb__before_spinlock();
> +	spin_lock_irqsave(&priv->tx_lock, flags);

At some point you may consider performing both Tx and Rx from napi context
and thus replacing priv->tx_lock with netif_tx_lock.

> +
> +	if (!skb->xmit_more) {
> +		priv->tx_chain->ready = true;
> +		priv->tx_chain = NULL;
> +		nb8800_tx_dma_start(dev);
> +	}
> +
> +	spin_unlock_irqrestore(&priv->tx_lock, flags);
> +
> +	priv->tx_next = next;

Are there strong reasons why nb8800_tx_done could not kick between
spin_unlock_irqrestore and the non-local update of priv->tx_next ?

[...]
> +static irqreturn_t nb8800_irq(int irq, void *dev_id)
> +{
> +	struct net_device *dev = dev_id;
> +	struct nb8800_priv *priv = netdev_priv(dev);
> +	u32 val;
> +
> +	/* tx interrupt */
> +	val = nb8800_readl(priv, NB8800_TXC_SR);
> +	if (val) {
[...]
> +	}
> +
> +	/* rx interrupt */
> +	val = nb8800_readl(priv, NB8800_RXC_SR);
> +	if (val) {
[...]
> +	}
> +
> +	return IRQ_HANDLED;

Returning IRQ_HANDLED is fine if one of those hold:
1. you're sure that at least one of the "if" branch is used
2. you'll be able to quickly figure out what's happening whenever 1. stops
   being true.

-- 
Ueimor
