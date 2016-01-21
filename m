From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: [PATCH 23/33] x86/asm/bpf: Create stack frames in bpf_jit.S
Date: Thu, 21 Jan 2016 16:49:27 -0600
Message-ID: <fa4c41976b438b51954cb8021f06bceb1d1d66cc.1453405861.git.jpoimboe@redhat.com>
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

bpf_jit.S has several callable non-leaf functions which don't honor
CONFIG_FRAME_POINTER, which can result in bad stack traces.

Create a stack frame before the call instructions when
CONFIG_FRAME_POINTER is enabled.

Signed-off-by: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: netdev@vger.kernel.org
---
 arch/x86/net/bpf_jit.S | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/arch/x86/net/bpf_jit.S b/arch/x86/net/bpf_jit.S
index eb4a3bd..f2a7faf 100644
--- a/arch/x86/net/bpf_jit.S
+++ b/arch/x86/net/bpf_jit.S
@@ -8,6 +8,7 @@
  * of the License.
  */
 #include <linux/linkage.h>
+#include <asm/frame.h>
 
 /*
  * Calling convention :
@@ -65,16 +66,18 @@ FUNC(sk_load_byte_positive_offset)
 
 /* rsi contains offset and can be scratched */
 #define bpf_slow_path_common(LEN)		\
+	lea	-MAX_BPF_STACK + 32(%rbp), %rdx;\
+	FRAME_BEGIN;				\
 	mov	%rbx, %rdi; /* arg1 == skb */	\
 	push	%r9;				\
 	push	SKBDATA;			\
 /* rsi already has offset */			\
 	mov	$LEN,%ecx;	/* len */	\
-	lea	- MAX_BPF_STACK + 32(%rbp),%rdx;			\
 	call	skb_copy_bits;			\
 	test    %eax,%eax;			\
 	pop	SKBDATA;			\
-	pop	%r9;
+	pop	%r9;				\
+	FRAME_END
 
 
 bpf_slow_path_word:
@@ -99,6 +102,7 @@ bpf_slow_path_byte:
 	ret
 
 #define sk_negative_common(SIZE)				\
+	FRAME_BEGIN;						\
 	mov	%rbx, %rdi; /* arg1 == skb */			\
 	push	%r9;						\
 	push	SKBDATA;					\
@@ -108,6 +112,7 @@ bpf_slow_path_byte:
 	test	%rax,%rax;					\
 	pop	SKBDATA;					\
 	pop	%r9;						\
+	FRAME_END;						\
 	jz	bpf_error
 
 bpf_slow_path_word_neg:
-- 
2.4.3
