From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: [PATCH 2/2] The new jhash implementation
Date: Thu, 25 Nov 2010 14:15:08 +0100
Message-ID: <1290690908-794-3-git-send-email-kadlec@blackhole.kfki.hu>
References: <1290690908-794-1-git-send-email-kadlec@blackhole.kfki.hu>
 <1290690908-794-2-git-send-email-kadlec@blackhole.kfki.hu>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Linus Torvalds <torvalds@osdl.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1290690908-794-2-git-send-email-kadlec@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current jhash.h implements the lookup2() hash function by Bob Jenkins.
However, lookup2() is outdated as Bob wrote a new hash function called
lookup3(). The new hash function

- mixes better than lookup2(): it passes the check that every input bit
  changes every output bit 50% of the time, while lookup2() failed it.
- performs better: compiled with -O2 on Core2 Duo, lookup3() 20-40% faster
  than lookup2() depending on the key length.

The patch replaces the lookup2() implementation of the 'jhash*'
functions with that of lookup3().

You can read a longer comparison of the two and other hash functions at
http://burtleburtle.net/bob/hash/doobs.html.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/jhash.h |  136 +++-----------------------------------------
 lib/Makefile          |    2 +-
 lib/jhash.c           |  153 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 162 insertions(+), 129 deletions(-)
 create mode 100644 lib/jhash.c

diff --git a/include/linux/jhash.h b/include/linux/jhash.h
index ced1159..ca69ac3 100644
--- a/include/linux/jhash.h
+++ b/include/linux/jhash.h
@@ -1,134 +1,14 @@
 #ifndef _LINUX_JHASH_H
 #define _LINUX_JHASH_H
 
