From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v3 net-next] net: filter: cleanup sk_* and bpf_* names
Date: Mon, 28 Jul 2014 23:29:40 -0700
Message-ID: <1406615380-3488-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

clean up names related to socket filtering and bpf in the following way:
- everything that deals with sockets keeps 'sk_*' prefix
- everything that is pure BPF is changed to 'bpf_*' prefix

API for attaching classic BPF to a socket stays the same:
sk_attach_filter()/sk_detach_filter()
and SK_RUN_FILTER() to execute a program

API for 'unattached' BPF programs becomes:
bpf_prog_create()/bpf_prog_destroy()
and BPF_PROG_RUN() to execute a program

Introduce callback mechanism for 'struct sk_filter', so that different
filtering engines can be used in the future (as requested by Pablo)

Socket charging logic was complicated, since we had to charge/uncharge a socket
multiple times while preparing a filter. Simplify it by fully preparing bpf
program (through classic->ebpf conversion and JITing) and then charge
the socket memory once.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
v2->v3:
. full rename of funcs and structs (instead of renaming single struct sk_filter)
. added 'struct sk_filter' callback mechanism as Pablo suggested
. changed xt_bpf.h to use 'struct bpf_prog' as Dave suggested

 Documentation/networking/filter.txt      |   12 +-
 arch/arm/net/bpf_jit_32.c                |    8 +-
 arch/mips/net/bpf_jit.c                  |    8 +-
 arch/powerpc/net/bpf_jit_comp.c          |    8 +-
 arch/s390/net/bpf_jit_comp.c             |    4 +-
 arch/sparc/net/bpf_jit_comp.c            |    4 +-
 arch/x86/net/bpf_jit_comp.c              |   14 +-
 drivers/isdn/i4l/isdn_ppp.c              |   26 ++--
 drivers/net/ppp/ppp_generic.c            |   28 ++--
 drivers/net/team/team_mode_loadbalance.c |   14 +-
 include/linux/filter.h                   |   57 ++++----
 include/linux/isdn_ppp.h                 |    4 +-
 include/uapi/linux/netfilter/xt_bpf.h    |    5 +-
 kernel/bpf/core.c                        |   34 +++--
 kernel/seccomp.c                         |   18 +--
 lib/test_bpf.c                           |   24 ++--
 net/core/filter.c                        |  232 +++++++++++++++++-------------
 net/core/ptp_classifier.c                |    6 +-
 net/core/sock.c                          |    7 +-
 net/core/sock_diag.c                     |    9 +-
 net/netfilter/xt_bpf.c                   |    6 +-
 net/sched/cls_bpf.c                      |   12 +-
 22 files changed, 287 insertions(+), 253 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index ee78eba78a9d..c48a9704bda8 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -586,12 +586,12 @@ team driver's classifier for its load-balancing mode, netfilter's xt_bpf
 extension, PTP dissector/classifier, and much more. They are all internally
 converted by the kernel into the new instruction set representation and run
 in the eBPF interpreter. For in-kernel handlers, this all works transparently
