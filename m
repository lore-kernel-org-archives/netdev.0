From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 4/7] dccp ccid-3: TFRC reverse-lookup Bug-Fix
Date: Tue, 10 Jun 2008 13:53:40 +0100
Message-ID: <1213102423-27486-5-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_bug_fixes_for_net-2.6>
 <1213102423-27486-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1213102423-27486-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1213102423-27486-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1213102423-27486-4-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:37419 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753589AbYFJMyI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 08:54:08 -0400
In-Reply-To: <1213102423-27486-4-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a bug in the reverse lookup of p: given a value f(p), instead of p,
the function returned the smallest tabulated value f(p).

The smallest tabulated value of

   10^6 * f(p) =  sqrt(2*p/3) + 12 * sqrt(3*p/8) * (32 * p^3 + p)

for p=0.0001 is 8172.

Since this value is scaled by 10^6, the outcome of this bug is that a loss
of 8172/10^6 = 0.8172% was reported whenever the input was below the table
resolution of 0.01%.

This means that the value was over 80 times too high, resulting in large spikes
of the initial loss interval, thus unnecessarily reducing the throughput.

Also corrected the printk format (%u for u32).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/tfrc_equation.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

--- a/net/dccp/ccids/lib/tfrc_equation.c
+++ b/net/dccp/ccids/lib/tfrc_equation.c
@@ -661,7 +661,7 @@ u32 tfrc_calc_x(u16 s, u32 R, u32 p)
 
 EXPORT_SYMBOL_GPL(tfrc_calc_x);
 
-/*
+/**
  *  tfrc_calc_x_reverse_lookup  -  try to find p given f(p)
  *
  *  @fvalue: function value to match, scaled by 1000000
@@ -676,11 +676,11 @@ u32 tfrc_calc_x_reverse_lookup(u32 fvalue)
 
 	/* Error cases. */
 	if (fvalue < tfrc_calc_x_lookup[0][1]) {
-		DCCP_WARN("fvalue %d smaller than resolution\n", fvalue);
-		return tfrc_calc_x_lookup[0][1];
+		DCCP_WARN("fvalue %u smaller than resolution\n", fvalue);
+		return TFRC_SMALLEST_P;
 	}
 	if (fvalue > tfrc_calc_x_lookup[TFRC_CALC_X_ARRSIZE - 1][0]) {
-		DCCP_WARN("fvalue %d exceeds bounds!\n", fvalue);
+		DCCP_WARN("fvalue %u exceeds bounds!\n", fvalue);
 		return 1000000;
 	}
 
