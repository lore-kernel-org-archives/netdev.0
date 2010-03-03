From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [net-next PATCH] be2net: download NCSI section during firmware
 update
Date: Wed, 3 Mar 2010 14:07:28 +0530
Message-ID: <20100303083718.GA27402@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:56354 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752277Ab0CCIhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 03:37:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding code to update NCSI section while updating firmware on the controller.
Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be_hw.h   |    5 +++--
 drivers/net/benet/be_main.c |   14 +++++++++++---
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index 5ffb149..2d4a4b8 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -114,8 +114,7 @@ #define IMG_TYPE_FCOE_BIOS		8
 #define IMG_TYPE_ISCSI_BACKUP		9
 #define IMG_TYPE_FCOE_FW_ACTIVE		10
 #define IMG_TYPE_FCOE_FW_BACKUP 	11
-#define IMG_TYPE_NCSI_BITFILE		13
-#define IMG_TYPE_NCSI_8051		14
+#define IMG_TYPE_NCSI_FW		13
 
 #define FLASHROM_OPER_FLASH		1
 #define FLASHROM_OPER_SAVE		2
@@ -127,6 +126,7 @@ #define FLASH_REDBOOT_IMAGE_MAX_SIZE_g2	
 #define FLASH_IMAGE_MAX_SIZE_g3            (2097152) /* Max fw image size */
 #define FLASH_BIOS_IMAGE_MAX_SIZE_g3       (524288)  /* Max OPTION ROM img sz */
 #define FLASH_REDBOOT_IMAGE_MAX_SIZE_g3	  (1048576)  /* Max Redboot image sz */
+#define FLASH_NCSI_IMAGE_MAX_SIZE_g3       (262144)  /* Max NSCI image sz */
 
 #define FLASH_NCSI_MAGIC		(0x16032009)
 #define FLASH_NCSI_DISABLED		(0)
@@ -144,6 +144,7 @@ #define FLASH_PXE_BIOS_START_g2         
 #define FLASH_FCoE_BIOS_START_g2           (524288)
 #define FLASH_REDBOOT_START_g2		  (0)
 
+#define FLASH_NCSI_START_g3		   (15990784)
 #define FLASH_iSCSI_PRIMARY_IMAGE_START_g3 (2097152)
 #define FLASH_iSCSI_BACKUP_IMAGE_START_g3  (4194304)
 #define FLASH_FCoE_PRIMARY_IMAGE_START_g3  (6291456)
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index a703ed8..22f787f 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1880,8 +1880,9 @@ static int be_flash_data(struct be_adapt
 	const u8 *p = fw->data;
 	struct be_cmd_write_flashrom *req = flash_cmd->va;
 	struct flash_comp *pflashcomp;
+	int num_comp;
 
-	struct flash_comp gen3_flash_types[8] = {
+	struct flash_comp gen3_flash_types[9] = {
 		{ FLASH_iSCSI_PRIMARY_IMAGE_START_g3, IMG_TYPE_ISCSI_ACTIVE,
 			FLASH_IMAGE_MAX_SIZE_g3},
 		{ FLASH_REDBOOT_START_g3, IMG_TYPE_REDBOOT,
@@ -1897,7 +1898,9 @@ static int be_flash_data(struct be_adapt
 		{ FLASH_FCoE_PRIMARY_IMAGE_START_g3, IMG_TYPE_FCOE_FW_ACTIVE,
 			FLASH_IMAGE_MAX_SIZE_g3},
 		{ FLASH_FCoE_BACKUP_IMAGE_START_g3, IMG_TYPE_FCOE_FW_BACKUP,
-			FLASH_IMAGE_MAX_SIZE_g3}
+			FLASH_IMAGE_MAX_SIZE_g3},
+		{ FLASH_NCSI_START_g3, IMG_TYPE_NCSI_FW,
+			FLASH_NCSI_IMAGE_MAX_SIZE_g3}
 	};
 	struct flash_comp gen2_flash_types[8] = {
 		{ FLASH_iSCSI_PRIMARY_IMAGE_START_g2, IMG_TYPE_ISCSI_ACTIVE,
@@ -1921,11 +1924,16 @@ static int be_flash_data(struct be_adapt
 	if (adapter->generation == BE_GEN3) {
 		pflashcomp = gen3_flash_types;
 		filehdr_size = sizeof(struct flash_file_hdr_g3);
+		num_comp = 9;
 	} else {
 		pflashcomp = gen2_flash_types;
 		filehdr_size = sizeof(struct flash_file_hdr_g2);
+		num_comp = 8;
 	}
-	for (i = 0; i < 8; i++) {
+	for (i = 0; i < num_comp; i++) {
+		if ((pflashcomp[i].optype == IMG_TYPE_NCSI_FW) &&
+				memcmp(adapter->fw_ver, "3.102.148.0", 11) < 0)
+			continue;
 		if ((pflashcomp[i].optype == IMG_TYPE_REDBOOT) &&
 			(!be_flash_redboot(adapter, fw->data,
 			 pflashcomp[i].offset, pflashcomp[i].size,
-- 
1.4.0

