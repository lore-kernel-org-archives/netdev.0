From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 11/14] net/fec: reorder functions a bit allows removing forward declarations
Date: Fri, 11 Feb 2011 11:32:19 +0100
Message-ID: <1297420342-17739-11-git-send-email-u.kleine-koenig@pengutronix.de>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45119 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755652Ab1BKKcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 05:32:39 -0500
In-Reply-To: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/fec.c |  353 ++++++++++++++++++++++++++-------------------=
--------
 1 files changed, 174 insertions(+), 179 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 4c888f1..3f5dfe2 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -205,13 +205,6 @@ struct fec_enet_private {
 	struct	completion mdio_done;
 };
=20
-static irqreturn_t fec_enet_interrupt(int irq, void * dev_id);
-static void fec_enet_tx(struct net_device *ndev);
-static void fec_enet_rx(struct net_device *ndev);
-static int fec_enet_close(struct net_device *ndev);
-static void fec_restart(struct net_device *ndev, int duplex);
-static void fec_stop(struct net_device *ndev);
-
 /* FEC MII MMFR bits definition */
 #define FEC_MMFR_ST		(1 << 30)
 #define FEC_MMFR_OP_READ	(2 << 28)
@@ -335,54 +328,160 @@ fec_enet_start_xmit(struct sk_buff *skb, struct =
net_device *ndev)
 	return NETDEV_TX_OK;
 }
=20
+/* This function is called to start or restart the FEC during a link
+ * change.  This only happens when switching between half and full
+ * duplex.
+ */
 static void
