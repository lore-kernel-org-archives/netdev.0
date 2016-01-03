From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] net: Implement fast csum_partial for x86_64
Date: Sun, 3 Jan 2016 15:22:27 -0800
Message-ID: <1451863347-1832521-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:45902 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751027AbcACXWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2016 18:22:39 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u03NJ9Qw003155
	for <netdev@vger.kernel.org>; Sun, 3 Jan 2016 15:22:38 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 206aqsnmmg-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 03 Jan 2016 15:22:38 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 dfae9d24b27011e5809f0002c991e86a-b2ffd1f0 for <netdev@vger.kernel.org>;	Sun,
 03 Jan 2016 15:22:36 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement assembly routine for csum_partial for 64 bit x86. This
primarily speeds up checksum calculation for smaller lengths such as
those that are present when doing skb_postpull_rcsum when getting
CHECKSUM_COMPLETE from device or after CHECKSUM_UNNECESSARY
conversion.

This implementation is similar to csum_partial implemented in
checksum_32.S, however since we are dealing with 8 bytes at a time
there are more cases for alignment and small lengths-- for those we
employ jump tables.

Testing:

Verified correctness by testing arbitrary length buffer filled with
random data. For each buffer I compared the computed checksum
using the original algorithm for each possible alignment (0-7 bytes).

Checksum performance:

Isolating old and new implementation for some common cases:

                        Old      New
Case                    nsecs    nsecs    Improvement
---------------------+--------+--------+-----------------------------
1400 bytes (0 align)    194.4    176.7      9%    (Big packet)
40 bytes (0 align)      10.5     5.7       45%    (Ipv6 hdr common case)
8 bytes (4 align)       8.6      7.4       15%    (UDP, VXLAN in IPv4)
14 bytes (0 align)      10.4     6.5       37%    (Eth hdr)
14 bytes (4 align)      10.8     7.8       27%    (Eth hdr in IPv4)

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 arch/x86/include/asm/checksum_64.h |   5 +
 arch/x86/lib/csum-partial_64.S     | 336 +++++++++++++++++++++++++++++++++++++
 arch/x86/lib/csum-partial_64.c     | 148 ----------------
 3 files changed, 341 insertions(+), 148 deletions(-)
 create mode 100644 arch/x86/lib/csum-partial_64.S
 delete mode 100644 arch/x86/lib/csum-partial_64.c

