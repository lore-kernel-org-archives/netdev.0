From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 08/17] xfrm: policy: use rcu versions for iteration and list add/del
Date: Thu, 8 Sep 2016 07:54:43 +0200
Message-ID: <1473314092-11319-9-git-send-email-steffen.klassert@secunet.com>
References: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36354 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755362AbcIHGv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:51:26 -0400
In-Reply-To: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

This is required once we allow lockless readers.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b5e665b..93b8ff7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -426,14 +426,14 @@ redo:
 		h = __addr_hash(&pol->selector.daddr, &pol->selector.saddr,
 				pol->family, nhashmask, dbits, sbits);
 		if (!entry0) {
-			hlist_del(&pol->bydst);
-			hlist_add_head(&pol->bydst, ndsttable+h);
+			hlist_del_rcu(&pol->bydst);
+			hlist_add_head_rcu(&pol->bydst, ndsttable + h);
 			h0 = h;
 		} else {
 			if (h != h0)
 				continue;
-			hlist_del(&pol->bydst);
-			hlist_add_behind(&pol->bydst, entry0);
+			hlist_del_rcu(&pol->bydst);
+			hlist_add_behind_rcu(&pol->bydst, entry0);
 		}
 		entry0 = &pol->bydst;
 	}
@@ -1106,7 +1106,7 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 	read_lock_bh(&net->xfrm.xfrm_policy_lock);
 	chain = policy_hash_direct(net, daddr, saddr, family, dir);
 	ret = NULL;
-	hlist_for_each_entry(pol, chain, bydst) {
+	hlist_for_each_entry_rcu(pol, chain, bydst) {
 		err = xfrm_policy_match(pol, fl, type, family, dir);
 		if (err) {
 			if (err == -ESRCH)
@@ -1122,7 +1122,7 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 		}
 	}
 	chain = &net->xfrm.policy_inexact[dir];
-	hlist_for_each_entry(pol, chain, bydst) {
+	hlist_for_each_entry_rcu(pol, chain, bydst) {
 		if ((pol->priority >= priority) && ret)
 			break;
 
@@ -1271,7 +1271,7 @@ static struct xfrm_policy *__xfrm_policy_unlink(struct xfrm_policy *pol,
 
 	/* Socket policies are not hashed. */
 	if (!hlist_unhashed(&pol->bydst)) {
-		hlist_del(&pol->bydst);
+		hlist_del_rcu(&pol->bydst);
 		hlist_del(&pol->byidx);
 	}
 
-- 
1.9.1
