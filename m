From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCHv2 net-next 24/31] iw_cxgb4: rx_data() needs to hold the ep mutex.
Date: Mon,  3 Mar 2014 12:11:08 +0530
Message-ID: <1393828875-13452-25-git-send-email-hariprasad@chelsio.com>
References: <1393828875-13452-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1393828875-13452-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>

To avoid racing with other threads doing close/flush/whatever, rx_data()
should hold the endpoint mutex.

Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/cm.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 2930e91..f30ed32 100644
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
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
