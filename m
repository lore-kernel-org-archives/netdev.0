From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/7] [IPSEC]: Remove bogus ref count in xfrm_secpath_reject
Date: Tue, 09 Oct 2007 22:36:31 +0800
Message-ID: <E1IfGCF-0005Lh-00@gondolin.me.apana.org.au>
References: <20071009143517.GA20486@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4982 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752920AbXJIOgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 10:36:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Remove bogus ref count in xfrm_secpath_reject

Constructs of the form

	xfrm_state_hold(x);
	foo(x);
	xfrm_state_put(x);

tend to be broken because foo is either synchronous where this is totally
unnecessary or if foo is asynchronous then the reference count is in the
wrong spot.

In the case of xfrm_secpath_reject, the function is synchronous and therefore
we should just kill the reference count.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/xfrm/xfrm_policy.c |    6 +-----
 1 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 76f172f..af27c19 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1682,17 +1682,13 @@ static inline int
 xfrm_secpath_reject(int idx, struct sk_buff *skb, struct flowi *fl)
 {
 	struct xfrm_state *x;
-	int err;
 
 	if (!skb->sp || idx < 0 || idx >= skb->sp->len)
 		return 0;
 	x = skb->sp->xvec[idx];
 	if (!x->type->reject)
 		return 0;
-	xfrm_state_hold(x);
-	err = x->type->reject(x, skb, fl);
-	xfrm_state_put(x);
-	return err;
+	return x->type->reject(x, skb, fl);
 }
 
 /* When skb is transformed back to its "native" form, we have to
