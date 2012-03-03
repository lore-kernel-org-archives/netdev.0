From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 1/2] dccp ccid-3: replace incorrect BUG_ON
Date: Sat,  3 Mar 2012 09:33:52 -0700
Message-ID: <1330792433-15415-2-git-send-email-gerrit@erg.abdn.ac.uk>
References: <test_tree_patch_set_update_2012-03-03>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:49864 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753273Ab2CCQq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Mar 2012 11:46:29 -0500
In-Reply-To: <test_tree_patch_set_update_2012-03-03>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This replaces an unjustified BUG_ON(), which could get triggered under normal
conditions: X_calc can be 0 when p > 0. X would in this case be set to the
minimum, s/t_mbi. Its replacement avoids t_ipi = 0 (unbounded sending rate).

Thanks to Jordi, Victor and Xavier who reported this.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.uk>
---
 net/dccp/ccids/ccid3.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -98,6 +98,7 @@ static void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hc)
 {
 	hc->tx_t_ipi = scaled_div32(((u64)hc->tx_s) << 6, hc->tx_x);
 
+	DCCP_BUG_ON(hc->tx_t_ipi == 0);
 	ccid3_pr_debug("t_ipi=%u, s=%u, X=%u\n", hc->tx_t_ipi,
 		       hc->tx_s, (unsigned)(hc->tx_x >> 6));
 }
@@ -236,8 +237,6 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 		 *
 		 *  Note that X_recv is scaled by 2^6 while X_calc is not
 		 */
-		BUG_ON(hc->tx_p && !hc->tx_x_calc);
-
 		if (hc->tx_x_calc > (hc->tx_x_recv >> 5))
 			hc->tx_x_recv =
 				max(hc->tx_x_recv / 2,