diff --git a/arch/x86/include/asm/checksum_64.h b/arch/x86/include/asm/checksum_64.h
index cd00e17..a888f65 100644
--- a/arch/x86/include/asm/checksum_64.h
+++ b/arch/x86/include/asm/checksum_64.h
@@ -128,6 +128,11 @@ static inline __sum16 csum_tcpudp_magic(__be32 saddr, __be32 daddr,
  */
 extern __wsum csum_partial(const void *buff, int len, __wsum sum);
 
+static inline __sum16 ip_compute_csum(const void *buff, int len)
+{
+	return csum_fold(csum_partial(buff, len, 0));
+}
+
 #define  _HAVE_ARCH_COPY_AND_CSUM_FROM_USER 1
 #define HAVE_CSUM_COPY_USER 1
 
diff --git a/arch/x86/lib/csum-partial_64.S b/arch/x86/lib/csum-partial_64.S
new file mode 100644
index 0000000..0dca09d
--- /dev/null
+++ b/arch/x86/lib/csum-partial_64.S
@@ -0,0 +1,336 @@
+/* Copyright 2016 Tom Herbert <tom@herbertland.com>
+ *
+ * Checksum partial calculation
+ *
+ * __wsum csum_partial(const void *buff, int len, __wsum sum)
+ * computes the checksum of a memory block at buff, length len,
+ * and adds in "sum" (32-bit)
+ *
+ * returns a 32-bit number suitable for feeding into itself
+ * or csum_tcpudp_magic
+ *
+ * Register usage
+ *  %rdi: argument 1, buff
+ *  %rsi: argument 2, length
+ *  %rdx: argument 3, add in value
+ *  %rcx: counter and tmp
+ *  %r10: buffer alignment
+ *  %r11: tmp
+ *
+ * Basic algorithm:
+ *   1) Handle buffer that is not aligned to 8 bytes
+ *   2) Sum 8 bytes at a time using adcq (unroll main loop
+ *      to do 64 bytes at a time)
+ *   3) Sum remaining length (less than 8 bytes)
+ *
+ * If buffer is not aligned to 8 bytes and and length is less than
+ * or equal to 8 - alignment (whole buffer is in one quad), then
+ * treat this as a special case.
+ */
+
+#include <linux/linkage.h>
+#include <asm/errno.h>
+#include <asm/asm.h>
+
+#define branch_tbl_align	.L_branch_tbl_align
+#define branch_tbl_len		.L_branch_tbl_len
+#define branch_tbl_small_align	.L_branch_tbl_small_align
+#define branch_tbl_small_align_a1 .L_branch_tbl_small_align_a1
+
+ENTRY(csum_partial)
+	xorq	%rax, %rax
+
+	/* Determine buffer alignment to 8 bytes */
+	movl	%edi, %r10d
+	andl	$0x7, %r10d
+	jnz	1f
+
+	/* Quick check if length is small */
+10:	cmpl	$8, %esi
+	jle	20f
+
+	/* Determine number of quads (n). Sum over first n % 8  quads */
+	movl	%esi, %ecx
+	shrl	$3, %ecx
+	andl	$0x7, %ecx
+	negq	%rcx
+	lea	25f(, %rcx, 4), %r11
+	clc
+	jmp	*%r11
+
+.align 8
+	adcq	6*8(%rdi),%rax
+	adcq	5*8(%rdi),%rax
+	adcq	4*8(%rdi),%rax
+	adcq	3*8(%rdi),%rax
+	adcq	2*8(%rdi),%rax
+	adcq	1*8(%rdi),%rax
+	adcq	0*8(%rdi),%rax
+	nop
+
+25:	adcq	$0, %rax
+	shlq	$3, %rcx
+	subq	%rcx, %rdi /* %rcx is already negative length */
+
+	/* Now determine number of blocks of 8 quads. Sum 64 bytes at a time
+	 * using unrolled loop.
+	 */
+	movl	%esi, %ecx
+	shrl	$6, %ecx
+	jz	30f
+	clc
+
+35:	adcq	0*8(%rdi),%rax
+	adcq	1*8(%rdi),%rax
+	adcq	2*8(%rdi),%rax
+	adcq	3*8(%rdi),%rax
+	adcq	4*8(%rdi),%rax
+	adcq	5*8(%rdi),%rax
+	adcq	6*8(%rdi),%rax
+	adcq	7*8(%rdi),%rax
+	lea	64(%rdi), %rdi
+	loop	35b
+
+	adcq	$0, %rax
+
+30:	andl	$0x7, %esi
+
+	/* Handle remaining length which is <= 8 bytes */
+20:	jmpq *branch_tbl_len(, %rsi, 8)
+
+/* Length tabel targets */
+
+101:	/* Length 1 */
+	addb	(%rdi), %al
+	adcb	$0, %ah
+	adcq	$0, %rax
+	jmp	50f
+103:	/* Length 3 */
+	addb	2(%rdi), %al
+	adcb	$0, %ah
+	adcq	$0, %rax
+102:	/* Length 2 */
+	addw	(%rdi), %ax
+	adcq	$0, %rax
+	jmp	50f
+105:	/* Length 5 */
+	addb	4(%rdi), %al
+	adcb	$0, %ah
+	adcq	$0, %rax
+104:	/* Length 4 */
+	movl	(%rdi), %ecx
+	addq	%rcx, %rax
+	adcq	$0, %rax
+	jmp	50f
+107:	/* Length 7 */
+	addb	6(%rdi), %al
+	adcb	$0, %ah
+	adcq	$0, %rax
+106:	/* Length 6 */
+	movl	(%rdi), %ecx
+	addq	%rcx, %rax
+	adcw	4(%rdi), %ax
+	adcq	$0, %rax
+	jmp	50f
+108:	/* Length 8 */
+	addq	(%rdi), %rax
+	adcq	$0, %rax
+100:	/* Length 0 */
+
+	/* If alignment is odd we need to roll whole sum by 8 bits */
+50:	test	$1, %r10d
+	jnz	65f
+
+	/* Fold sum to 32 bits and add initial sum value from argument */
+60:	movq	%rax, %rcx
+	shrq	$32, %rcx
+	addl	%ecx, %eax
+	adcl	%edx, %eax
+	adcl	$0, %eax
+	ret
+
+65:	rolq	$8, %rax
+	jmp	60b
+
+	/* Process non-zero alignment */
+1:	cmpl	$8, %esi
+	jl	68f
+	jmpq	*branch_tbl_align(, %r10, 8)
+
+	/* Non-zero alignment and length < 8. See if buffer is in one quad */
+68:	test	%rsi, %rsi
+	je	60b
+	movl	$8, %ecx
+	subl	%r10d, %ecx
+	cmpl	%ecx, %esi
+	jle	70f
+	jmpq	*branch_tbl_align(, %r10, 8)
+
+/* Alignment table targets */
+
+201:	/* Align 1 */
+	movl	3(%rdi), %eax
+	addb	(%rdi), %ah
+	adcw	1(%rdi),%ax
+	adcq	$0, %rax
+	subl	$7, %esi
+	addq	$7, %rdi
+	jmp	10b
+202:	/* Align 2 */
+	movw	(%rdi), %ax
+	addl	2(%rdi), %eax
+	adcl	$0, %eax
+	subl	$6, %esi
+	addq	$6, %rdi
+	jmp	10b
+203:	/* Align 3 */
+	movb	(%rdi), %ah
+	addl	1(%rdi),%eax
+	adcl	$0, %eax
+	subl	$5, %esi
+	addq	$5, %rdi
+	jmp	10b
+204:	/* Align 4 */
+	movl	(%rdi), %eax
+	subl	$4, %esi
+	addq	$4, %rdi
+	jmp	10b
+205:	/* Align 5 */
+	movb	(%rdi), %ah
+	addw	1(%rdi),%ax
+	adcw	$0, %ax
+	subl	$3, %esi
+	addq	$3, %rdi
+	jmp	10b
+206:	/* Align 6 */
+	movw	(%rdi), %ax
+	subl	$2, %esi
+	addq	$2, %rdi
+	jmp	10b
+207:	/* Align 7 */
+	movb	(%rdi), %ah
+	subl	$1, %esi
+	addq	$1, %rdi
+200:	/* Align 0 */
+	jmp	10b
+
+	/* Non-zero alignment and buffer is in one quad (len <= 8 - align) */
+70:	decl	%esi
+	test	$0x1, %r10d
+	jnz	75f
+	jmpq	*branch_tbl_small_align(, %rsi, 8)
+
+/* Small length with even alignment table targets */
+
+301:	/* Length 1, align is 2,4, or 6 */
+	movb	(%rdi), %al
+	jmp	60b
+302:	/* Length 2, align is 2, 4, or 6 */
+	movw	(%rdi), %ax
+	jmp	60b
+303:	/* Length 3, align is 2 or 4 */
+	movb	2(%rdi), %al
+	addw	(%rdi), %ax
+	adcw	$0, %ax
+	jmp	60b
+304:	/* Length 4, align is 2 or 4 */
+	movw	(%rdi), %ax
+	addw	2(%rdi), %ax
+	adcw	$0, %ax
+	jmp	60b
+305:	/* Length 5, align must be 2 */
+	movb	4(%rdi), %al
+	addw	(%rdi), %ax
+	adcw	2(%rdi), %ax
+	adcw	$0, %ax
+	jmp	60b
+306:	/* Length 6, align must be 2 */
+	movw	(%rdi), %ax
+	addl	2(%rdi), %eax
+	adcl	$0, %eax
+	jmp	60b
+
+75:	jmp *branch_tbl_small_align_a1(, %rsi, 8)
+
+/* Small length with odd alignement table targets */
+
+401: /* Length 1, align is 1, 3, 5, or 7 */
+	movb	(%rdi), %al
+	jmp	60b
+402: /* Length 2, align is 1, 3, or 5 */
+	movb	(%rdi), %al
+	movb	1(%rdi), %ah
+	jmp	60b
+404: /* Length 4, align is 1 or 3 */
+	movb	(%rdi), %ah
+	movb	3(%rdi), %al
+	addw	1(%rdi), %ax
+	adcw	$0, %ax
+	rolq	$8, %rax
+	jmp	60b
+405: /* Length 5, align is 1 or 3 */
+	adcw	3(%rdi), %ax
+403: /* Length 3, align is 1, 3, or 5 */
+	adcb	(%rdi), %ah
+	adcw	1(%rdi), %ax
+	adcw	$0, %ax
+	rolq	$8, %rax
+	jmp	60b
+406: /* Length 6, align must be 1 */
+	movb	5(%rdi), %al
+	movb	(%rdi), %ah
+	addw	1(%rdi), %ax
+	adcw	3(%rdi), %ax
+	adcl	$0, %eax
+	rolq	$8, %rax
+	jmp	60b
+407: /* Length 7, align must be 1 */
+	movb	(%rdi), %ah
+	addw	1(%rdi), %ax
+	adcl	3(%rdi), %eax
+	adcl	$0, %eax
+	rolq	$8, %rax
+	jmp	60b
+ENDPROC(csum_partial)
+
+/* Jump tables */
+
+.section .rodata
+.align 64
+.L_branch_tbl_align:
+	.quad	200b
+	.quad	201b
+	.quad	202b
+	.quad	203b
+	.quad	204b
+	.quad	205b
+	.quad	206b
+	.quad	207b
+
+.L_branch_tbl_len:
+	.quad	100b
+	.quad	101b
+	.quad	102b
+	.quad	103b
+	.quad	104b
+	.quad	105b
+	.quad	106b
+	.quad	107b
+	.quad	108b
+
+.L_branch_tbl_small_align:
+	.quad	301b
+	.quad	302b
+	.quad	303b
+	.quad	304b
+	.quad	305b
+	.quad	306b
+
+.L_branch_tbl_small_align_a1:
+	.quad	401b
+	.quad	402b
+	.quad	403b
+	.quad	404b
+	.quad	405b
+	.quad	406b
+	.quad	407b
diff --git a/arch/x86/lib/csum-partial_64.c b/arch/x86/lib/csum-partial_64.c
deleted file mode 100644
index 9845371..0000000
--- a/arch/x86/lib/csum-partial_64.c
+++ /dev/null
@@ -1,148 +0,0 @@
-/*
- * arch/x86_64/lib/csum-partial.c
- *
- * This file contains network checksum routines that are better done
- * in an architecture-specific manner due to speed.
- */
- 
-#include <linux/compiler.h>
-#include <linux/module.h>
-#include <asm/checksum.h>
-
-static inline unsigned short from32to16(unsigned a) 
-{
-	unsigned short b = a >> 16; 
-	asm("addw %w2,%w0\n\t"
-	    "adcw $0,%w0\n" 
-	    : "=r" (b)
-	    : "0" (b), "r" (a));
-	return b;
-}
-
-/*
- * Do a 64-bit checksum on an arbitrary memory area.
- * Returns a 32bit checksum.
- *
- * This isn't as time critical as it used to be because many NICs
- * do hardware checksumming these days.
- * 
- * Things tried and found to not make it faster:
- * Manual Prefetching
- * Unrolling to an 128 bytes inner loop.
- * Using interleaving with more registers to break the carry chains.
- */
-static unsigned do_csum(const unsigned char *buff, unsigned len)
-{
-	unsigned odd, count;
-	unsigned long result = 0;
-
-	if (unlikely(len == 0))
-		return result; 
-	odd = 1 & (unsigned long) buff;
-	if (unlikely(odd)) {
-		result = *buff << 8;
-		len--;
-		buff++;
-	}
-	count = len >> 1;		/* nr of 16-bit words.. */
-	if (count) {
-		if (2 & (unsigned long) buff) {
-			result += *(unsigned short *)buff;
-			count--;
-			len -= 2;
-			buff += 2;
-		}
-		count >>= 1;		/* nr of 32-bit words.. */
-		if (count) {
-			unsigned long zero;
-			unsigned count64;
-			if (4 & (unsigned long) buff) {
-				result += *(unsigned int *) buff;
-				count--;
-				len -= 4;
-				buff += 4;
-			}
-			count >>= 1;	/* nr of 64-bit words.. */
-
-			/* main loop using 64byte blocks */
-			zero = 0;
-			count64 = count >> 3;
-			while (count64) { 
-				asm("addq 0*8(%[src]),%[res]\n\t"
-				    "adcq 1*8(%[src]),%[res]\n\t"
-				    "adcq 2*8(%[src]),%[res]\n\t"
-				    "adcq 3*8(%[src]),%[res]\n\t"
-				    "adcq 4*8(%[src]),%[res]\n\t"
-				    "adcq 5*8(%[src]),%[res]\n\t"
-				    "adcq 6*8(%[src]),%[res]\n\t"
-				    "adcq 7*8(%[src]),%[res]\n\t"
-				    "adcq %[zero],%[res]"
-				    : [res] "=r" (result)
-				    : [src] "r" (buff), [zero] "r" (zero),
-				    "[res]" (result));
-				buff += 64;
-				count64--;
-			}
-
-			/* last up to 7 8byte blocks */
-			count %= 8; 
-			while (count) { 
-				asm("addq %1,%0\n\t"
-				    "adcq %2,%0\n" 
-					    : "=r" (result)
-				    : "m" (*(unsigned long *)buff), 
-				    "r" (zero),  "0" (result));
-				--count; 
-					buff += 8;
-			}
-			result = add32_with_carry(result>>32,
-						  result&0xffffffff); 
-
-			if (len & 4) {
-				result += *(unsigned int *) buff;
-				buff += 4;
-			}
-		}
-		if (len & 2) {
-			result += *(unsigned short *) buff;
-			buff += 2;
-		}
-	}
-	if (len & 1)
-		result += *buff;
-	result = add32_with_carry(result>>32, result & 0xffffffff); 
-	if (unlikely(odd)) { 
-		result = from32to16(result);
-		result = ((result >> 8) & 0xff) | ((result & 0xff) << 8);
-	}
-	return result;
-}
-
-/*
- * computes the checksum of a memory block at buff, length len,
- * and adds in "sum" (32-bit)
- *
- * returns a 32-bit number suitable for feeding into itself
- * or csum_tcpudp_magic
- *
- * this function must be called with even lengths, except
- * for the last fragment, which may be odd
- *
- * it's best to have buff aligned on a 64-bit boundary
- */
-__wsum csum_partial(const void *buff, int len, __wsum sum)
-{
-	return (__force __wsum)add32_with_carry(do_csum(buff, len),
-						(__force u32)sum);
-}
-
-/*
- * this routine is used for miscellaneous IP-like checksums, mainly
- * in icmp.c
- */
-__sum16 ip_compute_csum(const void *buff, int len)
-{
-	return csum_fold(csum_partial(buff,len,0));
-}
-EXPORT_SYMBOL(ip_compute_csum);
-
-- 
2.4.6
