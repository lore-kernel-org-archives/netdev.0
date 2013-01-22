From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/5] xfrm: fix freed block size calculation in xfrm_policy_fini()
Date: Tue, 22 Jan 2013 10:06:35 +0100
Message-ID: <1358845596-2066-5-git-send-email-steffen.klassert@secunet.com>
References: <1358845596-2066-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33532 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752948Ab3AVJHT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 04:07:19 -0500
In-Reply-To: <1358845596-2066-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>

Missing multiplication of block size by sizeof(struct hlist_head)
can cause xfrm_hash_free() to be called with wrong second argument
so that kfree() is called on a block allocated with vzalloc() or
__get_free_pages() or free_pages() is called with wrong order when
a namespace with enough policies is removed.

Bug introduced by commit a35f6c5d, i.e. versions >= 2.6.29 are
affected.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
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
1.7.9.5
