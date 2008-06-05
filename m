From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [dccp] [RFC/RFT] [Patch 2/2]: Combine the functionality of
	enqeueing and cloning
Date: Thu, 5 Jun 2008 15:47:12 +0100
Message-ID: <20080605144712.GD8800@gerrit.erg.abdn.ac.uk>
References: <4846462F.3020004@cn.fujitsu.com> <20080604132152.GA17595@ghostprotocols.net> <20080604133849.GA5583@gerrit.erg.abdn.ac.uk> <20080604154452.GB4625@ghostprotocols.net> <20080604155540.GA16194@gerrit.erg.abdn.ac.uk> <20080605144435.GA8800@gerrit.erg.abdn.ac.uk> <20080605144529.GB8800@gerrit.erg.abdn.ac.uk> <20080605144609.GC8800@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Wei Yongjun <yjwei@cn.fujitsu.com>,
	dccp@vger.kernel.orgu
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:61227 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752917AbYFEOrR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 10:47:17 -0400
Content-Disposition: inline
In-Reply-To: <20080605144609.GC8800@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dccp: Combine the functionality of enqeueing and cloning

Realising that there is a pattern in that

 * first dccp_entail() is called to enqueue a new skb;
 * then skb_clone() is called to transmit a clone of that skb,

this patch integrates these two interrelated steps into dccp_entail.

Note: the return value of skb_clone is not checked. It may be an idea to add a
      warning if this occurs. In both instances, however, a timer is set for
      retransmission, so that cloning is re-tried via dccp_retransmit_skb().

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/output.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -26,11 +26,13 @@ static inline void dccp_event_ack_sent(s
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
@@ -536,8 +538,7 @@ int dccp_connect(struct sock *sk)
 
 	DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_REQUEST;
 
-	dccp_skb_entail(sk, skb);
-	dccp_transmit_skb(sk, skb_clone(skb, GFP_KERNEL));
+	dccp_transmit_skb(sk, dccp_skb_entail(sk, skb));
 	DCCP_INC_STATS(DCCP_MIB_ACTIVEOPENS);
 
 	/* Timer for repeating the REQUEST until an answer. */
@@ -662,8 +663,7 @@ void dccp_send_close(struct sock *sk, co
 		DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_CLOSE;
 
 	if (active) {
-		dccp_skb_entail(sk, skb);
-		dccp_transmit_skb(sk, skb_clone(skb, prio));
+		skb = dccp_skb_entail(sk, skb);
 		/*
 		 * Retransmission timer for active-close: RFC 4340, 8.3 requires
 		 * to retransmit the Close/CloseReq until the CLOSING/CLOSEREQ
@@ -676,6 +676,6 @@ void dccp_send_close(struct sock *sk, co
 		 */
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 					  DCCP_TIMEOUT_INIT, DCCP_RTO_MAX);
-	} else
-		dccp_transmit_skb(sk, skb);
+	}
+	dccp_transmit_skb(sk, skb);
 }
