From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: [PATCH ipsec-next 1/2] xfrm: hash prefixed policies based on preflen thresholds
Date: Mon, 12 May 2014 15:45:24 +0200
Message-ID: <1399902325-1788-2-git-send-email-christophe.gouault@6wind.com>
References: <1399902325-1788-1-git-send-email-christophe.gouault@6wind.com>
Cc: netdev@vger.kernel.org,
	Christophe Gouault <christophe.gouault@6wind.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:36964 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883AbaELNpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 09:45:50 -0400
Received: by mail-we0-f172.google.com with SMTP id k48so6942303wev.17
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 06:45:49 -0700 (PDT)
In-Reply-To: <1399902325-1788-1-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The idea is an extension of the current policy hashing.

Today only non-prefixed policies are stored in a hash table. This
patch relaxes the constraints, and hashes policies whose prefix
lengths are greater or equal to a configurable threshold.

Each hash table (one per direction) maintains its own set of IPv4 and
IPv6 thresholds (dbits4, sbits4, dbits6, sbits6), by default (32, 32,
128, 128).

Example, if the output hash table is configured with values (16, 24,
56, 64):

ip xfrm policy add dir out src 10.22.0.0/20 dst 10.24.1.0/24 ... => hashed
ip xfrm policy add dir out src 10.22.0.0/16 dst 10.24.1.1/32 ... => hashed
ip xfrm policy add dir out src 10.22.0.0/16 dst 10.24.0.0/16 ... => unhashed

ip xfrm policy add dir out \
    src 3ffe:304:124:2200::/60 dst 3ffe:304:124:2401::/64 ...    => hashed
ip xfrm policy add dir out \
    src 3ffe:304:124:2200::/56 dst 3ffe:304:124:2401::2/128 ...  => hashed
ip xfrm policy add dir out \
    src 3ffe:304:124:2200::/56 dst 3ffe:304:124:2400::/56 ...    => unhashed

The high order bits of the addresses (up to the threshold) are used to
compute the hash key.

