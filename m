From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 3/6] dccp ccid-2: Consolidate Ack-Vector processing within main DCCP module
Date: Mon, 15 Nov 2010 07:29:04 +0100
Message-ID: <1289802547-5617-4-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_ccid2_ack_vector_patch_set_concluding_part_II>
 <1289802547-5617-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1289802547-5617-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1289802547-5617-3-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:43251 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755584Ab0KOG3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 01:29:18 -0500
In-Reply-To: <1289802547-5617-3-git-send-email-gerrit@erg.abdn.ac.uk>
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
 net/dccp/input.c |   31 +++++++++----------------------
 1 files changed, 9 insertions(+), 22 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -160,13 +160,15 @@ static void dccp_rcv_reset(struct sock *sk, struct sk_buff *skb)
 	dccp_time_wait(sk, DCCP_TIME_WAIT, 0);
 }
 
-static void dccp_event_ack_recv(struct sock *sk, struct sk_buff *skb)
+static void dccp_handle_ackvec_processing(struct sock *sk, struct sk_buff *skb)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_ackvec *av = dccp_sk(sk)->dccps_hc_rx_ackvec;
 
-	if (dp->dccps_hc_rx_ackvec != NULL)
-		dccp_ackvec_clear_state(dp->dccps_hc_rx_ackvec,
-					DCCP_SKB_CB(skb)->dccpd_ack_seq);
+	if (av == NULL)
+		return;
+	if (DCCP_SKB_CB(skb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
+		dccp_ackvec_clear_state(av, DCCP_SKB_CB(skb)->dccpd_ack_seq);
+	dccp_ackvec_input(av, skb);
 }
 
 static void dccp_deliver_input_to_ccids(struct sock *sk, struct sk_buff *skb)
@@ -365,21 +367,13 @@ discard:
 int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			 const struct dccp_hdr *dh, const unsigned len)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
-
 	if (dccp_check_seqno(sk, skb))
 		goto discard;
 
 	if (dccp_parse_options(sk, NULL, skb))
 		return 1;
 
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
@@ -631,14 +625,7 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		if (dccp_parse_options(sk, NULL, skb))
 			return 1;
 
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
 
