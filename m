From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 5/5] qed*: Add support for read/write of eeprom
Date: Sun, 17 Apr 2016 22:26:35 +0300
Message-ID: <1460921195-23352-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1460921195-23352-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:31246 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750831AbcDQT04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2016 15:26:56 -0400
In-Reply-To: <1460921195-23352-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>

Add the driver logic needed for supporting the ethtool APIs for reading
and writing from the interface's eeprom.

There's quite a bit of `magic' here [based on the ethtool `magic' field]
which is retained by the user application responsible for interacting
with the driver for the purpose of upgrading the nvram image.

Basically, the interface goes via MFW which is responsible for actually
programming the non-volatile memory. There are 2 supported modes of
operations, one which is `file'-based and one which is based on raw data.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h           |  10 +
 drivers/net/ethernet/qlogic/qed/qed_main.c      |  37 ++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c       | 274 ++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h       | 103 +++++++++
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |  30 +++
 include/linux/qed/qed_if.h                      |  30 +++
 6 files changed, 484 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 33e2ed6..025248f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -38,6 +38,16 @@ enum qed_coalescing_mode {
 	QED_COAL_MODE_ENABLE
 };
 
+enum qed_nvm_cmd {
+	QED_PUT_FILE_BEGIN	= DRV_MSG_CODE_NVM_PUT_FILE_BEGIN,
+	QED_PUT_FILE_DATA	= DRV_MSG_CODE_NVM_PUT_FILE_DATA,
+	QED_NVM_READ_NVRAM	= DRV_MSG_CODE_NVM_READ_NVRAM,
+	QED_NVM_WRITE_NVRAM	= DRV_MSG_CODE_NVM_WRITE_NVRAM,
+	QED_NVM_DEL_FILE	= DRV_MSG_CODE_NVM_DEL_FILE,
+	QED_NVM_SET_SECURE_MODE = DRV_MSG_CODE_SET_SECURE_MODE,
+	QED_GET_MCP_NVM_RESP	= 0xFFFFFF00
+};
+
 struct qed_eth_cb_ops;
 struct qed_dev_info;
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 1918b83..78b5966 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1165,6 +1165,41 @@ static int qed_drain(struct qed_dev *cdev)
 	return 0;
 }
 
