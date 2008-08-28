From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 26/37] dccp: Integration of dynamic feature activation - part 1 (socket setup)
Date: Thu, 28 Aug 2008 19:45:01 +0200
Message-ID: <1219945512-7723-27-git-send-email-gerrit@erg.abdn.ac.uk>
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
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:55167 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754106AbYH1Rp2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 13:45:28 -0400
In-Reply-To: <1219945512-7723-26-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This first patch out of three replaces the hardcoded default settings with
initialisation code for the dynamic feature negotiation.

Note on retransmitting Confirm options:
---------------------------------------
This patch also defers flushing the client feature-negotiation queue,
due to the following considerations.

As long as the client is in PARTOPEN, it needs to retransmit the Confirm
options for the Change options received on the DCCP-Response from the server.

Otherwise, if the packet containing the Confirm options gets dropped in the
network, the connection aborts due to undefined feature negotiation state.

Thanks to Leandro Melo de Sales who reported a bug in an earlier revision
of the patch set, resulting from not retransmitting the Confirm options.

The patch now ensures that the client feature-negotiation queue is flushed only
when entering the OPEN state. Since confirmed Change options are removed as
soon as they are confirmed (in the DCCP-Response), this ensures that Confirm
options are retransmitted.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/proto.c |   46 ++++++----------------------------------------
 1 files changed, 6 insertions(+), 40 deletions(-)

--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -67,6 +67,9 @@ void dccp_set_state(struct sock *sk, const int state)
 	case DCCP_OPEN:
 		if (oldstate != DCCP_OPEN)
 			DCCP_INC_STATS(DCCP_MIB_CURRESTAB);
+		/* Client retransmits all Confirm options until entering OPEN */
+		if (oldstate == DCCP_PARTOPEN)
+			dccp_feat_list_purge(&dccp_sk(sk)->dccps_featneg);
 		break;
 
 	case DCCP_CLOSED:
@@ -175,7 +178,6 @@ EXPORT_SYMBOL_GPL(dccp_state_name);
 int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct dccp_minisock *dmsk = dccp_msk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
 	dccp_minisock_init(&dp->dccps_minisock);
@@ -194,45 +196,9 @@ int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 	dccp_init_xmit_timers(sk);
 
 	INIT_LIST_HEAD(&dp->dccps_featneg);
-	/*
-	 * FIXME: We're hardcoding the CCID, and doing this at this point makes
-	 * the listening (master) sock get CCID control blocks, which is not
-	 * necessary, but for now, to not mess with the test userspace apps,
-	 * lets leave it here, later the real solution is to do this in a
-	 * setsockopt(CCIDs-I-want/accept). -acme
-	 */
-	if (likely(ctl_sock_initialized)) {
-		int rc = dccp_feat_init(sk);
-
-		if (rc)
-			return rc;
-
-		if (dmsk->dccpms_send_ack_vector) {
-			dp->dccps_hc_rx_ackvec = dccp_ackvec_alloc(GFP_KERNEL);
-			if (dp->dccps_hc_rx_ackvec == NULL)
-				return -ENOMEM;
-		}
-		dp->dccps_hc_rx_ccid = ccid_hc_rx_new(dmsk->dccpms_rx_ccid,
-						      sk, GFP_KERNEL);
-		dp->dccps_hc_tx_ccid = ccid_hc_tx_new(dmsk->dccpms_tx_ccid,
-						      sk, GFP_KERNEL);
-		if (unlikely(dp->dccps_hc_rx_ccid == NULL ||
-			     dp->dccps_hc_tx_ccid == NULL)) {
-			ccid_hc_rx_delete(dp->dccps_hc_rx_ccid, sk);
-			ccid_hc_tx_delete(dp->dccps_hc_tx_ccid, sk);
-			if (dmsk->dccpms_send_ack_vector) {
-				dccp_ackvec_free(dp->dccps_hc_rx_ackvec);
-				dp->dccps_hc_rx_ackvec = NULL;
-			}
-			dp->dccps_hc_rx_ccid = dp->dccps_hc_tx_ccid = NULL;
-			return -ENOMEM;
-		}
-	} else {
-		/* control socket doesn't need feat nego */
-		INIT_LIST_HEAD(&dmsk->dccpms_pending);
-		INIT_LIST_HEAD(&dmsk->dccpms_conf);
-	}
-
+	/* control socket doesn't need feat nego */
+	if (likely(ctl_sock_initialized))
+		return dccp_feat_init(sk);
 	return 0;
 }
 
-- 
1.6.0.rc2

