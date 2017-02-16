From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/3] bpf: make jited programs visible in traces
Date: Thu, 16 Feb 2017 22:24:50 +0100
Message-ID: <36bb0882151c63dcf7c624f52bf92db8adbfb80a.1487279499.git.daniel@iogearbox.net>
References: <cover.1487279499.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40158 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933214AbdBPVZh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 16:25:37 -0500
In-Reply-To: <cover.1487279499.git.daniel@iogearbox.net>
In-Reply-To: <cover.1487279499.git.daniel@iogearbox.net>
References: <cover.1487279499.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Long standing issue with JITed programs is that stack traces from
function tracing check whether a given address is kernel code
through {__,}kernel_text_address(), which checks for code in core
kernel, modules and dynamically allocated ftrace trampolines. But
what is still missing is BPF JITed programs (interpreted programs
are not an issue as __bpf_prog_run() will be attributed to them),
thus when a stack trace is triggered, the code walking the stack
won't see any of the JITed ones. The same for address correlation
done from user space via reading /proc/kallsyms. This is read by
tools like perf, but the latter is also useful for permanent live
tracing with eBPF itself in combination with stack maps when other
eBPF types are part of the callchain. See offwaketime example on
dumping stack from a map.

This work tries to tackle that issue by making the addresses and
symbols known to the kernel. The lookup from *kernel_text_address()
is implemented through a latched RB tree that can be read under
RCU in fast-path that is also shared for symbol/size/offset lookup
for a specific given address in kallsyms. The slow-path iteration
through all symbols in the seq file done via RCU list, which holds
a tiny fraction of all exported ksyms, usually below 0.1 percent.
Function symbols are exported as bpf_prog_<tag>, in order to aide
debugging and attribution. This facility is currently enabled for
root-only when bpf_jit_kallsyms is set to 1, and disabled if hardening
is active in any mode. The rationale behind this is that still a lot
of systems ship with world read permissions on kallsyms thus addresses
should not get suddenly exposed for them. If that situation gets
much better in future, we always have the option to change the
default on this. Likewise, unprivileged programs are not allowed
to add entries there either, but that is less of a concern as most
such programs types relevant in this context are for root-only anyway.
If enabled, call graphs and stack traces will then show a correct
attribution; one example is illustrated below, where the trace is
now visible in tooling such as perf script --kallsyms=/proc/kallsyms
and friends.

Before:

  7fff8166889d bpf_clone_redirect+0x80007f0020ed (/lib/modules/4.9.0-rc8+/build/vmlinux)
         f5d80 __sendmsg_nocancel+0xffff006451f1a007 (/usr/lib64/libc-2.18.so)

