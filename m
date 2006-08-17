From: David Miller <davem@davemloft.net>
Subject: [PATCH 14/15]: [XFRM]: Extract common hashing code into
 xfrm_hash.[ch]
Date: Thu, 17 Aug 2006 01:28:40 -0700 (PDT)
Message-ID: <20060817.012840.102578976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:39354
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932445AbWHQI2i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 04:28:38 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[XFRM]: Extract common hashing code into xfrm_hash.[ch]

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/Makefile      |    3 +
 net/xfrm/xfrm_hash.c   |   41 ++++++++++++++++++
 net/xfrm/xfrm_hash.h   |  112 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_policy.c |   95 +++--------------------------------------
 net/xfrm/xfrm_state.c  |   99 ++++--------------------------------------
 5 files changed, 172 insertions(+), 178 deletions(-)

diff --git a/net/xfrm/Makefile b/net/xfrm/Makefile
index 693aac1..de3c1a6 100644
--- a/net/xfrm/Makefile
+++ b/net/xfrm/Makefile
@@ -2,6 +2,7 @@ #
 # Makefile for the XFRM subsystem.
 #
 
-obj-$(CONFIG_XFRM) := xfrm_policy.o xfrm_state.o xfrm_input.o xfrm_algo.o
+obj-$(CONFIG_XFRM) := xfrm_policy.o xfrm_state.o xfrm_hash.o \
+		      xfrm_input.o xfrm_algo.o
 obj-$(CONFIG_XFRM_USER) += xfrm_user.o
 
