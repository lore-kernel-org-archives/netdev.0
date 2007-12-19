From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 13/14] [ACKVEC]: Aggregate Ack-Vector related processing into single function
Date: Wed, 19 Dec 2007 14:25:54 +0000
Message-ID: <1198074355-18842-14-git-send-email-gerrit@erg.abdn.ac.uk>
References: dccp_ackvector_rfc_patch_set
 <1198074355-18842-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1198074355-18842-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1198074355-18842-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1198074355-18842-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <1198074355-18842-5-git-send-email-gerrit@erg.abdn.ac.uk>
 <1198074355-18842-6-git-send-email-gerrit@erg.abdn.ac.uk>
 <1198074355-18842-7-git-send-email-gerrit@erg.abdn.ac.uk>
 <1198074355-18842-8-git-send-email-gerrit@erg.abdn.ac.uk>
 <1198074355-18842-9-git-send-email-gerrit@erg.abdn.ac.uk>
 <1198074355-18842-10-git-send-email-gerrit@erg.abdn.ac.uk>
 <1198074355-18842-11-git-send-email-gerrit@erg.abdn.ac.uk>
 <1198074355-18842-12-git-send-email-gerrit@erg.abdn.ac.uk>
 <1198074355-18842-13-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:36885 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752564AbXLSO0t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 09:26:49 -0500
In-Reply-To: <1198074355-18842-13-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This aggregates Ack Vector processing (handling input and clearing old state)
into one function, for the following reasons and benefits:
 * duplicated code is removed;
 * all Ack Vector-specific processing is now in one place;
 * sanity: from an Ack Vector point of view, it is better to clear the old
   state first before entering new state;
 * Ack Event handling happens mostly within the CCIDs, not the main DCCP module.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |   38 +++++++++++---------------------------
 1 files changed, 11 insertions(+), 27 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -159,13 +159,16 @@ static void dccp_rcv_reset(struct sock *sk, struct sk_buff *skb)
 	dccp_time_wait(sk, DCCP_TIME_WAIT, 0);
 }
 
-static void dccp_event_ack_recv(struct sock *sk, struct sk_buff *skb)
+static void dccp_handle_ackvec_processing(struct sock *sk, struct sk_buff *skb)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_ackvec *av = dccp_sk(sk)->dccps_hc_rx_ackvec;
+	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 
-	if (dp->dccps_hc_rx_ackvec != NULL)
-		dccp_ackvec_clear_state(dp->dccps_hc_rx_ackvec,
-					DCCP_SKB_CB(skb)->dccpd_ack_seq);
+	if (av != NULL) {
+		if (dcb->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
+			dccp_ackvec_clear_state(av, dcb->dccpd_ack_seq);
+		dccp_ackvec_input(av, dcb->dccpd_seq, DCCPAV_RECEIVED);
+	}
 }
 
 static void dccp_deliver_input_to_ccids(struct sock *sk, struct sk_buff *skb)
@@ -364,21 +367,13 @@ discard:
 int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			 const struct dccp_hdr *dh, const unsigned len)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
-
 	if (dccp_check_seqno(sk, skb))
 		goto discard;
 
 	if (dccp_parse_options(sk, NULL, skb))
 		goto discard;
 
-	if (DCCP_SKB_CB(skb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
-		dccp_event_ack_recv(sk, skb);
-
-	if (dp->dccps_hc_rx_ackvec != NULL &&
-	    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
-			    DCCP_SKB_CB(skb)->dccpd_seq, DCCPAV_RECEIVED))
-		goto discard;
+	dccp_handle_ackvec_processing(sk, skb);
 	dccp_deliver_input_to_ccids(sk, skb);
 
 	return __dccp_rcv_established(sk, skb, dh, len);
@@ -507,11 +502,7 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
 		 */
 		if (dccp_feat_activate_values(sk, &dp->dccps_featneg))
 			goto unable_to_proceed;
-
-		if (dp->dccps_hc_rx_ackvec != NULL &&
-		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
-				    DCCP_SKB_CB(skb)->dccpd_seq, DCCPAV_RECEIVED))
-			goto unable_to_proceed;
+		dccp_handle_ackvec_processing(sk, skb);
 
 		dccp_send_ack(sk);
 		return -1;
@@ -632,14 +623,7 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		if (dccp_parse_options(sk, NULL, skb))
 			goto discard;
 
-		if (dcb->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
-			dccp_event_ack_recv(sk, skb);
-
-		if (dp->dccps_hc_rx_ackvec != NULL &&
-		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
-				    DCCP_SKB_CB(skb)->dccpd_seq, DCCPAV_RECEIVED))
-			goto discard;
-
+		dccp_handle_ackvec_processing(sk, skb);
 		dccp_deliver_input_to_ccids(sk, skb);
 	}
 
-- 
1.5.3.GIT

