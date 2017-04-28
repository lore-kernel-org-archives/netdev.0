From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH 1/7] crypto: aesni: make non-AVX AES-GCM work with any aadlen
Date: Fri, 28 Apr 2017 18:11:56 +0200
Message-ID: <f456b1912b0930c68d7f145cb42e4dec9d359a3a.1493395785.git.sd@queasysnail.net>
References: <cover.1493395785.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@redhat.com>,
        "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
        linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36804 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1424313AbdD1QMn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 12:12:43 -0400
In-Reply-To: <cover.1493395785.git.sd@queasysnail.net>
In-Reply-To: <cover.1493395785.git.sd@queasysnail.net>
References: <cover.1493395785.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the first step to make the aesni AES-GCM implementation
generic. The current code was written for rfc4106, so it handles only
some specific sizes of associated data.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 arch/x86/crypto/aesni-intel_asm.S | 169 +++++++++++++++++++++++++++++---------
 1 file changed, 132 insertions(+), 37 deletions(-)

diff --git a/arch/x86/crypto/aesni-intel_asm.S b/arch/x86/crypto/aesni-intel_asm.S
index 3c465184ff8a..605726aaf0a2 100644
--- a/arch/x86/crypto/aesni-intel_asm.S
+++ b/arch/x86/crypto/aesni-intel_asm.S
@@ -89,6 +89,29 @@ SHIFT_MASK: .octa 0x0f0e0d0c0b0a09080706050403020100
 ALL_F:      .octa 0xffffffffffffffffffffffffffffffff
             .octa 0x00000000000000000000000000000000
 
+.section .rodata
+.align 16
+.type aad_shift_arr, @object
+.size aad_shift_arr, 272
+aad_shift_arr:
+        .octa     0xffffffffffffffffffffffffffffffff
+        .octa     0xffffffffffffffffffffffffffffff0C
+        .octa     0xffffffffffffffffffffffffffff0D0C
+        .octa     0xffffffffffffffffffffffffff0E0D0C
+        .octa     0xffffffffffffffffffffffff0F0E0D0C
+        .octa     0xffffffffffffffffffffff0C0B0A0908
+        .octa     0xffffffffffffffffffff0D0C0B0A0908
+        .octa     0xffffffffffffffffff0E0D0C0B0A0908
+        .octa     0xffffffffffffffff0F0E0D0C0B0A0908
+        .octa     0xffffffffffffff0C0B0A090807060504
+        .octa     0xffffffffffff0D0C0B0A090807060504
+        .octa     0xffffffffff0E0D0C0B0A090807060504
+        .octa     0xffffffff0F0E0D0C0B0A090807060504
+        .octa     0xffffff0C0B0A09080706050403020100
+        .octa     0xffff0D0C0B0A09080706050403020100
+        .octa     0xff0E0D0C0B0A09080706050403020100
+        .octa     0x0F0E0D0C0B0A09080706050403020100
+
 
 .text
 
@@ -252,32 +275,66 @@ XMM2 XMM3 XMM4 XMMDst TMP6 TMP7 i i_seq operation
 	mov	   arg8, %r12           # %r12 = aadLen
 	mov	   %r12, %r11
 	pxor	   %xmm\i, %xmm\i
+	pxor       \XMM2, \XMM2
 
-_get_AAD_loop\num_initial_blocks\operation:
-	movd	   (%r10), \TMP1
-	pslldq	   $12, \TMP1
-	psrldq	   $4, %xmm\i
+	cmp	   $16, %r11
+	jl	   _get_AAD_rest8\num_initial_blocks\operation
+_get_AAD_blocks\num_initial_blocks\operation:
+	movdqu	   (%r10), %xmm\i
+	PSHUFB_XMM %xmm14, %xmm\i # byte-reflect the AAD data
+	pxor	   %xmm\i, \XMM2
+	GHASH_MUL  \XMM2, \TMP3, \TMP1, \TMP2, \TMP4, \TMP5, \XMM1
+	add	   $16, %r10
+	sub	   $16, %r12
+	sub	   $16, %r11
+	cmp	   $16, %r11
+	jge	   _get_AAD_blocks\num_initial_blocks\operation
+
+	movdqu	   \XMM2, %xmm\i
+	cmp	   $0, %r11
+	je	   _get_AAD_done\num_initial_blocks\operation
+
+	pxor	   %xmm\i,%xmm\i
+
+	/* read the last <16B of AAD. since we have at least 4B of
+	data right after the AAD (the ICV, and maybe some CT), we can
+	read 4B/8B blocks safely, and then get rid of the extra stuff */
+_get_AAD_rest8\num_initial_blocks\operation:
+	cmp	   $4, %r11
+	jle	   _get_AAD_rest4\num_initial_blocks\operation
+	movq	   (%r10), \TMP1
+	add	   $8, %r10
+	sub	   $8, %r11
+	pslldq	   $8, \TMP1
+	psrldq	   $8, %xmm\i
 	pxor	   \TMP1, %xmm\i
