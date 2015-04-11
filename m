From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: [PATCH net-next] tcp: fix bogus RTT for CC when retransmissions are acked
Date: Sat, 11 Apr 2015 02:17:49 +0200
Message-ID: <1428711469-5328-1-git-send-email-kennetkl@ifi.uio.no>
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out4.uio.no ([129.240.10.15]:58500 "EHLO mail-out4.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752959AbbDKAhc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 20:37:32 -0400
Received: from mail-mx1.uio.no ([129.240.10.29])
	by mail-out4.uio.no with esmtp (Exim 4.80.1)
	(envelope-from <kennetkl@ifi.uio.no>)
	id 1Ygj7t-0004O8-9t
	for netdev@vger.kernel.org; Sat, 11 Apr 2015 02:18:21 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since retransmitted segments are not used for RTT estimation, previously
SACKed segments present in the rtx queue are used. This estimation can be
several times larger than the actual RTT. When a cumulative ack covers both
previously SACKed and retransmitted segments, CC may thus get a bogus RTT.

Such segments previously had an RTT estimation in tcp_sacktag_one(), so it
seems reasonable to not reuse them in tcp_clean_rtx_queue() at all.

Afaik, this has had no effect on SRTT/RTO because of Karn's check.

Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
---
 net/ipv4/tcp_input.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 031cf72..a7ef679 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3099,17 +3099,15 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 			if (sacked & TCPCB_SACKED_RETRANS)
 				tp->retrans_out -= acked_pcount;
 			flag |= FLAG_RETRANS_DATA_ACKED;
-		} else {
+		} else if (!(sacked & TCPCB_SACKED_ACKED)) {
 			last_ackt = skb->skb_mstamp;
 			WARN_ON_ONCE(last_ackt.v64 == 0);
 			if (!first_ackt.v64)
 				first_ackt = last_ackt;
 
-			if (!(sacked & TCPCB_SACKED_ACKED)) {
-				reord = min(pkts_acked, reord);
-				if (!after(scb->end_seq, tp->high_seq))
-					flag |= FLAG_ORIG_SACK_ACKED;
-			}
+			reord = min(pkts_acked, reord);
+			if (!after(scb->end_seq, tp->high_seq))
+				flag |= FLAG_ORIG_SACK_ACKED;
 		}
 
 		if (sacked & TCPCB_SACKED_ACKED)
-- 
2.1.0
