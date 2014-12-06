From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] tcp: refine TSO autosizing
Date: Fri, 05 Dec 2014 18:22:40 -0800
Message-ID: <1417832560.15618.29.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417788937.4322.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:56660 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbaLFCWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 21:22:46 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so255206igj.16
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 18:22:46 -0800 (PST)
In-Reply-To: <1417788937.4322.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit 95bd09eb2750 ("tcp: TSO packets automatic sizing") tried to
control TSO size, but did this at the wrong place (sendmsg() time)

At sendmsg() time, we might have a pessimistic view of flow rate,
and we end up building very small skbs (with 2 MSS per skb).

This is bad because :

 - It sends small TSO packets even in Slow Start where rate quickly
   increases.
 - It tends to make socket write queue very big, increasing tcp_ack()
   processing time, but also increasing memory needs, not necessarily
   accounted for, as fast clones overhead is currently ignored.
 - Lower GRO efficiency and more ACK packets.

Servers with a lot of small lived connections suffer from this.

Lets instead fill skbs as much as possible (64KB of payload), but split
them at xmit time, when we have a precise idea of the flow rate.
skb split is actually quite efficient.

Patch looks bigger than necessary, because TCP Small Queue decision now
has to take place after the eventual split.

As Neal suggested, get rid of tp->xmit_size_goal_segs, and
introduce a new tcp_tso_autosize() helper, so that
tcp_tso_should_defer() can be synchronized on same goal.

Tested:

40 ms rtt link

nstat >/dev/null
netperf -H remote -Cc -l -2000000 -- -s 1000000
nstat | egrep "IpInReceives|IpOutRequests|TcpOutSegs|IpExtOutOctets"

Before patch :

Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380 2000000 2000000    0.36         44.22   0.00     0.06     0.000   5.007  
IpInReceives                    600                0.0
IpOutRequests                   599                0.0
TcpOutSegs                      1397               0.0
IpExtOutOctets                  2033249            0.0


After patch :

Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380 2000000 2000000    0.36         44.09   0.00     0.00     0.000   0.000  
IpInReceives                    257                0.0
IpOutRequests                   226                0.0
TcpOutSegs                      1399               0.0
IpExtOutOctets                  2013777            0.0


Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
v2: added tcp_tso_autosize() helper and removed tp->xmit_size_goal_segs

 include/linux/tcp.h   |    2 -
 net/ipv4/tcp.c        |   44 ++++++-----------------------
 net/ipv4/tcp_output.c |   59 +++++++++++++++++++++++++++-------------
 3 files changed, 51 insertions(+), 54 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index f566b8567892ef0bb213de0540b37cfc6ac03ca0..a2944717f1b7d1d12b4e2397c20457931ad71bac 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -130,7 +130,7 @@ struct tcp_sock {
 	/* inet_connection_sock has to be the first member of tcp_sock */
 	struct inet_connection_sock	inet_conn;
 	u16	tcp_header_len;	/* Bytes of tcp header to send		*/
-	u16	xmit_size_goal_segs; /* Goal for segmenting output packets */
+	/* 2 bytes hole */
 
 /*
  *	Header prediction flags
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index dc13a3657e8e1b81ba0cb1fcd5386a9d0b106168..6e692f7ac62880415093ca7a43c782c7fd6a049b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -835,45 +835,19 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
 				       int large_allowed)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	u32 xmit_size_goal, old_size_goal;
+	u32 hlen, xmit_size_goal;
 
-	xmit_size_goal = mss_now;
+	if (!large_allowed || !sk_can_gso(sk))
+		return mss_now;
 
-	if (large_allowed && sk_can_gso(sk)) {
-		u32 gso_size, hlen;
+	/* Maybe we should/could use sk->sk_prot->max_header here ? */
+	hlen = inet_csk(sk)->icsk_af_ops->net_header_len +
+	       inet_csk(sk)->icsk_ext_hdr_len +
+	       tp->tcp_header_len;
 
-		/* Maybe we should/could use sk->sk_prot->max_header here ? */
-		hlen = inet_csk(sk)->icsk_af_ops->net_header_len +
-		       inet_csk(sk)->icsk_ext_hdr_len +
-		       tp->tcp_header_len;
+	xmit_size_goal = sk->sk_gso_max_size - 1 - hlen;
 
-		/* Goal is to send at least one packet per ms,
-		 * not one big TSO packet every 100 ms.
-		 * This preserves ACK clocking and is consistent
-		 * with tcp_tso_should_defer() heuristic.
-		 */
-		gso_size = sk->sk_pacing_rate / (2 * MSEC_PER_SEC);
-		gso_size = max_t(u32, gso_size,
-				 sysctl_tcp_min_tso_segs * mss_now);
-
-		xmit_size_goal = min_t(u32, gso_size,
-				       sk->sk_gso_max_size - 1 - hlen);
-
-		xmit_size_goal = tcp_bound_to_half_wnd(tp, xmit_size_goal);
-
-		/* We try hard to avoid divides here */
-		old_size_goal = tp->xmit_size_goal_segs * mss_now;
-
-		if (likely(old_size_goal <= xmit_size_goal &&
-			   old_size_goal + mss_now > xmit_size_goal)) {
-			xmit_size_goal = old_size_goal;
-		} else {
-			tp->xmit_size_goal_segs =
-				min_t(u16, xmit_size_goal / mss_now,
-				      sk->sk_gso_max_segs);
-			xmit_size_goal = tp->xmit_size_goal_segs * mss_now;
-		}
-	}
+	xmit_size_goal = tcp_bound_to_half_wnd(tp, xmit_size_goal);
 
 	return max(xmit_size_goal, mss_now);
 }
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f5bd4bd3f7e669b3fd48a843d55e7313a30a3409..f37ecf53ee8a96827fc08bd203b0ca8857f8fc34 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1524,6 +1524,27 @@ static bool tcp_nagle_check(bool partial, const struct tcp_sock *tp,
 		((nonagle & TCP_NAGLE_CORK) ||
 		 (!nonagle && tp->packets_out && tcp_minshall_check(tp)));
 }
