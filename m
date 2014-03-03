From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 3/3] Altera TSE: Add Altera Triple Speed Ethernet
 (TSE) Driver
Date: Sun, 02 Mar 2014 16:59:10 -0800
Message-ID: <5313D3DE.3030907@gmail.com>
References: <1393792922-2381-1-git-send-email-vbridgers2013@gmail.com> <1393792922-2381-4-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	rob@landley.net
To: Vince Bridgers <vbridgers2013@gmail.com>,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1393792922-2381-4-git-send-email-vbridgers2013@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Vince,

It might help reviewing the patches by breaking the patches into:

- the SGDMA bits
- the MSGDMA bits
- the Ethernet MAC driver per-se

BTW, it does look like the SGDMA code could/should be a dmaengine drive=
r?

Le 02/03/2014 12:42, Vince Bridgers a =C3=A9crit :
[snip]

> +	iowrite32(buffer->dma_addr, &desc->read_addr_lo);
> +	iowrite32(0, &desc->read_addr_hi);
> +	iowrite32(0, &desc->write_addr_lo);
> +	iowrite32(0, &desc->write_addr_hi);

Since there is a HI/LO pair, you might want to break buffer->dma_addr=20
using lower_32bits/upper_32bits such that things don't start breaking=20
when a platform using that driver is 64-bits/LPAE capable.

> +	iowrite32(buffer->len, &desc->len);
> +	iowrite32(0, &desc->burst_seq_num);
> +	iowrite32(MSGDMA_DESC_TX_STRIDE, &desc->stride);
> +	iowrite32(MSGDMA_DESC_CTL_TX_SINGLE, &desc->control);
> +	return 0;
> +}

[snip]

