From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 3/3] be2net: FW download for Lancer
Date: Mon, 16 May 2011 23:06:59 +0530
Message-ID: <5d4795b3-0429-433a-abf2-15353934396c@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	Shripad Nunjundarao <shripad.nunjundarao@emulex.com>,
	Sevin Xavier <selvin.xavier@emulex.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:37891 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753870Ab1EPRhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 13:37:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shripad Nunjundarao <shripad.nunjundarao@emulex.com>

Added implementation of FW download feature for Lancer.

Signed-off-by: Shripad Nunjundarao <shripad.nunjundarao@emulex.com>
Signed-off-by: Sevin Xavier <selvin.xavier@emulex.com>
Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/benet/be_cmds.c |   78 +++++++++++++++++++++++++-
 drivers/net/benet/be_cmds.h |   36 ++++++++++++
 drivers/net/benet/be_main.c |  129 ++++++++++++++++++++++++++++++++++++------
 3 files changed, 223 insertions(+), 20 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index aaef0c7..2463b1c 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -71,7 +71,8 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 	compl_status = (compl->status >> CQE_STATUS_COMPL_SHIFT) &
 				CQE_STATUS_COMPL_MASK;
 
-	if ((compl->tag0 == OPCODE_COMMON_WRITE_FLASHROM) &&
+	if (((compl->tag0 == OPCODE_COMMON_WRITE_FLASHROM) ||
+		(compl->tag0 == OPCODE_COMMON_WRITE_OBJECT)) &&
 		(compl->tag1 == CMD_SUBSYSTEM_COMMON)) {
 		adapter->flash_status = compl_status;
 		complete(&adapter->flash_compl);
@@ -1801,6 +1802,81 @@ err:
 	return status;
 }
 
+int lancer_cmd_write_object(struct be_adapter *adapter, struct be_dma_mem *cmd,
+			u32 data_size, u32 data_offset, const char *obj_name,
+			u32 *data_written, u8 *addn_status)
+{
+	struct be_mcc_wrb *wrb;
+	struct lancer_cmd_req_write_object *req;
+	struct lancer_cmd_resp_write_object *resp;
+	void *ctxt = NULL;
+	int status;
+
+	spin_lock_bh(&adapter->mcc_lock);
+	adapter->flash_status = 0;
+
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err_unlock;
+	}
+
+	req = embedded_payload(wrb);
+
+	be_wrb_hdr_prepare(wrb, sizeof(struct lancer_cmd_req_write_object),
+			true, 1, OPCODE_COMMON_WRITE_OBJECT);
+	wrb->tag1 = CMD_SUBSYSTEM_COMMON;
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+				OPCODE_COMMON_WRITE_OBJECT,
+				sizeof(struct lancer_cmd_req_write_object));
+
+	ctxt = &req->context;
+	AMAP_SET_BITS(struct amap_lancer_write_obj_context,
+			write_length, ctxt, data_size);
+
+	if (data_size == 0)
+		AMAP_SET_BITS(struct amap_lancer_write_obj_context,
+				eof, ctxt, 1);
+	else
+		AMAP_SET_BITS(struct amap_lancer_write_obj_context,
+				eof, ctxt, 0);
+
+	be_dws_cpu_to_le(ctxt, sizeof(req->context));
+	req->write_offset = cpu_to_le32(data_offset);
+	strcpy(req->object_name, obj_name);
+	req->descriptor_count = cpu_to_le32(1);
+	req->buf_len = cpu_to_le32(data_size);
+	req->addr_low = cpu_to_le32((cmd->dma +
+				sizeof(struct lancer_cmd_req_write_object))
+				& 0xFFFFFFFF);
+	req->addr_high = cpu_to_le32(upper_32_bits(cmd->dma +
+				sizeof(struct lancer_cmd_req_write_object)));
+
+	be_mcc_notify(adapter);
+	spin_unlock_bh(&adapter->mcc_lock);
+
+	if (!wait_for_completion_timeout(&adapter->flash_compl,
+			msecs_to_jiffies(12000)))
+		status = -1;
+	else
+		status = adapter->flash_status;
+
+	resp = embedded_payload(wrb);
+	if (!status) {
+		*data_written = le32_to_cpu(resp->actual_write_len);
+	} else {
+		*addn_status = resp->additional_status;
+		status = resp->status;
+	}
+
+	return status;
+
+err_unlock:
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
+
 int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
 			u32 flash_type, u32 flash_opcode, u32 buf_size)
 {
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 9cff226..8148cc6 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -193,6 +193,7 @@ struct be_mcc_mailbox {
 #define OPCODE_COMMON_GET_PHY_DETAILS			102
 #define OPCODE_COMMON_SET_DRIVER_FUNCTION_CAP		103
 #define OPCODE_COMMON_GET_CNTL_ADDITIONAL_ATTRIBUTES	121
+#define OPCODE_COMMON_WRITE_OBJECT			172
 
 #define OPCODE_ETH_RSS_CONFIG				1
 #define OPCODE_ETH_ACPI_CONFIG				2
@@ -1131,6 +1132,36 @@ struct be_cmd_write_flashrom {
 	struct flashrom_params params;
 };
 
+/**************** Lancer Firmware Flash ************/
+struct amap_lancer_write_obj_context {
+	u8 write_length[24];
+	u8 reserved1[7];
+	u8 eof;
+} __packed;
+
+struct lancer_cmd_req_write_object {
+	struct be_cmd_req_hdr hdr;
+	u8 context[sizeof(struct amap_lancer_write_obj_context) / 8];
+	u32 write_offset;
+	u8 object_name[104];
+	u32 descriptor_count;
+	u32 buf_len;
+	u32 addr_low;
+	u32 addr_high;
+};
+
+struct lancer_cmd_resp_write_object {
+	u8 opcode;
+	u8 subsystem;
+	u8 rsvd1[2];
+	u8 status;
+	u8 additional_status;
+	u8 rsvd2[2];
+	u32 resp_len;
+	u32 actual_resp_len;
+	u32 actual_write_len;
+};
+
 /************************ WOL *******************************/
 struct be_cmd_req_acpi_wol_magic_config{
 	struct be_cmd_req_hdr hdr;
@@ -1481,6 +1512,11 @@ extern int be_cmd_get_beacon_state(struct be_adapter *adapter,
 extern int be_cmd_write_flashrom(struct be_adapter *adapter,
 			struct be_dma_mem *cmd, u32 flash_oper,
 			u32 flash_opcode, u32 buf_size);
+extern int lancer_cmd_write_object(struct be_adapter *adapter,
+				struct be_dma_mem *cmd,
+				u32 data_size, u32 data_offset,
+				const char *obj_name,
+				u32 *data_written, u8 *addn_status);
 int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc,
 				int offset);
 extern int be_cmd_enable_magic_wol(struct be_adapter *adapter, u8 *mac,
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 93be84c..7322a51 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2712,7 +2712,6 @@ static int be_flash_data(struct be_adapter *adapter,
 					"cmd to write to flash rom failed.\n");
 				return -1;
 			}
-			yield();
 		}
 	}
 	return 0;
@@ -2730,32 +2729,98 @@ static int get_ufigen_type(struct flash_file_hdr_g2 *fhdr)
 		return 0;
 }
 
