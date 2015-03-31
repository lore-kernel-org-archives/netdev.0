From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH] mvneta: implement SGMII-based in-band link state signaling
Date: Tue, 31 Mar 2015 16:24:59 +0300
Message-ID: <551AA02B.2050104@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When MDIO bus is unavailable (common setup for SGMII), the in-band
signaling must be used to correctly track link state.
This patch enables the in-band status delivery for links state changes, namely:
- link up/down
- link speed
- duplex full/half
fixed_phy link_update() callback is used to update status.

Note: SGMII setup is so common that I think it deserves a separate API
rather than the per-driver handling. There is an alternative implementation
that adds such API:
https://lkml.org/lkml/2015/3/27/346

CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
CC: Florian Fainelli <f.fainelli@gmail.com>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvneta.c |   90 +++++++++++++++++++++++++++++----
 1 file changed, 79 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 96208f1..13a2aa2 100644
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
@@ -2043,6 +2064,23 @@ static irqreturn_t mvneta_isr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }

+static int mvneta_fixed_link_update(struct net_device *dev,
+				  struct fixed_phy_status *status)
+{
+	struct mvneta_port *pp = netdev_priv(dev);
+	u32 gmac_stat = mvreg_read(pp, MVNETA_GMAC_STATUS);
+
+	status->link = !!(gmac_stat & MVNETA_GMAC_LINK_UP);
+	if (gmac_stat & MVNETA_GMAC_SPEED_1000)
+		status->speed = SPEED_1000;
+	else if (gmac_stat & MVNETA_GMAC_SPEED_100)
+		status->speed = SPEED_100;
+	else
+		status->speed = SPEED_10;
+	status->duplex = !!(gmac_stat & MVNETA_GMAC_FULL_DUPLEX);
+	return 0;
+}
+
 /* NAPI handler
  * Bits 0 - 7 of the causeRxTx register indicate that are transmitted
  * packets on the corresponding TXQ (Bit 0 is for TX queue 1).
@@ -2063,8 +2101,12 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 	}

 	/* Read cause register */
-	cause_rx_tx = mvreg_read(pp, MVNETA_INTR_NEW_CAUSE) &
-		(MVNETA_RX_INTR_MASK(rxq_number) | MVNETA_TX_INTR_MASK(txq_number));
+	cause_rx_tx = mvreg_read(pp, MVNETA_INTR_NEW_CAUSE);
+	if (cause_rx_tx & MVNETA_MISCINTR_INTR_MASK) {
+		/* since phylib uses polling, not much to do here...
+		 * Any way to tell phylib to do the poll NOW? */
+		mvreg_write(pp, MVNETA_INTR_MISC_CAUSE, 0);
+	}

 	/* Release Tx descriptors */
 	if (cause_rx_tx & MVNETA_TX_INTR_MASK_ALL) {
@@ -2109,7 +2151,9 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 		local_irq_save(flags);
 		mvreg_write(pp, MVNETA_INTR_NEW_MASK,
-			    MVNETA_RX_INTR_MASK(rxq_number) | MVNETA_TX_INTR_MASK(txq_number));
+			    MVNETA_RX_INTR_MASK(rxq_number) |
+			    MVNETA_TX_INTR_MASK(txq_number) |
+			    MVNETA_MISCINTR_INTR_MASK);
 		local_irq_restore(flags);
 	}

@@ -2373,7 +2417,13 @@ static void mvneta_start_dev(struct mvneta_port *pp)

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
@@ -2523,9 +2573,7 @@ static void mvneta_adjust_link(struct net_device *ndev)
 			val = mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
 			val &= ~(MVNETA_GMAC_CONFIG_MII_SPEED |
 				 MVNETA_GMAC_CONFIG_GMII_SPEED |
-				 MVNETA_GMAC_CONFIG_FULL_DUPLEX |
-				 MVNETA_GMAC_AN_SPEED_EN |
-				 MVNETA_GMAC_AN_DUPLEX_EN);
+				 MVNETA_GMAC_CONFIG_FULL_DUPLEX);

 			if (phydev->duplex)
 				val |= MVNETA_GMAC_CONFIG_FULL_DUPLEX;
@@ -2554,12 +2602,24 @@ static void mvneta_adjust_link(struct net_device *ndev)

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
@@ -2576,6 +2636,7 @@ static int mvneta_mdio_probe(struct mvneta_port *pp)
 		netdev_err(pp->dev, "could not find the PHY\n");
 		return -ENODEV;
 	}
+	fixed_phy_set_link_update(phy_dev, mvneta_fixed_link_update);

 	phy_dev->supported &= PHY_GBIT_FEATURES;
 	phy_dev->advertising = phy_dev->supported;
@@ -2590,6 +2651,7 @@ static int mvneta_mdio_probe(struct mvneta_port *pp)

 static void mvneta_mdio_remove(struct mvneta_port *pp)
 {
+	fixed_phy_set_link_update(pp->phy_dev, NULL);
 	phy_disconnect(pp->phy_dev);
 	pp->phy_dev = NULL;
 }
@@ -2910,6 +2972,9 @@ static int mvneta_port_power_up(struct mvneta_port *pp, int phy_mode)
 		return -EINVAL;
 	}

+	if (pp->use_inband_status)
+		ctrl |= MVNETA_GMAC2_INBAND_AN_ENABLE;
+
 	/* Cancel Port Reset */
 	ctrl &= ~MVNETA_GMAC2_PORT_RESET;
 	mvreg_write(pp, MVNETA_GMAC_CTRL_2, ctrl);
@@ -2934,6 +2999,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	char hw_mac_addr[ETH_ALEN];
 	const char *mac_from;
 	int phy_mode;
+	int fixed_phy = 0;
 	int err;

 	/* Our multiqueue support is not complete, so for now, only
@@ -2967,6 +3033,7 @@ static int mvneta_probe(struct platform_device *pdev)
 			dev_err(&pdev->dev, "cannot register fixed PHY\n");
 			goto err_free_irq;
 		}
+		fixed_phy = 1;

 		/* In the case of a fixed PHY, the DT node associated
 		 * to the PHY is the Ethernet MAC DT node.
@@ -2990,6 +3057,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	pp = netdev_priv(dev);
 	pp->phy_node = phy_node;
 	pp->phy_interface = phy_mode;
+	pp->use_inband_status = (phy_mode == PHY_INTERFACE_MODE_SGMII) && fixed_phy;

 	pp->clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pp->clk)) {
-- 
1.7.9.5
