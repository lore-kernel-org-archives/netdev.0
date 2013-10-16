From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC] xfrm: Don't queue retransmitted packets if the original
 is still on the host
Date: Wed, 16 Oct 2013 13:42:47 +0200
Message-ID: <20131016114246.GB7660@secunet.com>
References: <20131010063301.GO7660@secunet.com>
 <20131011.150124.527914076255487526.davem@davemloft.net>
 <20131015073020.GV7660@secunet.com>
 <1381881514.2045.82.camel@edumazet-glaptop.roam.corp.google.com>
 <20131016094549.GZ7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36394 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932406Ab3JPLnA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 07:43:00 -0400
Content-Disposition: inline
In-Reply-To: <20131016094549.GZ7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It does not make sense to queue retransmitted packets if the
original packet is still in some queue of this host. So add
a check to xdst_queue_output() and drop the packet if the
original packet is not yet sent.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
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
