From: Kan Liang <kan.liang@intel.com>
Subject: [PATCH V8 1/8] lib/bitmap.c: conversion routines to/from u32 array
Date: Thu, 18 Feb 2016 07:39:49 -0500
Message-ID: <1455799196-8947-2-git-send-email-kan.liang@intel.com>
References: <1455799196-8947-1-git-send-email-kan.liang@intel.com>
Cc: andi@firstfloor.org, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, f.fainelli@gmail.com,
	alexander.duyck@gmail.com, jeffrey.t.kirsher@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, decot@googlers.com, Kan Liang <kan.liang@intel.com>
To: netdev@vger.kernel.org, davem@davemloft.net, bwh@kernel.org,
	ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40499 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1947706AbcBRUAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 15:00:14 -0500
In-Reply-To: <1455799196-8947-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>

Aimed at transferring bitmaps to/from user-space in a 32/64-bit agnostic
way.

Tested:
  unit tests (next patch) on qemu i386, x86_64, ppc, ppc64 BE and LE,
  ARM.

Signed-off-by: David Decotigny <decot@googlers.com>
Reviewed-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/bitmap.h | 10 ++++++
 lib/bitmap.c           | 89 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 99 insertions(+)

diff --git a/include/linux/bitmap.h b/include/linux/bitmap.h
index 9653fdb..e9b0b9a 100644
--- a/include/linux/bitmap.h
+++ b/include/linux/bitmap.h
@@ -59,6 +59,8 @@
  * bitmap_find_free_region(bitmap, bits, order)	Find and allocate bit region
  * bitmap_release_region(bitmap, pos, order)	Free specified bit region
  * bitmap_allocate_region(bitmap, pos, order)	Allocate specified bit region
+ * bitmap_from_u32array(dst, nbits, buf, nwords) *dst = *buf (nwords 32b words)
+ * bitmap_to_u32array(buf, nwords, src, nbits)	*buf = *dst (nwords 32b words)
  */
 
 /*
@@ -163,6 +165,14 @@ extern void bitmap_fold(unsigned long *dst, const unsigned long *orig,
 extern int bitmap_find_free_region(unsigned long *bitmap, unsigned int bits, int order);
 extern void bitmap_release_region(unsigned long *bitmap, unsigned int pos, int order);
 extern int bitmap_allocate_region(unsigned long *bitmap, unsigned int pos, int order);
+extern unsigned int bitmap_from_u32array(unsigned long *bitmap,
+					 unsigned int nbits,
+					 const u32 *buf,
+					 unsigned int nwords);
+extern unsigned int bitmap_to_u32array(u32 *buf,
+				       unsigned int nwords,
+				       const unsigned long *bitmap,
+				       unsigned int nbits);
 #ifdef __BIG_ENDIAN
 extern void bitmap_copy_le(unsigned long *dst, const unsigned long *src, unsigned int nbits);
 #else
diff --git a/lib/bitmap.c b/lib/bitmap.c
index 8148143..c66da50 100644
--- a/lib/bitmap.c
+++ b/lib/bitmap.c
@@ -12,6 +12,8 @@
 #include <linux/bitmap.h>
 #include <linux/bitops.h>
 #include <linux/bug.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
 
 #include <asm/page.h>
 #include <asm/uaccess.h>
@@ -1060,6 +1062,93 @@ int bitmap_allocate_region(unsigned long *bitmap, unsigned int pos, int order)
 EXPORT_SYMBOL(bitmap_allocate_region);
 
 /**
+ * bitmap_from_u32array - copy the contents of a u32 array of bits to bitmap
+ *	@bitmap: array of unsigned longs, the destination bitmap, non NULL
+ *	@nbits: number of bits in @bitmap
+ *	@buf: array of u32 (in host byte order), the source bitmap, non NULL
+ *	@nwords: number of u32 words in @buf
+ *
+ * copy min(nbits, 32*nwords) bits from @buf to @bitmap, remaining
+ * bits between nword and nbits in @bitmap (if any) are cleared. In
+ * last word of @bitmap, the bits beyond nbits (if any) are kept
+ * unchanged.
+ *
+ * Return the number of bits effectively copied.
+ */
+unsigned int
+bitmap_from_u32array(unsigned long *bitmap, unsigned int nbits,
+		     const u32 *buf, unsigned int nwords)
+{
+	unsigned int dst_idx, src_idx;
+
+	for (src_idx = dst_idx = 0; dst_idx < BITS_TO_LONGS(nbits); ++dst_idx) {
+		unsigned long part = 0;
+
+		if (src_idx < nwords)
+			part = buf[src_idx++];
+
+#if BITS_PER_LONG == 64
+		if (src_idx < nwords)
+			part |= ((unsigned long) buf[src_idx++]) << 32;
+#endif
+
+		if (dst_idx < nbits/BITS_PER_LONG)
+			bitmap[dst_idx] = part;
+		else {
+			unsigned long mask = BITMAP_LAST_WORD_MASK(nbits);
+
+			bitmap[dst_idx] = (bitmap[dst_idx] & ~mask)
+				| (part & mask);
+		}
+	}
+
+	return min_t(unsigned int, nbits, 32*nwords);
+}
+EXPORT_SYMBOL(bitmap_from_u32array);
+
+/**
+ * bitmap_to_u32array - copy the contents of bitmap to a u32 array of bits
+ *	@buf: array of u32 (in host byte order), the dest bitmap, non NULL
+ *	@nwords: number of u32 words in @buf
+ *	@bitmap: array of unsigned longs, the source bitmap, non NULL
+ *	@nbits: number of bits in @bitmap
+ *
+ * copy min(nbits, 32*nwords) bits from @bitmap to @buf. Remaining
+ * bits after nbits in @buf (if any) are cleared.
+ *
+ * Return the number of bits effectively copied.
+ */
+unsigned int
+bitmap_to_u32array(u32 *buf, unsigned int nwords,
+		   const unsigned long *bitmap, unsigned int nbits)
+{
+	unsigned int dst_idx = 0, src_idx = 0;
+
+	while (dst_idx < nwords) {
+		unsigned long part = 0;
+
+		if (src_idx < BITS_TO_LONGS(nbits)) {
+			part = bitmap[src_idx];
+			if (src_idx >= nbits/BITS_PER_LONG)
+				part &= BITMAP_LAST_WORD_MASK(nbits);
+			src_idx++;
+		}
+
+		buf[dst_idx++] = part & 0xffffffffUL;
+
+#if BITS_PER_LONG == 64
+		if (dst_idx < nwords) {
+			part >>= 32;
+			buf[dst_idx++] = part & 0xffffffffUL;
+		}
+#endif
+	}
+
+	return min_t(unsigned int, nbits, 32*nwords);
+}
+EXPORT_SYMBOL(bitmap_to_u32array);
+
+/**
  * bitmap_copy_le - copy a bitmap, putting the bits into little-endian order.
  * @dst:   destination buffer
  * @src:   bitmap to copy
-- 
1.8.3.1