+	jmp	   _get_AAD_rest8\num_initial_blocks\operation
+_get_AAD_rest4\num_initial_blocks\operation:
+	cmp	   $0, %r11
+	jle	   _get_AAD_rest0\num_initial_blocks\operation
+	mov	   (%r10), %eax
+	movq	   %rax, \TMP1
 	add	   $4, %r10
-	sub	   $4, %r12
-	jne	   _get_AAD_loop\num_initial_blocks\operation
-
-	cmp	   $16, %r11
-	je	   _get_AAD_loop2_done\num_initial_blocks\operation
-
-	mov	   $16, %r12
-_get_AAD_loop2\num_initial_blocks\operation:
+	sub	   $4, %r10
+	pslldq	   $12, \TMP1
 	psrldq	   $4, %xmm\i
-	sub	   $4, %r12
-	cmp	   %r11, %r12
-	jne	   _get_AAD_loop2\num_initial_blocks\operation
-
-_get_AAD_loop2_done\num_initial_blocks\operation:
+	pxor	   \TMP1, %xmm\i
+_get_AAD_rest0\num_initial_blocks\operation:
+	/* finalize: shift out the extra bytes we read, and align
+	left. since pslldq can only shift by an immediate, we use
+	vpshufb and an array of shuffle masks */
+	movq	   %r12, %r11
+	salq	   $4, %r11
+	movdqu	   aad_shift_arr(%r11), \TMP1
+	PSHUFB_XMM \TMP1, %xmm\i
+_get_AAD_rest_final\num_initial_blocks\operation:
 	PSHUFB_XMM   %xmm14, %xmm\i # byte-reflect the AAD data
+	pxor	   \XMM2, %xmm\i
+	GHASH_MUL  %xmm\i, \TMP3, \TMP1, \TMP2, \TMP4, \TMP5, \XMM1
 
+_get_AAD_done\num_initial_blocks\operation:
 	xor	   %r11, %r11 # initialise the data pointer offset as zero
-
-        # start AES for num_initial_blocks blocks
+	# start AES for num_initial_blocks blocks
 
 	mov	   %arg5, %rax                      # %rax = *Y0
 	movdqu	   (%rax), \XMM0                    # XMM0 = Y0
@@ -322,7 +379,7 @@ XMM2 XMM3 XMM4 XMMDst TMP6 TMP7 i i_seq operation
                 # prepare plaintext/ciphertext for GHASH computation
 .endr
 .endif
-	GHASH_MUL  %xmm\i, \TMP3, \TMP1, \TMP2, \TMP4, \TMP5, \XMM1
+
         # apply GHASH on num_initial_blocks blocks
 
 .if \i == 5
@@ -477,28 +534,66 @@ XMM2 XMM3 XMM4 XMMDst TMP6 TMP7 i i_seq operation
 	mov	   arg8, %r12           # %r12 = aadLen
 	mov	   %r12, %r11
 	pxor	   %xmm\i, %xmm\i
