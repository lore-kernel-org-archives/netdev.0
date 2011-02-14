From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 6/9] jme: Safer MAC processor reset sequence
Date: Mon, 14 Feb 2011 12:27:39 +0800
Message-ID: <1297657662-30289-6-git-send-email-cooldavid@cooldavid.org>
References: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Aries Lee" <arieslee@jmicron.com>,
	"Devinchiu" <devinchiu@jmicron.com>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:48731 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755145Ab1BNE2d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 23:28:33 -0500
In-Reply-To: <1297657662-30289-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Adding control to clk_rx, and makes the control of clk_{rx|tx|tcp}
with safer sequence.
This sequence is provided by JMicron.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |  152 ++++++++++++++++++++++++++++++++++++++++------------
 drivers/net/jme.h |   16 +++---
 2 files changed, 126 insertions(+), 42 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 6996d04..dd41324 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -161,6 +161,67 @@ jme_setup_wakeup_frame(struct jme_adapter *jme,
 }
 
 static inline void
+jme_mac_rxclk_off(struct jme_adapter *jme)
+{
+	jme->reg_gpreg1 |= GPREG1_RXCLKOFF;
+	jwrite32f(jme, JME_GPREG1, jme->reg_gpreg1);
+}
+
+static inline void
+jme_mac_rxclk_on(struct jme_adapter *jme)
+{
+	jme->reg_gpreg1 &= ~GPREG1_RXCLKOFF;
+	jwrite32f(jme, JME_GPREG1, jme->reg_gpreg1);
+}
+
+static inline void
+jme_mac_txclk_off(struct jme_adapter *jme)
+{
+	jme->reg_ghc &= ~(GHC_TO_CLK_SRC | GHC_TXMAC_CLK_SRC);
+	jwrite32f(jme, JME_GHC, jme->reg_ghc);
+}
+
+static inline void
+jme_mac_txclk_on(struct jme_adapter *jme)
+{
+	u32 speed = jme->reg_ghc & GHC_SPEED;
+	if (speed == GHC_SPEED_1000M)
+		jme->reg_ghc |= GHC_TO_CLK_GPHY | GHC_TXMAC_CLK_GPHY;
+	else
+		jme->reg_ghc |= GHC_TO_CLK_PCIE | GHC_TXMAC_CLK_PCIE;
+	jwrite32f(jme, JME_GHC, jme->reg_ghc);
+}
+
+static inline void
+jme_reset_ghc_speed(struct jme_adapter *jme)
+{
+	jme->reg_ghc &= ~(GHC_SPEED | GHC_DPX);
+	jwrite32f(jme, JME_GHC, jme->reg_ghc);
+}
+
+static inline void
+jme_reset_250A2_workaround(struct jme_adapter *jme)
+{
+	jme->reg_gpreg1 &= ~(GPREG1_HALFMODEPATCH |
+			     GPREG1_RSSPATCH);
+	jwrite32(jme, JME_GPREG1, jme->reg_gpreg1);
+}
+
+static inline void
+jme_assert_ghc_reset(struct jme_adapter *jme)
+{
+	jme->reg_ghc |= GHC_SWRST;
+	jwrite32f(jme, JME_GHC, jme->reg_ghc);
+}
+
+static inline void
+jme_clear_ghc_reset(struct jme_adapter *jme)
+{
+	jme->reg_ghc &= ~GHC_SWRST;
+	jwrite32f(jme, JME_GHC, jme->reg_ghc);
+}
+
+static inline void
 jme_reset_mac_processor(struct jme_adapter *jme)
 {
 	static const u32 mask[WAKEUP_FRAME_MASK_DWNR] = {0, 0, 0, 0};
@@ -168,9 +229,24 @@ jme_reset_mac_processor(struct jme_adapter *jme)
 	u32 gpreg0;
 	int i;
 
-	jwrite32(jme, JME_GHC, jme->reg_ghc | GHC_SWRST);
-	udelay(2);
-	jwrite32(jme, JME_GHC, jme->reg_ghc);
+	jme_reset_ghc_speed(jme);
+	jme_reset_250A2_workaround(jme);
+
+	jme_mac_rxclk_on(jme);
+	jme_mac_txclk_on(jme);
+	udelay(1);
+	jme_assert_ghc_reset(jme);
+	udelay(1);
+	jme_mac_rxclk_off(jme);
+	jme_mac_txclk_off(jme);
+	udelay(1);
+	jme_clear_ghc_reset(jme);
+	udelay(1);
+	jme_mac_rxclk_on(jme);
+	jme_mac_txclk_on(jme);
+	udelay(1);
+	jme_mac_rxclk_off(jme);
+	jme_mac_txclk_off(jme);
 
 	jwrite32(jme, JME_RXDBA_LO, 0x00000000);
 	jwrite32(jme, JME_RXDBA_HI, 0x00000000);
@@ -190,14 +266,6 @@ jme_reset_mac_processor(struct jme_adapter *jme)
 	else
 		gpreg0 = GPREG0_DEFAULT;
 	jwrite32(jme, JME_GPREG0, gpreg0);
-	jwrite32(jme, JME_GPREG1, GPREG1_DEFAULT);
-}
-
-static inline void
-jme_reset_ghc_speed(struct jme_adapter *jme)
-{
-	jme->reg_ghc &= ~(GHC_SPEED_1000M | GHC_DPX);
-	jwrite32(jme, JME_GHC, jme->reg_ghc);
 }
 
 static inline void
