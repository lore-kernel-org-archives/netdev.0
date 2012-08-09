From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 1/2] bnx2x: fix unload previous driver flow when
 flr-capable
Date: Thu, 9 Aug 2012 17:37:25 +0300
Message-ID: <1344523046-31577-2-git-send-email-yuvalmin@broadcom.com>
References: <1344523046-31577-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2419 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030517Ab2HIOgo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 10:36:44 -0400
In-Reply-To: <1344523046-31577-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing previous driver unload flow is flawed, causing the probe of 
functions reaching the 'uncommon fork' in flr-capable devices to fail.

This patch resolves this, as well as fixing the flow for hypervisors which 
disable flr capabilities from functions as they pass them as PDA to VMs, 
as we cannot base the flow on the pci configuration space.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   55 +++++++++++-----------
 1 files changed, 28 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index dd451c3..5384a6d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9384,32 +9384,24 @@ static int __devinit bnx2x_prev_mark_path(struct bnx2x *bp)
 	return rc;
 }
 
-static bool __devinit bnx2x_can_flr(struct bnx2x *bp)
-{
-	int pos;
-	u32 cap;
-	struct pci_dev *dev = bp->pdev;
-
-	pos = pci_pcie_cap(dev);
-	if (!pos)
-		return false;
-
-	pci_read_config_dword(dev, pos + PCI_EXP_DEVCAP, &cap);
-	if (!(cap & PCI_EXP_DEVCAP_FLR))
-		return false;
-
-	return true;
-}
-
 static int __devinit bnx2x_do_flr(struct bnx2x *bp)
 {
 	int i, pos;
 	u16 status;
 	struct pci_dev *dev = bp->pdev;
 
-	/* probe the capability first */
-	if (bnx2x_can_flr(bp))
-		return -ENOTTY;
+
+	if (CHIP_IS_E1x(bp)) {
+		BNX2X_DEV_INFO("FLR not supported in E1/E1H\n");
+		return -EINVAL;
+	}
+
+	/* only bootcode REQ_BC_VER_4_INITIATE_FLR and onwards support flr */
+	if (bp->common.bc_ver < REQ_BC_VER_4_INITIATE_FLR) {
+		BNX2X_ERR("FLR not supported by BC_VER: 0x%x\n",
+			  bp->common.bc_ver);
+		return -EINVAL;
+	}
 
 	pos = pci_pcie_cap(dev);
 	if (!pos)
@@ -9429,12 +9421,8 @@ static int __devinit bnx2x_do_flr(struct bnx2x *bp)
 		"transaction is not cleared; proceeding with reset anyway\n");
 
 clear:
-	if (bp->common.bc_ver < REQ_BC_VER_4_INITIATE_FLR) {
-		BNX2X_ERR("FLR not supported by BC_VER: 0x%x\n",
-			  bp->common.bc_ver);
-		return -EINVAL;
-	}
 
+	BNX2X_DEV_INFO("Initiating FLR\n");
 	bnx2x_fw_command(bp, DRV_MSG_CODE_INITIATE_FLR, 0);
 
 	return 0;
@@ -9454,8 +9442,21 @@ static int __devinit bnx2x_prev_unload_uncommon(struct bnx2x *bp)
 	 * the one required, then FLR will be sufficient to clean any residue
 	 * left by previous driver
 	 */
-	if (bnx2x_test_firmware_version(bp, false) && bnx2x_can_flr(bp))
-		return bnx2x_do_flr(bp);
+	rc = bnx2x_test_firmware_version(bp, false);
+
+	if (!rc) {
+		/* fw version is good */
+		BNX2X_DEV_INFO("FW version matches our own. Attempting FLR\n");
+		rc = bnx2x_do_flr(bp);
+	}
+
+	if (!rc) {
+		/* FLR was performed */
+		BNX2X_DEV_INFO("FLR successful\n");
+		return 0;
+	}
+
+	BNX2X_DEV_INFO("Could not FLR\n");
 
 	/* Close the MCP request, return failure*/
 	rc = bnx2x_prev_mcp_done(bp);
-- 
1.7.9.rc2