-fec_timeout(struct net_device *ndev)
+fec_restart(struct net_device *ndev, int duplex)
 {
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
+	const struct platform_device_id *id_entry =3D
+				platform_get_device_id(fep->pdev);
+	int i;
+	u32 val, temp_mac[2];
=20
-	ndev->stats.tx_errors++;
+	/* Whack a reset.  We should wait for this. */
+	writel(1, fep->hwp + FEC_ECNTRL);
+	udelay(10);
=20
-	fec_restart(ndev, fep->full_duplex);
-	netif_wake_queue(ndev);
-}
+	/*
+	 * enet-mac reset will reset mac address registers too,
+	 * so need to reconfigure it.
+	 */
+	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
+		memcpy(&temp_mac, ndev->dev_addr, ETH_ALEN);
+		writel(cpu_to_be32(temp_mac[0]), fep->hwp + FEC_ADDR_LOW);
+		writel(cpu_to_be32(temp_mac[1]), fep->hwp + FEC_ADDR_HIGH);
+	}
=20
-static irqreturn_t
-fec_enet_interrupt(int irq, void *dev_id)
-{
-	struct net_device *ndev =3D dev_id;
-	struct fec_enet_private *fep =3D netdev_priv(ndev);
-	uint int_events;
-	irqreturn_t ret =3D IRQ_NONE;
+	/* Clear any outstanding interrupt. */
+	writel(0xffc00000, fep->hwp + FEC_IEVENT);
=20
-	do {
-		int_events =3D readl(fep->hwp + FEC_IEVENT);
-		writel(int_events, fep->hwp + FEC_IEVENT);
+	/* Reset all multicast.	*/
+	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
+	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
+#ifndef CONFIG_M5272
+	writel(0, fep->hwp + FEC_HASH_TABLE_HIGH);
+	writel(0, fep->hwp + FEC_HASH_TABLE_LOW);
+#endif
=20
-		if (int_events & FEC_ENET_RXF) {
-			ret =3D IRQ_HANDLED;
-			fec_enet_rx(ndev);
-		}
+	/* Set maximum receive buffer size. */
+	writel(PKT_MAXBLR_SIZE, fep->hwp + FEC_R_BUFF_SIZE);
=20
-		/* Transmit OK, or non-fatal error. Update the buffer
-		 * descriptors. FEC handles all errors, we just discover
-		 * them as part of the transmit process.
-		 */
-		if (int_events & FEC_ENET_TXF) {
-			ret =3D IRQ_HANDLED;
-			fec_enet_tx(ndev);
+	/* Set receive and transmit descriptor base. */
+	writel(fep->bd_dma, fep->hwp + FEC_R_DES_START);
+	writel((unsigned long)fep->bd_dma + sizeof(struct bufdesc) * RX_RING_=
SIZE,
+			fep->hwp + FEC_X_DES_START);
+
+	fep->dirty_tx =3D fep->cur_tx =3D fep->tx_bd_base;
+	fep->cur_rx =3D fep->rx_bd_base;
+
+	/* Reset SKB transmit buffers. */
+	fep->skb_cur =3D fep->skb_dirty =3D 0;
+	for (i =3D 0; i <=3D TX_RING_MOD_MASK; i++) {
+		if (fep->tx_skbuff[i]) {
+			dev_kfree_skb_any(fep->tx_skbuff[i]);
+			fep->tx_skbuff[i] =3D NULL;
 		}
+	}
=20
-		if (int_events & FEC_ENET_MII) {
-			ret =3D IRQ_HANDLED;
-			complete(&fep->mdio_done);
+	/* Enable MII mode */
+	if (duplex) {
+		/* MII enable / FD enable */
+		writel(OPT_FRAME_SIZE | 0x04, fep->hwp + FEC_R_CNTRL);
+		writel(0x04, fep->hwp + FEC_X_CNTRL);
+	} else {
+		/* MII enable / No Rcv on Xmit */
+		writel(OPT_FRAME_SIZE | 0x06, fep->hwp + FEC_R_CNTRL);
+		writel(0x0, fep->hwp + FEC_X_CNTRL);
+	}
+	fep->full_duplex =3D duplex;
+
+	/* Set MII speed */
+	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
+
+	/*
+	 * The phy interface and speed need to get configured
+	 * differently on enet-mac.
+	 */
+	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
+		val =3D readl(fep->hwp + FEC_R_CNTRL);
+
+		/* MII or RMII */
+		if (fep->phy_interface =3D=3D PHY_INTERFACE_MODE_RMII)
+			val |=3D (1 << 8);
+		else
+			val &=3D ~(1 << 8);
+
+		/* 10M or 100M */
+		if (fep->phy_dev && fep->phy_dev->speed =3D=3D SPEED_100)
+			val &=3D ~(1 << 9);
+		else
+			val |=3D (1 << 9);
+
+		writel(val, fep->hwp + FEC_R_CNTRL);
+	} else {
+#ifdef FEC_MIIGSK_ENR
+		if (fep->phy_interface =3D=3D PHY_INTERFACE_MODE_RMII) {
+			/* disable the gasket and wait */
+			writel(0, fep->hwp + FEC_MIIGSK_ENR);
+			while (readl(fep->hwp + FEC_MIIGSK_ENR) & 4)
+				udelay(1);
+
+			/*
+			 * configure the gasket:
+			 *   RMII, 50 MHz, no loopback, no echo
+			 */
+			writel(1, fep->hwp + FEC_MIIGSK_CFGR);
+
+			/* re-enable the gasket */
+			writel(2, fep->hwp + FEC_MIIGSK_ENR);
 		}
-	} while (int_events);
+#endif
+	}
=20
-	return ret;
+	/* And last, enable the transmit and receive processing */
+	writel(2, fep->hwp + FEC_ECNTRL);
+	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
+
+	/* Enable interrupts we wish to service */
+	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+}
+
+static void
+fec_stop(struct net_device *ndev)
+{
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
+
+	/* We cannot expect a graceful transmit stop without link !!! */
+	if (fep->link) {
+		writel(1, fep->hwp + FEC_X_CNTRL); /* Graceful transmit stop */
+		udelay(10);
+		if (!(readl(fep->hwp + FEC_IEVENT) & FEC_ENET_GRA))
+			printk("fec_stop : Graceful transmit stop did not complete !\n");
+	}
+
+	/* Whack a reset.  We should wait for this. */
+	writel(1, fep->hwp + FEC_ECNTRL);
+	udelay(10);
+	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
+	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
 }
=20
=20
 static void
+fec_timeout(struct net_device *ndev)
+{
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
+
+	ndev->stats.tx_errors++;
+
+	fec_restart(ndev, fep->full_duplex);
+	netif_wake_queue(ndev);
+}
+
+static void
 fec_enet_tx(struct net_device *ndev)
 {
 	struct	fec_enet_private *fep;
@@ -576,6 +675,43 @@ rx_processing_done:
 	spin_unlock(&fep->hw_lock);
 }
=20
+static irqreturn_t
+fec_enet_interrupt(int irq, void *dev_id)
+{
+	struct net_device *ndev =3D dev_id;
+	struct fec_enet_private *fep =3D netdev_priv(ndev);
+	uint int_events;
+	irqreturn_t ret =3D IRQ_NONE;
+
+	do {
+		int_events =3D readl(fep->hwp + FEC_IEVENT);
+		writel(int_events, fep->hwp + FEC_IEVENT);
+
+		if (int_events & FEC_ENET_RXF) {
+			ret =3D IRQ_HANDLED;
+			fec_enet_rx(ndev);
+		}
+
+		/* Transmit OK, or non-fatal error. Update the buffer
+		 * descriptors. FEC handles all errors, we just discover
+		 * them as part of the transmit process.
+		 */
+		if (int_events & FEC_ENET_TXF) {
+			ret =3D IRQ_HANDLED;
+			fec_enet_tx(ndev);
+		}
+
+		if (int_events & FEC_ENET_MII) {
+			ret =3D IRQ_HANDLED;
+			complete(&fep->mdio_done);
+		}
+	} while (int_events);
+
+	return ret;
+}
+
+
+
 /* -------------------------------------------------------------------=
------ */
 static void __inline__ fec_get_mac(struct net_device *ndev)
 {
@@ -1217,147 +1353,6 @@ static int fec_enet_init(struct net_device *nde=
v)
 	return 0;
 }
=20
-/* This function is called to start or restart the FEC during a link
- * change.  This only happens when switching between half and full
- * duplex.
- */
-static void
-fec_restart(struct net_device *ndev, int duplex)
-{
-	struct fec_enet_private *fep =3D netdev_priv(ndev);
-	const struct platform_device_id *id_entry =3D
-				platform_get_device_id(fep->pdev);
-	int i;
-	u32 val, temp_mac[2];
-
-	/* Whack a reset.  We should wait for this. */
-	writel(1, fep->hwp + FEC_ECNTRL);
-	udelay(10);
-
-	/*
-	 * enet-mac reset will reset mac address registers too,
-	 * so need to reconfigure it.
-	 */
-	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
-		memcpy(&temp_mac, ndev->dev_addr, ETH_ALEN);
-		writel(cpu_to_be32(temp_mac[0]), fep->hwp + FEC_ADDR_LOW);
-		writel(cpu_to_be32(temp_mac[1]), fep->hwp + FEC_ADDR_HIGH);
-	}
-
-	/* Clear any outstanding interrupt. */
-	writel(0xffc00000, fep->hwp + FEC_IEVENT);
-
-	/* Reset all multicast.	*/
-	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
-	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
-#ifndef CONFIG_M5272
-	writel(0, fep->hwp + FEC_HASH_TABLE_HIGH);
-	writel(0, fep->hwp + FEC_HASH_TABLE_LOW);
-#endif
-
-	/* Set maximum receive buffer size. */
-	writel(PKT_MAXBLR_SIZE, fep->hwp + FEC_R_BUFF_SIZE);
-
-	/* Set receive and transmit descriptor base. */
-	writel(fep->bd_dma, fep->hwp + FEC_R_DES_START);
-	writel((unsigned long)fep->bd_dma + sizeof(struct bufdesc) * RX_RING_=
SIZE,
-			fep->hwp + FEC_X_DES_START);
-
-	fep->dirty_tx =3D fep->cur_tx =3D fep->tx_bd_base;
-	fep->cur_rx =3D fep->rx_bd_base;
-
-	/* Reset SKB transmit buffers. */
-	fep->skb_cur =3D fep->skb_dirty =3D 0;
-	for (i =3D 0; i <=3D TX_RING_MOD_MASK; i++) {
-		if (fep->tx_skbuff[i]) {
-			dev_kfree_skb_any(fep->tx_skbuff[i]);
-			fep->tx_skbuff[i] =3D NULL;
-		}
-	}
-
-	/* Enable MII mode */
-	if (duplex) {
-		/* MII enable / FD enable */
-		writel(OPT_FRAME_SIZE | 0x04, fep->hwp + FEC_R_CNTRL);
-		writel(0x04, fep->hwp + FEC_X_CNTRL);
-	} else {
-		/* MII enable / No Rcv on Xmit */
-		writel(OPT_FRAME_SIZE | 0x06, fep->hwp + FEC_R_CNTRL);
-		writel(0x0, fep->hwp + FEC_X_CNTRL);
-	}
-	fep->full_duplex =3D duplex;
-
-	/* Set MII speed */
-	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
-
-	/*
-	 * The phy interface and speed need to get configured
-	 * differently on enet-mac.
-	 */
-	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
-		val =3D readl(fep->hwp + FEC_R_CNTRL);
-
-		/* MII or RMII */
-		if (fep->phy_interface =3D=3D PHY_INTERFACE_MODE_RMII)
-			val |=3D (1 << 8);
-		else
-			val &=3D ~(1 << 8);
-
-		/* 10M or 100M */
-		if (fep->phy_dev && fep->phy_dev->speed =3D=3D SPEED_100)
-			val &=3D ~(1 << 9);
-		else
-			val |=3D (1 << 9);
-
-		writel(val, fep->hwp + FEC_R_CNTRL);
-	} else {
-#ifdef FEC_MIIGSK_ENR
-		if (fep->phy_interface =3D=3D PHY_INTERFACE_MODE_RMII) {
-			/* disable the gasket and wait */
-			writel(0, fep->hwp + FEC_MIIGSK_ENR);
-			while (readl(fep->hwp + FEC_MIIGSK_ENR) & 4)
-				udelay(1);
-
-			/*
-			 * configure the gasket:
-			 *   RMII, 50 MHz, no loopback, no echo
-			 */
-			writel(1, fep->hwp + FEC_MIIGSK_CFGR);
-
-			/* re-enable the gasket */
-			writel(2, fep->hwp + FEC_MIIGSK_ENR);
-		}
-#endif
-	}
-
-	/* And last, enable the transmit and receive processing */
-	writel(2, fep->hwp + FEC_ECNTRL);
-	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
-
-	/* Enable interrupts we wish to service */
-	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
-}
-
-static void
-fec_stop(struct net_device *ndev)
-{
-	struct fec_enet_private *fep =3D netdev_priv(ndev);
-
-	/* We cannot expect a graceful transmit stop without link !!! */
-	if (fep->link) {
-		writel(1, fep->hwp + FEC_X_CNTRL); /* Graceful transmit stop */
-		udelay(10);
-		if (!(readl(fep->hwp + FEC_IEVENT) & FEC_ENET_GRA))
-			printk("fec_stop : Graceful transmit stop did not complete !\n");
-	}
-
-	/* Whack a reset.  We should wait for this. */
-	writel(1, fep->hwp + FEC_ECNTRL);
-	udelay(10);
-	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
-	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
-}
-
 static int __devinit
 fec_probe(struct platform_device *pdev)
 {
--=20
1.7.2.3

