From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH 3/3] bnx2x: remove {TPA,GRO}_ENABLE_FLAG
Date: Tue, 28 Apr 2015 11:34:23 +0200
Message-ID: <1430213663-5657-4-git-send-email-mschmidt@redhat.com>
References: <1430213663-5657-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50491 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933000AbbD1Jed (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 05:34:33 -0400
In-Reply-To: <1430213663-5657-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These flags are redundant with dev->features. Remove them.
Just make sure to set dev->features ourselves in bnx2x_set_features()
before performing the reload of the card.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  2 --
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 39 +++++++++---------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  5 +--
 3 files changed, 15 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 2a41604cdd..a3b0f7a0c6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1545,9 +1545,7 @@ struct bnx2x {
 #define USING_MSIX_FLAG			(1 << 5)
 #define USING_MSI_FLAG			(1 << 6)
 #define DISABLE_MSI_FLAG		(1 << 7)
-#define TPA_ENABLE_FLAG			(1 << 8)
 #define NO_MCP_FLAG			(1 << 9)
-#define GRO_ENABLE_FLAG			(1 << 10)
 #define MF_FUNC_DIS			(1 << 11)
 #define OWN_CNIC_IRQ			(1 << 12)
 #define NO_ISCSI_OOO_FLAG		(1 << 13)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 84612b082b..a8bb8f664d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2477,9 +2477,9 @@ static void bnx2x_bz_fp(struct bnx2x *bp, int index)
 	/* set the tpa flag for each queue. The tpa flag determines the queue
 	 * minimal size so it must be set prior to queue memory allocation
 	 */
-	if (bp->flags & TPA_ENABLE_FLAG)
+	if (bp->dev->features & NETIF_F_LRO)
 		fp->mode = TPA_MODE_LRO;
-	else if (bp->flags & GRO_ENABLE_FLAG &&
+	else if (bp->dev->features & NETIF_F_GRO &&
 		 bnx2x_mtu_allows_gro(bp->dev->mtu))
 		fp->mode = TPA_MODE_GRO;
 	else
@@ -3249,7 +3249,7 @@ int bnx2x_low_latency_recv(struct napi_struct *napi)
 
 	if ((bp->state == BNX2X_STATE_CLOSED) ||
 	    (bp->state == BNX2X_STATE_ERROR) ||
-	    (bp->flags & (TPA_ENABLE_FLAG | GRO_ENABLE_FLAG)))
+	    (bp->dev->features & (NETIF_F_LRO | NETIF_F_GRO)))
 		return LL_FLUSH_FAILED;
 
 	if (!bnx2x_fp_lock_poll(fp))
@@ -4840,19 +4840,9 @@ netdev_features_t bnx2x_fix_features(struct net_device *dev,
 int bnx2x_set_features(struct net_device *dev, netdev_features_t features)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	u32 flags = bp->flags;
-	u32 changes;
+	netdev_features_t changes = features ^ dev->features;
 	bool bnx2x_reload = false;
-
-	if (features & NETIF_F_LRO)
-		flags |= TPA_ENABLE_FLAG;
-	else
-		flags &= ~TPA_ENABLE_FLAG;
-
-	if (features & NETIF_F_GRO)
-		flags |= GRO_ENABLE_FLAG;
-	else
-		flags &= ~GRO_ENABLE_FLAG;
+	int rc;
 
 	/* VFs or non SRIOV PFs should be able to change loopback feature */
 	if (!pci_num_vf(bp->pdev)) {
@@ -4869,24 +4859,23 @@ int bnx2x_set_features(struct net_device *dev, netdev_features_t features)
 		}
 	}
 
-	changes = flags ^ bp->flags;
-
 	/* if GRO is changed while LRO is enabled, don't force a reload */
-	if ((changes & GRO_ENABLE_FLAG) && (flags & TPA_ENABLE_FLAG))
-		changes &= ~GRO_ENABLE_FLAG;
+	if ((changes & NETIF_F_GRO) && (features & NETIF_F_LRO))
+		changes &= ~NETIF_F_GRO;
 
 	/* if GRO is changed while HW TPA is off, don't force a reload */
-	if ((changes & GRO_ENABLE_FLAG) && bp->disable_tpa)
-		changes &= ~GRO_ENABLE_FLAG;
+	if ((changes & NETIF_F_GRO) && bp->disable_tpa)
+		changes &= ~NETIF_F_GRO;
 
 	if (changes)
 		bnx2x_reload = true;
 
-	bp->flags = flags;
-
 	if (bnx2x_reload) {
-		if (bp->recovery_state == BNX2X_RECOVERY_DONE)
-			return bnx2x_reload_if_running(dev);
+		if (bp->recovery_state == BNX2X_RECOVERY_DONE) {
+			dev->features = features;
+			rc = bnx2x_reload_if_running(dev);
+			return rc ? rc : 1;
+		}
 		/* else: bnx2x_nic_load() will be called at end of recovery */
 	}
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 64ea5adf72..60d2b8ebba 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -3304,7 +3304,7 @@ static void bnx2x_pf_init(struct bnx2x *bp)
 	/* This flag is relevant for E1x only.
 	 * E2 doesn't have a TPA configuration in a function level.
 	 */
-	flags |= (bp->flags & TPA_ENABLE_FLAG) ? FUNC_FLG_TPA : 0;
+	flags |= (bp->dev->features & NETIF_F_LRO) ? FUNC_FLG_TPA : 0;
 
 	func_init.func_flgs = flags;
 	func_init.pf_id = BP_FUNC(bp);
@@ -12107,11 +12107,8 @@ static int bnx2x_init_bp(struct bnx2x *bp)
 
 	/* Set TPA flags */
 	if (bp->disable_tpa) {
-		bp->flags &= ~(TPA_ENABLE_FLAG | GRO_ENABLE_FLAG);
 		bp->dev->hw_features &= ~NETIF_F_LRO;
 		bp->dev->features &= ~NETIF_F_LRO;
-	} else {
-		bp->flags |= (TPA_ENABLE_FLAG | GRO_ENABLE_FLAG);
 	}
 
 	if (CHIP_IS_E1(bp))
-- 
2.1.0
