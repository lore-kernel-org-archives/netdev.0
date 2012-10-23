From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next] be2net: Fix smatch warnings in be_main.c
Date: Tue, 23 Oct 2012 14:32:44 +0530
Message-ID: <60b05fee-7c4f-42f9-ae31-be214fe65d41@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	Vasundhara Volam <vasundhara.volam@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:55215 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090Ab2JWJD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 05:03:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FW flashing code, even though it works correctly, makes some hidden
assumptions about buffer sizes. This is causing code analysers to
report error. Cleanup FW flashing code to remove these hidden assumptions.

Reported-by: Yuanhan Liu <yuanhan.liu@intel.com>
Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    7 ++++---
 drivers/net/ethernet/emulex/benet/be_cmds.h |   12 ++++++++++--
 drivers/net/ethernet/emulex/benet/be_main.c |    4 ++--
 3 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 8d35750..7ea1ea4 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2160,7 +2160,7 @@ int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc,
 			 int offset)
 {
 	struct be_mcc_wrb *wrb;
-	struct be_cmd_write_flashrom *req;
+	struct be_cmd_read_flash_crc *req;
 	int status;
 
 	spin_lock_bh(&adapter->mcc_lock);
@@ -2173,7 +2173,8 @@ int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc,
 	req = embedded_payload(wrb);
 
 	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_READ_FLASHROM, sizeof(*req)+4, wrb, NULL);
+			       OPCODE_COMMON_READ_FLASHROM, sizeof(*req),
+			       wrb, NULL);
 
 	req->params.op_type = cpu_to_le32(OPTYPE_REDBOOT);
 	req->params.op_code = cpu_to_le32(FLASHROM_OPER_REPORT);
@@ -2182,7 +2183,7 @@ int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc,
 
 	status = be_mcc_notify_wait(adapter);
 	if (!status)
-		memcpy(flashed_crc, req->params.data_buf, 4);
+		memcpy(flashed_crc, req->crc, 4);
 
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 68de6c6..06fc227 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1156,14 +1156,22 @@ struct flashrom_params {
 	u32 op_type;
 	u32 data_buf_size;
 	u32 offset;
-	u8 data_buf[4];
 };
 
 struct be_cmd_write_flashrom {
 	struct be_cmd_req_hdr hdr;
 	struct flashrom_params params;
-};
+	u8 data_buf[32768];
+	u8 rsvd[4];
+} __packed;
 
+/* cmd to read flash crc */
+struct be_cmd_read_flash_crc {
+	struct be_cmd_req_hdr hdr;
+	struct flashrom_params params;
+	u8 crc[4];
+	u8 rsvd[4];
+};
 /**************** Lancer Firmware Flash ************/
 struct amap_lancer_write_obj_context {
 	u8 write_length[24];
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 68665da..5e48674 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3114,7 +3114,7 @@ static int be_flash(struct be_adapter *adapter, const u8 *img,
 				flash_op = FLASHROM_OPER_SAVE;
 		}
 
-		memcpy(req->params.data_buf, img, num_bytes);
+		memcpy(req->data_buf, img, num_bytes);
 		img += num_bytes;
 		status = be_cmd_write_flashrom(adapter, flash_cmd, optype,
 						flash_op, num_bytes);
@@ -3471,7 +3471,7 @@ static int be_fw_download(struct be_adapter *adapter, const struct firmware* fw)
 	const u8 *p;
 	int status = 0, i = 0, num_imgs = 0, ufi_type = 0;
 
-	flash_cmd.size = sizeof(struct be_cmd_write_flashrom) + 32*1024;
+	flash_cmd.size = sizeof(struct be_cmd_write_flashrom);
 	flash_cmd.va = dma_alloc_coherent(&adapter->pdev->dev, flash_cmd.size,
 					  &flash_cmd.dma, GFP_KERNEL);
 	if (!flash_cmd.va) {
-- 
1.6.0.2
