From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 4/5] tcp: improve fastopen icmp handling
Date: Sun, 11 May 2014 20:22:12 -0700
Message-ID: <1399864933-28287-5-git-send-email-ycheng@google.com>
References: <1399864933-28287-1-git-send-email-ycheng@google.com>
Cc: longinus00@gmail.com, hkchu@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:64271 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864AbaELDWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 23:22:51 -0400
Received: by mail-pa0-f73.google.com with SMTP id lj1so1099334pab.0
        for <netdev@vger.kernel.org>; Sun, 11 May 2014 20:22:50 -0700 (PDT)
In-Reply-To: <1399864933-28287-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a fast open socket is already accepted by the user, it should
be treated like a connected socket to record the ICMP error in
sk_softerr, so the user can fetch it. Do that in both tcp_v4_err
and tcp_v6_err.

Also refactor the sequence window check to improve readability
(e.g., there were two local variables named 'req').

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Daniel Lee <longinus00@gmail.com>
Signed-off-by: Jerry Chu <hkchu@google.com>
---
 net/ipv4/tcp_ipv4.c | 35 ++++++++++++++---------------------
 net/ipv6/tcp_ipv6.c | 22 +++++++++++++++++-----
 2 files changed, 31 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1665f0f..a2780e5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -336,8 +336,8 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 	const int code = icmp_hdr(icmp_skb)->code;
 	struct sock *sk;
 	struct sk_buff *skb;
-	struct request_sock *req;
-	__u32 seq;
+	struct request_sock *fastopen;
+	__u32 seq, snd_una;
 	__u32 remaining;
 	int err;
 	struct net *net = dev_net(icmp_skb->dev);
@@ -378,12 +378,12 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 
 	icsk = inet_csk(sk);
 	tp = tcp_sk(sk);
-	req = tp->fastopen_rsk;
 	seq = ntohl(th->seq);
+	/* XXX (TFO) - tp->snd_una should be ISN (tcp_create_openreq_child() */
+	fastopen = tp->fastopen_rsk;
+	snd_una = fastopen ? tcp_rsk(fastopen)->snt_isn : tp->snd_una;
 	if (sk->sk_state != TCP_LISTEN &&
-	    !between(seq, tp->snd_una, tp->snd_nxt) &&
-	    (req == NULL || seq != tcp_rsk(req)->snt_isn)) {
-		/* For a Fast Open socket, allow seq to be snt_isn. */
+	    !between(seq, snd_una, tp->snd_nxt)) {
 		NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 		goto out;
 	}
@@ -426,11 +426,9 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		if (code != ICMP_NET_UNREACH && code != ICMP_HOST_UNREACH)
 			break;
 		if (seq != tp->snd_una  || !icsk->icsk_retransmits ||
-		    !icsk->icsk_backoff)
+		    !icsk->icsk_backoff || fastopen)
 			break;
 
-		/* XXX (TFO) - revisit the following logic for TFO */
-
 		if (sock_owned_by_user(sk))
 			break;
 
@@ -462,14 +460,6 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		goto out;
 	}
 
-	/* XXX (TFO) - if it's a TFO socket and has been accepted, rather
-	 * than following the TCP_SYN_RECV case and closing the socket,
-	 * we ignore the ICMP error and keep trying like a fully established
-	 * socket. Is this the right thing to do?
-	 */
-	if (req && req->sk == NULL)
-		goto out;
-
 	switch (sk->sk_state) {
 		struct request_sock *req, **prev;
 	case TCP_LISTEN:
@@ -502,10 +492,13 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		goto out;
 
 	case TCP_SYN_SENT:
-	case TCP_SYN_RECV:  /* Cannot happen.
-			       It can f.e. if SYNs crossed,
-			       or Fast Open.
-			     */
+	case TCP_SYN_RECV:
+		/* Only in fast or simultaneous open. If a fast open socket is
+		 * is already accepted it is treated as a connected one below.
+		 */
+		if (fastopen && fastopen->sk == NULL)
+			break;
+
 		if (!sock_owned_by_user(sk)) {
 			sk->sk_err = err;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7fa6743..a7a62ce 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -340,7 +340,8 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	struct sock *sk;
 	int err;
 	struct tcp_sock *tp;
-	__u32 seq;
+	struct request_sock *fastopen;
+	__u32 seq, snd_una;
 	struct net *net = dev_net(skb->dev);
 
 	sk = inet6_lookup(net, &tcp_hashinfo, &hdr->daddr,
@@ -371,8 +372,11 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	tp = tcp_sk(sk);
 	seq = ntohl(th->seq);
+	/* XXX (TFO) - tp->snd_una should be ISN (tcp_create_openreq_child() */
+	fastopen = tp->fastopen_rsk;
+	snd_una = fastopen ? tcp_rsk(fastopen)->snt_isn : tp->snd_una;
 	if (sk->sk_state != TCP_LISTEN &&
-	    !between(seq, tp->snd_una, tp->snd_nxt)) {
+	    !between(seq, snd_una, tp->snd_nxt)) {
 		NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 		goto out;
 	}
@@ -436,8 +440,13 @@ static void tcp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		goto out;
 
 	case TCP_SYN_SENT:
-	case TCP_SYN_RECV:  /* Cannot happen.
-			       It can, it SYNs are crossed. --ANK */
+	case TCP_SYN_RECV:
+		/* Only in fast or simultaneous open. If a fast open socket is
+		 * is already accepted it is treated as a connected one below.
+		 */
+		if (fastopen && fastopen->sk == NULL)
+			break;
+
 		if (!sock_owned_by_user(sk)) {
 			sk->sk_err = err;
 			sk->sk_error_report(sk);		/* Wake people up to see the error (see connect in sock.c) */
@@ -1760,6 +1769,7 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 	const struct inet_sock *inet = inet_sk(sp);
 	const struct tcp_sock *tp = tcp_sk(sp);
 	const struct inet_connection_sock *icsk = inet_csk(sp);
+	struct fastopen_queue *fastopenq = icsk->icsk_accept_queue.fastopenq;
 
 	dest  = &sp->sk_v6_daddr;
 	src   = &sp->sk_v6_rcv_saddr;
@@ -1802,7 +1812,9 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 		   jiffies_to_clock_t(icsk->icsk_ack.ato),
 		   (icsk->icsk_ack.quick << 1) | icsk->icsk_ack.pingpong,
 		   tp->snd_cwnd,
-		   tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh
+		   sp->sk_state == TCP_LISTEN ?
+			(fastopenq ? fastopenq->max_qlen : 0) :
+			(tcp_in_initial_slowstart(tp) ? -1 : tp->snd_ssthresh)
 		   );
 }
 
-- 
1.9.1.423.g4596e3a
