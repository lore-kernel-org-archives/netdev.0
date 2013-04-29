From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/18] netfilter: ipset: list:set type using the extension interface
Date: Mon, 29 Apr 2013 20:22:14 +0200
Message-ID: <1367259744-8922-9-git-send-email-pablo@netfilter.org>
References: <1367259744-8922-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41449 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758709Ab3D2SW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 14:22:56 -0400
In-Reply-To: <1367259744-8922-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_list_set.c |  547 ++++++++++++++++++---------------
 1 file changed, 301 insertions(+), 246 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 09c744a..919eefe 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2008-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+/* Copyright (C) 2008-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -13,7 +13,6 @@
 #include <linux/errno.h>
 
 #include <linux/netfilter/ipset/ip_set.h>
-#include <linux/netfilter/ipset/ip_set_timeout.h>
 #include <linux/netfilter/ipset/ip_set_list.h>
 
 #define REVISION_MIN	0
@@ -24,19 +23,28 @@ MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
 IP_SET_MODULE_DESC("list:set", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_list:set");
 
-/* Member elements without and with timeout */
+/* Member elements  */
 struct set_elem {
 	ip_set_id_t id;
 };
 
-struct set_telem {
-	ip_set_id_t id;
+struct sett_elem {
+	struct {
+		ip_set_id_t id;
+	} __attribute__ ((aligned));
 	unsigned long timeout;
 };
 
+struct set_adt_elem {
+	ip_set_id_t id;
+	ip_set_id_t refid;
+	int before;
+};
+
 /* Type structure */
 struct list_set {
 	size_t dsize;		/* element size */
+	size_t offset[IPSET_OFFSET_MAX]; /* Offsets to extensions */
 	u32 size;		/* size of set list array */
 	u32 timeout;		/* timeout value */
 	struct timer_list gc;	/* garbage collection */
@@ -49,179 +57,296 @@ list_set_elem(const struct list_set *map, u32 id)
 	return (struct set_elem *)((void *)map->members + id * map->dsize);
 }
 
-static inline struct set_telem *
-list_set_telem(const struct list_set *map, u32 id)
-{
-	return (struct set_telem *)((void *)map->members + id * map->dsize);
-}
+#define ext_timeout(e, m)	\
+(unsigned long *)((void *)(e) + (m)->offset[IPSET_OFFSET_TIMEOUT])
 
-static inline bool
-list_set_timeout(const struct list_set *map, u32 id)
+static int
+list_set_ktest(struct ip_set *set, const struct sk_buff *skb,
+	       const struct xt_action_param *par,
+	       struct ip_set_adt_opt *opt, const struct ip_set_ext *ext)
 {
-	const struct set_telem *elem = list_set_telem(map, id);
+	struct list_set *map = set->data;
+	struct set_elem *e;
+	u32 i;
+	int ret;
 
-	return ip_set_timeout_test(elem->timeout);
+	for (i = 0; i < map->size; i++) {
+		e = list_set_elem(map, i);
+		if (e->id == IPSET_INVALID_ID)
+			return 0;
+		if (SET_WITH_TIMEOUT(set) &&
+		    ip_set_timeout_expired(ext_timeout(e, map)))
+			continue;
+		ret = ip_set_test(e->id, skb, par, opt);
+		if (ret > 0)
+			return ret;
+	}
+	return 0;
 }
 
-static inline bool
-list_set_expired(const struct list_set *map, u32 id)
+static int
+list_set_kadd(struct ip_set *set, const struct sk_buff *skb,
+	      const struct xt_action_param *par,
+	      struct ip_set_adt_opt *opt, const struct ip_set_ext *ext)
 {
-	const struct set_telem *elem = list_set_telem(map, id);
+	struct list_set *map = set->data;
+	struct set_elem *e;
+	u32 i;
+	int ret;
 
-	return ip_set_timeout_expired(elem->timeout);
+	for (i = 0; i < map->size; i++) {
+		e = list_set_elem(map, i);
+		if (e->id == IPSET_INVALID_ID)
+			return 0;
+		if (SET_WITH_TIMEOUT(set) &&
+		    ip_set_timeout_expired(ext_timeout(e, map)))
+			continue;
+		ret = ip_set_add(e->id, skb, par, opt);
+		if (ret == 0)
+			return ret;
+	}
+	return 0;
 }
 
-/* Set list without and with timeout */
-
 static int
-list_set_kadt(struct ip_set *set, const struct sk_buff *skb,
+list_set_kdel(struct ip_set *set, const struct sk_buff *skb,
 	      const struct xt_action_param *par,
-	      enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+	      struct ip_set_adt_opt *opt, const struct ip_set_ext *ext)
 {
 	struct list_set *map = set->data;
-	struct set_elem *elem;
+	struct set_elem *e;
 	u32 i;
 	int ret;
 
 	for (i = 0; i < map->size; i++) {
-		elem = list_set_elem(map, i);
-		if (elem->id == IPSET_INVALID_ID)
+		e = list_set_elem(map, i);
+		if (e->id == IPSET_INVALID_ID)
 			return 0;
-		if (with_timeout(map->timeout) && list_set_expired(map, i))
+		if (SET_WITH_TIMEOUT(set) &&
+		    ip_set_timeout_expired(ext_timeout(e, map)))
 			continue;
-		switch (adt) {
-		case IPSET_TEST:
-			ret = ip_set_test(elem->id, skb, par, opt);
-			if (ret > 0)
-				return ret;
-			break;
-		case IPSET_ADD:
-			ret = ip_set_add(elem->id, skb, par, opt);
-			if (ret == 0)
-				return ret;
-			break;
-		case IPSET_DEL:
-			ret = ip_set_del(elem->id, skb, par, opt);
-			if (ret == 0)
-				return ret;
-			break;
-		default:
-			break;
-		}
+		ret = ip_set_del(e->id, skb, par, opt);
+		if (ret == 0)
+			return ret;
+	}
+	return 0;
+}
+
+static int
+list_set_kadt(struct ip_set *set, const struct sk_buff *skb,
+	      const struct xt_action_param *par,
+	      enum ipset_adt adt, struct ip_set_adt_opt *opt)
+{
+	struct list_set *map = set->data;
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, map);
+
+	switch (adt) {
+	case IPSET_TEST:
+		return list_set_ktest(set, skb, par, opt, &ext);
+	case IPSET_ADD:
+		return list_set_kadd(set, skb, par, opt, &ext);
+	case IPSET_DEL:
+		return list_set_kdel(set, skb, par, opt, &ext);
+	default:
+		break;
 	}
 	return -EINVAL;
 }
 
 static bool
-id_eq(const struct list_set *map, u32 i, ip_set_id_t id)
+id_eq(const struct ip_set *set, u32 i, ip_set_id_t id)
 {
-	const struct set_elem *elem;
+	const struct list_set *map = set->data;
+	const struct set_elem *e;
+
+	if (i >= map->size)
+		return 0;
 
-	if (i < map->size) {
-		elem = list_set_elem(map, i);
-		return elem->id == id;
+	e = list_set_elem(map, i);
+	return !!(e->id == id &&
+		 !(SET_WITH_TIMEOUT(set) &&
+		   ip_set_timeout_expired(ext_timeout(e, map))));
+}
+
+static int
+list_set_add(struct ip_set *set, u32 i, struct set_adt_elem *d,
+	     const struct ip_set_ext *ext)
+{
+	struct list_set *map = set->data;
+	struct set_elem *e = list_set_elem(map, i);
+
+	if (e->id != IPSET_INVALID_ID) {
+		if (i == map->size - 1)
+			/* Last element replaced: e.g. add new,before,last */
+			ip_set_put_byindex(e->id);
+		else {
+			struct set_elem *x = list_set_elem(map, map->size - 1);
+
+			/* Last element pushed off */
+			if (x->id != IPSET_INVALID_ID)
+				ip_set_put_byindex(x->id);
+			memmove(list_set_elem(map, i + 1), e,
+				map->dsize * (map->size - (i + 1)));
+		}
 	}
 
+	e->id = d->id;
+	if (SET_WITH_TIMEOUT(set))
+		ip_set_timeout_set(ext_timeout(e, map), ext->timeout);
 	return 0;
 }
 
-static bool
-id_eq_timeout(const struct list_set *map, u32 i, ip_set_id_t id)
+static int
+list_set_del(struct ip_set *set, u32 i)
 {
-	const struct set_elem *elem;
+	struct list_set *map = set->data;
+	struct set_elem *e = list_set_elem(map, i);
 
-	if (i < map->size) {
-		elem = list_set_elem(map, i);
-		return !!(elem->id == id &&
-			  !(with_timeout(map->timeout) &&
-			    list_set_expired(map, i)));
-	}
+	ip_set_put_byindex(e->id);
 
+	if (i < map->size - 1)
+		memmove(e, list_set_elem(map, i + 1),
+			map->dsize * (map->size - (i + 1)));
+
+	/* Last element */
+	e = list_set_elem(map, map->size - 1);
+	e->id = IPSET_INVALID_ID;
 	return 0;
 }
 
 static void
-list_elem_add(struct list_set *map, u32 i, ip_set_id_t id)
+set_cleanup_entries(struct ip_set *set)
 {
+	struct list_set *map = set->data;
 	struct set_elem *e;
+	u32 i;
 
-	for (; i < map->size; i++) {
+	for (i = 0; i < map->size; i++) {
 		e = list_set_elem(map, i);
-		swap(e->id, id);
-		if (e->id == IPSET_INVALID_ID)
-			break;
+		if (e->id != IPSET_INVALID_ID &&
+		    ip_set_timeout_expired(ext_timeout(e, map)))
+			list_set_del(set, i);
 	}
 }
 
-static void
-list_elem_tadd(struct list_set *map, u32 i, ip_set_id_t id,
-	       unsigned long timeout)
+static int
+list_set_utest(struct ip_set *set, void *value, const struct ip_set_ext *ext,
+	       struct ip_set_ext *mext, u32 flags)
 {
-	struct set_telem *e;
+	struct list_set *map = set->data;
+	struct set_adt_elem *d = value;
+	struct set_elem *e;
+	u32 i;
+	int ret;
 
-	for (; i < map->size; i++) {
-		e = list_set_telem(map, i);
-		swap(e->id, id);
-		swap(e->timeout, timeout);
+	for (i = 0; i < map->size; i++) {
+		e = list_set_elem(map, i);
 		if (e->id == IPSET_INVALID_ID)
-			break;
+			return 0;
+		else if (SET_WITH_TIMEOUT(set) &&
+			 ip_set_timeout_expired(ext_timeout(e, map)))
+			continue;
+		else if (e->id != d->id)
+			continue;
+
+		if (d->before == 0)
+			return 1;
+		else if (d->before > 0)
+			ret = id_eq(set, i + 1, d->refid);
+		else
+			ret = i > 0 && id_eq(set, i - 1, d->refid);
+		return ret;
 	}
+	return 0;
 }
 
+
 static int
-list_set_add(struct list_set *map, u32 i, ip_set_id_t id,
-	     unsigned long timeout)
+list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
+	      struct ip_set_ext *mext, u32 flags)
 {
-	const struct set_elem *e = list_set_elem(map, i);
+	struct list_set *map = set->data;
+	struct set_adt_elem *d = value;
+	struct set_elem *e;
+	bool flag_exist = flags & IPSET_FLAG_EXIST;
+	u32 i, ret = 0;
 
-	if (e->id != IPSET_INVALID_ID) {
-		const struct set_elem *x = list_set_elem(map, map->size - 1);
+	/* Check already added element */
+	for (i = 0; i < map->size; i++) {
+		e = list_set_elem(map, i);
+		if (e->id == IPSET_INVALID_ID)
+			goto insert;
+		else if (SET_WITH_TIMEOUT(set) &&
+			 ip_set_timeout_expired(ext_timeout(e, map)))
+			continue;
+		else if (e->id != d->id)
+			continue;
 
-		/* Last element replaced or pushed off */
-		if (x->id != IPSET_INVALID_ID)
-			ip_set_put_byindex(x->id);
+		if ((d->before > 1 && !id_eq(set, i + 1, d->refid)) ||
+		    (d->before < 0 &&
+		     (i == 0 || !id_eq(set, i - 1, d->refid))))
+			/* Before/after doesn't match */
+			return -IPSET_ERR_REF_EXIST;
+		if (!flag_exist)
+			/* Can't re-add */
+			return -IPSET_ERR_EXIST;
+		/* Update extensions */
+		if (SET_WITH_TIMEOUT(set))
+			ip_set_timeout_set(ext_timeout(e, map), ext->timeout);
+		/* Set is already added to the list */
+		ip_set_put_byindex(d->id);
+		return 0;
+	}
+insert:
+	ret = -IPSET_ERR_LIST_FULL;
+	for (i = 0; i < map->size && ret == -IPSET_ERR_LIST_FULL; i++) {
+		e = list_set_elem(map, i);
+		if (e->id == IPSET_INVALID_ID)
+			ret = d->before != 0 ? -IPSET_ERR_REF_EXIST
+				: list_set_add(set, i, d, ext);
+		else if (e->id != d->refid)
+			continue;
+		else if (d->before > 0)
+			ret = list_set_add(set, i, d, ext);
+		else if (i + 1 < map->size)
+			ret = list_set_add(set, i + 1, d, ext);
 	}
-	if (with_timeout(map->timeout))
-		list_elem_tadd(map, i, id, ip_set_timeout_set(timeout));
-	else
-		list_elem_add(map, i, id);
 
-	return 0;
+	return ret;
 }
 
 static int
-list_set_del(struct list_set *map, u32 i)
+list_set_udel(struct ip_set *set, void *value, const struct ip_set_ext *ext,
+	      struct ip_set_ext *mext, u32 flags)
 {
-	struct set_elem *a = list_set_elem(map, i), *b;
-
-	ip_set_put_byindex(a->id);
-
-	for (; i < map->size - 1; i++) {
-		b = list_set_elem(map, i + 1);
-		a->id = b->id;
-		if (with_timeout(map->timeout))
-			((struct set_telem *)a)->timeout =
-				((struct set_telem *)b)->timeout;
-		a = b;
-		if (a->id == IPSET_INVALID_ID)
-			break;
-	}
-	/* Last element */
-	a->id = IPSET_INVALID_ID;
-	return 0;
-}
-
-static void
-cleanup_entries(struct list_set *map)
-{
-	struct set_telem *e;
+	struct list_set *map = set->data;
+	struct set_adt_elem *d = value;
+	struct set_elem *e;
 	u32 i;
 
 	for (i = 0; i < map->size; i++) {
-		e = list_set_telem(map, i);
-		if (e->id != IPSET_INVALID_ID && list_set_expired(map, i))
-			list_set_del(map, i);
+		e = list_set_elem(map, i);
+		if (e->id == IPSET_INVALID_ID)
+			return d->before != 0 ? -IPSET_ERR_REF_EXIST
+					      : -IPSET_ERR_EXIST;
+		else if (SET_WITH_TIMEOUT(set) &&
+			 ip_set_timeout_expired(ext_timeout(e, map)))
+			continue;
+		else if (e->id != d->id)
+			continue;
+
+		if (d->before == 0)
+			return list_set_del(set, i);
+		else if (d->before > 0) {
+			if (!id_eq(set, i + 1, d->refid))
+				return -IPSET_ERR_REF_EXIST;
+			return list_set_del(set, i);
+		} else if (i == 0 || !id_eq(set, i - 1, d->refid))
+			return -IPSET_ERR_REF_EXIST;
+		else
+			return list_set_del(set, i);
 	}
+	return -IPSET_ERR_EXIST;
 }
 
 static int
@@ -229,14 +354,10 @@ list_set_uadt(struct ip_set *set, struct nlattr *tb[],
 	      enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
 	struct list_set *map = set->data;
-	bool with_timeout = with_timeout(map->timeout);
-	bool flag_exist = flags & IPSET_FLAG_EXIST;
-	int before = 0;
-	u32 timeout = map->timeout;
-	ip_set_id_t id, refid = IPSET_INVALID_ID;
-	const struct set_elem *elem;
+	ipset_adtfn adtfn = set->variant->adt[adt];
+	struct set_adt_elem e = { .refid = IPSET_INVALID_ID };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(map);
 	struct ip_set *s;
-	u32 i;
 	int ret = 0;
 
 	if (unlikely(!tb[IPSET_ATTR_NAME] ||
@@ -247,8 +368,11 @@ list_set_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	id = ip_set_get_byname(nla_data(tb[IPSET_ATTR_NAME]), &s);
-	if (id == IPSET_INVALID_ID)
+	ret = ip_set_get_extensions(set, tb, &ext);
+	if (ret)
+		return ret;
+	e.id = ip_set_get_byname(nla_data(tb[IPSET_ATTR_NAME]), &s);
+	if (e.id == IPSET_INVALID_ID)
 		return -IPSET_ERR_NAME;
 	/* "Loop detection" */
 	if (s->type->features & IPSET_TYPE_NAME) {
@@ -258,115 +382,34 @@ list_set_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (tb[IPSET_ATTR_CADT_FLAGS]) {
 		u32 f = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
-		before = f & IPSET_FLAG_BEFORE;
+		e.before = f & IPSET_FLAG_BEFORE;
 	}
 
-	if (before && !tb[IPSET_ATTR_NAMEREF]) {
+	if (e.before && !tb[IPSET_ATTR_NAMEREF]) {
 		ret = -IPSET_ERR_BEFORE;
 		goto finish;
 	}
 
 	if (tb[IPSET_ATTR_NAMEREF]) {
-		refid = ip_set_get_byname(nla_data(tb[IPSET_ATTR_NAMEREF]),
-					  &s);
-		if (refid == IPSET_INVALID_ID) {
+		e.refid = ip_set_get_byname(nla_data(tb[IPSET_ATTR_NAMEREF]),
+					    &s);
+		if (e.refid == IPSET_INVALID_ID) {
 			ret = -IPSET_ERR_NAMEREF;
 			goto finish;
 		}
-		if (!before)
-			before = -1;
-	}
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout) {
-			ret = -IPSET_ERR_TIMEOUT;
-			goto finish;
-		}
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
+		if (!e.before)
+			e.before = -1;
 	}
-	if (with_timeout && adt != IPSET_TEST)
-		cleanup_entries(map);
+	if (adt != IPSET_TEST && SET_WITH_TIMEOUT(set))
+		set_cleanup_entries(set);
 
-	switch (adt) {
-	case IPSET_TEST:
-		for (i = 0; i < map->size && !ret; i++) {
-			elem = list_set_elem(map, i);
-			if (elem->id == IPSET_INVALID_ID ||
-			    (before != 0 && i + 1 >= map->size))
-				break;
-			else if (with_timeout && list_set_expired(map, i))
-				continue;
-			else if (before > 0 && elem->id == id)
-				ret = id_eq_timeout(map, i + 1, refid);
-			else if (before < 0 && elem->id == refid)
-				ret = id_eq_timeout(map, i + 1, id);
-			else if (before == 0 && elem->id == id)
-				ret = 1;
-		}
-		break;
-	case IPSET_ADD:
-		for (i = 0; i < map->size; i++) {
-			elem = list_set_elem(map, i);
-			if (elem->id != id)
-				continue;
-			if (!(with_timeout && flag_exist)) {
-				ret = -IPSET_ERR_EXIST;
-				goto finish;
-			} else {
-				struct set_telem *e = list_set_telem(map, i);
-
-				if ((before > 1 &&
-				     !id_eq(map, i + 1, refid)) ||
-				    (before < 0 &&
-				     (i == 0 || !id_eq(map, i - 1, refid)))) {
-					ret = -IPSET_ERR_EXIST;
-					goto finish;
-				}
-				e->timeout = ip_set_timeout_set(timeout);
-				ip_set_put_byindex(id);
-				ret = 0;
-				goto finish;
-			}
-		}
-		ret = -IPSET_ERR_LIST_FULL;
-		for (i = 0; i < map->size && ret == -IPSET_ERR_LIST_FULL; i++) {
-			elem = list_set_elem(map, i);
-			if (elem->id == IPSET_INVALID_ID)
-				ret = before != 0 ? -IPSET_ERR_REF_EXIST
-					: list_set_add(map, i, id, timeout);
-			else if (elem->id != refid)
-				continue;
-			else if (before > 0)
-				ret = list_set_add(map, i, id, timeout);
-			else if (i + 1 < map->size)
-				ret = list_set_add(map, i + 1, id, timeout);
-		}
-		break;
-	case IPSET_DEL:
-		ret = -IPSET_ERR_EXIST;
-		for (i = 0; i < map->size && ret == -IPSET_ERR_EXIST; i++) {
-			elem = list_set_elem(map, i);
-			if (elem->id == IPSET_INVALID_ID) {
-				ret = before != 0 ? -IPSET_ERR_REF_EXIST
-						  : -IPSET_ERR_EXIST;
-				break;
-			} else if (elem->id == id &&
-				   (before == 0 ||
-				    (before > 0 && id_eq(map, i + 1, refid))))
-				ret = list_set_del(map, i);
-			else if (elem->id == refid &&
-				 before < 0 && id_eq(map, i + 1, id))
-				ret = list_set_del(map, i + 1);
-		}
-		break;
-	default:
-		break;
-	}
+	ret = adtfn(set, &e, &ext, &ext, flags);
 
 finish:
-	if (refid != IPSET_INVALID_ID)
-		ip_set_put_byindex(refid);
+	if (e.refid != IPSET_INVALID_ID)
+		ip_set_put_byindex(e.refid);
 	if (adt != IPSET_ADD || ret)
-		ip_set_put_byindex(id);
+		ip_set_put_byindex(e.id);
 
 	return ip_set_eexist(ret, flags) ? 0 : ret;
 }
@@ -375,14 +418,14 @@ static void
 list_set_flush(struct ip_set *set)
 {
 	struct list_set *map = set->data;
-	struct set_elem *elem;
+	struct set_elem *e;
 	u32 i;
 
 	for (i = 0; i < map->size; i++) {
-		elem = list_set_elem(map, i);
-		if (elem->id != IPSET_INVALID_ID) {
-			ip_set_put_byindex(elem->id);
-			elem->id = IPSET_INVALID_ID;
+		e = list_set_elem(map, i);
+		if (e->id != IPSET_INVALID_ID) {
+			ip_set_put_byindex(e->id);
+			e->id = IPSET_INVALID_ID;
 		}
 	}
 }
@@ -392,7 +435,7 @@ list_set_destroy(struct ip_set *set)
 {
 	struct list_set *map = set->data;
 
-	if (with_timeout(map->timeout))
+	if (SET_WITH_TIMEOUT(set))
 		del_timer_sync(&map->gc);
 	list_set_flush(set);
 	kfree(map);
@@ -410,7 +453,7 @@ list_set_head(struct ip_set *set, struct sk_buff *skb)
 	if (!nested)
 		goto nla_put_failure;
 	if (nla_put_net32(skb, IPSET_ATTR_SIZE, htonl(map->size)) ||
-	    (with_timeout(map->timeout) &&
+	    (SET_WITH_TIMEOUT(set) &&
 	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout))) ||
 	    nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
 	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE,
@@ -440,7 +483,8 @@ list_set_list(const struct ip_set *set,
 		e = list_set_elem(map, i);
 		if (e->id == IPSET_INVALID_ID)
 			goto finish;
-		if (with_timeout(map->timeout) && list_set_expired(map, i))
+		if (SET_WITH_TIMEOUT(set) &&
+		    ip_set_timeout_expired(ext_timeout(e, map)))
 			continue;
 		nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
 		if (!nested) {
@@ -453,13 +497,11 @@ list_set_list(const struct ip_set *set,
 		if (nla_put_string(skb, IPSET_ATTR_NAME,
 				   ip_set_name_byindex(e->id)))
 			goto nla_put_failure;
-		if (with_timeout(map->timeout)) {
-			const struct set_telem *te =
-				(const struct set_telem *) e;
-			__be32 to = htonl(ip_set_timeout_get(te->timeout));
-			if (nla_put_net32(skb, IPSET_ATTR_TIMEOUT, to))
-				goto nla_put_failure;
-		}
+		if (SET_WITH_TIMEOUT(set) &&
+		    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+				  htonl(ip_set_timeout_get(
+						ext_timeout(e, map)))))
+			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
 finish:
@@ -485,12 +527,18 @@ list_set_same_set(const struct ip_set *a, const struct ip_set *b)
 	const struct list_set *y = b->data;
 
 	return x->size == y->size &&
-	       x->timeout == y->timeout;
+	       x->timeout == y->timeout &&
+	       a->extensions == b->extensions;
 }
 
-static const struct ip_set_type_variant list_set = {
+static const struct ip_set_type_variant set_variant = {
 	.kadt	= list_set_kadt,
 	.uadt	= list_set_uadt,
+	.adt	= {
+		[IPSET_ADD] = list_set_uadd,
+		[IPSET_DEL] = list_set_udel,
+		[IPSET_TEST] = list_set_utest,
+	},
 	.destroy = list_set_destroy,
 	.flush	= list_set_flush,
 	.head	= list_set_head,
@@ -505,7 +553,7 @@ list_set_gc(unsigned long ul_set)
 	struct list_set *map = set->data;
 
 	write_lock_bh(&set->lock);
-	cleanup_entries(map);
+	set_cleanup_entries(set);
 	write_unlock_bh(&set->lock);
 
 	map->gc.expires = jiffies + IPSET_GC_PERIOD(map->timeout) * HZ;
@@ -513,20 +561,20 @@ list_set_gc(unsigned long ul_set)
 }
 
 static void
-list_set_gc_init(struct ip_set *set)
+list_set_gc_init(struct ip_set *set, void (*gc)(unsigned long ul_set))
 {
 	struct list_set *map = set->data;
 
 	init_timer(&map->gc);
 	map->gc.data = (unsigned long) set;
-	map->gc.function = list_set_gc;
+	map->gc.function = gc;
 	map->gc.expires = jiffies + IPSET_GC_PERIOD(map->timeout) * HZ;
 	add_timer(&map->gc);
 }
 
 /* Create list:set type of sets */
 
-static bool
+static struct list_set *
 init_list_set(struct ip_set *set, u32 size, size_t dsize,
 	      unsigned long timeout)
 {
@@ -536,7 +584,7 @@ init_list_set(struct ip_set *set, u32 size, size_t dsize,
 
 	map = kzalloc(sizeof(*map) + size * dsize, GFP_KERNEL);
 	if (!map)
-		return false;
+		return NULL;
 
 	map->size = size;
 	map->dsize = dsize;
@@ -548,13 +596,15 @@ init_list_set(struct ip_set *set, u32 size, size_t dsize,
 		e->id = IPSET_INVALID_ID;
 	}
 
-	return true;
+	return map;
 }
 
 static int
 list_set_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 {
+	struct list_set *map;
 	u32 size = IP_SET_LIST_DEFAULT_SIZE;
+	unsigned long timeout = 0;
 
 	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_SIZE) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
@@ -565,18 +615,23 @@ list_set_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	if (size < IP_SET_LIST_MIN_SIZE)
 		size = IP_SET_LIST_MIN_SIZE;
 
+	if (tb[IPSET_ATTR_TIMEOUT])
+		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
+	set->variant = &set_variant;
 	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!init_list_set(set, size, sizeof(struct set_telem),
-				   ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT])))
+		map = init_list_set(set, size,
+				    sizeof(struct sett_elem), timeout);
+		if (!map)
 			return -ENOMEM;
-
-		list_set_gc_init(set);
+		set->extensions |= IPSET_EXT_TIMEOUT;
+		map->offset[IPSET_OFFSET_TIMEOUT] =
+			offsetof(struct sett_elem, timeout);
+		list_set_gc_init(set, list_set_gc);
 	} else {
-		if (!init_list_set(set, size, sizeof(struct set_elem),
-				   IPSET_NO_TIMEOUT))
+		map = init_list_set(set, size, sizeof(struct set_elem), 0);
+		if (!map)
 			return -ENOMEM;
 	}
-	set->variant = &list_set;
 	return 0;
 }
 
-- 
1.7.10.4
