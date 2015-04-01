From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH 2/2] mvneta: implement SGMII-based in-band link state signaling
Date: Wed, 01 Apr 2015 20:32:49 +0300
Message-ID: <551C2BC1.4040906@list.ru>
References: <551C2AB9.8020508@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <551C2AB9.8020508@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When MDIO bus is unavailable (common setup for SGMII), the in-band
signaling must be used to correctly track link state.
This patch enables the in-band status delivery for link state changes, namely:
- link up/down
- link speed
- duplex full/half
fixed_phy_update_state() is used to update phy status.

CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
CC: Florian Fainelli <f.fainelli@gmail.com>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvneta.c |  106 +++++++++++++++++++++++++++++----
 1 file changed, 95 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 96208f1..a7a9271 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -100,6 +100,8 @@
 #define MVNETA_TXQ_CMD                           0x2448
 #define      MVNETA_TXQ_DISABLE_SHIFT            8
 #define      MVNETA_TXQ_ENABLE_MASK              0x000000ff
+#define MVNETA_GMAC_CLOCK_DIVIDER                0x24f4
+#define      MVNETA_GMAC_1MS_CLOCK_ENABLE        BIT(31)
 #define MVNETA_ACC_MODE                          0x2500
 #define MVNETA_CPU_MAP(cpu)                      (0x2540 + ((cpu) << 2))
 #define      MVNETA_CPU_RXQ_ACCESS_ALL_MASK      0x000000ff
@@ -122,6 +124,7 @@
 #define      MVNETA_TX_INTR_MASK_ALL             (0xff << 0)
 #define      MVNETA_RX_INTR_MASK(nr_rxqs)        (((1 << nr_rxqs) - 1) << 8)
 #define      MVNETA_RX_INTR_MASK_ALL             (0xff << 8)
+#define      MVNETA_MISCINTR_INTR_MASK           BIT(31)

 #define MVNETA_INTR_OLD_CAUSE                    0x25a8
 #define MVNETA_INTR_OLD_MASK                     0x25ac
@@ -165,6 +168,7 @@
 #define      MVNETA_GMAC_MAX_RX_SIZE_MASK        0x7ffc
 #define      MVNETA_GMAC0_PORT_ENABLE            BIT(0)
 #define MVNETA_GMAC_CTRL_2                       0x2c08
+#define      MVNETA_GMAC2_INBAND_AN_ENABLE       BIT(0)
 #define      MVNETA_GMAC2_PCS_ENABLE             BIT(3)
 #define      MVNETA_GMAC2_PORT_RGMII             BIT(4)
 #define      MVNETA_GMAC2_PORT_RESET             BIT(6)
@@ -180,9 +184,11 @@
 #define MVNETA_GMAC_AUTONEG_CONFIG               0x2c0c
 #define      MVNETA_GMAC_FORCE_LINK_DOWN         BIT(0)
 #define      MVNETA_GMAC_FORCE_LINK_PASS         BIT(1)
+#define      MVNETA_GMAC_INBAND_AN_ENABLE        BIT(2)
 #define      MVNETA_GMAC_CONFIG_MII_SPEED        BIT(5)
 #define      MVNETA_GMAC_CONFIG_GMII_SPEED       BIT(6)
 #define      MVNETA_GMAC_AN_SPEED_EN             BIT(7)
+#define      MVNETA_GMAC_AN_FLOW_CTRL_EN         BIT(11)
 #define      MVNETA_GMAC_CONFIG_FULL_DUPLEX      BIT(12)
 #define      MVNETA_GMAC_AN_DUPLEX_EN            BIT(13)
 #define MVNETA_MIB_COUNTERS_BASE                 0x3080
