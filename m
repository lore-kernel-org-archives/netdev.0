From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/33] netfilter: ipset: Move extension data to set structure
Date: Fri,  4 Oct 2013 10:33:00 +0200
Message-ID: <1380875598-5250-16-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55955 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754559Ab3JDIe5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Oct 2013 04:34:57 -0400
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Default timeout and extension offsets are moved to struct set, because
all set types supports all extensions and it makes possible to generalize
extension support.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h         |   29 ++++--
 include/linux/netfilter/ipset/ip_set_timeout.h |    4 +-
 net/netfilter/ipset/ip_set_bitmap_gen.h        |   59 ++++++-----
 net/netfilter/ipset/ip_set_bitmap_ip.c         |   45 ++++-----
 net/netfilter/ipset/ip_set_bitmap_ipmac.c      |   64 ++++++------
 net/netfilter/ipset/ip_set_bitmap_port.c       |   44 ++++----
 net/netfilter/ipset/ip_set_hash_gen.h          |  127 +++++++++++-------------
 net/netfilter/ipset/ip_set_hash_ip.c           |    8 +-
 net/netfilter/ipset/ip_set_hash_ipport.c       |   10 +-
 net/netfilter/ipset/ip_set_hash_ipportip.c     |   10 +-
 net/netfilter/ipset/ip_set_hash_ipportnet.c    |   14 +--
 net/netfilter/ipset/ip_set_hash_net.c          |    9 +-
 net/netfilter/ipset/ip_set_hash_netiface.c     |    8 +-
 net/netfilter/ipset/ip_set_hash_netport.c      |    8 +-
 net/netfilter/ipset/ip_set_list_set.c          |  116 ++++++++++------------
 15 files changed, 266 insertions(+), 289 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index b4db791..992a2f5 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -72,6 +72,16 @@ struct ip_set_ext {
 	u32 timeout;
 };
 
+struct ip_set_counter {
+	atomic64_t bytes;
+	atomic64_t packets;
+};
+
+#define ext_timeout(e, s)	\
+(unsigned long *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_TIMEOUT])
+#define ext_counter(e, s)	\
+(struct ip_set_counter *)(((void *)(e)) + (s)->offset[IPSET_EXT_ID_COUNTER])
+
 struct ip_set;
 
 typedef int (*ipset_adtfn)(struct ip_set *set, void *value,
@@ -179,15 +189,16 @@ struct ip_set {
 	u8 revision;
 	/* Extensions */
 	u8 extensions;
+	/* Default timeout value, if enabled */
+	u32 timeout;
+	/* Element data size */
+	size_t dsize;
+	/* Offsets to extensions in elements */
+	size_t offset[IPSET_EXT_ID_MAX];
 	/* The type specific data */
 	void *data;
 };
 
-struct ip_set_counter {
-	atomic64_t bytes;
-	atomic64_t packets;
-};
-
 static inline void
 ip_set_add_bytes(u64 bytes, struct ip_set_counter *counter)
 {
@@ -390,13 +401,13 @@ bitmap_bytes(u32 a, u32 b)
 
 #include <linux/netfilter/ipset/ip_set_timeout.h>
 
-#define IP_SET_INIT_KEXT(skb, opt, map)			\
+#define IP_SET_INIT_KEXT(skb, opt, set)			\
 	{ .bytes = (skb)->len, .packets = 1,		\
-	  .timeout = ip_set_adt_opt_timeout(opt, map) }
+	  .timeout = ip_set_adt_opt_timeout(opt, set) }
 
-#define IP_SET_INIT_UEXT(map)				\
+#define IP_SET_INIT_UEXT(set)				\
 	{ .bytes = ULLONG_MAX, .packets = ULLONG_MAX,	\
-	  .timeout = (map)->timeout }
+	  .timeout = (set)->timeout }
 
 #define IP_SET_INIT_CIDR(a, b) ((a) ? (a) : (b))
 
diff --git a/include/linux/netfilter/ipset/ip_set_timeout.h b/include/linux/netfilter/ipset/ip_set_timeout.h
index 3aac041..83c2f9e 100644
--- a/include/linux/netfilter/ipset/ip_set_timeout.h
+++ b/include/linux/netfilter/ipset/ip_set_timeout.h
@@ -23,8 +23,8 @@
 /* Set is defined with timeout support: timeout value may be 0 */
 #define IPSET_NO_TIMEOUT	UINT_MAX
 
-#define ip_set_adt_opt_timeout(opt, map)	\
-((opt)->ext.timeout != IPSET_NO_TIMEOUT ? (opt)->ext.timeout : (map)->timeout)
+#define ip_set_adt_opt_timeout(opt, set)	\
+((opt)->ext.timeout != IPSET_NO_TIMEOUT ? (opt)->ext.timeout : (set)->timeout)
 
 static inline unsigned int
 ip_set_timeout_uget(struct nlattr *tb)
diff --git a/net/netfilter/ipset/ip_set_bitmap_gen.h b/net/netfilter/ipset/ip_set_bitmap_gen.h
index 889a929..f32ddbc 100644
--- a/net/netfilter/ipset/ip_set_bitmap_gen.h
+++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
@@ -32,11 +32,7 @@
 #define mtype_gc		IPSET_TOKEN(MTYPE, _gc)
 #define mtype			MTYPE
 
-#define ext_timeout(e, m)	\
-	(unsigned long *)((e) + (m)->offset[IPSET_EXT_ID_TIMEOUT])
-#define ext_counter(e, m)	\
-	(struct ip_set_counter *)((e) + (m)->offset[IPSET_EXT_ID_COUNTER])
-#define get_ext(map, id)	((map)->extensions + (map)->dsize * (id))
+#define get_ext(set, map, id)	((map)->extensions + (set)->dsize * (id))
 
 static void
 mtype_gc_init(struct ip_set *set, void (*gc)(unsigned long ul_set))
@@ -46,7 +42,7 @@ mtype_gc_init(struct ip_set *set, void (*gc)(unsigned long ul_set))
 	init_timer(&map->gc);
 	map->gc.data = (unsigned long) set;
 	map->gc.function = gc;
-	map->gc.expires = jiffies + IPSET_GC_PERIOD(map->timeout) * HZ;
+	map->gc.expires = jiffies + IPSET_GC_PERIOD(set->timeout) * HZ;
 	add_timer(&map->gc);
 }
 
@@ -59,7 +55,7 @@ mtype_destroy(struct ip_set *set)
 		del_timer_sync(&map->gc);
 
 	ip_set_free(map->members);
-	if (map->dsize)
+	if (set->dsize)
 		ip_set_free(map->extensions);
 	kfree(map);
 
@@ -88,9 +84,9 @@ mtype_head(struct ip_set *set, struct sk_buff *skb)
 	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE,
 			  htonl(sizeof(*map) +
 				map->memsize +
-				map->dsize * map->elements)) ||
+				set->dsize * map->elements)) ||
 	    (SET_WITH_TIMEOUT(set) &&
-	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout))) ||
+	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(set->timeout))) ||
 	    (SET_WITH_COUNTER(set) &&
 	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS,
 			   htonl(IPSET_FLAG_WITH_COUNTERS))))
@@ -108,16 +104,16 @@ mtype_test(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 {
 	struct mtype *map = set->data;
 	const struct mtype_adt_elem *e = value;
-	void *x = get_ext(map, e->id);
-	int ret = mtype_do_test(e, map);
+	void *x = get_ext(set, map, e->id);
+	int ret = mtype_do_test(e, map, set->dsize);
 
 	if (ret <= 0)
 		return ret;
 	if (SET_WITH_TIMEOUT(set) &&
-	    ip_set_timeout_expired(ext_timeout(x, map)))
+	    ip_set_timeout_expired(ext_timeout(x, set)))
 		return 0;
 	if (SET_WITH_COUNTER(set))
-		ip_set_update_counter(ext_counter(x, map), ext, mext, flags);
+		ip_set_update_counter(ext_counter(x, set), ext, mext, flags);
 	return 1;
 }
 
@@ -127,12 +123,12 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 {
 	struct mtype *map = set->data;
 	const struct mtype_adt_elem *e = value;
-	void *x = get_ext(map, e->id);
-	int ret = mtype_do_add(e, map, flags);
+	void *x = get_ext(set, map, e->id);
+	int ret = mtype_do_add(e, map, flags, set->dsize);
 
 	if (ret == IPSET_ADD_FAILED) {
 		if (SET_WITH_TIMEOUT(set) &&
-		    ip_set_timeout_expired(ext_timeout(x, map)))
+		    ip_set_timeout_expired(ext_timeout(x, set)))
 			ret = 0;
 		else if (!(flags & IPSET_FLAG_EXIST))
 			return -IPSET_ERR_EXIST;
@@ -140,13 +136,13 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 
 	if (SET_WITH_TIMEOUT(set))
 #ifdef IP_SET_BITMAP_STORED_TIMEOUT
-		mtype_add_timeout(ext_timeout(x, map), e, ext, map, ret);
+		mtype_add_timeout(ext_timeout(x, set), e, ext, set, map, ret);
 #else
-		ip_set_timeout_set(ext_timeout(x, map), ext->timeout);
+		ip_set_timeout_set(ext_timeout(x, set), ext->timeout);
 #endif
 
 	if (SET_WITH_COUNTER(set))
-		ip_set_init_counter(ext_counter(x, map), ext);
+		ip_set_init_counter(ext_counter(x, set), ext);
 	return 0;
 }
 
@@ -156,11 +152,11 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 {
 	struct mtype *map = set->data;
 	const struct mtype_adt_elem *e = value;
-	const void *x = get_ext(map, e->id);
+	const void *x = get_ext(set, map, e->id);
 
 	if (mtype_do_del(e, map) ||
 	    (SET_WITH_TIMEOUT(set) &&
-	     ip_set_timeout_expired(ext_timeout(x, map))))
+	     ip_set_timeout_expired(ext_timeout(x, set))))
 		return -IPSET_ERR_EXIST;
 
 	return 0;
