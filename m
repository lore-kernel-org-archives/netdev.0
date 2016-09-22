From: <sean.wang@mediatek.com>
Subject: [PATCH net-next v2 2/3] net: ethernet: mediatek: add support for GMAC0 connecting with external PHY through TRGMII
Date: Thu, 22 Sep 2016 10:33:55 +0800
Message-ID: <1474511636-11644-3-git-send-email-sean.wang@mediatek.com>
References: <1474511636-11644-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <andrew@lunn.ch>,
        <f.fainelli@gmail.com>, <keyhaede@gmail.com>, <objelf@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474511636-11644-1-git-send-email-sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang@mediatek.com>

Changing dynamically source clock, TX/RX delay and interface mode
used by TRGMII hardware module inside PHY capability polling routine
for adapting to the various speed of RGMII used by external PHY for
GMAC0.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 32 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/mediatek/mtk_eth_soc.h | 31 +++++++++++++++++++++++++++-
 2 files changed, 61 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 827f4bd..73c7904 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -52,7 +52,7 @@ static const struct mtk_ethtool_stats {
 };
 
 static const char * const mtk_clks_source_name[] = {
-	"ethif", "esw", "gp1", "gp2"
+	"ethif", "esw", "gp1", "gp2", "trgpll"
 };
 
 void mtk_w32(struct mtk_eth *eth, u32 val, unsigned reg)
@@ -135,6 +135,33 @@ static int mtk_mdio_read(struct mii_bus *bus, int phy_addr, int phy_reg)
 	return _mtk_mdio_read(eth, phy_addr, phy_reg);
 }
 
+static void mtk_gmac0_rgmii_adjust(struct mtk_eth *eth, int speed)
+{
+	u32 val;
+	int ret;
+
+	val = (speed == SPEED_1000) ?
+		INTF_MODE_RGMII_1000 : INTF_MODE_RGMII_10_100;
+	mtk_w32(eth, val, INTF_MODE);
+
+	regmap_update_bits(eth->ethsys, ETHSYS_CLKCFG0,
+			   ETHSYS_TRGMII_CLK_SEL362_5,
+			   ETHSYS_TRGMII_CLK_SEL362_5);
+
+	val = (speed == SPEED_1000) ? 250000000 : 500000000;
+	ret = clk_set_rate(eth->clks[MTK_CLK_TRGPLL], val);
+	if (ret)
+		dev_err(eth->dev, "Failed to set trgmii pll: %d\n", ret);
+
+	val = (speed == SPEED_1000) ?
+		RCK_CTRL_RGMII_1000 : RCK_CTRL_RGMII_10_100;
+	mtk_w32(eth, val, TRGMII_RCK_CTRL);
+
+	val = (speed == SPEED_1000) ?
+		TCK_CTRL_RGMII_1000 : TCK_CTRL_RGMII_10_100;
+	mtk_w32(eth, val, TRGMII_TCK_CTRL);
+}
+
 static void mtk_phy_link_adjust(struct net_device *dev)
 {
 	struct mtk_mac *mac = netdev_priv(dev);
@@ -157,6 +184,9 @@ static void mtk_phy_link_adjust(struct net_device *dev)
 		break;
 	};
 
+	if (mac->id == 0 && !mac->trgmii)
+		mtk_gmac0_rgmii_adjust(mac->hw, mac->phy_dev->speed);
+
 	if (mac->phy_dev->link)
 		mcr |= MAC_MCR_FORCE_LINK;
 
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index e3b9525..e521156 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -313,6 +313,30 @@
 				 MAC_MCR_FORCE_TX_FC | MAC_MCR_SPEED_1000 | \
 				 MAC_MCR_FORCE_DPX | MAC_MCR_FORCE_LINK)
 
+/* TRGMII RXC control register */
+#define TRGMII_RCK_CTRL		0x10300
+#define DQSI0(x)		((x << 0) & GENMASK(6, 0))
+#define DQSI1(x)		((x << 8) & GENMASK(14, 8))
+#define RXCTL_DMWTLAT(x)	((x << 16) & GENMASK(18, 16))
+#define RXC_DQSISEL		BIT(30)
+#define RCK_CTRL_RGMII_1000	(RXC_DQSISEL | RXCTL_DMWTLAT(2) | DQSI1(16))
+#define RCK_CTRL_RGMII_10_100	RXCTL_DMWTLAT(2)
+
+/* TRGMII RXC control register */
+#define TRGMII_TCK_CTRL		0x10340
+#define TXCTL_DMWTLAT(x)	((x << 16) & GENMASK(18, 16))
+#define TXC_INV			BIT(30)
+#define TCK_CTRL_RGMII_1000	TXCTL_DMWTLAT(2)
+#define TCK_CTRL_RGMII_10_100	(TXC_INV | TXCTL_DMWTLAT(2))
+
+/* TRGMII Interface mode register */
+#define INTF_MODE		0x10390
+#define TRGMII_INTF_DIS		BIT(0)
+#define TRGMII_MODE		BIT(1)
+#define TRGMII_CENTRAL_ALIGNED	BIT(2)
+#define INTF_MODE_RGMII_1000    (TRGMII_MODE | TRGMII_CENTRAL_ALIGNED)
+#define INTF_MODE_RGMII_10_100  0
+
 /* GPIO port control registers for GMAC 2*/
 #define GPIO_OD33_CTRL8		0x4c0
 #define GPIO_BIAS_CTRL		0xed0
@@ -323,7 +347,11 @@
 #define SYSCFG0_GE_MASK		0x3
 #define SYSCFG0_GE_MODE(x, y)	(x << (12 + (y * 2)))
 
-/*ethernet reset control register*/
+/* ethernet subsystem clock register */
+#define ETHSYS_CLKCFG0		0x2c
+#define ETHSYS_TRGMII_CLK_SEL362_5	BIT(11)
+
+/* ethernet reset control register */
 #define ETHSYS_RSTCTRL		0x34
 #define RSTCTRL_FE		BIT(6)
 #define RSTCTRL_PPE		BIT(31)
@@ -389,6 +417,7 @@ enum mtk_clks_map {
 	MTK_CLK_ESW,
 	MTK_CLK_GP1,
 	MTK_CLK_GP2,
+	MTK_CLK_TRGPLL,
 	MTK_CLK_MAX
 };
 
-- 
1.9.1
