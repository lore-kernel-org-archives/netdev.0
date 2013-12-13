From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v3 net-next] tcp: refine TSO splits
Date: Fri, 13 Dec 2013 13:51:23 -0800
Message-ID: <1386971483.19078.188.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386876523.19078.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1386958426.19078.162.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Van Jacobson <vanj@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:50366 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407Ab3LMVv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 16:51:29 -0500
Received: by mail-yh0-f47.google.com with SMTP id 29so1994616yhl.6
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 13:51:26 -0800 (PST)
In-Reply-To: <1386958426.19078.162.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While investigating performance problems on small RPC workloads,
I noticed linux TCP stack was always splitting the last TSO skb
into two parts (skbs). One being a multiple of MSS, and a small one
with the Push flag. This split is done even if TCP_NODELAY is set,
or if no small packet is in flight.

Example with request/response of 4K/4K

IP A > B: . ack 68432 win 2783 <nop,nop,timestamp 6524593 6525001>
IP A > B: . 65537:68433(2896) ack 69632 win 2783 <nop,nop,timestamp 6524593 6525001>
IP A > B: P 68433:69633(1200) ack 69632 win 2783 <nop,nop,timestamp 6524593 6525001>
IP B > A: . ack 68433 win 2768 <nop,nop,timestamp 6525001 6524593>
IP B > A: . 69632:72528(2896) ack 69633 win 2768 <nop,nop,timestamp 6525001 6524593>
IP B > A: P 72528:73728(1200) ack 69633 win 2768 <nop,nop,timestamp 6525001 6524593>
IP A > B: . ack 72528 win 2783 <nop,nop,timestamp 6524593 6525001>
IP A > B: . 69633:72529(2896) ack 73728 win 2783 <nop,nop,timestamp 6524593 6525001>
IP A > B: P 72529:73729(1200) ack 73728 win 2783 <nop,nop,timestamp 6524593 6525001>

We can avoid this split by including the Nagle tests at the right place.

Note : If some NIC had trouble sending TSO packets with a partial
last segment, we would have hit the problem in GRO/forwarding workload already.

tcp_minshall_update() is moved to tcp_output.c and is updated as we might
feed a TSO packet with a partial last segment.

This patch tremendously improves performance, as the traffic now looks
like :

IP A > B: . ack 98304 win 2783 <nop,nop,timestamp 6834277 6834685>
IP A > B: P 94209:98305(4096) ack 98304 win 2783 <nop,nop,timestamp 6834277 6834685>
IP B > A: . ack 98305 win 2768 <nop,nop,timestamp 6834686 6834277>
IP B > A: P 98304:102400(4096) ack 98305 win 2768 <nop,nop,timestamp 6834686 6834277>
IP A > B: . ack 102400 win 2783 <nop,nop,timestamp 6834279 6834686>
IP A > B: P 98305:102401(4096) ack 102400 win 2783 <nop,nop,timestamp 6834279 6834686>
IP B > A: . ack 102401 win 2768 <nop,nop,timestamp 6834687 6834279>
IP B > A: P 102400:106496(4096) ack 102401 win 2768 <nop,nop,timestamp 6834687 6834279>
IP A > B: . ack 106496 win 2783 <nop,nop,timestamp 6834280 6834687>
IP A > B: P 102401:106497(4096) ack 106496 win 2783 <nop,nop,timestamp 6834280 6834687>
IP B > A: . ack 106497 win 2768 <nop,nop,timestamp 6834688 6834280>
IP B > A: P 106496:110592(4096) ack 106497 win 2768 <nop,nop,timestamp 6834688 6834280>


Before :

lpq83:~# nstat >/dev/null;perf stat ./super_netperf 200 -t TCP_RR -H lpq84 -l 20 -- -r 4K,4K
280774

 Performance counter stats for './super_netperf 200 -t TCP_RR -H lpq84 -l 20 -- -r 4K,4K':

     205719.049006 task-clock                #    9.278 CPUs utilized          
         8,449,968 context-switches          #    0.041 M/sec                  
         1,935,997 CPU-migrations            #    0.009 M/sec                  
           160,541 page-faults               #    0.780 K/sec                  
   548,478,722,290 cycles                    #    2.666 GHz                     [83.20%]
   455,240,670,857 stalled-cycles-frontend   #   83.00% frontend cycles idle    [83.48%]
   272,881,454,275 stalled-cycles-backend    #   49.75% backend  cycles idle    [66.73%]
   166,091,460,030 instructions              #    0.30  insns per cycle        
                                             #    2.74  stalled cycles per insn [83.39%]
    29,150,229,399 branches                  #  141.699 M/sec                   [83.30%]
     1,943,814,026 branch-misses             #    6.67% of all branches         [83.32%]

      22.173517844 seconds time elapsed

