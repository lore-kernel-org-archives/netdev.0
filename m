From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/33] netfilter: ipset: Generalize extensions support
Date: Fri,  4 Oct 2013 10:33:01 +0200
Message-ID: <1380875598-5250-17-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56001 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753822Ab3JDIfG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Oct 2013 04:35:06 -0400
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Get rid of the structure based extensions and introduce a blob for
the extensions. Thus we can support more extension types easily.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h      |   13 ++++
 net/netfilter/ipset/ip_set_bitmap_ip.c      |   81 +++---------------------
 net/netfilter/ipset/ip_set_bitmap_ipmac.c   |   91 +++------------------------
 net/netfilter/ipset/ip_set_bitmap_port.c    |   71 ++-------------------
 net/netfilter/ipset/ip_set_core.c           |   46 ++++++++++++++
 net/netfilter/ipset/ip_set_hash_gen.h       |   86 +++----------------------
 net/netfilter/ipset/ip_set_hash_ip.c        |   36 +----------
 net/netfilter/ipset/ip_set_hash_ipport.c    |   54 +---------------
 net/netfilter/ipset/ip_set_hash_ipportip.c  |   60 +-----------------
 net/netfilter/ipset/ip_set_hash_ipportnet.c |   66 +------------------
 net/netfilter/ipset/ip_set_hash_net.c       |   54 +---------------
 net/netfilter/ipset/ip_set_hash_netiface.c  |   68 +-------------------
 net/netfilter/ipset/ip_set_hash_netport.c   |   60 +-----------------
 net/netfilter/ipset/ip_set_list_set.c       |   81 ++++--------------------
 14 files changed, 118 insertions(+), 749 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 992a2f5..66d6bd4 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -66,6 +66,17 @@ enum ip_set_ext_id {
 	IPSET_EXT_ID_MAX,
 };
 
