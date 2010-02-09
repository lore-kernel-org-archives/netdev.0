From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH 2/7] be2net: bug fix for flashing the BladeEngine3 ASIC
Date: Tue, 9 Feb 2010 17:00:35 +0530
Message-ID: <20100209113024.GA10453@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f182.google.com ([209.85.223.182]:56889 "EHLO
	mail-iw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754108Ab0BILam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 06:30:42 -0500
Received: by iwn12 with SMTP id 12so8473952iwn.26
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2010 03:30:42 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now flashing both BE2 and BE3 devices is supported.

From: Naresh G <nareshg@serverengines.com>
Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_cmds.c |    9 +-
 drivers/net/benet/be_cmds.h |    3 +-
 drivers/net/benet/be_hw.h   |  119 +++++++++++++++-------
 drivers/net/benet/be_main.c |  239 +++++++++++++++++++++++--------------------
 4 files changed, 217 insertions(+), 153 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index fee6eee..5fd9567 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1374,7 +1374,7 @@ int be_cmd_write_flashrom(struct be_adapter *adapter, struct be_dma_mem *cmd,
 			u32 flash_type, u32 flash_opcode, u32 buf_size)
 {
 	struct be_mcc_wrb *wrb;
-	struct be_cmd_write_flashrom *req = cmd->va;
+	struct be_cmd_write_flashrom *req;
 	struct be_sge *sge;
 	int status;
 
@@ -1408,7 +1408,8 @@ err:
 	return status;
 }
 
-int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc)
+int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc,
+			 int offset)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_write_flashrom *req;
@@ -1429,9 +1430,9 @@ int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc)
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_READ_FLASHROM, sizeof(*req)+4);
 
-	req->params.op_type = cpu_to_le32(FLASHROM_TYPE_REDBOOT);
+	req->params.op_type = cpu_to_le32(IMG_TYPE_REDBOOT);
 	req->params.op_code = cpu_to_le32(FLASHROM_OPER_REPORT);
-	req->params.offset = 0x3FFFC;
+	req->params.offset = offset;
 	req->params.data_buf_size = 0x4;
 
 	status = be_mcc_notify_wait(adapter);
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 13b33c8..c97d773 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -917,7 +917,8 @@ extern int be_cmd_read_port_type(struct be_adapter *adapter, u32 port,
 extern int be_cmd_write_flashrom(struct be_adapter *adapter,
 			struct be_dma_mem *cmd, u32 flash_oper,
 			u32 flash_opcode, u32 buf_size);
-extern int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc);
+int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc,
+				int offset);
 extern int be_cmd_enable_magic_wol(struct be_adapter *adapter, u8 *mac,
 				struct be_dma_mem *nonemb_cmd);
 extern int be_cmd_fw_init(struct be_adapter *adapter);
diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index e2b3bef..bb2ae6f 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -99,6 +99,63 @@
 /* Number of entries posted */
 #define DB_MCCQ_NUM_POSTED_SHIFT	(16)	/* bits 16 - 29 */
 
