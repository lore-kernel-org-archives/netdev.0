From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC 3/3] TCP: htcp - use measured rtt
Date: Thu, 19 Jul 2007 08:41:32 +0100
Message-ID: <20070719074906.806729566@linux-foundation.org>
References: <20070719074129.670215301@linux-foundation.org>
Cc: Sangtae Ha <sha2@ncsu.edu>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42162 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763549AbXGSIYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 04:24:34 -0400
Cc: Luca De Cicco <ldecicco@gmail.com>
Cc: Gavin McCullagh <gavin.mccullagh@nuim.ie>
Cc: netdev@vger.kernel.org
Content-Disposition: inline; filename=htcp-fix.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change HTCP to use measured RTT rather than smooth RTT.
Srtt is computed using the TCP receive timestamp
options, so it is vulnerable to hostile receivers. To avoid any problems
this might cause use the measured RTT instead.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/ipv4/tcp_htcp.c	2007-07-19 08:26:40.000000000 +0100
+++ b/net/ipv4/tcp_htcp.c	2007-07-19 08:28:07.000000000 +0100
@@ -76,12 +76,11 @@ static u32 htcp_cwnd_undo(struct sock *s
 	return max(tp->snd_cwnd, (tp->snd_ssthresh << 7) / ca->beta);
 }
 
-static inline void measure_rtt(struct sock *sk)
+static inline void measure_rtt(struct sock *sk, u32 srtt)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct htcp *ca = inet_csk_ca(sk);
-	u32 srtt = tp->srtt >> 3;
 
 	/* keep track of minimum RTT seen so far, minRTT is zero at first */
 	if (ca->minRTT > srtt || !ca->minRTT)
@@ -108,6 +107,9 @@ static void measure_achieved_throughput(
 	if (icsk->icsk_ca_state == TCP_CA_Open)
 		ca->pkts_acked = pkts_acked;
 
+	if (rtt > 0)
+		measure_rtt(sk, usecs_to_jiffies(rtt));
+
 	if (!use_bandwidth_switch)
 		return;
 
@@ -237,8 +239,6 @@ static void htcp_cong_avoid(struct sock 
 	if (tp->snd_cwnd <= tp->snd_ssthresh)
 		tcp_slow_start(tp);
 	else {
-		measure_rtt(sk);
-
 		/* In dangerous area, increase slowly.
 		 * In theory this is tp->snd_cwnd += alpha / tp->snd_cwnd
 		 */

-- 