@@ -304,6 +310,7 @@ struct mvneta_port {
 	unsigned int link;
 	unsigned int duplex;
 	unsigned int speed;
+	int use_inband_status:1;
 };

 /* The mvneta_tx_desc and mvneta_rx_desc structures describe the
@@ -994,6 +1001,20 @@ static void mvneta_defaults_set(struct mvneta_port *pp)
 	val &= ~MVNETA_PHY_POLLING_ENABLE;
 	mvreg_write(pp, MVNETA_UNIT_CONTROL, val);

+	if (pp->use_inband_status) {
+		val = mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
+		val &= ~(MVNETA_GMAC_FORCE_LINK_PASS |
+			 MVNETA_GMAC_FORCE_LINK_DOWN |
+			 MVNETA_GMAC_AN_FLOW_CTRL_EN);
+		val |= MVNETA_GMAC_INBAND_AN_ENABLE |
+		       MVNETA_GMAC_AN_SPEED_EN |
+		       MVNETA_GMAC_AN_DUPLEX_EN;
+		mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
+		val = mvreg_read(pp, MVNETA_GMAC_CLOCK_DIVIDER);
+		val |= MVNETA_GMAC_1MS_CLOCK_ENABLE;
+		mvreg_write(pp, MVNETA_GMAC_CLOCK_DIVIDER, val);
+	}
+
 	mvneta_set_ucast_table(pp, -1);
 	mvneta_set_special_mcast_table(pp, -1);
 	mvneta_set_other_mcast_table(pp, -1);
@@ -2043,6 +2064,28 @@ static irqreturn_t mvneta_isr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }

+static int mvneta_fixed_link_update(struct mvneta_port *pp,
+				    struct phy_device *phy)
+{
+	struct fixed_phy_status status;
+	struct fixed_phy_status changed = {};
+	u32 gmac_stat = mvreg_read(pp, MVNETA_GMAC_STATUS);
+
+	status.link = !!(gmac_stat & MVNETA_GMAC_LINK_UP);
+	if (gmac_stat & MVNETA_GMAC_SPEED_1000)
+		status.speed = SPEED_1000;
+	else if (gmac_stat & MVNETA_GMAC_SPEED_100)
+		status.speed = SPEED_100;
+	else
+		status.speed = SPEED_10;
+	status.duplex = !!(gmac_stat & MVNETA_GMAC_FULL_DUPLEX);
+	changed.link = 1;
+	changed.speed = 1;
+	changed.duplex = 1;
+	fixed_phy_update_state(phy, &status, &changed);
+	return 0;
+}
+
 /* NAPI handler
  * Bits 0 - 7 of the causeRxTx register indicate that are transmitted
  * packets on the corresponding TXQ (Bit 0 is for TX queue 1).
@@ -2063,8 +2106,18 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 	}

 	/* Read cause register */
-	cause_rx_tx = mvreg_read(pp, MVNETA_INTR_NEW_CAUSE) &
-		(MVNETA_RX_INTR_MASK(rxq_number) | MVNETA_TX_INTR_MASK(txq_number));
+	cause_rx_tx = mvreg_read(pp, MVNETA_INTR_NEW_CAUSE);
+	if (cause_rx_tx & MVNETA_MISCINTR_INTR_MASK) {
+		u32 cause_misc = mvreg_read(pp, MVNETA_INTR_MISC_CAUSE);
+
+		mvreg_write(pp, MVNETA_INTR_MISC_CAUSE, 0);
+		if (pp->use_inband_status && (cause_misc &
+				(MVNETA_CAUSE_PHY_STATUS_CHANGE |
+				 MVNETA_CAUSE_LINK_CHANGE |
+				 MVNETA_CAUSE_PSC_SYNC_CHANGE))) {
+			mvneta_fixed_link_update(pp, pp->phy_dev);
+		}
+	}

 	/* Release Tx descriptors */
 	if (cause_rx_tx & MVNETA_TX_INTR_MASK_ALL) {
@@ -2109,7 +2162,9 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 		local_irq_save(flags);
 		mvreg_write(pp, MVNETA_INTR_NEW_MASK,
-			    MVNETA_RX_INTR_MASK(rxq_number) | MVNETA_TX_INTR_MASK(txq_number));
+			    MVNETA_RX_INTR_MASK(rxq_number) |
+			    MVNETA_TX_INTR_MASK(txq_number) |
+			    MVNETA_MISCINTR_INTR_MASK);
 		local_irq_restore(flags);
 	}

