From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 01/14] [CCID2]: Ack Vectors can happen on most packets
Date: Wed, 19 Dec 2007 14:25:42 +0000
Message-ID: <1198074355-18842-2-git-send-email-gerrit@erg.abdn.ac.uk>
References: dccp_ackvector_rfc_patch_set
 <1198074355-18842-1-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:36889 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753878AbXLSO1W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 09:27:22 -0500
In-Reply-To: <1198074355-18842-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CCID2 feedback only considers Ack/DataAck packets, but Ack Vectors can appear
on other packets, too. In RFC 4340, 11.4 the only restriction is that they must
not appear on Data or Request packets.

A possible case is for instance a Sync packet used for feature-negotiation
(as used e.g in  section 6.6.1 of RFC 4340). In this case the host must answer
with a SyncAck (7.5.4). Now, if the Sync packet carried an Ack Vector then
the SyncAck acknowledges the receipt of that Ack Vector (thus changing the
Acknowledgment Window, cf. 11.4.2); but the current code would not allow to
parse the received Ack Vector.

The fix is in parsing Ack Vectors on all packet types which are allowed to
carry an Ack Vector.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -549,13 +549,8 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	if (hctx->ccid2hctx_seqh == hctx->ccid2hctx_seqt)
 		return;
 
-	switch (DCCP_SKB_CB(skb)->dccpd_type) {
-	case DCCP_PKT_ACK:
-	case DCCP_PKT_DATAACK:
-		break;
-	default:
+	if (dccp_packet_without_ack(skb))
 		return;
-	}
 
 	ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
 	if (after48(ackno, hctx->ccid2hctx_high_ack))
-- 
1.5.3.GIT