-int be_load_fw(struct be_adapter *adapter, u8 *func)
+static int lancer_fw_download(struct be_adapter *adapter,
+				const struct firmware *fw)
 {
-	char fw_file[ETHTOOL_FLASH_MAX_FILENAME];
-	const struct firmware *fw;
-	struct flash_file_hdr_g2 *fhdr;
-	struct flash_file_hdr_g3 *fhdr3;
-	struct image_hdr *img_hdr_ptr = NULL;
+#define LANCER_FW_DOWNLOAD_CHUNK      (32 * 1024)
+#define LANCER_FW_DOWNLOAD_LOCATION   "/prg"
 	struct be_dma_mem flash_cmd;
-	int status, i = 0, num_imgs = 0;
-	const u8 *p;
+	struct lancer_cmd_req_write_object *req;
+	const u8 *data_ptr = NULL;
+	u8 *dest_image_ptr = NULL;
+	size_t image_size = 0;
+	u32 chunk_size = 0;
+	u32 data_written = 0;
+	u32 offset = 0;
+	int status = 0;
+	u8 add_status = 0;
 
-	if (!netif_running(adapter->netdev)) {
+	if (!IS_ALIGNED(fw->size, sizeof(u32))) {
 		dev_err(&adapter->pdev->dev,
-			"Firmware load not allowed (interface is down)\n");
-		return -EPERM;
+			"FW Image not properly aligned. "
+			"Length must be 4 byte aligned.\n");
+		status = -EINVAL;
+		goto lancer_fw_exit;
 	}
 
-	strcpy(fw_file, func);
+	flash_cmd.size = sizeof(struct lancer_cmd_req_write_object)
+				+ LANCER_FW_DOWNLOAD_CHUNK;
+	flash_cmd.va = dma_alloc_coherent(&adapter->pdev->dev, flash_cmd.size,
+						&flash_cmd.dma, GFP_KERNEL);
+	if (!flash_cmd.va) {
+		status = -ENOMEM;
+		dev_err(&adapter->pdev->dev,
+			"Memory allocation failure while flashing\n");
+		goto lancer_fw_exit;
+	}
 
-	status = request_firmware(&fw, fw_file, &adapter->pdev->dev);
-	if (status)
-		goto fw_exit;
+	req = flash_cmd.va;
+	dest_image_ptr = flash_cmd.va +
+				sizeof(struct lancer_cmd_req_write_object);
+	image_size = fw->size;
+	data_ptr = fw->data;
+
+	while (image_size) {
+		chunk_size = min_t(u32, image_size, LANCER_FW_DOWNLOAD_CHUNK);
+
+		/* Copy the image chunk content. */
+		memcpy(dest_image_ptr, data_ptr, chunk_size);
+
+		status = lancer_cmd_write_object(adapter, &flash_cmd,
+				chunk_size, offset, LANCER_FW_DOWNLOAD_LOCATION,
+				&data_written, &add_status);
+
+		if (status)
+			break;
+
+		offset += data_written;
+		data_ptr += data_written;
+		image_size -= data_written;
+	}
+
+	if (!status) {
+		/* Commit the FW written */
+		status = lancer_cmd_write_object(adapter, &flash_cmd,
+					0, offset, LANCER_FW_DOWNLOAD_LOCATION,
+					&data_written, &add_status);
+	}
+
+	dma_free_coherent(&adapter->pdev->dev, flash_cmd.size, flash_cmd.va,
+				flash_cmd.dma);
+	if (status) {
+		dev_err(&adapter->pdev->dev,
+			"Firmware load error. "
+			"Status code: 0x%x Additional Status: 0x%x\n",
+			status, add_status);
+		goto lancer_fw_exit;
+	}
+
+	dev_info(&adapter->pdev->dev, "Firmware flashed successfully\n");
+lancer_fw_exit:
+	return status;
+}
+
+static int be_fw_download(struct be_adapter *adapter, const struct firmware* fw)
+{
+	struct flash_file_hdr_g2 *fhdr;
+	struct flash_file_hdr_g3 *fhdr3;
+	struct image_hdr *img_hdr_ptr = NULL;
+	struct be_dma_mem flash_cmd;
+	const u8 *p;
+	int status = 0, i = 0, num_imgs = 0;
 
 	p = fw->data;
 	fhdr = (struct flash_file_hdr_g2 *) p;
-	dev_info(&adapter->pdev->dev, "Flashing firmware file %s\n", fw_file);
 
 	flash_cmd.size = sizeof(struct be_cmd_write_flashrom) + 32*1024;
 	flash_cmd.va = dma_alloc_coherent(&adapter->pdev->dev, flash_cmd.size,
@@ -2764,7 +2829,7 @@ int be_load_fw(struct be_adapter *adapter, u8 *func)
 		status = -ENOMEM;
 		dev_err(&adapter->pdev->dev,
 			"Memory allocation failure while flashing\n");
-		goto fw_exit;
+		goto be_fw_exit;
 	}
 
 	if ((adapter->generation == BE_GEN3) &&
@@ -2792,11 +2857,37 @@ int be_load_fw(struct be_adapter *adapter, u8 *func)
 			  flash_cmd.dma);
 	if (status) {
 		dev_err(&adapter->pdev->dev, "Firmware load error\n");
-		goto fw_exit;
+		goto be_fw_exit;
 	}
 
 	dev_info(&adapter->pdev->dev, "Firmware flashed successfully\n");
 
+be_fw_exit:
+	return status;
+}
+
+int be_load_fw(struct be_adapter *adapter, u8 *fw_file)
+{
+	const struct firmware *fw;
+	int status;
+
+	if (!netif_running(adapter->netdev)) {
+		dev_err(&adapter->pdev->dev,
+			"Firmware load not allowed (interface is down)\n");
+		return -1;
+	}
+
+	status = request_firmware(&fw, fw_file, &adapter->pdev->dev);
+	if (status)
+		goto fw_exit;
+
+	dev_info(&adapter->pdev->dev, "Flashing firmware file %s\n", fw_file);
+
+	if (lancer_chip(adapter))
+		status = lancer_fw_download(adapter, fw);
+	else
+		status = be_fw_download(adapter, fw);
+
 fw_exit:
 	release_firmware(fw);
 	return status;
-- 
1.6.0.2

