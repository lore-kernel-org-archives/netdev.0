From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 27/37] dccp: Integration of dynamic feature activation - part 2 (server side)
Date: Thu, 28 Aug 2008 19:45:02 +0200
Message-ID: <1219945512-7723-28-git-send-email-gerrit@erg.abdn.ac.uk>
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
 <1219945512-7723-22-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-23-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-24-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-25-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-26-git-send-email-gerrit@erg.abdn.ac.uk>
 <1219945512-7723-27-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:55126 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753993AbYH1RpS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 13:45:18 -0400
In-Reply-To: <1219945512-7723-27-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch integrates the activation of features at the end of negotiation
into the server-side code.

Note:
  In dccp_create_openreq_child the request_sock argument is no longer constant,
  since dccp_activate_values() uses the feature-negotiation list on dreq to sort
  out the initialisation values for the different features of the child socket;
  and purges this queue after use (but the `req' argument to openreq_child
  can and does still remain constant).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/minisocks.c |   42 ++++++++++++------------------------------
 1 files changed, 12 insertions(+), 30 deletions(-)

--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -111,7 +111,7 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
 	struct sock *newsk = inet_csk_clone(sk, req, GFP_ATOMIC);
 
 	if (newsk != NULL) {
-		const struct dccp_request_sock *dreq = dccp_rsk(req);
+		struct dccp_request_sock *dreq = dccp_rsk(req);
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
 		struct dccp_sock *newdp = dccp_sk(newsk);
 		struct dccp_minisock *newdmsk = dccp_msk(newsk);
@@ -125,35 +125,6 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
 		newicsk->icsk_rto	    = DCCP_TIMEOUT_INIT;
 
 		INIT_LIST_HEAD(&newdp->dccps_featneg);
-		if (dccp_feat_clone(sk, newsk))
-			goto out_free;
-
-		if (newdmsk->dccpms_send_ack_vector) {
-			newdp->dccps_hc_rx_ackvec =
-						dccp_ackvec_alloc(GFP_ATOMIC);
-			if (unlikely(newdp->dccps_hc_rx_ackvec == NULL))
-				goto out_free;
-		}
-
-		newdp->dccps_hc_rx_ccid =
-			    ccid_hc_rx_new(newdmsk->dccpms_rx_ccid,
-					   newsk, GFP_ATOMIC);
-		newdp->dccps_hc_tx_ccid =
-			    ccid_hc_tx_new(newdmsk->dccpms_tx_ccid,
-					   newsk, GFP_ATOMIC);
-		if (unlikely(newdp->dccps_hc_rx_ccid == NULL ||
-			     newdp->dccps_hc_tx_ccid == NULL)) {
-			dccp_ackvec_free(newdp->dccps_hc_rx_ackvec);
-			ccid_hc_rx_delete(newdp->dccps_hc_rx_ccid, newsk);
-			ccid_hc_tx_delete(newdp->dccps_hc_tx_ccid, newsk);
-out_free:
-			/* It is still raw copy of parent, so invalidate
-			 * destructor and make plain sk_free() */
-			newsk->sk_destruct = NULL;
-			sk_free(newsk);
-			return NULL;
-		}
-
 		/*
 		 * Step 3: Process LISTEN state
 		 *
@@ -184,6 +155,17 @@ out_free:
 		dccp_set_seqno(&newdp->dccps_awl,
 			       max48(newdp->dccps_awl, newdp->dccps_iss));
 
+		/*
+		 * Activate features after initialising the sequence numbers,
+		 * since CCID initialisation may depend on GSS, ISR, ISS etc.
+		 */
+		if (dccp_feat_activate_values(newsk, &dreq->dreq_featneg)) {
+			/* It is still raw copy of parent, so invalidate
+			 * destructor and make plain sk_free() */
+			newsk->sk_destruct = NULL;
+			sk_free(newsk);
+			return NULL;
+		}
 		dccp_init_xmit_timers(newsk);
 
 		DCCP_INC_STATS_BH(DCCP_MIB_PASSIVEOPENS);
-- 
1.6.0.rc2

