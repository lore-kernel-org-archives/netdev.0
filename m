From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 1/3] soc: qcom: smd: Transition client drivers from smd to rpmsg
Date: Mon, 20 Mar 2017 16:35:42 -0700
Message-ID: <20170320233544.1656-1-bjorn.andersson@linaro.org>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-bluetooth@vger.kernel.org,
        linux-kernel@vger.kernel.org, wcn36xx@lists.infradead.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, linux-soc@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        Eugene Krasnikov <k.eugene.e@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Andy Gross <andy.gross@linaro.org>,
        David Brown <david.brown@linaro.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By moving these client drivers to use RPMSG instead of the direct SMD
API we can reuse them ontop of the newly added GLINK wire-protocol
support found in the 820 and 835 Qualcomm platforms.

As the new (RPMSG-based) and old SMD implementations are mutually
exclusive we have to change all client drivers in one commit, to make
sure we have a working system before and after this transition.

Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---

Based on v4.11-rc3 with Arnd's Kconfig dependency fixes for BT_QCOMSMD
(https://lkml.org/lkml/2017/3/20/1038).

 drivers/bluetooth/Kconfig                  |  2 +-
 drivers/bluetooth/btqcomsmd.c              | 32 +++++++++----------
 drivers/net/wireless/ath/wcn36xx/Kconfig   |  2 +-
 drivers/net/wireless/ath/wcn36xx/main.c    |  6 ++--
 drivers/net/wireless/ath/wcn36xx/smd.c     | 10 +++---
 drivers/net/wireless/ath/wcn36xx/smd.h     |  6 ++--
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h |  2 +-
 drivers/soc/qcom/Kconfig                   |  4 +--
 drivers/soc/qcom/smd-rpm.c                 | 43 +++++++++++++------------
 drivers/soc/qcom/wcnss_ctrl.c              | 50 +++++++++++++++++-------------
 include/linux/soc/qcom/wcnss_ctrl.h        | 11 ++++---
 net/qrtr/Kconfig                           |  2 +-
 net/qrtr/smd.c                             | 42 ++++++++++++-------------
 13 files changed, 108 insertions(+), 104 deletions(-)

diff --git a/drivers/bluetooth/Kconfig b/drivers/bluetooth/Kconfig
index 08e054507d0b..a6a9dd4d0eef 100644
--- a/drivers/bluetooth/Kconfig
+++ b/drivers/bluetooth/Kconfig
@@ -344,7 +344,7 @@ config BT_WILINK
 
 config BT_QCOMSMD
 	tristate "Qualcomm SMD based HCI support"
-	depends on QCOM_SMD || (COMPILE_TEST && QCOM_SMD=n)
+	depends on RPMSG || (COMPILE_TEST && RPMSG=n)
 	depends on QCOM_WCNSS_CTRL || (COMPILE_TEST && QCOM_WCNSS_CTRL=n)
 	select BT_QCA
 	help
diff --git a/drivers/bluetooth/btqcomsmd.c b/drivers/bluetooth/btqcomsmd.c
index 8d4868af9bbd..ef730c173d4b 100644
--- a/drivers/bluetooth/btqcomsmd.c
+++ b/drivers/bluetooth/btqcomsmd.c
@@ -14,7 +14,7 @@
 
 #include <linux/module.h>
 #include <linux/slab.h>
-#include <linux/soc/qcom/smd.h>
+#include <linux/rpmsg.h>
 #include <linux/soc/qcom/wcnss_ctrl.h>
 #include <linux/platform_device.h>
 
@@ -26,8 +26,8 @@
 struct btqcomsmd {
 	struct hci_dev *hdev;
 
-	struct qcom_smd_channel *acl_channel;
-	struct qcom_smd_channel *cmd_channel;
+	struct rpmsg_endpoint *acl_channel;
+	struct rpmsg_endpoint *cmd_channel;
 };
 
 static int btqcomsmd_recv(struct hci_dev *hdev, unsigned int type,
@@ -48,19 +48,19 @@ static int btqcomsmd_recv(struct hci_dev *hdev, unsigned int type,
 	return hci_recv_frame(hdev, skb);
 }
 
-static int btqcomsmd_acl_callback(struct qcom_smd_channel *channel,
-				  const void *data, size_t count)
+static int btqcomsmd_acl_callback(struct rpmsg_device *rpdev, void *data,
+				  int count, void *priv, u32 addr)
 {
-	struct btqcomsmd *btq = qcom_smd_get_drvdata(channel);
+	struct btqcomsmd *btq = priv;
 
 	btq->hdev->stat.byte_rx += count;
 	return btqcomsmd_recv(btq->hdev, HCI_ACLDATA_PKT, data, count);
 }
 
-static int btqcomsmd_cmd_callback(struct qcom_smd_channel *channel,
-				  const void *data, size_t count)
+static int btqcomsmd_cmd_callback(struct rpmsg_device *rpdev, void *data,
+				  int count, void *priv, u32 addr)
 {
-	struct btqcomsmd *btq = qcom_smd_get_drvdata(channel);
+	struct btqcomsmd *btq = priv;
 
 	return btqcomsmd_recv(btq->hdev, HCI_EVENT_PKT, data, count);
 }
@@ -72,12 +72,12 @@ static int btqcomsmd_send(struct hci_dev *hdev, struct sk_buff *skb)
 
 	switch (hci_skb_pkt_type(skb)) {
 	case HCI_ACLDATA_PKT:
-		ret = qcom_smd_send(btq->acl_channel, skb->data, skb->len);
+		ret = rpmsg_send(btq->acl_channel, skb->data, skb->len);
 		hdev->stat.acl_tx++;
 		hdev->stat.byte_tx += skb->len;
 		break;
 	case HCI_COMMAND_PKT:
-		ret = qcom_smd_send(btq->cmd_channel, skb->data, skb->len);
+		ret = rpmsg_send(btq->cmd_channel, skb->data, skb->len);
 		hdev->stat.cmd_tx++;
 		break;
 	default:
@@ -114,18 +114,15 @@ static int btqcomsmd_probe(struct platform_device *pdev)
 	wcnss = dev_get_drvdata(pdev->dev.parent);
 
 	btq->acl_channel = qcom_wcnss_open_channel(wcnss, "APPS_RIVA_BT_ACL",
-						   btqcomsmd_acl_callback);
+						   btqcomsmd_acl_callback, btq);
 	if (IS_ERR(btq->acl_channel))
 		return PTR_ERR(btq->acl_channel);
 
 	btq->cmd_channel = qcom_wcnss_open_channel(wcnss, "APPS_RIVA_BT_CMD",
-						   btqcomsmd_cmd_callback);
+						   btqcomsmd_cmd_callback, btq);
 	if (IS_ERR(btq->cmd_channel))
 		return PTR_ERR(btq->cmd_channel);
 
-	qcom_smd_set_drvdata(btq->acl_channel, btq);
-	qcom_smd_set_drvdata(btq->cmd_channel, btq);
-
 	hdev = hci_alloc_dev();
 	if (!hdev)
 		return -ENOMEM;
@@ -158,6 +155,9 @@ static int btqcomsmd_remove(struct platform_device *pdev)
 	hci_unregister_dev(btq->hdev);
 	hci_free_dev(btq->hdev);
 
+	rpmsg_destroy_ept(btq->cmd_channel);
+	rpmsg_destroy_ept(btq->acl_channel);
+
 	return 0;
 }
 