diff --git a/net/xfrm/xfrm_hash.c b/net/xfrm/xfrm_hash.c
new file mode 100644
index 0000000..37643bb
--- /dev/null
+++ b/net/xfrm/xfrm_hash.c
@@ -0,0 +1,41 @@
+/* xfrm_hash.c: Common hash table code.
+ *
+ * Copyright (C) 2006 David S. Miller (davem@davemloft.net)
+ */
+
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/bootmem.h>
+#include <linux/vmalloc.h>
+#include <linux/slab.h>
+#include <linux/xfrm.h>
+
+#include "xfrm_hash.h"
+
+struct hlist_head *xfrm_hash_alloc(unsigned int sz)
+{
+	struct hlist_head *n;
+
+	if (sz <= PAGE_SIZE)
+		n = kmalloc(sz, GFP_KERNEL);
+	else if (hashdist)
+		n = __vmalloc(sz, GFP_KERNEL, PAGE_KERNEL);
+	else
+		n = (struct hlist_head *)
+			__get_free_pages(GFP_KERNEL, get_order(sz));
+
+	if (n)
+		memset(n, 0, sz);
+
+	return n;
+}
+
+void xfrm_hash_free(struct hlist_head *n, unsigned int sz)
+{
+	if (sz <= PAGE_SIZE)
+		kfree(n);
+	else if (hashdist)
+		vfree(n);
+	else
+		free_pages((unsigned long)n, get_order(sz));
+}
diff --git a/net/xfrm/xfrm_hash.h b/net/xfrm/xfrm_hash.h
new file mode 100644
index 0000000..ae756aa
--- /dev/null
+++ b/net/xfrm/xfrm_hash.h
@@ -0,0 +1,112 @@
+#ifndef _XFRM_HASH_H
+#define _XFRM_HASH_H
+
+#include <linux/xfrm.h>
+#include <linux/socket.h>
+
+static inline unsigned int __xfrm4_daddr_hash(xfrm_address_t *daddr)
+{
+	return ntohl(daddr->a4);
+}
+
+static inline unsigned int __xfrm6_daddr_hash(xfrm_address_t *daddr)
+{
+	return ntohl(daddr->a6[2] ^ daddr->a6[3]);
+}
+
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
+					   u32 reqid, unsigned short family,
+					   unsigned int hmask)
+{
+	unsigned int h = family ^ reqid;
+	switch (family) {
+	case AF_INET:
+		h ^= __xfrm4_daddr_saddr_hash(daddr, saddr);
+		break;
+	case AF_INET6:
+		h ^= __xfrm6_daddr_saddr_hash(daddr, saddr);
+		break;
+	}
+	return (h ^ (h >> 16)) & hmask;
+}
+
+static inline unsigned int
+__xfrm_spi_hash(xfrm_address_t *daddr, u32 spi, u8 proto, unsigned short family,
+		unsigned int hmask)
+{
+	unsigned int h = spi ^ proto;
+	switch (family) {
+	case AF_INET:
+		h ^= __xfrm4_daddr_hash(daddr);
+		break;
+	case AF_INET6:
+		h ^= __xfrm6_daddr_hash(daddr);
+		break;
+	}
+	return (h ^ (h >> 10) ^ (h >> 20)) & hmask;
+}
+
+static inline unsigned int __idx_hash(u32 index, unsigned int hmask)
+{
+	return (index ^ (index >> 8)) & hmask;
+}
+
+static inline unsigned int __sel_hash(struct xfrm_selector *sel, unsigned short family, unsigned int hmask)
+{
+	xfrm_address_t *daddr = &sel->daddr;
+	xfrm_address_t *saddr = &sel->saddr;
+	unsigned int h = 0;
+
+	switch (family) {
+	case AF_INET:
+		if (sel->prefixlen_d != 32 ||
+		    sel->prefixlen_s != 32)
+			return hmask + 1;
+
+		h = __xfrm4_daddr_saddr_hash(daddr, saddr);
+		break;
+
+	case AF_INET6:
+		if (sel->prefixlen_d != 128 ||
+		    sel->prefixlen_s != 128)
+			return hmask + 1;
+
+		h = __xfrm6_daddr_saddr_hash(daddr, saddr);
+		break;
+	};
+	h ^= (h >> 16);
+	return h & hmask;
+}
+
+static inline unsigned int __addr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr, unsigned short family, unsigned int hmask)
+{
+	unsigned int h = 0;
+
+	switch (family) {
+	case AF_INET:
+		h = __xfrm4_daddr_saddr_hash(daddr, saddr);
+		break;
+
+	case AF_INET6:
+		h = __xfrm6_daddr_saddr_hash(daddr, saddr);
+		break;
+	};
+	h ^= (h >> 16);
+	return h & hmask;
+}
+
+extern struct hlist_head *xfrm_hash_alloc(unsigned int sz);
+extern void xfrm_hash_free(struct hlist_head *n, unsigned int sz);
+
+#endif /* _XFRM_HASH_H */
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 0f6eff8..554f0db 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -22,12 +22,12 @@ #include <linux/notifier.h>
 #include <linux/netdevice.h>
 #include <linux/netfilter.h>
 #include <linux/module.h>
-#include <linux/bootmem.h>
-#include <linux/vmalloc.h>
 #include <linux/cache.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
 
+#include "xfrm_hash.h"
+
 DEFINE_MUTEX(xfrm_cfg_mutex);
 EXPORT_SYMBOL(xfrm_cfg_mutex);
 
@@ -409,62 +409,11 @@ static struct hlist_head *xfrm_policy_by
 static unsigned int xfrm_idx_hmask __read_mostly;
 static unsigned int xfrm_policy_hashmax __read_mostly = 1 * 1024 * 1024;
 
-static inline unsigned int __idx_hash(u32 index, unsigned int hmask)
-{
-	return (index ^ (index >> 8)) & hmask;
-}
-
 static inline unsigned int idx_hash(u32 index)
 {
 	return __idx_hash(index, xfrm_idx_hmask);
 }
 
