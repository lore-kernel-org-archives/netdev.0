From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/18] netfilter: ipset: Bitmap types using the unified code base
Date: Sat, 27 Apr 2013 20:58:10 +0200
Message-ID: <1367089103-8394-6-git-send-email-pablo@netfilter.org>
References: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42565 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755460Ab3D0S6o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Apr 2013 14:58:44 -0400
In-Reply-To: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_bitmap_ip.c    |  351 ++++--------------
 net/netfilter/ipset/ip_set_bitmap_ipmac.c |  562 +++++++++--------------------
 net/netfilter/ipset/ip_set_bitmap_port.c  |  361 ++++--------------
 3 files changed, 316 insertions(+), 958 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index 4a92fd4..f2ab011 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -1,6 +1,6 @@
 /* Copyright (C) 2000-2002 Joakim Axelsson <gozem@linux.nu>
  *                         Patrick Schaaf <bof@bof.de>
- * Copyright (C) 2003-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+ * Copyright (C) 2003-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -24,8 +24,6 @@
 #include <linux/netfilter/ipset/pfxlen.h>
 #include <linux/netfilter/ipset/ip_set.h>
 #include <linux/netfilter/ipset/ip_set_bitmap.h>
-#define IP_SET_BITMAP_TIMEOUT
-#include <linux/netfilter/ipset/ip_set_timeout.h>
 
 #define REVISION_MIN	0
 #define REVISION_MAX	0
@@ -35,20 +33,28 @@ MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
 IP_SET_MODULE_DESC("bitmap:ip", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_bitmap:ip");
 
+#define MTYPE		bitmap_ip
+
 /* Type structure */
 struct bitmap_ip {
 	void *members;		/* the set members */
+	void *extensions;	/* data extensions */
 	u32 first_ip;		/* host byte order, included in range */
 	u32 last_ip;		/* host byte order, included in range */
 	u32 elements;		/* number of max elements in the set */
 	u32 hosts;		/* number of hosts in a subnet */
 	size_t memsize;		/* members size */
+	size_t dsize;		/* extensions struct size */
+	size_t offset[IPSET_OFFSET_MAX]; /* Offsets to extensions */
 	u8 netmask;		/* subnet netmask */
 	u32 timeout;		/* timeout parameter */
 	struct timer_list gc;	/* garbage collection */
 };
 
-/* Base variant */
+/* ADT structure for generic function args */
+struct bitmap_ip_adt_elem {
+	u16 id;
+};
 
 static inline u32
 ip_to_id(const struct bitmap_ip *m, u32 ip)
@@ -56,188 +62,67 @@ ip_to_id(const struct bitmap_ip *m, u32 ip)
 	return ((ip & ip_set_hostmask(m->netmask)) - m->first_ip)/m->hosts;
 }
 
-static int
-bitmap_ip_test(struct ip_set *set, void *value, u32 timeout, u32 flags)
-{
-	const struct bitmap_ip *map = set->data;
-	u16 id = *(u16 *)value;
-
-	return !!test_bit(id, map->members);
-}
-
-static int
-bitmap_ip_add(struct ip_set *set, void *value, u32 timeout, u32 flags)
-{
-	struct bitmap_ip *map = set->data;
-	u16 id = *(u16 *)value;
-
-	if (test_and_set_bit(id, map->members))
-		return -IPSET_ERR_EXIST;
-
-	return 0;
-}
+/* Common functions */
 
-static int
-bitmap_ip_del(struct ip_set *set, void *value, u32 timeout, u32 flags)
+static inline int
+bitmap_ip_do_test(const struct bitmap_ip_adt_elem *e, struct bitmap_ip *map)
 {
-	struct bitmap_ip *map = set->data;
-	u16 id = *(u16 *)value;
-
-	if (!test_and_clear_bit(id, map->members))
-		return -IPSET_ERR_EXIST;
-
-	return 0;
+	return !!test_bit(e->id, map->members);
 }
 
-static int
-bitmap_ip_list(const struct ip_set *set,
-	       struct sk_buff *skb, struct netlink_callback *cb)
+static inline int
+bitmap_ip_gc_test(u16 id, const struct bitmap_ip *map)
 {
-	const struct bitmap_ip *map = set->data;
-	struct nlattr *atd, *nested;
-	u32 id, first = cb->args[2];
-
-	atd = ipset_nest_start(skb, IPSET_ATTR_ADT);
-	if (!atd)
-		return -EMSGSIZE;
-	for (; cb->args[2] < map->elements; cb->args[2]++) {
-		id = cb->args[2];
-		if (!test_bit(id, map->members))
-			continue;
-		nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
-		if (!nested) {
-			if (id == first) {
-				nla_nest_cancel(skb, atd);
-				return -EMSGSIZE;
-			} else
-				goto nla_put_failure;
-		}
-		if (nla_put_ipaddr4(skb, IPSET_ATTR_IP,
-				    htonl(map->first_ip + id * map->hosts)))
-			goto nla_put_failure;
-		ipset_nest_end(skb, nested);
-	}
-	ipset_nest_end(skb, atd);
-	/* Set listing finished */
-	cb->args[2] = 0;
-	return 0;
-
-nla_put_failure:
-	nla_nest_cancel(skb, nested);
-	ipset_nest_end(skb, atd);
-	if (unlikely(id == first)) {
-		cb->args[2] = 0;
-		return -EMSGSIZE;
-	}
-	return 0;
+	return !!test_bit(id, map->members);
 }
 
-/* Timeout variant */
-
-static int
-bitmap_ip_ttest(struct ip_set *set, void *value, u32 timeout, u32 flags)
+static inline int
+bitmap_ip_do_add(const struct bitmap_ip_adt_elem *e, struct bitmap_ip *map,
+		 u32 flags)
 {
-	const struct bitmap_ip *map = set->data;
-	const unsigned long *members = map->members;
-	u16 id = *(u16 *)value;
-
-	return ip_set_timeout_test(members[id]);
+	return !!test_and_set_bit(e->id, map->members);
 }
 
-static int
-bitmap_ip_tadd(struct ip_set *set, void *value, u32 timeout, u32 flags)
+static inline int
+bitmap_ip_do_del(const struct bitmap_ip_adt_elem *e, struct bitmap_ip *map)
 {
-	struct bitmap_ip *map = set->data;
-	unsigned long *members = map->members;
-	u16 id = *(u16 *)value;
-
-	if (ip_set_timeout_test(members[id]) && !(flags & IPSET_FLAG_EXIST))
-		return -IPSET_ERR_EXIST;
-
-	members[id] = ip_set_timeout_set(timeout);
-
-	return 0;
+	return !test_and_clear_bit(e->id, map->members);
 }
 
-static int
-bitmap_ip_tdel(struct ip_set *set, void *value, u32 timeout, u32 flags)
+static inline int
+bitmap_ip_do_list(struct sk_buff *skb, const struct bitmap_ip *map, u32 id)
 {
-	struct bitmap_ip *map = set->data;
-	unsigned long *members = map->members;
-	u16 id = *(u16 *)value;
-	int ret = -IPSET_ERR_EXIST;
-
-	if (ip_set_timeout_test(members[id]))
-		ret = 0;
-
-	members[id] = IPSET_ELEM_UNSET;
-	return ret;
+	return nla_put_ipaddr4(skb, IPSET_ATTR_IP,
+			htonl(map->first_ip + id * map->hosts));
 }
 
