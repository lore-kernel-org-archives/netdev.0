From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [PATCH 1/4] spidernet: add auto negotiation on Celleb
Date: Wed, 17 Jan 2007 19:06:05 +0900 (JST)
Message-ID: <200701171006.l0HA665q014636@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-tsb5.toshiba.co.jp ([202.33.96.24]:36381 "EHLO
	inet-tsb5.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932214AbXAQKGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 05:06:12 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch enables spider_net driver to use auto negotiation on
Celleb. This driver also tries traditional link methods(setup_force()
and enable_fibre()). This driver is designed so as to work a PHY that
is not able to negotiate automatically, but we didn't test on it.


Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
---

--- org-linux-powerpc-git/drivers/net/spider_net.h	2007-01-15 10:37:48.000000000 +0900
+++ linux-powerpc-git/drivers/net/spider_net.h	2007-01-15 10:41:25.000000000 +0900
@@ -50,6 +50,7 @@
 #define SPIDER_NET_TX_DESCRIPTORS_MAX		512
 
 #define SPIDER_NET_TX_TIMER			(HZ/5)
+#define SPIDER_NET_ANEG_TIMER			(HZ)
 
 #define SPIDER_NET_RX_CSUM_DEFAULT		1
 
@@ -104,6 +105,7 @@
 
 #define SPIDER_NET_GMACOPEMD		0x00000100
 #define SPIDER_NET_GMACLENLMT		0x00000108
+#define SPIDER_NET_GMACST		0x00000110
 #define SPIDER_NET_GMACINTEN		0x00000118
 #define SPIDER_NET_GMACPHYCTRL		0x00000120
 
@@ -333,9 +335,12 @@
 /* We rely on flagged descriptor interrupts */
 #define SPIDER_NET_RXINT	( (1 << SPIDER_NET_GDAFDCINT) )
 
+#define SPIDER_NET_LINKINT	( 1 << SPIDER_NET_GMAC2INT )
+
 #define SPIDER_NET_ERRINT	( 0xffffffff & \
 				  (~SPIDER_NET_TXINT) & \
-				  (~SPIDER_NET_RXINT) )
+				  (~SPIDER_NET_RXINT) & \
+				  (~SPIDER_NET_LINKINT) )
 
 #define SPIDER_NET_GPREXEC			0x80000000
 #define SPIDER_NET_GPRDAT_MASK			0x0000ffff
@@ -442,6 +447,10 @@
 	struct spider_net_descr_chain rx_chain;
 	struct spider_net_descr *low_watermark;
 
+	int aneg_count;
+	int forced;
+	int is1000;
+	struct timer_list aneg_timer;
 	struct timer_list tx_timer;
 	struct work_struct tx_timeout_task;
 	atomic_t tx_timeout_task_counter;
--- org-linux-powerpc-git/drivers/net/spider_net.c	2007-01-15 10:37:48.000000000 +0900
+++ linux-powerpc-git/drivers/net/spider_net.c	2007-01-15 10:48:17.000000000 +0900
@@ -165,6 +165,74 @@
 	return readvalue;
 }
 
