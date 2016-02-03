From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Wed, 3 Feb 2016 11:18:41 -0800
Message-ID: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tglx@linutronix.de>, <mingo@redhat.com>, <hpa@zytor.com>,
	<x86@kernel.org>, <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:51291 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965284AbcBCTSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 14:18:54 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u13JENdI001047
	for <netdev@vger.kernel.org>; Wed, 3 Feb 2016 11:18:54 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 20up0trfuf-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 11:18:54 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 f5cef94ecaaa11e5911724be0593f280-8bdf52b0 for <netdev@vger.kernel.org>;	Wed,
 03 Feb 2016 11:18:52 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement assembly routine for csum_partial for 64 bit x86. This
primarily speeds up checksum calculation for smaller lengths such as
those that are present when doing skb_postpull_rcsum when getting
CHECKSUM_COMPLETE from device or after CHECKSUM_UNNECESSARY
conversion.

CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is checked to determine whether
we need to avoid unaligned accesses. Efficient unaligned accesses
offer a nice additional speedup as demonstrated in the results
provided below.

This implementation is similar to csum_partial implemented in
checksum_32.S, however since we are dealing with 8 bytes at a time
there are more cases for small lengths (and alignments)-- for that
we employ a jump table.

Testing:

Correctness:

Verified correctness by testing arbitrary length buffer filled with
random data. For each buffer I compared the computed checksum
using the original algorithm for each possible alignment (0-7 bytes).

Checksum performance:

Isolating old and new implementation for some common cases:

         Old      NewA     NewA %   NewNoA   NewNoA %
Len/Aln  nsec     nsec     Improv   nsecs    Improve
--------+-------+--------+-------+-------+---------------------
1400/0    192.9    175.1   10%     174.9     10%   (Big packet)
40/0      13.8     7.7     44%     5.7       58%   (Ipv6 hdr cmn case)
8/4       8.4      6.9     18%     2.8       67%   (UDP, VXLAN in IPv4)
14/0      10.5     7.3     30%     5.4       48%   (Eth hdr)
14/4      10.8     8.7     19%     5.4       50%   (Eth hdr in IPv4)
14/3      11.0     9.8     11%     5.6       49%   (Eth with odd align)
7/1       10.0     5.8     42%     4.8       52%   (buffer in one quad)

NewA=>CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS not set
NewNoA=>CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set

Results from: Intel(R) Xeon(R) CPU X5650 @ 2.67GHz

Also test on these with similar results:

Intel(R) Xeon(R) CPU E5-2660 v2 @ 2.20GHz
Intel(R) Xeon(R) CPU E5-2680 v2 @ 2.80GHz

Branch prediction:

