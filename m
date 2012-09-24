From: pablo@netfilter.org
Subject: [PATCH 08/16] netfilter: ipset: Rewrite cidr book keeping to handle /0
Date: Mon, 24 Sep 2012 21:19:20 +0200
Message-ID: <1348514369-3272-9-git-send-email-pablo@netfilter.org>
References: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set_ahash.h |  104 ++++++++++++++------------
 1 file changed, 55 insertions(+), 49 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set_ahash.h b/include/linux/netfilter/ipset/ip_set_ahash.h
index b114d35..495acdf 100644
--- a/include/linux/netfilter/ipset/ip_set_ahash.h
+++ b/include/linux/netfilter/ipset/ip_set_ahash.h
@@ -137,50 +137,59 @@ htable_bits(u32 hashsize)
 #endif
 
 #define SET_HOST_MASK(family)	(family == AF_INET ? 32 : 128)
+#ifdef IP_SET_HASH_WITH_MULTI
+#define NETS_LENGTH(family)	(SET_HOST_MASK(family) + 1)
+#else
+#define NETS_LENGTH(family)	SET_HOST_MASK(family)
+#endif
 
 /* Network cidr size book keeping when the hash stores different
  * sized networks */
 static void
-add_cidr(struct ip_set_hash *h, u8 cidr, u8 host_mask)
+add_cidr(struct ip_set_hash *h, u8 cidr, u8 nets_length)
 {
-	u8 i;
-
-	++h->nets[cidr-1].nets;
-
-	pr_debug("add_cidr added %u: %u\n", cidr, h->nets[cidr-1].nets);
+	int i, j;
 
-	if (h->nets[cidr-1].nets > 1)
-		return;
-
-	/* New cidr size */
-	for (i = 0; i < host_mask && h->nets[i].cidr; i++) {
-		/* Add in increasing prefix order, so larger cidr first */
-		if (h->nets[i].cidr < cidr)
-			swap(h->nets[i].cidr, cidr);
+	/* Add in increasing prefix order, so larger cidr first */
+	for (i = 0, j = -1; i < nets_length && h->nets[i].nets; i++) {
+		if (j != -1)
+			continue;
+		else if (h->nets[i].cidr < cidr)
+			j = i;
+		else if (h->nets[i].cidr == cidr) {
+			h->nets[i].nets++;
+			return;
+		}
+	}
+	if (j != -1) {
+		for (; i > j; i--) {
+			h->nets[i].cidr = h->nets[i - 1].cidr;
+			h->nets[i].nets = h->nets[i - 1].nets;
+		}
 	}
-	if (i < host_mask)
-		h->nets[i].cidr = cidr;
+	h->nets[i].cidr = cidr;
+	h->nets[i].nets = 1;
 }
 
 static void
-del_cidr(struct ip_set_hash *h, u8 cidr, u8 host_mask)
+del_cidr(struct ip_set_hash *h, u8 cidr, u8 nets_length)
 {
-	u8 i;
-
-	--h->nets[cidr-1].nets;
+	u8 i, j;
 
-	pr_debug("del_cidr deleted %u: %u\n", cidr, h->nets[cidr-1].nets);
+	for (i = 0; i < nets_length - 1 && h->nets[i].cidr != cidr; i++)
+		;
+	h->nets[i].nets--;
 
-	if (h->nets[cidr-1].nets != 0)
+	if (h->nets[i].nets != 0)
 		return;
 
-	/* All entries with this cidr size deleted, so cleanup h->cidr[] */
-	for (i = 0; i < host_mask - 1 && h->nets[i].cidr; i++) {
-		if (h->nets[i].cidr == cidr)
-			h->nets[i].cidr = cidr = h->nets[i+1].cidr;
+	for (j = i; j < nets_length - 1 && h->nets[j].nets; j++) {
+		h->nets[j].cidr = h->nets[j + 1].cidr;
+		h->nets[j].nets = h->nets[j + 1].nets;
 	}
-	h->nets[i - 1].cidr = 0;
 }
+#else
+#define NETS_LENGTH(family)		0
 #endif
 
 /* Destroy the hashtable part of the set */
@@ -202,14 +211,14 @@ ahash_destroy(struct htable *t)
 
 /* Calculate the actual memory size of the set data */
 static size_t
-ahash_memsize(const struct ip_set_hash *h, size_t dsize, u8 host_mask)
+ahash_memsize(const struct ip_set_hash *h, size_t dsize, u8 nets_length)
 {
 	u32 i;
 	struct htable *t = h->table;
 	size_t memsize = sizeof(*h)
 			 + sizeof(*t)
 #ifdef IP_SET_HASH_WITH_NETS
-			 + sizeof(struct ip_set_hash_nets) * host_mask
+			 + sizeof(struct ip_set_hash_nets) * nets_length
 #endif
 			 + jhash_size(t->htable_bits) * sizeof(struct hbucket);
 
@@ -238,7 +247,7 @@ ip_set_hash_flush(struct ip_set *set)
 	}
 #ifdef IP_SET_HASH_WITH_NETS
 	memset(h->nets, 0, sizeof(struct ip_set_hash_nets)
-			   * SET_HOST_MASK(set->family));
+			   * NETS_LENGTH(set->family));
 #endif
 	h->elements = 0;
 }
