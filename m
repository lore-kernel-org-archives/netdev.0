From: David Miller <davem@davemloft.net>
Subject: [PATCH 7/10]: [XFRM]: Put more keys into destination hash function.
Date: Tue, 15 Aug 2006 04:39:47 -0700 (PDT)
Message-ID: <20060815.043947.72711031.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:3547
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030257AbWHOLjt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 07:39:49 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[XFRM]: Put more keys into destination hash function.

Besides the daddr, key the hash on family and reqid too.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_state.c |   44 +++++++++++++++++++++++---------------------
 1 files changed, 23 insertions(+), 21 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index eb17f1b..9b3ab5c 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -35,7 +35,7 @@ EXPORT_SYMBOL(sysctl_xfrm_aevent_rseqth)
 /* Each xfrm_state may be linked to two tables:
 
    1. Hash table by (spi,daddr,ah/esp) to find SA by SPI. (input,ctl)
-   2. Hash table by daddr to find what SAs exist for given
+   2. Hash table by (daddr,family,reqid) to find what SAs exist for given
       destination/tunnel endpoint. (output)
  */
 
@@ -54,37 +54,36 @@ static unsigned int xfrm_state_hashmax _
 static unsigned int xfrm_state_num;
 static unsigned int xfrm_state_genid;
 
-static inline unsigned int __xfrm4_dst_hash(xfrm_address_t *addr, unsigned int hmask)
+static inline unsigned int __xfrm4_addr_hash(xfrm_address_t *addr)
 {
-	unsigned int h;
-	h = ntohl(addr->a4);
-	h = (h ^ (h>>16)) & xfrm_state_hmask;
-	return h;
+	return ntohl(addr->a4);
 }
 
-static inline unsigned int __xfrm6_dst_hash(xfrm_address_t *addr, unsigned int hmask)
+static inline unsigned int __xfrm6_addr_hash(xfrm_address_t *addr)
 {
-	unsigned int h;
-	h = ntohl(addr->a6[2]^addr->a6[3]);
-	h = (h ^ (h>>16)) & hmask;
-	return h;
+	return ntohl(addr->a6[2]^addr->a6[3]);
 }
 
-static inline unsigned int __xfrm_dst_hash(xfrm_address_t *addr, unsigned short family,
+static inline unsigned int __xfrm_dst_hash(xfrm_address_t *addr,
+					   u32 reqid, unsigned short family,
 					   unsigned int hmask)
 {
+	unsigned int h = family ^ reqid;
 	switch (family) {
 	case AF_INET:
-		return __xfrm4_dst_hash(addr, hmask);
+		h ^= __xfrm4_addr_hash(addr);
+		break;
 	case AF_INET6:
-		return __xfrm6_dst_hash(addr, hmask);
+		h ^= __xfrm6_addr_hash(addr);
+		break;
 	}
-	return 0;
+	return (h ^ (h >> 16)) & hmask;
 }
 
-static inline unsigned int xfrm_dst_hash(xfrm_address_t *addr, unsigned short family)
+static inline unsigned int xfrm_dst_hash(xfrm_address_t *addr,
+					 u32 reqid, unsigned short family)
 {
-	return __xfrm_dst_hash(addr, family, xfrm_state_hmask);
+	return __xfrm_dst_hash(addr, reqid, family, xfrm_state_hmask);
 }
 
 static inline unsigned int __xfrm4_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto,
@@ -163,7 +162,8 @@ static void xfrm_hash_transfer(struct hl
 	hlist_for_each_entry_safe(x, entry, tmp, list, bydst) {
 		unsigned int h;
 
-		h = __xfrm_dst_hash(&x->id.daddr, x->props.family, nhashmask);
+		h = __xfrm_dst_hash(&x->id.daddr, x->props.reqid,
+				    x->props.family, nhashmask);
 		hlist_add_head(&x->bydst, ndsttable+h);
 
 		h = __xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto,
@@ -542,7 +542,7 @@ xfrm_state_find(xfrm_address_t *daddr, x
 		struct xfrm_policy *pol, int *err,
 		unsigned short family)
 {
-	unsigned int h = xfrm_dst_hash(daddr, family);
+	unsigned int h = xfrm_dst_hash(daddr, tmpl->reqid, family);
 	struct hlist_node *entry;
 	struct xfrm_state *x, *x0;
 	int acquire_in_progress = 0;
@@ -639,7 +639,9 @@ out:
 
 static void __xfrm_state_insert(struct xfrm_state *x)
 {
-	unsigned h = xfrm_dst_hash(&x->id.daddr, x->props.family);
+	unsigned int h;
+
+	h = xfrm_dst_hash(&x->id.daddr, x->props.reqid, x->props.family);
 
 	x->genid = ++xfrm_state_genid;
 
@@ -681,7 +683,7 @@ EXPORT_SYMBOL(xfrm_state_insert);
 /* xfrm_state_lock is held */
 static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 reqid, u8 proto, xfrm_address_t *daddr, xfrm_address_t *saddr, int create)
 {
-	unsigned int h = xfrm_dst_hash(daddr, family);
+	unsigned int h = xfrm_dst_hash(daddr, reqid, family);
 	struct hlist_node *entry;
 	struct xfrm_state *x;
 
-- 
1.4.2.rc2.g3e042

