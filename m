From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 2/5] be2net: NCSI FW section should be properly updated with ethtool for BE3
Date: Sun,  9 Oct 2016 09:58:50 +0530
Message-ID: <20161009042853.20601-3-sriharsha.basavapatna@broadcom.com>
References: <20161009042853.20601-1-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:1200 "EHLO
        CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751011AbcJIE3e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 00:29:34 -0400
In-Reply-To: <20161009042853.20601-1-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver has a check to ensure that NCSI FW section is updated only
if the current FW version in the card supports it. This FW version check
is done using memcmp() which obviously fails in some cases. Fix this by
breaking up the version string into integer version components and
comparing them.

Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 45d1742..7e9be9f4 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2728,6 +2728,26 @@ static int be_flash(struct be_adapter *adapter, const u8 *img,
 	return 0;
 }
 
+#define NCSI_UPDATE_LOG	"NCSI section update is not supported in FW ver %s\n"
+static bool be_fw_ncsi_supported(char *ver)
+{
+	int v1[4] = {3, 102, 148, 0}; /* Min ver that supports NCSI FW */
+	int v2[4];
+	int i;
+
+	if (sscanf(ver, "%d.%d.%d.%d", &v2[0], &v2[1], &v2[2], &v2[3]) != 4)
+		return false;
+
+	for (i = 0; i < 4; i++) {
+		if (v1[i] < v2[i])
+			return true;
+		else if (v1[i] > v2[i])
+			return false;
+	}
+
+	return true;
+}
+
 /* For BE2, BE3 and BE3-R */
 static int be_flash_BEx(struct be_adapter *adapter,
 			const struct firmware *fw,
@@ -2805,8 +2825,10 @@ static int be_flash_BEx(struct be_adapter *adapter,
 			continue;
 
 		if ((pflashcomp[i].optype == OPTYPE_NCSI_FW) &&
-		    memcmp(adapter->fw_ver, "3.102.148.0", 11) < 0)
+		    !be_fw_ncsi_supported(adapter->fw_ver)) {
+			dev_info(dev, NCSI_UPDATE_LOG, adapter->fw_ver);
 			continue;
+		}
 
 		if (pflashcomp[i].optype == OPTYPE_PHY_FW  &&
 		    !phy_flashing_required(adapter))
-- 
2.10.0.478.g3ef7618
