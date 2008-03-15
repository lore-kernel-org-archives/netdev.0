From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [DCCP] [Patch 1/1] [BUG-FIX]: Fix problem with small RTTs in CCID-3
Date: Sat, 15 Mar 2008 06:56:32 +0000
Message-ID: <20080315065632.GA5323@gerrit.erg.abdn.ac.uk>
References: <200712241443.33716.tomasz@grobelny.oswiecenia.net> <200803081629.09562.tomasz@grobelny.oswiecenia.net> <20080310130056.GA28663@gerrit.erg.abdn.ac.uk> <200803102128.17019.tomasz@grobelny.oswiecenia.net> <20080312080633.GA4996@gerrit.erg.abdn.ac.uk> <20080314133324.GA22237@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:45376 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750956AbYCOG5P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Mar 2008 02:57:15 -0400
Content-Disposition: inline
In-Reply-To: <20080314133324.GA22237@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnaldo,

please consider the attached patch which fixes the reported problems with small
RTTs in CCID-3. Clamping the RTT is not a good idea, since CCID-3 in many places
computes its throughput in the form "xxx/RTT" - so that increasing the RTT by a
factor of 10 will decrease the maximum achievable throughput by a factor of 10.

The patch is at the bottom of the test tree. The bug has also been fixed
in the CCID-4 subtree (a note has been added to patch #19 there).

----------------------------> Patch / BUG-FIX <---------------------------------
[CCID-3]: Fix "t_ipi explosion" bug

The identification of this bug is thanks to Cheng Wei and Tomasz Grobelny.

To avoid divide-by-zero, the implementation previously ignored RTTs smaller
than 4 microseconds when performing integer division RTT/4. 

When the RTT reached a value less than 4 microseconds (as observed on loopback),
this prevented the Window Counter CCVal value from advancing. As a result, the
receiver stopped sending feedback. This in turn caused non-ending expiries of
the nofeedback timer at the sender, so that the sending rate was progressively
reduced until reaching the bottom of one packet per 64 seconds.

The patch fixes this bug by handling integer division more intelligently. Due to
consistent use of dccp_sample_rtt(), divide-by-zero-RTT is avoided.

The patch was tested to successfully eliminate the "t_ipi explosion" problem
for loopback RTTs in the order of 1 microsecond - the sending behaviour now
became stable and predictable.

Since 1 microsecond is at the same time the minimum RTT resolution, the same
stable behaviour can be expected for other (small) RTTs.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -193,22 +193,17 @@ static inline void ccid3_hc_tx_update_s(
 
 /*
  *	Update Window Counter using the algorithm from [RFC 4342, 8.1].
- *	The algorithm is not applicable if RTT < 4 microseconds.
+ *	As elsewhere, RTT > 0 is assumed by using dccp_sample_rtt().
  */
 static inline void ccid3_hc_tx_update_win_count(struct ccid3_hc_tx_sock *hctx,
 						ktime_t now)
 {
-	u32 quarter_rtts;
-
-	if (unlikely(hctx->ccid3hctx_rtt < 4))	/* avoid divide-by-zero */
-		return;
-
-	quarter_rtts = ktime_us_delta(now, hctx->ccid3hctx_t_last_win_count);
-	quarter_rtts /= hctx->ccid3hctx_rtt / 4;
+	u32 delta = ktime_us_delta(now, hctx->ccid3hctx_t_last_win_count),
+	    quarter_rtts = (4 * delta) / hctx->ccid3hctx_rtt;
 
 	if (quarter_rtts > 0) {
 		hctx->ccid3hctx_t_last_win_count = now;
-		hctx->ccid3hctx_last_win_count	+= min_t(u32, quarter_rtts, 5);
+		hctx->ccid3hctx_last_win_count	+= min(quarter_rtts, 5U);
 		hctx->ccid3hctx_last_win_count	&= 0xF;		/* mod 16 */
 	}
 }
