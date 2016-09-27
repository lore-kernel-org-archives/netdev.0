From: Florian Westphal <fw@strlen.de>
Subject: [RFC 1/3] xfrm: state: do not acquire lock in get_mtu helpers
Date: Tue, 27 Sep 2016 18:05:21 +0200
Message-ID: <1474992323-11327-2-git-send-email-fw@strlen.de>
References: <1474992323-11327-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:53292 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934325AbcI0QFd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 12:05:33 -0400
In-Reply-To: <1474992323-11327-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once flow cache is removed the mtu initialisation happens for every skb
that gets an xfrm attached to it.

It is not obvious why this lock is required -- the caller holds
reference on the state struct.

xfrm_init_state already has been called (else private data accessed
by type->get_mtu() would not be set up).

So just remove the lock -- the race on the state (DEAD?) doesn't
matter (could change right after dropping the lock too).

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_state.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f9a255457a1d..bf5969aa7dc2 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2008,16 +2008,13 @@ EXPORT_SYMBOL(xfrm_state_delete_tunnel);
 
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
2.7.3
