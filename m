From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/2] xfrm: state lookup can be lockless
Date: Fri, 23 Sep 2016 09:14:42 +0200
Message-ID: <1474614882-25253-3-git-send-email-steffen.klassert@secunet.com>
References: <1474614882-25253-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:45165 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756603AbcIWHOw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:14:52 -0400
In-Reply-To: <1474614882-25253-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

This is called from the packet input path, we get lock contention
if many cpus handle ipsec in parallel.

After recent rcu conversion it is safe to call __xfrm_state_lookup
without the spinlock.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
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
1.9.1
