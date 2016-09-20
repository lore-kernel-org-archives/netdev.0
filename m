From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next] xfrm: state lookup can be lockless
Date: Tue, 20 Sep 2016 15:45:26 +0200
Message-ID: <1474379126-32550-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:32962 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752364AbcITNpN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 09:45:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is called from the packet input path, we get lock contention
if many cpus handle ipsec in parallel.

After recent rcu conversion it is safe to call __xfrm_state_lookup
without the spinlock.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_state.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index ba8bf51..a38fdea 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1431,9 +1431,9 @@ xfrm_state_lookup(struct net *net, u32 mark, const xfrm_address_t *daddr, __be32
 {
 	struct xfrm_state *x;
 
-	spin_lock_bh(&net->xfrm.xfrm_state_lock);
+	rcu_read_lock();
 	x = __xfrm_state_lookup(net, mark, daddr, spi, proto, family);
-	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
+	rcu_read_unlock();
 	return x;
 }
 EXPORT_SYMBOL(xfrm_state_lookup);
-- 
2.7.3
