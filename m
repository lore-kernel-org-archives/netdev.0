From: <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 2/4] net-next: mediatek: add platform data to adapt
 into various hardware
Date: Wed, 12 Jul 2017 11:37:43 +0800
Message-ID: <401e9fa04ea4759c936fa5af11bb2b5c97ef14f0.1499829241.git.sean.wang@mediatek.com>
References: <cover.1499829241.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, Sean
 Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <cover.1499829241.git.sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>

This patch is the preparation patch in order to adapt into various
hardware through adding platform data which holds specific characteristics
among MediaTek SoCs and introducing the unified clock handler for those
distinct clock requirements depending on different features such as
TRGMII and SGMII getting support on the target SoC. And finally, add
enhancement with given the generic description for Kconfig and remove the
unnecessary machine type dependency in Makefile.

Signed-off-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/Kconfig       |  6 +--
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 71 ++++++++++++++++++++++++-----
 drivers/net/ethernet/mediatek/mtk_eth_soc.h | 23 +++++++++-
 3 files changed, 85 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/Kconfig b/drivers/net/ethernet/mediatek/Kconfig
index 698bb89..f9149d2 100644
--- a/drivers/net/ethernet/mediatek/Kconfig
+++ b/drivers/net/ethernet/mediatek/Kconfig
@@ -7,11 +7,11 @@ config NET_VENDOR_MEDIATEK
 if NET_VENDOR_MEDIATEK
 
 config NET_MEDIATEK_SOC
-	tristate "MediaTek MT7623 Gigabit ethernet support"
-	depends on NET_VENDOR_MEDIATEK && (MACH_MT7623 || MACH_MT2701)
+	tristate "MediaTek SoC Gigabit Ethernet support"
+	depends on NET_VENDOR_MEDIATEK
 	select PHYLIB
 	---help---
 	  This driver supports the gigabit ethernet MACs in the
-	  MediaTek MT2701/MT7623 chipset family.
+	  MediaTek SoC family.
 
 endif #NET_VENDOR_MEDIATEK
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index b8068ce..51ca79f 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -184,7 +184,8 @@ static void mtk_phy_link_adjust(struct net_device *dev)
 		break;
 	};
 
-	if (mac->id == 0 && !mac->trgmii)
+	if (MTK_HAS_CAPS(mac->hw->soc->caps, MTK_GMAC1_TRGMII) &&
+	    !mac->id && !mac->trgmii)
 		mtk_gmac0_rgmii_adjust(mac->hw, dev->phydev->speed);
 
 	if (dev->phydev->link)
@@ -1837,6 +1838,39 @@ static void ethsys_reset(struct mtk_eth *eth, u32 reset_bits)
 	mdelay(10);
 }
 