-by using sk_unattached_filter_create() for setting up the filter, resp.
-sk_unattached_filter_destroy() for destroying it. The macro
-SK_RUN_FILTER(filter, ctx) transparently invokes eBPF interpreter or JITed
-code to run the filter. 'filter' is a pointer to struct sk_filter that we
-got from sk_unattached_filter_create(), and 'ctx' the given context (e.g.
-skb pointer). All constraints and restrictions from sk_chk_filter() apply
+by using bpf_prog_create() for setting up the filter, resp.
+bpf_prog_destroy() for destroying it. The macro
+BPF_PROG_RUN(filter, ctx) transparently invokes eBPF interpreter or JITed
+code to run the filter. 'filter' is a pointer to struct bpf_prog that we
+got from bpf_prog_create(), and 'ctx' the given context (e.g.
+skb pointer). All constraints and restrictions from bpf_check_classic() apply
 before a conversion to the new layout is being done behind the scenes!
 
 Currently, the classic BPF format is being used for JITing on most of the
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
index 71737a83f022..5c8cb8043c5a 100644
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
@@ -235,7 +235,7 @@ static int do_jit(struct sk_filter *bpf_prog, int *addrs, u8 *image,
 	/* mov qword ptr [rbp-X],rbx */
 	EMIT3_off32(0x48, 0x89, 0x9D, -stacksize);
 
-	/* sk_convert_filter() maps classic BPF register X to R7 and uses R8
+	/* bpf_convert_filter() maps classic BPF register X to R7 and uses R8
 	 * as temporary, so all tcpdump filters need to spill/fill R7(r13) and
 	 * R8(r14). R9(r15) spill could be made conditional, but there is only
 	 * one 'bpf_error' return path out of helper functions inside bpf_jit.S
@@ -841,7 +841,7 @@ common_load:		ctx->seen_ld_abs = true;
 			/* By design x64 JIT should support all BPF instructions
 			 * This error will be seen if new instruction was added
 			 * to interpreter, but not to JIT
-			 * or if there is junk in sk_filter
+			 * or if there is junk in bpf_prog
 			 */
 			pr_err("bpf_jit: unknown opcode %02x\n", insn->code);
 			return -EINVAL;
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
diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index 62f0688d45a5..c4198fa490bf 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -379,12 +379,12 @@ isdn_ppp_release(int min, struct file *file)
 #endif
 #ifdef CONFIG_IPPP_FILTER
 	if (is->pass_filter) {
-		sk_unattached_filter_destroy(is->pass_filter);
+		bpf_prog_destroy(is->pass_filter);
 		is->pass_filter = NULL;
 	}
 
 	if (is->active_filter) {
-		sk_unattached_filter_destroy(is->active_filter);
+		bpf_prog_destroy(is->active_filter);
 		is->active_filter = NULL;
 	}
 #endif
@@ -639,12 +639,11 @@ isdn_ppp_ioctl(int min, struct file *file, unsigned int cmd, unsigned long arg)
 		fprog.filter = code;
 
 		if (is->pass_filter) {
-			sk_unattached_filter_destroy(is->pass_filter);
+			bpf_prog_destroy(is->pass_filter);
 			is->pass_filter = NULL;
 		}
 		if (fprog.filter != NULL)
-			err = sk_unattached_filter_create(&is->pass_filter,
-							  &fprog);
+			err = bpf_prog_create(&is->pass_filter, &fprog);
 		else
 			err = 0;
 		kfree(code);
@@ -664,12 +663,11 @@ isdn_ppp_ioctl(int min, struct file *file, unsigned int cmd, unsigned long arg)
 		fprog.filter = code;
 
 		if (is->active_filter) {
-			sk_unattached_filter_destroy(is->active_filter);
+			bpf_prog_destroy(is->active_filter);
 			is->active_filter = NULL;
 		}
 		if (fprog.filter != NULL)
-			err = sk_unattached_filter_create(&is->active_filter,
-							  &fprog);
+			err = bpf_prog_create(&is->active_filter, &fprog);
 		else
 			err = 0;
 		kfree(code);
@@ -1174,14 +1172,14 @@ isdn_ppp_push_higher(isdn_net_dev *net_dev, isdn_net_local *lp, struct sk_buff *
 	}
 
 	if (is->pass_filter
-	    && SK_RUN_FILTER(is->pass_filter, skb) == 0) {
+	    && BPF_PROG_RUN(is->pass_filter, skb) == 0) {
 		if (is->debug & 0x2)
 			printk(KERN_DEBUG "IPPP: inbound frame filtered.\n");
 		kfree_skb(skb);
 		return;
 	}
 	if (!(is->active_filter
-	      && SK_RUN_FILTER(is->active_filter, skb) == 0)) {
+	      && BPF_PROG_RUN(is->active_filter, skb) == 0)) {
 		if (is->debug & 0x2)
 			printk(KERN_DEBUG "IPPP: link-active filter: resetting huptimer.\n");
 		lp->huptimer = 0;
@@ -1320,14 +1318,14 @@ isdn_ppp_xmit(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	if (ipt->pass_filter
-	    && SK_RUN_FILTER(ipt->pass_filter, skb) == 0) {
+	    && BPF_PROG_RUN(ipt->pass_filter, skb) == 0) {
 		if (ipt->debug & 0x4)
 			printk(KERN_DEBUG "IPPP: outbound frame filtered.\n");
 		kfree_skb(skb);
 		goto unlock;
 	}
 	if (!(ipt->active_filter
-	      && SK_RUN_FILTER(ipt->active_filter, skb) == 0)) {
+	      && BPF_PROG_RUN(ipt->active_filter, skb) == 0)) {
 		if (ipt->debug & 0x4)
 			printk(KERN_DEBUG "IPPP: link-active filter: resetting huptimer.\n");
 		lp->huptimer = 0;
@@ -1517,9 +1515,9 @@ int isdn_ppp_autodial_filter(struct sk_buff *skb, isdn_net_local *lp)
 	}
 
 	drop |= is->pass_filter
-		&& SK_RUN_FILTER(is->pass_filter, skb) == 0;
+		&& BPF_PROG_RUN(is->pass_filter, skb) == 0;
 	drop |= is->active_filter
-		&& SK_RUN_FILTER(is->active_filter, skb) == 0;
+		&& BPF_PROG_RUN(is->active_filter, skb) == 0;
 
 	skb_push(skb, IPPP_MAX_HEADER - 4);
 	return drop;
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 765248b42a0a..fa0d71727894 100644
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
@@ -762,12 +762,12 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 			ppp_lock(ppp);
 			if (ppp->pass_filter) {
-				sk_unattached_filter_destroy(ppp->pass_filter);
+				bpf_prog_destroy(ppp->pass_filter);
 				ppp->pass_filter = NULL;
 			}
 			if (fprog.filter != NULL)
-				err = sk_unattached_filter_create(&ppp->pass_filter,
-								  &fprog);
+				err = bpf_prog_create(&ppp->pass_filter,
+						      &fprog);
 			else
 				err = 0;
 			kfree(code);
@@ -788,12 +788,12 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 			ppp_lock(ppp);
 			if (ppp->active_filter) {
-				sk_unattached_filter_destroy(ppp->active_filter);
+				bpf_prog_destroy(ppp->active_filter);
 				ppp->active_filter = NULL;
 			}
 			if (fprog.filter != NULL)
-				err = sk_unattached_filter_create(&ppp->active_filter,
-								  &fprog);
+				err = bpf_prog_create(&ppp->active_filter,
+						      &fprog);
 			else
 				err = 0;
 			kfree(code);
@@ -1205,7 +1205,7 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 		   a four-byte PPP header on each packet */
 		*skb_push(skb, 2) = 1;
 		if (ppp->pass_filter &&
-		    SK_RUN_FILTER(ppp->pass_filter, skb) == 0) {
+		    BPF_PROG_RUN(ppp->pass_filter, skb) == 0) {
 			if (ppp->debug & 1)
 				netdev_printk(KERN_DEBUG, ppp->dev,
 					      "PPP: outbound frame "
@@ -1215,7 +1215,7 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 		}
 		/* if this packet passes the active filter, record the time */
 		if (!(ppp->active_filter &&
-		      SK_RUN_FILTER(ppp->active_filter, skb) == 0))
+		      BPF_PROG_RUN(ppp->active_filter, skb) == 0))
 			ppp->last_xmit = jiffies;
 		skb_pull(skb, 2);
 #else
@@ -1839,7 +1839,7 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 
 			*skb_push(skb, 2) = 0;
 			if (ppp->pass_filter &&
-			    SK_RUN_FILTER(ppp->pass_filter, skb) == 0) {
+			    BPF_PROG_RUN(ppp->pass_filter, skb) == 0) {
 				if (ppp->debug & 1)
 					netdev_printk(KERN_DEBUG, ppp->dev,
 						      "PPP: inbound frame "
@@ -1848,7 +1848,7 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 				return;
 			}
 			if (!(ppp->active_filter &&
-			      SK_RUN_FILTER(ppp->active_filter, skb) == 0))
+			      BPF_PROG_RUN(ppp->active_filter, skb) == 0))
 				ppp->last_recv = jiffies;
 			__skb_pull(skb, 2);
 		} else
@@ -2829,12 +2829,12 @@ static void ppp_destroy_interface(struct ppp *ppp)
 #endif /* CONFIG_PPP_MULTILINK */
 #ifdef CONFIG_PPP_FILTER
 	if (ppp->pass_filter) {
-		sk_unattached_filter_destroy(ppp->pass_filter);
+		bpf_prog_destroy(ppp->pass_filter);
 		ppp->pass_filter = NULL;
 	}
 
 	if (ppp->active_filter) {
-		sk_unattached_filter_destroy(ppp->active_filter);
+		bpf_prog_destroy(ppp->active_filter);
 		ppp->active_filter = NULL;
 	}
 #endif /* CONFIG_PPP_FILTER */
diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index a58dfebb5512..b9c94c87d043 100644
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
@@ -174,14 +174,14 @@ static lb_select_tx_port_func_t *lb_select_tx_port_get_func(const char *name)
 static unsigned int lb_get_skb_hash(struct lb_priv *lb_priv,
 				    struct sk_buff *skb)
 {
-	struct sk_filter *fp;
+	struct bpf_prog *fp;
 	uint32_t lhash;
 	unsigned char *c;
 
 	fp = rcu_dereference_bh(lb_priv->fp);
 	if (unlikely(!fp))
 		return 0;
-	lhash = SK_RUN_FILTER(fp, skb);
+	lhash = BPF_PROG_RUN(fp, skb);
 	c = (char *) &lhash;
 	return c[0] ^ c[1] ^ c[2] ^ c[3];
 }
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
 
