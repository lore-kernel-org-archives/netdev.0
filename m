From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch 10/12] bnx2x: Support DCBX for all functions
Date: Wed, 13 Jun 2012 15:44:22 +0300
Message-ID: <1339591464-10554-11-git-send-email-meravs@broadcom.com>
References: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>,
	"Barak Witkowski" <barak@broadcom.com>
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2835 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752802Ab2FMJmx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 05:42:53 -0400
In-Reply-To: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barak Witkowski <barak@broadcom.com>

In multi-function device, allow configuring dcbx admin params from all drivers
on a single physical port.

Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    6 +++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c  |   30 +++++++++++++++-------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |    1 +
 7 files changed, 31 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index e0a3cc9..1f2e03a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1333,6 +1333,7 @@ struct bnx2x {
 #define NO_FCOE_FLAG			(1 << 15)
 #define BC_SUPPORTS_PFC_STATS		(1 << 17)
 #define USING_SINGLE_MSIX_FLAG		(1 << 20)
+#define BC_SUPPORTS_DCBX_MSG_NON_PMF	(1 << 21)
 
 #define NO_ISCSI(bp)		((bp)->flags & NO_ISCSI_FLAG)
 #define NO_ISCSI_OOO(bp)	((bp)->flags & NO_ISCSI_OOO_FLAG)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index c8a83a3..f774acf 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2257,8 +2257,10 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		return -EBUSY;
 	}
 
-	if (bp->state != BNX2X_STATE_DIAG)
-		bnx2x_dcbx_init(bp);
+	/* If PMF - send ADMIN DCBX msg to MFW to initiate DCBX FSM */
+	if (bp->port.pmf && (bp->state != BNX2X_STATE_DIAG))
+		bnx2x_dcbx_init(bp, false);
+
 	return 0;
 
 #ifndef BNX2X_STOP_ON_ERROR
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index b6ae665..cd98a3a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -418,7 +418,7 @@ void bnx2x_ilt_set_info(struct bnx2x *bp);
  *
  * @bp:		driver handle
  */
-void bnx2x_dcbx_init(struct bnx2x *bp);
+void bnx2x_dcbx_init(struct bnx2x *bp, bool update_shmem);
 
 /**
  * bnx2x_set_power_state - set power state to the requested value.
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 4f9244b..8a73374 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -972,23 +972,26 @@ void bnx2x_dcbx_init_params(struct bnx2x *bp)
 	bp->dcbx_config_params.admin_default_priority = 0;
 }
 
-void bnx2x_dcbx_init(struct bnx2x *bp)
+void bnx2x_dcbx_init(struct bnx2x *bp, bool update_shmem)
 {
 	u32 dcbx_lldp_params_offset = SHMEM_LLDP_DCBX_PARAMS_NONE;
 
+	/* only PMF can send ADMIN msg to MFW in old MFW versions */
+	if ((!bp->port.pmf) && (!(bp->flags & BC_SUPPORTS_DCBX_MSG_NON_PMF)))
+		return;
+
 	if (bp->dcbx_enabled <= 0)
 		return;
 
 	/* validate:
 	 * chip of good for dcbx version,
 	 * dcb is wanted
-	 * the function is pmf
 	 * shmem2 contains DCBX support fields
 	 */
 	DP(BNX2X_MSG_DCB, "dcb_state %d bp->port.pmf %d\n",
 	   bp->dcb_state, bp->port.pmf);
 
-	if (bp->dcb_state == BNX2X_DCB_STATE_ON && bp->port.pmf &&
+	if (bp->dcb_state == BNX2X_DCB_STATE_ON &&
 	    SHMEM2_HAS(bp, dcbx_lldp_params_offset)) {
 		dcbx_lldp_params_offset =
 			SHMEM2_RD(bp, dcbx_lldp_params_offset);
@@ -999,12 +1002,23 @@ void bnx2x_dcbx_init(struct bnx2x *bp)
 		bnx2x_update_drv_flags(bp, 1 << DRV_FLAGS_DCB_CONFIGURED, 0);
 
 		if (SHMEM_LLDP_DCBX_PARAMS_NONE != dcbx_lldp_params_offset) {
-			bnx2x_dcbx_admin_mib_updated_params(bp,
-				dcbx_lldp_params_offset);
+			/* need HW lock to avoid scenario of two drivers
+			 * writing in parallel to shmem
+			 */
+			bnx2x_acquire_hw_lock(bp,
+					      HW_LOCK_RESOURCE_DCBX_ADMIN_MIB);
+			if (update_shmem)
+				bnx2x_dcbx_admin_mib_updated_params(bp,
+					dcbx_lldp_params_offset);
 
 			/* Let HW start negotiation */
 			bnx2x_fw_command(bp,
 					 DRV_MSG_CODE_DCBX_ADMIN_PMF_MSG, 0);
+			/* release HW lock only after MFW acks that it finished
+			 * reading values from shmem
+			 */
+			bnx2x_release_hw_lock(bp,
+					      HW_LOCK_RESOURCE_DCBX_ADMIN_MIB);
 		}
 	}
 }
@@ -2063,10 +2077,8 @@ static u8 bnx2x_dcbnl_set_all(struct net_device *netdev)
 			   "Handling parity error recovery. Try again later\n");
 		return 1;
 	}
-	if (netif_running(bp->dev)) {
-		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
-		rc = bnx2x_nic_load(bp, LOAD_NORMAL);
-	}
+	if (netif_running(bp->dev))
+		bnx2x_dcbx_init(bp, true);
 	DP(BNX2X_MSG_DCB, "set_dcbx_params done (%d)\n", rc);
 	if (rc)
 		return 1;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index c61aa37..6b77630 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -1253,6 +1253,7 @@ struct drv_func_mb {
 
 	#define DRV_MSG_CODE_DCBX_ADMIN_PMF_MSG         0xb0000000
 	#define DRV_MSG_CODE_DCBX_PMF_DRV_OK            0xb2000000
+	#define REQ_BC_VER_4_DCBX_ADMIN_MSG_NON_PMF     0x00070401
 
 	#define DRV_MSG_CODE_VF_DISABLED_DONE           0xc0000000
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 3a4fefd..26a8296 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9732,6 +9732,8 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	bp->flags |= (val >= REQ_BC_VER_4_PFC_STATS_SUPPORTED) ?
 			BC_SUPPORTS_PFC_STATS : 0;
 
+	bp->flags |= (val >= REQ_BC_VER_4_DCBX_ADMIN_MSG_NON_PMF) ?
+			BC_SUPPORTS_DCBX_MSG_NON_PMF : 0;
 	boot_mode = SHMEM_RD(bp,
 			dev_info.port_feature_config[BP_PORT(bp)].mba_config) &
 			PORT_FEATURE_MBA_BOOT_AGENT_TYPE_MASK;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index bfef98f..a78e356 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -5913,6 +5913,7 @@
 #define MISC_REGISTERS_SPIO_OUTPUT_LOW				 0
 #define MISC_REGISTERS_SPIO_SET_POS				 8
 #define HW_LOCK_MAX_RESOURCE_VALUE				 31
+#define HW_LOCK_RESOURCE_DCBX_ADMIN_MIB				 13
 #define HW_LOCK_RESOURCE_DRV_FLAGS				 10
 #define HW_LOCK_RESOURCE_GPIO					 1
 #define HW_LOCK_RESOURCE_MDIO					 0
-- 
1.7.10
