From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCH 2/3] Revert Backoff [v3]: Revert RTO on ICMP destination
 unreachable
Date: Wed, 26 Aug 2009 12:16:31 +0200
Message-ID: <4A950B7F.6000702@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:38293 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756807AbZHZKQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 06:16:30 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KOZ00GTVB7BUDA0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Wed, 26 Aug 2009 12:16:31 +0200 (CEST)
Received: from [137.226.143.131] (nexus.tvk.RWTH-Aachen.DE [137.226.143.131])
	by relay.rwth-aachen.de (8.13.8+Sun/8.13.8/1) with ESMTP id n7QAGVNt012917	for
 <netdev@vger.kernel.org>; Wed, 26 Aug 2009 12:16:31 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here, an ICMP host/network unreachable message, whose payload fits to
TCP's SND.UNA, is taken as an indication that the RTO retransmission has
not been lost due to congestion, but because of a route failure
somewhere along the path.
With true congestion, a router won't trigger such a message and the
patched TCP will operate as standard TCP.

This patch reverts one RTO backoff, if an ICMP host/network unreachable
message, whose payload fits to TCP's SND.UNA, arrives.
Based on the new RTO, the retransmission timer is reset to reflect the
remaining time, or - if the revert clocked out the timer - a retransmission
is sent out immediately.
Backoffs are only reverted, if TCP is in RTO loss recovery, i.e. if
there have been retransmissions and reversible backoffs, already.

Changes from v2:
1) Renaming of skb in tcp_v4_err() moved to another patch.
2) Reintroduced tcp_bound_rto() and __tcp_set_rto().
3) Fixed code comments.

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
 include/net/tcp.h    |   12 ++++++++++++
 net/ipv4/tcp_input.c |    5 ++---
 net/ipv4/tcp_ipv4.c  |   37 +++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_timer.c |    2 +-
 4 files changed, 52 insertions(+), 4 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 88af843..c35b329 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -469,6 +469,7 @@ extern void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
 				      int nonagle);
 extern int tcp_may_send_now(struct sock *sk);
 extern int tcp_retransmit_skb(struct sock *, struct sk_buff *);
+extern void tcp_retransmit_timer(struct sock *sk);
 extern void tcp_xmit_retransmit_queue(struct sock *);
 extern void tcp_simple_retransmit(struct sock *);
 extern int tcp_trim_head(struct sock *, struct sk_buff *, u32);
@@ -521,6 +522,17 @@ extern int tcp_mtu_to_mss(struct sock *sk, int pmtu);
 extern int tcp_mss_to_mtu(struct sock *sk, int mss);
 extern void tcp_mtup_init(struct sock *sk);
 
+static inline void tcp_bound_rto(const struct sock *sk)
+{
+	if (inet_csk(sk)->icsk_rto > TCP_RTO_MAX)
+		inet_csk(sk)->icsk_rto = TCP_RTO_MAX;
+}
+
+static inline u32 __tcp_set_rto(const struct tcp_sock *tp)
+{
+	return (tp->srtt >> 3) + tp->rttvar;
+}
+
 static inline void __tcp_fast_path_on(struct tcp_sock *tp, u32 snd_wnd)
 {
 	tp->pred_flags = htonl((tp->tcp_header_len << 26) |
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2bdb0da..af6d6fa 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -685,7 +685,7 @@ static inline void tcp_set_rto(struct sock *sk)
 	 *    is invisible. Actually, Linux-2.4 also generates erratic
 	 *    ACKs in some circumstances.
 	 */
-	inet_csk(sk)->icsk_rto = (tp->srtt >> 3) + tp->rttvar;
+	inet_csk(sk)->icsk_rto = __tcp_set_rto(tp);
 
 	/* 2. Fixups made earlier cannot be right.
 	 *    If we do not estimate RTO correctly without them,
@@ -696,8 +696,7 @@ static inline void tcp_set_rto(struct sock *sk)
 	/* NOTE: clamping at TCP_RTO_MIN is not required, current algo
 	 * guarantees that rto is higher.
 	 */
-	if (inet_csk(sk)->icsk_rto > TCP_RTO_MAX)
-		inet_csk(sk)->icsk_rto = TCP_RTO_MAX;
+	tcp_bound_rto(sk);
 }
 
 /* Save metrics learned by this TCP session.
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 6ca1bc8..6755e29 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -332,12 +332,15 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 {
 	struct iphdr *iph = (struct iphdr *)icmp_skb->data;
 	struct tcphdr *th = (struct tcphdr *)(icmp_skb->data + (iph->ihl << 2));
+	struct inet_connection_sock *icsk;
 	struct tcp_sock *tp;
 	struct inet_sock *inet;
 	const int type = icmp_hdr(icmp_skb)->type;
 	const int code = icmp_hdr(icmp_skb)->code;
 	struct sock *sk;
+	struct sk_buff *skb;
 	__u32 seq;
+	__u32 remaining;
 	int err;
 	struct net *net = dev_net(icmp_skb->dev);
 
@@ -367,6 +370,7 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 	if (sk->sk_state == TCP_CLOSE)
 		goto out;
 
+	icsk = inet_csk(sk);
 	tp = tcp_sk(sk);
 	seq = ntohl(th->seq);
 	if (sk->sk_state != TCP_LISTEN &&
@@ -393,6 +397,39 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		}
 
 		err = icmp_err_convert[code].errno;
+		/* check if icmp_skb allows revert of backoff
+		 * (see draft-zimmermann-tcp-lcd) */
+		if (code != ICMP_NET_UNREACH && code != ICMP_HOST_UNREACH)
+			break;
+		if (seq != tp->snd_una  || !icsk->icsk_retransmits ||
+		    !icsk->icsk_backoff)
+			break;
+
+		icsk->icsk_backoff--;
+		inet_csk(sk)->icsk_rto = __tcp_set_rto(tp) <<
+					 icsk->icsk_backoff;
+		tcp_bound_rto(sk);
+
+		skb = tcp_write_queue_head(sk);
+		BUG_ON(!skb);
+
+		remaining = icsk->icsk_rto - min(icsk->icsk_rto,
+				tcp_time_stamp - TCP_SKB_CB(skb)->when);
+
+		if (remaining) {
+			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
+						  remaining, TCP_RTO_MAX);
+		} else if (sock_owned_by_user(sk)) {
+			/* RTO revert clocked out retransmission,
+			 * but socket is locked. Will defer. */
+			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
+						  HZ/20, TCP_RTO_MAX);
+		} else {
+			/* RTO revert clocked out retransmission.
+			 * Will retransmit now */
+			tcp_retransmit_timer(sk);
+		}
+
 		break;
 	case ICMP_TIME_EXCEEDED:
 		err = EHOSTUNREACH;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index b144a26..a3ba494 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -279,7 +279,7 @@ static void tcp_probe_timer(struct sock *sk)
  *	The TCP retransmit timer.
  */
 
-static void tcp_retransmit_timer(struct sock *sk)
+void tcp_retransmit_timer(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
-- 
1.6.3.3

