From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 1/8] xfrm: policy: use rcu versions for iteration and list add/del
Date: Thu, 11 Aug 2016 15:17:52 +0200
Message-ID: <1470921479-25592-2-git-send-email-fw@strlen.de>
References: <1470921479-25592-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:54958 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752682AbcHKNRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 09:17:45 -0400
In-Reply-To: <1470921479-25592-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is required once we allow lockless readers.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_policy.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index b5e665b..538685c 100644
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
2.7.3
