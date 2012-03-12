From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 5/8] bnx2x: mark functions as loaded on shared memory
Date: Mon, 12 Mar 2012 14:53:11 -0400
Message-ID: <1331578394-1153-6-git-send-email-yuvalmin@broadcom.com>
References: <1331578394-1153-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1169 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754738Ab2CLL7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 07:59:32 -0400
In-Reply-To: <1331578394-1153-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change enables the FW to make more accurate decisions regarding the
active functions.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index f82dfff..c11e50d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2007,6 +2007,15 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		bnx2x_cnic_notify(bp, CNIC_CTL_START_CMD);
 #endif
 
+	/* mark driver is loaded in shmem2 */
+	if (SHMEM2_HAS(bp, drv_capabilities_flag)) {
+		u32 val;
+		val = SHMEM2_RD(bp, drv_capabilities_flag[BP_FW_MB_IDX(bp)]);
+		SHMEM2_WR(bp, drv_capabilities_flag[BP_FW_MB_IDX(bp)],
+			  val | DRV_FLAGS_CAPABILITIES_LOADED_SUPPORTED |
+			  DRV_FLAGS_CAPABILITIES_LOADED_L2);
+	}
+
 	/* Wait for all pending SP commands to complete */
 	if (!bnx2x_wait_sp_comp(bp, ~0x0UL)) {
 		BNX2X_ERR("Timeout waiting for SP elements to complete\n");
@@ -2060,6 +2069,14 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 	int i;
 	bool global = false;
 
+	/* mark driver is unloaded in shmem2 */
+	if (SHMEM2_HAS(bp, drv_capabilities_flag)) {
+		u32 val;
+		val = SHMEM2_RD(bp, drv_capabilities_flag[BP_FW_MB_IDX(bp)]);
+		SHMEM2_WR(bp, drv_capabilities_flag[BP_FW_MB_IDX(bp)],
+			  val & ~DRV_FLAGS_CAPABILITIES_LOADED_L2);
+	}
+
 	if ((bp->state == BNX2X_STATE_CLOSED) ||
 	    (bp->state == BNX2X_STATE_ERROR)) {
 		/* We can get here if the driver has been unloaded
-- 
1.7.9.rc2
