From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/10]: [XFRM]: Dynamic xfrm_state hash table sizing.
Date: Tue, 15 Aug 2006 04:39:05 -0700 (PDT)
Message-ID: <20060815.043905.79069789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2011
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030254AbWHOLjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 07:39:07 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[XFRM]: Dynamic xfrm_state hash table sizing.

The grow algorithm is simple, we grow if:

1) we see a hash chain collision at insert, and
2) we haven't hit the hash size limit (currently 1*1024*1024 slots), and
3) the number of xfrm_state objects is > the current hash mask

All of this needs some tweaking.

Remove __initdata from "hashdist" so we can use it safely at run time.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/bootmem.h |    2 
 mm/page_alloc.c         |    2 
 net/xfrm/xfrm_state.c   |  200 ++++++++++++++++++++++++++++++++++++++---------
 3 files changed, 165 insertions(+), 39 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 1021f50..e319c64 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -114,7 +114,7 @@ #define HASHDIST_DEFAULT 1
 #else
 #define HASHDIST_DEFAULT 0
 #endif
-extern int __initdata hashdist;		/* Distribute hashes across NUMA nodes? */
+extern int hashdist;		/* Distribute hashes across NUMA nodes? */
 
 
 #endif /* _LINUX_BOOTMEM_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 54a4f53..3b5358a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2363,7 +2363,7 @@ int percpu_pagelist_fraction_sysctl_hand
 	return 0;
 }
 
-__initdata int hashdist = HASHDIST_DEFAULT;
+int hashdist = HASHDIST_DEFAULT;
 
 #ifdef CONFIG_NUMA
 static int __init set_hashdist(char *str)
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 724479f..af3f23e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -18,6 +18,9 @@ #include <net/xfrm.h>
 #include <linux/pfkeyv2.h>
 #include <linux/ipsec.h>
 #include <linux/module.h>
+#include <linux/bootmem.h>
+#include <linux/vmalloc.h>
+#include <linux/cache.h>
 #include <asm/uaccess.h>
 
 struct sock *xfrm_nl;
@@ -38,77 +41,188 @@ EXPORT_SYMBOL(sysctl_xfrm_aevent_rseqth)
 
 static DEFINE_SPINLOCK(xfrm_state_lock);
 
-#define XFRM_DST_HSIZE		1024
-
 /* Hash table to find appropriate SA towards given target (endpoint
  * of tunnel or destination of transport mode) allowed by selector.
  *
  * Main use is finding SA after policy selected tunnel or transport mode.
  * Also, it can be used by ah/esp icmp error handler to find offending SA.
  */
-static struct hlist_head xfrm_state_bydst[XFRM_DST_HSIZE];
-static struct hlist_head xfrm_state_byspi[XFRM_DST_HSIZE];
+static struct hlist_head *xfrm_state_bydst __read_mostly;
+static struct hlist_head *xfrm_state_byspi __read_mostly;
+static unsigned int xfrm_state_hmask __read_mostly;
+static unsigned int xfrm_state_hashmax __read_mostly = 1 * 1024 * 1024;
+static unsigned int xfrm_state_num;
 
-static __inline__
-unsigned __xfrm4_dst_hash(xfrm_address_t *addr)
+static inline unsigned int __xfrm4_dst_hash(xfrm_address_t *addr, unsigned int hmask)
 {
-	unsigned h;
+	unsigned int h;
 	h = ntohl(addr->a4);
-	h = (h ^ (h>>16)) % XFRM_DST_HSIZE;
+	h = (h ^ (h>>16)) & xfrm_state_hmask;
 	return h;
 }
 
-static __inline__
-unsigned __xfrm6_dst_hash(xfrm_address_t *addr)
+static inline unsigned int __xfrm6_dst_hash(xfrm_address_t *addr, unsigned int hmask)
 {
-	unsigned h;
+	unsigned int h;
 	h = ntohl(addr->a6[2]^addr->a6[3]);
-	h = (h ^ (h>>16)) % XFRM_DST_HSIZE;
+	h = (h ^ (h>>16)) & hmask;
 	return h;
 }
 
-static __inline__
-unsigned xfrm_dst_hash(xfrm_address_t *addr, unsigned short family)
+static inline unsigned int __xfrm_dst_hash(xfrm_address_t *addr, unsigned short family,
+					   unsigned int hmask)
 {
 	switch (family) {
 	case AF_INET:
-		return __xfrm4_dst_hash(addr);
+		return __xfrm4_dst_hash(addr, hmask);
 	case AF_INET6:
-		return __xfrm6_dst_hash(addr);
+		return __xfrm6_dst_hash(addr, hmask);
 	}
 	return 0;
 }
 
