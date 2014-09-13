From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 10/12] net: sched: make cls_u32 lockless
Date: Fri, 12 Sep 2014 20:09:16 -0700
Message-ID: <20140913030914.6249.52999.stgit@nitbit.x32>
References: <20140913025925.6249.12537.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com, jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:61822 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbaIMDJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 23:09:42 -0400
Received: by mail-oi0-f44.google.com with SMTP id x69so1110241oia.31
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 20:09:41 -0700 (PDT)
In-Reply-To: <20140913025925.6249.12537.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make cls_u32 classifier safe to run without holding lock. This patch
converts statistics that are kept in read section u32_classify into
per cpu counters.

This patch was tested with a tight u32 filter add/delete loop while
generating traffic with pktgen. By running pktgen on vlan devices
created on top of a physical device we can hit the qdisc layer
correctly. For ingress qdisc's a loopback cable was used.

for i in {1..100}; do
        q=`echo $i%8|bc`;
        echo -n "u32 tos: iteration $i on queue $q";
        tc filter add dev p3p2 parent $p prio $i u32 match ip tos 0x10 0xff \
                  action skbedit queue_mapping $q;
        sleep 1;
        tc filter del dev p3p2 prio $i;

        echo -n "u32 tos hash table: iteration $i on queue $q";
        tc filter add dev p3p2 parent $p protocol ip prio $i handle 628: u32 divisor 1
        tc filter add dev p3p2 parent $p protocol ip prio $i u32 \
                match ip protocol 17 0xff link 628: offset at 0 mask 0xf00 shift 6 plus 0
        tc filter add dev p3p2 parent $p protocol ip prio $i u32 \
                ht 628:0 match ip tos 0x10 0xff action skbedit queue_mapping $q
        sleep 2;
        tc filter del dev p3p2 prio $i
        sleep 1;
done

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/cls_u32.c |  183 +++++++++++++++++++++++++++++++--------------------
 1 file changed, 110 insertions(+), 73 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index f3227d7..5ed5ac4 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -36,6 +36,7 @@
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/errno.h>
+#include <linux/percpu.h>
 #include <linux/rtnetlink.h>
 #include <linux/skbuff.h>
 #include <linux/bitmap.h>