After:

  7fff816688b7 bpf_clone_redirect+0x80007f002107 (/lib/modules/4.9.0-rc8+/build/vmlinux)
  7fffa0575728 bpf_prog_33c45a467c9e061a+0x8000600020fb (/lib/modules/4.9.0-rc8+/build/vmlinux)
  7fffa07ef1fc cls_bpf_classify+0x8000600020dc (/lib/modules/4.9.0-rc8+/build/vmlinux)
  7fff81678b68 tc_classify+0x80007f002078 (/lib/modules/4.9.0-rc8+/build/vmlinux)
  7fff8164d40b __netif_receive_skb_core+0x80007f0025fb (/lib/modules/4.9.0-rc8+/build/vmlinux)
  7fff8164d718 __netif_receive_skb+0x80007f002018 (/lib/modules/4.9.0-rc8+/build/vmlinux)
  7fff8164e565 process_backlog+0x80007f002095 (/lib/modules/4.9.0-rc8+/build/vmlinux)
  7fff8164dc71 net_rx_action+0x80007f002231 (/lib/modules/4.9.0-rc8+/build/vmlinux)
  7fff81767461 __softirqentry_text_start+0x80007f0020d1 (/lib/modules/4.9.0-rc8+/build/vmlinux)
  7fff817658ac do_softirq_own_stack+0x80007f00201c (/lib/modules/4.9.0-rc8+/build/vmlinux)
  7fff810a2c20 do_softirq+0x80007f002050 (/lib/modules/4.9.0-rc8+/build/vmlinux)
  7fff810a2cb5 __local_bh_enable_ip+0x80007f002085 (/lib/modules/4.9.0-rc8+/build/vmlinux)
  7fff8168d452 ip_finish_output2+0x80007f002152 (/lib/modules/4.9.0-rc8+/build/vmlinux)
  7fff8168ea3d ip_finish_output+0x80007f00217d (/lib/modules/4.9.0-rc8+/build/vmlinux)
  7fff8168f2af ip_output+0x80007f00203f (/lib/modules/4.9.0-rc8+/build/vmlinux)
  [...]
  7fff81005854 do_syscall_64+0x80007f002054 (/lib/modules/4.9.0-rc8+/build/vmlinux)
  7fff817649eb return_from_SYSCALL_64+0x80007f002000 (/lib/modules/4.9.0-rc8+/build/vmlinux)
         f5d80 __sendmsg_nocancel+0xffff01c484812007 (/usr/lib64/libc-2.18.so)

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Cc: linux-kernel@vger.kernel.org
---
 Documentation/sysctl/net.txt      |  12 ++
 arch/arm64/net/bpf_jit_comp.c     |  15 ---
 arch/powerpc/net/bpf_jit_comp64.c |   1 +
 arch/s390/net/bpf_jit_comp.c      |  18 ---
 arch/x86/net/bpf_jit_comp.c       |  15 ---
 include/linux/bpf.h               |   4 +
 include/linux/filter.h            | 112 ++++++++++++++++++-
 kernel/bpf/core.c                 | 223 ++++++++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c              |   2 +
 kernel/extable.c                  |   9 +-
 kernel/kallsyms.c                 |  61 +++++++++--
 net/Kconfig                       |   3 +-
 net/core/sysctl_net_core.c        |   7 ++
 13 files changed, 419 insertions(+), 63 deletions(-)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
index b80fbd4..2ebabc9 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -54,6 +54,18 @@ Values :
 	1 - enable JIT hardening for unprivileged users only
 	2 - enable JIT hardening for all users
 
+bpf_jit_kallsyms
+----------------
+
+When Berkeley Packet Filter Just in Time compiler is enabled, then compiled
+images are unknown addresses to the kernel, meaning they neither show up in
+traces nor in /proc/kallsyms. This enables export of these addresses, which
+can be used for debugging/tracing. If bpf_jit_harden is enabled, this feature
+is disabled.
+Values :
+	0 - disable JIT kallsyms export (default value)
+	1 - enable JIT kallsyms export for privileged users only
+
 dev_weight
 --------------
 
diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index c444408..05d1210 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -910,18 +910,3 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 					   tmp : orig_prog);
 	return prog;
 }
-
-void bpf_jit_free(struct bpf_prog *prog)
-{
-	unsigned long addr = (unsigned long)prog->bpf_func & PAGE_MASK;
-	struct bpf_binary_header *header = (void *)addr;
-
-	if (!prog->jited)
-		goto free_filter;
-
-	set_memory_rw(addr, header->pages);
-	bpf_jit_binary_free(header);
-
-free_filter:
-	bpf_prog_unlock_free(prog);
-}
diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
index f9ebd02..c34166e 100644
--- a/arch/powerpc/net/bpf_jit_comp64.c
+++ b/arch/powerpc/net/bpf_jit_comp64.c
@@ -1064,6 +1064,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 	return fp;
 }
 
+/* Overriding bpf_jit_free() as we don't set images read-only. */
 void bpf_jit_free(struct bpf_prog *fp)
 {
 	unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 6454efd..f1d0e62 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -1339,21 +1339,3 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *fp)
 					   tmp : orig_fp);
 	return fp;
 }
