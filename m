From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 26/32] netfilter: ipset: Introduce RCU locking in list type
Date: Mon, 15 Jun 2015 23:26:23 +0200
Message-ID: <1434403589-24796-27-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Standard rculist is used.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_list_set.c |  398 ++++++++++++++++-----------------
 1 file changed, 189 insertions(+), 209 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 107ea6c..9f624ee 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -9,6 +9,7 @@
 
 #include <linux/module.h>
 #include <linux/ip.h>
+#include <linux/rculist.h>
 #include <linux/skbuff.h>
 #include <linux/errno.h>
 
@@ -27,6 +28,8 @@ MODULE_ALIAS("ip_set_list:set");
 
 /* Member elements  */
 struct set_elem {
+	struct rcu_head rcu;
+	struct list_head list;
 	ip_set_id_t id;
 };
 
@@ -41,12 +44,9 @@ struct list_set {
 	u32 size;		/* size of set list array */
 	struct timer_list gc;	/* garbage collection */
 	struct net *net;	/* namespace */
-	struct set_elem members[0]; /* the set members */
+	struct list_head members; /* the set members */
 };
 
-#define list_set_elem(set, map, id)	\
-	(struct set_elem *)((void *)(map)->members + (id) * (set)->dsize)
-
 static int
 list_set_ktest(struct ip_set *set, const struct sk_buff *skb,
 	       const struct xt_action_param *par,
@@ -54,17 +54,14 @@ list_set_ktest(struct ip_set *set, const struct sk_buff *skb,
 {
 	struct list_set *map = set->data;
 	struct set_elem *e;
-	u32 i, cmdflags = opt->cmdflags;
+	u32 cmdflags = opt->cmdflags;
 	int ret;
 
 	/* Don't lookup sub-counters at all */
 	opt->cmdflags &= ~IPSET_FLAG_MATCH_COUNTERS;
 	if (opt->cmdflags & IPSET_FLAG_SKIP_SUBCOUNTER_UPDATE)
 		opt->cmdflags &= ~IPSET_FLAG_SKIP_COUNTER_UPDATE;
-	for (i = 0; i < map->size; i++) {
-		e = list_set_elem(set, map, i);
-		if (e->id == IPSET_INVALID_ID)
-			return 0;
+	list_for_each_entry_rcu(e, &map->members, list) {
 		if (SET_WITH_TIMEOUT(set) &&
 		    ip_set_timeout_expired(ext_timeout(e, set)))
 			continue;
@@ -91,13 +88,9 @@ list_set_kadd(struct ip_set *set, const struct sk_buff *skb,
 {
 	struct list_set *map = set->data;
 	struct set_elem *e;
-	u32 i;
 	int ret;
 
-	for (i = 0; i < map->size; i++) {
-		e = list_set_elem(set, map, i);
-		if (e->id == IPSET_INVALID_ID)
-			return 0;
+	list_for_each_entry(e, &map->members, list) {
 		if (SET_WITH_TIMEOUT(set) &&
 		    ip_set_timeout_expired(ext_timeout(e, set)))
 			continue;
@@ -115,13 +108,9 @@ list_set_kdel(struct ip_set *set, const struct sk_buff *skb,
 {
 	struct list_set *map = set->data;
 	struct set_elem *e;
-	u32 i;
 	int ret;
 
-	for (i = 0; i < map->size; i++) {
-		e = list_set_elem(set, map, i);
-		if (e->id == IPSET_INVALID_ID)
-			return 0;
+	list_for_each_entry(e, &map->members, list) {
 		if (SET_WITH_TIMEOUT(set) &&
 		    ip_set_timeout_expired(ext_timeout(e, set)))
 			continue;
@@ -138,110 +127,65 @@ list_set_kadt(struct ip_set *set, const struct sk_buff *skb,
 	      enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
+	int ret = -EINVAL;
 
+	rcu_read_lock();
 	switch (adt) {
 	case IPSET_TEST:
-		return list_set_ktest(set, skb, par, opt, &ext);
+		ret = list_set_ktest(set, skb, par, opt, &ext);
+		break;
 	case IPSET_ADD:
-		return list_set_kadd(set, skb, par, opt, &ext);
+		ret = list_set_kadd(set, skb, par, opt, &ext);
+		break;
 	case IPSET_DEL:
-		return list_set_kdel(set, skb, par, opt, &ext);
+		ret = list_set_kdel(set, skb, par, opt, &ext);
+		break;
 	default:
 		break;
 	}
-	return -EINVAL;
-}
-
-static bool
-id_eq(const struct ip_set *set, u32 i, ip_set_id_t id)
-{
-	const struct list_set *map = set->data;
-	const struct set_elem *e;
-
-	if (i >= map->size)
-		return 0;
+	rcu_read_unlock();
 
-	e = list_set_elem(set, map, i);
-	return !!(e->id == id &&
-		 !(SET_WITH_TIMEOUT(set) &&
-		   ip_set_timeout_expired(ext_timeout(e, set))));
+	return ret;
 }
 
-static int
-list_set_add(struct ip_set *set, u32 i, struct set_adt_elem *d,
-	     const struct ip_set_ext *ext)
-{
-	struct list_set *map = set->data;
-	struct set_elem *e = list_set_elem(set, map, i);
-
-	if (e->id != IPSET_INVALID_ID) {
-		if (i == map->size - 1) {
-			/* Last element replaced: e.g. add new,before,last */
-			ip_set_put_byindex(map->net, e->id);
-			ip_set_ext_destroy(set, e);
-		} else {
-			struct set_elem *x = list_set_elem(set, map,
-							   map->size - 1);
-
-			/* Last element pushed off */
-			if (x->id != IPSET_INVALID_ID) {
-				ip_set_put_byindex(map->net, x->id);
-				ip_set_ext_destroy(set, x);
-			}
-			memmove(list_set_elem(set, map, i + 1), e,
-				set->dsize * (map->size - (i + 1)));
-			/* Extensions must be initialized to zero */
-			memset(e, 0, set->dsize);
-		}
-	}
-
-	e->id = d->id;
-	if (SET_WITH_TIMEOUT(set))
-		ip_set_timeout_set(ext_timeout(e, set), ext->timeout);
-	if (SET_WITH_COUNTER(set))
-		ip_set_init_counter(ext_counter(e, set), ext);
-	if (SET_WITH_COMMENT(set))
-		ip_set_init_comment(ext_comment(e, set), ext);
-	if (SET_WITH_SKBINFO(set))
-		ip_set_init_skbinfo(ext_skbinfo(e, set), ext);
-	return 0;
-}
+/* Userspace interfaces: we are protected by the nfnl mutex */
 
-static int
-list_set_del(struct ip_set *set, u32 i)
+static void
+__list_set_del(struct ip_set *set, struct set_elem *e)
 {
 	struct list_set *map = set->data;
-	struct set_elem *e = list_set_elem(set, map, i);
 
 	ip_set_put_byindex(map->net, e->id);
+	/* We may call it, because we don't have a to be destroyed
+	 * extension which is used by the kernel.
+	 */
 	ip_set_ext_destroy(set, e);
+	kfree_rcu(e, rcu);
+}
 
-	if (i < map->size - 1)
-		memmove(e, list_set_elem(set, map, i + 1),
-			set->dsize * (map->size - (i + 1)));
+static inline void
+list_set_del(struct ip_set *set, struct set_elem *e)
+{
+	list_del_rcu(&e->list);
+	__list_set_del(set, e);
+}
 
-	/* Last element */
-	e = list_set_elem(set, map, map->size - 1);
-	e->id = IPSET_INVALID_ID;
-	return 0;
+static inline void
+list_set_replace(struct ip_set *set, struct set_elem *e, struct set_elem *old)
+{
+	list_replace_rcu(&old->list, &e->list);
+	__list_set_del(set, old);
 }
 
 static void
 set_cleanup_entries(struct ip_set *set)
 {
 	struct list_set *map = set->data;
-	struct set_elem *e;
-	u32 i = 0;
+	struct set_elem *e, *n;
 
-	while (i < map->size) {
-		e = list_set_elem(set, map, i);
-		if (e->id != IPSET_INVALID_ID &&
-		    ip_set_timeout_expired(ext_timeout(e, set)))
-			list_set_del(set, i);
-			/* Check element moved to position i in next loop */
-		else
-			i++;
-	}
+	list_for_each_entry_safe(e, n, &map->members, list)
+		if (ip_set_timeout_expired(ext_timeout(e, set)))
+			list_set_del(set, e);
 }
 
 static int
@@ -250,31 +194,45 @@ list_set_utest(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 {
 	struct list_set *map = set->data;
 	struct set_adt_elem *d = value;
-	struct set_elem *e;
-	u32 i;
+	struct set_elem *e, *next, *prev = NULL;
 	int ret;
 
-	for (i = 0; i < map->size; i++) {
-		e = list_set_elem(set, map, i);
-		if (e->id == IPSET_INVALID_ID)
-			return 0;
-		else if (SET_WITH_TIMEOUT(set) &&
-			 ip_set_timeout_expired(ext_timeout(e, set)))
+	list_for_each_entry(e, &map->members, list) {
+		if (SET_WITH_TIMEOUT(set) &&
+		    ip_set_timeout_expired(ext_timeout(e, set)))
 			continue;
-		else if (e->id != d->id)
+		else if (e->id != d->id) {
+			prev = e;
 			continue;
+		}
 
 		if (d->before == 0)
-			return 1;
-		else if (d->before > 0)
-			ret = id_eq(set, i + 1, d->refid);
-		else
-			ret = i > 0 && id_eq(set, i - 1, d->refid);
+			ret = 1;
+		else if (d->before > 0) {
+			next = list_next_entry(e, list);
+			ret = !list_is_last(&e->list, &map->members) &&
+			      next->id == d->refid;
+		} else
+			ret = prev && prev->id == d->refid;
 		return ret;
 	}
 	return 0;
 }
 
+static void
+list_set_init_extensions(struct ip_set *set, const struct ip_set_ext *ext,
+			 struct set_elem *e)
+{
+	if (SET_WITH_COUNTER(set))
+		ip_set_init_counter(ext_counter(e, set), ext);
+	if (SET_WITH_COMMENT(set))
+		ip_set_init_comment(ext_comment(e, set), ext);
+	if (SET_WITH_SKBINFO(set))
+		ip_set_init_skbinfo(ext_skbinfo(e, set), ext);
+	/* Update timeout last */
+	if (SET_WITH_TIMEOUT(set))
+		ip_set_timeout_set(ext_timeout(e, set), ext->timeout);
+}
 
 static int
 list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
@@ -282,60 +240,78 @@ list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 {
 	struct list_set *map = set->data;
 	struct set_adt_elem *d = value;
-	struct set_elem *e;
+	struct set_elem *e, *n, *prev, *next;
 	bool flag_exist = flags & IPSET_FLAG_EXIST;
-	u32 i, ret = 0;
 
 	if (SET_WITH_TIMEOUT(set))
 		set_cleanup_entries(set);
 
-	/* Check already added element */
-	for (i = 0; i < map->size; i++) {
-		e = list_set_elem(set, map, i);
-		if (e->id == IPSET_INVALID_ID)
-			goto insert;
-		else if (e->id != d->id)
+	/* Find where to add the new entry */
+	n = prev = next = NULL;
+	list_for_each_entry(e, &map->members, list) {
+		if (SET_WITH_TIMEOUT(set) &&
+		    ip_set_timeout_expired(ext_timeout(e, set)))
 			continue;
-
-		if ((d->before > 1 && !id_eq(set, i + 1, d->refid)) ||
-		    (d->before < 0 &&
-		     (i == 0 || !id_eq(set, i - 1, d->refid))))
-			/* Before/after doesn't match */
+		else if (d->id == e->id)
+			n = e;
+		else if (d->before == 0 || e->id != d->refid)
+			continue;
+		else if (d->before > 0)
+			next = e;
+		else
+			prev = e;
+	}
+	/* Re-add already existing element */
+	if (n) {
+		if ((d->before > 0 && !next) ||
+		    (d->before < 0 && !prev))
 			return -IPSET_ERR_REF_EXIST;
 		if (!flag_exist)
-			/* Can't re-add */
 			return -IPSET_ERR_EXIST;
 		/* Update extensions */
-		ip_set_ext_destroy(set, e);
+		ip_set_ext_destroy(set, n);
+		list_set_init_extensions(set, ext, n);
 
-		if (SET_WITH_TIMEOUT(set))
-			ip_set_timeout_set(ext_timeout(e, set), ext->timeout);
-		if (SET_WITH_COUNTER(set))
-			ip_set_init_counter(ext_counter(e, set), ext);
-		if (SET_WITH_COMMENT(set))
-			ip_set_init_comment(ext_comment(e, set), ext);
-		if (SET_WITH_SKBINFO(set))
-			ip_set_init_skbinfo(ext_skbinfo(e, set), ext);
 		/* Set is already added to the list */
 		ip_set_put_byindex(map->net, d->id);
 		return 0;
 	}
-insert:
-	ret = -IPSET_ERR_LIST_FULL;
-	for (i = 0; i < map->size && ret == -IPSET_ERR_LIST_FULL; i++) {
-		e = list_set_elem(set, map, i);
-		if (e->id == IPSET_INVALID_ID)
-			ret = d->before != 0 ? -IPSET_ERR_REF_EXIST
-				: list_set_add(set, i, d, ext);
-		else if (e->id != d->refid)
-			continue;
-		else if (d->before > 0)
-			ret = list_set_add(set, i, d, ext);
-		else if (i + 1 < map->size)
-			ret = list_set_add(set, i + 1, d, ext);
+	/* Add new entry */
+	if (d->before == 0) {
+		/* Append  */
+		n = list_empty(&map->members) ? NULL :
+		    list_last_entry(&map->members, struct set_elem, list);
+	} else if (d->before > 0) {
+		/* Insert after next element */
+		if (!list_is_last(&next->list, &map->members))
+			n = list_next_entry(next, list);
+	} else {
+		/* Insert before prev element */
+		if (prev->list.prev != &map->members)
+			n = list_prev_entry(prev, list);
 	}
+	/* Can we replace a timed out entry? */
+	if (n &&
+	    !(SET_WITH_TIMEOUT(set) &&
+	      ip_set_timeout_expired(ext_timeout(n, set))))
+		n =  NULL;
+
+	e = kzalloc(set->dsize, GFP_KERNEL);
+	if (!e)
+		return -ENOMEM;
+	e->id = d->id;
+	INIT_LIST_HEAD(&e->list);
+	list_set_init_extensions(set, ext, e);
+	if (n)
+		list_set_replace(set, e, n);
+	else if (next)
+		list_add_tail_rcu(&e->list, &next->list);
+	else if (prev)
+		list_add_rcu(&e->list, &prev->list);
+	else
+		list_add_tail_rcu(&e->list, &map->members);
 
-	return ret;
+	return 0;
 }
 
 static int
@@ -344,32 +320,30 @@ list_set_udel(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 {
 	struct list_set *map = set->data;
 	struct set_adt_elem *d = value;
-	struct set_elem *e;
-	u32 i;
-
-	for (i = 0; i < map->size; i++) {
-		e = list_set_elem(set, map, i);
-		if (e->id == IPSET_INVALID_ID)
-			return d->before != 0 ? -IPSET_ERR_REF_EXIST
-					      : -IPSET_ERR_EXIST;
-		else if (SET_WITH_TIMEOUT(set) &&
-			 ip_set_timeout_expired(ext_timeout(e, set)))
+	struct set_elem *e, *next, *prev = NULL;
+
+	list_for_each_entry(e, &map->members, list) {
+		if (SET_WITH_TIMEOUT(set) &&
+		    ip_set_timeout_expired(ext_timeout(e, set)))
 			continue;
-		else if (e->id != d->id)
+		else if (e->id != d->id) {
+			prev = e;
 			continue;
+		}
 
-		if (d->before == 0)
-			return list_set_del(set, i);
-		else if (d->before > 0) {
-			if (!id_eq(set, i + 1, d->refid))
+		if (d->before > 0) {
+			next = list_next_entry(e, list);
+			if (list_is_last(&e->list, &map->members) ||
+			    next->id != d->refid)
 				return -IPSET_ERR_REF_EXIST;
-			return list_set_del(set, i);
-		} else if (i == 0 || !id_eq(set, i - 1, d->refid))
-			return -IPSET_ERR_REF_EXIST;
-		else
-			return list_set_del(set, i);
+		} else if (d->before < 0) {
+			if (!prev || prev->id != d->refid)
+				return -IPSET_ERR_REF_EXIST;
+		}
+		list_set_del(set, e);
+		return 0;
 	}
-	return -IPSET_ERR_EXIST;
+	return d->before != 0 ? -IPSET_ERR_REF_EXIST : -IPSET_ERR_EXIST;
 }
 
 static int
@@ -404,6 +378,7 @@ list_set_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (tb[IPSET_ATTR_CADT_FLAGS]) {
 		u32 f = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
+
 		e.before = f & IPSET_FLAG_BEFORE;
 	}
 
@@ -441,27 +416,26 @@ static void
 list_set_flush(struct ip_set *set)
 {
 	struct list_set *map = set->data;
-	struct set_elem *e;
-	u32 i;
-
-	for (i = 0; i < map->size; i++) {
-		e = list_set_elem(set, map, i);
-		if (e->id != IPSET_INVALID_ID) {
-			ip_set_put_byindex(map->net, e->id);
-			ip_set_ext_destroy(set, e);
-			e->id = IPSET_INVALID_ID;
-		}
-	}
+	struct set_elem *e, *n;
+
+	list_for_each_entry_safe(e, n, &map->members, list)
+		list_set_del(set, e);
 }
 
 static void
 list_set_destroy(struct ip_set *set)
 {
 	struct list_set *map = set->data;
+	struct set_elem *e, *n;
 
 	if (SET_WITH_TIMEOUT(set))
 		del_timer_sync(&map->gc);
-	list_set_flush(set);
+	list_for_each_entry_safe(e, n, &map->members, list) {
+		list_del(&e->list);
+		ip_set_put_byindex(map->net, e->id);
+		ip_set_ext_destroy(set, e);
+		kfree(e);
+	}
 	kfree(map);
 
 	set->data = NULL;
@@ -472,6 +446,11 @@ list_set_head(struct ip_set *set, struct sk_buff *skb)
 {
 	const struct list_set *map = set->data;
 	struct nlattr *nested;
+	struct set_elem *e;
+	u32 n = 0;
+
+	list_for_each_entry(e, &map->members, list)
+		n++;
 
 	nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
 	if (!nested)
@@ -479,7 +458,7 @@ list_set_head(struct ip_set *set, struct sk_buff *skb)
 	if (nla_put_net32(skb, IPSET_ATTR_SIZE, htonl(map->size)) ||
 	    nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
 	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE,
-			  htonl(sizeof(*map) + map->size * set->dsize)))
+			  htonl(sizeof(*map) + n * set->dsize)))
 		goto nla_put_failure;
 	if (unlikely(ip_set_put_flags(skb, set)))
 		goto nla_put_failure;
@@ -496,18 +475,22 @@ list_set_list(const struct ip_set *set,
 {
 	const struct list_set *map = set->data;
 	struct nlattr *atd, *nested;
-	u32 i, first = cb->args[IPSET_CB_ARG0];
-	const struct set_elem *e;
+	u32 i = 0, first = cb->args[IPSET_CB_ARG0];
+	struct set_elem *e;
+	int ret = 0;
 
 	atd = ipset_nest_start(skb, IPSET_ATTR_ADT);
 	if (!atd)
 		return -EMSGSIZE;
-	for (; cb->args[IPSET_CB_ARG0] < map->size;
-	     cb->args[IPSET_CB_ARG0]++) {
-		i = cb->args[IPSET_CB_ARG0];
-		e = list_set_elem(set, map, i);
-		if (e->id == IPSET_INVALID_ID)
-			goto finish;
+	list_for_each_entry(e, &map->members, list) {
+		if (i == first)
+			break;
+		i++;
+	}
+
+	rcu_read_lock();
+	list_for_each_entry_from(e, &map->members, list) {
+		i++;
 		if (SET_WITH_TIMEOUT(set) &&
 		    ip_set_timeout_expired(ext_timeout(e, set)))
 			continue;
@@ -515,9 +498,10 @@ list_set_list(const struct ip_set *set,
 		if (!nested) {
 			if (i == first) {
 				nla_nest_cancel(skb, atd);
-				return -EMSGSIZE;
-			} else
-				goto nla_put_failure;
+				ret = -EMSGSIZE;
+				goto out;
+			}
+			goto nla_put_failure;
 		}
 		if (nla_put_string(skb, IPSET_ATTR_NAME,
 				   ip_set_name_byindex(map->net, e->id)))
@@ -526,20 +510,23 @@ list_set_list(const struct ip_set *set,
 			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
-finish:
+
 	ipset_nest_end(skb, atd);
 	/* Set listing finished */
 	cb->args[IPSET_CB_ARG0] = 0;
-	return 0;
+	goto out;
 
 nla_put_failure:
 	nla_nest_cancel(skb, nested);
 	if (unlikely(i == first)) {
 		cb->args[IPSET_CB_ARG0] = 0;
-		return -EMSGSIZE;
+		ret = -EMSGSIZE;
 	}
+	cb->args[IPSET_CB_ARG0] = i - 1;
 	ipset_nest_end(skb, atd);
-	return 0;
+out:
+	rcu_read_unlock();
+	return ret;
 }
 
 static bool
@@ -574,9 +561,9 @@ list_set_gc(unsigned long ul_set)
 	struct ip_set *set = (struct ip_set *) ul_set;
 	struct list_set *map = set->data;
 
-	write_lock_bh(&set->lock);
+	spin_lock_bh(&set->lock);
 	set_cleanup_entries(set);
-	write_unlock_bh(&set->lock);
+	spin_unlock_bh(&set->lock);
 
 	map->gc.expires = jiffies + IPSET_GC_PERIOD(set->timeout) * HZ;
 	add_timer(&map->gc);
@@ -600,24 +587,16 @@ static bool
 init_list_set(struct net *net, struct ip_set *set, u32 size)
 {
 	struct list_set *map;
-	struct set_elem *e;
-	u32 i;
 
-	map = kzalloc(sizeof(*map) +
-		      min_t(u32, size, IP_SET_LIST_MAX_SIZE) * set->dsize,
-		      GFP_KERNEL);
+	map = kzalloc(sizeof(*map), GFP_KERNEL);
 	if (!map)
 		return false;
 
 	map->size = size;
 	map->net = net;
+	INIT_LIST_HEAD(&map->members);
 	set->data = map;
 
-	for (i = 0; i < size; i++) {
-		e = list_set_elem(set, map, i);
-		e->id = IPSET_INVALID_ID;
-	}
-
 	return true;
 }
 
@@ -690,6 +669,7 @@ list_set_init(void)
 static void __exit
 list_set_fini(void)
 {
+	rcu_barrier();
 	ip_set_type_unregister(&list_set_type);
 }
 
-- 
1.7.10.4

