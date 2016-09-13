From: Varun Prakash <varun@chelsio.com>
Subject: [net-next PATCH 09/11] libcxgb,iw_cxgb4,cxgbit: add cxgb_mk_abort_req()
Date: Tue, 13 Sep 2016 21:24:04 +0530
Message-ID: <742a53c0b23bf9d9e2f0d2c96e8359ec466ce069.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        target-devel@vger.kernel.org, nab@linux-iscsi.org,
        dledford@redhat.com, swise@opengridcomputing.com,
        gerlitz.or@gmail.com, indranil@chelsio.com, varun@chelsio.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:52197 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1759445AbcIMP5P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 11:57:15 -0400
In-Reply-To: <cover.1473781521.git.varun@chelsio.com>
In-Reply-To: <cover.1473781521.git.varun@chelsio.com>
References: <cover.1473781521.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add cxgb_mk_abort_req() to remove duplicate code
to form CPL_ABORT_REQ hardware command.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cm.c                  | 13 ++++---------
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h | 16 ++++++++++++++++
 drivers/target/iscsi/cxgbit/cxgbit_cm.c           | 13 +++----------
 3 files changed, 23 insertions(+), 19 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 22bccd8..484196e 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -652,21 +652,16 @@ static int send_halfclose(struct c4iw_ep *ep)
 
 static int send_abort(struct c4iw_ep *ep)
 {
-	struct cpl_abort_req *req;
-	int wrlen = roundup(sizeof *req, 16);
+	u32 wrlen = roundup(sizeof(struct cpl_abort_req), 16);
 	struct sk_buff *req_skb = skb_dequeue(&ep->com.ep_skb_list);
 
 	PDBG("%s ep %p tid %u\n", __func__, ep, ep->hwtid);
 	if (WARN_ON(!req_skb))
 		return -ENOMEM;
 
-	set_wr_txq(req_skb, CPL_PRIORITY_DATA, ep->txq_idx);
-	t4_set_arp_err_handler(req_skb, ep, abort_arp_failure);
-	req = (struct cpl_abort_req *)skb_put(req_skb, wrlen);
-	memset(req, 0, wrlen);
-	INIT_TP_WR(req, ep->hwtid);
-	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_ABORT_REQ, ep->hwtid));
-	req->cmd = CPL_ABORT_SEND_RST;
+	cxgb_mk_abort_req(req_skb, wrlen, ep->hwtid, ep->txq_idx,
+			  ep, abort_arp_failure);
+
 	return c4iw_l2t_send(&ep->com.dev->rdev, req_skb, ep->l2t);
 }
 
diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
index e77661d..2d3a3bf 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
@@ -112,4 +112,20 @@ cxgb_mk_close_con_req(struct sk_buff *skb, u32 len, u32 tid, u16 chan,
 	set_wr_txq(skb, CPL_PRIORITY_DATA, chan);
 	t4_set_arp_err_handler(skb, handle, handler);
 }
+
+static inline void
+cxgb_mk_abort_req(struct sk_buff *skb, u32 len, u32 tid, u16 chan,
+		  void *handle, arp_err_handler_t handler)
+{
+	struct cpl_abort_req *req;
+
+	req = (struct cpl_abort_req *)__skb_put(skb, len);
+	memset(req, 0, len);
+
+	INIT_TP_WR(req, tid);
+	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_ABORT_REQ, tid));
+	req->cmd = CPL_ABORT_SEND_RST;
+	set_wr_txq(skb, CPL_PRIORITY_DATA, chan);
+	t4_set_arp_err_handler(skb, handle, handler);
+}
 #endif
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_cm.c b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
index a8f5f36..f2b737e 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_cm.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
@@ -647,9 +647,8 @@ static void cxgbit_abort_arp_failure(void *handle, struct sk_buff *skb)
 
 static int cxgbit_send_abort_req(struct cxgbit_sock *csk)
 {
-	struct cpl_abort_req *req;
-	unsigned int len = roundup(sizeof(*req), 16);
 	struct sk_buff *skb;
+	u32 len = roundup(sizeof(struct cpl_abort_req), 16);
 
 	pr_debug("%s: csk %p tid %u; state %d\n",
 		 __func__, csk, csk->tid, csk->com.state);
@@ -660,15 +659,9 @@ static int cxgbit_send_abort_req(struct cxgbit_sock *csk)
 		cxgbit_send_tx_flowc_wr(csk);
 
 	skb = __skb_dequeue(&csk->skbq);
-	req = (struct cpl_abort_req *)__skb_put(skb, len);
-	memset(req, 0, len);
+	cxgb_mk_abort_req(skb, len, csk->tid, csk->txq_idx,
+			  csk->com.cdev, cxgbit_abort_arp_failure);
 
-	set_wr_txq(skb, CPL_PRIORITY_DATA, csk->txq_idx);
-	t4_set_arp_err_handler(skb, csk->com.cdev, cxgbit_abort_arp_failure);
-	INIT_TP_WR(req, csk->tid);
-	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_ABORT_REQ,
-						    csk->tid));
-	req->cmd = CPL_ABORT_SEND_RST;
 	return cxgbit_l2t_send(csk->com.cdev, skb, csk->l2t);
 }
 
-- 
2.0.2
