From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] Update jhash.h with the new version of Jenkins' hash
Date: Tue, 10 Feb 2009 23:03:11 +0100 (CET)
Message-ID: <alpine.DEB.2.00.0902102224510.10665@blackhole.kfki.hu>
References: <alpine.DEB.2.00.0902102026060.10299@blackhole.kfki.hu> <4991EF7B.90004@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4991EF7B.90004@cisco.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Feb 2009, Scott Feldman wrote:

> Jozsef Kadlecsik wrote:
> > The patch replaces the lookup2() implementation of the 'jhash*' functions
> > with that of lookup3().
> 
> Should the lookup3() be added to rather than replacing lookup2()?  In case
> some hardware vendor used the lookup2() version for weird things like flow
> classification.

Do you imagine a case where a system with lookup3() communicates with 
another one with lookup2() and they want to exchange data identified by 
the hash keys? But the normal approach is to use a random seed (initval), 
so even two systems with lookup2() won't generate the same hash value for 
the same key.

Grepping through the whole kernel, at a lot of places jhash used with zero 
initval. :-(.

Sure, it's safer to add a new header file instead, see below.
 
> >  /* The golden ration: an arbitrary value */
> > -#define JHASH_GOLDEN_RATIO	0x9e3779b9
> > +#define JHASH_GOLDEN_RATIO	0xdeadbeef
> 
> The #define seems mis-named now.

It's the new arbitrary value, taken from the original source :-).
----
The current jhash.h implements the lookup2() hash function by Bob Jenkins.
However, lookup2() is outdated as Bob wrote a new hash function called
lookup3(). The new hash function

- mixes better than lookup2(): it passes the check that every input bit
  changes every output bit 50% of the time, while lookup2() failed it.
- performs better: compiled with -O2 on Core2 Duo, lookup3() 20-40% faster
  than lookup2() depending on the key length.

The patch adds jhash3.h which implements the lookup3() function(s) for
the Linux kernel.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/jhash3.h |  157 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 157 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/jhash3.h

diff --git a/include/linux/jhash3.h b/include/linux/jhash3.h
new file mode 100644
index 0000000..99a203d
--- /dev/null
+++ b/include/linux/jhash3.h
@@ -0,0 +1,157 @@
+#ifndef _LINUX_JHASH3_H
+#define _LINUX_JHASH3_H
+
+/* jhash3.h: Jenkins hash support.
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
+ * Copyright (C) 2009 Jozsef Kadlecsik (kadlec@blackhole.kfki.hu)
+ *
+ * I've modified Bob's hash to be useful in the Linux kernel, and
+ * any bugs present are my fault.  Jozsef
+ */
+
+#define __rot(x,k) (((x)<<(k)) | ((x)>>(32-(k))))
+
+/* __jhash3_mix - mix 3 32-bit values reversibly. */
+#define __jhash3_mix(a,b,c) \
+{ \
+  a -= c;  a ^= __rot(c, 4);  c += b; \
+  b -= a;  b ^= __rot(a, 6);  a += c; \
+  c -= b;  c ^= __rot(b, 8);  b += a; \
+  a -= c;  a ^= __rot(c,16);  c += b; \
+  b -= a;  b ^= __rot(a,19);  a += c; \
+  c -= b;  c ^= __rot(b, 4);  b += a; \
+}
+
+/* __jhash3_final - final mixing of 3 32-bit values (a,b,c) into c */
+#define __jhash3_final(a,b,c) \
+{ \
+  c ^= b; c -= __rot(b,14); \
+  a ^= c; a -= __rot(c,11); \
+  b ^= a; b -= __rot(a,25); \
+  c ^= b; c -= __rot(b,16); \
+  a ^= c; a -= __rot(c,4);  \
+  b ^= a; b -= __rot(a,14); \
+  c ^= b; c -= __rot(b,24); \
+}
+
+/* The golden ration: an arbitrary value */
+#define JHASH3_GOLDEN_RATIO	0xdeadbeef
+
+/* The most generic version, hashes an arbitrary sequence
+ * of bytes.  No alignment or length assumptions are made about
+ * the input key. The result depends on endianness.
+ */
+static inline u32 jhash3(const void *key, u32 length, u32 initval)
+{
+	u32 a,b,c;
+	const u8 *k = key;
+
+	/* Set up the internal state */
+	a = b = c = JHASH3_GOLDEN_RATIO + length + initval;
+
+	/* all but the last block: affect some 32 bits of (a,b,c) */
+	while (length > 12) {
+    		a += (k[0] + ((u32)k[1]<<8) + ((u32)k[2]<<16) + ((u32)k[3]<<24));
+		b += (k[4] + ((u32)k[5]<<8) + ((u32)k[6]<<16) + ((u32)k[7]<<24));
+		c += (k[8] + ((u32)k[9]<<8) + ((u32)k[10]<<16) + ((u32)k[11]<<24));
+		__jhash3_mix(a, b, c);
+		length -= 12;
+		k += 12;
+	}
+
+	/* last block: affect all 32 bits of (c) */
+	/* all the case statements fall through */
+	switch (length) {
+	case 12: c += (u32)k[11]<<24;
+	case 11: c += (u32)k[10]<<16;
+	case 10: c += (u32)k[9]<<8;
+	case 9 : c += k[8];
+	case 8 : b += (u32)k[7]<<24;
+	case 7 : b += (u32)k[6]<<16;
+	case 6 : b += (u32)k[5]<<8;
+	case 5 : b += k[4];
+	case 4 : a += (u32)k[3]<<24;
+	case 3 : a += (u32)k[2]<<16;
+	case 2 : a += (u32)k[1]<<8;
+	case 1 : a += k[0];
+		__jhash3_final(a, b, c);
+	case 0 :
+		break;
+	}
+
+	return c;
+}
+
+/* A special optimized version that handles 1 or more of u32s.
+ * The length parameter here is the number of u32s in the key.
+ */
+static inline u32 jhash3_words(const u32 *k, u32 length, u32 initval)
+{
+	u32 a, b, c;
+
+	/* Set up the internal state */
+	a = b = c = JHASH3_GOLDEN_RATIO + (length<<2) + initval;
+
+	/* handle most of the key */
+	while (length > 3) {
+		a += k[0];
+		b += k[1];
+		c += k[2];
+		__jhash3_mix(a, b, c);
+		length -= 3;
+		k += 3;
+	}
+
+	/* handle the last 3 u32's */
+	/* all the case statements fall through */ 
+	switch (length) {
+	case 3: c += k[2];
+	case 2: b += k[1];
+	case 1: a += k[0];
+		__jhash3_final(a, b, c);
+	case 0:     /* case 0: nothing left to add */
+		break;
+	}
+
+	return c;
+}
+
+/* A special ultra-optimized versions that knows they are hashing exactly
+ * 3, 2 or 1 word(s).
+ */
+static inline u32 jhash3_3words(u32 a, u32 b, u32 c, u32 initval)
+{
+	a += JHASH3_GOLDEN_RATIO + initval;
+	b += JHASH3_GOLDEN_RATIO + initval;
+	c += JHASH3_GOLDEN_RATIO + initval;
+
+	__jhash3_final(a, b, c);
+
+	return c;
+}
+
+static inline u32 jhash3_2words(u32 a, u32 b, u32 initval)
+{
+	return jhash3_3words(0, a, b, initval);
+}
+
+static inline u32 jhash3_1word(u32 a, u32 initval)
+{
+	return jhash3_3words(0, 0, a, initval);
+}
+
+#endif /* _LINUX_JHASH3_H */
-- 
1.5.4.3

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
