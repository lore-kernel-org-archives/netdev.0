From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/18] netfilter: ipset: The bitmap types with counter support
Date: Sat, 27 Apr 2013 20:58:15 +0200
Message-ID: <1367089103-8394-11-git-send-email-pablo@netfilter.org>
References: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42610 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756258Ab3D0S7A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Apr 2013 14:59:00 -0400
In-Reply-To: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_bitmap_gen.h   |   14 +++++-
 net/netfilter/ipset/ip_set_bitmap_ip.c    |   62 +++++++++++++++++++++++---
 net/netfilter/ipset/ip_set_bitmap_ipmac.c |   68 ++++++++++++++++++++++++++---
 net/netfilter/ipset/ip_set_bitmap_port.c  |   57 ++++++++++++++++++++++--
 4 files changed, 186 insertions(+), 15 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_gen.h b/net/netfilter/ipset/ip_set_bitmap_gen.h
index b993159..2524337 100644
--- a/net/netfilter/ipset/ip_set_bitmap_gen.h
+++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
@@ -37,6 +37,8 @@
 
 #define ext_timeout(e, m)	\
 	(unsigned long *)((e) + (m)->offset[IPSET_OFFSET_TIMEOUT])
+#define ext_counter(e, m)	\
+	(struct ip_set_counter *)((e) + (m)->offset[IPSET_OFFSET_COUNTER])
 #define get_ext(map, id)	((map)->extensions + (map)->dsize * (id))
 
 static void
@@ -91,7 +93,10 @@ mtype_head(struct ip_set *set, struct sk_buff *skb)
 				map->memsize +
 				map->dsize * map->elements)) ||
 	    (SET_WITH_TIMEOUT(set) &&
-	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout))))
+	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout))) ||
+	    (SET_WITH_COUNTER(set) &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS,
+			   htonl(IPSET_FLAG_WITH_COUNTERS))))
 		goto nla_put_failure;
 	ipset_nest_end(skb, nested);
 
@@ -114,6 +119,8 @@ mtype_test(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	if (SET_WITH_TIMEOUT(set) &&
 	    ip_set_timeout_expired(ext_timeout(x, map)))
 		return 0;
+	if (SET_WITH_COUNTER(set))
+		ip_set_update_counter(ext_counter(x, map), ext, mext, flags);
 	return 1;
 }
 
@@ -141,6 +148,8 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		ip_set_timeout_set(ext_timeout(x, map), ext->timeout);
 #endif
 
+	if (SET_WITH_COUNTER(set))
+		ip_set_init_counter(ext_counter(x, map), ext);
 	return 0;
 }
 
@@ -205,6 +214,9 @@ mtype_list(const struct ip_set *set,
 				goto nla_put_failure;
 #endif
 		}
+		if (SET_WITH_COUNTER(set) &&
+		    ip_set_put_counter(skb, ext_counter(x, map)))
+			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
 	ipset_nest_end(skb, adt);
diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index f2ab011..f1a8128 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -26,7 +26,7 @@
 #include <linux/netfilter/ipset/ip_set_bitmap.h>
 
 #define REVISION_MIN	0
-#define REVISION_MAX	0
+#define REVISION_MAX	1	/* Counter support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -137,7 +137,9 @@ bitmap_ip_uadt(struct ip_set *set, struct nlattr *tb[],
 	int ret = 0;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -213,6 +215,19 @@ struct bitmap_ipt_elem {
 	unsigned long timeout;
 };
 
+/* Plain variant with counter */
+
+struct bitmap_ipc_elem {
+	struct ip_set_counter counter;
+};
+
+/* Timeout variant with counter */
+
+struct bitmap_ipct_elem {
+	unsigned long timeout;
+	struct ip_set_counter counter;
+};
+
 #include "ip_set_bitmap_gen.h"
 
 /* Create bitmap:ip type of sets */
@@ -249,13 +264,14 @@ static int
 bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 {
 	struct bitmap_ip *map;
-	u32 first_ip, last_ip, hosts;
+	u32 first_ip, last_ip, hosts, cadt_flags = 0;
 	u64 elements;
 	u8 netmask = 32;
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
 	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &first_ip);
@@ -320,7 +336,40 @@ bitmap_ip_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 
 	map->memsize = bitmap_bytes(0, elements - 1);
 	set->variant = &bitmap_ip;
