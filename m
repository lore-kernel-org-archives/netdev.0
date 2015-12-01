From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next] examples, bpf: further improve examples
Date: Wed,  2 Dec 2015 00:25:36 +0100
Message-ID: <d47c2d0a35e6ea07b7c83c8ca5bebb2464b9805c.1449011912.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52503 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755689AbbLAXZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 18:25:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improve example files further and add a more generic set of possible
helpers for them that can be used.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 examples/bpf/bpf_cyclic.c   |  38 ++++----
 examples/bpf/bpf_funcs.h    |  76 ---------------
 examples/bpf/bpf_graft.c    |  39 ++++----
 examples/bpf/bpf_prog.c     |  33 ++++---
 examples/bpf/bpf_shared.c   |  32 +++----
 examples/bpf/bpf_shared.h   |   2 +-
 examples/bpf/bpf_tailcall.c |  84 +++++++----------
 include/bpf_api.h           | 225 ++++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 327 insertions(+), 202 deletions(-)
 delete mode 100644 examples/bpf/bpf_funcs.h
 create mode 100644 include/bpf_api.h

diff --git a/examples/bpf/bpf_cyclic.c b/examples/bpf/bpf_cyclic.c
index bde061c..c66cbec 100644
--- a/examples/bpf/bpf_cyclic.c
+++ b/examples/bpf/bpf_cyclic.c
@@ -1,32 +1,30 @@
-#include <linux/bpf.h>
-
-#include "bpf_funcs.h"
+#include "../../include/bpf_api.h"
 
 /* Cyclic dependency example to test the kernel's runtime upper
- * bound on loops.
+ * bound on loops. Also demonstrates on how to use direct-actions,
+ * loaded as: tc filter add [...] bpf da obj [...]
  */
-struct bpf_elf_map __section("maps") jmp_tc = {
-	.type		= BPF_MAP_TYPE_PROG_ARRAY,
-	.id		= 0xabccba,
-	.size_key	= sizeof(int),
-	.size_value	= sizeof(int),
-	.pinning	= PIN_OBJECT_NS,
-	.max_elem	= 1,
-};
+#define JMP_MAP_ID	0xabccba
+
+BPF_PROG_ARRAY(jmp_tc, JMP_MAP_ID, PIN_OBJECT_NS, 1);
 
-__section_tail(0xabccba, 0) int cls_loop(struct __sk_buff *skb)
+__section_tail(JMP_MAP_ID, 0)
+int cls_loop(struct __sk_buff *skb)
 {
 	char fmt[] = "cb: %u\n";
 
-	bpf_printk(fmt, sizeof(fmt), skb->cb[0]++);
-	bpf_tail_call(skb, &jmp_tc, 0);
-	return -1;
+	trace_printk(fmt, sizeof(fmt), skb->cb[0]++);
+	tail_call(skb, &jmp_tc, 0);
+
+	skb->tc_classid = TC_H_MAKE(1, 42);
+	return TC_ACT_OK;
 }
 
-__section("classifier") int cls_entry(struct __sk_buff *skb)
+__section_cls_entry
+int cls_entry(struct __sk_buff *skb)
 {
-	bpf_tail_call(skb, &jmp_tc, 0);
-	return -1;
+	tail_call(skb, &jmp_tc, 0);
+	return TC_ACT_SHOT;
 }
 