-static int
-bitmap_ip_tlist(const struct ip_set *set,
-		struct sk_buff *skb, struct netlink_callback *cb)
+static inline int
+bitmap_ip_do_head(struct sk_buff *skb, const struct bitmap_ip *map)
 {
-	const struct bitmap_ip *map = set->data;
-	struct nlattr *adt, *nested;
-	u32 id, first = cb->args[2];
-	const unsigned long *members = map->members;
-
-	adt = ipset_nest_start(skb, IPSET_ATTR_ADT);
-	if (!adt)
-		return -EMSGSIZE;
-	for (; cb->args[2] < map->elements; cb->args[2]++) {
-		id = cb->args[2];
-		if (!ip_set_timeout_test(members[id]))
-			continue;
-		nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
-		if (!nested) {
-			if (id == first) {
-				nla_nest_cancel(skb, adt);
-				return -EMSGSIZE;
-			} else
-				goto nla_put_failure;
-		}
-		if (nla_put_ipaddr4(skb, IPSET_ATTR_IP,
-				    htonl(map->first_ip + id * map->hosts)) ||
-		    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-				  htonl(ip_set_timeout_get(members[id]))))
-			goto nla_put_failure;
-		ipset_nest_end(skb, nested);
-	}
-	ipset_nest_end(skb, adt);
-
-	/* Set listing finished */
-	cb->args[2] = 0;
-
-	return 0;
-
-nla_put_failure:
-	nla_nest_cancel(skb, nested);
-	ipset_nest_end(skb, adt);
-	if (unlikely(id == first)) {
-		cb->args[2] = 0;
-		return -EMSGSIZE;
-	}
-	return 0;
+	return nla_put_ipaddr4(skb, IPSET_ATTR_IP, htonl(map->first_ip)) ||
+	       nla_put_ipaddr4(skb, IPSET_ATTR_IP_TO, htonl(map->last_ip)) ||
+	       (map->netmask != 32 &&
+		nla_put_u8(skb, IPSET_ATTR_NETMASK, map->netmask));
 }
 
 static int
 bitmap_ip_kadt(struct ip_set *set, const struct sk_buff *skb,
 	       const struct xt_action_param *par,
-	       enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+	       enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
 	struct bitmap_ip *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
+	struct bitmap_ip_adt_elem e = { };
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, map);
 	u32 ip;
 
 	ip = ntohl(ip4addr(skb, opt->flags & IPSET_DIM_ONE_SRC));
 	if (ip < map->first_ip || ip > map->last_ip)
 		return -IPSET_ERR_BITMAP_RANGE;
 
-	ip = ip_to_id(map, ip);
+	e.id = ip_to_id(map, ip);
 
-	return adtfn(set, &ip, opt_timeout(opt, map), opt->cmdflags);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
 }
 
 static int
@@ -246,8 +131,9 @@ bitmap_ip_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	struct bitmap_ip *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	u32 timeout = map->timeout;
-	u32 ip, ip_to, id;
+	u32 ip, ip_to;
+	struct bitmap_ip_adt_elem e = { };
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(map);
 	int ret = 0;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
@@ -257,22 +143,17 @@ bitmap_ip_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
 	if (ip < map->first_ip || ip > map->last_ip)
 		return -IPSET_ERR_BITMAP_RANGE;
 
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout(map->timeout))
-			return -IPSET_ERR_TIMEOUT;
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-	}
-
 	if (adt == IPSET_TEST) {
-		id = ip_to_id(map, ip);
-		return adtfn(set, &id, timeout, flags);
+		e.id = ip_to_id(map, ip);
+		return adtfn(set, &e, &ext, &ext, flags);
 	}
 
 	if (tb[IPSET_ATTR_IP_TO]) {
@@ -297,8 +178,8 @@ bitmap_ip_uadt(struct ip_set *set, struct nlattr *tb[],
 		return -IPSET_ERR_BITMAP_RANGE;
 
 	for (; !before(ip_to, ip); ip += map->hosts) {
-		id = ip_to_id(map, ip);
-		ret = adtfn(set, &id, timeout, flags);
+		e.id = ip_to_id(map, ip);
+		ret = adtfn(set, &e, &ext, &ext, flags);
 
 		if (ret && !ip_set_eexist(ret, flags))
 			return ret;
@@ -308,54 +189,6 @@ bitmap_ip_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-static void
-bitmap_ip_destroy(struct ip_set *set)
-{
-	struct bitmap_ip *map = set->data;
-
-	if (with_timeout(map->timeout))
-		del_timer_sync(&map->gc);
-
-	ip_set_free(map->members);
-	kfree(map);
-
-	set->data = NULL;
-}
-
-static void
-bitmap_ip_flush(struct ip_set *set)
-{
-	struct bitmap_ip *map = set->data;
-
-	memset(map->members, 0, map->memsize);
-}
-
-static int
-bitmap_ip_head(struct ip_set *set, struct sk_buff *skb)
-{
-	const struct bitmap_ip *map = set->data;
-	struct nlattr *nested;
-
-	nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
-	if (!nested)
-		goto nla_put_failure;
-	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, htonl(map->first_ip)) ||
-	    nla_put_ipaddr4(skb, IPSET_ATTR_IP_TO, htonl(map->last_ip)) ||
-	    (map->netmask != 32 &&
-	     nla_put_u8(skb, IPSET_ATTR_NETMASK, map->netmask)) ||
-	    nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
-	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE,
-			  htonl(sizeof(*map) + map->memsize)) ||
-	    (with_timeout(map->timeout) &&
-	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout))))
-		goto nla_put_failure;
-	ipset_nest_end(skb, nested);
-
-	return 0;
-nla_put_failure:
-	return -EMSGSIZE;
-}
-
 static bool
 bitmap_ip_same_set(const struct ip_set *a, const struct ip_set *b)
 {
@@ -365,70 +198,22 @@ bitmap_ip_same_set(const struct ip_set *a, const struct ip_set *b)
 	return x->first_ip == y->first_ip &&
 	       x->last_ip == y->last_ip &&
 	       x->netmask == y->netmask &&
-	       x->timeout == y->timeout;
+	       x->timeout == y->timeout &&
+	       a->extensions == b->extensions;
 }
 
-static const struct ip_set_type_variant bitmap_ip = {
-	.kadt	= bitmap_ip_kadt,
-	.uadt	= bitmap_ip_uadt,
-	.adt	= {
-		[IPSET_ADD] = bitmap_ip_add,
-		[IPSET_DEL] = bitmap_ip_del,
-		[IPSET_TEST] = bitmap_ip_test,
-	},
-	.destroy = bitmap_ip_destroy,
-	.flush	= bitmap_ip_flush,
-	.head	= bitmap_ip_head,
-	.list	= bitmap_ip_list,
-	.same_set = bitmap_ip_same_set,
-};
+/* Plain variant */
 
