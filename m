From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 07/10] [ACKVEC]: Consolidate Ack-Vector processing within main DCCP module
Date: Thu, 21 Feb 2008 09:09:25 +0000
Message-ID: <1203584968-8957-8-git-send-email-gerrit@erg.abdn.ac.uk>
References: ack_vector_implementation_repackaged_no_changes
 <1203584968-8957-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1203584968-8957-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1203584968-8957-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1203584968-8957-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <1203584968-8957-5-git-send-email-gerrit@erg.abdn.ac.uk>
 <1203584968-8957-6-git-send-email-gerrit@erg.abdn.ac.uk>
 <1203584968-8957-7-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:60947 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753488AbYBUJKe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2008 04:10:34 -0500
In-Reply-To: <1203584968-8957-7-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This aggregates Ack Vector processing (handling input and clearing old state)
into one function, for the following reasons and benefits:
 * all Ack Vector-specific processing is now in one place;
 * duplicated code is removed;
 * ensuring sanity: from an Ack Vector point of view, it is better to clear the
                    old state first before entering new state;
 * Ack Event handling happens mostly within the CCIDs, not the main DCCP module.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |   32 ++++++++++----------------------
 1 files changed, 10 insertions(+), 22 deletions(-)

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
@@ -621,14 +616,7 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
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
 
