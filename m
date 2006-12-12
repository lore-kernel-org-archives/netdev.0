From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [PATCH] drivers/net: spidernet driver on Celleb
Date: Tue, 12 Dec 2006 14:25:50 +0900 (JST)
Message-ID: <200612120525.kBC5PpWC009418@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx12.toshiba.co.jp ([61.202.160.132]:43661 "EHLO
	imx12.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175AbWLLFgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 00:36:33 -0500
To: jim@jklewis.com, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Following are the changes.
-This patch enables auto-negotiation.
-Loading firmware is done when spidernet_open() is called.
-And this patch adds other several small changes for Celleb. 
-This patch is not tested on CellBlade.

Signed-off-by: Kou Ishizaki <kou.ishizaki at toshiba.co.jp>
---

Dear everyone,

This is the patch (besed on powerpc-git (2006-12-05)) for spidernet driver to
work on Toshiba Cell reference set(Celleb). 
The reference set consists of Cell, 512MB memory, Super Companion Chip(SCC) 
and some peripherals such as HDD, GbE, etc. You can see brief explanation
and picture of Cell reference set at following URLs.

    http://www.toshiba.co.jp/about/press/2005_09/pr2001.htm
    http://cell-industries.com/toshiba_announces.php

This patch set is intended to be merged to 2.6.20.
If you have any comment, please write to me.

---
Index: linux-2.6.19/drivers/net/Kconfig
diff -u linux-2.6.19/drivers/net/Kconfig:1.1.1.4 linux-2.6.19/drivers/net/Kconfig:1.6
--- linux-2.6.19/drivers/net/Kconfig:1.1.1.4	Tue Nov 14 11:15:25 2006
+++ linux-2.6.19/drivers/net/Kconfig	Fri Dec  1 15:16:10 2006
@@ -2245,7 +2245,7 @@
 
 config SPIDER_NET
 	tristate "Spider Gigabit Ethernet driver"
-	depends on PCI && PPC_IBM_CELL_BLADE
+	depends on PCI && (PPC_IBM_CELL_BLADE || PPC_CELLEB)
 	select FW_LOADER
 	help
 	  This driver supports the Gigabit Ethernet chips present on the
Index: linux-2.6.19/drivers/net/spider_net.h
diff -u linux-2.6.19/drivers/net/spider_net.h:1.1.1.2 linux-2.6.19/drivers/net/spider_net.h:1.5
--- linux-2.6.19/drivers/net/spider_net.h:1.1.1.2	Tue Oct 17 08:42:39 2006
+++ linux-2.6.19/drivers/net/spider_net.h	Tue Nov  7 12:36:35 2006
@@ -1,7 +1,8 @@
 /*
- * Network device driver for Cell Processor-Based Blade
+ * Network device driver for Cell Processor-Based Blade and Celleb platform
  *
  * (C) Copyright IBM Corp. 2005
+ * (C) Copyright 2006 TOSHIBA CORPORATION
  *
  * Authors : Utz Bacher <utz.bacher@de.ibm.com>
  *           Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
@@ -50,6 +51,7 @@
 #define SPIDER_NET_TX_DESCRIPTORS_MAX		512
 
 #define SPIDER_NET_TX_TIMER			(HZ/5)
+#define SPIDER_NET_ANEG_TIMER			(HZ*2)
 
 #define SPIDER_NET_RX_CSUM_DEFAULT		1
 
@@ -104,6 +106,7 @@
 
 #define SPIDER_NET_GMACOPEMD		0x00000100
 #define SPIDER_NET_GMACLENLMT		0x00000108
+#define SPIDER_NET_GMACST		0x00000110
 #define SPIDER_NET_GMACINTEN		0x00000118
 #define SPIDER_NET_GMACPHYCTRL		0x00000120
 
@@ -180,8 +183,8 @@
 #define SPIDER_NET_IPSECINIT_VALUE	0x6f716f71
 
 /* pause frames: automatic, no upper retransmission count */
-/* outside loopback mode: ETOMOD signal dont matter, not connected */
-#define SPIDER_NET_OPMODE_VALUE		0x00000063
+/* ETOMOD signal is brought to PHY reset. bit2 must be 1 in Celleb */
+#define SPIDER_NET_OPMODE_VALUE		0x00000067
 /*#define SPIDER_NET_OPMODE_VALUE		0x001b0062*/
 #define SPIDER_NET_LENLMT_VALUE		0x00000908
 
@@ -333,9 +336,12 @@
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
@@ -447,6 +453,8 @@
 
 	spinlock_t intmask_lock;
 	struct tasklet_struct rxram_full_tl;
+	int aneg_count;
+	struct timer_list aneg_timer;
 	struct timer_list tx_timer;
 
 	struct work_struct tx_timeout_task;
Index: linux-2.6.19/drivers/net/spider_net.c
diff -u linux-2.6.19/drivers/net/spider_net.c:1.1.1.2 linux-2.6.19/drivers/net/spider_net.c:1.10
--- linux-2.6.19/drivers/net/spider_net.c:1.1.1.2	Tue Oct 17 08:42:39 2006
+++ linux-2.6.19/drivers/net/spider_net.c	Tue Dec  5 20:30:42 2006
@@ -1,7 +1,8 @@
 /*
- * Network device driver for Cell Processor-Based Blade
+ * Network device driver for Cell Processor-Based Blade and Celleb platform
  *
  * (C) Copyright IBM Corp. 2005
+ * (C) Copyright 2006 TOSHIBA CORPORATION
  *
  * Authors : Utz Bacher <utz.bacher@de.ibm.com>
  *           Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
@@ -78,6 +79,8 @@
 
 MODULE_DEVICE_TABLE(pci, spider_net_pci_tbl);
 
+static int is1000 = 1;
+
 /**
  * spider_net_read_reg - reads an SMMIO register of a card
  * @card: device structure
@@ -163,6 +166,53 @@
 	return readvalue;
 }
 
+static void
+spider_net_setup_aneg(struct spider_net_card *card, int is1000)
+{
+	struct mii_phy *phy = &card->phy;
+	u32 advertise = 0;
+	u16 bmcr, bmsr, ctrl1000, stat1000, estat;
+
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
+	if (is1000) {
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
@@ -1233,6 +1283,31 @@
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
+	struct spider_net_card *card=netdev_priv(netdev);
+
+	del_timer_sync(&card->aneg_timer);
+
+	spider_net_write_reg(card, SPIDER_NET_GMACST,
+			     spider_net_read_reg(card, SPIDER_NET_GMACST));
+	spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0);
+
+	mii_phy_probe(&card->phy, card->phy.mii_id);
+	spider_net_setup_aneg(card, is1000);
+	if (card->phy.def->phy_id)
+		mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
+	else
+		pr_err("No phy is available\n");
+}
+
+/**
  * spider_net_handle_rxram_full - cleans up RX ring upon RX RAM full interrupt
  * @card: card structure
  *
@@ -1362,8 +1437,8 @@
 				switch (i)
 	{
 	case SPIDER_NET_GTMFLLINT:
-		if (netif_msg_intr(card) && net_ratelimit())
-			pr_err("Spider TX RAM full\n");
+		/* if (netif_msg_intr(card) && net_ratelimit())
+			pr_err("Spider TX RAM full\n"); */
 		show_error = 0;
 		break;
 	case SPIDER_NET_GRFDFLLINT: /* fallthrough */
@@ -1503,6 +1578,9 @@
 	if (status_reg & SPIDER_NET_TXINT)
 		netif_rx_schedule(netdev);
 
+	if (status_reg & SPIDER_NET_LINKINT)
+		spider_net_link_reset(netdev);
+
 	if (status_reg & SPIDER_NET_ERRINT )
 		spider_net_handle_error_irq(card, status_reg);
 
@@ -1543,6 +1621,10 @@
 
 	spider_net_write_reg(card, SPIDER_NET_CKRCTRL,
 			     SPIDER_NET_CKRCTRL_RUN_VALUE);
+
+	spider_net_write_reg(card, SPIDER_NET_GMACOPEMD,
+	                     spider_net_read_reg(card, SPIDER_NET_GMACOPEMD) | 0x4);
+
 }
 
 /**
@@ -1627,8 +1709,6 @@
 
 	spider_net_write_reg(card, SPIDER_NET_GMACLENLMT,
 			     SPIDER_NET_LENLMT_VALUE);
-	spider_net_write_reg(card, SPIDER_NET_GMACMODE,
-			     SPIDER_NET_MACMODE_VALUE);
 	spider_net_write_reg(card, SPIDER_NET_GMACOPEMD,
 			     SPIDER_NET_OPMODE_VALUE);
 
@@ -1644,6 +1724,7 @@
 			     SPIDER_NET_GDTBSTA | SPIDER_NET_GDTDCEIDIS);
 }
 
+static int spider_net_init_firmware(struct spider_net_card *);
 /**
  * spider_net_open - called upon ifonfig up
  * @netdev: interface device structure
@@ -1661,6 +1742,16 @@
 	int i, result;
 
 	result = -ENOMEM;
+	if (spider_net_init_firmware(card))
+		goto init_firmware_failed;
+
+	spider_net_setup_aneg(card, is1000);
+	if (card->phy.def->phy_id)
+		mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
+	else
+		pr_err("No phy is available\n");
+
+
 	if (spider_net_init_chain(card, &card->tx_chain, card->descr,
 	                          card->num_tx_desc))
 		goto alloc_tx_failed;
@@ -1705,9 +1796,60 @@
 alloc_rx_failed:
 	spider_net_free_chain(card, &card->tx_chain);
 alloc_tx_failed:
+init_firmware_failed:
 	return result;
 }
 
+static void spider_net_init_card(struct spider_net_card *);
+/**
+ * spider_net_link_phy
+ * @data: used for pointer to card structure
+ *
+ */
+static void spider_net_link_phy(unsigned long data)
+{
+	struct spider_net_card *card = (struct spider_net_card *)data;
+	struct mii_phy *phy = &card->phy;
+
+	if (card->aneg_count > 10) {
+		/* timeout */
+		card->aneg_count = 0;
+		is1000 = !is1000;
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
+	if (phy->speed == 1000 && !is1000) {
+		is1000 = 1;
+		goto re_setup;
+	} else if(phy->speed != 1000 && is1000) {
+		is1000 = 0;
+		goto re_setup;
+	} 
+
+	spider_net_write_reg(card, SPIDER_NET_GMACST,
+			     spider_net_read_reg(card, SPIDER_NET_GMACST));
+	spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0x4);
+
+	pr_info("Found %s with %i Mbps, %s-duplex.\n",
+		phy->def->name, phy->speed, phy->duplex==1 ? "Full" : "Half");
+
+	return;
+
+re_setup:
+	mii_phy_probe(phy, phy->mii_id);
+	spider_net_setup_aneg(card, is1000);
+	card->aneg_count = 0;
+	mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
+}
+
 /**
  * spider_net_setup_phy - setup PHY
  * @card: card structure
@@ -1726,21 +1868,19 @@
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
@@ -1913,11 +2053,13 @@
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
@@ -1961,8 +2103,6 @@
 
 	if (spider_net_setup_phy(card))
 		goto out;
-	if (spider_net_init_firmware(card))
-		goto out;
 
 	spider_net_open(netdev);
 	spider_net_kick_tx_dma(card);
@@ -2058,6 +2198,11 @@
 	card->tx_timer.data = (unsigned long) card;
 	netdev->irq = card->pdev->irq;
 
+	card->aneg_count = 0;
+	init_timer(&card->aneg_timer);
+	card->aneg_timer.function = spider_net_link_phy;
+	card->aneg_timer.data = (unsigned long) card;
+
 	card->options.rx_csum = SPIDER_NET_RX_CSUM_DEFAULT;
 
 	card->num_tx_desc = tx_descriptors;
@@ -2236,10 +2381,6 @@
 	if (err)
 		goto out_undo_pci;
 
-	err = spider_net_init_firmware(card);
-	if (err)
-		goto out_undo_pci;
-
 	err = spider_net_setup_netdev(card);
 	if (err)
 		goto out_undo_pci;
