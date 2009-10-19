From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] tcp: reduce SYN-ACK retrans for TCP_DEFER_ACCEPT
Date: Mon, 19 Oct 2009 23:03:58 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0910192302000.2971@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:59735 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751103AbZJSUCZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2009 16:02:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Change SYN-ACK retransmitting code for the TCP_DEFER_ACCEPT
users to not retransmit SYN-ACKs during the deferring period if
ACK from client was received. The goal is to reduce traffic
during the deferring period. When the period is finished
we continue with sending SYN-ACKs (at least one) but this time
any traffic from client will change the request to established
socket allowing application to terminate it properly.
Also, do not drop acked request if sending of SYN-ACK fails.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp v2.6.31/linux/net/ipv4/inet_connection_sock.c linux/net/ipv4/inet_connection_sock.c
--- v2.6.31/linux/net/ipv4/inet_connection_sock.c	2009-06-13 10:53:58.000000000 +0300
+++ linux/net/ipv4/inet_connection_sock.c	2009-10-16 11:35:52.000000000 +0300
@@ -446,6 +446,28 @@ extern int sysctl_tcp_synack_retries;
 
 EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_hash_add);
 
+/* Decide when to expire the request and when to resend SYN-ACK */
+static inline void syn_ack_recalc(struct request_sock *req, const int thresh,
+				  const int max_retries,
+				  const u8 rskq_defer_accept,
+				  int *expire, int *resend)
+{
+	if (!rskq_defer_accept) {
+		*expire = req->retrans >= thresh;
+		*resend = 1;
+		return;
+	}
+	*expire = req->retrans >= thresh &&
+		  (!inet_rsk(req)->acked || req->retrans >= max_retries);
+	/*
+	 * Do not resend while waiting for data after ACK,
+	 * start to resend on end of deferring period to give
+	 * last chance for data or ACK to create established socket.
+	 */
+	*resend = !inet_rsk(req)->acked ||
+		  req->retrans >= rskq_defer_accept - 1;
+}
+
 void inet_csk_reqsk_queue_prune(struct sock *parent,
 				const unsigned long interval,
 				const unsigned long timeout,
@@ -501,9 +523,15 @@ void inet_csk_reqsk_queue_prune(struct s
 		reqp=&lopt->syn_table[i];
 		while ((req = *reqp) != NULL) {
 			if (time_after_eq(now, req->expires)) {
-				if ((req->retrans < thresh ||
-				     (inet_rsk(req)->acked && req->retrans < max_retries))
-				    && !req->rsk_ops->rtx_syn_ack(parent, req)) {
+				int expire = 0, resend = 0;
+
+				syn_ack_recalc(req, thresh, max_retries,
+					       queue->rskq_defer_accept,
+					       &expire, &resend);
+				if (!expire &&
+				    (!resend ||
+				     !req->rsk_ops->rtx_syn_ack(parent, req) ||
+				     inet_rsk(req)->acked)) {
 					unsigned long timeo;
 
 					if (req->retrans++ == 0)
