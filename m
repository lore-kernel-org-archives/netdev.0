From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 10/17] xfrm: policy: add sequence count to sync with hash resize
Date: Thu, 8 Sep 2016 07:54:45 +0200
Message-ID: <1473314092-11319-11-git-send-email-steffen.klassert@secunet.com>
References: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36355 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754912AbcIHGv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:51:26 -0400
In-Reply-To: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Once xfrm_policy_lookup_bytype doesn't grab xfrm_policy_lock anymore its
possible for a hash resize to occur in parallel.

Use sequence counter to block lookup in case a resize is in
progress and to also re-lookup in case hash table was altered
in the mean time (might cause use to not find the best-match).

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4a8d90a..576d903 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -49,6 +49,7 @@ static struct xfrm_policy_afinfo __rcu *xfrm_policy_afinfo[NPROTO]
 						__read_mostly;
 
 static struct kmem_cache *xfrm_dst_cache __read_mostly;
+static __read_mostly seqcount_t xfrm_policy_hash_generation;
 
 static void xfrm_init_pmtu(struct dst_entry *dst);
 static int stale_bundle(struct dst_entry *dst);
@@ -479,6 +480,10 @@ static void xfrm_bydst_resize(struct net *net, int dir)
 		return;
 
 	write_lock_bh(&net->xfrm.xfrm_policy_lock);
+	write_seqcount_begin(&xfrm_policy_hash_generation);
+
+	odst = rcu_dereference_protected(net->xfrm.policy_bydst[dir].table,
+				lockdep_is_held(&net->xfrm.xfrm_policy_lock));
 
 	odst = rcu_dereference_protected(net->xfrm.policy_bydst[dir].table,
 				lockdep_is_held(&net->xfrm.xfrm_policy_lock));
@@ -489,6 +494,7 @@ static void xfrm_bydst_resize(struct net *net, int dir)
 	rcu_assign_pointer(net->xfrm.policy_bydst[dir].table, ndst);
 	net->xfrm.policy_bydst[dir].hmask = nhashmask;
 
+	write_seqcount_end(&xfrm_policy_hash_generation);
 	write_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
 	synchronize_rcu();
@@ -1104,7 +1110,8 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 	struct xfrm_policy *pol, *ret;
 	const xfrm_address_t *daddr, *saddr;
 	struct hlist_head *chain;
-	u32 priority = ~0U;
+	unsigned int sequence;
+	u32 priority;
 
 	daddr = xfrm_flowi_daddr(fl, family);
 	saddr = xfrm_flowi_saddr(fl, family);
@@ -1112,7 +1119,13 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 		return NULL;
 
 	read_lock_bh(&net->xfrm.xfrm_policy_lock);
-	chain = policy_hash_direct(net, daddr, saddr, family, dir);
+ retry:
+	do {
+		sequence = read_seqcount_begin(&xfrm_policy_hash_generation);
+		chain = policy_hash_direct(net, daddr, saddr, family, dir);
+	} while (read_seqcount_retry(&xfrm_policy_hash_generation, sequence));
+
+	priority = ~0U;
 	ret = NULL;
 	hlist_for_each_entry_rcu(pol, chain, bydst) {
 		err = xfrm_policy_match(pol, fl, type, family, dir);
@@ -1148,6 +1161,9 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 		}
 	}
 
+	if (read_seqcount_retry(&xfrm_policy_hash_generation, sequence))
+		goto retry;
+
 	xfrm_pol_hold(ret);
 fail:
 	read_unlock_bh(&net->xfrm.xfrm_policy_lock);
@@ -3090,6 +3106,7 @@ static struct pernet_operations __net_initdata xfrm_net_ops = {
 void __init xfrm_init(void)
 {
 	register_pernet_subsys(&xfrm_net_ops);
+	seqcount_init(&xfrm_policy_hash_generation);
 	xfrm_input_init();
 }
 
-- 
1.9.1