@@ -44,16 +45,16 @@
 #include <net/pkt_cls.h>
 
 struct tc_u_knode {
-	struct tc_u_knode	*next;
+	struct tc_u_knode __rcu	*next;
 	u32			handle;
-	struct tc_u_hnode	*ht_up;
+	struct tc_u_hnode __rcu	*ht_up;
 	struct tcf_exts		exts;
 #ifdef CONFIG_NET_CLS_IND
 	int			ifindex;
 #endif
 	u8			fshift;
 	struct tcf_result	res;
-	struct tc_u_hnode	*ht_down;
+	struct tc_u_hnode __rcu	*ht_down;
 #ifdef CONFIG_CLS_U32_PERF
 	struct tc_u32_pcnt __percpu *pf;
 #endif
@@ -62,24 +63,28 @@ struct tc_u_knode {
 	u32			mask;
 	u32 __percpu		*pcpu_success;
 #endif
+	struct tcf_proto	*tp;
 	struct tc_u32_sel	sel;
+	struct rcu_head		rcu;
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
@@ -98,7 +103,7 @@ static int u32_classify(struct sk_buff *skb, const struct tcf_proto *tp, struct
 		unsigned int	  off;
 	} stack[TC_U32_MAXDEPTH];
 
-	struct tc_u_hnode *ht = tp->root;
+	struct tc_u_hnode *ht = rcu_dereference_bh(tp->root);
 	unsigned int off = skb_network_offset(skb);
 	struct tc_u_knode *n;
 	int sdepth = 0;
@@ -110,7 +115,7 @@ static int u32_classify(struct sk_buff *skb, const struct tcf_proto *tp, struct
 	int i, r;
 
 next_ht:
-	n = ht->ht[sel];
+	n = rcu_dereference_bh(ht->ht[sel]);
 
 next_knode:
 	if (n) {
@@ -123,7 +128,7 @@ next_knode:
 
 #ifdef CONFIG_CLS_U32_MARK
 		if ((skb->mark & n->mask) != n->val) {
-			n = n->next;
+			n = rcu_dereference_bh(n->next);
 			goto next_knode;
 		} else {
 			__this_cpu_inc(*n->pcpu_success);
@@ -141,7 +146,7 @@ next_knode:
 			if (!data)
 				goto out;
 			if ((*data ^ key->val) & key->mask) {
-				n = n->next;
+				n = rcu_dereference_bh(n->next);
 				goto next_knode;
 			}
 #ifdef CONFIG_CLS_U32_PERF
@@ -149,14 +154,16 @@ next_knode:
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
 				if (!tcf_match_indev(skb, n->ifindex)) {
-					n = n->next;
+					n = rcu_dereference_bh(n->next);
 					goto next_knode;
 				}
 #endif
@@ -165,13 +172,13 @@ check_terminal:
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
 
@@ -182,7 +189,7 @@ check_terminal:
 		stack[sdepth].off = off;
 		sdepth++;
 
-		ht = n->ht_down;
+		ht = rcu_dereference_bh(n->ht_down);
 		sel = 0;
 		if (ht->divisor) {
 			__be32 *data, hdata;
@@ -224,7 +231,7 @@ check_terminal:
 	/* POP */
 	if (sdepth--) {
 		n = stack[sdepth].knode;
-		ht = n->ht_up;
+		ht = rcu_dereference_bh(n->ht_up);
 		off = stack[sdepth].off;
 		goto check_terminal;
 	}
@@ -241,7 +248,9 @@ u32_lookup_ht(struct tc_u_common *tp_c, u32 handle)
 {
 	struct tc_u_hnode *ht;
 
-	for (ht = tp_c->hlist; ht; ht = ht->next)
+	for (ht = rtnl_dereference(tp_c->hlist);
+	     ht;
+	     ht = rtnl_dereference(ht->next))
 		if (ht->handle == handle)
 			break;
 
@@ -258,7 +267,9 @@ u32_lookup_key(struct tc_u_hnode *ht, u32 handle)
 	if (sel > ht->divisor)
 		goto out;
 
-	for (n = ht->ht[sel]; n; n = n->next)
+	for (n = rtnl_dereference(ht->ht[sel]);
+	     n;
+	     n = rtnl_dereference(n->next))
 		if (n->handle == handle)
 			break;
 out:
@@ -272,7 +283,7 @@ static unsigned long u32_get(struct tcf_proto *tp, u32 handle)
 	struct tc_u_common *tp_c = tp->data;
 
 	if (TC_U32_HTID(handle) == TC_U32_ROOT)
-		ht = tp->root;
+		ht = rtnl_dereference(tp->root);
 	else
 		ht = u32_lookup_ht(tp_c, TC_U32_HTID(handle));
 
@@ -293,6 +304,9 @@ static u32 gen_new_htid(struct tc_u_common *tp_c)
 {
 	int i = 0x800;
 
+	/* hgenerator only used inside rtnl lock it is safe to increment
+	 * without read _copy_ update semantics
+	 */
 	do {
 		if (++tp_c->hgenerator == 0x7FF)
 			tp_c->hgenerator = 1;
@@ -328,11 +342,11 @@ static int u32_init(struct tcf_proto *tp)
 	}
 
 	tp_c->refcnt++;
-	root_ht->next = tp_c->hlist;
-	tp_c->hlist = root_ht;
+	RCU_INIT_POINTER(root_ht->next, tp_c->hlist);
+	rcu_assign_pointer(tp_c->hlist, root_ht);
 	root_ht->tp_c = tp_c;
 
-	tp->root = root_ht;
+	rcu_assign_pointer(tp->root, root_ht);
 	tp->data = tp_c;
 	return 0;
 }
@@ -350,19 +364,27 @@ static int u32_destroy_key(struct tcf_proto *tp, struct tc_u_knode *n)
 	return 0;
 }
 
+static void u32_delete_key_rcu(struct rcu_head *rcu)
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
+				RCU_INIT_POINTER(*kp, key->next);
 
-				u32_destroy_key(tp, key);
+				call_rcu(&key->rcu, u32_delete_key_rcu);
 				return 0;
 			}
 		}
@@ -371,16 +393,16 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
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
+			RCU_INIT_POINTER(ht->ht[h],
+					 rtnl_dereference(n->next));
+			call_rcu(&n->rcu, u32_delete_key_rcu);
 		}
 	}
 }
@@ -388,28 +410,31 @@ static void u32_clear_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
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
+			RCU_INIT_POINTER(*hn, ht->next);
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
 
@@ -421,17 +446,16 @@ static void u32_destroy(struct tcf_proto *tp)
 
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
+			RCU_INIT_POINTER(tp_c->hlist, ht->next);
+			kfree_rcu(ht, rcu);
 		}
 
 		kfree(tp_c);
