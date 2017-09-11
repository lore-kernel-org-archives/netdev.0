From: Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH net-next 2/3] net: ethernet: socionext: add AVE ethernet driver
Date: Mon, 11 Sep 2017 15:55:56 +0900
Message-ID: <20170911155555.6719.4A936039@socionext.com>
References: <1504875731-3680-3-git-send-email-hayashi.kunihiko@socionext.com> <df4ec8b2-67cf-5dee-2600-88cffd1bcd11@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
        Masami Hiramatsu <masami.hiramatsu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <df4ec8b2-67cf-5dee-2600-88cffd1bcd11-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Florian,
Thank you for your comments,

On Fri, 8 Sep 2017 12:31:18 -0700 <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On 09/08/2017 06:02 AM, Kunihiko Hayashi wrote:
> > The UniPhier platform from Socionext provides the AVE ethernet
> > controller that includes MAC and MDIO bus supporting RGMII/RMII
> > modes. The controller is named AVE.
> > 
> > Signed-off-by: Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
> > Signed-off-by: Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> > ---

..snip..

> > +static inline u32 ave_r32(struct net_device *ndev, u32 offset)
> > +{
> > +	void __iomem *addr = (void __iomem *)ndev->base_addr;
> > +
> > +	return readl_relaxed(addr + offset);
> > +}
> 
> Don't do this, ndev->base_addr is convenient, but is now deprecated
> (unlike ISA cards, you can't change this anymore) instead, just pass a
> reference to an ave_private structure and store the base register
> pointer there.

Oh, I didn't notice that ndev->base_addr was deprecated.
I'll rewrite it using an ave_private structure.

> > +
> > +static inline void ave_w32(struct net_device *ndev, u32 offset, u32 value)
> > +{
> > +	void __iomem *addr = (void __iomem *)ndev->base_addr;
> > +
> > +	writel_relaxed(value, addr + offset);
> > +}
> 
> Same here.

Ditto.

> > +
> > +static inline u32 ave_rdesc(struct net_device *ndev, enum desc_id id,
> > +			    int entry, int offset)
> > +{
> > +	struct ave_private *priv = netdev_priv(ndev);
> > +	u32 addr = (id == AVE_DESCID_TX) ? priv->tx.daddr : priv->rx.daddr;
> > +
> > +	addr += entry * priv->desc_size + offset;
> > +
> > +	return ave_r32(ndev, addr);
> > +}
> > +
> > +static inline void ave_wdesc(struct net_device *ndev, enum desc_id id,
> > +			     int entry, int offset, u32 val)
> > +{
> > +	struct ave_private *priv = netdev_priv(ndev);
> > +	u32 addr = (id == AVE_DESCID_TX) ? priv->tx.daddr : priv->rx.daddr;
> > +
> > +	addr += entry * priv->desc_size + offset;
> > +
> > +	ave_w32(ndev, addr, val);
> > +}
> > +
> > +static void ave_wdesc_addr(struct net_device *ndev, enum desc_id id,
> > +			   int entry, int offset, dma_addr_t paddr)
> > +{
> > +	struct ave_private *priv = netdev_priv(ndev);
> > +
> > +	ave_wdesc(ndev, id, entry, offset, (u32)((u64)paddr & 0xFFFFFFFFULL));
> 
> lower_32_bits()

It's convenient.

> > +	if (IS_DESC_64BIT(priv))
> > +		ave_wdesc(ndev, id,
> > +			  entry, offset + 4, (u32)((u64)paddr >> 32));
> 
> upper_32_bits()

Ditto.

> > +	else if ((u64)paddr > (u64)U32_MAX)
> > +		netdev_warn(ndev, "DMA address exceeds the address space\n");
> > +}
> > +
> > +static void ave_get_fwversion(struct net_device *ndev, char *buf, int len)
> > +{
> > +	u32 major, minor;
> > +
> > +	major = (ave_r32(ndev, AVE_VR) & GENMASK(15, 8)) >> 8;
> > +	minor = (ave_r32(ndev, AVE_VR) & GENMASK(7, 0));
> > +	snprintf(buf, len, "v%u.%u", major, minor);
> > +}
> > +
> > +static void ave_get_drvinfo(struct net_device *ndev,
> > +			    struct ethtool_drvinfo *info)
> > +{
> > +	struct device *dev = ndev->dev.parent;
> > +
> > +	strlcpy(info->driver, dev->driver->name, sizeof(info->driver));
> > +	strlcpy(info->bus_info, dev_name(dev), sizeof(info->bus_info));
> 
> bus_info would likely be platform, since this is a memory mapped
> peripheral, right?

Yes, this is a memory mapped peripheral.
Now ethtool says "bus-info: 65000000.ethernet" in our case.
Is it reasonable for bus-info? or is null desirable?

> > +	ave_get_fwversion(ndev, info->fw_version, sizeof(info->fw_version));
> > +}
> > +
> > +static int ave_nway_reset(struct net_device *ndev)
> > +{
> > +	return genphy_restart_aneg(ndev->phydev);
> > +}
> 
> You can just set your ethtool_ops::nway_reset to be
> phy_ethtool_nway_reset() which does additional checks.

I see. I'll use it.

> > +
> > +static u32 ave_get_link(struct net_device *ndev)
> > +{
> > +	int err;
> > +
> > +	err = genphy_update_link(ndev->phydev);
> > +	if (err)
> > +		return ethtool_op_get_link(ndev);
> 
> No, calling genphy_update_link() is bogus see:
> 
> e69e46261063a25c3907bed16a2e9d18b115d1fd ("net: dsa: Do not clobber PHY
> link outside of state machine")

You mean that phylib can't guarantee link-state when the driver calls
genphy_update_link() here, that is outside of phy_state_machine().

> > +
> > +	return ndev->phydev->link;
> 
> This can just be ethtool_op_get_link()

Okay, I'll replace it.

> > +}
> > +
> > +static u32 ave_get_msglevel(struct net_device *ndev)
> > +{
> > +	struct ave_private *priv = netdev_priv(ndev);
> > +
> > +	return priv->msg_enable;
> > +}
> > +
> > +static void ave_set_msglevel(struct net_device *ndev, u32 val)
> > +{
> > +	struct ave_private *priv = netdev_priv(ndev);
> > +
> > +	priv->msg_enable = val;
> > +}
> > +
> > +static void ave_get_wol(struct net_device *ndev,
> > +			struct ethtool_wolinfo *wol)
> > +{
> > +	wol->supported = 0;
> > +	wol->wolopts   = 0;
> > +	phy_ethtool_get_wol(ndev->phydev, wol);
> 
> This can be called before you successfully connected to a PHY so you
> need to check that ndev->phydev is not NULL at the very least.

I see. I'll add check code for ndev->phydev.

> > +}
> > +
> > +static int ave_set_wol(struct net_device *ndev,
> > +		       struct ethtool_wolinfo *wol)
> > +{
> > +	if (wol->wolopts & (WAKE_ARP | WAKE_MAGICSECURE))
> > +		return -EOPNOTSUPP;
> > +
> > +	return phy_ethtool_set_wol(ndev->phydev, wol);
> 
> Same here.

Ditto.

> > +
> > +static int ave_mdio_busywait(struct net_device *ndev)
> > +{
> > +	int ret = 1, loop = 100;
> > +	u32 mdiosr;
> > +
> > +	/* wait until completion */
> > +	while (1) {
> 
> Since you are already bound by the number of times you allow this look,
> just make that a clear condition for the while() loop to exit.

Indeed. I can replace while condition.

> > +		mdiosr = ave_r32(ndev, AVE_MDIOSR);
> > +		if (!(mdiosr & AVE_MDIOSR_STS))
> > +			break;
> > +
> > +		usleep_range(10, 20);
> > +		if (!loop--) {
> > +			netdev_err(ndev,
> > +				   "failed to read from MDIO (status:0x%08x)\n",
> > +				   mdiosr);
> > +			ret = 0;
> > +			break;
> > +		}
> > +	}
> > +
> > +	return ret;
> > +}
> > +
> > +static int ave_mdiobus_read(struct mii_bus *bus, int phyid, int regnum)
> > +{
> > +	struct net_device *ndev = bus->priv;
> > +	u32 mdioctl;
> > +
> > +	/* write address */
> > +	ave_w32(ndev, AVE_MDIOAR, (phyid << 8) | regnum);
> > +
> > +	/* read request */
> > +	mdioctl = ave_r32(ndev, AVE_MDIOCTR);
> > +	ave_w32(ndev, AVE_MDIOCTR, mdioctl | AVE_MDIOCTR_RREQ);
> > +
> > +	if (!ave_mdio_busywait(ndev)) {
> > +		netdev_err(ndev, "phy-%d reg-%x read failed\n",
> > +			   phyid, regnum);
> > +		return 0xffff;
> > +	}
> > +
> > +	return ave_r32(ndev, AVE_MDIORDR) & GENMASK(15, 0);
> > +}
> > +
> > +static int ave_mdiobus_write(struct mii_bus *bus,
> > +			     int phyid, int regnum, u16 val)
> > +{
> > +	struct net_device *ndev = bus->priv;
> > +	u32 mdioctl;
> > +
> > +	/* write address */
> > +	ave_w32(ndev, AVE_MDIOAR, (phyid << 8) | regnum);
> > +
> > +	/* write data */
> > +	ave_w32(ndev, AVE_MDIOWDR, val);
> > +
> > +	/* write request */
> > +	mdioctl = ave_r32(ndev, AVE_MDIOCTR);
> > +	ave_w32(ndev, AVE_MDIOCTR, mdioctl | AVE_MDIOCTR_WREQ);
> > +
> > +	if (!ave_mdio_busywait(ndev)) {
> > +		netdev_err(ndev, "phy-%d reg-%x write failed\n",
> > +			   phyid, regnum);
> > +		return -1;
> > +	}
> 
> Just propagate the return value of ave_mdio_busywait().

Yes, I'll reconsider the way to handle return value.

> > +
> > +	return 0;
> > +}
> > +
> > +static dma_addr_t ave_dma_map(struct net_device *ndev, struct ave_desc *desc,
> > +			      void *ptr, size_t len,
> > +			      enum dma_data_direction dir)
> > +{
> > +	dma_addr_t paddr;
> > +
> > +	paddr = dma_map_single(ndev->dev.parent, ptr, len, dir);
> > +	if (dma_mapping_error(ndev->dev.parent, paddr)) {
> > +		desc->skbs_dma = 0;
> > +		paddr = (dma_addr_t)virt_to_phys(ptr);
> 
> Why do you do that? If dma_map_single() failed, that's it, game over,
> you need to discad the packet, not assume that it is in the kernel's
> linear mapping!

I see. It's not necessary to worry about failing dma_map_single().
I'll rewrite it to discard the packet.

> > +	} else {
> > +		desc->skbs_dma = paddr;
> > +		desc->skbs_dmalen = len;
> > +	}
> > +
> > +	return paddr;
> > +}
> > +
> > +static void ave_dma_unmap(struct net_device *ndev, struct ave_desc *desc,
> > +			  enum dma_data_direction dir)
> > +{
> > +	if (!desc->skbs_dma)
> > +		return;
> > +
> > +	dma_unmap_single(ndev->dev.parent,
> > +			 desc->skbs_dma, desc->skbs_dmalen, dir);
> > +	desc->skbs_dma = 0;
> > +}
> > +
> > +/* Set Rx descriptor and memory */
> > +static int ave_set_rxdesc(struct net_device *ndev, int entry)
> > +{
> > +	struct ave_private *priv = netdev_priv(ndev);
> > +	struct sk_buff *skb;
> > +	unsigned long align;
> > +	dma_addr_t paddr;
> > +	void *buffptr;
> > +	int ret = 0;
> > +
> > +	skb = priv->rx.desc[entry].skbs;
> > +	if (!skb) {
> > +		skb = netdev_alloc_skb_ip_align(ndev,
> > +						AVE_MAX_ETHFRAME + NET_SKB_PAD);
> > +		if (!skb) {
> > +			netdev_err(ndev, "can't allocate skb for Rx\n");
> > +			return -ENOMEM;
> > +		}
> > +	}
> > +
> > +	/* set disable to cmdsts */
> > +	ave_wdesc(ndev, AVE_DESCID_RX, entry, 0, AVE_STS_INTR | AVE_STS_OWN);
> > +
> > +	/* align skb data for cache size */
> > +	align = (unsigned long)skb_tail_pointer(skb) & (NET_SKB_PAD - 1);
> > +	align = NET_SKB_PAD - align;
> > +	skb_reserve(skb, align);
> > +	buffptr = (void *)skb_tail_pointer(skb);
> 
> Are you positive you need this? Because by default, the networking stack
> will align to the maximum between your L1 cache line size and 64 bytes,
> which should be a pretty good alignment guarantee.

Now if L1 cache line size is 128,
the skb buffer is also aligned to 128, isn't it?
So this code doesn't make sense.

> > +
> > +	paddr = ave_dma_map(ndev, &priv->rx.desc[entry], buffptr,
> > +			    AVE_MAX_ETHFRAME + NET_IP_ALIGN, DMA_FROM_DEVICE);
> 
> This needs to be checked, as mentioned before, you can't just assume the
> linear virtual map is going to be satisfactory.

I see.

> > +	priv->rx.desc[entry].skbs = skb;
> > +
> > +	/* set buffer pointer */
> > +	ave_wdesc_addr(ndev, AVE_DESCID_RX, entry, 4, paddr);
> 
> OK, so 4 is an offset, can you add a define for that so it's clear it is
> not an address size instead?

Yes, 4 is an offset. I'll add the definition for '4'.

> > +
> > +	/* set enable to cmdsts */
> > +	ave_wdesc(ndev, AVE_DESCID_RX,
> > +		  entry, 0, AVE_STS_INTR | AVE_MAX_ETHFRAME);
> > +
> > +	return ret;
> > +}
> > +
> > +/* Switch state of descriptor */
> > +static int ave_desc_switch(struct net_device *ndev, enum desc_state state)
> > +{
> > +	int counter;
> > +	u32 val;
> > +
> > +	switch (state) {
> > +	case AVE_DESC_START:
> > +		ave_w32(ndev, AVE_DESCC, AVE_DESCC_TD | AVE_DESCC_RD0);
> > +		break;
> > +
> > +	case AVE_DESC_STOP:
> > +		ave_w32(ndev, AVE_DESCC, 0);
> > +		counter = 0;
> > +		while (1) {
> > +			usleep_range(100, 150);
> > +			if (!ave_r32(ndev, AVE_DESCC))
> > +				break;
> > +
> > +			counter++;
> > +			if (counter > 100) {
> > +				netdev_err(ndev, "can't stop descriptor\n");
> > +				return -EBUSY;
> > +			}
> > +		}
> 
> Same here, pleas rewrite the loop so the exit condition is clear.

Ditto.

> > +		break;
> > +
> > +	case AVE_DESC_RX_SUSPEND:
> > +		val = ave_r32(ndev, AVE_DESCC);
> > +		val |= AVE_DESCC_RDSTP;
> > +		val &= AVE_DESCC_CTRL_MASK;
> 
> Should not this be a &= ~AVE_DESCC_CTRL_MASK? OK maybe not.

This may be confusing. I'll fix it.

> > +		ave_w32(ndev, AVE_DESCC, val);
> > +
> > +		counter = 0;
> > +		while (1) {
> > +			usleep_range(100, 150);
> > +			val = ave_r32(ndev, AVE_DESCC);
> > +			if (val & (AVE_DESCC_RDSTP << 16))
> > +				break;
> > +
> > +			counter++;
> > +			if (counter > 1000) {
> > +				netdev_err(ndev, "can't suspend descriptor\n");
> > +				return -EBUSY;
> > +			}
> > +		}
> > +		break;
> 
> Same here, please rewrite with the counter as an exit condition.

Ditto.

> > +
> > +	case AVE_DESC_RX_PERMIT:
> > +		val = ave_r32(ndev, AVE_DESCC);
> > +		val &= ~AVE_DESCC_RDSTP;
> > +		val &= AVE_DESCC_CTRL_MASK;
> > +		ave_w32(ndev, AVE_DESCC, val);
> > +		break;
> > +
> > +	default:
> > +		return -EINVAL;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static int ave_tx_completion(struct net_device *ndev)
> > +{
> > +	struct ave_private *priv = netdev_priv(ndev);
> > +	u32 proc_idx, done_idx, ndesc, val;
> > +	int freebuf_flag = 0;
> > +
> > +	proc_idx = priv->tx.proc_idx;
> > +	done_idx = priv->tx.done_idx;
> > +	ndesc    = priv->tx.ndesc;
> > +
> > +	/* free pre stored skb from done to proc */
> > +	while (proc_idx != done_idx) {
> > +		/* get cmdsts */
> > +		val = ave_rdesc(ndev, AVE_DESCID_TX, done_idx, 0);
> > +
> > +		/* do nothing if owner is HW */
> > +		if (val & AVE_STS_OWN)
> > +			break;
> > +
> > +		/* check Tx status and updates statistics */
> > +		if (val & AVE_STS_OK) {
> > +			priv->stats.tx_bytes += val & AVE_STS_PKTLEN_TX;
> 
> AVE_STS_PKTLEN_TX should be suffixed with _MASK to make it clear this is
> a bitmask.

I see. I'll rename it.

> > +
> > +			/* success */
> > +			if (val & AVE_STS_LAST)
> > +				priv->stats.tx_packets++;
> > +		} else {
> > +			/* error */
> > +			if (val & AVE_STS_LAST) {
> > +				priv->stats.tx_errors++;
> > +				if (val & (AVE_STS_OWC | AVE_STS_EC))
> > +					priv->stats.collisions++;
> > +			}
> > +		}
> > +
> > +		/* release skb */
> > +		if (priv->tx.desc[done_idx].skbs) {
> > +			ave_dma_unmap(ndev, &priv->tx.desc[done_idx],
> > +				      DMA_TO_DEVICE);
> > +			dev_consume_skb_any(priv->tx.desc[done_idx].skbs);
> 
> Kudos for using dev_consume_skb_any()!

Thank you! I was worried about whether I could use it.

> > +			priv->tx.desc[done_idx].skbs = NULL;
> > +			freebuf_flag++;
> > +		}
> > +		done_idx = (done_idx + 1) % ndesc;
> > +	}
> > +
> > +	priv->tx.done_idx = done_idx;
> > +
> > +	/* wake queue for freeing buffer */
> > +	if (netif_queue_stopped(ndev))
> > +			if (freebuf_flag)
> > +				netif_wake_queue(ndev);
> 
> This can be simplified to:
> 
> 	if (netif_queue_stopped(ndev) && freebuf_flag)
> 		netif_wake_queue(ndev)
> 
> because checking for netif_running() is implicit by actually getting
> called here, this would not happen if the network interface was not
> operational.

Oh, it can be simple. I understand the reason.

> > +static irqreturn_t ave_interrupt(int irq, void *netdev)
> > +{
> > +	struct net_device *ndev = (struct net_device *)netdev;
> > +	struct ave_private *priv = netdev_priv(ndev);
> > +	u32 gimr_val, gisr_val;
> > +
> > +	gimr_val = ave_irq_disable_all(ndev);
> > +
> > +	/* get interrupt status */
> > +	gisr_val = ave_r32(ndev, AVE_GISR);
> > +
> > +	/* PHY */
> > +	if (gisr_val & AVE_GI_PHY) {
> > +		ave_w32(ndev, AVE_GISR, AVE_GI_PHY);
> > +		if (priv->internal_phy_interrupt)
> > +			phy_mac_interrupt(ndev->phydev, ndev->phydev->link);
> 
> This is not correct you should be telling the PHY the new link state. If
> you cannot, because what happens here is really that the PHY interrupt
> is routed to your MAC controller, then what I would suggest doing is the
> following: create an interrupt controller domain which allows the PHY
> driver to manage the interrupt line using normal request_irq().

You're right. The interrupt from PHY is routed to the MAC controller.
Hmm...I think that I want to use normal PHY sequence including request_irq,
so I'll try to consider about applying the interrupt controller domain.

> > +static int ave_poll_tx(struct napi_struct *napi, int budget)
> > +{
> > +	struct ave_private *priv;
> > +	struct net_device *ndev;
> > +	int num;
> > +
> > +	priv = container_of(napi, struct ave_private, napi_tx);
> > +	ndev = priv->ndev;
> > +
> > +	num = ave_tx_completion(ndev);
> > +	if (num < budget) {
> 
> TX reclamation should not be bound against the budget, always process
> all packets that have been successfully submitted.

It's helpful for me.
I'll reconsider it to submit all packets.

> > +		napi_complete(napi);
> > +
> > +		/* enable Tx interrupt when NAPI finishes */
> > +		ave_irq_enable(ndev, AVE_GI_TX);
> > +	}
> > +
> > +	return num;
> > +}
> > +
> 
> > +static void ave_adjust_link(struct net_device *ndev)
> > +{
> > +	struct ave_private *priv = netdev_priv(ndev);
> > +	struct phy_device *phydev = ndev->phydev;
> > +	u32 val, txcr, rxcr, rxcr_org;
> > +
> > +	/* set RGMII speed */
> > +	val = ave_r32(ndev, AVE_TXCR);
> > +	val &= ~(AVE_TXCR_TXSPD_100 | AVE_TXCR_TXSPD_1G);
> > +
> > +	if (priv->phy_mode == PHY_INTERFACE_MODE_RGMII &&
> > +	    phydev->speed == SPEED_1000)
> > +		val |= AVE_TXCR_TXSPD_1G;
> 
> Using phy_interface_is_rgmii() would be more robust here.

It's convenience.

> > +	else if (phydev->speed == SPEED_100)
> > +		val |= AVE_TXCR_TXSPD_100;
> > +
> > +	ave_w32(ndev, AVE_TXCR, val);
> > +
> > +	/* set RMII speed (100M/10M only) */
> > +	if (priv->phy_mode != PHY_INTERFACE_MODE_RGMII) {
> 
> PHY_INTERFACE_MODE_MII, PHY_INTERFACE_MODE_REVMII,
> PHY_INTERFACE_MODE_RMII would all qualify here presumably so you need
> this check to be more restrictive to just the modes that you support.

I'll rewrite it to check the supported modes restrictly.

> > +		val = ave_r32(ndev, AVE_LINKSEL);
> > +		if (phydev->speed == SPEED_10)
> > +			val &= ~AVE_LINKSEL_100M;
> > +		else
> > +			val |= AVE_LINKSEL_100M;
> > +		ave_w32(ndev, AVE_LINKSEL, val);
> > +	}
> > +
> > +	/* check current RXCR/TXCR */
> > +	rxcr = ave_r32(ndev, AVE_RXCR);
> > +	txcr = ave_r32(ndev, AVE_TXCR);
> > +	rxcr_org = rxcr;
> > +
> > +	if (phydev->duplex)
> > +		rxcr |= AVE_RXCR_FDUPEN;
> > +	else
> > +		rxcr &= ~AVE_RXCR_FDUPEN;
> > +
> > +	if (phydev->pause) {
> > +		rxcr |= AVE_RXCR_FLOCTR;
> > +		txcr |= AVE_TXCR_FLOCTR;
> 
> You must also check for phydev->asym_pause and keep in mind that
> phydev->pause and phydev->asym_pause reflect what the link partner
> reflects, you need to implement .get_pauseparam and .set_pauseparam or
> default to flow control ON (which is what you are doing here).

I see.
I'll consider how to implement flow control with pause and asym_pause.

> > +	} else {
> > +		rxcr &= ~AVE_RXCR_FLOCTR;
> > +		txcr &= ~AVE_TXCR_FLOCTR;
> > +	}
> > +
> > +	if (rxcr_org != rxcr) {
> > +		/* disable Rx mac */
> > +		ave_w32(ndev, AVE_RXCR, rxcr & ~AVE_RXCR_RXEN);
> > +		/* change and enable TX/Rx mac */
> > +		ave_w32(ndev, AVE_TXCR, txcr);
> > +		ave_w32(ndev, AVE_RXCR, rxcr);
> > +	}
> > +
> > +	if (phydev->link)
> > +		netif_carrier_on(ndev);
> > +	else
> > +		netif_carrier_off(ndev);
> 
> This is not necessary, PHYLIB is specifically taking care of that.

Okay, I'll remove it.

> > +
> > +	phy_print_status(phydev);
> > +}
> > +
> > +static int ave_init(struct net_device *ndev)
> > +{
> > +	struct ave_private *priv = netdev_priv(ndev);
> > +	struct device *dev = ndev->dev.parent;
> > +	struct device_node *phy_node, *np = dev->of_node;
> > +	struct phy_device *phydev;
> > +	const void *mac_addr;
> > +	u32 supported;
> > +
> > +	/* get mac address */
> > +	mac_addr = of_get_mac_address(np);
> > +	if (mac_addr)
> > +		ether_addr_copy(ndev->dev_addr, mac_addr);
> > +
> > +	/* if the mac address is invalid, use random mac address */
> > +	if (!is_valid_ether_addr(ndev->dev_addr)) {
> > +		eth_hw_addr_random(ndev);
> > +		dev_warn(dev, "Using random MAC address: %pM\n",
> > +			 ndev->dev_addr);
> > +	}
> > +
> > +	/* attach PHY with MAC */
> > +	phy_node =  of_get_next_available_child(np, NULL);
> 
> You should be using a "phy-handle" property to connect to a designated
> PHY, not the next child DT node.

Yes, I found it was wrong. I'll fix it.

> > +	phydev = of_phy_connect(ndev, phy_node,
> > +				ave_adjust_link, 0, priv->phy_mode);
> > +	if (!phydev) {
> > +		dev_err(dev, "could not attach to PHY\n");
> > +		return -ENODEV;
> > +	}
> > +	of_node_put(phy_node);
> > +
> > +	priv->phydev = phydev;
> > +	phydev->autoneg = AUTONEG_ENABLE;
> > +	phydev->speed = 0;
> > +	phydev->duplex = 0;
> 
> This is not necessary.

I see. I'll remove it.

> > +
> > +	dev_info(dev, "connected to %s phy with id 0x%x\n",
> > +		 phydev->drv->name, phydev->phy_id);
> > +
> > +	if (priv->phy_mode != PHY_INTERFACE_MODE_RGMII) {
> > +		supported = phydev->supported;
> > +		phydev->supported &= ~PHY_GBIT_FEATURES;
> > +		phydev->supported |= supported & PHY_BASIC_FEATURES;
> 
> One of these two statements is redundant here.

I'll shirink the statements.

> > +	}
> > +
> > +	/* PHY interrupt stop instruction is needed because the interrupt
> > +	 * continues to assert.
> > +	 */
> > +	phy_stop_interrupts(phydev);
> 
> Wait, what?

I've thought that PHY interrupts might be enabled, but It's wrong.

> > +
> > +	/* When PHY driver can't handle its interrupt directly,
> > +	 * interrupt request always fails and polling method is used
> > +	 * alternatively. In this case, the libphy says
> > +	 * "libphy: uniphier-mdio: Can't get IRQ -1 (PHY)".
> > +	 */
> > +	phy_start_interrupts(phydev);
> > +
> > +	phy_start_aneg(phydev);
> 
> No, no, phy_start() would take care of all of that correctly for you,
> you don't have have to do it just there because ave_open() eventually
> calls phy_start() for you, so just drop these two calls.

Oh, I see.
Once calling phy_start(), all are done.

> > +
> > +	return 0;
> > +}
> > +
> > +static void ave_uninit(struct net_device *ndev)
> > +{
> > +	struct ave_private *priv = netdev_priv(ndev);
> > +
> > +	phy_stop_interrupts(priv->phydev);
> 
> You are missing a call to phy_stop() here, calling phy_stop_interrupts()
> directly should not happen.

I'll replace it.

> > +	phy_disconnect(priv->phydev);
> > +}
> > +
> > +static int ave_open(struct net_device *ndev)
> > +{
> > +	struct ave_private *priv = netdev_priv(ndev);
> > +	int entry;
> > +	u32 val;
> > +
> > +	/* initialize Tx work */
> > +	priv->tx.proc_idx = 0;
> > +	priv->tx.done_idx = 0;
> > +	memset(priv->tx.desc, 0, sizeof(struct ave_desc) * priv->tx.ndesc);
> > +
> > +	/* initialize Tx descriptor */
> > +	for (entry = 0; entry < priv->tx.ndesc; entry++) {
> > +		ave_wdesc(ndev, AVE_DESCID_TX, entry, 0, 0);
> > +		ave_wdesc_addr(ndev, AVE_DESCID_TX, entry, 4, 0);
> > +	}
> > +	ave_w32(ndev, AVE_TXDC, AVE_TXDC_ADDR_START
> > +		| (((priv->tx.ndesc * priv->desc_size) << 16) & AVE_TXDC_SIZE));
> > +
> > +	/* initialize Rx work */
> > +	priv->rx.proc_idx = 0;
> > +	priv->rx.done_idx = 0;
> > +	memset(priv->rx.desc, 0, sizeof(struct ave_desc) * priv->rx.ndesc);
> > +
> > +	/* initialize Rx descriptor and buffer */
> > +	for (entry = 0; entry < priv->rx.ndesc; entry++) {
> > +		if (ave_set_rxdesc(ndev, entry))
> > +			break;
> > +	}
> > +	ave_w32(ndev, AVE_RXDC0, AVE_RXDC0_ADDR_START
> > +	    | (((priv->rx.ndesc * priv->desc_size) << 16) & AVE_RXDC0_SIZE));
> > +
> > +	/* enable descriptor */
> > +	ave_desc_switch(ndev, AVE_DESC_START);
> > +
> > +	/* initialize filter */
> > +	ave_pfsel_init(ndev);
> > +
> > +	/* set macaddr */
> > +	val = le32_to_cpu(((u32 *)ndev->dev_addr)[0]);
> > +	ave_w32(ndev, AVE_RXMAC1R, val);
> > +	val = (u32)le16_to_cpu(((u16 *)ndev->dev_addr)[2]);
> > +	ave_w32(ndev, AVE_RXMAC2R, val);
> > +
> > +	/* set Rx configuration */
> > +	/* full duplex, enable pause drop, enalbe flow control */
> > +	val = AVE_RXCR_RXEN | AVE_RXCR_FDUPEN | AVE_RXCR_DRPEN |
> > +		AVE_RXCR_FLOCTR | (AVE_MAX_ETHFRAME & AVE_RXCR_MPSIZ_MASK);
> > +	ave_w32(ndev, AVE_RXCR, val);
> > +
> > +	/* set Tx configuration */
> > +	/* enable flow control, disable loopback */
> > +	ave_w32(ndev, AVE_TXCR, AVE_TXCR_FLOCTR);
> > +
> > +	/* enable timer, clear EN,INTM, and mask interval unit(BSCK) */
> > +	val = ave_r32(ndev, AVE_IIRQC) & AVE_IIRQC_BSCK;
> > +	val |= AVE_IIRQC_EN0 | (AVE_INTM_COUNT << 16);
> > +	ave_w32(ndev, AVE_IIRQC, val);
> > +
> > +	/* set interrupt mask */
> > +	val = AVE_GI_RXIINT | AVE_GI_RXOVF | AVE_GI_TX;
> > +	val |= (priv->internal_phy_interrupt) ? AVE_GI_PHY : 0;
> > +	ave_irq_restore(ndev, val);
> > +
> > +	napi_enable(&priv->napi_rx);
> > +	napi_enable(&priv->napi_tx);
> > +
> > +	phy_start(ndev->phydev);
> > +	netif_start_queue(ndev);
> > +
> > +	return 0;
> > +}
> > +
> > +static int ave_stop(struct net_device *ndev)
> > +{
> > +	struct ave_private *priv = netdev_priv(ndev);
> > +	int entry;
> > +
> > +	/* disable all interrupt */
> > +	ave_irq_disable_all(ndev);
> > +	disable_irq(ndev->irq);
> > +
> > +	netif_tx_disable(ndev);
> > +	phy_stop(ndev->phydev);
> > +	napi_disable(&priv->napi_tx);
> > +	napi_disable(&priv->napi_rx);
> > +
> > +	/* free Tx buffer */
> > +	for (entry = 0; entry < priv->tx.ndesc; entry++) {
> > +		if (!priv->tx.desc[entry].skbs)
> > +			continue;
> > +
> > +		ave_dma_unmap(ndev, &priv->tx.desc[entry], DMA_TO_DEVICE);
> > +		dev_kfree_skb_any(priv->tx.desc[entry].skbs);
> > +		priv->tx.desc[entry].skbs = NULL;
> > +	}
> > +	priv->tx.proc_idx = 0;
> > +	priv->tx.done_idx = 0;
> > +
> > +	/* free Rx buffer */
> > +	for (entry = 0; entry < priv->rx.ndesc; entry++) {
> > +		if (!priv->rx.desc[entry].skbs)
> > +			continue;
> > +
> > +		ave_dma_unmap(ndev, &priv->rx.desc[entry], DMA_FROM_DEVICE);
> > +		dev_kfree_skb_any(priv->rx.desc[entry].skbs);
> > +		priv->rx.desc[entry].skbs = NULL;
> > +	}
> > +	priv->rx.proc_idx = 0;
> > +	priv->rx.done_idx = 0;
> > +
> > +	return 0;
> > +}
> > +
> > +static int ave_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> > +{
> > +	struct ave_private *priv = netdev_priv(ndev);
> > +	u32 proc_idx, done_idx, ndesc, cmdsts;
> > +	int freepkt;
> > +	unsigned char *buffptr = NULL; /* buffptr for descriptor */
> > +	unsigned int len;
> > +	dma_addr_t paddr;
> > +
> > +	proc_idx = priv->tx.proc_idx;
> > +	done_idx = priv->tx.done_idx;
> > +	ndesc = priv->tx.ndesc;
> > +	freepkt = ((done_idx + ndesc - 1) - proc_idx) % ndesc;
> > +
> > +	/* not enough entry, then we stop queue */
> > +	if (unlikely(freepkt < 2)) {
> > +		netif_stop_queue(ndev);
> > +		if (unlikely(freepkt < 1))
> > +			return NETDEV_TX_BUSY;
> > +	}
> > +
> > +	priv->tx.desc[proc_idx].skbs = skb;
> > +
> > +	/* add padding for short packet */
> > +	if (skb_padto(skb, ETH_ZLEN)) {
> > +		dev_kfree_skb_any(skb);
> > +		return NETDEV_TX_OK;
> > +	}
> > +
> > +	buffptr = skb->data - NET_IP_ALIGN;
> > +	len = max_t(unsigned int, ETH_ZLEN, skb->len);
> > +
> > +	paddr = ave_dma_map(ndev, &priv->tx.desc[proc_idx], buffptr,
> > +			    len + NET_IP_ALIGN, DMA_TO_DEVICE);
> > +	paddr += NET_IP_ALIGN;
> > +
> > +	/* set buffer address to descriptor */
> > +	ave_wdesc_addr(ndev, AVE_DESCID_TX, proc_idx, 4, paddr);
> > +
> > +	/* set flag and length to send */
> > +	cmdsts = AVE_STS_OWN | AVE_STS_1ST | AVE_STS_LAST
> > +		| (len & AVE_STS_PKTLEN_TX);
> > +
> > +	/* set interrupt per AVE_FORCE_TXINTCNT or when queue is stopped */
> > +	if (!(proc_idx % AVE_FORCE_TXINTCNT) || netif_queue_stopped(ndev))
> > +		cmdsts |= AVE_STS_INTR;
> > +
> > +	/* disable checksum calculation when skb doesn't calurate checksum */
> > +	if (skb->ip_summed == CHECKSUM_NONE ||
> > +	    skb->ip_summed == CHECKSUM_UNNECESSARY)
> > +		cmdsts |= AVE_STS_NOCSUM;
> > +
> > +	/* set cmdsts */
> > +	ave_wdesc(ndev, AVE_DESCID_TX, proc_idx, 0, cmdsts);
> > +
> > +	priv->tx.proc_idx = (proc_idx + 1) % ndesc;
> > +
> > +	return NETDEV_TX_OK;
> > +}
> > +
> > +static int ave_ioctl(struct net_device *ndev, struct ifreq *ifr, int cmd)
> > +{
> > +	return phy_mii_ioctl(ndev->phydev, ifr, cmd);
> > +}
> > +
> > +static void ave_set_rx_mode(struct net_device *ndev)
> > +{
> > +	int count, mc_cnt = netdev_mc_count(ndev);
> > +	struct netdev_hw_addr *hw_adr;
> > +	u32 val;
> > +	u8 v4multi_macadr[6] = { 0x01, 0x00, 0x00, 0x00, 0x00, 0x00 };
> > +	u8 v6multi_macadr[6] = { 0x33, 0x00, 0x00, 0x00, 0x00, 0x00 };
> > +
> > +	/* MAC addr filter enable for promiscious mode */
> > +	val = ave_r32(ndev, AVE_RXCR);
> > +	if (ndev->flags & IFF_PROMISC || !mc_cnt)
> > +		val &= ~AVE_RXCR_AFEN;
> > +	else
> > +		val |= AVE_RXCR_AFEN;
> > +	ave_w32(ndev, AVE_RXCR, val);
> > +
> > +	/* set all multicast address */
> > +	if ((ndev->flags & IFF_ALLMULTI) || (mc_cnt > AVE_PF_MULTICAST_SIZE)) {
> > +		ave_pfsel_macaddr_set(ndev, AVE_PFNUM_MULTICAST,
> > +				      v4multi_macadr, 1);
> > +		ave_pfsel_macaddr_set(ndev, AVE_PFNUM_MULTICAST + 1,
> > +				      v6multi_macadr, 1);
> > +	} else {
> > +		/* stop all multicast filter */
> > +		for (count = 0; count < AVE_PF_MULTICAST_SIZE; count++)
> > +			ave_pfsel_stop(ndev, AVE_PFNUM_MULTICAST + count);
> > +
> > +		/* set multicast addresses */
> > +		count = 0;
> > +		netdev_for_each_mc_addr(hw_adr, ndev) {
> > +			if (count == mc_cnt)
> > +				break;
> > +			ave_pfsel_macaddr_set(ndev, AVE_PFNUM_MULTICAST + count,
> > +					      hw_adr->addr, 6);
> > +			count++;
> > +		}
> > +	}
> > +}
> > +
> > +static struct net_device_stats *ave_stats(struct net_device *ndev)
> > +{
> > +	struct ave_private *priv = netdev_priv(ndev);
> > +	u32 drop_num = 0;
> > +
> > +	priv->stats.rx_errors = ave_r32(ndev, AVE_BFCR);
> > +
> > +	drop_num += ave_r32(ndev, AVE_RX0OVFFC);
> > +	drop_num += ave_r32(ndev, AVE_SN5FC);
> > +	drop_num += ave_r32(ndev, AVE_SN6FC);
> > +	drop_num += ave_r32(ndev, AVE_SN7FC);
> > +	priv->stats.rx_dropped = drop_num;
> > +
> > +	return &priv->stats;
> > +}
> > +
> > +static int ave_set_mac_address(struct net_device *ndev, void *p)
> > +{
> > +	int ret = eth_mac_addr(ndev, p);
> > +	u32 val;
> > +
> > +	if (ret)
> > +		return ret;
> > +
> > +	/* set macaddr */
> > +	val = le32_to_cpu(((u32 *)ndev->dev_addr)[0]);
> > +	ave_w32(ndev, AVE_RXMAC1R, val);
> > +	val = (u32)le16_to_cpu(((u16 *)ndev->dev_addr)[2]);
> > +	ave_w32(ndev, AVE_RXMAC2R, val);
> > +
> > +	/* pfsel unicast entry */
> > +	ave_pfsel_macaddr_set(ndev, AVE_PFNUM_UNICAST, ndev->dev_addr, 6);
> > +
> > +	return 0;
> > +}
> > +
> > +static const struct net_device_ops ave_netdev_ops = {
> > +	.ndo_init		= ave_init,
> > +	.ndo_uninit		= ave_uninit,
> > +	.ndo_open		= ave_open,
> > +	.ndo_stop		= ave_stop,
> > +	.ndo_start_xmit		= ave_start_xmit,
> > +	.ndo_do_ioctl		= ave_ioctl,
> > +	.ndo_set_rx_mode	= ave_set_rx_mode,
> > +	.ndo_get_stats		= ave_stats,
> > +	.ndo_set_mac_address	= ave_set_mac_address,
> > +};
> > +
> > +static int ave_probe(struct platform_device *pdev)
> > +{
> > +	struct device *dev = &pdev->dev;
> > +	struct device_node *np = dev->of_node;
> > +	u32 desc_bits, ave_id;
> > +	struct reset_control *rst;
> > +	struct ave_private *priv;
> > +	phy_interface_t phy_mode;
> > +	struct net_device *ndev;
> > +	struct resource	*res;
> > +	void __iomem *base;
> > +	int irq, ret = 0;
> > +	char buf[ETHTOOL_FWVERS_LEN];
> > +
> > +	/* get phy mode */
> > +	phy_mode = of_get_phy_mode(np);
> > +	if (phy_mode < 0) {
> > +		dev_err(dev, "phy-mode not found\n");
> > +		return -EINVAL;
> > +	}
> > +
> > +	irq = platform_get_irq(pdev, 0);
> > +	if (irq < 0) {
> > +		dev_err(dev, "IRQ not found\n");
> > +		return irq;
> > +	}
> > +
> > +	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> > +	base = devm_ioremap_resource(dev, res);
> > +	if (IS_ERR(base))
> > +		return PTR_ERR(base);
> > +
> > +	/* alloc netdevice */
> > +	ndev = alloc_etherdev(sizeof(struct ave_private));
> > +	if (!ndev) {
> > +		dev_err(dev, "can't allocate ethernet device\n");
> > +		return -ENOMEM;
> > +	}
> > +
> > +	ndev->base_addr = (unsigned long)base;
> 
> This is deprecated as mentioned earlier, just store this in
> priv->base_adr or something.

Yes, Andrew teaches me in his comment and I'll replace it.

> > +	ndev->irq = irq;
> 
> Same here.

I'll move it to ave_private, too.

> > +	ndev->netdev_ops = &ave_netdev_ops;
> > +	ndev->ethtool_ops = &ave_ethtool_ops;
> > +	SET_NETDEV_DEV(ndev, dev);
> > +
> > +	/* support hardware checksum */
> > +	ndev->features    |= (NETIF_F_IP_CSUM | NETIF_F_RXCSUM);
> > +	ndev->hw_features |= (NETIF_F_IP_CSUM | NETIF_F_RXCSUM);
> > +
> > +	ndev->max_mtu = AVE_MAX_ETHFRAME - (ETH_HLEN + ETH_FCS_LEN);
> > +
> > +	priv = netdev_priv(ndev);
> > +	priv->ndev = ndev;
> > +	priv->msg_enable = netif_msg_init(-1, AVE_DEFAULT_MSG_ENABLE);
> > +	priv->phy_mode = phy_mode;
> > +
> > +	/* get bits of descriptor from devicetree */
> > +	of_property_read_u32(np, "socionext,desc-bits", &desc_bits);
> > +	priv->desc_size = AVE_DESC_SIZE_32;
> > +	if (desc_bits == 64)
> > +		priv->desc_size = AVE_DESC_SIZE_64;
> > +	else if (desc_bits != 32)
> > +		dev_warn(dev, "Defaulting to 32bit descriptor\n");
> 
> This should really be determined by the compatible string.

Okay, I'll reconsider about compatible strings for each SoCs.

> > +
> > +	/* use internal phy interrupt */
> > +	priv->internal_phy_interrupt =
> > +		of_property_read_bool(np, "socionext,internal-phy-interrupt");
> 
> Same here.

Ditto.

> > +
> > +	/* setting private data for descriptor */
> > +	priv->tx.daddr = IS_DESC_64BIT(priv) ? AVE_TXDM_64 : AVE_TXDM_32;
> > +	priv->tx.ndesc = AVE_NR_TXDESC;
> > +	priv->tx.desc = devm_kzalloc(dev,
> > +				     sizeof(struct ave_desc) * priv->tx.ndesc,
> > +				     GFP_KERNEL);
> > +	if (!priv->tx.desc)
> > +		return -ENOMEM;
> > +
> > +	priv->rx.daddr = IS_DESC_64BIT(priv) ? AVE_RXDM_64 : AVE_RXDM_32;
> > +	priv->rx.ndesc = AVE_NR_RXDESC;
> > +	priv->rx.desc = devm_kzalloc(dev,
> > +				     sizeof(struct ave_desc) * priv->rx.ndesc,
> > +				     GFP_KERNEL);
> > +	if (!priv->rx.desc)
> > +		return -ENOMEM;
> 
> If your network device driver is probed, but never used after that, that
> is the network device is not open, you just this memory sitting for
> nothing, you should consider moving that to ndo_open() time.

Indeed. 
The driver allocates memory when the driver is opened. I'll reconsider it.

> > +
> > +	/* enable clock */
> > +	priv->clk = devm_clk_get(dev, NULL);
> > +	if (IS_ERR(priv->clk))
> > +		priv->clk = NULL;
> > +	clk_prepare_enable(priv->clk);
> 
> Same here with the clock, the block is clocked, so it can consume some
> amount of power, just do the necessary HW initialization with the clock
> enabled, then defer until ndo_open() before turning it back on.

Okay, also the clocks.

> > +
> > +	/* reset block */
> > +	rst = devm_reset_control_get(dev, NULL);
> > +	if (!IS_ERR_OR_NULL(rst)) {
> > +		reset_control_deassert(rst);
> > +		reset_control_put(rst);
> > +	}
> 
> Ah so that's interesting, you need it clocked first, then reset, I guess
> that works :)

Yes, this device starts to enable clock first.

> > +
> > +	/* reset mac and phy */
> > +	ave_global_reset(ndev);
> > +
> > +	/* request interrupt */
> > +	ret = devm_request_irq(dev, irq, ave_interrupt,
> > +			       IRQF_SHARED, ndev->name, ndev);
> > +	if (ret)
> > +		goto err_req_irq;
> 
> Same here, this is usually moved to ndo_open() for network drivers, but
> then remember not to use devm_, just normal request_irq() because it
> need to be balanced in ndo_close().

Okay, also interrupts without devm_, and I'll take care of ndo_close().

> This looks like a pretty good first submission, and there does not
> appear to be any obvious functional problems!

Thanks a lot for your helpful advice!

> -- 
> Florian

---
Best Regards,
Kunihiko Hayashi


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