lpq83:~# nstat | egrep "IpOutRequests|IpExtOutOctets"
IpOutRequests                   16851063           0.0
IpExtOutOctets                  23878580777        0.0

After patch :

lpq83:~# nstat >/dev/null;perf stat ./super_netperf 200 -t TCP_RR -H lpq84 -l 20 -- -r 4K,4K
280877

 Performance counter stats for './super_netperf 200 -t TCP_RR -H lpq84 -l 20 -- -r 4K,4K':

     107496.071918 task-clock                #    4.847 CPUs utilized          
         5,635,458 context-switches          #    0.052 M/sec                  
         1,374,707 CPU-migrations            #    0.013 M/sec                  
           160,920 page-faults               #    0.001 M/sec                  
   281,500,010,924 cycles                    #    2.619 GHz                     [83.28%]
   228,865,069,307 stalled-cycles-frontend   #   81.30% frontend cycles idle    [83.38%]
   142,462,742,658 stalled-cycles-backend    #   50.61% backend  cycles idle    [66.81%]
    95,227,712,566 instructions              #    0.34  insns per cycle        
                                             #    2.40  stalled cycles per insn [83.43%]
    16,209,868,171 branches                  #  150.795 M/sec                   [83.20%]
       874,252,952 branch-misses             #    5.39% of all branches         [83.37%]

      22.175821286 seconds time elapsed

lpq83:~# nstat | egrep "IpOutRequests|IpExtOutOctets"
IpOutRequests                   11239428           0.0
IpExtOutOctets                  23595191035        0.0

Indeed, the occupancy of tx skbs (IpExtOutOctets/IpOutRequests) is higher :
2099 instead of 1417, thus helping GRO to be more efficient when using FQ packet
scheduler.

Many thanks to Neal for review and ideas.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
Cc: Van Jacobson <vanj@google.com>
---
v3: Add the Nagle tests to make sure we can send the whole skb
    according to Nagle rules. Factorize the code.

v2: changed tcp_minshall_update() as Neal pointed out.

 include/net/tcp.h     |    7 ----
 net/ipv4/tcp_output.c |   65 +++++++++++++++++++++++++---------------
 2 files changed, 42 insertions(+), 30 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index f7e1ab2139ef..9cd62bc09055 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -978,13 +978,6 @@ static inline u32 tcp_wnd_end(const struct tcp_sock *tp)
 }
 bool tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight);
 
-static inline void tcp_minshall_update(struct tcp_sock *tp, unsigned int mss,
-				       const struct sk_buff *skb)
-{
-	if (skb->len < mss)
-		tp->snd_sml = TCP_SKB_CB(skb)->end_seq;
-}
-
 static inline void tcp_check_probe_timer(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 2a69f42e51ca..9e7aec7ee67e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1384,23 +1384,51 @@ static void tcp_cwnd_validate(struct sock *sk)
 	}
 }
 
-/* Returns the portion of skb which can be sent right away without
- * introducing MSS oddities to segment boundaries. In rare cases where
- * mss_now != mss_cache, we will request caller to create a small skb
- * per input skb which could be mostly avoided here (if desired).
- *
- * We explicitly want to create a request for splitting write queue tail
- * to a small skb for Nagle purposes while avoiding unnecessary modulos,
- * thus all the complexity (cwnd_len is always MSS multiple which we
- * return whenever allowed by the other factors). Basically we need the
- * modulo only when the receiver window alone is the limiting factor or
- * when we would be allowed to send the split-due-to-Nagle skb fully.
+/* Minshall's variant of the Nagle send check. */
+static bool tcp_minshall_check(const struct tcp_sock *tp)
+{
+	return after(tp->snd_sml, tp->snd_una) &&
+		!after(tp->snd_sml, tp->snd_nxt);
+}
+
+/* Update snd_sml if this skb is under mss
+ * Note that a TSO packet might end with a sub-mss segment
+ * The test is really :
+ * if ((skb->len % mss) != 0)
+ *        tp->snd_sml = TCP_SKB_CB(skb)->end_seq;
+ * But we can avoid doing the divide again given we already have
+ *  skb_pcount = skb->len / mss_now
  */
