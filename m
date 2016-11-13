From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 29/39] netfilter: ipset: Make NLEN compile time constant for hash types
Date: Sun, 13 Nov 2016 23:25:23 +0100
Message-ID: <1479075933-4491-30-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Hash types define HOST_MASK before inclusion of ip_set_hash_gen.h
and the only place where NLEN needed to be calculated at runtime
is *_create() method.

Ported from a patch proposed by Sergey Popovich <popovich_sergei@mail.ua>.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_gen.h | 51 ++++++++++++++++-------------------
 1 file changed, 23 insertions(+), 28 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 7999e4c556a5..6c88c20ae1d4 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -150,20 +150,18 @@ htable_bits(u32 hashsize)
 #define INIT_CIDR(cidr, host_mask)	\
 	DCIDR_PUT(((cidr) ? NCIDR_GET(cidr) : host_mask))
 
-#define SET_HOST_MASK(family)	(family == AF_INET ? 32 : 128)
-
 #ifdef IP_SET_HASH_WITH_NET0
-/* cidr from 0 to SET_HOST_MASK() value and c = cidr + 1 */
-#define NLEN(family)		(SET_HOST_MASK(family) + 1)
+/* cidr from 0 to HOST_MASK value and c = cidr + 1 */
+#define NLEN			(HOST_MASK + 1)
 #define CIDR_POS(c)		((c) - 1)
 #else
-/* cidr from 1 to SET_HOST_MASK() value and c = cidr + 1 */
-#define NLEN(family)		SET_HOST_MASK(family)
+/* cidr from 1 to HOST_MASK value and c = cidr + 1 */
+#define NLEN			HOST_MASK
 #define CIDR_POS(c)		((c) - 2)
 #endif
 
 #else
-#define NLEN(family)		0
+#define NLEN			0
 #endif /* IP_SET_HASH_WITH_NETS */
 
 #endif /* _IP_SET_HASH_GEN_H */
