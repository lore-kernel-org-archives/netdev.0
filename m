From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 2/6] xfrm: state: use atomic_inc_not_zero to increment refcount
Date: Tue,  9 Aug 2016 12:16:05 +0200
Message-ID: <1470737769-30438-3-git-send-email-fw@strlen.de>
References: <1470737769-30438-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43906 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751590AbcHIKQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 06:16:35 -0400
In-Reply-To: <1470737769-30438-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once xfrm_state_lookup_byaddr no longer acquires the state lock another
cpu might be freeing the state entry at the same time.

To detect this we use atomic_inc_not_zero, we then signal -EAGAIN to
caller in case our result was stale.

Signed-off-by: Florian Westphal <fw@strlen.de>
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
2.7.3