-static const struct ip_set_type_variant bitmap_tip = {
-	.kadt	= bitmap_ip_kadt,
-	.uadt	= bitmap_ip_uadt,
-	.adt	= {
-		[IPSET_ADD] = bitmap_ip_tadd,
-		[IPSET_DEL] = bitmap_ip_tdel,
-		[IPSET_TEST] = bitmap_ip_ttest,
-	},
-	.destroy = bitmap_ip_destroy,
-	.flush	= bitmap_ip_flush,
-	.head	= bitmap_ip_head,
-	.list	= bitmap_ip_tlist,
-	.same_set = bitmap_ip_same_set,
+struct bitmap_ip_elem {
 };
 
-static void
-bitmap_ip_gc(unsigned long ul_set)
-{
-	struct ip_set *set = (struct ip_set *) ul_set;
-	struct bitmap_ip *map = set->data;
-	unsigned long *table = map->members;
-	u32 id;
-
-	/* We run parallel with other readers (test element)
-	 * but adding/deleting new entries is locked out */
-	read_lock_bh(&set->lock);
-	for (id = 0; id < map->elements; id++)
-		if (ip_set_timeout_expired(table[id]))
-			table[id] = IPSET_ELEM_UNSET;
-	read_unlock_bh(&set->lock);
-
-	map->gc.expires = jiffies + IPSET_GC_PERIOD(map->timeout) * HZ;
-	add_timer(&map->gc);
-}
+/* Timeout variant */
 
-static void
-bitmap_ip_gc_init(struct ip_set *set)
-{
-	struct bitmap_ip *map = set->data;
+struct bitmap_ipt_elem {
+	unsigned long timeout;
+};
 
-	init_timer(&map->gc);
-	map->gc.data = (unsigned long) set;
-	map->gc.function = bitmap_ip_gc;
-	map->gc.expires = jiffies + IPSET_GC_PERIOD(map->timeout) * HZ;
-	add_timer(&map->gc);
-}
+#include "ip_set_bitmap_gen.h"
 
 /* Create bitmap:ip type of sets */
 
@@ -440,6 +225,13 @@ init_map_ip(struct ip_set *set, struct bitmap_ip *map,
 	map->members = ip_set_alloc(map->memsize);
 	if (!map->members)
 		return false;
+	if (map->dsize) {
+		map->extensions = ip_set_alloc(map->dsize * elements);
+		if (!map->extensions) {
+			kfree(map->members);
+			return false;
+		}
+	}
 	map->first_ip = first_ip;
 	map->last_ip = last_ip;
 	map->elements = elements;
@@ -526,8 +318,12 @@ bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	if (!map)
 		return -ENOMEM;
 
+	map->memsize = bitmap_bytes(0, elements - 1);
+	set->variant = &bitmap_ip;
 	if (tb[IPSET_ATTR_TIMEOUT]) {
-		map->memsize = elements * sizeof(unsigned long);
+		map->dsize = sizeof(struct bitmap_ipt_elem);
+		map->offset[IPSET_OFFSET_TIMEOUT] =
+			offsetof(struct bitmap_ipt_elem, timeout);
 
 		if (!init_map_ip(set, map, first_ip, last_ip,
 				 elements, hosts, netmask)) {
@@ -536,19 +332,16 @@ bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 		}
 
 		map->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-		set->variant = &bitmap_tip;
+		set->extensions |= IPSET_EXT_TIMEOUT;
 
-		bitmap_ip_gc_init(set);
+		bitmap_ip_gc_init(set, bitmap_ip_gc);
 	} else {
-		map->memsize = bitmap_bytes(0, elements - 1);
-
+		map->dsize = 0;
 		if (!init_map_ip(set, map, first_ip, last_ip,
 				 elements, hosts, netmask)) {
 			kfree(map);
 			return -ENOMEM;
 		}
-
-		set->variant = &bitmap_ip;
 	}
 	return 0;
 }
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index d7df6ac..960810d 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -1,7 +1,7 @@
 /* Copyright (C) 2000-2002 Joakim Axelsson <gozem@linux.nu>
  *                         Patrick Schaaf <bof@bof.de>
  *			   Martin Josefsson <gandalf@wlug.westbo.se>
- * Copyright (C) 2003-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+ * Copyright (C) 2003-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -23,7 +23,6 @@
 
 #include <linux/netfilter/ipset/pfxlen.h>
 #include <linux/netfilter/ipset/ip_set.h>
-#include <linux/netfilter/ipset/ip_set_timeout.h>
 #include <linux/netfilter/ipset/ip_set_bitmap.h>
 
 #define REVISION_MIN	0
@@ -34,333 +33,198 @@ MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
 IP_SET_MODULE_DESC("bitmap:ip,mac", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_bitmap:ip,mac");
 
+#define MTYPE		bitmap_ipmac
+#define IP_SET_BITMAP_STORED_TIMEOUT
+
 enum {
-	MAC_EMPTY,		/* element is not set */
-	MAC_FILLED,		/* element is set with MAC */
 	MAC_UNSET,		/* element is set, without MAC */
+	MAC_FILLED,		/* element is set with MAC */
 };
 
 /* Type structure */
 struct bitmap_ipmac {
 	void *members;		/* the set members */
+	void *extensions;	/* MAC + data extensions */
 	u32 first_ip;		/* host byte order, included in range */
 	u32 last_ip;		/* host byte order, included in range */
+	u32 elements;		/* number of max elements in the set */
 	u32 timeout;		/* timeout value */
 	struct timer_list gc;	/* garbage collector */
+	size_t memsize;		/* members size */
 	size_t dsize;		/* size of element */
+	size_t offset[IPSET_OFFSET_MAX]; /* Offsets to extensions */
 };
 
 /* ADT structure for generic function args */
