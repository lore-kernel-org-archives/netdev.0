From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/4] netfilter: ipset: hash:*net*: nomatch flag not excluded on set resize
Date: Fri, 12 Apr 2013 12:13:18 +0200
Message-ID: <1365761599-6990-4-git-send-email-pablo@netfilter.org>
References: <1365761599-6990-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1365761599-6990-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

If a resize is triggered the nomatch flag is not excluded at hashing,
which leads to the element missed at lookup in the resized set.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/ipset/ip_set_ahash.h |   30 ++++++++++++++++++++------
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |   18 ++++++++++++++++
 net/netfilter/ipset/ip_set_hash_net.c        |   22 +++++++++++++++++--
 net/netfilter/ipset/ip_set_hash_netiface.c   |   22 +++++++++++++++++--
 net/netfilter/ipset/ip_set_hash_netport.c    |   18 ++++++++++++++++
 5 files changed, 99 insertions(+), 11 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set_ahash.h b/include/linux/netfilter/ipset/ip_set_ahash.h
index 01d25e6..0214c4c 100644
--- a/include/linux/netfilter/ipset/ip_set_ahash.h
+++ b/include/linux/netfilter/ipset/ip_set_ahash.h
@@ -291,6 +291,7 @@ ip_set_hash_destroy(struct ip_set *set)
 #define type_pf_data_tlist	TOKEN(TYPE, PF, _data_tlist)
 #define type_pf_data_next	TOKEN(TYPE, PF, _data_next)
 #define type_pf_data_flags	TOKEN(TYPE, PF, _data_flags)
+#define type_pf_data_reset_flags TOKEN(TYPE, PF, _data_reset_flags)
 #ifdef IP_SET_HASH_WITH_NETS
 #define type_pf_data_match	TOKEN(TYPE, PF, _data_match)
 #else
@@ -385,9 +386,9 @@ type_pf_resize(struct ip_set *set, bool retried)
 	struct ip_set_hash *h = set->data;
 	struct htable *t, *orig = h->table;
 	u8 htable_bits = orig->htable_bits;
-	const struct type_pf_elem *data;
+	struct type_pf_elem *data;
 	struct hbucket *n, *m;
-	u32 i, j;
+	u32 i, j, flags = 0;
 	int ret;
 
 retry:
