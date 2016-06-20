From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 5/6] wcn36xx: Transition driver to SMD client
Date: Sun, 19 Jun 2016 23:19:47 -0700
Message-ID: <1466403588-7041-5-git-send-email-bjorn.andersson@linaro.org>
References: <1466403588-7041-1-git-send-email-bjorn.andersson@linaro.org>
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-msm@vger.kernel.org
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1466403588-7041-1-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The wcn36xx wifi driver follows the life cycle of the WLAN_CTRL SMD
channel, as such it should be a SMD client. This patch makes this
transition, now that we have the necessary frameworks available.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---

This patch depends on the devicetree binding approved by Rob Herring [1] and
the addition of support in the wcnss_ctrl driver for probing sub-drivers in a
timely manner [2] - i.e. when the WCNSS core OS signals that it's booted.

These are both scheduled to be merged in v4.8

[1] https://patchwork.kernel.org/patch/9159621/
[2] https://git.kernel.org/cgit/linux/kernel/git/agross/linux.git/log/?h=for-next

 drivers/net/wireless/ath/wcn36xx/Kconfig   |  2 +-
 drivers/net/wireless/ath/wcn36xx/dxe.c     | 16 +++---
 drivers/net/wireless/ath/wcn36xx/main.c    | 79 ++++++++++++++++++++----------
 drivers/net/wireless/ath/wcn36xx/smd.c     | 29 +++++------
 drivers/net/wireless/ath/wcn36xx/smd.h     |  5 ++
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h | 21 +++-----
 6 files changed, 86 insertions(+), 66 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/Kconfig b/drivers/net/wireless/ath/wcn36xx/Kconfig
index 591ebaea8265..394fe5b77c90 100644
--- a/drivers/net/wireless/ath/wcn36xx/Kconfig
+++ b/drivers/net/wireless/ath/wcn36xx/Kconfig
@@ -1,6 +1,6 @@
 config WCN36XX
 	tristate "Qualcomm Atheros WCN3660/3680 support"
-	depends on MAC80211 && HAS_DMA
+	depends on MAC80211 && HAS_DMA && QCOM_SMD
 	---help---
 	  This module adds support for wireless adapters based on
 	  Qualcomm Atheros WCN3660 and WCN3680 mobile chipsets.
diff --git a/drivers/net/wireless/ath/wcn36xx/dxe.c b/drivers/net/wireless/ath/wcn36xx/dxe.c
index 231fd022f0f5..87dfdaf9044c 100644
--- a/drivers/net/wireless/ath/wcn36xx/dxe.c
+++ b/drivers/net/wireless/ath/wcn36xx/dxe.c
@@ -23,6 +23,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/interrupt.h>
+#include <linux/soc/qcom/smem_state.h>
 #include "wcn36xx.h"
 #include "txrx.h"
 
@@ -151,9 +152,12 @@ int wcn36xx_dxe_alloc_ctl_blks(struct wcn36xx *wcn)
 		goto out_err;
 
 	/* Initialize SMSM state  Clear TX Enable RING EMPTY STATE */
-	ret = wcn->ctrl_ops->smsm_change_state(
-		WCN36XX_SMSM_WLAN_TX_ENABLE,
-		WCN36XX_SMSM_WLAN_TX_RINGS_EMPTY);
+	ret = qcom_smem_state_update_bits(wcn->tx_enable_state,
+					  WCN36XX_SMSM_WLAN_TX_ENABLE |
+					  WCN36XX_SMSM_WLAN_TX_RINGS_EMPTY,
+					  WCN36XX_SMSM_WLAN_TX_RINGS_EMPTY);
+	if (ret)
+		goto out_err;
 
 	return 0;
 