@@ -2373,7 +2428,13 @@ static void mvneta_start_dev(struct mvneta_port *pp)

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
@@ -2523,9 +2584,7 @@ static void mvneta_adjust_link(struct net_device *ndev)
 			val = mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
 			val &= ~(MVNETA_GMAC_CONFIG_MII_SPEED |
 				 MVNETA_GMAC_CONFIG_GMII_SPEED |
-				 MVNETA_GMAC_CONFIG_FULL_DUPLEX |
-				 MVNETA_GMAC_AN_SPEED_EN |
-				 MVNETA_GMAC_AN_DUPLEX_EN);
+				 MVNETA_GMAC_CONFIG_FULL_DUPLEX);

 			if (phydev->duplex)
 				val |= MVNETA_GMAC_CONFIG_FULL_DUPLEX;
@@ -2554,12 +2613,24 @@ static void mvneta_adjust_link(struct net_device *ndev)

 	if (status_change) {
 		if (phydev->link) {
-			u32 val = mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
-			val |= (MVNETA_GMAC_FORCE_LINK_PASS |
-				MVNETA_GMAC_FORCE_LINK_DOWN);
-			mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
+			if (!pp->use_inband_status) {
+				u32 val = mvreg_read(pp,
+						  MVNETA_GMAC_AUTONEG_CONFIG);
+				val &= ~MVNETA_GMAC_FORCE_LINK_DOWN;
+				val |= MVNETA_GMAC_FORCE_LINK_PASS;
+				mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG,
+					    val);
+			}
 			mvneta_port_up(pp);
 		} else {
+			if (!pp->use_inband_status) {
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
@@ -2910,6 +2981,9 @@ static int mvneta_port_power_up(struct mvneta_port *pp, int phy_mode)
 		return -EINVAL;
 	}

+	if (pp->use_inband_status)
+		ctrl |= MVNETA_GMAC2_INBAND_AN_ENABLE;
+
 	/* Cancel Port Reset */
 	ctrl &= ~MVNETA_GMAC2_PORT_RESET;
 	mvreg_write(pp, MVNETA_GMAC_CTRL_2, ctrl);
@@ -2934,6 +3008,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	char hw_mac_addr[ETH_ALEN];
 	const char *mac_from;
 	int phy_mode;
+	int fixed_phy = 0;
 	int err;

 	/* Our multiqueue support is not complete, so for now, only
@@ -2967,6 +3042,7 @@ static int mvneta_probe(struct platform_device *pdev)
 			dev_err(&pdev->dev, "cannot register fixed PHY\n");
 			goto err_free_irq;
 		}
+		fixed_phy = 1;

 		/* In the case of a fixed PHY, the DT node associated
 		 * to the PHY is the Ethernet MAC DT node.
@@ -2990,6 +3066,8 @@ static int mvneta_probe(struct platform_device *pdev)
 	pp = netdev_priv(dev);
 	pp->phy_node = phy_node;
 	pp->phy_interface = phy_mode;
+	pp->use_inband_status = (phy_mode == PHY_INTERFACE_MODE_SGMII) &&
+				fixed_phy;

 	pp->clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pp->clk)) {
@@ -3067,6 +3145,12 @@ static int mvneta_probe(struct platform_device *pdev)

 	platform_set_drvdata(pdev, pp->dev);

+	if (pp->use_inband_status) {
+		struct phy_device *phy = of_phy_find_device(dn);
+
+		mvneta_fixed_link_update(pp, phy);
+	}
+
 	return 0;

 err_free_stats:
-- 
1.7.9.5
