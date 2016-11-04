From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/2] tcp: no longer hold ehash lock while calling tcp_get_info()
Date: Fri,  4 Nov 2016 11:54:32 -0700
Message-ID: <1478285672-3195-3-git-send-email-edumazet@google.com>
References: <1478285672-3195-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36345 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964835AbcKDSyq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 14:54:46 -0400
Received: by mail-pf0-f178.google.com with SMTP id 189so56192024pfz.3
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 11:54:45 -0700 (PDT)
In-Reply-To: <1478285672-3195-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We had various problems in the past in tcp_get_info() and used
specific synchronization to avoid deadlocks.

We would like to add more instrumentation points for TCP, and
avoiding grabing socket lock in tcp_getinfo() was too costly.

Being able to lock the socket allows to provide consistent set
of fields.

inet_diag_dump_icsk() can make sure ehash locks are not
held any more when tcp_get_info() is called.

We can remove syncp added in commit d654976cbf85
("tcp: fix a potential deadlock in tcp_get_info()"), but we need
to use lock_sock_fast() instead of spin_lock_bh() since TCP input
path can now be run from process context.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
Acked-by: Neal Cardwell <ncardwell@google.com>
---
 include/linux/tcp.h  |  2 --
 net/ipv4/inet_diag.c | 48 +++++++++++++++++++++++++++++++++---------------
 net/ipv4/tcp.c       | 20 +++++++++-----------
 net/ipv4/tcp_input.c |  4 ----
 4 files changed, 42 insertions(+), 32 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index a17ae7b85218..32a7c7e35b71 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -176,8 +176,6 @@ struct tcp_sock {
 				 * sum(delta(snd_una)), or how many bytes
 				 * were acked.
 				 */
-	struct u64_stats_sync syncp; /* protects 64bit vars (cf tcp_get_info()) */
-
  	u32	snd_una;	/* First byte we want an ack for	*/
  	u32	snd_sml;	/* Last byte of the most recently transmitted small packet */
 	u32	rcv_tstamp;	/* timestamp of last received ACK (for keepalives) */
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 3b34024202d8..4dea33e5f295 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -861,10 +861,11 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 			 struct netlink_callback *cb,
 			 const struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
+	bool net_admin = netlink_net_capable(cb->skb, CAP_NET_ADMIN);
 	struct net *net = sock_net(skb->sk);
-	int i, num, s_i, s_num;
 	u32 idiag_states = r->idiag_states;
-	bool net_admin = netlink_net_capable(cb->skb, CAP_NET_ADMIN);
+	int i, num, s_i, s_num;
+	struct sock *sk;
 
 	if (idiag_states & TCPF_SYN_RECV)
 		idiag_states |= TCPF_NEW_SYN_RECV;
@@ -877,7 +878,6 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 
 		for (i = s_i; i < INET_LHTABLE_SIZE; i++) {
 			struct inet_listen_hashbucket *ilb;
-			struct sock *sk;
 
 			num = 0;
 			ilb = &hashinfo->listening_hash[i];
@@ -922,13 +922,14 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 	if (!(idiag_states & ~TCPF_LISTEN))
 		goto out;
 
+#define SKARR_SZ 16
 	for (i = s_i; i <= hashinfo->ehash_mask; i++) {
 		struct inet_ehash_bucket *head = &hashinfo->ehash[i];
 		spinlock_t *lock = inet_ehash_lockp(hashinfo, i);
 		struct hlist_nulls_node *node;
-		struct sock *sk;
-
-		num = 0;
+		struct sock *sk_arr[SKARR_SZ];
+		int num_arr[SKARR_SZ];
+		int idx, accum, res;
 
 		if (hlist_nulls_empty(&head->chain))
 			continue;
@@ -936,9 +937,12 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 		if (i > s_i)
 			s_num = 0;
 
+next_chunk:
+		num = 0;
+		accum = 0;
 		spin_lock_bh(lock);
 		sk_nulls_for_each(sk, node, &head->chain) {
-			int state, res;
+			int state;
 
 			if (!net_eq(sock_net(sk), net))
 				continue;
@@ -962,21 +966,35 @@ void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 			if (!inet_diag_bc_sk(bc, sk))
 				goto next_normal;
 
-			res = sk_diag_fill(sk, skb, r,
+			sock_hold(sk);
+			num_arr[accum] = num;
+			sk_arr[accum] = sk;
+			if (++accum == SKARR_SZ)
+				break;
+next_normal:
+			++num;
+		}
+		spin_unlock_bh(lock);
+		res = 0;
+		for (idx = 0; idx < accum; idx++) {
+			if (res >= 0) {
+				res = sk_diag_fill(sk_arr[idx], skb, r,
 					   sk_user_ns(NETLINK_CB(cb->skb).sk),
 					   NETLINK_CB(cb->skb).portid,
 					   cb->nlh->nlmsg_seq, NLM_F_MULTI,
 					   cb->nlh, net_admin);
-			if (res < 0) {
-				spin_unlock_bh(lock);
-				goto done;
+				if (res < 0)
+					num = num_arr[idx];
 			}
-next_normal:
-			++num;
+			sock_gen_put(sk_arr[idx]);
 		}
-
-		spin_unlock_bh(lock);
+		if (res < 0)
+			break;
 		cond_resched();
+		if (accum == SKARR_SZ) {
+			s_num = num + 1;
+			goto next_chunk;
+		}
 	}
 
 done:
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 117982be0cab..a7d54cbcdabb 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -405,7 +405,6 @@ void tcp_init_sock(struct sock *sk)
 	tp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
 	tp->snd_cwnd_clamp = ~0;
 	tp->mss_cache = TCP_MSS_DEFAULT;
-	u64_stats_init(&tp->syncp);
 
 	tp->reordering = sock_net(sk)->ipv4.sysctl_tcp_reordering;
 	tcp_enable_early_retrans(tp);
@@ -2710,9 +2709,8 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	const struct tcp_sock *tp = tcp_sk(sk); /* iff sk_type == SOCK_STREAM */
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	u32 now = tcp_time_stamp, intv;
-	unsigned int start;
-	int notsent_bytes;
 	u64 rate64;
+	bool slow;
 	u32 rate;
 
 	memset(info, 0, sizeof(*info));
@@ -2792,17 +2790,17 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 
 	info->tcpi_total_retrans = tp->total_retrans;
 
-	do {
-		start = u64_stats_fetch_begin_irq(&tp->syncp);
-		put_unaligned(tp->bytes_acked, &info->tcpi_bytes_acked);
-		put_unaligned(tp->bytes_received, &info->tcpi_bytes_received);
-	} while (u64_stats_fetch_retry_irq(&tp->syncp, start));
+	slow = lock_sock_fast(sk);
+
+	put_unaligned(tp->bytes_acked, &info->tcpi_bytes_acked);
+	put_unaligned(tp->bytes_received, &info->tcpi_bytes_received);
+	info->tcpi_notsent_bytes = max_t(int, 0, tp->write_seq - tp->snd_nxt);
+
+	unlock_sock_fast(sk, slow);
+
 	info->tcpi_segs_out = tp->segs_out;
 	info->tcpi_segs_in = tp->segs_in;
 
-	notsent_bytes = READ_ONCE(tp->write_seq) - READ_ONCE(tp->snd_nxt);
-	info->tcpi_notsent_bytes = max(0, notsent_bytes);
-
 	info->tcpi_min_rtt = tcp_min_rtt(tp);
 	info->tcpi_data_segs_in = tp->data_segs_in;
 	info->tcpi_data_segs_out = tp->data_segs_out;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f2c59c8e57ff..a70046fea0e8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3351,9 +3351,7 @@ static void tcp_snd_una_update(struct tcp_sock *tp, u32 ack)
 	u32 delta = ack - tp->snd_una;
 
 	sock_owned_by_me((struct sock *)tp);
-	u64_stats_update_begin_raw(&tp->syncp);
 	tp->bytes_acked += delta;
-	u64_stats_update_end_raw(&tp->syncp);
 	tp->snd_una = ack;
 }
 
@@ -3363,9 +3361,7 @@ static void tcp_rcv_nxt_update(struct tcp_sock *tp, u32 seq)
 	u32 delta = seq - tp->rcv_nxt;
 
 	sock_owned_by_me((struct sock *)tp);
-	u64_stats_update_begin_raw(&tp->syncp);
 	tp->bytes_received += delta;
-	u64_stats_update_end_raw(&tp->syncp);
 	tp->rcv_nxt = seq;
 }
 
-- 
2.8.0.rc3.226.g39d4020
