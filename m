From: Nelson Chang <nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next v3 1/3] net: ethernet: mediatek: get the chip id by
 ETHDMASYS registers
Date: Thu, 6 Oct 2016 19:44:01 +0800
Message-ID: <1475754243-12557-2-git-send-email-nelson.chang@mediatek.com>
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

The driver gets the chip id by ETHSYS_CHIPID0_3/ETHSYS_CHIPID4_7 registers
in mtk_probe().

Signed-off-by: Nelson Chang <nelson.chang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 29 +++++++++++++++++++++++++++++
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |  5 +++++
 2 files changed, 34 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index ad4ab97..0c67ab1 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -2323,6 +2323,31 @@ free_netdev:
 	return err;
 }
 
+static int mtk_get_chip_id(struct mtk_eth *eth, u32 *chip_id)
+{
+	u32 val[2], id[4];
+
+	regmap_read(eth->ethsys, ETHSYS_CHIPID0_3, &val[0]);
+	regmap_read(eth->ethsys, ETHSYS_CHIPID4_7, &val[1]);
+
+	id[3] = ((val[0] >> 16) & 0xff) - '0';
+	id[2] = ((val[0] >> 24) & 0xff) - '0';
+	id[1] = (val[1] & 0xff) - '0';
+	id[0] = ((val[1] >> 8) & 0xff) - '0';
+
+	*chip_id = (id[3] * 1000) + (id[2] * 100) +
+		   (id[1] * 10) + id[0];
+
+	if (!(*chip_id)) {
+		dev_err(eth->dev, "failed to get chip id\n");
+		return -ENODEV;
+	}
+
+	dev_info(eth->dev, "chip id = %d\n", *chip_id);
+
+	return 0;
+}
+
 static int mtk_probe(struct platform_device *pdev)
 {
 	struct resource *res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -2388,6 +2413,10 @@ static int mtk_probe(struct platform_device *pdev)
 	if (err)
 		return err;
 
+	err = mtk_get_chip_id(eth, &eth->chip_id);
+	if (err)
+		return err;
+
 	for_each_child_of_node(pdev->dev.of_node, mac_np) {
 		if (!of_device_is_compatible(mac_np,
 					     "mediatek,eth-mac"))
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
index 3003195..a5b422b 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
@@ -342,6 +342,10 @@
 #define GPIO_BIAS_CTRL		0xed0
 #define GPIO_DRV_SEL10		0xf00
 
+/* ethernet subsystem chip id register */
+#define ETHSYS_CHIPID0_3	0x0
+#define ETHSYS_CHIPID4_7	0x4
+
 /* ethernet subsystem config register */
 #define ETHSYS_SYSCFG0		0x14
 #define SYSCFG0_GE_MASK		0x3
@@ -534,6 +538,7 @@ struct mtk_eth {
 	unsigned long			sysclk;
 	struct regmap			*ethsys;
 	struct regmap			*pctl;
+	u32				chip_id;
 	bool				hwlro;
 	atomic_t			dma_refcnt;
 	struct mtk_tx_ring		tx_ring;
-- 
1.9.1
