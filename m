From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/12] netfilter: ipset: Simplify cidr handling for hash:*net* types
Date: Wed,  3 Dec 2014 13:55:40 +0100
Message-ID: <1417611342-25257-11-git-send-email-pablo@netfilter.org>
References: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_gen.h |   56 ++++++++++++++++-----------------
 1 file changed, 28 insertions(+), 28 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index 9428fa5..8ef9135 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -147,11 +147,17 @@ hbucket_elem_add(struct hbucket *n, u8 ahash_max, size_t dsize)
 #else
 #define __CIDR(cidr, i)		(cidr)
 #endif
+
+/* cidr + 1 is stored in net_prefixes to support /0 */
+#define SCIDR(cidr, i)		(__CIDR(cidr, i) + 1)
+
 #ifdef IP_SET_HASH_WITH_NETS_PACKED
-/* When cidr is packed with nomatch, cidr - 1 is stored in the entry */
-#define CIDR(cidr, i)		(__CIDR(cidr, i) + 1)
+/* When cidr is packed with nomatch, cidr - 1 is stored in the data entry */
+#define GCIDR(cidr, i)		(__CIDR(cidr, i) + 1)
+#define NCIDR(cidr)		(cidr)
 #else
-#define CIDR(cidr, i)		(__CIDR(cidr, i))
+#define GCIDR(cidr, i)		(__CIDR(cidr, i))
+#define NCIDR(cidr)		(cidr - 1)
 #endif
 
 #define SET_HOST_MASK(family)	(family == AF_INET ? 32 : 128)
@@ -292,24 +298,22 @@ mtype_add_cidr(struct htype *h, u8 cidr, u8 nets_length, u8 n)
 	int i, j;
 
 	/* Add in increasing prefix order, so larger cidr first */
-	for (i = 0, j = -1; i < nets_length && h->nets[i].nets[n]; i++) {
+	for (i = 0, j = -1; i < nets_length && h->nets[i].cidr[n]; i++) {
 		if (j != -1)
 			continue;
 		else if (h->nets[i].cidr[n] < cidr)
 			j = i;
 		else if (h->nets[i].cidr[n] == cidr) {
-			h->nets[i].nets[n]++;
+			h->nets[cidr - 1].nets[n]++;
 			return;
 		}
 	}
 	if (j != -1) {
-		for (; i > j; i--) {
+		for (; i > j; i--)
 			h->nets[i].cidr[n] = h->nets[i - 1].cidr[n];
-			h->nets[i].nets[n] = h->nets[i - 1].nets[n];
-		}
 	}
 	h->nets[i].cidr[n] = cidr;
-	h->nets[i].nets[n] = 1;
+	h->nets[cidr - 1].nets[n] = 1;
 }
 
 static void
@@ -320,16 +324,12 @@ mtype_del_cidr(struct htype *h, u8 cidr, u8 nets_length, u8 n)
 	for (i = 0; i < nets_length; i++) {
 	        if (h->nets[i].cidr[n] != cidr)
 	                continue;
-                if (h->nets[i].nets[n] > 1 || i == net_end ||
-                    h->nets[i + 1].nets[n] == 0) {
-                        h->nets[i].nets[n]--;
+		h->nets[cidr -1].nets[n]--;
+		if (h->nets[cidr -1].nets[n] > 0)
                         return;
-                }
-                for (j = i; j < net_end && h->nets[j].nets[n]; j++) {
+		for (j = i; j < net_end && h->nets[j].cidr[n]; j++)
 		        h->nets[j].cidr[n] = h->nets[j + 1].cidr[n];
-		        h->nets[j].nets[n] = h->nets[j + 1].nets[n];
-                }
-                h->nets[j].nets[n] = 0;
+		h->nets[j].cidr[n] = 0;
                 return;
 	}
 }
