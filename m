From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH v3 -next 1/2] x86: bpf_jit_comp: support BPF_S_ANC_SECCOMP_LD_W
Date: Thu,  2 May 2013 18:28:56 -0400
Message-ID: <1367533737-17196-2-git-send-email-xi.wang@gmail.com>
References: <1367533737-17196-1-git-send-email-xi.wang@gmail.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Will Drewry <wad@chromium.org>,
	Eric Dumazet <edumazet@google.com>,
	Russell King <linux@arm.linux.org.uk>,
	David Laight <david.laight@aculab.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Xi Wang <xi.wang@gmail.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367533737-17196-1-git-send-email-xi.wang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements the seccomp BPF_S_ANC_SECCOMP_LD_W instruction
in x86 JIT, by simply calling seccomp_bpf_load().

SEEN_SKBREF was suggested by Eric Dumazet.  SEEN_SKBREF shouldn't be
set in seccomp filters.

Signed-off-by: Xi Wang <xi.wang@gmail.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Will Drewry <wad@chromium.org>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: David Laight <david.laight@aculab.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicolas Schichan <nschichan@freebox.fr>
---
 arch/x86/Kconfig            |   1 +
 arch/x86/net/bpf_jit_comp.c | 112 +++++++++++++++++++++++++++++++++++---------
 2 files changed, 91 insertions(+), 22 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index e8fff2f4..f7e1848 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -93,6 +93,7 @@ config X86
 	select IRQ_FORCED_THREADING
 	select USE_GENERIC_SMP_HELPERS if SMP
 	select HAVE_BPF_JIT if X86_64
