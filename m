From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: [PATCH 22/33] x86/asm/bpf: Annotate callable functions
Date: Thu, 21 Jan 2016 16:49:26 -0600
Message-ID: <bbe1de0c299fecd4fc9a1766bae8be2647bedb01.1453405861.git.jpoimboe@redhat.com>
References: <cover.1453405861.git.jpoimboe@redhat.com>
Cc: linux-kernel@vger.kernel.org, live-patching@vger.kernel.org,
	Michal Marek <mmarek@suse.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@kernel.org>,
	Borislav Petkov <bp@alien8.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Pedro Alves <palves@redhat.com>,
	Namhyung Kim <namhyung@gmail.com>,
	Bernd Petrovitsch <bernd@petrovitsch.priv.at>,
	Chris J Arges <chris.j.arges@canonical.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jiri Slaby <jslaby@suse.cz>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1453405861.git.jpoimboe@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bpf_jit.S has several functions which can be called from C code.  Give
them proper ELF annotations.

Signed-off-by: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: netdev@vger.kernel.org
---
 arch/x86/net/bpf_jit.S | 39 ++++++++++++++++-----------------------
 1 file changed, 16 insertions(+), 23 deletions(-)

diff --git a/arch/x86/net/bpf_jit.S b/arch/x86/net/bpf_jit.S
index 4093216..eb4a3bd 100644
--- a/arch/x86/net/bpf_jit.S
+++ b/arch/x86/net/bpf_jit.S
@@ -22,15 +22,16 @@
 	32 /* space for rbx,r13,r14,r15 */ + \
 	8 /* space for skb_copy_bits */)
 
-sk_load_word:
-	.globl	sk_load_word
+#define FUNC(name) \
+	.globl name; \
+	.type name, @function; \
+	name:
 
+FUNC(sk_load_word)
 	test	%esi,%esi
 	js	bpf_slow_path_word_neg
 
-sk_load_word_positive_offset:
-	.globl	sk_load_word_positive_offset
-
+FUNC(sk_load_word_positive_offset)
 	mov	%r9d,%eax		# hlen
 	sub	%esi,%eax		# hlen - offset
 	cmp	$3,%eax
@@ -39,15 +40,11 @@ sk_load_word_positive_offset:
 	bswap   %eax  			/* ntohl() */
 	ret
 
-sk_load_half:
-	.globl	sk_load_half
-
+FUNC(sk_load_half)
 	test	%esi,%esi
 	js	bpf_slow_path_half_neg
 
-sk_load_half_positive_offset:
-	.globl	sk_load_half_positive_offset
-
+FUNC(sk_load_half_positive_offset)
 	mov	%r9d,%eax
 	sub	%esi,%eax		#	hlen - offset
 	cmp	$1,%eax
@@ -56,15 +53,11 @@ sk_load_half_positive_offset:
 	rol	$8,%ax			# ntohs()
 	ret
 
-sk_load_byte:
-	.globl	sk_load_byte
-
+FUNC(sk_load_byte)
 	test	%esi,%esi
 	js	bpf_slow_path_byte_neg
 
-sk_load_byte_positive_offset:
-	.globl	sk_load_byte_positive_offset
-
+FUNC(sk_load_byte_positive_offset)
 	cmp	%esi,%r9d   /* if (offset >= hlen) goto bpf_slow_path_byte */
 	jle	bpf_slow_path_byte
 	movzbl	(SKBDATA,%rsi),%eax
@@ -120,8 +113,8 @@ bpf_slow_path_byte:
 bpf_slow_path_word_neg:
 	cmp	SKF_MAX_NEG_OFF, %esi	/* test range */
 	jl	bpf_error	/* offset lower -> error  */
-sk_load_word_negative_offset:
-	.globl	sk_load_word_negative_offset
+
+FUNC(sk_load_word_negative_offset)
 	sk_negative_common(4)
 	mov	(%rax), %eax
 	bswap	%eax
@@ -130,8 +123,8 @@ sk_load_word_negative_offset:
 bpf_slow_path_half_neg:
 	cmp	SKF_MAX_NEG_OFF, %esi
 	jl	bpf_error
-sk_load_half_negative_offset:
-	.globl	sk_load_half_negative_offset
+
+FUNC(sk_load_half_negative_offset)
 	sk_negative_common(2)
 	mov	(%rax),%ax
 	rol	$8,%ax
@@ -141,8 +134,8 @@ sk_load_half_negative_offset:
 bpf_slow_path_byte_neg:
 	cmp	SKF_MAX_NEG_OFF, %esi
 	jl	bpf_error
-sk_load_byte_negative_offset:
-	.globl	sk_load_byte_negative_offset
+
+FUNC(sk_load_byte_negative_offset)
 	sk_negative_common(1)
 	movzbl	(%rax), %eax
 	ret
-- 
2.4.3
