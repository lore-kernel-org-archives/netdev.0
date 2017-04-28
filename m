From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH 3/7] crypto: aesni: make AVX AES-GCM work with any aadlen
Date: Fri, 28 Apr 2017 18:11:58 +0200
Message-ID: <aa6a030e469f366285af8ec2483a62dbbfb88e86.1493395785.git.sd@queasysnail.net>
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
Received: from mx1.redhat.com ([209.132.183.28]:36910 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1426304AbdD1QMr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 12:12:47 -0400
In-Reply-To: <cover.1493395785.git.sd@queasysnail.net>
In-Reply-To: <cover.1493395785.git.sd@queasysnail.net>
References: <cover.1493395785.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the first step to make the aesni AES-GCM implementation
generic. The current code was written for rfc4106, so it handles
only some specific sizes of associated data.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 arch/x86/crypto/aesni-intel_avx-x86_64.S | 122 ++++++++++++++++++++++---------
 1 file changed, 88 insertions(+), 34 deletions(-)

diff --git a/arch/x86/crypto/aesni-intel_avx-x86_64.S b/arch/x86/crypto/aesni-intel_avx-x86_64.S
index d664382c6e56..a73117c84904 100644
--- a/arch/x86/crypto/aesni-intel_avx-x86_64.S
+++ b/arch/x86/crypto/aesni-intel_avx-x86_64.S
@@ -155,6 +155,30 @@ SHIFT_MASK:      .octa     0x0f0e0d0c0b0a09080706050403020100
 ALL_F:           .octa     0xffffffffffffffffffffffffffffffff
                  .octa     0x00000000000000000000000000000000
 
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
+
 .text
 
 
@@ -372,41 +396,72 @@ VARIABLE_OFFSET = 16*8
 
 .macro INITIAL_BLOCKS_AVX num_initial_blocks T1 T2 T3 T4 T5 CTR XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 XMM8 T6 T_key ENC_DEC
 	i = (8-\num_initial_blocks)
+	j = 0
 	setreg
 
-        mov     arg6, %r10                      # r10 = AAD
-        mov     arg7, %r12                      # r12 = aadLen
-
-
-        mov     %r12, %r11
-
-        vpxor   reg_i, reg_i, reg_i
-_get_AAD_loop\@:
-        vmovd   (%r10), \T1
-        vpslldq $12, \T1, \T1
-        vpsrldq $4, reg_i, reg_i
-        vpxor   \T1, reg_i, reg_i
-
-        add     $4, %r10
-        sub     $4, %r12
-        jg      _get_AAD_loop\@
-
-
-        cmp     $16, %r11
-        je      _get_AAD_loop2_done\@
-        mov     $16, %r12
-
-_get_AAD_loop2\@:
-        vpsrldq $4, reg_i, reg_i
-        sub     $4, %r12
-        cmp     %r11, %r12
-        jg      _get_AAD_loop2\@
-
-_get_AAD_loop2_done\@:
-
-        #byte-reflect the AAD data
-        vpshufb SHUF_MASK(%rip), reg_i, reg_i
-
+	mov     arg6, %r10                      # r10 = AAD
+	mov     arg7, %r12                      # r12 = aadLen
+
+
+	mov     %r12, %r11
+
+	vpxor   reg_j, reg_j, reg_j
+	vpxor   reg_i, reg_i, reg_i
+	cmp     $16, %r11
+	jl      _get_AAD_rest8\@
+_get_AAD_blocks\@:
+	vmovdqu (%r10), reg_i
+	vpshufb SHUF_MASK(%rip), reg_i, reg_i
+	vpxor   reg_i, reg_j, reg_j
+	GHASH_MUL_AVX       reg_j, \T2, \T1, \T3, \T4, \T5, \T6
+	add     $16, %r10
+	sub     $16, %r12
+	sub     $16, %r11
+	cmp     $16, %r11
+	jge     _get_AAD_blocks\@
+	vmovdqu reg_j, reg_i
+	cmp     $0, %r11
+	je      _get_AAD_done\@
+
+	vpxor   reg_i, reg_i, reg_i
+
+	/* read the last <16B of AAD. since we have at least 4B of
+	data right after the AAD (the ICV, and maybe some CT), we can
+	read 4B/8B blocks safely, and then get rid of the extra stuff */
+_get_AAD_rest8\@:
+	cmp     $4, %r11
+	jle     _get_AAD_rest4\@
+	movq    (%r10), \T1
+	add     $8, %r10
+	sub     $8, %r11
+	vpslldq $8, \T1, \T1
+	vpsrldq $8, reg_i, reg_i
+	vpxor   \T1, reg_i, reg_i
+	jmp     _get_AAD_rest8\@
+_get_AAD_rest4\@:
+	cmp     $0, %r11
+	jle      _get_AAD_rest0\@
+	mov     (%r10), %eax
+	movq    %rax, \T1
+	add     $4, %r10
+	sub     $4, %r11
+	vpslldq $12, \T1, \T1
+	vpsrldq $4, reg_i, reg_i
+	vpxor   \T1, reg_i, reg_i
+_get_AAD_rest0\@:
+	/* finalize: shift out the extra bytes we read, and align
+	left. since pslldq can only shift by an immediate, we use
+	vpshufb and an array of shuffle masks */
+	movq    %r12, %r11
+	salq    $4, %r11
+	movdqu  aad_shift_arr(%r11), \T1
+	vpshufb \T1, reg_i, reg_i
+_get_AAD_rest_final\@:
+	vpshufb SHUF_MASK(%rip), reg_i, reg_i
+	vpxor   reg_j, reg_i, reg_i
+	GHASH_MUL_AVX       reg_i, \T2, \T1, \T3, \T4, \T5, \T6
+
+_get_AAD_done\@:
 	# initialize the data pointer offset as zero
 	xor     %r11, %r11
 
@@ -480,7 +535,6 @@ VARIABLE_OFFSET = 16*8
 	i = (8-\num_initial_blocks)
 	j = (9-\num_initial_blocks)
 	setreg
-        GHASH_MUL_AVX       reg_i, \T2, \T1, \T3, \T4, \T5, \T6
 
 .rep \num_initial_blocks
         vpxor    reg_i, reg_j, reg_j
-- 
2.12.2