To test the effects of poor branch prediction in the jump tables I
tested checksum performance with runs for two combinations of length
and alignment. As the baseline I performed the test by doing half of
calls with the first combination, followed by using the second
combination for the second half. In the test case, I interleave the
two combinations so that in every call the length and alignment are
different to defeat the effects of branch prediction. Running several
cases, I did not see any material performance difference between
the baseline and the interleaving test case.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 arch/x86/include/asm/checksum_64.h |   5 +
 arch/x86/lib/csum-partial_64.S     | 277 +++++++++++++++++++++++++++++++++++++
 arch/x86/lib/csum-partial_64.c     | 148 --------------------
 3 files changed, 282 insertions(+), 148 deletions(-)
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
index 0000000..520b400
--- /dev/null
+++ b/arch/x86/lib/csum-partial_64.S
@@ -0,0 +1,277 @@
+/* Copyright 2016 Tom Herbert <tom@herbertland.com>
+ *
+ * Checksum partial calculation
+ *
+ * __wsum csum_partial(const void *buff, int len, __wsum sum)
+ *
+ * Computes the checksum of a memory block at buff, length len,
+ * and adds in "sum" (32-bit)
+ *
+ * Returns a 32-bit number suitable for feeding into itself
+ * or csum_tcpudp_magic
+ *
+ * CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS determines whether alignment of the
+ * buffer must be dealt with.
+ *
+ * If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set then the steps are:
+ *     1) Initialize accumulator to initial sum
+ *     2) Sum 8 bytes at a time using adcq (unroll main loop
+ *        to do 128 bytes at a time)
+ *     3) Sum remaining length (less than 8 bytes)
+ *
+ * If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is not set then the steps are:
+ *     1) Handle buffer that is not aligned to 8 bytes, sum up to 8 byte
+ *        alignment
+ *     2) Sum 8 bytes at a time using adcq (unroll main loop
+ *        to do 128 bytes at a time)
+ *     3) Sum remaining length (less than 8 bytes)
+ *     4) Roll result if alignment is odd and add in initial sum argument
+ *     5) If buffer is not aligned to 8 bytes and length is less than
+ *        or equal to 8 - alignment (whole buffer is in one quad), then
+ *        treat that as a special case.
+ *
+ * Register usage:
+ *   %rdi: argument #1, buff
+ *   %rsi: argument #2, length
+ *   %rdx: argument #3, add in value
+ *   %rax,%eax: accumulator and return value
+ *   %rcx,%ecx: counter and tmp
+ *   %r11: tmp
+ *   %r10: alignment (0-7) - when CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set
+ */
+
+#include <linux/linkage.h>
+#include <asm/errno.h>
+#include <asm/asm.h>
+
+#define branch_tbl_len .L_branch_tbl_len
+
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+
+/* Close the carry chain and return. */
+#define	RETURN			\
+	adcl	$0, %eax;	\
+	ret
+
+#else /* CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS */
+
+/* Before returning need to roll the result if alignment was odd and then add
+ * in the initial sum.
+ */
+#define	RETURN			\
+	adcl	$0, %eax;	\
+	test	$0x1, %r10d;	\
+	jz	99f;		\
+	roll	$8, %eax;	\
+99:	addl	%edx, %eax;	\
+	adcl	$0, %eax;	\
+	ret
+
+#define branch_tbl_align .L_branch_tbl_align
+
+#endif /* CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS */
+
+ENTRY(csum_partial)
+
+#ifdef	CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+	movl	%edx, %eax	/* Initialize with initial sum argument */
+#else	/* CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS */
+	test	%esi, %esi	/* Zero length? */
+	jne	310f
+	movl	%edx, %eax
+	ret
+
+310:	xorl	%eax, %eax
+
+	/* Determine alignment */
+	movl	%edi, %r10d
+	andl	$0x7, %r10d
+	jz	10f
+	movl	$8, %ecx
+	subl	%r10d, %ecx
+	cmpl	%ecx, %esi
+	jle	320f
+	clc
+	jmpq	*branch_tbl_align(, %r10, 8)
+
+	/* Whole buffer fits into one quad. Sum up to a four byte alignment
+	 * and then call into the length table to finish.
+	 */
+320:	test	$0x1, %r10d
+	jz	330f
+	movb	(%rdi), %ah /* Align to two bytes */
+	decl	%esi
+	lea	1(%rdi), %rdi
+330:	cmpl	$2, %esi
+	jl	340f
+	test	$0x2, %r10d
+	jz	340f
+	addw	(%rdi), %ax /* Align to four bytes */
+	adcl	$0, %eax
+	lea	2(%rdi), %rdi
+	subl	$2, %esi
+340:
+	clc
+	jmpq *branch_tbl_len(, %rsi, 8)
+
+/* Jumps table for alignments */
+
+201:	/* Align 1 */
+	adcw	5(%rdi), %ax
+203:	/* Align 3 */
+	adcw	3(%rdi), %ax
+205:	/* Align 5 */
+	adcw	1(%rdi), %ax
+207:	/* Align 7 */
+	adcl	$0, %eax
+	addb	(%rdi), %ah
+	jmp	222f
+202:	/* Align 2 */
+	adcw	4(%rdi), %ax
+204:	/* Align 4 */
+	adcw	2(%rdi), %ax
+206:	/* Align 6 */
+	adcw	(%rdi), %ax
+
+222:	adcl	$0, %eax
+	subl	%ecx, %esi /* %rcx is 8 - alignment */
+	addq	%rcx, %rdi
+200:
+	/* Fall through */
+
+#endif /* CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS */
+
+	/* Check length */
+10:	cmpl	$8, %esi
+	jg	30f
+	jl	20f
+
+	/* Exactly 8 bytes length */
+	addl	(%rdi), %eax
+	adcl	4(%rdi), %eax
+	RETURN
+
+	/* Less than 8 bytes length */
+20:	clc
+	jmpq *branch_tbl_len(, %rsi, 8)
+
+	/* Greater than 8 bytes length. Determine number of quads (n). Sum
+	 * over first n % 16 quads
+	 */
+30:	movl	%esi, %ecx
+	shrl	$3, %ecx
+	andl	$0xf, %ecx
+	negq	%rcx
+	lea	40f(, %rcx, 4), %r11
+	clc
+	jmp	*%r11
+
+.align 8
+	adcq	14*8(%rdi),%rax
+	adcq	13*8(%rdi),%rax
+	adcq	12*8(%rdi),%rax
+	adcq	11*8(%rdi),%rax
+	adcq	10*8(%rdi),%rax
+	adcq	9*8(%rdi),%rax
+	adcq	8*8(%rdi),%rax
+	adcq	7*8(%rdi),%rax
+	adcq	6*8(%rdi),%rax
+	adcq	5*8(%rdi),%rax
+	adcq	4*8(%rdi),%rax
+	adcq	3*8(%rdi),%rax
+	adcq	2*8(%rdi),%rax
+	adcq	1*8(%rdi),%rax
+	adcq 	0*8(%rdi),%rax
+	nop
+40:	/* #quads % 16 jump table base */
+
+	adcq	$0, %rax
+	shlq	$3, %rcx
+	subq	%rcx, %rdi /* %rcx is already negative length */
+
+	/* Now determine number of blocks of 8 quads. Sum 128 bytes at a time
+	 * using unrolled loop.
+	 */
+	movl	%esi, %ecx
+	shrl	$7, %ecx
+	jz	60f
+	clc
+
+	/* Main loop */
+50:	adcq	0*8(%rdi),%rax
+	adcq	1*8(%rdi),%rax
+	adcq	2*8(%rdi),%rax
+	adcq	3*8(%rdi),%rax
+	adcq	4*8(%rdi),%rax
+	adcq	5*8(%rdi),%rax
+	adcq	6*8(%rdi),%rax
+	adcq	7*8(%rdi),%rax
+	adcq	8*8(%rdi),%rax
+	adcq	9*8(%rdi),%rax
+	adcq	10*8(%rdi),%rax
+	adcq	11*8(%rdi),%rax
+	adcq	12*8(%rdi),%rax
+	adcq	13*8(%rdi),%rax
+	adcq	14*8(%rdi),%rax
+	adcq	15*8(%rdi),%rax
+	lea	128(%rdi), %rdi
+	loop	50b
+
+	adcq	$0, %rax
+
+	/* Handle remaining length which is <= 8 bytes */
+60:	andl	$0x7, %esi
+
+	/* Fold 64 bit sum to 32 bits */
+	movq	%rax, %rcx
+	shrq	$32, %rcx
+	addl	%ecx, %eax
+
+	jmpq *branch_tbl_len(, %rsi, 8)
+
+/* Length table targets */
+
+107:	/* Length 7 */
+	adcw	4(%rdi), %ax
+105:	/* Length 5 */
+	adcw	2(%rdi), %ax
+103:	/* Length 3 */
+	adcw	(%rdi), %ax
+101:	/* Length 1, grab the odd byte */
+	adcb	-1(%rdi, %rsi), %al
+	adcb	$0, %ah
+	RETURN
+106:	/* Length 6 */
+	adcw	4(%rdi), %ax
+104:	/* Length 4, optimized  for double word access*/
+	adcl	(%rdi), %eax
+	RETURN
+102:	/* Length 2 */
+	adcw	(%rdi), %ax
+100:	/* Length 0 */
+	RETURN
+
+.section .rodata
+.align 64
+.L_branch_tbl_len:
+	.quad	100b
+	.quad	101b
+	.quad	102b
+	.quad	103b
+	.quad	104b
+	.quad	105b
+	.quad	106b
+	.quad	107b
+
+#ifndef	CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+.L_branch_tbl_align:
+	.quad	200b
+	.quad	201b
+	.quad	202b
+	.quad	203b
+	.quad	204b
+	.quad	205b
+	.quad	206b
+	.quad	207b
+#endif
+
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