-
-/*
- * Free eBPF program
- */
-void bpf_jit_free(struct bpf_prog *fp)
-{
-	unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
-	struct bpf_binary_header *header = (void *)addr;
-
-	if (!fp->jited)
-		goto free_filter;
-
-	set_memory_rw(addr, header->pages);
-	bpf_jit_binary_free(header);
-
-free_filter:
-	bpf_prog_unlock_free(fp);
-}
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 26123d0..18a62e2 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -1180,18 +1180,3 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 					   tmp : orig_prog);
 	return prog;
 }
-
-void bpf_jit_free(struct bpf_prog *fp)
-{
-	unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
-	struct bpf_binary_header *header = (void *)addr;
-
-	if (!fp->jited)
-		goto free_filter;
-
-	set_memory_rw(addr, header->pages);
-	bpf_jit_binary_free(header);
-
-free_filter:
-	bpf_prog_unlock_free(fp);
-}
diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 57d60dc..909fc03 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -8,10 +8,12 @@
 #define _LINUX_BPF_H 1
 
 #include <uapi/linux/bpf.h>
+
 #include <linux/workqueue.h>
 #include <linux/file.h>
 #include <linux/percpu.h>
 #include <linux/err.h>
+#include <linux/rbtree_latch.h>
 
 struct perf_event;
 struct bpf_map;
