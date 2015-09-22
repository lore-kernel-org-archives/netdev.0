From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 4/9] powerpc: inline ip_fast_csum()
Date: Tue, 22 Sep 2015 16:34:25 +0200 (CEST)
Message-ID: <807dbc9449077e36752c649c09ae1c0d70e45254.1442876807.git.christophe.leroy@c-s.fr>
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

In several architectures, ip_fast_csum() is inlined
There are functions like ip_send_check() which do nothing
much more than calling ip_fast_csum().
Inlining ip_fast_csum() allows the compiler to optimise better

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/include/asm/checksum.h | 46 +++++++++++++++++++++++++++++++------
 arch/powerpc/lib/checksum_32.S      | 21 -----------------
 arch/powerpc/lib/checksum_64.S      | 27 ----------------------
 arch/powerpc/lib/ppc_ksyms.c        |  1 -
 4 files changed, 39 insertions(+), 56 deletions(-)

diff --git a/arch/powerpc/include/asm/checksum.h b/arch/powerpc/include/asm/checksum.h
index afa6722..56deea8 100644
--- a/arch/powerpc/include/asm/checksum.h
+++ b/arch/powerpc/include/asm/checksum.h
@@ -9,16 +9,9 @@
  * 2 of the License, or (at your option) any later version.
  */
 
-/*
- * This is a version of ip_compute_csum() optimized for IP headers,
- * which always checksum on 4 octet boundaries.  ihl is the number
- * of 32-bit words and is always >= 5.
- */
 #ifdef CONFIG_GENERIC_CSUM
 #include <asm-generic/checksum.h>
 #else
-extern __sum16 ip_fast_csum(const void *iph, unsigned int ihl);
-
 /*
  * computes the checksum of a memory block at buff, length len,
  * and adds in "sum" (32-bit)
@@ -137,6 +130,45 @@ static inline __wsum csum_add(__wsum csum, __wsum addend)
 #endif
 }
 
+/*
+ * This is a version of ip_compute_csum() optimized for IP headers,
+ * which always checksum on 4 octet boundaries.  ihl is the number
+ * of 32-bit words and is always >= 5.
+ */
+static inline __wsum ip_fast_csum_nofold(const void *iph, unsigned int ihl)
+{
+	u32 *ptr = (u32 *)iph + 1;
+#ifdef __powerpc64__
+	unsigned int i;
+	u64 s = *(__force u32 *)iph;
+
+	for (i = 0; i < ihl - 1; i++, ptr++)
+		s += *ptr;
+	s += (s >> 32);
+	return (__force __wsum)s;
+
+#else
+	__wsum sum, tmp;
+
+	asm("mtctr %3;"
+	    "addc %0,%4,%5;"
+	    "1:lwzu %1, 4(%2);"
+	    "adde %0,%0,%1;"
+	    "bdnz 1b;"
+	    "addze %0,%0;"
+	    : "=r"(sum), "=r"(tmp), "+b"(ptr)
+	    : "r"(ihl - 2), "r"(*(u32 *)iph), "r"(*ptr)
+	    : "ctr", "xer", "memory");
+
+	return sum;
+#endif
+}
+
+static inline __sum16 ip_fast_csum(const void *iph, unsigned int ihl)
+{
+	return csum_fold(ip_fast_csum_nofold(iph, ihl));
+}
+
 #endif
 #endif /* __KERNEL__ */
 #endif
diff --git a/arch/powerpc/lib/checksum_32.S b/arch/powerpc/lib/checksum_32.S
index 6d67e05..0d7eba3 100644
--- a/arch/powerpc/lib/checksum_32.S
+++ b/arch/powerpc/lib/checksum_32.S
@@ -20,27 +20,6 @@
 	.text
 
 /*
- * ip_fast_csum(buf, len) -- Optimized for IP header
- * len is in words and is always >= 5.
- */
-_GLOBAL(ip_fast_csum)
-	lwz	r0,0(r3)
-	lwzu	r5,4(r3)
-	addic.	r4,r4,-2
-	addc	r0,r0,r5
-	mtctr	r4
-	blelr-
-1:	lwzu	r4,4(r3)
-	adde	r0,r0,r4
-	bdnz	1b
-	addze	r0,r0		/* add in final carry */
-	rlwinm	r3,r0,16,0,31	/* fold two halves together */
-	add	r3,r0,r3
-	not	r3,r3
-	srwi	r3,r3,16
-	blr
-
-/*
  * computes the checksum of a memory block at buff, length len,
  * and adds in "sum" (32-bit)
  *
diff --git a/arch/powerpc/lib/checksum_64.S b/arch/powerpc/lib/checksum_64.S
index f3ef354..f53f4ab 100644
--- a/arch/powerpc/lib/checksum_64.S
+++ b/arch/powerpc/lib/checksum_64.S
@@ -18,33 +18,6 @@
 #include <asm/ppc_asm.h>
 
 /*
- * ip_fast_csum(r3=buf, r4=len) -- Optimized for IP header
- * len is in words and is always >= 5.
- *
- * In practice len == 5, but this is not guaranteed.  So this code does not
- * attempt to use doubleword instructions.
- */
-_GLOBAL(ip_fast_csum)
-	lwz	r0,0(r3)
-	lwzu	r5,4(r3)
-	addic.	r4,r4,-2
-	addc	r0,r0,r5
-	mtctr	r4
-	blelr-
-1:	lwzu	r4,4(r3)
-	adde	r0,r0,r4
-	bdnz	1b
-	addze	r0,r0		/* add in final carry */
-        rldicl  r4,r0,32,0      /* fold two 32-bit halves together */
-        add     r0,r0,r4
-        srdi    r0,r0,32
-	rlwinm	r3,r0,16,0,31	/* fold two halves together */
-	add	r3,r0,r3
-	not	r3,r3
-	srwi	r3,r3,16
-	blr
-
-/*
  * Computes the checksum of a memory block at buff, length len,
  * and adds in "sum" (32-bit).
  *
diff --git a/arch/powerpc/lib/ppc_ksyms.c b/arch/powerpc/lib/ppc_ksyms.c
index f5e427e..8cd5c0b 100644
--- a/arch/powerpc/lib/ppc_ksyms.c
+++ b/arch/powerpc/lib/ppc_ksyms.c
@@ -19,7 +19,6 @@ EXPORT_SYMBOL(strncmp);
 #ifndef CONFIG_GENERIC_CSUM
 EXPORT_SYMBOL(csum_partial);
 EXPORT_SYMBOL(csum_partial_copy_generic);
-EXPORT_SYMBOL(ip_fast_csum);
 #endif
 
 EXPORT_SYMBOL(__copy_tofrom_user);
-- 
2.1.0