-struct ipmac {
-	u32 id;			/* id in array */
-	unsigned char *ether;	/* ethernet address */
+struct bitmap_ipmac_adt_elem {
+	u16 id;
+	unsigned char *ether;
 };
 
-/* Member element without and with timeout */
-
-struct ipmac_elem {
+struct bitmap_ipmac_elem {
 	unsigned char ether[ETH_ALEN];
-	unsigned char match;
+	unsigned char filled;
 } __attribute__ ((aligned));
 
-struct ipmac_telem {
-	unsigned char ether[ETH_ALEN];
-	unsigned char match;
-	unsigned long timeout;
-} __attribute__ ((aligned));
-
-static inline void *
-bitmap_ipmac_elem(const struct bitmap_ipmac *map, u32 id)
+static inline u32
+ip_to_id(const struct bitmap_ipmac *m, u32 ip)
 {
-	return (void *)((char *)map->members + id * map->dsize);
+	return ip - m->first_ip;
 }
 
-static inline bool
-bitmap_timeout(const struct bitmap_ipmac *map, u32 id)
+static inline struct bitmap_ipmac_elem *
+get_elem(void *extensions, u16 id, size_t dsize)
 {
-	const struct ipmac_telem *elem = bitmap_ipmac_elem(map, id);
-
-	return ip_set_timeout_test(elem->timeout);
+	return (struct bitmap_ipmac_elem *)(extensions + id * dsize);
 }
 
-static inline bool
-bitmap_expired(const struct bitmap_ipmac *map, u32 id)
-{
-	const struct ipmac_telem *elem = bitmap_ipmac_elem(map, id);
-
-	return ip_set_timeout_expired(elem->timeout);
-}
+/* Common functions */
 
 static inline int
-bitmap_ipmac_exist(const struct ipmac_telem *elem)
-{
-	return elem->match == MAC_UNSET ||
-	       (elem->match == MAC_FILLED &&
-		!ip_set_timeout_expired(elem->timeout));
-}
-
-/* Base variant */
-
-static int
-bitmap_ipmac_test(struct ip_set *set, void *value, u32 timeout, u32 flags)
-{
-	const struct bitmap_ipmac *map = set->data;
-	const struct ipmac *data = value;
-	const struct ipmac_elem *elem = bitmap_ipmac_elem(map, data->id);
-
-	switch (elem->match) {
-	case MAC_UNSET:
-		/* Trigger kernel to fill out the ethernet address */
-		return -EAGAIN;
-	case MAC_FILLED:
-		return data->ether == NULL ||
-		       ether_addr_equal(data->ether, elem->ether);
-	}
-	return 0;
-}
-
-static int
-bitmap_ipmac_add(struct ip_set *set, void *value, u32 timeout, u32 flags)
-{
-	struct bitmap_ipmac *map = set->data;
-	const struct ipmac *data = value;
-	struct ipmac_elem *elem = bitmap_ipmac_elem(map, data->id);
-
-	switch (elem->match) {
-	case MAC_UNSET:
-		if (!data->ether)
-			/* Already added without ethernet address */
-			return -IPSET_ERR_EXIST;
-		/* Fill the MAC address */
-		memcpy(elem->ether, data->ether, ETH_ALEN);
-		elem->match = MAC_FILLED;
-		break;
-	case MAC_FILLED:
-		return -IPSET_ERR_EXIST;
-	case MAC_EMPTY:
-		if (data->ether) {
-			memcpy(elem->ether, data->ether, ETH_ALEN);
-			elem->match = MAC_FILLED;
-		} else
-			elem->match = MAC_UNSET;
-	}
-
-	return 0;
-}
-
-static int
-bitmap_ipmac_del(struct ip_set *set, void *value, u32 timeout, u32 flags)
+bitmap_ipmac_do_test(const struct bitmap_ipmac_adt_elem *e,
+		     const struct bitmap_ipmac *map)
 {
-	struct bitmap_ipmac *map = set->data;
-	const struct ipmac *data = value;
-	struct ipmac_elem *elem = bitmap_ipmac_elem(map, data->id);
-
-	if (elem->match == MAC_EMPTY)
-		return -IPSET_ERR_EXIST;
+	const struct bitmap_ipmac_elem *elem;
 
-	elem->match = MAC_EMPTY;
-
-	return 0;
+	if (!test_bit(e->id, map->members))
+		return 0;
+	elem = get_elem(map->extensions, e->id, map->dsize);
+	if (elem->filled == MAC_FILLED)
+		return e->ether == NULL ||
+		       ether_addr_equal(e->ether, elem->ether);
+	/* Trigger kernel to fill out the ethernet address */
+	return -EAGAIN;
 }
 
-static int
-bitmap_ipmac_list(const struct ip_set *set,
-		  struct sk_buff *skb, struct netlink_callback *cb)
+static inline int
+bitmap_ipmac_gc_test(u16 id, const struct bitmap_ipmac *map)
 {
-	const struct bitmap_ipmac *map = set->data;
-	const struct ipmac_elem *elem;
-	struct nlattr *atd, *nested;
-	u32 id, first = cb->args[2];
-	u32 last = map->last_ip - map->first_ip;
-
-	atd = ipset_nest_start(skb, IPSET_ATTR_ADT);
-	if (!atd)
-		return -EMSGSIZE;
-	for (; cb->args[2] <= last; cb->args[2]++) {
-		id = cb->args[2];
-		elem = bitmap_ipmac_elem(map, id);
-		if (elem->match == MAC_EMPTY)
-			continue;
-		nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
-		if (!nested) {
-			if (id == first) {
-				nla_nest_cancel(skb, atd);
-				return -EMSGSIZE;
-			} else
-				goto nla_put_failure;
-		}
-		if (nla_put_ipaddr4(skb, IPSET_ATTR_IP,
-				    htonl(map->first_ip + id)) ||
-		    (elem->match == MAC_FILLED &&
-		     nla_put(skb, IPSET_ATTR_ETHER, ETH_ALEN,
-			     elem->ether)))
-			goto nla_put_failure;
-		ipset_nest_end(skb, nested);
-	}
-	ipset_nest_end(skb, atd);
-	/* Set listing finished */
-	cb->args[2] = 0;
-
-	return 0;
+	const struct bitmap_ipmac_elem *elem;
 
-nla_put_failure:
-	nla_nest_cancel(skb, nested);
-	ipset_nest_end(skb, atd);
-	if (unlikely(id == first)) {
-		cb->args[2] = 0;
-		return -EMSGSIZE;
-	}
-	return 0;
+	if (!test_bit(id, map->members))
+		return 0;
+	elem = get_elem(map->extensions, id, map->dsize);
+	/* Timer not started for the incomplete elements */
+	return elem->filled == MAC_FILLED;
 }
 
-/* Timeout variant */
-
-static int
-bitmap_ipmac_ttest(struct ip_set *set, void *value, u32 timeout, u32 flags)
+static inline int
+bitmap_ipmac_is_filled(const struct bitmap_ipmac_elem *elem)
 {
-	const struct bitmap_ipmac *map = set->data;
-	const struct ipmac *data = value;
-	const struct ipmac_elem *elem = bitmap_ipmac_elem(map, data->id);
-
-	switch (elem->match) {
-	case MAC_UNSET:
-		/* Trigger kernel to fill out the ethernet address */
-		return -EAGAIN;
-	case MAC_FILLED:
-		return (data->ether == NULL ||
-			ether_addr_equal(data->ether, elem->ether)) &&
-		       !bitmap_expired(map, data->id);
-	}
-	return 0;
+	return elem->filled == MAC_FILLED;
 }
 
-static int
-bitmap_ipmac_tadd(struct ip_set *set, void *value, u32 timeout, u32 flags)
+static inline int
+bitmap_ipmac_add_timeout(unsigned long *timeout,
+			 const struct bitmap_ipmac_adt_elem *e,
+			 const struct ip_set_ext *ext,
+			 struct bitmap_ipmac *map, int mode)
 {
-	struct bitmap_ipmac *map = set->data;
-	const struct ipmac *data = value;
-	struct ipmac_telem *elem = bitmap_ipmac_elem(map, data->id);
-	bool flag_exist = flags & IPSET_FLAG_EXIST;
+	u32 t = ext->timeout;
 
-	switch (elem->match) {
-	case MAC_UNSET:
-		if (!(data->ether || flag_exist))
-			/* Already added without ethernet address */
-			return -IPSET_ERR_EXIST;
-		/* Fill the MAC address and activate the timer */
-		memcpy(elem->ether, data->ether, ETH_ALEN);
-		elem->match = MAC_FILLED;
-		if (timeout == map->timeout)
+	if (mode == IPSET_ADD_START_STORED_TIMEOUT) {
+		if (t == map->timeout)
 			/* Timeout was not specified, get stored one */
-			timeout = elem->timeout;
-		elem->timeout = ip_set_timeout_set(timeout);
-		break;
-	case MAC_FILLED:
-		if (!(bitmap_expired(map, data->id) || flag_exist))
-			return -IPSET_ERR_EXIST;
-		/* Fall through */
-	case MAC_EMPTY:
-		if (data->ether) {
-			memcpy(elem->ether, data->ether, ETH_ALEN);
-			elem->match = MAC_FILLED;
-		} else
-			elem->match = MAC_UNSET;
+			t = *timeout;
+		ip_set_timeout_set(timeout, t);
+	} else {
 		/* If MAC is unset yet, we store plain timeout value
 		 * because the timer is not activated yet
 		 * and we can reuse it later when MAC is filled out,
 		 * possibly by the kernel */
-		elem->timeout = data->ether ? ip_set_timeout_set(timeout)
-					    : timeout;
-		break;
+		if (e->ether)
+			ip_set_timeout_set(timeout, t);
+		else
+			*timeout = t;
 	}
-
 	return 0;
 }
 
-static int
-bitmap_ipmac_tdel(struct ip_set *set, void *value, u32 timeout, u32 flags)
+static inline int
+bitmap_ipmac_do_add(const struct bitmap_ipmac_adt_elem *e,
+		    struct bitmap_ipmac *map, u32 flags)
 {
-	struct bitmap_ipmac *map = set->data;
-	const struct ipmac *data = value;
-	struct ipmac_telem *elem = bitmap_ipmac_elem(map, data->id);
+	struct bitmap_ipmac_elem *elem;
+
+	elem = get_elem(map->extensions, e->id, map->dsize);
+	if (test_and_set_bit(e->id, map->members)) {
+		if (elem->filled == MAC_FILLED) {
+			if (e->ether && (flags & IPSET_FLAG_EXIST))
+				memcpy(elem->ether, e->ether, ETH_ALEN);
+			return IPSET_ADD_FAILED;
+		} else if (!e->ether)
+			/* Already added without ethernet address */
+			return IPSET_ADD_FAILED;
+		/* Fill the MAC address and trigger the timer activation */
+		memcpy(elem->ether, e->ether, ETH_ALEN);
+		elem->filled = MAC_FILLED;
+		return IPSET_ADD_START_STORED_TIMEOUT;
+	} else if (e->ether) {
+		/* We can store MAC too */
+		memcpy(elem->ether, e->ether, ETH_ALEN);
+		elem->filled = MAC_FILLED;
+		return 0;
+	} else {
+		elem->filled = MAC_UNSET;
+		/* MAC is not stored yet, don't start timer */
+		return IPSET_ADD_STORE_PLAIN_TIMEOUT;
+	}
+}
 
-	if (elem->match == MAC_EMPTY || bitmap_expired(map, data->id))
-		return -IPSET_ERR_EXIST;
+static inline int
+bitmap_ipmac_do_del(const struct bitmap_ipmac_adt_elem *e,
+		    struct bitmap_ipmac *map)
+{
+	return !test_and_clear_bit(e->id, map->members);
+}
 
-	elem->match = MAC_EMPTY;
+static inline unsigned long
+ip_set_timeout_stored(struct bitmap_ipmac *map, u32 id, unsigned long *timeout)
+{
+	const struct bitmap_ipmac_elem *elem =
+		get_elem(map->extensions, id, map->dsize);
 
-	return 0;
+	return elem->filled == MAC_FILLED ? ip_set_timeout_get(timeout) :
+					    *timeout;
 }
 
-static int
-bitmap_ipmac_tlist(const struct ip_set *set,
-		   struct sk_buff *skb, struct netlink_callback *cb)
+static inline int
+bitmap_ipmac_do_list(struct sk_buff *skb, const struct bitmap_ipmac *map,
+		     u32 id)
 {
-	const struct bitmap_ipmac *map = set->data;
-	const struct ipmac_telem *elem;
-	struct nlattr *atd, *nested;
-	u32 id, first = cb->args[2];
-	u32 timeout, last = map->last_ip - map->first_ip;
-
-	atd = ipset_nest_start(skb, IPSET_ATTR_ADT);
-	if (!atd)
-		return -EMSGSIZE;
-	for (; cb->args[2] <= last; cb->args[2]++) {
-		id = cb->args[2];
-		elem = bitmap_ipmac_elem(map, id);
-		if (!bitmap_ipmac_exist(elem))
-			continue;
-		nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
-		if (!nested) {
-			if (id == first) {
-				nla_nest_cancel(skb, atd);
-				return -EMSGSIZE;
-			} else
-				goto nla_put_failure;
-		}
-		if (nla_put_ipaddr4(skb, IPSET_ATTR_IP,
-				    htonl(map->first_ip + id)) ||
-		    (elem->match == MAC_FILLED &&
-		     nla_put(skb, IPSET_ATTR_ETHER, ETH_ALEN,
-			     elem->ether)))
-			goto nla_put_failure;
-		timeout = elem->match == MAC_UNSET ? elem->timeout
-				: ip_set_timeout_get(elem->timeout);
-		if (nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(timeout)))
-			goto nla_put_failure;
-		ipset_nest_end(skb, nested);
-	}
-	ipset_nest_end(skb, atd);
-	/* Set listing finished */
-	cb->args[2] = 0;
+	const struct bitmap_ipmac_elem *elem =
+		get_elem(map->extensions, id, map->dsize);
 
-	return 0;
+	return nla_put_ipaddr4(skb, IPSET_ATTR_IP,
+			       htonl(map->first_ip + id)) ||
+	       (elem->filled == MAC_FILLED &&
+		nla_put(skb, IPSET_ATTR_ETHER, ETH_ALEN, elem->ether));
+}
 
-nla_put_failure:
-	nla_nest_cancel(skb, nested);
-	ipset_nest_end(skb, atd);
-	if (unlikely(id == first)) {
-		cb->args[2] = 0;
-		return -EMSGSIZE;
-	}
-	return 0;
+static inline int
+bitmap_ipmac_do_head(struct sk_buff *skb, const struct bitmap_ipmac *map)
+{
+	return nla_put_ipaddr4(skb, IPSET_ATTR_IP, htonl(map->first_ip)) ||
+	       nla_put_ipaddr4(skb, IPSET_ATTR_IP_TO, htonl(map->last_ip));
 }
 
 static int
 bitmap_ipmac_kadt(struct ip_set *set, const struct sk_buff *skb,
 		  const struct xt_action_param *par,
-		  enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+		  enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
 	struct bitmap_ipmac *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct ipmac data;
+	struct bitmap_ipmac_adt_elem e = {};
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, map);
+	u32 ip;
 
 	/* MAC can be src only */
 	if (!(opt->flags & IPSET_DIM_TWO_SRC))
 		return 0;
 
-	data.id = ntohl(ip4addr(skb, opt->flags & IPSET_DIM_ONE_SRC));
-	if (data.id < map->first_ip || data.id > map->last_ip)
+	ip = ntohl(ip4addr(skb, opt->flags & IPSET_DIM_ONE_SRC));
+	if (ip < map->first_ip || ip > map->last_ip)
 		return -IPSET_ERR_BITMAP_RANGE;
 
 	/* Backward compatibility: we don't check the second flag */
@@ -368,10 +232,10 @@ bitmap_ipmac_kadt(struct ip_set *set, const struct sk_buff *skb,
 	    (skb_mac_header(skb) + ETH_HLEN) > skb->data)
 		return -EINVAL;
 
-	data.id -= map->first_ip;
-	data.ether = eth_hdr(skb)->h_source;
+	e.id = ip_to_id(map, ip);
+	e.ether = eth_hdr(skb)->h_source;
 
-	return adtfn(set, &data, opt_timeout(opt, map), opt->cmdflags);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
 }
 
 static int
@@ -380,8 +244,9 @@ bitmap_ipmac_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct bitmap_ipmac *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct ipmac data;
-	u32 timeout = map->timeout;
+	struct bitmap_ipmac_adt_elem e = {};
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(map);
+	u32 ip;
 	int ret = 0;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
@@ -391,80 +256,25 @@ bitmap_ipmac_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &data.id);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip) ||
+	      ip_set_get_extensions(set, tb, &ext);
 	if (ret)
 		return ret;
 
