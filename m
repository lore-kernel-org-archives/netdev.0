From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: [PATCH v17 7/9] bpf: Add __bpf_prog_run() to objtool whitelist
Date: Wed, 24 Feb 2016 10:36:09 -0600
Message-ID: <5309cb35aa061d385e2bfcb7ac1fbb2f1fac90b7.1456331595.git.jpoimboe@redhat.com>
References: <cover.1456331595.git.jpoimboe@redhat.com>
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
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1456331595.git.jpoimboe@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

objtool reports the following false positive warnings:

  objtool: kernel/bpf/core.o: __bpf_prog_run()+0x5c: sibling call from callable instruction with changed frame pointer
  objtool: kernel/bpf/core.o: __bpf_prog_run()+0x60: function has unreachable instruction
  objtool: kernel/bpf/core.o: __bpf_prog_run()+0x64: function has unreachable instruction
  [...]

It's confused by the following dynamic jump instruction in
__bpf_prog_run()::

  jmp     *(%r12,%rax,8)

which corresponds to the following line in the C code:

  goto *jumptable[insn->code];

There's no way for objtool to deterministically find all possible
branch targets for a dynamic jump, so it can't verify this code.

In this case the jumps all stay within the function, and there's nothing
unusual going on related to the stack, so we can whitelist the function.

Signed-off-by: Josh Poimboeuf <jpoimboe@redhat.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Cc: netdev@vger.kernel.org
---
 kernel/bpf/core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 972d9a8..b26b1f8 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -27,6 +27,7 @@
 #include <linux/random.h>
 #include <linux/moduleloader.h>
 #include <linux/bpf.h>
+#include <linux/objtool.h>
 
 #include <asm/unaligned.h>
 
@@ -649,6 +650,7 @@ load_byte:
 		WARN_RATELIMIT(1, "unknown opcode %02x\n", insn->code);
 		return 0;
 }
+STACK_FRAME_NON_STANDARD(__bpf_prog_run); /* jump table */
 
 bool bpf_prog_array_compatible(struct bpf_array *array,
 			       const struct bpf_prog *fp)
-- 
2.4.3
