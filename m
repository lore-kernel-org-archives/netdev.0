From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 02/15] xfrm: state: do not acquire lock in get_mtu helpers
Date: Wed, 1 Feb 2017 09:17:44 +0100
Message-ID: <1485937077-612-3-git-send-email-steffen.klassert@secunet.com>
References: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37022 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751426AbdBAISI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 03:18:08 -0500
In-Reply-To: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Once flow cache gets removed the mtu initialisation happens for every skb
that gets an xfrm attached, so this lock starts to show up in perf.

It is not obvious why this lock is required -- the caller holds
reference on the state struct, type->destructor is only called from the
state gc worker (all state structs on gc list must have refcount 0).

xfrm_init_state already has been called (else private data accessed
by type->get_mtu() would not be set up).

So just remove the lock -- the race on the state (DEAD?) doesn't
matter (could change right after dropping the lock too).

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index c5cf4d6..6b3366f 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2000,16 +2000,13 @@ void xfrm_state_delete_tunnel(struct xfrm_state *x)
 
 int xfrm_state_mtu(struct xfrm_state *x, int mtu)
 {
-	int res;
+	const struct xfrm_type *type = READ_ONCE(x->type);
 
-	spin_lock_bh(&x->lock);
 	if (x->km.state == XFRM_STATE_VALID &&
-	    x->type && x->type->get_mtu)
-		res = x->type->get_mtu(x, mtu);
-	else
-		res = mtu - x->props.header_len;
-	spin_unlock_bh(&x->lock);
-	return res;
+	    type && type->get_mtu)
+		return type->get_mtu(x, mtu);
+
+	return mtu - x->props.header_len;
 }
 
 int __xfrm_init_state(struct xfrm_state *x, bool init_replay)
-- 
1.9.1
