From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 5/5] bnx2x: Fix VF stats sync
Date: Wed, 28 Aug 2013 01:13:04 +0300
Message-ID: <1377641584-2939-6-git-send-email-yuvalmin@broadcom.com>
References: <1377641584-2939-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2563 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753894Ab3H0WNV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 18:13:21 -0400
In-Reply-To: <1377641584-2939-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Since the PF gathers statistics for the VF, when the VF is about to unload
we must synchronize the release of its statistics buffer with the PF, so that
no DMA operation will be made to that address after the buffer release.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 26 ++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 11 ++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h |  3 +++
 3 files changed, 39 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index b7efe27..e8706e1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -2786,6 +2786,18 @@ int bnx2x_vf_init(struct bnx2x *bp, struct bnx2x_virtf *vf, dma_addr_t *sb_map)
 	return 0;
 }
 
+struct set_vf_state_cookie {
+	struct bnx2x_virtf *vf;
+	u8 state;
+};
+
+void bnx2x_set_vf_state(void *cookie)
+{
+	struct set_vf_state_cookie *p = (struct set_vf_state_cookie *)cookie;
+
+	p->vf->state = p->state;
+}
+
 /* VFOP close (teardown the queues, delete mcasts and close HW) */
 static void bnx2x_vfop_close(struct bnx2x *bp, struct bnx2x_virtf *vf)
 {
@@ -2836,7 +2848,19 @@ static void bnx2x_vfop_close(struct bnx2x *bp, struct bnx2x_virtf *vf)
 op_err:
 	BNX2X_ERR("VF[%d] CLOSE error: rc %d\n", vf->abs_vfid, vfop->rc);
 op_done:
-	vf->state = VF_ACQUIRED;
+
+	/* need to make sure there are no outstanding stats ramrods which may
+	 * cause the device to access the VF's stats buffer which it will free
+	 * as soon as we return from the close flow.
+	 */
+	{
+		struct set_vf_state_cookie cookie;
+
+		cookie.vf = vf;
+		cookie.state = VF_ACQUIRED;
+		bnx2x_stats_safe_exec(bp, bnx2x_set_vf_state, &cookie);
+	}
+
 	DP(BNX2X_MSG_IOV, "set state to acquired\n");
 	bnx2x_vfop_end(bp, vf, vfop);
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index fed9b15..86436c7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1993,3 +1993,14 @@ void bnx2x_afex_collect_stats(struct bnx2x *bp, void *void_afex_stats,
 		       estats->mac_discard);
 	}
 }
+
+void bnx2x_stats_safe_exec(struct bnx2x *bp,
+			   void (func_to_exec)(void *cookie),
+			   void *cookie){
+	if (down_timeout(&bp->stats_sema, HZ/10))
+		BNX2X_ERR("Unable to acquire stats lock\n");
+	bnx2x_stats_comp(bp);
+	func_to_exec(cookie);
+	__bnx2x_stats_start(bp);
+	up(&bp->stats_sema);
+}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
index 853824d..f358450 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
@@ -539,6 +539,9 @@ struct bnx2x;
 void bnx2x_memset_stats(struct bnx2x *bp);
 void bnx2x_stats_init(struct bnx2x *bp);
 void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event);
+void bnx2x_stats_safe_exec(struct bnx2x *bp,
+			   void (func_to_exec)(void *cookie),
+			   void *cookie);
 
 /**
  * bnx2x_save_statistics - save statistics when unloading.
-- 
1.8.1.227.g44fe835
