From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 09/12] net: sched: make cls_u32 lockless
Date: Fri, 10 Jan 2014 01:42:43 -0800
Message-ID: <20140110094241.7193.14386.stgit@nitbit.x32>
References: <20140110092041.7193.5952.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:53511 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbaAJJnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 04:43:08 -0500
Received: by mail-oa0-f41.google.com with SMTP id i4so3710728oah.14
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 01:43:07 -0800 (PST)
In-Reply-To: <20140110092041.7193.5952.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make cls_u32 classifier safe to run without holding lock. This patch
converts statistics that are kept in read section u32_classify into
per cpu counters.

This patch needs careful review to be sure the internal data
structures are being handled. With regards to testing simply creating
a u32 filter is not enough the actual structure need to be created
and destroyed under stress for a valid test case.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_u32.c |  258 +++++++++++++++++++++++++++++++++------------------
 1 file changed, 169 insertions(+), 89 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 20f2fb7..1d68d08 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -36,6 +36,7 @@
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/errno.h>
+#include <linux/percpu.h>
 #include <linux/rtnetlink.h>
 #include <linux/skbuff.h>
 #include <net/netlink.h>
@@ -43,40 +44,46 @@
 #include <net/pkt_cls.h>
 
 struct tc_u_knode {
-	struct tc_u_knode	*next;
+	struct tc_u_knode __rcu	*next;
 	u32			handle;
-	struct tc_u_hnode	*ht_up;
+	struct tc_u_hnode __rcu	*ht_up;
 	struct tcf_exts		exts;
 #ifdef CONFIG_NET_CLS_IND
 	char                     indev[IFNAMSIZ];
 #endif
 	u8			fshift;
 	struct tcf_result	res;
-	struct tc_u_hnode	*ht_down;
+	struct tc_u_hnode __rcu	*ht_down;
 #ifdef CONFIG_CLS_U32_PERF
-	struct tc_u32_pcnt	*pf;
+	struct tc_u32_pcnt __percpu *pf;
 #endif
 #ifdef CONFIG_CLS_U32_MARK
-	struct tc_u32_mark	mark;
+	u32			val;
+	u32			mask;
+	u32 __percpu		*pcpu_success;
 #endif
+	struct tcf_proto	*tp;
+	struct rcu_head		rcu;
 	struct tc_u32_sel	sel;
 };
 
 struct tc_u_hnode {
-	struct tc_u_hnode	*next;
+	struct tc_u_hnode __rcu	*next;
 	u32			handle;
 	u32			prio;
 	struct tc_u_common	*tp_c;
 	int			refcnt;
 	unsigned int		divisor;
-	struct tc_u_knode	*ht[1];
+	struct tc_u_knode __rcu	*ht[1];
+	struct rcu_head		rcu;
 };
 
 struct tc_u_common {
-	struct tc_u_hnode	*hlist;
+	struct tc_u_hnode __rcu	*hlist;
 	struct Qdisc		*q;
 	int			refcnt;
 	u32			hgenerator;
+	struct rcu_head		rcu;
 };
 
 static inline unsigned int u32_hash_fold(__be32 key,
@@ -95,7 +102,7 @@ static int u32_classify(struct sk_buff *skb, const struct tcf_proto *tp, struct
 		unsigned int	  off;
 	} stack[TC_U32_MAXDEPTH];
 
-	struct tc_u_hnode *ht = (struct tc_u_hnode *)tp->root;
+	struct tc_u_hnode *ht = (struct tc_u_hnode *) rcu_dereference_bh(tp->root);
 	unsigned int off = skb_network_offset(skb);
 	struct tc_u_knode *n;
 	int sdepth = 0;
@@ -103,27 +110,31 @@ static int u32_classify(struct sk_buff *skb, const struct tcf_proto *tp, struct
 	int sel = 0;
 #ifdef CONFIG_CLS_U32_PERF
 	int j;
+	struct tc_u32_pcnt *pf;
 #endif
 	int i, r;
 
 next_ht:
-	n = ht->ht[sel];
+	n = rcu_dereference_bh(ht->ht[sel]);
 
 next_knode:
 	if (n) {
 		struct tc_u32_key *key = n->sel.keys;
 
 #ifdef CONFIG_CLS_U32_PERF
-		n->pf->rcnt += 1;
+		pf = this_cpu_ptr(n->pf);
+		pf->rcnt += 1;
 		j = 0;
 #endif
 
 #ifdef CONFIG_CLS_U32_MARK
-		if ((skb->mark & n->mark.mask) != n->mark.val) {
-			n = n->next;
+		if ((skb->mark & n->mask) != n->val) {
+			n = rcu_dereference_bh(n->next);
 			goto next_knode;
 		} else {
-			n->mark.success++;
+			u32 *success = this_cpu_ptr(n->pcpu_success);
+
+			*success = *success + 1;
 		}
 #endif
 
@@ -138,37 +149,41 @@ next_knode:
 			if (!data)
 				goto out;
 			if ((*data ^ key->val) & key->mask) {
-				n = n->next;
+				n = rcu_dereference_bh(n->next);
 				goto next_knode;
 			}
 #ifdef CONFIG_CLS_U32_PERF
-			n->pf->kcnts[j] += 1;
+			pf = this_cpu_ptr(n->pf);
+			pf->kcnts[j] += 1;
 			j++;
 #endif
 		}
-		if (n->ht_down == NULL) {
+
+		ht = rcu_dereference_bh(n->ht_down);
+		if (!ht) {
 check_terminal:
 			if (n->sel.flags & TC_U32_TERMINAL) {
 
 				*res = n->res;
 #ifdef CONFIG_NET_CLS_IND
 				if (!tcf_match_indev(skb, n->indev)) {
-					n = n->next;
+					n = rcu_dereference_bh(n->next);
 					goto next_knode;
 				}
 #endif
 #ifdef CONFIG_CLS_U32_PERF
-				n->pf->rhit += 1;
+				pf = this_cpu_ptr(n->pf);
+				pf->rhit += 1;
 #endif
 				r = tcf_exts_exec(skb, &n->exts, res);
 				if (r < 0) {
-					n = n->next;
+					n = rcu_dereference_bh(n->next);
 					goto next_knode;
 				}
 
 				return r;
 			}
-			n = n->next;
+			n = rcu_dereference_bh(n->next);
 			goto next_knode;
 		}
 
@@ -179,7 +194,7 @@ check_terminal:
 		stack[sdepth].off = off;
 		sdepth++;
 
-		ht = n->ht_down;
+		ht = rcu_dereference_bh(n->ht_down);
 		sel = 0;
 		if (ht->divisor) {
 			__be32 *data, hdata;
@@ -221,7 +236,7 @@ check_terminal:
 	/* POP */
 	if (sdepth--) {
 		n = stack[sdepth].knode;
-		ht = n->ht_up;
+		ht = rcu_dereference_bh(n->ht_up);
 		off = stack[sdepth].off;
 		goto check_terminal;
 	}
@@ -238,7 +253,9 @@ u32_lookup_ht(struct tc_u_common *tp_c, u32 handle)
 {
 	struct tc_u_hnode *ht;
 
-	for (ht = tp_c->hlist; ht; ht = ht->next)
+	for (ht = rtnl_dereference(tp_c->hlist);
+	     ht;
+	     ht = rtnl_dereference(ht->next))
 		if (ht->handle == handle)
 			break;
 
@@ -255,7 +272,9 @@ u32_lookup_key(struct tc_u_hnode *ht, u32 handle)
 	if (sel > ht->divisor)
 		goto out;
 
-	for (n = ht->ht[sel]; n; n = n->next)
+	for (n = rtnl_dereference(ht->ht[sel]);
+	     n;
+	     n = rtnl_dereference(n->next))
 		if (n->handle == handle)
 			break;
 out:
@@ -269,7 +288,7 @@ static unsigned long u32_get(struct tcf_proto *tp, u32 handle)
 	struct tc_u_common *tp_c = tp->data;
 
 	if (TC_U32_HTID(handle) == TC_U32_ROOT)
-		ht = tp->root;
+		ht = rtnl_dereference(tp->root);
 	else
 		ht = u32_lookup_ht(tp_c, TC_U32_HTID(handle));
 
@@ -290,6 +309,9 @@ static u32 gen_new_htid(struct tc_u_common *tp_c)
 {
 	int i = 0x800;
 
+	/* hgenerator only used inside rtnl lock it is safe to increment
+	 * without read _copy_ update semantics
+	 */
 	do {
 		if (++tp_c->hgenerator == 0x7FF)
 			tp_c->hgenerator = 1;
@@ -325,11 +347,11 @@ static int u32_init(struct tcf_proto *tp)
 	}
 
 	tp_c->refcnt++;
-	root_ht->next = tp_c->hlist;
-	tp_c->hlist = root_ht;
+	rcu_assign_pointer(root_ht->next, tp_c->hlist);
+	rcu_assign_pointer(tp_c->hlist, root_ht);
 	root_ht->tp_c = tp_c;
 
-	tp->root = root_ht;
+	rcu_assign_pointer(tp->root, root_ht);
 	tp->data = tp_c;
 	return 0;
 }
@@ -341,25 +363,33 @@ static int u32_destroy_key(struct tcf_proto *tp, struct tc_u_knode *n)
 	if (n->ht_down)
 		n->ht_down->refcnt--;
 #ifdef CONFIG_CLS_U32_PERF
-	kfree(n->pf);
+	free_percpu(n->pf);
 #endif
 	kfree(n);
 	return 0;
 }
 
+void __u32_delete_key(struct rcu_head *rcu)
+{
+	struct tc_u_knode *key = container_of(rcu, struct tc_u_knode, rcu);
+
+	u32_destroy_key(key->tp, key);
+}
+
 static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
 {
-	struct tc_u_knode **kp;
+	struct tc_u_knode __rcu **kp;
+	struct tc_u_knode *pkp;
 	struct tc_u_hnode *ht = key->ht_up;
 
 	if (ht) {
-		for (kp = &ht->ht[TC_U32_HASH(key->handle)]; *kp; kp = &(*kp)->next) {
-			if (*kp == key) {
-				tcf_tree_lock(tp);
-				*kp = key->next;
-				tcf_tree_unlock(tp);
+		kp = &ht->ht[TC_U32_HASH(key->handle)];
+		for (pkp = rtnl_dereference(*kp); pkp;
+		     kp = &pkp->next, pkp = rtnl_dereference(*kp)) {
+			if (pkp == key) {
+				rcu_assign_pointer(*kp, key->next);
 
-				u32_destroy_key(tp, key);
+				call_rcu(&key->rcu, __u32_delete_key);
 				return 0;
 			}
 		}
@@ -368,16 +398,15 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
 	return 0;
 }
 
-static void u32_clear_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
+static void u32_clear_hnode(struct tc_u_hnode *ht)
 {
 	struct tc_u_knode *n;
 	unsigned int h;
 
 	for (h = 0; h <= ht->divisor; h++) {
-		while ((n = ht->ht[h]) != NULL) {
-			ht->ht[h] = n->next;
-
-			u32_destroy_key(tp, n);
+		while ((n = rtnl_dereference(ht->ht[h])) != NULL) {
+			rcu_assign_pointer(ht->ht[h], rtnl_dereference(n->next));
+			call_rcu(&n->rcu, __u32_delete_key);
 		}
 	}
 }
@@ -385,28 +414,31 @@ static void u32_clear_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
 static int u32_destroy_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
 {
 	struct tc_u_common *tp_c = tp->data;
-	struct tc_u_hnode **hn;
+	struct tc_u_hnode __rcu **hn;
+	struct tc_u_hnode *phn;
 
 	WARN_ON(ht->refcnt);
 
-	u32_clear_hnode(tp, ht);
+	u32_clear_hnode(ht);
 
-	for (hn = &tp_c->hlist; *hn; hn = &(*hn)->next) {
-		if (*hn == ht) {
-			*hn = ht->next;
-			kfree(ht);
+	hn = &tp_c->hlist;
+	for (phn = rtnl_dereference(*hn);
+	     phn;
+	     hn = &phn->next, phn = rtnl_dereference(*hn)) {
+		if (phn == ht) {
+			rcu_assign_pointer(*hn, ht->next);
+			kfree_rcu(ht, rcu);
 			return 0;
 		}
 	}
 
-	WARN_ON(1);
 	return -ENOENT;
 }
 
 static void u32_destroy(struct tcf_proto *tp)
 {
 	struct tc_u_common *tp_c = tp->data;
-	struct tc_u_hnode *root_ht = tp->root;
+	struct tc_u_hnode *root_ht = rtnl_dereference(tp->root);
 
 	WARN_ON(root_ht == NULL);
 
@@ -418,17 +450,16 @@ static void u32_destroy(struct tcf_proto *tp)
 
 		tp->q->u32_node = NULL;
 
-		for (ht = tp_c->hlist; ht; ht = ht->next) {
+		for (ht = rtnl_dereference(tp_c->hlist);
+		     ht;
+		     ht = rtnl_dereference(ht->next)) {
 			ht->refcnt--;
-			u32_clear_hnode(tp, ht);
+			u32_clear_hnode(ht);
 		}
 
-		while ((ht = tp_c->hlist) != NULL) {
-			tp_c->hlist = ht->next;
-
-			WARN_ON(ht->refcnt != 0);
-
-			kfree(ht);
+		while ((ht = rtnl_dereference(tp_c->hlist)) != NULL) {
+			rcu_assign_pointer(tp_c->hlist, ht->next);
+			kfree_rcu(ht, rcu);
 		}
 
 		kfree(tp_c);
@@ -440,6 +471,7 @@ static void u32_destroy(struct tcf_proto *tp)
 static int u32_delete(struct tcf_proto *tp, unsigned long arg)
 {
 	struct tc_u_hnode *ht = (struct tc_u_hnode *)arg;
+	struct tc_u_hnode *root_ht = rtnl_dereference(tp->root);
 
 	if (ht == NULL)
 		return 0;
@@ -447,7 +479,7 @@ static int u32_delete(struct tcf_proto *tp, unsigned long arg)
 	if (TC_U32_KEY(ht->handle))
 		return u32_delete_key(tp, (struct tc_u_knode *)ht);
 
-	if (tp->root == ht)
+	if (root_ht == ht)
 		return -EINVAL;
 
 	if (ht->refcnt == 1) {
@@ -465,7 +497,9 @@ static u32 gen_new_kid(struct tc_u_hnode *ht, u32 handle)
 	struct tc_u_knode *n;
 	unsigned int i = 0x7FF;
 
-	for (n = ht->ht[TC_U32_HASH(handle)]; n; n = n->next)
+	for (n = rtnl_dereference(ht->ht[TC_U32_HASH(handle)]);
+	     n;
+	     n = rtnl_dereference(n->next))
 		if (i < TC_U32_NODE(n->handle))
 			i = TC_U32_NODE(n->handle);
 	i++;
@@ -512,10 +546,8 @@ static int u32_set_parms(struct net *net, struct tcf_proto *tp,
 			ht_down->refcnt++;
 		}
 
-		tcf_tree_lock(tp);
-		ht_old = n->ht_down;
-		n->ht_down = ht_down;
-		tcf_tree_unlock(tp);
+		ht_old = rtnl_dereference(n->ht_down);
+		rcu_assign_pointer(n->ht_down, ht_down);
 
 		if (ht_old)
 			ht_old->refcnt--;
@@ -527,6 +559,7 @@ static int u32_set_parms(struct net *net, struct tcf_proto *tp,
 
 #ifdef CONFIG_NET_CLS_IND
 	if (tb[TCA_U32_INDEV]) {
+		/* TODO make this a pointer update */
 		err = tcf_change_indev(tp, n->indev, tb[TCA_U32_INDEV]);
 		if (err < 0)
 			goto errout;
@@ -590,8 +623,8 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 		ht->divisor = divisor;
 		ht->handle = handle;
 		ht->prio = tp->prio;
-		ht->next = tp_c->hlist;
-		tp_c->hlist = ht;
+		rcu_assign_pointer(ht->next, tp_c->hlist);
+		rcu_assign_pointer(tp_c->hlist, ht);
 		*arg = (unsigned long)ht;
 		return 0;
 	}
@@ -599,7 +632,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 	if (tb[TCA_U32_HASH]) {
 		htid = nla_get_u32(tb[TCA_U32_HASH]);
 		if (TC_U32_HTID(htid) == TC_U32_ROOT) {
-			ht = tp->root;
+			ht = rtnl_dereference(tp->root);
 			htid = ht->handle;
 		} else {
 			ht = u32_lookup_ht(tp->data, TC_U32_HTID(htid));
@@ -607,7 +640,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 				return -EINVAL;
 		}
 	} else {
-		ht = tp->root;
+		ht = rtnl_dereference(tp->root);
 		htid = ht->handle;
 	}
 
@@ -631,8 +664,9 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 		return -ENOBUFS;
 
 #ifdef CONFIG_CLS_U32_PERF
-	n->pf = kzalloc(sizeof(struct tc_u32_pcnt) + s->nkeys*sizeof(u64), GFP_KERNEL);
-	if (n->pf == NULL) {
+	n->pf = __alloc_percpu(sizeof(struct tc_u32_pcnt) + s->nkeys * sizeof(u64),
+			       __alignof__(struct tc_u32_pcnt));
+	if (!n->pf) {
 		kfree(n);
 		return -ENOBUFS;
 	}
@@ -643,34 +677,39 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 	n->handle = handle;
 	n->fshift = s->hmask ? ffs(ntohl(s->hmask)) - 1 : 0;
 	tcf_exts_init(&n->exts, TCA_U32_ACT, TCA_U32_POLICE);
+	n->tp = tp;
 
 #ifdef CONFIG_CLS_U32_MARK
+	n->pcpu_success = alloc_percpu(u32);
+
 	if (tb[TCA_U32_MARK]) {
 		struct tc_u32_mark *mark;
 
 		mark = nla_data(tb[TCA_U32_MARK]);
-		memcpy(&n->mark, mark, sizeof(struct tc_u32_mark));
-		n->mark.success = 0;
+		n->val = mark->val;
+		n->mask = mark->mask;
 	}
 #endif
 
 	err = u32_set_parms(net, tp, base, ht, n, tb, tca[TCA_RATE]);
 	if (err == 0) {
-		struct tc_u_knode **ins;
-		for (ins = &ht->ht[TC_U32_HASH(handle)]; *ins; ins = &(*ins)->next)
-			if (TC_U32_NODE(handle) < TC_U32_NODE((*ins)->handle))
+		struct tc_u_knode __rcu **ins;
+		struct tc_u_knode *pins;
+
+		ins = &ht->ht[TC_U32_HASH(handle)];
+		for (pins = rtnl_dereference(*ins); pins;
+		     ins = &pins->next, pins = rtnl_dereference(*ins))
+			if (TC_U32_NODE(handle) < TC_U32_NODE(pins->handle))
 				break;
 
-		n->next = *ins;
-		tcf_tree_lock(tp);
-		*ins = n;
-		tcf_tree_unlock(tp);
+		rcu_assign_pointer(n->next, pins);
+		rcu_assign_pointer(*ins, n);
 
 		*arg = (unsigned long)n;
 		return 0;
 	}
 #ifdef CONFIG_CLS_U32_PERF
-	kfree(n->pf);
+	free_percpu(n->pf);
 #endif
 	kfree(n);
 	return err;
@@ -686,7 +725,9 @@ static void u32_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	if (arg->stop)
 		return;
 
-	for (ht = tp_c->hlist; ht; ht = ht->next) {
+	for (ht = rtnl_dereference(tp_c->hlist);
+	     ht;
+	     ht = rtnl_dereference(ht->next)) {
 		if (ht->prio != tp->prio)
 			continue;
 		if (arg->count >= arg->skip) {
@@ -697,7 +738,9 @@ static void u32_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 		}
 		arg->count++;
 		for (h = 0; h <= ht->divisor; h++) {
-			for (n = ht->ht[h]; n; n = n->next) {
+			for (n = rtnl_dereference(ht->ht[h]);
+			     n;
+			     n = rtnl_dereference(n->next)) {
 				if (arg->count < arg->skip) {
 					arg->count++;
 					continue;
@@ -716,6 +759,7 @@ static int u32_dump(struct tcf_proto *tp, unsigned long fh,
 		     struct sk_buff *skb, struct tcmsg *t)
 {
 	struct tc_u_knode *n = (struct tc_u_knode *)fh;
+	struct tc_u_hnode *ht_up, *ht_down;
 	struct nlattr *nest;
 
 	if (n == NULL)
@@ -734,11 +778,18 @@ static int u32_dump(struct tcf_proto *tp, unsigned long fh,
 		if (nla_put_u32(skb, TCA_U32_DIVISOR, divisor))
 			goto nla_put_failure;
 	} else {
+#ifdef CONFIG_CLS_U32_PERF
+		struct tc_u32_pcnt *gpf;
+#endif
+		int cpu;
+
 		if (nla_put(skb, TCA_U32_SEL,
 			    sizeof(n->sel) + n->sel.nkeys*sizeof(struct tc_u32_key),
 			    &n->sel))
 			goto nla_put_failure;
-		if (n->ht_up) {
+
+		ht_up = rtnl_dereference(n->ht_up);
+		if (ht_up) {
 			u32 htid = n->handle & 0xFFFFF000;
 			if (nla_put_u32(skb, TCA_U32_HASH, htid))
 				goto nla_put_failure;
@@ -746,14 +797,24 @@ static int u32_dump(struct tcf_proto *tp, unsigned long fh,
 		if (n->res.classid &&
 		    nla_put_u32(skb, TCA_U32_CLASSID, n->res.classid))
 			goto nla_put_failure;
-		if (n->ht_down &&
-		    nla_put_u32(skb, TCA_U32_LINK, n->ht_down->handle))
+
+		ht_down = rtnl_dereference(n->ht_down);
+		if (ht_down &&
+		    nla_put_u32(skb, TCA_U32_LINK, ht_down->handle))
 			goto nla_put_failure;
 
 #ifdef CONFIG_CLS_U32_MARK
-		if ((n->mark.val || n->mark.mask) &&
-		    nla_put(skb, TCA_U32_MARK, sizeof(n->mark), &n->mark))
-			goto nla_put_failure;
+		if ((n->val || n->mask)) {
+			struct tc_u32_mark mark = {.val = n->val,
+						   .mask = n->mask,
+						   .success = 0};
+
+			for_each_possible_cpu(cpu)
+				mark.success += *per_cpu_ptr(n->pcpu_success, cpu);
+
+			if (nla_put(skb, TCA_U32_MARK, sizeof(mark), &mark))
+				goto nla_put_failure;
+		}
 #endif
 
 		if (tcf_exts_dump(skb, &n->exts) < 0)
@@ -765,10 +826,29 @@ static int u32_dump(struct tcf_proto *tp, unsigned long fh,
 			goto nla_put_failure;
 #endif
 #ifdef CONFIG_CLS_U32_PERF
+		gpf = kzalloc(sizeof(struct tc_u32_pcnt) +
+					n->sel.nkeys * sizeof(u64),
+			      GFP_KERNEL);
+		if (!gpf)
+			goto nla_put_failure;
+
+		for_each_possible_cpu(cpu) {
+			int i;
+			struct tc_u32_pcnt *pf = per_cpu_ptr(n->pf, cpu);
+
+			gpf->rcnt += pf->rcnt;
+			gpf->rhit += pf->rhit;
+			for (i = 0; i < n->sel.nkeys; i++)
+				gpf->kcnts[i] += pf->kcnts[i];
+		}
+
 		if (nla_put(skb, TCA_U32_PCNT,
 			    sizeof(struct tc_u32_pcnt) + n->sel.nkeys*sizeof(u64),
-			    n->pf))
+			    gpf)) {
+			kfree(gpf);
 			goto nla_put_failure;
+		}
+		kfree(gpf);
 #endif
 	}
 