diff --git a/drivers/net/wireless/ath/wcn36xx/Kconfig b/drivers/net/wireless/ath/wcn36xx/Kconfig
index 4b83e87f0b94..20bf967a70b9 100644
--- a/drivers/net/wireless/ath/wcn36xx/Kconfig
+++ b/drivers/net/wireless/ath/wcn36xx/Kconfig
@@ -2,7 +2,7 @@ config WCN36XX
 	tristate "Qualcomm Atheros WCN3660/3680 support"
 	depends on MAC80211 && HAS_DMA
 	depends on QCOM_WCNSS_CTRL || QCOM_WCNSS_CTRL=n
-	depends on QCOM_SMD || QCOM_SMD=n
+	depends on RPMSG || RPMSG=n
 	---help---
 	  This module adds support for wireless adapters based on
 	  Qualcomm Atheros WCN3660 and WCN3680 mobile chipsets.
diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index 7a0c2e7da7f6..bb7110f7fc86 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -22,7 +22,7 @@
 #include <linux/of_address.h>
 #include <linux/of_device.h>
 #include <linux/of_irq.h>
-#include <linux/soc/qcom/smd.h>
+#include <linux/rpmsg.h>
 #include <linux/soc/qcom/smem_state.h>
 #include <linux/soc/qcom/wcnss_ctrl.h>
 #include "wcn36xx.h"
