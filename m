From: Nelson Chang <nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next v3 2/3] net: ethernet: mediatek: get hw lro
 capability by the chip id instead of by the dtsi
Date: Thu, 6 Oct 2016 19:44:02 +0800
Message-ID: <1475754243-12557-3-git-send-email-nelson.chang@mediatek.com>
References: <1475754243-12557-1-git-send-email-nelson.chang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 nelsonch.tw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Nelson Chang <nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
To: <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1475754243-12557-1-git-send-email-nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
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

Because hw lro started to be supported from MT7623, the proper way to check if
the feature is capable is to judge by the chip id instead of by the dtsi.

Signed-off-by: Nelson Chang <nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 14 ++++++++++++--
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |  1 +
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 0c67ab1..4a62ffd 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -2348,6 +2348,16 @@ static int mtk_get_chip_id(struct mtk_eth *eth, u32 *chip_id)
 	return 0;
 }
 
+static bool mtk_is_hwlro_supported(struct mtk_eth *eth)
+{
+	switch (eth->chip_id) {
+	case MT7623_ETH:
+		return true;
+	}
+
+	return false;
+}
+
 static int mtk_probe(struct platform_device *pdev)
 {
 	struct resource *res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -2387,8 +2397,6 @@ static int mtk_probe(struct platform_device *pdev)
 		return PTR_ERR(eth->pctl);
 	}
 
-	eth->hwlro = of_property_read_bool(pdev->dev.of_node, "mediatek,hwlro");
-
 	for (i = 0; i < 3; i++) {
 		eth->irq[i] = platform_get_irq(pdev, i);
 		if (eth->irq[i] < 0) {
@@ -2417,6 +2425,8 @@ static int mtk_probe(struct platform_device *pdev)
 	if (err)
 		return err;
 
+	eth->hwlro = mtk_is_hwlro_supported(eth);
+
 	for_each_child_of_node(pdev->dev.of_node, mac_np) {
 		if (!of_device_is_compatible(mac_np,
 					     "mediatek,eth-mac"))
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index a5b422b..99b1c8e 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -345,6 +345,7 @@
 /* ethernet subsystem chip id register */
 #define ETHSYS_CHIPID0_3	0x0
 #define ETHSYS_CHIPID4_7	0x4
+#define MT7623_ETH		7623
 
 /* ethernet subsystem config register */
 #define ETHSYS_SYSCFG0		0x14
-- 
1.9.1
