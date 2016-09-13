From: Varun Prakash <varun@chelsio.com>
Subject: [net-next PATCH 10/11] libcxgb,iw_cxgb4,cxgbit: add cxgb_mk_abort_rpl()
Date: Tue, 13 Sep 2016 21:24:05 +0530
Message-ID: <df6f672316df4f3d804f0c60d10504f85178e559.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        target-devel@vger.kernel.org, nab@linux-iscsi.org,
        dledford@redhat.com, swise@opengridcomputing.com,
        gerlitz.or@gmail.com, indranil@chelsio.com, varun@chelsio.com
To: davem@davemloft.net
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1473781521.git.varun@chelsio.com>
In-Reply-To: <cover.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add cxgb_mk_abort_rpl() to remove duplicate
code to form CPL_ABORT_RPL hardware command.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cm.c                  | 10 ++++------
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h | 14 ++++++++++++++
 drivers/target/iscsi/cxgbit/cxgbit_cm.c           | 11 ++---------
 3 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 484196e..a6d5fcb 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -2705,12 +2705,12 @@ static int peer_abort(struct c4iw_dev *dev, struct sk_buff *skb)
 {
 	struct cpl_abort_req_rss *req = cplhdr(skb);
 	struct c4iw_ep *ep;
-	struct cpl_abort_rpl *rpl;
 	struct sk_buff *rpl_skb;
 	struct c4iw_qp_attributes attrs;
 	int ret;
 	int release = 0;
 	unsigned int tid = GET_TID(req);
+	u32 len = roundup(sizeof(struct cpl_abort_rpl), 16);
 
 	ep = get_ep_from_tid(dev, tid);
 	if (!ep)
@@ -2809,11 +2809,9 @@ static int peer_abort(struct c4iw_dev *dev, struct sk_buff *skb)
 		release = 1;
 		goto out;
 	}
-	set_wr_txq(skb, CPL_PRIORITY_DATA, ep->txq_idx);
-	rpl = (struct cpl_abort_rpl *) skb_put(rpl_skb, sizeof(*rpl));
-	INIT_TP_WR(rpl, ep->hwtid);
-	OPCODE_TID(rpl) = cpu_to_be32(MK_OPCODE_TID(CPL_ABORT_RPL, ep->hwtid));
-	rpl->cmd = CPL_ABORT_NO_RST;
+
+	cxgb_mk_abort_rpl(rpl_skb, len, ep->hwtid, ep->txq_idx);
+
 	c4iw_ofld_send(&ep->com.dev->rdev, rpl_skb);
 out:
 	if (release)
diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
index 2d3a3bf..70999e8 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
@@ -128,4 +128,18 @@ cxgb_mk_abort_req(struct sk_buff *skb, u32 len, u32 tid, u16 chan,
 	set_wr_txq(skb, CPL_PRIORITY_DATA, chan);
 	t4_set_arp_err_handler(skb, handle, handler);
 }
+
+static inline void
+cxgb_mk_abort_rpl(struct sk_buff *skb, u32 len, u32 tid, u16 chan)
+{
+	struct cpl_abort_rpl *rpl;
+
+	rpl = (struct cpl_abort_rpl *)__skb_put(skb, len);
+	memset(rpl, 0, len);
+
+	INIT_TP_WR(rpl, tid);
+	OPCODE_TID(rpl) = cpu_to_be32(MK_OPCODE_TID(CPL_ABORT_RPL, tid));
+	rpl->cmd = CPL_ABORT_NO_RST;
+	set_wr_txq(skb, CPL_PRIORITY_DATA, chan);
+}
 #endif
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_cm.c b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
index f2b737e..9bdbe3b 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_cm.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
@@ -1642,11 +1642,10 @@ static void cxgbit_abort_req_rss(struct cxgbit_sock *csk, struct sk_buff *skb)
 {
 	struct cpl_abort_req_rss *hdr = cplhdr(skb);
 	unsigned int tid = GET_TID(hdr);
-	struct cpl_abort_rpl *rpl;
 	struct sk_buff *rpl_skb;
 	bool release = false;
 	bool wakeup_thread = false;
-	unsigned int len = roundup(sizeof(*rpl), 16);
+	u32 len = roundup(sizeof(struct cpl_abort_rpl), 16);
 
 	pr_debug("%s: csk %p; tid %u; state %d\n",
 		 __func__, csk, tid, csk->com.state);
@@ -1686,14 +1685,8 @@ static void cxgbit_abort_req_rss(struct cxgbit_sock *csk, struct sk_buff *skb)
 		cxgbit_send_tx_flowc_wr(csk);
 
 	rpl_skb = __skb_dequeue(&csk->skbq);
-	set_wr_txq(skb, CPL_PRIORITY_DATA, csk->txq_idx);
-
-	rpl = (struct cpl_abort_rpl *)__skb_put(rpl_skb, len);
-	memset(rpl, 0, len);
 
-	INIT_TP_WR(rpl, csk->tid);
-	OPCODE_TID(rpl) = cpu_to_be32(MK_OPCODE_TID(CPL_ABORT_RPL, tid));
-	rpl->cmd = CPL_ABORT_NO_RST;
+	cxgb_mk_abort_rpl(rpl_skb, len, csk->tid, csk->txq_idx);
 	cxgbit_ofld_send(csk->com.cdev, rpl_skb);
 
 	if (wakeup_thread) {
-- 
2.0.2
