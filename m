From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 30/53] netns xfrm: policy insertion in netns
Date: Tue, 25 Nov 2008 20:27:02 +0300
Message-ID: <1227634045-27534-30-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-23-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-24-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-25-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-26-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-27-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-28-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-29-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:3932 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770AbYKYRYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:24:50 -0500
Received: by nf-out-0910.google.com with SMTP id d3so28136nfc.21
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:24:49 -0800 (PST)
In-Reply-To: <1227634045-27534-29-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 net/xfrm/xfrm_policy.c |   46 ++++++++++++++++++++++++----------------------
 1 files changed, 24 insertions(+), 22 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index aefbb56..11fee87 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -326,22 +326,22 @@ static inline unsigned int idx_hash(struct net *net, u32 index)
 	return __idx_hash(index, net->xfrm.policy_idx_hmask);
 }
 
-static struct hlist_head *policy_hash_bysel(struct xfrm_selector *sel, unsigned short family, int dir)
+static struct hlist_head *policy_hash_bysel(struct net *net, struct xfrm_selector *sel, unsigned short family, int dir)
 {
-	unsigned int hmask = init_net.xfrm.policy_bydst[dir].hmask;
+	unsigned int hmask = net->xfrm.policy_bydst[dir].hmask;
 	unsigned int hash = __sel_hash(sel, family, hmask);
 
 	return (hash == hmask + 1 ?
-		&init_net.xfrm.policy_inexact[dir] :
-		init_net.xfrm.policy_bydst[dir].table + hash);
+		&net->xfrm.policy_inexact[dir] :
+		net->xfrm.policy_bydst[dir].table + hash);
 }
 
