From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 5/9] be2net: use offset based FW flashing for Skyhawk chip
Date: Fri, 6 Feb 2015 08:18:39 -0500
Message-ID: <1423228723-10919-6-git-send-email-sathya.perla@emulex.com>
References: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:28175 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754467AbbBFNPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 08:15:40 -0500
In-Reply-To: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

While sending FW update cmds to the FW, the driver specifies the "type"
of each component that needs to be flashed. The FW then picks the offset
in the flash area at which the componnet is to be flashed. This doesn't work
when new components that the current FW doesn't recognize, need to be
flashed. Recent FWs (10.2 and above) support a scheme of FW-update wherein
the "offset" of the component in the flash area can be specified instead
of the "type". This patch uses the "offset" based FW-update mechanism and
only when it fails, it fallsback to the old "type" based update.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 18 +++++---
 drivers/net/ethernet/emulex/benet/be_cmds.h |  6 ++-
 drivers/net/ethernet/emulex/benet/be_main.c | 65 ++++++++++++++++++++++-------
 3 files changed, 66 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 3a10145..2f59553 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2436,7 +2436,8 @@ err_unlock:
 }
 
 int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
-			  u32 flash_type, u32 flash_opcode, u32 buf_size)
+			  u32 flash_type, u32 flash_opcode, u32 img_offset,
+			  u32 buf_size)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_write_flashrom *req;
@@ -2457,6 +2458,9 @@ int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
 			       cmd);
 
 	req->params.op_type = cpu_to_le32(flash_type);
+	if (flash_type == OPTYPE_OFFSET_SPECIFIED)
+		req->params.offset = cpu_to_le32(img_offset);
+
 	req->params.op_code = cpu_to_le32(flash_opcode);
 	req->params.data_buf_size = cpu_to_le32(buf_size);
 
@@ -2477,10 +2481,10 @@ err_unlock:
 }
 
 int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc,
-			 u16 optype, int offset)
+			 u16 img_optype, u32 img_offset, u32 crc_offset)
 {
-	struct be_mcc_wrb *wrb;
 	struct be_cmd_read_flash_crc *req;
+	struct be_mcc_wrb *wrb;
 	int status;
 
 	spin_lock_bh(&adapter->mcc_lock);
@@ -2496,9 +2500,13 @@ int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc,
 			       OPCODE_COMMON_READ_FLASHROM, sizeof(*req),
 			       wrb, NULL);
 
-	req->params.op_type = cpu_to_le32(optype);
+	req->params.op_type = cpu_to_le32(img_optype);
+	if (img_optype == OPTYPE_OFFSET_SPECIFIED)
+		req->params.offset = cpu_to_le32(img_offset + crc_offset);
+	else
+		req->params.offset = cpu_to_le32(crc_offset);
+
 	req->params.op_code = cpu_to_le32(FLASHROM_OPER_REPORT);
-	req->params.offset = cpu_to_le32(offset);
 	req->params.data_buf_size = cpu_to_le32(0x4);
 
 	status = be_mcc_notify_wait(adapter);
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 774c5d1..402d64f 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1172,6 +1172,7 @@ struct be_cmd_resp_get_beacon_state {
 #define OPTYPE_REDBOOT			1
 #define OPTYPE_BIOS			2
 #define OPTYPE_PXE_BIOS			3
+#define OPTYPE_OFFSET_SPECIFIED		7
 #define OPTYPE_FCOE_BIOS		8
 #define OPTYPE_ISCSI_BACKUP		9
 #define OPTYPE_FCOE_FW_ACTIVE		10
@@ -2255,7 +2256,8 @@ int be_cmd_read_port_transceiver_data(struct be_adapter *adapter,
 				      u8 page_num, u8 *data);
 int be_cmd_query_cable_type(struct be_adapter *adapter);
 int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
-			  u32 flash_oper, u32 flash_opcode, u32 buf_size);
+			  u32 flash_oper, u32 flash_opcode, u32 img_offset,
+			  u32 buf_size);
 int lancer_cmd_write_object(struct be_adapter *adapter, struct be_dma_mem *cmd,
 			    u32 data_size, u32 data_offset,
 			    const char *obj_name, u32 *data_written,
@@ -2265,7 +2267,7 @@ int lancer_cmd_read_object(struct be_adapter *adapter, struct be_dma_mem *cmd,
 			   u32 *data_read, u32 *eof, u8 *addn_status);
 int lancer_cmd_delete_object(struct be_adapter *adapter, const char *obj_name);
 int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc,
-			  u16 optype, int offset);
+			 u16 img_optype, u32 img_offset, u32 crc_offset);
 int be_cmd_enable_magic_wol(struct be_adapter *adapter, u8 *mac,
 			    struct be_dma_mem *nonemb_cmd);
 int be_cmd_fw_init(struct be_adapter *adapter);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9eaf8bc..2ec1d80 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3942,7 +3942,8 @@ static int be_check_flash_crc(struct be_adapter *adapter, const u8 *p,
 	int status;
 	u8 crc[4];
 
-	status = be_cmd_get_flash_crc(adapter, crc, img_optype, img_size - 4);
+	status = be_cmd_get_flash_crc(adapter, crc, img_optype, img_offset,
+				      img_size - 4);
 	if (status)
 		return status;
 
@@ -3958,13 +3959,13 @@ static int be_check_flash_crc(struct be_adapter *adapter, const u8 *p,
 }
 
 static int be_flash(struct be_adapter *adapter, const u8 *img,
-		    struct be_dma_mem *flash_cmd, int optype, int img_size)
+		    struct be_dma_mem *flash_cmd, int optype, int img_size,
+		    u32 img_offset)
 {
+	u32 flash_op, num_bytes, total_bytes = img_size, bytes_sent = 0;
 	struct be_cmd_write_flashrom *req = flash_cmd->va;
-	u32 total_bytes, flash_op, num_bytes;
 	int status;
 
-	total_bytes = img_size;
 	while (total_bytes) {
 		num_bytes = min_t(u32, 32*1024, total_bytes);
 
@@ -3985,12 +3986,15 @@ static int be_flash(struct be_adapter *adapter, const u8 *img,
 		memcpy(req->data_buf, img, num_bytes);
 		img += num_bytes;
 		status = be_cmd_write_flashrom(adapter, flash_cmd, optype,
-					       flash_op, num_bytes);
+					       flash_op, img_offset +
+					       bytes_sent, num_bytes);
 		if (base_status(status) == MCC_STATUS_ILLEGAL_REQUEST &&
 		    optype == OPTYPE_PHY_FW)
 			break;
 		else if (status)
 			return status;
+
+		bytes_sent += num_bytes;
 	}
 	return 0;
 }
