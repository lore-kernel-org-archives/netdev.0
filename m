From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 03/13] bnx2x: Management can control PFC/ETS
Date: Sun, 2 Dec 2012 16:05:47 +0200
Message-ID: <1354457157-4730-4-git-send-email-yuvalmin@broadcom.com>
References: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Barak Witkowski" <barak@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2505 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752090Ab2LBOFE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2012 09:05:04 -0500
In-Reply-To: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barak Witkowski <barak@broadcom.com>

If configured for PFC/ETS by management, configure chip regardless of the
presence of a remote peer which supports DCBX.

Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c |   21 +++++++++++++++++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h |    7 ++++++-
 3 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 8779ac1..e95174d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2426,7 +2426,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	}
 
 	if (bp->port.pmf)
-		bnx2x_update_drv_flags(bp, 1 << DRV_FLAGS_DCB_CONFIGURED, 0);
+		bnx2x_update_drv_flags(bp, 1 << DRV_FLAGS_PORT_MASK, 0);
 	else
 		bnx2x__link_status_update(bp);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index cba4a16..c0d9b69 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -413,8 +413,11 @@ static int bnx2x_dcbx_read_mib(struct bnx2x *bp,
 
 static void bnx2x_pfc_set_pfc(struct bnx2x *bp)
 {
+	int mfw_configured = SHMEM2_HAS(bp, drv_flags) &&
+			     GET_FLAGS(SHMEM2_RD(bp, drv_flags),
+				       1 << DRV_FLAGS_DCB_MFW_CONFIGURED);
 	if (bp->dcbx_port_params.pfc.enabled &&
-	    !(bp->dcbx_error & DCBX_REMOTE_MIB_ERROR))
+	    (!(bp->dcbx_error & DCBX_REMOTE_MIB_ERROR) || mfw_configured))
 		/*
 		 * 1. Fills up common PFC structures if required
 		 * 2. Configure NIG, MAC and BRB via the elink
@@ -552,10 +555,13 @@ static void bnx2x_dcbx_update_ets_config(struct bnx2x *bp)
 
 static void bnx2x_dcbx_update_ets_params(struct bnx2x *bp)
 {
+	int mfw_configured = SHMEM2_HAS(bp, drv_flags) &&
+			     GET_FLAGS(SHMEM2_RD(bp, drv_flags),
+				       1 << DRV_FLAGS_DCB_MFW_CONFIGURED);
 	bnx2x_ets_disabled(&bp->link_params, &bp->link_vars);
 
 	if (!bp->dcbx_port_params.ets.enabled ||
-	    (bp->dcbx_error & DCBX_REMOTE_MIB_ERROR))
+	    ((bp->dcbx_error & DCBX_REMOTE_MIB_ERROR) && !mfw_configured))
 		return;
 
 	if (CHIP_IS_E3B0(bp))
@@ -1802,11 +1808,14 @@ static void bnx2x_dcbx_fw_struct(struct bnx2x *bp,
 	u8 cos = 0, pri = 0;
 	struct priority_cos *tt2cos;
 	u32 *ttp = bp->dcbx_port_params.app.traffic_type_priority;
+	int mfw_configured = SHMEM2_HAS(bp, drv_flags) &&
+			     GET_FLAGS(SHMEM2_RD(bp, drv_flags),
+				       1 << DRV_FLAGS_DCB_MFW_CONFIGURED);
 
 	memset(pfc_fw_cfg, 0, sizeof(*pfc_fw_cfg));
 
 	/* to disable DCB - the structure must be zeroed */
-	if (bp->dcbx_error & DCBX_REMOTE_MIB_ERROR)
+	if ((bp->dcbx_error & DCBX_REMOTE_MIB_ERROR) && !mfw_configured)
 		return;
 
 	/*shortcut*/
@@ -2073,8 +2082,12 @@ static u8 bnx2x_dcbnl_set_all(struct net_device *netdev)
 			   "Handling parity error recovery. Try again later\n");
 		return 1;
 	}
-	if (netif_running(bp->dev))
+	if (netif_running(bp->dev)) {
+		bnx2x_update_drv_flags(bp,
+				       1 << DRV_FLAGS_DCB_MFW_CONFIGURED,
+				       1);
 		bnx2x_dcbx_init(bp, true);
+	}
 	DP(BNX2X_MSG_DCB, "set_dcbx_params done (%d)\n", rc);
 	if (rc)
 		return 1;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 1504e0a..9a51d49 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -2088,8 +2088,13 @@ struct shmem2_region {
 
 	/* generic flags controlled by the driver */
 	u32 drv_flags;
-	#define DRV_FLAGS_DCB_CONFIGURED                0x1
+	#define DRV_FLAGS_DCB_CONFIGURED		0x0
+	#define DRV_FLAGS_DCB_CONFIGURATION_ABORTED	0x1
+	#define DRV_FLAGS_DCB_MFW_CONFIGURED	0x2
 
+	#define DRV_FLAGS_PORT_MASK	((1 << DRV_FLAGS_DCB_CONFIGURED) | \
+			(1 << DRV_FLAGS_DCB_CONFIGURATION_ABORTED) | \
+			(1 << DRV_FLAGS_DCB_MFW_CONFIGURED))
 	/* pointer to extended dev_info shared data copied from nvm image */
 	u32 extended_dev_info_shared_addr;
 	u32 ncsi_oem_data_addr;
-- 
1.7.1
