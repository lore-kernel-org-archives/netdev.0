From: divy@chelsio.com
Subject: [PATCH 2.6.21 1/2] cxgb3 - Fix low memory conditions
Date: Tue, 17 Apr 2007 11:06:30 -0700
Message-ID: <20070417180630.17050.15974.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:14622 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161292AbXDQSGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 14:06:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Reuse the incoming skb when a clientless abort req is recieved.

The release of RDMA connections HW resources might be deferred in
low memory situations. 
Ensure that no further activity is passed up to the RDMA driver
for these connections.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_defs.h    |    5 ++-
 drivers/net/cxgb3/cxgb3_offload.c |   69 +++++++++++++++++++++++++++----------
 2 files changed, 55 insertions(+), 19 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_defs.h b/drivers/net/cxgb3/cxgb3_defs.h
index e14862b..483a594 100644
--- a/drivers/net/cxgb3/cxgb3_defs.h
+++ b/drivers/net/cxgb3/cxgb3_defs.h
@@ -67,7 +67,10 @@ static inline union listen_entry *stid2e
 static inline struct t3c_tid_entry *lookup_tid(const struct tid_info *t,
 					       unsigned int tid)
 {
-	return tid < t->ntids ? &(t->tid_tab[tid]) : NULL;
+	struct t3c_tid_entry *t3c_tid = tid < t->ntids ?
+	    &(t->tid_tab[tid]) : NULL;
+
+	return (t3c_tid && t3c_tid->client) ? t3c_tid : NULL;
 }
 
 /*
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index 4864924..199e506 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -508,6 +508,7 @@ void cxgb3_queue_tid_release(struct t3cd
 
 	spin_lock_bh(&td->tid_release_lock);
 	p->ctx = (void *)td->tid_release_list;
+	p->client = NULL;
 	td->tid_release_list = p;
 	if (!p->ctx)
 		schedule_work(&td->tid_release_task);
@@ -623,7 +624,8 @@ static int do_act_open_rpl(struct t3cdev
 	struct t3c_tid_entry *t3c_tid;
 
 	t3c_tid = lookup_atid(&(T3C_DATA(dev))->tid_maps, atid);
-	if (t3c_tid->ctx && t3c_tid->client && t3c_tid->client->handlers &&
+	if (t3c_tid && t3c_tid->ctx && t3c_tid->client &&
+	    t3c_tid->client->handlers &&
 	    t3c_tid->client->handlers[CPL_ACT_OPEN_RPL]) {
 		return t3c_tid->client->handlers[CPL_ACT_OPEN_RPL] (dev, skb,
 								    t3c_tid->
@@ -642,7 +644,7 @@ static int do_stid_rpl(struct t3cdev *de
 	struct t3c_tid_entry *t3c_tid;
 
 	t3c_tid = lookup_stid(&(T3C_DATA(dev))->tid_maps, stid);
-	if (t3c_tid->ctx && t3c_tid->client->handlers &&
+	if (t3c_tid && t3c_tid->ctx && t3c_tid->client->handlers &&
 	    t3c_tid->client->handlers[p->opcode]) {
 		return t3c_tid->client->handlers[p->opcode] (dev, skb,
 							     t3c_tid->ctx);
@@ -660,7 +662,7 @@ static int do_hwtid_rpl(struct t3cdev *d
 	struct t3c_tid_entry *t3c_tid;
 
 	t3c_tid = lookup_tid(&(T3C_DATA(dev))->tid_maps, hwtid);
-	if (t3c_tid->ctx && t3c_tid->client->handlers &&
+	if (t3c_tid && t3c_tid->ctx && t3c_tid->client->handlers &&
 	    t3c_tid->client->handlers[p->opcode]) {
 		return t3c_tid->client->handlers[p->opcode]
 		    (dev, skb, t3c_tid->ctx);
@@ -689,6 +691,28 @@ static int do_cr(struct t3cdev *dev, str
 	}
 }
 
+/*
+ * Returns an sk_buff for a reply CPL message of size len.  If the input
+ * sk_buff has no other users it is trimmed and reused, otherwise a new buffer
+ * is allocated.  The input skb must be of size at least len.  Note that this
+ * operation does not destroy the original skb data even if it decides to reuse
+ * the buffer.
+ */
+static struct sk_buff *cxgb3_get_cpl_reply_skb(struct sk_buff *skb, size_t len,
+					       int gfp)
+{
+	if (likely(!skb_cloned(skb))) {
+		BUG_ON(skb->len < len);
+		__skb_trim(skb, len);
+		skb_get(skb);
+	} else {
+		skb = alloc_skb(len, gfp);
+		if (skb)
+			__skb_put(skb, len);
+	}
+	return skb;
+}
+
 static int do_abort_req_rss(struct t3cdev *dev, struct sk_buff *skb)
 {
 	union opcode_tid *p = cplhdr(skb);
@@ -696,30 +720,39 @@ static int do_abort_req_rss(struct t3cde
 	struct t3c_tid_entry *t3c_tid;
 
 	t3c_tid = lookup_tid(&(T3C_DATA(dev))->tid_maps, hwtid);
-	if (t3c_tid->ctx && t3c_tid->client->handlers &&
+	if (t3c_tid && t3c_tid->ctx && t3c_tid->client->handlers &&
 	    t3c_tid->client->handlers[p->opcode]) {
 		return t3c_tid->client->handlers[p->opcode]
 		    (dev, skb, t3c_tid->ctx);
 	} else {
 		struct cpl_abort_req_rss *req = cplhdr(skb);
 		struct cpl_abort_rpl *rpl;
+		struct sk_buff *reply_skb;
+		unsigned int tid = GET_TID(req);
+		u8 cmd = req->status;
+
+		if (req->status == CPL_ERR_RTX_NEG_ADVICE ||
+		    req->status == CPL_ERR_PERSIST_NEG_ADVICE)
+			goto out;
 
-		struct sk_buff *skb =
-		    alloc_skb(sizeof(struct cpl_abort_rpl), GFP_ATOMIC);
-		if (!skb) {
+		reply_skb = cxgb3_get_cpl_reply_skb(skb,
+						    sizeof(struct
+							   cpl_abort_rpl),
+						    GFP_ATOMIC);
+
+		if (!reply_skb) {
 			printk("do_abort_req_rss: couldn't get skb!\n");
 			goto out;
 		}
-		skb->priority = CPL_PRIORITY_DATA;
-		__skb_put(skb, sizeof(struct cpl_abort_rpl));
-		rpl = cplhdr(skb);
+		reply_skb->priority = CPL_PRIORITY_DATA;
+		__skb_put(reply_skb, sizeof(struct cpl_abort_rpl));
+		rpl = cplhdr(reply_skb);
 		rpl->wr.wr_hi =
 		    htonl(V_WR_OP(FW_WROPCODE_OFLD_HOST_ABORT_CON_RPL));
-		rpl->wr.wr_lo = htonl(V_WR_TID(GET_TID(req)));
-		OPCODE_TID(rpl) =
-		    htonl(MK_OPCODE_TID(CPL_ABORT_RPL, GET_TID(req)));
-		rpl->cmd = req->status;
-		cxgb3_ofld_send(dev, skb);
+		rpl->wr.wr_lo = htonl(V_WR_TID(tid));
+		OPCODE_TID(rpl) = htonl(MK_OPCODE_TID(CPL_ABORT_RPL, tid));
+		rpl->cmd = cmd;
+		cxgb3_ofld_send(dev, reply_skb);
 out:
 		return CPL_RET_BUF_DONE;
 	}
@@ -732,7 +765,7 @@ static int do_act_establish(struct t3cde
 	struct t3c_tid_entry *t3c_tid;
 
 	t3c_tid = lookup_atid(&(T3C_DATA(dev))->tid_maps, atid);
-	if (t3c_tid->ctx && t3c_tid->client->handlers &&
+	if (t3c_tid && t3c_tid->ctx && t3c_tid->client->handlers &&
 	    t3c_tid->client->handlers[CPL_ACT_ESTABLISH]) {
 		return t3c_tid->client->handlers[CPL_ACT_ESTABLISH]
 		    (dev, skb, t3c_tid->ctx);
@@ -762,7 +795,7 @@ static int do_term(struct t3cdev *dev, s
 	struct t3c_tid_entry *t3c_tid;
 
 	t3c_tid = lookup_tid(&(T3C_DATA(dev))->tid_maps, hwtid);
-	if (t3c_tid->ctx && t3c_tid->client->handlers &&
+	if (t3c_tid && t3c_tid->ctx && t3c_tid->client->handlers &&
 	    t3c_tid->client->handlers[opcode]) {
 		return t3c_tid->client->handlers[opcode] (dev, skb,
 							  t3c_tid->ctx);
@@ -961,7 +994,7 @@ void cxgb_redirect(struct dst_entry *old
 	for (tid = 0; tid < ti->ntids; tid++) {
 		te = lookup_tid(ti, tid);
 		BUG_ON(!te);
-		if (te->ctx && te->client && te->client->redirect) {
+		if (te && te->ctx && te->client && te->client->redirect) {
 			update_tcb = te->client->redirect(te->ctx, old, new, e);
 			if (update_tcb) {
 				l2t_hold(L2DATA(tdev), e);
