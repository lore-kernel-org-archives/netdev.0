From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 6/7] xfrm: move the checking for old xfrm_policy hold_queue to beginning
Date: Thu, 28 May 2015 08:25:53 +0200
Message-ID: <1432794354-19391-7-git-send-email-steffen.klassert@secunet.com>
References: <1432794354-19391-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50006 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751515AbbE1G0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 02:26:25 -0400
In-Reply-To: <1432794354-19391-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

if hold_queue of old xfrm_policy is NULL, return directly, then not need to
run other codes, especially take the spin lock

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 435bc0d..3d264e5 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -700,6 +700,9 @@ static void xfrm_policy_requeue(struct xfrm_policy *old,
 	struct xfrm_policy_queue *pq = &old->polq;
 	struct sk_buff_head list;
 
+	if (skb_queue_empty(&pq->hold_queue))
+		return;
+
 	__skb_queue_head_init(&list);
 
 	spin_lock_bh(&pq->hold_queue.lock);
@@ -708,9 +711,6 @@ static void xfrm_policy_requeue(struct xfrm_policy *old,
 		xfrm_pol_put(old);
 	spin_unlock_bh(&pq->hold_queue.lock);
 
-	if (skb_queue_empty(&list))
-		return;
-
 	pq = &new->polq;
 
 	spin_lock_bh(&pq->hold_queue.lock);
-- 
1.9.1
