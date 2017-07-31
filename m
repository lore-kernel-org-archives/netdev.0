From: <sean.wang@mediatek.com>
Subject: [PATCH net-next v3 3/4] net-next: mediatek: add support for MediaTek MT7622 SoC
Date: Mon, 31 Jul 2017 18:05:10 +0800
Message-ID: <986a033a9a83b405b74e6e39cff737d35e9154ff.1501494522.git.sean.wang@mediatek.com>
References: <cover.1501494522.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1501494522.git.sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang@mediatek.com>

This patch adds the driver for ethernet controller on MT7622 SoC. It has
the similar handling logic as the previously MT7623 does, but there are
additions against with MT7623 SoC, the shared SGMII given for the dual
GMACs and including 5-ports 10/100 embedded switch support (ESW) as the
GMAC1 option, thus more clocks consumers for the extra feature are
introduced here. So for ease portability and maintenance, those
differences all are being kept inside the platform data as other drivers
usually do. Currently testing successfully is done with those patches for
the conditions such as GMAC2 with IP1001 PHY via RGMII and GMAC1/2 with
RTL8211F PHY via SGMII.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 67 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/mediatek/mtk_eth_soc.h | 54 ++++++++++++++++++++++-
 2 files changed, 117 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index ad48623..9f44246 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -52,7 +52,8 @@ static const struct mtk_ethtool_stats {
 };
 
 static const char * const mtk_clks_source_name[] = {
-	"ethif", "esw", "gp1", "gp2", "trgpll"
+	"ethif", "esw", "gp0", "gp1", "gp2", "trgpll", "sgmii_tx250m",
+	"sgmii_rx250m", "sgmii_cdr_ref", "sgmii_cdr_fb", "sgmii_ck", "eth2pll"
 };
 
 void mtk_w32(struct mtk_eth *eth, u32 val, unsigned reg)
@@ -162,6 +163,47 @@ static void mtk_gmac0_rgmii_adjust(struct mtk_eth *eth, int speed)
 	mtk_w32(eth, val, TRGMII_TCK_CTRL);
 }
 
