From: "H.K. Jerry Chu" <hkchu@google.com>
Subject: [PATCH] RFC2988bis + taking RTT sample from 3WHS for the passive open side
Date: Wed,  8 Jun 2011 14:08:38 -0700
Message-ID: <1307567318-26760-1-git-send-email-hkchu@google.com>
Cc: tsunanet@gmail.com, netdev@vger.kernel.org,
	Jerry Chu <hkchu@google.com>
To: davem@davemloft.net, eric.dumazet@gmail.com, hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:33246 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751722Ab1FHVJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 17:09:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>

This patch lowers the default initRTO from 3secs to 1sec per
RFC2988bis. It falls back to 3secs if the SYN or SYN-ACK packet
has been retransmitted, AND the TCP timestamp option is not on.

It also adds support to take RTT sample during 3WHS on the passive
open side, just like its active open counterpart, and uses it, if
valid, to seed the initRTO for the data transmission phase.

The patch also resets ssthresh to its initial default at the
beginning of the data transmission phase, and reduces cwnd to 1 if
there has been MORE THAN ONE retransmission during 3WHS per RFC5681.

Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
---
 include/linux/tcp.h      |    1 +
 include/net/tcp.h        |   11 +++++++++--
 net/ipv4/syncookies.c    |    1 +
 net/ipv4/tcp_input.c     |   46 +++++++++++++++++++++++++---------------------
 net/ipv4/tcp_ipv4.c      |   11 ++++++++---
 net/ipv4/tcp_minisocks.c |    6 +++++-
 net/ipv6/syncookies.c    |    1 +
 net/ipv6/tcp_ipv6.c      |    5 +++++
 8 files changed, 55 insertions(+), 27 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index e64f4c6..531ede8 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -282,6 +282,7 @@ struct tcp_request_sock {
 #endif
 	u32				rcv_isn;
 	u32				snt_isn;
+	u32				snt_synack; /* synack sent time */
 };
 
 static inline struct tcp_request_sock *tcp_rsk(const struct request_sock *req)
diff --git a/include/net/tcp.h b/include/net/tcp.h
index cda30ea..149a415 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -122,7 +122,13 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #endif
 #define TCP_RTO_MAX	((unsigned)(120*HZ))
 #define TCP_RTO_MIN	((unsigned)(HZ/5))
-#define TCP_TIMEOUT_INIT ((unsigned)(3*HZ))	/* RFC 1122 initial RTO value	*/
+#define TCP_TIMEOUT_INIT ((unsigned)(1*HZ))	/* RFC2988bis initial RTO value	*/
+#define TCP_TIMEOUT_FALLBACK ((unsigned)(3*HZ))	/* RFC 1122 initial RTO value, now
+						 * used as a fallback RTO for the
+						 * initial data transmission if no
+						 * valid RTT sample has been acquired,
+						 * most likely due to retrans in 3WHS.
+						 */
 
 #define TCP_RESOURCE_PROBE_INTERVAL ((unsigned)(HZ/2U)) /* Maximal interval between probes
 					                 * for local resources.
@@ -295,7 +301,7 @@ static inline void tcp_synq_overflow(struct sock *sk)
 static inline int tcp_synq_no_recent_overflow(const struct sock *sk)
 {
 	unsigned long last_overflow = tcp_sk(sk)->rx_opt.ts_recent_stamp;
-	return time_after(jiffies, last_overflow + TCP_TIMEOUT_INIT);
+	return time_after(jiffies, last_overflow + TCP_TIMEOUT_FALLBACK);
 }
 
 extern struct proto tcp_prot;
@@ -508,6 +514,7 @@ extern void tcp_initialize_rcv_mss(struct sock *sk);
 extern int tcp_mtu_to_mss(struct sock *sk, int pmtu);
 extern int tcp_mss_to_mtu(struct sock *sk, int mss);
 extern void tcp_mtup_init(struct sock *sk);
