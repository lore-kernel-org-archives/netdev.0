From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 6/7] xfrm: Add refcount handling to queued policies
Date: Wed,  9 Oct 2013 12:59:10 +0200
Message-ID: <1381316351-14418-7-git-send-email-steffen.klassert@secunet.com>
References: <1381316351-14418-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51358 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757073Ab3JIK7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Oct 2013 06:59:31 -0400
In-Reply-To: <1381316351-14418-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to ensure that policies can't go away as long as the hold timer
is armed, so take a refcont when we arm the timer and drop one if we
delete it.

Bug was introduced with git commit a0073fe18 ("xfrm: Add a state
resolution packet queue")

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c |   24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index ed38d5d..5f9be97 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -334,7 +334,8 @@ static void xfrm_policy_kill(struct xfrm_policy *policy)
 
 	atomic_inc(&policy->genid);
 
-	del_timer(&policy->polq.hold_timer);
+	if (del_timer(&policy->polq.hold_timer))
+		xfrm_pol_put(policy);
 	xfrm_queue_purge(&policy->polq.hold_queue);
 
 	if (del_timer(&policy->timer))
@@ -589,7 +590,8 @@ static void xfrm_policy_requeue(struct xfrm_policy *old,
 
 	spin_lock_bh(&pq->hold_queue.lock);
 	skb_queue_splice_init(&pq->hold_queue, &list);
-	del_timer(&pq->hold_timer);
+	if (del_timer(&pq->hold_timer))
+		xfrm_pol_put(old);
 	spin_unlock_bh(&pq->hold_queue.lock);
 
 	if (skb_queue_empty(&list))
@@ -600,7 +602,8 @@ static void xfrm_policy_requeue(struct xfrm_policy *old,
 	spin_lock_bh(&pq->hold_queue.lock);
 	skb_queue_splice(&list, &pq->hold_queue);
 	pq->timeout = XFRM_QUEUE_TMO_MIN;
-	mod_timer(&pq->hold_timer, jiffies);
+	if (!mod_timer(&pq->hold_timer, jiffies))
+		xfrm_pol_hold(new);
 	spin_unlock_bh(&pq->hold_queue.lock);
 }
 
@@ -1787,8 +1790,9 @@ static void xfrm_policy_queue_process(unsigned long arg)
 			goto purge_queue;
 
 		pq->timeout = pq->timeout << 1;
-		mod_timer(&pq->hold_timer, jiffies + pq->timeout);
-		return;
+		if (!mod_timer(&pq->hold_timer, jiffies + pq->timeout))
+			xfrm_pol_hold(pol);
+	goto out;
 	}
 
 	dst_release(dst);
@@ -1819,11 +1823,14 @@ static void xfrm_policy_queue_process(unsigned long arg)
 		err = dst_output(skb);
 	}
 
+out:
+	xfrm_pol_put(pol);
 	return;
 
 purge_queue:
 	pq->timeout = 0;
 	xfrm_queue_purge(&pq->hold_queue);
+	xfrm_pol_put(pol);
 }
 
 static int xdst_queue_output(struct sk_buff *skb)
@@ -1831,7 +1838,8 @@ static int xdst_queue_output(struct sk_buff *skb)
 	unsigned long sched_next;
 	struct dst_entry *dst = skb_dst(skb);
 	struct xfrm_dst *xdst = (struct xfrm_dst *) dst;
-	struct xfrm_policy_queue *pq = &xdst->pols[0]->polq;
+	struct xfrm_policy *pol = xdst->pols[0];
+	struct xfrm_policy_queue *pq = &pol->polq;
 
 	if (pq->hold_queue.qlen > XFRM_MAX_QUEUE_LEN) {
 		kfree_skb(skb);
@@ -1850,10 +1858,12 @@ static int xdst_queue_output(struct sk_buff *skb)
 	if (del_timer(&pq->hold_timer)) {
 		if (time_before(pq->hold_timer.expires, sched_next))
 			sched_next = pq->hold_timer.expires;
+		xfrm_pol_put(pol);
 	}
 
 	__skb_queue_tail(&pq->hold_queue, skb);
-	mod_timer(&pq->hold_timer, sched_next);
+	if (!mod_timer(&pq->hold_timer, sched_next))
+		xfrm_pol_hold(pol);
 
 	spin_unlock_bh(&pq->hold_queue.lock);
 
-- 
1.7.9.5