-	if (data.id < map->first_ip || data.id > map->last_ip)
+	if (ip < map->first_ip || ip > map->last_ip)
 		return -IPSET_ERR_BITMAP_RANGE;
 
+	e.id = ip_to_id(map, ip);
 	if (tb[IPSET_ATTR_ETHER])
-		data.ether = nla_data(tb[IPSET_ATTR_ETHER]);
+		e.ether = nla_data(tb[IPSET_ATTR_ETHER]);
 	else
-		data.ether = NULL;
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout(map->timeout))
-			return -IPSET_ERR_TIMEOUT;
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-	}
+		e.ether = NULL;
 
-	data.id -= map->first_ip;
-
-	ret = adtfn(set, &data, timeout, flags);
+	ret = adtfn(set, &e, &ext, &ext, flags);
 
 	return ip_set_eexist(ret, flags) ? 0 : ret;
 }
 
-static void
-bitmap_ipmac_destroy(struct ip_set *set)
-{
-	struct bitmap_ipmac *map = set->data;
-
-	if (with_timeout(map->timeout))
-		del_timer_sync(&map->gc);
-
-	ip_set_free(map->members);
-	kfree(map);
-
-	set->data = NULL;
-}
-
-static void
-bitmap_ipmac_flush(struct ip_set *set)
-{
-	struct bitmap_ipmac *map = set->data;
-
-	memset(map->members, 0,
-	       (map->last_ip - map->first_ip + 1) * map->dsize);
-}
-
-static int
-bitmap_ipmac_head(struct ip_set *set, struct sk_buff *skb)
-{
-	const struct bitmap_ipmac *map = set->data;
-	struct nlattr *nested;
-
-	nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
-	if (!nested)
-		goto nla_put_failure;
-	if (nla_put_ipaddr4(skb, IPSET_ATTR_IP, htonl(map->first_ip)) ||
-	    nla_put_ipaddr4(skb, IPSET_ATTR_IP_TO, htonl(map->last_ip)) ||
-	    nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
-	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE,
-			  htonl(sizeof(*map) +
-				((map->last_ip - map->first_ip + 1) *
-				 map->dsize))) ||
-	    (with_timeout(map->timeout) &&
-	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout))))
-		goto nla_put_failure;
-	ipset_nest_end(skb, nested);
-
-	return 0;
-nla_put_failure:
-	return -EMSGSIZE;
-}
-
 static bool
 bitmap_ipmac_same_set(const struct ip_set *a, const struct ip_set *b)
 {
@@ -473,85 +283,43 @@ bitmap_ipmac_same_set(const struct ip_set *a, const struct ip_set *b)
 
 	return x->first_ip == y->first_ip &&
 	       x->last_ip == y->last_ip &&
-	       x->timeout == y->timeout;
+	       x->timeout == y->timeout &&
+	       a->extensions == b->extensions;
 }
 
