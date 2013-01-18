From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net] xfrm: fix freed block size calculation in xfrm_policy_fini()
Date: Fri, 18 Jan 2013 16:03:48 +0100
Message-ID: <20130118153446.3AE05C1AFE@unicorn.suse.cz>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44005 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750820Ab3ARPes (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 10:34:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Missing multiplication of block size by sizeof(struct hlist_head)
can cause xfrm_hash_free() to be called with wrong second argument
so that kfree() is called on a block allocated with vzalloc() or
__get_free_pages() or free_pages() is called with wrong order when
a namespace with enough policies is removed.

Bug introduced by commit a35f6c5d, i.e. versions >= 2.6.29 are
affected.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/xfrm/xfrm_policy.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 41eabc4..07c5857 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2656,7 +2656,7 @@ static void xfrm_policy_fini(struct net *net)
 		WARN_ON(!hlist_empty(&net->xfrm.policy_inexact[dir]));
 
 		htab = &net->xfrm.policy_bydst[dir];
-		sz = (htab->hmask + 1);
+		sz = (htab->hmask + 1) * sizeof(struct hlist_head);
 		WARN_ON(!hlist_empty(htab->table));
 		xfrm_hash_free(htab->table, sz);
 	}
-- 
1.7.10.4
