From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH 6/7] crypto: aesni: make AVX2 AES-GCM work with all valid auth_tag_len
Date: Fri, 28 Apr 2017 18:12:01 +0200
Message-ID: <15bc4be561e5ab8113d02848d8fe3b684b15a172.1493395785.git.sd@queasysnail.net>
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
Received: from mx1.redhat.com ([209.132.183.28]:47304 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756069AbdD1QMz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 12:12:55 -0400
In-Reply-To: <cover.1493395785.git.sd@queasysnail.net>
In-Reply-To: <cover.1493395785.git.sd@queasysnail.net>
References: <cover.1493395785.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 arch/x86/crypto/aesni-intel_avx-x86_64.S | 31 ++++++++++++++++++++++++-------
 1 file changed, 24 insertions(+), 7 deletions(-)

diff --git a/arch/x86/crypto/aesni-intel_avx-x86_64.S b/arch/x86/crypto/aesni-intel_avx-x86_64.S
index 7230808a7cef..faecb1518bf8 100644
--- a/arch/x86/crypto/aesni-intel_avx-x86_64.S
+++ b/arch/x86/crypto/aesni-intel_avx-x86_64.S
@@ -2804,19 +2804,36 @@ ENDPROC(aesni_gcm_dec_avx_gen2)
         cmp     $16, %r11
         je      _T_16\@
 
-        cmp     $12, %r11
-        je      _T_12\@
+        cmp     $8, %r11
+        jl      _T_4\@
 
 _T_8\@:
         vmovq   %xmm9, %rax
         mov     %rax, (%r10)
-        jmp     _return_T_done\@
-_T_12\@:
-        vmovq   %xmm9, %rax
-        mov     %rax, (%r10)
+        add     $8, %r10
+        sub     $8, %r11
         vpsrldq $8, %xmm9, %xmm9
+        cmp     $0, %r11
+        je     _return_T_done\@
+_T_4\@:
         vmovd   %xmm9, %eax
-        mov     %eax, 8(%r10)
+        mov     %eax, (%r10)
+        add     $4, %r10
+        sub     $4, %r11
+        vpsrldq     $4, %xmm9, %xmm9
+        cmp     $0, %r11
+        je     _return_T_done\@
+_T_123\@:
+        vmovd     %xmm9, %eax
+        cmp     $2, %r11
+        jl     _T_1\@
+        mov     %ax, (%r10)
+        cmp     $2, %r11
+        je     _return_T_done\@
+        add     $2, %r10
+        sar     $16, %eax
+_T_1\@:
+        mov     %al, (%r10)
         jmp     _return_T_done\@
 
 _T_16\@:
-- 
2.12.2