-static unsigned int tcp_mss_split_point(const struct sock *sk, const struct sk_buff *skb,
-					unsigned int mss_now, unsigned int max_segs)
+static void tcp_minshall_update(struct tcp_sock *tp, unsigned int mss_now,
+				const struct sk_buff *skb)
+{
+	if (skb->len < tcp_skb_pcount(skb) * mss_now)
+		tp->snd_sml = TCP_SKB_CB(skb)->end_seq;
+}
+
+/* Return false, if packet can be sent now without violation Nagle's rules:
+ * 1. It is full sized. (provided by caller in %partial bool)
+ * 2. Or it contains FIN. (already checked by caller)
+ * 3. Or TCP_CORK is not set, and TCP_NODELAY is set.
+ * 4. Or TCP_CORK is not set, and all sent packets are ACKed.
+ *    With Minshall's modification: all sent small packets are ACKed.
+ */
+static bool tcp_nagle_check(bool partial, const struct tcp_sock *tp,
+			    unsigned int mss_now, int nonagle)
+{
+	return partial &&
+		((nonagle & TCP_NAGLE_CORK) ||
+		 (!nonagle && tp->packets_out && tcp_minshall_check(tp)));
+}
+/* Returns the portion of skb which can be sent right away */
+static unsigned int tcp_mss_split_point(const struct sock *sk,
+					const struct sk_buff *skb,
+					unsigned int mss_now,
+					unsigned int max_segs,
+					int nonagle)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
-	u32 needed, window, max_len;
+	u32 partial, needed, window, max_len;
 
 	window = tcp_wnd_end(tp) - TCP_SKB_CB(skb)->seq;
 	max_len = mss_now * max_segs;
@@ -1413,7 +1441,15 @@ static unsigned int tcp_mss_split_point(const struct sock *sk, const struct sk_b
 	if (max_len <= needed)
 		return max_len;
 
-	return needed - needed % mss_now;
+	partial = needed % mss_now;
+	/* If last segment is not a full MSS, check if Nagle rules allow us
+	 * to include this last segment in this skb.
+	 * Otherwise, we'll split the skb at last MSS boundary
+	 */
+	if (tcp_nagle_check(partial != 0, tp, mss_now, nonagle))
+		return needed - partial;
+
+	return needed;
 }
 
 /* Can at least one segment of SKB be sent right now, according to the
@@ -1453,28 +1489,6 @@ static int tcp_init_tso_segs(const struct sock *sk, struct sk_buff *skb,
 	return tso_segs;
 }
 
-/* Minshall's variant of the Nagle send check. */
-static inline bool tcp_minshall_check(const struct tcp_sock *tp)
-{
-	return after(tp->snd_sml, tp->snd_una) &&
-		!after(tp->snd_sml, tp->snd_nxt);
-}
-
-/* Return false, if packet can be sent now without violation Nagle's rules:
- * 1. It is full sized.
- * 2. Or it contains FIN. (already checked by caller)
- * 3. Or TCP_CORK is not set, and TCP_NODELAY is set.
- * 4. Or TCP_CORK is not set, and all sent packets are ACKed.
- *    With Minshall's modification: all sent small packets are ACKed.
- */
-static inline bool tcp_nagle_check(const struct tcp_sock *tp,
-				  const struct sk_buff *skb,
-				  unsigned int mss_now, int nonagle)
-{
-	return skb->len < mss_now &&
-		((nonagle & TCP_NAGLE_CORK) ||
-		 (!nonagle && tp->packets_out && tcp_minshall_check(tp)));
-}
 
 /* Return true if the Nagle test allows this packet to be
  * sent now.
@@ -1495,7 +1509,7 @@ static inline bool tcp_nagle_test(const struct tcp_sock *tp, const struct sk_buf
 	if (tcp_urg_mode(tp) || (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN))
 		return true;
 
-	if (!tcp_nagle_check(tp, skb, cur_mss, nonagle))
+	if (!tcp_nagle_check(skb->len < cur_mss, tp, cur_mss, nonagle))
 		return true;
 
 	return false;
@@ -1898,7 +1912,8 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 			limit = tcp_mss_split_point(sk, skb, mss_now,
 						    min_t(unsigned int,
 							  cwnd_quota,
-							  sk->sk_gso_max_segs));
+							  sk->sk_gso_max_segs),
+						    nonagle);
 
 		if (skb->len > limit &&
 		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