@@ -180,13 +176,13 @@ mtype_list(const struct ip_set *set,
 		return -EMSGSIZE;
 	for (; cb->args[2] < map->elements; cb->args[2]++) {
 		id = cb->args[2];
-		x = get_ext(map, id);
+		x = get_ext(set, map, id);
 		if (!test_bit(id, map->members) ||
 		    (SET_WITH_TIMEOUT(set) &&
 #ifdef IP_SET_BITMAP_STORED_TIMEOUT
 		     mtype_is_filled((const struct mtype_elem *) x) &&
 #endif
-		     ip_set_timeout_expired(ext_timeout(x, map))))
+		     ip_set_timeout_expired(ext_timeout(x, set))))
 			continue;
 		nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
 		if (!nested) {
@@ -196,23 +192,24 @@ mtype_list(const struct ip_set *set,
 			} else
 				goto nla_put_failure;
 		}
-		if (mtype_do_list(skb, map, id))
+		if (mtype_do_list(skb, map, id, set->dsize))
 			goto nla_put_failure;
 		if (SET_WITH_TIMEOUT(set)) {
 #ifdef IP_SET_BITMAP_STORED_TIMEOUT
 			if (nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
 					  htonl(ip_set_timeout_stored(map, id,
-							ext_timeout(x, map)))))
+							ext_timeout(x, set),
+							set->dsize))))
 				goto nla_put_failure;
 #else
 			if (nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
 					  htonl(ip_set_timeout_get(
-							ext_timeout(x, map)))))
+							ext_timeout(x, set)))))
 				goto nla_put_failure;
 #endif
 		}
 		if (SET_WITH_COUNTER(set) &&
-		    ip_set_put_counter(skb, ext_counter(x, map)))
+		    ip_set_put_counter(skb, ext_counter(x, set)))
 			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
@@ -245,14 +242,14 @@ mtype_gc(unsigned long ul_set)
 	 * but adding/deleting new entries is locked out */
 	read_lock_bh(&set->lock);
 	for (id = 0; id < map->elements; id++)
-		if (mtype_gc_test(id, map)) {
-			x = get_ext(map, id);
-			if (ip_set_timeout_expired(ext_timeout(x, map)))
+		if (mtype_gc_test(id, map, set->dsize)) {
+			x = get_ext(set, map, id);
+			if (ip_set_timeout_expired(ext_timeout(x, set)))
 				clear_bit(id, map->members);
 		}
 	read_unlock_bh(&set->lock);
 
-	map->gc.expires = jiffies + IPSET_GC_PERIOD(map->timeout) * HZ;
+	map->gc.expires = jiffies + IPSET_GC_PERIOD(set->timeout) * HZ;
 	add_timer(&map->gc);
 }
 
diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index 2ee210e..363022e 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -44,10 +44,7 @@ struct bitmap_ip {
 	u32 elements;		/* number of max elements in the set */
 	u32 hosts;		/* number of hosts in a subnet */
 	size_t memsize;		/* members size */
-	size_t dsize;		/* extensions struct size */
-	size_t offset[IPSET_EXT_ID_MAX]; /* Offsets to extensions */
 	u8 netmask;		/* subnet netmask */
-	u32 timeout;		/* timeout parameter */
 	struct timer_list gc;	/* garbage collection */
 };
 
@@ -65,20 +62,21 @@ ip_to_id(const struct bitmap_ip *m, u32 ip)
 /* Common functions */
 
 static inline int
-bitmap_ip_do_test(const struct bitmap_ip_adt_elem *e, struct bitmap_ip *map)
+bitmap_ip_do_test(const struct bitmap_ip_adt_elem *e,
+		  struct bitmap_ip *map, size_t dsize)
 {
 	return !!test_bit(e->id, map->members);
 }
 
 static inline int
-bitmap_ip_gc_test(u16 id, const struct bitmap_ip *map)
+bitmap_ip_gc_test(u16 id, const struct bitmap_ip *map, size_t dsize)
 {
 	return !!test_bit(id, map->members);
 }
 
 static inline int
 bitmap_ip_do_add(const struct bitmap_ip_adt_elem *e, struct bitmap_ip *map,
-		 u32 flags)
+		 u32 flags, size_t dsize)
 {
 	return !!test_and_set_bit(e->id, map->members);
 }
@@ -90,7 +88,8 @@ bitmap_ip_do_del(const struct bitmap_ip_adt_elem *e, struct bitmap_ip *map)
 }
 
 static inline int
