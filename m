From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [net-next-2.6 PATCH] be2net:Patch to flash redboot section while
 firmware update.
Date: Thu, 19 Nov 2009 14:18:43 +0530
Message-ID: <20091119084829.GA19247@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:29866 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753543AbZKSIsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 03:48:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply patch to update redboot section while firmware update. Code
checks if section needs to be updated before actually doing it.

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be_cmds.c |   29 +++++++++++++++++++++++++++++
 drivers/net/benet/be_cmds.h |    2 ++
 drivers/net/benet/be_hw.h   |    5 +++++
 drivers/net/benet/be_main.c |   31 +++++++++++++++++++++++++++++++
 4 files changed, 67 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index cc75dd0..808ad0d 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1251,3 +1251,32 @@ int be_cmd_write_flashrom(struct be_adap
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
+
+int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc)
+{
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_write_flashrom *req;
+	int status;
+
+	spin_lock_bh(&adapter->mcc_lock);
+
+	wrb = wrb_from_mccq(adapter);
+	req = embedded_payload(wrb);
+
+	be_wrb_hdr_prepare(wrb, sizeof(*req)+4, true, 0);
+
+	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
+		OPCODE_COMMON_READ_FLASHROM, sizeof(*req)+4);
+
+	req->params.op_type = cpu_to_le32(FLASHROM_TYPE_REDBOOT);
+	req->params.op_code = cpu_to_le32(FLASHROM_OPER_REPORT);
+	req->params.offset = 0x3FFFC;
+	req->params.data_buf_size = 0x4;
+
+	status = be_mcc_notify_wait(adapter);
+	if (!status)
+		memcpy(flashed_crc, req->params.data_buf, 4);
+
+	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
+}
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 69dc017..6a430e4 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -118,6 +118,7 @@ #define OPCODE_COMMON_NTWK_MAC_SET			2
 #define OPCODE_COMMON_NTWK_MULTICAST_SET		3
 #define OPCODE_COMMON_NTWK_VLAN_CONFIG  		4
 #define OPCODE_COMMON_NTWK_LINK_STATUS_QUERY		5
+#define OPCODE_COMMON_READ_FLASHROM			6
 #define OPCODE_COMMON_WRITE_FLASHROM			7
 #define OPCODE_COMMON_CQ_CREATE				12
 #define OPCODE_COMMON_EQ_CREATE				13
@@ -846,3 +847,4 @@ extern int be_cmd_read_port_type(struct 
 extern int be_cmd_write_flashrom(struct be_adapter *adapter,
 			struct be_dma_mem *cmd, u32 flash_oper,
 			u32 flash_opcode, u32 buf_size);
+extern int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc);
diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index a3394b4..f53d5ca 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -225,6 +225,7 @@ #define IMAGE_TYPE_OPTIONROM		32
 #define NUM_FLASHDIR_ENTRIES		32
 
 #define FLASHROM_TYPE_ISCSI_ACTIVE	0
+#define FLASHROM_TYPE_REDBOOT		1
 #define FLASHROM_TYPE_BIOS		2
 #define FLASHROM_TYPE_PXE_BIOS		3
 #define FLASHROM_TYPE_FCOE_BIOS		8
@@ -234,9 +235,11 @@ #define FLASHROM_TYPE_FCOE_FW_BACKUP 	11
 
 #define FLASHROM_OPER_FLASH		1
 #define FLASHROM_OPER_SAVE		2
+#define FLASHROM_OPER_REPORT		4
 
 #define FLASH_IMAGE_MAX_SIZE            (1310720) /* Max firmware image size */
 #define FLASH_BIOS_IMAGE_MAX_SIZE       (262144)  /* Max OPTION ROM image sz */
+#define FLASH_REDBOOT_IMAGE_MAX_SIZE    (262144)  /* Max redboot image sz */
 
 /* Offsets for components on Flash. */
 #define FLASH_iSCSI_PRIMARY_IMAGE_START (1048576)
@@ -246,6 +249,8 @@ #define FLASH_FCoE_BACKUP_IMAGE_START   
 #define FLASH_iSCSI_BIOS_START          (7340032)
 #define FLASH_PXE_BIOS_START            (7864320)
 #define FLASH_FCoE_BIOS_START           (524288)
+#define FLASH_REDBOOT_START		(32768)
+#define FLASH_REDBOOT_ISM_START		(0)
 
 struct controller_id {
 	u32 vendor;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index c0bd203..921103c 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1721,6 +1721,31 @@ static int be_close(struct net_device *n
 #define FW_FILE_HDR_SIGN 	"ServerEngines Corp. "
 char flash_cookie[2][16] =	{"*** SE FLAS",
 				"H DIRECTORY *** "};
+
+static bool be_flash_redboot(struct be_adapter *adapter,
+			const u8 *p)
+{
+	u32 crc_offset;
+	u8 flashed_crc[4];
+	int status;
+	crc_offset = FLASH_REDBOOT_START + FLASH_REDBOOT_IMAGE_MAX_SIZE - 4
+			+ sizeof(struct flash_file_hdr) - 32*1024;
+	p += crc_offset;
+	status = be_cmd_get_flash_crc(adapter, flashed_crc);
+	if (status) {
+		dev_err(&adapter->pdev->dev,
+		"could not get crc from flash, not flashing redboot\n");
+		return false;
+	}
+
+	/*update redboot only if crc does not match*/
+	if (!memcmp(flashed_crc, p, 4))
+		return false;
+	else
+		return true;
+
+}
+
 static int be_flash_image(struct be_adapter *adapter,
 			const struct firmware *fw,
 			struct be_dma_mem *flash_cmd, u32 flash_type)
@@ -1760,6 +1785,12 @@ static int be_flash_image(struct be_adap
 		image_offset = FLASH_PXE_BIOS_START;
 		image_size = FLASH_BIOS_IMAGE_MAX_SIZE;
 		break;
+	case FLASHROM_TYPE_REDBOOT:
+		if (!be_flash_redboot(adapter, fw->data))
+			return 0;
+		image_offset = FLASH_REDBOOT_ISM_START;
+		image_size = FLASH_REDBOOT_IMAGE_MAX_SIZE;
+		break;
 	default:
 		return 0;
 	}
-- 
1.4.0

