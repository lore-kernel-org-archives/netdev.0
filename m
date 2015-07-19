From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: [PATCH v3] jhash: Deinline jhash and jhash2
Date: Sun, 19 Jul 2015 17:36:00 +0200
Message-ID: <1437320160-13290-1-git-send-email-dvlasenk@redhat.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch deinlines jhash and jhash2.

It also removes rhashtable_jhash2(key, length, seed)
because it was merely calling jhash2(key, length, seed).

With this .config: http://busybox.net/~vda/kernel_config,
after deinlining these functions have sizes and callsite counts
as follows:

jhash: 297 bytes, 111 calls
jhash2: 205 bytes, 136 calls

Total size decrease is about 33,000 bytes:

    text     data      bss       dec     hex filename
90663567 17221960 36659200 144544727 89d93d7 vmlinux5
90630370 17221864 36659200 144511434 89d11ca vmlinux.after

Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
CC: Thomas Graf <tgraf@suug.ch>
CC: David Miller <davem@davemloft.net>
CC: Tom Herbert <tom@herbertland.com>
CC: Alexander Duyck <alexander.h.duyck@redhat.com>
CC: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
CC: Herbert Xu <herbert@gondor.apana.org.au>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org
---
Changes in v2: created a new source file, jhash.c
Changes in v3: do not deinline __jhash_nwords;
  use EXPORT_SYMBOL instead of EXPORT_SYMBOL_GPL

 include/linux/jhash.h |  89 +--------------------------------------
 lib/Makefile          |   2 +-
 lib/jhash.c           | 113 ++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/rhashtable.c      |  13 +++---
 4 files changed, 123 insertions(+), 94 deletions(-)
 create mode 100644 lib/jhash.c

diff --git a/include/linux/jhash.h b/include/linux/jhash.h
index 348c6f4..847c1aa 100644
--- a/include/linux/jhash.h
+++ b/include/linux/jhash.h
@@ -57,93 +57,8 @@
 /* An arbitrary initial parameter */
 #define JHASH_INITVAL		0xdeadbeef
 
-/* jhash - hash an arbitrary key
- * @k: sequence of bytes as key
- * @length: the length of the key
- * @initval: the previous hash, or an arbitray value
- *
- * The generic version, hashes an arbitrary sequence of bytes.
- * No alignment or length assumptions are made about the input key.
- *
- * Returns the hash value of the key. The result depends on endianness.
- */
-static inline u32 jhash(const void *key, u32 length, u32 initval)
-{
-	u32 a, b, c;
-	const u8 *k = key;
-
-	/* Set up the internal state */
-	a = b = c = JHASH_INITVAL + length + initval;
-
-	/* All but the last block: affect some 32 bits of (a,b,c) */
-	while (length > 12) {
-		a += __get_unaligned_cpu32(k);
-		b += __get_unaligned_cpu32(k + 4);
-		c += __get_unaligned_cpu32(k + 8);
-		__jhash_mix(a, b, c);
-		length -= 12;
-		k += 12;
-	}
-	/* Last block: affect all 32 bits of (c) */
-	/* All the case statements fall through */
-	switch (length) {
-	case 12: c += (u32)k[11]<<24;
-	case 11: c += (u32)k[10]<<16;
-	case 10: c += (u32)k[9]<<8;
-	case 9:  c += k[8];
-	case 8:  b += (u32)k[7]<<24;
-	case 7:  b += (u32)k[6]<<16;
-	case 6:  b += (u32)k[5]<<8;
-	case 5:  b += k[4];
-	case 4:  a += (u32)k[3]<<24;
-	case 3:  a += (u32)k[2]<<16;
-	case 2:  a += (u32)k[1]<<8;
-	case 1:  a += k[0];
-		 __jhash_final(a, b, c);
-	case 0: /* Nothing left to add */
-		break;
-	}
-
-	return c;
-}
-
-/* jhash2 - hash an array of u32's
- * @k: the key which must be an array of u32's
- * @length: the number of u32's in the key
- * @initval: the previous hash, or an arbitray value
- *
- * Returns the hash value of the key.
- */
-static inline u32 jhash2(const u32 *k, u32 length, u32 initval)
-{
-	u32 a, b, c;
-
-	/* Set up the internal state */
-	a = b = c = JHASH_INITVAL + (length<<2) + initval;
-
-	/* Handle most of the key */
-	while (length > 3) {
-		a += k[0];
-		b += k[1];
-		c += k[2];
-		__jhash_mix(a, b, c);
-		length -= 3;
-		k += 3;
-	}
-
-	/* Handle the last 3 u32's: all the case statements fall through */
-	switch (length) {
-	case 3: c += k[2];
-	case 2: b += k[1];
-	case 1: a += k[0];
-		__jhash_final(a, b, c);
-	case 0:	/* Nothing left to add */
-		break;
-	}
-
-	return c;
-}
-
+u32 jhash(const void *key, u32 length, u32 initval);
+u32 jhash2(const u32 *k, u32 length, u32 initval);
 
 /* __jhash_nwords - hash exactly 3, 2 or 1 word(s) */
 static inline u32 __jhash_nwords(u32 a, u32 b, u32 c, u32 initval)
diff --git a/lib/Makefile b/lib/Makefile
index 6897b52..978be53 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -26,7 +26,7 @@ obj-y += bcd.o div64.o sort.o parser.o halfmd4.o debug_locks.o random32.o \
 	 bust_spinlocks.o kasprintf.o bitmap.o scatterlist.o \
 	 gcd.o lcm.o list_sort.o uuid.o flex_array.o iov_iter.o clz_ctz.o \
 	 bsearch.o find_bit.o llist.o memweight.o kfifo.o \
-	 percpu-refcount.o percpu_ida.o rhashtable.o reciprocal_div.o
+	 percpu-refcount.o percpu_ida.o jhash.o rhashtable.o reciprocal_div.o
 obj-y += string_helpers.o
 obj-$(CONFIG_TEST_STRING_HELPERS) += test-string_helpers.o
 obj-y += hexdump.o
diff --git a/lib/jhash.c b/lib/jhash.c
new file mode 100644
index 0000000..880a7c8
--- /dev/null
+++ b/lib/jhash.c
@@ -0,0 +1,113 @@
+/* Jenkins hash support.
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
+#include <linux/export.h>
+#include <linux/jhash.h>
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
+		a += __get_unaligned_cpu32(k);
+		b += __get_unaligned_cpu32(k + 4);
+		c += __get_unaligned_cpu32(k + 8);
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
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index cc0c697..cf429c5 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -663,11 +663,6 @@ static size_t rounded_hashtable_size(const struct rhashtable_params *params)
 		   (unsigned long)params->min_size);
 }
 
-static u32 rhashtable_jhash2(const void *key, u32 length, u32 seed)
-{
-	return jhash2(key, length, seed);
-}
-
 /**
  * rhashtable_init - initialize a new hash table
  * @ht:		hash table to be initialized
@@ -773,8 +768,14 @@ int rhashtable_init(struct rhashtable *ht,
 		ht->p.hashfn = jhash;
 
 		if (!(ht->key_len & (sizeof(u32) - 1))) {
+			typedef u32 (*hashfunc)(const void *k, u32 length, u32 initval);
+
 			ht->key_len /= sizeof(u32);
-			ht->p.hashfn = rhashtable_jhash2;
+			/*
+			 * jhash2() 1st param is const u32*,
+			 * p.hashfn wants const void*. Hence the cast:
+			 */
+			ht->p.hashfn = (hashfunc)jhash2;
 		}
 	}
 
-- 
1.8.1.4