-bitmap_ip_do_list(struct sk_buff *skb, const struct bitmap_ip *map, u32 id)
+bitmap_ip_do_list(struct sk_buff *skb, const struct bitmap_ip *map, u32 id,
+		  size_t dsize)
 {
 	return nla_put_ipaddr4(skb, IPSET_ATTR_IP,
 			htonl(map->first_ip + id * map->hosts));
@@ -113,7 +112,7 @@ bitmap_ip_kadt(struct ip_set *set, const struct sk_buff *skb,
 	struct bitmap_ip *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct bitmap_ip_adt_elem e = { };
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, map);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 	u32 ip;
 
 	ip = ntohl(ip4addr(skb, opt->flags & IPSET_DIM_ONE_SRC));
@@ -133,7 +132,7 @@ bitmap_ip_uadt(struct ip_set *set, struct nlattr *tb[],
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	u32 ip = 0, ip_to = 0;
 	struct bitmap_ip_adt_elem e = { };
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(map);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	int ret = 0;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
@@ -200,7 +199,7 @@ bitmap_ip_same_set(const struct ip_set *a, const struct ip_set *b)
 	return x->first_ip == y->first_ip &&
 	       x->last_ip == y->last_ip &&
 	       x->netmask == y->netmask &&
-	       x->timeout == y->timeout &&
+	       a->timeout == b->timeout &&
 	       a->extensions == b->extensions;
 }
 
@@ -240,8 +239,8 @@ init_map_ip(struct ip_set *set, struct bitmap_ip *map,
 	map->members = ip_set_alloc(map->memsize);
 	if (!map->members)
 		return false;
-	if (map->dsize) {
-		map->extensions = ip_set_alloc(map->dsize * elements);
+	if (set->dsize) {
+		map->extensions = ip_set_alloc(set->dsize * elements);
 		if (!map->extensions) {
 			kfree(map->members);
 			return false;
@@ -252,7 +251,7 @@ init_map_ip(struct ip_set *set, struct bitmap_ip *map,
 	map->elements = elements;
 	map->hosts = hosts;
 	map->netmask = netmask;
-	map->timeout = IPSET_NO_TIMEOUT;
+	set->timeout = IPSET_NO_TIMEOUT;
 
 	set->data = map;
 	set->family = NFPROTO_IPV4;
@@ -341,10 +340,10 @@ bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	if (cadt_flags & IPSET_FLAG_WITH_COUNTERS) {
 		set->extensions |= IPSET_EXT_COUNTER;
 		if (tb[IPSET_ATTR_TIMEOUT]) {
-			map->dsize = sizeof(struct bitmap_ipct_elem);
-			map->offset[IPSET_EXT_ID_TIMEOUT] =
+			set->dsize = sizeof(struct bitmap_ipct_elem);
+			set->offset[IPSET_EXT_ID_TIMEOUT] =
 				offsetof(struct bitmap_ipct_elem, timeout);
-			map->offset[IPSET_EXT_ID_COUNTER] =
+			set->offset[IPSET_EXT_ID_COUNTER] =
 				offsetof(struct bitmap_ipct_elem, counter);
 
 			if (!init_map_ip(set, map, first_ip, last_ip,
@@ -353,14 +352,14 @@ bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 				return -ENOMEM;
 			}
 
-			map->timeout = ip_set_timeout_uget(
+			set->timeout = ip_set_timeout_uget(
 				tb[IPSET_ATTR_TIMEOUT]);
 			set->extensions |= IPSET_EXT_TIMEOUT;
 
 			bitmap_ip_gc_init(set, bitmap_ip_gc);
 		} else {
-			map->dsize = sizeof(struct bitmap_ipc_elem);
-			map->offset[IPSET_EXT_ID_COUNTER] =
+			set->dsize = sizeof(struct bitmap_ipc_elem);
+			set->offset[IPSET_EXT_ID_COUNTER] =
 				offsetof(struct bitmap_ipc_elem, counter);
 
 			if (!init_map_ip(set, map, first_ip, last_ip,
@@ -370,8 +369,8 @@ bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 			}
 		}
 	} else if (tb[IPSET_ATTR_TIMEOUT]) {
-		map->dsize = sizeof(struct bitmap_ipt_elem);
-		map->offset[IPSET_EXT_ID_TIMEOUT] =
+		set->dsize = sizeof(struct bitmap_ipt_elem);
+		set->offset[IPSET_EXT_ID_TIMEOUT] =
 			offsetof(struct bitmap_ipt_elem, timeout);
 
 		if (!init_map_ip(set, map, first_ip, last_ip,
@@ -380,12 +379,12 @@ bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 			return -ENOMEM;
 		}
 
-		map->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
+		set->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 		set->extensions |= IPSET_EXT_TIMEOUT;
 
 		bitmap_ip_gc_init(set, bitmap_ip_gc);
 	} else {
-		map->dsize = 0;
+		set->dsize = 0;
 		if (!init_map_ip(set, map, first_ip, last_ip,
 				 elements, hosts, netmask)) {
 			kfree(map);
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index e711875..74576cb 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -48,11 +48,8 @@ struct bitmap_ipmac {
 	u32 first_ip;		/* host byte order, included in range */
 	u32 last_ip;		/* host byte order, included in range */
 	u32 elements;		/* number of max elements in the set */
-	u32 timeout;		/* timeout value */
-	struct timer_list gc;	/* garbage collector */
 	size_t memsize;		/* members size */
-	size_t dsize;		/* size of element */
-	size_t offset[IPSET_EXT_ID_MAX]; /* Offsets to extensions */
+	struct timer_list gc;	/* garbage collector */
 };
 
 /* ADT structure for generic function args */
@@ -82,13 +79,13 @@ get_elem(void *extensions, u16 id, size_t dsize)
 
 static inline int
 bitmap_ipmac_do_test(const struct bitmap_ipmac_adt_elem *e,
-		     const struct bitmap_ipmac *map)
+		     const struct bitmap_ipmac *map, size_t dsize)
 {
 	const struct bitmap_ipmac_elem *elem;
 
 	if (!test_bit(e->id, map->members))
 		return 0;
-	elem = get_elem(map->extensions, e->id, map->dsize);
+	elem = get_elem(map->extensions, e->id, dsize);
 	if (elem->filled == MAC_FILLED)
 		return e->ether == NULL ||
 		       ether_addr_equal(e->ether, elem->ether);
@@ -97,13 +94,13 @@ bitmap_ipmac_do_test(const struct bitmap_ipmac_adt_elem *e,
 }
 
 static inline int
-bitmap_ipmac_gc_test(u16 id, const struct bitmap_ipmac *map)
+bitmap_ipmac_gc_test(u16 id, const struct bitmap_ipmac *map, size_t dsize)
 {
 	const struct bitmap_ipmac_elem *elem;
 
 	if (!test_bit(id, map->members))
 		return 0;
-	elem = get_elem(map->extensions, id, map->dsize);
+	elem = get_elem(map->extensions, id, dsize);
 	/* Timer not started for the incomplete elements */
 	return elem->filled == MAC_FILLED;
 }
@@ -117,13 +114,13 @@ bitmap_ipmac_is_filled(const struct bitmap_ipmac_elem *elem)
 static inline int
 bitmap_ipmac_add_timeout(unsigned long *timeout,
 			 const struct bitmap_ipmac_adt_elem *e,
-			 const struct ip_set_ext *ext,
+			 const struct ip_set_ext *ext, struct ip_set *set,
 			 struct bitmap_ipmac *map, int mode)
 {
 	u32 t = ext->timeout;
 
 	if (mode == IPSET_ADD_START_STORED_TIMEOUT) {
-		if (t == map->timeout)
+		if (t == set->timeout)
 			/* Timeout was not specified, get stored one */
 			t = *timeout;
 		ip_set_timeout_set(timeout, t);
@@ -142,11 +139,11 @@ bitmap_ipmac_add_timeout(unsigned long *timeout,
 
 static inline int
 bitmap_ipmac_do_add(const struct bitmap_ipmac_adt_elem *e,
-		    struct bitmap_ipmac *map, u32 flags)
+		    struct bitmap_ipmac *map, u32 flags, size_t dsize)
 {
 	struct bitmap_ipmac_elem *elem;
 
-	elem = get_elem(map->extensions, e->id, map->dsize);
+	elem = get_elem(map->extensions, e->id, dsize);
 	if (test_and_set_bit(e->id, map->members)) {
 		if (elem->filled == MAC_FILLED) {
 			if (e->ether && (flags & IPSET_FLAG_EXIST))
@@ -179,10 +176,11 @@ bitmap_ipmac_do_del(const struct bitmap_ipmac_adt_elem *e,
 }
 
 static inline unsigned long
-ip_set_timeout_stored(struct bitmap_ipmac *map, u32 id, unsigned long *timeout)
+ip_set_timeout_stored(struct bitmap_ipmac *map, u32 id, unsigned long *timeout,
+		      size_t dsize)
 {
 	const struct bitmap_ipmac_elem *elem =
-		get_elem(map->extensions, id, map->dsize);
+		get_elem(map->extensions, id, dsize);
 
 	return elem->filled == MAC_FILLED ? ip_set_timeout_get(timeout) :
 					    *timeout;
@@ -190,10 +188,10 @@ ip_set_timeout_stored(struct bitmap_ipmac *map, u32 id, unsigned long *timeout)
 
 static inline int
 bitmap_ipmac_do_list(struct sk_buff *skb, const struct bitmap_ipmac *map,
-		     u32 id)
+		     u32 id, size_t dsize)
 {
 	const struct bitmap_ipmac_elem *elem =
-		get_elem(map->extensions, id, map->dsize);
+		get_elem(map->extensions, id, dsize);
 
 	return nla_put_ipaddr4(skb, IPSET_ATTR_IP,
 			       htonl(map->first_ip + id)) ||
@@ -216,7 +214,7 @@ bitmap_ipmac_kadt(struct ip_set *set, const struct sk_buff *skb,
 	struct bitmap_ipmac *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct bitmap_ipmac_adt_elem e = {};
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, map);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 	u32 ip;
 
 	/* MAC can be src only */
@@ -245,7 +243,7 @@ bitmap_ipmac_uadt(struct ip_set *set, struct nlattr *tb[],
 	const struct bitmap_ipmac *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct bitmap_ipmac_adt_elem e = {};
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(map);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 ip = 0;
 	int ret = 0;
 
@@ -285,7 +283,7 @@ bitmap_ipmac_same_set(const struct ip_set *a, const struct ip_set *b)
 
 	return x->first_ip == y->first_ip &&
 	       x->last_ip == y->last_ip &&
-	       x->timeout == y->timeout &&
+	       a->timeout == b->timeout &&
 	       a->extensions == b->extensions;
 }
 
@@ -330,11 +328,11 @@ static bool
 init_map_ipmac(struct ip_set *set, struct bitmap_ipmac *map,
 	       u32 first_ip, u32 last_ip, u32 elements)
 {
-	map->members = ip_set_alloc((last_ip - first_ip + 1) * map->dsize);
+	map->members = ip_set_alloc((last_ip - first_ip + 1) * set->dsize);
 	if (!map->members)
 		return false;
-	if (map->dsize) {
-		map->extensions = ip_set_alloc(map->dsize * elements);
+	if (set->dsize) {
+		map->extensions = ip_set_alloc(set->dsize * elements);
 		if (!map->extensions) {
 			kfree(map->members);
 			return false;
@@ -343,7 +341,7 @@ init_map_ipmac(struct ip_set *set, struct bitmap_ipmac *map,
 	map->first_ip = first_ip;
 	map->last_ip = last_ip;
 	map->elements = elements;
-	map->timeout = IPSET_NO_TIMEOUT;
+	set->timeout = IPSET_NO_TIMEOUT;
 
 	set->data = map;
 	set->family = NFPROTO_IPV4;
@@ -404,10 +402,10 @@ bitmap_ipmac_create(struct ip_set *set, struct nlattr *tb[],
 	if (cadt_flags & IPSET_FLAG_WITH_COUNTERS) {
 		set->extensions |= IPSET_EXT_COUNTER;
 		if (tb[IPSET_ATTR_TIMEOUT]) {
-			map->dsize = sizeof(struct bitmap_ipmacct_elem);
-			map->offset[IPSET_EXT_ID_TIMEOUT] =
+			set->dsize = sizeof(struct bitmap_ipmacct_elem);
+			set->offset[IPSET_EXT_ID_TIMEOUT] =
 				offsetof(struct bitmap_ipmacct_elem, timeout);
-			map->offset[IPSET_EXT_ID_COUNTER] =
+			set->offset[IPSET_EXT_ID_COUNTER] =
 				offsetof(struct bitmap_ipmacct_elem, counter);
 
 			if (!init_map_ipmac(set, map, first_ip, last_ip,
@@ -415,13 +413,13 @@ bitmap_ipmac_create(struct ip_set *set, struct nlattr *tb[],
 				kfree(map);
 				return -ENOMEM;
 			}
-			map->timeout = ip_set_timeout_uget(
+			set->timeout = ip_set_timeout_uget(
 				tb[IPSET_ATTR_TIMEOUT]);
 			set->extensions |= IPSET_EXT_TIMEOUT;
 			bitmap_ipmac_gc_init(set, bitmap_ipmac_gc);
 		} else {
-			map->dsize = sizeof(struct bitmap_ipmacc_elem);
-			map->offset[IPSET_EXT_ID_COUNTER] =
+			set->dsize = sizeof(struct bitmap_ipmacc_elem);
+			set->offset[IPSET_EXT_ID_COUNTER] =
 				offsetof(struct bitmap_ipmacc_elem, counter);
 
 			if (!init_map_ipmac(set, map, first_ip, last_ip,
@@ -431,19 +429,19 @@ bitmap_ipmac_create(struct ip_set *set, struct nlattr *tb[],
 			}
 		}
 	} else if (tb[IPSET_ATTR_TIMEOUT]) {
-		map->dsize = sizeof(struct bitmap_ipmact_elem);
-		map->offset[IPSET_EXT_ID_TIMEOUT] =
+		set->dsize = sizeof(struct bitmap_ipmact_elem);
+		set->offset[IPSET_EXT_ID_TIMEOUT] =
 			offsetof(struct bitmap_ipmact_elem, timeout);
 
 		if (!init_map_ipmac(set, map, first_ip, last_ip, elements)) {
 			kfree(map);
 			return -ENOMEM;
 		}
-		map->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
+		set->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 		set->extensions |= IPSET_EXT_TIMEOUT;
 		bitmap_ipmac_gc_init(set, bitmap_ipmac_gc);
 	} else {
-		map->dsize = sizeof(struct bitmap_ipmac_elem);
+		set->dsize = sizeof(struct bitmap_ipmac_elem);
 
 		if (!init_map_ipmac(set, map, first_ip, last_ip, elements)) {
 			kfree(map);
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index bebc137..71da319 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -38,9 +38,6 @@ struct bitmap_port {
 	u16 last_port;		/* host byte order, included in range */
 	u32 elements;		/* number of max elements in the set */
 	size_t memsize;		/* members size */
-	size_t dsize;		/* extensions struct size */
-	size_t offset[IPSET_EXT_ID_MAX]; /* Offsets to extensions */
-	u32 timeout;		/* timeout parameter */
 	struct timer_list gc;	/* garbage collection */
 };
 
@@ -59,20 +56,20 @@ port_to_id(const struct bitmap_port *m, u16 port)
 
 static inline int
 bitmap_port_do_test(const struct bitmap_port_adt_elem *e,
-		    const struct bitmap_port *map)
+		    const struct bitmap_port *map, size_t dsize)
 {
 	return !!test_bit(e->id, map->members);
 }
 
 static inline int
-bitmap_port_gc_test(u16 id, const struct bitmap_port *map)
+bitmap_port_gc_test(u16 id, const struct bitmap_port *map, size_t dsize)
 {
 	return !!test_bit(id, map->members);
 }
 
 static inline int
 bitmap_port_do_add(const struct bitmap_port_adt_elem *e,
-		   struct bitmap_port *map, u32 flags)
+		   struct bitmap_port *map, u32 flags, size_t dsize)
 {
 	return !!test_and_set_bit(e->id, map->members);
 }
@@ -85,7 +82,8 @@ bitmap_port_do_del(const struct bitmap_port_adt_elem *e,
 }
 
 static inline int
-bitmap_port_do_list(struct sk_buff *skb, const struct bitmap_port *map, u32 id)
+bitmap_port_do_list(struct sk_buff *skb, const struct bitmap_port *map, u32 id,
+		    size_t dsize)
 {
 	return nla_put_net16(skb, IPSET_ATTR_PORT,
 			     htons(map->first_port + id));
@@ -106,7 +104,7 @@ bitmap_port_kadt(struct ip_set *set, const struct sk_buff *skb,
 	struct bitmap_port *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct bitmap_port_adt_elem e = {};
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, map);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 	__be16 __port;
 	u16 port = 0;
 
@@ -131,7 +129,7 @@ bitmap_port_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct bitmap_port *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct bitmap_port_adt_elem e = {};
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(map);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 port;	/* wraparound */
 	u16 port_to;
 	int ret = 0;
@@ -191,7 +189,7 @@ bitmap_port_same_set(const struct ip_set *a, const struct ip_set *b)
 
 	return x->first_port == y->first_port &&
 	       x->last_port == y->last_port &&
-	       x->timeout == y->timeout &&
+	       a->timeout == b->timeout &&
 	       a->extensions == b->extensions;
 }
 
@@ -230,8 +228,8 @@ init_map_port(struct ip_set *set, struct bitmap_port *map,
 	map->members = ip_set_alloc(map->memsize);
 	if (!map->members)
 		return false;
-	if (map->dsize) {
-		map->extensions = ip_set_alloc(map->dsize * map->elements);
+	if (set->dsize) {
+		map->extensions = ip_set_alloc(set->dsize * map->elements);
 		if (!map->extensions) {
 			kfree(map->members);
 			return false;
@@ -239,7 +237,7 @@ init_map_port(struct ip_set *set, struct bitmap_port *map,
 	}
 	map->first_port = first_port;
 	map->last_port = last_port;
-	map->timeout = IPSET_NO_TIMEOUT;
+	set->timeout = IPSET_NO_TIMEOUT;
 
 	set->data = map;
 	set->family = NFPROTO_UNSPEC;
@@ -281,23 +279,23 @@ bitmap_port_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	if (cadt_flags & IPSET_FLAG_WITH_COUNTERS) {
 		set->extensions |= IPSET_EXT_COUNTER;
 		if (tb[IPSET_ATTR_TIMEOUT]) {
-			map->dsize = sizeof(struct bitmap_portct_elem);
-			map->offset[IPSET_EXT_ID_TIMEOUT] =
+			set->dsize = sizeof(struct bitmap_portct_elem);
+			set->offset[IPSET_EXT_ID_TIMEOUT] =
 				offsetof(struct bitmap_portct_elem, timeout);
-			map->offset[IPSET_EXT_ID_COUNTER] =
+			set->offset[IPSET_EXT_ID_COUNTER] =
 				offsetof(struct bitmap_portct_elem, counter);
 			if (!init_map_port(set, map, first_port, last_port)) {
 				kfree(map);
 				return -ENOMEM;
 			}
 
-			map->timeout =
+			set->timeout =
 				ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 			set->extensions |= IPSET_EXT_TIMEOUT;
 			bitmap_port_gc_init(set, bitmap_port_gc);
 		} else {
-			map->dsize = sizeof(struct bitmap_portc_elem);
-			map->offset[IPSET_EXT_ID_COUNTER] =
+			set->dsize = sizeof(struct bitmap_portc_elem);
+			set->offset[IPSET_EXT_ID_COUNTER] =
 				offsetof(struct bitmap_portc_elem, counter);
 			if (!init_map_port(set, map, first_port, last_port)) {
 				kfree(map);
@@ -305,19 +303,19 @@ bitmap_port_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 			}
 		}
 	} else if (tb[IPSET_ATTR_TIMEOUT]) {
-		map->dsize = sizeof(struct bitmap_portt_elem);
-		map->offset[IPSET_EXT_ID_TIMEOUT] =
+		set->dsize = sizeof(struct bitmap_portt_elem);
+		set->offset[IPSET_EXT_ID_TIMEOUT] =
 			offsetof(struct bitmap_portt_elem, timeout);
 		if (!init_map_port(set, map, first_port, last_port)) {
 			kfree(map);
 			return -ENOMEM;
 		}
 
-		map->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
+		set->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 		set->extensions |= IPSET_EXT_TIMEOUT;
 		bitmap_port_gc_init(set, bitmap_port_gc);
 	} else {
-		map->dsize = 0;
+		set->dsize = 0;
 		if (!init_map_port(set, map, first_port, last_port)) {
 			kfree(map);
 			return -ENOMEM;
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index e4db925..0cb840e 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -178,11 +178,6 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 #define NLEN(family)		0
 #endif /* IP_SET_HASH_WITH_NETS */
 
-#define ext_timeout(e, h)	\
-(unsigned long *)(((void *)(e)) + (h)->offset[IPSET_EXT_ID_TIMEOUT])
-#define ext_counter(e, h)	\
-(struct ip_set_counter *)(((void *)(e)) + (h)->offset[IPSET_EXT_ID_COUNTER])
-
 #endif /* _IP_SET_HASH_GEN_H */
 
 /* Family dependent templates */
@@ -276,9 +271,6 @@ struct htype {
 	u32 maxelem;		/* max elements in the hash */
 	u32 elements;		/* current element (vs timeout) */
 	u32 initval;		/* random jhash init value */
-	u32 timeout;		/* timeout value, if enabled */
-	size_t dsize;		/* data struct size */
-	size_t offset[IPSET_EXT_ID_MAX]; /* Offsets to extensions */
 	struct timer_list gc;	/* garbage collection when timeout enabled */
 	struct mtype_elem next; /* temporary storage for uadd */
 #ifdef IP_SET_HASH_WITH_MULTI
@@ -351,7 +343,7 @@ mtype_del_cidr(struct htype *h, u8 cidr, u8 nets_length, u8 n)
 /* Calculate the actual memory size of the set data */
 static size_t
 mtype_ahash_memsize(const struct htype *h, const struct htable *t,
-		    u8 nets_length)
+		    u8 nets_length, size_t dsize)
 {
 	u32 i;
 	size_t memsize = sizeof(*h)
@@ -362,7 +354,7 @@ mtype_ahash_memsize(const struct htype *h, const struct htable *t,
 			 + jhash_size(t->htable_bits) * sizeof(struct hbucket);
 
 	for (i = 0; i < jhash_size(t->htable_bits); i++)
-		memsize += t->bucket[i].size * h->dsize;
+		memsize += t->bucket[i].size * dsize;
 
 	return memsize;
 }
@@ -417,10 +409,10 @@ mtype_gc_init(struct ip_set *set, void (*gc)(unsigned long ul_set))
 	init_timer(&h->gc);
 	h->gc.data = (unsigned long) set;
 	h->gc.function = gc;
-	h->gc.expires = jiffies + IPSET_GC_PERIOD(h->timeout) * HZ;
+	h->gc.expires = jiffies + IPSET_GC_PERIOD(set->timeout) * HZ;
 	add_timer(&h->gc);
 	pr_debug("gc initialized, run in every %u\n",
-		 IPSET_GC_PERIOD(h->timeout));
+		 IPSET_GC_PERIOD(set->timeout));
 }
 
 static bool
@@ -431,7 +423,7 @@ mtype_same_set(const struct ip_set *a, const struct ip_set *b)
 
 	/* Resizing changes htable_bits, so we ignore it */
 	return x->maxelem == y->maxelem &&
-	       x->timeout == y->timeout &&
+	       a->timeout == b->timeout &&
 #ifdef IP_SET_HASH_WITH_NETMASK
 	       x->netmask == y->netmask &&
 #endif
@@ -444,7 +436,7 @@ mtype_same_set(const struct ip_set *a, const struct ip_set *b)
 
 /* Delete expired elements from the hashtable */
 static void
-mtype_expire(struct htype *h, u8 nets_length, size_t dsize)
+mtype_expire(struct ip_set *set, struct htype *h, u8 nets_length, size_t dsize)
 {
 	struct htable *t;
 	struct hbucket *n;
@@ -458,7 +450,7 @@ mtype_expire(struct htype *h, u8 nets_length, size_t dsize)
 		n = hbucket(t, i);
 		for (j = 0; j < n->pos; j++) {
 			data = ahash_data(n, j, dsize);
-			if (ip_set_timeout_expired(ext_timeout(data, h))) {
+			if (ip_set_timeout_expired(ext_timeout(data, set))) {
 				pr_debug("expired %u/%u\n", i, j);
 #ifdef IP_SET_HASH_WITH_NETS
 				mtype_del_cidr(h, CIDR(data->cidr),
@@ -497,10 +489,10 @@ mtype_gc(unsigned long ul_set)
 
 	pr_debug("called\n");
 	write_lock_bh(&set->lock);
-	mtype_expire(h, NLEN(set->family), h->dsize);
+	mtype_expire(set, h, NLEN(set->family), set->dsize);
 	write_unlock_bh(&set->lock);
 
-	h->gc.expires = jiffies + IPSET_GC_PERIOD(h->timeout) * HZ;
+	h->gc.expires = jiffies + IPSET_GC_PERIOD(set->timeout) * HZ;
 	add_timer(&h->gc);
 }
 
@@ -526,7 +518,7 @@ mtype_resize(struct ip_set *set, bool retried)
 	if (SET_WITH_TIMEOUT(set) && !retried) {
 		i = h->elements;
 		write_lock_bh(&set->lock);
-		mtype_expire(set->data, NLEN(set->family), h->dsize);
+		mtype_expire(set, set->data, NLEN(set->family), set->dsize);
 		write_unlock_bh(&set->lock);
 		if (h->elements < i)
 			return 0;
@@ -553,13 +545,13 @@ retry:
 	for (i = 0; i < jhash_size(orig->htable_bits); i++) {
 		n = hbucket(orig, i);
 		for (j = 0; j < n->pos; j++) {
-			data = ahash_data(n, j, h->dsize);
+			data = ahash_data(n, j, set->dsize);
 #ifdef IP_SET_HASH_WITH_NETS
 			flags = 0;
 			mtype_data_reset_flags(data, &flags);
 #endif
 			m = hbucket(t, HKEY(data, h->initval, htable_bits));
-			ret = hbucket_elem_add(m, AHASH_MAX(h), h->dsize);
+			ret = hbucket_elem_add(m, AHASH_MAX(h), set->dsize);
 			if (ret < 0) {
 #ifdef IP_SET_HASH_WITH_NETS
 				mtype_data_reset_flags(data, &flags);
@@ -570,8 +562,8 @@ retry:
 					goto retry;
 				return ret;
 			}
-			d = ahash_data(m, m->pos++, h->dsize);
-			memcpy(d, data, h->dsize);
+			d = ahash_data(m, m->pos++, set->dsize);
+			memcpy(d, data, set->dsize);
 #ifdef IP_SET_HASH_WITH_NETS
 			mtype_data_reset_flags(d, &flags);
 #endif
@@ -609,7 +601,7 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 
 	if (SET_WITH_TIMEOUT(set) && h->elements >= h->maxelem)
 		/* FIXME: when set is full, we slow down here */
-		mtype_expire(h, NLEN(set->family), h->dsize);
+		mtype_expire(set, h, NLEN(set->family), set->dsize);
 
 	if (h->elements >= h->maxelem) {
 		if (net_ratelimit())
@@ -623,11 +615,11 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	key = HKEY(value, h->initval, t->htable_bits);
 	n = hbucket(t, key);
 	for (i = 0; i < n->pos; i++) {
-		data = ahash_data(n, i, h->dsize);
+		data = ahash_data(n, i, set->dsize);
 		if (mtype_data_equal(data, d, &multi)) {
 			if (flag_exist ||
 			    (SET_WITH_TIMEOUT(set) &&
-			     ip_set_timeout_expired(ext_timeout(data, h)))) {
+			     ip_set_timeout_expired(ext_timeout(data, set)))) {
 				/* Just the extensions could be overwritten */
 				j = i;
 				goto reuse_slot;
@@ -638,14 +630,14 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		}
 		/* Reuse first timed out entry */
 		if (SET_WITH_TIMEOUT(set) &&
-		    ip_set_timeout_expired(ext_timeout(data, h)) &&
+		    ip_set_timeout_expired(ext_timeout(data, set)) &&
 		    j != AHASH_MAX(h) + 1)
 			j = i;
 	}
 reuse_slot:
 	if (j != AHASH_MAX(h) + 1) {
 		/* Fill out reused slot */
-		data = ahash_data(n, j, h->dsize);
+		data = ahash_data(n, j, set->dsize);
 #ifdef IP_SET_HASH_WITH_NETS
 		mtype_del_cidr(h, CIDR(data->cidr), NLEN(set->family), 0);
 		mtype_add_cidr(h, CIDR(d->cidr), NLEN(set->family), 0);
@@ -653,13 +645,13 @@ reuse_slot:
 	} else {
 		/* Use/create a new slot */
 		TUNE_AHASH_MAX(h, multi);
-		ret = hbucket_elem_add(n, AHASH_MAX(h), h->dsize);
+		ret = hbucket_elem_add(n, AHASH_MAX(h), set->dsize);
 		if (ret != 0) {
 			if (ret == -EAGAIN)
 				mtype_data_next(&h->next, d);
 			goto out;
 		}
-		data = ahash_data(n, n->pos++, h->dsize);
+		data = ahash_data(n, n->pos++, set->dsize);
 #ifdef IP_SET_HASH_WITH_NETS
 		mtype_add_cidr(h, CIDR(d->cidr), NLEN(set->family), 0);
 #endif
@@ -670,9 +662,9 @@ reuse_slot:
 	mtype_data_set_flags(data, flags);
 #endif
 	if (SET_WITH_TIMEOUT(set))
-		ip_set_timeout_set(ext_timeout(data, h), ext->timeout);
+		ip_set_timeout_set(ext_timeout(data, set), ext->timeout);
 	if (SET_WITH_COUNTER(set))
-		ip_set_init_counter(ext_counter(data, h), ext);
+		ip_set_init_counter(ext_counter(data, set), ext);
 
 out:
 	rcu_read_unlock_bh();
@@ -699,16 +691,16 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	key = HKEY(value, h->initval, t->htable_bits);
 	n = hbucket(t, key);
 	for (i = 0; i < n->pos; i++) {
-		data = ahash_data(n, i, h->dsize);
+		data = ahash_data(n, i, set->dsize);
 		if (!mtype_data_equal(data, d, &multi))
 			continue;
 		if (SET_WITH_TIMEOUT(set) &&
-		    ip_set_timeout_expired(ext_timeout(data, h)))
+		    ip_set_timeout_expired(ext_timeout(data, set)))
 			goto out;
 		if (i != n->pos - 1)
 			/* Not last one */
-			memcpy(data, ahash_data(n, n->pos - 1, h->dsize),
-			       h->dsize);
+			memcpy(data, ahash_data(n, n->pos - 1, set->dsize),
+			       set->dsize);
 
 		n->pos--;
 		h->elements--;
@@ -717,14 +709,14 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 #endif
 		if (n->pos + AHASH_INIT_SIZE < n->size) {
 			void *tmp = kzalloc((n->size - AHASH_INIT_SIZE)
-					    * h->dsize,
+					    * set->dsize,
 					    GFP_ATOMIC);
 			if (!tmp) {
 				ret = 0;
 				goto out;
 			}
 			n->size -= AHASH_INIT_SIZE;
-			memcpy(tmp, n->value, n->size * h->dsize);
+			memcpy(tmp, n->value, n->size * set->dsize);
 			kfree(n->value);
 			n->value = tmp;
 		}
@@ -742,8 +734,7 @@ mtype_data_match(struct mtype_elem *data, const struct ip_set_ext *ext,
 		 struct ip_set_ext *mext, struct ip_set *set, u32 flags)
 {
 	if (SET_WITH_COUNTER(set))
-		ip_set_update_counter(ext_counter(data,
-						  (struct htype *)(set->data)),
+		ip_set_update_counter(ext_counter(data, set),
 				      ext, mext, flags);
 	return mtype_do_data_match(data);
 }
@@ -770,12 +761,12 @@ mtype_test_cidrs(struct ip_set *set, struct mtype_elem *d,
 		key = HKEY(d, h->initval, t->htable_bits);
 		n = hbucket(t, key);
 		for (i = 0; i < n->pos; i++) {
-			data = ahash_data(n, i, h->dsize);
+			data = ahash_data(n, i, set->dsize);
 			if (!mtype_data_equal(data, d, &multi))
 				continue;
 			if (SET_WITH_TIMEOUT(set)) {
 				if (!ip_set_timeout_expired(
-							ext_timeout(data, h)))
+						ext_timeout(data, set)))
 					return mtype_data_match(data, ext,
 								mext, set,
 								flags);
@@ -818,10 +809,10 @@ mtype_test(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	key = HKEY(d, h->initval, t->htable_bits);
 	n = hbucket(t, key);
 	for (i = 0; i < n->pos; i++) {
-		data = ahash_data(n, i, h->dsize);
+		data = ahash_data(n, i, set->dsize);
 		if (mtype_data_equal(data, d, &multi) &&
 		    !(SET_WITH_TIMEOUT(set) &&
-		      ip_set_timeout_expired(ext_timeout(data, h)))) {
+		      ip_set_timeout_expired(ext_timeout(data, set)))) {
 			ret = mtype_data_match(data, ext, mext, set, flags);
 			goto out;
 		}
@@ -841,7 +832,7 @@ mtype_head(struct ip_set *set, struct sk_buff *skb)
 	size_t memsize;
 
 	t = rcu_dereference_bh_nfnl(h->table);
-	memsize = mtype_ahash_memsize(h, t, NLEN(set->family));
+	memsize = mtype_ahash_memsize(h, t, NLEN(set->family), set->dsize);
 
 	nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
 	if (!nested)
@@ -858,7 +849,7 @@ mtype_head(struct ip_set *set, struct sk_buff *skb)
 	if (nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
 	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE, htonl(memsize)) ||
 	    ((set->extensions & IPSET_EXT_TIMEOUT) &&
-	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(h->timeout))) ||
+	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(set->timeout))) ||
 	    ((set->extensions & IPSET_EXT_COUNTER) &&
 	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS,
 			   htonl(IPSET_FLAG_WITH_COUNTERS))))
@@ -894,9 +885,9 @@ mtype_list(const struct ip_set *set,
 		n = hbucket(t, cb->args[2]);
 		pr_debug("cb->args[2]: %lu, t %p n %p\n", cb->args[2], t, n);
 		for (i = 0; i < n->pos; i++) {
-			e = ahash_data(n, i, h->dsize);
+			e = ahash_data(n, i, set->dsize);
 			if (SET_WITH_TIMEOUT(set) &&
-			    ip_set_timeout_expired(ext_timeout(e, h)))
+			    ip_set_timeout_expired(ext_timeout(e, set)))
 				continue;
 			pr_debug("list hash %lu hbucket %p i %u, data %p\n",
 				 cb->args[2], n, i, e);
@@ -913,10 +904,10 @@ mtype_list(const struct ip_set *set,
 			if (SET_WITH_TIMEOUT(set) &&
 			    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
 					  htonl(ip_set_timeout_get(
-						ext_timeout(e, h)))))
+						ext_timeout(e, set)))))
 				goto nla_put_failure;
 			if (SET_WITH_COUNTER(set) &&
-			    ip_set_put_counter(skb, ext_counter(e, h)))
+			    ip_set_put_counter(skb, ext_counter(e, set)))
 				goto nla_put_failure;
 			ipset_nest_end(skb, nested);
 		}
@@ -1026,7 +1017,7 @@ IPSET_TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	h->netmask = netmask;
 #endif
 	get_random_bytes(&h->initval, sizeof(h->initval));
-	h->timeout = IPSET_NO_TIMEOUT;
+	set->timeout = IPSET_NO_TIMEOUT;
 
 	hbits = htable_bits(hashsize);
 	hsize = htable_size(hbits);
@@ -1053,30 +1044,30 @@ IPSET_TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	if (cadt_flags & IPSET_FLAG_WITH_COUNTERS) {
 		set->extensions |= IPSET_EXT_COUNTER;
 		if (tb[IPSET_ATTR_TIMEOUT]) {
-			h->timeout =
+			set->timeout =
 				ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 			set->extensions |= IPSET_EXT_TIMEOUT;
 			if (set->family == NFPROTO_IPV4) {
-				h->dsize = sizeof(struct
+				set->dsize = sizeof(struct
 					IPSET_TOKEN(HTYPE, 4ct_elem));
-				h->offset[IPSET_EXT_ID_TIMEOUT] =
+				set->offset[IPSET_EXT_ID_TIMEOUT] =
 					offsetof(struct
 						IPSET_TOKEN(HTYPE, 4ct_elem),
 						timeout);
-				h->offset[IPSET_EXT_ID_COUNTER] =
+				set->offset[IPSET_EXT_ID_COUNTER] =
 					offsetof(struct
 						IPSET_TOKEN(HTYPE, 4ct_elem),
 						counter);
 				IPSET_TOKEN(HTYPE, 4_gc_init)(set,
 					IPSET_TOKEN(HTYPE, 4_gc));
 			} else {
-				h->dsize = sizeof(struct
+				set->dsize = sizeof(struct
 					IPSET_TOKEN(HTYPE, 6ct_elem));
-				h->offset[IPSET_EXT_ID_TIMEOUT] =
+				set->offset[IPSET_EXT_ID_TIMEOUT] =
 					offsetof(struct
 						IPSET_TOKEN(HTYPE, 6ct_elem),
 						timeout);
-				h->offset[IPSET_EXT_ID_COUNTER] =
+				set->offset[IPSET_EXT_ID_COUNTER] =
 					offsetof(struct
 						IPSET_TOKEN(HTYPE, 6ct_elem),
 						counter);
@@ -1085,36 +1076,36 @@ IPSET_TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
 			}
 		} else {
 			if (set->family == NFPROTO_IPV4) {
-				h->dsize =
+				set->dsize =
 					sizeof(struct
 						IPSET_TOKEN(HTYPE, 4c_elem));
-				h->offset[IPSET_EXT_ID_COUNTER] =
+				set->offset[IPSET_EXT_ID_COUNTER] =
 					offsetof(struct
 						IPSET_TOKEN(HTYPE, 4c_elem),
 						counter);
 			} else {
-				h->dsize =
+				set->dsize =
 					sizeof(struct
 						IPSET_TOKEN(HTYPE, 6c_elem));
-				h->offset[IPSET_EXT_ID_COUNTER] =
+				set->offset[IPSET_EXT_ID_COUNTER] =
 					offsetof(struct
 						IPSET_TOKEN(HTYPE, 6c_elem),
 						counter);
 			}
 		}
 	} else if (tb[IPSET_ATTR_TIMEOUT]) {
-		h->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
+		set->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 		set->extensions |= IPSET_EXT_TIMEOUT;
 		if (set->family == NFPROTO_IPV4) {
-			h->dsize = sizeof(struct IPSET_TOKEN(HTYPE, 4t_elem));
-			h->offset[IPSET_EXT_ID_TIMEOUT] =
+			set->dsize = sizeof(struct IPSET_TOKEN(HTYPE, 4t_elem));
+			set->offset[IPSET_EXT_ID_TIMEOUT] =
 				offsetof(struct IPSET_TOKEN(HTYPE, 4t_elem),
 					 timeout);
 			IPSET_TOKEN(HTYPE, 4_gc_init)(set,
 				IPSET_TOKEN(HTYPE, 4_gc));
 		} else {
-			h->dsize = sizeof(struct IPSET_TOKEN(HTYPE, 6t_elem));
-			h->offset[IPSET_EXT_ID_TIMEOUT] =
+			set->dsize = sizeof(struct IPSET_TOKEN(HTYPE, 6t_elem));
+			set->offset[IPSET_EXT_ID_TIMEOUT] =
 				offsetof(struct IPSET_TOKEN(HTYPE, 6t_elem),
 					 timeout);
 			IPSET_TOKEN(HTYPE, 6_gc_init)(set,
@@ -1122,9 +1113,9 @@ IPSET_TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
 		}
 	} else {
 		if (set->family == NFPROTO_IPV4)
-			h->dsize = sizeof(struct IPSET_TOKEN(HTYPE, 4_elem));
+			set->dsize = sizeof(struct IPSET_TOKEN(HTYPE, 4_elem));
 		else
-			h->dsize = sizeof(struct IPSET_TOKEN(HTYPE, 6_elem));
+			set->dsize = sizeof(struct IPSET_TOKEN(HTYPE, 6_elem));
 	}
 
 	pr_debug("create %s hashsize %u (%u) maxelem %u: %p(%p)\n",
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 260c9a8..bbde7c3 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -99,7 +99,7 @@ hash_ip4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	const struct hash_ip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ip4_elem e = {};
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 	__be32 ip;
 
 	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &ip);
@@ -118,7 +118,7 @@ hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	const struct hash_ip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ip4_elem e = {};
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 ip = 0, ip_to = 0, hosts;
 	int ret = 0;
 
@@ -253,7 +253,7 @@ hash_ip6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	const struct hash_ip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ip6_elem e = {};
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &e.ip.in6);
 	hash_ip6_netmask(&e.ip, h->netmask);
@@ -270,7 +270,7 @@ hash_ip6_uadt(struct ip_set *set, struct nlattr *tb[],
 	const struct hash_ip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ip6_elem e = {};
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index 64caad3..dd175d6 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -116,10 +116,9 @@ hash_ipport4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		  const struct xt_action_param *par,
 		  enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_ipport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipport4_elem e = { };
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	if (!ip_set_get_ip4_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
 				 &e.port, &e.proto))
@@ -136,7 +135,7 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	const struct hash_ipport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipport4_elem e = { };
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 ip, ip_to = 0, p = 0, port, port_to;
 	bool with_ports = false;
 	int ret;
@@ -306,10 +305,9 @@ hash_ipport6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		  const struct xt_action_param *par,
 		  enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_ipport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipport6_elem e = { };
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	if (!ip_set_get_ip6_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
 				 &e.port, &e.proto))
@@ -326,7 +324,7 @@ hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	const struct hash_ipport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipport6_elem e = { };
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 port, port_to;
 	bool with_ports = false;
 	int ret;
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 2873bbc..87a2cfa 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -120,10 +120,9 @@ hash_ipportip4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		    const struct xt_action_param *par,
 		    enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_ipportip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportip4_elem e = { };
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	if (!ip_set_get_ip4_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
 				 &e.port, &e.proto))
@@ -141,7 +140,7 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	const struct hash_ipportip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportip4_elem e = { };
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 ip, ip_to = 0, p = 0, port, port_to;
 	bool with_ports = false;
 	int ret;
@@ -319,10 +318,9 @@ hash_ipportip6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		    const struct xt_action_param *par,
 		    enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	const struct hash_ipportip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportip6_elem e = { };
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	if (!ip_set_get_ip6_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
 				 &e.port, &e.proto))
@@ -340,7 +338,7 @@ hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 	const struct hash_ipportip *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportip6_elem e = { };
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 port, port_to;
 	bool with_ports = false;
 	int ret;
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 6ce5a8e..0b9a28d 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -172,7 +172,7 @@ hash_ipportnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	struct hash_ipportnet4_elem e = {
 		.cidr = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK) - 1,
 	};
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	if (adt == IPSET_TEST)
 		e.cidr = HOST_MASK - 1;
@@ -195,7 +195,7 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	const struct hash_ipportnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportnet4_elem e = { .cidr = HOST_MASK - 1 };
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 ip = 0, ip_to = 0, p = 0, port, port_to;
 	u32 ip2_from = 0, ip2_to = 0, ip2_last, ip2;
 	bool with_ports = false;
@@ -306,9 +306,9 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 						       : port;
 		for (; p <= port_to; p++) {
 			e.port = htons(p);
-			ip2 = retried
-			      && ip == ntohl(h->next.ip)
-			      && p == ntohs(h->next.port)
+			ip2 = retried &&
+			      ip == ntohl(h->next.ip) &&
+			      p == ntohs(h->next.port)
 				? ntohl(h->next.ip2) : ip2_from;
 			while (!after(ip2, ip2_to)) {
 				e.ip2 = htonl(ip2);
@@ -456,7 +456,7 @@ hash_ipportnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	struct hash_ipportnet6_elem e = {
 		.cidr = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK) - 1,
 	};
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	if (adt == IPSET_TEST)
 		e.cidr = HOST_MASK - 1;
@@ -479,7 +479,7 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	const struct hash_ipportnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportnet6_elem e = { .cidr = HOST_MASK - 1 };
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 port, port_to;
 	bool with_ports = false;
 	u8 cidr;
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index ec1c7dc..1d4caa5 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -145,7 +145,7 @@ hash_net4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	struct hash_net4_elem e = {
 		.cidr = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
 	};
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	if (e.cidr == 0)
 		return -EINVAL;
@@ -165,7 +165,7 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 	const struct hash_net *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_net4_elem e = { .cidr = HOST_MASK };
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 ip = 0, ip_to = 0, last;
 	int ret;
 
@@ -340,7 +340,7 @@ hash_net6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	struct hash_net6_elem e = {
 		.cidr = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
 	};
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	if (e.cidr == 0)
 		return -EINVAL;
@@ -357,10 +357,9 @@ static int
 hash_net6_uadt(struct ip_set *set, struct nlattr *tb[],
 	       enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	const struct hash_net *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_net6_elem e = { .cidr = HOST_MASK };
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 814b4e3..2f0ffe3 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -268,7 +268,7 @@ hash_netiface4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		.cidr = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
 		.elem = 1,
 	};
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 	int ret;
 
 	if (e.cidr == 0)
@@ -319,7 +319,7 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct hash_netiface *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netiface4_elem e = { .cidr = HOST_MASK, .elem = 1 };
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 ip = 0, ip_to = 0, last;
 	char iface[IFNAMSIZ];
 	int ret;
@@ -537,7 +537,7 @@ hash_netiface6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		.cidr = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
 		.elem = 1,
 	};
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 	int ret;
 
 	if (e.cidr == 0)
@@ -584,7 +584,7 @@ hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct hash_netiface *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netiface6_elem e = { .cidr = HOST_MASK, .elem = 1 };
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	char iface[IFNAMSIZ];
 	int ret;
 
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 3bd923d..cab2366 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -164,7 +164,7 @@ hash_netport4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	struct hash_netport4_elem e = {
 		.cidr = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK) - 1,
 	};
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	if (adt == IPSET_TEST)
 		e.cidr = HOST_MASK - 1;
@@ -186,7 +186,7 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	const struct hash_netport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netport4_elem e = { .cidr = HOST_MASK - 1 };
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 port, port_to, p = 0, ip = 0, ip_to = 0, last;
 	bool with_ports = false;
 	u8 cidr;
@@ -409,7 +409,7 @@ hash_netport6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	struct hash_netport6_elem e = {
 		.cidr = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK) - 1,
 	};
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	if (adt == IPSET_TEST)
 		e.cidr = HOST_MASK - 1;
@@ -431,7 +431,7 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	const struct hash_netport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netport6_elem e = { .cidr = HOST_MASK  - 1 };
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(h);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 port, port_to;
 	bool with_ports = false;
 	u8 cidr;
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 0ed19b5..f22d05d 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -58,24 +58,13 @@ struct set_adt_elem {
 
 /* Type structure */
 struct list_set {
-	size_t dsize;		/* element size */
-	size_t offset[IPSET_EXT_ID_MAX]; /* Offsets to extensions */
 	u32 size;		/* size of set list array */
-	u32 timeout;		/* timeout value */
 	struct timer_list gc;	/* garbage collection */
 	struct set_elem members[0]; /* the set members */
 };
 
-static inline struct set_elem *
-list_set_elem(const struct list_set *map, u32 id)
-{
-	return (struct set_elem *)((void *)map->members + id * map->dsize);
-}
-
-#define ext_timeout(e, m)	\
-(unsigned long *)((void *)(e) + (m)->offset[IPSET_EXT_ID_TIMEOUT])
-#define ext_counter(e, m)	\
-(struct ip_set_counter *)((void *)(e) + (m)->offset[IPSET_EXT_ID_COUNTER])
+#define list_set_elem(set, map, id)	\
+	(struct set_elem *)((void *)(map)->members + (id) * (set)->dsize)
 
 static int
 list_set_ktest(struct ip_set *set, const struct sk_buff *skb,
@@ -92,16 +81,16 @@ list_set_ktest(struct ip_set *set, const struct sk_buff *skb,
 	if (opt->cmdflags & IPSET_FLAG_SKIP_SUBCOUNTER_UPDATE)
 		opt->cmdflags &= ~IPSET_FLAG_SKIP_COUNTER_UPDATE;
 	for (i = 0; i < map->size; i++) {
-		e = list_set_elem(map, i);
+		e = list_set_elem(set, map, i);
 		if (e->id == IPSET_INVALID_ID)
 			return 0;
 		if (SET_WITH_TIMEOUT(set) &&
-		    ip_set_timeout_expired(ext_timeout(e, map)))
+		    ip_set_timeout_expired(ext_timeout(e, set)))
 			continue;
 		ret = ip_set_test(e->id, skb, par, opt);
 		if (ret > 0) {
 			if (SET_WITH_COUNTER(set))
-				ip_set_update_counter(ext_counter(e, map),
+				ip_set_update_counter(ext_counter(e, set),
 						      ext, &opt->ext,
 						      cmdflags);
 			return ret;
@@ -121,11 +110,11 @@ list_set_kadd(struct ip_set *set, const struct sk_buff *skb,
 	int ret;
 
 	for (i = 0; i < map->size; i++) {
-		e = list_set_elem(map, i);
+		e = list_set_elem(set, map, i);
 		if (e->id == IPSET_INVALID_ID)
 			return 0;
 		if (SET_WITH_TIMEOUT(set) &&
-		    ip_set_timeout_expired(ext_timeout(e, map)))
+		    ip_set_timeout_expired(ext_timeout(e, set)))
 			continue;
 		ret = ip_set_add(e->id, skb, par, opt);
 		if (ret == 0)
@@ -145,11 +134,11 @@ list_set_kdel(struct ip_set *set, const struct sk_buff *skb,
 	int ret;
 
 	for (i = 0; i < map->size; i++) {
-		e = list_set_elem(map, i);
+		e = list_set_elem(set, map, i);
 		if (e->id == IPSET_INVALID_ID)
 			return 0;
 		if (SET_WITH_TIMEOUT(set) &&
-		    ip_set_timeout_expired(ext_timeout(e, map)))
+		    ip_set_timeout_expired(ext_timeout(e, set)))
 			continue;
 		ret = ip_set_del(e->id, skb, par, opt);
 		if (ret == 0)
@@ -163,8 +152,7 @@ list_set_kadt(struct ip_set *set, const struct sk_buff *skb,
 	      const struct xt_action_param *par,
 	      enum ipset_adt adt, struct ip_set_adt_opt *opt)
 {
-	struct list_set *map = set->data;
-	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, map);
+	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
 	switch (adt) {
 	case IPSET_TEST:
@@ -188,10 +176,10 @@ id_eq(const struct ip_set *set, u32 i, ip_set_id_t id)
 	if (i >= map->size)
 		return 0;
 
-	e = list_set_elem(map, i);
+	e = list_set_elem(set, map, i);
 	return !!(e->id == id &&
 		 !(SET_WITH_TIMEOUT(set) &&
-		   ip_set_timeout_expired(ext_timeout(e, map))));
+		   ip_set_timeout_expired(ext_timeout(e, set))));
 }
 
 static int
@@ -199,28 +187,29 @@ list_set_add(struct ip_set *set, u32 i, struct set_adt_elem *d,
 	     const struct ip_set_ext *ext)
 {
 	struct list_set *map = set->data;
-	struct set_elem *e = list_set_elem(map, i);
+	struct set_elem *e = list_set_elem(set, map, i);
 
 	if (e->id != IPSET_INVALID_ID) {
 		if (i == map->size - 1)
 			/* Last element replaced: e.g. add new,before,last */
 			ip_set_put_byindex(e->id);
 		else {
-			struct set_elem *x = list_set_elem(map, map->size - 1);
+			struct set_elem *x = list_set_elem(set, map,
+							   map->size - 1);
 
 			/* Last element pushed off */
 			if (x->id != IPSET_INVALID_ID)
 				ip_set_put_byindex(x->id);
-			memmove(list_set_elem(map, i + 1), e,
-				map->dsize * (map->size - (i + 1)));
+			memmove(list_set_elem(set, map, i + 1), e,
+				set->dsize * (map->size - (i + 1)));
 		}
 	}
 
 	e->id = d->id;
 	if (SET_WITH_TIMEOUT(set))
-		ip_set_timeout_set(ext_timeout(e, map), ext->timeout);
+		ip_set_timeout_set(ext_timeout(e, set), ext->timeout);
 	if (SET_WITH_COUNTER(set))
-		ip_set_init_counter(ext_counter(e, map), ext);
+		ip_set_init_counter(ext_counter(e, set), ext);
 	return 0;
 }
 
@@ -228,16 +217,16 @@ static int
 list_set_del(struct ip_set *set, u32 i)
 {
 	struct list_set *map = set->data;
-	struct set_elem *e = list_set_elem(map, i);
+	struct set_elem *e = list_set_elem(set, map, i);
 
 	ip_set_put_byindex(e->id);
 
 	if (i < map->size - 1)
-		memmove(e, list_set_elem(map, i + 1),
-			map->dsize * (map->size - (i + 1)));
+		memmove(e, list_set_elem(set, map, i + 1),
+			set->dsize * (map->size - (i + 1)));
 
 	/* Last element */
-	e = list_set_elem(map, map->size - 1);
+	e = list_set_elem(set, map, map->size - 1);
 	e->id = IPSET_INVALID_ID;
 	return 0;
 }
@@ -250,9 +239,9 @@ set_cleanup_entries(struct ip_set *set)
 	u32 i;
 
 	for (i = 0; i < map->size; i++) {
-		e = list_set_elem(map, i);
+		e = list_set_elem(set, map, i);
 		if (e->id != IPSET_INVALID_ID &&
-		    ip_set_timeout_expired(ext_timeout(e, map)))
+		    ip_set_timeout_expired(ext_timeout(e, set)))
 			list_set_del(set, i);
 	}
 }
@@ -268,11 +257,11 @@ list_set_utest(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	int ret;
 
 	for (i = 0; i < map->size; i++) {
-		e = list_set_elem(map, i);
+		e = list_set_elem(set, map, i);
 		if (e->id == IPSET_INVALID_ID)
 			return 0;
 		else if (SET_WITH_TIMEOUT(set) &&
-			 ip_set_timeout_expired(ext_timeout(e, map)))
+			 ip_set_timeout_expired(ext_timeout(e, set)))
 			continue;
 		else if (e->id != d->id)
 			continue;
@@ -301,11 +290,11 @@ list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 
 	/* Check already added element */
 	for (i = 0; i < map->size; i++) {
-		e = list_set_elem(map, i);
+		e = list_set_elem(set, map, i);
 		if (e->id == IPSET_INVALID_ID)
 			goto insert;
 		else if (SET_WITH_TIMEOUT(set) &&
-			 ip_set_timeout_expired(ext_timeout(e, map)))
+			 ip_set_timeout_expired(ext_timeout(e, set)))
 			continue;
 		else if (e->id != d->id)
 			continue;
@@ -320,9 +309,9 @@ list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 			return -IPSET_ERR_EXIST;
 		/* Update extensions */
 		if (SET_WITH_TIMEOUT(set))
-			ip_set_timeout_set(ext_timeout(e, map), ext->timeout);
+			ip_set_timeout_set(ext_timeout(e, set), ext->timeout);
 		if (SET_WITH_COUNTER(set))
-			ip_set_init_counter(ext_counter(e, map), ext);
+			ip_set_init_counter(ext_counter(e, set), ext);
 		/* Set is already added to the list */
 		ip_set_put_byindex(d->id);
 		return 0;
@@ -330,7 +319,7 @@ list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 insert:
 	ret = -IPSET_ERR_LIST_FULL;
 	for (i = 0; i < map->size && ret == -IPSET_ERR_LIST_FULL; i++) {
-		e = list_set_elem(map, i);
+		e = list_set_elem(set, map, i);
 		if (e->id == IPSET_INVALID_ID)
 			ret = d->before != 0 ? -IPSET_ERR_REF_EXIST
 				: list_set_add(set, i, d, ext);
@@ -355,12 +344,12 @@ list_set_udel(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	u32 i;
 
 	for (i = 0; i < map->size; i++) {
-		e = list_set_elem(map, i);
+		e = list_set_elem(set, map, i);
 		if (e->id == IPSET_INVALID_ID)
 			return d->before != 0 ? -IPSET_ERR_REF_EXIST
 					      : -IPSET_ERR_EXIST;
 		else if (SET_WITH_TIMEOUT(set) &&
-			 ip_set_timeout_expired(ext_timeout(e, map)))
+			 ip_set_timeout_expired(ext_timeout(e, set)))
 			continue;
 		else if (e->id != d->id)
 			continue;
@@ -383,10 +372,9 @@ static int
 list_set_uadt(struct ip_set *set, struct nlattr *tb[],
 	      enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
-	struct list_set *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct set_adt_elem e = { .refid = IPSET_INVALID_ID };
-	struct ip_set_ext ext = IP_SET_INIT_UEXT(map);
+	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	struct ip_set *s;
 	int ret = 0;
 
@@ -454,7 +442,7 @@ list_set_flush(struct ip_set *set)
 	u32 i;
 
 	for (i = 0; i < map->size; i++) {
-		e = list_set_elem(map, i);
+		e = list_set_elem(set, map, i);
 		if (e->id != IPSET_INVALID_ID) {
 			ip_set_put_byindex(e->id);
 			e->id = IPSET_INVALID_ID;
@@ -486,13 +474,13 @@ list_set_head(struct ip_set *set, struct sk_buff *skb)
 		goto nla_put_failure;
 	if (nla_put_net32(skb, IPSET_ATTR_SIZE, htonl(map->size)) ||
 	    (SET_WITH_TIMEOUT(set) &&
-	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout))) ||
+	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(set->timeout))) ||
 	    (SET_WITH_COUNTER(set) &&
 	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS,
 			   htonl(IPSET_FLAG_WITH_COUNTERS))) ||
 	    nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
 	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE,
-			  htonl(sizeof(*map) + map->size * map->dsize)))
+			  htonl(sizeof(*map) + map->size * set->dsize)))
 		goto nla_put_failure;
 	ipset_nest_end(skb, nested);
 
@@ -515,11 +503,11 @@ list_set_list(const struct ip_set *set,
 		return -EMSGSIZE;
 	for (; cb->args[2] < map->size; cb->args[2]++) {
 		i = cb->args[2];
-		e = list_set_elem(map, i);
+		e = list_set_elem(set, map, i);
 		if (e->id == IPSET_INVALID_ID)
 			goto finish;
 		if (SET_WITH_TIMEOUT(set) &&
-		    ip_set_timeout_expired(ext_timeout(e, map)))
+		    ip_set_timeout_expired(ext_timeout(e, set)))
 			continue;
 		nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
 		if (!nested) {
@@ -535,10 +523,10 @@ list_set_list(const struct ip_set *set,
 		if (SET_WITH_TIMEOUT(set) &&
 		    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
 				  htonl(ip_set_timeout_get(
-						ext_timeout(e, map)))))
+						ext_timeout(e, set)))))
 			goto nla_put_failure;
 		if (SET_WITH_COUNTER(set) &&
-		    ip_set_put_counter(skb, ext_counter(e, map)))
+		    ip_set_put_counter(skb, ext_counter(e, set)))
 			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
@@ -565,7 +553,7 @@ list_set_same_set(const struct ip_set *a, const struct ip_set *b)
 	const struct list_set *y = b->data;
 
 	return x->size == y->size &&
-	       x->timeout == y->timeout &&
+	       a->timeout == b->timeout &&
 	       a->extensions == b->extensions;
 }
 
@@ -594,7 +582,7 @@ list_set_gc(unsigned long ul_set)
 	set_cleanup_entries(set);
 	write_unlock_bh(&set->lock);
 
-	map->gc.expires = jiffies + IPSET_GC_PERIOD(map->timeout) * HZ;
+	map->gc.expires = jiffies + IPSET_GC_PERIOD(set->timeout) * HZ;
 	add_timer(&map->gc);
 }
 
@@ -606,7 +594,7 @@ list_set_gc_init(struct ip_set *set, void (*gc)(unsigned long ul_set))
 	init_timer(&map->gc);
 	map->gc.data = (unsigned long) set;
 	map->gc.function = gc;
-	map->gc.expires = jiffies + IPSET_GC_PERIOD(map->timeout) * HZ;
+	map->gc.expires = jiffies + IPSET_GC_PERIOD(set->timeout) * HZ;
 	add_timer(&map->gc);
 }
 
@@ -625,12 +613,12 @@ init_list_set(struct ip_set *set, u32 size, size_t dsize,
 		return NULL;
 
 	map->size = size;
-	map->dsize = dsize;
-	map->timeout = timeout;
+	set->dsize = dsize;
+	set->timeout = timeout;
 	set->data = map;
 
 	for (i = 0; i < size; i++) {
-		e = list_set_elem(map, i);
+		e = list_set_elem(set, map, i);
 		e->id = IPSET_INVALID_ID;
 	}
 
@@ -667,9 +655,9 @@ list_set_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 			if (!map)
 				return -ENOMEM;
 			set->extensions |= IPSET_EXT_TIMEOUT;
-			map->offset[IPSET_EXT_ID_TIMEOUT] =
+			set->offset[IPSET_EXT_ID_TIMEOUT] =
 				offsetof(struct setct_elem, timeout);
-			map->offset[IPSET_EXT_ID_COUNTER] =
+			set->offset[IPSET_EXT_ID_COUNTER] =
 				offsetof(struct setct_elem, counter);
 			list_set_gc_init(set, list_set_gc);
 		} else {
@@ -677,7 +665,7 @@ list_set_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 					    sizeof(struct setc_elem), 0);
 			if (!map)
 				return -ENOMEM;
-			map->offset[IPSET_EXT_ID_COUNTER] =
+			set->offset[IPSET_EXT_ID_COUNTER] =
 				offsetof(struct setc_elem, counter);
 		}
 	} else if (tb[IPSET_ATTR_TIMEOUT]) {
@@ -686,7 +674,7 @@ list_set_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 		if (!map)
 			return -ENOMEM;
 		set->extensions |= IPSET_EXT_TIMEOUT;
-		map->offset[IPSET_EXT_ID_TIMEOUT] =
+		set->offset[IPSET_EXT_ID_TIMEOUT] =
 			offsetof(struct sett_elem, timeout);
 		list_set_gc_init(set, list_set_gc);
 	} else {
-- 
1.7.10.4
