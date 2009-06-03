From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2] netdev: Added KS8842 driver
Date: Thu, 4 Jun 2009 00:41:47 +0200
Message-ID: <20090603224147.GB24847@electric-eye.fr.zoreil.com>
References: <4A2646F5.6050304@mocean-labs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Richard =?iso-8859-1?Q?R=3F=F6jfors?=
	<richard.rojfors.ext@mocean-labs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59230 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754465AbZFCWkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 18:40:03 -0400
Content-Disposition: inline
In-Reply-To: <4A2646F5.6050304@mocean-labs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard R?=F6jfors <richard.rojfors.ext@mocean-labs.com> :
[...]
> Index: linux-2.6.30-rc7/drivers/net/ks8842.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.30-rc7/drivers/net/ks8842.c	(revision 0)
> +++ linux-2.6.30-rc7/drivers/net/ks8842.c	(revision 872)
[...]
> +struct ks8842_adapter {
> +	u8 __iomem	*hw_addr;

void __iomem *hw_addr;

(nit)

> +	int		irq;
> +	struct tasklet_struct	tasklet;
> +	spinlock_t	lock; /* spinlock to be interrupt safe */
> +	struct net_device_stats	net_stats;

Redundant with include/linux/netdevice.h::struct net_device.stats

[...]
> +static int ks8842_tx_frame(struct sk_buff *skb, struct net_device *n=
etdev)
> +{
> +	struct ks8842_adapter *adapter =3D netdev_priv(netdev);
> +	int len =3D skb->len;
> +	u32 *ptr =3D (u32 *)skb->data;
> +	u32 ctrl;
> +
> +	dev_dbg(&adapter->pdev->dev,
> +		"%s: len %u head %p data %p tail %p end %p\n",
> +		__func__, skb->len, skb->head, skb->data,
> +		skb_tail_pointer(skb), skb_end_pointer(skb));
> +
> +	/* check FIFO buffer space, we need space for CRC and command bits =
*/
> +	if (ks8842_tx_fifo_space(adapter) < len + 8)
> +		return -ENOBUFS;

NETDEV_TX_BUSY

(it should complain loudly)

> +
> +	/* the control word, enable IRQ, port 1 and the length */
> +	ctrl =3D 0x8000 | 0x100 | (len << 16);
> +	ks8842_write32(adapter, 17, ctrl, REG_QMU_DATA_LO);
> +
> +	adapter->net_stats.tx_bytes +=3D len;
> +
> +	/* copy buffer */
> +	while (len > 0) {
> +		iowrite32(*ptr, adapter->hw_addr + REG_QMU_DATA_LO);
> +		len -=3D sizeof(u32);
> +		ptr++;
> +	}
> +
> +	/* enqueue packet */
> +	ks8842_write16(adapter, 17, 1, REG_TXQCR);
> +
> +	dev_kfree_skb(skb);
> +
> +	return 0;

NETDEV_TX_OK

> +}
> +
> +static void ks8842_rx_frame(struct net_device *netdev,
> +	struct ks8842_adapter *adapter)
> +{
> +	u32 status =3D ks8842_read32(adapter, 17, REG_QMU_DATA_LO);
> +	int len =3D (status >> 16) & 0x7ff;
> +
> +	status &=3D 0xffff;
> +
> +	dev_dbg(&adapter->pdev->dev, "%s - rx_data: status: %x\n",
> +		__func__, status);
> +
> +	/* check the status */
> +	if ((status & RXSR_VALID) && !(status & RXSR_ERROR)) {
> +		struct sk_buff *skb =3D dev_alloc_skb(len + 2);

Please use netdev_alloc_skb and remove 'skb->dev =3D netdev;' below.

> +
> +		dev_dbg(&adapter->pdev->dev, "%s, got package, len: %d\n",
> +			__func__, len);
> +		if (skb) {
> +			u32 *data;
> +
> +			adapter->net_stats.rx_packets++;
> +			adapter->net_stats.rx_bytes +=3D len;
> +			if (status & RXSR_MULTICAST)
> +				adapter->net_stats.multicast++;
> +
> +			/* Align socket buffer in 4-byte boundary for
> +				 better performance. */
> +			skb_reserve(skb, 2);
> +			data =3D (u32 *)skb_put(skb, len);
> +
> +			ks8842_select_bank(adapter, 17);
> +			while (len > 0) {
> +				*data++ =3D ioread32(adapter->hw_addr +
> +					REG_QMU_DATA_LO);
> +				len -=3D sizeof(u32);
> +			}
> +
> +			skb->dev =3D netdev;
> +			skb->protocol =3D eth_type_trans(skb, netdev);
> +			netdev->last_rx =3D jiffies;

last_rx is obsolete here.

See commit babcda74e9d96bb58fd9c6c5112dbdbff169e695 for specifics.

[...]
> +static irqreturn_t ks8842_irq(int irq, void *devid)
> +{
> +	struct ks8842_adapter *adapter =3D (struct ks8842_adapter *)devid;

Needless cast from void *.

[...]
> +static int ks8842_open(struct net_device *netdev)
> +{
> +	struct ks8842_adapter *adapter =3D netdev_priv(netdev);
> +	int err;
> +
> +	dev_dbg(&adapter->pdev->dev, "%s - entry\n", __func__);
> +
> +	/* reset the HW */
> +	ks8842_reset_hw(adapter);
> +
> +	ks8842_update_link_status(netdev, adapter);
> +
> +	err =3D request_irq(adapter->irq, ks8842_irq, IRQF_SHARED, DRV_NAME=
,
> +		adapter);
> +	if (err) {
> +		printk(KERN_ERR "Failed to request IRQ: %d: %d\n",
> +			adapter->irq, err);
> +		return err;
> +	}

Does the platform ensure that it produces the same result as a
reset/request_irq/enable cycle ?

[...]
> +static int __devinit ks8842_probe(struct platform_device *pdev)
> +{
> +	int err =3D -ENOMEM;
> +	struct resource *iomem;
> +	struct net_device *netdev;
> +	struct ks8842_adapter *adapter;
> +	u16 id;
> +
> +	iomem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	if (!request_mem_region(iomem->start, resource_size(iomem), DRV_NAM=
E))
> +		goto err_mem_region;
> +
> +	netdev =3D alloc_etherdev(sizeof(struct ks8842_adapter));
> +	if (!netdev)
> +		goto err_alloc_etherdev;
> +
> +	SET_NETDEV_DEV(netdev, &pdev->dev);
> +
> +	adapter =3D netdev_priv(netdev);
> +	adapter->hw_addr =3D ioremap(iomem->start, resource_size(iomem));
> +	if (!adapter->hw_addr)
> +		goto err_ioremap;
> +
> +	adapter->irq =3D platform_get_irq(pdev, 0);
> +	if (adapter->irq < 0) {
> +		err =3D adapter->irq;
> +		goto err_get_irq;
> +	}
> +
> +	adapter->pdev =3D pdev;
> +
> +	tasklet_init(&adapter->tasklet, ks8842_tasklet, (unsigned long)netd=
ev);
> +	spin_lock_init(&adapter->lock);
> +
> +	netdev->netdev_ops =3D &ks8842_netdev_ops;
> +	netdev->ethtool_ops =3D &ks8842_ethtool_ops;
> +
> +	strncpy(netdev->name, DRV_NAME, sizeof(netdev->name) - 1);

What's the point ?

> +
> +	ks8842_read_mac_addr(adapter, netdev->dev_addr);
> +
> +	id =3D ks8842_read16(adapter, 32, REG_SW_ID_AND_ENABLE);
> +
> +	/* tell the stack to leave us alone until ks8842_open() is called *=
/
> +	netif_carrier_off(netdev);
> +	netif_stop_queue(netdev);

Useless.

> +	strcpy(netdev->name, "eth%d");
> +	err =3D register_netdev(netdev);
> +	if (err)
> +		goto err_register;
> +
> +	platform_set_drvdata(pdev, netdev);
> +
> +	printk(KERN_INFO DRV_NAME
> +		" Found chip, family: 0x%x, id: 0x%x, rev: 0x%x\n",
> +		(id >> 8) & 0xff, (id >> 4) & 0xf, (id >> 1) & 0x7);
> +
> +	return 0;
> +
> +err_register:
> +err_get_irq:
> +	iounmap(adapter->hw_addr);
> +err_ioremap:
> +	kfree(netdev);

free_netdev(netdev);

> +err_alloc_etherdev:
> +	release_mem_region(iomem->start, resource_size(iomem));
> +err_mem_region:
> +	return err;
> +}
> +
> +static int __devexit ks8842_remove(struct platform_device *pdev)
> +{
> +	struct net_device *netdev =3D platform_get_drvdata(pdev);
> +	struct ks8842_adapter *adapter =3D netdev_priv(netdev);
> +	struct resource *iomem =3D platform_get_resource(pdev, IORESOURCE_M=
EM, 0);
> +
> +	unregister_netdev(netdev);
> +	tasklet_kill(&adapter->tasklet);
> +	iounmap(adapter->hw_addr);
> +	kfree(netdev);

free_netdev(netdev);

> +	release_mem_region(iomem->start, resource_size(iomem));
> +	platform_set_drvdata(pdev, NULL);
> +	return 0;
> +}

The tasklet seems right but I have not looked too closely at it.

--=20
Ueimor
