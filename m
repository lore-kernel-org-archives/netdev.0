From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 3/7] dccp tfrc: Suppress unavoidable "below resolution" warning
Date: Mon, 28 Jul 2008 19:13:59 +0100
Message-ID: <1217268843-19667-4-git-send-email-gerrit@erg.abdn.ac.uk>
References: <ccid3_updates_ecn_and_rfc3448bis>
 <1217268843-19667-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1217268843-19667-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1217268843-19667-3-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:58295 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752594AbYG1SOT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2008 14:14:19 -0400
In-Reply-To: <1217268843-19667-3-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the congestion-avoidance phase a decay of p towards 0 is natural once fewer
losses are encountered. Hence the warning message "p is below resolution" is
not necessary, and thus turned into a debug message by this patch.

The TFRC_SMALLEST_P is needed since in theory p never actually reaches 0. When
no further losses are encountered, the loss interval I_0 grows in length,
causing p to decrease towards 0, causing X_calc = s/(RTT * f(p)) to increase.

With the given minimum-resolution this congestion avoidance phase stops at some
fixed value, an approximation formula has been added to the documentation.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/tfrc_equation.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

--- a/net/dccp/ccids/lib/tfrc_equation.c
+++ b/net/dccp/ccids/lib/tfrc_equation.c
@@ -632,8 +632,16 @@ u32 tfrc_calc_x(u16 s, u32 R, u32 p)
 
 	if (p <= TFRC_CALC_X_SPLIT) 		{     /* 0.0000 < p <= 0.05   */
 		if (p < TFRC_SMALLEST_P) {	      /* 0.0000 < p <  0.0001 */
-			DCCP_WARN("Value of p (%d) below resolution. "
-				  "Substituting %d\n", p, TFRC_SMALLEST_P);
+			/*
+			 * In the congestion-avoidance phase p decays towards 0
+			 * when there are no further losses, so this case is
+			 * natural. Truncating to p_min = 0.01% means that the
+			 * maximum achievable throughput is limited to about
+			 * X_calc_max = 122.4 * s/RTT (see RFC 3448, 3.1); e.g.
+			 * with s=1500 bytes, RTT=0.01 s: X_calc_max = 147 Mbps.
+			 */
+			tfrc_pr_debug("Value of p (%d) below resolution. "
+				      "Substituting %d\n", p, TFRC_SMALLEST_P);
 			index = 0;
 		} else 				      /* 0.0001 <= p <= 0.05  */
 			index =  p/TFRC_SMALLEST_P - 1;