-static __inline__
-unsigned __xfrm4_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto)
+static inline unsigned int xfrm_dst_hash(xfrm_address_t *addr, unsigned short family)
+{
+	return __xfrm_dst_hash(addr, family, xfrm_state_hmask);
+}
+
+static inline unsigned int __xfrm4_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto,
+					    unsigned int hmask)
 {
-	unsigned h;
+	unsigned int h;
 	h = ntohl(addr->a4^spi^proto);
-	h = (h ^ (h>>10) ^ (h>>20)) % XFRM_DST_HSIZE;
+	h = (h ^ (h>>10) ^ (h>>20)) & hmask;
 	return h;
 }
 
-static __inline__
-unsigned __xfrm6_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto)
+static inline unsigned int __xfrm6_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto,
+					    unsigned int hmask)
 {
-	unsigned h;
+	unsigned int h;
 	h = ntohl(addr->a6[2]^addr->a6[3]^spi^proto);
-	h = (h ^ (h>>10) ^ (h>>20)) % XFRM_DST_HSIZE;
+	h = (h ^ (h>>10) ^ (h>>20)) & hmask;
 	return h;
 }
 
-static __inline__
-unsigned xfrm_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto, unsigned short family)
+static inline unsigned int
+__xfrm_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto, unsigned short family,
+		unsigned int hmask)
 {
 	switch (family) {
 	case AF_INET:
-		return __xfrm4_spi_hash(addr, spi, proto);
+		return __xfrm4_spi_hash(addr, spi, proto, hmask);
 	case AF_INET6:
-		return __xfrm6_spi_hash(addr, spi, proto);
+		return __xfrm6_spi_hash(addr, spi, proto, hmask);
 	}
 	return 0;	/*XXX*/
 }
 
+static inline unsigned int
+xfrm_spi_hash(xfrm_address_t *addr, u32 spi, u8 proto, unsigned short family)
+{
+	return __xfrm_spi_hash(addr, spi, proto, family, xfrm_state_hmask);
+}
+
+static struct hlist_head *xfrm_state_hash_alloc(unsigned int sz)
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
+static void xfrm_state_hash_free(struct hlist_head *n, unsigned int sz)
+{
+	if (sz <= PAGE_SIZE)
+		kfree(n);
+	else if (hashdist)
+		vfree(n);
+	else
+		free_pages((unsigned long)n, get_order(sz));
+}
+
+static void xfrm_hash_transfer(struct hlist_head *list,
+			       struct hlist_head *ndsttable,
+			       struct hlist_head *nspitable,
+			       unsigned int nhashmask)
+{
+	struct hlist_node *entry, *tmp;
+	struct xfrm_state *x;
+
+	hlist_for_each_entry_safe(x, entry, tmp, list, bydst) {
+		unsigned int h;
+
+		h = __xfrm_dst_hash(&x->id.daddr, x->props.family, nhashmask);
+		hlist_add_head(&x->bydst, ndsttable+h);
+
+		h = __xfrm_spi_hash(&x->id.daddr, x->id.spi, x->id.proto,
+				    x->props.family, nhashmask);
+		hlist_add_head(&x->byspi, nspitable+h);
+	}
+}
+
+static unsigned long xfrm_hash_new_size(void)
+{
+	return ((xfrm_state_hmask + 1) << 1) *
+		sizeof(struct hlist_head);
+}
+
+static DEFINE_MUTEX(hash_resize_mutex);
+
+static void xfrm_hash_resize(void *__unused)
+{
+	struct hlist_head *ndst, *nspi, *odst, *ospi;
+	unsigned long nsize;
+	unsigned int nhashmask, ohashmask;
+	int i;
+
+	mutex_lock(&hash_resize_mutex);
+
+	nsize = xfrm_hash_new_size();
+	ndst = xfrm_state_hash_alloc(nsize);
+	if (!ndst)
+		goto out_unlock;
+	nspi = xfrm_state_hash_alloc(nsize);
+	if (!nspi) {
+		xfrm_state_hash_free(ndst, nsize);
+		goto out_unlock;
+	}
+
+	spin_lock_bh(&xfrm_state_lock);
+
+	nhashmask = (nsize / sizeof(struct hlist_head)) - 1U;
+	for (i = xfrm_state_hmask; i >= 0; i--)
+		xfrm_hash_transfer(xfrm_state_bydst+i, ndst, nspi, nhashmask);
+
+	odst = xfrm_state_bydst;
+	ospi = xfrm_state_byspi;
+	ohashmask = xfrm_state_hmask;
+
+	xfrm_state_bydst = ndst;
+	xfrm_state_byspi = nspi;
+	xfrm_state_hmask = nhashmask;
+
+	spin_unlock_bh(&xfrm_state_lock);
+
+	xfrm_state_hash_free(odst, (ohashmask + 1) * sizeof(struct hlist_head));
+	xfrm_state_hash_free(ospi, (ohashmask + 1) * sizeof(struct hlist_head));
+
+out_unlock:
+	mutex_unlock(&hash_resize_mutex);
+}
+
+static DECLARE_WORK(xfrm_hash_work, xfrm_hash_resize, NULL);
+
 DECLARE_WAIT_QUEUE_HEAD(km_waitq);
 EXPORT_SYMBOL(km_waitq);
 