-	if (tb[IPSET_ATTR_TIMEOUT]) {
+	if (tb[IPSET_ATTR_CADT_FLAGS])
+		cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
+	if (cadt_flags & IPSET_FLAG_WITH_COUNTERS) {
+		set->extensions |= IPSET_EXT_COUNTER;
+		if (tb[IPSET_ATTR_TIMEOUT]) {
+			map->dsize = sizeof(struct bitmap_ipct_elem);
+			map->offset[IPSET_OFFSET_TIMEOUT] =
+				offsetof(struct bitmap_ipct_elem, timeout);
+			map->offset[IPSET_OFFSET_COUNTER] =
+				offsetof(struct bitmap_ipct_elem, counter);
+
+			if (!init_map_ip(set, map, first_ip, last_ip,
+					 elements, hosts, netmask)) {
+				kfree(map);
+				return -ENOMEM;
+			}
+
+			map->timeout = ip_set_timeout_uget(
+				tb[IPSET_ATTR_TIMEOUT]);
+			set->extensions |= IPSET_EXT_TIMEOUT;
+
+			bitmap_ip_gc_init(set, bitmap_ip_gc);
+		} else {
+			map->dsize = sizeof(struct bitmap_ipc_elem);
+			map->offset[IPSET_OFFSET_COUNTER] =
+				offsetof(struct bitmap_ipc_elem, counter);
+
+			if (!init_map_ip(set, map, first_ip, last_ip,
+					 elements, hosts, netmask)) {
+				kfree(map);
+				return -ENOMEM;
+			}
+		}
+	} else if (tb[IPSET_ATTR_TIMEOUT]) {
 		map->dsize = sizeof(struct bitmap_ipt_elem);
 		map->offset[IPSET_OFFSET_TIMEOUT] =
 			offsetof(struct bitmap_ipt_elem, timeout);
@@ -361,6 +410,7 @@ static struct ip_set_type bitmap_ip_type __read_mostly = {
 		[IPSET_ATTR_CIDR]	= { .type = NLA_U8 },
 		[IPSET_ATTR_NETMASK]	= { .type = NLA_U8  },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
+		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 	},
 	.adt_policy	= {
 		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
@@ -368,6 +418,8 @@ static struct ip_set_type bitmap_ip_type __read_mostly = {
 		[IPSET_ATTR_CIDR]	= { .type = NLA_U8 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
+		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 960810d..3b30e0b 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -26,7 +26,7 @@
 #include <linux/netfilter/ipset/ip_set_bitmap.h>
 
 #define REVISION_MIN	0
-#define REVISION_MAX	0
+#define REVISION_MAX	1	/* Counter support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -250,7 +250,9 @@ bitmap_ipmac_uadt(struct ip_set *set, struct nlattr *tb[],
 	int ret = 0;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -299,6 +301,27 @@ struct bitmap_ipmact_elem {
 	unsigned long timeout;
 };
 
+/* Plain variant with counter */
+
+struct bitmap_ipmacc_elem {
+	struct {
+		unsigned char ether[ETH_ALEN];
+		unsigned char filled;
+	} __attribute__ ((aligned));
+	struct ip_set_counter counter;
+};
+
+/* Timeout variant with counter */
+
+struct bitmap_ipmacct_elem {
+	struct {
+		unsigned char ether[ETH_ALEN];
+		unsigned char filled;
+	} __attribute__ ((aligned));
+	unsigned long timeout;
+	struct ip_set_counter counter;
+};
+
 #include "ip_set_bitmap_gen.h"
 
 /* Create bitmap:ip,mac type of sets */
@@ -332,13 +355,14 @@ static int
 bitmap_ipmac_create(struct ip_set *set, struct nlattr *tb[],
 		    u32 flags)
 {
-	u32 first_ip, last_ip;
+	u32 first_ip, last_ip, cadt_flags = 0;
 	u64 elements;
 	struct bitmap_ipmac *map;
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
 	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &first_ip);
@@ -375,7 +399,38 @@ bitmap_ipmac_create(struct ip_set *set, struct nlattr *tb[],
 
 	map->memsize = bitmap_bytes(0, elements - 1);
 	set->variant = &bitmap_ipmac;
-	if (tb[IPSET_ATTR_TIMEOUT]) {
+	if (tb[IPSET_ATTR_CADT_FLAGS])
+		cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
+	if (cadt_flags & IPSET_FLAG_WITH_COUNTERS) {
+		set->extensions |= IPSET_EXT_COUNTER;
+		if (tb[IPSET_ATTR_TIMEOUT]) {
+			map->dsize = sizeof(struct bitmap_ipmacct_elem);
+			map->offset[IPSET_OFFSET_TIMEOUT] =
+				offsetof(struct bitmap_ipmacct_elem, timeout);
+			map->offset[IPSET_OFFSET_COUNTER] =
+				offsetof(struct bitmap_ipmacct_elem, counter);
+
+			if (!init_map_ipmac(set, map, first_ip, last_ip,
+					    elements)) {
+				kfree(map);
+				return -ENOMEM;
+			}
+			map->timeout = ip_set_timeout_uget(
+				tb[IPSET_ATTR_TIMEOUT]);
+			set->extensions |= IPSET_EXT_TIMEOUT;
+			bitmap_ipmac_gc_init(set, bitmap_ipmac_gc);
+		} else {
+			map->dsize = sizeof(struct bitmap_ipmacc_elem);
+			map->offset[IPSET_OFFSET_COUNTER] =
+				offsetof(struct bitmap_ipmacc_elem, counter);
+
+			if (!init_map_ipmac(set, map, first_ip, last_ip,
+					    elements)) {
+				kfree(map);
+				return -ENOMEM;
+			}
+		}
+	} else if (tb[IPSET_ATTR_TIMEOUT]) {
 		map->dsize = sizeof(struct bitmap_ipmact_elem);
 		map->offset[IPSET_OFFSET_TIMEOUT] =
 			offsetof(struct bitmap_ipmact_elem, timeout);
@@ -413,6 +468,7 @@ static struct ip_set_type bitmap_ipmac_type = {
 		[IPSET_ATTR_IP_TO]	= { .type = NLA_NESTED },
 		[IPSET_ATTR_CIDR]	= { .type = NLA_U8 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
+		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 	},
 	.adt_policy	= {
 		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
@@ -420,6 +476,8 @@ static struct ip_set_type bitmap_ipmac_type = {
 					    .len  = ETH_ALEN },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
+		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index 27e2c57..8207d1f 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -21,7 +21,7 @@
 #include <linux/netfilter/ipset/ip_set_getport.h>
 
 #define REVISION_MIN	0
-#define REVISION_MAX	0
+#define REVISION_MAX	1	/* Counter support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -138,7 +138,9 @@ bitmap_port_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (unlikely(!ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -199,10 +201,24 @@ struct bitmap_port_elem {
 };
 
 /* Timeout variant */
+
 struct bitmap_portt_elem {
 	unsigned long timeout;
 };
 
+/* Plain variant with counter */
+
+struct bitmap_portc_elem {
+	struct ip_set_counter counter;
+};
+
+/* Timeout variant with counter */
+
+struct bitmap_portct_elem {
+	unsigned long timeout;
+	struct ip_set_counter counter;
+};
+
 #include "ip_set_bitmap_gen.h"
 
 /* Create bitmap:ip type of sets */
@@ -236,10 +252,12 @@ bitmap_port_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 {
 	struct bitmap_port *map;
 	u16 first_port, last_port;
+	u32 cadt_flags = 0;
 
 	if (unlikely(!ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
 	first_port = ip_set_get_h16(tb[IPSET_ATTR_PORT]);
@@ -258,7 +276,35 @@ bitmap_port_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	map->elements = last_port - first_port + 1;
 	map->memsize = map->elements * sizeof(unsigned long);
 	set->variant = &bitmap_port;
-	if (tb[IPSET_ATTR_TIMEOUT]) {
+	if (tb[IPSET_ATTR_CADT_FLAGS])
+		cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
+	if (cadt_flags & IPSET_FLAG_WITH_COUNTERS) {
+		set->extensions |= IPSET_EXT_COUNTER;
+		if (tb[IPSET_ATTR_TIMEOUT]) {
+			map->dsize = sizeof(struct bitmap_portct_elem);
+			map->offset[IPSET_OFFSET_TIMEOUT] =
+				offsetof(struct bitmap_portct_elem, timeout);
+			map->offset[IPSET_OFFSET_COUNTER] =
+				offsetof(struct bitmap_portct_elem, counter);
+			if (!init_map_port(set, map, first_port, last_port)) {
+				kfree(map);
+				return -ENOMEM;
+			}
+
+			map->timeout =
+				ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
+			set->extensions |= IPSET_EXT_TIMEOUT;
+			bitmap_port_gc_init(set, bitmap_port_gc);
+		} else {
+			map->dsize = sizeof(struct bitmap_portc_elem);
+			map->offset[IPSET_OFFSET_COUNTER] =
+				offsetof(struct bitmap_portc_elem, counter);
+			if (!init_map_port(set, map, first_port, last_port)) {
+				kfree(map);
+				return -ENOMEM;
+			}
+		}
+	} else if (tb[IPSET_ATTR_TIMEOUT]) {
 		map->dsize = sizeof(struct bitmap_portt_elem);
 		map->offset[IPSET_OFFSET_TIMEOUT] =
 			offsetof(struct bitmap_portt_elem, timeout);
@@ -294,12 +340,15 @@ static struct ip_set_type bitmap_port_type = {
 		[IPSET_ATTR_PORT]	= { .type = NLA_U16 },
 		[IPSET_ATTR_PORT_TO]	= { .type = NLA_U16 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
+		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 	},
 	.adt_policy	= {
 		[IPSET_ATTR_PORT]	= { .type = NLA_U16 },
 		[IPSET_ATTR_PORT_TO]	= { .type = NLA_U16 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
+		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 	},
 	.me		= THIS_MODULE,
 };
-- 
1.7.10.4