@@ -4103,7 +4107,7 @@ static int be_flash_BEx(struct be_adapter *adapter,
 			return -1;
 
 		status = be_flash(adapter, p, flash_cmd, pflashcomp[i].optype,
-				  pflashcomp[i].size);
+				  pflashcomp[i].size, 0);
 		if (status) {
 			dev_err(dev, "Flashing section type 0x%x failed\n",
 				pflashcomp[i].img_type);
@@ -4170,12 +4174,12 @@ static int be_flash_skyhawk(struct be_adapter *adapter,
 			    struct be_dma_mem *flash_cmd, int num_of_images)
 {
 	int img_hdrs_size = num_of_images * sizeof(struct image_hdr);
+	bool crc_match, old_fw_img, flash_offset_support = true;
 	struct device *dev = &adapter->pdev->dev;
 	struct flash_section_info *fsec = NULL;
 	u32 img_offset, img_size, img_type;
+	u16 img_optype, flash_optype;
 	int status, i, filehdr_size;
-	bool crc_match, old_fw_img;
-	u16 img_optype;
 	const u8 *p;
 
 	filehdr_size = sizeof(struct flash_file_hdr_g3);
@@ -4185,6 +4189,7 @@ static int be_flash_skyhawk(struct be_adapter *adapter,
 		return -EINVAL;
 	}
 
+retry_flash:
 	for (i = 0; i < le32_to_cpu(fsec->fsec_hdr.num_images); i++) {
 		img_offset = le32_to_cpu(fsec->fsec_entry[i].offset);
 		img_size   = le32_to_cpu(fsec->fsec_entry[i].pad_size);
@@ -4194,6 +4199,12 @@ static int be_flash_skyhawk(struct be_adapter *adapter,
 
 		if (img_optype == 0xFFFF)
 			continue;
+
+		if (flash_offset_support)
+			flash_optype = OPTYPE_OFFSET_SPECIFIED;
+		else
+			flash_optype = img_optype;
+
 		/* Don't bother verifying CRC if an old FW image is being
 		 * flashed
 		 */
@@ -4202,16 +4213,26 @@ static int be_flash_skyhawk(struct be_adapter *adapter,
 
 		status = be_check_flash_crc(adapter, fw->data, img_offset,
 					    img_size, filehdr_size +
-					    img_hdrs_size, img_optype,
+					    img_hdrs_size, flash_optype,
 					    &crc_match);
-		/* The current FW image on the card does not recognize the new
-		 * FLASH op_type. The FW download is partially complete.
-		 * Reboot the server now to enable FW image to recognize the
-		 * new FLASH op_type. To complete the remaining process,
-		 * download the same FW again after the reboot.
-		 */
 		if (base_status(status) == MCC_STATUS_ILLEGAL_REQUEST ||
 		    base_status(status) == MCC_STATUS_ILLEGAL_FIELD) {
+			/* The current FW image on the card does not support
+			 * OFFSET based flashing. Retry using older mechanism
+			 * of OPTYPE based flashing
+			 */
+			if (flash_optype == OPTYPE_OFFSET_SPECIFIED) {
+				flash_offset_support = false;
+				goto retry_flash;
+			}
+
+			/* The current FW image on the card does not recognize
+			 * the new FLASH op_type. The FW download is partially
+			 * complete. Reboot the server now to enable FW image
+			 * to recognize the new FLASH op_type. To complete the
+			 * remaining process, download the same FW again after
+			 * the reboot.
+			 */
 			dev_err(dev, "Flash incomplete. Reset the server\n");
 			dev_err(dev, "Download FW image again after reset\n");
 			return -EAGAIN;
@@ -4229,7 +4250,19 @@ flash:
 		if (p + img_size > fw->data + fw->size)
 			return -1;
 
-		status = be_flash(adapter, p, flash_cmd, img_optype, img_size);
+		status = be_flash(adapter, p, flash_cmd, flash_optype, img_size,
+				  img_offset);
+
+		/* The current FW image on the card does not support OFFSET
+		 * based flashing. Retry using older mechanism of OPTYPE based
+		 * flashing
+		 */
+		if (base_status(status) == MCC_STATUS_ILLEGAL_FIELD &&
+		    flash_optype == OPTYPE_OFFSET_SPECIFIED) {
+			flash_offset_support = false;
+			goto retry_flash;
+		}
+
 		/* For old FW images ignore ILLEGAL_FIELD error or errors on
 		 * UFI_DIR region
 		 */
-- 
2.2.0
