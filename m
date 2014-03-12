From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCHv6 net-next 29/31] iw_cxgb4: minor fixes
Date: Wed, 12 Mar 2014 21:20:44 +0530
Message-ID: <1394639446-6504-30-git-send-email-hariprasad@chelsio.com>
References: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394639446-6504-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>

Added some missing debug stats.

Use uninitialized_var().

Initialize reserved fields in a FW work request.

Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/cq.c       | 2 +-
 drivers/infiniband/hw/cxgb4/mem.c      | 6 +++++-
 drivers/infiniband/hw/cxgb4/qp.c       | 2 ++
 drivers/infiniband/hw/cxgb4/resource.c | 6 +++++-
 4 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cq.c b/drivers/infiniband/hw/cxgb4/cq.c
index 121ad07..a47b845 100644
--- a/drivers/infiniband/hw/cxgb4/cq.c
+++ b/drivers/infiniband/hw/cxgb4/cq.c
@@ -672,7 +672,7 @@ skip_cqe:
 static int c4iw_poll_cq_one(struct c4iw_cq *chp, struct ib_wc *wc)
 {
 	struct c4iw_qp *qhp = NULL;
-	struct t4_cqe cqe = {0, 0}, *rd_cqe;
+	struct t4_cqe uninitialized_var(cqe), *rd_cqe;
 	struct t4_wq *wq;
 	u32 credit = 0;
 	u8 cqe_flushed;
diff --git a/drivers/infiniband/hw/cxgb4/mem.c b/drivers/infiniband/hw/cxgb4/mem.c
index 22a2e3e..0989871a 100644
--- a/drivers/infiniband/hw/cxgb4/mem.c
+++ b/drivers/infiniband/hw/cxgb4/mem.c
@@ -259,8 +259,12 @@ static int write_tpt_entry(struct c4iw_rdev *rdev, u32 reset_tpt_entry,
 
 	if ((!reset_tpt_entry) && (*stag == T4_STAG_UNSET)) {
 		stag_idx = c4iw_get_resource(&rdev->resource.tpt_table);
-		if (!stag_idx)
+		if (!stag_idx) {
+			mutex_lock(&rdev->stats.lock);
+			rdev->stats.stag.fail++;
+			mutex_unlock(&rdev->stats.lock);
 			return -ENOMEM;
+		}
 		mutex_lock(&rdev->stats.lock);
 		rdev->stats.stag.cur += 32;
 		if (rdev->stats.stag.cur > rdev->stats.stag.max)
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index 141999d..dfe37fc 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -428,6 +428,8 @@ static int build_rdma_send(struct t4_sq *sq, union t4_wr *wqe,
 	default:
 		return -EINVAL;
 	}
+	wqe->send.r3 = 0;
+	wqe->send.r4 = 0;
 
 	plen = 0;
 	if (wr->num_sge) {
diff --git a/drivers/infiniband/hw/cxgb4/resource.c b/drivers/infiniband/hw/cxgb4/resource.c
index cdef4d7..d9bc9ba 100644
--- a/drivers/infiniband/hw/cxgb4/resource.c
+++ b/drivers/infiniband/hw/cxgb4/resource.c
@@ -179,8 +179,12 @@ u32 c4iw_get_qpid(struct c4iw_rdev *rdev, struct c4iw_dev_ucontext *uctx)
 		kfree(entry);
 	} else {
 		qid = c4iw_get_resource(&rdev->resource.qid_table);
-		if (!qid)
+		if (!qid) {
+			mutex_lock(&rdev->stats.lock);
+			rdev->stats.qid.fail++;
+			mutex_unlock(&rdev->stats.lock);
 			goto out;
+		}
 		mutex_lock(&rdev->stats.lock);
 		rdev->stats.qid.cur += rdev->qpmask + 1;
 		mutex_unlock(&rdev->stats.lock);
-- 
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
