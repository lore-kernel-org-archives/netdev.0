From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 2/6] dccp: combine the functionality of enqeueing and cloning
Date: Mon,  4 Jul 2011 13:01:15 -0600
Message-ID: <1309806079-21604-3-git-send-email-gerrit@erg.abdn.ac.uk>
References: <test_tree_patch_set_update_2011-07-04>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:53781 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751369Ab1GDTVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2011 15:21:54 -0400
In-Reply-To: <test_tree_patch_set_update_2011-07-04>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Realising the following call pattern,
 * first dccp_entail() is called to enqueue a new skb and
 * then skb_clone() is called to transmit a clone of that skb,
this patch integrates both into the same function.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/output.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -27,11 +27,13 @@ static inline void dccp_event_ack_sent(struct sock *sk)
 	inet_csk_clear_xmit_timer(sk, ICSK_TIME_DACK);
 }
 
-static void dccp_skb_entail(struct sock *sk, struct sk_buff *skb)
+/* enqueue @skb on sk_send_head for retransmission, return clone to send now */
+static struct sk_buff *dccp_skb_entail(struct sock *sk, struct sk_buff *skb)
 {
 	skb_set_owner_w(skb, sk);
 	WARN_ON(sk->sk_send_head);
 	sk->sk_send_head = skb;
+	return skb_clone(sk->sk_send_head, gfp_any());
 }
 
 /*
@@ -552,8 +554,7 @@ int dccp_connect(struct sock *sk)
 
 	DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_REQUEST;
 
-	dccp_skb_entail(sk, skb);
-	dccp_transmit_skb(sk, skb_clone(skb, GFP_KERNEL));
+	dccp_transmit_skb(sk, dccp_skb_entail(sk, skb));
 	DCCP_INC_STATS(DCCP_MIB_ACTIVEOPENS);
 
 	/* Timer for repeating the REQUEST until an answer. */
@@ -678,8 +679,7 @@ void dccp_send_close(struct sock *sk, const int active)
 		DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_CLOSE;
 
 	if (active) {
-		dccp_skb_entail(sk, skb);
-		dccp_transmit_skb(sk, skb_clone(skb, prio));
+		skb = dccp_skb_entail(sk, skb);
 		/*
 		 * Retransmission timer for active-close: RFC 4340, 8.3 requires
 		 * to retransmit the Close/CloseReq until the CLOSING/CLOSEREQ
@@ -692,6 +692,6 @@ void dccp_send_close(struct sock *sk, const int active)
 		 */
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 					  DCCP_TIMEOUT_INIT, DCCP_RTO_MAX);
-	} else
-		dccp_transmit_skb(sk, skb);
+	}
+	dccp_transmit_skb(sk, skb);
 }