@@ -351,7 +419,7 @@ static int
 jme_check_link(struct net_device *netdev, int testonly)
 {
 	struct jme_adapter *jme = netdev_priv(netdev);
-	u32 phylink, ghc, cnt = JME_SPDRSV_TIMEOUT, bmcr, gpreg1;
+	u32 phylink, cnt = JME_SPDRSV_TIMEOUT, bmcr;
 	char linkmsg[64];
 	int rc = 0;
 
@@ -414,23 +482,21 @@ jme_check_link(struct net_device *netdev, int testonly)
 
 		jme->phylink = phylink;
 
-		ghc = jme->reg_ghc & ~(GHC_SPEED | GHC_DPX |
-				GHC_TO_CLK_PCIE | GHC_TXMAC_CLK_PCIE |
-				GHC_TO_CLK_GPHY | GHC_TXMAC_CLK_GPHY);
+		/*
+		 * The speed/duplex setting of jme->reg_ghc already cleared
+		 * by jme_reset_mac_processor()
+		 */
 		switch (phylink & PHY_LINK_SPEED_MASK) {
 		case PHY_LINK_SPEED_10M:
-			ghc |= GHC_SPEED_10M |
-				GHC_TO_CLK_PCIE | GHC_TXMAC_CLK_PCIE;
+			jme->reg_ghc |= GHC_SPEED_10M;
 			strcat(linkmsg, "10 Mbps, ");
 			break;
 		case PHY_LINK_SPEED_100M:
-			ghc |= GHC_SPEED_100M |
-				GHC_TO_CLK_PCIE | GHC_TXMAC_CLK_PCIE;
+			jme->reg_ghc |= GHC_SPEED_100M;
 			strcat(linkmsg, "100 Mbps, ");
 			break;
 		case PHY_LINK_SPEED_1000M:
-			ghc |= GHC_SPEED_1000M |
-				GHC_TO_CLK_GPHY | GHC_TXMAC_CLK_GPHY;
+			jme->reg_ghc |= GHC_SPEED_1000M;
 			strcat(linkmsg, "1000 Mbps, ");
 			break;
 		default:
@@ -440,7 +506,7 @@ jme_check_link(struct net_device *netdev, int testonly)
 		if (phylink & PHY_LINK_DUPLEX) {
 			jwrite32(jme, JME_TXMCS, TXMCS_DEFAULT);
 			jwrite32(jme, JME_TXTRHD, TXTRHD_FULLDUPLEX);
-			ghc |= GHC_DPX;
+			jme->reg_ghc |= GHC_DPX;
 		} else {
 			jwrite32(jme, JME_TXMCS, TXMCS_DEFAULT |
 						TXMCS_BACKOFF |
@@ -449,18 +515,21 @@ jme_check_link(struct net_device *netdev, int testonly)
 			jwrite32(jme, JME_TXTRHD, TXTRHD_HALFDUPLEX);
 		}
 
-		gpreg1 = GPREG1_DEFAULT;
+		jwrite32(jme, JME_GHC, jme->reg_ghc);
+
 		if (is_buggy250(jme->pdev->device, jme->chiprev)) {
+			jme->reg_gpreg1 &= ~(GPREG1_HALFMODEPATCH |
+					     GPREG1_RSSPATCH);
 			if (!(phylink & PHY_LINK_DUPLEX))
-				gpreg1 |= GPREG1_HALFMODEPATCH;
+				jme->reg_gpreg1 |= GPREG1_HALFMODEPATCH;
 			switch (phylink & PHY_LINK_SPEED_MASK) {
 			case PHY_LINK_SPEED_10M:
 				jme_set_phyfifo_8level(jme);
-				gpreg1 |= GPREG1_RSSPATCH;
+				jme->reg_gpreg1 |= GPREG1_RSSPATCH;
 				break;
 			case PHY_LINK_SPEED_100M:
 				jme_set_phyfifo_5level(jme);
-				gpreg1 |= GPREG1_RSSPATCH;
+				jme->reg_gpreg1 |= GPREG1_RSSPATCH;
 				break;
 			case PHY_LINK_SPEED_1000M:
 				jme_set_phyfifo_8level(jme);
@@ -469,10 +538,7 @@ jme_check_link(struct net_device *netdev, int testonly)
 				break;
 			}
 		}
-
-		jwrite32(jme, JME_GPREG1, gpreg1);
-		jwrite32(jme, JME_GHC, ghc);
-		jme->reg_ghc = ghc;
+		jwrite32(jme, JME_GPREG1, jme->reg_gpreg1);
 
 		strcat(linkmsg, (phylink & PHY_LINK_DUPLEX) ?
 					"Full-Duplex, " :
@@ -611,10 +677,14 @@ jme_enable_tx_engine(struct jme_adapter *jme)
 	 * Enable TX Engine
 	 */
 	wmb();
-	jwrite32(jme, JME_TXCS, jme->reg_txcs |
+	jwrite32f(jme, JME_TXCS, jme->reg_txcs |
 				TXCS_SELECT_QUEUE0 |
 				TXCS_ENABLE);
 
+	/*
+	 * Start clock for TX MAC Processor
+	 */
+	jme_mac_txclk_on(jme);
 }
 
 static inline void
@@ -649,6 +719,11 @@ jme_disable_tx_engine(struct jme_adapter *jme)
 
 	if (!i)
 		pr_err("Disable TX engine timeout\n");
+
+	/*
+	 * Stop clock for TX MAC Processor
+	 */
+	jme_mac_txclk_off(jme);
 }
 
 static void
@@ -829,10 +904,15 @@ jme_enable_rx_engine(struct jme_adapter *jme)
 	 * Enable RX Engine
 	 */
 	wmb();
-	jwrite32(jme, JME_RXCS, jme->reg_rxcs |
+	jwrite32f(jme, JME_RXCS, jme->reg_rxcs |
 				RXCS_QUEUESEL_Q0 |
 				RXCS_ENABLE |
 				RXCS_QST);
+
+	/*
+	 * Start clock for RX MAC Processor
+	 */
+	jme_mac_rxclk_on(jme);
 }
 
 static inline void
@@ -869,6 +949,10 @@ jme_disable_rx_engine(struct jme_adapter *jme)
 	if (!i)
 		pr_err("Disable RX engine timeout\n");
 
+	/*
+	 * Stop clock for RX MAC Processor
+	 */
+	jme_mac_rxclk_off(jme);
 }
 
 static int
@@ -1205,7 +1289,6 @@ jme_link_change_tasklet(unsigned long arg)
 	tasklet_disable(&jme->rxempty_task);
 
 	if (netif_carrier_ok(netdev)) {
-		jme_reset_ghc_speed(jme);
 		jme_disable_rx_engine(jme);
 		jme_disable_tx_engine(jme);
 		jme_reset_mac_processor(jme);
@@ -1735,7 +1818,6 @@ jme_close(struct net_device *netdev)
 	tasklet_disable(&jme->rxclean_task);
 	tasklet_disable(&jme->rxempty_task);
 
-	jme_reset_ghc_speed(jme);
 	jme_disable_rx_engine(jme);
 	jme_disable_tx_engine(jme);
 	jme_reset_mac_processor(jme);
@@ -2921,6 +3003,7 @@ jme_init_one(struct pci_dev *pdev,
 	jme->reg_rxmcs = RXMCS_DEFAULT;
 	jme->reg_txpfc = 0;
 	jme->reg_pmcs = PMCS_MFEN;
+	jme->reg_gpreg1 = GPREG1_DEFAULT;
 	set_bit(JME_FLAG_TXCSUM, &jme->flags);
 	set_bit(JME_FLAG_TSO, &jme->flags);
 
@@ -3076,7 +3159,6 @@ jme_suspend(struct pci_dev *pdev, pm_message_t state)
 			jme_polling_mode(jme);
 
 		jme_stop_pcc_timer(jme);
-		jme_reset_ghc_speed(jme);
 		jme_disable_rx_engine(jme);
 		jme_disable_tx_engine(jme);
 		jme_reset_mac_processor(jme);
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index b33bc5b..668958c 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -434,6 +434,7 @@ struct jme_adapter {
 	u32			reg_rxmcs;
 	u32			reg_ghc;
 	u32			reg_pmcs;
+	u32			reg_gpreg1;
 	u32			phylink;
 	u32			tx_ring_size;
 	u32			tx_ring_mask;
@@ -821,6 +822,8 @@ static inline u32 smi_phy_addr(int x)
  */
 enum jme_ghc_bit_mask {
 	GHC_SWRST		= 0x40000000,
+	GHC_TO_CLK_SRC		= 0x00C00000,
+	GHC_TXMAC_CLK_SRC	= 0x00300000,
 	GHC_DPX			= 0x00000040,
 	GHC_SPEED		= 0x00000030,
 	GHC_LINK_POLL		= 0x00000001,
@@ -999,18 +1002,17 @@ enum jme_gpreg0_vals {
 
 /*
  * General Purpose REG-1
- * Note: All theses bits defined here are for
- *       Chip mode revision 0x11 only
  */
-enum jme_gpreg1_masks {
+enum jme_gpreg1_bit_masks {
+	GPREG1_RXCLKOFF		= 0x04000000,
+	GPREG1_PCREQN		= 0x00020000,
+	GPREG1_HALFMODEPATCH	= 0x00000040, /* For Chip revision 0x11 only */
+	GPREG1_RSSPATCH		= 0x00000020, /* For Chip revision 0x11 only */
 	GPREG1_INTRDELAYUNIT	= 0x00000018,
 	GPREG1_INTRDELAYENABLE	= 0x00000007,
 };
 
 enum jme_gpreg1_vals {
-	GPREG1_HALFMODEPATCH	= 0x00000040,
-	GPREG1_RSSPATCH		= 0x00000020,
-
 	GPREG1_INTDLYUNIT_16NS	= 0x00000000,
 	GPREG1_INTDLYUNIT_256NS	= 0x00000008,
 	GPREG1_INTDLYUNIT_1US	= 0x00000010,
@@ -1024,7 +1026,7 @@ enum jme_gpreg1_vals {
 	GPREG1_INTDLYEN_6U	= 0x00000006,
 	GPREG1_INTDLYEN_7U	= 0x00000007,
 
-	GPREG1_DEFAULT		= 0x00000000,
+	GPREG1_DEFAULT		= GPREG1_PCREQN,
 };
 
 /*
-- 
1.7.2.2