@@ -271,9 +280,6 @@ ip_set_hash_destroy(struct ip_set *set)
 (jhash2((u32 *)(data), HKEY_DATALEN/sizeof(u32), initval)	\
 	& jhash_mask(htable_bits))
 
-#define CONCAT(a, b, c)		a##b##c
-#define TOKEN(a, b, c)		CONCAT(a, b, c)
-
 /* Type/family dependent function prototypes */
 
 #define type_pf_data_equal	TOKEN(TYPE, PF, _data_equal)
@@ -478,7 +484,7 @@ type_pf_add(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	}
 
 #ifdef IP_SET_HASH_WITH_NETS
-	add_cidr(h, CIDR(d->cidr), HOST_MASK);
+	add_cidr(h, CIDR(d->cidr), NETS_LENGTH(set->family));
 #endif
 	h->elements++;
 out:
@@ -513,7 +519,7 @@ type_pf_del(struct ip_set *set, void *value, u32 timeout, u32 flags)
 		n->pos--;
 		h->elements--;
 #ifdef IP_SET_HASH_WITH_NETS
-		del_cidr(h, CIDR(d->cidr), HOST_MASK);
+		del_cidr(h, CIDR(d->cidr), NETS_LENGTH(set->family));
 #endif
 		if (n->pos + AHASH_INIT_SIZE < n->size) {
 			void *tmp = kzalloc((n->size - AHASH_INIT_SIZE)
@@ -546,10 +552,10 @@ type_pf_test_cidrs(struct ip_set *set, struct type_pf_elem *d, u32 timeout)
 	const struct type_pf_elem *data;
 	int i, j = 0;
 	u32 key, multi = 0;
-	u8 host_mask = SET_HOST_MASK(set->family);
+	u8 nets_length = NETS_LENGTH(set->family);
 
 	pr_debug("test by nets\n");
-	for (; j < host_mask && h->nets[j].cidr && !multi; j++) {
+	for (; j < nets_length && h->nets[j].nets && !multi; j++) {
 		type_pf_data_netmask(d, h->nets[j].cidr);
 		key = HKEY(d, h->initval, t->htable_bits);
 		n = hbucket(t, key);
@@ -604,7 +610,7 @@ type_pf_head(struct ip_set *set, struct sk_buff *skb)
 	memsize = ahash_memsize(h, with_timeout(h->timeout)
 					? sizeof(struct type_pf_telem)
 					: sizeof(struct type_pf_elem),
-				set->family == AF_INET ? 32 : 128);
+				NETS_LENGTH(set->family));
 	read_unlock_bh(&set->lock);
 
 	nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
@@ -783,7 +789,7 @@ type_pf_elem_tadd(struct hbucket *n, const struct type_pf_elem *value,
 
 /* Delete expired elements from the hashtable */
 static void
-type_pf_expire(struct ip_set_hash *h)
+type_pf_expire(struct ip_set_hash *h, u8 nets_length)
 {
 	struct htable *t = h->table;
 	struct hbucket *n;
@@ -798,7 +804,7 @@ type_pf_expire(struct ip_set_hash *h)
 			if (type_pf_data_expired(data)) {
 				pr_debug("expired %u/%u\n", i, j);
 #ifdef IP_SET_HASH_WITH_NETS
-				del_cidr(h, CIDR(data->cidr), HOST_MASK);
+				del_cidr(h, CIDR(data->cidr), nets_length);
 #endif
 				if (j != n->pos - 1)
 					/* Not last one */
@@ -839,7 +845,7 @@ type_pf_tresize(struct ip_set *set, bool retried)
 	if (!retried) {
 		i = h->elements;
 		write_lock_bh(&set->lock);
-		type_pf_expire(set->data);
+		type_pf_expire(set->data, NETS_LENGTH(set->family));
 		write_unlock_bh(&set->lock);
 		if (h->elements <  i)
 			return 0;
@@ -904,7 +910,7 @@ type_pf_tadd(struct ip_set *set, void *value, u32 timeout, u32 flags)
 
 	if (h->elements >= h->maxelem)
 		/* FIXME: when set is full, we slow down here */
-		type_pf_expire(h);
+		type_pf_expire(h, NETS_LENGTH(set->family));
 	if (h->elements >= h->maxelem) {
 		if (net_ratelimit())
 			pr_warning("Set %s is full, maxelem %u reached\n",
@@ -933,8 +939,8 @@ type_pf_tadd(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	if (j != AHASH_MAX(h) + 1) {
 		data = ahash_tdata(n, j);
 #ifdef IP_SET_HASH_WITH_NETS
-		del_cidr(h, CIDR(data->cidr), HOST_MASK);
-		add_cidr(h, CIDR(d->cidr), HOST_MASK);
+		del_cidr(h, CIDR(data->cidr), NETS_LENGTH(set->family));
+		add_cidr(h, CIDR(d->cidr), NETS_LENGTH(set->family));
 #endif
 		type_pf_data_copy(data, d);
 		type_pf_data_timeout_set(data, timeout);
@@ -952,7 +958,7 @@ type_pf_tadd(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	}
 
 #ifdef IP_SET_HASH_WITH_NETS
-	add_cidr(h, CIDR(d->cidr), HOST_MASK);
+	add_cidr(h, CIDR(d->cidr), NETS_LENGTH(set->family));
 #endif
 	h->elements++;
 out:
@@ -986,7 +992,7 @@ type_pf_tdel(struct ip_set *set, void *value, u32 timeout, u32 flags)
 		n->pos--;
 		h->elements--;
 #ifdef IP_SET_HASH_WITH_NETS
-		del_cidr(h, CIDR(d->cidr), HOST_MASK);
+		del_cidr(h, CIDR(d->cidr), NETS_LENGTH(set->family));
 #endif
 		if (n->pos + AHASH_INIT_SIZE < n->size) {
 			void *tmp = kzalloc((n->size - AHASH_INIT_SIZE)
@@ -1016,9 +1022,9 @@ type_pf_ttest_cidrs(struct ip_set *set, struct type_pf_elem *d, u32 timeout)
 	struct hbucket *n;
 	int i, j = 0;
 	u32 key, multi = 0;
-	u8 host_mask = SET_HOST_MASK(set->family);
+	u8 nets_length = NETS_LENGTH(set->family);
 
-	for (; j < host_mask && h->nets[j].cidr && !multi; j++) {
+	for (; j < nets_length && h->nets[j].nets && !multi; j++) {
 		type_pf_data_netmask(d, h->nets[j].cidr);
 		key = HKEY(d, h->initval, t->htable_bits);
 		n = hbucket(t, key);
@@ -1147,7 +1153,7 @@ type_pf_gc(unsigned long ul_set)
 
 	pr_debug("called\n");
 	write_lock_bh(&set->lock);
-	type_pf_expire(h);
+	type_pf_expire(h, NETS_LENGTH(set->family));
 	write_unlock_bh(&set->lock);
 
 	h->gc.expires = jiffies + IPSET_GC_PERIOD(h->timeout) * HZ;
-- 
1.7.10.4

