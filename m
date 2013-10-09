From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 7/7] xfrm: check for a vaild skb in xfrm_policy_queue_process
Date: Wed,  9 Oct 2013 12:59:11 +0200
Message-ID: <1381316351-14418-8-git-send-email-steffen.klassert@secunet.com>
References: <1381316351-14418-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51349 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757090Ab3JIK7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Oct 2013 06:59:31 -0400
In-Reply-To: <1381316351-14418-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We might dreference a NULL pointer if the hold_queue is empty,
so add a check to avoid this.

Bug was introduced with git commit a0073fe18 ("xfrm: Add a state
resolution packet queue")

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 5f9be97..76e1873 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1772,6 +1772,10 @@ static void xfrm_policy_queue_process(unsigned long arg)
 
 	spin_lock(&pq->hold_queue.lock);
 	skb = skb_peek(&pq->hold_queue);
+	if (!skb) {
+		spin_unlock(&pq->hold_queue.lock);
+		goto out;
+	}
 	dst = skb_dst(skb);
 	sk = skb->sk;
 	xfrm_decode_session(skb, &fl, dst->ops->family);
-- 
1.7.9.5
