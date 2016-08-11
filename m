From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 2/8] xfrm: policy: prepare policy_bydst hash for rcu lookups
Date: Thu, 11 Aug 2016 15:17:53 +0200
Message-ID: <1470921479-25592-3-git-send-email-fw@strlen.de>
References: <1470921479-25592-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:54962 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752682AbcHKNRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 09:17:48 -0400
In-Reply-To: <1470921479-25592-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 56f047305dd4b6b617
("xfrm: add rcu grace period in xfrm_policy_destroy()") xfrm policy
objects are already free'd via rcu.

In order to make more places lockless (i.e. use rcu_read_lock instead of
grabbing read-side of policy rwlock) we only need to:

- use rcu_assign_pointer to store address of new hash table backend memory
- add rcu barrier so that freeing of old memory is delayed (expansion
  and free happens from system workqueue, so synchronize_rcu is fine)
- use rcu_dereference to fetch current address of the hash table.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_policy.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 538685c..362bdb4 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -385,9 +385,11 @@ static struct hlist_head *policy_hash_bysel(struct net *net,
 	__get_hash_thresh(net, family, dir, &dbits, &sbits);
 	hash = __sel_hash(sel, family, hmask, dbits, sbits);
 
-	return (hash == hmask + 1 ?
-		&net->xfrm.policy_inexact[dir] :
-		net->xfrm.policy_bydst[dir].table + hash);
+	if (hash == hmask + 1)
+		return &net->xfrm.policy_inexact[dir];
+
+	return rcu_dereference_check(net->xfrm.policy_bydst[dir].table,
+		     lockdep_is_held(&net->xfrm.xfrm_policy_lock)) + hash;
 }
 
 static struct hlist_head *policy_hash_direct(struct net *net,
@@ -403,7 +405,8 @@ static struct hlist_head *policy_hash_direct(struct net *net,
 	__get_hash_thresh(net, family, dir, &dbits, &sbits);
 	hash = __addr_hash(daddr, saddr, family, hmask, dbits, sbits);
 
-	return net->xfrm.policy_bydst[dir].table + hash;
+	return rcu_dereference_check(net->xfrm.policy_bydst[dir].table,
+		     lockdep_is_held(&net->xfrm.xfrm_policy_lock)) + hash;
 }
 
 static void xfrm_dst_hash_transfer(struct net *net,
@@ -468,8 +471,8 @@ static void xfrm_bydst_resize(struct net *net, int dir)
 	unsigned int hmask = net->xfrm.policy_bydst[dir].hmask;
 	unsigned int nhashmask = xfrm_new_hash_mask(hmask);
 	unsigned int nsize = (nhashmask + 1) * sizeof(struct hlist_head);
-	struct hlist_head *odst = net->xfrm.policy_bydst[dir].table;
 	struct hlist_head *ndst = xfrm_hash_alloc(nsize);
+	struct hlist_head *odst;
 	int i;
 
 	if (!ndst)
@@ -477,14 +480,19 @@ static void xfrm_bydst_resize(struct net *net, int dir)
 
 	write_lock_bh(&net->xfrm.xfrm_policy_lock);
 
+	odst = rcu_dereference_protected(net->xfrm.policy_bydst[dir].table,
+				lockdep_is_held(&net->xfrm.xfrm_policy_lock));
+
 	for (i = hmask; i >= 0; i--)
 		xfrm_dst_hash_transfer(net, odst + i, ndst, nhashmask, dir);
 
-	net->xfrm.policy_bydst[dir].table = ndst;
+	rcu_assign_pointer(net->xfrm.policy_bydst[dir].table, ndst);
 	net->xfrm.policy_bydst[dir].hmask = nhashmask;
 
 	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
+	synchronize_rcu();
+
 	xfrm_hash_free(odst, (hmask + 1) * sizeof(struct hlist_head));
 }
 
-- 
2.7.3