+/* Flashrom related descriptors */
+#define IMAGE_TYPE_FIRMWARE		160
+#define IMAGE_TYPE_BOOTCODE		224
+#define IMAGE_TYPE_OPTIONROM		32
+
+#define NUM_FLASHDIR_ENTRIES		32
+
+#define IMG_TYPE_ISCSI_ACTIVE		0
+#define IMG_TYPE_REDBOOT		1
+#define IMG_TYPE_BIOS			2
+#define IMG_TYPE_PXE_BIOS		3
+#define IMG_TYPE_FCOE_BIOS		8
+#define IMG_TYPE_ISCSI_BACKUP		9
+#define IMG_TYPE_FCOE_FW_ACTIVE		10
+#define IMG_TYPE_FCOE_FW_BACKUP 	11
+#define IMG_TYPE_NCSI_BITFILE		13
+#define IMG_TYPE_NCSI_8051		14
+
+#define FLASHROM_OPER_FLASH		1
+#define FLASHROM_OPER_SAVE		2
+#define FLASHROM_OPER_REPORT		4
+
+#define FLASH_IMAGE_MAX_SIZE_g2            (1310720) /* Max firmware image sz */
+#define FLASH_BIOS_IMAGE_MAX_SIZE_g2       (262144)  /* Max OPTION ROM img sz */
+#define FLASH_REDBOOT_IMAGE_MAX_SIZE_g2	  (262144)  /* Max Redboot image sz */
+#define FLASH_IMAGE_MAX_SIZE_g3            (2097152) /* Max fw image size */
+#define FLASH_BIOS_IMAGE_MAX_SIZE_g3       (524288)  /* Max OPTION ROM img sz */
+#define FLASH_REDBOOT_IMAGE_MAX_SIZE_g3	  (1048576)  /* Max Redboot image sz */
+
+#define FLASH_NCSI_MAGIC		(0x16032009)
+#define FLASH_NCSI_DISABLED		(0)
+#define FLASH_NCSI_ENABLED		(1)
+
+#define FLASH_NCSI_BITFILE_HDR_OFFSET	(0x600000)
+
+/* Offsets for components on Flash. */
+#define FLASH_iSCSI_PRIMARY_IMAGE_START_g2 (1048576)
+#define FLASH_iSCSI_BACKUP_IMAGE_START_g2  (2359296)
+#define FLASH_FCoE_PRIMARY_IMAGE_START_g2  (3670016)
+#define FLASH_FCoE_BACKUP_IMAGE_START_g2   (4980736)
+#define FLASH_iSCSI_BIOS_START_g2          (7340032)
+#define FLASH_PXE_BIOS_START_g2            (7864320)
+#define FLASH_FCoE_BIOS_START_g2           (524288)
+#define FLASH_REDBOOT_START_g2		  (0)
+
+#define FLASH_iSCSI_PRIMARY_IMAGE_START_g3 (2097152)
+#define FLASH_iSCSI_BACKUP_IMAGE_START_g3  (4194304)
+#define FLASH_FCoE_PRIMARY_IMAGE_START_g3  (6291456)
+#define FLASH_FCoE_BACKUP_IMAGE_START_g3   (8388608)
+#define FLASH_iSCSI_BIOS_START_g3          (12582912)
+#define FLASH_PXE_BIOS_START_g3            (13107200)
+#define FLASH_FCoE_BIOS_START_g3           (13631488)
+#define FLASH_REDBOOT_START_g3             (262144)
+
+
+
+
 /*
  * BE descriptors: host memory data structures whose formats
  * are hardwired in BE silicon.
@@ -107,6 +164,7 @@
 #define EQ_ENTRY_VALID_MASK 		0x1	/* bit 0 */
 #define EQ_ENTRY_RES_ID_MASK 		0xFFFF	/* bits 16 - 31 */
 #define EQ_ENTRY_RES_ID_SHIFT 		16
+
 struct be_eq_entry {
 	u32 evt;
 };
@@ -221,41 +279,6 @@ struct be_eth_rx_compl {
 	u32 dw[4];
 };
 
