From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 1/6] dccp: Always generate a Reset in response to option errors
Date: Wed, 27 Aug 2008 07:35:20 +0200
Message-ID: <1219815325-13778-2-git-send-email-gerrit@erg.abdn.ac.uk>
References: <20080827050636.GB6760@gerrit.erg.abdn.ac.uk>
 <1219815325-13778-1-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:46970 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752605AbYH0Ffq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 01:35:46 -0400
In-Reply-To: <1219815325-13778-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

RFC4340 states that if a packet is received with an option error (such as a
Mandatory Option as the last byte of the option list), the endpoint should
repond with a Reset.

In the LISTEN and RESPOND states, the endpoint correctly reponds with Reset,
while in the REQUEST/OPEN states, packets with option errors are just ignored.

The packet sequence is as follows:

Case 1:

  Endpoint A                           Endpoint B
  (CLOSED)                             (CLOSED)

               <----------------       REQUEST

  RESPONSE     ----------------->      (*1)
  (with invalid option)
               <----------------       RESET
                                       (with Reset Code 5, "Option Error")

  (*1) currently just ignored, no Reset is sent

Case 2:

  Endpoint A                           Endpoint B
  (OPEN)                               (OPEN)

  DATA-ACK     ----------------->      (*2)
  (with invalid option)
               <----------------       RESET
                                       (with Reset Code 5, "Option Error")

  (*2) currently just ignored, no Reset is sent

This patch fixes the problem, by generating a Reset instead of silently
ignoring option errors.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -370,7 +370,7 @@ int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
 		goto discard;
 
 	if (dccp_parse_options(sk, NULL, skb))
-		goto discard;
+		return 1;
 
 	if (DCCP_SKB_CB(skb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
 		dccp_event_ack_recv(sk, skb);
@@ -610,7 +610,7 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		 * Step 8: Process options and mark acknowledgeable
 		 */
 		if (dccp_parse_options(sk, NULL, skb))
-			goto discard;
+			return 1;
 
 		if (dcb->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
 			dccp_event_ack_recv(sk, skb);

