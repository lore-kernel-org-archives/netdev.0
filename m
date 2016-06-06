From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/5] ethernet: add sun8i-emac driver
Date: Mon, 6 Jun 2016 11:25:15 -0700
Message-ID: <5755C00B.2040203@gmail.com>
References: <1464947790-22991-1-git-send-email-clabbe.montjoie@gmail.com>
 <1464947790-22991-2-git-send-email-clabbe.montjoie@gmail.com>
Reply-To: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
 pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
 galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
 linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-sunxi+bncBCH67JWTV4DBBD4A265AKGQEI3WH4ZY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <1464947790-22991-2-git-send-email-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On 06/03/2016 02:56 AM, LABBE Corentin wrote:
> This patch add support for sun8i-emac ethernet MAC hardware.
> It could be found in Allwinner H3/A83T/A64 SoCs.
> 
> It supports 10/100/1000 Mbit/s speed with half/full duplex.
> It can use an internal PHY (MII 10/100) or an external PHY
> via RGMII/RMII.
> 
> Signed-off-by: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---

[snip]

> +
> +struct ethtool_str {
> +	char name[ETH_GSTRING_LEN];

You might as well drop the encapsulating structure and just use an array
of strings?

> +};
> +

[snip]

> +
> +/* The datasheet said that each descriptor can transfers up to 4096bytes
> + * But latter, a register documentation reduce that value to 2048
> + * Anyway using 2048 cause strange behaviours and even BSP driver use 2047
> + */
> +#define DESC_BUF_MAX 2044
> +#if (DESC_BUF_MAX < (ETH_FRAME_LEN + 4))
> +#error "DESC_BUF_MAX must be set at minimum to ETH_FRAME_LEN + 4"
> +#endif

You can probably drop that, it would not make much sense to enable
fragments and a buffer size smaller than ETH_FRAME_LEN + ETH_FCS_LEN anyway.

> +
> +/* MAGIC value for knowing if a descriptor is available or not */
> +#define DCLEAN (BIT(16) | BIT(14) | BIT(12) | BIT(10) | BIT(9))
> +
> +/* Structure of DMA descriptor used by the hardware  */
> +struct dma_desc {
> +	u32 status; /* status of the descriptor */
> +	u32 st; /* Information on the frame */
> +	u32 buf_addr; /* physical address of the frame data */
> +	u32 next; /* physical address of next dma_desc */
> +} __packed __aligned(4);

This has been noticed in other emails, no need for the __packed here,
they are all naturally aligned.

