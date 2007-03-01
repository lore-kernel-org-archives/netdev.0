From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 2.6.21 1/6] iw_cxgb3: Fixes for "normal close" failures.
Date: Thu, 01 Mar 2007 16:50:38 -0600
Message-ID: <20070301225038.2373.13980.stgit@dell3.ogc.int>
References: <20070301225036.2373.71668.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:32818 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161084AbXCAWuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 17:50:39 -0500
In-Reply-To: <20070301225036.2373.71668.stgit@dell3.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fixes for "normal close" failures.

- Start normal close timer when moving to CLOSING state.
- Handle ABORTING state in close_con_rpl().
- Stop timer correctly on abort during a normal close.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_cm.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index b21fde8..1dcfedc 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -1415,6 +1415,7 @@ static int peer_close(struct t3cdev *tde
 		wake_up(&ep->com.waitq);
 		break;
 	case FPDU_MODE:
+		start_ep_timer(ep);
 		__state_set(&ep->com, CLOSING);
 		attrs.next_state = IWCH_QP_STATE_CLOSING;
 		iwch_modify_qp(ep->com.qp->rhp, ep->com.qp,
@@ -1425,7 +1426,6 @@ static int peer_close(struct t3cdev *tde
 		disconnect = 0;
 		break;
 	case CLOSING:
-		start_ep_timer(ep);
 		__state_set(&ep->com, MORIBUND);
 		disconnect = 0;
 		break;
@@ -1507,9 +1507,10 @@ static int peer_abort(struct t3cdev *tde
 		get_ep(&ep->com);
 		break;
 	case MORIBUND:
+	case CLOSING:
 		stop_ep_timer(ep);
+		/*FALLTHROUGH*/
 	case FPDU_MODE:
-	case CLOSING:
 		if (ep->com.cm_id && ep->com.qp) {
 			attrs.next_state = IWCH_QP_STATE_ERROR;
 			ret = iwch_modify_qp(ep->com.qp->rhp,
@@ -1570,7 +1571,6 @@ static int close_con_rpl(struct t3cdev *
 	spin_lock_irqsave(&ep->com.lock, flags);
 	switch (ep->com.state) {
 	case CLOSING:
-		start_ep_timer(ep);
 		__state_set(&ep->com, MORIBUND);
 		break;
 	case MORIBUND:
@@ -1586,6 +1586,8 @@ static int close_con_rpl(struct t3cdev *
 		__state_set(&ep->com, DEAD);
 		release = 1;
 		break;
+	case ABORTING:
+		break;
 	case DEAD:
 	default:
 		BUG_ON(1);
@@ -1659,6 +1661,7 @@ static void ep_timeout(unsigned long arg
 		break;
 	case MPA_REQ_WAIT:
 		break;
+	case CLOSING:
 	case MORIBUND:
 		if (ep->com.cm_id && ep->com.qp) {
 			attrs.next_state = IWCH_QP_STATE_ERROR;
@@ -1957,11 +1960,11 @@ int iwch_ep_disconnect(struct iwch_ep *e
 	case MPA_REQ_RCVD:
 	case MPA_REP_SENT:
 	case FPDU_MODE:
+		start_ep_timer(ep);
 		ep->com.state = CLOSING;
 		close = 1;
 		break;
 	case CLOSING:
-		start_ep_timer(ep);
 		ep->com.state = MORIBUND;
 		close = 1;
 		break;
