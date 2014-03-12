From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv6 net-next 22/31] iw_cxgb4: lock around accept/reject downcalls
Date: Wed, 12 Mar 2014 21:20:37 +0530
Message-ID: <1394639446-6504-23-git-send-email-hariprasad@chelsio.com>
References: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:30748 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755253AbaCLQAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 12:00:10 -0400
In-Reply-To: <1394639446-6504-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

There is a race between ULP threads doing an accept/reject, and the
ingress processing thread handling close/abort for the same connection.
The accept/reject path needs to hold the lock to serialize these paths.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cm.c | 31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 87bd3c8..9708987 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -775,7 +775,7 @@ static void send_mpa_req(struct c4iw_ep *ep, struct sk_buff *skb,
 	ep->mpa_skb = skb;
 	c4iw_l2t_send(&ep->com.dev->rdev, skb, ep->l2t);
 	start_ep_timer(ep);
-	state_set(&ep->com, MPA_REQ_SENT);
+	__state_set(&ep->com, MPA_REQ_SENT);
 	ep->mpa_attr.initiator = 1;
 	ep->snd_seq += mpalen;
 	return;
@@ -941,7 +941,7 @@ static int send_mpa_reply(struct c4iw_ep *ep, const void *pdata, u8 plen)
 	skb_get(skb);
 	t4_set_arp_err_handler(skb, NULL, arp_failure_discard);
 	ep->mpa_skb = skb;
-	state_set(&ep->com, MPA_REP_SENT);
+	__state_set(&ep->com, MPA_REP_SENT);
 	ep->snd_seq += mpalen;
 	return c4iw_l2t_send(&ep->com.dev->rdev, skb, ep->l2t);
 }
@@ -959,6 +959,7 @@ static int act_establish(struct c4iw_dev *dev, struct sk_buff *skb)
 	PDBG("%s ep %p tid %u snd_isn %u rcv_isn %u\n", __func__, ep, tid,
 	     be32_to_cpu(req->snd_isn), be32_to_cpu(req->rcv_isn));
 
+	mutex_lock(&ep->com.mutex);
 	dst_confirm(ep->dst);
 
 	/* setup the hwtid for this connection */
@@ -982,7 +983,7 @@ static int act_establish(struct c4iw_dev *dev, struct sk_buff *skb)
 		send_mpa_req(ep, skb, 1);
 	else
 		send_mpa_req(ep, skb, mpa_rev);
-
+	mutex_unlock(&ep->com.mutex);
 	return 0;
 }
 
@@ -2566,22 +2567,28 @@ static int fw4_ack(struct c4iw_dev *dev, struct sk_buff *skb)
 
 int c4iw_reject_cr(struct iw_cm_id *cm_id, const void *pdata, u8 pdata_len)
 {
-	int err;
+	int err = 0;
+	int disconnect = 0;
 	struct c4iw_ep *ep = to_ep(cm_id);
 	PDBG("%s ep %p tid %u\n", __func__, ep, ep->hwtid);
 
-	if (state_read(&ep->com) == DEAD) {
+
+	mutex_lock(&ep->com.mutex);
+	if (ep->com.state == DEAD) {
 		c4iw_put_ep(&ep->com);
 		return -ECONNRESET;
 	}
 	set_bit(ULP_REJECT, &ep->com.history);
-	BUG_ON(state_read(&ep->com) != MPA_REQ_RCVD);
+	BUG_ON(ep->com.state != MPA_REQ_RCVD);
 	if (mpa_rev == 0)
 		abort_connection(ep, NULL, GFP_KERNEL);
 	else {
 		err = send_mpa_reject(ep, pdata, pdata_len);
-		err = c4iw_ep_disconnect(ep, 0, GFP_KERNEL);
+		disconnect = 1;
 	}
+	mutex_unlock(&ep->com.mutex);
+	if (disconnect)
+		err = c4iw_ep_disconnect(ep, 0, GFP_KERNEL);
 	c4iw_put_ep(&ep->com);
 	return 0;
 }
@@ -2596,12 +2603,14 @@ int c4iw_accept_cr(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	struct c4iw_qp *qp = get_qhp(h, conn_param->qpn);
 
 	PDBG("%s ep %p tid %u\n", __func__, ep, ep->hwtid);
-	if (state_read(&ep->com) == DEAD) {
+
+	mutex_lock(&ep->com.mutex);
+	if (ep->com.state == DEAD) {
 		err = -ECONNRESET;
 		goto err;
 	}
 
-	BUG_ON(state_read(&ep->com) != MPA_REQ_RCVD);
+	BUG_ON(ep->com.state != MPA_REQ_RCVD);
 	BUG_ON(!qp);
 
 	set_bit(ULP_ACCEPT, &ep->com.history);
@@ -2670,14 +2679,16 @@ int c4iw_accept_cr(struct iw_cm_id *cm_id, struct iw_cm_conn_param *conn_param)
 	if (err)
 		goto err1;
 
-	state_set(&ep->com, FPDU_MODE);
+	__state_set(&ep->com, FPDU_MODE);
 	established_upcall(ep);
+	mutex_unlock(&ep->com.mutex);
 	c4iw_put_ep(&ep->com);
 	return 0;
 err1:
 	ep->com.cm_id = NULL;
 	cm_id->rem_ref(cm_id);
 err:
+	mutex_unlock(&ep->com.mutex);
 	c4iw_put_ep(&ep->com);
 	return err;
 }
-- 
1.8.4
