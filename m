From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Thu, 20 Jan 2011 16:41:45 +0100
Message-ID: <1295538105.2825.308.camel@edumazet-laptop>
References: <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
	 <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 20 janvier 2011 =C3=A0 23:30 +0800, Po-Yu Chuang a =C3=A9crit =
:

> +static bool ftmac100_tx_complete_packet(struct ftmac100 *priv)
> +{
> +	struct net_device *netdev =3D priv->netdev;
> +	struct ftmac100_txdes *txdes;
> +	struct sk_buff *skb;
> +	dma_addr_t map;
> +
> +	if (priv->tx_pending =3D=3D 0)
> +		return false;
> +
> +	txdes =3D ftmac100_current_clean_txdes(priv);
> +
> +	if (ftmac100_txdes_owned_by_dma(txdes))
> +		return false;
> +
> +	skb =3D ftmac100_txdes_get_skb(txdes);
> +	map =3D ftmac100_txdes_get_dma_addr(txdes);
> +
> +	if (unlikely(ftmac100_txdes_excessive_collision(txdes) ||
> +		     ftmac100_txdes_late_collision(txdes))) {
> +		/*
> +		 * packet transmitted to ethernet lost due to late collision
> +		 * or excessive collision
> +		 */
> +		netdev->stats.tx_aborted_errors++;
> +	} else {
> +		netdev->stats.tx_packets++;
> +		netdev->stats.tx_bytes +=3D skb->len;
> +	}
> +
> +	dma_unmap_single(priv->dev, map, skb_headlen(skb), DMA_TO_DEVICE);
> +
> +	dev_kfree_skb_irq(skb);
> +
> +	ftmac100_txdes_reset(txdes);
> +
> +	ftmac100_tx_clean_pointer_advance(priv);
> +
> +	priv->tx_pending--;
> +	netif_wake_queue(netdev);
> +
> +	return true;
> +}
> +
> +static void ftmac100_tx_complete(struct ftmac100 *priv)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&priv->tx_lock, flags);
> +	while (ftmac100_tx_complete_packet(priv))
> +		;
> +	spin_unlock_irqrestore(&priv->tx_lock, flags);
> +}
> +

I dont understand why you still block hard IRQS, after full NAPI
conversion.

Now you run from NAPI, and softirq handler, are you sure you still need
to block hard IRQ and tx_lock ?

It seems to me ftmac100_xmit() could only block softirqs (but they
already are blocked by caller), so you could use spin_lock() from
ftmac100_xmit()
