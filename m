From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 1/7] dccp ccid-3: Bug-Fix - Zero RTT is possible
Date: Tue, 10 Jun 2008 13:53:37 +0100
Message-ID: <1213102423-27486-2-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_bug_fixes_for_net-2.6>
 <1213102423-27486-1-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:37419 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753793AbYFJMx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 08:53:57 -0400
In-Reply-To: <1213102423-27486-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 825de27d9e40b3117b29a79d412b7a4b78c5d815 fixed the CCID-3 window counter
computation for RTTs < 4 microseconds (as happens on loopback).

Since it uses the term "1/RTT", it needs to be protected against divide-by-zero,
done in established state using dccp_sample_rtt().

But there was an oversight, as a zero RTT can happen on sender initialisation
when there is no RTT sample from the Request/Response exchange.

The fix is to use the fallback-RTT from RFC 4340, 3.4.

This is also better than just fixing update_win_count() since it allows other
parts of the code to always assume that a (fallback) RTT value is available.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -329,8 +329,14 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
 			hctx->ccid3hctx_t_ld = now;
 		} else {
-			/* Sender does not have RTT sample: X_pps = 1 pkt/sec */
-			hctx->ccid3hctx_x = hctx->ccid3hctx_s;
+			/*
+			 * Sender does not have RTT sample:
+			 * - set fallback RTT (RFC 4340, 3.4) since a RTT value
+			 *   is needed in several parts (e.g.  window counter);
+			 * - set sending rate X_pps = 1pps as per RFC 3448, 4.2.
+			 */
+			hctx->ccid3hctx_rtt = DCCP_FALLBACK_RTT;
+			hctx->ccid3hctx_x   = hctx->ccid3hctx_s;
 			hctx->ccid3hctx_x <<= 6;
 		}
 		ccid3_update_send_interval(hctx);
