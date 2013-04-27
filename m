From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/18] netfilter: ipset: The list:set type with counter support
Date: Sat, 27 Apr 2013 20:58:17 +0200
Message-ID: <1367089103-8394-13-git-send-email-pablo@netfilter.org>
References: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42584 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754760Ab3D0S6w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Apr 2013 14:58:52 -0400
In-Reply-To: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_list_set.c |   73 ++++++++++++++++++++++++++++++---
 1 file changed, 67 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 919eefe..c09022e 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -16,7 +16,7 @@
 #include <linux/netfilter/ipset/ip_set_list.h>
 
 #define REVISION_MIN	0
-#define REVISION_MAX	0
+#define REVISION_MAX	1 /* Counters support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
@@ -35,6 +35,21 @@ struct sett_elem {
 	unsigned long timeout;
 };
 
+struct setc_elem {
+	struct {
+		ip_set_id_t id;
+	} __attribute__ ((aligned));
+	struct ip_set_counter counter;
+};
+
+struct setct_elem {
+	struct {
+		ip_set_id_t id;
+	} __attribute__ ((aligned));
+	struct ip_set_counter counter;
+	unsigned long timeout;
+};
+
 struct set_adt_elem {
 	ip_set_id_t id;
 	ip_set_id_t refid;
@@ -59,6 +74,8 @@ list_set_elem(const struct list_set *map, u32 id)
 
 #define ext_timeout(e, m)	\
 (unsigned long *)((void *)(e) + (m)->offset[IPSET_OFFSET_TIMEOUT])
+#define ext_counter(e, m)	\
+(struct ip_set_counter *)((void *)(e) + (m)->offset[IPSET_OFFSET_COUNTER])
 
 static int
 list_set_ktest(struct ip_set *set, const struct sk_buff *skb,
@@ -78,8 +95,13 @@ list_set_ktest(struct ip_set *set, const struct sk_buff *skb,
 		    ip_set_timeout_expired(ext_timeout(e, map)))
 			continue;
 		ret = ip_set_test(e->id, skb, par, opt);
-		if (ret > 0)
+		if (ret > 0) {
+			if (SET_WITH_COUNTER(set))
+				ip_set_update_counter(ext_counter(e, map),
+						      ext, &opt->ext,
+						      opt->cmdflags);
 			return ret;
+		}
 	}
 	return 0;
 }
@@ -193,6 +215,8 @@ list_set_add(struct ip_set *set, u32 i, struct set_adt_elem *d,
 	e->id = d->id;
 	if (SET_WITH_TIMEOUT(set))
 		ip_set_timeout_set(ext_timeout(e, map), ext->timeout);
+	if (SET_WITH_COUNTER(set))
+		ip_set_init_counter(ext_counter(e, map), ext);
 	return 0;
 }
 
@@ -293,6 +317,8 @@ list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		/* Update extensions */
 		if (SET_WITH_TIMEOUT(set))
 			ip_set_timeout_set(ext_timeout(e, map), ext->timeout);
+		if (SET_WITH_COUNTER(set))
+			ip_set_init_counter(ext_counter(e, map), ext);
 		/* Set is already added to the list */
 		ip_set_put_byindex(d->id);
 		return 0;
@@ -362,7 +388,9 @@ list_set_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (unlikely(!tb[IPSET_ATTR_NAME] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PACKETS) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_BYTES)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -455,6 +483,9 @@ list_set_head(struct ip_set *set, struct sk_buff *skb)
 	if (nla_put_net32(skb, IPSET_ATTR_SIZE, htonl(map->size)) ||
 	    (SET_WITH_TIMEOUT(set) &&
 	     nla_put_net32(skb, IPSET_ATTR_TIMEOUT, htonl(map->timeout))) ||
+	    (SET_WITH_COUNTER(set) &&
+	     nla_put_net32(skb, IPSET_ATTR_CADT_FLAGS,
+			   htonl(IPSET_FLAG_WITH_COUNTERS))) ||
 	    nla_put_net32(skb, IPSET_ATTR_REFERENCES, htonl(set->ref - 1)) ||
 	    nla_put_net32(skb, IPSET_ATTR_MEMSIZE,
 			  htonl(sizeof(*map) + map->size * map->dsize)))
@@ -502,6 +533,9 @@ list_set_list(const struct ip_set *set,
 				  htonl(ip_set_timeout_get(
 						ext_timeout(e, map)))))
 			goto nla_put_failure;
+		if (SET_WITH_COUNTER(set) &&
+		    ip_set_put_counter(skb, ext_counter(e, map)))
+			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
 finish:
@@ -603,11 +637,12 @@ static int
 list_set_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 {
 	struct list_set *map;
-	u32 size = IP_SET_LIST_DEFAULT_SIZE;
+	u32 size = IP_SET_LIST_DEFAULT_SIZE, cadt_flags = 0;
 	unsigned long timeout = 0;
 
 	if (unlikely(!ip_set_optattr_netorder(tb, IPSET_ATTR_SIZE) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_SIZE])
@@ -615,10 +650,33 @@ list_set_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	if (size < IP_SET_LIST_MIN_SIZE)
 		size = IP_SET_LIST_MIN_SIZE;
 
+	if (tb[IPSET_ATTR_CADT_FLAGS])
+		cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
 	if (tb[IPSET_ATTR_TIMEOUT])
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	set->variant = &set_variant;
-	if (tb[IPSET_ATTR_TIMEOUT]) {
+	if (cadt_flags & IPSET_FLAG_WITH_COUNTERS) {
+		set->extensions |= IPSET_EXT_COUNTER;
+		if (tb[IPSET_ATTR_TIMEOUT]) {
+			map = init_list_set(set, size,
+					sizeof(struct setct_elem), timeout);
+			if (!map)
+				return -ENOMEM;
+			set->extensions |= IPSET_EXT_TIMEOUT;
+			map->offset[IPSET_OFFSET_TIMEOUT] =
+				offsetof(struct setct_elem, timeout);
+			map->offset[IPSET_OFFSET_COUNTER] =
+				offsetof(struct setct_elem, counter);
+			list_set_gc_init(set, list_set_gc);
+		} else {
+			map = init_list_set(set, size,
+					    sizeof(struct setc_elem), 0);
+			if (!map)
+				return -ENOMEM;
+			map->offset[IPSET_OFFSET_COUNTER] =
+				offsetof(struct setc_elem, counter);
+		}
+	} else if (tb[IPSET_ATTR_TIMEOUT]) {
 		map = init_list_set(set, size,
 				    sizeof(struct sett_elem), timeout);
 		if (!map)
@@ -647,6 +705,7 @@ static struct ip_set_type list_set_type __read_mostly = {
 	.create_policy	= {
 		[IPSET_ATTR_SIZE]	= { .type = NLA_U32 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
+		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 	},
 	.adt_policy	= {
 		[IPSET_ATTR_NAME]	= { .type = NLA_STRING,
@@ -656,6 +715,8 @@ static struct ip_set_type list_set_type __read_mostly = {
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
+		[IPSET_ATTR_BYTES]	= { .type = NLA_U64 },
+		[IPSET_ATTR_PACKETS]	= { .type = NLA_U64 },
 	},
 	.me		= THIS_MODULE,
 };
-- 
1.7.10.4