-static struct hlist_head *policy_hash_direct(xfrm_address_t *daddr, xfrm_address_t *saddr, unsigned short family, int dir)
+static struct hlist_head *policy_hash_direct(struct net *net, xfrm_address_t *daddr, xfrm_address_t *saddr, unsigned short family, int dir)
 {
-	unsigned int hmask = init_net.xfrm.policy_bydst[dir].hmask;
+	unsigned int hmask = net->xfrm.policy_bydst[dir].hmask;
 	unsigned int hash = __addr_hash(daddr, saddr, family, hmask);
 
-	return init_net.xfrm.policy_bydst[dir].table + hash;
+	return net->xfrm.policy_bydst[dir].table + hash;
 }
 
 static void xfrm_dst_hash_transfer(struct hlist_head *list,
@@ -508,7 +508,7 @@ static void xfrm_hash_resize(struct work_struct *work)
 
 /* Generate new index... KAME seems to generate them ordered by cost
  * of an absolute inpredictability of ordering of rules. This will not pass. */
-static u32 xfrm_gen_index(int dir)
+static u32 xfrm_gen_index(struct net *net, int dir)
 {
 	static u32 idx_generator;
 
@@ -523,7 +523,7 @@ static u32 xfrm_gen_index(int dir)
 		idx_generator += 8;
 		if (idx == 0)
 			idx = 8;
-		list = init_net.xfrm.policy_byidx + idx_hash(&init_net, idx);
+		list = net->xfrm.policy_byidx + idx_hash(net, idx);
 		found = 0;
 		hlist_for_each_entry(p, entry, list, byidx) {
 			if (p->index == idx) {
@@ -553,6 +553,7 @@ static inline int selector_cmp(struct xfrm_selector *s1, struct xfrm_selector *s
 
 int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 {
+	struct net *net = xp_net(policy);
 	struct xfrm_policy *pol;
 	struct xfrm_policy *delpol;
 	struct hlist_head *chain;
@@ -560,7 +561,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	struct dst_entry *gc_list;
 
 	write_lock_bh(&xfrm_policy_lock);
-	chain = policy_hash_bysel(&policy->selector, policy->family, dir);
+	chain = policy_hash_bysel(net, &policy->selector, policy->family, dir);
 	delpol = NULL;
 	newpos = NULL;
 	hlist_for_each_entry(pol, entry, chain, bydst) {
@@ -587,27 +588,27 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 	else
 		hlist_add_head(&policy->bydst, chain);
 	xfrm_pol_hold(policy);
-	init_net.xfrm.policy_count[dir]++;
+	net->xfrm.policy_count[dir]++;
 	atomic_inc(&flow_cache_genid);
 	if (delpol) {
 		hlist_del(&delpol->bydst);
 		hlist_del(&delpol->byidx);
 		list_del(&delpol->walk.all);
-		init_net.xfrm.policy_count[dir]--;
+		net->xfrm.policy_count[dir]--;
 	}
-	policy->index = delpol ? delpol->index : xfrm_gen_index(dir);
-	hlist_add_head(&policy->byidx, init_net.xfrm.policy_byidx+idx_hash(&init_net, policy->index));
+	policy->index = delpol ? delpol->index : xfrm_gen_index(net, dir);
+	hlist_add_head(&policy->byidx, net->xfrm.policy_byidx+idx_hash(net, policy->index));
 	policy->curlft.add_time = get_seconds();
 	policy->curlft.use_time = 0;
 	if (!mod_timer(&policy->timer, jiffies + HZ))
 		xfrm_pol_hold(policy);
-	list_add(&policy->walk.all, &init_net.xfrm.policy_all);
+	list_add(&policy->walk.all, &net->xfrm.policy_all);
 	write_unlock_bh(&xfrm_policy_lock);
 
 	if (delpol)
 		xfrm_policy_kill(delpol);
-	else if (xfrm_bydst_should_resize(&init_net, dir, NULL))
-		schedule_work(&init_net.xfrm.policy_hash_work);
+	else if (xfrm_bydst_should_resize(net, dir, NULL))
+		schedule_work(&net->xfrm.policy_hash_work);
 
 	read_lock_bh(&xfrm_policy_lock);
 	gc_list = NULL;
@@ -652,7 +653,7 @@ struct xfrm_policy *xfrm_policy_bysel_ctx(u8 type, int dir,
 
 	*err = 0;
 	write_lock_bh(&xfrm_policy_lock);
-	chain = policy_hash_bysel(sel, sel->family, dir);
+	chain = policy_hash_bysel(&init_net, sel, sel->family, dir);
 	ret = NULL;
 	hlist_for_each_entry(pol, entry, chain, bydst) {
 		if (pol->type == type &&
@@ -955,7 +956,7 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(u8 type, struct flowi *fl,
 		return NULL;
 
 	read_lock_bh(&xfrm_policy_lock);
-	chain = policy_hash_direct(daddr, saddr, family, dir);
+	chain = policy_hash_direct(&init_net, daddr, saddr, family, dir);
 	ret = NULL;
 	hlist_for_each_entry(pol, entry, chain, bydst) {
 		err = xfrm_policy_match(pol, fl, type, family, dir);
@@ -1070,7 +1071,7 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir, struc
 static void __xfrm_policy_link(struct xfrm_policy *pol, int dir)
 {
 	struct net *net = xp_net(pol);
-	struct hlist_head *chain = policy_hash_bysel(&pol->selector,
+	struct hlist_head *chain = policy_hash_bysel(net, &pol->selector,
 						     pol->family, dir);
 
 	list_add(&pol->walk.all, &net->xfrm.policy_all);
@@ -1116,6 +1117,7 @@ EXPORT_SYMBOL(xfrm_policy_delete);
 
 int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 {
+	struct net *net = xp_net(pol);
 	struct xfrm_policy *old_pol;
 
 #ifdef CONFIG_XFRM_SUB_POLICY
@@ -1128,7 +1130,7 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 	sk->sk_policy[dir] = pol;
 	if (pol) {
 		pol->curlft.add_time = get_seconds();
-		pol->index = xfrm_gen_index(XFRM_POLICY_MAX+dir);
+		pol->index = xfrm_gen_index(net, XFRM_POLICY_MAX+dir);
 		__xfrm_policy_link(pol, XFRM_POLICY_MAX+dir);
 	}
 	if (old_pol)
@@ -2595,7 +2597,7 @@ static struct xfrm_policy * xfrm_migrate_policy_find(struct xfrm_selector *sel,
 	u32 priority = ~0U;
 
 	read_lock_bh(&xfrm_policy_lock);
-	chain = policy_hash_direct(&sel->daddr, &sel->saddr, sel->family, dir);
+	chain = policy_hash_direct(&init_net, &sel->daddr, &sel->saddr, sel->family, dir);
 	hlist_for_each_entry(pol, entry, chain, bydst) {
 		if (xfrm_migrate_selector_match(sel, &pol->selector) &&
 		    pol->type == type) {
-- 
1.5.6.5

