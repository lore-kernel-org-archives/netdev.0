From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] MIPS checksum fix
Date: Fri, 19 Sep 2008 14:07:52 +0200
Message-ID: <20080919120752.GA19877@linux-mips.org>
References: <Pine.LNX.4.55.0809171104290.17103@cliff.in.clinika.pl> <20080917.222350.41199051.anemo@mba.ocn.ne.jp> <Pine.LNX.4.55.0809171501450.17103@cliff.in.clinika.pl> <20080918.002705.78730226.anemo@mba.ocn.ne.jp> <Pine.LNX.4.55.0809171917580.17103@cliff.in.clinika.pl> <20080918220734.GA19222@linux-mips.org> <Pine.LNX.4.55.0809190112090.22686@cliff.in.clinika.pl> <20080919112304.GB13440@linux-mips.org> <20080919114743.GA19359@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Atsushi Nemoto <anemo@mba.ocn.ne.jp>, u1@terran.org,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([213.58.128.207]:51003 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbYISMJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 08:09:53 -0400
Received: from localhost.localdomain ([127.0.0.1]:51421 "EHLO
	ditditdahdahdah-dahdahdahditdit.dl5rb.org.uk") by ftp.linux-mips.org
	with ESMTP id S20316669AbYISMH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 13:07:58 +0100
Content-Disposition: inline
In-Reply-To: <20080919114743.GA19359@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2008 at 01:47:43PM +0200, Ralf Baechle wrote:

> I'm interested in test reports of this on all sorts of configurations -
> 32-bit, 64-bit, big / little endian, R2 processors and pre-R2.  In
> particular Cavium being the only MIPS64 R2 implementation would be
> interesting.  This definately is stuff which should go upstream for 2.6.27.

There was a trivial bug in the R2 code.

>From 97ad23f4696a322cb3bc379a25a8c0f6526751d6 Mon Sep 17 00:00:00 2001
From: Ralf Baechle <ralf@linux-mips.org>
Date: Fri, 19 Sep 2008 14:05:53 +0200
Subject: [PATCH] [MIPS] Fix 64-bit csum_partial, __csum_partial_copy_user and csum_partial_copy

On 64-bit machines it wouldn't handle a possible carry when adding the
32-bit folded checksum and checksum argument.

While at it, add a few trivial optimizations, also for R2 processors.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/arch/mips/lib/csum_partial.S b/arch/mips/lib/csum_partial.S
index 8d77841..c77a7a0 100644
--- a/arch/mips/lib/csum_partial.S
+++ b/arch/mips/lib/csum_partial.S
@@ -53,12 +53,14 @@
 #define UNIT(unit)  ((unit)*NBYTES)
 
 #define ADDC(sum,reg)						\
-	.set	push;						\
-	.set	noat;						\
 	ADD	sum, reg;					\
 	sltu	v1, sum, reg;					\
 	ADD	sum, v1;					\
-	.set	pop
+
+#define ADDC32(sum,reg)						\
+	addu	sum, reg;					\
+	sltu	v1, sum, reg;					\
+	addu	sum, v1;					\
 
 #define CSUM_BIGCHUNK1(src, offset, sum, _t0, _t1, _t2, _t3)	\
 	LOAD	_t0, (offset + UNIT(0))(src);			\
@@ -254,8 +256,6 @@ LEAF(csum_partial)
 1:	ADDC(sum, t1)
 
 	/* fold checksum */
-	.set	push
-	.set	noat
 #ifdef USE_DOUBLE
 	dsll32	v1, sum, 0
 	daddu	sum, v1
@@ -263,24 +263,25 @@ LEAF(csum_partial)
 	dsra32	sum, sum, 0
 	addu	sum, v1
 #endif
-	sll	v1, sum, 16
-	addu	sum, v1
-	sltu	v1, sum, v1
-	srl	sum, sum, 16
-	addu	sum, v1
 
 	/* odd buffer alignment? */
-	beqz	t7, 1f
-	 nop
-	sll	v1, sum, 8
+#ifdef CPU_MIPSR2
+	wsbh	v1, sum	
+	movn	sum, v1, t7
+#else
+	beqz	t7, 1f			/* odd buffer alignment? */
+	 lui	v1, 0x00ff
+	addu	v1, 0x00ff
+	and	t0, sum, v1
+	sll	t0, t0, 8
 	srl	sum, sum, 8
-	or	sum, v1
-	andi	sum, 0xffff
-	.set	pop
+	and	sum, sum, v1
+	or	sum, sum, t0
 1:
+#endif
 	.set	reorder
 	/* Add the passed partial csum.  */
-	ADDC(sum, a2)
+	ADDC32(sum, a2)
 	jr	ra
 	.set	noreorder
 	END(csum_partial)
@@ -656,8 +657,6 @@ EXC(	sb	t0, NBYTES-2(dst), .Ls_exc)
 	ADDC(sum, t2)
 .Ldone:
 	/* fold checksum */
-	.set	push
-	.set	noat
 #ifdef USE_DOUBLE
 	dsll32	v1, sum, 0
 	daddu	sum, v1
@@ -665,23 +664,23 @@ EXC(	sb	t0, NBYTES-2(dst), .Ls_exc)
 	dsra32	sum, sum, 0
 	addu	sum, v1
 #endif
-	sll	v1, sum, 16
-	addu	sum, v1
-	sltu	v1, sum, v1
-	srl	sum, sum, 16
-	addu	sum, v1
 
-	/* odd buffer alignment? */
-	beqz	odd, 1f
-	 nop
-	sll	v1, sum, 8
+#ifdef CPU_MIPSR2
+	wsbh	v1, sum
+	movn	sum, v1, odd
+#else
+	beqz	odd, 1f			/* odd buffer alignment? */
+	 lui	v1, 0x00ff
+	addu	v1, 0x00ff
+	and	t0, sum, v1
+	sll	t0, t0, 8
 	srl	sum, sum, 8
-	or	sum, v1
-	andi	sum, 0xffff
-	.set	pop
+	and	sum, sum, v1
+	or	sum, sum, t0
 1:
+#endif
 	.set reorder
-	ADDC(sum, psum)
+	ADDC32(sum, psum)
 	jr	ra
 	.set noreorder
 