-char __license[] __section("license") = "GPL";
+BPF_LICENSE("GPL");
diff --git a/examples/bpf/bpf_funcs.h b/examples/bpf/bpf_funcs.h
deleted file mode 100644
index 6d058f0..0000000
--- a/examples/bpf/bpf_funcs.h
+++ /dev/null
@@ -1,76 +0,0 @@
-#ifndef __BPF_FUNCS__
-#define __BPF_FUNCS__
-
-#include <stdint.h>
-
-#include "../../include/bpf_elf.h"
-
-/* Misc macros. */
-#ifndef __maybe_unused
-# define __maybe_unused		__attribute__ ((__unused__))
-#endif
-
-#ifndef __stringify
-# define __stringify(x)		#x
-#endif
-
-#ifndef __section
-# define __section(NAME)	__attribute__((section(NAME), used))
-#endif
-
-#ifndef __section_tail
-# define __section_tail(m, x)	__section(__stringify(m) "/" __stringify(x))
-#endif
-
-#ifndef offsetof
-# define offsetof		__builtin_offsetof
-#endif
-
-#ifndef htons
-# define htons(x)		__constant_htons((x))
-#endif
-
-#ifndef likely
-# define likely(x)		__builtin_expect(!!(x), 1)
-#endif
-
-#ifndef unlikely
-# define unlikely(x)		__builtin_expect(!!(x), 0)
-#endif
-
-/* The verifier will translate them to actual function calls. */
-static void *(*bpf_map_lookup_elem)(void *map, void *key) __maybe_unused =
-	(void *) BPF_FUNC_map_lookup_elem;
-
-static int (*bpf_map_update_elem)(void *map, void *key, void *value,
-				  unsigned long long flags) __maybe_unused =
-	(void *) BPF_FUNC_map_update_elem;
-
-static int (*bpf_map_delete_elem)(void *map, void *key) __maybe_unused =
-	(void *) BPF_FUNC_map_delete_elem;
-
-static unsigned int (*get_smp_processor_id)(void) __maybe_unused =
-	(void *) BPF_FUNC_get_smp_processor_id;
-
-static unsigned int (*get_prandom_u32)(void) __maybe_unused =
-	(void *) BPF_FUNC_get_prandom_u32;
-
-static int (*bpf_printk)(const char *fmt, int fmt_size, ...) __maybe_unused =
-	(void *) BPF_FUNC_trace_printk;
-
-static void (*bpf_tail_call)(void *ctx, void *map, int index) __maybe_unused =
-	(void *) BPF_FUNC_tail_call;
-
-/* LLVM built-in functions that an eBPF C program may use to emit
- * BPF_LD_ABS and BPF_LD_IND instructions.
- */
-unsigned long long load_byte(void *skb, unsigned long long off)
-	asm ("llvm.bpf.load.byte");
-
-unsigned long long load_half(void *skb, unsigned long long off)
-	asm ("llvm.bpf.load.half");
-
-unsigned long long load_word(void *skb, unsigned long long off)
-	asm ("llvm.bpf.load.word");
-
-#endif /* __BPF_FUNCS__ */
diff --git a/examples/bpf/bpf_graft.c b/examples/bpf/bpf_graft.c
index f36d25a..f48fd02 100644
--- a/examples/bpf/bpf_graft.c
+++ b/examples/bpf/bpf_graft.c
@@ -1,6 +1,4 @@
-#include <linux/bpf.h>
-
-#include "bpf_funcs.h"
+#include "../../include/bpf_api.h"
 
 /* This example demonstrates how classifier run-time behaviour
  * can be altered with tail calls. We start out with an empty
@@ -34,37 +32,36 @@
  *   Socket Thread-19818 [001] ..s. 139022.156730: : bbb
  *   [...]
  */
-struct bpf_elf_map __section("maps") jmp_tc = {
-	.type		= BPF_MAP_TYPE_PROG_ARRAY,
-	.size_key	= sizeof(int),
-	.size_value	= sizeof(int),
-	.pinning	= PIN_GLOBAL_NS,
-	.max_elem	= 1,
-};
 
-__section("aaa") int cls_aaa(struct __sk_buff *skb)
+BPF_PROG_ARRAY(jmp_tc, 0, PIN_GLOBAL_NS, 1);
+
+__section("aaa")
+int cls_aaa(struct __sk_buff *skb)
 {
 	char fmt[] = "aaa\n";
 
-	bpf_printk(fmt, sizeof(fmt));
-	return -1;
+	trace_printk(fmt, sizeof(fmt));
+	return TC_H_MAKE(1, 42);
 }
 
