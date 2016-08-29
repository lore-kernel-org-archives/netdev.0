From: <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net v2 2/9] net: ethernet: mediatek: fix incorrect return
 value of devm_clk_get with EPROBE_DEFER
Date: Mon, 29 Aug 2016 13:03:16 +0800
Message-ID: <1472447003-30726-3-git-send-email-sean.wang@mediatek.com>
References: <1472447003-30726-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1472447003-30726-1-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
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

1) If the return value of devm_clk_get is EPROBE_DEFER, we should
defer probing the driver. The change is verified and works based
on 4.8-rc1 staying with the latest clk-next code for MT7623.
2) Changing with the usage of loops to work out if all clocks are
fine

Signed-off-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 39 ++++++++++++++++-------------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h | 22 ++++++++++------
 2 files changed, 36 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 6e4a6ca..ad4865c 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -50,6 +50,10 @@ static const struct mtk_ethtool_stats {
 	MTK_ETHTOOL_STAT(rx_flow_control_packets),
 };
 
+static const char * const mtk_clks_source_name[] = {
+	"ethif", "esw", "gp1", "gp2"
+};
+
 void mtk_w32(struct mtk_eth *eth, u32 val, unsigned reg)
 {
 	__raw_writel(val, eth->base + reg);
@@ -1811,6 +1815,7 @@ static int mtk_probe(struct platform_device *pdev)
 	if (!eth)
 		return -ENOMEM;
 
+	eth->dev = &pdev->dev;
 	eth->base = devm_ioremap_resource(&pdev->dev, res);
 	if (IS_ERR(eth->base))
 		return PTR_ERR(eth->base);
@@ -1845,21 +1850,21 @@ static int mtk_probe(struct platform_device *pdev)
 			return -ENXIO;
 		}
 	}
+	for (i = 0; i < ARRAY_SIZE(eth->clks); i++) {
+		eth->clks[i] = devm_clk_get(eth->dev,
+					    mtk_clks_source_name[i]);
+		if (IS_ERR(eth->clks[i])) {
+			if (PTR_ERR(eth->clks[i]) == -EPROBE_DEFER)
+				return -EPROBE_DEFER;
+			return -ENODEV;
+		}
+	}
 
-	eth->clk_ethif = devm_clk_get(&pdev->dev, "ethif");
-	eth->clk_esw = devm_clk_get(&pdev->dev, "esw");
-	eth->clk_gp1 = devm_clk_get(&pdev->dev, "gp1");
-	eth->clk_gp2 = devm_clk_get(&pdev->dev, "gp2");
-	if (IS_ERR(eth->clk_esw) || IS_ERR(eth->clk_gp1) ||
-	    IS_ERR(eth->clk_gp2) || IS_ERR(eth->clk_ethif))
-		return -ENODEV;
-
-	clk_prepare_enable(eth->clk_ethif);
-	clk_prepare_enable(eth->clk_esw);
-	clk_prepare_enable(eth->clk_gp1);
-	clk_prepare_enable(eth->clk_gp2);
+	clk_prepare_enable(eth->clks[MTK_CLK_ETHIF]);
+	clk_prepare_enable(eth->clks[MTK_CLK_ESW]);
+	clk_prepare_enable(eth->clks[MTK_CLK_GP1]);
+	clk_prepare_enable(eth->clks[MTK_CLK_GP2]);
 
-	eth->dev = &pdev->dev;
 	eth->msg_enable = netif_msg_init(mtk_msg_level, MTK_DEFAULT_MSG_ENABLE);
 	INIT_WORK(&eth->pending_work, mtk_pending_work);
 
@@ -1902,10 +1907,10 @@ static int mtk_remove(struct platform_device *pdev)
 {
 	struct mtk_eth *eth = platform_get_drvdata(pdev);
 
-	clk_disable_unprepare(eth->clk_ethif);
-	clk_disable_unprepare(eth->clk_esw);
-	clk_disable_unprepare(eth->clk_gp1);
-	clk_disable_unprepare(eth->clk_gp2);
+	clk_disable_unprepare(eth->clks[MTK_CLK_GP1]);
+	clk_disable_unprepare(eth->clks[MTK_CLK_GP2]);
+	clk_disable_unprepare(eth->clks[MTK_CLK_ESW]);
+	clk_disable_unprepare(eth->clks[MTK_CLK_ETHIF]);
 
 	netif_napi_del(&eth->tx_napi);
 	netif_napi_del(&eth->rx_napi);
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index f82e3ac..6e1ade7 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -290,6 +290,17 @@ enum mtk_tx_flags {
 	MTK_TX_FLAGS_PAGE0	= 0x02,
 };
 
+/* This enum allows us to identify how the clock is defined on the array of the
+ * clock in the order
+ */
+enum mtk_clks_map {
+	MTK_CLK_ETHIF,
+	MTK_CLK_ESW,
+	MTK_CLK_GP1,
+	MTK_CLK_GP2,
+	MTK_CLK_MAX
+};
+
 /* struct mtk_tx_buf -	This struct holds the pointers to the memory pointed at
  *			by the TX descriptor	s
  * @skb:		The SKB pointer of the packet being sent
@@ -370,10 +381,7 @@ struct mtk_rx_ring {
  * @scratch_ring:	Newer SoCs need memory for a second HW managed TX ring
  * @phy_scratch_ring:	physical address of scratch_ring
  * @scratch_head:	The scratch memory that scratch_ring points to.
- * @clk_ethif:		The ethif clock
- * @clk_esw:		The switch clock
- * @clk_gp1:		The gmac1 clock
- * @clk_gp2:		The gmac2 clock
+ * @clks:		clock array for all clocks required
  * @mii_bus:		If there is a bus we need to create an instance for it
  * @pending_work:	The workqueue used to reset the dma ring
  */
@@ -400,10 +408,8 @@ struct mtk_eth {
 	struct mtk_tx_dma		*scratch_ring;
 	dma_addr_t			phy_scratch_ring;
 	void				*scratch_head;
-	struct clk			*clk_ethif;
-	struct clk			*clk_esw;
-	struct clk			*clk_gp1;
-	struct clk			*clk_gp2;
+	struct clk			*clks[MTK_CLK_MAX];
+
 	struct mii_bus			*mii_bus;
 	struct work_struct		pending_work;
 };
-- 
1.9.1