@@ -298,12 +296,12 @@ struct htype {
  * sized networks. cidr == real cidr + 1 to support /0.
  */
 static void
-mtype_add_cidr(struct htype *h, u8 cidr, u8 nets_length, u8 n)
+mtype_add_cidr(struct htype *h, u8 cidr, u8 n)
 {
 	int i, j;
 
 	/* Add in increasing prefix order, so larger cidr first */
-	for (i = 0, j = -1; i < nets_length && h->nets[i].cidr[n]; i++) {
+	for (i = 0, j = -1; i < NLEN && h->nets[i].cidr[n]; i++) {
 		if (j != -1) {
 			continue;
 		} else if (h->nets[i].cidr[n] < cidr) {
@@ -322,11 +320,11 @@ mtype_add_cidr(struct htype *h, u8 cidr, u8 nets_length, u8 n)
 }
 
 static void
-mtype_del_cidr(struct htype *h, u8 cidr, u8 nets_length, u8 n)
+mtype_del_cidr(struct htype *h, u8 cidr, u8 n)
 {
-	u8 i, j, net_end = nets_length - 1;
+	u8 i, j, net_end = NLEN - 1;
 
-	for (i = 0; i < nets_length; i++) {
+	for (i = 0; i < NLEN; i++) {
 		if (h->nets[i].cidr[n] != cidr)
 			continue;
 		h->nets[CIDR_POS(cidr)].nets[n]--;
@@ -342,13 +340,12 @@ mtype_del_cidr(struct htype *h, u8 cidr, u8 nets_length, u8 n)
 
 /* Calculate the actual memory size of the set data */
 static size_t
-mtype_ahash_memsize(const struct htype *h, const struct htable *t,
-		    u8 nets_length)
+mtype_ahash_memsize(const struct htype *h, const struct htable *t)
 {
 	size_t memsize = sizeof(*h) + sizeof(*t);
 
 #ifdef IP_SET_HASH_WITH_NETS
-	memsize += sizeof(struct net_prefixes) * nets_length;
+	memsize += sizeof(struct net_prefixes) * NLEN;
 #endif
 
 	return memsize;
@@ -389,7 +386,7 @@ mtype_flush(struct ip_set *set)
 		kfree_rcu(n, rcu);
 	}
 #ifdef IP_SET_HASH_WITH_NETS
-	memset(h->nets, 0, sizeof(struct net_prefixes) * NLEN(set->family));
+	memset(h->nets, 0, sizeof(struct net_prefixes) * NLEN);
 #endif
 	set->elements = 0;
 	set->ext_size = 0;
@@ -473,7 +470,7 @@ mtype_expire(struct ip_set *set, struct htype *h)
 	u32 i, j, d;
 	size_t dsize = set->dsize;
 #ifdef IP_SET_HASH_WITH_NETS
-	u8 k, nets_length = NLEN(set->family);
+	u8 k;
 #endif
 
 	t = ipset_dereference_protected(h->table, set);
@@ -496,7 +493,7 @@ mtype_expire(struct ip_set *set, struct htype *h)
 			for (k = 0; k < IPSET_NET_COUNT; k++)
 				mtype_del_cidr(h,
 					NCIDR_PUT(DCIDR_GET(data->cidr, k)),
-					nets_length, k);
+					k);
 #endif
 			ip_set_ext_destroy(set, data);
 			set->elements--;
@@ -776,7 +773,7 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 			for (i = 0; i < IPSET_NET_COUNT; i++)
 				mtype_del_cidr(h,
 					NCIDR_PUT(DCIDR_GET(data->cidr, i)),
-					NLEN(set->family), i);
+					i);
 #endif
 			ip_set_ext_destroy(set, data);
 			set->elements--;
@@ -812,8 +809,7 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	set->elements++;
 #ifdef IP_SET_HASH_WITH_NETS
 	for (i = 0; i < IPSET_NET_COUNT; i++)
-		mtype_add_cidr(h, NCIDR_PUT(DCIDR_GET(d->cidr, i)),
-			       NLEN(set->family), i);
+		mtype_add_cidr(h, NCIDR_PUT(DCIDR_GET(d->cidr, i)), i);
 #endif
 	memcpy(data, d, sizeof(struct mtype_elem));
 overwrite_extensions:
@@ -886,7 +882,7 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 #ifdef IP_SET_HASH_WITH_NETS
 		for (j = 0; j < IPSET_NET_COUNT; j++)
 			mtype_del_cidr(h, NCIDR_PUT(DCIDR_GET(d->cidr, j)),
-				       NLEN(set->family), j);
+				       j);
 #endif
 		ip_set_ext_destroy(set, data);
 
@@ -958,14 +954,13 @@ mtype_test_cidrs(struct ip_set *set, struct mtype_elem *d,
 	int i, j = 0;
 #endif
 	u32 key, multi = 0;
-	u8 nets_length = NLEN(set->family);
 
 	pr_debug("test by nets\n");
-	for (; j < nets_length && h->nets[j].cidr[0] && !multi; j++) {
+	for (; j < NLEN && h->nets[j].cidr[0] && !multi; j++) {
 #if IPSET_NET_COUNT == 2
 		mtype_data_reset_elem(d, &orig);
 		mtype_data_netmask(d, NCIDR_GET(h->nets[j].cidr[0]), false);
-		for (k = 0; k < nets_length && h->nets[k].cidr[1] && !multi;
+		for (k = 0; k < NLEN && h->nets[k].cidr[1] && !multi;
 		     k++) {
 			mtype_data_netmask(d, NCIDR_GET(h->nets[k].cidr[1]),
 					   true);
@@ -1022,7 +1017,7 @@ mtype_test(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	 * try all possible network sizes
 	 */
 	for (i = 0; i < IPSET_NET_COUNT; i++)
-		if (DCIDR_GET(d->cidr, i) != SET_HOST_MASK(set->family))
+		if (DCIDR_GET(d->cidr, i) != HOST_MASK)
 			break;
 	if (i == IPSET_NET_COUNT) {
 		ret = mtype_test_cidrs(set, d, ext, mext, flags);
@@ -1063,7 +1058,7 @@ mtype_head(struct ip_set *set, struct sk_buff *skb)
 
 	rcu_read_lock_bh();
 	t = rcu_dereference_bh_nfnl(h->table);
-	memsize = mtype_ahash_memsize(h, t, NLEN(set->family)) + set->ext_size;
+	memsize = mtype_ahash_memsize(h, t) + set->ext_size;
 	htable_bits = t->htable_bits;
 	rcu_read_unlock_bh();
 
@@ -1295,7 +1290,7 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
 
 	hsize = sizeof(*h);
 #ifdef IP_SET_HASH_WITH_NETS
-	hsize += sizeof(struct net_prefixes) * NLEN(set->family);
+	hsize += sizeof(struct net_prefixes) * NLEN;
 #endif
 	h = kzalloc(hsize, GFP_KERNEL);
 	if (!h)
-- 
2.1.4

