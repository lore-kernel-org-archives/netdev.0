From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 3/12] spidernet: autoneg support for Celleb
Date: Tue, 20 Feb 2007 16:33:41 -0600
Message-ID: <20070220223341.GC28895@austin.ibm.com>
References: <20070220221314.GU923@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	kou.ishizaki@toshiba.co.jp, arnd@arndb.de,
	Jens Osterkamp <jens@de.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:36209 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030514AbXBTWdn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 17:33:43 -0500
Content-Disposition: inline
In-Reply-To: <20070220221314.GU923@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>

Add auto negotiation support for Celleb. 

Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |  176 ++++++++++++++++++++++++++++++++++++++++++-----
 drivers/net/spider_net.h |   10 ++
 2 files changed, 170 insertions(+), 16 deletions(-)

Index: linux-2.6.20-git16/drivers/net/spider_net.h
===================================================================
--- linux-2.6.20-git16.orig/drivers/net/spider_net.h	2007-02-20 14:24:00.000000000 -0600
+++ linux-2.6.20-git16/drivers/net/spider_net.h	2007-02-20 15:02:32.000000000 -0600
@@ -50,6 +50,8 @@ extern char spider_net_driver_name[];
 #define SPIDER_NET_TX_DESCRIPTORS_MAX		512
 
 #define SPIDER_NET_TX_TIMER			(HZ/5)
+#define SPIDER_NET_ANEG_TIMER			(HZ)
+#define SPIDER_NET_ANEG_TIMEOUT			2
 
 #define SPIDER_NET_RX_CSUM_DEFAULT		1
 
@@ -104,6 +106,7 @@ extern char spider_net_driver_name[];
 
 #define SPIDER_NET_GMACOPEMD		0x00000100
 #define SPIDER_NET_GMACLENLMT		0x00000108
+#define SPIDER_NET_GMACST		0x00000110
 #define SPIDER_NET_GMACINTEN		0x00000118
 #define SPIDER_NET_GMACPHYCTRL		0x00000120
 
@@ -333,9 +336,12 @@ enum spider_net_int2_status {
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
@@ -442,6 +448,8 @@ struct spider_net_card {
 	struct spider_net_descr_chain rx_chain;
 	struct spider_net_descr *low_watermark;
 
+	int aneg_count;
+	struct timer_list aneg_timer;
 	struct timer_list tx_timer;
 	struct work_struct tx_timeout_task;
 	atomic_t tx_timeout_task_counter;
Index: linux-2.6.20-git16/drivers/net/spider_net.c
===================================================================
--- linux-2.6.20-git16.orig/drivers/net/spider_net.c	2007-02-20 14:36:13.000000000 -0600
+++ linux-2.6.20-git16/drivers/net/spider_net.c	2007-02-20 15:02:32.000000000 -0600
@@ -166,6 +166,41 @@ spider_net_read_phy(struct net_device *n
 }
 
 /**
+ * spider_net_setup_aneg - initial auto-negotiation setup
+ * @card: device structure
+ **/
+static void
+spider_net_setup_aneg(struct spider_net_card *card)
+{
+	struct mii_phy *phy = &card->phy;
+	u32 advertise = 0;
+	u16 bmcr, bmsr, stat1000, estat;
+
+	bmcr     = spider_net_read_phy(card->netdev, phy->mii_id, MII_BMCR);
+	bmsr     = spider_net_read_phy(card->netdev, phy->mii_id, MII_BMSR);
+	stat1000 = spider_net_read_phy(card->netdev, phy->mii_id, MII_STAT1000);
+	estat    = spider_net_read_phy(card->netdev, phy->mii_id, MII_ESTATUS);
+
+	if (bmsr & BMSR_10HALF)
+		advertise |= ADVERTISED_10baseT_Half;
+	if (bmsr & BMSR_10FULL)
+		advertise |= ADVERTISED_10baseT_Full;
+	if (bmsr & BMSR_100HALF)
+		advertise |= ADVERTISED_100baseT_Half;
+	if (bmsr & BMSR_100FULL)
+		advertise |= ADVERTISED_100baseT_Full;
+
+	if ((bmsr & BMSR_ESTATEN) && (estat & ESTATUS_1000_TFULL))
+		advertise |= SUPPORTED_1000baseT_Full;
+	if ((bmsr & BMSR_ESTATEN) && (estat & ESTATUS_1000_THALF))
+		advertise |= SUPPORTED_1000baseT_Half;
+
+	mii_phy_probe(phy, phy->mii_id);
+	phy->def->ops->setup_aneg(phy, advertise);
+
+}
+
+/**
  * spider_net_rx_irq_off - switch off rx irq on this spider card
  * @card: device structure
  *
@@ -1248,6 +1283,33 @@ spider_net_set_mac(struct net_device *ne
 }
 
 /**
+ * spider_net_link_reset
+ * @netdev: net device structure
+ *
+ * This is called when the PHY_LINK signal is asserted. For the blade this is
+ * not connected so we should never get here.
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
+	/* clear interrupt, block further interrupts */
+	spider_net_write_reg(card, SPIDER_NET_GMACST,
+			     spider_net_read_reg(card, SPIDER_NET_GMACST));
+	spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0);
+
+	/* reset phy and setup aneg */
+	spider_net_setup_aneg(card);
+	mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
+
+}
+
+/**
  * spider_net_handle_error_irq - handles errors raised by an interrupt
  * @card: card structure
  * @status_reg: interrupt status register 0 (GHIINT0STS)
@@ -1500,6 +1562,9 @@ spider_net_interrupt(int irq, void *ptr)
 	if (status_reg & SPIDER_NET_TXINT)
 		netif_rx_schedule(netdev);
 
+	if (status_reg & SPIDER_NET_LINKINT)
+		spider_net_link_reset(netdev);
+
 	if (status_reg & SPIDER_NET_ERRINT )
 		spider_net_handle_error_irq(card, status_reg);
 
@@ -1624,8 +1689,6 @@ spider_net_enable_card(struct spider_net
 
 	spider_net_write_reg(card, SPIDER_NET_GMACLENLMT,
 			     SPIDER_NET_LENLMT_VALUE);
-	spider_net_write_reg(card, SPIDER_NET_GMACMODE,
-			     SPIDER_NET_MACMODE_VALUE);
 	spider_net_write_reg(card, SPIDER_NET_GMACOPEMD,
 			     SPIDER_NET_OPMODE_VALUE);
 
@@ -1656,6 +1719,11 @@ spider_net_open(struct net_device *netde
 	struct spider_net_card *card = netdev_priv(netdev);
 	int result;
 
+	/* start probing with copper */
+	spider_net_setup_aneg(card);
+	if (card->phy.def->phy_id)
+		mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
+
 	result = spider_net_init_chain(card, &card->tx_chain);
 	if (result)
 		goto alloc_tx_failed;