+/* Extension type */
+struct ip_set_ext_type {
+	enum ip_set_extension type;
+	enum ipset_cadt_flags flag;
+	/* Size and minimal alignment */
+	u8 len;
+	u8 align;
+};
+
+extern const struct ip_set_ext_type ip_set_extensions[];
+
 struct ip_set_ext {
 	u64 packets;
 	u64 bytes;
@@ -283,6 +294,8 @@ extern void *ip_set_alloc(size_t size);
 extern void ip_set_free(void *members);
 extern int ip_set_get_ipaddr4(struct nlattr *nla,  __be32 *ipaddr);
 extern int ip_set_get_ipaddr6(struct nlattr *nla, union nf_inet_addr *ipaddr);
+extern size_t ip_set_elem_len(struct ip_set *set, struct nlattr *tb[],
+			      size_t len);
 extern int ip_set_get_extensions(struct ip_set *set, struct nlattr *tb[],
 				 struct ip_set_ext *ext);
 
diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index 363022e..94d9854 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -208,25 +208,6 @@ bitmap_ip_same_set(const struct ip_set *a, const struct ip_set *b)
 struct bitmap_ip_elem {
 };
 
-/* Timeout variant */
-
-struct bitmap_ipt_elem {
-	unsigned long timeout;
-};
-
-/* Plain variant with counter */
-
-struct bitmap_ipc_elem {
-	struct ip_set_counter counter;
-};
-
-/* Timeout variant with counter */
-
-struct bitmap_ipct_elem {
-	unsigned long timeout;
-	struct ip_set_counter counter;
-};
-
 #include "ip_set_bitmap_gen.h"
 
 /* Create bitmap:ip type of sets */
@@ -263,7 +244,7 @@ static int
 bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 {
 	struct bitmap_ip *map;
-	u32 first_ip = 0, last_ip = 0, hosts, cadt_flags = 0;
+	u32 first_ip = 0, last_ip = 0, hosts;
 	u64 elements;
 	u8 netmask = 32;
 	int ret;
@@ -335,61 +316,15 @@ bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 
 	map->memsize = bitmap_bytes(0, elements - 1);
 	set->variant = &bitmap_ip;
-	if (tb[IPSET_ATTR_CADT_FLAGS])
-		cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
-	if (cadt_flags & IPSET_FLAG_WITH_COUNTERS) {
-		set->extensions |= IPSET_EXT_COUNTER;
-		if (tb[IPSET_ATTR_TIMEOUT]) {
-			set->dsize = sizeof(struct bitmap_ipct_elem);
-			set->offset[IPSET_EXT_ID_TIMEOUT] =
-				offsetof(struct bitmap_ipct_elem, timeout);
-			set->offset[IPSET_EXT_ID_COUNTER] =
-				offsetof(struct bitmap_ipct_elem, counter);
-
-			if (!init_map_ip(set, map, first_ip, last_ip,
-					 elements, hosts, netmask)) {
-				kfree(map);
-				return -ENOMEM;
-			}
-
-			set->timeout = ip_set_timeout_uget(
-				tb[IPSET_ATTR_TIMEOUT]);
-			set->extensions |= IPSET_EXT_TIMEOUT;
-
-			bitmap_ip_gc_init(set, bitmap_ip_gc);
-		} else {
-			set->dsize = sizeof(struct bitmap_ipc_elem);
-			set->offset[IPSET_EXT_ID_COUNTER] =
-				offsetof(struct bitmap_ipc_elem, counter);
-
-			if (!init_map_ip(set, map, first_ip, last_ip,
-					 elements, hosts, netmask)) {
-				kfree(map);
-				return -ENOMEM;
-			}
-		}
-	} else if (tb[IPSET_ATTR_TIMEOUT]) {
-		set->dsize = sizeof(struct bitmap_ipt_elem);
-		set->offset[IPSET_EXT_ID_TIMEOUT] =
-			offsetof(struct bitmap_ipt_elem, timeout);
-
-		if (!init_map_ip(set, map, first_ip, last_ip,
-				 elements, hosts, netmask)) {
-			kfree(map);
-			return -ENOMEM;
-		}
-
+	set->dsize = ip_set_elem_len(set, tb, 0);
+	if (!init_map_ip(set, map, first_ip, last_ip,
+			 elements, hosts, netmask)) {
+		kfree(map);
+		return -ENOMEM;
+	}
+	if (tb[IPSET_ATTR_TIMEOUT]) {
 		set->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-		set->extensions |= IPSET_EXT_TIMEOUT;
-
 		bitmap_ip_gc_init(set, bitmap_ip_gc);
-	} else {
-		set->dsize = 0;
-		if (!init_map_ip(set, map, first_ip, last_ip,
-				 elements, hosts, netmask)) {
-			kfree(map);
-			return -ENOMEM;
-		}
 	}
 	return 0;
 }
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 74576cb..654a97b 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -289,37 +289,6 @@ bitmap_ipmac_same_set(const struct ip_set *a, const struct ip_set *b)
 
 /* Plain variant */
 
-/* Timeout variant */
-
-struct bitmap_ipmact_elem {
-	struct {
-		unsigned char ether[ETH_ALEN];
-		unsigned char filled;
-	} __attribute__ ((aligned));
-	unsigned long timeout;
-};
-
-/* Plain variant with counter */
-
-struct bitmap_ipmacc_elem {
-	struct {
-		unsigned char ether[ETH_ALEN];
-		unsigned char filled;
-	} __attribute__ ((aligned));
-	struct ip_set_counter counter;
-};
-
-/* Timeout variant with counter */
-
-struct bitmap_ipmacct_elem {
-	struct {
-		unsigned char ether[ETH_ALEN];
-		unsigned char filled;
-	} __attribute__ ((aligned));
-	unsigned long timeout;
-	struct ip_set_counter counter;
-};
-
 #include "ip_set_bitmap_gen.h"
 
 /* Create bitmap:ip,mac type of sets */
@@ -328,7 +297,7 @@ static bool
 init_map_ipmac(struct ip_set *set, struct bitmap_ipmac *map,
 	       u32 first_ip, u32 last_ip, u32 elements)
 {
-	map->members = ip_set_alloc((last_ip - first_ip + 1) * set->dsize);
+	map->members = ip_set_alloc(map->memsize);
 	if (!map->members)
 		return false;
 	if (set->dsize) {
@@ -353,7 +322,7 @@ static int
 bitmap_ipmac_create(struct ip_set *set, struct nlattr *tb[],
 		    u32 flags)
 {
-	u32 first_ip = 0, last_ip = 0, cadt_flags = 0;
+	u32 first_ip = 0, last_ip = 0;
 	u64 elements;
 	struct bitmap_ipmac *map;
 	int ret;
@@ -397,57 +366,15 @@ bitmap_ipmac_create(struct ip_set *set, struct nlattr *tb[],
 
 	map->memsize = bitmap_bytes(0, elements - 1);
 	set->variant = &bitmap_ipmac;
-	if (tb[IPSET_ATTR_CADT_FLAGS])
-		cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
-	if (cadt_flags & IPSET_FLAG_WITH_COUNTERS) {
-		set->extensions |= IPSET_EXT_COUNTER;
-		if (tb[IPSET_ATTR_TIMEOUT]) {
-			set->dsize = sizeof(struct bitmap_ipmacct_elem);
-			set->offset[IPSET_EXT_ID_TIMEOUT] =
-				offsetof(struct bitmap_ipmacct_elem, timeout);
-			set->offset[IPSET_EXT_ID_COUNTER] =
-				offsetof(struct bitmap_ipmacct_elem, counter);
-
-			if (!init_map_ipmac(set, map, first_ip, last_ip,
-					    elements)) {
-				kfree(map);
-				return -ENOMEM;
-			}
-			set->timeout = ip_set_timeout_uget(
-				tb[IPSET_ATTR_TIMEOUT]);
-			set->extensions |= IPSET_EXT_TIMEOUT;
-			bitmap_ipmac_gc_init(set, bitmap_ipmac_gc);
-		} else {
-			set->dsize = sizeof(struct bitmap_ipmacc_elem);
-			set->offset[IPSET_EXT_ID_COUNTER] =
-				offsetof(struct bitmap_ipmacc_elem, counter);
-
-			if (!init_map_ipmac(set, map, first_ip, last_ip,
-					    elements)) {
-				kfree(map);
-				return -ENOMEM;
-			}
-		}
-	} else if (tb[IPSET_ATTR_TIMEOUT]) {
-		set->dsize = sizeof(struct bitmap_ipmact_elem);
-		set->offset[IPSET_EXT_ID_TIMEOUT] =
-			offsetof(struct bitmap_ipmact_elem, timeout);
-
-		if (!init_map_ipmac(set, map, first_ip, last_ip, elements)) {
-			kfree(map);
-			return -ENOMEM;
-		}
+	set->dsize = ip_set_elem_len(set, tb,
+				     sizeof(struct bitmap_ipmac_elem));
+	if (!init_map_ipmac(set, map, first_ip, last_ip, elements)) {
+		kfree(map);
+		return -ENOMEM;
+	}
+	if (tb[IPSET_ATTR_TIMEOUT]) {
 		set->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-		set->extensions |= IPSET_EXT_TIMEOUT;
 		bitmap_ipmac_gc_init(set, bitmap_ipmac_gc);
-	} else {
-		set->dsize = sizeof(struct bitmap_ipmac_elem);
-
-		if (!init_map_ipmac(set, map, first_ip, last_ip, elements)) {
-			kfree(map);
-			return -ENOMEM;
-		}
-		set->variant = &bitmap_ipmac;
 	}
 	return 0;
 }
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index 71da319..1ef2f31 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -198,25 +198,6 @@ bitmap_port_same_set(const struct ip_set *a, const struct ip_set *b)
 struct bitmap_port_elem {
 };
 
-/* Timeout variant */
-
-struct bitmap_portt_elem {
-	unsigned long timeout;
-};
-
-/* Plain variant with counter */
-
-struct bitmap_portc_elem {
-	struct ip_set_counter counter;
-};
-
-/* Timeout variant with counter */
-
-struct bitmap_portct_elem {
-	unsigned long timeout;
-	struct ip_set_counter counter;
-};
-
 #include "ip_set_bitmap_gen.h"
 
 /* Create bitmap:ip type of sets */
@@ -250,7 +231,6 @@ bitmap_port_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 {
 	struct bitmap_port *map;
 	u16 first_port, last_port;
-	u32 cadt_flags = 0;
 
 	if (unlikely(!ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT_TO) ||
@@ -274,53 +254,14 @@ bitmap_port_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	map->elements = last_port - first_port + 1;
 	map->memsize = map->elements * sizeof(unsigned long);
 	set->variant = &bitmap_port;
-	if (tb[IPSET_ATTR_CADT_FLAGS])
-		cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
-	if (cadt_flags & IPSET_FLAG_WITH_COUNTERS) {
-		set->extensions |= IPSET_EXT_COUNTER;
-		if (tb[IPSET_ATTR_TIMEOUT]) {
-			set->dsize = sizeof(struct bitmap_portct_elem);
-			set->offset[IPSET_EXT_ID_TIMEOUT] =
-				offsetof(struct bitmap_portct_elem, timeout);
-			set->offset[IPSET_EXT_ID_COUNTER] =
-				offsetof(struct bitmap_portct_elem, counter);
-			if (!init_map_port(set, map, first_port, last_port)) {
-				kfree(map);
-				return -ENOMEM;
-			}
-
-			set->timeout =
-				ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-			set->extensions |= IPSET_EXT_TIMEOUT;
-			bitmap_port_gc_init(set, bitmap_port_gc);
-		} else {
-			set->dsize = sizeof(struct bitmap_portc_elem);
-			set->offset[IPSET_EXT_ID_COUNTER] =
-				offsetof(struct bitmap_portc_elem, counter);
-			if (!init_map_port(set, map, first_port, last_port)) {
-				kfree(map);
-				return -ENOMEM;
-			}
-		}
-	} else if (tb[IPSET_ATTR_TIMEOUT]) {
-		set->dsize = sizeof(struct bitmap_portt_elem);
-		set->offset[IPSET_EXT_ID_TIMEOUT] =
-			offsetof(struct bitmap_portt_elem, timeout);
-		if (!init_map_port(set, map, first_port, last_port)) {
-			kfree(map);
-			return -ENOMEM;
-		}
-
+	set->dsize = ip_set_elem_len(set, tb, 0);
+	if (!init_map_port(set, map, first_port, last_port)) {
+		kfree(map);
+		return -ENOMEM;
+	}
+	if (tb[IPSET_ATTR_TIMEOUT]) {
 		set->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-		set->extensions |= IPSET_EXT_TIMEOUT;
 		bitmap_port_gc_init(set, bitmap_port_gc);
-	} else {
-		set->dsize = 0;
-		if (!init_map_port(set, map, first_port, last_port)) {
-			kfree(map);
-			return -ENOMEM;
-		}
-
 	}
 	return 0;
 }
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 428c30a..f35afed 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -315,6 +315,52 @@ ip_set_get_ipaddr6(struct nlattr *nla, union nf_inet_addr *ipaddr)
 }
 EXPORT_SYMBOL_GPL(ip_set_get_ipaddr6);
 
+/* ipset data extension types, in size order */
+
+const struct ip_set_ext_type ip_set_extensions[] = {
+	[IPSET_EXT_ID_COUNTER] = {
+		.type	= IPSET_EXT_COUNTER,
+		.flag	= IPSET_FLAG_WITH_COUNTERS,
+		.len	= sizeof(struct ip_set_counter),
+		.align	= __alignof__(struct ip_set_counter),
+	},
+	[IPSET_EXT_ID_TIMEOUT] = {
+		.type	= IPSET_EXT_TIMEOUT,
+		.len	= sizeof(unsigned long),
+		.align	= __alignof__(unsigned long),
+	},
+};
+EXPORT_SYMBOL_GPL(ip_set_extensions);
+
+static inline bool
+add_extension(enum ip_set_ext_id id, u32 flags, struct nlattr *tb[])
+{
+	return ip_set_extensions[id].flag ?
+		(flags & ip_set_extensions[id].flag) :
+		!!tb[IPSET_ATTR_TIMEOUT];
+}
+
+size_t
+ip_set_elem_len(struct ip_set *set, struct nlattr *tb[], size_t len)
+{
+	enum ip_set_ext_id id;
+	size_t offset = 0;
+	u32 cadt_flags = 0;
+
+	if (tb[IPSET_ATTR_CADT_FLAGS])
+		cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
+	for (id = 0; id < IPSET_EXT_ID_MAX; id++) {
+		if (!add_extension(id, cadt_flags, tb))
+			continue;
+		offset += ALIGN(len + offset, ip_set_extensions[id].align);
+		set->offset[id] = offset;
+		set->extensions |= ip_set_extensions[id].type;
+		offset += ip_set_extensions[id].len;
+	}
+	return len + offset;
+}
+EXPORT_SYMBOL_GPL(ip_set_elem_len);
+
 int
 ip_set_get_extensions(struct ip_set *set, struct nlattr *tb[],
 		      struct ip_set_ext *ext)
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 0cb840e..3999f17 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -960,7 +960,6 @@ static int
 IPSET_TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
 {
 	u32 hashsize = IPSET_DEFAULT_HASHSIZE, maxelem = IPSET_DEFAULT_MAXELEM;
-	u32 cadt_flags = 0;
 	u8 hbits;
 #ifdef IP_SET_HASH_WITH_NETMASK
 	u8 netmask;
@@ -1034,88 +1033,23 @@ IPSET_TOKEN(HTYPE, _create)(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	rcu_assign_pointer(h->table, t);
 
 	set->data = h;
-	if (set->family ==  NFPROTO_IPV4)
+	if (set->family ==  NFPROTO_IPV4) {
 		set->variant = &IPSET_TOKEN(HTYPE, 4_variant);
-	else
+		set->dsize = ip_set_elem_len(set, tb,
+				sizeof(struct IPSET_TOKEN(HTYPE, 4_elem)));
+	} else {
 		set->variant = &IPSET_TOKEN(HTYPE, 6_variant);
-
-	if (tb[IPSET_ATTR_CADT_FLAGS])
-		cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
-	if (cadt_flags & IPSET_FLAG_WITH_COUNTERS) {
-		set->extensions |= IPSET_EXT_COUNTER;
-		if (tb[IPSET_ATTR_TIMEOUT]) {
-			set->timeout =
-				ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-			set->extensions |= IPSET_EXT_TIMEOUT;
-			if (set->family == NFPROTO_IPV4) {
-				set->dsize = sizeof(struct
-					IPSET_TOKEN(HTYPE, 4ct_elem));
-				set->offset[IPSET_EXT_ID_TIMEOUT] =
-					offsetof(struct
-						IPSET_TOKEN(HTYPE, 4ct_elem),
-						timeout);
-				set->offset[IPSET_EXT_ID_COUNTER] =
-					offsetof(struct
-						IPSET_TOKEN(HTYPE, 4ct_elem),
-						counter);
-				IPSET_TOKEN(HTYPE, 4_gc_init)(set,
-					IPSET_TOKEN(HTYPE, 4_gc));
-			} else {
-				set->dsize = sizeof(struct
-					IPSET_TOKEN(HTYPE, 6ct_elem));
-				set->offset[IPSET_EXT_ID_TIMEOUT] =
-					offsetof(struct
-						IPSET_TOKEN(HTYPE, 6ct_elem),
-						timeout);
-				set->offset[IPSET_EXT_ID_COUNTER] =
-					offsetof(struct
-						IPSET_TOKEN(HTYPE, 6ct_elem),
-						counter);
-				IPSET_TOKEN(HTYPE, 6_gc_init)(set,
-					IPSET_TOKEN(HTYPE, 6_gc));
-			}
-		} else {
-			if (set->family == NFPROTO_IPV4) {
-				set->dsize =
-					sizeof(struct
-						IPSET_TOKEN(HTYPE, 4c_elem));
-				set->offset[IPSET_EXT_ID_COUNTER] =
-					offsetof(struct
-						IPSET_TOKEN(HTYPE, 4c_elem),
-						counter);
-			} else {
-				set->dsize =
-					sizeof(struct
-						IPSET_TOKEN(HTYPE, 6c_elem));
-				set->offset[IPSET_EXT_ID_COUNTER] =
-					offsetof(struct
-						IPSET_TOKEN(HTYPE, 6c_elem),
-						counter);
-			}
-		}
-	} else if (tb[IPSET_ATTR_TIMEOUT]) {
+		set->dsize = ip_set_elem_len(set, tb,
+				sizeof(struct IPSET_TOKEN(HTYPE, 6_elem)));
+	}
+	if (tb[IPSET_ATTR_TIMEOUT]) {
 		set->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
-		set->extensions |= IPSET_EXT_TIMEOUT;
-		if (set->family == NFPROTO_IPV4) {
-			set->dsize = sizeof(struct IPSET_TOKEN(HTYPE, 4t_elem));
-			set->offset[IPSET_EXT_ID_TIMEOUT] =
-				offsetof(struct IPSET_TOKEN(HTYPE, 4t_elem),
-					 timeout);
+		if (set->family == NFPROTO_IPV4)
 			IPSET_TOKEN(HTYPE, 4_gc_init)(set,
 				IPSET_TOKEN(HTYPE, 4_gc));
-		} else {
-			set->dsize = sizeof(struct IPSET_TOKEN(HTYPE, 6t_elem));
-			set->offset[IPSET_EXT_ID_TIMEOUT] =
-				offsetof(struct IPSET_TOKEN(HTYPE, 6t_elem),
-					 timeout);
+		else
 			IPSET_TOKEN(HTYPE, 6_gc_init)(set,
 				IPSET_TOKEN(HTYPE, 6_gc));
-		}
-	} else {
-		if (set->family == NFPROTO_IPV4)
-			set->dsize = sizeof(struct IPSET_TOKEN(HTYPE, 4_elem));
-		else
-			set->dsize = sizeof(struct IPSET_TOKEN(HTYPE, 6_elem));
 	}
 
 	pr_debug("create %s hashsize %u (%u) maxelem %u: %p(%p)\n",
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index bbde7c3..a111ffe 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -35,7 +35,7 @@ MODULE_ALIAS("ip_set_hash:ip");
 #define HTYPE		hash_ip
 #define IP_SET_HASH_WITH_NETMASK
 
-/* IPv4 variants */
+/* IPv4 variant */
 
 /* Member elements */
 struct hash_ip4_elem {
@@ -43,22 +43,6 @@ struct hash_ip4_elem {
 	__be32 ip;
 };
 
-struct hash_ip4t_elem {
-	__be32 ip;
-	unsigned long timeout;
-};
-
-struct hash_ip4c_elem {
-	__be32 ip;
-	struct ip_set_counter counter;
-};
-
-struct hash_ip4ct_elem {
-	__be32 ip;
-	struct ip_set_counter counter;
-	unsigned long timeout;
-};
-
 /* Common functions */
 
 static inline bool
@@ -178,29 +162,13 @@ hash_ip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-/* IPv6 variants */
+/* IPv6 variant */
 
 /* Member elements */
 struct hash_ip6_elem {
 	union nf_inet_addr ip;
 };
 
-struct hash_ip6t_elem {
-	union nf_inet_addr ip;
-	unsigned long timeout;
-};
-
-struct hash_ip6c_elem {
-	union nf_inet_addr ip;
-	struct ip_set_counter counter;
-};
-
-struct hash_ip6ct_elem {
-	union nf_inet_addr ip;
-	struct ip_set_counter counter;
-	unsigned long timeout;
-};
-
 /* Common functions */
 
 static inline bool
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index dd175d6..5dc735c 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -36,7 +36,7 @@ MODULE_ALIAS("ip_set_hash:ip,port");
 /* Type specific function prefix */
 #define HTYPE		hash_ipport
 
-/* IPv4 variants */
+/* IPv4 variant */
 
 /* Member elements */
 struct hash_ipport4_elem {
@@ -46,31 +46,6 @@ struct hash_ipport4_elem {
 	u8 padding;
 };
 
-struct hash_ipport4t_elem {
-	__be32 ip;
-	__be16 port;
-	u8 proto;
-	u8 padding;
-	unsigned long timeout;
-};
-
-struct hash_ipport4c_elem {
-	__be32 ip;
-	__be16 port;
-	u8 proto;
-	u8 padding;
-	struct ip_set_counter counter;
-};
-
-struct hash_ipport4ct_elem {
-	__be32 ip;
-	__be16 port;
-	u8 proto;
-	u8 padding;
-	struct ip_set_counter counter;
-	unsigned long timeout;
-};
-
 /* Common functions */
 
 static inline bool
@@ -221,7 +196,7 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-/* IPv6 variants */
+/* IPv6 variant */
 
 struct hash_ipport6_elem {
 	union nf_inet_addr ip;
@@ -230,31 +205,6 @@ struct hash_ipport6_elem {
 	u8 padding;
 };
 
-struct hash_ipport6t_elem {
-	union nf_inet_addr ip;
-	__be16 port;
-	u8 proto;
-	u8 padding;
-	unsigned long timeout;
-};
-
-struct hash_ipport6c_elem {
-	union nf_inet_addr ip;
-	__be16 port;
-	u8 proto;
-	u8 padding;
-	struct ip_set_counter counter;
-};
-
-struct hash_ipport6ct_elem {
-	union nf_inet_addr ip;
-	__be16 port;
-	u8 proto;
-	u8 padding;
-	struct ip_set_counter counter;
-	unsigned long timeout;
-};
-
 /* Common functions */
 
 static inline bool
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 87a2cfa..8c43dc7 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -36,7 +36,7 @@ MODULE_ALIAS("ip_set_hash:ip,port,ip");
 /* Type specific function prefix */
 #define HTYPE		hash_ipportip
 
-/* IPv4 variants */
+/* IPv4 variant */
 
 /* Member elements  */
 struct hash_ipportip4_elem {
@@ -47,34 +47,6 @@ struct hash_ipportip4_elem {
 	u8 padding;
 };
 
-struct hash_ipportip4t_elem {
-	__be32 ip;
-	__be32 ip2;
-	__be16 port;
-	u8 proto;
-	u8 padding;
-	unsigned long timeout;
-};
-
-struct hash_ipportip4c_elem {
-	__be32 ip;
-	__be32 ip2;
-	__be16 port;
-	u8 proto;
-	u8 padding;
-	struct ip_set_counter counter;
-};
-
-struct hash_ipportip4ct_elem {
-	__be32 ip;
-	__be32 ip2;
-	__be16 port;
-	u8 proto;
-	u8 padding;
-	struct ip_set_counter counter;
-	unsigned long timeout;
-};
-
 static inline bool
 hash_ipportip4_data_equal(const struct hash_ipportip4_elem *ip1,
 			  const struct hash_ipportip4_elem *ip2,
@@ -230,7 +202,7 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-/* IPv6 variants */
+/* IPv6 variant */
 
 struct hash_ipportip6_elem {
 	union nf_inet_addr ip;
@@ -240,34 +212,6 @@ struct hash_ipportip6_elem {
 	u8 padding;
 };
 
-struct hash_ipportip6t_elem {
-	union nf_inet_addr ip;
-	union nf_inet_addr ip2;
-	__be16 port;
-	u8 proto;
-	u8 padding;
-	unsigned long timeout;
-};
-
-struct hash_ipportip6c_elem {
-	union nf_inet_addr ip;
-	union nf_inet_addr ip2;
-	__be16 port;
-	u8 proto;
-	u8 padding;
-	struct ip_set_counter counter;
-};
-
-struct hash_ipportip6ct_elem {
-	union nf_inet_addr ip;
-	union nf_inet_addr ip2;
-	__be16 port;
-	u8 proto;
-	u8 padding;
-	struct ip_set_counter counter;
-	unsigned long timeout;
-};
-
 /* Common functions */
 
 static inline bool
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 0b9a28d..3489045 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -46,7 +46,7 @@ MODULE_ALIAS("ip_set_hash:ip,port,net");
 #define IP_SET_HASH_WITH_PROTO
 #define IP_SET_HASH_WITH_NETS
 
-/* IPv4 variants */
+/* IPv4 variant */
 
 /* Member elements */
 struct hash_ipportnet4_elem {
@@ -58,37 +58,6 @@ struct hash_ipportnet4_elem {
 	u8 proto;
 };
 
-struct hash_ipportnet4t_elem {
-	__be32 ip;
-	__be32 ip2;
-	__be16 port;
-	u8 cidr:7;
-	u8 nomatch:1;
-	u8 proto;
-	unsigned long timeout;
-};
-
-struct hash_ipportnet4c_elem {
-	__be32 ip;
-	__be32 ip2;
-	__be16 port;
-	u8 cidr:7;
-	u8 nomatch:1;
-	u8 proto;
-	struct ip_set_counter counter;
-};
-
-struct hash_ipportnet4ct_elem {
-	__be32 ip;
-	__be32 ip2;
-	__be16 port;
-	u8 cidr:7;
-	u8 nomatch:1;
-	u8 proto;
-	struct ip_set_counter counter;
-	unsigned long timeout;
-};
-
 /* Common functions */
 
 static inline bool
@@ -328,7 +297,7 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-/* IPv6 variants */
+/* IPv6 variant */
 
 struct hash_ipportnet6_elem {
 	union nf_inet_addr ip;
@@ -339,37 +308,6 @@ struct hash_ipportnet6_elem {
 	u8 proto;
 };
 
-struct hash_ipportnet6t_elem {
-	union nf_inet_addr ip;
-	union nf_inet_addr ip2;
-	__be16 port;
-	u8 cidr:7;
-	u8 nomatch:1;
-	u8 proto;
-	unsigned long timeout;
-};
-
-struct hash_ipportnet6c_elem {
-	union nf_inet_addr ip;
-	union nf_inet_addr ip2;
-	__be16 port;
-	u8 cidr:7;
-	u8 nomatch:1;
-	u8 proto;
-	struct ip_set_counter counter;
-};
-
-struct hash_ipportnet6ct_elem {
-	union nf_inet_addr ip;
-	union nf_inet_addr ip2;
-	__be16 port;
-	u8 cidr:7;
-	u8 nomatch:1;
-	u8 proto;
-	struct ip_set_counter counter;
-	unsigned long timeout;
-};
-
 /* Common functions */
 
 static inline bool
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 1d4caa5..d559855 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -36,7 +36,7 @@ MODULE_ALIAS("ip_set_hash:net");
 #define HTYPE		hash_net
 #define IP_SET_HASH_WITH_NETS
 
-/* IPv4 variants */
+/* IPv4 variant */
 
 /* Member elements  */
 struct hash_net4_elem {
@@ -46,31 +46,6 @@ struct hash_net4_elem {
 	u8 cidr;
 };
 
-struct hash_net4t_elem {
-	__be32 ip;
-	u16 padding0;
-	u8 nomatch;
-	u8 cidr;
-	unsigned long timeout;
-};
-
-struct hash_net4c_elem {
-	__be32 ip;
-	u16 padding0;
-	u8 nomatch;
-	u8 cidr;
-	struct ip_set_counter counter;
-};
-
-struct hash_net4ct_elem {
-	__be32 ip;
-	u16 padding0;
-	u8 nomatch;
-	u8 cidr;
-	struct ip_set_counter counter;
-	unsigned long timeout;
-};
-
 /* Common functions */
 
 static inline bool
@@ -228,7 +203,7 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-/* IPv6 variants */
+/* IPv6 variant */
 
 struct hash_net6_elem {
 	union nf_inet_addr ip;
@@ -237,31 +212,6 @@ struct hash_net6_elem {
 	u8 cidr;
 };
 
-struct hash_net6t_elem {
-	union nf_inet_addr ip;
-	u16 padding0;
-	u8 nomatch;
-	u8 cidr;
-	unsigned long timeout;
-};
-
-struct hash_net6c_elem {
-	union nf_inet_addr ip;
-	u16 padding0;
-	u8 nomatch;
-	u8 cidr;
-	struct ip_set_counter counter;
-};
-
-struct hash_net6ct_elem {
-	union nf_inet_addr ip;
-	u16 padding0;
-	u8 nomatch;
-	u8 cidr;
-	struct ip_set_counter counter;
-	unsigned long timeout;
-};
-
 /* Common functions */
 
 static inline bool
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 2f0ffe3..26703e9 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -134,7 +134,7 @@ iface_add(struct rb_root *root, const char **iface)
 
 #define STREQ(a, b)	(strcmp(a, b) == 0)
 
-/* IPv4 variants */
+/* IPv4 variant */
 
 struct hash_netiface4_elem_hashed {
 	__be32 ip;
@@ -144,7 +144,7 @@ struct hash_netiface4_elem_hashed {
 	u8 elem;
 };
 
-/* Member elements without timeout */
+/* Member elements */
 struct hash_netiface4_elem {
 	__be32 ip;
 	u8 physdev;
@@ -154,37 +154,6 @@ struct hash_netiface4_elem {
 	const char *iface;
 };
 
-struct hash_netiface4t_elem {
-	__be32 ip;
-	u8 physdev;
-	u8 cidr;
-	u8 nomatch;
-	u8 elem;
-	const char *iface;
-	unsigned long timeout;
-};
-
-struct hash_netiface4c_elem {
-	__be32 ip;
-	u8 physdev;
-	u8 cidr;
-	u8 nomatch;
-	u8 elem;
-	const char *iface;
-	struct ip_set_counter counter;
-};
-
-struct hash_netiface4ct_elem {
-	__be32 ip;
-	u8 physdev;
-	u8 cidr;
-	u8 nomatch;
-	u8 elem;
-	const char *iface;
-	struct ip_set_counter counter;
-	unsigned long timeout;
-};
-
 /* Common functions */
 
 static inline bool
@@ -399,7 +368,7 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-/* IPv6 variants */
+/* IPv6 variant */
 
 struct hash_netiface6_elem_hashed {
 	union nf_inet_addr ip;
@@ -418,37 +387,6 @@ struct hash_netiface6_elem {
 	const char *iface;
 };
 
-struct hash_netiface6t_elem {
-	union nf_inet_addr ip;
-	u8 physdev;
-	u8 cidr;
-	u8 nomatch;
-	u8 elem;
-	const char *iface;
-	unsigned long timeout;
-};
-
-struct hash_netiface6c_elem {
-	union nf_inet_addr ip;
-	u8 physdev;
-	u8 cidr;
-	u8 nomatch;
-	u8 elem;
-	const char *iface;
-	struct ip_set_counter counter;
-};
-
-struct hash_netiface6ct_elem {
-	union nf_inet_addr ip;
-	u8 physdev;
-	u8 cidr;
-	u8 nomatch;
-	u8 elem;
-	const char *iface;
-	struct ip_set_counter counter;
-	unsigned long timeout;
-};
-
 /* Common functions */
 
 static inline bool
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index cab2366..45b6e91 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -45,7 +45,7 @@ MODULE_ALIAS("ip_set_hash:net,port");
  */
 #define IP_SET_HASH_WITH_NETS_PACKED
 
-/* IPv4 variants */
+/* IPv4 variant */
 
 /* Member elements */
 struct hash_netport4_elem {
@@ -56,34 +56,6 @@ struct hash_netport4_elem {
 	u8 nomatch:1;
 };
 
-struct hash_netport4t_elem {
-	__be32 ip;
-	__be16 port;
-	u8 proto;
-	u8 cidr:7;
-	u8 nomatch:1;
-	unsigned long timeout;
-};
-
-struct hash_netport4c_elem {
-	__be32 ip;
-	__be16 port;
-	u8 proto;
-	u8 cidr:7;
-	u8 nomatch:1;
-	struct ip_set_counter counter;
-};
-
-struct hash_netport4ct_elem {
-	__be32 ip;
-	__be16 port;
-	u8 proto;
-	u8 cidr:7;
-	u8 nomatch:1;
-	struct ip_set_counter counter;
-	unsigned long timeout;
-};
-
 /* Common functions */
 
 static inline bool
@@ -287,7 +259,7 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	return ret;
 }
 
-/* IPv6 variants */
+/* IPv6 variant */
 
 struct hash_netport6_elem {
 	union nf_inet_addr ip;
@@ -297,34 +269,6 @@ struct hash_netport6_elem {
 	u8 nomatch:1;
 };
 
-struct hash_netport6t_elem {
-	union nf_inet_addr ip;
-	__be16 port;
-	u8 proto;
-	u8 cidr:7;
-	u8 nomatch:1;
-	unsigned long timeout;
-};
-
-struct hash_netport6c_elem {
-	union nf_inet_addr ip;
-	__be16 port;
-	u8 proto;
-	u8 cidr:7;
-	u8 nomatch:1;
-	struct ip_set_counter counter;
-};
-
-struct hash_netport6ct_elem {
-	union nf_inet_addr ip;
-	__be16 port;
-	u8 proto;
-	u8 cidr:7;
-	u8 nomatch:1;
-	struct ip_set_counter counter;
-	unsigned long timeout;
-};
-
 /* Common functions */
 
 static inline bool
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index f22d05d..7fd11c7 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -28,28 +28,6 @@ struct set_elem {
 	ip_set_id_t id;
 };
 
-struct sett_elem {
-	struct {
-		ip_set_id_t id;
-	} __attribute__ ((aligned));
-	unsigned long timeout;
-};
-
-struct setc_elem {
-	struct {
-		ip_set_id_t id;
-	} __attribute__ ((aligned));
-	struct ip_set_counter counter;
-};
-
-struct setct_elem {
-	struct {
-		ip_set_id_t id;
-	} __attribute__ ((aligned));
-	struct ip_set_counter counter;
-	unsigned long timeout;
-};
-
 struct set_adt_elem {
 	ip_set_id_t id;
 	ip_set_id_t refid;
@@ -600,21 +578,18 @@ list_set_gc_init(struct ip_set *set, void (*gc)(unsigned long ul_set))
 
 /* Create list:set type of sets */
 
-static struct list_set *
-init_list_set(struct ip_set *set, u32 size, size_t dsize,
-	      unsigned long timeout)
+static bool
+init_list_set(struct ip_set *set, u32 size)
 {
 	struct list_set *map;
 	struct set_elem *e;
 	u32 i;
 
-	map = kzalloc(sizeof(*map) + size * dsize, GFP_KERNEL);
+	map = kzalloc(sizeof(*map) + size * set->dsize, GFP_KERNEL);
 	if (!map)
-		return NULL;
+		return false;
 
 	map->size = size;
-	set->dsize = dsize;
-	set->timeout = timeout;
 	set->data = map;
 
 	for (i = 0; i < size; i++) {
@@ -622,15 +597,13 @@ init_list_set(struct ip_set *set, u32 size, size_t dsize,
 		e->id = IPSET_INVALID_ID;
 	}
 
-	return map;
+	return true;
 }
 
 static int
 list_set_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 {
-	struct list_set *map;
-	u32 size = IP_SET_LIST_DEFAULT_SIZE, cadt_flags = 0;
-	unsigned long timeout = 0;
+	u32 size = IP_SET_LIST_DEFAULT_SIZE;
 
 	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_SIZE) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
@@ -642,45 +615,13 @@ list_set_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	if (size < IP_SET_LIST_MIN_SIZE)
 		size = IP_SET_LIST_MIN_SIZE;
 
-	if (tb[IPSET_ATTR_CADT_FLAGS])
-		cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
-	if (tb[IPSET_ATTR_TIMEOUT])
-		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	set->variant = &set_variant;
-	if (cadt_flags & IPSET_FLAG_WITH_COUNTERS) {
-		set->extensions |= IPSET_EXT_COUNTER;
-		if (tb[IPSET_ATTR_TIMEOUT]) {
-			map = init_list_set(set, size,
-					sizeof(struct setct_elem), timeout);
-			if (!map)
-				return -ENOMEM;
-			set->extensions |= IPSET_EXT_TIMEOUT;
-			set->offset[IPSET_EXT_ID_TIMEOUT] =
-				offsetof(struct setct_elem, timeout);
-			set->offset[IPSET_EXT_ID_COUNTER] =
-				offsetof(struct setct_elem, counter);
-			list_set_gc_init(set, list_set_gc);
-		} else {
-			map = init_list_set(set, size,
-					    sizeof(struct setc_elem), 0);
-			if (!map)
-				return -ENOMEM;
-			set->offset[IPSET_EXT_ID_COUNTER] =
-				offsetof(struct setc_elem, counter);
-		}
-	} else if (tb[IPSET_ATTR_TIMEOUT]) {
-		map = init_list_set(set, size,
-				    sizeof(struct sett_elem), timeout);
-		if (!map)
-			return -ENOMEM;
-		set->extensions |= IPSET_EXT_TIMEOUT;
-		set->offset[IPSET_EXT_ID_TIMEOUT] =
-			offsetof(struct sett_elem, timeout);
+	set->dsize = ip_set_elem_len(set, tb, sizeof(struct set_elem));
+	if (!init_list_set(set, size))
+		return -ENOMEM;
+	if (tb[IPSET_ATTR_TIMEOUT]) {
+		set->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 		list_set_gc_init(set, list_set_gc);
-	} else {
-		map = init_list_set(set, size, sizeof(struct set_elem), 0);
-		if (!map)
-			return -ENOMEM;
 	}
 	return 0;
 }
-- 
1.7.10.4
