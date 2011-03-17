From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next-2.6] be2net: Support for FAT dump retrieval using ethtool --register-dump option
Date: Thu, 17 Mar 2011 12:52:43 +0530
Message-ID: <b5be727a-4805-4ac5-b288-1beba1649057@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:42664 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751647Ab1CQHYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 03:24:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/benet/be_cmds.c    |  107 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/benet/be_cmds.h    |   21 ++++++++
 drivers/net/benet/be_ethtool.c |   21 ++++++++
 drivers/net/benet/be_hw.h      |    4 ++
 4 files changed, 153 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 5a4a87e..2aadf88 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1186,6 +1186,113 @@ err:
 	return status;
 }
 
+/* Uses synchronous mcc */
+int be_cmd_get_reg_len(struct be_adapter *adapter, u32 *log_size)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_get_fat *req;
+	int status;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+	req = embedded_payload(wrb);
+
+	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0,
+			OPCODE_COMMON_MANAGE_FAT);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_MANAGE_FAT, sizeof(*req));
+	req->fat_operation = cpu_to_le32(QUERY_FAT);
+	status = be_mcc_notify_wait(adapter);
+	if (!status) {
+		struct be_cmd_resp_get_fat *resp = embedded_payload(wrb);
+		if (log_size && resp->log_size)
+			*log_size = le32_to_cpu(resp->log_size -
+					sizeof(u32));
+	}
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
+void be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf)
+{
+	struct be_dma_mem get_fat_cmd;
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_get_fat *req;
+	struct be_sge *sge;
+	u32 offset = 0, total_size, buf_size, log_offset = sizeof(u32);
+	int status;
+
+	if (buf_len == 0)
+		return;
+
+	total_size = buf_len;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
+	while (total_size) {
+		buf_size = min(total_size, (u32)60*1024);
+		total_size -= buf_size;
+
+		get_fat_cmd.size = sizeof(struct be_cmd_req_get_fat) + buf_size;
+		get_fat_cmd.va = pci_alloc_consistent(adapter->pdev,
+					get_fat_cmd.size,
+					&get_fat_cmd.dma);
+		if (!get_fat_cmd.va) {
+			status = -ENOMEM;
+			dev_err(&adapter->pdev->dev,
+					"Memory allocation failure while retrieving FAT data\n");
+			goto err;
+		}
+		req = get_fat_cmd.va;
+		sge = nonembedded_sgl(wrb);
+
+		be_wrb_hdr_prepare(wrb, get_fat_cmd.size, false, 1,
+				OPCODE_COMMON_MANAGE_FAT);
+
+		be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+				OPCODE_COMMON_MANAGE_FAT, get_fat_cmd.size);
+
+		sge->pa_hi = cpu_to_le32(upper_32_bits(get_fat_cmd.size));
+		sge->pa_lo = cpu_to_le32(get_fat_cmd.dma & 0xFFFFFFFF);
+		sge->len = cpu_to_le32(get_fat_cmd.size);
+
+		req->fat_operation = cpu_to_le32(RETRIEVE_FAT);
+		req->read_log_offset = cpu_to_le32(log_offset);
+		req->read_log_length = cpu_to_le32(buf_size);
+		req->data_buffer_size = cpu_to_le32(buf_size);
+
+		status = be_mcc_notify_wait(adapter);
+		if (!status) {
+			struct be_cmd_resp_get_fat *resp = get_fat_cmd.va;
+			memcpy(buf + offset,
+				resp->data_buffer,
+				resp->read_log_length);
+		}
+		pci_free_consistent(adapter->pdev, get_fat_cmd.size,
+				get_fat_cmd.va,
+				get_fat_cmd.dma);
+		if (status)
+			dev_err(&adapter->pdev->dev, "FAT Table Retrieve error\n");
+
+		offset += buf_size;
+		log_offset += buf_size;
+	}
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
+}
+
 /* Uses Mbox */
 int be_cmd_get_fw_ver(struct be_adapter *adapter, char *fw_ver)
 {
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 4f254cf..3fb6e0a 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -186,6 +186,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_NTWK_PMAC_ADD			59
 #define OPCODE_COMMON_NTWK_PMAC_DEL			60
 #define OPCODE_COMMON_FUNCTION_RESET			61
+#define OPCODE_COMMON_MANAGE_FAT			68
 #define OPCODE_COMMON_ENABLE_DISABLE_BEACON		69
 #define OPCODE_COMMON_GET_BEACON_STATE			70
 #define OPCODE_COMMON_READ_TRANSRECV_DATA		73
@@ -380,6 +381,24 @@ struct be_cmd_resp_cq_create {
 	u16 rsvd0;
 } __packed;
 
+struct be_cmd_req_get_fat {
+	struct be_cmd_req_hdr hdr;
+	u32 fat_operation;
+	u32 read_log_offset;
+	u32 read_log_length;
+	u32 data_buffer_size;
+	u32 data_buffer[1];
+} __packed;
+
+struct be_cmd_resp_get_fat {
+	struct be_cmd_resp_hdr hdr;
+	u32 log_size;
+	u32 read_log_length;
+	u32 rsvd[2];
+	u32 data_buffer[1];
+} __packed;
+
+
 /******************** Create MCCQ ***************************/
 /* Pseudo amap definition in which each bit of the actual structure is defined
  * as a byte: used to calculate offset/shift/mask of each field */
@@ -1148,4 +1167,6 @@ extern void be_detect_dump_ue(struct be_adapter *adapter);
 extern int be_cmd_get_die_temperature(struct be_adapter *adapter);
 extern int be_cmd_get_cntl_attributes(struct be_adapter *adapter);
 extern int be_cmd_check_native_mode(struct be_adapter *adapter);
+extern int be_cmd_get_reg_len(struct be_adapter *adapter, u32 *log_size);
+extern void be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf);
 
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index aac248f..575ac65 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -156,6 +156,25 @@ be_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
 }
 
 static int
+be_get_reg_len(struct net_device *netdev)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+	u32 log_size = 0;
+
+	be_cmd_get_reg_len(adapter, &log_size);
+	return log_size;
+}
+
+static void
+be_get_regs(struct net_device *netdev, struct ethtool_regs *regs, void *buf)
+{
+	struct be_adapter *adapter = netdev_priv(netdev);
+
+	memset(buf, 0, regs->len);
+	be_cmd_get_regs(adapter, regs->len, buf);
+}
+
+static int
 be_get_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
@@ -737,6 +756,8 @@ const struct ethtool_ops be_ethtool_ops = {
 	.phys_id = be_phys_id,
 	.get_sset_count = be_get_sset_count,
 	.get_ethtool_stats = be_get_ethtool_stats,
+	.get_regs_len = be_get_reg_len,
+	.get_regs = be_get_regs,
 	.flash_device = be_do_flash,
 	.self_test = be_self_test,
 };
diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index d4344a0..53d658a 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -155,6 +155,10 @@
 /********** SRIOV VF PCICFG OFFSET ********/
 #define SRIOV_VF_PCICFG_OFFSET		(4096)
 
+/********** FAT TABLE  ********/
+#define RETRIEVE_FAT	0
+#define QUERY_FAT	1
+
 /* Flashrom related descriptors */
 #define IMAGE_TYPE_FIRMWARE		160
 #define IMAGE_TYPE_BOOTCODE		224
-- 
1.5.6.1