@@ -412,9 +413,16 @@ retry:
 		n = hbucket(orig, i);
 		for (j = 0; j < n->pos; j++) {
 			data = ahash_data(n, j);
+#ifdef IP_SET_HASH_WITH_NETS
+			flags = 0;
+			type_pf_data_reset_flags(data, &flags);
+#endif
 			m = hbucket(t, HKEY(data, h->initval, htable_bits));
-			ret = type_pf_elem_add(m, data, AHASH_MAX(h), 0);
+			ret = type_pf_elem_add(m, data, AHASH_MAX(h), flags);
 			if (ret < 0) {
+#ifdef IP_SET_HASH_WITH_NETS
+				type_pf_data_flags(data, flags);
+#endif
 				read_unlock_bh(&set->lock);
 				ahash_destroy(t);
 				if (ret == -EAGAIN)
@@ -836,9 +844,9 @@ type_pf_tresize(struct ip_set *set, bool retried)
 	struct ip_set_hash *h = set->data;
 	struct htable *t, *orig = h->table;
 	u8 htable_bits = orig->htable_bits;
-	const struct type_pf_elem *data;
+	struct type_pf_elem *data;
 	struct hbucket *n, *m;
-	u32 i, j;
+	u32 i, j, flags = 0;
 	int ret;
 
 	/* Try to cleanup once */
@@ -873,10 +881,17 @@ retry:
 		n = hbucket(orig, i);
 		for (j = 0; j < n->pos; j++) {
 			data = ahash_tdata(n, j);
+#ifdef IP_SET_HASH_WITH_NETS
+			flags = 0;
+			type_pf_data_reset_flags(data, &flags);
+#endif
 			m = hbucket(t, HKEY(data, h->initval, htable_bits));
-			ret = type_pf_elem_tadd(m, data, AHASH_MAX(h), 0,
-						ip_set_timeout_get(type_pf_data_timeout(data)));
+			ret = type_pf_elem_tadd(m, data, AHASH_MAX(h), flags,
+				ip_set_timeout_get(type_pf_data_timeout(data)));
 			if (ret < 0) {
+#ifdef IP_SET_HASH_WITH_NETS
+				type_pf_data_flags(data, flags);
+#endif
 				read_unlock_bh(&set->lock);
 				ahash_destroy(t);
 				if (ret == -EAGAIN)
@@ -1187,6 +1202,7 @@ type_pf_gc_init(struct ip_set *set)
 #undef type_pf_data_tlist
 #undef type_pf_data_next
 #undef type_pf_data_flags
+#undef type_pf_data_reset_flags
 #undef type_pf_data_match
 
 #undef type_pf_elem
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index f262722..10a30b4 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -104,6 +104,15 @@ hash_ipportnet4_data_flags(struct hash_ipportnet4_elem *dst, u32 flags)
 	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
 }
 
+static inline void
+hash_ipportnet4_data_reset_flags(struct hash_ipportnet4_elem *dst, u32 *flags)
+{
+	if (dst->nomatch) {
+		*flags = IPSET_FLAG_NOMATCH;
+		dst->nomatch = 0;
+	}
+}
+
 static inline int
 hash_ipportnet4_data_match(const struct hash_ipportnet4_elem *elem)
 {
@@ -414,6 +423,15 @@ hash_ipportnet6_data_flags(struct hash_ipportnet6_elem *dst, u32 flags)
 	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
 }
 
+static inline void
+hash_ipportnet6_data_reset_flags(struct hash_ipportnet6_elem *dst, u32 *flags)
+{
+	if (dst->nomatch) {
+		*flags = IPSET_FLAG_NOMATCH;
+		dst->nomatch = 0;
+	}
+}
+
 static inline int
 hash_ipportnet6_data_match(const struct hash_ipportnet6_elem *elem)
 {
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 4b677cf..d6a5915 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -87,7 +87,16 @@ hash_net4_data_copy(struct hash_net4_elem *dst,
 static inline void
 hash_net4_data_flags(struct hash_net4_elem *dst, u32 flags)
 {
-	dst->nomatch = flags & IPSET_FLAG_NOMATCH;
+	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
+}
+
+static inline void
+hash_net4_data_reset_flags(struct hash_net4_elem *dst, u32 *flags)
+{
+	if (dst->nomatch) {
+		*flags = IPSET_FLAG_NOMATCH;
+		dst->nomatch = 0;
+	}
 }
 
 static inline int
@@ -308,7 +317,16 @@ hash_net6_data_copy(struct hash_net6_elem *dst,
 static inline void
 hash_net6_data_flags(struct hash_net6_elem *dst, u32 flags)
 {
-	dst->nomatch = flags & IPSET_FLAG_NOMATCH;
+	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
+}
+
+static inline void
+hash_net6_data_reset_flags(struct hash_net6_elem *dst, u32 *flags)
+{
+	if (dst->nomatch) {
+		*flags = IPSET_FLAG_NOMATCH;
+		dst->nomatch = 0;
+	}
 }
 
 static inline int
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 6ba985f..f2b0a3c 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -198,7 +198,16 @@ hash_netiface4_data_copy(struct hash_netiface4_elem *dst,
 static inline void
 hash_netiface4_data_flags(struct hash_netiface4_elem *dst, u32 flags)
 {
-	dst->nomatch = flags & IPSET_FLAG_NOMATCH;
+	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
+}
+
+static inline void
+hash_netiface4_data_reset_flags(struct hash_netiface4_elem *dst, u32 *flags)
+{
+	if (dst->nomatch) {
+		*flags = IPSET_FLAG_NOMATCH;
+		dst->nomatch = 0;
+	}
 }
 
 static inline int
@@ -494,7 +503,7 @@ hash_netiface6_data_copy(struct hash_netiface6_elem *dst,
 static inline void
 hash_netiface6_data_flags(struct hash_netiface6_elem *dst, u32 flags)
 {
-	dst->nomatch = flags & IPSET_FLAG_NOMATCH;
+	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
 }
 
 static inline int
@@ -504,6 +513,15 @@ hash_netiface6_data_match(const struct hash_netiface6_elem *elem)
 }
 
 static inline void
+hash_netiface6_data_reset_flags(struct hash_netiface6_elem *dst, u32 *flags)
+{
+	if (dst->nomatch) {
+		*flags = IPSET_FLAG_NOMATCH;
+		dst->nomatch = 0;
+	}
+}
+
+static inline void
 hash_netiface6_data_zero_out(struct hash_netiface6_elem *elem)
 {
 	elem->elem = 0;
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index af20c0c..349deb6 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -104,6 +104,15 @@ hash_netport4_data_flags(struct hash_netport4_elem *dst, u32 flags)
 	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
 }
 
+static inline void
+hash_netport4_data_reset_flags(struct hash_netport4_elem *dst, u32 *flags)
+{
+	if (dst->nomatch) {
+		*flags = IPSET_FLAG_NOMATCH;
+		dst->nomatch = 0;
+	}
+}
+
 static inline int
 hash_netport4_data_match(const struct hash_netport4_elem *elem)
 {
@@ -375,6 +384,15 @@ hash_netport6_data_flags(struct hash_netport6_elem *dst, u32 flags)
 	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
 }
 
+static inline void
+hash_netport6_data_reset_flags(struct hash_netport6_elem *dst, u32 *flags)
+{
+	if (dst->nomatch) {
+		*flags = IPSET_FLAG_NOMATCH;
+		dst->nomatch = 0;
+	}
+}
+
 static inline int
 hash_netport6_data_match(const struct hash_netport6_elem *elem)
 {
-- 
1.7.10.4

