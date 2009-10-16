From: Julian Anastasov <ja@ssi.bg>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Fri, 16 Oct 2009 11:49:48 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0910161137490.3886@u.domain.uli>
References: <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli>
 <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net>
 <20091015060834.GB29564@1wt.eu> <Pine.LNX.4.58.0910151120340.2879@u.domain.uli>
 <20091015124134.GB1073@1wt.eu> <Pine.LNX.4.58.0910152257410.3047@u.domain.uli>
 <20091016050310.GA5574@1wt.eu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:38651 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751614AbZJPItq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2009 04:49:46 -0400
In-Reply-To: <20091016050310.GA5574@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 16 Oct 2009, Willy Tarreau wrote:

> > 	This will need little change in inet_csk_reqsk_queue_prune()
> > but it saves SYN-ACK traffic during deferring period in the
> > common case when client sends ACK. If such compromise is
> > acceptable I can prepare and test some patch.
> 
> I would personally like this a lot ! This will satisfy people who
> expect it to establish at the end of the "TCP_DEFER_ACCEPT delay"
> as can be interpreted from the man page, will reduce the number of
> useless SYN-ACKs that annoy other people while still making no
> visible change for anyone who would rely on the current behaviour.

	OK, I don't have much time now, this is what I'm
going to test later today and later can provide proper comments:

Signed-off-by: Julian Anastasov <ja@ssi.bg>

Patch 1: Accept connections after deferring period:

diff -urp v2.6.31/linux/net/ipv4/tcp_minisocks.c linux/net/ipv4/tcp_minisocks.c
--- v2.6.31/linux/net/ipv4/tcp_minisocks.c	2009-09-11 10:27:17.000000000 +0300
+++ linux/net/ipv4/tcp_minisocks.c	2009-10-16 10:29:19.000000000 +0300
@@ -641,8 +641,8 @@ struct sock *tcp_check_req(struct sock *
 	if (!(flg & TCP_FLAG_ACK))
 		return NULL;
 
-	/* If TCP_DEFER_ACCEPT is set, drop bare ACK. */
-	if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
+	/* While TCP_DEFER_ACCEPT is active, drop bare ACK. */
+	if (req->retrans < inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
 	    TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {
 		inet_rsk(req)->acked = 1;
 		return NULL;

Patch 2: Do not resend SYN-ACK while waiting for data after ACK.
Also, do not drop acked request if sending of SYN-ACK fails.

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

Regards

--
Julian Anastasov <ja@ssi.bg>
