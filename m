From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] xfrm: move the checking for old xfrm_policy hold_queue to beginning
Date: Thu, 30 Apr 2015 17:25:19 +0800
Message-ID: <1430385919-22030-1-git-send-email-roy.qing.li@gmail.com>
Cc: steffen.klassert@secunet.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39612 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbbD3J0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 05:26:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

if hold_queue of old xfrm_policy is NULL, return directly, then not need to
run other codes, especially take the spin lock

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/xfrm/xfrm_policy.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index f576217..1d53f4d 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -708,6 +708,9 @@ static void xfrm_policy_requeue(struct xfrm_policy *old,
 	struct xfrm_policy_queue *pq = &old->polq;
 	struct sk_buff_head list;
 
+	if (skb_queue_empty(&pq->hold_queue))
+		return;
+
 	__skb_queue_head_init(&list);
 
 	spin_lock_bh(&pq->hold_queue.lock);
@@ -716,9 +719,6 @@ static void xfrm_policy_requeue(struct xfrm_policy *old,
 		xfrm_pol_put(old);
 	spin_unlock_bh(&pq->hold_queue.lock);
 
-	if (skb_queue_empty(&list))
-		return;
-
 	pq = &new->polq;
 
 	spin_lock_bh(&pq->hold_queue.lock);
-- 
2.1.0
