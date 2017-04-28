From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH 2/7] crypto: aesni: make non-AVX AES-GCM work with all valid auth_tag_len
Date: Fri, 28 Apr 2017 18:11:57 +0200
Message-ID: <438115ad71e748b825d54bf1cb7ec74374040613.1493395785.git.sd@queasysnail.net>
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

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 arch/x86/crypto/aesni-intel_asm.S | 62 ++++++++++++++++++++++++++++++---------
 1 file changed, 48 insertions(+), 14 deletions(-)

diff --git a/arch/x86/crypto/aesni-intel_asm.S b/arch/x86/crypto/aesni-intel_asm.S
index 605726aaf0a2..16627fec80b2 100644
--- a/arch/x86/crypto/aesni-intel_asm.S
+++ b/arch/x86/crypto/aesni-intel_asm.S
@@ -1549,18 +1549,35 @@ ENTRY(aesni_gcm_dec)
 	mov	arg10, %r11               # %r11 = auth_tag_len
 	cmp	$16, %r11
 	je	_T_16_decrypt
-	cmp	$12, %r11
-	je	_T_12_decrypt
+	cmp	$8, %r11
+	jl	_T_4_decrypt
 _T_8_decrypt:
 	MOVQ_R64_XMM	%xmm0, %rax
 	mov	%rax, (%r10)
-	jmp	_return_T_done_decrypt
-_T_12_decrypt:
-	MOVQ_R64_XMM	%xmm0, %rax
-	mov	%rax, (%r10)
+	add	$8, %r10
+	sub	$8, %r11
 	psrldq	$8, %xmm0
+	cmp	$0, %r11
+	je	_return_T_done_decrypt
+_T_4_decrypt:
+	movd	%xmm0, %eax
+	mov	%eax, (%r10)
+	add	$4, %r10
+	sub	$4, %r11
+	psrldq	$4, %xmm0
+	cmp	$0, %r11
+	je	_return_T_done_decrypt
+_T_123_decrypt:
 	movd	%xmm0, %eax
-	mov	%eax, 8(%r10)
+	cmp	$2, %r11
+	jl	_T_1_decrypt
+	mov	%ax, (%r10)
+	cmp	$2, %r11
+	je	_return_T_done_decrypt
+	add	$2, %r10
+	sar	$16, %eax
+_T_1_decrypt:
+	mov	%al, (%r10)
 	jmp	_return_T_done_decrypt
 _T_16_decrypt:
 	movdqu	%xmm0, (%r10)
@@ -1813,18 +1830,35 @@ ENTRY(aesni_gcm_enc)
 	mov	arg10, %r11                    # %r11 = auth_tag_len
 	cmp	$16, %r11
 	je	_T_16_encrypt
-	cmp	$12, %r11
-	je	_T_12_encrypt
+	cmp	$8, %r11
+	jl	_T_4_encrypt
 _T_8_encrypt:
 	MOVQ_R64_XMM	%xmm0, %rax
 	mov	%rax, (%r10)
-	jmp	_return_T_done_encrypt
-_T_12_encrypt:
-	MOVQ_R64_XMM	%xmm0, %rax
-	mov	%rax, (%r10)
+	add	$8, %r10
+	sub	$8, %r11
 	psrldq	$8, %xmm0
+	cmp	$0, %r11
+	je	_return_T_done_encrypt
+_T_4_encrypt:
+	movd	%xmm0, %eax
+	mov	%eax, (%r10)
+	add	$4, %r10
+	sub	$4, %r11
+	psrldq	$4, %xmm0
+	cmp	$0, %r11
+	je	_return_T_done_encrypt
+_T_123_encrypt:
 	movd	%xmm0, %eax
-	mov	%eax, 8(%r10)
+	cmp	$2, %r11
+	jl	_T_1_encrypt
+	mov	%ax, (%r10)
+	cmp	$2, %r11
+	je	_return_T_done_encrypt
+	add	$2, %r10
+	sar	$16, %eax
+_T_1_encrypt:
+	mov	%al, (%r10)
 	jmp	_return_T_done_encrypt
 _T_16_encrypt:
 	movdqu	%xmm0, (%r10)
-- 
2.12.2
