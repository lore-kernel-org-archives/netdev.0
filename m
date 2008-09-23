From: David Miller <davem@davemloft.net>
Subject: [PATCH]: ppp_generic: Use skb_peek() in ppp_receive_mp_frame().
Date: Tue, 23 Sep 2008 01:34:46 -0700 (PDT)
Message-ID: <20080923.013446.239958956.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55362
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752522AbYIWIe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 04:34:58 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 99353C8C181
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 01:34:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'm going to try and take baby steps with these conversions
in PPP.

ppp_generic: Use skb_peek() in ppp_receive_mp_frame().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ppp_generic.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 98e0495..5d4d215 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1833,9 +1833,11 @@ ppp_receive_mp_frame(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 
 	/* If the queue is getting long, don't wait any longer for packets
 	   before the start of the queue. */
-	if (skb_queue_len(&ppp->mrq) >= PPP_MP_MAX_QLEN
-	    && seq_before(ppp->minseq, ppp->mrq.next->sequence))
-		ppp->minseq = ppp->mrq.next->sequence;
+	if (skb_queue_len(&ppp->mrq) >= PPP_MP_MAX_QLEN) {
+		struct sk_buff *skb = skb_peek(&ppp->mrq);
+		if (seq_before(ppp->minseq, skb->sequence))
+			ppp->minseq = skb->sequence;
+	}
 
 	/* Pull completed packets off the queue and receive them. */
 	while ((skb = ppp_mp_reconstruct(ppp)))
-- 
1.5.6.5

