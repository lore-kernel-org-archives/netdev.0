From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: fix a potential deadlock in tcp_get_info()
Date: Thu, 21 May 2015 21:51:19 -0700
Message-ID: <1432270279.4060.128.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150512130855.GA29412@localhost.localdomain>
	 <1431462713.566.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432164941.4060.57.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150521.232541.173137306546517818.davem@davemloft.net>
	 <1432266206.4060.119.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, edumazet@google.com, netdev@vger.kernel.org,
	ycheng@google.com, mattmathis@google.com, cgallek@google.com,
	kafai@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:34879 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbbEVEvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 00:51:22 -0400
Received: by igbyr2 with SMTP id yr2so27136353igb.0
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 21:51:21 -0700 (PDT)
In-Reply-To: <1432266206.4060.119.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Taking socket spinlock in tcp_get_info() can deadlock, as
inet_diag_dump_icsk() holds the &hashinfo->ehash_locks[i],
while packet processing can use the reverse locking order.

We could avoid this locking for TCP_LISTEN states, but lockdep would
certainly get confused as all TCP sockets share same lockdep classes.

[  523.722504] ======================================================
[  523.728706] [ INFO: possible circular locking dependency detected ]
[  523.734990] 4.1.0-dbg-DEV #1676 Not tainted
[  523.739202] -------------------------------------------------------
[  523.745474] ss/18032 is trying to acquire lock:
[  523.750002]  (slock-AF_INET){+.-...}, at: [<ffffffff81669d44>] tcp_get_info+0x2c4/0x360
[  523.758129]
[  523.758129] but task is already holding lock:
[  523.763968]  (&(&hashinfo->ehash_locks[i])->rlock){+.-...}, at: [<ffffffff816bcb75>] inet_diag_dump_icsk+0x1d5/0x6c0
[  523.774661]
[  523.774661] which lock already depends on the new lock.
[  523.774661]
[  523.782850]
[  523.782850] the existing dependency chain (in reverse order) is:
[  523.790326]
-> #1 (&(&hashinfo->ehash_locks[i])->rlock){+.-...}:
[  523.796599]        [<ffffffff811126bb>] lock_acquire+0xbb/0x270
[  523.802565]        [<ffffffff816f5868>] _raw_spin_lock+0x38/0x50
[  523.808628]        [<ffffffff81665af8>] __inet_hash_nolisten+0x78/0x110
[  523.815273]        [<ffffffff816819db>] tcp_v4_syn_recv_sock+0x24b/0x350
[  523.822067]        [<ffffffff81684d41>] tcp_check_req+0x3c1/0x500
[  523.828199]        [<ffffffff81682d09>] tcp_v4_do_rcv+0x239/0x3d0
[  523.834331]        [<ffffffff816842fe>] tcp_v4_rcv+0xa8e/0xc10
[  523.840202]        [<ffffffff81658fa3>] ip_local_deliver_finish+0x133/0x3e0
[  523.847214]        [<ffffffff81659a9a>] ip_local_deliver+0xaa/0xc0
[  523.853440]        [<ffffffff816593b8>] ip_rcv_finish+0x168/0x5c0
[  523.859624]        [<ffffffff81659db7>] ip_rcv+0x307/0x420

Lets use u64_sync infrastructure instead. As a bonus, 64bit
arches get optimized, as these are nop for them.

Fixes: 0df48c26d841 ("tcp: add tcpi_bytes_acked to tcp_info")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h     |    2 ++
 net/ipv4/tcp.c          |   12 ++++++++----
 net/ipv4/tcp_fastopen.c |    4 ++++
 net/ipv4/tcp_input.c    |    4 ++++
 4 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index f0212026c77f..48c3696e8645 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -163,6 +163,8 @@ struct tcp_sock {
 				 * sum(delta(snd_una)), or how many bytes
 				 * were acked.
 				 */
+	struct u64_stats_sync syncp; /* protects 64bit vars (cf tcp_get_info()) */
+
  	u32	snd_una;	/* First byte we want an ack for	*/
  	u32	snd_sml;	/* Last byte of the most recently transmitted small packet */
 	u32	rcv_tstamp;	/* timestamp of last received ACK (for keepalives) */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 7f3e721b9e69..7bab7dd130bf 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -402,6 +402,7 @@ void tcp_init_sock(struct sock *sk)
 	tp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
 	tp->snd_cwnd_clamp = ~0;
 	tp->mss_cache = TCP_MSS_DEFAULT;
+	u64_stats_init(&tp->syncp);
 
 	tp->reordering = sysctl_tcp_reordering;
 	tcp_enable_early_retrans(tp);
@@ -2625,6 +2626,7 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	u32 now = tcp_time_stamp;
+	unsigned int start;
 	u32 rate;
 
 	memset(info, 0, sizeof(*info));
@@ -2692,12 +2694,14 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	rate = READ_ONCE(sk->sk_max_pacing_rate);
 	info->tcpi_max_pacing_rate = rate != ~0U ? rate : ~0ULL;
 
-	spin_lock_bh(&sk->sk_lock.slock);
-	info->tcpi_bytes_acked = tp->bytes_acked;
-	info->tcpi_bytes_received = tp->bytes_received;
+	do {
+		start = u64_stats_fetch_begin_irq(&tp->syncp);
+		info->tcpi_bytes_acked = tp->bytes_acked;
+		info->tcpi_bytes_received = tp->bytes_received;
+	} while (u64_stats_fetch_retry_irq(&tp->syncp, start));
+
 	info->tcpi_segs_out = tp->segs_out;
 	info->tcpi_segs_in = tp->segs_in;
-	spin_unlock_bh(&sk->sk_lock.slock);
 }
 EXPORT_SYMBOL_GPL(tcp_get_info);
 
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 3c673d5e6cff..46b087a27503 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -206,6 +206,10 @@ static bool tcp_fastopen_create_child(struct sock *sk,
 			skb_set_owner_r(skb2, child);
 			__skb_queue_tail(&child->sk_receive_queue, skb2);
 			tp->syn_data_acked = 1;
+
+			/* u64_stats_update_begin(&tp->syncp) not needed here,
+			 * as we certainly are not changing upper 32bit value (0)
+			 */
 			tp->bytes_received = end_seq - TCP_SKB_CB(skb)->seq - 1;
 		} else {
 			end_seq = TCP_SKB_CB(skb)->seq + 1;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 40c435997e54..23bfd5492a32 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3281,7 +3281,9 @@ static void tcp_snd_una_update(struct tcp_sock *tp, u32 ack)
 {
 	u32 delta = ack - tp->snd_una;
 
+	u64_stats_update_begin(&tp->syncp);
 	tp->bytes_acked += delta;
+	u64_stats_update_end(&tp->syncp);
 	tp->snd_una = ack;
 }
 
@@ -3290,7 +3292,9 @@ static void tcp_rcv_nxt_update(struct tcp_sock *tp, u32 seq)
 {
 	u32 delta = seq - tp->rcv_nxt;
 
+	u64_stats_update_begin(&tp->syncp);
 	tp->bytes_received += delta;
+	u64_stats_update_end(&tp->syncp);
 	tp->rcv_nxt = seq;
 }
 