-/* Flashrom related descriptors */
-#define IMAGE_TYPE_FIRMWARE		160
-#define IMAGE_TYPE_BOOTCODE		224
-#define IMAGE_TYPE_OPTIONROM		32
-
-#define NUM_FLASHDIR_ENTRIES		32
-
-#define FLASHROM_TYPE_ISCSI_ACTIVE	0
-#define FLASHROM_TYPE_REDBOOT		1
-#define FLASHROM_TYPE_BIOS		2
-#define FLASHROM_TYPE_PXE_BIOS		3
-#define FLASHROM_TYPE_FCOE_BIOS		8
-#define FLASHROM_TYPE_ISCSI_BACKUP	9
-#define FLASHROM_TYPE_FCOE_FW_ACTIVE	10
-#define FLASHROM_TYPE_FCOE_FW_BACKUP 	11
-
-#define FLASHROM_OPER_FLASH		1
-#define FLASHROM_OPER_SAVE		2
-#define FLASHROM_OPER_REPORT		4
-
-#define FLASH_IMAGE_MAX_SIZE            (1310720) /* Max firmware image size */
-#define FLASH_BIOS_IMAGE_MAX_SIZE       (262144)  /* Max OPTION ROM image sz */
-#define FLASH_REDBOOT_IMAGE_MAX_SIZE    (262144)  /* Max redboot image sz */
-
-/* Offsets for components on Flash. */
-#define FLASH_iSCSI_PRIMARY_IMAGE_START (1048576)
-#define FLASH_iSCSI_BACKUP_IMAGE_START  (2359296)
-#define FLASH_FCoE_PRIMARY_IMAGE_START  (3670016)
-#define FLASH_FCoE_BACKUP_IMAGE_START   (4980736)
-#define FLASH_iSCSI_BIOS_START          (7340032)
-#define FLASH_PXE_BIOS_START            (7864320)
-#define FLASH_FCoE_BIOS_START           (524288)
-#define FLASH_REDBOOT_START		(32768)
-#define FLASH_REDBOOT_ISM_START		(0)
-
 struct controller_id {
 	u32 vendor;
 	u32 device;
@@ -263,7 +286,20 @@ struct controller_id {
 	u32 subdevice;
 };
 
-struct flash_file_hdr {
+struct flash_comp {
+	unsigned long offset;
+	int optype;
+	int size;
+};
+
+struct image_hdr {
+	u32 imageid;
+	u32 imageoffset;
+	u32 imagelength;
+	u32 image_checksum;
+	u8 image_version[32];
+};
+struct flash_file_hdr_g2 {
 	u8 sign[32];
 	u32 cksum;
 	u32 antidote;
@@ -275,6 +311,17 @@ struct flash_file_hdr {
 	u8 build[24];
 };
 
+struct flash_file_hdr_g3 {
+	u8 sign[52];
+	u8 ufi_version[4];
+	u32 file_len;
+	u32 cksum;
+	u32 antidote;
+	u32 num_imgs;
+	u8 build[24];
+	u8 rsvd[32];
+};
+
 struct flash_section_hdr {
 	u32 format_rev;
 	u32 cksum;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index f9e18eb..1d773db 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1797,15 +1797,19 @@ char flash_cookie[2][16] =	{"*** SE FLAS",
 				"H DIRECTORY *** "};
 
 static bool be_flash_redboot(struct be_adapter *adapter,
-			const u8 *p)
+			const u8 *p, u32 img_start, int image_size,
+			int hdr_size)
 {
 	u32 crc_offset;
 	u8 flashed_crc[4];
 	int status;
-	crc_offset = FLASH_REDBOOT_START + FLASH_REDBOOT_IMAGE_MAX_SIZE - 4
-			+ sizeof(struct flash_file_hdr) - 32*1024;
+
+	crc_offset = hdr_size + img_start + image_size - 4;
+
 	p += crc_offset;
-	status = be_cmd_get_flash_crc(adapter, flashed_crc);
+
+	status = be_cmd_get_flash_crc(adapter, flashed_crc,
+			(img_start + image_size - 4));
 	if (status) {
 		dev_err(&adapter->pdev->dev,
 		"could not get crc from flash, not flashing redboot\n");
@@ -1817,102 +1821,124 @@ static bool be_flash_redboot(struct be_adapter *adapter,
 		return false;
 	else
 		return true;
-
 }
 
-static int be_flash_image(struct be_adapter *adapter,
+static int be_flash_data(struct be_adapter *adapter,
 			const struct firmware *fw,
-			struct be_dma_mem *flash_cmd, u32 flash_type)
+			struct be_dma_mem *flash_cmd, int num_of_images)
+
 {
-	int status;
-	u32 flash_op, image_offset = 0, total_bytes, image_size = 0;
+	int status = 0, i, filehdr_size = 0;
+	u32 total_bytes = 0, flash_op;
 	int num_bytes;
 	const u8 *p = fw->data;
 	struct be_cmd_write_flashrom *req = flash_cmd->va;
-
-	switch (flash_type) {
-	case FLASHROM_TYPE_ISCSI_ACTIVE:
-		image_offset = FLASH_iSCSI_PRIMARY_IMAGE_START;
-		image_size = FLASH_IMAGE_MAX_SIZE;
-		break;
-	case FLASHROM_TYPE_ISCSI_BACKUP:
-		image_offset = FLASH_iSCSI_BACKUP_IMAGE_START;
-		image_size = FLASH_IMAGE_MAX_SIZE;
-		break;
-	case FLASHROM_TYPE_FCOE_FW_ACTIVE:
-		image_offset = FLASH_FCoE_PRIMARY_IMAGE_START;
-		image_size = FLASH_IMAGE_MAX_SIZE;
-		break;
-	case FLASHROM_TYPE_FCOE_FW_BACKUP:
-		image_offset = FLASH_FCoE_BACKUP_IMAGE_START;
-		image_size = FLASH_IMAGE_MAX_SIZE;
-		break;
-	case FLASHROM_TYPE_BIOS:
-		image_offset = FLASH_iSCSI_BIOS_START;
-		image_size = FLASH_BIOS_IMAGE_MAX_SIZE;
-		break;
-	case FLASHROM_TYPE_FCOE_BIOS:
-		image_offset = FLASH_FCoE_BIOS_START;
-		image_size = FLASH_BIOS_IMAGE_MAX_SIZE;
-		break;
-	case FLASHROM_TYPE_PXE_BIOS:
-		image_offset = FLASH_PXE_BIOS_START;
-		image_size = FLASH_BIOS_IMAGE_MAX_SIZE;
-		break;
-	case FLASHROM_TYPE_REDBOOT:
-		if (!be_flash_redboot(adapter, fw->data))
-			return 0;
-		image_offset = FLASH_REDBOOT_ISM_START;
-		image_size = FLASH_REDBOOT_IMAGE_MAX_SIZE;
-		break;
-	default:
-		return 0;
+	struct flash_comp *pflashcomp;
+
+	struct flash_comp gen3_flash_types[8] = {
+		{ FLASH_iSCSI_PRIMARY_IMAGE_START_g3, IMG_TYPE_ISCSI_ACTIVE,
+			FLASH_IMAGE_MAX_SIZE_g3},
+		{ FLASH_REDBOOT_START_g3, IMG_TYPE_REDBOOT,
+			FLASH_REDBOOT_IMAGE_MAX_SIZE_g3},
+		{ FLASH_iSCSI_BIOS_START_g3, IMG_TYPE_BIOS,
+			FLASH_BIOS_IMAGE_MAX_SIZE_g3},
+		{ FLASH_PXE_BIOS_START_g3, IMG_TYPE_PXE_BIOS,
+			FLASH_BIOS_IMAGE_MAX_SIZE_g3},
+		{ FLASH_FCoE_BIOS_START_g3, IMG_TYPE_FCOE_BIOS,
+			FLASH_BIOS_IMAGE_MAX_SIZE_g3},
+		{ FLASH_iSCSI_BACKUP_IMAGE_START_g3, IMG_TYPE_ISCSI_BACKUP,
+			FLASH_IMAGE_MAX_SIZE_g3},
+		{ FLASH_FCoE_PRIMARY_IMAGE_START_g3, IMG_TYPE_FCOE_FW_ACTIVE,
+			FLASH_IMAGE_MAX_SIZE_g3},
+		{ FLASH_FCoE_BACKUP_IMAGE_START_g3, IMG_TYPE_FCOE_FW_BACKUP,
+			FLASH_IMAGE_MAX_SIZE_g3}
+	};
+	struct flash_comp gen2_flash_types[8] = {
+		{ FLASH_iSCSI_PRIMARY_IMAGE_START_g2, IMG_TYPE_ISCSI_ACTIVE,
+			FLASH_IMAGE_MAX_SIZE_g2},
+		{ FLASH_REDBOOT_START_g2, IMG_TYPE_REDBOOT,
+			FLASH_REDBOOT_IMAGE_MAX_SIZE_g2},
+		{ FLASH_iSCSI_BIOS_START_g2, IMG_TYPE_BIOS,
+			FLASH_BIOS_IMAGE_MAX_SIZE_g2},
+		{ FLASH_PXE_BIOS_START_g2, IMG_TYPE_PXE_BIOS,
+			FLASH_BIOS_IMAGE_MAX_SIZE_g2},
+		{ FLASH_FCoE_BIOS_START_g2, IMG_TYPE_FCOE_BIOS,
+			FLASH_BIOS_IMAGE_MAX_SIZE_g2},
+		{ FLASH_iSCSI_BACKUP_IMAGE_START_g2, IMG_TYPE_ISCSI_BACKUP,
+			FLASH_IMAGE_MAX_SIZE_g2},
+		{ FLASH_FCoE_PRIMARY_IMAGE_START_g2, IMG_TYPE_FCOE_FW_ACTIVE,
+			FLASH_IMAGE_MAX_SIZE_g2},
+		{ FLASH_FCoE_BACKUP_IMAGE_START_g2, IMG_TYPE_FCOE_FW_BACKUP,
+			 FLASH_IMAGE_MAX_SIZE_g2}
+	};
+
+	if (adapter->generation == BE_GEN3) {
+		pflashcomp = gen3_flash_types;
+		filehdr_size = sizeof(struct flash_file_hdr_g3);
+	} else {
+		pflashcomp = gen2_flash_types;
+		filehdr_size = sizeof(struct flash_file_hdr_g2);
 	}
-
-	p += sizeof(struct flash_file_hdr) + image_offset;
-	if (p + image_size > fw->data + fw->size)
+	for (i = 0; i < 8; i++) {
+		if ((pflashcomp[i].optype == IMG_TYPE_REDBOOT) &&
+			(!be_flash_redboot(adapter, fw->data,
+			 pflashcomp[i].offset, pflashcomp[i].size,
+			 filehdr_size)))
+			continue;
+		p = fw->data;
+		p += filehdr_size + pflashcomp[i].offset
+			+ (num_of_images * sizeof(struct image_hdr));
+	if (p + pflashcomp[i].size > fw->data + fw->size)
 		return -1;
-
-	total_bytes = image_size;
-
-	while (total_bytes) {
-		if (total_bytes > 32*1024)
-			num_bytes = 32*1024;
-		else
-			num_bytes = total_bytes;
-		total_bytes -= num_bytes;
-
-		if (!total_bytes)
-			flash_op = FLASHROM_OPER_FLASH;
-		else
-			flash_op = FLASHROM_OPER_SAVE;
-		memcpy(req->params.data_buf, p, num_bytes);
-		p += num_bytes;
-		status = be_cmd_write_flashrom(adapter, flash_cmd,
-				flash_type, flash_op, num_bytes);
-		if (status) {
-			dev_err(&adapter->pdev->dev,
-			"cmd to write to flash rom failed. type/op %d/%d\n",
-			flash_type, flash_op);
-			return -1;
+	total_bytes = pflashcomp[i].size;
+		while (total_bytes) {
+			if (total_bytes > 32*1024)
+				num_bytes = 32*1024;
+			else
+				num_bytes = total_bytes;
+			total_bytes -= num_bytes;
+
+			if (!total_bytes)
+				flash_op = FLASHROM_OPER_FLASH;
+			else
+				flash_op = FLASHROM_OPER_SAVE;
+			memcpy(req->params.data_buf, p, num_bytes);
+			p += num_bytes;
+			status = be_cmd_write_flashrom(adapter, flash_cmd,
+				pflashcomp[i].optype, flash_op, num_bytes);
+			if (status) {
+				dev_err(&adapter->pdev->dev,
+					"cmd to write to flash rom failed.\n");
+				return -1;
+			}
+			yield();
 		}
-		yield();
 	}
-
 	return 0;
 }
 
+static int get_ufigen_type(struct flash_file_hdr_g2 *fhdr)
+{
+	if (fhdr == NULL)
+		return 0;
+	if (fhdr->build[0] == '3')
+		return BE_GEN3;
+	else if (fhdr->build[0] == '2')
+		return BE_GEN2;
+	else
+		return 0;
+}
+
 int be_load_fw(struct be_adapter *adapter, u8 *func)
 {
 	char fw_file[ETHTOOL_FLASH_MAX_FILENAME];
 	const struct firmware *fw;
-	struct flash_file_hdr *fhdr;
-	struct flash_section_info *fsec = NULL;
+	struct flash_file_hdr_g2 *fhdr;
+	struct flash_file_hdr_g3 *fhdr3;
+	struct image_hdr *img_hdr_ptr = NULL;
 	struct be_dma_mem flash_cmd;
-	int status;
+	int status, i = 0;
 	const u8 *p;
-	bool entry_found = false;
-	int flash_type;
 	char fw_ver[FW_VER_LEN];
 	char fw_cfg;
 
@@ -1930,34 +1956,9 @@ int be_load_fw(struct be_adapter *adapter, u8 *func)
 		goto fw_exit;
 
 	p = fw->data;
-	fhdr = (struct flash_file_hdr *) p;
-	if (memcmp(fhdr->sign, FW_FILE_HDR_SIGN, strlen(FW_FILE_HDR_SIGN))) {
-		dev_err(&adapter->pdev->dev,
-			"Firmware(%s) load error (signature did not match)\n",
-				fw_file);
-		status = -1;
-		goto fw_exit;
-	}
-
+	fhdr = (struct flash_file_hdr_g2 *) p;
 	dev_info(&adapter->pdev->dev, "Flashing firmware file %s\n", fw_file);
 
-	p += sizeof(struct flash_file_hdr);
-	while (p < (fw->data + fw->size)) {
-		fsec = (struct flash_section_info *)p;
-		if (!memcmp(flash_cookie, fsec->cookie, sizeof(flash_cookie))) {
-			entry_found = true;
-			break;
-		}
-		p += 32;
-	}
-
-	if (!entry_found) {
-		status = -1;
-		dev_err(&adapter->pdev->dev,
-			"Flash cookie not found in firmware image\n");
-		goto fw_exit;
-	}
-
 	flash_cmd.size = sizeof(struct be_cmd_write_flashrom) + 32*1024;
 	flash_cmd.va = pci_alloc_consistent(adapter->pdev, flash_cmd.size,
 					&flash_cmd.dma);
@@ -1968,12 +1969,26 @@ int be_load_fw(struct be_adapter *adapter, u8 *func)
 		goto fw_exit;
 	}
 
-	for (flash_type = FLASHROM_TYPE_ISCSI_ACTIVE;
-		flash_type <= FLASHROM_TYPE_FCOE_FW_BACKUP; flash_type++) {
-		status = be_flash_image(adapter, fw, &flash_cmd,
-				flash_type);
-		if (status)
-			break;
+	if ((adapter->generation == BE_GEN3) &&
+			(get_ufigen_type(fhdr) == BE_GEN3)) {
+		fhdr3 = (struct flash_file_hdr_g3 *) fw->data;
+		for (i = 0; i < fhdr3->num_imgs; i++) {
+			img_hdr_ptr = (struct image_hdr *) (fw->data +
+					(sizeof(struct flash_file_hdr_g3) +
+					i * sizeof(struct image_hdr)));
+			if (img_hdr_ptr->imageid == 1) {
+				status = be_flash_data(adapter, fw,
+						&flash_cmd, fhdr3->num_imgs);
+			}
+
+		}
+	} else if ((adapter->generation == BE_GEN2) &&
+			(get_ufigen_type(fhdr) == BE_GEN2)) {
+		status = be_flash_data(adapter, fw, &flash_cmd, 0);
+	} else {
+		dev_err(&adapter->pdev->dev,
+			"UFI and Interface are not compatible for flashing\n");
+		status = -1;
 	}
 
 	pci_free_consistent(adapter->pdev, flash_cmd.size, flash_cmd.va,
-- 
1.6.3.3