@@ -486,7 +486,7 @@ mtype_expire(struct ip_set *set, struct htype *h, u8 nets_length, size_t dsize)
 				pr_debug("expired %u/%u\n", i, j);
 #ifdef IP_SET_HASH_WITH_NETS
 				for (k = 0; k < IPSET_NET_COUNT; k++)
-					mtype_del_cidr(h, CIDR(data->cidr, k),
+					mtype_del_cidr(h, SCIDR(data->cidr, k),
 						       nets_length, k);
 #endif
 				ip_set_ext_destroy(set, data);
@@ -680,9 +680,9 @@ reuse_slot:
 		data = ahash_data(n, j, set->dsize);
 #ifdef IP_SET_HASH_WITH_NETS
 		for (i = 0; i < IPSET_NET_COUNT; i++) {
-			mtype_del_cidr(h, CIDR(data->cidr, i),
+			mtype_del_cidr(h, SCIDR(data->cidr, i),
 				       NLEN(set->family), i);
-			mtype_add_cidr(h, CIDR(d->cidr, i),
+			mtype_add_cidr(h, SCIDR(d->cidr, i),
 				       NLEN(set->family), i);
 		}
 #endif
@@ -699,7 +699,7 @@ reuse_slot:
 		data = ahash_data(n, n->pos++, set->dsize);
 #ifdef IP_SET_HASH_WITH_NETS
 		for (i = 0; i < IPSET_NET_COUNT; i++)
-			mtype_add_cidr(h, CIDR(d->cidr, i), NLEN(set->family),
+			mtype_add_cidr(h, SCIDR(d->cidr, i), NLEN(set->family),
 				       i);
 #endif
 		h->elements++;
@@ -760,7 +760,7 @@ mtype_del(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 		h->elements--;
 #ifdef IP_SET_HASH_WITH_NETS
 		for (j = 0; j < IPSET_NET_COUNT; j++)
-			mtype_del_cidr(h, CIDR(d->cidr, j), NLEN(set->family),
+			mtype_del_cidr(h, SCIDR(d->cidr, j), NLEN(set->family),
 				       j);
 #endif
 		ip_set_ext_destroy(set, data);
@@ -821,15 +821,15 @@ mtype_test_cidrs(struct ip_set *set, struct mtype_elem *d,
 	u8 nets_length = NLEN(set->family);
 
 	pr_debug("test by nets\n");
-	for (; j < nets_length && h->nets[j].nets[0] && !multi; j++) {
+	for (; j < nets_length && h->nets[j].cidr[0] && !multi; j++) {
 #if IPSET_NET_COUNT == 2
 		mtype_data_reset_elem(d, &orig);
-		mtype_data_netmask(d, h->nets[j].cidr[0], false);
-		for (k = 0; k < nets_length && h->nets[k].nets[1] && !multi;
+		mtype_data_netmask(d, NCIDR(h->nets[j].cidr[0]), false);
+		for (k = 0; k < nets_length && h->nets[k].cidr[1] && !multi;
 		     k++) {
-			mtype_data_netmask(d, h->nets[k].cidr[1], true);
+			mtype_data_netmask(d, NCIDR(h->nets[k].cidr[1]), true);
 #else
-		mtype_data_netmask(d, h->nets[j].cidr[0]);
+		mtype_data_netmask(d, NCIDR(h->nets[j].cidr[0]));
 #endif
 		key = HKEY(d, h->initval, t->htable_bits);
 		n = hbucket(t, key);
@@ -877,7 +877,7 @@ mtype_test(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	/* If we test an IP address and not a network address,
 	 * try all possible network sizes */
 	for (i = 0; i < IPSET_NET_COUNT; i++)
-		if (CIDR(d->cidr, i) != SET_HOST_MASK(set->family))
+		if (GCIDR(d->cidr, i) != SET_HOST_MASK(set->family))
 			break;
 	if (i == IPSET_NET_COUNT) {
 		ret = mtype_test_cidrs(set, d, ext, mext, flags);
-- 
1.7.10.4

