From: David Miller <davem@davemloft.net>
Subject: [PATCH 12/15]: [XFRM]: Hash xfrm_state objects by source address
 too.
Date: Thu, 17 Aug 2006 01:28:31 -0700 (PDT)
Message-ID: <20060817.012831.21930960.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37818
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932335AbWHQI23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 04:28:29 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[XFRM]: Hash xfrm_state objects by source address too.

The source address is always non-prefixed so we should use
it to help give entropy to the bydst hash.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_state.c |   51 +++++++++++++++++++++++++++++++------------------
 1 files changed, 32 insertions(+), 19 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 814e72e..f97872e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -54,49 +54,60 @@ static unsigned int xfrm_state_hashmax _
 static unsigned int xfrm_state_num;
 static unsigned int xfrm_state_genid;
 
-static inline unsigned int __xfrm4_addr_hash(xfrm_address_t *addr)
+static inline unsigned int __xfrm4_daddr_hash(xfrm_address_t *daddr)
 {
-	return ntohl(addr->a4);
+	return ntohl(daddr->a4);
 }
 
-static inline unsigned int __xfrm6_addr_hash(xfrm_address_t *addr)
+static inline unsigned int __xfrm6_daddr_hash(xfrm_address_t *daddr)
 {
-	return ntohl(addr->a6[2]^addr->a6[3]);
+	return ntohl(daddr->a6[2] ^ daddr->a6[3]);
 }
 
-static inline unsigned int __xfrm_dst_hash(xfrm_address_t *addr,
+static inline unsigned int __xfrm4_daddr_saddr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr)
+{
+	return ntohl(daddr->a4 ^ saddr->a4);
+}
+
+static inline unsigned int __xfrm6_daddr_saddr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr)
+{
+	return ntohl(daddr->a6[2] ^ daddr->a6[3] ^
+		     saddr->a6[2] ^ saddr->a6[3]);
+}
+
+static inline unsigned int __xfrm_dst_hash(xfrm_address_t *daddr, xfrm_address_t *saddr,
 					   u32 reqid, unsigned short family,
 					   unsigned int hmask)
 {
 	unsigned int h = family ^ reqid;
 	switch (family) {
 	case AF_INET:
-		h ^= __xfrm4_addr_hash(addr);
+		h ^= __xfrm4_daddr_saddr_hash(daddr, saddr);
 		break;
 	case AF_INET6:
-		h ^= __xfrm6_addr_hash(addr);
+		h ^= __xfrm6_daddr_saddr_hash(daddr, saddr);
 		break;
 	}
 	return (h ^ (h >> 16)) & hmask;
 }
 
-static inline unsigned int xfrm_dst_hash(xfrm_address_t *addr,
+static inline unsigned int xfrm_dst_hash(xfrm_address_t *daddr, xfrm_address_t *saddr,
 					 u32 reqid, unsigned short family)
 {
-	return __xfrm_dst_hash(addr, reqid, family, xfrm_state_hmask);
+	return __xfrm_dst_hash(daddr, saddr, reqid, family, xfrm_state_hmask);
 }
 
 static inline unsigned int
-__xfrm_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto, unsigned short family,
+__xfrm_spi_hash(xfrm_address_t *daddr, u32 spi, u8 proto, unsigned short family,
 		unsigned int hmask)
 {
 	unsigned int h = spi ^ proto;
 	switch (family) {
 	case AF_INET:
-		h ^= __xfrm4_addr_hash(addr);
+		h ^= __xfrm4_daddr_hash(daddr);
 		break;
 	case AF_INET6:
-		h ^= __xfrm6_addr_hash(addr);
+		h ^= __xfrm6_daddr_hash(daddr);
 		break;
 	}
 	return (h ^ (h >> 10) ^ (h >> 20)) & hmask;
@@ -147,8 +158,9 @@ static void xfrm_hash_transfer(struct hl
 	hlist_for_each_entry_safe(x, entry, tmp, list, bydst) {
 		unsigned int h;
 
-		h = __xfrm_dst_hash(&x->id.daddr, x->props.reqid,
-				    x->props.family, nhashmask);
+		h = __xfrm_dst_hash(&x->id.daddr, &x->props.saddr,
+				    x->props.reqid, x->props.family,
+				    nhashmask);
 		hlist_add_head(&x->bydst, ndsttable+h);
 
 		h = __xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto,
@@ -500,7 +512,7 @@ xfrm_state_find(xfrm_address_t *daddr, x
 		struct xfrm_policy *pol, int *err,
 		unsigned short family)
 {
-	unsigned int h = xfrm_dst_hash(daddr, tmpl->reqid, family);
+	unsigned int h = xfrm_dst_hash(daddr, saddr, tmpl->reqid, family);
 	struct hlist_node *entry;
 	struct xfrm_state *x, *x0;
 	int acquire_in_progress = 0;
@@ -598,7 +610,7 @@ static void __xfrm_state_insert(struct x
 
 	x->genid = ++xfrm_state_genid;
 
-	h = xfrm_dst_hash(&x->id.daddr, x->props.reqid, x->props.family);
+	h = xfrm_dst_hash(&x->id.daddr, &x->props.saddr, x->props.reqid, x->props.family);
 	hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 
 	h = xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto, x->props.family);
@@ -627,11 +639,12 @@ static void __xfrm_state_bump_genids(str
 	struct hlist_node *entry;
 	unsigned int h;
 
-	h = xfrm_dst_hash(&xnew->id.daddr, reqid, family);
+	h = xfrm_dst_hash(&xnew->id.daddr, &xnew->props.saddr, reqid, family);
 	hlist_for_each_entry(x, entry, xfrm_state_bydst+h, bydst) {
 		if (x->props.family	== family &&
 		    x->props.reqid	== reqid &&
-		    !xfrm_addr_cmp(&x->id.daddr, &xnew->id.daddr, family))
+		    !xfrm_addr_cmp(&x->id.daddr, &xnew->id.daddr, family) &&
+		    !xfrm_addr_cmp(&x->props.saddr, &xnew->props.saddr, family))
 			x->genid = xfrm_state_genid;
 	}
 }
@@ -648,7 +661,7 @@ EXPORT_SYMBOL(xfrm_state_insert);
 /* xfrm_state_lock is held */
 static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 reqid, u8 proto, xfrm_address_t *daddr, xfrm_address_t *saddr, int create)
 {
-	unsigned int h = xfrm_dst_hash(daddr, reqid, family);
+	unsigned int h = xfrm_dst_hash(daddr, saddr, reqid, family);
 	struct hlist_node *entry;
 	struct xfrm_state *x;
 
-- 
1.4.2.rc2.g3e042

