From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net-next 08/10] bnx2x: Recovery flow bug fixes
Date: Thu, 26 Jan 2012 18:01:52 +0200
Message-ID: <1327593714-18358-9-git-send-email-ariele@broadcom.com>
References: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4709 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752362Ab2AZQCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 11:02:04 -0500
In-Reply-To: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Sample mcp pulse and mcp sequence in nic load instead of in init_one
as they may change by the time we want to use them.

2. Allow cnic to access device during nic load (by adding a new "LOADING" state
to recovery flow). This prevents the unnecessary cnic timeout which resulted
by cnic attempting to access because nic is loading, but being blocked because
of the Recovery state.

3. Issue 'fake' driver load command to mcp when last driver unloads to prevent
mcp from taking ownership. When recovery is complete unload fake driver to
allow mcp to initialize the hardware before first driver loads.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |   18 +++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  102 +++++++++++++---------
 3 files changed, 75 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 8c73d34..06bbef7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1088,7 +1088,8 @@ enum bnx2x_recovery_state {
 	BNX2X_RECOVERY_DONE,
 	BNX2X_RECOVERY_INIT,
 	BNX2X_RECOVERY_WAIT,
-	BNX2X_RECOVERY_FAILED
+	BNX2X_RECOVERY_FAILED,
+	BNX2X_RECOVERY_NIC_LOADING
 };
 
 /*
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 15db2d6..8fdd71b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1776,6 +1776,18 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	 * common blocks should be initialized, otherwise - not
 	 */
 	if (!BP_NOMCP(bp)) {
+		/* init fw_seq */
+		bp->fw_seq =
+			(SHMEM_RD(bp, func_mb[BP_FW_MB_IDX(bp)].drv_mb_header) &
+			 DRV_MSG_SEQ_NUMBER_MASK);
+		BNX2X_DEV_INFO("fw_seq 0x%08x\n", bp->fw_seq);
+
+		/* Get current FW pulse sequence */
+		bp->fw_drv_pulse_wr_seq =
+			(SHMEM_RD(bp, func_mb[BP_FW_MB_IDX(bp)].drv_pulse_mb) &
+			 DRV_PULSE_SEQ_MASK);
+		BNX2X_DEV_INFO("drv_pulse 0x%x\n", bp->fw_drv_pulse_wr_seq);
+
 		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ, 0);
 		if (!load_code) {
 			BNX2X_ERR("MCP response failure, aborting\n");
@@ -3442,7 +3454,7 @@ int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
 	struct bnx2x *bp = netdev_priv(dev);
 
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
-		pr_err("Handling parity error recovery. Try again later\n");
+		netdev_err(dev, "Handling parity error recovery. Try again later\n");
 		return -EAGAIN;
 	}
 
@@ -3569,7 +3581,7 @@ int bnx2x_resume(struct pci_dev *pdev)
 	bp = netdev_priv(dev);
 
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
-		pr_err("Handling parity error recovery. Try again later\n");
+		netdev_err(dev, "Handling parity error recovery. Try again later\n");
 		return -EAGAIN;
 	}
 
@@ -3585,8 +3597,6 @@ int bnx2x_resume(struct pci_dev *pdev)
 	bnx2x_set_power_state(bp, PCI_D0);
 	netif_device_attach(dev);
 
