From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next] net: filter: rename 'struct sk_filter' to 'struct bpf_prog'
Date: Fri, 25 Jul 2014 12:11:09 -0700
Message-ID: <1406315469-20010-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

'sk_filter' name is used as 'struct sk_filter', function sk_filter() and
as variable 'sk_filter', which makes code hard to read.
Also it's easily confused with 'struct sock_filter'
Rename 'struct sk_filter' to 'struct bpf_prog' to clarify semantics and
align the name with generic BPF use model.

The only ugly place is uapi/linux/netfilter/xt_bpf.h which
managed to expose kernel internal structure into uapi header.
So replace 'struct sk_filter *' there with 'void *' and type cast it
to 'struct bpf_prog *' inside kernel in net/netfilter/xt_bpf.c

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
v1->v2:
replace 'struct sk_filter *' with 'void *' in uapi/../xt_bpf.h
(seems Daniel and Willem prefere this option)

 Documentation/networking/filter.txt      |    2 +-
 arch/arm/net/bpf_jit_32.c                |    8 +++---
 arch/mips/net/bpf_jit.c                  |    8 +++---
 arch/powerpc/net/bpf_jit_comp.c          |    8 +++---
 arch/s390/net/bpf_jit_comp.c             |    4 +--
 arch/sparc/net/bpf_jit_comp.c            |    4 +--
 arch/x86/net/bpf_jit_comp.c              |   10 +++----
 drivers/net/ppp/ppp_generic.c            |    4 +--
 drivers/net/team/team_mode_loadbalance.c |    8 +++---
 include/linux/filter.h                   |   28 +++++++++----------
 include/linux/isdn_ppp.h                 |    4 +--
 include/net/sock.h                       |    2 +-
 include/uapi/linux/netfilter/xt_bpf.h    |    2 +-
 kernel/bpf/core.c                        |    6 ++---
 kernel/seccomp.c                         |    2 +-
 lib/test_bpf.c                           |   12 ++++-----
 net/core/filter.c                        |   43 +++++++++++++++---------------
 net/core/ptp_classifier.c                |    2 +-
 net/core/sock.c                          |    4 +--
 net/core/sock_diag.c                     |    2 +-
 net/netfilter/xt_bpf.c                   |    7 ++---
 net/packet/af_packet.c                   |    2 +-
 net/sched/cls_bpf.c                      |    4 +--
 23 files changed, 88 insertions(+), 88 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index ee78eba78a9d..138b645d5682 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -589,7 +589,7 @@ in the eBPF interpreter. For in-kernel handlers, this all works transparently
 by using sk_unattached_filter_create() for setting up the filter, resp.
 sk_unattached_filter_destroy() for destroying it. The macro
 SK_RUN_FILTER(filter, ctx) transparently invokes eBPF interpreter or JITed
-code to run the filter. 'filter' is a pointer to struct sk_filter that we
+code to run the filter. 'filter' is a pointer to struct bpf_prog that we
 got from sk_unattached_filter_create(), and 'ctx' the given context (e.g.
 skb pointer). All constraints and restrictions from sk_chk_filter() apply
 before a conversion to the new layout is being done behind the scenes!
diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index fb5503ce016f..a37b989a2f91 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -56,7 +56,7 @@
 #define FLAG_NEED_X_RESET	(1 << 0)
 
 struct jit_ctx {
-	const struct sk_filter *skf;
+	const struct bpf_prog *skf;
 	unsigned idx;
 	unsigned prologue_bytes;
 	int ret0_fp_idx;
@@ -465,7 +465,7 @@ static inline void update_on_xread(struct jit_ctx *ctx)
 static int build_body(struct jit_ctx *ctx)
 {
 	void *load_func[] = {jit_get_skb_b, jit_get_skb_h, jit_get_skb_w};
-	const struct sk_filter *prog = ctx->skf;
+	const struct bpf_prog *prog = ctx->skf;
 	const struct sock_filter *inst;
 	unsigned i, load_order, off, condt;
 	int imm12;
@@ -857,7 +857,7 @@ b_epilogue:
 }
 
 
-void bpf_jit_compile(struct sk_filter *fp)
+void bpf_jit_compile(struct bpf_prog *fp)
 {
 	struct jit_ctx ctx;
 	unsigned tmp_idx;
@@ -926,7 +926,7 @@ out:
 	return;
 }
 
-void bpf_jit_free(struct sk_filter *fp)
+void bpf_jit_free(struct bpf_prog *fp)
 {
 	if (fp->jited)
 		module_free(NULL, fp->bpf_func);
diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index b87390a56a2f..05a56619ece2 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -131,7 +131,7 @@
  * @target:		Memory location for the compiled filter
  */
 struct jit_ctx {
-	const struct sk_filter *skf;
+	const struct bpf_prog *skf;
 	unsigned int prologue_bytes;
 	u32 idx;
 	u32 flags;
@@ -789,7 +789,7 @@ static int pkt_type_offset(void)
 static int build_body(struct jit_ctx *ctx)
 {
 	void *load_func[] = {jit_get_skb_b, jit_get_skb_h, jit_get_skb_w};
-	const struct sk_filter *prog = ctx->skf;
+	const struct bpf_prog *prog = ctx->skf;
 	const struct sock_filter *inst;
 	unsigned int i, off, load_order, condt;
 	u32 k, b_off __maybe_unused;
@@ -1369,7 +1369,7 @@ jmp_cmp:
 
 int bpf_jit_enable __read_mostly;
 
-void bpf_jit_compile(struct sk_filter *fp)
+void bpf_jit_compile(struct bpf_prog *fp)
 {
 	struct jit_ctx ctx;
 	unsigned int alloc_size, tmp_idx;
@@ -1423,7 +1423,7 @@ out:
 	kfree(ctx.offsets);
 }
 
-void bpf_jit_free(struct sk_filter *fp)
+void bpf_jit_free(struct bpf_prog *fp)
 {
 	if (fp->jited)
 		module_free(NULL, fp->bpf_func);
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 82e82cadcde5..3afa6f4c1957 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -25,7 +25,7 @@ static inline void bpf_flush_icache(void *start, void *end)
 	flush_icache_range((unsigned long)start, (unsigned long)end);
 }
 
-static void bpf_jit_build_prologue(struct sk_filter *fp, u32 *image,
+static void bpf_jit_build_prologue(struct bpf_prog *fp, u32 *image,
 				   struct codegen_context *ctx)
 {
 	int i;
@@ -121,7 +121,7 @@ static void bpf_jit_build_epilogue(u32 *image, struct codegen_context *ctx)
 	((int)K < 0 ? ((int)K >= SKF_LL_OFF ? func##_negative_offset : func) : func##_positive_offset)
 
 /* Assemble the body code between the prologue & epilogue. */
-static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
+static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 			      struct codegen_context *ctx,
 			      unsigned int *addrs)
 {
@@ -569,7 +569,7 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 	return 0;
 }
 
-void bpf_jit_compile(struct sk_filter *fp)
+void bpf_jit_compile(struct bpf_prog *fp)
 {
 	unsigned int proglen;
 	unsigned int alloclen;
@@ -693,7 +693,7 @@ out:
 	return;
 }
 
-void bpf_jit_free(struct sk_filter *fp)
+void bpf_jit_free(struct bpf_prog *fp)
 {
 	if (fp->jited)
 		module_free(NULL, fp->bpf_func);
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index a2cbd875543a..61e45b7c04d7 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -812,7 +812,7 @@ static struct bpf_binary_header *bpf_alloc_binary(unsigned int bpfsize,
 	return header;
 }
 
-void bpf_jit_compile(struct sk_filter *fp)
+void bpf_jit_compile(struct bpf_prog *fp)
 {
 	struct bpf_binary_header *header = NULL;
 	unsigned long size, prg_len, lit_len;
@@ -875,7 +875,7 @@ out:
 	kfree(addrs);
 }
 
-void bpf_jit_free(struct sk_filter *fp)
+void bpf_jit_free(struct bpf_prog *fp)
 {
 	unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
 	struct bpf_binary_header *header = (void *)addr;
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index 892a102671ad..1f76c22a6a75 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -354,7 +354,7 @@ do {	*prog++ = BR_OPC | WDISP22(OFF);		\
  * emit_jump() calls with adjusted offsets.
  */
 
-void bpf_jit_compile(struct sk_filter *fp)
+void bpf_jit_compile(struct bpf_prog *fp)
 {
 	unsigned int cleanup_addr, proglen, oldproglen = 0;
 	u32 temp[8], *prog, *func, seen = 0, pass;
@@ -808,7 +808,7 @@ out:
 	return;
 }
 
-void bpf_jit_free(struct sk_filter *fp)
+void bpf_jit_free(struct bpf_prog *fp)
 {
 	if (fp->jited)
 		module_free(NULL, fp->bpf_func);
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 71737a83f022..ad8701da196c 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -211,7 +211,7 @@ struct jit_context {
 	bool seen_ld_abs;
 };
 
-static int do_jit(struct sk_filter *bpf_prog, int *addrs, u8 *image,
+static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 		  int oldproglen, struct jit_context *ctx)
 {
 	struct bpf_insn *insn = bpf_prog->insnsi;
@@ -862,11 +862,11 @@ common_load:		ctx->seen_ld_abs = true;
 	return proglen;
 }
 
-void bpf_jit_compile(struct sk_filter *prog)
+void bpf_jit_compile(struct bpf_prog *prog)
 {
 }
 
-void bpf_int_jit_compile(struct sk_filter *prog)
+void bpf_int_jit_compile(struct bpf_prog *prog)
 {
 	struct bpf_binary_header *header = NULL;
 	int proglen, oldproglen = 0;
@@ -932,7 +932,7 @@ out:
 
 static void bpf_jit_free_deferred(struct work_struct *work)
 {
-	struct sk_filter *fp = container_of(work, struct sk_filter, work);
+	struct bpf_prog *fp = container_of(work, struct bpf_prog, work);
 	unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
 	struct bpf_binary_header *header = (void *)addr;
 
@@ -941,7 +941,7 @@ static void bpf_jit_free_deferred(struct work_struct *work)
 	kfree(fp);
 }
 
-void bpf_jit_free(struct sk_filter *fp)
+void bpf_jit_free(struct bpf_prog *fp)
 {
 	if (fp->jited) {
 		INIT_WORK(&fp->work, bpf_jit_free_deferred);
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 765248b42a0a..4610c7fe284a 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -143,8 +143,8 @@ struct ppp {
 	struct sk_buff_head mrq;	/* MP: receive reconstruction queue */
 #endif /* CONFIG_PPP_MULTILINK */
 #ifdef CONFIG_PPP_FILTER
-	struct sk_filter *pass_filter;	/* filter for packets to pass */
-	struct sk_filter *active_filter;/* filter for pkts to reset idle */
+	struct bpf_prog *pass_filter;	/* filter for packets to pass */
+	struct bpf_prog *active_filter; /* filter for pkts to reset idle */
 #endif /* CONFIG_PPP_FILTER */
 	struct net	*ppp_net;	/* the net we belong to */
 	struct ppp_link_stats stats64;	/* 64 bit network stats */
diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index a58dfebb5512..649c8f2daa11 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -58,7 +58,7 @@ struct lb_priv_ex {
 };
 
 struct lb_priv {
-	struct sk_filter __rcu *fp;
+	struct bpf_prog __rcu *fp;
 	lb_select_tx_port_func_t __rcu *select_tx_port_func;
 	struct lb_pcpu_stats __percpu *pcpu_stats;
 	struct lb_priv_ex *ex; /* priv extension */
@@ -174,7 +174,7 @@ static lb_select_tx_port_func_t *lb_select_tx_port_get_func(const char *name)
 static unsigned int lb_get_skb_hash(struct lb_priv *lb_priv,
 				    struct sk_buff *skb)
 {
-	struct sk_filter *fp;
+	struct bpf_prog *fp;
 	uint32_t lhash;
 	unsigned char *c;
 
@@ -271,8 +271,8 @@ static void __fprog_destroy(struct sock_fprog_kern *fprog)
 static int lb_bpf_func_set(struct team *team, struct team_gsetter_ctx *ctx)
 {
 	struct lb_priv *lb_priv = get_lb_priv(team);
-	struct sk_filter *fp = NULL;
-	struct sk_filter *orig_fp;
+	struct bpf_prog *fp = NULL;
+	struct bpf_prog *orig_fp;
 	struct sock_fprog_kern *fprog = NULL;
 	int err;
 
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 20dd50ef7271..2f4c1b10e99d 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -323,7 +323,7 @@ struct sk_buff;
 struct sock;
 struct seccomp_data;
 
-struct sk_filter {
+struct bpf_prog {
 	atomic_t		refcnt;
 	u32			jited:1,	/* Is our filter JIT'ed? */
 				len:31;		/* Number of filter blocks */
@@ -340,8 +340,8 @@ struct sk_filter {
 
 static inline unsigned int sk_filter_size(unsigned int proglen)
 {
-	return max(sizeof(struct sk_filter),
-		   offsetof(struct sk_filter, insns[proglen]));
+	return max(sizeof(struct bpf_prog),
+		   offsetof(struct bpf_prog, insns[proglen]));
 }
 
 #define sk_filter_proglen(fprog)			\
@@ -349,15 +349,15 @@ static inline unsigned int sk_filter_size(unsigned int proglen)
 
 int sk_filter(struct sock *sk, struct sk_buff *skb);
 
-void sk_filter_select_runtime(struct sk_filter *fp);
-void sk_filter_free(struct sk_filter *fp);
+void sk_filter_select_runtime(struct bpf_prog *fp);
+void sk_filter_free(struct bpf_prog *fp);
 
 int sk_convert_filter(struct sock_filter *prog, int len,
 		      struct bpf_insn *new_prog, int *new_len);
 
-int sk_unattached_filter_create(struct sk_filter **pfp,
+int sk_unattached_filter_create(struct bpf_prog **pfp,
 				struct sock_fprog_kern *fprog);
-void sk_unattached_filter_destroy(struct sk_filter *fp);
+void sk_unattached_filter_destroy(struct bpf_prog *fp);
 
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 int sk_detach_filter(struct sock *sk);
@@ -366,11 +366,11 @@ int sk_chk_filter(const struct sock_filter *filter, unsigned int flen);
 int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
 		  unsigned int len);
 
-void sk_filter_charge(struct sock *sk, struct sk_filter *fp);
-void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp);
+void sk_filter_charge(struct sock *sk, struct bpf_prog *fp);
+void sk_filter_uncharge(struct sock *sk, struct bpf_prog *fp);
 
 u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
-void bpf_int_jit_compile(struct sk_filter *fp);
+void bpf_int_jit_compile(struct bpf_prog *fp);
 
 #define BPF_ANC		BIT(15)
 
@@ -424,8 +424,8 @@ static inline void *bpf_load_pointer(const struct sk_buff *skb, int k,
 #include <linux/linkage.h>
 #include <linux/printk.h>
 
-void bpf_jit_compile(struct sk_filter *fp);
-void bpf_jit_free(struct sk_filter *fp);
+void bpf_jit_compile(struct bpf_prog *fp);
+void bpf_jit_free(struct bpf_prog *fp);
 
 static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
 				u32 pass, void *image)
@@ -439,11 +439,11 @@ static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
 #else
 #include <linux/slab.h>
 
-static inline void bpf_jit_compile(struct sk_filter *fp)
+static inline void bpf_jit_compile(struct bpf_prog *fp)
 {
 }
 
-static inline void bpf_jit_free(struct sk_filter *fp)
+static inline void bpf_jit_free(struct bpf_prog *fp)
 {
 	kfree(fp);
 }
diff --git a/include/linux/isdn_ppp.h b/include/linux/isdn_ppp.h
index 8e10f57f109f..a0070c6dfaf8 100644
--- a/include/linux/isdn_ppp.h
+++ b/include/linux/isdn_ppp.h
@@ -180,8 +180,8 @@ struct ippp_struct {
   struct slcompress *slcomp;
 #endif
 #ifdef CONFIG_IPPP_FILTER
-  struct sk_filter *pass_filter;   /* filter for packets to pass */
-  struct sk_filter *active_filter; /* filter for pkts to reset idle */
+  struct bpf_prog *pass_filter;   /* filter for packets to pass */
+  struct bpf_prog *active_filter; /* filter for pkts to reset idle */
 #endif
   unsigned long debug;
   struct isdn_ppp_compressor *compressor,*decompressor;
diff --git a/include/net/sock.h b/include/net/sock.h
index 720773304a85..ec21bd1b37e1 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -356,7 +356,7 @@ struct sock {
 	atomic_t		sk_drops;
 	int			sk_rcvbuf;
 
-	struct sk_filter __rcu	*sk_filter;
+	struct bpf_prog __rcu	*sk_filter;
 	struct socket_wq __rcu	*sk_wq;
 
 #ifdef CONFIG_NET_DMA
diff --git a/include/uapi/linux/netfilter/xt_bpf.h b/include/uapi/linux/netfilter/xt_bpf.h
index 5dda450eb55b..4c67dd8089c0 100644
--- a/include/uapi/linux/netfilter/xt_bpf.h
+++ b/include/uapi/linux/netfilter/xt_bpf.h
@@ -11,7 +11,7 @@ struct xt_bpf_info {
 	struct sock_filter bpf_program[XT_BPF_MAX_NUM_INSTR];
 
 	/* only used in the kernel */
-	struct sk_filter *filter __attribute__((aligned(8)));
+	void *filter __attribute__((aligned(8)));
 };
 
 #endif /*_XT_BPF_H */
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 265a02cc822d..e29000adfee2 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -508,7 +508,7 @@ load_byte:
 		return 0;
 }
 
-void __weak bpf_int_jit_compile(struct sk_filter *prog)
+void __weak bpf_int_jit_compile(struct bpf_prog *prog)
 {
 }
 
@@ -519,7 +519,7 @@ void __weak bpf_int_jit_compile(struct sk_filter *prog)
  * try to JIT internal BPF program, if JIT is not available select interpreter
  * BPF program will be executed via SK_RUN_FILTER() macro
  */
-void sk_filter_select_runtime(struct sk_filter *fp)
+void sk_filter_select_runtime(struct bpf_prog *fp)
 {
 	fp->bpf_func = (void *) __sk_run_filter;
 
@@ -529,7 +529,7 @@ void sk_filter_select_runtime(struct sk_filter *fp)
 EXPORT_SYMBOL_GPL(sk_filter_select_runtime);
 
 /* free internal BPF program */
-void sk_filter_free(struct sk_filter *fp)
+void sk_filter_free(struct bpf_prog *fp)
 {
 	bpf_jit_free(fp);
 }
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 565743db5384..5026b9cef786 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -54,7 +54,7 @@
 struct seccomp_filter {
 	atomic_t usage;
 	struct seccomp_filter *prev;
-	struct sk_filter *prog;
+	struct bpf_prog *prog;
 };
 
 /* Limit any path through the tree to 256KB worth of instructions. */
diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 5f48623ee1a7..00e7d8ec0cee 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -1761,9 +1761,9 @@ static int probe_filter_length(struct sock_filter *fp)
 	return len + 1;
 }
 
-static struct sk_filter *generate_filter(int which, int *err)
+static struct bpf_prog *generate_filter(int which, int *err)
 {
-	struct sk_filter *fp;
+	struct bpf_prog *fp;
 	struct sock_fprog_kern fprog;
 	unsigned int flen = probe_filter_length(tests[which].u.insns);
 	__u8 test_type = tests[which].aux & TEST_TYPE_MASK;
@@ -1817,7 +1817,7 @@ static struct sk_filter *generate_filter(int which, int *err)
 	return fp;
 }
 
-static void release_filter(struct sk_filter *fp, int which)
+static void release_filter(struct bpf_prog *fp, int which)
 {
 	__u8 test_type = tests[which].aux & TEST_TYPE_MASK;
 
@@ -1831,7 +1831,7 @@ static void release_filter(struct sk_filter *fp, int which)
 	}
 }
 
-static int __run_one(const struct sk_filter *fp, const void *data,
+static int __run_one(const struct bpf_prog *fp, const void *data,
 		     int runs, u64 *duration)
 {
 	u64 start, finish;
@@ -1850,7 +1850,7 @@ static int __run_one(const struct sk_filter *fp, const void *data,
 	return ret;
 }
 
-static int run_one(const struct sk_filter *fp, struct bpf_test *test)
+static int run_one(const struct bpf_prog *fp, struct bpf_test *test)
 {
 	int err_cnt = 0, i, runs = MAX_TESTRUNS;
 
@@ -1884,7 +1884,7 @@ static __init int test_bpf(void)
 	int i, err_cnt = 0, pass_cnt = 0;
 
 	for (i = 0; i < ARRAY_SIZE(tests); i++) {
-		struct sk_filter *fp;
+		struct bpf_prog *fp;
 		int err;
 
 		pr_info("#%d %s ", i, tests[i].descr);
diff --git a/net/core/filter.c b/net/core/filter.c
index f3b2d5e9fe5f..5b1ebffc6c19 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -60,7 +60,7 @@
 int sk_filter(struct sock *sk, struct sk_buff *skb)
 {
 	int err;
-	struct sk_filter *filter;
+	struct bpf_prog *filter;
 
 	/*
 	 * If the skb was allocated from pfmemalloc reserves, only
@@ -810,7 +810,7 @@ int sk_chk_filter(const struct sock_filter *filter, unsigned int flen)
 }
 EXPORT_SYMBOL(sk_chk_filter);
 
-static int sk_store_orig_filter(struct sk_filter *fp,
+static int sk_store_orig_filter(struct bpf_prog *fp,
 				const struct sock_fprog *fprog)
 {
 	unsigned int fsize = sk_filter_proglen(fprog);
@@ -831,7 +831,7 @@ static int sk_store_orig_filter(struct sk_filter *fp,
 	return 0;
 }
 
-static void sk_release_orig_filter(struct sk_filter *fp)
+static void sk_release_orig_filter(struct bpf_prog *fp)
 {
 	struct sock_fprog_kern *fprog = fp->orig_prog;
 
@@ -847,7 +847,7 @@ static void sk_release_orig_filter(struct sk_filter *fp)
  */
 static void sk_filter_release_rcu(struct rcu_head *rcu)
 {
-	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
+	struct bpf_prog *fp = container_of(rcu, struct bpf_prog, rcu);
 
 	sk_release_orig_filter(fp);
 	sk_filter_free(fp);
@@ -859,29 +859,28 @@ static void sk_filter_release_rcu(struct rcu_head *rcu)
  *
  *	Remove a filter from a socket and release its resources.
  */
-static void sk_filter_release(struct sk_filter *fp)
+static void sk_filter_release(struct bpf_prog *fp)
 {
 	if (atomic_dec_and_test(&fp->refcnt))
 		call_rcu(&fp->rcu, sk_filter_release_rcu);
 }
 
-void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp)
+void sk_filter_uncharge(struct sock *sk, struct bpf_prog *fp)
 {
 	atomic_sub(sk_filter_size(fp->len), &sk->sk_omem_alloc);
 	sk_filter_release(fp);
 }
 
-void sk_filter_charge(struct sock *sk, struct sk_filter *fp)
+void sk_filter_charge(struct sock *sk, struct bpf_prog *fp)
 {
 	atomic_inc(&fp->refcnt);
 	atomic_add(sk_filter_size(fp->len), &sk->sk_omem_alloc);
 }
 
-static struct sk_filter *__sk_migrate_realloc(struct sk_filter *fp,
-					      struct sock *sk,
-					      unsigned int len)
+static struct bpf_prog *__sk_migrate_realloc(struct bpf_prog *fp,
+					     struct sock *sk, unsigned int len)
 {
-	struct sk_filter *fp_new;
+	struct bpf_prog *fp_new;
 
 	if (sk == NULL)
 		return krealloc(fp, len, GFP_KERNEL);
@@ -900,11 +899,11 @@ static struct sk_filter *__sk_migrate_realloc(struct sk_filter *fp,
 	return fp_new;
 }
 
-static struct sk_filter *__sk_migrate_filter(struct sk_filter *fp,
-					     struct sock *sk)
+static struct bpf_prog *__sk_migrate_filter(struct bpf_prog *fp,
+					    struct sock *sk)
 {
 	struct sock_filter *old_prog;
-	struct sk_filter *old_fp;
+	struct bpf_prog *old_fp;
 	int err, new_len, old_len = fp->len;
 
 	/* We are free to overwrite insns et al right here as it
@@ -971,8 +970,8 @@ out_err:
 	return ERR_PTR(err);
 }
 
-static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp,
-					     struct sock *sk)
+static struct bpf_prog *__sk_prepare_filter(struct bpf_prog *fp,
+					    struct sock *sk)
 {
 	int err;
 
@@ -1012,11 +1011,11 @@ static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp,
  * If an error occurs or there is insufficient memory for the filter
  * a negative errno code is returned. On success the return is zero.
  */
-int sk_unattached_filter_create(struct sk_filter **pfp,
+int sk_unattached_filter_create(struct bpf_prog **pfp,
 				struct sock_fprog_kern *fprog)
 {
 	unsigned int fsize = sk_filter_proglen(fprog);
-	struct sk_filter *fp;
+	struct bpf_prog *fp;
 
 	/* Make sure new filter is there and in the right amounts. */
 	if (fprog->filter == NULL)
@@ -1048,7 +1047,7 @@ int sk_unattached_filter_create(struct sk_filter **pfp,
 }
 EXPORT_SYMBOL_GPL(sk_unattached_filter_create);
 
-void sk_unattached_filter_destroy(struct sk_filter *fp)
+void sk_unattached_filter_destroy(struct bpf_prog *fp)
 {
 	sk_filter_release(fp);
 }
@@ -1066,7 +1065,7 @@ EXPORT_SYMBOL_GPL(sk_unattached_filter_destroy);
  */
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 {
-	struct sk_filter *fp, *old_fp;
+	struct bpf_prog *fp, *old_fp;
 	unsigned int fsize = sk_filter_proglen(fprog);
 	unsigned int sk_fsize = sk_filter_size(fprog->len);
 	int err;
@@ -1117,7 +1116,7 @@ EXPORT_SYMBOL_GPL(sk_attach_filter);
 int sk_detach_filter(struct sock *sk)
 {
 	int ret = -ENOENT;
-	struct sk_filter *filter;
+	struct bpf_prog *filter;
 
 	if (sock_flag(sk, SOCK_FILTER_LOCKED))
 		return -EPERM;
@@ -1138,7 +1137,7 @@ int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf,
 		  unsigned int len)
 {
 	struct sock_fprog_kern *fprog;
-	struct sk_filter *filter;
+	struct bpf_prog *filter;
 	int ret = 0;
 
 	lock_sock(sk);
diff --git a/net/core/ptp_classifier.c b/net/core/ptp_classifier.c
index 12ab7b4be609..8debe826dc1a 100644
--- a/net/core/ptp_classifier.c
+++ b/net/core/ptp_classifier.c
@@ -107,7 +107,7 @@
 #include <linux/filter.h>
 #include <linux/ptp_classify.h>
 
-static struct sk_filter *ptp_insns __read_mostly;
+static struct bpf_prog *ptp_insns __read_mostly;
 
 unsigned int ptp_classify_raw(const struct sk_buff *skb)
 {
diff --git a/net/core/sock.c b/net/core/sock.c
index ca9b65199d28..af81f1415f0a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1405,7 +1405,7 @@ EXPORT_SYMBOL(sk_alloc);
 
 static void __sk_free(struct sock *sk)
 {
-	struct sk_filter *filter;
+	struct bpf_prog *filter;
 
 	if (sk->sk_destruct)
 		sk->sk_destruct(sk);
@@ -1481,7 +1481,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 
 	newsk = sk_prot_alloc(sk->sk_prot, priority, sk->sk_family);
 	if (newsk != NULL) {
-		struct sk_filter *filter;
+		struct bpf_prog *filter;
 
 		sock_copy(newsk, sk);
 
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index a4216a4c9572..16072cf03432 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -53,7 +53,7 @@ int sock_diag_put_filterinfo(bool may_report_filterinfo, struct sock *sk,
 			     struct sk_buff *skb, int attrtype)
 {
 	struct sock_fprog_kern *fprog;
-	struct sk_filter *filter;
+	struct bpf_prog *filter;
 	struct nlattr *attr;
 	unsigned int flen;
 	int err = 0;
diff --git a/net/netfilter/xt_bpf.c b/net/netfilter/xt_bpf.c
index bbffdbdaf603..85be0c89d640 100644
--- a/net/netfilter/xt_bpf.c
+++ b/net/netfilter/xt_bpf.c
@@ -28,7 +28,8 @@ static int bpf_mt_check(const struct xt_mtchk_param *par)
 	program.len = info->bpf_program_num_elem;
 	program.filter = info->bpf_program;
 
-	if (sk_unattached_filter_create(&info->filter, &program)) {
+	if (sk_unattached_filter_create((struct bpf_prog **) &info->filter,
+					&program)) {
 		pr_info("bpf: check failed: parse error\n");
 		return -EINVAL;
 	}
@@ -40,13 +41,13 @@ static bool bpf_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_bpf_info *info = par->matchinfo;
 
-	return SK_RUN_FILTER(info->filter, skb);
+	return SK_RUN_FILTER(((struct bpf_prog *) info->filter), skb);
 }
 
 static void bpf_mt_destroy(const struct xt_mtdtor_param *par)
 {
 	const struct xt_bpf_info *info = par->matchinfo;
-	sk_unattached_filter_destroy(info->filter);
+	sk_unattached_filter_destroy((struct bpf_prog *) info->filter);
 }
 
 static struct xt_match bpf_mt_reg __read_mostly = {
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 614ca91f785a..1db01efbd4f2 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1732,7 +1732,7 @@ static unsigned int run_filter(const struct sk_buff *skb,
 				      const struct sock *sk,
 				      unsigned int res)
 {
-	struct sk_filter *filter;
+	struct bpf_prog *filter;
 
 	rcu_read_lock();
 	filter = rcu_dereference(sk->sk_filter);
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 13f64df2c710..f5a24875e0ff 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -30,7 +30,7 @@ struct cls_bpf_head {
 };
 
 struct cls_bpf_prog {
-	struct sk_filter *filter;
+	struct bpf_prog *filter;
 	struct sock_filter *bpf_ops;
 	struct tcf_exts exts;
 	struct tcf_result res;
@@ -161,7 +161,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 	struct sock_filter *bpf_ops, *bpf_old;
 	struct tcf_exts exts;
 	struct sock_fprog_kern tmp;
-	struct sk_filter *fp, *fp_old;
+	struct bpf_prog *fp, *fp_old;
 	u16 bpf_size, bpf_len;
 	u32 classid;
 	int ret;
-- 
1.7.9.5
