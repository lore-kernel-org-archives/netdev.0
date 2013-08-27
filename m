From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 11/11] openvswitch: optimize flow compare and mask functions
Date: Tue, 27 Aug 2013 13:20:48 -0700
Message-ID: <1377634848-34327-12-git-send-email-jesse@nicira.com>
References: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Andy Zhou <azhou@nicira.com>, Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:50411 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753462Ab3H0UVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:21:22 -0400
Received: by mail-pd0-f179.google.com with SMTP id v10so5366201pde.10
        for <netdev@vger.kernel.org>; Tue, 27 Aug 2013 13:21:21 -0700 (PDT)
In-Reply-To: <1377634848-34327-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

Make sure the sw_flow_key structure and valid mask boundaries are always
machine word aligned. Optimize the flow compare and mask operations
using machine word size operations. This patch improves throughput on
average by 15% when CPU is the bottleneck of forwarding packets.

This patch is inspired by ideas and code from a patch submitted by Peter
Klausler titled "replace memcmp() with specialized comparator".
However, The original patch only optimizes for architectures
support unaligned machine word access. This patch optimizes for all
architectures.

Signed-off-by: Andy Zhou <azhou@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/flow.c | 64 +++++++++++++++++++++++++++++++++-----------------
 net/openvswitch/flow.h | 19 +--------------
 2 files changed, 44 insertions(+), 39 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 80bcb96..ad1aeeb 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -54,8 +54,8 @@ static void update_range__(struct sw_flow_match *match,
 			  size_t offset, size_t size, bool is_mask)
 {
 	struct sw_flow_key_range *range = NULL;
-	size_t start = offset;
-	size_t end = offset + size;
+	size_t start = rounddown(offset, sizeof(long));
+	size_t end = roundup(offset + size, sizeof(long));
 
 	if (!is_mask)
 		range = &match->range;
@@ -102,6 +102,11 @@ static void update_range__(struct sw_flow_match *match,
 		}                                                           \
 	} while (0)
 
+static u16 range_n_bytes(const struct sw_flow_key_range *range)
+{
+	return range->end - range->start;
+}
+
 void ovs_match_init(struct sw_flow_match *match,
 		    struct sw_flow_key *key,
 		    struct sw_flow_mask *mask)
@@ -370,16 +375,17 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
 void ovs_flow_key_mask(struct sw_flow_key *dst, const struct sw_flow_key *src,
 		       const struct sw_flow_mask *mask)
 {
-	u8 *m = (u8 *)&mask->key + mask->range.start;
-	u8 *s = (u8 *)src + mask->range.start;
-	u8 *d = (u8 *)dst + mask->range.start;
+	const long *m = (long *)((u8 *)&mask->key + mask->range.start);
+	const long *s = (long *)((u8 *)src + mask->range.start);
+	long *d = (long *)((u8 *)dst + mask->range.start);
 	int i;
 
-	memset(dst, 0, sizeof(*dst));
-	for (i = 0; i < ovs_sw_flow_mask_size_roundup(mask); i++) {
-		*d = *s & *m;
-		d++, s++, m++;
-	}
+	/* The memory outside of the 'mask->range' are not set since
+	 * further operations on 'dst' only uses contents within
+	 * 'mask->range'.
+	 */
+	for (i = 0; i < range_n_bytes(&mask->range); i += sizeof(long))
+		*d++ = *s++ & *m++;
 }
 
 #define TCP_FLAGS_OFFSET 13
@@ -1000,8 +1006,13 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 static u32 ovs_flow_hash(const struct sw_flow_key *key, int key_start,
 			 int key_end)
 {
-	return jhash2((u32 *)((u8 *)key + key_start),
-		      DIV_ROUND_UP(key_end - key_start, sizeof(u32)), 0);
+	u32 *hash_key = (u32 *)((u8 *)key + key_start);
+	int hash_u32s = (key_end - key_start) >> 2;
+
+	/* Make sure number of hash bytes are multiple of u32. */
+	BUILD_BUG_ON(sizeof(long) % sizeof(u32));
+
+	return jhash2(hash_key, hash_u32s, 0);
 }
 
 static int flow_key_start(const struct sw_flow_key *key)
@@ -1009,17 +1020,25 @@ static int flow_key_start(const struct sw_flow_key *key)
 	if (key->tun_key.ipv4_dst)
 		return 0;
 	else