Signed-off-by: Christophe Gouault <christophe.gouault@6wind.com>
---
 include/net/netns/xfrm.h |  4 +++
 net/xfrm/xfrm_hash.h     | 76 +++++++++++++++++++++++++++++++++++++++++-------
 net/xfrm/xfrm_policy.c   | 53 +++++++++++++++++++++++++++++----
 3 files changed, 117 insertions(+), 16 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 3492434..41902a8 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -13,6 +13,10 @@ struct ctl_table_header;
 struct xfrm_policy_hash {
 	struct hlist_head	*table;
 	unsigned int		hmask;
+	u8			dbits4;
+	u8			sbits4;
+	u8			dbits6;
+	u8			sbits6;
 };
 
 struct netns_xfrm {
diff --git a/net/xfrm/xfrm_hash.h b/net/xfrm/xfrm_hash.h
index 0622d31..666c5ff 100644
--- a/net/xfrm/xfrm_hash.h
+++ b/net/xfrm/xfrm_hash.h
@@ -3,6 +3,7 @@
 
 #include <linux/xfrm.h>
 #include <linux/socket.h>
+#include <linux/jhash.h>
 
 static inline unsigned int __xfrm4_addr_hash(const xfrm_address_t *addr)
 {
@@ -28,6 +29,58 @@ static inline unsigned int __xfrm6_daddr_saddr_hash(const xfrm_address_t *daddr,
 		     saddr->a6[2] ^ saddr->a6[3]);
 }
 
+static inline u32 __bits2mask32(__u8 bits)
+{
+	u32 mask32 = 0xffffffff;
+
+	if (bits == 0)
+		mask32 = 0;
+	else if (bits < 32)
+		mask32 <<= (32 - bits);
+
+	return mask32;
+}
+
+static inline unsigned int __xfrm4_dpref_spref_hash(const xfrm_address_t *daddr,
+						    const xfrm_address_t *saddr,
+						    __u8 dbits,
+						    __u8 sbits)
+{
+	return jhash_2words(ntohl(daddr->a4) & __bits2mask32(dbits),
+			    ntohl(saddr->a4) & __bits2mask32(sbits),
+			    0);
+}
+
+static inline unsigned int __xfrm6_pref_hash(const xfrm_address_t *addr,
+					     __u8 prefixlen)
+{
+	int pdw;
+	int pbi;
+	u32 initval = 0;
+
+	pdw = prefixlen >> 5;     /* num of whole u32 in prefix */
+	pbi = prefixlen &  0x1f;  /* num of bits in incomplete u32 in prefix */
+
+	if (pbi) {
+		__be32 mask;
+
+		mask = htonl((0xffffffff) << (32 - pbi));
+
+		initval = (__force u32)(addr->a6[pdw] & mask);
+	}
+
+	return jhash2((__force u32 *)addr->a6, pdw, initval);
+}
+
+static inline unsigned int __xfrm6_dpref_spref_hash(const xfrm_address_t *daddr,
+						    const xfrm_address_t *saddr,
+						    __u8 dbits,
+						    __u8 sbits)
+{
+	return __xfrm6_pref_hash(daddr, dbits) ^
+	       __xfrm6_pref_hash(saddr, sbits);
+}
+
 static inline unsigned int __xfrm_dst_hash(const xfrm_address_t *daddr,
 					   const xfrm_address_t *saddr,
 					   u32 reqid, unsigned short family,
@@ -84,7 +137,8 @@ static inline unsigned int __idx_hash(u32 index, unsigned int hmask)
 }
 
 static inline unsigned int __sel_hash(const struct xfrm_selector *sel,
-				      unsigned short family, unsigned int hmask)
+				      unsigned short family, unsigned int hmask,
+				      u8 dbits, u8 sbits)
 {
 	const xfrm_address_t *daddr = &sel->daddr;
 	const xfrm_address_t *saddr = &sel->saddr;
@@ -92,19 +146,19 @@ static inline unsigned int __sel_hash(const struct xfrm_selector *sel,
 
 	switch (family) {
 	case AF_INET:
-		if (sel->prefixlen_d != 32 ||
-		    sel->prefixlen_s != 32)
+		if (sel->prefixlen_d < dbits ||
+		    sel->prefixlen_s < sbits)
 			return hmask + 1;
 
-		h = __xfrm4_daddr_saddr_hash(daddr, saddr);
+		h = __xfrm4_dpref_spref_hash(daddr, saddr, dbits, sbits);
 		break;
 
 	case AF_INET6:
-		if (sel->prefixlen_d != 128 ||
-		    sel->prefixlen_s != 128)
+		if (sel->prefixlen_d < dbits ||
+		    sel->prefixlen_s < sbits)
 			return hmask + 1;
 
-		h = __xfrm6_daddr_saddr_hash(daddr, saddr);
+		h = __xfrm6_dpref_spref_hash(daddr, saddr, dbits, sbits);
 		break;
 	}
 	h ^= (h >> 16);
@@ -113,17 +167,19 @@ static inline unsigned int __sel_hash(const struct xfrm_selector *sel,
 
 static inline unsigned int __addr_hash(const xfrm_address_t *daddr,
 				       const xfrm_address_t *saddr,
-				       unsigned short family, unsigned int hmask)
+				       unsigned short family,
+				       unsigned int hmask,
+				       u8 dbits, u8 sbits)
 {
 	unsigned int h = 0;
 
 	switch (family) {
 	case AF_INET:
-		h = __xfrm4_daddr_saddr_hash(daddr, saddr);
+		h = __xfrm4_dpref_spref_hash(daddr, saddr, dbits, sbits);
 		break;
 
 	case AF_INET6:
-		h = __xfrm6_daddr_saddr_hash(daddr, saddr);
+		h = __xfrm6_dpref_spref_hash(daddr, saddr, dbits, sbits);
 		break;
 	}
 	h ^= (h >> 16);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 375267d..d65e254 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -344,12 +344,39 @@ static inline unsigned int idx_hash(struct net *net, u32 index)
 	return __idx_hash(index, net->xfrm.policy_idx_hmask);
 }
 
+/* calculate policy hash thresholds */
+static void __get_hash_thresh(struct net *net,
+				   unsigned short family, int dir,
+				   u8 *dbits, u8 *sbits)
+{
+	switch (family) {
+	case AF_INET:
+		*dbits = net->xfrm.policy_bydst[dir].dbits4;
+		*sbits = net->xfrm.policy_bydst[dir].sbits4;
+		break;
+
+	case AF_INET6:
+		*dbits = net->xfrm.policy_bydst[dir].dbits6;
+		*sbits = net->xfrm.policy_bydst[dir].sbits6;
+		break;
+
+	default:
+		*dbits = 0;
+		*sbits = 0;
+	}
+}
+
 static struct hlist_head *policy_hash_bysel(struct net *net,
 					    const struct xfrm_selector *sel,
 					    unsigned short family, int dir)
 {
 	unsigned int hmask = net->xfrm.policy_bydst[dir].hmask;
-	unsigned int hash = __sel_hash(sel, family, hmask);
+	unsigned int hash;
+	u8 dbits;
+	u8 sbits;
+
+	__get_hash_thresh(net, family, dir, &dbits, &sbits);
+	hash = __sel_hash(sel, family, hmask, dbits, sbits);
 
 	return (hash == hmask + 1 ?
 		&net->xfrm.policy_inexact[dir] :
@@ -362,25 +389,35 @@ static struct hlist_head *policy_hash_direct(struct net *net,
 					     unsigned short family, int dir)
 {
 	unsigned int hmask = net->xfrm.policy_bydst[dir].hmask;
-	unsigned int hash = __addr_hash(daddr, saddr, family, hmask);
+	unsigned int hash;
+	u8 dbits;
+	u8 sbits;
+
+	__get_hash_thresh(net, family, dir, &dbits, &sbits);
+	hash = __addr_hash(daddr, saddr, family, hmask, dbits, sbits);
 
 	return net->xfrm.policy_bydst[dir].table + hash;
 }
 
-static void xfrm_dst_hash_transfer(struct hlist_head *list,
+static void xfrm_dst_hash_transfer(struct net *net,
+				   struct hlist_head *list,
 				   struct hlist_head *ndsttable,
-				   unsigned int nhashmask)
+				   unsigned int nhashmask,
+				   int dir)
 {
 	struct hlist_node *tmp, *entry0 = NULL;
 	struct xfrm_policy *pol;
 	unsigned int h0 = 0;
+	u8 dbits;
+	u8 sbits;
 
 redo:
 	hlist_for_each_entry_safe(pol, tmp, list, bydst) {
 		unsigned int h;
 
+		__get_hash_thresh(net, pol->family, dir, &dbits, &sbits);
 		h = __addr_hash(&pol->selector.daddr, &pol->selector.saddr,
-				pol->family, nhashmask);
+				pol->family, nhashmask, dbits, sbits);
 		if (!entry0) {
 			hlist_del(&pol->bydst);
 			hlist_add_head(&pol->bydst, ndsttable+h);
@@ -434,7 +471,7 @@ static void xfrm_bydst_resize(struct net *net, int dir)
 	write_lock_bh(&net->xfrm.xfrm_policy_lock);
 
 	for (i = hmask; i >= 0; i--)
-		xfrm_dst_hash_transfer(odst + i, ndst, nhashmask);
+		xfrm_dst_hash_transfer(net, odst + i, ndst, nhashmask, dir);
 
 	net->xfrm.policy_bydst[dir].table = ndst;
 	net->xfrm.policy_bydst[dir].hmask = nhashmask;
@@ -2830,6 +2867,10 @@ static int __net_init xfrm_policy_init(struct net *net)
 		if (!htab->table)
 			goto out_bydst;
 		htab->hmask = hmask;
+		htab->dbits4 = 32;
+		htab->sbits4 = 32;
+		htab->dbits6 = 128;
+		htab->sbits6 = 128;
 	}
 
 	INIT_LIST_HEAD(&net->xfrm.policy_all);
-- 
1.9.1