@@ -443,6 +467,7 @@ static void u32_destroy(struct tcf_proto *tp)
 static int u32_delete(struct tcf_proto *tp, unsigned long arg)
 {
 	struct tc_u_hnode *ht = (struct tc_u_hnode *)arg;
+	struct tc_u_hnode *root_ht = rtnl_dereference(tp->root);
 
 	if (ht == NULL)
 		return 0;
@@ -450,7 +475,7 @@ static int u32_delete(struct tcf_proto *tp, unsigned long arg)
 	if (TC_U32_KEY(ht->handle))
 		return u32_delete_key(tp, (struct tc_u_knode *)ht);
 
-	if (tp->root == ht)
+	if (root_ht == ht)
 		return -EINVAL;
 
 	if (ht->refcnt == 1) {
@@ -473,7 +498,9 @@ static u32 gen_new_kid(struct tc_u_hnode *ht, u32 handle)
 	if (!bitmap)
 		return handle | 0xFFF;
 
-	for (n = ht->ht[TC_U32_HASH(handle)]; n; n = n->next)
+	for (n = rtnl_dereference(ht->ht[TC_U32_HASH(handle)]);
+	     n;
+	     n = rtnl_dereference(n->next))
 		set_bit(TC_U32_NODE(n->handle), bitmap);
 
 	i = find_next_zero_bit(bitmap, NR_U32_NODE, 0x800);
@@ -523,10 +550,8 @@ static int u32_set_parms(struct net *net, struct tcf_proto *tp,
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
@@ -606,8 +631,8 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 		ht->divisor = divisor;
 		ht->handle = handle;
 		ht->prio = tp->prio;
-		ht->next = tp_c->hlist;
-		tp_c->hlist = ht;
+		RCU_INIT_POINTER(ht->next, tp_c->hlist);
+		rcu_assign_pointer(tp_c->hlist, ht);
 		*arg = (unsigned long)ht;
 		return 0;
 	}
@@ -615,7 +640,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 	if (tb[TCA_U32_HASH]) {
 		htid = nla_get_u32(tb[TCA_U32_HASH]);
 		if (TC_U32_HTID(htid) == TC_U32_ROOT) {
-			ht = tp->root;
+			ht = rtnl_dereference(tp->root);
 			htid = ht->handle;
 		} else {
 			ht = u32_lookup_ht(tp->data, TC_U32_HTID(htid));
@@ -623,7 +648,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 				return -EINVAL;
 		}
 	} else {
-		ht = tp->root;
+		ht = rtnl_dereference(tp->root);
 		htid = ht->handle;
 	}
 
@@ -660,6 +685,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 	n->handle = handle;
 	n->fshift = s->hmask ? ffs(ntohl(s->hmask)) - 1 : 0;
 	tcf_exts_init(&n->exts, TCA_U32_ACT, TCA_U32_POLICE);
+	n->tp = tp;
 
 #ifdef CONFIG_CLS_U32_MARK
 	n->pcpu_success = alloc_percpu(u32);
@@ -675,21 +701,23 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 
 	err = u32_set_parms(net, tp, base, ht, n, tb, tca[TCA_RATE], ovr);
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
+		RCU_INIT_POINTER(n->next, pins);
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
@@ -705,7 +733,9 @@ static void u32_walk(struct tcf_proto *tp, struct tcf_walker *arg)
 	if (arg->stop)
 		return;
 
-	for (ht = tp_c->hlist; ht; ht = ht->next) {
+	for (ht = rtnl_dereference(tp_c->hlist);
+	     ht;
+	     ht = rtnl_dereference(ht->next)) {
 		if (ht->prio != tp->prio)
 			continue;
 		if (arg->count >= arg->skip) {
@@ -716,7 +746,9 @@ static void u32_walk(struct tcf_proto *tp, struct tcf_walker *arg)
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
@@ -735,6 +767,7 @@ static int u32_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		     struct sk_buff *skb, struct tcmsg *t)
 {
 	struct tc_u_knode *n = (struct tc_u_knode *)fh;
+	struct tc_u_hnode *ht_up, *ht_down;
 	struct nlattr *nest;
 
 	if (n == NULL)
@@ -762,7 +795,9 @@ static int u32_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
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
@@ -770,8 +805,10 @@ static int u32_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
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