@@ -1218,15 +1218,13 @@ static int wcn36xx_probe(struct platform_device *pdev)
 
 	INIT_WORK(&wcn->scan_work, wcn36xx_hw_scan_worker);
 
-	wcn->smd_channel = qcom_wcnss_open_channel(wcnss, "WLAN_CTRL", wcn36xx_smd_rsp_process);
+	wcn->smd_channel = qcom_wcnss_open_channel(wcnss, "WLAN_CTRL", wcn36xx_smd_rsp_process, hw);
 	if (IS_ERR(wcn->smd_channel)) {
 		wcn36xx_err("failed to open WLAN_CTRL channel\n");
 		ret = PTR_ERR(wcn->smd_channel);
 		goto out_wq;
 	}
 
-	qcom_smd_set_drvdata(wcn->smd_channel, hw);
-
 	addr = of_get_property(pdev->dev.of_node, "local-mac-address", &ret);
 	if (addr && ret != ETH_ALEN) {
 		wcn36xx_err("invalid local-mac-address\n");
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index 1c2966f7db7a..9c6590d5348a 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -19,7 +19,7 @@
 #include <linux/etherdevice.h>
 #include <linux/firmware.h>
 #include <linux/bitops.h>
-#include <linux/soc/qcom/smd.h>
+#include <linux/rpmsg.h>
 #include "smd.h"
 
 struct wcn36xx_cfg_val {
@@ -254,7 +254,7 @@ static int wcn36xx_smd_send_and_wait(struct wcn36xx *wcn, size_t len)
 
 	init_completion(&wcn->hal_rsp_compl);
 	start = jiffies;
-	ret = qcom_smd_send(wcn->smd_channel, wcn->hal_buf, len);
+	ret = rpmsg_send(wcn->smd_channel, wcn->hal_buf, len);
 	if (ret) {
 		wcn36xx_err("HAL TX failed\n");
 		goto out;
@@ -2205,11 +2205,11 @@ int wcn36xx_smd_set_mc_list(struct wcn36xx *wcn,
 	return ret;
 }
 
-int wcn36xx_smd_rsp_process(struct qcom_smd_channel *channel,
-			    const void *buf, size_t len)
+int wcn36xx_smd_rsp_process(struct rpmsg_device *rpdev,
+			    void *buf, int len, void *priv, u32 addr)
 {
 	const struct wcn36xx_hal_msg_header *msg_header = buf;
-	struct ieee80211_hw *hw = qcom_smd_get_drvdata(channel);
+	struct ieee80211_hw *hw = priv;
 	struct wcn36xx *wcn = hw->priv;
 	struct wcn36xx_hal_ind_msg *msg_ind;
 	wcn36xx_dbg_dump(WCN36XX_DBG_SMD_DUMP, "SMD <<< ", buf, len);
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.h b/drivers/net/wireless/ath/wcn36xx/smd.h
index 8892ccd67b14..013fc9546f56 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.h
+++ b/drivers/net/wireless/ath/wcn36xx/smd.h
@@ -51,7 +51,7 @@ struct wcn36xx_hal_ind_msg {
 };
 
 struct wcn36xx;
-struct qcom_smd_channel;
+struct rpmsg_device;
 
 int wcn36xx_smd_open(struct wcn36xx *wcn);
 void wcn36xx_smd_close(struct wcn36xx *wcn);
@@ -129,8 +129,8 @@ int wcn36xx_smd_trigger_ba(struct wcn36xx *wcn, u8 sta_index);
 
 int wcn36xx_smd_update_cfg(struct wcn36xx *wcn, u32 cfg_id, u32 value);
 
-int wcn36xx_smd_rsp_process(struct qcom_smd_channel *channel,
-			    const void *buf, size_t len);
+int wcn36xx_smd_rsp_process(struct rpmsg_device *rpdev,
+			    void *buf, int len, void *priv, u32 addr);
 
 int wcn36xx_smd_set_mc_list(struct wcn36xx *wcn,
 			    struct ieee80211_vif *vif,
diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
index 7423998ddeb4..b52b4da9a967 100644
--- a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
+++ b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
@@ -195,7 +195,7 @@ struct wcn36xx {
 	void __iomem		*ccu_base;
 	void __iomem		*dxe_base;
 
-	struct qcom_smd_channel *smd_channel;
+	struct rpmsg_endpoint	*smd_channel;
 
 	struct qcom_smem_state  *tx_enable_state;
 	unsigned		tx_enable_state_bit;
diff --git a/drivers/soc/qcom/Kconfig b/drivers/soc/qcom/Kconfig
index 78b1bb7bcf20..751dce0c19b3 100644
--- a/drivers/soc/qcom/Kconfig
+++ b/drivers/soc/qcom/Kconfig
@@ -43,7 +43,7 @@ config QCOM_SMD
 
 config QCOM_SMD_RPM
 	tristate "Qualcomm Resource Power Manager (RPM) over SMD"
-	depends on QCOM_SMD && OF
+	depends on RPMSG && OF
 	help
 	  If you say yes to this option, support will be included for the
 	  Resource Power Manager system found in the Qualcomm 8974 based
@@ -76,7 +76,7 @@ config QCOM_SMSM
 
 config QCOM_WCNSS_CTRL
 	tristate "Qualcomm WCNSS control driver"
-	depends on QCOM_SMD
+	depends on RPMSG
 	help
 	  Client driver for the WCNSS_CTRL SMD channel, used to download nv
 	  firmware to a newly booted WCNSS chip.
diff --git a/drivers/soc/qcom/smd-rpm.c b/drivers/soc/qcom/smd-rpm.c
index 6609d7e0edb0..0dcf1bf33126 100644
--- a/drivers/soc/qcom/smd-rpm.c
+++ b/drivers/soc/qcom/smd-rpm.c
@@ -19,7 +19,7 @@
 #include <linux/interrupt.h>
 #include <linux/slab.h>
 
-#include <linux/soc/qcom/smd.h>
+#include <linux/rpmsg.h>
 #include <linux/soc/qcom/smd-rpm.h>
 
 #define RPM_REQUEST_TIMEOUT     (5 * HZ)
@@ -32,7 +32,7 @@
  * @ack_status:		result of the rpm request
  */
 struct qcom_smd_rpm {
-	struct qcom_smd_channel *rpm_channel;
+	struct rpmsg_endpoint *rpm_channel;
 	struct device *dev;
 
 	struct completion ack;
@@ -133,7 +133,7 @@ int qcom_rpm_smd_write(struct qcom_smd_rpm *rpm,
 	pkt->req.data_len = cpu_to_le32(count);
 	memcpy(pkt->payload, buf, count);
 
-	ret = qcom_smd_send(rpm->rpm_channel, pkt, size);
+	ret = rpmsg_send(rpm->rpm_channel, pkt, size);
 	if (ret)
 		goto out;
 
@@ -150,14 +150,16 @@ int qcom_rpm_smd_write(struct qcom_smd_rpm *rpm,
 }
 EXPORT_SYMBOL(qcom_rpm_smd_write);
 
-static int qcom_smd_rpm_callback(struct qcom_smd_channel *channel,
-				 const void *data,
-				 size_t count)
+static int qcom_smd_rpm_callback(struct rpmsg_device *rpdev,
+				 void *data,
+				 int count,
+				 void *priv,
+				 u32 addr)
 {
 	const struct qcom_rpm_header *hdr = data;
 	size_t hdr_length = le32_to_cpu(hdr->length);
 	const struct qcom_rpm_message *msg;
-	struct qcom_smd_rpm *rpm = qcom_smd_get_drvdata(channel);
+	struct qcom_smd_rpm *rpm = dev_get_drvdata(&rpdev->dev);
 	const u8 *buf = data + sizeof(struct qcom_rpm_header);
 	const u8 *end = buf + hdr_length;
 	char msgbuf[32];
@@ -196,29 +198,27 @@ static int qcom_smd_rpm_callback(struct qcom_smd_channel *channel,
 	return 0;
 }
 
-static int qcom_smd_rpm_probe(struct qcom_smd_device *sdev)
+static int qcom_smd_rpm_probe(struct rpmsg_device *rpdev)
 {
 	struct qcom_smd_rpm *rpm;
 
-	rpm = devm_kzalloc(&sdev->dev, sizeof(*rpm), GFP_KERNEL);
+	rpm = devm_kzalloc(&rpdev->dev, sizeof(*rpm), GFP_KERNEL);
 	if (!rpm)
 		return -ENOMEM;
 
 	mutex_init(&rpm->lock);
 	init_completion(&rpm->ack);
 
-	rpm->dev = &sdev->dev;
-	rpm->rpm_channel = sdev->channel;
-	qcom_smd_set_drvdata(sdev->channel, rpm);
+	rpm->dev = &rpdev->dev;
+	rpm->rpm_channel = rpdev->ept;
+	dev_set_drvdata(&rpdev->dev, rpm);
 
-	dev_set_drvdata(&sdev->dev, rpm);
-
-	return of_platform_populate(sdev->dev.of_node, NULL, NULL, &sdev->dev);
+	return of_platform_populate(rpdev->dev.of_node, NULL, NULL, &rpdev->dev);
 }
 
-static void qcom_smd_rpm_remove(struct qcom_smd_device *sdev)
+static void qcom_smd_rpm_remove(struct rpmsg_device *rpdev)
 {
-	of_platform_depopulate(&sdev->dev);
+	of_platform_depopulate(&rpdev->dev);
 }
 
 static const struct of_device_id qcom_smd_rpm_of_match[] = {
@@ -229,26 +229,25 @@ static const struct of_device_id qcom_smd_rpm_of_match[] = {
 };
 MODULE_DEVICE_TABLE(of, qcom_smd_rpm_of_match);
 
-static struct qcom_smd_driver qcom_smd_rpm_driver = {
+static struct rpmsg_driver qcom_smd_rpm_driver = {
 	.probe = qcom_smd_rpm_probe,
 	.remove = qcom_smd_rpm_remove,
 	.callback = qcom_smd_rpm_callback,
-	.driver  = {
+	.drv  = {
 		.name  = "qcom_smd_rpm",
-		.owner = THIS_MODULE,
 		.of_match_table = qcom_smd_rpm_of_match,
 	},
 };
 
 static int __init qcom_smd_rpm_init(void)
 {
-	return qcom_smd_driver_register(&qcom_smd_rpm_driver);
+	return register_rpmsg_driver(&qcom_smd_rpm_driver);
 }
 arch_initcall(qcom_smd_rpm_init);
 
 static void __exit qcom_smd_rpm_exit(void)
 {
-	qcom_smd_driver_unregister(&qcom_smd_rpm_driver);
+	unregister_rpmsg_driver(&qcom_smd_rpm_driver);
 }
 module_exit(qcom_smd_rpm_exit);
 
diff --git a/drivers/soc/qcom/wcnss_ctrl.c b/drivers/soc/qcom/wcnss_ctrl.c
index 520aedd29965..b9069184df19 100644
--- a/drivers/soc/qcom/wcnss_ctrl.c
+++ b/drivers/soc/qcom/wcnss_ctrl.c
@@ -14,10 +14,10 @@
 #include <linux/firmware.h>
 #include <linux/module.h>
 #include <linux/slab.h>
-#include <linux/soc/qcom/smd.h>
 #include <linux/io.h>
 #include <linux/of_platform.h>
 #include <linux/platform_device.h>
+#include <linux/rpmsg.h>
 #include <linux/soc/qcom/wcnss_ctrl.h>
 
 #define WCNSS_REQUEST_TIMEOUT	(5 * HZ)
@@ -40,7 +40,7 @@
  */
 struct wcnss_ctrl {
 	struct device *dev;
-	struct qcom_smd_channel *channel;
+	struct rpmsg_endpoint *channel;
 
 	struct completion ack;
 	struct completion cbc;
@@ -122,11 +122,13 @@ struct wcnss_download_nv_resp {
  *
  * Handles any incoming packets from the remote WCNSS_CTRL service.
  */
-static int wcnss_ctrl_smd_callback(struct qcom_smd_channel *channel,
-				   const void *data,
-				   size_t count)
+static int wcnss_ctrl_smd_callback(struct rpmsg_device *rpdev,
+				   void *data,
+				   int count,
+				   void *priv,
+				   u32 addr)
 {
-	struct wcnss_ctrl *wcnss = qcom_smd_get_drvdata(channel);
+	struct wcnss_ctrl *wcnss = dev_get_drvdata(&rpdev->dev);
 	const struct wcnss_download_nv_resp *nvresp;
 	const struct wcnss_version_resp *version;
 	const struct wcnss_msg_hdr *hdr = data;
@@ -180,7 +182,7 @@ static int wcnss_request_version(struct wcnss_ctrl *wcnss)
 
 	msg.type = WCNSS_VERSION_REQ;
 	msg.len = sizeof(msg);
-	ret = qcom_smd_send(wcnss->channel, &msg, sizeof(msg));
+	ret = rpmsg_send(wcnss->channel, &msg, sizeof(msg));
 	if (ret < 0)
 		return ret;
 
@@ -238,7 +240,7 @@ static int wcnss_download_nv(struct wcnss_ctrl *wcnss, bool *expect_cbc)
 
 		memcpy(req->fragment, data, req->frag_size);
 
-		ret = qcom_smd_send(wcnss->channel, req, req->hdr.len);
+		ret = rpmsg_send(wcnss->channel, req, req->hdr.len);
 		if (ret < 0) {
 			dev_err(wcnss->dev, "failed to send smd packet\n");
 			goto release_fw;
@@ -274,11 +276,16 @@ static int wcnss_download_nv(struct wcnss_ctrl *wcnss, bool *expect_cbc)
  * @name:	SMD channel name
  * @cb:		callback to handle incoming data on the channel
  */
-struct qcom_smd_channel *qcom_wcnss_open_channel(void *wcnss, const char *name, qcom_smd_cb_t cb)
+struct rpmsg_endpoint *qcom_wcnss_open_channel(void *wcnss, const char *name, rpmsg_rx_cb_t cb, void *priv)
 {
+	struct rpmsg_channel_info chinfo;
 	struct wcnss_ctrl *_wcnss = wcnss;
 
-	return qcom_smd_open_channel(_wcnss->channel, name, cb);
+	strncpy(chinfo.name, name, sizeof(chinfo.name));
+	chinfo.src = RPMSG_ADDR_ANY;
+	chinfo.dst = RPMSG_ADDR_ANY;
+
+	return rpmsg_create_ept(_wcnss->channel->rpdev, cb, priv, chinfo);
 }
 EXPORT_SYMBOL(qcom_wcnss_open_channel);
 
@@ -306,35 +313,34 @@ static void wcnss_async_probe(struct work_struct *work)
 	of_platform_populate(wcnss->dev->of_node, NULL, NULL, wcnss->dev);
 }
 
-static int wcnss_ctrl_probe(struct qcom_smd_device *sdev)
+static int wcnss_ctrl_probe(struct rpmsg_device *rpdev)
 {
 	struct wcnss_ctrl *wcnss;
 
-	wcnss = devm_kzalloc(&sdev->dev, sizeof(*wcnss), GFP_KERNEL);
+	wcnss = devm_kzalloc(&rpdev->dev, sizeof(*wcnss), GFP_KERNEL);
 	if (!wcnss)
 		return -ENOMEM;
 
-	wcnss->dev = &sdev->dev;
-	wcnss->channel = sdev->channel;
+	wcnss->dev = &rpdev->dev;
+	wcnss->channel = rpdev->ept;
 
 	init_completion(&wcnss->ack);
 	init_completion(&wcnss->cbc);
 	INIT_WORK(&wcnss->probe_work, wcnss_async_probe);
 
-	qcom_smd_set_drvdata(sdev->channel, wcnss);
-	dev_set_drvdata(&sdev->dev, wcnss);
+	dev_set_drvdata(&rpdev->dev, wcnss);
 
 	schedule_work(&wcnss->probe_work);
 
 	return 0;
 }
 
-static void wcnss_ctrl_remove(struct qcom_smd_device *sdev)
+static void wcnss_ctrl_remove(struct rpmsg_device *rpdev)
 {
-	struct wcnss_ctrl *wcnss = qcom_smd_get_drvdata(sdev->channel);
+	struct wcnss_ctrl *wcnss = dev_get_drvdata(&rpdev->dev);
 
 	cancel_work_sync(&wcnss->probe_work);
-	of_platform_depopulate(&sdev->dev);
+	of_platform_depopulate(&rpdev->dev);
 }
 
 static const struct of_device_id wcnss_ctrl_of_match[] = {
@@ -342,18 +348,18 @@ static const struct of_device_id wcnss_ctrl_of_match[] = {
 	{}
 };
 
-static struct qcom_smd_driver wcnss_ctrl_driver = {
+static struct rpmsg_driver wcnss_ctrl_driver = {
 	.probe = wcnss_ctrl_probe,
 	.remove = wcnss_ctrl_remove,
 	.callback = wcnss_ctrl_smd_callback,
-	.driver  = {
+	.drv  = {
 		.name  = "qcom_wcnss_ctrl",
 		.owner = THIS_MODULE,
 		.of_match_table = wcnss_ctrl_of_match,
 	},
 };
 
-module_qcom_smd_driver(wcnss_ctrl_driver);
+module_rpmsg_driver(wcnss_ctrl_driver);
 
 MODULE_DESCRIPTION("Qualcomm WCNSS control driver");
 MODULE_LICENSE("GPL v2");
diff --git a/include/linux/soc/qcom/wcnss_ctrl.h b/include/linux/soc/qcom/wcnss_ctrl.h
index eab64976a73b..a4dd4d7c711d 100644
--- a/include/linux/soc/qcom/wcnss_ctrl.h
+++ b/include/linux/soc/qcom/wcnss_ctrl.h
@@ -1,16 +1,19 @@
 #ifndef __WCNSS_CTRL_H__
 #define __WCNSS_CTRL_H__
 
-#include <linux/soc/qcom/smd.h>
+#include <linux/rpmsg.h>
 
 #if IS_ENABLED(CONFIG_QCOM_WCNSS_CTRL)
 
-struct qcom_smd_channel *qcom_wcnss_open_channel(void *wcnss, const char *name, qcom_smd_cb_t cb);
+struct rpmsg_endpoint *qcom_wcnss_open_channel(void *wcnss, const char *name,
+					       rpmsg_rx_cb_t cb, void *priv);
 
 #else
 
-static inline struct qcom_smd_channel*
-qcom_wcnss_open_channel(void *wcnss, const char *name, qcom_smd_cb_t cb)
+static struct rpmsg_endpoint *qcom_wcnss_open_channel(void *wcnss,
+						      const char *name,
+						      rpmsg_rx_cb_t cb,
+						      void *priv)
 {
 	WARN_ON(1);
 	return ERR_PTR(-ENXIO);
diff --git a/net/qrtr/Kconfig b/net/qrtr/Kconfig
index b83c6807a5ae..326fd97444f5 100644
--- a/net/qrtr/Kconfig
+++ b/net/qrtr/Kconfig
@@ -16,7 +16,7 @@ if QRTR
 
 config QRTR_SMD
 	tristate "SMD IPC Router channels"
-	depends on QCOM_SMD || (COMPILE_TEST && QCOM_SMD=n)
+	depends on RPMSG || (COMPILE_TEST && RPMSG=n)
 	---help---
 	  Say Y here to support SMD based ipcrouter channels.  SMD is the
 	  most common transport for IPC Router.
diff --git a/net/qrtr/smd.c b/net/qrtr/smd.c
index 0d11132b3370..50615d5efac1 100644
--- a/net/qrtr/smd.c
+++ b/net/qrtr/smd.c
@@ -14,21 +14,21 @@
 
 #include <linux/module.h>
 #include <linux/skbuff.h>
-#include <linux/soc/qcom/smd.h>
+#include <linux/rpmsg.h>
 
 #include "qrtr.h"
 
 struct qrtr_smd_dev {
 	struct qrtr_endpoint ep;
-	struct qcom_smd_channel *channel;
+	struct rpmsg_endpoint *channel;
 	struct device *dev;
 };
 
 /* from smd to qrtr */
-static int qcom_smd_qrtr_callback(struct qcom_smd_channel *channel,
-				  const void *data, size_t len)
+static int qcom_smd_qrtr_callback(struct rpmsg_device *rpdev,
+				  void *data, int len, void *priv, u32 addr)
 {
-	struct qrtr_smd_dev *qdev = qcom_smd_get_drvdata(channel);
+	struct qrtr_smd_dev *qdev = dev_get_drvdata(&rpdev->dev);
 	int rc;
 
 	if (!qdev)
@@ -54,7 +54,7 @@ static int qcom_smd_qrtr_send(struct qrtr_endpoint *ep, struct sk_buff *skb)
 	if (rc)
 		goto out;
 
-	rc = qcom_smd_send(qdev->channel, skb->data, skb->len);
+	rc = rpmsg_send(qdev->channel, skb->data, skb->len);
 
 out:
 	if (rc)
@@ -64,57 +64,55 @@ static int qcom_smd_qrtr_send(struct qrtr_endpoint *ep, struct sk_buff *skb)
 	return rc;
 }
 
-static int qcom_smd_qrtr_probe(struct qcom_smd_device *sdev)
+static int qcom_smd_qrtr_probe(struct rpmsg_device *rpdev)
 {
 	struct qrtr_smd_dev *qdev;
 	int rc;
 
-	qdev = devm_kzalloc(&sdev->dev, sizeof(*qdev), GFP_KERNEL);
+	qdev = devm_kzalloc(&rpdev->dev, sizeof(*qdev), GFP_KERNEL);
 	if (!qdev)
 		return -ENOMEM;
 
-	qdev->channel = sdev->channel;
-	qdev->dev = &sdev->dev;
+	qdev->channel = rpdev->ept;
+	qdev->dev = &rpdev->dev;
 	qdev->ep.xmit = qcom_smd_qrtr_send;
 
 	rc = qrtr_endpoint_register(&qdev->ep, QRTR_EP_NID_AUTO);
 	if (rc)
 		return rc;
 
-	qcom_smd_set_drvdata(sdev->channel, qdev);
-	dev_set_drvdata(&sdev->dev, qdev);
+	dev_set_drvdata(&rpdev->dev, qdev);
 
-	dev_dbg(&sdev->dev, "Qualcomm SMD QRTR driver probed\n");
+	dev_dbg(&rpdev->dev, "Qualcomm SMD QRTR driver probed\n");
 
 	return 0;
 }
 
-static void qcom_smd_qrtr_remove(struct qcom_smd_device *sdev)
+static void qcom_smd_qrtr_remove(struct rpmsg_device *rpdev)
 {
-	struct qrtr_smd_dev *qdev = dev_get_drvdata(&sdev->dev);
+	struct qrtr_smd_dev *qdev = dev_get_drvdata(&rpdev->dev);
 
 	qrtr_endpoint_unregister(&qdev->ep);
 
-	dev_set_drvdata(&sdev->dev, NULL);
+	dev_set_drvdata(&rpdev->dev, NULL);
 }
 
-static const struct qcom_smd_id qcom_smd_qrtr_smd_match[] = {
+static const struct rpmsg_device_id qcom_smd_qrtr_smd_match[] = {
 	{ "IPCRTR" },
 	{}
 };
 
-static struct qcom_smd_driver qcom_smd_qrtr_driver = {
+static struct rpmsg_driver qcom_smd_qrtr_driver = {
 	.probe = qcom_smd_qrtr_probe,
 	.remove = qcom_smd_qrtr_remove,
 	.callback = qcom_smd_qrtr_callback,
-	.smd_match_table = qcom_smd_qrtr_smd_match,
-	.driver = {
+	.id_table = qcom_smd_qrtr_smd_match,
+	.drv = {
 		.name = "qcom_smd_qrtr",
-		.owner = THIS_MODULE,
 	},
 };
 
-module_qcom_smd_driver(qcom_smd_qrtr_driver);
+module_rpmsg_driver(qcom_smd_qrtr_driver);
 
 MODULE_DESCRIPTION("Qualcomm IPC-Router SMD interface driver");
 MODULE_LICENSE("GPL v2");
-- 
2.12.0
