From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] TCP: H-TCP maxRTT estimation at startup
Date: Fri, 3 Aug 2007 10:57:56 +0100
Message-ID: <20070803105756.2f41dc25@oldman.hamilton.local>
References: <CA61FA76-2C22-4048-B7AC-1D8E9D94868C@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Douglas Leith <doug.leith@nuim.ie>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35345 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757700AbXHCJ5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 05:57:34 -0400
In-Reply-To: <CA61FA76-2C22-4048-B7AC-1D8E9D94868C@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Small patch to H-TCP from Douglas Leith. 

Fix estimation of maxRTT.  The original code ignores rtt measurements
during slow start (via the check tp->snd_ssthresh < 0xFFFF) yet this
is probably a good time to try to estimate max rtt as delayed acking
is disabled and slow start will only exit on a loss which presumably
corresponds to a maxrtt measurement.  Second, the original code (via
the check htcp_ccount(ca) > 3) ignores rtt data during what it
estimates to be the first 3 round-trip times.  This seems like an
unnecessary check now that the RCV timestamp are no longer used
for rtt estimation.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/ipv4/tcp_htcp.c	2007-08-03 10:51:51.000000000 +0100
+++ b/net/ipv4/tcp_htcp.c	2007-08-03 10:51:53.000000000 +0100
@@ -79,7 +79,6 @@ static u32 htcp_cwnd_undo(struct sock *s
 static inline void measure_rtt(struct sock *sk, u32 srtt)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
-	const struct tcp_sock *tp = tcp_sk(sk);
 	struct htcp *ca = inet_csk_ca(sk);
 
 	/* keep track of minimum RTT seen so far, minRTT is zero at first */
@@ -87,8 +86,7 @@ static inline void measure_rtt(struct so
 		ca->minRTT = srtt;
 
 	/* max RTT */
-	if (icsk->icsk_ca_state == TCP_CA_Open
-	    && tp->snd_ssthresh < 0xFFFF && htcp_ccount(ca) > 3) {
+	if (icsk->icsk_ca_state == TCP_CA_Open) {
 		if (ca->maxRTT < ca->minRTT)
 			ca->maxRTT = ca->minRTT;
 		if (ca->maxRTT < srtt
