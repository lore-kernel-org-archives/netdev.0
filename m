From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next] xfrm: state: do not acquire lock in get_mtu helpers
Date: Thu,  5 Jan 2017 13:23:58 +0100
Message-ID: <1483619038-17586-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:48286 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752103AbdAEMYz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 07:24:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 net/xfrm/xfrm_state.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 64e3c82eedf6..53877fea9316 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2000,16 +2000,13 @@ EXPORT_SYMBOL(xfrm_state_delete_tunnel);
 
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
