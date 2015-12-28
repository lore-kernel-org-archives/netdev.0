From: Bjorn Andersson <bjorn-UYDU3/A3LUY@public.gmane.org>
Subject: [PATCH 3/4] wcn36xx: Transition driver to SMD client
Date: Sun, 27 Dec 2015 17:34:26 -0800
Message-ID: <1451266467-15377-4-git-send-email-bjorn.andersson@sonymobile.com>
References: <1451266467-15377-1-git-send-email-bjorn.andersson@sonymobile.com>
Cc: Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, fengwei.yin-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1451266467-15377-1-git-send-email-bjorn.andersson-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The wcn36xx wifi driver follows the life cycle of the WLAN_CTRL SMD
channel, as such it should be a SMD client. This patch makes this
transition, now that we have the necessary frameworks available.

Signed-off-by: Bjorn Andersson <bjorn.andersson-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org>
---
 drivers/net/wireless/ath/wcn36xx/Kconfig   |   2 +-
 drivers/net/wireless/ath/wcn36xx/dxe.c     |  16 +++--
 drivers/net/wireless/ath/wcn36xx/main.c    | 111 +++++++++++++++++------------
 drivers/net/wireless/ath/wcn36xx/smd.c     |  26 ++++---
 drivers/net/wireless/ath/wcn36xx/smd.h     |   4 ++
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h |  21 ++----
 6 files changed, 99 insertions(+), 81 deletions(-)

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
index f8dfa05b290a..47f3937a7ab9 100644
--- a/drivers/net/wireless/ath/wcn36xx/dxe.c
+++ b/drivers/net/wireless/ath/wcn36xx/dxe.c
@@ -23,6 +23,7 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/interrupt.h>
+#include <linux/soc/qcom/smem_state.h>
 #include "wcn36xx.h"
 #include "txrx.h"
 
@@ -150,9 +151,12 @@ int wcn36xx_dxe_alloc_ctl_blks(struct wcn36xx *wcn)
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
 