@@ -306,6 +420,7 @@ int __xfrm_state_delete(struct xfrm_stat
 			hlist_del(&x->byspi);
 			__xfrm_state_put(x);
 		}
+		xfrm_state_num--;
 		spin_unlock(&xfrm_state_lock);
 		if (del_timer(&x->timer))
 			__xfrm_state_put(x);
@@ -351,7 +466,7 @@ void xfrm_state_flush(u8 proto)
 	int i;
 
 	spin_lock_bh(&xfrm_state_lock);
-	for (i = 0; i < XFRM_DST_HSIZE; i++) {
+	for (i = 0; i <= xfrm_state_hmask; i++) {
 		struct hlist_node *entry;
 		struct xfrm_state *x;
 restart:
@@ -541,6 +656,13 @@ static void __xfrm_state_insert(struct x
 		xfrm_state_hold(x);
 
 	wake_up(&km_waitq);
+
+	xfrm_state_num++;
+
+	if (x->bydst.next != NULL &&
+	    (xfrm_state_hmask + 1) < xfrm_state_hashmax &&
+	    xfrm_state_num > xfrm_state_hmask)
+		schedule_work(&xfrm_hash_work);
 }
 
 void xfrm_state_insert(struct xfrm_state *x)
@@ -828,7 +950,7 @@ static struct xfrm_state *__xfrm_find_ac
 {
 	int i;
 
-	for (i = 0; i < XFRM_DST_HSIZE; i++) {
+	for (i = 0; i <= xfrm_state_hmask; i++) {
 		struct hlist_node *entry;
 		struct xfrm_state *x;
 
@@ -917,7 +1039,7 @@ int xfrm_state_walk(u8 proto, int (*func
 	int err = 0;
 
 	spin_lock_bh(&xfrm_state_lock);
-	for (i = 0; i < XFRM_DST_HSIZE; i++) {
+	for (i = 0; i <= xfrm_state_hmask; i++) {
 		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
 			if (proto == IPSEC_PROTO_ANY || x->id.proto == proto)
 				count++;
@@ -928,7 +1050,7 @@ int xfrm_state_walk(u8 proto, int (*func
 		goto out;
 	}
 
-	for (i = 0; i < XFRM_DST_HSIZE; i++) {
+	for (i = 0; i <= xfrm_state_hmask; i++) {
 		hlist_for_each_entry(x, entry, xfrm_state_bydst+i, bydst) {
 			if (proto != IPSEC_PROTO_ANY && x->id.proto != proto)
 				continue;
@@ -1355,12 +1477,16 @@ EXPORT_SYMBOL(xfrm_init_state);
  
 void __init xfrm_state_init(void)
 {
-	int i;
+	unsigned int sz;
+
+	sz = sizeof(struct hlist_head) * 8;
+
+	xfrm_state_bydst = xfrm_state_hash_alloc(sz);
+	xfrm_state_byspi = xfrm_state_hash_alloc(sz);
+	if (!xfrm_state_bydst || !xfrm_state_byspi)
+		panic("XFRM: Cannot allocate bydst/byspi hashes.");
+	xfrm_state_hmask = ((sz / sizeof(struct hlist_head)) - 1);
 
-	for (i=0; i<XFRM_DST_HSIZE; i++) {
-		INIT_HLIST_HEAD(&xfrm_state_bydst[i]);
-		INIT_HLIST_HEAD(&xfrm_state_byspi[i]);
-	}
 	INIT_WORK(&xfrm_state_gc_work, xfrm_state_gc_task, NULL);
 }
 
-- 
1.4.2.rc2.g3e042