+/** spider_net_setup_forced - initial force setup
+ * @card: device structure 
+ * @speed: speed
+ * @fd: duplex mode
+ **/
+static void
+spider_net_setup_forced(struct spider_net_card *card, int speed, int fd)
+{
+	struct mii_phy *phy = &card->phy;
+
+	card->forced = 1;
+	if (phy->def->ops->setup_forced)
+		phy->def->ops->setup_forced(phy, speed, fd);
+
+	phy->def->ops->enable_fiber(phy);
+}
+
+/** spider_net_setup_aneg - initial auto-negotiation setup
+ * @card: device structure 
+ **/
+static void
+spider_net_setup_aneg(struct spider_net_card *card)
+{
+	struct mii_phy *phy = &card->phy;
+	u32 advertise = 0;
+	u16 bmcr, bmsr, ctrl1000, stat1000, estat;
+
+	card->forced = 0;
+	bmcr     = spider_net_read_phy(card->netdev, phy->mii_id, MII_BMCR);
+	bmsr     = spider_net_read_phy(card->netdev, phy->mii_id, MII_BMSR);
+	ctrl1000 = spider_net_read_phy(card->netdev, phy->mii_id, MII_CTRL1000);
+	stat1000 = spider_net_read_phy(card->netdev, phy->mii_id, MII_STAT1000);
+	estat    = spider_net_read_phy(card->netdev, phy->mii_id, MII_ESTATUS);
+
+	if (bmsr & BMSR_10HALF)
+		advertise |= ADVERTISE_10HALF;
+	if (bmsr & BMSR_10FULL)
+		advertise |= ADVERTISE_10FULL;
+	if (bmsr & BMSR_100HALF)
+		advertise |= ADVERTISE_100HALF;
+	if (bmsr & BMSR_100FULL)
+		advertise |= ADVERTISE_100FULL;
+	if (bmsr & BMSR_100BASE4)
+		advertise |= ADVERTISE_100BASE4;
+
+	if (card->is1000) {
+		if ((bmsr & BMSR_ESTATEN) && (estat & ESTATUS_1000_TFULL)) {
+			advertise |= ADVERTISE_1000XFULL;
+			ctrl1000 |= ADVERTISE_1000FULL;
+		}
+		if ((bmsr & BMSR_ESTATEN) && (estat & ESTATUS_1000_THALF)) {
+			advertise |= ADVERTISE_1000XHALF;
+			ctrl1000 |= ADVERTISE_1000HALF;
+		}
+
+		spider_net_write_phy(card->netdev, phy->mii_id,
+				     MII_CTRL1000, ctrl1000);
+		spider_net_write_reg(card, SPIDER_NET_GMACMODE, 0x00000001);
+
+		phy->def->ops->setup_aneg(phy, advertise);
+	} else {
+		spider_net_write_reg(card, SPIDER_NET_GMACMODE, 0);
+		bmcr |= (BMCR_ANRESTART | BMCR_ANENABLE);
+		spider_net_write_phy(card->netdev, phy->mii_id,
+				     MII_BMCR, bmcr);
+	}
+}
+
 /**
  * spider_net_rx_irq_off - switch off rx irq on this spider card
  * @card: device structure
@@ -1244,6 +1312,29 @@
 }
 
 /**
+ * spider_net_link_reset
+ * @netdev: net device structure
+ *
+ */
+static void
+spider_net_link_reset(struct net_device *netdev)
+{
+
+	struct spider_net_card *card = netdev_priv(netdev);
+
+	del_timer_sync(&card->aneg_timer);
+
+	spider_net_write_reg(card, SPIDER_NET_GMACST,
+			     spider_net_read_reg(card, SPIDER_NET_GMACST));
+	spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0);
+
+	mii_phy_probe(&card->phy, card->phy.mii_id);
+	spider_net_setup_forced(card, SPEED_1000, DUPLEX_FULL);
+	mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
+
+}
+
+/**
  * spider_net_handle_error_irq - handles errors raised by an interrupt
  * @card: card structure
  * @status_reg: interrupt status register 0 (GHIINT0STS)
@@ -1496,6 +1587,9 @@
 	if (status_reg & SPIDER_NET_TXINT)
 		netif_rx_schedule(netdev);
 
+	if (status_reg & SPIDER_NET_LINKINT)
+		spider_net_link_reset(netdev);
+
 	if (status_reg & SPIDER_NET_ERRINT )
 		spider_net_handle_error_irq(card, status_reg);
 
@@ -1620,8 +1714,6 @@
 
 	spider_net_write_reg(card, SPIDER_NET_GMACLENLMT,
 			     SPIDER_NET_LENLMT_VALUE);
-	spider_net_write_reg(card, SPIDER_NET_GMACMODE,
-			     SPIDER_NET_MACMODE_VALUE);
 	spider_net_write_reg(card, SPIDER_NET_GMACOPEMD,
 			     SPIDER_NET_OPMODE_VALUE);
 
@@ -1653,6 +1745,9 @@
 	struct spider_net_descr *descr;
 	int result;
 
+	spider_net_setup_forced(card, SPEED_1000, DUPLEX_FULL);
+	mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
+
 	result = spider_net_init_chain(card, &card->tx_chain);
 	if (result)
 		goto alloc_tx_failed;
@@ -1697,17 +1792,79 @@
 alloc_rx_failed:
 	spider_net_free_chain(card, &card->tx_chain);
 alloc_tx_failed:
+	del_timer_sync(&card->aneg_timer);
 	return result;
 }
 
 /**
+ * spider_net_link_phy
+ * @data: used for pointer to card structure
+ *
+ */
+static void spider_net_link_phy(unsigned long data)
+{
+	struct spider_net_card *card = (struct spider_net_card *)data;
+	struct mii_phy *phy = &card->phy;
+
+	if (card->aneg_count > 5) {
+		/* timeout */
+		card->aneg_count = 0;
+		if (card->forced)
+			card->is1000 = 1;
+		else if (card->is1000)
+			card->is1000 = 0;
+		else {
+			spider_net_setup_forced(card, SPEED_1000, DUPLEX_FULL);
+			mod_timer(&card->aneg_timer,
+				jiffies + SPIDER_NET_ANEG_TIMER);
+			return;
+		}
+		goto re_setup;
+	}
+
+	if (!(phy->def->ops->poll_link(phy))) {
+		card->aneg_count++;
+		mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
+		return;
+	}
+
+	phy->def->ops->read_link(phy);
+
+	if (!card->forced) {
+		if (phy->speed == 1000 && !(card->is1000)) {
+			card->is1000 = 1;
+			goto re_setup;
+		} else if (phy->speed != 1000 && card->is1000) {
+			card->is1000 = 0;
+			goto re_setup;
+		}
+	}
+
+	spider_net_write_reg(card, SPIDER_NET_GMACST,
+			     spider_net_read_reg(card, SPIDER_NET_GMACST));
+	spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0x4);
+
+	card->aneg_count = 0;
+
+	pr_info("Found %s with %i Mbps, %s-duplex.\n",
+		phy->def->name, phy->speed, phy->duplex==1 ? "Full" : "Half");
+
+	return;
+
+re_setup:
+	mii_phy_probe(phy, phy->mii_id);
+	spider_net_setup_aneg(card);
+	card->aneg_count = 0;
+	mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
+}
+
+/**
  * spider_net_setup_phy - setup PHY
  * @card: card structure
  *
  * returns 0 on success, <0 on failure
  *
- * spider_net_setup_phy is used as part of spider_net_probe. Sets
- * the PHY to 1000 Mbps
+ * spider_net_setup_phy is used as part of spider_net_probe.
  **/
 static int
 spider_net_setup_phy(struct spider_net_card *card)
