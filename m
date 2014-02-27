From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/5] xfrm: Fix unlink race when policies are deleted.
Date: Thu, 27 Feb 2014 07:16:39 +0100
Message-ID: <1393481799-20492-6-git-send-email-steffen.klassert@secunet.com>
References: <1393481799-20492-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57433 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523AbaB0GQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 01:16:52 -0500
In-Reply-To: <1393481799-20492-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a policy is unlinked from the lists in thread context,
the xfrm timer can fire before we can mark this policy as dead.
So reinitialize the bydst hlist, then hlist_unhashed() will
notice that this policy is not linked and will avoid a
doulble unlink of that policy.

Reported-by: Xianpeng Zhao <673321875@qq.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4b98b25..1d5c7bf 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1158,7 +1158,7 @@ static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 	if (hlist_unhashed(&pol->bydst))
 		return NULL;
 
-	hlist_del(&pol->bydst);
+	hlist_del_init(&pol->bydst);
 	hlist_del(&pol->byidx);
 	list_del(&pol->walk.all);
 	net->xfrm.policy_count[dir]--;
-- 
1.7.9.5
