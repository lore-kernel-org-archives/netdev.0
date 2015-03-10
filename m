From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 10 Mar 2015 12:08:42 +1100
Message-ID: <20150310120842.6dfa6c2b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/5JLXp11bE8Xw2fboG=Bh1PO"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Josh Cartwright <joshc@ni.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/5JLXp11bE8Xw2fboG=Bh1PO
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/cadence/macb.c between commit 0b2eb3e9bc73 ("net:
macb: constify macb configuration data") from the net tree and commits
a848748959d5 ("net: macb: remove #if defined(CONFIG_ARCH_AT91)
sections") and 421d9df0628b ("net/macb: merge at91_ether driver into
macb driver") from the net-next tree.

I fixed it up (I think - see below) and can carry the fix as necessary
(no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/cadence/macb.c
index 81d41539fcba,a4c5462c071a..000000000000
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@@ -2366,12 -2294,433 +2294,433 @@@ static int macb_init(struct platform_de
  		dev->hw_features &=3D ~NETIF_F_SG;
  	dev->features =3D dev->hw_features;
 =20
+ 	val =3D 0;
+ 	if (bp->phy_interface =3D=3D PHY_INTERFACE_MODE_RGMII)
+ 		val =3D GEM_BIT(RGMII);
+ 	else if (bp->phy_interface =3D=3D PHY_INTERFACE_MODE_RMII &&
+ 		 (bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
+ 		val =3D MACB_BIT(RMII);
+ 	else if (!(bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
+ 		val =3D MACB_BIT(MII);
+=20
+ 	if (bp->caps & MACB_CAPS_USRIO_HAS_CLKEN)
+ 		val |=3D MACB_BIT(CLKEN);
+=20
+ 	macb_or_gem_writel(bp, USRIO, val);
+=20
+ 	/* setup capacities */
+ 	macb_configure_caps(bp);
+=20
  	/* Set MII management clock divider */
- 	config =3D macb_mdc_clk_div(bp);
- 	config |=3D macb_dbw(bp);
- 	macb_writel(bp, NCFGR, config);
+ 	val =3D macb_mdc_clk_div(bp);
+ 	val |=3D macb_dbw(bp);
+ 	macb_writel(bp, NCFGR, val);
+=20
+ 	return 0;
+=20
+ err_disable_tx_clk:
+ 	clk_disable_unprepare(bp->tx_clk);
+=20
+ err_disable_hclk:
+ 	clk_disable_unprepare(bp->hclk);
+=20
+ err_disable_pclk:
+ 	clk_disable_unprepare(bp->pclk);
+=20
+ 	return err;
+ }
+=20
+ #if defined(CONFIG_OF)
+ /* 1518 rounded up */
+ #define AT91ETHER_MAX_RBUFF_SZ	0x600
+ /* max number of receive buffers */
+ #define AT91ETHER_MAX_RX_DESCR	9
+=20
+ /* Initialize and start the Receiver and Transmit subsystems */
+ static int at91ether_start(struct net_device *dev)
+ {
+ 	struct macb *lp =3D netdev_priv(dev);
+ 	dma_addr_t addr;
+ 	u32 ctl;
+ 	int i;
+=20
+ 	lp->rx_ring =3D dma_alloc_coherent(&lp->pdev->dev,
+ 					 (AT91ETHER_MAX_RX_DESCR *
+ 					  sizeof(struct macb_dma_desc)),
+ 					 &lp->rx_ring_dma, GFP_KERNEL);
+ 	if (!lp->rx_ring)
+ 		return -ENOMEM;
+=20
+ 	lp->rx_buffers =3D dma_alloc_coherent(&lp->pdev->dev,
+ 					    AT91ETHER_MAX_RX_DESCR *
+ 					    AT91ETHER_MAX_RBUFF_SZ,
+ 					    &lp->rx_buffers_dma, GFP_KERNEL);
+ 	if (!lp->rx_buffers) {
+ 		dma_free_coherent(&lp->pdev->dev,
+ 				  AT91ETHER_MAX_RX_DESCR *
+ 				  sizeof(struct macb_dma_desc),
+ 				  lp->rx_ring, lp->rx_ring_dma);
+ 		lp->rx_ring =3D NULL;
+ 		return -ENOMEM;
+ 	}
+=20
+ 	addr =3D lp->rx_buffers_dma;
+ 	for (i =3D 0; i < AT91ETHER_MAX_RX_DESCR; i++) {
+ 		lp->rx_ring[i].addr =3D addr;
+ 		lp->rx_ring[i].ctrl =3D 0;
+ 		addr +=3D AT91ETHER_MAX_RBUFF_SZ;
+ 	}
+=20
+ 	/* Set the Wrap bit on the last descriptor */
+ 	lp->rx_ring[AT91ETHER_MAX_RX_DESCR - 1].addr |=3D MACB_BIT(RX_WRAP);
+=20
+ 	/* Reset buffer index */
+ 	lp->rx_tail =3D 0;
+=20
+ 	/* Program address of descriptor list in Rx Buffer Queue register */
+ 	macb_writel(lp, RBQP, lp->rx_ring_dma);
+=20
+ 	/* Enable Receive and Transmit */
+ 	ctl =3D macb_readl(lp, NCR);
+ 	macb_writel(lp, NCR, ctl | MACB_BIT(RE) | MACB_BIT(TE));
+=20
+ 	return 0;
+ }
+=20
+ /* Open the ethernet interface */
+ static int at91ether_open(struct net_device *dev)
+ {
+ 	struct macb *lp =3D netdev_priv(dev);
+ 	u32 ctl;
+ 	int ret;
+=20
+ 	/* Clear internal statistics */
+ 	ctl =3D macb_readl(lp, NCR);
+ 	macb_writel(lp, NCR, ctl | MACB_BIT(CLRSTAT));
+=20
+ 	macb_set_hwaddr(lp);
+=20
+ 	ret =3D at91ether_start(dev);
+ 	if (ret)
+ 		return ret;
+=20
+ 	/* Enable MAC interrupts */
+ 	macb_writel(lp, IER, MACB_BIT(RCOMP)	|
+ 			     MACB_BIT(RXUBR)	|
+ 			     MACB_BIT(ISR_TUND)	|
+ 			     MACB_BIT(ISR_RLE)	|
+ 			     MACB_BIT(TCOMP)	|
+ 			     MACB_BIT(ISR_ROVR)	|
+ 			     MACB_BIT(HRESP));
+=20
+ 	/* schedule a link state check */
+ 	phy_start(lp->phy_dev);
+=20
+ 	netif_start_queue(dev);
+=20
+ 	return 0;
+ }
+=20
+ /* Close the interface */
+ static int at91ether_close(struct net_device *dev)
+ {
+ 	struct macb *lp =3D netdev_priv(dev);
+ 	u32 ctl;
+=20
+ 	/* Disable Receiver and Transmitter */
+ 	ctl =3D macb_readl(lp, NCR);
+ 	macb_writel(lp, NCR, ctl & ~(MACB_BIT(TE) | MACB_BIT(RE)));
+=20
+ 	/* Disable MAC interrupts */
+ 	macb_writel(lp, IDR, MACB_BIT(RCOMP)	|
+ 			     MACB_BIT(RXUBR)	|
+ 			     MACB_BIT(ISR_TUND)	|
+ 			     MACB_BIT(ISR_RLE)	|
+ 			     MACB_BIT(TCOMP)	|
+ 			     MACB_BIT(ISR_ROVR) |
+ 			     MACB_BIT(HRESP));
+=20
+ 	netif_stop_queue(dev);
+=20
+ 	dma_free_coherent(&lp->pdev->dev,
+ 			  AT91ETHER_MAX_RX_DESCR *
+ 			  sizeof(struct macb_dma_desc),
+ 			  lp->rx_ring, lp->rx_ring_dma);
+ 	lp->rx_ring =3D NULL;
+=20
+ 	dma_free_coherent(&lp->pdev->dev,
+ 			  AT91ETHER_MAX_RX_DESCR * AT91ETHER_MAX_RBUFF_SZ,
+ 			  lp->rx_buffers, lp->rx_buffers_dma);
+ 	lp->rx_buffers =3D NULL;
+=20
+ 	return 0;
+ }
+=20
+ /* Transmit packet */
+ static int at91ether_start_xmit(struct sk_buff *skb, struct net_device *d=
ev)
+ {
+ 	struct macb *lp =3D netdev_priv(dev);
+=20
+ 	if (macb_readl(lp, TSR) & MACB_BIT(RM9200_BNQ)) {
+ 		netif_stop_queue(dev);
 =20
- 	mac =3D of_get_mac_address(pdev->dev.of_node);
+ 		/* Store packet information (to free when Tx completed) */
+ 		lp->skb =3D skb;
+ 		lp->skb_length =3D skb->len;
+ 		lp->skb_physaddr =3D dma_map_single(NULL, skb->data, skb->len,
+ 							DMA_TO_DEVICE);
+=20
+ 		/* Set address of the data in the Transmit Address register */
+ 		macb_writel(lp, TAR, lp->skb_physaddr);
+ 		/* Set length of the packet in the Transmit Control register */
+ 		macb_writel(lp, TCR, skb->len);
+=20
+ 	} else {
+ 		netdev_err(dev, "%s called, but device is busy!\n", __func__);
+ 		return NETDEV_TX_BUSY;
+ 	}
+=20
+ 	return NETDEV_TX_OK;
+ }
+=20
+ /* Extract received frame from buffer descriptors and sent to upper layer=
s.
+  * (Called from interrupt context)
+  */
+ static void at91ether_rx(struct net_device *dev)
+ {
+ 	struct macb *lp =3D netdev_priv(dev);
+ 	unsigned char *p_recv;
+ 	struct sk_buff *skb;
+ 	unsigned int pktlen;
+=20
+ 	while (lp->rx_ring[lp->rx_tail].addr & MACB_BIT(RX_USED)) {
+ 		p_recv =3D lp->rx_buffers + lp->rx_tail * AT91ETHER_MAX_RBUFF_SZ;
+ 		pktlen =3D MACB_BF(RX_FRMLEN, lp->rx_ring[lp->rx_tail].ctrl);
+ 		skb =3D netdev_alloc_skb(dev, pktlen + 2);
+ 		if (skb) {
+ 			skb_reserve(skb, 2);
+ 			memcpy(skb_put(skb, pktlen), p_recv, pktlen);
+=20
+ 			skb->protocol =3D eth_type_trans(skb, dev);
+ 			lp->stats.rx_packets++;
+ 			lp->stats.rx_bytes +=3D pktlen;
+ 			netif_rx(skb);
+ 		} else {
+ 			lp->stats.rx_dropped++;
+ 		}
+=20
+ 		if (lp->rx_ring[lp->rx_tail].ctrl & MACB_BIT(RX_MHASH_MATCH))
+ 			lp->stats.multicast++;
+=20
+ 		/* reset ownership bit */
+ 		lp->rx_ring[lp->rx_tail].addr &=3D ~MACB_BIT(RX_USED);
+=20
+ 		/* wrap after last buffer */
+ 		if (lp->rx_tail =3D=3D AT91ETHER_MAX_RX_DESCR - 1)
+ 			lp->rx_tail =3D 0;
+ 		else
+ 			lp->rx_tail++;
+ 	}
+ }
+=20
+ /* MAC interrupt handler */
+ static irqreturn_t at91ether_interrupt(int irq, void *dev_id)
+ {
+ 	struct net_device *dev =3D dev_id;
+ 	struct macb *lp =3D netdev_priv(dev);
+ 	u32 intstatus, ctl;
+=20
+ 	/* MAC Interrupt Status register indicates what interrupts are pending.
+ 	 * It is automatically cleared once read.
+ 	 */
+ 	intstatus =3D macb_readl(lp, ISR);
+=20
+ 	/* Receive complete */
+ 	if (intstatus & MACB_BIT(RCOMP))
+ 		at91ether_rx(dev);
+=20
+ 	/* Transmit complete */
+ 	if (intstatus & MACB_BIT(TCOMP)) {
+ 		/* The TCOM bit is set even if the transmission failed */
+ 		if (intstatus & (MACB_BIT(ISR_TUND) | MACB_BIT(ISR_RLE)))
+ 			lp->stats.tx_errors++;
+=20
+ 		if (lp->skb) {
+ 			dev_kfree_skb_irq(lp->skb);
+ 			lp->skb =3D NULL;
+ 			dma_unmap_single(NULL, lp->skb_physaddr,
+ 					 lp->skb_length, DMA_TO_DEVICE);
+ 			lp->stats.tx_packets++;
+ 			lp->stats.tx_bytes +=3D lp->skb_length;
+ 		}
+ 		netif_wake_queue(dev);
+ 	}
+=20
+ 	/* Work-around for EMAC Errata section 41.3.1 */
+ 	if (intstatus & MACB_BIT(RXUBR)) {
+ 		ctl =3D macb_readl(lp, NCR);
+ 		macb_writel(lp, NCR, ctl & ~MACB_BIT(RE));
+ 		macb_writel(lp, NCR, ctl | MACB_BIT(RE));
+ 	}
+=20
+ 	if (intstatus & MACB_BIT(ISR_ROVR))
+ 		netdev_err(dev, "ROVR error\n");
+=20
+ 	return IRQ_HANDLED;
+ }
+=20
+ #ifdef CONFIG_NET_POLL_CONTROLLER
+ static void at91ether_poll_controller(struct net_device *dev)
+ {
+ 	unsigned long flags;
+=20
+ 	local_irq_save(flags);
+ 	at91ether_interrupt(dev->irq, dev);
+ 	local_irq_restore(flags);
+ }
+ #endif
+=20
+ static const struct net_device_ops at91ether_netdev_ops =3D {
+ 	.ndo_open		=3D at91ether_open,
+ 	.ndo_stop		=3D at91ether_close,
+ 	.ndo_start_xmit		=3D at91ether_start_xmit,
+ 	.ndo_get_stats		=3D macb_get_stats,
+ 	.ndo_set_rx_mode	=3D macb_set_rx_mode,
+ 	.ndo_set_mac_address	=3D eth_mac_addr,
+ 	.ndo_do_ioctl		=3D macb_ioctl,
+ 	.ndo_validate_addr	=3D eth_validate_addr,
+ 	.ndo_change_mtu		=3D eth_change_mtu,
+ #ifdef CONFIG_NET_POLL_CONTROLLER
+ 	.ndo_poll_controller	=3D at91ether_poll_controller,
+ #endif
+ };
+=20
+ static int at91ether_init(struct platform_device *pdev)
+ {
+ 	struct net_device *dev =3D platform_get_drvdata(pdev);
+ 	struct macb *bp =3D netdev_priv(dev);
+ 	int err;
+ 	u32 reg;
+=20
+ 	bp->pclk =3D devm_clk_get(&pdev->dev, "ether_clk");
+ 	if (IS_ERR(bp->pclk))
+ 		return PTR_ERR(bp->pclk);
+=20
+ 	err =3D clk_prepare_enable(bp->pclk);
+ 	if (err) {
+ 		dev_err(&pdev->dev, "failed to enable pclk (%u)\n", err);
+ 		return err;
+ 	}
+=20
+ 	dev->netdev_ops =3D &at91ether_netdev_ops;
+ 	dev->ethtool_ops =3D &macb_ethtool_ops;
+=20
+ 	err =3D devm_request_irq(&pdev->dev, dev->irq, at91ether_interrupt,
+ 			       0, dev->name, dev);
+ 	if (err)
+ 		goto err_disable_clk;
+=20
+ 	macb_writel(bp, NCR, 0);
+=20
+ 	reg =3D MACB_BF(CLK, MACB_CLK_DIV32) | MACB_BIT(BIG);
+ 	if (bp->phy_interface =3D=3D PHY_INTERFACE_MODE_RMII)
+ 		reg |=3D MACB_BIT(RM9200_RMII);
+=20
+ 	macb_writel(bp, NCFGR, reg);
+=20
+ 	return 0;
+=20
+ err_disable_clk:
+ 	clk_disable_unprepare(bp->pclk);
+=20
+ 	return err;
+ }
+=20
 -static struct macb_config at91sam9260_config =3D {
++static const struct macb_config at91sam9260_config =3D {
+ 	.caps =3D MACB_CAPS_USRIO_HAS_CLKEN | MACB_CAPS_USRIO_DEFAULT_IS_MII,
+ 	.init =3D macb_init,
+ };
+=20
 -static struct macb_config pc302gem_config =3D {
++static const struct macb_config pc302gem_config =3D {
+ 	.caps =3D MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
+ 	.dma_burst_length =3D 16,
+ 	.init =3D macb_init,
+ };
+=20
 -static struct macb_config sama5d3_config =3D {
++static const struct macb_config sama5d3_config =3D {
+ 	.caps =3D MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
+ 	.dma_burst_length =3D 16,
+ 	.init =3D macb_init,
+ };
+=20
 -static struct macb_config sama5d4_config =3D {
++static const struct macb_config sama5d4_config =3D {
+ 	.caps =3D 0,
+ 	.dma_burst_length =3D 4,
+ 	.init =3D macb_init,
+ };
+=20
 -static struct macb_config emac_config =3D {
++static const struct macb_config emac_config =3D {
+ 	.init =3D at91ether_init,
+ };
+=20
+ static const struct of_device_id macb_dt_ids[] =3D {
+ 	{ .compatible =3D "cdns,at32ap7000-macb" },
+ 	{ .compatible =3D "cdns,at91sam9260-macb", .data =3D &at91sam9260_config=
 },
+ 	{ .compatible =3D "cdns,macb" },
+ 	{ .compatible =3D "cdns,pc302-gem", .data =3D &pc302gem_config },
+ 	{ .compatible =3D "cdns,gem", .data =3D &pc302gem_config },
+ 	{ .compatible =3D "atmel,sama5d3-gem", .data =3D &sama5d3_config },
+ 	{ .compatible =3D "atmel,sama5d4-gem", .data =3D &sama5d4_config },
+ 	{ .compatible =3D "cdns,at91rm9200-emac", .data =3D &emac_config },
+ 	{ .compatible =3D "cdns,emac", .data =3D &emac_config },
+ 	{ /* sentinel */ }
+ };
+ MODULE_DEVICE_TABLE(of, macb_dt_ids);
+ #endif /* CONFIG_OF */
+=20
+ static int macb_probe(struct platform_device *pdev)
+ {
+ 	int (*init)(struct platform_device *) =3D macb_init;
+ 	struct device_node *np =3D pdev->dev.of_node;
+ 	const struct macb_config *macb_config =3D NULL;
+ 	unsigned int queue_mask, num_queues;
+ 	struct macb_platform_data *pdata;
+ 	struct phy_device *phydev;
+ 	struct net_device *dev;
+ 	struct resource *regs;
+ 	void __iomem *mem;
+ 	const char *mac;
+ 	struct macb *bp;
+ 	int err;
+=20
+ 	regs =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
+ 	mem =3D devm_ioremap_resource(&pdev->dev, regs);
+ 	if (IS_ERR(mem))
+ 		return PTR_ERR(mem);
+=20
+ 	macb_probe_queues(mem, &queue_mask, &num_queues);
+ 	dev =3D alloc_etherdev_mq(sizeof(*bp), num_queues);
+ 	if (!dev)
+ 		return -ENOMEM;
+=20
+ 	dev->base_addr =3D regs->start;
+=20
+ 	SET_NETDEV_DEV(dev, &pdev->dev);
+=20
+ 	bp =3D netdev_priv(dev);
+ 	bp->pdev =3D pdev;
+ 	bp->dev =3D dev;
+ 	bp->regs =3D mem;
+ 	bp->num_queues =3D num_queues;
+ 	spin_lock_init(&bp->lock);
+=20
+ 	platform_set_drvdata(pdev, dev);
+=20
+ 	dev->irq =3D platform_get_irq(pdev, 0);
+ 	if (dev->irq < 0)
+ 		return dev->irq;
+=20
+ 	mac =3D of_get_mac_address(np);
  	if (mac)
  		memcpy(bp->dev->dev_addr, mac, ETH_ALEN);
  	else

--Sig_/5JLXp11bE8Xw2fboG=Bh1PO
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU/kQeAAoJEMDTa8Ir7ZwV838P/RywOqMgsFklwUeJxcsp7BeQ
ptf2m0stPmmbWcnfCCfTUsRfeAEhPrgindEmFliIQa5sKWSml6tQEO3Ww+9dVhU2
+2EgsystgiVjyDQIrMDY568Bbt5OjHOzcNgyUbAwlivyOX7O2UJxFioglJGJgX5z
T45GfYKF/uMhPq+WKR9H4s2UK61KuHQtXlvohtIvkux3EqCDdHHSeGp2dLh74pOR
sHD16QjUONEmZ7+7PFvBZHcXJEuMAFRXFWEYXY/w9Zdb4LdIcUxcEBRcMyVYDlh7
5rg6nG+rK0vqkBS4G0HnBi9539zrkshH6ctL90+UHJddtUBav8pObkbLH4naKXXG
fr6PeKDCpxMSxL9J+og6VF5rynoitmZd5POT5yh7/JZtGa6sLg+cMxWRBAlIVVTh
iEthBd7eDaEjluwn0jr5PdCyvsMhBrY2pPxGEx7qa+ott7j1U5CYRH+ukcYbQTF8
YIeCPZSHAintXTFJxa+Etm047wSqlFaGjxbJf1eC5s+6nw4cVC/lCe475mKAZ+2E
bV4z12NXlkbnIvPenpYx4ftEeA639MVdws3lliGorm9PlNMCXK/boxNNuDJtB8dm
y3RPwpjUXx4hu0cT8hm4WeuK5EV1VCLH3sYPCZkT1TwjowH12YZYJ1W9jRcEuPL0
9ls9jdx62acH9Dpj8S5N
=bMVR
-----END PGP SIGNATURE-----

--Sig_/5JLXp11bE8Xw2fboG=Bh1PO--
