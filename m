From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next] bnx2x: Fix compilation with no IOV support
Date: Mon, 24 Jun 2013 11:04:10 +0300
Message-ID: <1372061050-9206-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3216 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752928Ab3FXIE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 04:04:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes an issue caused by submit 78c3bcc5d1af64f51d9f30b0f5a2d1985bf69734
`bnx2x: Improve PF behaviour toward VF', which made the bnx2x driver fail
compilation when PCI_IOV is not set.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Hi Dave,

Please consider applying this to `net-next'.

Thanks,
Yuval Mintz
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  | 14 ++------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 14 ++++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h |  2 ++
 3 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index d468fe4..7318988 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -5457,18 +5457,8 @@ static void bnx2x_timer(unsigned long data)
 		bnx2x_stats_handle(bp, STATS_EVENT_UPDATE);
 
 	/* sample pf vf bulletin board for new posts from pf */
-	if (IS_VF(bp)) {
-		bnx2x_sample_bulletin(bp);
-
-		/* if channel is down we need to self destruct */
-		if (bp->old_bulletin.valid_bitmap & 1 << CHANNEL_DOWN) {
-			smp_mb__before_clear_bit();
-			set_bit(BNX2X_SP_RTNL_VFPF_CHANNEL_DOWN,
-				&bp->sp_rtnl_state);
-			smp_mb__after_clear_bit();
-			schedule_delayed_work(&bp->sp_rtnl_task, 0);
-		}
-	}
+	if (IS_VF(bp))
+		bnx2x_timer_sriov(bp);
 
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index bda4d7e..95861ef 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -3426,6 +3426,20 @@ enum sample_bulletin_result bnx2x_sample_bulletin(struct bnx2x *bp)
 	return PFVF_BULLETIN_UPDATED;
 }
 
+void bnx2x_timer_sriov(struct bnx2x *bp)
+{
+	bnx2x_sample_bulletin(bp);
+
+	/* if channel is down we need to self destruct */
+	if (bp->old_bulletin.valid_bitmap & 1 << CHANNEL_DOWN) {
+		smp_mb__before_clear_bit();
+		set_bit(BNX2X_SP_RTNL_VFPF_CHANNEL_DOWN,
+			&bp->sp_rtnl_state);
+		smp_mb__after_clear_bit();
+		schedule_delayed_work(&bp->sp_rtnl_task, 0);
+	}
+}
+
 void __iomem *bnx2x_vf_doorbells(struct bnx2x *bp)
 {
 	/* vf doorbells are embedded within the regview */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index 9fc029e..d143a7c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -751,6 +751,7 @@ static inline int bnx2x_vf_ustorm_prods_offset(struct bnx2x *bp,
 }
 
 enum sample_bulletin_result bnx2x_sample_bulletin(struct bnx2x *bp);
+void bnx2x_timer_sriov(struct bnx2x *bp);
 void __iomem *bnx2x_vf_doorbells(struct bnx2x *bp);
 int bnx2x_vf_pci_alloc(struct bnx2x *bp);
 int bnx2x_enable_sriov(struct bnx2x *bp);
@@ -809,6 +810,7 @@ static inline enum sample_bulletin_result bnx2x_sample_bulletin(struct bnx2x *bp
 {
 	return PFVF_BULLETIN_UNCHANGED;
 }
+static inline void bnx2x_timer_sriov(struct bnx2x *bp) {}
 
 static inline void __iomem *bnx2x_vf_doorbells(struct bnx2x *bp)
 {
-- 
1.8.1.227.g44fe835
