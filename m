From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 21/37] dccp: Integrate feature-negotiation insertion code
Date: Thu, 28 Aug 2008 19:44:56 +0200
Message-ID: <1219945512-7723-22-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_featneg_last_call_for_comments>
 <1219945512-7723-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-5-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-6-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-7-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-8-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-9-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-10-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-11-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-12-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-13-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-14-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-15-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-16-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-17-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-18-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-19-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-20-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-21-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:55122 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756111AbYH1Rps (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 13:45:48 -0400
In-Reply-To: <1219945512-7723-21-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch implements insertion of feature negotiation at the server (listening
and request socket) and the client (connecting socket).

In dccp_insert_options(), several statements have been grouped together now
to achieve (I hope) better efficiency by reducing the number of tests each
packet has to go through:
 - Ack Vectors are sent if the packet is neither a Data or a Request packet;
 - a previous issue is corrected - feature negotiation options are allowed
   on DataAck packets (5.8).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/options.c |   33 +++++++++++++++++++++------------
 1 files changed, 21 insertions(+), 12 deletions(-)

--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -554,11 +554,25 @@ int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 	    dccp_insert_option_ndp(sk, skb))
 		return -1;
 
-	if (!dccp_packet_without_ack(skb)) {
-		if (dmsk->dccpms_send_ack_vector &&
-		    dccp_ackvec_pending(dp->dccps_hc_rx_ackvec) &&
-		    dccp_insert_option_ackvec(sk, skb))
+	if (DCCP_SKB_CB(skb)->dccpd_type != DCCP_PKT_DATA) {
+
+		/* Feature Negotiation */
+		if (dccp_feat_insert_opts(dp, NULL, skb))
 			return -1;
+
+		if (DCCP_SKB_CB(skb)->dccpd_type == DCCP_PKT_REQUEST) {
+			/*
+			 * Obtain RTT sample from Request/Response exchange.
+			 * This is currently used in CCID 3 initialisation.
+			 */
+			if (dccp_insert_option_timestamp(sk, skb))
+				return -1;
+
+		} else if (dmsk->dccpms_send_ack_vector	&&
+			   dccp_ackvec_pending(dp->dccps_hc_rx_ackvec) &&
+			   dccp_insert_option_ackvec(sk, skb)) {
+				return -1;
+		}
 	}
 
 	if (dp->dccps_hc_rx_insert_options) {
@@ -567,14 +581,6 @@ int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 		dp->dccps_hc_rx_insert_options = 0;
 	}
 
-	/*
-	 * Obtain RTT sample from Request/Response exchange.
-	 * This is currently used in CCID 3 initialisation.
-	 */
-	if (DCCP_SKB_CB(skb)->dccpd_type == DCCP_PKT_REQUEST &&
-	    dccp_insert_option_timestamp(sk, skb))
-		return -1;
-
 	if (dp->dccps_timestamp_echo != 0 &&
 	    dccp_insert_option_timestamp_echo(dp, NULL, skb))
 		return -1;
@@ -587,6 +593,9 @@ int dccp_insert_options_rsk(struct dccp_request_sock *dreq, struct sk_buff *skb)
 {
 	DCCP_SKB_CB(skb)->dccpd_opt_len = 0;
 
+	if (dccp_feat_insert_opts(NULL, dreq, skb))
+		return -1;
+
 	if (dreq->dreq_timestamp_echo != 0 &&
 	    dccp_insert_option_timestamp_echo(NULL, dreq, skb))
 		return -1;
-- 
1.6.0.rc2

