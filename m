From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/18] netfilter: ipset: Introduce the counter extension in the core
Date: Sat, 27 Apr 2013 20:58:14 +0200
Message-ID: <1367089103-8394-10-git-send-email-pablo@netfilter.org>
References: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42606 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756241Ab3D0S67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Apr 2013 14:58:59 -0400
In-Reply-To: <1367089103-8394-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h      |   75 +++++++++++++++++++++++++--
 include/uapi/linux/netfilter/ipset/ip_set.h |    5 ++
 net/netfilter/ipset/ip_set_core.c           |   10 ++++
 3 files changed, 86 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index bf0220c..0f978eb 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -52,18 +52,24 @@ enum ip_set_extension {
 	IPSET_EXT_NONE = 0,
 	IPSET_EXT_BIT_TIMEOUT = 1,
 	IPSET_EXT_TIMEOUT = (1 << IPSET_EXT_BIT_TIMEOUT),
+	IPSET_EXT_BIT_COUNTER = 2,
+	IPSET_EXT_COUNTER = (1 << IPSET_EXT_BIT_COUNTER),
 };
 
 /* Extension offsets */
 enum ip_set_offset {
 	IPSET_OFFSET_TIMEOUT = 0,
+	IPSET_OFFSET_COUNTER,
 	IPSET_OFFSET_MAX,
 };
 
 #define SET_WITH_TIMEOUT(s)	((s)->extensions & IPSET_EXT_TIMEOUT)
+#define SET_WITH_COUNTER(s)	((s)->extensions & IPSET_EXT_COUNTER)
 
 struct ip_set_ext {
 	unsigned long timeout;
+	u64 packets;
+	u64 bytes;
 };
 
 struct ip_set;
@@ -177,6 +183,65 @@ struct ip_set {
 	void *data;
 };
 
+struct ip_set_counter {
+	atomic64_t bytes;
+	atomic64_t packets;
+};
+
+static inline void
+ip_set_add_bytes(u64 bytes, struct ip_set_counter *counter)
+{
+	atomic64_add((long long)bytes, &(counter)->bytes);
+}
+
+static inline void
+ip_set_add_packets(u64 packets, struct ip_set_counter *counter)
+{
+	atomic64_add((long long)packets, &(counter)->packets);
+}
+
+static inline u64
+ip_set_get_bytes(const struct ip_set_counter *counter)
+{
+	return (u64)atomic64_read(&(counter)->bytes);
+}
+
+static inline u64
+ip_set_get_packets(const struct ip_set_counter *counter)
+{
+	return (u64)atomic64_read(&(counter)->packets);
+}
+
+static inline void
+ip_set_update_counter(struct ip_set_counter *counter,
+		      const struct ip_set_ext *ext,
+		      struct ip_set_ext *mext, u32 flags)
+{
+	if (ext->packets != ULLONG_MAX) {
+		ip_set_add_bytes(ext->bytes, counter);
+		ip_set_add_packets(ext->packets, counter);
+	}
+}
+
+static inline bool
+ip_set_put_counter(struct sk_buff *skb, struct ip_set_counter *counter)
+{
+	return nla_put_net64(skb, IPSET_ATTR_BYTES,
+			     cpu_to_be64(ip_set_get_bytes(counter))) ||
+	       nla_put_net64(skb, IPSET_ATTR_PACKETS,
+			     cpu_to_be64(ip_set_get_packets(counter)));
+}
+
+static inline void
+ip_set_init_counter(struct ip_set_counter *counter,
+		    const struct ip_set_ext *ext)
+{
+	if (ext->bytes != ULLONG_MAX)
+		atomic64_set(&(counter)->bytes, (long long)(ext->bytes));
+	if (ext->packets != ULLONG_MAX)
+		atomic64_set(&(counter)->packets, (long long)(ext->packets));
+}
+
 /* register and unregister set references */
 extern ip_set_id_t ip_set_get_byname(const char *name, struct ip_set **set);
 extern void ip_set_put_byindex(ip_set_id_t index);
@@ -318,10 +383,12 @@ bitmap_bytes(u32 a, u32 b)
 
 #include <linux/netfilter/ipset/ip_set_timeout.h>
 
-#define IP_SET_INIT_KEXT(skb, opt, map)		\
-	{ .timeout = ip_set_adt_opt_timeout(opt, map) }
+#define IP_SET_INIT_KEXT(skb, opt, map)			\
+	{ .bytes = (skb)->len, .packets = 1,		\
+	  .timeout = ip_set_adt_opt_timeout(opt, map) }
 
-#define IP_SET_INIT_UEXT(map)			\
-	{ .timeout = (map)->timeout }
+#define IP_SET_INIT_UEXT(map)				\
+	{ .bytes = ULLONG_MAX, .packets = ULLONG_MAX,	\
+	  .timeout = (map)->timeout }
 
 #endif /*_IP_SET_H */
diff --git a/include/uapi/linux/netfilter/ipset/ip_set.h b/include/uapi/linux/netfilter/ipset/ip_set.h
index fbee428..ed45267 100644
--- a/include/uapi/linux/netfilter/ipset/ip_set.h
+++ b/include/uapi/linux/netfilter/ipset/ip_set.h
@@ -108,6 +108,8 @@ enum {
 	IPSET_ATTR_CIDR2,
 	IPSET_ATTR_IP2_TO,
 	IPSET_ATTR_IFACE,
+	IPSET_ATTR_BYTES,
+	IPSET_ATTR_PACKETS,
 	__IPSET_ATTR_ADT_MAX,
 };
 #define IPSET_ATTR_ADT_MAX	(__IPSET_ATTR_ADT_MAX - 1)
@@ -137,6 +139,7 @@ enum ipset_errno {
 	IPSET_ERR_REFERENCED,
 	IPSET_ERR_IPADDR_IPV4,
 	IPSET_ERR_IPADDR_IPV6,
+	IPSET_ERR_COUNTER,
 
 	/* Type specific error codes */
 	IPSET_ERR_TYPE_SPECIFIC = 4352,
@@ -161,6 +164,8 @@ enum ipset_cadt_flags {
 	IPSET_FLAG_PHYSDEV	= (1 << IPSET_FLAG_BIT_PHYSDEV),
 	IPSET_FLAG_BIT_NOMATCH	= 2,
 	IPSET_FLAG_NOMATCH	= (1 << IPSET_FLAG_BIT_NOMATCH),
+	IPSET_FLAG_BIT_WITH_COUNTERS = 3,
+	IPSET_FLAG_WITH_COUNTERS = (1 << IPSET_FLAG_BIT_WITH_COUNTERS),
 	IPSET_FLAG_CADT_MAX	= 15,	/* Upper half */
 };
 
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 4486285d..f6d878a 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -324,6 +324,16 @@ ip_set_get_extensions(struct ip_set *set, struct nlattr *tb[],
 			return -IPSET_ERR_TIMEOUT;
 		ext->timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
+	if (tb[IPSET_ATTR_BYTES] || tb[IPSET_ATTR_PACKETS]) {
+		if (!(set->extensions & IPSET_EXT_COUNTER))
+			return -IPSET_ERR_COUNTER;
+		if (tb[IPSET_ATTR_BYTES])
+			ext->bytes = be64_to_cpu(nla_get_be64(
+						 tb[IPSET_ATTR_BYTES]));
+		if (tb[IPSET_ATTR_PACKETS])
+			ext->packets = be64_to_cpu(nla_get_be64(
+						   tb[IPSET_ATTR_PACKETS]));
+	}
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ip_set_get_extensions);
-- 
1.7.10.4