+static void mtk_clk_disable(struct mtk_eth *eth)
+{
+	int clk;
+
+	for (clk = MTK_CLK_MAX - 1; clk >= 0; clk--) {
+		if (eth->clks[clk])
+			clk_disable_unprepare(eth->clks[clk]);
+	}
+}
+
+static int mtk_clk_enable(struct mtk_eth *eth)
+{
+	int clk, ret;
+
+	for (clk = 0; clk < MTK_CLK_MAX ; clk++) {
+		if (eth->clks[clk]) {
+			ret = clk_prepare_enable(eth->clks[clk]);
+			if (ret)
+				goto err_disable_clks;
+		}
+	}
+
+	return 0;
+
+err_disable_clks:
+	while (--clk >= 0) {
+		if (eth->clks[clk])
+			clk_disable_unprepare(eth->clks[clk]);
+	}
+
+	return ret;
+}
+
 static int mtk_hw_init(struct mtk_eth *eth)
 {
 	int i, val;
@@ -1847,10 +1881,8 @@ static int mtk_hw_init(struct mtk_eth *eth)
 	pm_runtime_enable(eth->dev);
 	pm_runtime_get_sync(eth->dev);
 
-	clk_prepare_enable(eth->clks[MTK_CLK_ETHIF]);
-	clk_prepare_enable(eth->clks[MTK_CLK_ESW]);
-	clk_prepare_enable(eth->clks[MTK_CLK_GP1]);
-	clk_prepare_enable(eth->clks[MTK_CLK_GP2]);
+	mtk_clk_enable(eth);
+
 	ethsys_reset(eth, RSTCTRL_FE);
 	ethsys_reset(eth, RSTCTRL_PPE);
 
@@ -1925,10 +1957,7 @@ static int mtk_hw_deinit(struct mtk_eth *eth)
 	if (!test_and_clear_bit(MTK_HW_INIT, &eth->state))
 		return 0;
 
-	clk_disable_unprepare(eth->clks[MTK_CLK_GP2]);
-	clk_disable_unprepare(eth->clks[MTK_CLK_GP1]);
-	clk_disable_unprepare(eth->clks[MTK_CLK_ESW]);
-	clk_disable_unprepare(eth->clks[MTK_CLK_ETHIF]);
+	mtk_clk_disable(eth);
 
 	pm_runtime_put_sync(eth->dev);
 	pm_runtime_disable(eth->dev);
@@ -2406,6 +2435,7 @@ static int mtk_probe(struct platform_device *pdev)
 {
 	struct resource *res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	struct device_node *mac_np;
+	const struct of_device_id *match;
 	struct mtk_eth *eth;
 	int err;
 	int i;
@@ -2414,6 +2444,9 @@ static int mtk_probe(struct platform_device *pdev)
 	if (!eth)
 		return -ENOMEM;
 
+	match = of_match_device(of_mtk_match, &pdev->dev);
+	eth->soc = (struct mtk_soc_data *)match->data;
+
 	eth->dev = &pdev->dev;
 	eth->base = devm_ioremap_resource(&pdev->dev, res);
 	if (IS_ERR(eth->base))
@@ -2450,7 +2483,12 @@ static int mtk_probe(struct platform_device *pdev)
 		if (IS_ERR(eth->clks[i])) {
 			if (PTR_ERR(eth->clks[i]) == -EPROBE_DEFER)
 				return -EPROBE_DEFER;
-			return -ENODEV;
+			if (eth->soc->required_clks & BIT(i)) {
+				dev_err(&pdev->dev, "clock %s not found\n",
+					mtk_clks_source_name[i]);
+				return -EINVAL;
+			}
+			eth->clks[i] = NULL;
 		}
 	}
 
@@ -2553,8 +2591,19 @@ static int mtk_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static const struct mtk_soc_data mt2701_data = {
+	.caps = MTK_GMAC1_TRGMII,
+	.required_clks = MT7623_CLKS_BITMAP
+};
+
+static const struct mtk_soc_data mt7623_data = {
+	.caps = MTK_GMAC1_TRGMII,
+	.required_clks = MT7623_CLKS_BITMAP
+};
+
 const struct of_device_id of_mtk_match[] = {
-	{ .compatible = "mediatek,mt2701-eth" },
+	{ .compatible = "mediatek,mt2701-eth", .data = &mt2701_data},
+	{ .compatible = "mediatek,mt7623-eth", .data = &mt7623_data},
 	{},
 };
 MODULE_DEVICE_TABLE(of, of_mtk_match);
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 5868a09..8ade23df 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -443,6 +443,9 @@ enum mtk_clks_map {
 	MTK_CLK_MAX
 };
 
+#define MT7623_CLKS_BITMAP	(BIT(MTK_CLK_ETHIF) | BIT(MTK_CLK_ESW) |  \
+				 BIT(MTK_CLK_GP1) | BIT(MTK_CLK_GP2) | \
+				 BIT(MTK_CLK_TRGPLL))
 enum mtk_dev_state {
 	MTK_HW_INIT,
 	MTK_RESETTING
@@ -511,6 +514,21 @@ struct mtk_rx_ring {
 	u32 crx_idx_reg;
 };
 
+#define MTK_TRGMII			BIT(0)
+#define MTK_GMAC1_TRGMII		(BIT(1) | MTK_TRGMII)
+#define MTK_HAS_CAPS(caps, _x)		(((caps) & (_x)) == (_x))
+
+/* struct mtk_soc_data -	This is the structure holding all differences
+ *				among various plaforms
+ * @caps			Flags shown the extra capability for the SoC
+ * @required_clks		Flags shown the bitmap for required clocks on
+ *				the target SoC
+ */
+struct mtk_soc_data {
+	u32		caps;
+	u32		required_clks;
+};
+
 /* currently no SoC has more than 2 macs */
 #define MTK_MAX_DEVS			2
 
@@ -542,7 +560,8 @@ struct mtk_rx_ring {
  * @clks:		clock array for all clocks required
  * @mii_bus:		If there is a bus we need to create an instance for it
  * @pending_work:	The workqueue used to reset the dma ring
- * @state               Initialization and runtime state of the device.
+ * @state		Initialization and runtime state of the device
+ * @soc:		Holding specific data among vaious SoCs
  */
 
 struct mtk_eth {
@@ -574,6 +593,8 @@ struct mtk_eth {
 	struct mii_bus			*mii_bus;
 	struct work_struct		pending_work;
 	unsigned long			state;
+
+	const struct mtk_soc_data	*soc;
 };
 
 /* struct mtk_mac -	the structure that holds the info about the MACs of the
-- 
2.7.4
