From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH] Add spinlocks to serialize ib_post_send/ib_post_recv
Date: Tue, 03 Oct 2006 09:46:41 -0500
Message-ID: <20061003144641.8901.28566.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: tom@opengridcomputing.com, openib-general@openib.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-218-104.sw.biz.rr.com ([24.153.218.104]:46777 "EHLO
	dell3.ogc.int") by vger.kernel.org with ESMTP id S932251AbWJCOqm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 10:46:42 -0400
To: rdreier@cisco.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Tucker <tom@opengridcomputing.com>

The AMSO driver was not thread-safe in the post WR code and had
code that would sleep if the WR post FIFO was full. Since these
functions can be called on interrupt level I changed the sleep to a
udelay.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 drivers/infiniband/hw/amso1100/c2_qp.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/amso1100/c2_qp.c b/drivers/infiniband/hw/amso1100/c2_qp.c
index 1226113..681c130 100644
--- a/drivers/infiniband/hw/amso1100/c2_qp.c
+++ b/drivers/infiniband/hw/amso1100/c2_qp.c
@@ -35,6 +35,7 @@
  *
  */
 
+#include <linux/delay.h>
 #include "c2.h"
 #include "c2_vq.h"
 #include "c2_status.h"
@@ -705,10 +706,8 @@ static inline void c2_activity(struct c2
 	 * cannot get on the bus and the card and system hang in a
 	 * deadlock -- thus the need for this code. [TOT]
 	 */
-	while (readl(c2dev->regs + PCI_BAR0_ADAPTER_HINT) & 0x80000000) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(0);
-	}
+	while (readl(c2dev->regs + PCI_BAR0_ADAPTER_HINT) & 0x80000000)
+		udelay(10);
 
 	__raw_writel(C2_HINT_MAKE(mq_index, shared),
 		     c2dev->regs + PCI_BAR0_ADAPTER_HINT);
@@ -766,6 +765,7 @@ int c2_post_send(struct ib_qp *ibqp, str
 	struct c2_dev *c2dev = to_c2dev(ibqp->device);
 	struct c2_qp *qp = to_c2qp(ibqp);
 	union c2wr wr;
+	unsigned long lock_flags;
 	int err = 0;
 
 	u32 flags;
@@ -881,8 +881,10 @@ int c2_post_send(struct ib_qp *ibqp, str
 		/*
 		 * Post the puppy!
 		 */
+		spin_lock_irqsave(&qp->lock, lock_flags);
 		err = qp_wr_post(&qp->sq_mq, &wr, qp, msg_size);
 		if (err) {
+			spin_unlock_irqrestore(&qp->lock, lock_flags);
 			break;
 		}
 
@@ -890,6 +892,7 @@ int c2_post_send(struct ib_qp *ibqp, str
 		 * Enqueue mq index to activity FIFO.
 		 */
 		c2_activity(c2dev, qp->sq_mq.index, qp->sq_mq.hint_count);
+		spin_unlock_irqrestore(&qp->lock, lock_flags);
 
 		ib_wr = ib_wr->next;
 	}
@@ -905,6 +908,7 @@ int c2_post_receive(struct ib_qp *ibqp, 
 	struct c2_dev *c2dev = to_c2dev(ibqp->device);
 	struct c2_qp *qp = to_c2qp(ibqp);
 	union c2wr wr;
+	unsigned long lock_flags;
 	int err = 0;
 
 	if (qp->state > IB_QPS_RTS)
@@ -945,8 +949,10 @@ int c2_post_receive(struct ib_qp *ibqp, 
 			break;
 		}
 
+		spin_lock_irqsave(&qp->lock, lock_flags);
 		err = qp_wr_post(&qp->rq_mq, &wr, qp, qp->rq_mq.msg_size);
 		if (err) {
+			spin_unlock_irqrestore(&qp->lock, lock_flags);
 			break;
 		}
 
@@ -954,6 +960,7 @@ int c2_post_receive(struct ib_qp *ibqp, 
 		 * Enqueue mq index to activity FIFO
 		 */
 		c2_activity(c2dev, qp->rq_mq.index, qp->rq_mq.hint_count);
+		spin_unlock_irqrestore(&qp->lock, lock_flags);
 
 		ib_wr = ib_wr->next;
 	}
