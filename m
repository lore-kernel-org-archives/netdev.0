From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCH 2/2] net-next-2.6: SYN retransmits: Add new parameter to
 retransmits_timed_out()
Date: Tue, 28 Sep 2010 21:46:20 +0200
Message-ID: <1285703180.7187.5.camel@nexus>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:46446 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756362Ab0I1TqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 15:46:22 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0L9H00IG02X9ADE0@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Tue, 28 Sep 2010 21:46:21 +0200 (CEST)
Received: from [192.168.0.131] ([unknown] [109.91.208.56])
 by relay-auth-1.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0L9H00FXJ2X9JN60@relay-auth-1.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Tue, 28 Sep 2010 21:46:21 +0200 (CEST)
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
 net/ipv4/tcp_timer.c |   26 +++++++++++++++-----------
 1 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 98cbc60..56a5aaf 100644
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
 				  unsigned int boundary,
-				  unsigned int timeout)
+				  unsigned int timeout,
+				  bool syn_set)
 {
 	unsigned int backoff_thresh, start_ts;
+	unsigned int rto_base = syn_set ? TCP_TIMEOUT_INIT : TCP_RTO_MIN;
 
 	if (!inet_csk(sk)->icsk_retransmits)
 		return false;
@@ -152,12 +155,12 @@ static bool retransmits_timed_out(struct sock *sk,
 		start_ts = tcp_sk(sk)->retrans_stamp;
 
 	if (likely(timeout == 0)) {
-		backoff_thresh = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
+		backoff_thresh = ilog2(TCP_RTO_MAX/rto_base);
 
 		if (boundary <= backoff_thresh)
-			timeout = ((2 << boundary) - 1) * TCP_RTO_MIN;
+			timeout = ((2 << boundary) - 1) * rto_base;
 		else
-			timeout = ((2 << backoff_thresh) - 1) * TCP_RTO_MIN +
+			timeout = ((2 << backoff_thresh) - 1) * rto_base +
 				  (boundary - backoff_thresh) * TCP_RTO_MAX;
 	}
 	return (tcp_time_stamp - start_ts) >= timeout;
@@ -168,14 +171,15 @@ static int tcp_write_timeout(struct sock *sk)
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
-		if (retransmits_timed_out(sk, sysctl_tcp_retries1, 0)) {
+		if (retransmits_timed_out(sk, sysctl_tcp_retries1, 0, 0)) {
 			/* Black hole detection */
 			tcp_mtu_probing(icsk, sk);
 
@@ -188,7 +192,8 @@ static int tcp_write_timeout(struct sock *sk)
 
 			retry_until = tcp_orphan_retries(sk, alive);
 			do_reset = alive ||
-				   !retransmits_timed_out(sk, retry_until, 0);
+				   !retransmits_timed_out(sk,
+							  retry_until, 0, 0);
 
 			if (tcp_out_of_resources(sk, do_reset))
 				return 1;
@@ -196,8 +201,7 @@ static int tcp_write_timeout(struct sock *sk)
 	}
 
 	if (retransmits_timed_out(sk, retry_until,
-	    (1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV) ? 0 :
-	    icsk->icsk_user_timeout)) {
+	    syn_set ? 0 : icsk->icsk_user_timeout, syn_set)) {
 		/* Has it gone just too far? */
 		tcp_write_err(sk);
 		return 1;
@@ -439,7 +443,7 @@ out_reset_timer:
 		icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
 	}
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
-	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1, 0))
+	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1, 0, 0))
 		__sk_dst_reset(sk);
 
 out:;
-- 
1.7.2.2