+	select HAVE_SECCOMP_FILTER_JIT if X86_64
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	select CLKEVT_I8253
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 9659817..64c72aa 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -107,9 +107,13 @@ do {								\
 		goto cond_branch
 
 
-#define SEEN_DATAREF 1 /* might call external helpers */
-#define SEEN_XREG    2 /* ebx is used */
-#define SEEN_MEM     4 /* use mem[] for temporary storage */
+#define SEEN_DATAREF (1 << 0) /* might call external skb helpers */
+#define SEEN_XREG    (1 << 1) /* ebx is used */
+#define SEEN_MEM     (1 << 2) /* use mem[] for temporary storage */
+#define SEEN_SKBREF  (1 << 3) /* use pointer to skb */
+#define SEEN_SECCOMP (1 << 4) /* seccomp filters */
+
+#define NEED_PERILOGUE(_seen) ((_seen) & (SEEN_XREG | SEEN_MEM | SEEN_DATAREF | SEEN_SECCOMP))
 
 static inline void bpf_flush_icache(void *start, void *end)
 {
@@ -144,7 +148,7 @@ static int pkt_type_offset(void)
 	return -1;
 }
 
-void bpf_jit_compile(struct sk_filter *fp)
+static void *__bpf_jit_compile(struct sock_filter *filter, unsigned int flen, u8 seen_all)
 {
 	u8 temp[64];
 	u8 *prog;
@@ -157,15 +161,14 @@ void bpf_jit_compile(struct sk_filter *fp)
 	int pc_ret0 = -1; /* bpf index of first RET #0 instruction (if any) */
 	unsigned int cleanup_addr; /* epilogue code offset */
 	unsigned int *addrs;
-	const struct sock_filter *filter = fp->insns;
-	int flen = fp->len;
+	void *bpf_func = NULL;
 
 	if (!bpf_jit_enable)
-		return;
+		return bpf_func;
 
 	addrs = kmalloc(flen * sizeof(*addrs), GFP_KERNEL);
 	if (addrs == NULL)
-		return;
+		return bpf_func;
 
 	/* Before first pass, make a rough estimation of addrs[]
 	 * each bpf instruction is translated to less than 64 bytes
@@ -177,12 +180,12 @@ void bpf_jit_compile(struct sk_filter *fp)
 	cleanup_addr = proglen; /* epilogue address */
 
 	for (pass = 0; pass < 10; pass++) {
-		u8 seen_or_pass0 = (pass == 0) ? (SEEN_XREG | SEEN_DATAREF | SEEN_MEM) : seen;
+		u8 seen_or_pass0 = (pass == 0) ? seen_all : seen;
 		/* no prologue/epilogue for trivial filters (RET something) */
 		proglen = 0;
 		prog = temp;
 
-		if (seen_or_pass0) {
+		if (NEED_PERILOGUE(seen_or_pass0)) {
 			EMIT4(0x55, 0x48, 0x89, 0xe5); /* push %rbp; mov %rsp,%rbp */
 			EMIT4(0x48, 0x83, 0xec, 96);	/* subq  $96,%rsp	*/
 			/* note : must save %rbx in case bpf_error is hit */
@@ -225,6 +228,16 @@ void bpf_jit_compile(struct sk_filter *fp)
 			}
 		}
 
+#ifdef CONFIG_SECCOMP_FILTER_JIT
+		if (seen_or_pass0 & SEEN_SECCOMP) {
+			/* seccomp filters: skb must be NULL */
+			if (seen_or_pass0 & (SEEN_SKBREF | SEEN_DATAREF)) {
+				pr_err_once("seccomp filters shouldn't use skb");
+				goto out;
+			}
+		}
+#endif /* CONFIG_SECCOMP_FILTER_JIT */
+
 		switch (filter[0].code) {
 		case BPF_S_RET_K:
 		case BPF_S_LD_W_LEN:
@@ -237,6 +250,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 		case BPF_S_ANC_VLAN_TAG_PRESENT:
 		case BPF_S_ANC_QUEUE:
 		case BPF_S_ANC_PKTTYPE:
+		case BPF_S_ANC_SECCOMP_LD_W:
 		case BPF_S_LD_W_ABS:
 		case BPF_S_LD_H_ABS:
 		case BPF_S_LD_B_ABS:
@@ -408,7 +422,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 				}
 				/* fallinto */
 			case BPF_S_RET_A:
-				if (seen_or_pass0) {
+				if (NEED_PERILOGUE(seen_or_pass0)) {
 					if (i != flen - 1) {
 						EMIT_JMP(cleanup_addr - addrs[i]);
 						break;
@@ -458,6 +472,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 				break;
 			case BPF_S_LD_W_LEN: /*	A = skb->len; */
 				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);
+				seen |= SEEN_SKBREF;
 				if (is_imm8(offsetof(struct sk_buff, len)))
 					/* mov    off8(%rdi),%eax */
 					EMIT3(0x8b, 0x47, offsetof(struct sk_buff, len));
@@ -467,7 +482,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 				}
 				break;
 			case BPF_S_LDX_W_LEN: /* X = skb->len; */
-				seen |= SEEN_XREG;
+				seen |= SEEN_XREG | SEEN_SKBREF;
 				if (is_imm8(offsetof(struct sk_buff, len)))
 					/* mov off8(%rdi),%ebx */
 					EMIT3(0x8b, 0x5f, offsetof(struct sk_buff, len));
@@ -478,6 +493,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 				break;
 			case BPF_S_ANC_PROTOCOL: /* A = ntohs(skb->protocol); */
 				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, protocol) != 2);
+				seen |= SEEN_SKBREF;
 				if (is_imm8(offsetof(struct sk_buff, protocol))) {
 					/* movzwl off8(%rdi),%eax */
 					EMIT4(0x0f, 0xb7, 0x47, offsetof(struct sk_buff, protocol));
@@ -488,6 +504,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 				EMIT2(0x86, 0xc4); /* ntohs() : xchg   %al,%ah */
 				break;
 			case BPF_S_ANC_IFINDEX:
+				seen |= SEEN_SKBREF;
 				if (is_imm8(offsetof(struct sk_buff, dev))) {
 					/* movq off8(%rdi),%rax */
 					EMIT4(0x48, 0x8b, 0x47, offsetof(struct sk_buff, dev));
@@ -503,6 +520,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 				break;
 			case BPF_S_ANC_MARK:
 				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
+				seen |= SEEN_SKBREF;
 				if (is_imm8(offsetof(struct sk_buff, mark))) {
 					/* mov off8(%rdi),%eax */
 					EMIT3(0x8b, 0x47, offsetof(struct sk_buff, mark));
@@ -513,6 +531,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 				break;
 			case BPF_S_ANC_RXHASH:
 				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, rxhash) != 4);
+				seen |= SEEN_SKBREF;
 				if (is_imm8(offsetof(struct sk_buff, rxhash))) {
 					/* mov off8(%rdi),%eax */
 					EMIT3(0x8b, 0x47, offsetof(struct sk_buff, rxhash));
@@ -523,6 +542,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 				break;
 			case BPF_S_ANC_QUEUE:
 				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, queue_mapping) != 2);
+				seen |= SEEN_SKBREF;
 				if (is_imm8(offsetof(struct sk_buff, queue_mapping))) {
 					/* movzwl off8(%rdi),%eax */
 					EMIT4(0x0f, 0xb7, 0x47, offsetof(struct sk_buff, queue_mapping));
@@ -542,6 +562,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 			case BPF_S_ANC_VLAN_TAG:
 			case BPF_S_ANC_VLAN_TAG_PRESENT:
 				BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
+				seen |= SEEN_SKBREF;
 				if (is_imm8(offsetof(struct sk_buff, vlan_tci))) {
 					/* movzwl off8(%rdi),%eax */
 					EMIT4(0x0f, 0xb7, 0x47, offsetof(struct sk_buff, vlan_tci));
@@ -563,6 +584,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 
 				if (off < 0)
 					goto out;
+				seen |= SEEN_SKBREF;
 				if (is_imm8(off)) {
 					/* movzbl off8(%rdi),%eax */
 					EMIT4(0x0f, 0xb6, 0x47, off);
@@ -576,7 +598,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 			}
 			case BPF_S_LD_W_ABS:
 				func = CHOOSE_LOAD_FUNC(K, sk_load_word);
-common_load:			seen |= SEEN_DATAREF;
+common_load:			seen |= SEEN_SKBREF | SEEN_DATAREF;
 				t_offset = func - (image + addrs[i]);
 				EMIT1_off32(0xbe, K); /* mov imm32,%esi */
 				EMIT1_off32(0xe8, t_offset); /* call */
@@ -589,14 +611,14 @@ common_load:			seen |= SEEN_DATAREF;
 				goto common_load;
 			case BPF_S_LDX_B_MSH:
 				func = CHOOSE_LOAD_FUNC(K, sk_load_byte_msh);
-				seen |= SEEN_DATAREF | SEEN_XREG;
+				seen |= SEEN_XREG | SEEN_SKBREF | SEEN_DATAREF;
 				t_offset = func - (image + addrs[i]);
 				EMIT1_off32(0xbe, K);	/* mov imm32,%esi */
 				EMIT1_off32(0xe8, t_offset); /* call sk_load_byte_msh */
 				break;
 			case BPF_S_LD_W_IND:
 				func = sk_load_word;
-common_load_ind:		seen |= SEEN_DATAREF | SEEN_XREG;
+common_load_ind:		seen |= SEEN_XREG | SEEN_SKBREF | SEEN_DATAREF;
 				t_offset = func - (image + addrs[i]);
 				if (K) {
 					if (is_imm8(K)) {
@@ -684,6 +706,18 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 				}
 				EMIT_COND_JMP(f_op, f_offset);
 				break;
+#ifdef CONFIG_SECCOMP_FILTER_JIT
+			case BPF_S_ANC_SECCOMP_LD_W:
+				seen |= SEEN_SECCOMP;
+				func = (u8 *)seccomp_bpf_load;
+				t_offset = func - (image + addrs[i]);
+				/* seccomp filters don't use %rdi, %r8, %r9
+				 * it is safe to not save them
+				 */
+				EMIT1_off32(0xbf, K); /* mov imm32,%edi */
+				EMIT1_off32(0xe8, t_offset); /* call seccomp_bpf_load */
+				break;
+#endif /* CONFIG_SECCOMP_FILTER_JIT */
 			default:
 				/* hmm, too complex filter, give up with jit compiler */
 				goto out;
@@ -694,7 +728,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 					pr_err("bpb_jit_compile fatal error\n");
 					kfree(addrs);
 					module_free(NULL, image);
-					return;
+					return bpf_func;
 				}
 				memcpy(image + proglen, temp, ilen);
 			}
@@ -706,7 +740,7 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 		 * use it to give the cleanup instruction(s) addr
 		 */
 		cleanup_addr = proglen - 1; /* ret */
-		if (seen_or_pass0)
+		if (NEED_PERILOGUE(seen_or_pass0))
 			cleanup_addr -= 1; /* leaveq */
 		if (seen_or_pass0 & SEEN_XREG)
 			cleanup_addr -= 4; /* mov  -8(%rbp),%rbx */
@@ -731,11 +765,11 @@ cond_branch:			f_offset = addrs[i + filter[i].jf] - addrs[i];
 
 	if (image) {
 		bpf_flush_icache(image, image + proglen);
-		fp->bpf_func = (void *)image;
+		bpf_func = image;
 	}
 out:
 	kfree(addrs);
-	return;
+	return bpf_func;
 }
 
 static void jit_free_defer(struct work_struct *arg)
@@ -746,16 +780,50 @@ static void jit_free_defer(struct work_struct *arg)
 /* run from softirq, we must use a work_struct to call
  * module_free() from process context
  */
-void bpf_jit_free(struct sk_filter *fp)
+static void __bpf_jit_free(void *bpf_func)
 {
-	if (fp->bpf_func != sk_run_filter) {
+	if (bpf_func != sk_run_filter) {
 		/*
 		 * bpf_jit_free() can be called from softirq; module_free()
 		 * requires process context.
 		 */
-		struct work_struct *work = (struct work_struct *)fp->bpf_func;
+		struct work_struct *work = (struct work_struct *)bpf_func;
 
 		INIT_WORK(work, jit_free_defer);
 		schedule_work(work);
 	}
 }
+
+void bpf_jit_compile(struct sk_filter *fp)
+{
+	u8 seen_all = SEEN_XREG | SEEN_MEM | SEEN_SKBREF | SEEN_DATAREF;
+	void *bpf_func = __bpf_jit_compile(fp->insns, fp->len, seen_all);
+
+	if (bpf_func)
+		fp->bpf_func = bpf_func;
+}
+
+void bpf_jit_free(struct sk_filter *fp)
+{
+	__bpf_jit_free(fp->bpf_func);
+}
+
+#ifdef CONFIG_SECCOMP_FILTER_JIT
+void seccomp_jit_compile(struct seccomp_filter *fp)
+{
+	struct sock_filter *filter = seccomp_filter_get_insns(fp);
+	unsigned int flen = seccomp_filter_get_len(fp);
+	u8 seen_all = SEEN_XREG | SEEN_MEM | SEEN_SECCOMP;
+	void *bpf_func = __bpf_jit_compile(filter, flen, seen_all);
+
+	if (bpf_func)
+		seccomp_filter_set_bpf_func(fp, bpf_func);
+}
+
+void seccomp_jit_free(struct seccomp_filter *fp)
+{
+	void *bpf_func = seccomp_filter_get_bpf_func(fp);
+
+	__bpf_jit_free(bpf_func);
+}
+#endif /* CONFIG_SECCOMP_FILTER_JIT */
-- 
1.8.1.2
