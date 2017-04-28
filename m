From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH 5/7] crypto: aesni: make AVX2 AES-GCM work with any aadlen
Date: Fri, 28 Apr 2017 18:12:00 +0200
Message-ID: <8a3654d708f0f28784fc578127fd28db71e1fe30.1493395785.git.sd@queasysnail.net>
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
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <cover.1493395785.git.sd@queasysnail.net>
In-Reply-To: <cover.1493395785.git.sd@queasysnail.net>
References: <cover.1493395785.git.sd@queasysnail.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the first step to make the aesni AES-GCM implementation
generic. The current code was written for rfc4106, so it handles only
some specific sizes of associated data.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 arch/x86/crypto/aesni-intel_avx-x86_64.S | 85 ++++++++++++++++++++++----------
 1 file changed, 58 insertions(+), 27 deletions(-)

diff --git a/arch/x86/crypto/aesni-intel_avx-x86_64.S b/arch/x86/crypto/aesni-intel_avx-x86_64.S
index ee6283120f83..7230808a7cef 100644
--- a/arch/x86/crypto/aesni-intel_avx-x86_64.S
+++ b/arch/x86/crypto/aesni-intel_avx-x86_64.S
@@ -1702,41 +1702,73 @@ ENDPROC(aesni_gcm_dec_avx_gen2)
 
 .macro INITIAL_BLOCKS_AVX2 num_initial_blocks T1 T2 T3 T4 T5 CTR XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 XMM8 T6 T_key ENC_DEC VER
 	i = (8-\num_initial_blocks)
+	j = 0
 	setreg
 
-        mov     arg6, %r10                       # r10 = AAD
-        mov     arg7, %r12                       # r12 = aadLen
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
+	mov     arg6, %r10                       # r10 = AAD
+	mov     arg7, %r12                       # r12 = aadLen
 
-        add     $4, %r10
-        sub     $4, %r12
-        jg      _get_AAD_loop\@
 
+	mov     %r12, %r11
 
-        cmp     $16, %r11
-        je      _get_AAD_loop2_done\@
-        mov     $16, %r12
+	vpxor   reg_j, reg_j, reg_j
+	vpxor   reg_i, reg_i, reg_i
 
-_get_AAD_loop2\@:
-        vpsrldq $4, reg_i, reg_i
-        sub     $4, %r12
-        cmp     %r11, %r12
-        jg      _get_AAD_loop2\@
+	cmp     $16, %r11
+	jl      _get_AAD_rest8\@
+_get_AAD_blocks\@:
+	vmovdqu (%r10), reg_i
+	vpshufb SHUF_MASK(%rip), reg_i, reg_i
+	vpxor   reg_i, reg_j, reg_j
+	GHASH_MUL_AVX2      reg_j, \T2, \T1, \T3, \T4, \T5, \T6
+	add     $16, %r10
+	sub     $16, %r12
+	sub     $16, %r11
+	cmp     $16, %r11
+	jge     _get_AAD_blocks\@
+	vmovdqu reg_j, reg_i
+	cmp     $0, %r11
+	je      _get_AAD_done\@
 
-_get_AAD_loop2_done\@:
+	vpxor   reg_i, reg_i, reg_i
 
-        #byte-reflect the AAD data
-        vpshufb SHUF_MASK(%rip), reg_i, reg_i
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
+	jle     _get_AAD_rest0\@
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
+	GHASH_MUL_AVX2      reg_i, \T2, \T1, \T3, \T4, \T5, \T6
 
+_get_AAD_done\@:
 	# initialize the data pointer offset as zero
 	xor     %r11, %r11
 
@@ -1811,7 +1843,6 @@ ENDPROC(aesni_gcm_dec_avx_gen2)
 	i = (8-\num_initial_blocks)
 	j = (9-\num_initial_blocks)
 	setreg
-        GHASH_MUL_AVX2       reg_i, \T2, \T1, \T3, \T4, \T5, \T6
 
 .rep \num_initial_blocks
         vpxor    reg_i, reg_j, reg_j
-- 
2.12.2
