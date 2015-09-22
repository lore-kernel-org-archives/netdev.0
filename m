From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 9/9] powerpc: optimise csum_partial() call when len is
 constant
Date: Tue, 22 Sep 2015 16:34:36 +0200 (CEST)
Message-ID: <df593a56e52ccd24b758b9d40ae3b414cb4e5372.1442876807.git.christophe.leroy@c-s.fr>
References: <cover.1442876807.git.christophe.leroy@c-s.fr>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, scottwood@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1442876807.git.christophe.leroy@c-s.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

csum_partial is often called for small fixed length packets
for which it is suboptimal to use the generic csum_partial()
function.

For instance, in my configuration, I got:
* One place calling it with constant len 4
* Seven places calling it with constant len 8
* Three places calling it with constant len 14
* One place calling it with constant len 20
* One place calling it with constant len 24
* One place calling it with constant len 32

This patch renames csum_partial() to __csum_partial() and
implements csum_partial() as a wrapper inline function which
* uses csum_add() for small 16bits multiple constant length
* uses ip_fast_csum() for other 32bits multiple constant
* uses __csum_partial() in all other cases

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/include/asm/checksum.h | 80 ++++++++++++++++++++++++++-----------
 arch/powerpc/lib/checksum_32.S      |  4 +-
 arch/powerpc/lib/checksum_64.S      |  4 +-
 arch/powerpc/lib/ppc_ksyms.c        |  2 +-
 4 files changed, 62 insertions(+), 28 deletions(-)

diff --git a/arch/powerpc/include/asm/checksum.h b/arch/powerpc/include/asm/checksum.h
index f8a9704..25c4657f 100644
--- a/arch/powerpc/include/asm/checksum.h
+++ b/arch/powerpc/include/asm/checksum.h
@@ -13,20 +13,6 @@
 #include <asm-generic/checksum.h>
 #else
 /*
- * computes the checksum of a memory block at buff, length len,
- * and adds in "sum" (32-bit)
- *
- * returns a 32-bit number suitable for feeding into itself
- * or csum_tcpudp_magic
- *
- * this function must be called with even lengths, except
- * for the last fragment, which may be odd
- *
- * it's best to have buff aligned on a 32-bit boundary
- */
-extern __wsum csum_partial(const void *buff, int len, __wsum sum);
-
-/*
  * Computes the checksum of a memory block at src, length len,
  * and adds in "sum" (32-bit), while copying the block to dst.
  * If an access exception occurs on src or dst, it stores -EFAULT
@@ -67,15 +53,6 @@ static inline __sum16 csum_fold(__wsum sum)
 	return (__force __sum16)(~((__force u32)sum + tmp) >> 16);
 }
 
-/*
- * this routine is used for miscellaneous IP-like checksums, mainly
- * in icmp.c
- */
-static inline __sum16 ip_compute_csum(const void *buff, int len)
-{
-	return csum_fold(csum_partial(buff, len, 0));
-}
-
 static inline __wsum csum_tcpudp_nofold(__be32 saddr, __be32 daddr,
                                      unsigned short len,
                                      unsigned short proto,
@@ -175,6 +152,63 @@ static inline __sum16 ip_fast_csum(const void *iph, unsigned int ihl)
 	return csum_fold(ip_fast_csum_nofold(iph, ihl));
 }
 