+static void mtk_gmac_sgmii_hw_setup(struct mtk_eth *eth, int mac_id)
+{
+	u32 val;
+
+	/* Setup the link timer and QPHY power up inside SGMIISYS */
+	regmap_write(eth->sgmiisys, SGMSYS_PCS_LINK_TIMER,
+		     SGMII_LINK_TIMER_DEFAULT);
+
+	regmap_read(eth->sgmiisys, SGMSYS_SGMII_MODE, &val);
+	val |= SGMII_REMOTE_FAULT_DIS;
+	regmap_write(eth->sgmiisys, SGMSYS_SGMII_MODE, val);
+
+	regmap_read(eth->sgmiisys, SGMSYS_PCS_CONTROL_1, &val);
+	val |= SGMII_AN_RESTART;
+	regmap_write(eth->sgmiisys, SGMSYS_PCS_CONTROL_1, val);
+
+	regmap_read(eth->sgmiisys, SGMSYS_QPHY_PWR_STATE_CTRL, &val);
+	val &= ~SGMII_PHYA_PWD;
+	regmap_write(eth->sgmiisys, SGMSYS_QPHY_PWR_STATE_CTRL, val);
+
+	/* Determine MUX for which GMAC uses the SGMII interface */
+	if (MTK_HAS_CAPS(eth->soc->caps, MTK_DUAL_GMAC_SHARED_SGMII)) {
+		regmap_read(eth->ethsys, ETHSYS_SYSCFG0, &val);
+		val &= ~SYSCFG0_SGMII_MASK;
+		val |= !mac_id ? SYSCFG0_SGMII_GMAC1 : SYSCFG0_SGMII_GMAC2;
+		regmap_write(eth->ethsys, ETHSYS_SYSCFG0, val);
+
+		dev_info(eth->dev, "setup shared sgmii for gmac=%d\n",
+			 mac_id);
+	}
+
+	/* Setup the GMAC1 going through SGMII path when SoC also support
+	 * ESW on GMAC1
+	 */
+	if (MTK_HAS_CAPS(eth->soc->caps, MTK_GMAC1_ESW | MTK_GMAC1_SGMII) &&
+	    !mac_id) {
+		mtk_w32(eth, 0, MTK_MAC_MISC);
+		dev_info(eth->dev, "setup gmac1 going through sgmii");
+	}
+}
+
 static void mtk_phy_link_adjust(struct net_device *dev)
 {
 	struct mtk_mac *mac = netdev_priv(dev);
@@ -269,6 +311,7 @@ static int mtk_phy_connect(struct net_device *dev)
 	if (!np)
 		return -ENODEV;
 
+	mac->ge_mode = 0;
 	switch (of_get_phy_mode(np)) {
 	case PHY_INTERFACE_MODE_TRGMII:
 		mac->trgmii = true;
@@ -276,7 +319,10 @@ static int mtk_phy_connect(struct net_device *dev)
 	case PHY_INTERFACE_MODE_RGMII_RXID:
 	case PHY_INTERFACE_MODE_RGMII_ID:
 	case PHY_INTERFACE_MODE_RGMII:
-		mac->ge_mode = 0;
+		break;
+	case PHY_INTERFACE_MODE_SGMII:
+		if (MTK_HAS_CAPS(eth->soc->caps, MTK_SGMII))
+			mtk_gmac_sgmii_hw_setup(eth, mac->id);
 		break;
 	case PHY_INTERFACE_MODE_MII:
 		mac->ge_mode = 1;
@@ -2421,6 +2467,7 @@ static int mtk_get_chip_id(struct mtk_eth *eth, u32 *chip_id)
 static bool mtk_is_hwlro_supported(struct mtk_eth *eth)
 {
 	switch (eth->chip_id) {
+	case MT7622_ETH:
 	case MT7623_ETH:
 		return true;
 	}
@@ -2460,6 +2507,16 @@ static int mtk_probe(struct platform_device *pdev)
 		return PTR_ERR(eth->ethsys);
 	}
 
+	if (MTK_HAS_CAPS(eth->soc->caps, MTK_SGMII)) {
+		eth->sgmiisys =
+		syscon_regmap_lookup_by_phandle(pdev->dev.of_node,
+						"mediatek,sgmiisys");
+		if (IS_ERR(eth->sgmiisys)) {
+			dev_err(&pdev->dev, "no sgmiisys regmap found\n");
+			return PTR_ERR(eth->sgmiisys);
+		}
+	}
+
 	eth->pctl = syscon_regmap_lookup_by_phandle(pdev->dev.of_node,
 						    "mediatek,pctl");
 	if (IS_ERR(eth->pctl)) {
@@ -2593,6 +2650,11 @@ static const struct mtk_soc_data mt2701_data = {
 	.required_clks = MT7623_CLKS_BITMAP
 };
 
+static const struct mtk_soc_data mt7622_data = {
+	.caps = MTK_DUAL_GMAC_SHARED_SGMII | MTK_GMAC1_ESW,
+	.required_clks = MT7622_CLKS_BITMAP
+};
+
 static const struct mtk_soc_data mt7623_data = {
 	.caps = MTK_GMAC1_TRGMII,
 	.required_clks = MT7623_CLKS_BITMAP
@@ -2600,6 +2662,7 @@ static const struct mtk_soc_data mt7623_data = {
 
 const struct of_device_id of_mtk_match[] = {
 	{ .compatible = "mediatek,mt2701-eth", .data = &mt2701_data},
+	{ .compatible = "mediatek,mt7622-eth", .data = &mt7622_data},
 	{ .compatible = "mediatek,mt7623-eth", .data = &mt7623_data},
 	{},
 };
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 8ade23df..4594862 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -302,6 +302,9 @@
 #define PHY_IAC_REG_SHIFT	25
 #define PHY_IAC_TIMEOUT		HZ
 
+#define MTK_MAC_MISC		0x1000c
+#define MTK_MUX_TO_ESW		BIT(0)
+
 /* Mac control registers */
 #define MTK_MAC_MCR(x)		(0x10100 + (x * 0x100))
 #define MAC_MCR_MAX_RX_1536	BIT(24)
@@ -357,11 +360,15 @@
 #define ETHSYS_CHIPID0_3	0x0
 #define ETHSYS_CHIPID4_7	0x4
 #define MT7623_ETH		7623
+#define MT7622_ETH		7622
 
 /* ethernet subsystem config register */
 #define ETHSYS_SYSCFG0		0x14
 #define SYSCFG0_GE_MASK		0x3
 #define SYSCFG0_GE_MODE(x, y)	(x << (12 + (y * 2)))
+#define SYSCFG0_SGMII_MASK	(3 << 8)
+#define SYSCFG0_SGMII_GMAC1	((2 << 8) & GENMASK(9, 8))
+#define SYSCFG0_SGMII_GMAC2	((3 << 8) & GENMASK(9, 8))
 
 /* ethernet subsystem clock register */
 #define ETHSYS_CLKCFG0		0x2c
@@ -372,6 +379,23 @@
 #define RSTCTRL_FE		BIT(6)
 #define RSTCTRL_PPE		BIT(31)
 
+/* SGMII subsystem config registers */
+/* Register to auto-negotiation restart */
+#define SGMSYS_PCS_CONTROL_1	0x0
+#define SGMII_AN_RESTART	BIT(9)
+
+/* Register to programmable link timer, the unit in 2 * 8ns */
+#define SGMSYS_PCS_LINK_TIMER	0x18
+#define SGMII_LINK_TIMER_DEFAULT	(0x186a0 & GENMASK(19, 0))
+
+/* Register to control remote fault */
+#define SGMSYS_SGMII_MODE	0x20
+#define SGMII_REMOTE_FAULT_DIS	BIT(8)
+
+/* Register to power up QPHY */
+#define SGMSYS_QPHY_PWR_STATE_CTRL 0xe8
+#define	SGMII_PHYA_PWD		BIT(4)
+
 struct mtk_rx_dma {
 	unsigned int rxd1;
 	unsigned int rxd2;
@@ -437,15 +461,31 @@ enum mtk_tx_flags {
 enum mtk_clks_map {
 	MTK_CLK_ETHIF,
 	MTK_CLK_ESW,
+	MTK_CLK_GP0,
 	MTK_CLK_GP1,
 	MTK_CLK_GP2,
 	MTK_CLK_TRGPLL,
+	MTK_CLK_SGMII_TX_250M,
+	MTK_CLK_SGMII_RX_250M,
+	MTK_CLK_SGMII_CDR_REF,
+	MTK_CLK_SGMII_CDR_FB,
+	MTK_CLK_SGMII_CK,
+	MTK_CLK_ETH2PLL,
 	MTK_CLK_MAX
 };
 
 #define MT7623_CLKS_BITMAP	(BIT(MTK_CLK_ETHIF) | BIT(MTK_CLK_ESW) |  \
 				 BIT(MTK_CLK_GP1) | BIT(MTK_CLK_GP2) | \
 				 BIT(MTK_CLK_TRGPLL))
+#define MT7622_CLKS_BITMAP	(BIT(MTK_CLK_ETHIF) | BIT(MTK_CLK_ESW) |  \
+				 BIT(MTK_CLK_GP0) | BIT(MTK_CLK_GP1) | \
+				 BIT(MTK_CLK_GP2) | \
+				 BIT(MTK_CLK_SGMII_TX_250M) | \
+				 BIT(MTK_CLK_SGMII_RX_250M) | \
+				 BIT(MTK_CLK_SGMII_CDR_REF) | \
+				 BIT(MTK_CLK_SGMII_CDR_FB) | \
+				 BIT(MTK_CLK_SGMII_CK) | \
+				 BIT(MTK_CLK_ETH2PLL))
 enum mtk_dev_state {
 	MTK_HW_INIT,
 	MTK_RESETTING
@@ -516,9 +556,16 @@ struct mtk_rx_ring {
 
 #define MTK_TRGMII			BIT(0)
 #define MTK_GMAC1_TRGMII		(BIT(1) | MTK_TRGMII)
+#define MTK_ESW				BIT(4)
+#define MTK_GMAC1_ESW			(BIT(5) | MTK_ESW)
+#define MTK_SGMII			BIT(8)
+#define MTK_GMAC1_SGMII			(BIT(9) | MTK_SGMII)
+#define MTK_GMAC2_SGMII			(BIT(10) | MTK_SGMII)
+#define MTK_DUAL_GMAC_SHARED_SGMII	(BIT(11) | MTK_GMAC1_SGMII | \
+					 MTK_GMAC2_SGMII)
 #define MTK_HAS_CAPS(caps, _x)		(((caps) & (_x)) == (_x))
 
-/* struct mtk_soc_data -	This is the structure holding all differences
+/* struct mtk_eth_data -	This is the structure holding all differences
  *				among various plaforms
  * @caps			Flags shown the extra capability for the SoC
  * @required_clks		Flags shown the bitmap for required clocks on
@@ -547,6 +594,8 @@ struct mtk_soc_data {
  * @msg_enable:		Ethtool msg level
  * @ethsys:		The register map pointing at the range used to setup
  *			MII modes
+ * @sgmiisys:		The register map pointing at the range used to setup
+ *			SGMII modes
  * @pctl:		The register map pointing at the range used to setup
  *			GMAC port drive/slew values
  * @dma_refcnt:		track how many netdevs are using the DMA engine
@@ -560,7 +609,7 @@ struct mtk_soc_data {
  * @clks:		clock array for all clocks required
  * @mii_bus:		If there is a bus we need to create an instance for it
  * @pending_work:	The workqueue used to reset the dma ring
- * @state		Initialization and runtime state of the device
+ * @state:		Initialization and runtime state of the device
  * @soc:		Holding specific data among vaious SoCs
  */
 
@@ -577,6 +626,7 @@ struct mtk_eth {
 	u32				msg_enable;
 	unsigned long			sysclk;
 	struct regmap			*ethsys;
+	struct regmap			*sgmiisys;
 	struct regmap			*pctl;
 	u32				chip_id;
 	bool				hwlro;
-- 
2.7.4
