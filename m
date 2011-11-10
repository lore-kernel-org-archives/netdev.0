From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 04/13] bnx2x: separate FCoE and iSCSI license
 initialization.
Date: Thu, 10 Nov 2011 17:14:05 +0200
Message-ID: <1320938054-31288-5-git-send-email-dmitry@broadcom.com>
References: <1320938054-31288-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2079 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934282Ab1KJPOc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Nov 2011 10:14:32 -0500
In-Reply-To: <1320938054-31288-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FCoE license info must be initialized at probe(), but
iSCSI at open().

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |   10 +++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   45 ++++++++++++++++-----
 3 files changed, 46 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index f946a6e..3f80c11 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1934,6 +1934,8 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
 
 #ifdef BCM_CNIC
+	/* re-read iscsi info */
+	bnx2x_get_iscsi_info(bp);
 	bnx2x_setup_cnic_irq_info(bp);
 	if (bp->state == BNX2X_STATE_OPEN)
 		bnx2x_cnic_notify(bp, CNIC_CTL_START_CMD);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 4a16757..c1d7833 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1489,4 +1489,14 @@ static inline u16 bnx2x_extract_max_cfg(struct bnx2x *bp, u32 mf_cfg)
 	return max_cfg;
 }
 
+#ifdef BCM_CNIC
+/**
+ * bnx2x_get_iscsi_info - update iSCSI params according to licensing info.
+ *
+ * @bp:		driver handle
+ *
+ */
+void bnx2x_get_iscsi_info(struct bnx2x *bp);
+#endif
+
 #endif /* BNX2X_CMN_H */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 1d185f2..26dc539 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9268,21 +9268,38 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 }
 
 #ifdef BCM_CNIC
-static void __devinit bnx2x_get_cnic_info(struct bnx2x *bp)
+void bnx2x_get_iscsi_info(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
-	int func = BP_ABS_FUNC(bp);
 
 	u32 max_iscsi_conn = FW_ENCODE_32BIT_PATTERN ^ SHMEM_RD(bp,
 				drv_lic_key[port].max_iscsi_conn);
-	u32 max_fcoe_conn = FW_ENCODE_32BIT_PATTERN ^ SHMEM_RD(bp,
-				drv_lic_key[port].max_fcoe_conn);
 
-	/* Get the number of maximum allowed iSCSI and FCoE connections */
+	/* Get the number of maximum allowed iSCSI connections */
 	bp->cnic_eth_dev.max_iscsi_conn =
 		(max_iscsi_conn & BNX2X_MAX_ISCSI_INIT_CONN_MASK) >>
 		BNX2X_MAX_ISCSI_INIT_CONN_SHIFT;
 
+	BNX2X_DEV_INFO("max_iscsi_conn 0x%x\n",
+		       bp->cnic_eth_dev.max_iscsi_conn);
+
+	/*
+	 * If maximum allowed number of connections is zero -
+	 * disable the feature.
+	 */
+	if (!bp->cnic_eth_dev.max_iscsi_conn)
+		bp->flags |= NO_ISCSI_FLAG;
+}
+
+static void __devinit bnx2x_get_fcoe_info(struct bnx2x *bp)
+{
+	int port = BP_PORT(bp);
+	int func = BP_ABS_FUNC(bp);
+
+	u32 max_fcoe_conn = FW_ENCODE_32BIT_PATTERN ^ SHMEM_RD(bp,
+				drv_lic_key[port].max_fcoe_conn);
+
+	/* Get the number of maximum allowed FCoE connections */
 	bp->cnic_eth_dev.max_fcoe_conn =
 		(max_fcoe_conn & BNX2X_MAX_FCOE_INIT_CONN_MASK) >>
 		BNX2X_MAX_FCOE_INIT_CONN_SHIFT;
@@ -9334,20 +9351,26 @@ static void __devinit bnx2x_get_cnic_info(struct bnx2x *bp)
 		}
 	}
 
-	BNX2X_DEV_INFO("max_iscsi_conn 0x%x max_fcoe_conn 0x%x\n",
-		       bp->cnic_eth_dev.max_iscsi_conn,
-		       bp->cnic_eth_dev.max_fcoe_conn);
+	BNX2X_DEV_INFO("max_fcoe_conn 0x%x\n", bp->cnic_eth_dev.max_fcoe_conn);
 
 	/*
 	 * If maximum allowed number of connections is zero -
 	 * disable the feature.
 	 */
-	if (!bp->cnic_eth_dev.max_iscsi_conn)
-		bp->flags |= NO_ISCSI_OOO_FLAG | NO_ISCSI_FLAG;
-
 	if (!bp->cnic_eth_dev.max_fcoe_conn)
 		bp->flags |= NO_FCOE_FLAG;
 }
+
+static void __devinit bnx2x_get_cnic_info(struct bnx2x *bp)
+{
+	/*
+	 * iSCSI may be dynamically disabled but reading
+	 * info here we will decrease memory usage by driver
+	 * if the feature is disabled for good
+	 */
+	bnx2x_get_iscsi_info(bp);
+	bnx2x_get_fcoe_info(bp);
+}
 #endif
 
 static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
-- 
1.7.7.2
