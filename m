From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH 5/6] mvneta: implement SGMII-based in-band link state signaling
Date: Fri, 27 Mar 2015 16:39:41 +0300
Message-ID: <55155D9D.6070800@list.ru>
References: <55155AFC.4050800@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55155AFC.4050800@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When MDIO bus is unavailable (common setup for SGMII), the in-band
signaling must be used to correctly track link state.
This patch enables the in-band status delivery and interrupts for
links state changes, namely:
- link up/down
- link speed
- duplex full/half
Upon reciving the appropriate interrupt, the driver updates the
fixed_phy status to match the received status.

CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvneta.c |   92 +++++++++++++++++++++++++++++----
 1 file changed, 81 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 96208f1..2d1c689 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -122,6 +122,7 @@
 #define      MVNETA_TX_INTR_MASK_ALL             (0xff << 0)
 #define      MVNETA_RX_INTR_MASK(nr_rxqs)        (((1 << nr_rxqs) - 1) << 8)
 #define      MVNETA_RX_INTR_MASK_ALL             (0xff << 8)
+#define      MVNETA_MISCINTR_INTR_MASK           BIT(31)

 #define MVNETA_INTR_OLD_CAUSE                    0x25a8
 #define MVNETA_INTR_OLD_MASK                     0x25ac
@@ -180,6 +181,7 @@
 #define MVNETA_GMAC_AUTONEG_CONFIG               0x2c0c
 #define      MVNETA_GMAC_FORCE_LINK_DOWN         BIT(0)
 #define      MVNETA_GMAC_FORCE_LINK_PASS         BIT(1)
+#define      MVNETA_GMAC_INBAND_AN_ENABLE        BIT(2)
 #define      MVNETA_GMAC_CONFIG_MII_SPEED        BIT(5)
 #define      MVNETA_GMAC_CONFIG_GMII_SPEED       BIT(6)
 #define      MVNETA_GMAC_AN_SPEED_EN             BIT(7)
@@ -304,6 +306,7 @@ struct mvneta_port {
 	unsigned int link;
 	unsigned int duplex;
 	unsigned int speed;
+	int inband_status;
 };

 /* The mvneta_tx_desc and mvneta_rx_desc structures describe the
@@ -994,6 +997,16 @@ static void mvneta_defaults_set(struct mvneta_port *pp)
 	val &= ~MVNETA_PHY_POLLING_ENABLE;
 	mvreg_write(pp, MVNETA_UNIT_CONTROL, val);

+	if (pp->inband_status) {
+		val = mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
+		val &= ~(MVNETA_GMAC_FORCE_LINK_PASS |
+			 MVNETA_GMAC_FORCE_LINK_DOWN);
+		val |= MVNETA_GMAC_INBAND_AN_ENABLE |
+		       MVNETA_GMAC_AN_SPEED_EN |
+		       MVNETA_GMAC_AN_DUPLEX_EN;
+		mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
+	}
+
 	mvneta_set_ucast_table(pp, -1);
 	mvneta_set_special_mcast_table(pp, -1);
 	mvneta_set_other_mcast_table(pp, -1);
@@ -2043,6 +2056,21 @@ static irqreturn_t mvneta_isr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }

+static void mvneta_get_phy_status(struct mvneta_port *pp,
+				  struct fixed_phy_status *r_stat)
+{
+	u32 gmac_stat = mvreg_read(pp, MVNETA_GMAC_STATUS);
+
+	r_stat->link = !!(gmac_stat & MVNETA_GMAC_LINK_UP);
+	if (gmac_stat & MVNETA_GMAC_SPEED_1000)
+		r_stat->speed = SPEED_1000;
+	else if (gmac_stat & MVNETA_GMAC_SPEED_100)
+		r_stat->speed = SPEED_100;
+	else
+		r_stat->speed = SPEED_10;
+	r_stat->duplex = !!(gmac_stat & MVNETA_GMAC_FULL_DUPLEX);
+}
+
 /* NAPI handler
  * Bits 0 - 7 of the causeRxTx register indicate that are transmitted
  * packets on the corresponding TXQ (Bit 0 is for TX queue 1).
@@ -2063,8 +2091,29 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 	}

 	/* Read cause register */
