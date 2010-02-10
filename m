From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCH][v3] tcp: fix ICMP-RTO war
Date: Wed, 10 Feb 2010 13:49:08 +0100
Message-ID: <4B72AB44.3050402@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>,
	=?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:32768 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750933Ab0BJMtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 07:49:09 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KXM00KNTM9WW400@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Wed, 10 Feb 2010 13:49:08 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure, that TCP has a nonzero RTT estimation after three-way
handshake. Currently, a listening TCP has a value of 0 for srtt,
rttvar and rto right after the three-way handshake is completed
with TCP timestamps disabled.
This will lead to corrupt RTO recalculation and retransmission
flood when RTO is recalculated on backoff reversion as introduced
in "Revert RTO on ICMP destination unreachable"
(f1ecd5d9e7366609d640ff4040304ea197fbc618).
This behaviour can be provoked by connecting to a server which
"responds first" (like SMTP) and rejecting every packet after
the handshake with dest-unreachable, which will lead to softirq
load on the server (up to 30% per socket in some tests).

Thanks to Ilpo Jarvinen for providing debug patches and to
Denys Fedoryshchenko for reporting and testing.

Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
---
 net/ipv4/tcp_input.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 28e0296..da7173b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5783,12 +5783,10 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 
 				/* tcp_ack considers this ACK as duplicate
 				 * and does not calculate rtt.
-				 * Fix it at least with timestamps.
+				 * Force it here.
 				 */
-				if (tp->rx_opt.saw_tstamp &&
-				    tp->rx_opt.rcv_tsecr && !tp->srtt)
-					tcp_ack_saw_tstamp(sk, 0);
-
+				tcp_ack_update_rtt(sk, 0, 0);
+				
 				if (tp->rx_opt.tstamp_ok)
 					tp->advmss -= TCPOLEN_TSTAMP_ALIGNED;
 
-- 
1.6.4.4

