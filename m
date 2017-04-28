From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH 4/7] crypto: aesni: make AVX AES-GCM work with all valid auth_tag_len
Date: Fri, 28 Apr 2017 18:11:59 +0200
Message-ID: <341c406e29e71369bc1fa6f614ae6904c58cfee4.1493395785.git.sd@queasysnail.net>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1493395785.git.sd@queasysnail.net>
In-Reply-To: <cover.1493395785.git.sd@queasysnail.net>
References: <cover.1493395785.git.sd@queasysnail.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 arch/x86/crypto/aesni-intel_avx-x86_64.S | 31 ++++++++++++++++++++++++-------
 1 file changed, 24 insertions(+), 7 deletions(-)

diff --git a/arch/x86/crypto/aesni-intel_avx-x86_64.S b/arch/x86/crypto/aesni-intel_avx-x86_64.S
index a73117c84904..ee6283120f83 100644
--- a/arch/x86/crypto/aesni-intel_avx-x86_64.S
+++ b/arch/x86/crypto/aesni-intel_avx-x86_64.S
@@ -1481,19 +1481,36 @@ VARIABLE_OFFSET = 16*8
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
