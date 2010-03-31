From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH 2/3] be2net: fix flashing on big endian architectures
Date: Wed, 31 Mar 2010 17:27:10 +0530
Message-ID: <20100331115709.GA9200@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:53953 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753984Ab0CaL5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 07:57:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flashing is broken on big endian architectures like ppc.
This patch fixes it.

From: Naresh G <nareshg@serverengines.com>
Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_cmds.c |    4 ++--
 drivers/net/benet/be_main.c |   15 +++++++--------
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 50e6259..d0ef4ac 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1464,8 +1464,8 @@ int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc,
 
 	req->params.op_type = cpu_to_le32(IMG_TYPE_REDBOOT);
 	req->params.op_code = cpu_to_le32(FLASHROM_OPER_REPORT);
-	req->params.offset = offset;
-	req->params.data_buf_size = 0x4;
+	req->params.offset = cpu_to_le32(offset);
+	req->params.data_buf_size = cpu_to_le32(0x4);
 
 	status = be_mcc_notify_wait(adapter);
 	if (!status)
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index a08faf3..b0faaa2 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1991,7 +1991,7 @@ int be_load_fw(struct be_adapter *adapter, u8 *func)
 	struct flash_file_hdr_g3 *fhdr3;
 	struct image_hdr *img_hdr_ptr = NULL;
 	struct be_dma_mem flash_cmd;
-	int status, i = 0;
+	int status, i = 0, num_imgs = 0;
 	const u8 *p;
 
 	strcpy(fw_file, func);
@@ -2017,15 +2017,14 @@ int be_load_fw(struct be_adapter *adapter, u8 *func)
 	if ((adapter->generation == BE_GEN3) &&
 			(get_ufigen_type(fhdr) == BE_GEN3)) {
 		fhdr3 = (struct flash_file_hdr_g3 *) fw->data;
-		for (i = 0; i < fhdr3->num_imgs; i++) {
+		num_imgs = le32_to_cpu(fhdr3->num_imgs);
+		for (i = 0; i < num_imgs; i++) {
 			img_hdr_ptr = (struct image_hdr *) (fw->data +
 					(sizeof(struct flash_file_hdr_g3) +
-					i * sizeof(struct image_hdr)));
-			if (img_hdr_ptr->imageid == 1) {
-				status = be_flash_data(adapter, fw,
-						&flash_cmd, fhdr3->num_imgs);
-			}
-
+					 i * sizeof(struct image_hdr)));
+			if (le32_to_cpu(img_hdr_ptr->imageid) == 1)
+				status = be_flash_data(adapter, fw, &flash_cmd,
+							num_imgs);
 		}
 	} else if ((adapter->generation == BE_GEN2) &&
 			(get_ufigen_type(fhdr) == BE_GEN2)) {
-- 
1.6.3.3

