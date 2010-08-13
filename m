From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 1/3] dccp ccid-2: Share TCP's minimum RTO code
Date: Fri, 13 Aug 2010 07:21:39 +0200
Message-ID: <1281676901-7018-2-git-send-email-gerrit@erg.abdn.ac.uk>
References: <ccid2_cwv_dccp_test_tree>
 <1281676901-7018-1-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:51722 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751640Ab0HMFeT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Aug 2010 01:34:19 -0400
In-Reply-To: <1281676901-7018-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Over the same link, DCCP and TCP face similar problems; and DCCP's
CCID-2 is in fact a restricted form of TCP.

Using the same RTO_MIN of 0.2 seconds was found to cause problems for CCID-2
over 802.11g: at least once per session there is a spurious timeout. It helped
to then increase the the value of RTO_MIN over this link.

Since the problem is the same as in TCP, this patch makes the solution from
commit "05bb1fad1cde025a864a90cfeb98dcbefe78a44a"
       "[TCP]: Allow minimum RTO to be configurable via routing metrics."
available to DCCP.

This avoids reinventing the wheel, so that e.g. the following works in the
expected way now also for DCCP:

> ip route change 10.0.0.2 rto_min 800 dev ath0

Luckily this useful rto_min function was recently moved to net/tcp.h,
which simplifies sharing code originating from TCP.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -267,8 +267,9 @@ static void ccid2_rtt_estimator(struct sock *sk, const long mrtt)
 		hc->tx_srtt = m << 3;
 		hc->tx_mdev = m << 1;
 
-		hc->tx_mdev_max = max(TCP_RTO_MIN, hc->tx_mdev);
+		hc->tx_mdev_max = max(hc->tx_mdev, tcp_rto_min(sk));
 		hc->tx_rttvar   = hc->tx_mdev_max;
+
 		hc->tx_rtt_seq  = dccp_sk(sk)->dccps_gss;
 	} else {
 		/* Update scaled SRTT as SRTT += 1/8 * (m - SRTT) */
@@ -309,7 +310,7 @@ static void ccid2_rtt_estimator(struct sock *sk, const long mrtt)
 				hc->tx_rttvar -= (hc->tx_rttvar -
 						  hc->tx_mdev_max) >> 2;
 			hc->tx_rtt_seq  = dccp_sk(sk)->dccps_gss;
-			hc->tx_mdev_max = TCP_RTO_MIN;
+			hc->tx_mdev_max = tcp_rto_min(sk);
 		}
 	}
 
