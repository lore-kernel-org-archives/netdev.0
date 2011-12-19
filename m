From: Dave Martin <dave.martin@linaro.org>
Subject: Re: [PATCH v2] ARM: net: JIT compiler for packet filters
Date: Mon, 19 Dec 2011 18:29:08 +0000
Message-ID: <20111219182908.GA2027@linaro.org>
References: <1324284030-25540-1-git-send-email-mgherzan@gmail.com>
 <20111219125021.GA2031@linaro.org>
 <20111219164513.GA25105@swarm.cs.pub.ro>
 <20111219181839.GH2031@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Mircea Gherzan <mgherzan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:46560 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434Ab1LSS3S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 13:29:18 -0500
Received: by wibhm6 with SMTP id hm6so1056029wib.19
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 10:29:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20111219181839.GH2031@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2011 at 06:18:39PM +0000, Dave Martin wrote:
> On Mon, Dec 19, 2011 at 06:45:13PM +0200, Mircea Gherzan wrote:

[...]

> > The JITed code calls back to the kernel for the load helpers. So setting
> > bit 0 is required.
> 
> When you take the address of a link-time external function symbol,
> bit[0] in the address will automatically be set appropriately by the
> linker to indicate the target instruction set -- you already use BX/BLX
> to jump to such symbols, so you should switch correctly when calling
> _to_ the kernel.
> 
> Returns should also work, except for old-style "mov pc,lr" returns made
> in Thumb code (from ARM code, this magically works for >= v7).  Such returns
> only happen in hand-written assembler: for C code, the compiler always
> generates proper AEABI-compliant return sequences.
> 
> So, for calling load_func[], jit_get_skb_b etc. (which are C functions),
> there should be no problem.
> 
> I think the only code which you call from the JIT output but which does
> not return compliantly is __aeabi_uidiv() in arch/arm/lib/lib1funcs.S.
> 
> 
> I have a quick hacked-up patch (below) which attempts to fix this;
> I'd be interested if this works for you  -- but finalising your ARM-only
> version of the patch should still be the priority.
> 
> If this fix does work, I'll turn it into a proper patch, as we can maybe
> use it more widely.

Oops, I forgot to paste in my patch ... here it is.

Cheers
---Dave

diff --git a/arch/arm/include/asm/assembler.h b/arch/arm/include/asm/assembler.h
index b6e65de..013bfaf 100644
--- a/arch/arm/include/asm/assembler.h
+++ b/arch/arm/include/asm/assembler.h
@@ -313,4 +313,39 @@
 	.size \name , . - \name
 	.endm
 
+/*
+ * Helper macro to abstract a function return, where the return address is
+ * held in a register:
+ */
+.macro __def_bret cc
+	.macro bret\cc Rm:req
+#if __LINUX_ARM_ARCH__ < 7
+		mov\cc	pc, \Rm
+#else
+		bx\cc	\Rm
+#endif
+	
+	.endm
+.endm
+
+__def_bret
+__def_bret eq
+__def_bret ne
+__def_bret hs
+__def_bret cs	
+__def_bret lo
+__def_bret cc
+__def_bret vs
+__def_bret vc
+__def_bret mi
+__def_bret pl
+__def_bret hi
+__def_bret ls
+__def_bret ge
+__def_bret lt
+__def_bret gt
+__def_bret le
+
+.purgem __def_bret
+
 #endif /* __ASM_ASSEMBLER_H__ */
diff --git a/arch/arm/lib/lib1funcs.S b/arch/arm/lib/lib1funcs.S
index c562f64..c3a4dbf 100644
--- a/arch/arm/lib/lib1funcs.S
+++ b/arch/arm/lib/lib1funcs.S
@@ -210,7 +210,7 @@ ENTRY(__aeabi_uidiv)
 UNWIND(.fnstart)
 
 	subs	r2, r1, #1
-	moveq	pc, lr
+	breteq	lr
 	bcc	Ldiv0
 	cmp	r0, r1
 	bls	11f
@@ -220,16 +220,16 @@ UNWIND(.fnstart)
 	ARM_DIV_BODY r0, r1, r2, r3
 
 	mov	r0, r2
-	mov	pc, lr
+	bret	lr
 
 11:	moveq	r0, #1
 	movne	r0, #0
-	mov	pc, lr
+	bret	lr
 
 12:	ARM_DIV2_ORDER r1, r2
 
 	mov	r0, r0, lsr r2
-	mov	pc, lr
+	bret	lr
 
 UNWIND(.fnend)
 ENDPROC(__udivsi3)
@@ -244,11 +244,11 @@ UNWIND(.fnstart)
 	moveq   r0, #0
 	tsthi	r1, r2				@ see if divisor is power of 2
 	andeq	r0, r0, r2
-	movls	pc, lr
+	bretls	lr
 
 	ARM_MOD_BODY r0, r1, r2, r3
 
-	mov	pc, lr
+	bret	lr
 
 UNWIND(.fnend)
 ENDPROC(__umodsi3)
@@ -274,23 +274,23 @@ UNWIND(.fnstart)
 
 	cmp	ip, #0
 	rsbmi	r0, r0, #0
-	mov	pc, lr
+	bret	lr
 
 10:	teq	ip, r0				@ same sign ?
 	rsbmi	r0, r0, #0
-	mov	pc, lr
+	bret	lr
 
 11:	movlo	r0, #0
 	moveq	r0, ip, asr #31
 	orreq	r0, r0, #1
-	mov	pc, lr
+	bret	lr
 
 12:	ARM_DIV2_ORDER r1, r2
 
 	cmp	ip, #0
 	mov	r0, r3, lsr r2
 	rsbmi	r0, r0, #0
-	mov	pc, lr
+	bret	lr
 
 UNWIND(.fnend)
 ENDPROC(__divsi3)
@@ -315,7 +315,7 @@ UNWIND(.fnstart)
 
 10:	cmp	ip, #0
 	rsbmi	r0, r0, #0
-	mov	pc, lr
+	bret	lr
 
 UNWIND(.fnend)
 ENDPROC(__modsi3)
@@ -331,7 +331,7 @@ UNWIND(.save {r0, r1, ip, lr}	)
 	ldmfd	sp!, {r1, r2, ip, lr}
 	mul	r3, r0, r2
 	sub	r1, r1, r3
-	mov	pc, lr
+	bret	lr
 
 UNWIND(.fnend)
 ENDPROC(__aeabi_uidivmod)
@@ -344,7 +344,7 @@ UNWIND(.save {r0, r1, ip, lr}	)
 	ldmfd	sp!, {r1, r2, ip, lr}
 	mul	r3, r0, r2
 	sub	r1, r1, r3
-	mov	pc, lr
+	bret	lr
 
 UNWIND(.fnend)
 ENDPROC(__aeabi_idivmod)