-static const struct ip_set_type_variant bitmap_ipmac = {
-	.kadt	= bitmap_ipmac_kadt,
-	.uadt	= bitmap_ipmac_uadt,
-	.adt	= {
-		[IPSET_ADD] = bitmap_ipmac_add,
-		[IPSET_DEL] = bitmap_ipmac_del,
-		[IPSET_TEST] = bitmap_ipmac_test,
-	},
-	.destroy = bitmap_ipmac_destroy,
-	.flush	= bitmap_ipmac_flush,
-	.head	= bitmap_ipmac_head,
-	.list	= bitmap_ipmac_list,
-	.same_set = bitmap_ipmac_same_set,
-};
-
-static const struct ip_set_type_variant bitmap_tipmac = {
-	.kadt	= bitmap_ipmac_kadt,
-	.uadt	= bitmap_ipmac_uadt,
-	.adt	= {
-		[IPSET_ADD] = bitmap_ipmac_tadd,
-		[IPSET_DEL] = bitmap_ipmac_tdel,
-		[IPSET_TEST] = bitmap_ipmac_ttest,
-	},
-	.destroy = bitmap_ipmac_destroy,
-	.flush	= bitmap_ipmac_flush,
-	.head	= bitmap_ipmac_head,
-	.list	= bitmap_ipmac_tlist,
-	.same_set = bitmap_ipmac_same_set,
-};
-
-static void
-bitmap_ipmac_gc(unsigned long ul_set)
-{
-	struct ip_set *set = (struct ip_set *) ul_set;
-	struct bitmap_ipmac *map = set->data;
-	struct ipmac_telem *elem;
-	u32 id, last = map->last_ip - map->first_ip;
-
-	/* We run parallel with other readers (test element)
-	 * but adding/deleting new entries is locked out */
-	read_lock_bh(&set->lock);
-	for (id = 0; id <= last; id++) {
-		elem = bitmap_ipmac_elem(map, id);
-		if (elem->match == MAC_FILLED &&
-		    ip_set_timeout_expired(elem->timeout))
-			elem->match = MAC_EMPTY;
-	}
-	read_unlock_bh(&set->lock);
+/* Plain variant */
 
-	map->gc.expires = jiffies + IPSET_GC_PERIOD(map->timeout) * HZ;
-	add_timer(&map->gc);
-}
+/* Timeout variant */
 
