From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 03/17] xfrm: state: use atomic_inc_not_zero to increment refcount
Date: Thu, 8 Sep 2016 07:54:38 +0200
Message-ID: <1473314092-11319-4-git-send-email-steffen.klassert@secunet.com>
References: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36343 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752257AbcIHGvY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:51:24 -0400
In-Reply-To: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Once xfrm_state_lookup_byaddr no longer acquires the state lock another
cpu might be freeing the state entry at the same time.

To detect this we use atomic_inc_not_zero, we then signal -EAGAIN to
caller in case our result was stale.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 904ab4d..84c1db6 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -37,6 +37,11 @@
 
 static unsigned int xfrm_state_hashmax __read_mostly = 1 * 1024 * 1024;
 
+static inline bool xfrm_state_hold_rcu(struct xfrm_state __rcu *x)
+{
+	return atomic_inc_not_zero(&x->refcnt);
+}
+
 static inline unsigned int xfrm_dst_hash(struct net *net,
 					 const xfrm_address_t *daddr,
 					 const xfrm_address_t *saddr,
@@ -668,7 +673,8 @@ static struct xfrm_state *__xfrm_state_lookup(struct net *net, u32 mark,
 
 		if ((mark & x->mark.m) != x->mark.v)
 			continue;
-		xfrm_state_hold(x);
+		if (!xfrm_state_hold_rcu(x))
+			continue;
 		return x;
 	}
 
@@ -692,7 +698,8 @@ static struct xfrm_state *__xfrm_state_lookup_byaddr(struct net *net, u32 mark,
 
 		if ((mark & x->mark.m) != x->mark.v)
 			continue;
-		xfrm_state_hold(x);
+		if (!xfrm_state_hold_rcu(x))
+			continue;
 		return x;
 	}
 
@@ -871,10 +878,14 @@ found:
 		}
 	}
 out:
-	if (x)
-		xfrm_state_hold(x);
-	else
+	if (x) {
+		if (!xfrm_state_hold_rcu(x)) {
+			*err = -EAGAIN;
+			x = NULL;
+		}
+	} else {
 		*err = acquire_in_progress ? -EAGAIN : error;
+	}
 	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 	if (to_put)
 		xfrm_state_put(to_put);
-- 
1.9.1