@@ -281,7 +281,7 @@ static int lb_bpf_func_set(struct team *team, struct team_gsetter_ctx *ctx)
 				     ctx->data.bin_val.ptr);
 		if (err)
 			return err;
-		err = sk_unattached_filter_create(&fp, fprog);
+		err = bpf_prog_create(&fp, fprog);
 		if (err) {
 			__fprog_destroy(fprog);
 			return err;
@@ -293,7 +293,7 @@ static int lb_bpf_func_set(struct team *team, struct team_gsetter_ctx *ctx)
 		__fprog_destroy(lb_priv->ex->orig_fprog);
 		orig_fp = rcu_dereference_protected(lb_priv->fp,
 						lockdep_is_held(&team->lock));
-		sk_unattached_filter_destroy(orig_fp);
+		bpf_prog_destroy(orig_fp);
 	}
 
 	rcu_assign_pointer(lb_priv->fp, fp);
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 20dd50ef7271..448fdd193cdf 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -296,7 +296,7 @@ enum {
 })
 
 /* Macro to invoke filter function. */
-#define SK_RUN_FILTER(filter, ctx)  (*filter->bpf_func)(ctx, filter->insnsi)
+#define SK_RUN_FILTER(filter, ctx)  (*filter->run)(ctx, filter)
 
 struct bpf_insn {
 	__u8	code;		/* opcode */
@@ -323,12 +323,11 @@ struct sk_buff;
 struct sock;
 struct seccomp_data;
 
-struct sk_filter {
-	atomic_t		refcnt;
+struct bpf_prog {
 	u32			jited:1,	/* Is our filter JIT'ed? */
 				len:31;		/* Number of filter blocks */
 	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
-	struct rcu_head		rcu;
+	struct rcu_head		rcu;		/* used by 'unattached' progs */
 	unsigned int		(*bpf_func)(const struct sk_buff *skb,
 					    const struct bpf_insn *filter);
 	union {
@@ -337,40 +336,48 @@ struct sk_filter {
 		struct work_struct	work;
 	};
 };
+#define BPF_PROG_RUN(filter, ctx)  (*filter->bpf_func)(ctx, filter->insnsi)
 
-static inline unsigned int sk_filter_size(unsigned int proglen)
+static inline unsigned int bpf_prog_size(unsigned int proglen)
 {
-	return max(sizeof(struct sk_filter),
-		   offsetof(struct sk_filter, insns[proglen]));
+	return max(sizeof(struct bpf_prog),
+		   offsetof(struct bpf_prog, insns[proglen]));
 }
 
-#define sk_filter_proglen(fprog)			\
-		(fprog->len * sizeof(fprog->filter[0]))
+struct sk_filter {
+	atomic_t refcnt;
+	struct rcu_head rcu;
+	u32 filter_size;
+	union {
+		struct bpf_prog *prog;
+	};
+	void (*release)(struct sk_filter *fp);
+	int (*get_filter)(struct sk_filter *fp, void **prog, unsigned int *len);
+	unsigned int (*run)(const struct sk_buff *skb, struct sk_filter *fp);
+};
 
 int sk_filter(struct sock *sk, struct sk_buff *skb);
 
-void sk_filter_select_runtime(struct sk_filter *fp);
-void sk_filter_free(struct sk_filter *fp);
+void bpf_prog_select_runtime(struct bpf_prog *fp);
+void bpf_prog_free(struct bpf_prog *fp);
 
-int sk_convert_filter(struct sock_filter *prog, int len,
-		      struct bpf_insn *new_prog, int *new_len);
+int bpf_convert_filter(struct sock_filter *prog, int len,
+		       struct bpf_insn *new_prog, int *new_len);
 
-int sk_unattached_filter_create(struct sk_filter **pfp,
-				struct sock_fprog_kern *fprog);
-void sk_unattached_filter_destroy(struct sk_filter *fp);
+int bpf_prog_create(struct bpf_prog **pfp, struct sock_fprog_kern *fprog);
+void bpf_prog_destroy(struct bpf_prog *fp);
 
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 int sk_detach_filter(struct sock *sk);
 
-int sk_chk_filter(const struct sock_filter *filter, unsigned int flen);
-int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
-		  unsigned int len);
+int bpf_check_classic(const struct sock_filter *filter, unsigned int flen);
+int sk_get_filter(struct sock *sk, char __user *filter, unsigned int len);
 
-void sk_filter_charge(struct sock *sk, struct sk_filter *fp);
+bool sk_filter_charge(struct sock *sk, struct sk_filter *fp);
 void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp);
 
 u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
-void bpf_int_jit_compile(struct sk_filter *fp);
+void bpf_int_jit_compile(struct bpf_prog *fp);
 
 #define BPF_ANC		BIT(15)
 
@@ -424,8 +431,8 @@ static inline void *bpf_load_pointer(const struct sk_buff *skb, int k,
 #include <linux/linkage.h>
 #include <linux/printk.h>
 
-void bpf_jit_compile(struct sk_filter *fp);
-void bpf_jit_free(struct sk_filter *fp);
+void bpf_jit_compile(struct bpf_prog *fp);
+void bpf_jit_free(struct bpf_prog *fp);
 
 static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
 				u32 pass, void *image)
@@ -439,11 +446,11 @@ static inline void bpf_jit_dump(unsigned int flen, unsigned int proglen,
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
diff --git a/include/uapi/linux/netfilter/xt_bpf.h b/include/uapi/linux/netfilter/xt_bpf.h
index 5dda450eb55b..7c8ca16706fb 100644
--- a/include/uapi/linux/netfilter/xt_bpf.h
+++ b/include/uapi/linux/netfilter/xt_bpf.h
@@ -1,17 +1,18 @@
 #ifndef _XT_BPF_H
 #define _XT_BPF_H
 
-#include <linux/filter.h>
 #include <linux/types.h>
 
 #define XT_BPF_MAX_NUM_INSTR	64
 
+struct bpf_prog;
+
 struct xt_bpf_info {
 	__u16 bpf_program_num_elem;
 	struct sock_filter bpf_program[XT_BPF_MAX_NUM_INSTR];
 
 	/* only used in the kernel */
-	struct sk_filter *filter __attribute__((aligned(8)));
+	struct bpf_prog *filter __attribute__((aligned(8)));
 };
 
 #endif /*_XT_BPF_H */
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 265a02cc822d..7f0dbcbb34af 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -18,7 +18,7 @@
  * 2 of the License, or (at your option) any later version.
  *
  * Andi Kleen - Fix a few bad bugs and races.
- * Kris Katterjohn - Added many additional checks in sk_chk_filter()
+ * Kris Katterjohn - Added many additional checks in bpf_check_classic()
  */
 #include <linux/filter.h>
 #include <linux/skbuff.h>
@@ -73,15 +73,13 @@ noinline u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 }
 
 /**
- *	__sk_run_filter - run a filter on a given context
- *	@ctx: buffer to run the filter on
- *	@insn: filter to apply
+ *	__bpf_prog_run - run eBPF program on a given context
+ *	@ctx: is the data we are operating on
+ *	@insn: is the array of eBPF instructions
  *
- * Decode and apply filter instructions to the skb->data. Return length to
- * keep, 0 for none. @ctx is the data we are operating on, @insn is the
- * array of filter instructions.
+ * Decode and execute eBPF instructions.
  */
-static unsigned int __sk_run_filter(void *ctx, const struct bpf_insn *insn)
+static unsigned int __bpf_prog_run(void *ctx, const struct bpf_insn *insn)
 {
 	u64 stack[MAX_BPF_STACK / sizeof(u64)];
 	u64 regs[MAX_BPF_REG], tmp;
@@ -446,7 +444,7 @@ load_word:
 		/* BPF_LD + BPD_ABS and BPF_LD + BPF_IND insns are
 		 * only appearing in the programs where ctx ==
 		 * skb. All programs keep 'ctx' in regs[BPF_REG_CTX]
-		 * == BPF_R6, sk_convert_filter() saves it in BPF_R6,
+		 * == BPF_R6, bpf_convert_filter() saves it in BPF_R6,
 		 * internal BPF verifier will check that BPF_R6 ==
 		 * ctx.
 		 *
@@ -508,29 +506,29 @@ load_byte:
 		return 0;
 }
 
-void __weak bpf_int_jit_compile(struct sk_filter *prog)
+void __weak bpf_int_jit_compile(struct bpf_prog *prog)
 {
 }
 
 /**
- *	sk_filter_select_runtime - select execution runtime for BPF program
- *	@fp: sk_filter populated with internal BPF program
+ *	bpf_prog_select_runtime - select execution runtime for BPF program
+ *	@fp: bpf_prog populated with internal BPF program
  *
  * try to JIT internal BPF program, if JIT is not available select interpreter
- * BPF program will be executed via SK_RUN_FILTER() macro
+ * BPF program will be executed via BPF_PROG_RUN() macro
  */
-void sk_filter_select_runtime(struct sk_filter *fp)
+void bpf_prog_select_runtime(struct bpf_prog *fp)
 {
-	fp->bpf_func = (void *) __sk_run_filter;
+	fp->bpf_func = (void *) __bpf_prog_run;
 
 	/* Probe if internal BPF can be JITed */
 	bpf_int_jit_compile(fp);
 }
-EXPORT_SYMBOL_GPL(sk_filter_select_runtime);
+EXPORT_SYMBOL_GPL(bpf_prog_select_runtime);
 
 /* free internal BPF program */
-void sk_filter_free(struct sk_filter *fp)
+void bpf_prog_free(struct bpf_prog *fp)
 {
 	bpf_jit_free(fp);
 }
-EXPORT_SYMBOL_GPL(sk_filter_free);
+EXPORT_SYMBOL_GPL(bpf_prog_free);
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 565743db5384..2f3fa2cc2eac 100644
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
@@ -87,7 +87,7 @@ static void populate_seccomp_data(struct seccomp_data *sd)
  *	@filter: filter to verify
  *	@flen: length of filter
  *
- * Takes a previously checked filter (by sk_chk_filter) and
+ * Takes a previously checked filter (by bpf_check_classic) and
  * redirects all filter code that loads struct sk_buff data
  * and related data through seccomp_bpf_load.  It also
  * enforces length and alignment checking of those loads.
@@ -187,7 +187,7 @@ static u32 seccomp_run_filters(int syscall)
 	 * value always takes priority (ignoring the DATA).
 	 */
 	for (f = current->seccomp.filter; f; f = f->prev) {
-		u32 cur_ret = SK_RUN_FILTER(f->prog, (void *)&sd);
+		u32 cur_ret = BPF_PROG_RUN(f->prog, (void *)&sd);
 
 		if ((cur_ret & SECCOMP_RET_ACTION) < (ret & SECCOMP_RET_ACTION))
 			ret = cur_ret;
@@ -239,7 +239,7 @@ static long seccomp_attach_filter(struct sock_fprog *fprog)
 		goto free_prog;
 
 	/* Check and rewrite the fprog via the skb checker */
-	ret = sk_chk_filter(fp, fprog->len);
+	ret = bpf_check_classic(fp, fprog->len);
 	if (ret)
 		goto free_prog;
 
@@ -249,7 +249,7 @@ static long seccomp_attach_filter(struct sock_fprog *fprog)
 		goto free_prog;
 
 	/* Convert 'sock_filter' insns to 'bpf_insn' insns */
-	ret = sk_convert_filter(fp, fprog->len, NULL, &new_len);
+	ret = bpf_convert_filter(fp, fprog->len, NULL, &new_len);
 	if (ret)
 		goto free_prog;
 
@@ -260,12 +260,12 @@ static long seccomp_attach_filter(struct sock_fprog *fprog)
 	if (!filter)
 		goto free_prog;
 
-	filter->prog = kzalloc(sk_filter_size(new_len),
+	filter->prog = kzalloc(bpf_prog_size(new_len),
 			       GFP_KERNEL|__GFP_NOWARN);
 	if (!filter->prog)
 		goto free_filter;
 
-	ret = sk_convert_filter(fp, fprog->len, filter->prog->insnsi, &new_len);
+	ret = bpf_convert_filter(fp, fprog->len, filter->prog->insnsi, &new_len);
 	if (ret)
 		goto free_filter_prog;
 	kfree(fp);
@@ -273,7 +273,7 @@ static long seccomp_attach_filter(struct sock_fprog *fprog)
 	atomic_set(&filter->usage, 1);
 	filter->prog->len = new_len;
 
-	sk_filter_select_runtime(filter->prog);
+	bpf_prog_select_runtime(filter->prog);
 
 	/*
 	 * If there is an existing filter, make it the prev and don't drop its
@@ -337,7 +337,7 @@ void put_seccomp_filter(struct task_struct *tsk)
 	while (orig && atomic_dec_and_test(&orig->usage)) {
 		struct seccomp_filter *freeme = orig;
 		orig = orig->prev;
-		sk_filter_free(freeme->prog);
+		bpf_prog_free(freeme->prog);
 		kfree(freeme);
 	}
 }
diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 5f48623ee1a7..89e0345733bd 100644
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
@@ -1773,7 +1773,7 @@ static struct sk_filter *generate_filter(int which, int *err)
 		fprog.filter = tests[which].u.insns;
 		fprog.len = flen;
 
-		*err = sk_unattached_filter_create(&fp, &fprog);
+		*err = bpf_prog_create(&fp, &fprog);
 		if (tests[which].aux & FLAG_EXPECTED_FAIL) {
 			if (*err == -EINVAL) {
 				pr_cont("PASS\n");
@@ -1798,7 +1798,7 @@ static struct sk_filter *generate_filter(int which, int *err)
 		break;
 
 	case INTERNAL:
-		fp = kzalloc(sk_filter_size(flen), GFP_KERNEL);
+		fp = kzalloc(bpf_prog_size(flen), GFP_KERNEL);
 		if (fp == NULL) {
 			pr_cont("UNEXPECTED_FAIL no memory left\n");
 			*err = -ENOMEM;
@@ -1809,7 +1809,7 @@ static struct sk_filter *generate_filter(int which, int *err)
 		memcpy(fp->insnsi, tests[which].u.insns_int,
 		       fp->len * sizeof(struct bpf_insn));
 
-		sk_filter_select_runtime(fp);
+		bpf_prog_select_runtime(fp);
 		break;
 	}
 
@@ -1817,21 +1817,21 @@ static struct sk_filter *generate_filter(int which, int *err)
 	return fp;
 }
 
-static void release_filter(struct sk_filter *fp, int which)
+static void release_filter(struct bpf_prog *fp, int which)
 {
 	__u8 test_type = tests[which].aux & TEST_TYPE_MASK;
 
 	switch (test_type) {
 	case CLASSIC:
-		sk_unattached_filter_destroy(fp);
+		bpf_prog_destroy(fp);
 		break;
 	case INTERNAL:
-		sk_filter_free(fp);
+		bpf_prog_free(fp);
 		break;
 	}
 }
 
-static int __run_one(const struct sk_filter *fp, const void *data,
+static int __run_one(const struct bpf_prog *fp, const void *data,
 		     int runs, u64 *duration)
 {
 	u64 start, finish;
@@ -1840,7 +1840,7 @@ static int __run_one(const struct sk_filter *fp, const void *data,
 	start = ktime_to_us(ktime_get());
 
 	for (i = 0; i < runs; i++)
-		ret = SK_RUN_FILTER(fp, data);
+		ret = BPF_PROG_RUN(fp, data);
 
 	finish = ktime_to_us(ktime_get());
 
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
index f3b2d5e9fe5f..01f11ceab9fe 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -18,7 +18,7 @@
  * 2 of the License, or (at your option) any later version.
  *
  * Andi Kleen - Fix a few bad bugs and races.
- * Kris Katterjohn - Added many additional checks in sk_chk_filter()
+ * Kris Katterjohn - Added many additional checks in bpf_check_classic()
  */
 
 #include <linux/module.h>
@@ -312,7 +312,7 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 }
 
 /**
- *	sk_convert_filter - convert filter program
+ *	bpf_convert_filter - convert filter program
  *	@prog: the user passed filter program
  *	@len: the length of the user passed filter program
  *	@new_prog: buffer where converted program will be stored
@@ -322,12 +322,12 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
  * Conversion workflow:
  *
  * 1) First pass for calculating the new program length:
- *   sk_convert_filter(old_prog, old_len, NULL, &new_len)
+ *   bpf_convert_filter(old_prog, old_len, NULL, &new_len)
  *
  * 2) 2nd pass to remap in two passes: 1st pass finds new
  *    jump offsets, 2nd pass remapping:
  *   new_prog = kmalloc(sizeof(struct bpf_insn) * new_len);
- *   sk_convert_filter(old_prog, old_len, new_prog, &new_len);
+ *   bpf_convert_filter(old_prog, old_len, new_prog, &new_len);
  *
  * User BPF's register A is mapped to our BPF register 6, user BPF
  * register X is mapped to BPF register 7; frame pointer is always
@@ -335,8 +335,8 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
  * for socket filters: ctx == 'struct sk_buff *', for seccomp:
  * ctx == 'struct seccomp_data *'.
  */
-int sk_convert_filter(struct sock_filter *prog, int len,
-		      struct bpf_insn *new_prog, int *new_len)
+int bpf_convert_filter(struct sock_filter *prog, int len,
+		       struct bpf_insn *new_prog, int *new_len)
 {
 	int new_flen = 0, pass = 0, target, i;
 	struct bpf_insn *new_insn;
@@ -721,7 +721,7 @@ static bool chk_code_allowed(u16 code_to_probe)
 }
 
 /**
- *	sk_chk_filter - verify socket filter code
+ *	bpf_check_classic - verify socket filter code
  *	@filter: filter to verify
  *	@flen: length of filter
  *
@@ -734,7 +734,7 @@ static bool chk_code_allowed(u16 code_to_probe)
  *
  * Returns 0 if the rule set is legal or -EINVAL if not.
  */
-int sk_chk_filter(const struct sock_filter *filter, unsigned int flen)
+int bpf_check_classic(const struct sock_filter *filter, unsigned int flen)
 {
 	bool anc_found;
 	int pc;
@@ -808,12 +808,14 @@ int sk_chk_filter(const struct sock_filter *filter, unsigned int flen)
 
 	return -EINVAL;
 }
-EXPORT_SYMBOL(sk_chk_filter);
+EXPORT_SYMBOL(bpf_check_classic);
 
-static int sk_store_orig_filter(struct sk_filter *fp,
-				const struct sock_fprog *fprog)
+#define bpf_classic_proglen(fprog) (fprog->len * sizeof(fprog->filter[0]))
+
+static int bpf_prog_store_orig_filter(struct bpf_prog *fp,
+				      const struct sock_fprog *fprog)
 {
-	unsigned int fsize = sk_filter_proglen(fprog);
+	unsigned int fsize = bpf_classic_proglen(fprog);
 	struct sock_fprog_kern *fkprog;
 
 	fp->orig_prog = kmalloc(sizeof(*fkprog), GFP_KERNEL);
@@ -831,7 +833,7 @@ static int sk_store_orig_filter(struct sk_filter *fp,
 	return 0;
 }
 
-static void sk_release_orig_filter(struct sk_filter *fp)
+static void bpf_release_orig_filter(struct bpf_prog *fp)
 {
 	struct sock_fprog_kern *fprog = fp->orig_prog;
 
@@ -841,6 +843,20 @@ static void sk_release_orig_filter(struct sk_filter *fp)
 	}
 }
 
+static void __sk_filter_bpf_release(struct sk_filter *skf)
+{
+	bpf_release_orig_filter(skf->prog);
+	bpf_prog_free(skf->prog);
+}
+
+static void bpf_prog_release_rcu(struct rcu_head *rcu)
+{
+	struct bpf_prog *prog = container_of(rcu, struct bpf_prog, rcu);
+
+	bpf_release_orig_filter(prog);
+	bpf_prog_free(prog);
+}
+
 /**
  * 	sk_filter_release_rcu - Release a socket filter by rcu_head
  *	@rcu: rcu_head that contains the sk_filter to free
@@ -849,8 +865,9 @@ static void sk_filter_release_rcu(struct rcu_head *rcu)
 {
 	struct sk_filter *fp = container_of(rcu, struct sk_filter, rcu);
 
-	sk_release_orig_filter(fp);
-	sk_filter_free(fp);
+	if (fp->release)
+		fp->release(fp);
+	kfree(fp);
 }
 
 /**
@@ -867,44 +884,25 @@ static void sk_filter_release(struct sk_filter *fp)
 
 void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp)
 {
-	atomic_sub(sk_filter_size(fp->len), &sk->sk_omem_alloc);
+	atomic_sub(fp->filter_size, &sk->sk_omem_alloc);
 	sk_filter_release(fp);
 }
 
-void sk_filter_charge(struct sock *sk, struct sk_filter *fp)
-{
-	atomic_inc(&fp->refcnt);
-	atomic_add(sk_filter_size(fp->len), &sk->sk_omem_alloc);
-}
-
-static struct sk_filter *__sk_migrate_realloc(struct sk_filter *fp,
-					      struct sock *sk,
-					      unsigned int len)
+bool sk_filter_charge(struct sock *sk, struct sk_filter *fp)
 {
-	struct sk_filter *fp_new;
-
-	if (sk == NULL)
-		return krealloc(fp, len, GFP_KERNEL);
-
-	fp_new = sock_kmalloc(sk, len, GFP_KERNEL);
-	if (fp_new) {
-		*fp_new = *fp;
-		/* As we're keeping orig_prog in fp_new along,
-		 * we need to make sure we're not evicting it
-		 * from the old fp.
-		 */
-		fp->orig_prog = NULL;
-		sk_filter_uncharge(sk, fp);
+	if (fp->filter_size <= sysctl_optmem_max &&
+	    atomic_read(&sk->sk_omem_alloc) + fp->filter_size < sysctl_optmem_max) {
+		atomic_inc(&fp->refcnt);
+		atomic_add(fp->filter_size, &sk->sk_omem_alloc);
+		return true;
 	}
-
-	return fp_new;
+	return false;
 }
 
-static struct sk_filter *__sk_migrate_filter(struct sk_filter *fp,
-					     struct sock *sk)
+static struct bpf_prog *__bpf_migrate_filter(struct bpf_prog *fp)
 {
 	struct sock_filter *old_prog;
-	struct sk_filter *old_fp;
+	struct bpf_prog *old_fp;
 	int err, new_len, old_len = fp->len;
 
 	/* We are free to overwrite insns et al right here as it
@@ -927,13 +925,13 @@ static struct sk_filter *__sk_migrate_filter(struct sk_filter *fp,
 	}
 
 	/* 1st pass: calculate the new program length. */
-	err = sk_convert_filter(old_prog, old_len, NULL, &new_len);
+	err = bpf_convert_filter(old_prog, old_len, NULL, &new_len);
 	if (err)
 		goto out_err_free;
 
 	/* Expand fp for appending the new filter representation. */
 	old_fp = fp;
-	fp = __sk_migrate_realloc(old_fp, sk, sk_filter_size(new_len));
+	fp = krealloc(old_fp, bpf_prog_size(new_len), GFP_KERNEL);
 	if (!fp) {
 		/* The old_fp is still around in case we couldn't
 		 * allocate new memory, so uncharge on that one.
@@ -946,16 +944,16 @@ static struct sk_filter *__sk_migrate_filter(struct sk_filter *fp,
 	fp->len = new_len;
 
 	/* 2nd pass: remap sock_filter insns into bpf_insn insns. */
-	err = sk_convert_filter(old_prog, old_len, fp->insnsi, &new_len);
+	err = bpf_convert_filter(old_prog, old_len, fp->insnsi, &new_len);
 	if (err)
-		/* 2nd sk_convert_filter() can fail only if it fails
+		/* 2nd bpf_convert_filter() can fail only if it fails
 		 * to allocate memory, remapping must succeed. Note,
 		 * that at this time old_fp has already been released
-		 * by __sk_migrate_realloc().
+		 * by krealloc().
 		 */
 		goto out_err_free;
 
-	sk_filter_select_runtime(fp);
+	bpf_prog_select_runtime(fp);
 
 	kfree(old_prog);
 	return fp;
@@ -963,28 +961,20 @@ static struct sk_filter *__sk_migrate_filter(struct sk_filter *fp,
 out_err_free:
 	kfree(old_prog);
 out_err:
-	/* Rollback filter setup. */
-	if (sk != NULL)
-		sk_filter_uncharge(sk, fp);
-	else
-		kfree(fp);
+	kfree(fp);
 	return ERR_PTR(err);
 }
 
-static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp,
-					     struct sock *sk)
+static struct bpf_prog *__bpf_prepare_filter(struct bpf_prog *fp)
 {
 	int err;
 
 	fp->bpf_func = NULL;
 	fp->jited = 0;
 
-	err = sk_chk_filter(fp->insns, fp->len);
+	err = bpf_check_classic(fp->insns, fp->len);
 	if (err) {
-		if (sk != NULL)
-			sk_filter_uncharge(sk, fp);
-		else
-			kfree(fp);
+		kfree(fp);
 		return ERR_PTR(err);
 	}
 
@@ -997,13 +987,13 @@ static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp,
 	 * internal BPF translation for the optimized interpreter.
 	 */
 	if (!fp->jited)
-		fp = __sk_migrate_filter(fp, sk);
+		fp = __bpf_migrate_filter(fp);
 
 	return fp;
 }
 
 /**
- *	sk_unattached_filter_create - create an unattached filter
+ *	bpf_prog_create - create an unattached filter
  *	@pfp: the unattached filter that is created
  *	@fprog: the filter program
  *
@@ -1012,23 +1002,21 @@ static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp,
  * If an error occurs or there is insufficient memory for the filter
  * a negative errno code is returned. On success the return is zero.
  */
-int sk_unattached_filter_create(struct sk_filter **pfp,
-				struct sock_fprog_kern *fprog)
+int bpf_prog_create(struct bpf_prog **pfp, struct sock_fprog_kern *fprog)
 {
-	unsigned int fsize = sk_filter_proglen(fprog);
-	struct sk_filter *fp;
+	unsigned int fsize = bpf_classic_proglen(fprog);
+	struct bpf_prog *fp;
 
 	/* Make sure new filter is there and in the right amounts. */
 	if (fprog->filter == NULL)
 		return -EINVAL;
 
-	fp = kmalloc(sk_filter_size(fprog->len), GFP_KERNEL);
+	fp = kmalloc(bpf_prog_size(fprog->len), GFP_KERNEL);
 	if (!fp)
 		return -ENOMEM;
 
 	memcpy(fp->insns, fprog->filter, fsize);
 
-	atomic_set(&fp->refcnt, 1);
 	fp->len = fprog->len;
 	/* Since unattached filters are not copied back to user
 	 * space through sk_get_filter(), we do not need to hold
@@ -1036,23 +1024,44 @@ int sk_unattached_filter_create(struct sk_filter **pfp,
 	 */
 	fp->orig_prog = NULL;
 
-	/* __sk_prepare_filter() already takes care of uncharging
+	/* __bpf_prepare_filter() already takes care of freeing
 	 * memory in case something goes wrong.
 	 */
-	fp = __sk_prepare_filter(fp, NULL);
+	fp = __bpf_prepare_filter(fp);
 	if (IS_ERR(fp))
 		return PTR_ERR(fp);
 
 	*pfp = fp;
 	return 0;
 }
-EXPORT_SYMBOL_GPL(sk_unattached_filter_create);
+EXPORT_SYMBOL_GPL(bpf_prog_create);
 
-void sk_unattached_filter_destroy(struct sk_filter *fp)
+void bpf_prog_destroy(struct bpf_prog *fp)
 {
-	sk_filter_release(fp);
+	call_rcu(&fp->rcu, bpf_prog_release_rcu);
+}
+EXPORT_SYMBOL_GPL(bpf_prog_destroy);
+
+static int __sk_filter_bpf_get_filter(struct sk_filter *fp, void **prog,
+				      unsigned int *len)
+{
+	struct sock_fprog_kern *fprog;
+
+	fprog = fp->prog->orig_prog;
+
+	if (!fprog)
+		return -EINVAL;
+
+	*len = fprog->len * sizeof(fprog->filter[0]);
+	*prog = fprog;
+	return 0;
+}
+
+static unsigned int __sk_filter_bpf_run(const struct sk_buff *skb,
+					struct sk_filter *fp)
+{
+	return BPF_PROG_RUN(fp->prog, skb);
 }
-EXPORT_SYMBOL_GPL(sk_unattached_filter_destroy);
 
 /**
  *	sk_attach_filter - attach a socket filter
@@ -1067,8 +1076,9 @@ EXPORT_SYMBOL_GPL(sk_unattached_filter_destroy);
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 {
 	struct sk_filter *fp, *old_fp;
-	unsigned int fsize = sk_filter_proglen(fprog);
-	unsigned int sk_fsize = sk_filter_size(fprog->len);
+	unsigned int fsize = bpf_classic_proglen(fprog);
+	unsigned int bpf_fsize = bpf_prog_size(fprog->len);
+	struct bpf_prog *prog;
 	int err;
 
 	if (sock_flag(sk, SOCK_FILTER_LOCKED))
@@ -1078,30 +1088,48 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 	if (fprog->filter == NULL)
 		return -EINVAL;
 
-	fp = sock_kmalloc(sk, sk_fsize, GFP_KERNEL);
-	if (!fp)
+	prog = kmalloc(bpf_fsize, GFP_KERNEL);
+	if (!prog)
 		return -ENOMEM;
 
-	if (copy_from_user(fp->insns, fprog->filter, fsize)) {
-		sock_kfree_s(sk, fp, sk_fsize);
+	if (copy_from_user(prog->insns, fprog->filter, fsize)) {
+		kfree(prog);
 		return -EFAULT;
 	}
 
-	atomic_set(&fp->refcnt, 1);
-	fp->len = fprog->len;
+	prog->len = fprog->len;
 
-	err = sk_store_orig_filter(fp, fprog);
+	err = bpf_prog_store_orig_filter(prog, fprog);
 	if (err) {
-		sk_filter_uncharge(sk, fp);
+		kfree(prog);
 		return -ENOMEM;
 	}
 
-	/* __sk_prepare_filter() already takes care of uncharging
+	/* __bpf_prepare_filter() already takes care of freeing
 	 * memory in case something goes wrong.
 	 */
-	fp = __sk_prepare_filter(fp, sk);
-	if (IS_ERR(fp))
-		return PTR_ERR(fp);
+	prog = __bpf_prepare_filter(prog);
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	fp = kmalloc(sizeof(*fp), GFP_KERNEL);
+	if (!fp) {
+		bpf_prog_destroy(prog);
+		return -ENOMEM;
+	}
+	fp->prog = prog;
+	fp->release = __sk_filter_bpf_release;
+	fp->run = __sk_filter_bpf_run;
+	fp->get_filter = __sk_filter_bpf_get_filter;
+	fp->filter_size = bpf_prog_size(prog->len);
+	atomic_set(&fp->refcnt, 0);
+
+	if (!sk_filter_charge(sk, fp)) {
+		/* socket doesn't have enough room for the program */
+		bpf_prog_destroy(prog);
+		kfree(fp);
+		return -ENOMEM;
+	}
 
 	old_fp = rcu_dereference_protected(sk->sk_filter,
 					   sock_owned_by_user(sk));
@@ -1134,12 +1162,12 @@ int sk_detach_filter(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(sk_detach_filter);
 
-int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf,
-		  unsigned int len)
+int sk_get_filter(struct sock *sk, char __user *ubuf, unsigned int ulen)
 {
-	struct sock_fprog_kern *fprog;
 	struct sk_filter *filter;
 	int ret = 0;
+	void *prog;
+	unsigned int prog_len;
 
 	lock_sock(sk);
 	filter = rcu_dereference_protected(sk->sk_filter,
@@ -1147,28 +1175,28 @@ int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf,
 	if (!filter)
 		goto out;
 
-	/* We're copying the filter that has been originally attached,
-	 * so no conversion/decode needed anymore.
-	 */
-	fprog = filter->orig_prog;
+	ret = filter->get_filter(filter, &prog, &prog_len);
+	if (ret)
+		goto out;
 
-	ret = fprog->len;
-	if (!len)
+	ret = prog_len / sizeof(struct sock_filter);
+	if (!ulen)
 		/* User space only enquires number of filter blocks. */
 		goto out;
 
 	ret = -EINVAL;
-	if (len < fprog->len)
+	if (ulen < prog_len)
 		goto out;
 
 	ret = -EFAULT;
-	if (copy_to_user(ubuf, fprog->filter, sk_filter_proglen(fprog)))
+	if (copy_to_user(ubuf, prog, prog_len))
 		goto out;
 
 	/* Instead of bytes, the API requests to return the number
 	 * of filter blocks.
 	 */
-	ret = fprog->len;
+	ret = prog_len / sizeof(struct sock_filter);
+
 out:
 	release_sock(sk);
 	return ret;
diff --git a/net/core/ptp_classifier.c b/net/core/ptp_classifier.c
index 12ab7b4be609..4eab4a94a59d 100644
--- a/net/core/ptp_classifier.c
+++ b/net/core/ptp_classifier.c
@@ -107,11 +107,11 @@
 #include <linux/filter.h>
 #include <linux/ptp_classify.h>
 
-static struct sk_filter *ptp_insns __read_mostly;
+static struct bpf_prog *ptp_insns __read_mostly;
 
 unsigned int ptp_classify_raw(const struct sk_buff *skb)
 {
-	return SK_RUN_FILTER(ptp_insns, skb);
+	return BPF_PROG_RUN(ptp_insns, skb);
 }
 EXPORT_SYMBOL_GPL(ptp_classify_raw);
 
@@ -189,5 +189,5 @@ void __init ptp_classifier_init(void)
 		.len = ARRAY_SIZE(ptp_filter), .filter = ptp_filter,
 	};
 
-	BUG_ON(sk_unattached_filter_create(&ptp_insns, &ptp_prog));
+	BUG_ON(bpf_prog_create(&ptp_insns, &ptp_prog));
 }
diff --git a/net/core/sock.c b/net/core/sock.c
index ca9b65199d28..574179f28ae5 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1206,7 +1206,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 		return sock_getbindtodevice(sk, optval, optlen, len);
 
 	case SO_GET_FILTER:
-		len = sk_get_filter(sk, (struct sock_filter __user *)optval, len);
+		len = sk_get_filter(sk, optval, len);
 		if (len < 0)
 			return len;
 
@@ -1478,6 +1478,7 @@ static void sk_update_clone(const struct sock *sk, struct sock *newsk)
 struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 {
 	struct sock *newsk;
+	bool is_charged = true;
 
 	newsk = sk_prot_alloc(sk->sk_prot, priority, sk->sk_family);
 	if (newsk != NULL) {
@@ -1522,9 +1523,9 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 
 		filter = rcu_dereference_protected(newsk->sk_filter, 1);
 		if (filter != NULL)
-			sk_filter_charge(newsk, filter);
+			is_charged = sk_filter_charge(newsk, filter);
 
-		if (unlikely(xfrm_sk_clone_policy(newsk))) {
+		if (!is_charged || unlikely(xfrm_sk_clone_policy(newsk))) {
 			/* It is still raw copy of parent, so invalidate
 			 * destructor and make plain sk_free() */
 			newsk->sk_destruct = NULL;
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index a4216a4c9572..0dc47dee525b 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -52,7 +52,7 @@ EXPORT_SYMBOL_GPL(sock_diag_put_meminfo);
 int sock_diag_put_filterinfo(bool may_report_filterinfo, struct sock *sk,
 			     struct sk_buff *skb, int attrtype)
 {
-	struct sock_fprog_kern *fprog;
+	void *prog;
 	struct sk_filter *filter;
 	struct nlattr *attr;
 	unsigned int flen;
@@ -68,8 +68,9 @@ int sock_diag_put_filterinfo(bool may_report_filterinfo, struct sock *sk,
 	if (!filter)
 		goto out;
 
-	fprog = filter->orig_prog;
-	flen = sk_filter_proglen(fprog);
+	err = filter->get_filter(filter, &prog, &flen);
+	if (err)
+		goto out;
 
 	attr = nla_reserve(skb, attrtype, flen);
 	if (attr == NULL) {
@@ -77,7 +78,7 @@ int sock_diag_put_filterinfo(bool may_report_filterinfo, struct sock *sk,
 		goto out;
 	}
 
-	memcpy(nla_data(attr), fprog->filter, flen);
+	memcpy(nla_data(attr), prog, flen);
 out:
 	rcu_read_unlock();
 	return err;
diff --git a/net/netfilter/xt_bpf.c b/net/netfilter/xt_bpf.c
index bbffdbdaf603..dffee9d47ec4 100644
--- a/net/netfilter/xt_bpf.c
+++ b/net/netfilter/xt_bpf.c
@@ -28,7 +28,7 @@ static int bpf_mt_check(const struct xt_mtchk_param *par)
 	program.len = info->bpf_program_num_elem;
 	program.filter = info->bpf_program;
 
-	if (sk_unattached_filter_create(&info->filter, &program)) {
+	if (bpf_prog_create(&info->filter, &program)) {
 		pr_info("bpf: check failed: parse error\n");
 		return -EINVAL;
 	}
@@ -40,13 +40,13 @@ static bool bpf_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_bpf_info *info = par->matchinfo;
 
-	return SK_RUN_FILTER(info->filter, skb);
+	return BPF_PROG_RUN(info->filter, skb);
 }
 
 static void bpf_mt_destroy(const struct xt_mtdtor_param *par)
 {
 	const struct xt_bpf_info *info = par->matchinfo;
-	sk_unattached_filter_destroy(info->filter);
+	bpf_prog_destroy(info->filter);
 }
 
 static struct xt_match bpf_mt_reg __read_mostly = {
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 13f64df2c710..0e30d58149da 100644
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
@@ -54,7 +54,7 @@ static int cls_bpf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	int ret;
 
 	list_for_each_entry(prog, &head->plist, link) {
-		int filter_res = SK_RUN_FILTER(prog->filter, skb);
+		int filter_res = BPF_PROG_RUN(prog->filter, skb);
 
 		if (filter_res == 0)
 			continue;
@@ -92,7 +92,7 @@ static void cls_bpf_delete_prog(struct tcf_proto *tp, struct cls_bpf_prog *prog)
 	tcf_unbind_filter(tp, &prog->res);
 	tcf_exts_destroy(tp, &prog->exts);
 
-	sk_unattached_filter_destroy(prog->filter);
+	bpf_prog_destroy(prog->filter);
 
 	kfree(prog->bpf_ops);
 	kfree(prog);
@@ -161,7 +161,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 	struct sock_filter *bpf_ops, *bpf_old;
 	struct tcf_exts exts;
 	struct sock_fprog_kern tmp;
-	struct sk_filter *fp, *fp_old;
+	struct bpf_prog *fp, *fp_old;
 	u16 bpf_size, bpf_len;
 	u32 classid;
 	int ret;
@@ -193,7 +193,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 	tmp.len = bpf_len;
 	tmp.filter = bpf_ops;
 
-	ret = sk_unattached_filter_create(&fp, &tmp);
+	ret = bpf_prog_create(&fp, &tmp);
 	if (ret)
 		goto errout_free;
 
@@ -211,7 +211,7 @@ static int cls_bpf_modify_existing(struct net *net, struct tcf_proto *tp,
 	tcf_exts_change(tp, &prog->exts, &exts);
 
 	if (fp_old)
-		sk_unattached_filter_destroy(fp_old);
+		bpf_prog_destroy(fp_old);
 	if (bpf_old)
 		kfree(bpf_old);
 
-- 
1.7.9.5
