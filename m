From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.21] iw_cxgb3 - Add set_tcb_rpl_handler.
Date: Thu, 12 Apr 2007 07:56:34 -0500
Message-ID: <1176382594.9396.1.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Divy Le Ray <divy@chelsio.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	OpenFabrics General <general@lists.openfabrics.org>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Hey Roland,

This patch is needed for iw_cxgb3 to handle a change in the cxgb3 driver
posted by Divy that Jeff recently applied.  If the cxgb3 change is
destined for 2.6.21, then this change to iw_cxgb3 also needs to go in
(otherwise we get an error log entry for every rdma connection).  

It was an oversight that this patch didn't really get included in Divy's
series since the two go together.

See http://marc.info/?l=linux-netdev&m=117617444422260&w=2


Thanks,

Steve.


---


Add set_tcb_rpl_handler.

The Ethernet Driver no longer handles SET_TCB replies.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_cm.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index d0ed1d3..2d2de9b 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -2026,6 +2026,17 @@ static int sched(struct t3cdev *tdev, st
 	return 0;
 }
 
+static int set_tcb_rpl(struct t3cdev *tdev, struct sk_buff *skb, void *ctx)
+{
+	struct cpl_set_tcb_rpl *rpl = cplhdr(skb);
+
+	if (rpl->status != CPL_ERR_NONE) {
+		printk(KERN_ERR MOD "Unexpected SET_TCB_RPL status %u "
+		       "for tid %u\n", rpl->status, GET_TID(rpl));
+	}
+	return CPL_RET_BUF_DONE;
+}
+
 int __init iwch_cm_init(void)
 {
 	skb_queue_head_init(&rxq);
@@ -2053,6 +2064,7 @@ int __init iwch_cm_init(void)
 	t3c_handlers[CPL_ABORT_REQ_RSS] = sched;
 	t3c_handlers[CPL_RDMA_TERMINATE] = sched;
 	t3c_handlers[CPL_RDMA_EC_STATUS] = sched;
+	t3c_handlers[CPL_SET_TCB_RPL] = set_tcb_rpl;
 
 	/*
 	 * These are the real handlers that are called from a
