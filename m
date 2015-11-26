From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next v2 5/5] {f,m}_bpf: add more example code
Date: Thu, 26 Nov 2015 15:38:46 +0100
Message-ID: <d40d1f8668201d9a766aabef4045c6baf14aa146.1448547199.git.daniel@iogearbox.net>
References: <cover.1448547199.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49509 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026AbbKZOix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 09:38:53 -0500
In-Reply-To: <cover.1448547199.git.daniel@iogearbox.net>
In-Reply-To: <cover.1448547199.git.daniel@iogearbox.net>
References: <cover.1448547199.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've added three examples to examples/bpf/ that demonstrate how one can
implement eBPF tail calls in tc with f.e. multiple levels of nesting.
That should act as a good starting point, but also as test cases for the
ELF loader and kernel. A real test suite for {f,m,e}_bpf is still to be
developed in future work.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 examples/bpf/README         |  13 +++++
 examples/bpf/bpf_cyclic.c   |  32 ++++++++++++
 examples/bpf/bpf_funcs.h    |  11 +++++
 examples/bpf/bpf_graft.c    |  70 +++++++++++++++++++++++++++
 examples/bpf/bpf_tailcall.c | 115 ++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 241 insertions(+)
 create mode 100644 examples/bpf/README
 create mode 100644 examples/bpf/bpf_cyclic.c
 create mode 100644 examples/bpf/bpf_graft.c
 create mode 100644 examples/bpf/bpf_tailcall.c

diff --git a/examples/bpf/README b/examples/bpf/README
new file mode 100644
index 0000000..4247257
--- /dev/null
+++ b/examples/bpf/README
@@ -0,0 +1,13 @@
+eBPF toy code examples (running in kernel) to familiarize yourself
+with syntax and features:
+
+ - bpf_prog.c		-> Classifier examples with using maps
+ - bpf_shared.c		-> Ingress/egress map sharing example
+ - bpf_tailcall.c	-> Using tail call chains
+ - bpf_cyclic.c		-> Simple cycle as tail calls
+ - bpf_graft.c		-> Demo on altering runtime behaviour
+
+User space code example:
+
+ - bpf_agent.c		-> Counterpart to bpf_prog.c for user
+                           space to transfer/read out map data
diff --git a/examples/bpf/bpf_cyclic.c b/examples/bpf/bpf_cyclic.c
new file mode 100644
index 0000000..bde061c
--- /dev/null
+++ b/examples/bpf/bpf_cyclic.c
@@ -0,0 +1,32 @@
+#include <linux/bpf.h>
+
+#include "bpf_funcs.h"
+
+/* Cyclic dependency example to test the kernel's runtime upper
+ * bound on loops.
+ */
+struct bpf_elf_map __section("maps") jmp_tc = {
+	.type		= BPF_MAP_TYPE_PROG_ARRAY,
+	.id		= 0xabccba,
+	.size_key	= sizeof(int),
+	.size_value	= sizeof(int),
+	.pinning	= PIN_OBJECT_NS,
+	.max_elem	= 1,
+};
+
+__section_tail(0xabccba, 0) int cls_loop(struct __sk_buff *skb)
+{
+	char fmt[] = "cb: %u\n";
+
+	bpf_printk(fmt, sizeof(fmt), skb->cb[0]++);
+	bpf_tail_call(skb, &jmp_tc, 0);
+	return -1;
+}
+
+__section("classifier") int cls_entry(struct __sk_buff *skb)
+{
+	bpf_tail_call(skb, &jmp_tc, 0);
+	return -1;
+}
+
+char __license[] __section("license") = "GPL";
diff --git a/examples/bpf/bpf_funcs.h b/examples/bpf/bpf_funcs.h
index 1369401..6d058f0 100644
--- a/examples/bpf/bpf_funcs.h
+++ b/examples/bpf/bpf_funcs.h
@@ -10,10 +10,18 @@
 # define __maybe_unused		__attribute__ ((__unused__))
 #endif
 
+#ifndef __stringify
+# define __stringify(x)		#x
+#endif
+
 #ifndef __section
 # define __section(NAME)	__attribute__((section(NAME), used))
 #endif
 
