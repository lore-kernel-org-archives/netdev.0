From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv5 net-next 24/31] iw_cxgb4: rx_data() needs to hold the ep mutex
Date: Mon, 10 Mar 2014 22:38:21 +0530
Message-ID: <1394471308-4304-25-git-send-email-hariprasad@chelsio.com>
References: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25975 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754079AbaCJRSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:18:22 -0400
In-Reply-To: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

To avoid racing with other threads doing close/flush/whatever, rx_data()
should hold the endpoint mutex.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cm.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index e7c6dfd..31e725e 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1193,7 +1193,7 @@ static void process_mpa_reply(struct c4iw_ep *ep, struct sk_buff *skb)
 	 * the connection.
 	 */
 	stop_ep_timer(ep);
-	if (state_read(&ep->com) != MPA_REQ_SENT)
+	if (ep->com.state != MPA_REQ_SENT)
 		return;
 
 	/*
@@ -1268,7 +1268,7 @@ static void process_mpa_reply(struct c4iw_ep *ep, struct sk_buff *skb)
 	 * start reply message including private data. And
 	 * the MPA header is valid.
 	 */
-	state_set(&ep->com, FPDU_MODE);
+	__state_set(&ep->com, FPDU_MODE);
 	ep->mpa_attr.crc_enabled = (mpa->flags & MPA_CRC) | crc_enabled ? 1 : 0;
 	ep->mpa_attr.recv_marker_enabled = markers_enabled;
 	ep->mpa_attr.xmit_marker_enabled = mpa->flags & MPA_MARKERS ? 1 : 0;
@@ -1383,7 +1383,7 @@ static void process_mpa_reply(struct c4iw_ep *ep, struct sk_buff *skb)
 	}
 	goto out;
 err:
-	state_set(&ep->com, ABORTING);
+	__state_set(&ep->com, ABORTING);
 	send_abort(ep, skb, GFP_KERNEL);
 out:
 	connect_reply_upcall(ep, err);
@@ -1398,7 +1398,7 @@ static void process_mpa_request(struct c4iw_ep *ep, struct sk_buff *skb)
 
 	PDBG("%s ep %p tid %u\n", __func__, ep, ep->hwtid);
 
-	if (state_read(&ep->com) != MPA_REQ_WAIT)
+	if (ep->com.state != MPA_REQ_WAIT)
 		return;
 
 	/*
@@ -1519,7 +1519,7 @@ static void process_mpa_request(struct c4iw_ep *ep, struct sk_buff *skb)
 	     ep->mpa_attr.xmit_marker_enabled, ep->mpa_attr.version,
 	     ep->mpa_attr.p2p_type);
 
-	state_set(&ep->com, MPA_REQ_RCVD);
+	__state_set(&ep->com, MPA_REQ_RCVD);
 	stop_ep_timer(ep);
 
 	/* drive upcall */
@@ -1549,11 +1549,12 @@ static int rx_data(struct c4iw_dev *dev, struct sk_buff *skb)
 	PDBG("%s ep %p tid %u dlen %u\n", __func__, ep, ep->hwtid, dlen);
 	skb_pull(skb, sizeof(*hdr));
 	skb_trim(skb, dlen);
+	mutex_lock(&ep->com.mutex);
 
 	/* update RX credits */
 	update_rx_credits(ep, dlen);
 
-	switch (state_read(&ep->com)) {
+	switch (ep->com.state) {
 	case MPA_REQ_SENT:
 		ep->rcv_seq += dlen;
 		process_mpa_reply(ep, skb);
@@ -1569,7 +1570,7 @@ static int rx_data(struct c4iw_dev *dev, struct sk_buff *skb)
 			pr_err("%s Unexpected streaming data." \
 			       " qpid %u ep %p state %d tid %u status %d\n",
 			       __func__, ep->com.qp->wq.sq.qid, ep,
-			       state_read(&ep->com), ep->hwtid, status);
+			       ep->com.state, ep->hwtid, status);
 		attrs.next_state = C4IW_QP_STATE_TERMINATE;
 		c4iw_modify_qp(ep->com.qp->rhp, ep->com.qp,
 			       C4IW_QP_ATTR_NEXT_STATE, &attrs, 0);
@@ -1578,6 +1579,7 @@ static int rx_data(struct c4iw_dev *dev, struct sk_buff *skb)
 	default:
 		break;
 	}
+	mutex_unlock(&ep->com.mutex);
 	return 0;
 }
 
-- 
1.8.4
