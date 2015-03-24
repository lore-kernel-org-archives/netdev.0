From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 1/5] tcp: md5: fix rcu lockdep splat
Date: Tue, 24 Mar 2015 15:58:52 -0700
Message-ID: <1427237936-19030-2-git-send-email-edumazet@google.com>
References: <1427237936-19030-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:33478 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbbCXW7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:59:17 -0400
Received: by pablj1 with SMTP id lj1so763456pab.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 15:59:16 -0700 (PDT)
In-Reply-To: <1427237936-19030-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While timer handler effectively runs a rcu read locked section,
there is no explicit rcu_read_lock()/rcu_read_unlock() annotations
and lockdep can be confused here :

net/ipv4/tcp_ipv4.c-906-        /* caller either holds rcu_read_lock() or socket lock */
net/ipv4/tcp_ipv4.c:907:        md5sig = rcu_dereference_check(tp->md5sig_info,
net/ipv4/tcp_ipv4.c-908-                                       sock_owned_by_user(sk) ||
net/ipv4/tcp_ipv4.c-909-                                       lockdep_is_held(&sk->sk_lock.slock));

Let's explicitely acquire rcu_read_lock() in tcp_make_synack()

Before commit fa76ce7328b ("inet: get rid of central tcp/dccp listener
timer"), we were holding listener lock so lockdep was happy.

Fixes: fa76ce7328b ("inet: get rid of central tcp/dccp listener timer")
Signed-off-by: Eric DUmazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 18474088c3d0..5b7fad4b314c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -601,15 +601,14 @@ static unsigned int tcp_synack_options(struct sock *sk,
 				   struct request_sock *req,
 				   unsigned int mss, struct sk_buff *skb,
 				   struct tcp_out_options *opts,
-				   struct tcp_md5sig_key **md5,
+				   const struct tcp_md5sig_key *md5,
 				   struct tcp_fastopen_cookie *foc)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 	unsigned int remaining = MAX_TCP_OPTION_SPACE;
 
 #ifdef CONFIG_TCP_MD5SIG
-	*md5 = tcp_rsk(req)->af_specific->md5_lookup(sk, req);
-	if (*md5) {
+	if (md5) {
 		opts->options |= OPTION_MD5;
 		remaining -= TCPOLEN_MD5SIG_ALIGNED;
 
@@ -620,8 +619,6 @@ static unsigned int tcp_synack_options(struct sock *sk,
 		 */
 		ireq->tstamp_ok &= !ireq->sack_ok;
 	}
-#else
-	*md5 = NULL;
 #endif
 
 	/* We always send an MSS option. */
@@ -2913,7 +2910,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcphdr *th;
 	struct sk_buff *skb;
-	struct tcp_md5sig_key *md5;
+	struct tcp_md5sig_key *md5 = NULL;
 	int tcp_header_size;
 	int mss;
 
@@ -2938,7 +2935,12 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	else
 #endif
 	skb_mstamp_get(&skb->skb_mstamp);
-	tcp_header_size = tcp_synack_options(sk, req, mss, skb, &opts, &md5,
+
+#ifdef CONFIG_TCP_MD5SIG
+	rcu_read_lock();
+	md5 = tcp_rsk(req)->af_specific->md5_lookup(sk, req);
+#endif
+	tcp_header_size = tcp_synack_options(sk, req, mss, skb, &opts, md5,
 					     foc) + sizeof(*th);
 
 	skb_push(skb, tcp_header_size);
@@ -2969,10 +2971,10 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Okay, we have all we need - do the md5 hash if needed */
-	if (md5) {
+	if (md5)
 		tcp_rsk(req)->af_specific->calc_md5_hash(opts.hash_location,
 					       md5, NULL, req, skb);
-	}
+	rcu_read_unlock();
 #endif
 
 	return skb;
-- 
2.2.0.rc0.207.ga3a616c
