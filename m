From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: dccp-test-tree [PATCH 7/10] Extend the packet-history code to support ECN-marked-CE events
Date: Sun,  9 Aug 2009 21:48:44 +0200
Message-ID: <1249847327-6792-8-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_test_tree_sending_ecn_for_review>
 <1249847327-6792-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1249847327-6792-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1249847327-6792-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1249847327-6792-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <1249847327-6792-5-git-send-email-gerrit@erg.abdn.ac.uk>
 <1249847327-6792-6-git-send-email-gerrit@erg.abdn.ac.uk>
 <1249847327-6792-7-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54919 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752600AbZHITuu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Aug 2009 15:50:50 -0400
In-Reply-To: <1249847327-6792-7-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This extends the main accounting routine, tfrc_rx_congestion_event, to
also consider ECN-marks.

Loss and ECN-marks are treated separately: when there is already a loss
event, it is not necessary to also check for ECN marks (there will be at
most one new congestion event anyway).

Conversely, if there is an ECN-event, tracking a pending loss is disabled.
This is due to the fact that considering every possible combination of
loss_count with/-out ECN-marks creates a lot of complexity which does not
seem warranted -- comments added to point this out.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/packet_history.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -360,6 +360,27 @@ bool tfrc_rx_congestion_event(struct tfrc_rx_hist *h,
 		 */
 		new_event = tfrc_lh_interval_add(lh, h, first_li, sk);
 		__three_after_loss(h);
+
+	} else if (dccp_data_packet(skb) && dccp_skb_is_ecn_ce(skb)) {
+		/*
+		 * We only test for ECN marks on data packets. This is the way
+		 * the RFC considers ECN marks - a future implementation may
+		 * find it useful to also check ECN marks on non-data packets.
+		 */
+		new_event = tfrc_lh_interval_add(lh, h, first_li, sk);
+		/*
+		 * Also combinations of loss and ECN-marks (as per the warning)
+		 * are not supported. The permutations of loss combined with or
+		 * without ECN-marks create a lot of complexity, which does not
+		 * seem warranted: ECN-marked packets immediately trigger con-
+		 * gestion events.
+		 * Testing is needed to see whether ignoring the loss_count in
+		 * light of an ECN-marked-CE event really has any disadvantages.
+		 */
+		if (new_event && h->loss_count) {
+			DCCP_WARN("Ignoring loss count due to ECN\n");
+			tfrc_rx_hist_resume_rtt_sampling(h);
+		}
 	}
 
 	/*
-- 
1.6.0.rc2

