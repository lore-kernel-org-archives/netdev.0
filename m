From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 4/9] be2net: avoid flashing SH-B0 UFI image on SH-P2 chip
Date: Fri, 6 Feb 2015 08:18:38 -0500
Message-ID: <1423228723-10919-5-git-send-email-sathya.perla@emulex.com>
References: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:28175 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754992AbbBFNPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 08:15:39 -0500
In-Reply-To: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Skyhawk-B0 FW UFI is not compatible to flash on Skyhawk-P2 ASIC.
But, Skyhawk-P2 FW UFI is compatible with both B0 and P2 chips.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.h |  1 +
 drivers/net/ethernet/emulex/benet/be_main.c | 10 ++++++++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index bed4a32..774c5d1 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1093,6 +1093,7 @@ struct be_cmd_req_query_fw_cfg {
 
 /* ASIC revisions */
 #define ASIC_REV_B0		0x10
+#define ASIC_REV_P2		0x11
 
 struct be_cmd_resp_query_fw_cfg {
 	struct be_cmd_resp_hdr hdr;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index ddc5966..9eaf8bc 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4336,6 +4336,7 @@ static int lancer_fw_download(struct be_adapter *adapter,
 #define BE3_UFI		3
 #define BE3R_UFI	10
 #define SH_UFI		4
+#define SH_P2_UFI	11
 
 static int be_get_ufi_type(struct be_adapter *adapter,
 			   struct flash_file_hdr_g3 *fhdr)
@@ -4350,7 +4351,8 @@ static int be_get_ufi_type(struct be_adapter *adapter,
 	 */
 	switch (fhdr->build[0]) {
 	case BLD_STR_UFI_TYPE_SH:
-		return SH_UFI;
+		return (fhdr->asic_type_rev == ASIC_REV_P2) ? SH_P2_UFI :
+								SH_UFI;
 	case BLD_STR_UFI_TYPE_BE3:
 		return (fhdr->asic_type_rev == ASIC_REV_B0) ? BE3R_UFI :
 								BE3_UFI;
@@ -4364,6 +4366,7 @@ static int be_get_ufi_type(struct be_adapter *adapter,
 /* Check if the flash image file is compatible with the adapter that
  * is being flashed.
  * BE3 chips with asic-rev B0 must be flashed only with BE3R_UFI type.
+ * Skyhawk chips with asic-rev P2 must be flashed only with SH_P2_UFI type.
  */
 static bool be_check_ufi_compatibility(struct be_adapter *adapter,
 				       struct flash_file_hdr_g3 *fhdr)
@@ -4371,8 +4374,11 @@ static bool be_check_ufi_compatibility(struct be_adapter *adapter,
 	int ufi_type = be_get_ufi_type(adapter, fhdr);
 
 	switch (ufi_type) {
-	case SH_UFI:
+	case SH_P2_UFI:
 		return skyhawk_chip(adapter);
+	case SH_UFI:
+		return (skyhawk_chip(adapter) &&
+			adapter->asic_rev < ASIC_REV_P2);
 	case BE3R_UFI:
 		return BE3_chip(adapter);
 	case BE3_UFI:
-- 
2.2.0