@@ -1718,21 +1875,19 @@
 			     SPIDER_NET_DMASEL_VALUE);
 	spider_net_write_reg(card, SPIDER_NET_GPCCTRL,
 			     SPIDER_NET_PHY_CTRL_VALUE);
-	phy->mii_id = 1;
+
 	phy->dev = card->netdev;
 	phy->mdio_read = spider_net_read_phy;
 	phy->mdio_write = spider_net_write_phy;
 
-	mii_phy_probe(phy, phy->mii_id);
-
-	if (phy->def->ops->setup_forced)
-		phy->def->ops->setup_forced(phy, SPEED_1000, DUPLEX_FULL);
-
-	phy->def->ops->enable_fiber(phy);
-
-	phy->def->ops->read_link(phy);
-	pr_info("Found %s with %i Mbps, %s-duplex.\n", phy->def->name,
-		phy->speed, phy->duplex==1 ? "Full" : "Half");
+	for (phy->mii_id = 1; phy->mii_id <= 31; phy->mii_id++) {
+		unsigned short id;
+		id = spider_net_read_phy(card->netdev, phy->mii_id, MII_BMSR);
+		if (id != 0x0000 && id != 0xffff) {
+			mii_phy_probe(phy, phy->mii_id);
+			break;
+		}
+	}
 
 	return 0;
 }
@@ -1904,11 +2059,13 @@
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 	del_timer_sync(&card->tx_timer);
+	del_timer_sync(&card->aneg_timer);
 
 	/* disable/mask all interrupts */
 	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, 0);
 	spider_net_write_reg(card, SPIDER_NET_GHIINT1MSK, 0);
 	spider_net_write_reg(card, SPIDER_NET_GHIINT2MSK, 0);
+	spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0);
 
 	/* free_irq(netdev->irq, netdev);*/
 	free_irq(to_pci_dev(netdev->class_dev.dev)->irq, netdev);
@@ -2048,6 +2205,12 @@
 	card->tx_timer.data = (unsigned long) card;
 	netdev->irq = card->pdev->irq;
 
+	card->is1000 = 1;
+	card->aneg_count = 0;
+	init_timer(&card->aneg_timer);
+	card->aneg_timer.function = spider_net_link_phy;
+	card->aneg_timer.data = (unsigned long) card;
+
 	card->options.rx_csum = SPIDER_NET_RX_CSUM_DEFAULT;
 
 	card->tx_chain.num_desc = tx_descriptors;