-static inline unsigned int __sel_hash(struct xfrm_selector *sel, unsigned short family, unsigned int hmask)
-{
-	xfrm_address_t *daddr = &sel->daddr;
-	xfrm_address_t *saddr = &sel->saddr;
-	unsigned int h = 0;
-
-	switch (family) {
-	case AF_INET:
-		if (sel->prefixlen_d != 32 ||
-		    sel->prefixlen_s != 32)
-			return hmask + 1;
-
-		h = ntohl(daddr->a4 ^ saddr->a4);
-		break;
-
-	case AF_INET6:
-		if (sel->prefixlen_d != 128 ||
-		    sel->prefixlen_s != 128)
-			return hmask + 1;
-
-		h = ntohl(daddr->a6[2] ^ daddr->a6[3] ^
-			  saddr->a6[2] ^ saddr->a6[3]);
-		break;
-	};
-	h ^= (h >> 16);
-	return h & hmask;
-}
-
-static inline unsigned int __addr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr, unsigned short family, unsigned int hmask)
-{
-	unsigned int h = 0;
-
-	switch (family) {
-	case AF_INET:
-		h = ntohl(daddr->a4 ^ saddr->a4);
-		break;
-
-	case AF_INET6:
-		h = ntohl(daddr->a6[2] ^ daddr->a6[3] ^
-			  saddr->a6[2] ^ saddr->a6[3]);
-		break;
-	};
-	h ^= (h >> 16);
-	return h & hmask;
-}
-
 static struct hlist_head *policy_hash_bysel(struct xfrm_selector *sel, unsigned short family, int dir)
 {
 	unsigned int hmask = xfrm_policy_bydst[dir].hmask;
@@ -483,34 +432,6 @@ static struct hlist_head *policy_hash_di
 	return xfrm_policy_bydst[dir].table + hash;
 }
 
-static struct hlist_head *xfrm_policy_hash_alloc(unsigned int sz)
-{
-	struct hlist_head *n;
-
-	if (sz <= PAGE_SIZE)
-		n = kmalloc(sz, GFP_KERNEL);
-	else if (hashdist)
-		n = __vmalloc(sz, GFP_KERNEL, PAGE_KERNEL);
-	else
-		n = (struct hlist_head *)
-			__get_free_pages(GFP_KERNEL, get_order(sz));
-
-	if (n)
-		memset(n, 0, sz);
-
-	return n;
-}
-
-static void xfrm_policy_hash_free(struct hlist_head *n, unsigned int sz)
-{
-	if (sz <= PAGE_SIZE)
-		kfree(n);
-	else if (hashdist)
-		vfree(n);
-	else
-		free_pages((unsigned long)n, get_order(sz));
-}
-
 static void xfrm_dst_hash_transfer(struct hlist_head *list,
 				   struct hlist_head *ndsttable,
 				   unsigned int nhashmask)
@@ -553,7 +474,7 @@ static void xfrm_bydst_resize(int dir)
 	unsigned int nhashmask = xfrm_new_hash_mask(hmask);
 	unsigned int nsize = (nhashmask + 1) * sizeof(struct hlist_head);
 	struct hlist_head *odst = xfrm_policy_bydst[dir].table;
-	struct hlist_head *ndst = xfrm_policy_hash_alloc(nsize);
+	struct hlist_head *ndst = xfrm_hash_alloc(nsize);
 	int i;
 
 	if (!ndst)
@@ -569,7 +490,7 @@ static void xfrm_bydst_resize(int dir)
 
 	write_unlock_bh(&xfrm_policy_lock);
 
-	xfrm_policy_hash_free(odst, (hmask + 1) * sizeof(struct hlist_head));
+	xfrm_hash_free(odst, (hmask + 1) * sizeof(struct hlist_head));
 }
 
 static void xfrm_byidx_resize(int total)
@@ -578,7 +499,7 @@ static void xfrm_byidx_resize(int total)
 	unsigned int nhashmask = xfrm_new_hash_mask(hmask);
 	unsigned int nsize = (nhashmask + 1) * sizeof(struct hlist_head);
 	struct hlist_head *oidx = xfrm_policy_byidx;
