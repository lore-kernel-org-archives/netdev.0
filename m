From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: add support for STMicroelectronics Ethernet controllers.
Date: Tue, 06 Oct 2009 12:27:33 +0200
Message-ID: <4ACB1B95.4090701@gmail.com>
References: <1254815493-17576-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41550 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757121AbZJFK2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 06:28:12 -0400
In-Reply-To: <1254815493-17576-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Giuseppe CAVALLARO a =E9crit :

> +static int stmmac_sw_tso(struct stmmac_priv *priv, struct sk_buff *s=
kb)
> +{
> +	struct sk_buff *segs, *curr_skb;
> +	int gso_segs =3D skb_shinfo(skb)->gso_segs;
> +
> +	/* Estimate the number of fragments in the worst case */
> +	if (unlikely(stmmac_tx_avail(priv) < gso_segs)) {
> +		netif_stop_queue(priv->dev);
> +		TX_DBG(KERN_ERR "%s: TSO BUG! Tx Ring full when queue awake\n",
> +		       __func__);
> +		if (stmmac_tx_avail(priv) < gso_segs)
> +			return NETDEV_TX_BUSY;
> +
> +		netif_wake_queue(priv->dev);
> +	}
> +	TX_DBG("\tstmmac_sw_tso: segmenting: skb %p (len %d)\n",
> +	       skb, skb->len);
> +
> +	segs =3D skb_gso_segment(skb, priv->dev->features & ~NETIF_F_TSO);
> +	if (unlikely(IS_ERR(segs)))
> +		goto sw_tso_end;
> +
> +	do {
> +		curr_skb =3D segs;
> +		segs =3D segs->next;
> +		TX_DBG("\t\tcurrent skb->len: %d, *curr %p,"
> +		       "*next %p\n", curr_skb->len, curr_skb, segs);
> +		curr_skb->next =3D NULL;
> +		stmmac_xmit(curr_skb, priv->dev);
> +	} while (segs);
> +
> +sw_tso_end:
> +	dev_kfree_skb(skb);
> +	return NETDEV_TX_OK;
> +}

So stmmac_sw_tso() calls stmmac_xmit() for each seg skb.

But stmmac_sw_tso() was called from stmmac_xmit(),
with priv->tx_lock locked, so I suspect something is wrong.

> +/**
> + *  stmmac_xmit:
> + *  @skb : the socket buffer
> + *  @dev : device pointer
> + *  Description : Tx entry point of the driver.
> + */
> +static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_devic=
e *dev)
> +{

=2E..

> +	if (unlikely(!spin_trylock_irqsave(&priv->tx_lock, flags)))
> +		return NETDEV_TX_LOCKED;
=2E..

> +	if (unlikely(skb_is_gso(skb))) {
> +		ret =3D stmmac_sw_tso(priv, skb);
> +		goto end_xmit;
> +	}
> +


Also please change various

+	mac =3D kmalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
+	memset(mac, 0, sizeof(struct mac_device_info));
+

+	mac =3D kmalloc(sizeof(const struct mac_device_info), GFP_KERNEL);
+	memset(mac, 0, sizeof(struct mac_device_info));
+

to use kzalloc(), and of course, you should check kmalloc()/kzalloc() d=
ont return NULL !



Also :

+static int stmmac_clean_tx(struct net_device *dev)
+{
+	struct stmmac_priv *priv =3D netdev_priv(dev);
+	unsigned int txsize =3D priv->dma_tx_size;
+	unsigned long ioaddr =3D dev->base_addr;
+	unsigned int entry =3D priv->dirty_tx % txsize;
+	unsigned int count =3D 0;
+
+	spin_lock(&priv->tx_lock);
+	while (priv->dirty_tx !=3D priv->cur_tx) {
+		int last;
+		struct sk_buff *skb =3D priv->tx_skbuff[entry];
+		struct dma_desc *p =3D priv->dma_tx + entry;
+
+		if (priv->mac_type->ops->get_tx_owner(p))
+			break;
+
+		count++;
+
+		/* verify tx error by looking at the last segment */
+		last =3D priv->mac_type->ops->get_tx_ls(p);
+		if (likely(last)) {
+			int tx_error =3D
+			    priv->mac_type->ops->tx_status(&dev->stats,
+							   &priv->xstats,
+							   p, ioaddr);
+			if (likely(tx_error =3D=3D 0)) {
+				dev->stats.tx_packets++;
+				priv->xstats.tx_pkt_n++;
+			} else
+				dev->stats.tx_errors++;
+		}
+		DBG(intr, DEBUG, "stmmac_tx: curr %d, dirty %d\n",
+		    priv->cur_tx, priv->dirty_tx);
+
+		if (likely(p->des2))
+			dma_unmap_single(priv->device, p->des2,
+					 priv->mac_type->ops->get_tx_len(p),
+					 DMA_TO_DEVICE);
+		if (unlikely(p->des3))
+			p->des3 =3D 0;
+
+		if (skb !=3D NULL) {
+			/*
+			 * If there's room in the queue (limit it to size)
+			 * we add this skb back into the pool,
+			 * if it's the right size.
+			 */
+			if ((skb_queue_len(&priv->rx_recycle) <
+				priv->dma_rx_size) &&
+				skb_recycle_check(skb, priv->dma_buf_sz))
+				__skb_queue_head(&priv->rx_recycle, skb);
+			else
+				dev_kfree_skb_any(skb);

Why call dev_kfree_skb_any() here ? From NAPI context it is overkill.

+
+			priv->tx_skbuff[entry] =3D NULL;
+		}
+
+		priv->mac_type->ops->release_tx_desc(p);
+
+		entry =3D (++priv->dirty_tx) % txsize;
+	}
+	if (unlikely(netif_queue_stopped(dev) &&
+		     stmmac_tx_avail(priv) > (MAX_SKB_FRAGS + 1)))
+		netif_wake_queue(dev);
+
+	spin_unlock(&priv->tx_lock);
+	return count;
+}



static int stmmac_poll(struct napi_struct *napi, int budget)
+{
+	struct stmmac_priv *priv =3D container_of(napi, struct stmmac_priv, n=
api);
+	struct net_device *dev =3D priv->dev;
+	int tx_cleaned =3D 0, work_done =3D 0;
+
+	priv->xstats.poll_n++;
+
+	tx_cleaned =3D stmmac_clean_tx(dev);
+
+	work_done =3D stmmac_rx(dev, budget);
+


+	if (tx_cleaned)
+		return budget;

Why tx_cleaned is used here to exit early ?


+
+	/* If budget not fully consumed, exit the polling mode */
+	if (work_done < budget) {
+		napi_complete(napi);
+		stmmac_dma_enable_irq_rx(dev->base_addr);
+	}
+	return work_done;
+}
+
