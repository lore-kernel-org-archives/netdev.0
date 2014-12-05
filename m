From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: refine TSO autosizing
Date: Fri, 05 Dec 2014 06:15:37 -0800
Message-ID: <1417788937.4322.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:39226 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbaLEOPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 09:15:40 -0500
Received: by mail-ie0-f173.google.com with SMTP id y20so743180ier.18
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 06:15:39 -0800 (PST)
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
---
 net/ipv4/tcp.c        |   14 ++------------
 net/ipv4/tcp_output.c |   38 ++++++++++++++++++++++++--------------
 2 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index dc13a3657e8e..91e6c1406313 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -840,24 +840,14 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
 	xmit_size_goal = mss_now;
 
 	if (large_allowed && sk_can_gso(sk)) {
-		u32 gso_size, hlen;
+		u32 hlen;
 
 		/* Maybe we should/could use sk->sk_prot->max_header here ? */
 		hlen = inet_csk(sk)->icsk_af_ops->net_header_len +
 		       inet_csk(sk)->icsk_ext_hdr_len +
 		       tp->tcp_header_len;
 
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
+		xmit_size_goal = sk->sk_gso_max_size - 1 - hlen;
 
 		xmit_size_goal = tcp_bound_to_half_wnd(tp, xmit_size_goal);
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f5bd4bd3f7e6..dac9991bccbf 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1533,6 +1533,16 @@ static unsigned int tcp_mss_split_point(const struct sock *sk,
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	u32 partial, needed, window, max_len;
+	u32 bytes = sk->sk_pacing_rate >> 10;
+	u32 segs;
+
+	/* Goal is to send at least one packet per ms,
+	 * not one big TSO packet every 100 ms.
+	 * This preserves ACK clocking and is consistent
+	 * with tcp_tso_should_defer() heuristic.
+	 */
+	segs = max_t(u32, bytes / mss_now, sysctl_tcp_min_tso_segs);
+	max_segs = min_t(u32, max_segs, segs);
 
 	window = tcp_wnd_end(tp) - TCP_SKB_CB(skb)->seq;
 	max_len = mss_now * max_segs;
@@ -2008,6 +2018,18 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 				break;
 		}
 
+		limit = mss_now;
+		if (tso_segs > 1 && !tcp_urg_mode(tp))
+			limit = tcp_mss_split_point(sk, skb, mss_now,
+						    min_t(unsigned int,
+							  cwnd_quota,
+							  sk->sk_gso_max_segs),
+						    nonagle);
+
+		if (skb->len > limit &&
+		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
+			break;
+
 		/* TCP Small Queues :
 		 * Control number of packets in qdisc/devices to two packets / or ~1 ms.
 		 * This allows for :
@@ -2018,8 +2040,8 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		 * of queued bytes to ensure line rate.
 		 * One example is wifi aggregation (802.11 AMPDU)
 		 */
-		limit = max_t(unsigned int, sysctl_tcp_limit_output_bytes,
-			      sk->sk_pacing_rate >> 10);
+		limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 10);
+		limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);
 
 		if (atomic_read(&sk->sk_wmem_alloc) > limit) {
 			set_bit(TSQ_THROTTLED, &tp->tsq_flags);
@@ -2032,18 +2054,6 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
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
 