@@ -676,9 +680,9 @@ int wcn36xx_dxe_tx_frame(struct wcn36xx *wcn,
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
index 7c169abdbafe..8659e3f997d2 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -19,6 +19,9 @@
 #include <linux/module.h>
 #include <linux/firmware.h>
 #include <linux/platform_device.h>
+#include <linux/of_irq.h>
+#include <linux/soc/qcom/smd.h>
+#include <linux/soc/qcom/smem_state.h>
 #include "wcn36xx.h"
 
 unsigned int wcn36xx_dbg_mask;
@@ -981,48 +984,63 @@ static int wcn36xx_init_ieee80211(struct wcn36xx *wcn)
 }
 
 static int wcn36xx_platform_get_resources(struct wcn36xx *wcn,
-					  struct platform_device *pdev)
+					  struct device *dev)
 {
-	struct resource *res;
+	u32 mmio[2];
+	int ret;
+
 	/* Set TX IRQ */
-	res = platform_get_resource_byname(pdev, IORESOURCE_IRQ,
-					   "wcnss_wlantx_irq");
-	if (!res) {
+	wcn->tx_irq = irq_of_parse_and_map(dev->of_node, 0);
+	if (!wcn->tx_irq) {
 		wcn36xx_err("failed to get tx_irq\n");
 		return -ENOENT;
 	}
-	wcn->tx_irq = res->start;
 
 	/* Set RX IRQ */
-	res = platform_get_resource_byname(pdev, IORESOURCE_IRQ,
-					   "wcnss_wlanrx_irq");
-	if (!res) {
+	wcn->rx_irq = irq_of_parse_and_map(dev->of_node, 1);
+	if (!wcn->rx_irq) {
 		wcn36xx_err("failed to get rx_irq\n");
 		return -ENOENT;
 	}
-	wcn->rx_irq = res->start;
+
+	/* Acquire SMSM tx enable handle */
+	wcn->tx_enable_state = qcom_smem_state_get(dev, "tx-enable",
+			&wcn->tx_enable_state_bit);
+	if (IS_ERR(wcn->tx_enable_state)) {
+		wcn36xx_err("failed to get tx-enable state\n");
+		return -ENOENT;
+	}
+
+	/* Acquire SMSM tx rings empty handle */
+	wcn->tx_rings_empty_state = qcom_smem_state_get(dev, "tx-rings-empty",
+			&wcn->tx_rings_empty_state_bit);
+	if (IS_ERR(wcn->tx_rings_empty_state)) {
+		wcn36xx_err("failed to get tx-rings-empty state\n");
+		return -ENOENT;
+	}
 
 	/* Map the memory */
-	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
-						 "wcnss_mmio");
-	if (!res) {
-		wcn36xx_err("failed to get mmio\n");
+	ret = of_property_read_u32_array(dev->of_node, "qcom,wcnss-mmio", mmio, 2);
+	if (ret) {
+		wcn36xx_err("failed to get qcom,wcnss-mmio\n");
 		return -ENOENT;
 	}
-	wcn->mmio = ioremap(res->start, resource_size(res));
+
+	wcn->mmio = ioremap(mmio[0], mmio[1]);
 	if (!wcn->mmio) {
 		wcn36xx_err("failed to map io memory\n");
 		return -ENOMEM;
 	}
+
 	return 0;
 }
 
-static int wcn36xx_probe(struct platform_device *pdev)
+static int wcn36xx_probe(struct qcom_smd_device *sdev)
 {
 	struct ieee80211_hw *hw;
 	struct wcn36xx *wcn;
 	int ret;
-	u8 addr[ETH_ALEN];
+	const u8 *addr;
 
 	wcn36xx_dbg(WCN36XX_DBG_MAC, "platform probe\n");
 
@@ -1032,20 +1050,27 @@ static int wcn36xx_probe(struct platform_device *pdev)
 		ret = -ENOMEM;
 		goto out_err;
 	}
-	platform_set_drvdata(pdev, hw);
+	dev_set_drvdata(&sdev->dev, hw);
 	wcn = hw->priv;
 	wcn->hw = hw;
-	wcn->dev = &pdev->dev;
-	wcn->ctrl_ops = pdev->dev.platform_data;
+	wcn->dev = &sdev->dev;
+	wcn->smd_channel = sdev->channel;
 
 	mutex_init(&wcn->hal_mutex);
 
-	if (!wcn->ctrl_ops->get_hw_mac(addr)) {
+	sdev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
+
+	addr = of_get_property(sdev->dev.of_node, "local-mac-address", &ret);
+	if (addr && ret != ETH_ALEN) {
+		wcn36xx_err("invalid local-mac-address\n");
+		ret = -EINVAL;
+		goto out_err;
+	} else if (addr) {
 		wcn36xx_info("mac address: %pM\n", addr);
 		SET_IEEE80211_PERM_ADDR(wcn->hw, addr);
 	}
 
-	ret = wcn36xx_platform_get_resources(wcn, pdev);
+	ret = wcn36xx_platform_get_resources(wcn, &sdev->dev);
 	if (ret)
 		goto out_wq;
 
@@ -1063,9 +1088,10 @@ out_wq:
 out_err:
 	return ret;
 }
-static int wcn36xx_remove(struct platform_device *pdev)
+
+static void wcn36xx_remove(struct qcom_smd_device *sdev)
 {
-	struct ieee80211_hw *hw = platform_get_drvdata(pdev);
+	struct ieee80211_hw *hw = dev_get_drvdata(&sdev->dev);
 	struct wcn36xx *wcn = hw->priv;
 	wcn36xx_dbg(WCN36XX_DBG_MAC, "platform remove\n");
 
@@ -1073,41 +1099,34 @@ static int wcn36xx_remove(struct platform_device *pdev)
 	mutex_destroy(&wcn->hal_mutex);
 
 	ieee80211_unregister_hw(hw);
+
+	qcom_smem_state_put(wcn->tx_enable_state);
+	qcom_smem_state_put(wcn->tx_rings_empty_state);
+
 	iounmap(wcn->mmio);
 	ieee80211_free_hw(hw);
-
-	return 0;
 }
-static const struct platform_device_id wcn36xx_platform_id_table[] = {
-	{
-		.name = "wcn36xx",
-		.driver_data = 0
-	},
+
+static const struct of_device_id wcn36xx_of_match[] = {
+	{ .compatible = "qcom,wcn3620-wlan" },
+	{ .compatible = "qcom,wcn3660-wlan" },
+	{ .compatible = "qcom,wcn3680-wlan" },
 	{}
 };
-MODULE_DEVICE_TABLE(platform, wcn36xx_platform_id_table);
+MODULE_DEVICE_TABLE(of, wcn36xx_of_match);
 
-static struct platform_driver wcn36xx_driver = {
+static struct qcom_smd_driver wcn36xx_driver = {
 	.probe      = wcn36xx_probe,
 	.remove     = wcn36xx_remove,
+	.callback = wcn36xx_smd_rsp_process,
 	.driver         = {
 		.name   = "wcn36xx",
+		.of_match_table = wcn36xx_of_match,
+		.owner  = THIS_MODULE,
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
+module_qcom_smd_driver(wcn36xx_driver);
 
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Eugene Krasnikov k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org");
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index 4307429740a9..2bf42787a4af 100644
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
@@ -2100,9 +2101,13 @@ out:
 	mutex_unlock(&wcn->hal_mutex);
 	return ret;
 }
-static void wcn36xx_smd_rsp_process(struct wcn36xx *wcn, void *buf, size_t len)
+
+int wcn36xx_smd_rsp_process(struct qcom_smd_device *sdev,
+			    const void *buf, size_t len)
 {
-	struct wcn36xx_hal_msg_header *msg_header = buf;
+	const struct wcn36xx_hal_msg_header *msg_header = buf;
+	struct ieee80211_hw *hw = dev_get_drvdata(&sdev->dev);
+	struct wcn36xx *wcn = hw->priv;
 	struct wcn36xx_hal_ind_msg *msg_ind;
 	wcn36xx_dbg_dump(WCN36XX_DBG_SMD_DUMP, "SMD <<< ", buf, len);
 
@@ -2151,7 +2156,7 @@ static void wcn36xx_smd_rsp_process(struct wcn36xx *wcn, void *buf, size_t len)
 	case WCN36XX_HAL_OTA_TX_COMPL_IND:
 	case WCN36XX_HAL_MISSED_BEACON_IND:
 	case WCN36XX_HAL_DELETE_STA_CONTEXT_IND:
-		msg_ind = kmalloc(sizeof(*msg_ind) + len, GFP_KERNEL);
+		msg_ind = kmalloc(sizeof(*msg_ind) + len, GFP_ATOMIC);
 		if (!msg_ind) {
 			/*
 			 * FIXME: Do something smarter then just
@@ -2175,6 +2180,8 @@ static void wcn36xx_smd_rsp_process(struct wcn36xx *wcn, void *buf, size_t len)
 		wcn36xx_err("SMD_EVENT (%d) not supported\n",
 			      msg_header->msg_type);
 	}
+
+	return 0;
 }
 static void wcn36xx_ind_smd_work(struct work_struct *work)
 {
@@ -2232,22 +2239,13 @@ int wcn36xx_smd_open(struct wcn36xx *wcn)
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
index 21cc4ac7b5ca..4d96d56d266f 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.h
+++ b/drivers/net/wireless/ath/wcn36xx/smd.h
@@ -60,6 +60,7 @@ struct wcn36xx_hal_ind_msg {
 };
 
 struct wcn36xx;
+struct qcom_smd_device;
 
 int wcn36xx_smd_open(struct wcn36xx *wcn);
 void wcn36xx_smd_close(struct wcn36xx *wcn);
@@ -136,4 +137,7 @@ int wcn36xx_smd_del_ba(struct wcn36xx *wcn, u16 tid, u8 sta_index);
 int wcn36xx_smd_trigger_ba(struct wcn36xx *wcn, u8 sta_index);
 
 int wcn36xx_smd_update_cfg(struct wcn36xx *wcn, u32 cfg_id, u32 value);
+
+int wcn36xx_smd_rsp_process(struct qcom_smd_device *sdev,
+			    const void *buf, size_t len);
 #endif	/* _SMD_H_ */
diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
index 7997cc1312ee..4be81f66e167 100644
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