-		return offsetof(struct sw_flow_key, phy);
+		return rounddown(offsetof(struct sw_flow_key, phy),
+					  sizeof(long));
 }
 
 static bool __cmp_key(const struct sw_flow_key *key1,
 		const struct sw_flow_key *key2,  int key_start, int key_end)
 {
-	return !memcmp((u8 *)key1 + key_start,
-			(u8 *)key2 + key_start, (key_end - key_start));
+	const long *cp1 = (long *)((u8 *)key1 + key_start);
+	const long *cp2 = (long *)((u8 *)key2 + key_start);
+	long diffs = 0;
+	int i;
+
+	for (i = key_start; i < key_end;  i += sizeof(long))
+		diffs |= *cp1++ ^ *cp2++;
+
+	return diffs == 0;
 }
 
-static bool __flow_cmp_key(const struct sw_flow *flow,
+static bool __flow_cmp_masked_key(const struct sw_flow *flow,
 		const struct sw_flow_key *key, int key_start, int key_end)
 {
 	return __cmp_key(&flow->key, key, key_start, key_end);
@@ -1056,7 +1075,7 @@ struct sw_flow *ovs_flow_lookup_unmasked_key(struct flow_table *table,
 }
 
 static struct sw_flow *ovs_masked_flow_lookup(struct flow_table *table,
-				    const struct sw_flow_key *flow_key,
+				    const struct sw_flow_key *unmasked,
 				    struct sw_flow_mask *mask)
 {
 	struct sw_flow *flow;
@@ -1066,12 +1085,13 @@ static struct sw_flow *ovs_masked_flow_lookup(struct flow_table *table,
 	u32 hash;
 	struct sw_flow_key masked_key;
 
-	ovs_flow_key_mask(&masked_key, flow_key, mask);
+	ovs_flow_key_mask(&masked_key, unmasked, mask);
 	hash = ovs_flow_hash(&masked_key, key_start, key_end);
 	head = find_bucket(table, hash);
 	hlist_for_each_entry_rcu(flow, head, hash_node[table->node_ver]) {
 		if (flow->mask == mask &&
-		    __flow_cmp_key(flow, &masked_key, key_start, key_end))
+		    __flow_cmp_masked_key(flow, &masked_key,
+					  key_start, key_end))
 			return flow;
 	}
 	return NULL;
@@ -1961,6 +1981,8 @@ nla_put_failure:
  * Returns zero if successful or a negative error code. */
 int ovs_flow_init(void)
 {
+	BUILD_BUG_ON(sizeof(struct sw_flow_key) % sizeof(long));
+
 	flow_cache = kmem_cache_create("sw_flow", sizeof(struct sw_flow), 0,
 					0, NULL);
 	if (flow_cache == NULL)
@@ -2016,7 +2038,7 @@ static bool ovs_sw_flow_mask_equal(const struct sw_flow_mask *a,
 
 	return  (a->range.end == b->range.end)
 		&& (a->range.start == b->range.start)
-		&& (memcmp(a_, b_, ovs_sw_flow_mask_actual_size(a)) == 0);
+		&& (memcmp(a_, b_, range_n_bytes(&a->range)) == 0);
 }
 
 struct sw_flow_mask *ovs_sw_flow_mask_find(const struct flow_table *tbl,
@@ -2053,5 +2075,5 @@ static void ovs_sw_flow_mask_set(struct sw_flow_mask *mask,
 	u8 *m = (u8 *)&mask->key + range->start;
 
 	mask->range = *range;
-	memset(m, val, ovs_sw_flow_mask_size_roundup(mask));
+	memset(m, val, range_n_bytes(range));
 }
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index e793051..b65f885 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -125,7 +125,7 @@ struct sw_flow_key {
 			} nd;
 		} ipv6;
 	};
-};
+} __aligned(__alignof__(long));
 
 struct sw_flow {
 	struct rcu_head rcu;
@@ -149,11 +149,6 @@ struct sw_flow_key_range {
 	size_t end;
 };
 
-static inline u16 ovs_sw_flow_key_range_actual_size(const struct sw_flow_key_range *range)
-{
-	return range->end - range->start;
-}
-
 struct sw_flow_match {
 	struct sw_flow_key *key;
 	struct sw_flow_key_range range;
@@ -253,18 +248,6 @@ struct sw_flow_mask {
 	struct sw_flow_key key;
 };
 
-static inline u16
-ovs_sw_flow_mask_actual_size(const struct sw_flow_mask *mask)
-{
-	return ovs_sw_flow_key_range_actual_size(&mask->range);
-}
-
-static inline u16
-ovs_sw_flow_mask_size_roundup(const struct sw_flow_mask *mask)
-{
-	return roundup(ovs_sw_flow_mask_actual_size(mask), sizeof(u32));
-}
-
 struct sw_flow_mask *ovs_sw_flow_mask_alloc(void);
 void ovs_sw_flow_mask_add_ref(struct sw_flow_mask *);
 void ovs_sw_flow_mask_del_ref(struct sw_flow_mask *, bool deferred);
-- 
1.8.1.2