+extern void tcp_valid_rtt_meas(struct sock *sk, u32 seq_rtt);
 
 static inline void tcp_bound_rto(const struct sock *sk)
 {
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 2646149..92bb943 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -316,6 +316,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	ireq->wscale_ok		= tcp_opt.wscale_ok;
 	ireq->tstamp_ok		= tcp_opt.saw_tstamp;
 	req->ts_recent		= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
+	treq->snt_synack	= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsecr : 0;
 
 	/* We throwed the options of the initial SYN away, so we hope
 	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bef9f04..ea0d218 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -880,6 +880,11 @@ static void tcp_init_metrics(struct sock *sk)
 		tp->snd_ssthresh = dst_metric(dst, RTAX_SSTHRESH);
 		if (tp->snd_ssthresh > tp->snd_cwnd_clamp)
 			tp->snd_ssthresh = tp->snd_cwnd_clamp;
+	} else {
+		/* ssthresh may have been reduced unnecessarily during.
+		 * 3WHS. Restore it back to its initial default.
+		 */
+		tp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
 	}
 	if (dst_metric(dst, RTAX_REORDERING) &&
 	    tp->reordering != dst_metric(dst, RTAX_REORDERING)) {
@@ -887,10 +892,7 @@ static void tcp_init_metrics(struct sock *sk)
 		tp->reordering = dst_metric(dst, RTAX_REORDERING);
 	}
 
-	if (dst_metric(dst, RTAX_RTT) == 0)
-		goto reset;
-
-	if (!tp->srtt && dst_metric_rtt(dst, RTAX_RTT) < (TCP_TIMEOUT_INIT << 3))
+	if (dst_metric(dst, RTAX_RTT) == 0 || tp->srtt == 0)
 		goto reset;
 
 	/* Initial rtt is determined from SYN,SYN-ACK.
@@ -916,19 +918,26 @@ static void tcp_init_metrics(struct sock *sk)
 		tp->mdev_max = tp->rttvar = max(tp->mdev, tcp_rto_min(sk));
 	}
 	tcp_set_rto(sk);
-	if (inet_csk(sk)->icsk_rto < TCP_TIMEOUT_INIT && !tp->rx_opt.saw_tstamp) {
 reset:
-		/* Play conservative. If timestamps are not
-		 * supported, TCP will fail to recalculate correct
-		 * rtt, if initial rto is too small. FORGET ALL AND RESET!
+	if (tp->srtt == 0) {
+		/* RFC2988bis: We've failed to get a valid RTT sample from
+		 * 3WHS. This is most likely due to retransmission,
+		 * including spurious one. Reset the RTO back to 3secs
+		 * from the more aggressive 1sec to avoid more spurious
+		 * retransmission.
 		 */
-		if (!tp->rx_opt.saw_tstamp && tp->srtt) {
-			tp->srtt = 0;
-			tp->mdev = tp->mdev_max = tp->rttvar = TCP_TIMEOUT_INIT;
-			inet_csk(sk)->icsk_rto = TCP_TIMEOUT_INIT;
-		}
+		tp->mdev = tp->mdev_max = tp->rttvar = TCP_TIMEOUT_FALLBACK;
+		inet_csk(sk)->icsk_rto = TCP_TIMEOUT_FALLBACK;
 	}
-	tp->snd_cwnd = tcp_init_cwnd(tp, dst);
+	/* Cut cwnd down to 1 per RFC5681 if SYN or SYN-ACK has been
+	 * retransmitted. In light of RFC2988bis' more aggressive 1sec
+	 * initRTO, we only reset cwnd when more than 1 SYN/SYN-ACK
+	 * retransmission has occurred.
+	 */
+	if (tp->total_retrans > 1)
+		tp->snd_cwnd = 1;
+	else
+		tp->snd_cwnd = tcp_init_cwnd(tp, dst);
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
@@ -3112,12 +3121,13 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	tcp_xmit_retransmit_queue(sk);
 }
 
-static void tcp_valid_rtt_meas(struct sock *sk, u32 seq_rtt)
+void tcp_valid_rtt_meas(struct sock *sk, u32 seq_rtt)
 {
 	tcp_rtt_estimator(sk, seq_rtt);
 	tcp_set_rto(sk);
 	inet_csk(sk)->icsk_backoff = 0;
 }
+EXPORT_SYMBOL(tcp_valid_rtt_meas);
 
 /* Read draft-ietf-tcplw-high-performance before mucking
  * with this code. (Supersedes RFC1323)
@@ -5806,12 +5816,6 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 					      tp->rx_opt.snd_wscale;
 				tcp_init_wl(tp, TCP_SKB_CB(skb)->seq);
 
-				/* tcp_ack considers this ACK as duplicate
-				 * and does not calculate rtt.
-				 * Force it here.
-				 */
-				tcp_ack_update_rtt(sk, 0, 0);
-
 				if (tp->rx_opt.tstamp_ok)
 					tp->advmss -= TCPOLEN_TSTAMP_ALIGNED;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3c8d9b6..5fb504b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -429,8 +429,8 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 			break;
 
 		icsk->icsk_backoff--;