-__section("bbb") int cls_bbb(struct __sk_buff *skb)
+__section("bbb")
+int cls_bbb(struct __sk_buff *skb)
 {
 	char fmt[] = "bbb\n";
 
-	bpf_printk(fmt, sizeof(fmt));
-	return -1;
+	trace_printk(fmt, sizeof(fmt));
+	return TC_H_MAKE(1, 43);
 }
 
-__section("classifier") int cls_entry(struct __sk_buff *skb)
+__section_cls_entry
+int cls_entry(struct __sk_buff *skb)
 {
 	char fmt[] = "fallthrough\n";
 
-	bpf_tail_call(skb, &jmp_tc, 0);
-	bpf_printk(fmt, sizeof(fmt));
-	return -1;
+	tail_call(skb, &jmp_tc, 0);
+	trace_printk(fmt, sizeof(fmt));
+
+	return BPF_H_DEFAULT;
 }
 
-char __license[] __section("license") = "GPL";
+BPF_LICENSE("GPL");
diff --git a/examples/bpf/bpf_prog.c b/examples/bpf/bpf_prog.c
index 009febd..4728049 100644
--- a/examples/bpf/bpf_prog.c
+++ b/examples/bpf/bpf_prog.c
@@ -168,8 +168,8 @@
 
 /* Common, shared definitions with ebpf_agent.c. */
 #include "bpf_shared.h"
-/* Selection of BPF helper functions for our example. */
-#include "bpf_funcs.h"
+/* BPF helper functions for our example. */
+#include "../../include/bpf_api.h"
 
 /* Could be defined here as well, or included from the header. */
 #define TC_ACT_UNSPEC		(-1)
@@ -387,10 +387,10 @@ static inline void cls_update_proto_map(const struct __sk_buff *skb,
 	uint8_t proto = flow->ip_proto;
 	struct count_tuple *ct, _ct;
 
-	ct = bpf_map_lookup_elem(&map_proto, &proto);
+	ct = map_lookup_elem(&map_proto, &proto);
 	if (likely(ct)) {
-		__sync_fetch_and_add(&ct->packets, 1);
-		__sync_fetch_and_add(&ct->bytes, skb->len);
+		lock_xadd(&ct->packets, 1);
+		lock_xadd(&ct->bytes, skb->len);
 		return;
 	}
 
@@ -398,7 +398,7 @@ static inline void cls_update_proto_map(const struct __sk_buff *skb,
 	_ct.packets = 1;
 	_ct.bytes = skb->len;
 
-	bpf_map_update_elem(&map_proto, &proto, &_ct, BPF_ANY);
+	map_update_elem(&map_proto, &proto, &_ct, BPF_ANY);
 }
 
 static inline void cls_update_queue_map(const struct __sk_buff *skb)
@@ -409,11 +409,11 @@ static inline void cls_update_queue_map(const struct __sk_buff *skb)
 
 	mismatch = skb->queue_mapping != get_smp_processor_id();
 
-	cq = bpf_map_lookup_elem(&map_queue, &queue);
+	cq = map_lookup_elem(&map_queue, &queue);
 	if (likely(cq)) {
-		__sync_fetch_and_add(&cq->total, 1);
+		lock_xadd(&cq->total, 1);
 		if (mismatch)
-			__sync_fetch_and_add(&cq->mismatch, 1);
+			lock_xadd(&cq->mismatch, 1);
 		return;
 	}
 
@@ -421,7 +421,7 @@ static inline void cls_update_queue_map(const struct __sk_buff *skb)
 	_cq.total = 1;
 	_cq.mismatch = mismatch ? 1 : 0;
 
-	bpf_map_update_elem(&map_queue, &queue, &_cq, BPF_ANY);
+	map_update_elem(&map_queue, &queue, &_cq, BPF_ANY);
 }
 
 /* eBPF program definitions, placed in various sections, which can
@@ -439,7 +439,8 @@ static inline void cls_update_queue_map(const struct __sk_buff *skb)
  * It is however not required to have multiple programs sharing
  * a file.
  */