+/*
+ * computes the checksum of a memory block at buff, length len,
+ * and adds in "sum" (32-bit)
+ *
+ * returns a 32-bit number suitable for feeding into itself
+ * or csum_tcpudp_magic
+ *
+ * this function must be called with even lengths, except
+ * for the last fragment, which may be odd
+ *
+ * it's best to have buff aligned on a 32-bit boundary
+ */
+__wsum __csum_partial(const void *buff, int len, __wsum sum);
+
+static inline __wsum csum_partial(const void *buff, int len, __wsum sum)
+{
+	if (__builtin_constant_p(len) && len == 0)
+		return sum;
+
+	if (__builtin_constant_p(len) && len <= 16 && (len & 1) == 0) {
+		__wsum sum1;
+
+		if (len == 2)
+			sum1 = (__force u32)*(u16 *)buff;
+		if (len >= 4)
+			sum1 = *(u32 *)buff;
+		if (len == 6)
+			sum1 = csum_add(sum1, (__force u32)*(u16 *)(buff + 4));
+		if (len >= 8)
+			sum1 = csum_add(sum1, *(u32 *)(buff + 4));
+		if (len == 10)
+			sum1 = csum_add(sum1, (__force u32)*(u16 *)(buff + 8));
+		if (len >= 12)
+			sum1 = csum_add(sum1, *(u32 *)(buff + 8));
+		if (len == 14)
+			sum1 = csum_add(sum1, (__force u32)*(u16 *)(buff + 12));
+		if (len >= 16)
+			sum1 = csum_add(sum1, *(u32 *)(buff + 12));
+
+		sum = csum_add(sum1, sum);
+	} else if (__builtin_constant_p(len) && (len & 3) == 0) {
+		sum = csum_add(ip_fast_csum_nofold(buff, len >> 2), sum);
+	} else {
+		sum = __csum_partial(buff, len, sum);
+	}
+	return sum;
+}
+
+/*
+ * this routine is used for miscellaneous IP-like checksums, mainly
+ * in icmp.c
+ */
+static inline __sum16 ip_compute_csum(const void *buff, int len)
+{
+	return csum_fold(csum_partial(buff, len, 0));
+}
+
 #endif
 #endif /* __KERNEL__ */
 #endif
diff --git a/arch/powerpc/lib/checksum_32.S b/arch/powerpc/lib/checksum_32.S
index 0d34f47..043d0088 100644
--- a/arch/powerpc/lib/checksum_32.S
+++ b/arch/powerpc/lib/checksum_32.S
@@ -24,9 +24,9 @@
  * computes the checksum of a memory block at buff, length len,
  * and adds in "sum" (32-bit)
  *
- * csum_partial(buff, len, sum)
+ * do_csum_partial(buff, len, sum)
  */
-_GLOBAL(csum_partial)
+_GLOBAL(__csum_partial)
 	subi	r3,r3,4
 	srawi.	r6,r4,2		/* Divide len by 4 and also clear carry */
 	beq	3f		/* if we're doing < 4 bytes */
diff --git a/arch/powerpc/lib/checksum_64.S b/arch/powerpc/lib/checksum_64.S
index f53f4ab..4ab562d 100644
--- a/arch/powerpc/lib/checksum_64.S
+++ b/arch/powerpc/lib/checksum_64.S
@@ -21,9 +21,9 @@
  * Computes the checksum of a memory block at buff, length len,
  * and adds in "sum" (32-bit).
  *
- * csum_partial(r3=buff, r4=len, r5=sum)
+ * do_csum_partial(r3=buff, r4=len, r5=sum)
  */
-_GLOBAL(csum_partial)
+_GLOBAL(__csum_partial)
 	addic	r0,r5,0			/* clear carry */
 
 	srdi.	r6,r4,3			/* less than 8 bytes? */
diff --git a/arch/powerpc/lib/ppc_ksyms.c b/arch/powerpc/lib/ppc_ksyms.c
index 8cd5c0b..c422812 100644
--- a/arch/powerpc/lib/ppc_ksyms.c
+++ b/arch/powerpc/lib/ppc_ksyms.c
@@ -17,7 +17,7 @@ EXPORT_SYMBOL(strcmp);
 EXPORT_SYMBOL(strncmp);
 
 #ifndef CONFIG_GENERIC_CSUM
-EXPORT_SYMBOL(csum_partial);
+EXPORT_SYMBOL(__csum_partial);
 EXPORT_SYMBOL(csum_partial_copy_generic);
 #endif
 
-- 
2.1.0