+#ifndef __section_tail
+# define __section_tail(m, x)	__section(__stringify(m) "/" __stringify(x))
+#endif
+
 #ifndef offsetof
 # define offsetof		__builtin_offsetof
 #endif
@@ -50,6 +58,9 @@ static unsigned int (*get_prandom_u32)(void) __maybe_unused =
 static int (*bpf_printk)(const char *fmt, int fmt_size, ...) __maybe_unused =
 	(void *) BPF_FUNC_trace_printk;
 
+static void (*bpf_tail_call)(void *ctx, void *map, int index) __maybe_unused =
+	(void *) BPF_FUNC_tail_call;
+
 /* LLVM built-in functions that an eBPF C program may use to emit
  * BPF_LD_ABS and BPF_LD_IND instructions.
  */
diff --git a/examples/bpf/bpf_graft.c b/examples/bpf/bpf_graft.c
new file mode 100644
index 0000000..f36d25a
--- /dev/null
+++ b/examples/bpf/bpf_graft.c
@@ -0,0 +1,70 @@
+#include <linux/bpf.h>
+
+#include "bpf_funcs.h"
+
+/* This example demonstrates how classifier run-time behaviour
+ * can be altered with tail calls. We start out with an empty
+ * jmp_tc array, then add section aaa to the array slot 0, and
+ * later on atomically replace it with section bbb. Note that
+ * as shown in other examples, the tc loader can prepopulate
+ * tail called sections, here we start out with an empty one
+ * on purpose to show it can also be done this way.
+ *
+ * tc filter add dev foo parent ffff: bpf obj graft.o
+ * tc exec bpf dbg
+ *   [...]
+ *   Socket Thread-20229 [001] ..s. 138993.003923: : fallthrough
+ *   <idle>-0            [001] ..s. 138993.202265: : fallthrough
+ *   Socket Thread-20229 [001] ..s. 138994.004149: : fallthrough
+ *   [...]
+ *
+ * tc exec bpf graft m:globals/jmp_tc key 0 obj graft.o sec aaa
+ * tc exec bpf dbg
+ *   [...]
+ *   Socket Thread-19818 [002] ..s. 139012.053587: : aaa
+ *   <idle>-0            [002] ..s. 139012.172359: : aaa
+ *   Socket Thread-19818 [001] ..s. 139012.173556: : aaa
+ *   [...]
+ *
+ * tc exec bpf graft m:globals/jmp_tc key 0 obj graft.o sec bbb
+ * tc exec bpf dbg
+ *   [...]
+ *   Socket Thread-19818 [002] ..s. 139022.102967: : bbb
+ *   <idle>-0            [002] ..s. 139022.155640: : bbb
+ *   Socket Thread-19818 [001] ..s. 139022.156730: : bbb
+ *   [...]
+ */
+struct bpf_elf_map __section("maps") jmp_tc = {
+	.type		= BPF_MAP_TYPE_PROG_ARRAY,
+	.size_key	= sizeof(int),
+	.size_value	= sizeof(int),
+	.pinning	= PIN_GLOBAL_NS,
+	.max_elem	= 1,
+};
+
+__section("aaa") int cls_aaa(struct __sk_buff *skb)
+{
+	char fmt[] = "aaa\n";
+
+	bpf_printk(fmt, sizeof(fmt));
+	return -1;
+}
+
+__section("bbb") int cls_bbb(struct __sk_buff *skb)
+{
+	char fmt[] = "bbb\n";
+
+	bpf_printk(fmt, sizeof(fmt));
+	return -1;
+}
+
+__section("classifier") int cls_entry(struct __sk_buff *skb)
+{
+	char fmt[] = "fallthrough\n";
+
+	bpf_tail_call(skb, &jmp_tc, 0);
+	bpf_printk(fmt, sizeof(fmt));
+	return -1;
+}
+
+char __license[] __section("license") = "GPL";
diff --git a/examples/bpf/bpf_tailcall.c b/examples/bpf/bpf_tailcall.c
new file mode 100644
index 0000000..f186e57
--- /dev/null
+++ b/examples/bpf/bpf_tailcall.c
@@ -0,0 +1,115 @@
+#include <linux/bpf.h>
+
+#include "bpf_funcs.h"
+
+#define ENTRY_INIT	3
+#define ENTRY_0		0
+#define ENTRY_1		1
+#define MAX_JMP_SIZE	2
+
+#define FOO		42
+#define BAR		43
+
+/* This example doesn't really do anything useful, but it's purpose is to
+ * demonstrate eBPF tail calls on a very simple example.
+ *
+ * cls_entry() is our classifier entry point, from there we jump based on
+ * skb->hash into cls_case1() or cls_case2(). They are both part of the
+ * program array jmp_tc. Indicated via __section_tail(), the tc loader
+ * populates the program arrays with the loaded file descriptors already.
+ *
+ * To demonstrate nested jumps, cls_case2() jumps within the same jmp_tc
+ * array to cls_case1(). And whenever we arrive at cls_case1(), we jump
+ * into cls_exit(), part of the jump array jmp_ex.
+ *
+ * Also, to show it's possible, all programs share map_sh and dump the value
+ * that the entry point incremented. The sections that are loaded into a
+ * program array can be atomically replaced during run-time, e.g. to change
+ * classifier behaviour.
+ */
+struct bpf_elf_map __section("maps") map_sh = {
+	.type		= BPF_MAP_TYPE_ARRAY,
+	.size_key	= sizeof(int),
+	.size_value	= sizeof(int),
+	.pinning	= PIN_OBJECT_NS,
+	.max_elem	= 1,
+};
+
+struct bpf_elf_map __section("maps") jmp_tc = {
+	.type		= BPF_MAP_TYPE_PROG_ARRAY,
+	.id		= FOO,
+	.size_key	= sizeof(int),
+	.size_value	= sizeof(int),
+	.pinning	= PIN_OBJECT_NS,
+	.max_elem	= MAX_JMP_SIZE,
+};
+
+struct bpf_elf_map __section("maps") jmp_ex = {
+	.type		= BPF_MAP_TYPE_PROG_ARRAY,
+	.id		= BAR,
+	.size_key	= sizeof(int),
+	.size_value	= sizeof(int),
+	.pinning	= PIN_OBJECT_NS,
+	.max_elem	= 1,
+};
+
+__section_tail(FOO, ENTRY_0) int cls_case1(struct __sk_buff *skb)
+{
+	char fmt[] = "case1: map-val: %d from:%u\n";
+	int key = 0, *val;
+
+	val = bpf_map_lookup_elem(&map_sh, &key);
+	if (val)
+		bpf_printk(fmt, sizeof(fmt), *val, skb->cb[0]);
+
+	skb->cb[0] = ENTRY_0;
+	bpf_tail_call(skb, &jmp_ex, ENTRY_0);
+	return 0;
+}
+
+__section_tail(FOO, ENTRY_1) int cls_case2(struct __sk_buff *skb)
+{
+	char fmt[] = "case2: map-val: %d from:%u\n";
+	int key = 0, *val;
+
+	val = bpf_map_lookup_elem(&map_sh, &key);
+	if (val)
+		bpf_printk(fmt, sizeof(fmt), *val, skb->cb[0]);
+
+	skb->cb[0] = ENTRY_1;
+	bpf_tail_call(skb, &jmp_tc, ENTRY_0);
+	return 0;
+}
+
+__section_tail(BAR, ENTRY_0) int cls_exit(struct __sk_buff *skb)
+{
+	char fmt[] = "exit: map-val: %d from:%u\n";
+	int key = 0, *val;
+
+	val = bpf_map_lookup_elem(&map_sh, &key);
+	if (val)
+		bpf_printk(fmt, sizeof(fmt), *val, skb->cb[0]);
+
+	/* Termination point. */
+	return -1;
+}
+
+__section("classifier") int cls_entry(struct __sk_buff *skb)
+{
+	char fmt[] = "fallthrough\n";
+	int key = 0, *val;
+
+	/* For transferring state, we can use skb->cb[0] ... skb->cb[4]. */
+	val = bpf_map_lookup_elem(&map_sh, &key);
+	if (val) {
+		__sync_fetch_and_add(val, 1);
+
+		skb->cb[0] = ENTRY_INIT;
+		bpf_tail_call(skb, &jmp_tc, skb->hash & (MAX_JMP_SIZE - 1));
+	}
+
+	bpf_printk(fmt, sizeof(fmt));
+	return 0;
+}
+
+char __license[] __section("license") = "GPL";
-- 
1.9.3