-	struct hlist_head *nidx = xfrm_policy_hash_alloc(nsize);
+	struct hlist_head *nidx = xfrm_hash_alloc(nsize);
 	int i;
 
 	if (!nidx)
@@ -594,7 +515,7 @@ static void xfrm_byidx_resize(int total)
 
 	write_unlock_bh(&xfrm_policy_lock);
 
-	xfrm_policy_hash_free(oidx, (hmask + 1) * sizeof(struct hlist_head));
+	xfrm_hash_free(oidx, (hmask + 1) * sizeof(struct hlist_head));
 }
 
 static inline int xfrm_bydst_should_resize(int dir, int *total)
@@ -1839,7 +1760,7 @@ static void __init xfrm_policy_init(void
 	hmask = 8 - 1;
 	sz = (hmask+1) * sizeof(struct hlist_head);
 
-	xfrm_policy_byidx = xfrm_policy_hash_alloc(sz);
+	xfrm_policy_byidx = xfrm_hash_alloc(sz);
 	xfrm_idx_hmask = hmask;
 	if (!xfrm_policy_byidx)
 		panic("XFRM: failed to allocate byidx hash\n");
@@ -1850,7 +1771,7 @@ static void __init xfrm_policy_init(void
 		INIT_HLIST_HEAD(&xfrm_policy_inexact[dir]);
 
 		htab = &xfrm_policy_bydst[dir];
-		htab->table = xfrm_policy_hash_alloc(sz);
+		htab->table = xfrm_hash_alloc(sz);
 		htab->hmask = hmask;
 		if (!htab->table)
 			panic("XFRM: failed to allocate bydst hash\n");
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f97872e..d12b0af 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -18,11 +18,11 @@ #include <net/xfrm.h>
 #include <linux/pfkeyv2.h>
 #include <linux/ipsec.h>
 #include <linux/module.h>
-#include <linux/bootmem.h>
-#include <linux/vmalloc.h>
 #include <linux/cache.h>
 #include <asm/uaccess.h>
 
+#include "xfrm_hash.h"
+
 struct sock *xfrm_nl;
 EXPORT_SYMBOL(xfrm_nl);
 
@@ -54,43 +54,6 @@ static unsigned int xfrm_state_hashmax _
 static unsigned int xfrm_state_num;
 static unsigned int xfrm_state_genid;
 
-static inline unsigned int __xfrm4_daddr_hash(xfrm_address_t *daddr)
-{
-	return ntohl(daddr->a4);
-}
-
-static inline unsigned int __xfrm6_daddr_hash(xfrm_address_t *daddr)
-{
-	return ntohl(daddr->a6[2] ^ daddr->a6[3]);
-}
-
-static inline unsigned int __xfrm4_daddr_saddr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr)
-{
-	return ntohl(daddr->a4 ^ saddr->a4);
-}
-
-static inline unsigned int __xfrm6_daddr_saddr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr)
-{
-	return ntohl(daddr->a6[2] ^ daddr->a6[3] ^
-		     saddr->a6[2] ^ saddr->a6[3]);
-}
-
-static inline unsigned int __xfrm_dst_hash(xfrm_address_t *daddr, xfrm_address_t *saddr,
-					   u32 reqid, unsigned short family,
-					   unsigned int hmask)
-{
-	unsigned int h = family ^ reqid;
-	switch (family) {
-	case AF_INET:
-		h ^= __xfrm4_daddr_saddr_hash(daddr, saddr);
-		break;
-	case AF_INET6:
-		h ^= __xfrm6_daddr_saddr_hash(daddr, saddr);
-		break;
-	}
-	return (h ^ (h >> 16)) & hmask;
-}
-
 static inline unsigned int xfrm_dst_hash(xfrm_address_t *daddr, xfrm_address_t *saddr,
 					 u32 reqid, unsigned short family)
 {
@@ -98,55 +61,11 @@ static inline unsigned int xfrm_dst_hash
 }
 
 static inline unsigned int
