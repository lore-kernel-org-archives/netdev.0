From: Varun Prakash <varun@chelsio.com>
Subject: [net-next PATCH 08/11] libcxgb,iw_cxgb4,cxgbit: add cxgb_mk_close_con_req()
Date: Tue, 13 Sep 2016 21:24:03 +0530
Message-ID: <bab96a7ca90a0aa17f0698f5c248de3209f62a8f.1473781521.git.varun@chelsio.com>
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

Add cxgb_mk_close_con_req() to remove duplicate
code to form CPL_CLOSE_CON_REQ hardware command.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cm.c                  | 13 ++++---------
 drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h | 16 ++++++++++++++++
 drivers/target/iscsi/cxgbit/cxgbit_cm.c           | 13 +++----------
 3 files changed, 23 insertions(+), 19 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index b818bd6..22bccd8 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -637,21 +637,16 @@ static int send_flowc(struct c4iw_ep *ep)
 
 static int send_halfclose(struct c4iw_ep *ep)
 {
-	struct cpl_close_con_req *req;
 	struct sk_buff *skb = skb_dequeue(&ep->com.ep_skb_list);
-	int wrlen = roundup(sizeof *req, 16);
+	u32 wrlen = roundup(sizeof(struct cpl_close_con_req), 16);
 
 	PDBG("%s ep %p tid %u\n", __func__, ep, ep->hwtid);
 	if (WARN_ON(!skb))
 		return -ENOMEM;
 
-	set_wr_txq(skb, CPL_PRIORITY_DATA, ep->txq_idx);
-	t4_set_arp_err_handler(skb, NULL, arp_failure_discard);
-	req = (struct cpl_close_con_req *) skb_put(skb, wrlen);
-	memset(req, 0, wrlen);
-	INIT_TP_WR(req, ep->hwtid);
-	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_CLOSE_CON_REQ,
-						    ep->hwtid));
+	cxgb_mk_close_con_req(skb, wrlen, ep->hwtid, ep->txq_idx,
+			      NULL, arp_failure_discard);
+
 	return c4iw_l2t_send(&ep->com.dev->rdev, skb, ep->l2t);
 }
 
diff --git a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
index fbb973e..e77661d 100644
--- a/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
+++ b/drivers/net/ethernet/chelsio/libcxgb/libcxgb_cm.h
@@ -38,6 +38,7 @@
 
 #include <cxgb4.h>
 #include <t4_msg.h>
+#include <l2t.h>
 
 void
 cxgb_get_4tuple(struct cpl_pass_accept_req *, enum chip_type,
@@ -96,4 +97,19 @@ cxgb_mk_tid_release(struct sk_buff *skb, u32 len, u32 tid, u16 chan)
 	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_TID_RELEASE, tid));
 	set_wr_txq(skb, CPL_PRIORITY_SETUP, chan);
 }
+
+static inline void
+cxgb_mk_close_con_req(struct sk_buff *skb, u32 len, u32 tid, u16 chan,
+		      void *handle, arp_err_handler_t handler)
+{
+	struct cpl_close_con_req *req;
+
+	req = (struct cpl_close_con_req *)__skb_put(skb, len);
+	memset(req, 0, len);
+
+	INIT_TP_WR(req, tid);
+	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_CLOSE_CON_REQ, tid));
+	set_wr_txq(skb, CPL_PRIORITY_DATA, chan);
+	t4_set_arp_err_handler(skb, handle, handler);
+}
 #endif
diff --git a/drivers/target/iscsi/cxgbit/cxgbit_cm.c b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
index 994058f..a8f5f36 100644
--- a/drivers/target/iscsi/cxgbit/cxgbit_cm.c
+++ b/drivers/target/iscsi/cxgbit/cxgbit_cm.c
@@ -615,21 +615,14 @@ void cxgbit_free_np(struct iscsi_np *np)
 static void cxgbit_send_halfclose(struct cxgbit_sock *csk)
 {
 	struct sk_buff *skb;
-	struct cpl_close_con_req *req;
-	unsigned int len = roundup(sizeof(struct cpl_close_con_req), 16);
+	u32 len = roundup(sizeof(struct cpl_close_con_req), 16);
 
 	skb = alloc_skb(len, GFP_ATOMIC);
 	if (!skb)
 		return;
 
-	req = (struct cpl_close_con_req *)__skb_put(skb, len);
-	memset(req, 0, len);
-
-	set_wr_txq(skb, CPL_PRIORITY_DATA, csk->txq_idx);
-	INIT_TP_WR(req, csk->tid);
-	OPCODE_TID(req) = cpu_to_be32(MK_OPCODE_TID(CPL_CLOSE_CON_REQ,
-						    csk->tid));
-	req->rsvd = 0;
+	cxgb_mk_close_con_req(skb, len, csk->tid, csk->txq_idx,
+			      NULL, NULL);
 
 	cxgbit_skcb_flags(skb) |= SKCBF_TX_FLAG_COMPL;
 	__skb_queue_tail(&csk->txq, skb);
-- 
2.0.2
