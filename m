From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/4] xfrm: Don't queue retransmitted packets if the original is still on the host
Date: Fri,  1 Nov 2013 08:50:55 +0100
Message-ID: <1383292257-4634-3-git-send-email-steffen.klassert@secunet.com>
References: <1383292257-4634-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49101 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752399Ab3KAHvJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 03:51:09 -0400
In-Reply-To: <1383292257-4634-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It does not make sense to queue retransmitted packets if the
original packet is still in some queue of this host. So add
a check to xdst_queue_output() and drop the packet if the
original packet is not yet sent.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/xfrm/xfrm_policy.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index ed38d5d..e09edfc 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1832,6 +1832,13 @@ static int xdst_queue_output(struct sk_buff *skb)
 	struct dst_entry *dst = skb_dst(skb);
 	struct xfrm_dst *xdst = (struct xfrm_dst *) dst;
 	struct xfrm_policy_queue *pq = &xdst->pols[0]->polq;
+	const struct sk_buff *fclone = skb + 1;
+
+	if (unlikely(skb->fclone == SKB_FCLONE_ORIG &&
+		     fclone->fclone == SKB_FCLONE_CLONE)) {
+		kfree_skb(skb);
+		return 0;
+	}
 
 	if (pq->hold_queue.qlen > XFRM_MAX_QUEUE_LEN) {
 		kfree_skb(skb);
-- 
1.7.9.5
