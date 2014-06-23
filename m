From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v4] net: ethernet driver: Fujitsu OGMA
Date: Sun, 22 Jun 2014 21:25:39 -0700 (PDT)
Message-ID: <20140622.212539.527240518214265501.davem@davemloft.net>
References: <20140620070921.25956.13507.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com,
	stephen@networkplumber.org, f.fainelli@gmail.com,
	patches@linaro.org, romieu@fr.zoreil.com
To: andy.green@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50727 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbaFWEZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 00:25:41 -0400
In-Reply-To: <20140620070921.25956.13507.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Green <andy.green@linaro.org>
Date: Fri, 20 Jun 2014 15:09:21 +0800

> +	u8 running:1;
> +	u8 full:1;

Please use bool and true/false.

> +	u8 rx_cksum_offload_flag:1;
> +	u8 actual_duplex:1;
> +	u8 irq_registered:1;

Likewise.

> +};
> +
> +
> +static inline void ogma_writel(struct ogma_priv *priv, u32 reg_addr, u32 val)

Please no more than one empty line between top level declarations.

> +static inline void ogma_mark_skb_type(void *skb, bool recv_buf_flag)
> +{
> +	struct sk_buff *skb_p = skb;

There is zero reason to declar 'skb' as a void pointer, "struct sk_buff *"
is fine and all callers pass the proper type.

Furthermore, it is much cleaner to define an explicit skb control block
structure to cast skb->cb to and from.

> +static const u32 ads_irq_set[] = {
> +	OGMA_REG_NRM_TX_INTEN_SET,
> +	OGMA_REG_NRM_RX_INTEN_SET,
> +};
> +static const u32 desc_ring_irq_inten_clr_reg_addr[] = {

One empty line between top-level object declarations.

> +	OGMA_REG_NRM_TX_INTEN_CLR,
> +	OGMA_REG_NRM_RX_INTEN_CLR,
> +};
> +static const u32 int_tmr_reg_addr[] = {

Likewise.

> +	OGMA_REG_NRM_TX_TXINT_TMR,
> +	OGMA_REG_NRM_RX_RXINT_TMR,
> +};
> +static const u32 rx_pkt_cnt_reg_addr[] = {

Likewise.

> +	0,
> +	OGMA_REG_NRM_RX_PKTCNT,
> +};
> +static const u32 tx_pkt_cnt_reg_addr[] = {

Likewise.  etc. there are more such cases, please audit your entire
driver submission for this.

> +int ogma_ring_irq_enable(struct ogma_priv *priv, enum ogma_rings id, u32 irqf)
> +{
> +	struct ogma_desc_ring *desc = &priv->desc_ring[id];
> +	int ret = 0;
> +
> +	spin_lock(&desc->spinlock_desc);
> +
> +	if (!desc->running) {
> +		netif_err(priv, drv, priv->net_device,
> +			  "desc ring not running\n");
> +		ret = -ENODEV;
> +		goto err;
> +	}
> +
> +	ogma_writel(priv, ads_irq_set[id], irqf);
> +
> +err:
> +	spin_unlock(&desc->spinlock_desc);
> +
> +	return ret;
> +}

Taking this lock just for this sanity check is _WAY_ overkill.  Just do the single
atomic register write and that's it.

A 21 line function when a 1 line statement would do... :-/

> +static int alloc_rx_pkt_buf(struct ogma_priv *priv, struct ogma_frag_info *info,
> +			    struct sk_buff **skb)
> +{
> +	*skb = netdev_alloc_skb_ip_align(priv->net_device, info->len);
> +	if (!*skb)
> +		return -ENOMEM;
> +
> +	ogma_mark_skb_type(*skb, OGMA_RING_RX);
> +	info->addr = (*skb)->data;
> +	info->dma_addr = dma_map_single(priv->dev, info->addr, info->len,
> +					DMA_FROM_DEVICE);
> +	if (dma_mapping_error(priv->dev, info->dma_addr)) {
> +		dev_kfree_skb(*skb);
> +		return -ENOMEM;
> +	}
> +
> +	return 0;
> +}

Do not pass pointers to pointers unless absolutely necessary, and here it is
not.  *skb never changes, so just pass plain "struct sk_buff *" and avoid all
of these excess address-of and dereference operations.

> +void ogma_free_desc_ring(struct ogma_priv *priv, struct ogma_desc_ring *desc)
> +{
> +	if (desc->ring_vaddr && desc->frag && desc->priv)
> +		ogma_uninit_pkt_desc_ring(priv, desc);
> +
> +	if (desc->ring_vaddr)
> +		dma_free_coherent(priv->dev, desc->len * DESC_NUM,
> +				  desc->ring_vaddr, desc->desc_phys);
> +	kfree(desc->frag);
> +	kfree(desc->priv);
> +
> +	memset(desc, 0, sizeof(*desc));
> +}

This memset makes no sense, especially as "zero" is not an appropriate initial
state for desc->spinlock_desc.

Just NULL out the items explicitly, one by one, as you free the resources they
point to.

That's much easier to audit than this sledgehammer memset().

> +	de->data_buf_addr = info->dma_addr;
> +	de->buf_len_info = info->len;
> +	de->reserved = 0;
> +	smp_wmb(); /* make sure descriptor body is written */
> +	de->attr = attr; /* write this last */

You need a larger and more detailed comment than this.

Memory barriers must describe exactly what must be seen, in what order,
and by _who_.
