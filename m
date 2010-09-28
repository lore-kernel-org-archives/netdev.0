From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCH] net-2.6: SYN retransmits: Add new parameter to
 retransmits_timed_out()
Date: Tue, 28 Sep 2010 21:44:54 +0200
Message-ID: <1285703094.7187.3.camel@nexus>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:45509 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753955Ab0I1Toz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 15:44:55 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0L9H004TM2UUU610@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Tue, 28 Sep 2010 21:44:54 +0200 (CEST)
Received: from [192.168.0.131] ([unknown] [109.91.208.56])
 by relay-auth-1.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0L9H00FWW2UUJN60@relay-auth-1.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Tue, 28 Sep 2010 21:44:54 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch adds a syn_set parameter to the retransmits_timed_out()
routine and updates its callers. If not set, TCP_RTO_MIN is taken
as the calculation basis as before. If set, TCP_TIMEOUT_INIT is
used instead, so that sysctl_syn_retries represents the actual
amount of SYN retransmissions in case no SYNACKs are received when
establishing a new connection.

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
 net/ipv4/tcp_timer.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index c35b469..74c54b3 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -135,13 +135,16 @@ static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
 
 /* This function calculates a "timeout" which is equivalent to the timeout of a
  * TCP connection after "boundary" unsuccessful, exponentially backed-off
- * retransmissions with an initial RTO of TCP_RTO_MIN.
+ * retransmissions with an initial RTO of TCP_RTO_MIN or TCP_TIMEOUT_INIT if
+ * syn_set flag is set.
  */
 static bool retransmits_timed_out(struct sock *sk,
-				  unsigned int boundary)
+				  unsigned int boundary,
+				  bool syn_set)
 {
 	unsigned int timeout, linear_backoff_thresh;
 	unsigned int start_ts;
+	unsigned int rto_base = syn_set ? TCP_TIMEOUT_INIT : TCP_RTO_MIN;
 
 	if (!inet_csk(sk)->icsk_retransmits)
 		return false;
@@ -151,12 +154,12 @@ static bool retransmits_timed_out(struct sock *sk,
 	else
 		start_ts = tcp_sk(sk)->retrans_stamp;
 
-	linear_backoff_thresh = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
+	linear_backoff_thresh = ilog2(TCP_RTO_MAX/rto_base);
 
 	if (boundary <= linear_backoff_thresh)
-		timeout = ((2 << boundary) - 1) * TCP_RTO_MIN;
+		timeout = ((2 << boundary) - 1) * rto_base;
 	else
-		timeout = ((2 << linear_backoff_thresh) - 1) * TCP_RTO_MIN +
+		timeout = ((2 << linear_backoff_thresh) - 1) * rto_base +
 			  (boundary - linear_backoff_thresh) * TCP_RTO_MAX;
 
 	return (tcp_time_stamp - start_ts) >= timeout;
@@ -167,14 +170,15 @@ static int tcp_write_timeout(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	int retry_until;
-	bool do_reset;
+	bool do_reset, syn_set = 0;
 
 	if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
 		if (icsk->icsk_retransmits)
 			dst_negative_advice(sk);
 		retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
+		syn_set = 1;
 	} else {
-		if (retransmits_timed_out(sk, sysctl_tcp_retries1)) {
+		if (retransmits_timed_out(sk, sysctl_tcp_retries1, 0)) {
 			/* Black hole detection */
 			tcp_mtu_probing(icsk, sk);
 
@@ -187,14 +191,14 @@ static int tcp_write_timeout(struct sock *sk)
 
 			retry_until = tcp_orphan_retries(sk, alive);
 			do_reset = alive ||
-				   !retransmits_timed_out(sk, retry_until);
+				   !retransmits_timed_out(sk, retry_until, 0);
 
 			if (tcp_out_of_resources(sk, do_reset))
 				return 1;
 		}
 	}
 
-	if (retransmits_timed_out(sk, retry_until)) {
+	if (retransmits_timed_out(sk, retry_until, syn_set)) {
 		/* Has it gone just too far? */
 		tcp_write_err(sk);
 		return 1;
@@ -436,7 +440,7 @@ out_reset_timer:
 		icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
 	}
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
-	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1))
+	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1, 0))
 		__sk_dst_reset(sk);
 
 out:;
-- 
1.7.2.2



