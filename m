From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH v2 net-next 6/9] be2net: simplify UFI compatibility checking
Date: Wed,  6 May 2015 05:30:37 -0400
Message-ID: <1430904640-31918-7-git-send-email-sathya.perla@avagotech.com>
References: <1430904640-31918-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:51843 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752572AbbEFJmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 05:42:46 -0400
In-Reply-To: <1430904640-31918-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@avagotech.com>

The code in be_check_ufi_compatibility() checks to see if a UFI file meant
for a lower rev of a chip is being flashed on a higher rev, which is
disallowed. This patch re-writes the code needed for this check in a much
simpler manner.

Signed-off-by: Vasundhara Volam <vasundhara.volam@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.h |  4 ---
 drivers/net/ethernet/emulex/benet/be_main.c | 56 +++++++++--------------------
 2 files changed, 16 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 5eccf87..2694033 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1110,10 +1110,6 @@ struct be_cmd_req_query_fw_cfg {
 	u32 rsvd[31];
 };
 
-/* ASIC revisions */
-#define ASIC_REV_B0		0x10
-#define ASIC_REV_P2		0x11
-
 struct be_cmd_resp_query_fw_cfg {
 	struct be_cmd_resp_hdr hdr;
 	u32 be_config_number;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5611466..5d60ba0 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4771,14 +4771,11 @@ static int lancer_fw_download(struct be_adapter *adapter,
 	return 0;
 }
 
-#define BE2_UFI		2
-#define BE3_UFI		3
-#define BE3R_UFI	10
-#define SH_UFI		4
-#define SH_P2_UFI	11
-
-static int be_get_ufi_type(struct be_adapter *adapter,
-			   struct flash_file_hdr_g3 *fhdr)
+/* Check if the flash image file is compatible with the adapter that
+ * is being flashed.
+ */
+static bool be_check_ufi_compatibility(struct be_adapter *adapter,
+				       struct flash_file_hdr_g3 *fhdr)
 {
 	if (!fhdr) {
 		dev_err(&adapter->pdev->dev, "Invalid FW UFI file");
@@ -4790,43 +4787,22 @@ static int be_get_ufi_type(struct be_adapter *adapter,
 	 */
 	switch (fhdr->build[0]) {
 	case BLD_STR_UFI_TYPE_SH:
-		return (fhdr->asic_type_rev == ASIC_REV_P2) ? SH_P2_UFI :
-								SH_UFI;
+		if (!skyhawk_chip(adapter))
+			return false;
+		break;
 	case BLD_STR_UFI_TYPE_BE3:
-		return (fhdr->asic_type_rev == ASIC_REV_B0) ? BE3R_UFI :
-								BE3_UFI;
+		if (!BE3_chip(adapter))
+			return false;
+		break;
 	case BLD_STR_UFI_TYPE_BE2:
-		return BE2_UFI;
-	default:
-		return -1;
-	}
-}
-
-/* Check if the flash image file is compatible with the adapter that
- * is being flashed.
- * BE3 chips with asic-rev B0 must be flashed only with BE3R_UFI type.
- * Skyhawk chips with asic-rev P2 must be flashed only with SH_P2_UFI type.
- */
-static bool be_check_ufi_compatibility(struct be_adapter *adapter,
-				       struct flash_file_hdr_g3 *fhdr)
-{
-	int ufi_type = be_get_ufi_type(adapter, fhdr);
-
-	switch (ufi_type) {
-	case SH_P2_UFI:
-		return skyhawk_chip(adapter);
-	case SH_UFI:
-		return (skyhawk_chip(adapter) &&
-			adapter->asic_rev < ASIC_REV_P2);
-	case BE3R_UFI:
-		return BE3_chip(adapter);
-	case BE3_UFI:
-		return (BE3_chip(adapter) && adapter->asic_rev < ASIC_REV_B0);
-	case BE2_UFI:
-		return BE2_chip(adapter);
+		if (!BE2_chip(adapter))
+			return false;
+		break;
 	default:
 		return false;
 	}
+
+	return (fhdr->asic_type_rev >= adapter->asic_rev);
 }
 
 static int be_fw_download(struct be_adapter *adapter, const struct firmware* fw)
-- 
2.2.0
