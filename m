From: Patrick McHardy <kaber@trash.net>
Subject: [XFRM]: Fix wildcard as tunnel source
Date: Sat, 02 Sep 2006 16:46:44 +0200
Message-ID: <44F99954.1040606@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000703020006020904080700"
Cc: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59816 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750845AbWIBOqs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Sep 2006 10:46:48 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000703020006020904080700
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------000703020006020904080700
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[XFRM]: Fix wildcard as tunnel source

Hashing SAs by source address breaks templates with wildcards as tunnel
source. Remove saddr from the hash key.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 19f7b6f33c0e9fbdf23a33506c2dfc0706b0c731
tree bca60eb94c50fcd66673bd87823fd38364b45b55
parent 6ddbd02eb61532f9af4f28912a09717ab8c71d8a
author Patrick McHardy <kaber@gw.localnet> Sat, 02 Sep 2006 16:43:39 +0200
committer Patrick McHardy <kaber@gw.localnet> Sat, 02 Sep 2006 16:43:39 +0200

 net/xfrm/xfrm_hash.h  |    8 ++++----
 net/xfrm/xfrm_state.c |   17 +++++++----------
 2 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/net/xfrm/xfrm_hash.h b/net/xfrm/xfrm_hash.h
index d3abb0b..deb18ce 100644
--- a/net/xfrm/xfrm_hash.h
+++ b/net/xfrm/xfrm_hash.h
@@ -25,17 +25,17 @@ static inline unsigned int __xfrm6_daddr
 		     saddr->a6[2] ^ saddr->a6[3]);
 }
 
-static inline unsigned int __xfrm_dst_hash(xfrm_address_t *daddr, xfrm_address_t *saddr,
-					   u32 reqid, unsigned short family,
+static inline unsigned int __xfrm_dst_hash(xfrm_address_t *daddr, u32 reqid,
+					   unsigned short family,
 					   unsigned int hmask)
 {
 	unsigned int h = family ^ reqid;
 	switch (family) {
 	case AF_INET:
-		h ^= __xfrm4_daddr_saddr_hash(daddr, saddr);
+		h ^= __xfrm4_addr_hash(daddr);
 		break;
 	case AF_INET6:
-		h ^= __xfrm6_daddr_saddr_hash(daddr, saddr);
+		h ^= __xfrm6_addr_hash(daddr);
 		break;
 	}
 	return (h ^ (h >> 16)) & hmask;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 9f63edd..0c26a1f 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -56,11 +56,10 @@ static unsigned int xfrm_state_num;
 static unsigned int xfrm_state_genid;
 
 static inline unsigned int xfrm_dst_hash(xfrm_address_t *daddr,
-					 xfrm_address_t *saddr,
 					 u32 reqid,
 					 unsigned short family)
 {
-	return __xfrm_dst_hash(daddr, saddr, reqid, family, xfrm_state_hmask);
+	return __xfrm_dst_hash(daddr, reqid, family, xfrm_state_hmask);
 }
 
 static inline unsigned int xfrm_src_hash(xfrm_address_t *addr,
@@ -87,9 +86,8 @@ static void xfrm_hash_transfer(struct hl
 	hlist_for_each_entry_safe(x, entry, tmp, list, bydst) {
 		unsigned int h;
 
-		h = __xfrm_dst_hash(&x->id.daddr, &x->props.saddr,
-				    x->props.reqid, x->props.family,
-				    nhashmask);
+		h = __xfrm_dst_hash(&x->id.daddr, x->props.reqid,
+				    x->props.family, nhashmask);
 		hlist_add_head(&x->bydst, ndsttable+h);
 
 		h = __xfrm_src_hash(&x->props.saddr, x->props.family,
@@ -506,7 +504,7 @@ xfrm_state_find(xfrm_address_t *daddr, x
 		struct xfrm_policy *pol, int *err,
 		unsigned short family)
 {
-	unsigned int h = xfrm_dst_hash(daddr, saddr, tmpl->reqid, family);
+	unsigned int h = xfrm_dst_hash(daddr, tmpl->reqid, family);
 	struct hlist_node *entry;
 	struct xfrm_state *x, *x0;
 	int acquire_in_progress = 0;
@@ -615,8 +613,7 @@ static void __xfrm_state_insert(struct x
 
 	x->genid = ++xfrm_state_genid;
 
-	h = xfrm_dst_hash(&x->id.daddr, &x->props.saddr,
-			  x->props.reqid, x->props.family);
+	h = xfrm_dst_hash(&x->id.daddr, x->props.reqid, x->props.family);
 	hlist_add_head(&x->bydst, xfrm_state_bydst+h);
 
 	h = xfrm_src_hash(&x->props.saddr, x->props.family);
@@ -652,7 +649,7 @@ static void __xfrm_state_bump_genids(str
 	struct hlist_node *entry;
 	unsigned int h;
 
-	h = xfrm_dst_hash(&xnew->id.daddr, &xnew->props.saddr, reqid, family);
+	h = xfrm_dst_hash(&xnew->id.daddr, reqid, family);
 	hlist_for_each_entry(x, entry, xfrm_state_bydst+h, bydst) {
 		if (x->props.family	== family &&
 		    x->props.reqid	== reqid &&
@@ -674,7 +671,7 @@ EXPORT_SYMBOL(xfrm_state_insert);
 /* xfrm_state_lock is held */
 static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 reqid, u8 proto, xfrm_address_t *daddr, xfrm_address_t *saddr, int create)
 {
-	unsigned int h = xfrm_dst_hash(daddr, saddr, reqid, family);
+	unsigned int h = xfrm_dst_hash(daddr, reqid, family);
 	struct hlist_node *entry;
 	struct xfrm_state *x;
 

--------------000703020006020904080700--

-- 
VGER BF report: U 0.499996