-static void
-bitmap_ipmac_gc_init(struct ip_set *set)
-{
-	struct bitmap_ipmac *map = set->data;
+struct bitmap_ipmact_elem {
+	struct {
+		unsigned char ether[ETH_ALEN];
+		unsigned char filled;
+	} __attribute__ ((aligned));
+	unsigned long timeout;
+};
 
-	init_timer(&map->gc);
-	map->gc.data = (unsigned long) set;
-	map->gc.function = bitmap_ipmac_gc;
-	map->gc.expires = jiffies + IPSET_GC_PERIOD(map->timeout) * HZ;
-	add_timer(&map->gc);
-}
+#include "ip_set_bitmap_gen.h"
 
 /* Create bitmap:ip,mac type of sets */
 
 static bool
 init_map_ipmac(struct ip_set *set, struct bitmap_ipmac *map,
-	       u32 first_ip, u32 last_ip)
+	       u32 first_ip, u32 last_ip, u32 elements)
 {
 	map->members = ip_set_alloc((last_ip - first_ip + 1) * map->dsize);
 	if (!map->members)
 		return false;
+	if (map->dsize) {
+		map->extensions = ip_set_alloc(map->dsize * elements);
+		if (!map->extensions) {
+			kfree(map->members);
+			return false;
+		}
+	}
 	map->first_ip = first_ip;
 	map->last_ip = last_ip;
+	map->elements = elements;
 	map->timeout = IPSET_NO_TIMEOUT;
 
 	set->data = map;
@@ -605,28 +373,28 @@ bitmap_ipmac_create(struct ip_set *set, struct nlattr *tb[],
 	if (!map)
 		return -ENOMEM;
 
+	map->memsize = bitmap_bytes(0, elements - 1);
+	set->variant = &bitmap_ipmac;
 	if (tb[IPSET_ATTR_TIMEOUT]) {
-		map->dsize = sizeof(struct ipmac_telem);
+		map->dsize = sizeof(struct bitmap_ipmact_elem);
+		map->offset[IPSET_OFFSET_TIMEOUT] =
+			offsetof(struct bitmap_ipmact_elem, timeout);
 
-		if (!init_map_ipmac(set, map, first_ip, last_ip)) {
+		if (!init_map_ipmac(set, map, first_ip, last_ip, elements)) {
 			kfree(map);
 			return -ENOMEM;
 		}
-
 		map->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-
-		set->variant = &bitmap_tipmac;
-
-		bitmap_ipmac_gc_init(set);
+		set->extensions |= IPSET_EXT_TIMEOUT;
+		bitmap_ipmac_gc_init(set, bitmap_ipmac_gc);
 	} else {
-		map->dsize = sizeof(struct ipmac_elem);
+		map->dsize = sizeof(struct bitmap_ipmac_elem);
 
-		if (!init_map_ipmac(set, map, first_ip, last_ip)) {
+		if (!init_map_ipmac(set, map, first_ip, last_ip, elements)) {
 			kfree(map);
 			return -ENOMEM;
 		}
 		set->variant = &bitmap_ipmac;
-
 	}
 	return 0;
 }
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index e6b2db7..27e2c57 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -1,4 +1,4 @@
-/* Copyright (C) 2003-2011 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
+/* Copyright (C) 2003-2013 Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -19,8 +19,6 @@
 #include <linux/netfilter/ipset/ip_set.h>
 #include <linux/netfilter/ipset/ip_set_bitmap.h>
 #include <linux/netfilter/ipset/ip_set_getport.h>
-#define IP_SET_BITMAP_TIMEOUT
-#include <linux/netfilter/ipset/ip_set_timeout.h>
 
 #define REVISION_MIN	0
 #define REVISION_MAX	0
@@ -30,194 +28,85 @@ MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
 IP_SET_MODULE_DESC("bitmap:port", REVISION_MIN, REVISION_MAX);
 MODULE_ALIAS("ip_set_bitmap:port");
 
+#define MTYPE		bitmap_port
+
 /* Type structure */
 struct bitmap_port {
 	void *members;		/* the set members */
+	void *extensions;	/* data extensions */
 	u16 first_port;		/* host byte order, included in range */
 	u16 last_port;		/* host byte order, included in range */
+	u32 elements;		/* number of max elements in the set */
 	size_t memsize;		/* members size */
+	size_t dsize;		/* extensions struct size */
+	size_t offset[IPSET_OFFSET_MAX]; /* Offsets to extensions */
 	u32 timeout;		/* timeout parameter */
 	struct timer_list gc;	/* garbage collection */
 };
 
-/* Base variant */
+/* ADT structure for generic function args */
+struct bitmap_port_adt_elem {
+	u16 id;
+};
 
-static int
-bitmap_port_test(struct ip_set *set, void *value, u32 timeout, u32 flags)
+static inline u16
+port_to_id(const struct bitmap_port *m, u16 port)
 {
-	const struct bitmap_port *map = set->data;
-	u16 id = *(u16 *)value;
-
-	return !!test_bit(id, map->members);
+	return port - m->first_port;
 }
 
-static int
-bitmap_port_add(struct ip_set *set, void *value, u32 timeout, u32 flags)
-{
-	struct bitmap_port *map = set->data;
-	u16 id = *(u16 *)value;
-
-	if (test_and_set_bit(id, map->members))
-		return -IPSET_ERR_EXIST;
-
-	return 0;
-}
+/* Common functions */
 
-static int
-bitmap_port_del(struct ip_set *set, void *value, u32 timeout, u32 flags)
+static inline int
+bitmap_port_do_test(const struct bitmap_port_adt_elem *e,
+		    const struct bitmap_port *map)
 {
-	struct bitmap_port *map = set->data;
-	u16 id = *(u16 *)value;
-
-	if (!test_and_clear_bit(id, map->members))
-		return -IPSET_ERR_EXIST;
-
-	return 0;
+	return !!test_bit(e->id, map->members);
 }
 
-static int
-bitmap_port_list(const struct ip_set *set,
-		 struct sk_buff *skb, struct netlink_callback *cb)
+static inline int
+bitmap_port_gc_test(u16 id, const struct bitmap_port *map)
 {
-	const struct bitmap_port *map = set->data;
-	struct nlattr *atd, *nested;
-	u16 id, first = cb->args[2];
-	u16 last = map->last_port - map->first_port;
-
-	atd = ipset_nest_start(skb, IPSET_ATTR_ADT);
-	if (!atd)
-		return -EMSGSIZE;
-	for (; cb->args[2] <= last; cb->args[2]++) {
-		id = cb->args[2];
-		if (!test_bit(id, map->members))
-			continue;
-		nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
-		if (!nested) {
-			if (id == first) {
-				nla_nest_cancel(skb, atd);
-				return -EMSGSIZE;
-			} else
-				goto nla_put_failure;
-		}
-		if (nla_put_net16(skb, IPSET_ATTR_PORT,
-				  htons(map->first_port + id)))
-			goto nla_put_failure;
-		ipset_nest_end(skb, nested);
-	}
-	ipset_nest_end(skb, atd);
-	/* Set listing finished */
-	cb->args[2] = 0;
-
-	return 0;
-
-nla_put_failure:
-	nla_nest_cancel(skb, nested);
-	ipset_nest_end(skb, atd);
-	if (unlikely(id == first)) {
-		cb->args[2] = 0;
-		return -EMSGSIZE;
-	}
-	return 0;
+	return !!test_bit(id, map->members);
 }
 
-/* Timeout variant */
-
-static int
-bitmap_port_ttest(struct ip_set *set, void *value, u32 timeout, u32 flags)
+static inline int
+bitmap_port_do_add(const struct bitmap_port_adt_elem *e,
+		   struct bitmap_port *map, u32 flags)
 {
-	const struct bitmap_port *map = set->data;
-	const unsigned long *members = map->members;
-	u16 id = *(u16 *)value;
-
-	return ip_set_timeout_test(members[id]);
+	return !!test_and_set_bit(e->id, map->members);
 }
 
-static int
-bitmap_port_tadd(struct ip_set *set, void *value, u32 timeout, u32 flags)
+static inline int
+bitmap_port_do_del(const struct bitmap_port_adt_elem *e,
+		   struct bitmap_port *map)
 {
-	struct bitmap_port *map = set->data;
-	unsigned long *members = map->members;
-	u16 id = *(u16 *)value;
-
-	if (ip_set_timeout_test(members[id]) && !(flags & IPSET_FLAG_EXIST))
-		return -IPSET_ERR_EXIST;
-
-	members[id] = ip_set_timeout_set(timeout);
-
-	return 0;
+	return !test_and_clear_bit(e->id, map->members);
 }
 
-static int
-bitmap_port_tdel(struct ip_set *set, void *value, u32 timeout, u32 flags)
+static inline int
+bitmap_port_do_list(struct sk_buff *skb, const struct bitmap_port *map, u32 id)
 {
-	struct bitmap_port *map = set->data;
-	unsigned long *members = map->members;
-	u16 id = *(u16 *)value;
-	int ret = -IPSET_ERR_EXIST;
-
-	if (ip_set_timeout_test(members[id]))
-		ret = 0;
-
-	members[id] = IPSET_ELEM_UNSET;
-	return ret;
+	return nla_put_net16(skb, IPSET_ATTR_PORT,
+			     htons(map->first_port + id));
 }
 
-static int
-bitmap_port_tlist(const struct ip_set *set,
-		  struct sk_buff *skb, struct netlink_callback *cb)
+static inline int
+bitmap_port_do_head(struct sk_buff *skb, const struct bitmap_port *map)
 {
-	const struct bitmap_port *map = set->data;
-	struct nlattr *adt, *nested;
-	u16 id, first = cb->args[2];
-	u16 last = map->last_port - map->first_port;
-	const unsigned long *members = map->members;
-
-	adt = ipset_nest_start(skb, IPSET_ATTR_ADT);
-	if (!adt)
-		return -EMSGSIZE;
-	for (; cb->args[2] <= last; cb->args[2]++) {
-		id = cb->args[2];
-		if (!ip_set_timeout_test(members[id]))
-			continue;
-		nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
-		if (!nested) {
-			if (id == first) {
-				nla_nest_cancel(skb, adt);
-				return -EMSGSIZE;
-			} else
-				goto nla_put_failure;
-		}
-		if (nla_put_net16(skb, IPSET_ATTR_PORT,
-				  htons(map->first_port + id)) ||
-		    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-				  htonl(ip_set_timeout_get(members[id]))))
-			goto nla_put_failure;
-		ipset_nest_end(skb, nested);
-	}
-	ipset_nest_end(skb, adt);
-
-	/* Set listing finished */
-	cb->args[2] = 0;
-
-	return 0;
-
-nla_put_failure:
-	nla_nest_cancel(skb, nested);
-	ipset_nest_end(skb, adt);
-	if (unlikely(id == first)) {
-		cb->args[2] = 0;
-		return -EMSGSIZE;
-	}
-	return 0;
+	return nla_put_net16(skb, IPSET_ATTR_PORT, htons(map->first_port)) ||
+	       nla_put_net16(skb, IPSET_ATTR_PORT_TO, htons(map->last_port));
 }
 
 static int
 bitmap_port_kadt(struct ip_set *set, const struct sk_buff *skb,
 		 const struct xt_action_param *par,
-		 enum ipset_adt adt, const struct ip_set_adt_opt *opt)
+		 enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
 	struct bitmap_port *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
+	struct bitmap_port_adt_elem e = {};
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, map);
 	__be16 __port;
 	u16 port = 0;
 
@@ -230,9 +119,9 @@ bitmap_port_kadt(struct ip_set *set, const struct sk_buff *skb,
 	if (port < map->first_port || port > map->last_port)
 		return -IPSET_ERR_BITMAP_RANGE;
 
-	port -= map->first_port;
+	e.id = port_to_id(map, port);
 
-	return adtfn(set, &port, opt_timeout(opt, map), opt->cmdflags);
+	return adtfn(set, &e, &ext, &opt->ext, opt->cmdflags);
 }
 
 static int
@@ -241,9 +130,10 @@ bitmap_port_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	struct bitmap_port *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	u32 timeout = map->timeout;
+	struct bitmap_port_adt_elem e = {};
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(map);
 	u32 port;	/* wraparound */
-	u16 id, port_to;
+	u16 port_to;
 	int ret = 0;
 
 	if (unlikely(!ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
@@ -257,16 +147,13 @@ bitmap_port_uadt(struct ip_set *set, struct nlattr *tb[],
 	port = ip_set_get_h16(tb[IPSET_ATTR_PORT]);
 	if (port < map->first_port || port > map->last_port)
 		return -IPSET_ERR_BITMAP_RANGE;
-
-	if (tb[IPSET_ATTR_TIMEOUT]) {
-		if (!with_timeout(map->timeout))
-			return -IPSET_ERR_TIMEOUT;
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-	}
+	ret = ip_set_get_extensions(set, tb, &ext);
+	if (ret)
+		return ret;
 
 	if (adt == IPSET_TEST) {
-		id = port - map->first_port;
-		return adtfn(set, &id, timeout, flags);
+		e.id = port_to_id(map, port);
+		return adtfn(set, &e, &ext, &ext, flags);
 	}
 
 	if (tb[IPSET_ATTR_PORT_TO]) {
@@ -283,8 +170,8 @@ bitmap_port_uadt(struct ip_set *set, struct nlattr *tb[],
 		return -IPSET_ERR_BITMAP_RANGE;
 
 	for (; port <= port_to; port++) {
-		id = port - map->first_port;
-		ret = adtfn(set, &id, timeout, flags);
+		e.id = port_to_id(map, port);
+		ret = adtfn(set, &e, &ext, &ext, flags);
 
 		if (ret && !ip_set_eexist(ret, flags))
 			return ret;
@@ -294,52 +181,6 @@ bitmap_port_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-static void
-bitmap_port_destroy(struct ip_set *set)
-{
-	struct bitmap_port *map = set->data;
-
-	if (with_timeout(map->timeout))
-		del_timer_sync(&map->gc);
-
-	ip_set_free(map->members);
-	kfree(map);
-
-	set->data = NULL;
-}
-
-static void
-bitmap_port_flush(struct ip_set *set)
-{
-	struct bitmap_port *map = set->data;
-
-	memset(map->members, 0, map->memsize);
-}
-
-static int
-bitmap_port_head(struct ip_set *set, struct sk_buff *skb)
-{
-	const struct bitmap_port *map = set->data;
-	struct nlattr *nested;
-
-	nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
-	if (!nested)
-		goto nla_put_failure;
-	if (nla_put_net16(skb, IPSET_ATTR_PORT, htons(map->first_port)) ||
-	    nla_put_net16(skb, IPSET_ATTR_PORT_TO, htons(map->last_port)) ||
-	    nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
-	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE,
-			  htonl(sizeof(*map) + map->memsize)) ||
-	    (with_timeout(map->timeout) &&
-	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout))))
-		goto nla_put_failure;
-	ipset_nest_end(skb, nested);
-
-	return 0;
-nla_put_failure:
-	return -EMSGSIZE;
-}
-
 static bool
 bitmap_port_same_set(const struct ip_set *a, const struct ip_set *b)
 {
@@ -348,71 +189,21 @@ bitmap_port_same_set(const struct ip_set *a, const struct ip_set *b)
 
 	return x->first_port == y->first_port &&
 	       x->last_port == y->last_port &&
-	       x->timeout == y->timeout;
+	       x->timeout == y->timeout &&
+	       a->extensions == b->extensions;
 }
 
-static const struct ip_set_type_variant bitmap_port = {
-	.kadt	= bitmap_port_kadt,
-	.uadt	= bitmap_port_uadt,
-	.adt	= {
-		[IPSET_ADD] = bitmap_port_add,
-		[IPSET_DEL] = bitmap_port_del,
-		[IPSET_TEST] = bitmap_port_test,
-	},
-	.destroy = bitmap_port_destroy,
-	.flush	= bitmap_port_flush,
-	.head	= bitmap_port_head,
-	.list	= bitmap_port_list,
-	.same_set = bitmap_port_same_set,
-};
+/* Plain variant */
 
-static const struct ip_set_type_variant bitmap_tport = {
-	.kadt	= bitmap_port_kadt,
-	.uadt	= bitmap_port_uadt,
-	.adt	= {
-		[IPSET_ADD] = bitmap_port_tadd,
-		[IPSET_DEL] = bitmap_port_tdel,
-		[IPSET_TEST] = bitmap_port_ttest,
-	},
-	.destroy = bitmap_port_destroy,
-	.flush	= bitmap_port_flush,
-	.head	= bitmap_port_head,
-	.list	= bitmap_port_tlist,
-	.same_set = bitmap_port_same_set,
+struct bitmap_port_elem {
 };
 
-static void
-bitmap_port_gc(unsigned long ul_set)
-{
-	struct ip_set *set = (struct ip_set *) ul_set;
-	struct bitmap_port *map = set->data;
-	unsigned long *table = map->members;
-	u32 id;	/* wraparound */
-	u16 last = map->last_port - map->first_port;
-
-	/* We run parallel with other readers (test element)
-	 * but adding/deleting new entries is locked out */
-	read_lock_bh(&set->lock);
-	for (id = 0; id <= last; id++)
-		if (ip_set_timeout_expired(table[id]))
-			table[id] = IPSET_ELEM_UNSET;
-	read_unlock_bh(&set->lock);
-
-	map->gc.expires = jiffies + IPSET_GC_PERIOD(map->timeout) * HZ;
-	add_timer(&map->gc);
-}
-
-static void
-bitmap_port_gc_init(struct ip_set *set)
-{
-	struct bitmap_port *map = set->data;
+/* Timeout variant */
+struct bitmap_portt_elem {
+	unsigned long timeout;
+};
 
-	init_timer(&map->gc);
-	map->gc.data = (unsigned long) set;
-	map->gc.function = bitmap_port_gc;
-	map->gc.expires = jiffies + IPSET_GC_PERIOD(map->timeout) * HZ;
-	add_timer(&map->gc);
-}
+#include "ip_set_bitmap_gen.h"
 
 /* Create bitmap:ip type of sets */
 
@@ -423,6 +214,13 @@ init_map_port(struct ip_set *set, struct bitmap_port *map,
 	map->members = ip_set_alloc(map->memsize);
 	if (!map->members)
 		return false;
+	if (map->dsize) {
+		map->extensions = ip_set_alloc(map->dsize * map->elements);
+		if (!map->extensions) {
+			kfree(map->members);
+			return false;
+		}
+	}
 	map->first_port = first_port;
 	map->last_port = last_port;
 	map->timeout = IPSET_NO_TIMEOUT;
@@ -434,8 +232,7 @@ init_map_port(struct ip_set *set, struct bitmap_port *map,
 }
 
 static int
-bitmap_port_create(struct ip_set *set, struct nlattr *tb[],
-		 u32 flags)
+bitmap_port_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 {
 	struct bitmap_port *map;
 	u16 first_port, last_port;
@@ -458,28 +255,28 @@ bitmap_port_create(struct ip_set *set, struct nlattr *tb[],
 	if (!map)
 		return -ENOMEM;
 
+	map->elements = last_port - first_port + 1;
+	map->memsize = map->elements * sizeof(unsigned long);
+	set->variant = &bitmap_port;
 	if (tb[IPSET_ATTR_TIMEOUT]) {
-		map->memsize = (last_port - first_port + 1)
-			       * sizeof(unsigned long);
-
+		map->dsize = sizeof(struct bitmap_portt_elem);
+		map->offset[IPSET_OFFSET_TIMEOUT] =
+			offsetof(struct bitmap_portt_elem, timeout);
 		if (!init_map_port(set, map, first_port, last_port)) {
 			kfree(map);
 			return -ENOMEM;
 		}
 
 		map->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-		set->variant = &bitmap_tport;
-
-		bitmap_port_gc_init(set);
+		set->extensions |= IPSET_EXT_TIMEOUT;
+		bitmap_port_gc_init(set, bitmap_port_gc);
 	} else {
-		map->memsize = bitmap_bytes(0, last_port - first_port);
-		pr_debug("memsize: %zu\n", map->memsize);
+		map->dsize = 0;
 		if (!init_map_port(set, map, first_port, last_port)) {
 			kfree(map);
 			return -ENOMEM;
 		}
 
-		set->variant = &bitmap_port;
 	}
 	return 0;
 }
-- 
1.7.10.4
