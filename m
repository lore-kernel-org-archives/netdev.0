From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 3/6] wcn36xx: Split mmio space into explicit regions
Date: Sun, 19 Jun 2016 23:19:45 -0700
Message-ID: <1466403588-7041-3-git-send-email-bjorn.andersson@linaro.org>
References: <1466403588-7041-1-git-send-email-bjorn.andersson@linaro.org>
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-msm@vger.kernel.org
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35648 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380AbcFTGTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 02:19:54 -0400
Received: by mail-pf0-f181.google.com with SMTP id c2so50915947pfa.2
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2016 23:19:54 -0700 (PDT)
In-Reply-To: <1466403588-7041-1-git-send-email-bjorn.andersson@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split the wcnss mmio space into explicit regions for ccu and dxe and
acquire these from the node referenced by the qcom,mmio phandle.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/dxe.c     | 26 ++++++++-------
 drivers/net/wireless/ath/wcn36xx/dxe.h     |  6 ++--
 drivers/net/wireless/ath/wcn36xx/main.c    | 51 +++++++++++++++++++++++-------
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h |  3 +-
 4 files changed, 59 insertions(+), 27 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/dxe.c b/drivers/net/wireless/ath/wcn36xx/dxe.c
index 8643801f31b6..a8ff45400982 100644
--- a/drivers/net/wireless/ath/wcn36xx/dxe.c
+++ b/drivers/net/wireless/ath/wcn36xx/dxe.c
@@ -35,26 +35,27 @@ void *wcn36xx_dxe_get_next_bd(struct wcn36xx *wcn, bool is_low)
 	return ch->head_blk_ctl->bd_cpu_addr;
 }
 
+static void wcn36xx_ccu_write_register(struct wcn36xx *wcn, int addr, int data)
+{
+	wcn36xx_dbg(WCN36XX_DBG_DXE,
+		    "wcn36xx_ccu_write_register: addr=%x, data=%x\n",
+		    addr, data);
+
+	writel(data, wcn->ccu_base + addr);
+}
+
 static void wcn36xx_dxe_write_register(struct wcn36xx *wcn, int addr, int data)
 {
 	wcn36xx_dbg(WCN36XX_DBG_DXE,
 		    "wcn36xx_dxe_write_register: addr=%x, data=%x\n",
 		    addr, data);
 
-	writel(data, wcn->mmio + addr);
+	writel(data, wcn->dxe_base + addr);
 }
 