-/* jhash.h: Jenkins hash support.
- *
- * Copyright (C) 1996 Bob Jenkins (bob_jenkins@burtleburtle.net)
- *
- * http://burtleburtle.net/bob/hash/
- *
- * These are the credits from Bob's sources:
- *
- * lookup2.c, by Bob Jenkins, December 1996, Public Domain.
- * hash(), hash2(), hash3, and mix() are externally useful functions.
- * Routines to test the hash are included if SELF_TEST is defined.
- * You can use this free for any purpose.  It has no warranty.
- *
- * Copyright (C) 2003 David S. Miller (davem@redhat.com)
- *
- * I've modified Bob's hash to be useful in the Linux kernel, and
- * any bugs present are surely my fault.  -DaveM
- */
-
-/* NOTE: Arguments are modified. */
-#define __jhash_mix(a, b, c) \
-{ \
-  a -= b; a -= c; a ^= (c>>13); \
-  b -= c; b -= a; b ^= (a<<8); \
-  c -= a; c -= b; c ^= (b>>13); \
-  a -= b; a -= c; a ^= (c>>12);  \
-  b -= c; b -= a; b ^= (a<<16); \
-  c -= a; c -= b; c ^= (b>>5); \
-  a -= b; a -= c; a ^= (c>>3);  \
-  b -= c; b -= a; b ^= (a<<10); \
-  c -= a; c -= b; c ^= (b>>15); \
-}
-
-/* The golden ration: an arbitrary value */
-#define JHASH_GOLDEN_RATIO	0x9e3779b9
-
-/* The most generic version, hashes an arbitrary sequence
- * of bytes.  No alignment or length assumptions are made about
- * the input key.
- */
-static inline u32 jhash(const void *key, u32 length, u32 initval)
-{
-	u32 a, b, c, len;
-	const u8 *k = key;
-
-	len = length;
-	a = b = JHASH_GOLDEN_RATIO;
-	c = initval;
-
-	while (len >= 12) {
-		a += (k[0] +((u32)k[1]<<8) +((u32)k[2]<<16) +((u32)k[3]<<24));
-		b += (k[4] +((u32)k[5]<<8) +((u32)k[6]<<16) +((u32)k[7]<<24));
-		c += (k[8] +((u32)k[9]<<8) +((u32)k[10]<<16)+((u32)k[11]<<24));
-
-		__jhash_mix(a,b,c);
-
-		k += 12;
-		len -= 12;
-	}
-
-	c += length;
-	switch (len) {
-	case 11: c += ((u32)k[10]<<24);
-	case 10: c += ((u32)k[9]<<16);
-	case 9 : c += ((u32)k[8]<<8);
-	case 8 : b += ((u32)k[7]<<24);
-	case 7 : b += ((u32)k[6]<<16);
-	case 6 : b += ((u32)k[5]<<8);
-	case 5 : b += k[4];
-	case 4 : a += ((u32)k[3]<<24);
-	case 3 : a += ((u32)k[2]<<16);
-	case 2 : a += ((u32)k[1]<<8);
-	case 1 : a += k[0];
-	};
-
-	__jhash_mix(a,b,c);
-
-	return c;
-}
-
-/* A special optimized version that handles 1 or more of u32s.
- * The length parameter here is the number of u32s in the key.
- */
-static inline u32 jhash2(const u32 *k, u32 length, u32 initval)
-{
-	u32 a, b, c, len;
-
-	a = b = JHASH_GOLDEN_RATIO;
-	c = initval;
-	len = length;
-
-	while (len >= 3) {
-		a += k[0];
-		b += k[1];
-		c += k[2];
-		__jhash_mix(a, b, c);
-		k += 3; len -= 3;
-	}
-
-	c += length * 4;
-
-	switch (len) {
-	case 2 : b += k[1];
-	case 1 : a += k[0];
-	};
-
-	__jhash_mix(a,b,c);
-
-	return c;
-}
-
-
-/* A special ultra-optimized versions that knows they are hashing exactly
- * 3, 2 or 1 word(s).
- *
- * NOTE: In particular the "c += length; __jhash_mix(a,b,c);" normally
- *       done at the end is not done here.
- */
-static inline u32 jhash_3words(u32 a, u32 b, u32 c, u32 initval)
-{
-	a += JHASH_GOLDEN_RATIO;
-	b += JHASH_GOLDEN_RATIO;
-	c += initval;
-
-	__jhash_mix(a, b, c);
-
-	return c;
-}
+/* Best hash sizes are of power of two */
+#define jhash_size(n)   ((u32)1<<(n))
+/* Mask the hash value, i.e (value & jhash_mask(n)) instead of (value % n) */
+#define jhash_mask(n)   (jhash_size(n)-1)
+
+extern u32 jhash(const void *key, u32 length, u32 initval);
+extern u32 jhash2(const u32 *k, u32 length, u32 initval);
+extern u32 jhash_3words(u32 a, u32 b, u32 c, u32 initval);
 
 static inline u32 jhash_2words(u32 a, u32 b, u32 initval)
 {
diff --git a/lib/Makefile b/lib/Makefile
index e6a3763..a1a4932 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -10,7 +10,7 @@ endif
 lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 rbtree.o radix-tree.o dump_stack.o \
 	 idr.o int_sqrt.o extable.o prio_tree.o \
-	 sha1.o irq_regs.o reciprocal_div.o argv_split.o \
+	 jhash.o sha1.o irq_regs.o reciprocal_div.o argv_split.o \
 	 proportions.o prio_heap.o ratelimit.o show_mem.o \
 	 is_single_threaded.o plist.o decompress.o flex_array.o
 
diff --git a/lib/jhash.c b/lib/jhash.c
new file mode 100644
index 0000000..593cc77
--- /dev/null
+++ b/lib/jhash.c
@@ -0,0 +1,153 @@
+/* jhash.c: Jenkins hash support.
+ *
+ * Copyright (C) 2006. Bob Jenkins (bob_jenkins@burtleburtle.net)
+ *
+ * http://burtleburtle.net/bob/hash/
+ *
+ * These are the credits from Bob's sources:
+ *
+ * lookup3.c, by Bob Jenkins, May 2006, Public Domain.
+ *
+ * These are functions for producing 32-bit hashes for hash table lookup.
+ * hashword(), hashlittle(), hashlittle2(), hashbig(), mix(), and final()
+ * are externally useful functions.  Routines to test the hash are included
+ * if SELF_TEST is defined.  You can use this free for any purpose.  It's in
+ * the public domain.  It has no warranty.
+ *
+ * Copyright (C) 2009-2010 Jozsef Kadlecsik (kadlec@blackhole.kfki.hu)
+ *
+ * I've modified Bob's hash to be useful in the Linux kernel, and
+ * any bugs present are my fault.
+ * Jozsef
+ */
+#include <linux/bitops.h>
+#include <linux/module.h>
+#include <linux/jhash.h>
+
+/* __jhash_mix -- mix 3 32-bit values reversibly. */
+#define __jhash_mix(a, b, c)			\
+{						\
+	a -= c;  a ^= rol32(c, 4);  c += b;	\
+	b -= a;  b ^= rol32(a, 6);  a += c;	\
+	c -= b;  c ^= rol32(b, 8);  b += a;	\
+	a -= c;  a ^= rol32(c, 16); c += b;	\
+	b -= a;  b ^= rol32(a, 19); a += c;	\
+	c -= b;  c ^= rol32(b, 4);  b += a;	\
+}
+
+/* __jhash_final - final mixing of 3 32-bit values (a,b,c) into c */
+#define __jhash_final(a, b, c)			\
+{						\
+	c ^= b; c -= rol32(b, 14);		\
+	a ^= c; a -= rol32(c, 11);		\
+	b ^= a; b -= rol32(a, 25);		\
+	c ^= b; c -= rol32(b, 16);		\
+	a ^= c; a -= rol32(c, 4);		\
+	b ^= a; b -= rol32(a, 14);		\
+	c ^= b; c -= rol32(b, 24);		\
+}
+
+/* An arbitrary initial parameter */
+#define JHASH_INITVAL		0xdeadbeef
+
+/* jhash - hash an arbitrary key
+ * @k: sequence of bytes as key
+ * @length: the length of the key
+ * @initval: the previous hash, or an arbitray value
+ *
+ * The generic version, hashes an arbitrary sequence of bytes.
+ * No alignment or length assumptions are made about the input key.
+ *
+ * Returns the hash value of the key. The result depends on endianness.
+ */
+u32 jhash(const void *key, u32 length, u32 initval)
+{
+	u32 a, b, c;
+	const u8 *k = key;
+
+	/* Set up the internal state */
+	a = b = c = JHASH_INITVAL + length + initval;
+
+	/* All but the last block: affect some 32 bits of (a,b,c) */
+	while (length > 12) {
+		a += k[0] + ((u32)k[1]<<8) + ((u32)k[2]<<16) + ((u32)k[3]<<24);
+		b += k[4] + ((u32)k[5]<<8) + ((u32)k[6]<<16) + ((u32)k[7]<<24);
+		c += k[8] + ((u32)k[9]<<8) + ((u32)k[10]<<16) + ((u32)k[11]<<24);
+		__jhash_mix(a, b, c);
+		length -= 12;
+		k += 12;
+	}
+	/* Last block: affect all 32 bits of (c) */
+	/* All the case statements fall through */
+	switch (length) {
+	case 12: c += (u32)k[11]<<24;
+	case 11: c += (u32)k[10]<<16;
+	case 10: c += (u32)k[9]<<8;
+	case 9:  c += k[8];
+	case 8:  b += (u32)k[7]<<24;
+	case 7:  b += (u32)k[6]<<16;
+	case 6:  b += (u32)k[5]<<8;
+	case 5:  b += k[4];
+	case 4:  a += (u32)k[3]<<24;
+	case 3:  a += (u32)k[2]<<16;
+	case 2:  a += (u32)k[1]<<8;
+	case 1:  a += k[0];
+		 __jhash_final(a, b, c);
+	case 0: /* Nothing left to add */
+		break;
+	}
+
+	return c;
+}
+EXPORT_SYMBOL(jhash);
+
+/* jhash2 - hash an array of u32's
+ * @k: the key which must be an array of u32's
+ * @length: the number of u32's in the key
+ * @initval: the previous hash, or an arbitray value
+ *
+ * Returns the hash value of the key.
+ */
+u32 jhash2(const u32 *k, u32 length, u32 initval)
+{
+	u32 a, b, c;
+
+	/* Set up the internal state */
+	a = b = c = JHASH_INITVAL + (length<<2) + initval;
+
+	/* Handle most of the key */
+	while (length > 3) {
+		a += k[0];
+		b += k[1];
+		c += k[2];
+		__jhash_mix(a, b, c);
+		length -= 3;
+		k += 3;
+	}
+
+	/* Handle the last 3 u32's: all the case statements fall through */
+	switch (length) {
+	case 3: c += k[2];
+	case 2: b += k[1];
+	case 1: a += k[0];
+		__jhash_final(a, b, c);
+	case 0:	/* Nothing left to add */
+		break;
+	}
+
+	return c;
+}
+EXPORT_SYMBOL(jhash2);
+
+/* jhash_3words - hash exactly 3, 2 or 1 word(s) */
+u32 jhash_3words(u32 a, u32 b, u32 c, u32 initval)
+{
+	a += JHASH_INITVAL;
+	b += JHASH_INITVAL;
+	c += initval;
+
+	__jhash_mix(a, b, c);
+
+	return c;
+}
+EXPORT_SYMBOL(jhash_3words);
-- 
1.7.0.4

