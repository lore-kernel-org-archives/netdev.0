From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv5 net-next 19/31] iw_cxgb4: connect_request_upcall fixes
Date: Mon, 10 Mar 2014 22:38:16 +0530
Message-ID: <1394471308-4304-20-git-send-email-hariprasad@chelsio.com>
References: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15078 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754364AbaCJRSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:18:03 -0400
In-Reply-To: <1394471308-4304-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>

When processing an MPA Start Request, if the listening
endpoint is DEAD, then abort the connection.

If the IWCM returns an error, then we must abort the connection and
release resources.  Also abort_connection() should not post a CLOSE
event, so clean that up too.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/cm.c | 40 ++++++++++++++++++++++++----------------
 1 file changed, 24 insertions(+), 16 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 5e9e258..c839303 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -968,13 +968,14 @@ static int act_establish(struct c4iw_dev *dev, struct sk_buff *skb)
 	return 0;
 }
 
-static void close_complete_upcall(struct c4iw_ep *ep)
+static void close_complete_upcall(struct c4iw_ep *ep, int status)
 {
 	struct iw_cm_event event;
 
 	PDBG("%s ep %p tid %u\n", __func__, ep, ep->hwtid);
 	memset(&event, 0, sizeof(event));
 	event.event = IW_CM_EVENT_CLOSE;
+	event.status = status;
 	if (ep->com.cm_id) {
 		PDBG("close complete delivered ep %p cm_id %p tid %u\n",
 		     ep, ep->com.cm_id, ep->hwtid);
@@ -988,7 +989,6 @@ static void close_complete_upcall(struct c4iw_ep *ep)
 static int abort_connection(struct c4iw_ep *ep, struct sk_buff *skb, gfp_t gfp)
 {
 	PDBG("%s ep %p tid %u\n", __func__, ep, ep->hwtid);
-	close_complete_upcall(ep);
 	state_set(&ep->com, ABORTING);
 	set_bit(ABORT_CONN, &ep->com.history);
 	return send_abort(ep, skb, gfp);
@@ -1067,9 +1067,10 @@ static void connect_reply_upcall(struct c4iw_ep *ep, int status)
 	}
 }
 
-static void connect_request_upcall(struct c4iw_ep *ep)
+static int connect_request_upcall(struct c4iw_ep *ep)
 {
 	struct iw_cm_event event;
+	int ret;
 
 	PDBG("%s ep %p tid %u\n", __func__, ep, ep->hwtid);
 	memset(&event, 0, sizeof(event));
@@ -1094,15 +1095,14 @@ static void connect_request_upcall(struct c4iw_ep *ep)
 		event.private_data_len = ep->plen;
 		event.private_data = ep->mpa_pkt + sizeof(struct mpa_message);
 	}
-	if (state_read(&ep->parent_ep->com) != DEAD) {
-		c4iw_get_ep(&ep->com);
-		ep->parent_ep->com.cm_id->event_handler(
-						ep->parent_ep->com.cm_id,
-						&event);
-	}
+	c4iw_get_ep(&ep->com);
+	ret = ep->parent_ep->com.cm_id->event_handler(ep->parent_ep->com.cm_id,
+						      &event);
+	if (ret)
+		c4iw_put_ep(&ep->com);
 	set_bit(CONNREQ_UPCALL, &ep->com.history);
 	c4iw_put_ep(&ep->parent_ep->com);
-	ep->parent_ep = NULL;
+	return ret;
 }
 
 static void established_upcall(struct c4iw_ep *ep)
@@ -1401,7 +1401,6 @@ static void process_mpa_request(struct c4iw_ep *ep, struct sk_buff *skb)
 		return;
 
 	PDBG("%s enter (%s line %u)\n", __func__, __FILE__, __LINE__);
-	stop_ep_timer(ep);
 	mpa = (struct mpa_message *) ep->mpa_pkt;
 
 	/*
@@ -1494,9 +1493,17 @@ static void process_mpa_request(struct c4iw_ep *ep, struct sk_buff *skb)
 	     ep->mpa_attr.p2p_type);
 
 	state_set(&ep->com, MPA_REQ_RCVD);
+	stop_ep_timer(ep);
 
 	/* drive upcall */
-	connect_request_upcall(ep);
+	mutex_lock(&ep->parent_ep->com.mutex);
+	if (ep->parent_ep->com.state != DEAD) {
+		if (connect_request_upcall(ep))
+			abort_connection(ep, skb, GFP_KERNEL);
+	} else {
+		abort_connection(ep, skb, GFP_KERNEL);
+	}
+	mutex_unlock(&ep->parent_ep->com.mutex);
 	return;
 }
 
@@ -2256,7 +2263,7 @@ static int peer_close(struct c4iw_dev *dev, struct sk_buff *skb)
 			c4iw_modify_qp(ep->com.qp->rhp, ep->com.qp,
 				       C4IW_QP_ATTR_NEXT_STATE, &attrs, 1);
 		}
-		close_complete_upcall(ep);
+		close_complete_upcall(ep, 0);
 		__state_set(&ep->com, DEAD);
 		release = 1;
 		disconnect = 0;
@@ -2426,7 +2433,7 @@ static int close_con_rpl(struct c4iw_dev *dev, struct sk_buff *skb)
 					     C4IW_QP_ATTR_NEXT_STATE,
 					     &attrs, 1);
 		}
-		close_complete_upcall(ep);
+		close_complete_upcall(ep, 0);
 		__state_set(&ep->com, DEAD);
 		release = 1;
 		break;
@@ -2981,7 +2988,7 @@ int c4iw_ep_disconnect(struct c4iw_ep *ep, int abrupt, gfp_t gfp)
 	rdev = &ep->com.dev->rdev;
 	if (c4iw_fatal_error(rdev)) {
 		fatal = 1;
-		close_complete_upcall(ep);
+		close_complete_upcall(ep, -EIO);
 		ep->com.state = DEAD;
 	}
 	switch (ep->com.state) {
@@ -3023,7 +3030,7 @@ int c4iw_ep_disconnect(struct c4iw_ep *ep, int abrupt, gfp_t gfp)
 	if (close) {
 		if (abrupt) {
 			set_bit(EP_DISC_ABORT, &ep->com.history);
-			close_complete_upcall(ep);
+			close_complete_upcall(ep, -ECONNRESET);
 			ret = send_abort(ep, NULL, gfp);
 		} else {
 			set_bit(EP_DISC_CLOSE, &ep->com.history);
@@ -3436,6 +3443,7 @@ static void process_timeout(struct c4iw_ep *ep)
 				     &attrs, 1);
 		}
 		__state_set(&ep->com, ABORTING);
+		close_complete_upcall(ep, -ETIMEDOUT);
 		break;
 	default:
 		WARN(1, "%s unexpected state ep %p tid %u state %u\n",
-- 
1.8.4