-	cause_rx_tx = mvreg_read(pp, MVNETA_INTR_NEW_CAUSE) &
-		(MVNETA_RX_INTR_MASK(rxq_number) | MVNETA_TX_INTR_MASK(txq_number));
+	cause_rx_tx = mvreg_read(pp, MVNETA_INTR_NEW_CAUSE);
+	if (cause_rx_tx & MVNETA_MISCINTR_INTR_MASK) {
+		u32 cause_misc = mvreg_read(pp, MVNETA_INTR_MISC_CAUSE);
+
+		mvreg_write(pp, MVNETA_INTR_MISC_CAUSE, 0);
+		if (pp->inband_status && (cause_misc &
+				 (MVNETA_CAUSE_PHY_STATUS_CHANGE |
+				  MVNETA_CAUSE_LINK_CHANGE |
+				  MVNETA_CAUSE_PSC_SYNC_CHANGE))) {
+			struct fixed_phy_status phy_stat;
+
+			mvneta_get_phy_status(pp, &phy_stat);
+			if (pp->link != phy_stat.link)
+				of_phy_fixed_link_set_link(pp->phy_dev,
+							   phy_stat.link);
+			if (pp->speed != phy_stat.speed)
+				of_phy_fixed_link_set_speed(pp->phy_dev,
+							    phy_stat.speed);
+			if (pp->duplex != phy_stat.duplex)
+				of_phy_fixed_link_set_duplex(pp->phy_dev,
+							     phy_stat.duplex);
+		}
+	}

 	/* Release Tx descriptors */
 	if (cause_rx_tx & MVNETA_TX_INTR_MASK_ALL) {
@@ -2109,7 +2158,9 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 		local_irq_save(flags);
 		mvreg_write(pp, MVNETA_INTR_NEW_MASK,
-			    MVNETA_RX_INTR_MASK(rxq_number) | MVNETA_TX_INTR_MASK(txq_number));
+			    MVNETA_RX_INTR_MASK(rxq_number) |
+			    MVNETA_TX_INTR_MASK(txq_number) |
+			    MVNETA_MISCINTR_INTR_MASK);
 		local_irq_restore(flags);
 	}

@@ -2373,7 +2424,13 @@ static void mvneta_start_dev(struct mvneta_port *pp)

 	/* Unmask interrupts */
 	mvreg_write(pp, MVNETA_INTR_NEW_MASK,
-		    MVNETA_RX_INTR_MASK(rxq_number) | MVNETA_TX_INTR_MASK(txq_number));
+		    MVNETA_RX_INTR_MASK(rxq_number) |
+		    MVNETA_TX_INTR_MASK(txq_number) |
+		    MVNETA_MISCINTR_INTR_MASK);
+	mvreg_write(pp, MVNETA_INTR_MISC_MASK,
+		    MVNETA_CAUSE_PHY_STATUS_CHANGE |
+		    MVNETA_CAUSE_LINK_CHANGE |
+		    MVNETA_CAUSE_PSC_SYNC_CHANGE);

 	phy_start(pp->phy_dev);
 	netif_tx_start_all_queues(pp->dev);
@@ -2523,9 +2580,7 @@ static void mvneta_adjust_link(struct net_device *ndev)
 			val = mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
 			val &= ~(MVNETA_GMAC_CONFIG_MII_SPEED |
 				 MVNETA_GMAC_CONFIG_GMII_SPEED |
-				 MVNETA_GMAC_CONFIG_FULL_DUPLEX |
-				 MVNETA_GMAC_AN_SPEED_EN |
-				 MVNETA_GMAC_AN_DUPLEX_EN);
+				 MVNETA_GMAC_CONFIG_FULL_DUPLEX);

 			if (phydev->duplex)
 				val |= MVNETA_GMAC_CONFIG_FULL_DUPLEX;
@@ -2554,12 +2609,24 @@ static void mvneta_adjust_link(struct net_device *ndev)

 	if (status_change) {
 		if (phydev->link) {
-			u32 val = mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
-			val |= (MVNETA_GMAC_FORCE_LINK_PASS |
-				MVNETA_GMAC_FORCE_LINK_DOWN);
-			mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
+			if (!pp->inband_status) {
+				u32 val = mvreg_read(pp,
+						  MVNETA_GMAC_AUTONEG_CONFIG);
+				val &= ~MVNETA_GMAC_FORCE_LINK_DOWN;
+				val |= MVNETA_GMAC_FORCE_LINK_PASS;
+				mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG,
+					    val);
+			}
 			mvneta_port_up(pp);
 		} else {
+			if (!pp->inband_status) {
+				u32 val = mvreg_read(pp,
+						  MVNETA_GMAC_AUTONEG_CONFIG);
+				val &= ~MVNETA_GMAC_FORCE_LINK_PASS;
+				val |= MVNETA_GMAC_FORCE_LINK_DOWN;
+				mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG,
+					    val);
+			}
 			mvneta_port_down(pp);
 		}
 		phy_print_status(phydev);
@@ -2934,6 +3001,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	char hw_mac_addr[ETH_ALEN];
 	const char *mac_from;
 	int phy_mode;
+	int fixed_phy = 0;
 	int err;

 	/* Our multiqueue support is not complete, so for now, only
@@ -2967,6 +3035,7 @@ static int mvneta_probe(struct platform_device *pdev)
 			dev_err(&pdev->dev, "cannot register fixed PHY\n");
 			goto err_free_irq;
 		}
+		fixed_phy = 1;

 		/* In the case of a fixed PHY, the DT node associated
 		 * to the PHY is the Ethernet MAC DT node.
@@ -2990,6 +3059,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	pp = netdev_priv(dev);
 	pp->phy_node = phy_node;
 	pp->phy_interface = phy_mode;
+	pp->inband_status = (phy_mode == PHY_INTERFACE_MODE_SGMII) && fixed_phy;

 	pp->clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pp->clk)) {
-- 
1.7.9.5