+
+/* Return how many segs we'd like on a TSO packet,
+ * to send one TSO packet per ms.
+ */
+static u32 tcp_tso_autosize(const struct sock *sk, unsigned int mss_now)
+{
+	u32 bytes, segs;
+
+	bytes = min(sk->sk_pacing_rate >> 10,
+		    sk->sk_gso_max_size - 1 - MAX_TCP_HEADER);
+
+	/* Goal is to send at least one packet per ms,
+	 * not one big TSO packet every 100 ms.
+	 * This preserves ACK clocking and is consistent
+	 * with tcp_tso_should_defer() heuristic.
+	 */
+	segs = max_t(u32, bytes / mss_now, sysctl_tcp_min_tso_segs);
+
+	return min_t(u32, segs, sk->sk_gso_max_segs);
+}
+
 /* Returns the portion of skb which can be sent right away */
 static unsigned int tcp_mss_split_point(const struct sock *sk,
 					const struct sk_buff *skb,
@@ -1731,7 +1752,7 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
  * This algorithm is from John Heffner.
  */
 static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb,
-				 bool *is_cwnd_limited)
+				 bool *is_cwnd_limited, u32 max_segs)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -1761,8 +1782,7 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb,
 	limit = min(send_win, cong_win);
 
 	/* If a full-sized TSO skb can be sent, do it. */
-	if (limit >= min_t(unsigned int, sk->sk_gso_max_size,
-			   tp->xmit_size_goal_segs * tp->mss_cache))
+	if (limit >= max_segs * tp->mss_cache)
 		goto send_now;
 
 	/* Middle in queue won't get any more data, full sendable already? */
@@ -1959,6 +1979,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 	int cwnd_quota;
 	int result;
 	bool is_cwnd_limited = false;
+	u32 max_segs;
 
 	sent_pkts = 0;
 
@@ -1972,6 +1993,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		}
 	}
 
+	max_segs = tcp_tso_autosize(sk, mss_now);
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;
 
@@ -2004,10 +2026,23 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 				break;
 		} else {
 			if (!push_one &&
-			    tcp_tso_should_defer(sk, skb, &is_cwnd_limited))
+			    tcp_tso_should_defer(sk, skb, &is_cwnd_limited,
+						 max_segs))
 				break;
 		}
 
+		limit = mss_now;
+		if (tso_segs > 1 && !tcp_urg_mode(tp))
+			limit = tcp_mss_split_point(sk, skb, mss_now,
+						    min_t(unsigned int,
+							  cwnd_quota,
+							  max_segs),
+						    nonagle);
+
+		if (skb->len > limit &&
+		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
+			break;
+
 		/* TCP Small Queues :
 		 * Control number of packets in qdisc/devices to two packets / or ~1 ms.
 		 * This allows for :
@@ -2018,8 +2053,8 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		 * of queued bytes to ensure line rate.
 		 * One example is wifi aggregation (802.11 AMPDU)
 		 */
-		limit = max_t(unsigned int, sysctl_tcp_limit_output_bytes,
-			      sk->sk_pacing_rate >> 10);
+		limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 10);
+		limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);
 
 		if (atomic_read(&sk->sk_wmem_alloc) > limit) {
 			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
@@ -2032,18 +2067,6 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 				break;
 		}
 
-		limit = mss_now;
-		if (tso_segs > 1 && !tcp_urg_mode(tp))
-			limit = tcp_mss_split_point(sk, skb, mss_now,
-						    min_t(unsigned int,
-							  cwnd_quota,
-							  sk->sk_gso_max_segs),
-						    nonagle);
-
-		if (skb->len > limit &&
-		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
-			break;
-
 		if (unlikely(tcp_transmit_skb(sk, skb, 1, gfp)))
 			break;
 
