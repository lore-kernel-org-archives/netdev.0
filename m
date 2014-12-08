From: kxie@chelsio.com
Subject: [PATCH net v2 3/5] cxgb4i: handle non-pdu-aligned rx and
 additional types of negative advice
Date: Mon, 08 Dec 2014 01:58:14 -0800
Message-ID: <201412080958.sB89wEsj005499@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kxie@chelsio.com, hariprasad@chelsio.com, anish@chelsio.com,
	hch@infradead.org, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu, davem@davemloft.net
To: linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:29056 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753221AbaLHJ7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 04:59:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH net v2 3/5] cxgb4i: handle non-pdu-aligned rx data and additional types of negative advice

From: Karen Xie <kxie@chelsio.com>

- abort the connection upon receiving of cpl_rx_data, which means the pdu cannot be recovered from the tcp stream. This could be due to pdu header corruption.
- handle additional types of negative advice returned by h/w.

Signed-off-by: Karen Xie <kxie@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |   34 +++++++++++++++++++++++++++++++---
 1 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index b834bde..051adab 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -845,6 +845,13 @@ static void csk_act_open_retry_timer(unsigned long data)
 
 }
 
+static inline int is_neg_adv(unsigned int status)
+{
+	return status == CPL_ERR_RTX_NEG_ADVICE ||
+		status == CPL_ERR_KEEPALV_NEG_ADVICE ||
+		status == CPL_ERR_PERSIST_NEG_ADVICE;
+}
+
 static void do_act_open_rpl(struct cxgbi_device *cdev, struct sk_buff *skb)
 {
 	struct cxgbi_sock *csk;
@@ -866,7 +873,7 @@ static void do_act_open_rpl(struct cxgbi_device *cdev, struct sk_buff *skb)
 		       "csk 0x%p,%u,0x%lx. ", (&csk->saddr), (&csk->daddr),
 		       atid, tid, status, csk, csk->state, csk->flags);
 
-	if (status == CPL_ERR_RTX_NEG_ADVICE)
+	if (is_neg_adv(status))
 		goto rel_skb;
 
 	module_put(THIS_MODULE);
@@ -972,8 +979,7 @@ static void do_abort_req_rss(struct cxgbi_device *cdev, struct sk_buff *skb)
 		       (&csk->saddr), (&csk->daddr),
 		       csk, csk->state, csk->flags, csk->tid, req->status);
 
-	if (req->status == CPL_ERR_RTX_NEG_ADVICE ||
-	    req->status == CPL_ERR_PERSIST_NEG_ADVICE)
+	if (is_neg_adv(req->status))
 		goto rel_skb;
 
 	cxgbi_sock_get(csk);
@@ -1027,6 +1033,27 @@ rel_skb:
 	__kfree_skb(skb);
 }
 
+static void do_rx_data(struct cxgbi_device *cdev, struct sk_buff *skb)
+{
+	struct cxgbi_sock *csk;
+	struct cpl_rx_data *cpl = (struct cpl_rx_data *)skb->data;
+	unsigned int tid = GET_TID(cpl);
+	struct cxgb4_lld_info *lldi = cxgbi_cdev_priv(cdev);
+	struct tid_info *t = lldi->tids;
+
+	csk = lookup_tid(t, tid);
+	if (!csk) {
+		pr_err("can't find connection for tid %u.\n", tid);
+	} else {
+		/* not expecting this, reset the connection. */
+		pr_err("csk 0x%p, tid %u, rcv cpl_rx_data.\n", csk, tid);
+		spin_lock_bh(&csk->lock);
+		send_abort_req(csk);
+		spin_unlock_bh(&csk->lock);
+	}
+	__kfree_skb(skb);
+}
+
 static void do_rx_iscsi_hdr(struct cxgbi_device *cdev, struct sk_buff *skb)
 {
 	struct cxgbi_sock *csk;
@@ -1446,6 +1473,7 @@ cxgb4i_cplhandler_func cxgb4i_cplhandlers[NUM_CPL_CMDS] = {
 	[CPL_SET_TCB_RPL] = do_set_tcb_rpl,
 	[CPL_RX_DATA_DDP] = do_rx_data_ddp,
 	[CPL_RX_ISCSI_DDP] = do_rx_data_ddp,
+	[CPL_RX_DATA] = do_rx_data,
 };
 
 int cxgb4i_ofld_init(struct cxgbi_device *cdev)