> +
> +/* Put buffer to the mSGDMA RX FIFO
> + */
> +int msgdma_add_rx_desc(struct altera_tse_private *priv,
> +			struct tse_buffer *rxbuffer)
> +{
> +	struct msgdma_extended_desc *desc =3D priv->rx_dma_desc;
> +	u32 len =3D priv->rx_dma_buf_sz;
> +	dma_addr_t dma_addr =3D rxbuffer->dma_addr;
> +	u32 control =3D (MSGDMA_DESC_CTL_END_ON_EOP
> +			| MSGDMA_DESC_CTL_END_ON_LEN
> +			| MSGDMA_DESC_CTL_TR_COMP_IRQ
> +			| MSGDMA_DESC_CTL_EARLY_IRQ
> +			| MSGDMA_DESC_CTL_TR_ERR_IRQ
> +			| MSGDMA_DESC_CTL_GO);
> +
> +	iowrite32(0, &desc->read_addr_lo);
> +	iowrite32(0, &desc->read_addr_hi);
> +	iowrite32(dma_addr, &desc->write_addr_lo);
> +	iowrite32(0, &desc->write_addr_hi);

Same here

> +	iowrite32(len, &desc->len);
> +	iowrite32(0, &desc->burst_seq_num);
> +	iowrite32(0x00010001, &desc->stride);
> +	iowrite32(control, &desc->control);
> +	return 1;
[snip]

> +
> +#define RX_DESCRIPTORS 64
> +static int dma_rx_num =3D RX_DESCRIPTORS;
> +module_param(dma_rx_num, int, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(dma_rx_num, "Number of descriptors in the RX list")=
;
> +
> +#define TX_DESCRIPTORS 64
> +static int dma_tx_num =3D TX_DESCRIPTORS;
> +module_param(dma_tx_num, int, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(dma_tx_num, "Number of descriptors in the TX list")=
;

Is this the software number of descriptors or hardware number of=20
descriptors?

[snip]

> +
> +static int altera_tse_mdio_create(struct net_device *dev, unsigned i=
nt id)
> +{
> +	struct altera_tse_private *priv =3D netdev_priv(dev);
> +	int ret;
> +	int i;
> +	struct device_node *mdio_node;
> +	struct mii_bus *mdio;
> +
> +	mdio_node =3D of_find_compatible_node(priv->device->of_node, NULL,
> +		"altr,tse-mdio");
> +
> +	if (mdio_node) {
> +		dev_warn(priv->device, "FOUND MDIO subnode\n");
> +	} else {
> +		dev_warn(priv->device, "NO MDIO subnode\n");
> +		return 0;
> +	}
> +
> +	mdio =3D mdiobus_alloc();
> +	if (mdio =3D=3D NULL) {
> +		dev_err(priv->device, "Error allocating MDIO bus\n");
> +		return -ENOMEM;
> +	}
> +
> +	mdio->name =3D ALTERA_TSE_RESOURCE_NAME;
> +	mdio->read =3D &altera_tse_mdio_read;
> +	mdio->write =3D &altera_tse_mdio_write;
> +	snprintf(mdio->id, MII_BUS_ID_SIZE, "%s-%u", mdio->name, id);

You could use something more user-friendly such as mdio_node->full_name=
=2E

> +
> +	mdio->irq =3D kcalloc(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL);
> +	if (mdio->irq =3D=3D NULL) {
> +		dev_err(priv->device, "%s: Cannot allocate memory\n", __func__);
> +		ret =3D -ENOMEM;
> +		goto out_free_mdio;
> +	}
> +	for (i =3D 0; i < PHY_MAX_ADDR; i++)
> +		mdio->irq[i] =3D PHY_POLL;
> +
> +	mdio->priv =3D (void *)priv->mac_dev;

No need for the cast here, this is already a void *.

> +	mdio->parent =3D priv->device;

[snip]

> +		/* make cache consistent with receive packet buffer */
> +		dma_sync_single_for_cpu(priv->device,
> +					priv->rx_ring[entry].dma_addr,
> +					priv->rx_ring[entry].len,
> +					DMA_FROM_DEVICE);
> +
> +		dma_unmap_single(priv->device, priv->rx_ring[entry].dma_addr,
> +				 priv->rx_ring[entry].len, DMA_FROM_DEVICE);
> +
> +		/* make sure all pending memory updates are complete */
> +		rmb();

Are you sure this does something in your case? I am fairly sure that th=
e=20
dma_unmap_single() call would have done that implicitely for you here.

[snip]

> +	if (txcomplete+rxcomplete !=3D budget) {
> +		napi_gro_flush(napi, false);
> +		__napi_complete(napi);
> +
> +		dev_dbg(priv->device,
> +			"NAPI Complete, did %d packets with budget %d\n",
> +			txcomplete+rxcomplete, budget);
> +	}

That is a bit unusual, a driver usually checks for the RX completion=20
return to match upto "budget"; you should reclaim as many TX buffers as=
=20
needed.

> +	spin_lock_irqsave(&priv->rxdma_irq_lock, flags);
> +	priv->enable_rxirq(priv);
> +	priv->enable_txirq(priv);
> +	spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
> +	return rxcomplete + txcomplete;
> +}
> +
> +/* DMA TX & RX FIFO interrupt routing
> + */
> +static irqreturn_t altera_isr(int irq, void *dev_id)
> +{
> +	struct net_device *dev =3D dev_id;
> +	struct altera_tse_private *priv;
> +	unsigned long int flags;
> +
> +
> +	if (unlikely(!dev)) {
> +		pr_err("%s: invalid dev pointer\n", __func__);
> +		return IRQ_NONE;
> +	}
> +	priv =3D netdev_priv(dev);
> +
> +	/* turn off desc irqs and enable napi rx */
> +	spin_lock_irqsave(&priv->rxdma_irq_lock, flags);
> +
> +	if (likely(napi_schedule_prep(&priv->napi))) {
> +		priv->disable_rxirq(priv);
> +		priv->disable_txirq(priv);
> +		__napi_schedule(&priv->napi);
> +	}
> +
> +	/* reset IRQs */
> +	priv->clear_rxirq(priv);
> +	priv->clear_txirq(priv);
> +
> +	spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
> +
> +	return IRQ_HANDLED;
> +}
> +
> +/* Transmit a packet (called by the kernel). Dispatches
> + * either the SGDMA method for transmitting or the
> + * MSGDMA method, assumes no scatter/gather support,
> + * implying an assumption that there's only one
> + * physically contiguous fragment starting at
> + * skb->data, for length of skb_headlen(skb).
> + */
> +static int tse_start_xmit(struct sk_buff *skb, struct net_device *de=
v)
> +{
> +	struct altera_tse_private *priv =3D netdev_priv(dev);
> +	unsigned int txsize =3D priv->tx_ring_size;
> +	unsigned int entry;
> +	struct tse_buffer *buffer =3D NULL;
> +	int nfrags =3D skb_shinfo(skb)->nr_frags;
> +	unsigned int nopaged_len =3D skb_headlen(skb);
> +	enum netdev_tx ret =3D NETDEV_TX_OK;
> +	dma_addr_t dma_addr;
> +	int txcomplete =3D 0;
> +
> +	spin_lock_bh(&priv->tx_lock);
> +
> +	if (unlikely(nfrags)) {
> +		dev_err(priv->device,
> +			"%s: nfrags must be 0, SG not supported\n", __func__);
> +		ret =3D NETDEV_TX_BUSY;
> +		goto out;
> +	}

I am not sure this will even be triggered if you want do not advertise=20
NETIF_F_SG, so you might want to drop that entirely.

> +
> +	if (unlikely(tse_tx_avail(priv) < nfrags + 1)) {
> +		if (!netif_queue_stopped(dev)) {
> +			netif_stop_queue(dev);
> +			/* This is a hard error, log it. */
> +			dev_err(priv->device,
> +				"%s: Tx list full when queue awake\n",
> +				__func__);
> +		}
> +		ret =3D NETDEV_TX_BUSY;
> +		goto out;
> +	}
> +
> +	/* Map the first skb fragment */
> +	entry =3D priv->tx_prod % txsize;
> +	buffer =3D &priv->tx_ring[entry];
> +
> +	dma_addr =3D dma_map_single(priv->device, skb->data, nopaged_len,
> +				  DMA_TO_DEVICE);
> +	if (dma_mapping_error(priv->device, dma_addr)) {
> +		dev_err(priv->device, "%s: DMA mapping error\n", __func__);
> +		ret =3D NETDEV_TX_BUSY;

NETDEV_TX_BUSY should only be returned in case you are attempting to=20
queue more packets than available, you want to return NETDEV_TX_OK here=
=2E

> +		goto out;
> +	}
> +
> +	buffer->skb =3D skb;
> +	buffer->dma_addr =3D dma_addr;
> +	buffer->len =3D nopaged_len;
> +
> +	/* Push data out of the cache hierarchy into main memory */
> +	dma_sync_single_for_device(priv->device, buffer->dma_addr,
> +				   buffer->len, DMA_TO_DEVICE);
> +
> +	/* Make sure the write buffers are bled ahead of initiated the I/O =
*/
> +	wmb();
> +
> +	txcomplete =3D priv->tx_buffer(priv, buffer);
> +
> +	priv->tx_prod++;
> +	dev->stats.tx_bytes +=3D skb->len;
> +
> +	if (unlikely(tse_tx_avail(priv) <=3D 2)) {

Why the value 2? Use a constant for this.

[snip]

> +/* Initialize driver's PHY state, and attach to the PHY
> + */
> +static int init_phy(struct net_device *dev)
> +{
> +	struct altera_tse_private *priv =3D netdev_priv(dev);
> +	struct phy_device *phydev;
> +	struct device_node *phynode;
> +
> +	priv->oldlink =3D 0;
> +	priv->oldspeed =3D 0;
> +	priv->oldduplex =3D -1;
> +
> +	phynode =3D of_parse_phandle(priv->device->of_node, "phy-handle", 0=
);
> +
> +	if (!phynode) {
> +		netdev_warn(dev, "no phy-handle found\n");
> +		if (!priv->mdio) {
> +			netdev_err(dev,
> +				   "No phy-handle nor local mdio specified\n");
> +			return -ENODEV;
> +		}
> +		phydev =3D connect_local_phy(dev);
> +	} else {
> +		netdev_warn(dev, "phy-handle found\n");
> +		phydev =3D of_phy_connect(dev, phynode,
> +			&altera_tse_adjust_link, 0, priv->phy_iface);
> +	}
> +
> +	/* Stop Advertising 1000BASE Capability if interface is not GMII
> +	 * Note: Checkpatch throws CHECKs for the camel case defines below,
> +	 * it's ok to ignore.
> +	 */
> +	if ((priv->phy_iface =3D=3D PHY_INTERFACE_MODE_MII) ||
> +	    (priv->phy_iface =3D=3D PHY_INTERFACE_MODE_RMII))
> +		phydev->advertising &=3D ~(SUPPORTED_1000baseT_Half |
> +					 SUPPORTED_1000baseT_Full);
> +
> +	/* Broken HW is sometimes missing the pull-up resistor on the
> +	 * MDIO line, which results in reads to non-existent devices return=
ing
> +	 * 0 rather than 0xffff. Catch this here and treat 0 as a non-exist=
ent
> +	 * device as well.
> +	 * Note: phydev->phy_id is the result of reading the UID PHY regist=
ers.
> +	 */
> +	if (phydev->phy_id =3D=3D 0) {
> +		netdev_err(dev, "Bad PHY UID 0x%08x\n", phydev->phy_id);
> +		phy_disconnect(phydev);
> +		return -ENODEV;
> +	}
> +
> +	dev_dbg(priv->device, "attached to PHY %d UID 0x%08x Link =3D %d\n"=
,
> +		phydev->addr, phydev->phy_id, phydev->link);
> +
> +	priv->phydev =3D phydev;
> +	return 0;

You might rather do this during your driver probe function rather than=20
in the ndo_open() callback.

[snip]

> +	/* Stop and disconnect the PHY */
> +	if (priv->phydev) {
> +		phy_stop(priv->phydev);
> +		phy_disconnect(priv->phydev);
> +		priv->phydev =3D NULL;
> +	}
> +
> +	netif_stop_queue(dev);
> +	napi_disable(&priv->napi);
> +
> +	/* Disable DMA interrupts */
> +	spin_lock_irqsave(&priv->rxdma_irq_lock, flags);
> +	priv->disable_rxirq(priv);
> +	priv->disable_txirq(priv);
> +	spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
> +
> +	/* Free the IRQ lines */
> +	free_irq(priv->rx_irq, dev);
> +	free_irq(priv->tx_irq, dev);
> +
> +	/* disable and reset the MAC, empties fifo */
> +	spin_lock(&priv->mac_cfg_lock);
> +	spin_lock(&priv->tx_lock);
> +
> +	ret =3D reset_mac(priv);
> +	if (ret)
> +		netdev_err(dev, "Cannot reset MAC core (error: %d)\n", ret);
> +	priv->reset_dma(priv);
> +	free_skbufs(dev);
> +
> +	spin_unlock(&priv->tx_lock);
> +	spin_unlock(&priv->mac_cfg_lock);
> +
> +	priv->uninit_dma(priv);
> +
> +	netif_carrier_off(dev);

phy_stop() does that already.

> +
> +	return 0;
> +}
> +
> +static struct net_device_ops altera_tse_netdev_ops =3D {
> +	.ndo_open		=3D tse_open,
> +	.ndo_stop		=3D tse_shutdown,
> +	.ndo_start_xmit		=3D tse_start_xmit,
> +	.ndo_set_mac_address	=3D eth_mac_addr,
> +	.ndo_set_rx_mode	=3D tse_set_rx_mode,
> +	.ndo_change_mtu		=3D tse_change_mtu,
> +	.ndo_validate_addr	=3D eth_validate_addr,
> +};
> +
> +static int altera_tse_get_of_prop(struct platform_device *pdev,
> +				  const char *name, unsigned int *val)
> +{
> +	const __be32 *tmp;
> +	int len;
> +	char buf[strlen(name)+1];
> +
> +	tmp =3D of_get_property(pdev->dev.of_node, name, &len);
> +	if (!tmp && !strncmp(name, "altr,", 5)) {
> +		strcpy(buf, name);
> +		strncpy(buf, "ALTR,", 5);
> +		tmp =3D of_get_property(pdev->dev.of_node, buf, &len);
> +	}
> +	if (!tmp || (len < sizeof(__be32)))
> +		return -ENODEV;
> +
> +	*val =3D be32_to_cpup(tmp);
> +	return 0;
> +}

Do we really need that abstration?

> +
> +static int altera_tse_get_phy_iface_prop(struct platform_device *pde=
v,
> +					 phy_interface_t *iface)
> +{
> +	const void *prop;
> +	int len;
> +
> +	prop =3D of_get_property(pdev->dev.of_node, "phy-mode", &len);
> +	if (!prop)
> +		return -ENOENT;
> +	if (len < 4)
> +		return -EINVAL;
> +
> +	if (!strncmp((char *)prop, "mii", 3)) {
> +		*iface =3D PHY_INTERFACE_MODE_MII;
> +		return 0;
> +	} else if (!strncmp((char *)prop, "gmii", 4)) {
> +		*iface =3D PHY_INTERFACE_MODE_GMII;
> +		return 0;
> +	} else if (!strncmp((char *)prop, "rgmii-id", 8)) {
> +		*iface =3D PHY_INTERFACE_MODE_RGMII_ID;
> +		return 0;
> +	} else if (!strncmp((char *)prop, "rgmii", 5)) {
> +		*iface =3D PHY_INTERFACE_MODE_RGMII;
> +		return 0;
> +	} else if (!strncmp((char *)prop, "sgmii", 5)) {
> +		*iface =3D PHY_INTERFACE_MODE_SGMII;
> +		return 0;
> +	}

of_get_phy_mode() does that for you.

> +
> +	return -EINVAL;
> +}
> +
> +static int request_and_map(struct platform_device *pdev, const char =
*name,
> +			   struct resource **res, void __iomem **ptr)
> +{
> +	struct resource *region;
> +	struct device *device =3D &pdev->dev;
> +
> +	*res =3D platform_get_resource_byname(pdev, IORESOURCE_MEM, name);
> +	if (*res =3D=3D NULL) {
> +		dev_err(device, "resource %s not defined\n", name);
> +		return -ENODEV;
> +	}
> +
> +	region =3D devm_request_mem_region(device, (*res)->start,
> +					 resource_size(*res), dev_name(device));
> +	if (region =3D=3D NULL) {
> +		dev_err(device, "unable to request %s\n", name);
> +		return -EBUSY;
> +	}
> +
> +	*ptr =3D devm_ioremap_nocache(device, region->start,
> +				    resource_size(region));
> +	if (*ptr =3D=3D NULL) {
> +		dev_err(device, "ioremap_nocache of %s failed!", name);
> +		return -ENOMEM;
> +	}
> +
> +	return 0;
> +}
> +
> +/* Probe Altera TSE MAC device
> + */
> +static int altera_tse_probe(struct platform_device *pdev)
> +{
> +	struct net_device *ndev;
> +	int ret =3D -ENODEV;
> +	struct resource *control_port;
> +	struct resource *dma_res;
> +	struct altera_tse_private *priv;
> +	int len;
> +	const unsigned char *macaddr;
> +	struct device_node *np =3D pdev->dev.of_node;
> +	unsigned int descmap;
> +
> +	ndev =3D alloc_etherdev(sizeof(struct altera_tse_private));
> +	if (!ndev) {
> +		dev_err(&pdev->dev, "Could not allocate network device\n");
> +		return -ENODEV;
> +	}
> +
> +	SET_NETDEV_DEV(ndev, &pdev->dev);
> +
> +	priv =3D netdev_priv(ndev);
> +	priv->device =3D &pdev->dev;
> +	priv->dev =3D ndev;
> +	priv->msg_enable =3D netif_msg_init(debug, default_msg_level);
> +
> +	if (of_device_is_compatible(np, "altr,tse-1.0") ||
> +	    of_device_is_compatible(np, "ALTR,tse-1.0")) {

Use the .data pointer associated with the compatible string to help you=
=20
do that, see below.

[snip]

> +	/* get supplemental address settings for this instance */
> +	ret =3D altera_tse_get_of_prop(pdev, "altr,enable-sup-addr",
> +				     &priv->added_unicast);
> +	if (ret)
> +		priv->added_unicast =3D 0;
> +
> +	/* Max MTU is 1500, ETH_DATA_LEN */
> +	priv->max_mtu =3D ETH_DATA_LEN;

How about VLANs? If this is always 1500, just let the core ethernet=20
functions configure the MTU for your interface.

> +
> +	/* The DMA buffer size already accounts for an alignment bias
> +	 * to avoid unaligned access exceptions for the NIOS processor,
> +	 */
> +	priv->rx_dma_buf_sz =3D ALTERA_RXDMABUFFER_SIZE;
> +
> +	/* get default MAC address from device tree */
> +	macaddr =3D of_get_property(pdev->dev.of_node, "local-mac-address",=
 &len);
> +	if (macaddr && len =3D=3D ETH_ALEN)
> +		memcpy(ndev->dev_addr, macaddr, ETH_ALEN);
> +
> +	/* If we didn't get a valid address, generate a random one */
> +	if (!is_valid_ether_addr(ndev->dev_addr))
> +		eth_hw_addr_random(ndev);
> +
> +	ret =3D altera_tse_get_phy_iface_prop(pdev, &priv->phy_iface);
> +	if (ret =3D=3D -ENOENT) {
> +		/* backward compatability, assume RGMII */
> +		dev_warn(&pdev->dev,
> +			 "cannot obtain PHY interface mode, assuming RGMII\n");
> +		priv->phy_iface =3D PHY_INTERFACE_MODE_RGMII;
> +	} else if (ret) {
> +		dev_err(&pdev->dev, "unknown PHY interface mode\n");
> +		goto out_free;
> +	}
> +
> +	/* try to get PHY address from device tree, use PHY autodetection i=
f
> +	 * no valid address is given
> +	 */
> +	ret =3D altera_tse_get_of_prop(pdev, "altr,phy-addr", &priv->phy_ad=
dr);
> +	if (ret)
> +		priv->phy_addr =3D POLL_PHY;

Please do not use such as custom property, either you use an Ethernet=20
PHY device tree node as described in ePAPR; or you do not and use a=20
fixed-link property instead.

> +
> +	if (!((priv->phy_addr =3D=3D POLL_PHY) ||
> +	      ((priv->phy_addr >=3D 0) && (priv->phy_addr < PHY_MAX_ADDR)))=
) {
> +		dev_err(&pdev->dev, "invalid altr,phy-addr specified %d\n",
> +			priv->phy_addr);
> +		goto out_free;
> +	}
> +
> +	/* Create/attach to MDIO bus */
> +	ret =3D altera_tse_mdio_create(ndev,
> +				     atomic_add_return(1, &instance_count));
> +
> +	if (ret)
> +		goto out_free;
> +
> +	/* initialize netdev */
> +	ether_setup(ndev);
> +	ndev->mem_start =3D control_port->start;
> +	ndev->mem_end =3D control_port->end;
> +	ndev->netdev_ops =3D &altera_tse_netdev_ops;
> +	altera_tse_set_ethtool_ops(ndev);
> +
> +	altera_tse_netdev_ops.ndo_set_rx_mode =3D tse_set_rx_mode;
> +
> +	if (priv->hash_filter)
> +		altera_tse_netdev_ops.ndo_set_rx_mode =3D
> +			tse_set_rx_mode_hashfilter;
> +
> +	/* Scatter/gather IO is not supported,
> +	 * so it is turned off
> +	 */
> +	ndev->hw_features &=3D ~NETIF_F_SG;
> +	ndev->features |=3D ndev->hw_features | NETIF_F_HIGHDMA;
> +
> +	/* VLAN offloading of tagging, stripping and filtering is not
> +	 * supported by hardware, but driver will accommodate the
> +	 * extra 4-byte VLAN tag for processing by upper layers
> +	 */
> +	ndev->features |=3D NETIF_F_HW_VLAN_CTAG_RX;
> +
> +	/* setup NAPI interface */
> +	netif_napi_add(ndev, &priv->napi, tse_poll, NAPI_POLL_WEIGHT);
> +
> +	spin_lock_init(&priv->mac_cfg_lock);
> +	spin_lock_init(&priv->tx_lock);
> +	spin_lock_init(&priv->rxdma_irq_lock);
> +
> +	ret =3D register_netdev(ndev);
> +	if (ret) {
> +		dev_err(&pdev->dev, "failed to register TSE net device\n");
> +		goto out_free_mdio;
> +	}
> +
> +	platform_set_drvdata(pdev, ndev);
> +
> +	priv->revision =3D ioread32(&priv->mac_dev->megacore_revision);
> +
> +	if (netif_msg_probe(priv))
> +		dev_info(&pdev->dev, "Altera TSE MAC version %d.%d at 0x%08lx irq =
%d/%d\n",
> +			 (priv->revision >> 8) & 0xff,
> +			 priv->revision & 0xff,
> +			 (unsigned long) control_port->start, priv->rx_irq,
> +			 priv->tx_irq);
> +	return 0;
> +
> +out_free_mdio:
> +	altera_tse_mdio_destroy(ndev);
> +out_free:
> +	free_netdev(ndev);
> +	return ret;
> +}
> +
> +/* Remove Altera TSE MAC device
> + */
> +static int altera_tse_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev =3D platform_get_drvdata(pdev);
> +
> +	platform_set_drvdata(pdev, NULL);
> +	if (ndev) {
> +		altera_tse_mdio_destroy(ndev);
> +		netif_carrier_off(ndev);

That call is not needed; the interface would be brought down before. Is=
=20
there a case where we might get called with ndev NULLL?

> +		unregister_netdev(ndev);
> +		free_netdev(ndev);
> +	}
> +
> +	return 0;
> +}
> +
> +static struct of_device_id altera_tse_of_match[] =3D {
> +	{ .compatible =3D "altr,tse-1.0", },
> +	{ .compatible =3D "ALTR,tse-1.0", },
> +	{ .compatible =3D "altr,tse-msgdma-1.0", },

I would use a .data pointer here to help assigning the DMA engine=20
configuration which is done in the probe routine of the driver, see the=
=20
=46EC or bcmgenet driver for examples.

> +	{},
> +};
> +MODULE_DEVICE_TABLE(of, altera_tse_of_match);
> +
> +static struct platform_driver altera_tse_driver =3D {
> +	.probe		=3D altera_tse_probe,
> +	.remove		=3D altera_tse_remove,
> +	.suspend	=3D NULL,
> +	.resume		=3D NULL,
> +	.driver		=3D {
> +		.name	=3D ALTERA_

,
> +		.owner	=3D THIS_MODULE,
> +		.of_match_table =3D altera_tse_of_match,
> +	},
> +};
> +
> +module_platform_driver(altera_tse_driver);
> +
> +MODULE_AUTHOR("Altera Corporation");
> +MODULE_DESCRIPTION("Altera Triple Speed Ethernet MAC driver");
> +MODULE_LICENSE("GPL v2");

[snip]

> +static void tse_get_drvinfo(struct net_device *dev,
> +			    struct ethtool_drvinfo *info)
> +{
> +	struct altera_tse_private *priv =3D netdev_priv(dev);
> +	u32 rev =3D ioread32(&priv->mac_dev->megacore_revision);
> +
> +	strcpy(info->driver, "Altera TSE MAC IP Driver");
> +	strcpy(info->version, "v8.0");
> +	snprintf(info->fw_version, ETHTOOL_FWVERS_LEN, "v%d.%d",
> +		 rev & 0xFFFF, (rev & 0xFFFF0000) >> 16);
> +	sprintf(info->bus_info, "AVALON");

"platform" would be more traditional than "AVALON" which is supposedly=20
some internal SoC bussing right? In general we want to tell user-space=20
whether this is PCI(e), USB, on-chip or something entirely different.
--
=46lorian