@@ -177,6 +179,8 @@ struct bpf_prog_aux {
 	atomic_t refcnt;
 	u32 used_map_cnt;
 	u32 max_ctx_offset;
+	struct latch_tree_node ksym_tnode;
+	struct list_head ksym_lnode;
 	const struct bpf_verifier_ops *ops;
 	struct bpf_map **used_maps;
 	struct bpf_prog *prog;
diff --git a/include/linux/filter.h b/include/linux/filter.h
index c7a70e0..0c1cc91 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -54,6 +54,12 @@
 #define BPF_REG_AX		MAX_BPF_REG
 #define MAX_BPF_JIT_REG		(MAX_BPF_REG + 1)
 
+/* As per nm, we expose JITed images as text (code) section for
+ * kallsyms. That way, tools like perf can find it to match
+ * addresses.
+ */
+#define BPF_SYM_ELF_TYPE	't'
+
 /* BPF program can access up to 512 bytes of stack space. */
 #define MAX_BPF_STACK	512
 
@@ -555,6 +561,11 @@ static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
 {
 	set_memory_rw((unsigned long)fp, fp->pages);
 }
+
+static inline void bpf_jit_binary_unlock_ro(struct bpf_binary_header *hdr)
+{
+	set_memory_rw((unsigned long)hdr, hdr->pages);
+}
 #else
 static inline void bpf_prog_lock_ro(struct bpf_prog *fp)
 {
@@ -563,8 +574,21 @@ static inline void bpf_prog_lock_ro(struct bpf_prog *fp)
 static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
 {
 }
+
+static inline void bpf_jit_binary_unlock_ro(struct bpf_binary_header *hdr)
+{
+}
 #endif /* CONFIG_DEBUG_SET_MODULE_RONX */
 
+static inline struct bpf_binary_header *
+bpf_jit_binary_hdr(const struct bpf_prog *fp)
+{
+	unsigned long real_start = (unsigned long)fp->bpf_func;
+	unsigned long addr = real_start & PAGE_MASK;
+
+	return (void *)addr;
+}
+
 int sk_filter_trim_cap(struct sock *sk, struct sk_buff *skb, unsigned int cap);
 static inline int sk_filter(struct sock *sk, struct sk_buff *skb)
 {
@@ -617,6 +641,7 @@ struct bpf_prog *bpf_patch_insn_single(struct bpf_prog *prog, u32 off,
 #ifdef CONFIG_BPF_JIT
 extern int bpf_jit_enable;
 extern int bpf_jit_harden;
+extern int bpf_jit_kallsyms;
 
 typedef void (*bpf_jit_fill_hole_t)(void *area, unsigned int size);
 
@@ -651,6 +676,11 @@ static inline bool bpf_jit_is_ebpf(void)
 # endif
 }
 
+static inline bool bpf_prog_ebpf_jited(const struct bpf_prog *fp)
+{
+	return fp->jited && bpf_jit_is_ebpf();
+}
+
 static inline bool bpf_jit_blinding_enabled(void)
 {
 	/* These are the prerequisites, should someone ever have the
@@ -668,11 +698,91 @@ static inline bool bpf_jit_blinding_enabled(void)
 
 	return true;
 }
-#else
+
+static inline bool bpf_jit_kallsyms_enabled(void)
+{
+	/* There are a couple of corner cases where kallsyms should
+	 * not be enabled f.e. on hardening.
+	 */
+	if (bpf_jit_harden)
+		return false;
+	if (!bpf_jit_kallsyms)
+		return false;
+	if (bpf_jit_kallsyms == 1)
+		return true;
+
+	return false;
+}
+
+const char *__bpf_address_lookup(unsigned long addr, unsigned long *size,
+				 unsigned long *off, char *sym);
+bool is_bpf_text_address(unsigned long addr);
+int bpf_get_kallsym(unsigned int symnum, unsigned long *value, char *type,
+		    char *sym);
+
+static inline const char *
+bpf_address_lookup(unsigned long addr, unsigned long *size,
+		   unsigned long *off, char **modname, char *sym)
+{
+	const char *ret = __bpf_address_lookup(addr, size, off, sym);
+
+	if (ret && modname)
+		*modname = NULL;
+	return ret;
+}
+
+void bpf_prog_kallsyms_add(struct bpf_prog *fp);
+void bpf_prog_kallsyms_del(struct bpf_prog *fp);
+
+#else /* CONFIG_BPF_JIT */
+
+static inline bool bpf_prog_ebpf_jited(const struct bpf_prog *fp)
+{
+	return false;
+}
+
 static inline void bpf_jit_free(struct bpf_prog *fp)
 {
 	bpf_prog_unlock_free(fp);
 }
+
+static inline bool bpf_jit_kallsyms_enabled(void)
+{
+	return false;
+}
+
+static inline const char *
+__bpf_address_lookup(unsigned long addr, unsigned long *size,
+		     unsigned long *off, char *sym)
+{
+	return NULL;
+}
+
+static inline bool is_bpf_text_address(unsigned long addr)
+{
+	return false;
+}
+
+static inline int bpf_get_kallsym(unsigned int symnum, unsigned long *value,
+				  char *type, char *sym)
+{
+	return -ERANGE;
+}
+
+static inline const char *
+bpf_address_lookup(unsigned long addr, unsigned long *size,
+		   unsigned long *off, char **modname, char *sym)
+{
+	return NULL;
+}
+
+static inline void bpf_prog_kallsyms_add(struct bpf_prog *fp)
+{
+}
+
+static inline void bpf_prog_kallsyms_del(struct bpf_prog *fp)
+{
+}
 #endif /* CONFIG_BPF_JIT */
 
 #define BPF_ANC		BIT(15)
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 2831ba1..f45827e2 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -28,6 +28,9 @@
 #include <linux/moduleloader.h>
 #include <linux/bpf.h>
 #include <linux/frame.h>
+#include <linux/rbtree_latch.h>
+#include <linux/kallsyms.h>
+#include <linux/rcupdate.h>
 
 #include <asm/unaligned.h>
 
@@ -95,6 +98,8 @@ struct bpf_prog *bpf_prog_alloc(unsigned int size, gfp_t gfp_extra_flags)
 	fp->aux = aux;
 	fp->aux->prog = fp;
 
+	INIT_LIST_HEAD_RCU(&fp->aux->ksym_lnode);
+
 	return fp;
 }
 EXPORT_SYMBOL_GPL(bpf_prog_alloc);
@@ -290,6 +295,206 @@ struct bpf_prog *bpf_patch_insn_single(struct bpf_prog *prog, u32 off,
 }
 
 #ifdef CONFIG_BPF_JIT
+static __always_inline void
+bpf_get_prog_addr_region(const struct bpf_prog *prog,
+			 unsigned long *symbol_start,
+			 unsigned long *symbol_end)
+{
+	const struct bpf_binary_header *hdr = bpf_jit_binary_hdr(prog);
+	unsigned long addr = (unsigned long)hdr;
+
+	WARN_ON_ONCE(!bpf_prog_ebpf_jited(prog));
+
+	*symbol_start = addr;
+	*symbol_end   = addr + hdr->pages * PAGE_SIZE;
+}
+
+static void bpf_get_prog_name(const struct bpf_prog *prog, char *sym)
+{
+	BUILD_BUG_ON(sizeof("bpf_prog_") +
+		     sizeof(prog->tag) * 2 + 1 > KSYM_NAME_LEN);
+
+	sym += snprintf(sym, KSYM_NAME_LEN, "bpf_prog_");
+	sym  = bin2hex(sym, prog->tag, sizeof(prog->tag));
+	*sym = 0;
+}
+
+static __always_inline unsigned long
+bpf_get_prog_addr_start(struct latch_tree_node *n)
+{
+	unsigned long symbol_start, symbol_end;
+	const struct bpf_prog_aux *aux;
+
+	aux = container_of(n, struct bpf_prog_aux, ksym_tnode);
+	bpf_get_prog_addr_region(aux->prog, &symbol_start, &symbol_end);
+
+	return symbol_start;
+}
+
+static __always_inline bool bpf_tree_less(struct latch_tree_node *a,
+					  struct latch_tree_node *b)
+{
+	return bpf_get_prog_addr_start(a) < bpf_get_prog_addr_start(b);
+}
+
+static __always_inline int bpf_tree_comp(void *key, struct latch_tree_node *n)
+{
+	unsigned long val = (unsigned long)key;
+	unsigned long symbol_start, symbol_end;
+	const struct bpf_prog_aux *aux;
+
+	aux = container_of(n, struct bpf_prog_aux, ksym_tnode);
+	bpf_get_prog_addr_region(aux->prog, &symbol_start, &symbol_end);
+
+	if (val < symbol_start)
+		return -1;
+	if (val >= symbol_end)
+		return  1;
+
+	return 0;
+}
+
+static const struct latch_tree_ops bpf_tree_ops = {
+	.less	= bpf_tree_less,
+	.comp	= bpf_tree_comp,
+};
+
+static DEFINE_SPINLOCK(bpf_lock);
+static LIST_HEAD(bpf_kallsyms);
+static struct latch_tree_root bpf_tree __cacheline_aligned;
+
+int bpf_jit_kallsyms __read_mostly;
+
+static void bpf_prog_ksym_node_add(struct bpf_prog_aux *aux)
+{
+	WARN_ON_ONCE(!list_empty(&aux->ksym_lnode));
+	list_add_tail_rcu(&aux->ksym_lnode, &bpf_kallsyms);
+	latch_tree_insert(&aux->ksym_tnode, &bpf_tree, &bpf_tree_ops);
+}
+
+static void bpf_prog_ksym_node_del(struct bpf_prog_aux *aux)
+{
+	if (list_empty(&aux->ksym_lnode))
+		return;
+
+	latch_tree_erase(&aux->ksym_tnode, &bpf_tree, &bpf_tree_ops);
+	list_del_rcu(&aux->ksym_lnode);
+}
+
+static bool bpf_prog_kallsyms_candidate(const struct bpf_prog *fp)
+{
+	return fp->jited && !bpf_prog_was_classic(fp);
+}
+
+static bool bpf_prog_kallsyms_verify_off(const struct bpf_prog *fp)
+{
+	return list_empty(&fp->aux->ksym_lnode) ||
+	       fp->aux->ksym_lnode.prev == LIST_POISON2;
+}
+
+void bpf_prog_kallsyms_add(struct bpf_prog *fp)
+{
+	unsigned long flags;
+
+	if (!bpf_prog_kallsyms_candidate(fp) ||
+	    !capable(CAP_SYS_ADMIN))
+		return;
+
+	spin_lock_irqsave(&bpf_lock, flags);
+	bpf_prog_ksym_node_add(fp->aux);
+	spin_unlock_irqrestore(&bpf_lock, flags);
+}
+
+void bpf_prog_kallsyms_del(struct bpf_prog *fp)
+{
+	unsigned long flags;
+
+	if (!bpf_prog_kallsyms_candidate(fp))
+		return;
+
+	spin_lock_irqsave(&bpf_lock, flags);
+	bpf_prog_ksym_node_del(fp->aux);
+	spin_unlock_irqrestore(&bpf_lock, flags);
+}
+
+static struct bpf_prog *bpf_prog_kallsyms_find(unsigned long addr)
+{
+	struct latch_tree_node *n;
+
+	if (!bpf_jit_kallsyms_enabled())
+		return NULL;
+
+	n = latch_tree_find((void *)addr, &bpf_tree, &bpf_tree_ops);
+	return n ?
+	       container_of(n, struct bpf_prog_aux, ksym_tnode)->prog :
+	       NULL;
+}
+
+const char *__bpf_address_lookup(unsigned long addr, unsigned long *size,
+				 unsigned long *off, char *sym)
+{
+	unsigned long symbol_start, symbol_end;
+	struct bpf_prog *prog;
+	char *ret = NULL;
+
+	rcu_read_lock();
+	prog = bpf_prog_kallsyms_find(addr);
+	if (prog) {
+		bpf_get_prog_addr_region(prog, &symbol_start, &symbol_end);
+		bpf_get_prog_name(prog, sym);
+
+		ret = sym;
+		if (size)
+			*size = symbol_end - symbol_start;
+		if (off)
+			*off  = addr - symbol_start;
+	}
+	rcu_read_unlock();
+
+	return ret;
+}
+
+bool is_bpf_text_address(unsigned long addr)
+{
+	bool ret;
+
+	rcu_read_lock();
+	ret = bpf_prog_kallsyms_find(addr) != NULL;
+	rcu_read_unlock();
+
+	return ret;
+}
+
+int bpf_get_kallsym(unsigned int symnum, unsigned long *value, char *type,
+		    char *sym)
+{
+	unsigned long symbol_start, symbol_end;
+	struct bpf_prog_aux *aux;
+	unsigned int it = 0;
+	int ret = -ERANGE;
+
+	if (!bpf_jit_kallsyms_enabled())
+		return ret;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(aux, &bpf_kallsyms, ksym_lnode) {
+		if (it++ != symnum)
+			continue;
+
+		bpf_get_prog_addr_region(aux->prog, &symbol_start, &symbol_end);
+		bpf_get_prog_name(aux->prog, sym);
+
+		*value = symbol_start;
+		*type  = BPF_SYM_ELF_TYPE;
+
+		ret = 0;
+		break;
+	}
+	rcu_read_unlock();
+
+	return ret;
+}
+
 struct bpf_binary_header *
 bpf_jit_binary_alloc(unsigned int proglen, u8 **image_ptr,
 		     unsigned int alignment,
@@ -326,6 +531,24 @@ void bpf_jit_binary_free(struct bpf_binary_header *hdr)
 	module_memfree(hdr);
 }
 
+/* This symbol is only overridden by archs that have different
+ * requirements than the usual eBPF JITs, f.e. when they only
+ * implement cBPF JIT, do not set images read-only, etc.
+ */
+void __weak bpf_jit_free(struct bpf_prog *fp)
+{
+	if (fp->jited) {
+		struct bpf_binary_header *hdr = bpf_jit_binary_hdr(fp);
+
+		bpf_jit_binary_unlock_ro(hdr);
+		bpf_jit_binary_free(hdr);
+
+		WARN_ON_ONCE(!bpf_prog_kallsyms_verify_off(fp));
+	}
+
+	bpf_prog_unlock_free(fp);
+}
+
 int bpf_jit_harden __read_mostly;
 
 static int bpf_jit_blind_insn(const struct bpf_insn *from,
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 08a4d28..f5a0e23 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -707,6 +707,7 @@ void bpf_prog_put(struct bpf_prog *prog)
 {
 	if (atomic_dec_and_test(&prog->aux->refcnt)) {
 		trace_bpf_prog_put_rcu(prog);
+		bpf_prog_kallsyms_del(prog);
 		call_rcu(&prog->aux->rcu, __bpf_prog_put_rcu);
 	}
 }
@@ -903,6 +904,7 @@ static int bpf_prog_load(union bpf_attr *attr)
 		/* failed to allocate fd */
 		goto free_used_maps;
 
+	bpf_prog_kallsyms_add(prog);
 	trace_bpf_prog_load(prog, err);
 	return err;
 
diff --git a/kernel/extable.c b/kernel/extable.c
index e3beec4..bd82117 100644
--- a/kernel/extable.c
+++ b/kernel/extable.c
@@ -20,6 +20,7 @@
 #include <linux/module.h>
 #include <linux/mutex.h>
 #include <linux/init.h>
+#include <linux/filter.h>
 
 #include <asm/sections.h>
 #include <linux/uaccess.h>
@@ -104,6 +105,8 @@ int __kernel_text_address(unsigned long addr)
 		return 1;
 	if (is_ftrace_trampoline(addr))
 		return 1;
+	if (is_bpf_text_address(addr))
+		return 1;
 	/*
 	 * There might be init symbols in saved stacktraces.
 	 * Give those symbols a chance to be printed in
@@ -123,7 +126,11 @@ int kernel_text_address(unsigned long addr)
 		return 1;
 	if (is_module_text_address(addr))
 		return 1;
-	return is_ftrace_trampoline(addr);
+	if (is_ftrace_trampoline(addr))
+		return 1;
+	if (is_bpf_text_address(addr))
+		return 1;
+	return 0;
 }
 
 /*
diff --git a/kernel/kallsyms.c b/kernel/kallsyms.c
index fafd1a3..6a3b249 100644
--- a/kernel/kallsyms.c
+++ b/kernel/kallsyms.c
@@ -23,6 +23,7 @@
 #include <linux/mm.h>
 #include <linux/ctype.h>
 #include <linux/slab.h>
+#include <linux/filter.h>
 #include <linux/compiler.h>
 
 #include <asm/sections.h>
@@ -300,10 +301,11 @@ int kallsyms_lookup_size_offset(unsigned long addr, unsigned long *symbolsize,
 				unsigned long *offset)
 {
 	char namebuf[KSYM_NAME_LEN];
+
 	if (is_ksym_addr(addr))
 		return !!get_symbol_pos(addr, symbolsize, offset);
-
-	return !!module_address_lookup(addr, symbolsize, offset, NULL, namebuf);
+	return !!module_address_lookup(addr, symbolsize, offset, NULL, namebuf) ||
+	       !!__bpf_address_lookup(addr, symbolsize, offset, namebuf);
 }
 
 /*
@@ -318,6 +320,8 @@ const char *kallsyms_lookup(unsigned long addr,
 			    unsigned long *offset,
 			    char **modname, char *namebuf)
 {
+	const char *ret;
+
 	namebuf[KSYM_NAME_LEN - 1] = 0;
 	namebuf[0] = 0;
 
@@ -333,9 +337,13 @@ const char *kallsyms_lookup(unsigned long addr,
 		return namebuf;
 	}
 
-	/* See if it's in a module. */
-	return module_address_lookup(addr, symbolsize, offset, modname,
-				     namebuf);
+	/* See if it's in a module or a BPF JITed image. */
+	ret = module_address_lookup(addr, symbolsize, offset,
+				    modname, namebuf);
+	if (!ret)
+		ret = bpf_address_lookup(addr, symbolsize,
+					 offset, modname, namebuf);
+	return ret;
 }
 
 int lookup_symbol_name(unsigned long addr, char *symname)
@@ -471,6 +479,7 @@ void __print_symbol(const char *fmt, unsigned long address)
 /* To avoid using get_symbol_offset for every symbol, we carry prefix along. */
 struct kallsym_iter {
 	loff_t pos;
+	loff_t pos_mod_end;
 	unsigned long value;
 	unsigned int nameoff; /* If iterating in core kernel symbols. */
 	char type;
@@ -481,13 +490,27 @@ struct kallsym_iter {
 
 static int get_ksymbol_mod(struct kallsym_iter *iter)
 {
-	if (module_get_kallsym(iter->pos - kallsyms_num_syms, &iter->value,
-				&iter->type, iter->name, iter->module_name,
-				&iter->exported) < 0)
+	int ret = module_get_kallsym(iter->pos - kallsyms_num_syms,
+				     &iter->value, &iter->type,
+				     iter->name, iter->module_name,
+				     &iter->exported);
+	if (ret < 0) {
+		iter->pos_mod_end = iter->pos;
 		return 0;
+	}
+
 	return 1;
 }
 
+static int get_ksymbol_bpf(struct kallsym_iter *iter)
+{
+	iter->module_name[0] = '\0';
+	iter->exported = 0;
+	return bpf_get_kallsym(iter->pos - iter->pos_mod_end,
+			       &iter->value, &iter->type,
+			       iter->name) < 0 ? 0 : 1;
+}
+
 /* Returns space to next name. */
 static unsigned long get_ksymbol_core(struct kallsym_iter *iter)
 {
@@ -508,16 +531,30 @@ static void reset_iter(struct kallsym_iter *iter, loff_t new_pos)
 	iter->name[0] = '\0';
 	iter->nameoff = get_symbol_offset(new_pos);
 	iter->pos = new_pos;
+	if (new_pos == 0)
+		iter->pos_mod_end = 0;
+}
+
+static int update_iter_mod(struct kallsym_iter *iter, loff_t pos)
+{
+	iter->pos = pos;
+
+	if (iter->pos_mod_end > 0 &&
+	    iter->pos_mod_end < iter->pos)
+		return get_ksymbol_bpf(iter);
+
+	if (!get_ksymbol_mod(iter))
+		return get_ksymbol_bpf(iter);
+
+	return 1;
 }
 
 /* Returns false if pos at or past end of file. */
 static int update_iter(struct kallsym_iter *iter, loff_t pos)
 {
 	/* Module symbols can be accessed randomly. */
-	if (pos >= kallsyms_num_syms) {
-		iter->pos = pos;
-		return get_ksymbol_mod(iter);
-	}
+	if (pos >= kallsyms_num_syms)
+		return update_iter_mod(iter, pos);
 
 	/* If we're not on the desired position, reset to new position. */
 	if (pos != iter->pos)
diff --git a/net/Kconfig b/net/Kconfig
index f19c0c3..102f781 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -297,7 +297,8 @@ config BPF_JIT
 
 	  Note, admin should enable this feature changing:
 	  /proc/sys/net/core/bpf_jit_enable
-	  /proc/sys/net/core/bpf_jit_harden (optional)
+	  /proc/sys/net/core/bpf_jit_harden   (optional)
+	  /proc/sys/net/core/bpf_jit_kallsyms (optional)
 
 config NET_FLOW_LIMIT
 	bool
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index eaa72eb..4ead336 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -334,6 +334,13 @@ static int proc_do_rss_key(struct ctl_table *table, int write,
 		.mode		= 0600,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "bpf_jit_kallsyms",
+		.data		= &bpf_jit_kallsyms,
+		.maxlen		= sizeof(int),
+		.mode		= 0600,
+		.proc_handler	= proc_dointvec,
+	},
 # endif
 #endif
 	{
-- 
1.9.3
