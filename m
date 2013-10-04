From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 27/33] netfilter: ipset: Use a common function at listing the extensions
Date: Fri,  4 Oct 2013 10:33:12 +0200
Message-ID: <1380875598-5250-28-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h    |   21 +++++++++++++++++++++
 net/netfilter/ipset/ip_set_bitmap_gen.h   |   29 ++++++++++-------------------
 net/netfilter/ipset/ip_set_bitmap_ipmac.c |   11 -----------
 net/netfilter/ipset/ip_set_hash_gen.h     |   11 +----------
 net/netfilter/ipset/ip_set_list_set.c     |   11 +----------
 5 files changed, 33 insertions(+), 50 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 407f84d..da2a45a 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -461,6 +461,27 @@ bitmap_bytes(u32 a, u32 b)
 #include <linux/netfilter/ipset/ip_set_timeout.h>
 #include <linux/netfilter/ipset/ip_set_comment.h>
 
+static inline int
+ip_set_put_extensions(struct sk_buff *skb, const struct ip_set *set,
+		      const void *e, bool active)
+{
+	if (SET_WITH_TIMEOUT(set)) {
+		unsigned long *timeout = ext_timeout(e, set);
+
+		if (nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
+			htonl(active ? ip_set_timeout_get(timeout)
+				: *timeout)))
+			return -EMSGSIZE;
+	}
+	if (SET_WITH_COUNTER(set) &&
+	    ip_set_put_counter(skb, ext_counter(e, set)))
+		return -EMSGSIZE;
+	if (SET_WITH_COMMENT(set) &&
+	    ip_set_put_comment(skb, ext_comment(e, set)))
+		return -EMSGSIZE;
+	return 0;
+}
+
 #define IP_SET_INIT_KEXT(skb, opt, set)			\
 	{ .bytes = (skb)->len, .packets = 1,		\
 	  .timeout = ip_set_adt_opt_timeout(opt, set) }
diff --git a/net/netfilter/ipset/ip_set_bitmap_gen.h b/net/netfilter/ipset/ip_set_bitmap_gen.h
index 6167fc9..a13e15b 100644
--- a/net/netfilter/ipset/ip_set_bitmap_gen.h
+++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
@@ -183,6 +183,14 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	return 0;
 }
 
+#ifndef IP_SET_BITMAP_STORED_TIMEOUT
+static inline bool
+mtype_is_filled(const struct mtype_elem *x)
+{
+	return true;
+}
+#endif
+
 static int
 mtype_list(const struct ip_set *set,
 	   struct sk_buff *skb, struct netlink_callback *cb)
@@ -215,25 +223,8 @@ mtype_list(const struct ip_set *set,
 		}
 		if (mtype_do_list(skb, map, id, set->dsize))
 			goto nla_put_failure;
-		if (SET_WITH_TIMEOUT(set)) {
-#ifdef IP_SET_BITMAP_STORED_TIMEOUT
-			if (nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-					  htonl(ip_set_timeout_stored(map, id,
-							ext_timeout(x, set),
-							set->dsize))))
-				goto nla_put_failure;
-#else
-			if (nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-					  htonl(ip_set_timeout_get(
-							ext_timeout(x, set)))))
-				goto nla_put_failure;
-#endif
-		}
-		if (SET_WITH_COUNTER(set) &&
-		    ip_set_put_counter(skb, ext_counter(x, set)))
-			goto nla_put_failure;
-		if (SET_WITH_COMMENT(set) &&
-		    ip_set_put_comment(skb, ext_comment(x, set)))
+		if (ip_set_put_extensions(skb, set, x,
+		    mtype_is_filled((const struct mtype_elem *) x)))
 			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index fb4d163..87a218f 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -176,17 +176,6 @@ bitmap_ipmac_do_del(const struct bitmap_ipmac_adt_elem *e,
 	return !test_and_clear_bit(e->id, map->members);
 }
 
-static inline unsigned long
-ip_set_timeout_stored(struct bitmap_ipmac *map, u32 id, unsigned long *timeout,
-		      size_t dsize)
-{
-	const struct bitmap_ipmac_elem *elem =
-		get_elem(map->extensions, id, dsize);
-
-	return elem->filled == MAC_FILLED ? ip_set_timeout_get(timeout) :
-					    *timeout;
-}
-
 static inline int
 bitmap_ipmac_do_list(struct sk_buff *skb, const struct bitmap_ipmac *map,
 		     u32 id, size_t dsize)
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 1cffeb9..b4add20 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -961,16 +961,7 @@ mtype_list(const struct ip_set *set,
 			}
 			if (mtype_data_list(skb, e))
 				goto nla_put_failure;
-			if (SET_WITH_TIMEOUT(set) &&
-			    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-					  htonl(ip_set_timeout_get(
-						ext_timeout(e, set)))))
-				goto nla_put_failure;
-			if (SET_WITH_COUNTER(set) &&
-			    ip_set_put_counter(skb, ext_counter(e, set)))
-				goto nla_put_failure;
-			if (SET_WITH_COMMENT(set) &&
-			    ip_set_put_comment(skb, ext_comment(e, set)))
+			if (ip_set_put_extensions(skb, set, e, true))
 				goto nla_put_failure;
 			ipset_nest_end(skb, nested);
 		}
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index e23f33c..ba4232e 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -512,16 +512,7 @@ list_set_list(const struct ip_set *set,
 		if (nla_put_string(skb, IPSET_ATTR_NAME,
 				   ip_set_name_byindex(e->id)))
 			goto nla_put_failure;
-		if (SET_WITH_TIMEOUT(set) &&
-		    nla_put_net32(skb, IPSET_ATTR_TIMEOUT,
-				  htonl(ip_set_timeout_get(
-						ext_timeout(e, set)))))
-			goto nla_put_failure;
-		if (SET_WITH_COUNTER(set) &&
-		    ip_set_put_counter(skb, ext_counter(e, set)))
-			goto nla_put_failure;
-		if (SET_WITH_COMMENT(set) &&
-		    ip_set_put_comment(skb, ext_comment(e, set)))
+		if (ip_set_put_extensions(skb, set, e, true))
 			goto nla_put_failure;
 		ipset_nest_end(skb, nested);
 	}
-- 
1.7.10.4