-	/* Since the chip was reset, clear the FW sequence number */
-	bp->fw_seq = 0;
 	rc = bnx2x_nic_load(bp, LOAD_OPEN);
 
 	rtnl_unlock();
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index f7f167a..c945df0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -468,7 +468,9 @@ static int bnx2x_issue_dmae_with_comp(struct bnx2x *bp,
 	while ((*wb_comp & ~DMAE_PCI_ERR_FLAG) != DMAE_COMP_VAL) {
 		DP(BNX2X_MSG_OFF, "wb_comp 0x%08x\n", *wb_comp);
 
-		if (!cnt) {
+		if (!cnt ||
+		    (bp->recovery_state != BNX2X_RECOVERY_DONE &&
+		     bp->recovery_state != BNX2X_RECOVERY_NIC_LOADING)) {
 			BNX2X_ERR("DMAE timeout!\n");
 			rc = DMAE_TIMEOUT;
 			goto unlock;
@@ -8477,13 +8479,38 @@ int bnx2x_leader_reset(struct bnx2x *bp)
 {
 	int rc = 0;
 	bool global = bnx2x_reset_is_global(bp);
+	u32 load_code;
+
+	/* if not going to reset MCP - load "fake" driver to reset HW while
+	 * driver is owner of the HW
+	 */
+	if (!global && !BP_NOMCP(bp)) {
+		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ, 0);
+		if (!load_code) {
+			BNX2X_ERR("MCP response failure, aborting\n");
+			rc = -EAGAIN;
+			goto exit_leader_reset;
+		}
+		if ((load_code != FW_MSG_CODE_DRV_LOAD_COMMON_CHIP) &&
+		    (load_code != FW_MSG_CODE_DRV_LOAD_COMMON)) {
+			BNX2X_ERR("MCP unexpected resp, aborting\n");
+			rc = -EAGAIN;
+			goto exit_leader_reset2;
+		}
+		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE, 0);
+		if (!load_code) {
+			BNX2X_ERR("MCP response failure, aborting\n");
+			rc = -EAGAIN;
+			goto exit_leader_reset2;
+		}
+	}
 
 	/* Try to recover after the failure */
 	if (bnx2x_process_kill(bp, global)) {
 		netdev_err(bp->dev, "Something bad had happen on engine %d! "
 				    "Aii!\n", BP_PATH(bp));
 		rc = -EAGAIN;
-		goto exit_leader_reset;
+		goto exit_leader_reset2;
 	}
 
 	/*
@@ -8494,6 +8521,12 @@ int bnx2x_leader_reset(struct bnx2x *bp)
 	if (global)
 		bnx2x_clear_reset_global(bp);
 
+exit_leader_reset2:
+	/* unload "fake driver" if it was loaded */
+	if (!global && !BP_NOMCP(bp)) {
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP, 0);
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE, 0);
+	}
 exit_leader_reset:
 	bp->is_leader = 0;
 	bnx2x_release_leader_lock(bp);
@@ -8530,13 +8563,15 @@ static inline void bnx2x_recovery_failed(struct bnx2x *bp)
 static void bnx2x_parity_recover(struct bnx2x *bp)
 {
 	bool global = false;
+	bool is_parity;
 
 	DP(NETIF_MSG_HW, "Handling parity\n");
 	while (1) {
 		switch (bp->recovery_state) {
 		case BNX2X_RECOVERY_INIT:
 			DP(NETIF_MSG_HW, "State is BNX2X_RECOVERY_INIT\n");
-			bnx2x_chk_parity_attn(bp, &global, false);
+			is_parity = bnx2x_chk_parity_attn(bp, &global, false);
+			WARN_ON(!is_parity);
 
 			/* Try to get a LEADER_LOCK HW lock */
 			if (bnx2x_trylock_leader_lock(bp)) {
@@ -8560,15 +8595,6 @@ static void bnx2x_parity_recover(struct bnx2x *bp)
 
 			bp->recovery_state = BNX2X_RECOVERY_WAIT;
 
-			/*
-			 * Reset MCP command sequence number and MCP mail box
-			 * sequence as we are going to reset the MCP.
-			 */
-			if (global) {
-				bp->fw_seq = 0;
-				bp->fw_drv_pulse_wr_seq = 0;
-			}
-
 			/* Ensure "is_leader", MCP command sequence and
 			 * "recovery_state" update values are seen on other
 			 * CPUs.
@@ -8652,9 +8678,20 @@ static void bnx2x_parity_recover(struct bnx2x *bp)
 						return;
 					}
 
-					if (bnx2x_nic_load(bp, LOAD_NORMAL))
-						bnx2x_recovery_failed(bp);
-					else {
+					bp->recovery_state =
+						BNX2X_RECOVERY_NIC_LOADING;
+					if (bnx2x_nic_load(bp, LOAD_NORMAL)) {
+						netdev_err(bp->dev,
+							   "Recovery failed. "
+							   "Power cycle "
+							   "needed\n");
+						/* Disconnect this device */
+						netif_device_detach(bp->dev);
+						/* Shut down the power */
+						bnx2x_set_power_state(
+							bp, PCI_D3hot);
+						smp_mb();
+					} else {
 						bp->recovery_state =
 							BNX2X_RECOVERY_DONE;
 						smp_mb();
@@ -8908,9 +8945,6 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 
 			/* restore our func and fw_seq */
 			bp->pf_num = orig_pf_num;
-			bp->fw_seq =
-			      (SHMEM_RD(bp, func_mb[bp->pf_num].drv_mb_header) &
-				DRV_MSG_SEQ_NUMBER_MASK);
 		}
 	}
 
@@ -9936,16 +9970,6 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 
 	bnx2x_get_cnic_info(bp);
 
-	/* Get current FW pulse sequence */
-	if (!BP_NOMCP(bp)) {
-		int mb_idx = BP_FW_MB_IDX(bp);
-
-		bp->fw_drv_pulse_wr_seq =
-				(SHMEM_RD(bp, func_mb[mb_idx].drv_pulse_mb) &
-				 DRV_PULSE_SEQ_MASK);
-		BNX2X_DEV_INFO("drv_pulse 0x%x\n", bp->fw_drv_pulse_wr_seq);
-	}
-
 	return rc;
 }
 
@@ -10115,14 +10139,6 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	if (!BP_NOMCP(bp))
 		bnx2x_undi_unload(bp);
 
-	/* init fw_seq after undi_unload! */
-	if (!BP_NOMCP(bp)) {
-		bp->fw_seq =
-			(SHMEM_RD(bp, func_mb[BP_FW_MB_IDX(bp)].drv_mb_header) &
-			 DRV_MSG_SEQ_NUMBER_MASK);
-		BNX2X_DEV_INFO("fw_seq 0x%08x\n", bp->fw_seq);
-	}
-
 	if (CHIP_REV_IS_FPGA(bp))
 		dev_err(&bp->pdev->dev, "FPGA detected\n");
 
@@ -11331,13 +11347,6 @@ static void bnx2x_eeh_recover(struct bnx2x *bp)
 	if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
 		!= (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
 		BNX2X_ERR("BAD MCP validity signature\n");
-
-	if (!BP_NOMCP(bp)) {
-		bp->fw_seq =
-		    (SHMEM_RD(bp, func_mb[BP_FW_MB_IDX(bp)].drv_mb_header) &
-		    DRV_MSG_SEQ_NUMBER_MASK);
-		BNX2X_DEV_INFO("fw_seq 0x%08x\n", bp->fw_seq);
-	}
 }
 
 /**
@@ -11593,6 +11602,13 @@ static int bnx2x_cnic_sp_queue(struct net_device *dev,
 		return -EIO;
 #endif
 
+	if ((bp->recovery_state != BNX2X_RECOVERY_DONE) &&
+	    (bp->recovery_state != BNX2X_RECOVERY_NIC_LOADING)) {
+		netdev_err(dev, "Handling parity error recovery. Try again "
+				"later\n");
+		return -EAGAIN;
+	}
+
 	spin_lock_bh(&bp->spq_lock);
 
 	for (i = 0; i < count; i++) {
-- 
1.7.1
