From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 8/8] xfrm: Fix potential null pointer dereference in xdst_queue_output
Date: Wed, 28 Aug 2013 13:04:55 +0200
Message-ID: <1377687895-5780-9-git-send-email-steffen.klassert@secunet.com>
References: <1377687895-5780-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56739 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753527Ab3H1LFI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 07:05:08 -0400
In-Reply-To: <1377687895-5780-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The net_device might be not set on the skb when we try refcounting.
This leads to a null pointer dereference in xdst_queue_output().
It turned out that the refcount to the net_device is not needed
after all. The dst_entry has a refcount to the net_device before
we queue the skb, so it can't go away. Therefore we can remove the
refcount on queueing to fix the null pointer dereference.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c |    9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index e52cab3..f77c371 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -320,10 +320,8 @@ static void xfrm_queue_purge(struct sk_buff_head *list)
 {
 	struct sk_buff *skb;
 
-	while ((skb = skb_dequeue(list)) != NULL) {
-		dev_put(skb->dev);
+	while ((skb = skb_dequeue(list)) != NULL)
 		kfree_skb(skb);
-	}
 }
 
 /* Rule must be locked. Release descentant resources, announce
@@ -1758,7 +1756,6 @@ static void xfrm_policy_queue_process(unsigned long arg)
 	struct sk_buff *skb;
 	struct sock *sk;
 	struct dst_entry *dst;
-	struct net_device *dev;
 	struct xfrm_policy *pol = (struct xfrm_policy *)arg;
 	struct xfrm_policy_queue *pq = &pol->polq;
 	struct flowi fl;
@@ -1805,7 +1802,6 @@ static void xfrm_policy_queue_process(unsigned long arg)
 		dst = xfrm_lookup(xp_net(pol), skb_dst(skb)->path,
 				  &fl, skb->sk, 0);
 		if (IS_ERR(dst)) {
-			dev_put(skb->dev);
 			kfree_skb(skb);
 			continue;
 		}
@@ -1814,9 +1810,7 @@ static void xfrm_policy_queue_process(unsigned long arg)
 		skb_dst_drop(skb);
 		skb_dst_set(skb, dst);
 
-		dev = skb->dev;
 		err = dst_output(skb);
-		dev_put(dev);
 	}
 
 	return;
@@ -1839,7 +1833,6 @@ static int xdst_queue_output(struct sk_buff *skb)
 	}
 
 	skb_dst_force(skb);
-	dev_hold(skb->dev);
 
 	spin_lock_bh(&pq->hold_queue.lock);
 
-- 
1.7.9.5
