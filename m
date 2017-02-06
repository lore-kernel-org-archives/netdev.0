From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv4 net-next 4/7] tcp: replace dst_confirm with sk_dst_confirm
Date: Mon,  6 Feb 2017 23:14:14 +0200
Message-ID: <1486415657-14714-5-git-send-email-ja@ssi.bg>
References: <1486415657-14714-1-git-send-email-ja@ssi.bg>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        linux-rdma@vger.kernel.org, YueHaibing <yuehaibing@huawei.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47236 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752567AbdBFVQb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 16:16:31 -0500
In-Reply-To: <1486415657-14714-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When same struct dst_entry can be used for many different
neighbours we can not use it for pending confirmations.
Use the new sk_dst_confirm() helper to propagate the
indication from received packets to sock_confirm_neigh().

Reported-by: YueHaibing <yuehaibing@huawei.com>
Fixes: 5110effee8fd ("net: Do delayed neigh confirmation.")
Fixes: f2bb4bedf35d ("ipv4: Cache output routes in fib_info nexthops.")
Tested-by: YueHaibing <yuehaibing@huawei.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c   | 12 +++---------
 net/ipv4/tcp_metrics.c |  7 ++-----
 net/ipv4/tcp_output.c  |  2 ++
 3 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 27c95ac..2c0ff32 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3644,11 +3644,8 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	if (tp->tlp_high_seq)
 		tcp_process_tlp_ack(sk, ack, flag);
 
-	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag & FLAG_NOT_DUP)) {
-		struct dst_entry *dst = __sk_dst_get(sk);
-		if (dst)
-			dst_confirm(dst);
-	}
+	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag & FLAG_NOT_DUP))
+		sk_dst_confirm(sk);
 
 	if (icsk->icsk_pending == ICSK_TIME_RETRANS)
 		tcp_schedule_loss_probe(sk);
@@ -5995,7 +5992,6 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 		break;
 
 	case TCP_FIN_WAIT1: {
-		struct dst_entry *dst;
 		int tmo;
 
 		/* If we enter the TCP_FIN_WAIT1 state and we are a
@@ -6022,9 +6018,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 		tcp_set_state(sk, TCP_FIN_WAIT2);
 		sk->sk_shutdown |= SEND_SHUTDOWN;
 
-		dst = __sk_dst_get(sk);
-		if (dst)
-			dst_confirm(dst);
+		sk_dst_confirm(sk);
 
 		if (!sock_flag(sk, SOCK_DEAD)) {
 			/* Wake up lingering close() */
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index b9ed0d5..0f46e5f 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -375,12 +375,10 @@ void tcp_update_metrics(struct sock *sk)
 	u32 val;
 	int m;
 
+	sk_dst_confirm(sk);
 	if (sysctl_tcp_nometrics_save || !dst)
 		return;
 
-	if (dst->flags & DST_HOST)
-		dst_confirm(dst);
-
 	rcu_read_lock();
 	if (icsk->icsk_backoff || !tp->srtt_us) {
 		/* This session failed to estimate rtt. Why?
@@ -493,11 +491,10 @@ void tcp_init_metrics(struct sock *sk)
 	struct tcp_metrics_block *tm;
 	u32 val, crtt = 0; /* cached RTT scaled by 8 */
 
+	sk_dst_confirm(sk);
 	if (!dst)
 		goto reset;
 
-	dst_confirm(dst);
-
 	rcu_read_lock();
 	tm = tcp_get_metrics(sk, dst, true);
 	if (!tm) {
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ccf1ef4..61f272a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -980,6 +980,8 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	skb_set_hash_from_sk(skb, sk);
 	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 
+	skb_set_dst_pending_confirm(skb, sk->sk_dst_pending_confirm);
+
 	/* Build TCP header and checksum it. */
 	th = (struct tcphdr *)skb->data;
 	th->source		= inet->inet_sport;
-- 
1.9.3