@@ -678,9 +682,9 @@ int wcn36xx_dxe_tx_frame(struct wcn36xx *wcn,
 	 * notify chip about new frame through SMSM bus.
 	 */
 	if (is_low &&  vif_priv->pw_state == WCN36XX_BMPS) {
-		wcn->ctrl_ops->smsm_change_state(
-				  0,
-				  WCN36XX_SMSM_WLAN_TX_ENABLE);
+		qcom_smem_state_update_bits(wcn->tx_rings_empty_state,
+					    WCN36XX_SMSM_WLAN_TX_ENABLE,
+					    WCN36XX_SMSM_WLAN_TX_ENABLE);
 	} else {
 		/* indicate End Of Packet and generate interrupt on descriptor
 		 * done.
diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index e1d59da2ad20..3c2522b07c90 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -21,6 +21,10 @@
 #include <linux/platform_device.h>
 #include <linux/of_address.h>
 #include <linux/of_device.h>
+#include <linux/of_irq.h>
+#include <linux/soc/qcom/smd.h>
+#include <linux/soc/qcom/smem_state.h>
+#include <linux/soc/qcom/wcnss_ctrl.h>
 #include "wcn36xx.h"
 
 unsigned int wcn36xx_dbg_mask;
@@ -1058,8 +1062,7 @@ static int wcn36xx_platform_get_resources(struct wcn36xx *wcn,
 	int ret;
 
 	/* Set TX IRQ */
-	res = platform_get_resource_byname(pdev, IORESOURCE_IRQ,
-					   "wcnss_wlantx_irq");
+	res = platform_get_resource_byname(pdev, IORESOURCE_IRQ, "tx");
 	if (!res) {
 		wcn36xx_err("failed to get tx_irq\n");
 		return -ENOENT;
@@ -1067,14 +1070,29 @@ static int wcn36xx_platform_get_resources(struct wcn36xx *wcn,
 	wcn->tx_irq = res->start;
 
 	/* Set RX IRQ */
-	res = platform_get_resource_byname(pdev, IORESOURCE_IRQ,
-					   "wcnss_wlanrx_irq");
+	res = platform_get_resource_byname(pdev, IORESOURCE_IRQ, "rx");
 	if (!res) {
 		wcn36xx_err("failed to get rx_irq\n");
 		return -ENOENT;
 	}
 	wcn->rx_irq = res->start;
 
+	/* Acquire SMSM tx enable handle */
+	wcn->tx_enable_state = qcom_smem_state_get(&pdev->dev,
+			"tx-enable", &wcn->tx_enable_state_bit);
+	if (IS_ERR(wcn->tx_enable_state)) {
+		wcn36xx_err("failed to get tx-enable state\n");
+		return PTR_ERR(wcn->tx_enable_state);
+	}
+
+	/* Acquire SMSM tx rings empty handle */
+	wcn->tx_rings_empty_state = qcom_smem_state_get(&pdev->dev,
+			"tx-rings-empty", &wcn->tx_rings_empty_state_bit);
+	if (IS_ERR(wcn->tx_rings_empty_state)) {
+		wcn36xx_err("failed to get tx-rings-empty state\n");
+		return PTR_ERR(wcn->tx_rings_empty_state);
+	}
+
 	mmio_node = of_parse_phandle(pdev->dev.parent->of_node, "qcom,mmio", 0);
 	if (!mmio_node) {
 		wcn36xx_err("failed to acquire qcom,mmio reference\n");
@@ -1115,11 +1133,14 @@ static int wcn36xx_probe(struct platform_device *pdev)
 {
 	struct ieee80211_hw *hw;
 	struct wcn36xx *wcn;
+	void *wcnss;
 	int ret;
-	u8 addr[ETH_ALEN];
+	const u8 *addr;
 
 	wcn36xx_dbg(WCN36XX_DBG_MAC, "platform probe\n");
 
+	wcnss = dev_get_drvdata(pdev->dev.parent);
+
 	hw = ieee80211_alloc_hw(sizeof(struct wcn36xx), &wcn36xx_ops);
 	if (!hw) {
 		wcn36xx_err("failed to alloc hw\n");
@@ -1130,11 +1151,23 @@ static int wcn36xx_probe(struct platform_device *pdev)
 	wcn = hw->priv;
 	wcn->hw = hw;
 	wcn->dev = &pdev->dev;
-	wcn->ctrl_ops = pdev->dev.platform_data;
-
 	mutex_init(&wcn->hal_mutex);
 
-	if (!wcn->ctrl_ops->get_hw_mac(addr)) {
+	wcn->smd_channel = qcom_wcnss_open_channel(wcnss, "WLAN_CTRL", wcn36xx_smd_rsp_process);
+	if (IS_ERR(wcn->smd_channel)) {
+		wcn36xx_err("failed to open WLAN_CTRL channel\n");
+		ret = PTR_ERR(wcn->smd_channel);
+		goto out_wq;
+	}
+
+	qcom_smd_set_drvdata(wcn->smd_channel, hw);
+
+	addr = of_get_property(pdev->dev.of_node, "local-mac-address", &ret);
+	if (addr && ret != ETH_ALEN) {
+		wcn36xx_err("invalid local-mac-address\n");
+		ret = -EINVAL;
+		goto out_wq;
+	} else if (addr) {
 		wcn36xx_info("mac address: %pM\n", addr);
 		SET_IEEE80211_PERM_ADDR(wcn->hw, addr);
 	}
@@ -1158,6 +1191,7 @@ out_wq:
 out_err:
 	return ret;
 }
+
 static int wcn36xx_remove(struct platform_device *pdev)
 {
 	struct ieee80211_hw *hw = platform_get_drvdata(pdev);
@@ -1168,42 +1202,33 @@ static int wcn36xx_remove(struct platform_device *pdev)
 	mutex_destroy(&wcn->hal_mutex);
 
 	ieee80211_unregister_hw(hw);
+
+	qcom_smem_state_put(wcn->tx_enable_state);
+	qcom_smem_state_put(wcn->tx_rings_empty_state);
+
 	iounmap(wcn->dxe_base);
 	iounmap(wcn->ccu_base);
 	ieee80211_free_hw(hw);
 
 	return 0;
 }
-static const struct platform_device_id wcn36xx_platform_id_table[] = {
-	{
-		.name = "wcn36xx",
-		.driver_data = 0
-	},
+
+static const struct of_device_id wcn36xx_of_match[] = {
+	{ .compatible = "qcom,wcnss-wlan" },
 	{}
 };
-MODULE_DEVICE_TABLE(platform, wcn36xx_platform_id_table);
+MODULE_DEVICE_TABLE(of, wcn36xx_of_match);
 
 static struct platform_driver wcn36xx_driver = {
 	.probe      = wcn36xx_probe,
 	.remove     = wcn36xx_remove,
 	.driver         = {
 		.name   = "wcn36xx",
+		.of_match_table = wcn36xx_of_match,
 	},
-	.id_table    = wcn36xx_platform_id_table,
 };
 
-static int __init wcn36xx_init(void)
-{
-	platform_driver_register(&wcn36xx_driver);
-	return 0;
-}
-module_init(wcn36xx_init);
-
-static void __exit wcn36xx_exit(void)
-{
-	platform_driver_unregister(&wcn36xx_driver);
-}
-module_exit(wcn36xx_exit);
+module_platform_driver(wcn36xx_driver);
 
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Eugene Krasnikov k.eugene.e@gmail.com");
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index b2108076f5c0..f9b2785cc277 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -19,6 +19,7 @@
 #include <linux/etherdevice.h>
 #include <linux/firmware.h>
 #include <linux/bitops.h>
+#include <linux/soc/qcom/smd.h>
 #include "smd.h"
 
 struct wcn36xx_cfg_val {
@@ -253,7 +254,7 @@ static int wcn36xx_smd_send_and_wait(struct wcn36xx *wcn, size_t len)
 
 	init_completion(&wcn->hal_rsp_compl);
 	start = jiffies;
-	ret = wcn->ctrl_ops->tx(wcn->hal_buf, len);
+	ret = qcom_smd_send(wcn->smd_channel, wcn->hal_buf, len);
 	if (ret) {
 		wcn36xx_err("HAL TX failed\n");
 		goto out;
@@ -2177,9 +2178,12 @@ out:
 	return ret;
 }
 
-static void wcn36xx_smd_rsp_process(struct wcn36xx *wcn, void *buf, size_t len)
+int wcn36xx_smd_rsp_process(struct qcom_smd_channel *channel,
+			    const void *buf, size_t len)
 {
 	struct wcn36xx_hal_msg_header *msg_header = buf;
+	struct ieee80211_hw *hw = qcom_smd_get_drvdata(channel);
+	struct wcn36xx *wcn = hw->priv;
 	struct wcn36xx_hal_ind_msg *msg_ind;
 	wcn36xx_dbg_dump(WCN36XX_DBG_SMD_DUMP, "SMD <<< ", buf, len);
 
@@ -2229,15 +2233,11 @@ static void wcn36xx_smd_rsp_process(struct wcn36xx *wcn, void *buf, size_t len)
 	case WCN36XX_HAL_OTA_TX_COMPL_IND:
 	case WCN36XX_HAL_MISSED_BEACON_IND:
 	case WCN36XX_HAL_DELETE_STA_CONTEXT_IND:
-		msg_ind = kmalloc(sizeof(*msg_ind) + len, GFP_KERNEL);
+		msg_ind = kmalloc(sizeof(*msg_ind) + len, GFP_ATOMIC);
 		if (!msg_ind) {
-			/*
-			 * FIXME: Do something smarter then just
-			 * printing an error.
-			 */
 			wcn36xx_err("Run out of memory while handling SMD_EVENT (%d)\n",
 				    msg_header->msg_type);
-			break;
+			return -ENOMEM;
 		}
 
 		msg_ind->msg_len = len;
@@ -2253,6 +2253,8 @@ static void wcn36xx_smd_rsp_process(struct wcn36xx *wcn, void *buf, size_t len)
 		wcn36xx_err("SMD_EVENT (%d) not supported\n",
 			      msg_header->msg_type);
 	}
+
+	return 0;
 }
 static void wcn36xx_ind_smd_work(struct work_struct *work)
 {
@@ -2310,22 +2312,13 @@ int wcn36xx_smd_open(struct wcn36xx *wcn)
 	INIT_LIST_HEAD(&wcn->hal_ind_queue);
 	spin_lock_init(&wcn->hal_ind_lock);
 
-	ret = wcn->ctrl_ops->open(wcn, wcn36xx_smd_rsp_process);
-	if (ret) {
-		wcn36xx_err("failed to open control channel\n");
-		goto free_wq;
-	}
-
-	return ret;
+	return 0;
 
-free_wq:
-	destroy_workqueue(wcn->hal_ind_wq);
 out:
 	return ret;
 }
 
 void wcn36xx_smd_close(struct wcn36xx *wcn)
 {
-	wcn->ctrl_ops->close();
 	destroy_workqueue(wcn->hal_ind_wq);
 }
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.h b/drivers/net/wireless/ath/wcn36xx/smd.h
index c4375ce1019a..493f6191a173 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.h
+++ b/drivers/net/wireless/ath/wcn36xx/smd.h
@@ -51,6 +51,7 @@ struct wcn36xx_hal_ind_msg {
 };
 
 struct wcn36xx;
+struct qcom_smd_channel;
 
 int wcn36xx_smd_open(struct wcn36xx *wcn);
 void wcn36xx_smd_close(struct wcn36xx *wcn);
@@ -127,6 +128,10 @@ int wcn36xx_smd_del_ba(struct wcn36xx *wcn, u16 tid, u8 sta_index);
 int wcn36xx_smd_trigger_ba(struct wcn36xx *wcn, u8 sta_index);
 
 int wcn36xx_smd_update_cfg(struct wcn36xx *wcn, u32 cfg_id, u32 value);
+
+int wcn36xx_smd_rsp_process(struct qcom_smd_channel *channel,
+			    const void *buf, size_t len);
+
 int wcn36xx_smd_set_mc_list(struct wcn36xx *wcn,
 			    struct ieee80211_vif *vif,
 			    struct wcn36xx_hal_rcv_flt_mc_addr_list_type *fp);
diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
index 22242d18e1fe..68cc06cf9bc0 100644
--- a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
+++ b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
@@ -103,19 +103,6 @@ struct nv_data {
 	u8	table;
 };
 
-/* Interface for platform control path
- *
- * @open: hook must be called when wcn36xx wants to open control channel.
- * @tx: sends a buffer.
- */
-struct wcn36xx_platform_ctrl_ops {
-	int (*open)(void *drv_priv, void *rsp_cb);
-	void (*close)(void);
-	int (*tx)(char *buf, size_t len);
-	int (*get_hw_mac)(u8 *addr);
-	int (*smsm_change_state)(u32 clear_mask, u32 set_mask);
-};
-
 /**
  * struct wcn36xx_vif - holds VIF related fields
  *
@@ -205,7 +192,13 @@ struct wcn36xx {
 	void __iomem		*ccu_base;
 	void __iomem		*dxe_base;
 
-	struct wcn36xx_platform_ctrl_ops *ctrl_ops;
+	struct qcom_smd_channel *smd_channel;
+
+	struct qcom_smem_state  *tx_enable_state;
+	unsigned		tx_enable_state_bit;
+	struct qcom_smem_state	*tx_rings_empty_state;
+	unsigned		tx_rings_empty_state_bit;
+
 	/*
 	 * smd_buf must be protected with smd_mutex to garantee
 	 * that all messages are sent one after another
-- 
2.5.0
