From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 3/4] qed: Support NVM-image reading API
Date: Fri, 2 Jun 2017 08:58:32 +0300
Message-ID: <20170602055833.21814-4-Yuval.Mintz@cavium.com>
References: <20170602055833.21814-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-scsi@vger.kernel.org>, <nilesh.javali@cavium.com>,
        <chad.dupuis@cavium.com>, <saurav.kashyap@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0083.outbound.protection.outlook.com ([104.47.32.83]:57712
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751208AbdFBF73 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Jun 2017 01:59:29 -0400
In-Reply-To: <20170602055833.21814-1-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Storage drivers require images from the nvram in boot-from-SAN
scenarios. This provides the necessary API between qed and the
protocol drivers to perform such reads.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_main.c | 16 ++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c  | 89 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h  | 21 +++++++
 include/linux/qed/qed_if.h                 | 18 ++++++
 4 files changed, 144 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index baebd59..6ac10ce 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1535,6 +1535,21 @@ static int qed_drain(struct qed_dev *cdev)
 	return 0;
 }
 
+static int qed_nvm_get_image(struct qed_dev *cdev, enum qed_nvm_images type,
+			     u8 *buf, u16 len)
+{
+	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_ptt *ptt = qed_ptt_acquire(hwfn);
+	int rc;
+
+	if (!ptt)
+		return -EAGAIN;
+
+	rc = qed_mcp_get_nvm_image(hwfn, ptt, type, buf, len);
+	qed_ptt_release(hwfn, ptt);
+	return rc;
+}
+
 static void qed_get_coalesce(struct qed_dev *cdev, u16 *rx_coal, u16 *tx_coal)
 {
 	*rx_coal = cdev->rx_coalesce_usecs;
@@ -1712,6 +1727,7 @@ const struct qed_common_ops qed_common_ops_pass = {
 	.dbg_all_data_size = &qed_dbg_all_data_size,
 	.chain_alloc = &qed_chain_alloc,
 	.chain_free = &qed_chain_free,
+	.nvm_get_image = &qed_nvm_get_image,
 	.get_coalesce = &qed_get_coalesce,
 	.set_coalesce = &qed_set_coalesce,
 	.set_led = &qed_set_led,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index e82f329..9da9104 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -2310,6 +2310,95 @@ int qed_mcp_bist_nvm_test_get_image_att(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
+static int
+qed_mcp_get_nvm_image_att(struct qed_hwfn *p_hwfn,
+			  struct qed_ptt *p_ptt,
+			  enum qed_nvm_images image_id,
+			  struct qed_nvm_image_att *p_image_att)
+{
+	struct bist_nvm_image_att mfw_image_att;
+	enum nvm_image_type type;
+	u32 num_images, i;
+	int rc;
+
+	/* Translate image_id into MFW definitions */
+	switch (image_id) {
+	case QED_NVM_IMAGE_ISCSI_CFG:
+		type = NVM_TYPE_ISCSI_CFG;
+		break;
+	case QED_NVM_IMAGE_FCOE_CFG:
+		type = NVM_TYPE_FCOE_CFG;
+		break;
+	default:
+		DP_NOTICE(p_hwfn, "Unknown request of image_id %08x\n",
+			  image_id);
+		return -EINVAL;
+	}
+
+	/* Learn number of images, then traverse and see if one fits */
+	rc = qed_mcp_bist_nvm_test_get_num_images(p_hwfn, p_ptt, &num_images);
+	if (rc || !num_images)
+		return -EINVAL;
+
+	for (i = 0; i < num_images; i++) {
+		rc = qed_mcp_bist_nvm_test_get_image_att(p_hwfn, p_ptt,
+							 &mfw_image_att, i);
+		if (rc)
+			return rc;
+
+		if (type == mfw_image_att.image_type)
+			break;
+	}
+	if (i == num_images) {
+		DP_VERBOSE(p_hwfn, QED_MSG_STORAGE,
+			   "Failed to find nvram image of type %08x\n",
+			   image_id);
+		return -EINVAL;
+	}
+
+	p_image_att->start_addr = mfw_image_att.nvm_start_addr;
+	p_image_att->length = mfw_image_att.len;
+
+	return 0;
+}
+
+int qed_mcp_get_nvm_image(struct qed_hwfn *p_hwfn,
+			  struct qed_ptt *p_ptt,
+			  enum qed_nvm_images image_id,
+			  u8 *p_buffer, u32 buffer_len)
+{
+	struct qed_nvm_image_att image_att;
+	int rc;
+
+	memset(p_buffer, 0, buffer_len);
+
+	rc = qed_mcp_get_nvm_image_att(p_hwfn, p_ptt, image_id, &image_att);
+	if (rc)
+		return rc;
+
+	/* Validate sizes - both the image's and the supplied buffer's */
+	if (image_att.length <= 4) {
+		DP_VERBOSE(p_hwfn, QED_MSG_STORAGE,
+			   "Image [%d] is too small - only %d bytes\n",
+			   image_id, image_att.length);
+		return -EINVAL;
+	}
+
+	/* Each NVM image is suffixed by CRC; Upper-layer has no need for it */
+	image_att.length -= 4;
+
+	if (image_att.length > buffer_len) {
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_STORAGE,
+			   "Image [%d] is too big - %08x bytes where only %08x are available\n",
+			   image_id, image_att.length, buffer_len);
+		return -ENOMEM;
+	}
+
+	return qed_mcp_nvm_read(p_hwfn->cdev, image_att.start_addr,
+				p_buffer, image_att.length);
+}
+
 static enum resource_id_enum qed_mcp_get_mfw_res_id(enum qed_resources res_id)
 {
 	enum resource_id_enum mfw_res_id = RESOURCE_NUM_INVALID;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index 4024759..af03b36 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -430,6 +430,27 @@ int qed_mcp_set_led(struct qed_hwfn *p_hwfn,
  */
 int qed_mcp_nvm_read(struct qed_dev *cdev, u32 addr, u8 *p_buf, u32 len);
 
+struct qed_nvm_image_att {
+	u32 start_addr;
+	u32 length;
+};
+
+/**
+ * @brief Allows reading a whole nvram image
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param image_id - image requested for reading
+ * @param p_buffer - allocated buffer into which to fill data
+ * @param buffer_len - length of the allocated buffer.
+ *
+ * @return 0 iff p_buffer now contains the nvram image.
+ */
+int qed_mcp_get_nvm_image(struct qed_hwfn *p_hwfn,
+			  struct qed_ptt *p_ptt,
+			  enum qed_nvm_images image_id,
+			  u8 *p_buffer, u32 buffer_len);
+
 /**
  * @brief Bist register test
  *
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index e29c6f7..567ea3e 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -156,6 +156,11 @@ struct qed_dcbx_get {
 	struct qed_dcbx_admin_params local;
 };
 
+enum qed_nvm_images {
+	QED_NVM_IMAGE_ISCSI_CFG,
+	QED_NVM_IMAGE_FCOE_CFG,
+};
+
 enum qed_led_mode {
 	QED_LED_MODE_OFF,
 	QED_LED_MODE_ON,
@@ -631,6 +636,19 @@ struct qed_common_ops {
 				      struct qed_chain *p_chain);
 
 /**
+ * @brief nvm_get_image - reads an entire image from nvram
+ *
+ * @param cdev
+ * @param type - type of the request nvram image
+ * @param buf - preallocated buffer to fill with the image
+ * @param len - length of the allocated buffer
+ *
+ * @return 0 on success, error otherwise
+ */
+	int (*nvm_get_image)(struct qed_dev *cdev,
+			     enum qed_nvm_images type, u8 *buf, u16 len);
+
+/**
  * @brief get_coalesce - Get coalesce parameters in usec
  *
  * @param cdev
-- 
2.9.4
