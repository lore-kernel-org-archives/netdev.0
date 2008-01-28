From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 1/6] [CCID3]: Function returned wrong value
Date: Mon, 28 Jan 2008 10:16:11 +0000
Message-ID: <1201515376-8280-2-git-send-email-gerrit@erg.abdn.ac.uk>
References: dccp_ccid3_dccp_probe__bug_fixes
 <1201515376-8280-1-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:60470 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754211AbYA1KSA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2008 05:18:00 -0500
In-Reply-To: <1201515376-8280-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a bug in the reverse lookup of p, given a value f(p) (used in the
reverse-lookup of the first/synthetic loss interval in RFC 3448, 6.3.1):
instead of p, the function returned the smallest table value f(p).

The smallest tabulated value of

   10^6 * f(p) =  sqrt(2*p/3) + 12 * sqrt(3*p/8) * (32 * p^3 + p)

for p=0.0001 is 8172.

Since this value is scaled by 10^6, the impact of this bug is that a loss
of 8172/10^6 = 0.8172% was reported whenever the input was below the table
resolution of 0.01%.

This means that the value was over 80 times too high, resulting in large spikes
of the initial loss interval, and thus unnecessarily reducing the throughput.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/tfrc_equation.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

--- a/net/dccp/ccids/lib/tfrc_equation.c
+++ b/net/dccp/ccids/lib/tfrc_equation.c
@@ -677,11 +677,11 @@ u32 tfrc_calc_x_reverse_lookup(u32 fvalue)
 	/* Error cases. */
 	if (fvalue < tfrc_calc_x_lookup[0][1]) {
 		DCCP_WARN("fvalue %d smaller than resolution\n", fvalue);
-		return tfrc_calc_x_lookup[0][1];
+		return TFRC_SMALLEST_P;
 	}
 	if (fvalue > tfrc_calc_x_lookup[TFRC_CALC_X_ARRSIZE - 1][0]) {
 		DCCP_WARN("fvalue %d exceeds bounds!\n", fvalue);
-		return 1000000;
+		return 1000000;		/* The maximum: 100% scaled by 10^6 */
 	}
 
 	if (fvalue <= tfrc_calc_x_lookup[TFRC_CALC_X_ARRSIZE - 1][1]) {