-		inet_csk(sk)->icsk_rto = __tcp_set_rto(tp) <<
-					 icsk->icsk_backoff;
+		inet_csk(sk)->icsk_rto = (tp->srtt ? __tcp_set_rto(tp) :
+			TCP_TIMEOUT_INIT) << icsk->icsk_backoff;
 		tcp_bound_rto(sk);
 
 		skb = tcp_write_queue_head(sk);
@@ -1384,6 +1384,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		isn = tcp_v4_init_sequence(skb);
 	}
 	tcp_rsk(req)->snt_isn = isn;
+	tcp_rsk(req)->snt_synack = tcp_time_stamp;
 
 	if (tcp_v4_send_synack(sk, dst, req,
 			       (struct request_values *)&tmp_ext) ||
@@ -1458,6 +1459,10 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 		newtp->advmss = tcp_sk(sk)->rx_opt.user_mss;
 
 	tcp_initialize_rcv_mss(newsk);
+	if (tcp_rsk(req)->snt_synack)
+		tcp_valid_rtt_meas(newsk,
+		    tcp_time_stamp - tcp_rsk(req)->snt_synack);
+	newtp->total_retrans = req->retrans;
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Copy over the MD5 key from the original socket */
@@ -1854,7 +1859,7 @@ static int tcp_v4_init_sock(struct sock *sk)
 	 * algorithms that we must have the following bandaid to talk
 	 * efficiently to them.  -DaveM
 	 */
-	tp->snd_cwnd = 2;
+	tp->snd_cwnd = TCP_INIT_CWND;
 
 	/* See draft-stevens-tcpca-spec-01 for discussion of the
 	 * initialization of these values.
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 80b1f80..d2fe4e0 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -486,7 +486,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		 * algorithms that we must have the following bandaid to talk
 		 * efficiently to them.  -DaveM
 		 */
-		newtp->snd_cwnd = 2;
+		newtp->snd_cwnd = TCP_INIT_CWND;
 		newtp->snd_cwnd_cnt = 0;
 		newtp->bytes_acked = 0;
 
@@ -720,6 +720,10 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPDEFERACCEPTDROP);
 		return NULL;
 	}
+	if (tmp_opt.saw_tstamp && tmp_opt.rcv_tsecr)
+		tcp_rsk(req)->snt_synack = tmp_opt.rcv_tsecr;
+	else if (req->retrans) /* don't take RTT sample if retrans && ~TS */
+		tcp_rsk(req)->snt_synack = 0;
 
 	/* OK, ACK is valid, create big socket and
 	 * feed this segment to it. It will repeat all
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 8b9644a..89d5bf8 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -223,6 +223,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	ireq->wscale_ok		= tcp_opt.wscale_ok;
 	ireq->tstamp_ok		= tcp_opt.saw_tstamp;
 	req->ts_recent		= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
+	treq->snt_synack	= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsecr : 0;
 	treq->rcv_isn = ntohl(th->seq) - 1;
 	treq->snt_isn = cookie;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 8683664..e7d47e4 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1341,6 +1341,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	}
 have_isn:
 	tcp_rsk(req)->snt_isn = isn;
+	tcp_rsk(req)->snt_synack = tcp_time_stamp;
 
 	security_inet_conn_request(sk, skb, req);
 
@@ -1509,6 +1510,10 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	tcp_sync_mss(newsk, dst_mtu(dst));
 	newtp->advmss = dst_metric_advmss(dst);
 	tcp_initialize_rcv_mss(newsk);
+	if (tcp_rsk(req)->snt_synack)
+		tcp_valid_rtt_meas(newsk,
+		    tcp_time_stamp - tcp_rsk(req)->snt_synack);
+	newtp->total_retrans = req->retrans;
 
 	newinet->inet_daddr = newinet->inet_saddr = LOOPBACK4_IPV6;
 	newinet->inet_rcv_saddr = LOOPBACK4_IPV6;
-- 
1.7.3.1