+int qed_nvm_get_cmd(struct qed_dev *cdev, u32 cmd, u32 addr,
+		    u8 *buf, u32 len)
+{
+	switch (cmd) {
+	case QED_NVM_READ_NVRAM:
+		return qed_mcp_nvm_read(cdev, addr, buf, len);
+	case QED_GET_MCP_NVM_RESP:
+		return qed_mcp_nvm_resp(cdev, buf);
+	default:
+		cdev->mcp_nvm_resp = FW_MSG_CODE_NVM_OPERATION_FAILED;
+		DP_NOTICE(cdev, "Unknown command %d\n", cmd);
+		return -EOPNOTSUPP;
+	}
+}
+
+int qed_nvm_set_cmd(struct qed_dev *cdev, u32 cmd, u32 addr,
+		    u8 *buf, u32 len)
+{
+	switch (cmd) {
+	case QED_NVM_DEL_FILE:
+		return qed_mcp_nvm_del_file(cdev, addr);
+	case QED_PUT_FILE_BEGIN:
+		return qed_mcp_nvm_put_file_begin(cdev, addr);
+	case QED_PUT_FILE_DATA:
+	case QED_NVM_WRITE_NVRAM:
+		return qed_mcp_nvm_write(cdev, cmd, addr, buf, len);
+	case QED_NVM_SET_SECURE_MODE:
+		return qed_mcp_nvm_set_secure_mode(cdev, addr);
+	default:
+		cdev->mcp_nvm_resp = FW_MSG_CODE_NVM_OPERATION_FAILED;
+		DP_NOTICE(cdev, "Unknown command %d\n", cmd);
+		return -EOPNOTSUPP;
+	}
+}
+
 static int qed_set_led(struct qed_dev *cdev, enum qed_led_mode mode)
 {
 	struct qed_hwfn *hwfn = QED_LEADING_HWFN(cdev);
@@ -1203,5 +1238,7 @@ const struct qed_common_ops qed_common_ops_pass = {
 	.update_msglvl = &qed_init_dp,
 	.chain_alloc = &qed_chain_alloc,
 	.chain_free = &qed_chain_free,
+	.nvm_get_cmd = &qed_nvm_get_cmd,
+	.nvm_set_cmd = &qed_nvm_set_cmd,
 	.set_led = &qed_set_led,
 };
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index b89c9a8..1812ff9 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -395,6 +395,60 @@ int qed_mcp_cmd(struct qed_hwfn *p_hwfn,
 	return 0;
 }
 
+static int qed_mcp_nvm_wr_cmd(struct qed_hwfn *p_hwfn,
+			      struct qed_ptt *p_ptt,
+			      u32 cmd, u32 param,
+			      u32 *o_mcp_resp, u32 *o_mcp_param,
+			      u32 i_txn_size, u32 *i_buf)
+{
+	struct qed_mcp_mb_params mb_params;
+	union drv_union_data union_data;
+	int rc;
+
+	memset(&mb_params, 0, sizeof(mb_params));
+	mb_params.cmd = cmd;
+	mb_params.param = param;
+	memcpy(&union_data.raw_data, i_buf, i_txn_size);
+	mb_params.p_data_src = &union_data;
+
+	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
+	if (rc)
+		return rc;
+
+	*o_mcp_resp = mb_params.mcp_resp;
+	*o_mcp_param = mb_params.mcp_param;
+
+	return 0;
+}
+
+static int qed_mcp_nvm_rd_cmd(struct qed_hwfn *p_hwfn,
+			      struct qed_ptt *p_ptt,
+			      u32 cmd, u32 param,
+			      u32 *o_mcp_resp, u32 *o_mcp_param,
+			      u32 *o_txn_size, u32 *o_buf)
+{
+	struct qed_mcp_mb_params mb_params;
+	union drv_union_data union_data;
+	int rc;
+
+	memset(&mb_params, 0, sizeof(mb_params));
+	mb_params.cmd = cmd;
+	mb_params.param = param;
+	mb_params.p_data_dst = &union_data;
+
+	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
+	if (rc)
+		return rc;
+
+	*o_mcp_resp = mb_params.mcp_resp;
+	*o_mcp_param = mb_params.mcp_param;
+
+	*o_txn_size = *o_mcp_param;
+	memcpy(o_buf, &union_data.raw_data, *o_txn_size);
+
+	return 0;
+}
+
 int qed_mcp_load_req(struct qed_hwfn *p_hwfn,
 		     struct qed_ptt *p_ptt,
 		     u32 *p_load_code)
@@ -908,6 +962,43 @@ int qed_mcp_drain(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
+static int qed_mcp_nvm_command(struct qed_hwfn *p_hwfn,
+			       struct qed_ptt *p_ptt,
+			       struct qed_mcp_nvm_params *params)
+{
+	int rc;
+
+	switch (params->type) {
+	case QED_MCP_NVM_RD:
+		rc = qed_mcp_nvm_rd_cmd(p_hwfn, p_ptt, params->nvm_common.cmd,
+					params->nvm_common.offset,
+					&params->nvm_common.resp,
+					&params->nvm_common.param,
+					params->nvm_rd.buf_size,
+					params->nvm_rd.buf);
+		break;
+	case QED_MCP_CMD:
+		rc = qed_mcp_cmd(p_hwfn, p_ptt, params->nvm_common.cmd,
+				 params->nvm_common.offset,
+				 &params->nvm_common.resp,
+				 &params->nvm_common.param);
+		break;
+	case QED_MCP_NVM_WR:
+		rc = qed_mcp_nvm_wr_cmd(p_hwfn, p_ptt, params->nvm_common.cmd,
+					params->nvm_common.offset,
+					&params->nvm_common.resp,
+					&params->nvm_common.param,
+					params->nvm_wr.buf_size,
+					params->nvm_wr.buf);
+		break;
+	default:
+		rc = -EINVAL;
+		break;
+	}
+
+	return rc;
+}
+
 int qed_mcp_get_flash_size(struct qed_hwfn *p_hwfn,
 			   struct qed_ptt *p_ptt,
 			   u32 *p_flash_size)
@@ -979,3 +1070,186 @@ int qed_mcp_set_led(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 
 	return rc;
 }
+
+int qed_mcp_nvm_read(struct qed_dev *cdev,
+		     u32 addr,
+		     u8 *p_buf,
+		     u32 len)
+{
+	u32 bytes_left = len, offset = 0, bytes_to_copy, buf_size;
+	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_mcp_nvm_params params;
+	struct qed_ptt *p_ptt;
+	int rc = 0;
+
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt)
+		return -EBUSY;
+
+	memset(&params, 0, sizeof(struct qed_mcp_nvm_params));
+	params.type = QED_MCP_NVM_RD;
+	params.nvm_rd.buf_size = &buf_size;
+	params.nvm_common.cmd = DRV_MSG_CODE_NVM_READ_NVRAM;
+
+	while (bytes_left > 0) {
+		bytes_to_copy = min_t(u32, bytes_left,
+				      MCP_DRV_NVM_BUF_LEN);
+		params.nvm_common.offset = (addr + offset) |
+					   (bytes_to_copy <<
+					    DRV_MB_PARAM_NVM_LEN_SHIFT);
+		params.nvm_rd.buf = (u32 *)(p_buf + offset);
+
+		rc = qed_mcp_nvm_command(p_hwfn, p_ptt, &params);
+		if (rc || (params.nvm_common.resp != FW_MSG_CODE_NVM_OK)) {
+			DP_NOTICE(cdev, "MCP command rc = %d\n",
+				  rc);
+			break;
+		}
+
+		offset += *params.nvm_rd.buf_size;
+		bytes_left -= *params.nvm_rd.buf_size;
+	}
+
+	cdev->mcp_nvm_resp = params.nvm_common.resp;
+	qed_ptt_release(p_hwfn, p_ptt);
+
+	return rc;
+}
+
+int qed_mcp_nvm_resp(struct qed_dev *cdev,
+		     u8 *p_buf)
+{
+	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_mcp_nvm_params params;
+	struct qed_ptt *p_ptt;
+
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt)
+		return -EBUSY;
+
+	memset(&params, 0, sizeof(struct qed_mcp_nvm_params));
+	memcpy(p_buf, &cdev->mcp_nvm_resp, sizeof(cdev->mcp_nvm_resp));
+	qed_ptt_release(p_hwfn, p_ptt);
+
+	return 0;
+}
+
+int qed_mcp_nvm_del_file(struct qed_dev *cdev,
+			 u32 addr)
+{
+	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_mcp_nvm_params params;
+	struct qed_ptt *p_ptt;
+	int rc;
+
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt)
+		return -EBUSY;
+
+	memset(&params, 0, sizeof(struct qed_mcp_nvm_params));
+	params.type = QED_MCP_CMD;
+	params.nvm_common.cmd = DRV_MSG_CODE_NVM_DEL_FILE;
+	params.nvm_common.offset = addr;
+
+	rc = qed_mcp_nvm_command(p_hwfn, p_ptt, &params);
+	cdev->mcp_nvm_resp = params.nvm_common.resp;
+	qed_ptt_release(p_hwfn, p_ptt);
+
+	return rc;
+}
+
+int qed_mcp_nvm_put_file_begin(struct qed_dev *cdev,
+			       u32 addr)
+{
+	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_mcp_nvm_params params;
+	struct qed_ptt *p_ptt;
+	int rc;
+
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt)
+		return -EBUSY;
+
+	memset(&params, 0, sizeof(struct qed_mcp_nvm_params));
+	params.type = QED_MCP_CMD;
+	params.nvm_common.cmd = DRV_MSG_CODE_NVM_PUT_FILE_BEGIN;
+	params.nvm_common.offset = addr;
+
+	rc = qed_mcp_nvm_command(p_hwfn, p_ptt, &params);
+	cdev->mcp_nvm_resp = params.nvm_common.resp;
+	qed_ptt_release(p_hwfn, p_ptt);
+
+	return rc;
+}
+
+int qed_mcp_nvm_write(struct qed_dev *cdev,
+		      u32 cmd,
+		      u32 addr,
+		      u8 *p_buf,
+		      u32 len)
+{
+	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_mcp_nvm_params params;
+	struct qed_ptt *p_ptt;
+	u32 buf_idx = 0, buf_size;
+	int rc = -EINVAL;
+
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt)
+		return -EBUSY;
+
+	memset(&params, 0, sizeof(struct qed_mcp_nvm_params));
+	params.type = QED_MCP_NVM_WR;
+	if (cmd == QED_PUT_FILE_DATA)
+		params.nvm_common.cmd = DRV_MSG_CODE_NVM_PUT_FILE_DATA;
+	else
+		params.nvm_common.cmd = DRV_MSG_CODE_NVM_WRITE_NVRAM;
+
+	while (buf_idx < len) {
+		buf_size = min_t(u32, (len - buf_idx),
+				 MCP_DRV_NVM_BUF_LEN);
+		params.nvm_common.offset = ((buf_size <<
+					     DRV_MB_PARAM_NVM_LEN_SHIFT) |
+					    addr) + buf_idx;
+		params.nvm_wr.buf_size	= buf_size;
+		params.nvm_wr.buf = (u32 *)&p_buf[buf_idx];
+
+		rc = qed_mcp_nvm_command(p_hwfn, p_ptt, &params);
+		if (rc ||
+		    ((params.nvm_common.resp != FW_MSG_CODE_NVM_OK) &&
+		     (params.nvm_common.resp !=
+		      FW_MSG_CODE_NVM_PUT_FILE_FINISH_OK)))
+			DP_NOTICE(cdev, "MCP command rc = %d\n", rc);
+
+		buf_idx += buf_size;
+	}
+
+	cdev->mcp_nvm_resp = params.nvm_common.resp;
+	qed_ptt_release(p_hwfn, p_ptt);
+
+	return rc;
+}
+
+int qed_mcp_nvm_set_secure_mode(struct qed_dev *cdev,
+				u32 addr)
+{
+	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
+	struct qed_mcp_nvm_params params;
+	struct qed_ptt *p_ptt;
+	int rc;
+
+	p_ptt = qed_ptt_acquire(p_hwfn);
+	if (!p_ptt)
+		return -EBUSY;
+
+	memset(&params, 0, sizeof(struct qed_mcp_nvm_params));
+	params.type = QED_MCP_CMD;
+	params.nvm_common.cmd = DRV_MSG_CODE_SET_SECURE_MODE;
+	params.nvm_common.offset = addr;
+
+	rc =  qed_mcp_nvm_command(p_hwfn, p_ptt, &params);
+	cdev->mcp_nvm_resp = params.nvm_common.resp;
+	qed_ptt_release(p_hwfn, p_ptt);
+
+	return rc;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.h b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
index 50917a2..ab0f0a5 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
@@ -92,6 +92,33 @@ struct qed_mcp_nvm_common {
 	u32	cmd;
 };
 
+struct qed_mcp_nvm_rd {
+	u32	*buf_size;
+	u32	*buf;
+};
+
+struct qed_mcp_nvm_wr {
+	u32	buf_size;
+	u32	*buf;
+};
+
+enum qed_mcp_num_parameters_type {
+	QED_MCP_CMD,
+	QED_MCP_NVM_RD,
+	QED_MCP_NVM_WR,
+};
+
+struct qed_mcp_nvm_params {
+	enum qed_mcp_num_parameters_type	type;
+
+	struct qed_mcp_nvm_common		nvm_common;
+
+	union {
+		struct qed_mcp_nvm_rd		nvm_rd;
+		struct qed_mcp_nvm_wr		nvm_wr;
+	};
+};
+
 struct qed_mcp_drv_version {
 	u32	version;
 	u8	name[MCP_DRV_VER_STR_SIZE - 4];
@@ -237,6 +264,82 @@ int qed_mcp_set_led(struct qed_hwfn *p_hwfn,
 		    struct qed_ptt *p_ptt,
 		    enum qed_led_mode mode);
 
+/**
+ * @brief Change security mode to allow writing faulty boards
+ *
+ *  @param cdev
+ *  @param addr - nvm offset
+ *
+ * @return int - 0 - operation was successful.
+ */
+int qed_mcp_nvm_set_secure_mode(struct qed_dev *cdev,
+				u32 addr);
+
+/**
+ * @brief Write to nvm
+ *
+ *  @param cdev
+ *  @param addr - nvm offset
+ *  @param cmd - nvm command
+ *  @param p_buf - nvm write buffer
+ *  @param len - buffer len
+ *
+ * @return int - 0 - operation was successful.
+ */
+int qed_mcp_nvm_write(struct qed_dev *cdev,
+		      u32 cmd,
+		      u32 addr,
+		      u8 *p_buf,
+		      u32 len);
+
+/**
+ * @brief Write a file image to nvram
+ *
+ *  @param cdev
+ *  @param addr - nvm offset
+ *
+ * @return int - 0 - operation was successful.
+ */
+int qed_mcp_nvm_put_file_begin(struct qed_dev *cdev,
+			       u32 addr);
+
+/**
+ * @brief Delete a file image from nvram
+ *
+ *  @param cdev
+ *  @param addr - nvm offset
+ *
+ * @return int - 0 - operation was successful.
+ */
+int qed_mcp_nvm_del_file(struct qed_dev *cdev,
+			 u32 addr);
+
+/**
+ * @brief Check latest mfw response in regard to nvm access
+ *
+ *  @param cdev
+ *  @param p_buf - nvm write buffer
+ *
+ * @return int - 0 - operation was successful.
+ */
+int qed_mcp_nvm_resp(struct qed_dev *cdev,
+		     u8 *p_buf);
+
+/**
+ * @brief Read from nvm
+ *
+ *  @param cdev
+ *  @param addr - nvm offset
+ *  @param p_buf - nvm write buffer
+ *  @param len - buffer len
+ *
+ * @return int - 0 - operation was successful.
+ */
+int qed_mcp_nvm_read(struct qed_dev *cdev,
+		     u32 addr,
+		     u8	*p_buf,
+		     u32 len);
+
 /* Using hwfn number (and not pf_num) is required since in CMT mode,
  * same pf_num may be used by two different hwfn
  * TODO - this shouldn't really be in .h file, but until all fields
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 0f11685..50580d2 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -389,6 +389,33 @@ static u32 qede_get_link(struct net_device *dev)
 	return current_link.link_up;
 }
 
+static int qede_get_eeprom_len(struct net_device *ndev)
+{
+	struct qede_dev *edev = netdev_priv(ndev);
+
+	return edev->dev_info.common.flash_size;
+}
+
+static int qede_get_eeprom(struct net_device *dev,
+			    struct ethtool_eeprom *eeprom, u8 *eebuf)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	return edev->ops->common->nvm_get_cmd(edev->cdev, eeprom->magic,
+					      eeprom->offset, eebuf,
+					      eeprom->len);
+}
+
+static int qede_set_eeprom(struct net_device *dev,
+			    struct ethtool_eeprom *eeprom, u8 *eebuf)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	return edev->ops->common->nvm_set_cmd(edev->cdev, eeprom->magic,
+					      eeprom->offset, eebuf,
+					      eeprom->len);
+}
+
 static void qede_get_ringparam(struct net_device *dev,
 			       struct ethtool_ringparam *ering)
 {
@@ -839,6 +866,9 @@ static const struct ethtool_ops qede_ethtool_ops = {
 	.set_msglevel = qede_set_msglevel,
 	.nway_reset = qede_nway_reset,
 	.get_link = qede_get_link,
+	.get_eeprom_len = qede_get_eeprom_len,
+	.get_eeprom = qede_get_eeprom,
+	.set_eeprom = qede_set_eeprom,
 	.get_ringparam = qede_get_ringparam,
 	.set_ringparam = qede_set_ringparam,
 	.get_pauseparam = qede_get_pauseparam,
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index e5de42b..497cce9 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -270,6 +270,36 @@ struct qed_common_ops {
 				      struct qed_chain *p_chain);
 
 /**
+ * @brief nvm_get_cmd - Invoke mcp nvm get command
+ *
+ * @param cdev
+ * @param cmd - qed_mcp command
+ * @param offset
+ * @param buf - buffer
+ * @param len - buffer length
+ *
+ * @return 0 on success, error otherwise.
+ */
+	int (*nvm_get_cmd)(struct qed_dev *cdev,
+			   u32 cmd, u32 offset,
+			   u8 *buf, u32 len);
+
+/**
+ * @brief nvm_put_cmd - Invoke mcp nvm get command
+ *
+ * @param cdev
+ * @param cmd - qed_mcp command
+ * @param offset
+ * @param buf - buffer
+ * @param len - buffer length
+ *
+ * @return 0 on success, error otherwise.
+ */
+	int (*nvm_set_cmd)(struct qed_dev *cdev,
+			   u32 cmd, u32 offset,
+			   u8 *buf, u32 len);
+
+/**
  * @brief set_led - Configure LED mode
  *
  * @param cdev
-- 
1.9.3
