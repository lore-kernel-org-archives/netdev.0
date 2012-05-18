From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 06/10] RDMA/cxgb4: disable interrupts in c4iw_ev_dispatch().
Date: Fri, 18 May 2012 15:29:29 +0530
Message-ID: <1337335173-3226-7-git-send-email-vipul@chelsio.com>
References: <1337335173-3226-1-git-send-email-vipul@chelsio.com>
Cc: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1337335173-3226-1-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use GFP_ATOMIC in _insert_handle() if ints are disabled.

Don't panic if we get an abort with no endpoint found. Just log a
warning.

Signed-off-by: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/cm.c       |    5 ++++-
 drivers/infiniband/hw/cxgb4/ev.c       |    8 ++++----
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h |    2 +-
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 4c7c62f..6ce401a 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1362,7 +1362,10 @@ static int abort_rpl(struct c4iw_dev *dev, struct sk_buff *skb)
 
 	ep = lookup_tid(t, tid);
 	PDBG("%s ep %p tid %u\n", __func__, ep, ep->hwtid);
-	BUG_ON(!ep);
+	if (!ep) {
+		printk(KERN_WARNING MOD "Abort rpl to freed endpoint\n");
+		return 0;
+	}
 	mutex_lock(&ep->com.mutex);
 	switch (ep->com.state) {
 	case ABORTING:
diff --git a/drivers/infiniband/hw/cxgb4/ev.c b/drivers/infiniband/hw/cxgb4/ev.c
index 397cb36..cf2f6b4 100644
--- a/drivers/infiniband/hw/cxgb4/ev.c
+++ b/drivers/infiniband/hw/cxgb4/ev.c
@@ -84,7 +84,7 @@ void c4iw_ev_dispatch(struct c4iw_dev *dev, struct t4_cqe *err_cqe)
 	struct c4iw_qp *qhp;
 	u32 cqid;
 
-	spin_lock(&dev->lock);
+	spin_lock_irq(&dev->lock);
 	qhp = get_qhp(dev, CQE_QPID(err_cqe));
 	if (!qhp) {
 		printk(KERN_ERR MOD "BAD AE qpid 0x%x opcode %d "
@@ -93,7 +93,7 @@ void c4iw_ev_dispatch(struct c4iw_dev *dev, struct t4_cqe *err_cqe)
 		       CQE_OPCODE(err_cqe), CQE_STATUS(err_cqe),
 		       CQE_TYPE(err_cqe), CQE_WRID_HI(err_cqe),
 		       CQE_WRID_LOW(err_cqe));
-		spin_unlock(&dev->lock);
+		spin_unlock_irq(&dev->lock);
 		goto out;
 	}
 
@@ -109,13 +109,13 @@ void c4iw_ev_dispatch(struct c4iw_dev *dev, struct t4_cqe *err_cqe)
 		       CQE_OPCODE(err_cqe), CQE_STATUS(err_cqe),
 		       CQE_TYPE(err_cqe), CQE_WRID_HI(err_cqe),
 		       CQE_WRID_LOW(err_cqe));
-		spin_unlock(&dev->lock);
+		spin_unlock_irq(&dev->lock);
 		goto out;
 	}
 
 	c4iw_qp_add_ref(&qhp->ibqp);
 	atomic_inc(&chp->refcnt);
-	spin_unlock(&dev->lock);
+	spin_unlock_irq(&dev->lock);
 
 	/* Bad incoming write */
 	if (RQ_TYPE(err_cqe) &&
diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index a11ed5c..e8b88a0 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -246,7 +246,7 @@ static inline int _insert_handle(struct c4iw_dev *rhp, struct idr *idr,
 	int newid;
 
 	do {
-		if (!idr_pre_get(idr, GFP_KERNEL))
+		if (!idr_pre_get(idr, lock ? GFP_KERNEL : GFP_ATOMIC))
 			return -ENOMEM;
 		if (lock)
 			spin_lock_irq(&rhp->lock);
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
