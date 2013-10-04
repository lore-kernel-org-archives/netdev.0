From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/33] netfilter: ipset: Prepare ipset to support multiple networks for hash types
Date: Fri,  4 Oct 2013 10:32:58 +0200
Message-ID: <1380875598-5250-14-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55662 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754414Ab3JDIeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Oct 2013 04:34:13 -0400
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

In order to support hash:net,net, hash:net,port,net etc. types,
arrays are introduced for the book-keeping of existing cidr sizes
and network numbers in a set.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h      |    2 +
 net/netfilter/ipset/ip_set_hash_gen.h       |   78 ++++++++++++++-------------
 net/netfilter/ipset/ip_set_hash_ipportnet.c |    4 +-
 net/netfilter/ipset/ip_set_hash_net.c       |    4 +-
 net/netfilter/ipset/ip_set_hash_netiface.c  |    4 +-
 net/netfilter/ipset/ip_set_hash_netport.c   |    4 +-
 6 files changed, 50 insertions(+), 46 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 69aa604..56012a3 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -398,6 +398,8 @@ bitmap_bytes(u32 a, u32 b)
 	{ .bytes = ULLONG_MAX, .packets = ULLONG_MAX,	\
 	  .timeout = (map)->timeout }
 
+#define IP_SET_INIT_CIDR(a, b) ((a) ? (a) : (b))
+
 #define IPSET_CONCAT(a, b)		a##b
 #define IPSET_TOKEN(a, b)		IPSET_CONCAT(a, b)
 
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 68b9cce..a833240 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -77,10 +77,14 @@ struct htable {
 
 #define hbucket(h, i)		(&((h)->bucket[i]))
 
+#ifndef IPSET_NET_COUNT
+#define IPSET_NET_COUNT		1
+#endif
+
 /* Book-keeping of the prefixes added to the set */
 struct net_prefixes {
-	u8 cidr;		/* the different cidr values in the set */
-	u32 nets;		/* number of elements per cidr */
+	u32 nets[IPSET_NET_COUNT]; /* number of elements per cidr */
+	u8 cidr[IPSET_NET_COUNT];  /* the different cidr values in the set */
 };
 
 /* Compute the hash table size */
@@ -165,13 +169,13 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 #define SET_HOST_MASK(family)	(family == AF_INET ? 32 : 128)
 
 #ifdef IP_SET_HASH_WITH_MULTI
-#define NETS_LENGTH(family)	(SET_HOST_MASK(family) + 1)
+#define NLEN(family)		(SET_HOST_MASK(family) + 1)
 #else
-#define NETS_LENGTH(family)	SET_HOST_MASK(family)
+#define NLEN(family)		SET_HOST_MASK(family)
 #endif
 
 #else
-#define NETS_LENGTH(family)	0
+#define NLEN(family)		0
 #endif /* IP_SET_HASH_WITH_NETS */
 
 #define ext_timeout(e, h)	\
@@ -296,49 +300,49 @@ struct htype {
 /* Network cidr size book keeping when the hash stores different
  * sized networks */
 static void
-mtype_add_cidr(struct htype *h, u8 cidr, u8 nets_length)
+mtype_add_cidr(struct htype *h, u8 cidr, u8 nets_length, u8 n)
 {
 	int i, j;
 
 	/* Add in increasing prefix order, so larger cidr first */
-	for (i = 0, j = -1; i < nets_length && h->nets[i].nets; i++) {
+	for (i = 0, j = -1; i < nets_length && h->nets[i].nets[n]; i++) {
 		if (j != -1)
 			continue;
-		else if (h->nets[i].cidr < cidr)
+		else if (h->nets[i].cidr[n] < cidr)
 			j = i;
-		else if (h->nets[i].cidr == cidr) {
-			h->nets[i].nets++;
+		else if (h->nets[i].cidr[n] == cidr) {
+			h->nets[i].nets[n]++;
 			return;
 		}
 	}
 	if (j != -1) {
 		for (; i > j; i--) {
-			h->nets[i].cidr = h->nets[i - 1].cidr;
-			h->nets[i].nets = h->nets[i - 1].nets;
+			h->nets[i].cidr[n] = h->nets[i - 1].cidr[n];
+			h->nets[i].nets[n] = h->nets[i - 1].nets[n];
 		}
 	}
-	h->nets[i].cidr = cidr;
-	h->nets[i].nets = 1;
+	h->nets[i].cidr[n] = cidr;
+	h->nets[i].nets[n] = 1;
 }
 
 static void
-mtype_del_cidr(struct htype *h, u8 cidr, u8 nets_length)
+mtype_del_cidr(struct htype *h, u8 cidr, u8 nets_length, u8 n)
 {
 	u8 i, j, net_end = nets_length - 1;
 
 	for (i = 0; i < nets_length; i++) {
-	        if (h->nets[i].cidr != cidr)
+	        if (h->nets[i].cidr[n] != cidr)
 	                continue;
-                if (h->nets[i].nets > 1 || i == net_end ||
-                    h->nets[i + 1].nets == 0) {
-                        h->nets[i].nets--;
+                if (h->nets[i].nets[n] > 1 || i == net_end ||
+                    h->nets[i + 1].nets[n] == 0) {
+                        h->nets[i].nets[n]--;
                         return;
                 }
-                for (j = i; j < net_end && h->nets[j].nets; j++) {
-		        h->nets[j].cidr = h->nets[j + 1].cidr;
-		        h->nets[j].nets = h->nets[j + 1].nets;
+                for (j = i; j < net_end && h->nets[j].nets[n]; j++) {
+		        h->nets[j].cidr[n] = h->nets[j + 1].cidr[n];
+		        h->nets[j].nets[n] = h->nets[j + 1].nets[n];
                 }
-                h->nets[j].nets = 0;
+                h->nets[j].nets[n] = 0;
                 return;
 	}
 }
@@ -382,8 +386,7 @@ mtype_flush(struct ip_set *set)
 		}
 	}
 #ifdef IP_SET_HASH_WITH_NETS
-	memset(h->nets, 0, sizeof(struct net_prefixes)
-			   * NETS_LENGTH(set->family));
+	memset(h->nets, 0, sizeof(struct net_prefixes) * NLEN(set->family));
 #endif
 	h->elements = 0;
 }
@@ -459,7 +462,7 @@ mtype_expire(struct htype *h, u8 nets_length, size_t dsize)
 				pr_debug("expired %u/%u\n", i, j);
 #ifdef IP_SET_HASH_WITH_NETS
 				mtype_del_cidr(h, CIDR(data->cidr),
-					       nets_length);
+					       nets_length, 0);
 #endif
 				if (j != n->pos - 1)
 					/* Not last one */
@@ -494,7 +497,7 @@ mtype_gc(unsigned long ul_set)
 
 	pr_debug("called\n");
 	write_lock_bh(&set->lock);
-	mtype_expire(h, NETS_LENGTH(set->family), h->dsize);
+	mtype_expire(h, NLEN(set->family), h->dsize);
 	write_unlock_bh(&set->lock);
 
 	h->gc.expires = jiffies + IPSET_GC_PERIOD(h->timeout) * HZ;
@@ -523,8 +526,7 @@ mtype_resize(struct ip_set *set, bool retried)
 	if (SET_WITH_TIMEOUT(set) && !retried) {
 		i = h->elements;
 		write_lock_bh(&set->lock);
-		mtype_expire(set->data, NETS_LENGTH(set->family),
-			     h->dsize);
+		mtype_expire(set->data, NLEN(set->family), h->dsize);
 		write_unlock_bh(&set->lock);
 		if (h->elements < i)
 			return 0;
@@ -607,7 +609,7 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 
 	if (SET_WITH_TIMEOUT(set) && h->elements >= h->maxelem)
 		/* FIXME: when set is full, we slow down here */
-		mtype_expire(h, NETS_LENGTH(set->family), h->dsize);
+		mtype_expire(h, NLEN(set->family), h->dsize);
 
 	if (h->elements >= h->maxelem) {
 		if (net_ratelimit())
@@ -645,8 +647,8 @@ reuse_slot:
 		/* Fill out reused slot */
 		data = ahash_data(n, j, h->dsize);
 #ifdef IP_SET_HASH_WITH_NETS
-		mtype_del_cidr(h, CIDR(data->cidr), NETS_LENGTH(set->family));
-		mtype_add_cidr(h, CIDR(d->cidr), NETS_LENGTH(set->family));
+		mtype_del_cidr(h, CIDR(data->cidr), NLEN(set->family), 0);
+		mtype_add_cidr(h, CIDR(d->cidr), NLEN(set->family), 0);
 #endif
 	} else {
 		/* Use/create a new slot */
@@ -659,7 +661,7 @@ reuse_slot:
 		}
 		data = ahash_data(n, n->pos++, h->dsize);
 #ifdef IP_SET_HASH_WITH_NETS
-		mtype_add_cidr(h, CIDR(d->cidr), NETS_LENGTH(set->family));
+		mtype_add_cidr(h, CIDR(d->cidr), NLEN(set->family), 0);
 #endif
 		h->elements++;
 	}
@@ -711,7 +713,7 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		n->pos--;
 		h->elements--;
 #ifdef IP_SET_HASH_WITH_NETS
-		mtype_del_cidr(h, CIDR(d->cidr), NETS_LENGTH(set->family));
+		mtype_del_cidr(h, CIDR(d->cidr), NLEN(set->family), 0);
 #endif
 		if (n->pos + AHASH_INIT_SIZE < n->size) {
 			void *tmp = kzalloc((n->size - AHASH_INIT_SIZE)
@@ -760,11 +762,11 @@ mtype_test_cidrs(struct ip_set *set, struct mtype_elem *d,
 	struct mtype_elem *data;
 	int i, j = 0;
 	u32 key, multi = 0;
-	u8 nets_length = NETS_LENGTH(set->family);
+	u8 nets_length = NLEN(set->family);
 
 	pr_debug("test by nets\n");
-	for (; j < nets_length && h->nets[j].nets && !multi; j++) {
-		mtype_data_netmask(d, h->nets[j].cidr);
+	for (; j < nets_length && h->nets[j].nets[0] && !multi; j++) {
+		mtype_data_netmask(d, h->nets[j].cidr[0]);
 		key = HKEY(d, h->initval, t->htable_bits);
 		n = hbucket(t, key);
 		for (i = 0; i < n->pos; i++) {
@@ -839,7 +841,7 @@ mtype_head(struct ip_set *set, struct sk_buff *skb)
 	size_t memsize;
 
 	t = rcu_dereference_bh_nfnl(h->table);
-	memsize = mtype_ahash_memsize(h, t, NETS_LENGTH(set->family));
+	memsize = mtype_ahash_memsize(h, t, NLEN(set->family));
 
 	nested = ipset_nest_start(skb, IPSET_ATTR_DATA);
 	if (!nested)
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index f111558..6ce5a8e 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -170,7 +170,7 @@ hash_ipportnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	const struct hash_ipportnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportnet4_elem e = {
-		.cidr = h->nets[0].cidr ? h->nets[0].cidr - 1 : HOST_MASK - 1
+		.cidr = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK) - 1,
 	};
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 
@@ -454,7 +454,7 @@ hash_ipportnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	const struct hash_ipportnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportnet6_elem e = {
-		.cidr = h->nets[0].cidr ? h->nets[0].cidr - 1 : HOST_MASK - 1
+		.cidr = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK) - 1,
 	};
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 0a64dad..ec1c7dc 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -143,7 +143,7 @@ hash_net4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	const struct hash_net *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_net4_elem e = {
-		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK
+		.cidr = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
 	};
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 
@@ -338,7 +338,7 @@ hash_net6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	const struct hash_net *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_net6_elem e = {
-		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK
+		.cidr = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
 	};
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 846371b..814b4e3 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -265,7 +265,7 @@ hash_netiface4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	struct hash_netiface *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netiface4_elem e = {
-		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK,
+		.cidr = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
 		.elem = 1,
 	};
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
@@ -534,7 +534,7 @@ hash_netiface6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	struct hash_netiface *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netiface6_elem e = {
-		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK,
+		.cidr = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
 		.elem = 1,
 	};
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index d98a685..3bd923d 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -162,7 +162,7 @@ hash_netport4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	const struct hash_netport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netport4_elem e = {
-		.cidr = h->nets[0].cidr ? h->nets[0].cidr - 1 : HOST_MASK - 1
+		.cidr = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK) - 1,
 	};
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 
@@ -407,7 +407,7 @@ hash_netport6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	const struct hash_netport *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netport6_elem e = {
-		.cidr = h->nets[0].cidr ? h->nets[0].cidr - 1 : HOST_MASK - 1,
+		.cidr = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK) - 1,
 	};
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, h);
 
-- 
1.7.10.4
