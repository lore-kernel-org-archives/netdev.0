From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCH 3/3] Revert Backoff [v3]: Calculate TCP's connection close
 threshold as a time value.
Date: Wed, 26 Aug 2009 12:16:34 +0200
Message-ID: <4A950B82.1070807@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:38333 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756815AbZHZKQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 06:16:33 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KOZ00GTVB7BUDA0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Wed, 26 Aug 2009 12:16:35 +0200 (CEST)
Received: from [137.226.143.131] (nexus.tvk.RWTH-Aachen.DE [137.226.143.131])
	by relay.rwth-aachen.de (8.13.8+Sun/8.13.8/1) with ESMTP id n7QAGYTu012987	for
 <netdev@vger.kernel.org>; Wed, 26 Aug 2009 12:16:35 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 1122 specifies two threshold values R1 and R2 for connection timeouts,
which may represent a number of allowed retransmissions or a timeout value.
Currently linux uses sysctl_tcp_retries{1,2} to specify the thresholds
in number of allowed retransmissions.

For any desired threshold R2 (by means of time) one can specify tcp_retries2
(by means of number of retransmissions) such that TCP will not time out
earlier than R2. This is the case, because the RTO schedule follows a fixed
pattern, namely exponential backoff.

However, the RTO behaviour is not predictable any more if RTO backoffs can be
reverted, as it is the case in the draft
"Make TCP more Robust to Long Connectivity Disruptions"
(http://tools.ietf.org/html/draft-zimmermann-tcp-lcd).

In the worst case TCP would time out a connection after 3.2 seconds, if the
initial RTO equaled MIN_RTO and each backoff has been reverted.

This patch introduces a function retransmits_timed_out(N),
which calculates the timeout of a TCP connection, assuming an initial
RTO of MIN_RTO and N unsuccessful, exponentially backed-off retransmissions.

Whenever timeout decisions are made by comparing the retransmission counter
to some value N, this function can be used, instead.

The meaning of tcp_retries2 will be changed, as many more RTO retransmissions
can occur than the value indicates. However, it yields a timeout which is
similar to the one of an unpatched, exponentially backing off TCP in the same
scenario. As no application could rely on an RTO greater than MIN_RTO, there
should be no risk of a regression.

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
 include/net/tcp.h    |   18 ++++++++++++++++++
 net/ipv4/tcp_timer.c |   11 +++++++----
 2 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index c35b329..17d1a88 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1247,6 +1247,24 @@ static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, struct sk_bu
 #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
 	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
 
+static inline bool retransmits_timed_out(const struct sock *sk,
+					 unsigned int boundary)
+{
+	int limit, K;
+	if (!inet_csk(sk)->icsk_retransmits)
+		return false;
+
+	K = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
+
+	if (boundary <= K)
+		limit = ((2 << boundary) - 1) * TCP_RTO_MIN;
+	else
+		limit = ((2 << K) - 1) * TCP_RTO_MIN +
+			(boundary - K) * TCP_RTO_MAX;
+
+	return (tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >= limit;
+}
+
 static inline struct sk_buff *tcp_send_head(struct sock *sk)
 {
 	return sk->sk_send_head;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index a3ba494..2972d7b 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -137,13 +137,14 @@ static int tcp_write_timeout(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	int retry_until;
+	bool do_reset;
 
 	if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
 		if (icsk->icsk_retransmits)
 			dst_negative_advice(&sk->sk_dst_cache);
 		retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
 	} else {
-		if (icsk->icsk_retransmits >= sysctl_tcp_retries1) {
+		if (retransmits_timed_out(sk, sysctl_tcp_retries1)) {
 			/* Black hole detection */
 			tcp_mtu_probing(icsk, sk);
 
@@ -155,13 +156,15 @@ static int tcp_write_timeout(struct sock *sk)
 			const int alive = (icsk->icsk_rto < TCP_RTO_MAX);
 
 			retry_until = tcp_orphan_retries(sk, alive);
+			do_reset = alive ||
+				   !retransmits_timed_out(sk, retry_until);
 
-			if (tcp_out_of_resources(sk, alive || icsk->icsk_retransmits < retry_until))
+			if (tcp_out_of_resources(sk, do_reset))
 				return 1;
 		}
 	}
 
-	if (icsk->icsk_retransmits >= retry_until) {
+	if (retransmits_timed_out(sk, retry_until)) {
 		/* Has it gone just too far? */
 		tcp_write_err(sk);
 		return 1;
@@ -385,7 +388,7 @@ void tcp_retransmit_timer(struct sock *sk)
 out_reset_timer:
 	icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
-	if (icsk->icsk_retransmits > sysctl_tcp_retries1)
+	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1))
 		__sk_dst_reset(sk);
 
 out:;
-- 
1.6.3.3