-__section("classifier") int cls_main(struct __sk_buff *skb)
+__section("classifier")
+int cls_main(struct __sk_buff *skb)
 {
 	struct flow_keys flow;
 
@@ -456,13 +457,14 @@ static inline void act_update_drop_map(void)
 {
 	uint32_t *count, cpu = get_smp_processor_id();
 
-	count = bpf_map_lookup_elem(&map_drops, &cpu);
+	count = map_lookup_elem(&map_drops, &cpu);
 	if (count)
 		/* Only this cpu is accessing this element. */
 		(*count)++;
 }
 
-__section("action-mark") int act_mark_main(struct __sk_buff *skb)
+__section("action-mark")
+int act_mark_main(struct __sk_buff *skb)
 {
 	/* You could also mangle skb data here with the helper function
 	 * BPF_FUNC_skb_store_bytes, etc. Or, alternatively you could
@@ -479,7 +481,8 @@ __section("action-mark") int act_mark_main(struct __sk_buff *skb)
 	return TC_ACT_UNSPEC;
 }
 
-__section("action-rand") int act_rand_main(struct __sk_buff *skb)
+__section("action-rand")
+int act_rand_main(struct __sk_buff *skb)
 {
 	/* Sorry, we're near event horizon ... */
 	if ((get_prandom_u32() & 3) == 0) {
@@ -493,4 +496,4 @@ __section("action-rand") int act_rand_main(struct __sk_buff *skb)
 /* Last but not least, the file contains a license. Some future helper
  * functions may only be available with a GPL license.
  */
-char __license[] __section("license") = "GPL";
+BPF_LICENSE("GPL");
diff --git a/examples/bpf/bpf_shared.c b/examples/bpf/bpf_shared.c
index a8dc39c..accc0ad 100644
--- a/examples/bpf/bpf_shared.c
+++ b/examples/bpf/bpf_shared.c
@@ -1,6 +1,4 @@
-#include <linux/bpf.h>
-
-#include "bpf_funcs.h"
+#include "../../include/bpf_api.h"
 
 /* Minimal, stand-alone toy map pinning example:
  *
@@ -20,35 +18,31 @@
  * instance is being created.
  */
 
-struct bpf_elf_map __section("maps") map_sh = {
-	.type		= BPF_MAP_TYPE_ARRAY,
-	.size_key	= sizeof(int),
-	.size_value	= sizeof(int),
-	.pinning	= PIN_OBJECT_NS, /* or PIN_GLOBAL_NS, or PIN_NONE */
-	.max_elem	= 1,
-};
+BPF_ARRAY4(map_sh, 0, PIN_OBJECT_NS, 1); /* or PIN_GLOBAL_NS, or PIN_NONE */
 
-__section("egress") int emain(struct __sk_buff *skb)
+__section("egress")
+int emain(struct __sk_buff *skb)
 {
 	int key = 0, *val;
 
-	val = bpf_map_lookup_elem(&map_sh, &key);
+	val = map_lookup_elem(&map_sh, &key);
 	if (val)
-		__sync_fetch_and_add(val, 1);
+		lock_xadd(val, 1);
 
-	return -1;
+	return BPF_H_DEFAULT;
 }
 
-__section("ingress") int imain(struct __sk_buff *skb)
+__section("ingress")
+int imain(struct __sk_buff *skb)
 {
 	char fmt[] = "map val: %d\n";
 	int key = 0, *val;
 
-	val = bpf_map_lookup_elem(&map_sh, &key);
+	val = map_lookup_elem(&map_sh, &key);
 	if (val)
-		bpf_printk(fmt, sizeof(fmt), *val);
+		trace_printk(fmt, sizeof(fmt), *val);
 
-	return -1;
+	return BPF_H_DEFAULT;
 }
 
-char __license[] __section("license") = "GPL";
+BPF_LICENSE("GPL");
diff --git a/examples/bpf/bpf_shared.h b/examples/bpf/bpf_shared.h
index ea8f014..a24038d 100644
--- a/examples/bpf/bpf_shared.h
+++ b/examples/bpf/bpf_shared.h
@@ -10,7 +10,7 @@ enum {
 };
 
 struct count_tuple {
-	long packets; /* type long for __sync_fetch_and_add() */
+	long packets; /* type long for lock_xadd() */
 	long bytes;
 };
 
diff --git a/examples/bpf/bpf_tailcall.c b/examples/bpf/bpf_tailcall.c
index f186e57..040790d 100644
--- a/examples/bpf/bpf_tailcall.c
+++ b/examples/bpf/bpf_tailcall.c
@@ -1,6 +1,4 @@
-#include <linux/bpf.h>
-
-#include "bpf_funcs.h"
+#include "../../include/bpf_api.h"
 
 #define ENTRY_INIT	3
 #define ENTRY_0		0
@@ -27,89 +25,75 @@
  * program array can be atomically replaced during run-time, e.g. to change
  * classifier behaviour.
  */
-struct bpf_elf_map __section("maps") map_sh = {
-	.type		= BPF_MAP_TYPE_ARRAY,
-	.size_key	= sizeof(int),
-	.size_value	= sizeof(int),
-	.pinning	= PIN_OBJECT_NS,
-	.max_elem	= 1,
-};
-
-struct bpf_elf_map __section("maps") jmp_tc = {
-	.type		= BPF_MAP_TYPE_PROG_ARRAY,
-	.id		= FOO,
-	.size_key	= sizeof(int),
-	.size_value	= sizeof(int),
-	.pinning	= PIN_OBJECT_NS,
-	.max_elem	= MAX_JMP_SIZE,
-};
-
-struct bpf_elf_map __section("maps") jmp_ex = {
-	.type		= BPF_MAP_TYPE_PROG_ARRAY,
-	.id		= BAR,
-	.size_key	= sizeof(int),
-	.size_value	= sizeof(int),
-	.pinning	= PIN_OBJECT_NS,
-	.max_elem	= 1,
-};
-
-__section_tail(FOO, ENTRY_0) int cls_case1(struct __sk_buff *skb)
+
+BPF_PROG_ARRAY(jmp_tc, FOO, PIN_OBJECT_NS, MAX_JMP_SIZE);
+BPF_PROG_ARRAY(jmp_ex, BAR, PIN_OBJECT_NS, 1);
+
+BPF_ARRAY4(map_sh, 0, PIN_OBJECT_NS, 1);
+
+__section_tail(FOO, ENTRY_0)
+int cls_case1(struct __sk_buff *skb)
 {
 	char fmt[] = "case1: map-val: %d from:%u\n";
 	int key = 0, *val;
 
-	val = bpf_map_lookup_elem(&map_sh, &key);
+	val = map_lookup_elem(&map_sh, &key);
 	if (val)
-		bpf_printk(fmt, sizeof(fmt), *val, skb->cb[0]);
+		trace_printk(fmt, sizeof(fmt), *val, skb->cb[0]);
 
 	skb->cb[0] = ENTRY_0;
-	bpf_tail_call(skb, &jmp_ex, ENTRY_0);
-	return 0;
+	tail_call(skb, &jmp_ex, ENTRY_0);
+
+	return BPF_H_DEFAULT;
 }
 
-__section_tail(FOO, ENTRY_1) int cls_case2(struct __sk_buff *skb)
+__section_tail(FOO, ENTRY_1)
+int cls_case2(struct __sk_buff *skb)
 {
 	char fmt[] = "case2: map-val: %d from:%u\n";
 	int key = 0, *val;
 
-	val = bpf_map_lookup_elem(&map_sh, &key);
+	val = map_lookup_elem(&map_sh, &key);
 	if (val)
-		bpf_printk(fmt, sizeof(fmt), *val, skb->cb[0]);
+		trace_printk(fmt, sizeof(fmt), *val, skb->cb[0]);
 
 	skb->cb[0] = ENTRY_1;
-	bpf_tail_call(skb, &jmp_tc, ENTRY_0);
-	return 0;
+	tail_call(skb, &jmp_tc, ENTRY_0);
+
+	return BPF_H_DEFAULT;
 }
 
-__section_tail(BAR, ENTRY_0) int cls_exit(struct __sk_buff *skb)
+__section_tail(BAR, ENTRY_0)
+int cls_exit(struct __sk_buff *skb)
 {
 	char fmt[] = "exit: map-val: %d from:%u\n";
 	int key = 0, *val;
 
-	val = bpf_map_lookup_elem(&map_sh, &key);
+	val = map_lookup_elem(&map_sh, &key);
 	if (val)
-		bpf_printk(fmt, sizeof(fmt), *val, skb->cb[0]);
+		trace_printk(fmt, sizeof(fmt), *val, skb->cb[0]);
 
 	/* Termination point. */
-	return -1;
+	return BPF_H_DEFAULT;
 }
 
-__section("classifier") int cls_entry(struct __sk_buff *skb)
+__section_cls_entry
+int cls_entry(struct __sk_buff *skb)
 {
 	char fmt[] = "fallthrough\n";
 	int key = 0, *val;
 
 	/* For transferring state, we can use skb->cb[0] ... skb->cb[4]. */
-	val = bpf_map_lookup_elem(&map_sh, &key);
+	val = map_lookup_elem(&map_sh, &key);
 	if (val) {
-		__sync_fetch_and_add(val, 1);
+		lock_xadd(val, 1);
 
 		skb->cb[0] = ENTRY_INIT;
-		bpf_tail_call(skb, &jmp_tc, skb->hash & (MAX_JMP_SIZE - 1));
+		tail_call(skb, &jmp_tc, skb->hash & (MAX_JMP_SIZE - 1));
 	}
 
-	bpf_printk(fmt, sizeof(fmt));
-	return 0;
+	trace_printk(fmt, sizeof(fmt));
+	return BPF_H_DEFAULT;
 }
 
-char __license[] __section("license") = "GPL";
+BPF_LICENSE("GPL");
diff --git a/include/bpf_api.h b/include/bpf_api.h
new file mode 100644
index 0000000..8503b9a
--- /dev/null
+++ b/include/bpf_api.h
@@ -0,0 +1,225 @@
+#ifndef __BPF_API__
+#define __BPF_API__
+
+/* Note:
+ *
+ * This file can be included into eBPF kernel programs. It contains
+ * a couple of useful helper functions, map/section ABI (bpf_elf.h),
+ * misc macros and some eBPF specific LLVM built-ins.
+ */
+
+#include <stdint.h>
+
+#include <linux/pkt_cls.h>
+#include <linux/bpf.h>
+#include <linux/filter.h>
+
+#include <asm/byteorder.h>
+
+#include "bpf_elf.h"
+
+/** Misc macros. */
+
+#ifndef __stringify
+# define __stringify(X)		#X
+#endif
+
+#ifndef __maybe_unused
+# define __maybe_unused		__attribute__((__unused__))
+#endif
+
+#ifndef offsetof
+# define offsetof(TYPE, MEMBER)	__builtin_offsetof(TYPE, MEMBER)
+#endif
+
+#ifndef likely
+# define likely(X)		__builtin_expect(!!(X), 1)
+#endif
+
+#ifndef unlikely
+# define unlikely(X)		__builtin_expect(!!(X), 0)
+#endif
+
+#ifndef htons
+# define htons(X)		__constant_htons((X))
+#endif
+
+#ifndef ntohs
+# define ntohs(X)		__constant_ntohs((X))
+#endif
+
+#ifndef htonl
+# define htonl(X)		__constant_htonl((X))
+#endif
+
+#ifndef ntohl
+# define ntohl(X)		__constant_ntohl((X)
+#endif
+
+/** Section helper macros. */
+
+#ifndef __section
+# define __section(NAME)						\
+	__attribute__((section(NAME), used))
+#endif
+
+#ifndef __section_tail
+# define __section_tail(ID, KEY)					\
+	__section(__stringify(ID) "/" __stringify(KEY))
+#endif
+
+#ifndef __section_cls_entry
+# define __section_cls_entry						\
+	__section(ELF_SECTION_CLASSIFIER)
+#endif
+
+#ifndef __section_act_entry
+# define __section_act_entry						\
+	__section(ELF_SECTION_ACTION)
+#endif
+
+#ifndef __section_license
+# define __section_license						\
+	__section(ELF_SECTION_LICENSE)
+#endif
+
+#ifndef __section_maps
+# define __section_maps							\
+	__section(ELF_SECTION_MAPS)
+#endif
+
+/** Declaration helper macros. */
+
+#ifndef BPF_LICENSE
+# define BPF_LICENSE(NAME)						\
+	char ____license[] __section_license = NAME
+#endif
+
+#ifndef __BPF_MAP
+# define __BPF_MAP(NAME, TYPE, ID, SIZE_KEY, SIZE_VALUE, PIN, MAX_ELEM)	\
+	struct bpf_elf_map __section_maps NAME = {			\
+		.type		= (TYPE),				\
+		.id		= (ID),					\
+		.size_key	= (SIZE_KEY),				\
+		.size_value	= (SIZE_VALUE),				\
+		.pinning	= (PIN),				\
+		.max_elem	= (MAX_ELEM),				\
+	}
+#endif
+
+#ifndef BPF_HASH
+# define BPF_HASH(NAME, ID, SIZE_KEY, SIZE_VALUE, PIN, MAX_ELEM)	\
+	__BPF_MAP(NAME, BPF_MAP_TYPE_HASH, ID, SIZE_KEY, SIZE_VALUE,	\
+		  PIN, MAX_ELEM)
+#endif
+
+#ifndef BPF_ARRAY
+# define BPF_ARRAY(NAME, ID, SIZE_VALUE, PIN, MAX_ELEM)			\
+	__BPF_MAP(NAME, BPF_MAP_TYPE_ARRAY, ID, sizeof(uint32_t), 	\
+		  SIZE_VALUE, PIN, MAX_ELEM)
+#endif
+
+#ifndef BPF_ARRAY2
+# define BPF_ARRAY2(NAME, ID, PIN, MAX_ELEM)				\
+	BPF_ARRAY(NAME, ID, sizeof(uint16_t), PIN, MAX_ELEM)
+#endif
+
+#ifndef BPF_ARRAY4
+# define BPF_ARRAY4(NAME, ID, PIN, MAX_ELEM)				\
+	BPF_ARRAY(NAME, ID, sizeof(uint32_t), PIN, MAX_ELEM)
+#endif
+
+#ifndef BPF_ARRAY8
+# define BPF_ARRAY8(NAME, ID, PIN, MAX_ELEM)				\
+	BPF_ARRAY(NAME, ID, sizeof(uint64_t), PIN, MAX_ELEM)
+#endif
+
+#ifndef BPF_PROG_ARRAY
+# define BPF_PROG_ARRAY(NAME, ID, PIN, MAX_ELEM)			\
+	__BPF_MAP(NAME, BPF_MAP_TYPE_PROG_ARRAY, ID, sizeof(uint32_t),	\
+		  sizeof(uint32_t), PIN, MAX_ELEM)
+#endif
+
+/** Classifier helper */
+
+#ifndef BPF_H_DEFAULT
+# define BPF_H_DEFAULT	-1
+#endif
+
+/** BPF helper functions for tc. */
+
+#ifndef BPF_FUNC
+# define BPF_FUNC(NAME, ...)						\
+	(* NAME)(__VA_ARGS__) __maybe_unused = (void *) BPF_FUNC_##NAME
+#endif
+
+/* Map access/manipulation */
+static void *BPF_FUNC(map_lookup_elem, void *map, const void *key);
+static int BPF_FUNC(map_update_elem, void *map, const void *key,
+		    const void *value, uint32_t flags);
+static int BPF_FUNC(map_delete_elem, void *map, const void *key);
+
+/* Time access */
+static uint64_t BPF_FUNC(ktime_get_ns);
+
+/* Debugging */
+static void BPF_FUNC(trace_printk, const char *fmt, int fmt_size, ...);
+
+/* Random numbers */
+static uint32_t BPF_FUNC(get_prandom_u32);
+
+/* Tail calls */
+static void BPF_FUNC(tail_call, struct __sk_buff *skb, void *map,
+		     uint32_t index);
+
+/* System helpers */
+static uint32_t BPF_FUNC(get_smp_processor_id);
+
+/* Packet misc meta data */
+static uint32_t BPF_FUNC(get_cgroup_classid, struct __sk_buff *skb);
+static uint32_t BPF_FUNC(get_route_realm, struct __sk_buff *skb);
+
+/* Packet redirection */
+static int BPF_FUNC(redirect, int ifindex, uint32_t flags);
+static int BPF_FUNC(clone_redirect, struct __sk_buff *skb, int ifindex,
+		    uint32_t flags);
+
+/* Packet manipulation */
+#define BPF_PSEUDO_HDR			0x10
+#define BPF_HAS_PSEUDO_HDR(flags)	((flags) & BPF_PSEUDO_HDR)
+#define BPF_HDR_FIELD_SIZE(flags)	((flags) & 0x0f)
+
+static int BPF_FUNC(skb_store_bytes, struct __sk_buff *skb, uint32_t off,
+		    void *from, uint32_t len, uint32_t flags);
+static int BPF_FUNC(l3_csum_replace, struct __sk_buff *skb, uint32_t off,
+		    uint32_t from, uint32_t to, uint32_t flags);
+static int BPF_FUNC(l4_csum_replace, struct __sk_buff *skb, uint32_t off,
+		    uint32_t from, uint32_t to, uint32_t flags);
+
+/* Packet vlan encap/decap */
+static int BPF_FUNC(skb_vlan_push, struct __sk_buff *skb, uint16_t proto,
+		    uint16_t vlan_tci);
+static int BPF_FUNC(skb_vlan_pop, struct __sk_buff *skb);
+
+/* Packet tunnel encap/decap */
+static int BPF_FUNC(skb_get_tunnel_key, struct __sk_buff *skb,
+		    struct bpf_tunnel_key *to, uint32_t size, uint32_t flags);
+static int BPF_FUNC(skb_set_tunnel_key, struct __sk_buff *skb,
+		    struct bpf_tunnel_key *from, uint32_t size, uint32_t flags);
+
+/** LLVM built-ins */
+
+#ifndef lock_xadd
+# define lock_xadd(ptr, val)	((void) __sync_fetch_and_add(ptr, val))
+#endif
+
+unsigned long long load_byte(void *skb, unsigned long long off)
+	asm ("llvm.bpf.load.byte");
+
+unsigned long long load_half(void *skb, unsigned long long off)
+	asm ("llvm.bpf.load.half");
+
+unsigned long long load_word(void *skb, unsigned long long off)
+	asm ("llvm.bpf.load.word");
+
+#endif /* __BPF_API__ */
-- 
1.9.3