-#define wcn36xx_dxe_write_register_x(wcn, reg, reg_data)		 \
-do {									 \
-	if (wcn->chip_version == WCN36XX_CHIP_3680)			 \
-		wcn36xx_dxe_write_register(wcn, reg ## _3680, reg_data); \
-	else								 \
-		wcn36xx_dxe_write_register(wcn, reg ## _3660, reg_data); \
-} while (0)								 \
-
 static void wcn36xx_dxe_read_register(struct wcn36xx *wcn, int addr, int *data)
 {
-	*data = readl(wcn->mmio + addr);
+	*data = readl(wcn->dxe_base + addr);
 
 	wcn36xx_dbg(WCN36XX_DBG_DXE,
 		    "wcn36xx_dxe_read_register: addr=%x, data=%x\n",
@@ -703,7 +704,10 @@ int wcn36xx_dxe_init(struct wcn36xx *wcn)
 
 	/* Setting interrupt path */
 	reg_data = WCN36XX_DXE_CCU_INT;
-	wcn36xx_dxe_write_register_x(wcn, WCN36XX_DXE_REG_CCU_INT, reg_data);
+	if (wcn->chip_version == WCN36XX_CHIP_3680)
+		wcn36xx_ccu_write_register(wcn, WCN36XX_DXE_REG_CCU_INT_3680, reg_data);
+	else
+		wcn36xx_ccu_write_register(wcn, WCN36XX_DXE_REG_CCU_INT_3660, reg_data);
 
 	/***************************************/
 	/* Init descriptors for TX LOW channel */
diff --git a/drivers/net/wireless/ath/wcn36xx/dxe.h b/drivers/net/wireless/ath/wcn36xx/dxe.h
index 3eca4f9594f2..012b59f4f91b 100644
--- a/drivers/net/wireless/ath/wcn36xx/dxe.h
+++ b/drivers/net/wireless/ath/wcn36xx/dxe.h
@@ -28,11 +28,11 @@ H2H_TEST_RX_TX = DMA2
 */
 
 /* DXE registers */
-#define WCN36XX_DXE_MEM_REG			0x202000
+#define WCN36XX_DXE_MEM_REG			0
 
 #define WCN36XX_DXE_CCU_INT			0xA0011
-#define WCN36XX_DXE_REG_CCU_INT_3660		0x200b10
-#define WCN36XX_DXE_REG_CCU_INT_3680		0x2050dc
+#define WCN36XX_DXE_REG_CCU_INT_3660		0x310
+#define WCN36XX_DXE_REG_CCU_INT_3680		0x10dc
 
 /* TODO This must calculated properly but not hardcoded */
 #define WCN36XX_DXE_CTRL_TX_L			0x328a44
diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index a920d7020148..8146eeba4458 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -19,6 +19,8 @@
 #include <linux/module.h>
 #include <linux/firmware.h>
 #include <linux/platform_device.h>
+#include <linux/of_address.h>
+#include <linux/of_device.h>
 #include "wcn36xx.h"
 
 unsigned int wcn36xx_dbg_mask;
@@ -1064,7 +1066,11 @@ static int wcn36xx_init_ieee80211(struct wcn36xx *wcn)
 static int wcn36xx_platform_get_resources(struct wcn36xx *wcn,
 					  struct platform_device *pdev)
 {
+	struct device_node *mmio_node;
 	struct resource *res;
+	int index;
+	int ret;
+
 	/* Set TX IRQ */
 	res = platform_get_resource_byname(pdev, IORESOURCE_IRQ,
 					   "wcnss_wlantx_irq");
@@ -1083,19 +1089,38 @@ static int wcn36xx_platform_get_resources(struct wcn36xx *wcn,
 	}
 	wcn->rx_irq = res->start;
 
-	/* Map the memory */
-	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
-						 "wcnss_mmio");
-	if (!res) {
-		wcn36xx_err("failed to get mmio\n");
-		return -ENOENT;
+	mmio_node = of_parse_phandle(pdev->dev.parent->of_node, "qcom,mmio", 0);
+	if (!mmio_node) {
+		wcn36xx_err("failed to acquire qcom,mmio reference\n");
+		return -EINVAL;
+	}
+
+	/* Map the CCU memory */
+	index = of_property_match_string(mmio_node, "reg-names", "ccu");
+	wcn->ccu_base = of_iomap(mmio_node, index);
+	if (!wcn->ccu_base) {
+		wcn36xx_err("failed to map ccu memory\n");
+		ret = -ENOMEM;
+		goto put_mmio_node;
 	}
-	wcn->mmio = ioremap(res->start, resource_size(res));
-	if (!wcn->mmio) {
-		wcn36xx_err("failed to map io memory\n");
-		return -ENOMEM;
+
+	/* Map the DXE memory */
+	index = of_property_match_string(mmio_node, "reg-names", "dxe");
+	wcn->dxe_base = of_iomap(mmio_node, index);
+	if (!wcn->dxe_base) {
+		wcn36xx_err("failed to map dxe memory\n");
+		ret = -ENOMEM;
+		goto unmap_ccu;
 	}
+
+	of_node_put(mmio_node);
 	return 0;
+
+unmap_ccu:
+	iounmap(wcn->ccu_base);
+put_mmio_node:
+	of_node_put(mmio_node);
+	return ret;
 }
 
 static int wcn36xx_probe(struct platform_device *pdev)
@@ -1138,7 +1163,8 @@ static int wcn36xx_probe(struct platform_device *pdev)
 	return 0;
 
 out_unmap:
-	iounmap(wcn->mmio);
+	iounmap(wcn->ccu_base);
+	iounmap(wcn->dxe_base);
 out_wq:
 	ieee80211_free_hw(hw);
 out_err:
@@ -1154,7 +1180,8 @@ static int wcn36xx_remove(struct platform_device *pdev)
 	mutex_destroy(&wcn->hal_mutex);
 
 	ieee80211_unregister_hw(hw);
-	iounmap(wcn->mmio);
+	iounmap(wcn->dxe_base);
+	iounmap(wcn->ccu_base);
 	ieee80211_free_hw(hw);
 
 	return 0;
diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
index f6d8d14f13d1..845f2446a1b5 100644
--- a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
+++ b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
@@ -202,7 +202,8 @@ struct wcn36xx {
 	/* IRQs */
 	int			tx_irq;
 	int			rx_irq;
-	void __iomem		*mmio;
+	void __iomem		*ccu_base;
+	void __iomem		*dxe_base;
 
 	struct wcn36xx_platform_ctrl_ops *ctrl_ops;
 	/*
-- 
2.5.0
