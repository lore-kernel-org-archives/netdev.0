From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] SCTP: Flush fragment queue when exiting partial delivery
Date: Sun, 16 Dec 2007 02:08:36 -0500
Message-ID: <1197788916-2969-1-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:17553 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbXLPHIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 02:08:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the end of partial delivery, we may have complete messages
sitting on the fragment queue.  These messages are stuck there
until a new fragment arrives.  This can comletely stall a
given association.  When clearing partial delivery state, flush
any complete messages from the fragment queue and send them on
their way up.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/ulpqueue.c |   33 +++++++++++++++++++++++++++++++++
 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 4908041..1733fa2 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -53,6 +53,7 @@ static struct sctp_ulpevent * sctp_ulpq_reasm(struct sctp_ulpq *ulpq,
 					      struct sctp_ulpevent *);
 static struct sctp_ulpevent * sctp_ulpq_order(struct sctp_ulpq *,
 					      struct sctp_ulpevent *);
+static void sctp_ulpq_reasm_drain(struct sctp_ulpq *ulpq);
 
 /* 1st Level Abstractions */
 
@@ -190,6 +191,7 @@ static void sctp_ulpq_set_pd(struct sctp_ulpq *ulpq)
 static int sctp_ulpq_clear_pd(struct sctp_ulpq *ulpq)
 {
 	ulpq->pd_mode = 0;
+	sctp_ulpq_reasm_drain(ulpq);
 	return sctp_clear_pd(ulpq->asoc->base.sk, ulpq->asoc);
 }
 
@@ -699,6 +701,37 @@ void sctp_ulpq_reasm_flushtsn(struct sctp_ulpq *ulpq, __u32 fwd_tsn)
 	}
 }
 
+/*
+ * Drain the reassembly queue.  If we just cleared parted delivery, it
+ * is possible that the reassembly queue will contain already reassembled
+ * messages.  Retrieve any such messages and give them to the user.
+ */
+static void sctp_ulpq_reasm_drain(struct sctp_ulpq *ulpq)
+{
+	struct sctp_ulpevent *event = NULL;
+	struct sk_buff_head temp;
+
+	if (skb_queue_empty(&ulpq->reasm))
+		return;
+
+	while ((event = sctp_ulpq_retrieve_reassembled(ulpq)) != NULL) {
+		/* Do ordering if needed.  */
+		if ((event) && (event->msg_flags & MSG_EOR)){
+			skb_queue_head_init(&temp);
+			__skb_queue_tail(&temp, sctp_event2skb(event));
+
+			event = sctp_ulpq_order(ulpq, event);
+		}
+
+		/* Send event to the ULP.  'event' is the
+		 * sctp_ulpevent for  very first SKB on the  temp' list.
+		 */
+		if (event)
+			sctp_ulpq_tail_event(ulpq, event);
+	}
+}
+
+
 /* Helper function to gather skbs that have possibly become
  * ordered by an an incoming chunk.
  */
-- 
1.5.3.5