-__xfrm_spi_hash(xfrm_address_t *daddr, u32 spi, u8 proto, unsigned short family,
-		unsigned int hmask)
-{
-	unsigned int h = spi ^ proto;
-	switch (family) {
-	case AF_INET:
-		h ^= __xfrm4_daddr_hash(daddr);
-		break;
-	case AF_INET6:
-		h ^= __xfrm6_daddr_hash(daddr);
-		break;
-	}
-	return (h ^ (h >> 10) ^ (h >> 20)) & hmask;
-}
-
-static inline unsigned int
 xfrm_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto, unsigned short family)
 {
 	return __xfrm_spi_hash(addr, spi, proto, family, xfrm_state_hmask);
 }
 
-static struct hlist_head *xfrm_state_hash_alloc(unsigned int sz)
-{
-	struct hlist_head *n;
-
-	if (sz <= PAGE_SIZE)
-		n = kmalloc(sz, GFP_KERNEL);
-	else if (hashdist)
-		n = __vmalloc(sz, GFP_KERNEL, PAGE_KERNEL);
-	else
-		n = (struct hlist_head *)
-			__get_free_pages(GFP_KERNEL, get_order(sz));
-
-	if (n)
-		memset(n, 0, sz);
-
-	return n;
-}
-
-static void xfrm_state_hash_free(struct hlist_head *n, unsigned int sz)
-{
-	if (sz <= PAGE_SIZE)
-		kfree(n);
-	else if (hashdist)
-		vfree(n);
-	else
-		free_pages((unsigned long)n, get_order(sz));
-}
-
 static void xfrm_hash_transfer(struct hlist_head *list,
 			       struct hlist_head *ndsttable,
 			       struct hlist_head *nspitable,
@@ -187,12 +106,12 @@ static void xfrm_hash_resize(void *__unu
 	mutex_lock(&hash_resize_mutex);
 
 	nsize = xfrm_hash_new_size();
-	ndst = xfrm_state_hash_alloc(nsize);
+	ndst = xfrm_hash_alloc(nsize);
 	if (!ndst)
 		goto out_unlock;
-	nspi = xfrm_state_hash_alloc(nsize);
+	nspi = xfrm_hash_alloc(nsize);
 	if (!nspi) {
-		xfrm_state_hash_free(ndst, nsize);
+		xfrm_hash_free(ndst, nsize);
 		goto out_unlock;
 	}
 
@@ -212,8 +131,8 @@ static void xfrm_hash_resize(void *__unu
 
 	spin_unlock_bh(&xfrm_state_lock);
 
-	xfrm_state_hash_free(odst, (ohashmask + 1) * sizeof(struct hlist_head));
-	xfrm_state_hash_free(ospi, (ohashmask + 1) * sizeof(struct hlist_head));
+	xfrm_hash_free(odst, (ohashmask + 1) * sizeof(struct hlist_head));
+	xfrm_hash_free(ospi, (ohashmask + 1) * sizeof(struct hlist_head));
 
 out_unlock:
 	mutex_unlock(&hash_resize_mutex);
@@ -1456,8 +1375,8 @@ void __init xfrm_state_init(void)
 
 	sz = sizeof(struct hlist_head) * 8;
 
-	xfrm_state_bydst = xfrm_state_hash_alloc(sz);
-	xfrm_state_byspi = xfrm_state_hash_alloc(sz);
+	xfrm_state_bydst = xfrm_hash_alloc(sz);
+	xfrm_state_byspi = xfrm_hash_alloc(sz);
 	if (!xfrm_state_bydst || !xfrm_state_byspi)
 		panic("XFRM: Cannot allocate bydst/byspi hashes.");
 	xfrm_state_hmask = ((sz / sizeof(struct hlist_head)) - 1);
-- 
1.4.2.rc2.g3e042

