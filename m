From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH v3 07/29] x86: bpf_jit, use ENTRY+ENDPROC
Date: Fri, 21 Apr 2017 16:12:43 +0200
Message-ID: <20170421141305.25180-7-jslaby@suse.cz>
References: <20170421141305.25180-1-jslaby@suse.cz>
Cc: tglx@linutronix.de, hpa@zytor.com, x86@kernel.org,
        jpoimboe@redhat.com, linux-kernel@vger.kernel.org,
        Jiri Slaby <jslaby@suse.cz>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: mingo@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56071 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1040442AbdDUONM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 10:13:12 -0400
In-Reply-To: <20170421141305.25180-1-jslaby@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not use a custom macro FUNC for starts of the global functions, use
ENTRY instead.

And while at it, annotate also ends of the functions by ENDPROC.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: netdev@vger.kernel.org
---
 arch/x86/net/bpf_jit.S | 32 ++++++++++++++++++--------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git a/arch/x86/net/bpf_jit.S b/arch/x86/net/bpf_jit.S
index f2a7faf4706e..762c29fb8832 100644
--- a/arch/x86/net/bpf_jit.S
+++ b/arch/x86/net/bpf_jit.S
@@ -23,16 +23,12 @@
 	32 /* space for rbx,r13,r14,r15 */ + \
 	8 /* space for skb_copy_bits */)
 
-#define FUNC(name) \
-	.globl name; \
-	.type name, @function; \
-	name:
-
-FUNC(sk_load_word)
+ENTRY(sk_load_word)
 	test	%esi,%esi
 	js	bpf_slow_path_word_neg
+ENDPROC(sk_load_word)
 
-FUNC(sk_load_word_positive_offset)
+ENTRY(sk_load_word_positive_offset)
 	mov	%r9d,%eax		# hlen
 	sub	%esi,%eax		# hlen - offset
 	cmp	$3,%eax
@@ -40,12 +36,14 @@ FUNC(sk_load_word_positive_offset)
 	mov     (SKBDATA,%rsi),%eax
 	bswap   %eax  			/* ntohl() */
 	ret
+ENDPROC(sk_load_word_positive_offset)
 
-FUNC(sk_load_half)
+ENTRY(sk_load_half)
 	test	%esi,%esi
 	js	bpf_slow_path_half_neg
+ENDPROC(sk_load_half)
 
-FUNC(sk_load_half_positive_offset)
+ENTRY(sk_load_half_positive_offset)
 	mov	%r9d,%eax
 	sub	%esi,%eax		#	hlen - offset
 	cmp	$1,%eax
@@ -53,16 +51,19 @@ FUNC(sk_load_half_positive_offset)
 	movzwl	(SKBDATA,%rsi),%eax
 	rol	$8,%ax			# ntohs()
 	ret
+ENDPROC(sk_load_half_positive_offset)
 
-FUNC(sk_load_byte)
+ENTRY(sk_load_byte)
 	test	%esi,%esi
 	js	bpf_slow_path_byte_neg
+ENDPROC(sk_load_byte)
 
-FUNC(sk_load_byte_positive_offset)
+ENTRY(sk_load_byte_positive_offset)
 	cmp	%esi,%r9d   /* if (offset >= hlen) goto bpf_slow_path_byte */
 	jle	bpf_slow_path_byte
 	movzbl	(SKBDATA,%rsi),%eax
 	ret
+ENDPROC(sk_load_byte_positive_offset)
 
 /* rsi contains offset and can be scratched */
 #define bpf_slow_path_common(LEN)		\
@@ -119,31 +120,34 @@ bpf_slow_path_word_neg:
 	cmp	SKF_MAX_NEG_OFF, %esi	/* test range */
 	jl	bpf_error	/* offset lower -> error  */
 
-FUNC(sk_load_word_negative_offset)
+ENTRY(sk_load_word_negative_offset)
 	sk_negative_common(4)
 	mov	(%rax), %eax
 	bswap	%eax
 	ret
+ENDPROC(sk_load_word_negative_offset)
 
 bpf_slow_path_half_neg:
 	cmp	SKF_MAX_NEG_OFF, %esi
 	jl	bpf_error
 
-FUNC(sk_load_half_negative_offset)
+ENTRY(sk_load_half_negative_offset)
 	sk_negative_common(2)
 	mov	(%rax),%ax
 	rol	$8,%ax
 	movzwl	%ax,%eax
 	ret
+ENDPROC(sk_load_half_negative_offset)
 
 bpf_slow_path_byte_neg:
 	cmp	SKF_MAX_NEG_OFF, %esi
 	jl	bpf_error
 
-FUNC(sk_load_byte_negative_offset)
+ENTRY(sk_load_byte_negative_offset)
 	sk_negative_common(1)
 	movzbl	(%rax), %eax
 	ret
+ENDPROC(sk_load_byte_negative_offset)
 
 bpf_error:
 # force a return 0 from jit handler
-- 
2.12.2