@@ -1693,17 +1761,88 @@ alloc_skbs_failed:
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
+	/* if link didn't come up after SPIDER_NET_ANEG_TIMEOUT tries, setup phy again */
+	if (card->aneg_count > SPIDER_NET_ANEG_TIMEOUT) {
+
+		pr_info("%s: link is down trying to bring it up\n", card->netdev->name);
+
+		switch (phy->medium) {
+		case GMII_COPPER:
+			/* enable fiber with autonegotiation first */
+			if (phy->def->ops->enable_fiber)
+				phy->def->ops->enable_fiber(phy, 1);
+			phy->medium = GMII_FIBER;
+			break;
+
+		case GMII_FIBER:
+			/* fiber didn't come up, try to disable fiber autoneg */
+			if (phy->def->ops->enable_fiber)
+				phy->def->ops->enable_fiber(phy, 0);
+			phy->medium = GMII_UNKNOWN;
+			break;
+
+		case GMII_UNKNOWN:
+			/* copper, fiber with and without failed,
+			 * retry from beginning */
+			spider_net_setup_aneg(card);
+			phy->medium = GMII_COPPER;
+			break;
+		}
+
+		card->aneg_count = 0;
+		mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
+		return;
+	}
+
+	/* link still not up, try again later */
+	if (!(phy->def->ops->poll_link(phy))) {
+		card->aneg_count++;
+		mod_timer(&card->aneg_timer, jiffies + SPIDER_NET_ANEG_TIMER);
+		return;
+	}
+
+	/* link came up, get abilities */
+	phy->def->ops->read_link(phy);
+
+	spider_net_write_reg(card, SPIDER_NET_GMACST,
+			     spider_net_read_reg(card, SPIDER_NET_GMACST));
+	spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0x4);
+
+	if (phy->speed == 1000)
+		spider_net_write_reg(card, SPIDER_NET_GMACMODE, 0x00000001);
+	else
+		spider_net_write_reg(card, SPIDER_NET_GMACMODE, 0);
+
+	card->aneg_count = 0;
+
+	pr_debug("Found %s with %i Mbps, %s-duplex %sautoneg.\n",
+		phy->def->name, phy->speed, phy->duplex==1 ? "Full" : "Half",
+		phy->autoneg==1 ? "" : "no ");
+
+	return;
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
@@ -1714,21 +1853,21 @@ spider_net_setup_phy(struct spider_net_c
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
+			if (!mii_phy_probe(phy, phy->mii_id)) {
+				pr_info("Found %s.\n", phy->def->name);
+				break;
+			}
+		}
+	}
 
 	return 0;
 }
@@ -1900,11 +2039,13 @@ spider_net_stop(struct net_device *netde
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 	del_timer_sync(&card->tx_timer);
+	del_timer_sync(&card->aneg_timer);
 
 	/* disable/mask all interrupts */
 	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, 0);
 	spider_net_write_reg(card, SPIDER_NET_GHIINT1MSK, 0);
 	spider_net_write_reg(card, SPIDER_NET_GHIINT2MSK, 0);
+	spider_net_write_reg(card, SPIDER_NET_GMACINTEN, 0);
 
 	free_irq(netdev->irq, netdev);
 
@@ -2043,6 +2184,11 @@ spider_net_setup_netdev(struct spider_ne
 	card->tx_timer.data = (unsigned long) card;
 	netdev->irq = card->pdev->irq;
 
+	card->aneg_count = 0;
+	init_timer(&card->aneg_timer);
+	card->aneg_timer.function = spider_net_link_phy;
+	card->aneg_timer.data = (unsigned long) card;
+
 	card->options.rx_csum = SPIDER_NET_RX_CSUM_DEFAULT;
 
 	card->tx_chain.num_desc = tx_descriptors;