-_get_AAD_loop\num_initial_blocks\operation:
-	movd	   (%r10), \TMP1
-	pslldq	   $12, \TMP1
-	psrldq	   $4, %xmm\i
+	pxor	   \XMM2, \XMM2
+
+	cmp	   $16, %r11
+	jl	   _get_AAD_rest8\num_initial_blocks\operation
+_get_AAD_blocks\num_initial_blocks\operation:
+	movdqu	   (%r10), %xmm\i
+	PSHUFB_XMM   %xmm14, %xmm\i # byte-reflect the AAD data
+	pxor	   %xmm\i, \XMM2
+	GHASH_MUL  \XMM2, \TMP3, \TMP1, \TMP2, \TMP4, \TMP5, \XMM1
+	add	   $16, %r10
+	sub	   $16, %r12
+	sub	   $16, %r11
+	cmp	   $16, %r11
+	jge	   _get_AAD_blocks\num_initial_blocks\operation
+
+	movdqu	   \XMM2, %xmm\i
+	cmp	   $0, %r11
+	je	   _get_AAD_done\num_initial_blocks\operation
+
+	pxor	   %xmm\i,%xmm\i
+
+	/* read the last <16B of AAD. since we have at least 4B of
+	data right after the AAD (the ICV, and maybe some PT), we can
+	read 4B/8B blocks safely, and then get rid of the extra stuff */
+_get_AAD_rest8\num_initial_blocks\operation:
+	cmp	   $4, %r11
+	jle	   _get_AAD_rest4\num_initial_blocks\operation
+	movq	   (%r10), \TMP1
+	add	   $8, %r10
+	sub	   $8, %r11
+	pslldq	   $8, \TMP1
+	psrldq	   $8, %xmm\i
 	pxor	   \TMP1, %xmm\i
+	jmp	   _get_AAD_rest8\num_initial_blocks\operation
+_get_AAD_rest4\num_initial_blocks\operation:
+	cmp	   $0, %r11
+	jle	   _get_AAD_rest0\num_initial_blocks\operation
+	mov	   (%r10), %eax
+	movq	   %rax, \TMP1
 	add	   $4, %r10
-	sub	   $4, %r12
-	jne	   _get_AAD_loop\num_initial_blocks\operation
-	cmp	   $16, %r11
-	je	   _get_AAD_loop2_done\num_initial_blocks\operation
-	mov	   $16, %r12
-_get_AAD_loop2\num_initial_blocks\operation:
+	sub	   $4, %r10
+	pslldq	   $12, \TMP1
 	psrldq	   $4, %xmm\i
-	sub	   $4, %r12
-	cmp	   %r11, %r12
-	jne	   _get_AAD_loop2\num_initial_blocks\operation
-_get_AAD_loop2_done\num_initial_blocks\operation:
+	pxor	   \TMP1, %xmm\i
+_get_AAD_rest0\num_initial_blocks\operation:
+	/* finalize: shift out the extra bytes we read, and align
+	left. since pslldq can only shift by an immediate, we use
+	vpshufb and an array of shuffle masks */
+	movq	   %r12, %r11
+	salq	   $4, %r11
+	movdqu	   aad_shift_arr(%r11), \TMP1
+	PSHUFB_XMM \TMP1, %xmm\i
+_get_AAD_rest_final\num_initial_blocks\operation:
 	PSHUFB_XMM   %xmm14, %xmm\i # byte-reflect the AAD data
+	pxor	   \XMM2, %xmm\i
+	GHASH_MUL  %xmm\i, \TMP3, \TMP1, \TMP2, \TMP4, \TMP5, \XMM1
 
+_get_AAD_done\num_initial_blocks\operation:
 	xor	   %r11, %r11 # initialise the data pointer offset as zero
-
-        # start AES for num_initial_blocks blocks
+	# start AES for num_initial_blocks blocks
 
 	mov	   %arg5, %rax                      # %rax = *Y0
 	movdqu	   (%rax), \XMM0                    # XMM0 = Y0
@@ -543,7 +638,7 @@ XMM2 XMM3 XMM4 XMMDst TMP6 TMP7 i i_seq operation
 		# prepare plaintext/ciphertext for GHASH computation
 .endr
 .endif
-	GHASH_MUL  %xmm\i, \TMP3, \TMP1, \TMP2, \TMP4, \TMP5, \XMM1
+
         # apply GHASH on num_initial_blocks blocks
 
 .if \i == 5
-- 
2.12.2
