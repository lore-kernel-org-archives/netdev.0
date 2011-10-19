From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH 06/10] RDMA/cxgb4: disable interrupts in c4iw_ev_dispatch().
Date: Wed, 19 Oct 2011 22:41:00 +0530
Message-ID: <1319044264-779-7-git-send-email-vipul@chelsio.com>
References: <1319044264-779-1-git-send-email-vipul@chelsio.com>
Cc: roland@purestorage.com, davem@davemloft.net, divy@chelsio.com,
	dm@chelsio.com, kumaras@chelsio.com, swise@opengridcomputing.com,
	Vipul Pandya <vipul@chelsio.com>
To: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:29373 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756904Ab1JSRNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 13:13:35 -0400
In-Reply-To: <1319044264-779-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Use GFP_ATOMIC in _insert_handle() if ints are disabled.

	Don't panic if we get an abort with no endpoint found. Just log a
	warning.

Signed-off-by: Vipul Pandya <vipul@chelsio.com>
Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cm.c       |    5 ++++-
 drivers/infiniband/hw/cxgb4/ev.c       |    8 ++++----
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h |    2 +-
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index b36cdac..c51818a 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1360,7 +1360,10 @@ static int abort_rpl(struct c4iw_dev *dev, struct sk_buff *skb)
 
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
index c13041a..e9eac34 100644
--- a/drivers/infiniband/hw/cxgb4/ev.c
+++ b/drivers/infiniband/hw/cxgb4/ev.c
@@ -81,7 +81,7 @@ void c4iw_ev_dispatch(struct c4iw_dev *dev, struct t4_cqe *err_cqe)
 	struct c4iw_qp *qhp;
 	u32 cqid;
 
-	spin_lock(&dev->lock);
+	spin_lock_irq(&dev->lock);
 	qhp = get_qhp(dev, CQE_QPID(err_cqe));
 	if (!qhp) {
 		printk(KERN_ERR MOD "BAD AE qpid 0x%x opcode %d "
@@ -90,7 +90,7 @@ void c4iw_ev_dispatch(struct c4iw_dev *dev, struct t4_cqe *err_cqe)
 		       CQE_OPCODE(err_cqe), CQE_STATUS(err_cqe),
 		       CQE_TYPE(err_cqe), CQE_WRID_HI(err_cqe),
 		       CQE_WRID_LOW(err_cqe));
-		spin_unlock(&dev->lock);
+		spin_unlock_irq(&dev->lock);
 		goto out;
 	}
 
@@ -106,13 +106,13 @@ void c4iw_ev_dispatch(struct c4iw_dev *dev, struct t4_cqe *err_cqe)
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
index 1924c19..2ce7741 100644
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