> +
> +/* Benched on OPIPC with 100M, setting more than 256 does not give any
> + * perf boost
> + */
> +static int nbdesc_tx = 256;
> +module_param(nbdesc_tx, int, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(nbdesc_tx, "Number of descriptors in the TX list");
> +static int nbdesc_rx = 128;
> +module_param(nbdesc_rx, int, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(nbdesc_rx, "Number of descriptors in the RX list");

This needs to be statically defined to begin driver operation with, and
then implement the ethtool operations to re-size the rings would you
want that.

[snip]

> +/* Return the number of contiguous free descriptors
> + * starting from tx_slot
> + */
> +static int rb_tx_numfreedesc(struct net_device *ndev)
> +{
> +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> +
> +	if (priv->tx_slot < priv->tx_dirty)
> +		return priv->tx_dirty - priv->tx_slot;

Does this work with if tx_dirty wraps around?

> +
> +	return (nbdesc_tx - priv->tx_slot) + priv->tx_dirty;
> +}
> +
> +/* Allocate a skb in a DMA descriptor
> + *
> + * @i index of slot to fill
> +*/
> +static int sun8i_emac_rx_sk(struct net_device *ndev, int i)
> +{
> +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> +	struct dma_desc *ddesc;
> +	struct sk_buff *sk;

The networking stack typically refers to "sk" as socket and skb as
socket buffers.

> +
> +	ddesc = priv->dd_rx + i;
> +
> +	ddesc->st = 0;
> +
> +	sk = netdev_alloc_skb_ip_align(ndev, DESC_BUF_MAX);
> +	if (!sk)
> +		return -ENOMEM;
> +
> +	/* should not happen */
> +	if (unlikely(priv->rx_sk[i]))
> +		dev_warn(priv->dev, "BUG: Leaking a skbuff\n");
> +
> +	priv->rx_sk[i] = sk;
> +
> +	ddesc->buf_addr = dma_map_single(priv->dev, sk->data,
> +					 DESC_BUF_MAX, DMA_FROM_DEVICE);
> +	if (dma_mapping_error(priv->dev, ddesc->buf_addr)) {
> +		dev_err(priv->dev, "ERROR: Cannot dma_map RX buffer\n");
> +		dev_kfree_skb(sk);
> +		return -EFAULT;
> +	}
> +	ddesc->st |= DESC_BUF_MAX;
> +	ddesc->status = BIT(31);

You are missing a lightweight barrier here to ensure there is no
re-ordering done by the compiler in how you write to the descriptors in
DRAM, even though they are allocated from dma_alloc_coherent().

[snip]

> +static void sun8i_emac_set_link_mode(struct sun8i_emac_priv *priv)
> +{
> +	u32 v;
> +
> +	v = readl(priv->base + SUN8I_EMAC_BASIC_CTL0);
> +
> +	if (priv->duplex)
> +		v |= BIT(0);
> +	else
> +		v &= ~BIT(0);
> +
> +	v &= ~0x0C;
> +	switch (priv->speed) {
> +	case 1000:
> +		break;
> +	case 100:
> +		v |= BIT(2);
> +		v |= BIT(3);
> +		break;
> +	case 10:
> +		v |= BIT(3);
> +		break;
> +	}

Proper defines for all of these bits and masks?

> +
> +	writel(v, priv->base + SUN8I_EMAC_BASIC_CTL0);
> +}
> +
> +static void sun8i_emac_flow_ctrl(struct sun8i_emac_priv *priv, int duplex,
> +				 int fc, int pause)
> +{
> +	u32 flow = 0;

pause is unused (outside of printing it) here

> +
> +	netif_dbg(priv, link, priv->ndev, "%s %d %d %d\n", __func__,
> +		  duplex, fc, pause);
> +
> +	flow = readl(priv->base + SUN8I_EMAC_RX_CTL0);
> +	if (fc & FLOW_RX)
> +		flow |= BIT(16);
> +	else
> +		flow &= ~BIT(16);
> +	writel(flow, priv->base + SUN8I_EMAC_RX_CTL0);
> +
> +	flow = readl(priv->base + SUN8I_EMAC_TX_FLOW_CTL);
> +	if (fc & FLOW_TX)
> +		flow |= BIT(0);
> +	else
> +		flow &= ~BIT(0);
> +	writel(flow, priv->base + SUN8I_EMAC_TX_FLOW_CTL);
> +}
> +
> +/* Grab a frame into a skb from descriptor number i */
> +static int sun8i_emac_rx_from_ddesc(struct net_device *ndev, int i)
> +{
> +	struct sk_buff *skb;
> +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> +	struct dma_desc *ddesc = priv->dd_rx + i;
> +	int frame_len;
> +	int crc_checked = 0;
> +
> +	if (ndev->features & NETIF_F_RXCSUM)
> +		crc_checked = 1;

Assuming CRC here refers to the Ethernet frame's FCS, then this is
absolutely not how NETIF_F_RXCSUM works. NETIF_F_RXCSUM is about your
Ethernet adapter supporting L3/L4 checksum offloads, while the Ethernet
FCS is pretty much mandatory for the frame to be properly received in
the first place. Can you clarify which way it is?

> +
> +	/* bit0/bit7 work only on IPv4/IPv6 TCP traffic,
> +	 * (not on ARP for example) so we dont raise rx_errors/discard frame
> +	 */
> +	/* the checksum or length of received frame's payload is wrong*/
> +	if (ddesc->status & BIT(0)) {
> +		priv->estats.rx_payload_error++;
> +		crc_checked = 0;
> +	}
> +	if (ddesc->status & BIT(1)) {
> +		priv->ndev->stats.rx_errors++;
> +		priv->ndev->stats.rx_crc_errors++;
> +		priv->estats.rx_crc_error++;
> +		goto discard_frame;
> +	}
> +	if ((ddesc->status & BIT(3))) {
> +		priv->ndev->stats.rx_errors++;
> +		priv->estats.rx_phy_error++;
> +		goto discard_frame;
> +	}
> +	if ((ddesc->status & BIT(4))) {
> +		priv->ndev->stats.rx_errors++;
> +		priv->ndev->stats.rx_length_errors++;
> +		priv->estats.rx_length_error++;
> +		goto discard_frame;
> +	}
> +	if ((ddesc->status & BIT(6))) {
> +		priv->ndev->stats.rx_errors++;
> +		priv->estats.rx_col_error++;
> +		goto discard_frame;
> +	}
> +	if ((ddesc->status & BIT(7))) {
> +		priv->estats.rx_header_error++;
> +		crc_checked = 0;
> +	}
> +	if ((ddesc->status & BIT(11))) {
> +		priv->ndev->stats.rx_over_errors++;
> +		priv->estats.rx_overflow_error++;
> +		goto discard_frame;
> +	}
> +	if ((ddesc->status & BIT(14))) {
> +		priv->ndev->stats.rx_errors++;
> +		priv->estats.rx_buf_error++;
> +		goto discard_frame;
> +	}

Please define what these bits are.

> +
> +	if ((ddesc->status & BIT(9)) == 0) {
> +		/* begin of a Jumbo frame */
> +		dev_warn(priv->dev, "This should not happen\n");
> +		goto discard_frame;
> +	}

This should be ratelimited at the very least, if there is a mis
configuration, chances are that you could see this happen fairly often.

> +	frame_len = (ddesc->status >> 16) & 0x3FFF;
> +	if (!(ndev->features & NETIF_F_RXFCS))
> +		frame_len -= ETH_FCS_LEN;
> +
> +	skb = priv->rx_sk[i];
> +
> +	netif_dbg(priv, rx_status, priv->ndev,
> +		  "%s from %02d %pad len=%d status=%x st=%x\n",
> +		  __func__, i, &ddesc, frame_len, ddesc->status, ddesc->st);
> +
> +	skb_put(skb, frame_len);
> +
> +	dma_unmap_single(priv->dev, ddesc->buf_addr, DESC_BUF_MAX,
> +			 DMA_FROM_DEVICE);
> +	skb->protocol = eth_type_trans(skb, priv->ndev);
> +	if (crc_checked) {
> +		skb->ip_summed = CHECKSUM_UNNECESSARY;
> +		priv->estats.rx_hw_csum++;
> +	} else {
> +		skb->ip_summed = CHECKSUM_PARTIAL;
> +	}
> +	skb->dev = priv->ndev;

eth_type_trans() already does that.

> +
> +	priv->ndev->stats.rx_packets++;
> +	priv->ndev->stats.rx_bytes += frame_len;
> +	priv->rx_sk[i] = NULL;
> +
> +	/* this frame is not the last */
> +	if ((ddesc->status & BIT(8)) == 0) {
> +		dev_warn(priv->dev, "Multi frame not implemented currlen=%d\n",
> +			 frame_len);
> +	}
> +
> +	sun8i_emac_rx_sk(ndev, i);
> +
> +	netif_rx(skb);

netif_receive_skb() at the very least, or if you implement NAPI, like
you shoud napi_gro_receive().

> +
> +	return 0;
> +	/* If the frame need to be dropped, we simply reuse the buffer */
> +discard_frame:
> +	ddesc->st = DESC_BUF_MAX;
> +	ddesc->status = BIT(31);

Same here, there does not seem to be any barrier to ensure proper ordering.

> +	return 0;
> +}
> +
> +/* Cycle over RX DMA descriptors for finding frame to receive
> + */
> +static int sun8i_emac_receive_all(struct net_device *ndev)
> +{
> +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> +	struct dma_desc *ddesc;
> +
> +	ddesc = priv->dd_rx + priv->rx_dirty;
> +	while (!(ddesc->status & BIT(31))) {
> +		sun8i_emac_rx_from_ddesc(ndev, priv->rx_dirty);
> +		rb_inc(&priv->rx_dirty, nbdesc_rx);
> +		ddesc = priv->dd_rx + priv->rx_dirty;
> +	};

So, what if we ping flood your device here, is not there a remote chance
that we keep the RX interrupt so busy we can't break out of this loop,
and we are executing from hard IRQ context, that's bad.

> +
> +	return 0;
> +}
> +
> +/* iterate over dma_desc for finding completed xmit.
> + * Called from interrupt context, so no need to spinlock tx

Humm, well it depends if what you are doing here may race with
ndo_start_xmit(), and usually it does.

Also, you should consider completing TX packets in NAPI context (soft
IRQ) instead of hard IRQs like here.

[snip]

> +static int sun8i_emac_mdio_register(struct net_device *ndev)
> +{
> +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> +	struct mii_bus *bus;
> +	int ret;
> +
> +	bus = devm_mdiobus_alloc(priv->dev);
> +	if (!bus) {
> +		netdev_err(ndev, "Failed to allocate new mdio bus\n");
> +		return -ENOMEM;
> +	}
> +
> +	bus->name = dev_name(priv->dev);
> +	bus->read = &sun8i_mdio_read;
> +	bus->write = &sun8i_mdio_write;
> +	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-%x", bus->name, 0);

If there are two of these adapters or more you will start seeing
conflicts, give this a better unique name that uses pdev->id or
something like that.

> +
> +	bus->parent = priv->dev;
> +	bus->priv = ndev;
> +
> +	ret = of_mdiobus_register(bus, priv->dev->of_node);
> +	if (ret) {
> +		netdev_err(ndev, "Could not register as MDIO bus: %d\n", ret);
> +		return ret;
> +	}
> +
> +	priv->mdio = bus;
> +
> +	return 0;
> +}
> +
> +static void sun8i_emac_adjust_link(struct net_device *ndev)
> +{
> +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> +	struct phy_device *phydev = ndev->phydev;
> +	unsigned long flags;
> +	int new_state = 0;
> +
> +	netif_dbg(priv, link, priv->ndev,
> +		  "%s link=%x duplex=%x speed=%x\n", __func__,
> +		  phydev->link, phydev->duplex, phydev->speed);
> +	if (!phydev)
> +		return;
> +
> +	spin_lock_irqsave(&priv->lock, flags);

You are executing under the phydev->lock mutex already, what is this
achieving?

[snip]


> +	priv->tx_slot = 0;
> +	priv->tx_dirty = 0;
> +	priv->rx_dirty = 0;
> +
> +	priv->rx_sk = kcalloc(nbdesc_rx, sizeof(struct sk_buff *), GFP_KERNEL);
> +	if (!priv->rx_sk) {
> +		err = -ENOMEM;
> +		goto rx_sk_error;
> +	}
> +	priv->tx_sk = kcalloc(nbdesc_tx, sizeof(struct sk_buff *), GFP_KERNEL);
> +	if (!priv->tx_sk) {
> +		err = -ENOMEM;
> +		goto tx_sk_error;
> +	}
> +	priv->tx_map = kcalloc(nbdesc_tx, sizeof(int), GFP_KERNEL);
> +	if (!priv->tx_map) {
> +		err = -ENOMEM;
> +		goto tx_map_error;
> +	}

You are allocating two arrays of the same size, why not combine them
into a single one which holds both the tx_sk and the tx_map?

> +
> +	priv->dd_rx = dma_alloc_coherent(priv->dev,
> +			nbdesc_rx * sizeof(struct dma_desc),
> +			&priv->dd_rx_phy,
> +			GFP_KERNEL);
> +	if (!priv->dd_rx) {
> +		dev_err(priv->dev, "ERROR: cannot DMA RX");
> +		err = -ENOMEM;
> +		goto dma_rx_error;
> +	}
> +	memset(priv->dd_rx, 0, nbdesc_rx * sizeof(struct dma_desc));
> +	ddesc = priv->dd_rx;
> +	for (i = 0; i < nbdesc_rx; i++) {
> +		sun8i_emac_rx_sk(ndev, i);
> +		ddesc->next = (u32)priv->dd_rx_phy + (i + 1)
> +			* sizeof(struct dma_desc);
> +		ddesc++;
> +	}
> +	/* last descriptor point back to first one */
> +	ddesc--;
> +	ddesc->next = (u32)priv->dd_rx_phy;

So is there a limitation of this hardware that can only do DMA within
the first 4GB of the system?

> +
> +	priv->dd_tx = dma_alloc_coherent(priv->dev,
> +			nbdesc_tx * sizeof(struct dma_desc),
> +			&priv->dd_tx_phy,
> +			GFP_KERNEL);
> +	if (!priv->dd_tx) {
> +		dev_err(priv->dev, "ERROR: cannot DMA TX");
> +		err = -ENOMEM;
> +		goto dma_tx_error;
> +	}
> +	memset(priv->dd_tx, 0, nbdesc_tx * sizeof(struct dma_desc));

dma_zalloc_coherent()?

> +	ddesc = priv->dd_tx;
> +	for (i = 0; i < nbdesc_tx; i++) {
> +		ddesc->status = DCLEAN;
> +		ddesc->st = 0;
> +		ddesc->next = (u32)(priv->dd_tx_phy + (i + 1)
> +			* sizeof(struct dma_desc));
> +		ddesc++;
> +	}
> +	/* last descriptor point back to first one */
> +	ddesc--;
> +	ddesc->next = (u32)priv->dd_tx_phy;
> +	i--;
> +
> +	if (ndev->phydev)
> +		phy_start(ndev->phydev);

You can't get here without a valid phydev pointer.

[snip]

> +static int sun8i_emac_stop(struct net_device *ndev)
> +{
> +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> +	int i;
> +	struct dma_desc *ddesc;
> +
> +	/* Stop receiver */
> +	writel(0, priv->base + SUN8I_EMAC_RX_CTL0);
> +	writel(0, priv->base + SUN8I_EMAC_RX_CTL1);
> +	/* Stop transmitter */
> +	writel(0, priv->base + SUN8I_EMAC_TX_CTL0);
> +	writel(0, priv->base + SUN8I_EMAC_TX_CTL1);
> +
> +	netif_stop_queue(ndev);
> +	netif_carrier_off(ndev);

phy_stop() does that.

> +
> +	phy_stop(ndev->phydev);
> +	phy_disconnect(ndev->phydev);
> +
> +	/* clean RX ring */
> +	for (i = 0; i < nbdesc_rx; i++)
> +		if (priv->rx_sk[i]) {
> +			ddesc = priv->dd_rx + i;
> +			dma_unmap_single(priv->dev, ddesc->buf_addr,
> +					 DESC_BUF_MAX, DMA_FROM_DEVICE);
> +			dev_kfree_skb_any(priv->rx_sk[i]);
> +			priv->rx_sk[i] = NULL;
> +		}
> +	sun8i_emac_tx_clean(ndev);
> +
> +	kfree(priv->rx_sk);
> +	kfree(priv->tx_sk);
> +	kfree(priv->tx_map);
> +
> +	dma_free_coherent(priv->dev, nbdesc_rx * sizeof(struct dma_desc),
> +			  priv->dd_rx, priv->dd_rx_phy);
> +	dma_free_coherent(priv->dev, nbdesc_tx * sizeof(struct dma_desc),
> +			  priv->dd_tx, priv->dd_tx_phy);
> +
> +	return 0;
> +}
> +
> +static netdev_tx_t sun8i_emac_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> +	struct dma_desc *ddesc;
> +	struct dma_desc *first;
> +	int i = 0, rbd_first;
> +	unsigned int len, fraglen;
> +	u32 v;
> +	int n;
> +	int nf;
> +	const skb_frag_t *frag;
> +	int do_csum = 0;
> +
> +	len = skb_headlen(skb);
> +	if (len < ETH_ZLEN) {
> +		if (skb_padto(skb, ETH_ZLEN))
> +			return NETDEV_TX_OK;
> +		len = ETH_ZLEN;
> +	}

skb_put_padto() would be able to do a bit of that.

> +	n = skb_shinfo(skb)->nr_frags;
> +
> +	if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +		do_csum = 1;
> +		priv->estats.tx_hw_csum++;
> +	}
> +	netif_dbg(priv, tx_queued, ndev, "%s len=%u skblen=%u %x\n", __func__,
> +		  len, skb->len,
> +		  (skb->ip_summed == CHECKSUM_PARTIAL));
> +
> +	spin_lock(&priv->tx_lock);
> +
> +	/* check for contigous space
> +	 * We need at least 1(skb->data) + n(numfrags) + 1(one clean slot)
> +	 */
> +	if (rb_tx_numfreedesc(ndev) < n + 2) {
> +		dev_err_ratelimited(priv->dev, "BUG!: TX is full %d %d\n",
> +				    priv->tx_dirty, priv->tx_slot);
> +		netif_stop_queue(ndev);
> +		spin_unlock(&priv->tx_lock);
> +		return NETDEV_TX_BUSY;
> +	}
> +	i = priv->tx_slot;
> +
> +	ddesc = priv->dd_tx + i;
> +	first = priv->dd_tx + i;
> +	rbd_first = i;
> +
> +	priv->tx_slot = (i + 1 + n) % nbdesc_tx;
> +
> +	ddesc->buf_addr = dma_map_single(priv->dev, skb->data, len,
> +					 DMA_TO_DEVICE);
> +	if (dma_mapping_error(priv->dev, ddesc->buf_addr)) {
> +		dev_err(priv->dev, "ERROR: Cannot dmamap buf\n");
> +		goto xmit_error;
> +	}
> +	priv->tx_map[i] = MAP_SINGLE;
> +	priv->tx_sk[i] = skb;
> +	priv->ndev->stats.tx_packets++;
> +	priv->ndev->stats.tx_bytes += len;

You should not increment stats until you had a schance to complete the
actual transmission of the packets, there could be many reasons why
these are not transmited.

> +
> +	ddesc->st = len;
> +	/* undocumented bit that make it works */
> +	ddesc->st |= BIT(24);
> +	if (do_csum)
> +		ddesc->st |= SUN8I_EMAC_TX_DO_CRC;

Missing barriers.

> +
> +	/* handle fragmented skb, one descriptor per fragment  */
> +	for (nf = 0; nf < n; nf++) {
> +		frag = &skb_shinfo(skb)->frags[nf];
> +		rb_inc(&i, nbdesc_tx);
> +		priv->tx_sk[i] = skb;
> +		ddesc = priv->dd_tx + i;
> +		fraglen = skb_frag_size(frag);
> +		ddesc->st = fraglen;
> +		priv->ndev->stats.tx_bytes += fraglen;
> +		ddesc->st |= BIT(24);
> +		if (do_csum)
> +			ddesc->st |= SUN8I_EMAC_TX_DO_CRC;
> +
> +		ddesc->buf_addr = skb_frag_dma_map(priv->dev, frag, 0,
> +				fraglen, DMA_TO_DEVICE);
> +		if (dma_mapping_error(priv->dev, ddesc->buf_addr)) {
> +			dev_err(priv->dev, "DMA MAP ERROR\n");
> +			goto xmit_error;
> +		}
> +		priv->tx_map[i] = MAP_PAGE;
> +		ddesc->status = BIT(31);
> +	}
> +
> +	/* frame end */
> +	ddesc->st |= BIT(30);
> +	/* We want an interrupt after transmission */
> +	ddesc->st |= BIT(31);
> +
> +	rb_inc(&i, nbdesc_tx);
> +
> +	/* frame begin */
> +	first->st |= BIT(29);
> +	first->status = BIT(31);
> +	priv->tx_slot = i;
> +
> +	/* Trying to optimize this (recording DMA start/stop) seems
> +	 * to lead to errors. So we always start DMA.
> +	 */
> +	v = readl(priv->base + SUN8I_EMAC_TX_CTL1);
> +	/* TX DMA START */
> +	v |= BIT(31);
> +	/* Start an run DMA */
> +	v |= BIT(30);
> +	writel(v, priv->base + SUN8I_EMAC_TX_CTL1);
> +
> +	if (rb_tx_numfreedesc(ndev) < MAX_SKB_FRAGS + 1) {
> +		netif_stop_queue(ndev);
> +		priv->estats.tx_stop_queue++;
> +	}
> +	priv->estats.tx_used_desc = rb_tx_numfreedesc(ndev);
> +
> +	spin_unlock(&priv->tx_lock);
> +
> +	return NETDEV_TX_OK;
> +
> +xmit_error:
> +	/* destroy skb and return TX OK Documentation/DMA-API-HOWTO.txt */
> +	/* clean descritors from rbd_first to i */
> +	ddesc->st = 0;
> +	ddesc->status = DCLEAN;
> +	do {
> +		ddesc = priv->dd_tx + rbd_first;
> +		ddesc->st = 0;
> +		ddesc->status = DCLEAN;
> +		rb_inc(&rbd_first, nbdesc_tx);
> +	} while (rbd_first != i);
> +	spin_unlock(&priv->tx_lock);
> +	dev_kfree_skb_any(skb);
> +	return NETDEV_TX_OK;
> +}
> +

[snip]

> +
> +static int sun8i_emac_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
> +{
> +	struct phy_device *phydev = ndev->phydev;
> +
> +	if (!netif_running(ndev))
> +		return -EINVAL;
> +
> +	if (!phydev)
> +		return -ENODEV;

You don't allow your MDIO probe function not to have a phydev so this
cannot really happen by the time you are here?

> +
> +	return phy_mii_ioctl(phydev, rq, cmd);
> +}
> +
> +static int sun8i_emac_check_if_running(struct net_device *ndev)
> +{
> +	if (!netif_running(ndev))
> +		return -EBUSY;

This does not seem like the intended usage of a

> +	return 0;
> +}
> +
> +static int sun8i_emac_get_sset_count(struct net_device *ndev, int sset)
> +{
> +	switch (sset) {
> +	case ETH_SS_STATS:
> +		return ARRAY_SIZE(estats_str);
> +	}
> +	return -EOPNOTSUPP;
> +}
> +
> +static int sun8i_emac_ethtool_get_settings(struct net_device *ndev,
> +					   struct ethtool_cmd *cmd)
> +{
> +	struct phy_device *phy = ndev->phydev;
> +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> +
> +	if (!phy) {
> +		netdev_err(ndev, "%s: %s: PHY is not registered\n",
> +			   __func__, ndev->name);
> +		return -ENODEV;
> +	}
> +
> +	if (!netif_running(ndev)) {
> +		dev_err(priv->dev, "interface disabled: we cannot track link speed / duplex setting\n");
> +		return -EBUSY;
> +	}
> +
> +	cmd->transceiver = XCVR_INTERNAL;

If you write a PHY driver for the internal PHY, and set PHY_IS_INTERNAL
in the flags of that driver (see bcm63xx.c and bcm7xxx.c in
drivers/net/phy/*), this is set automatically by the core PHYLIB code.

> +	return phy_ethtool_gset(phy, cmd);
> +}
> +

[snip]

> +
> +static void sun8i_emac_get_pauseparam(struct net_device *ndev,
> +				      struct ethtool_pauseparam *pause)
> +{
> +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> +
> +	pause->rx_pause = 0;
> +	pause->tx_pause = 0;
> +	pause->autoneg = ndev->phydev->autoneg;
> +
> +	if (priv->flow_ctrl & FLOW_RX)
> +		pause->rx_pause = 1;
> +	if (priv->flow_ctrl & FLOW_TX)
> +		pause->tx_pause = 1;
> +}
> +
> +static int sun8i_emac_set_pauseparam(struct net_device *ndev,
> +				     struct ethtool_pauseparam *pause)
> +{
> +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> +	struct phy_device *phy = ndev->phydev;
> +	int new_pause = 0;
> +	int ret = 0;
> +
> +	if (pause->rx_pause)
> +		new_pause |= FLOW_RX;
> +	if (pause->tx_pause)
> +		new_pause |= FLOW_TX;
> +
> +	priv->flow_ctrl = new_pause;
> +	phy->autoneg = pause->autoneg;
> +
> +	if (phy->autoneg) {
> +		if (netif_running(ndev))
> +			ret = phy_start_aneg(phy);
> +	} else {
> +		sun8i_emac_flow_ctrl(priv, phy->duplex, priv->flow_ctrl,
> +				     priv->pause);
> +	}
> +	return ret;
> +}
> +
> +static const struct ethtool_ops sun8i_emac_ethtool_ops = {
> +	.begin = sun8i_emac_check_if_running,
> +	.get_settings = sun8i_emac_ethtool_get_settings,
> +	.set_settings = sun8i_emac_ethtool_set_settings,
> +	.get_link = ethtool_op_get_link,
> +	.get_pauseparam = sun8i_emac_get_pauseparam,
> +	.set_pauseparam = sun8i_emac_set_pauseparam,
> +	.get_ethtool_stats = sun8i_emac_ethtool_stats,
> +	.get_strings = sun8i_emac_ethtool_strings,
> +	.get_wol = NULL,
> +	.set_wol = NULL,

Not necessary

> +	.get_sset_count = sun8i_emac_get_sset_count,
> +	.get_drvinfo = sun8i_emac_ethtool_getdrvinfo,
> +	.get_msglevel = sun8i_emac_ethtool_getmsglevel,
> +	.set_msglevel = sun8i_emac_ethtool_setmsglevel,
> +};
> +
> +static const struct net_device_ops sun8i_emac_netdev_ops = {
> +	.ndo_init = sun8i_emac_init,
> +	.ndo_uninit = sun8i_emac_uninit,
> +	.ndo_open = sun8i_emac_open,
> +	.ndo_start_xmit = sun8i_emac_xmit,
> +	.ndo_stop = sun8i_emac_stop,
> +	.ndo_change_mtu = sun8i_emac_change_mtu,
> +	.ndo_fix_features = sun8i_emac_fix_features,
> +	.ndo_set_rx_mode = sun8i_emac_set_rx_mode,
> +	.ndo_tx_timeout = sun8i_emac_tx_timeout,
> +	.ndo_do_ioctl = sun8i_emac_ioctl,
> +	.ndo_set_mac_address = eth_mac_addr,
> +	.ndo_set_features = sun8i_emac_set_features,
> +};
> +
> +static irqreturn_t sun8i_emac_dma_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *ndev = (struct net_device *)dev_id;

No need for a cast here.

> +	struct sun8i_emac_priv *priv = netdev_priv(ndev);
> +	u32 v, u;
> +
> +	v = readl(priv->base + SUN8I_EMAC_INT_STA);
> +
> +	netif_info(priv, intr, ndev, "%s %x\n", __func__, v);

This is a fastpath, you would want something that does not have to test
against netif_msg_##type at all here.

> +
> +	/* When this bit is asserted, a frame transmission is completed. */
> +	if (v & BIT(0))
> +		sun8i_emac_complete_xmit(ndev);
> +
> +	/* When this bit is asserted, the TX DMA FSM is stopped. */
> +	if (v & BIT(1))
> +		priv->estats.tx_dma_stop++;
> +
> +	/* When this asserted, the TX DMA can not acquire next TX descriptor
> +	 * and TX DMA FSM is suspended.
> +	*/
> +	if (v & BIT(2))
> +		priv->estats.tx_dma_ua++;
> +
> +	if (v & BIT(3))
> +		netif_dbg(priv, intr, ndev, "Unhandled interrupt TX TIMEOUT\n");
> +
> +	if (v & BIT(4)) {
> +		netif_dbg(priv, intr, ndev, "Unhandled interrupt TX underflow\n");
> +		priv->estats.tx_underflow_int++;
> +	}
> +
> +	/* When this bit asserted , the frame is transmitted to FIFO totally. */
> +	if (v & BIT(5)) {
> +		netif_dbg(priv, intr, ndev, "Unhandled interrupt TX_EARLY_INT\n");
> +		priv->estats.tx_early_int++;
> +	}
> +
> +	/* When this bit is asserted, a frame reception is completed  */
> +	if (v & BIT(8))
> +		sun8i_emac_receive_all(ndev);

Can we get proper definitions for each and every one of these bits?

[snip]

> +
> +	ndev = alloc_etherdev(sizeof(*priv));
> +	if (!ndev)
> +		return -ENOMEM;
> +
> +	SET_NETDEV_DEV(ndev, &pdev->dev);
> +	priv = netdev_priv(ndev);
> +	platform_set_drvdata(pdev, ndev);
> +
> +	priv->variant = (enum emac_variant)of_device_get_match_data(&pdev->dev);

Should not we still test if the of_device_id's data member has been set,
if you later add a new member to the compatible list with an absent
.data member won't this crash?

> +
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	priv->base = devm_ioremap_resource(&pdev->dev, res);
> +	if (IS_ERR(priv->base)) {
> +		ret = PTR_ERR(priv->base);
> +		dev_err(&pdev->dev, "Cannot request MMIO: %d\n", ret);
> +		goto probe_err;
> +	}
> +
> +	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "syscon");
> +	priv->syscon = devm_ioremap_resource(&pdev->dev, res);
> +	if (IS_ERR(priv->syscon)) {
> +		ret = PTR_ERR(priv->syscon);
> +		dev_err(&pdev->dev,
> +			"Cannot map system control registers: %d\n", ret);
> +		goto probe_err;
> +	}
> +
> +	priv->irq = platform_get_irq(pdev, 0);
> +	if (priv->irq < 0) {
> +		ret = priv->irq;
> +		dev_err(&pdev->dev, "Cannot claim IRQ: %d\n", ret);
> +		goto probe_err;
> +	}
> +
> +	ret = devm_request_irq(&pdev->dev, priv->irq, sun8i_emac_dma_interrupt,
> +			       0, dev_name(&pdev->dev), ndev);
> +	if (ret) {
> +		dev_err(&pdev->dev, "Cannot request IRQ: %d\n", ret);
> +		goto probe_err;
> +	}

Network drivers typically do not request any resources (memory,
interrupts)  until ndo_open() is called, which helps with making sure
that interrupts are properly disabled if the hardware is never used. You
are also missing masking of interrupts of the MAC/DMA hardware here.

[snip]

> +	ndev->netdev_ops = &sun8i_emac_netdev_ops;
> +	ndev->ethtool_ops = &sun8i_emac_ethtool_ops;
> +
> +	priv->ndev = ndev;
> +	priv->dev = &pdev->dev;
> +
> +	ndev->base_addr = (unsigned long)priv->base;
> +	ndev->irq = priv->irq;

These are now deprecated and there is no requirement to set these two.

> +
> +	ndev->hw_features = NETIF_F_SG | NETIF_F_HIGHDMA;
> +	ndev->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +		NETIF_F_RXCSUM;
> +	ndev->features |= ndev->hw_features;
> +	ndev->hw_features |= NETIF_F_RXFCS;
> +	ndev->hw_features |= NETIF_F_RXALL;
> +	ndev->hw_features |= NETIF_F_LOOPBACK;
> +	ndev->priv_flags |= IFF_UNICAST_FLT;
> +
> +	ndev->watchdog_timeo = msecs_to_jiffies(5000);

Missing netif_carrier_off() here.

> +
> +	ret = register_netdev(ndev);
> +	if (ret) {
> +		dev_err(&pdev->dev, "ERROR: Register %s failed\n", ndev->name);
> +		goto probe_err;
> +	}
> +
> +	return 0;
> +
> +probe_err:
> +	free_netdev(ndev);
> +	return ret;
> +}
> +
> +static int sun8i_emac_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev = platform_get_drvdata(pdev);
> +
> +	unregister_netdev(ndev);
> +	platform_set_drvdata(pdev, NULL);

Missing unregister_netdevice() here.

> +	free_netdev(ndev);
> +
> +	return 0;
> +}
-- 
Florian
