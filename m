From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH] sctp: signal sk_data_ready earlier on data chunks reception
Date: Fri, 29 Apr 2016 14:17:08 -0300
Message-ID: <271eaec3c8fad125a48b5acce192dd1080c26528.1461949899.git.marcelo.leitner@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38903 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751980AbcD2RRT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Apr 2016 13:17:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Miller pointed out that fb586f25300f ("sctp: delay calls to
sk_data_ready() as much as possible") may insert latency specially if
the receiving application is running on another CPU and that it would be
better if we signalled as early as possible.

This patch thus basically inverts the logic on fb586f25300f and signals
it as early as possible, similar to what we had before.

Fixes: fb586f25300f ("sctp: delay calls to sk_data_ready() as much as possible")
Reported-by: Dave Miller <davem@davemloft.net>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/sctp/structs.h |  2 +-
 net/sctp/sm_sideeffect.c   |  7 +++----
 net/sctp/ulpqueue.c        | 25 ++++++++++++++++---------
 3 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 558bae3cbe0d5107d52c8cb31b324cfd5479def0..16b013a6191cf1c416e4dd1aeb1707a8569ea49b 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -218,7 +218,7 @@ struct sctp_sock {
 		frag_interleave:1,
 		recvrcvinfo:1,
 		recvnxtinfo:1,
-		pending_data_ready:1;
+		data_ready_signalled:1;
 
 	atomic_t pd_mode;
 	/* Receive to here while partial delivery is in effect. */
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index e8f0112f9b28472c39c4c91dcb28576373c858e7..aa37122593684d8501fdca15983fbd8620fabe07 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1741,10 +1741,9 @@ out:
 	} else if (local_cork)
 		error = sctp_outq_uncork(&asoc->outqueue, gfp);
 
-	if (sp->pending_data_ready) {
-		sk->sk_data_ready(sk);
-		sp->pending_data_ready = 0;
-	}
+	if (sp->data_ready_signalled)
+		sp->data_ready_signalled = 0;
+
 	return error;
 nomem:
 	error = -ENOMEM;
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index ec12a8920e5fd7a0f26d19f1695bc2feeae41518..ec166d2bd2d95d9aa69369da2ead9437da4ce8ed 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -194,6 +194,7 @@ static int sctp_ulpq_clear_pd(struct sctp_ulpq *ulpq)
 int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 {
 	struct sock *sk = ulpq->asoc->base.sk;
+	struct sctp_sock *sp = sctp_sk(sk);
 	struct sk_buff_head *queue, *skb_list;
 	struct sk_buff *skb = sctp_event2skb(event);
 	int clear_pd = 0;
@@ -211,7 +212,7 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 		sk_incoming_cpu_update(sk);
 	}
 	/* Check if the user wishes to receive this event.  */
-	if (!sctp_ulpevent_is_enabled(event, &sctp_sk(sk)->subscribe))
+	if (!sctp_ulpevent_is_enabled(event, &sp->subscribe))
 		goto out_free;
 
 	/* If we are in partial delivery mode, post to the lobby until
@@ -219,7 +220,7 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 	 * the association the cause of the partial delivery.
 	 */
 
-	if (atomic_read(&sctp_sk(sk)->pd_mode) == 0) {
+	if (atomic_read(&sp->pd_mode) == 0) {
 		queue = &sk->sk_receive_queue;
 	} else {
 		if (ulpq->pd_mode) {
@@ -231,7 +232,7 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 			if ((event->msg_flags & MSG_NOTIFICATION) ||
 			    (SCTP_DATA_NOT_FRAG ==
 				    (event->msg_flags & SCTP_DATA_FRAG_MASK)))
-				queue = &sctp_sk(sk)->pd_lobby;
+				queue = &sp->pd_lobby;
 			else {
 				clear_pd = event->msg_flags & MSG_EOR;
 				queue = &sk->sk_receive_queue;
@@ -242,10 +243,10 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 			 * can queue this to the receive queue instead
 			 * of the lobby.
 			 */
-			if (sctp_sk(sk)->frag_interleave)
+			if (sp->frag_interleave)
 				queue = &sk->sk_receive_queue;
 			else
-				queue = &sctp_sk(sk)->pd_lobby;
+				queue = &sp->pd_lobby;
 		}
 	}
 
@@ -264,8 +265,10 @@ int sctp_ulpq_tail_event(struct sctp_ulpq *ulpq, struct sctp_ulpevent *event)
 	if (clear_pd)
 		sctp_ulpq_clear_pd(ulpq);
 
-	if (queue == &sk->sk_receive_queue)
-		sctp_sk(sk)->pending_data_ready = 1;
+	if (queue == &sk->sk_receive_queue && !sp->data_ready_signalled) {
+		sp->data_ready_signalled = 1;
+		sk->sk_data_ready(sk);
+	}
 	return 1;
 
 out_free:
@@ -1126,11 +1129,13 @@ void sctp_ulpq_abort_pd(struct sctp_ulpq *ulpq, gfp_t gfp)
 {
 	struct sctp_ulpevent *ev = NULL;
 	struct sock *sk;
+	struct sctp_sock *sp;
 
 	if (!ulpq->pd_mode)
 		return;
 
 	sk = ulpq->asoc->base.sk;
+	sp = sctp_sk(sk);
 	if (sctp_ulpevent_type_enabled(SCTP_PARTIAL_DELIVERY_EVENT,
 				       &sctp_sk(sk)->subscribe))
 		ev = sctp_ulpevent_make_pdapi(ulpq->asoc,
@@ -1140,6 +1145,8 @@ void sctp_ulpq_abort_pd(struct sctp_ulpq *ulpq, gfp_t gfp)
 		__skb_queue_tail(&sk->sk_receive_queue, sctp_event2skb(ev));
 
 	/* If there is data waiting, send it up the socket now. */
-	if (sctp_ulpq_clear_pd(ulpq) || ev)
-		sctp_sk(sk)->pending_data_ready = 1;
+	if ((sctp_ulpq_clear_pd(ulpq) || ev) && !sp->data_ready_signalled) {
+		sp->data_ready_signalled = 1;
+		sk->sk_data_ready(sk);
+	}
 }
-- 
2.5.0
