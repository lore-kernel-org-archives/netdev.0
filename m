From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 6/6] dccp ccid-3: Replace lazy BUG_ON with condition
Date: Wed, 27 Aug 2008 07:35:25 +0200
Message-ID: <1219815325-13778-7-git-send-email-gerrit@erg.abdn.ac.uk>
References: <20080827050636.GB6760@gerrit.erg.abdn.ac.uk>
 <1219815325-13778-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219815325-13778-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219815325-13778-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219815325-13778-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219815325-13778-5-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219815325-13778-6-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:46922 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752151AbYH0Ffh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 01:35:37 -0400
In-Reply-To: <1219815325-13778-6-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BUG_ON(w_tot == 0) only holds if there is no more than 1 loss interval in
the loss history. If there is only a single loss interval, the calc_i_mean()
routine need in fact not be called (RFC 3448, 6.3.1).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/loss_interval.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -67,7 +67,10 @@ static void tfrc_lh_calc_i_mean(struct tfrc_loss_hist *lh)
 	u32 i_i, i_tot0 = 0, i_tot1 = 0, w_tot = 0;
 	int i, k = tfrc_lh_length(lh) - 1; /* k is as in rfc3448bis, 5.4 */
 
-	for (i=0; i <= k; i++) {
+	if (k <= 0)
+		return;
+
+	for (i = 0; i <= k; i++) {
 		i_i = tfrc_lh_get_interval(lh, i);
 
 		if (i < k) {
@@ -78,7 +81,6 @@ static void tfrc_lh_calc_i_mean(struct tfrc_loss_hist *lh)
 			i_tot1 += i_i * tfrc_lh_weights[i-1];
 	}
 
-	BUG_ON(w_tot == 0);
 	lh->i_mean = max(i_tot0, i_tot1) / w_tot;
 }
 
