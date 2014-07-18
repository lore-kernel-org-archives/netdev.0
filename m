From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH RFC v2 net-next 03/16] net: filter: rename struct sock_filter_int into bpf_insn
Date: Thu, 17 Jul 2014 21:19:53 -0700
Message-ID: <1405657206-12060-4-git-send-email-ast@plumgrid.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

follow on patch exposes eBPF to user space and 'sock_filter_int' name
no longer makes sense, so rename it to 'bpf_insn'

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/x86/net/bpf_jit_comp.c |    2 +-
 include/linux/filter.h      |   50 +++++++++++++++++++++----------------------
 kernel/bpf/core.c           |    2 +-
 kernel/seccomp.c            |    2 +-
 lib/test_bpf.c              |    4 ++--
 net/core/filter.c           |   18 ++++++++--------
 6 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 99bef86ed6df..71737a83f022 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -214,7 +214,7 @@ struct jit_context {
 static int do_jit(struct sk_filter *bpf_prog, int *addrs, u8 *image,
 		  int oldproglen, struct jit_context *ctx)
 {
-	struct sock_filter_int *insn = bpf_prog->insnsi;
+	struct bpf_insn *insn = bpf_prog->insnsi;
 	int insn_cnt = bpf_prog->len;
 	u8 temp[64];
 	int i;
diff --git a/include/linux/filter.h b/include/linux/filter.h
index c43c8258e682..a3287d1c9a56 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -82,7 +82,7 @@ enum {
 /* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
 
 #define BPF_ALU64_REG(OP, DST, SRC)				\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_ALU64 | BPF_OP(OP) | BPF_X,	\
 		.dst_reg = DST,					\
 		.src_reg = SRC,					\
@@ -90,7 +90,7 @@ enum {
 		.imm   = 0 })
 
 #define BPF_ALU32_REG(OP, DST, SRC)				\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_ALU | BPF_OP(OP) | BPF_X,		\
 		.dst_reg = DST,					\
 		.src_reg = SRC,					\
@@ -100,7 +100,7 @@ enum {
 /* ALU ops on immediates, bpf_add|sub|...: dst_reg += imm32 */
 
 #define BPF_ALU64_IMM(OP, DST, IMM)				\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_ALU64 | BPF_OP(OP) | BPF_K,	\
 		.dst_reg = DST,					\
 		.src_reg = 0,					\
@@ -108,7 +108,7 @@ enum {
 		.imm   = IMM })
 
 #define BPF_ALU32_IMM(OP, DST, IMM)				\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_ALU | BPF_OP(OP) | BPF_K,		\
 		.dst_reg = DST,					\
 		.src_reg = 0,					\
@@ -118,7 +118,7 @@ enum {
 /* Endianess conversion, cpu_to_{l,b}e(), {l,b}e_to_cpu() */
 
 #define BPF_ENDIAN(TYPE, DST, LEN)				\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_ALU | BPF_END | BPF_SRC(TYPE),	\
 		.dst_reg = DST,					\
 		.src_reg = 0,					\
@@ -128,7 +128,7 @@ enum {
 /* Short form of mov, dst_reg = src_reg */
 
 #define BPF_MOV64_REG(DST, SRC)					\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_ALU64 | BPF_MOV | BPF_X,		\
 		.dst_reg = DST,					\
 		.src_reg = SRC,					\
@@ -136,7 +136,7 @@ enum {
 		.imm   = 0 })
 
 #define BPF_MOV32_REG(DST, SRC)					\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_ALU | BPF_MOV | BPF_X,		\
 		.dst_reg = DST,					\
 		.src_reg = SRC,					\
@@ -146,7 +146,7 @@ enum {
 /* Short form of mov, dst_reg = imm32 */
 
 #define BPF_MOV64_IMM(DST, IMM)					\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_ALU64 | BPF_MOV | BPF_K,		\
 		.dst_reg = DST,					\
 		.src_reg = 0,					\
@@ -154,7 +154,7 @@ enum {
 		.imm   = IMM })
 
 #define BPF_MOV32_IMM(DST, IMM)					\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_ALU | BPF_MOV | BPF_K,		\
 		.dst_reg = DST,					\
 		.src_reg = 0,					\
@@ -164,7 +164,7 @@ enum {
 /* Short form of mov based on type, BPF_X: dst_reg = src_reg, BPF_K: dst_reg = imm32 */
 
 #define BPF_MOV64_RAW(TYPE, DST, SRC, IMM)			\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_ALU64 | BPF_MOV | BPF_SRC(TYPE),	\
 		.dst_reg = DST,					\
 		.src_reg = SRC,					\
@@ -172,7 +172,7 @@ enum {
 		.imm   = IMM })
 
 #define BPF_MOV32_RAW(TYPE, DST, SRC, IMM)			\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_ALU | BPF_MOV | BPF_SRC(TYPE),	\
 		.dst_reg = DST,					\
 		.src_reg = SRC,					\
@@ -182,7 +182,7 @@ enum {
 /* Direct packet access, R0 = *(uint *) (skb->data + imm32) */
 
 #define BPF_LD_ABS(SIZE, IMM)					\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_LD | BPF_SIZE(SIZE) | BPF_ABS,	\
 		.dst_reg = 0,					\
 		.src_reg = 0,					\
@@ -192,7 +192,7 @@ enum {
 /* Indirect packet access, R0 = *(uint *) (skb->data + src_reg + imm32) */
 
 #define BPF_LD_IND(SIZE, SRC, IMM)				\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_LD | BPF_SIZE(SIZE) | BPF_IND,	\
 		.dst_reg = 0,					\
 		.src_reg = SRC,					\
@@ -202,7 +202,7 @@ enum {
 /* Memory load, dst_reg = *(uint *) (src_reg + off16) */
 
 #define BPF_LDX_MEM(SIZE, DST, SRC, OFF)			\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_LDX | BPF_SIZE(SIZE) | BPF_MEM,	\
 		.dst_reg = DST,					\
 		.src_reg = SRC,					\
@@ -212,7 +212,7 @@ enum {
 /* Memory store, *(uint *) (dst_reg + off16) = src_reg */
 
 #define BPF_STX_MEM(SIZE, DST, SRC, OFF)			\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_STX | BPF_SIZE(SIZE) | BPF_MEM,	\
 		.dst_reg = DST,					\
 		.src_reg = SRC,					\
@@ -222,7 +222,7 @@ enum {
 /* Memory store, *(uint *) (dst_reg + off16) = imm32 */
 
 #define BPF_ST_MEM(SIZE, DST, OFF, IMM)				\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_ST | BPF_SIZE(SIZE) | BPF_MEM,	\
 		.dst_reg = DST,					\
 		.src_reg = 0,					\
@@ -232,7 +232,7 @@ enum {
 /* Conditional jumps against registers, if (dst_reg 'op' src_reg) goto pc + off16 */
 
 #define BPF_JMP_REG(OP, DST, SRC, OFF)				\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_JMP | BPF_OP(OP) | BPF_X,		\
 		.dst_reg = DST,					\
 		.src_reg = SRC,					\
@@ -242,7 +242,7 @@ enum {
 /* Conditional jumps against immediates, if (dst_reg 'op' imm32) goto pc + off16 */
 
 #define BPF_JMP_IMM(OP, DST, IMM, OFF)				\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_JMP | BPF_OP(OP) | BPF_K,		\
 		.dst_reg = DST,					\
 		.src_reg = 0,					\
@@ -252,7 +252,7 @@ enum {
 /* Function call */
 
 #define BPF_EMIT_CALL(FUNC)					\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_JMP | BPF_CALL,			\
 		.dst_reg = 0,					\
 		.src_reg = 0,					\
@@ -262,7 +262,7 @@ enum {
 /* Raw code statement block */
 
 #define BPF_RAW_INSN(CODE, DST, SRC, OFF, IMM)			\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = CODE,					\
 		.dst_reg = DST,					\
 		.src_reg = SRC,					\
@@ -272,7 +272,7 @@ enum {
 /* Program exit */
 
 #define BPF_EXIT_INSN()						\
-	((struct sock_filter_int) {				\
+	((struct bpf_insn) {				\
 		.code  = BPF_JMP | BPF_EXIT,			\
 		.dst_reg = 0,					\
 		.src_reg = 0,					\
@@ -298,7 +298,7 @@ enum {
 /* Macro to invoke filter function. */
 #define SK_RUN_FILTER(filter, ctx)  (*filter->bpf_func)(ctx, filter->insnsi)
 
-struct sock_filter_int {
+struct bpf_insn {
 	__u8	code;		/* opcode */
 	__u8	dst_reg:4;	/* dest register */
 	__u8	src_reg:4;	/* source register */
@@ -330,10 +330,10 @@ struct sk_filter {
 	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
 	struct rcu_head		rcu;
 	unsigned int		(*bpf_func)(const struct sk_buff *skb,
-					    const struct sock_filter_int *filter);
+					    const struct bpf_insn *filter);
 	union {
 		struct sock_filter	insns[0];
-		struct sock_filter_int	insnsi[0];
+		struct bpf_insn	insnsi[0];
 		struct work_struct	work;
 	};
 };
@@ -353,7 +353,7 @@ void sk_filter_select_runtime(struct sk_filter *fp);
 void sk_filter_free(struct sk_filter *fp);
 
 int sk_convert_filter(struct sock_filter *prog, int len,
-		      struct sock_filter_int *new_prog, int *new_len);
+		      struct bpf_insn *new_prog, int *new_len);
 
 int sk_unattached_filter_create(struct sk_filter **pfp,
 				struct sock_fprog_kern *fprog);
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 77a240a1ce11..265a02cc822d 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -81,7 +81,7 @@ noinline u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
  * keep, 0 for none. @ctx is the data we are operating on, @insn is the
  * array of filter instructions.
  */
-static unsigned int __sk_run_filter(void *ctx, const struct sock_filter_int *insn)
+static unsigned int __sk_run_filter(void *ctx, const struct bpf_insn *insn)
 {
 	u64 stack[MAX_BPF_STACK / sizeof(u64)];
 	u64 regs[MAX_BPF_REG], tmp;
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 301bbc24739c..565743db5384 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -248,7 +248,7 @@ static long seccomp_attach_filter(struct sock_fprog *fprog)
 	if (ret)
 		goto free_prog;
 
-	/* Convert 'sock_filter' insns to 'sock_filter_int' insns */
+	/* Convert 'sock_filter' insns to 'bpf_insn' insns */
 	ret = sk_convert_filter(fp, fprog->len, NULL, &new_len);
 	if (ret)
 		goto free_prog;
diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index c579e0f58818..5f48623ee1a7 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -66,7 +66,7 @@ struct bpf_test {
 	const char *descr;
 	union {
 		struct sock_filter insns[MAX_INSNS];
-		struct sock_filter_int insns_int[MAX_INSNS];
+		struct bpf_insn insns_int[MAX_INSNS];
 	} u;
 	__u8 aux;
 	__u8 data[MAX_DATA];
@@ -1807,7 +1807,7 @@ static struct sk_filter *generate_filter(int which, int *err)
 
 		fp->len = flen;
 		memcpy(fp->insnsi, tests[which].u.insns_int,
-		       fp->len * sizeof(struct sock_filter_int));
+		       fp->len * sizeof(struct bpf_insn));
 
 		sk_filter_select_runtime(fp);
 		break;
diff --git a/net/core/filter.c b/net/core/filter.c
index 1d0e9492e4fa..f3b2d5e9fe5f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -174,9 +174,9 @@ static u64 __get_random_u32(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 }
 
 static bool convert_bpf_extensions(struct sock_filter *fp,
-				   struct sock_filter_int **insnp)
+				   struct bpf_insn **insnp)
 {
-	struct sock_filter_int *insn = *insnp;
+	struct bpf_insn *insn = *insnp;
 
 	switch (fp->k) {
 	case SKF_AD_OFF + SKF_AD_PROTOCOL:
@@ -326,7 +326,7 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
  *
  * 2) 2nd pass to remap in two passes: 1st pass finds new
  *    jump offsets, 2nd pass remapping:
- *   new_prog = kmalloc(sizeof(struct sock_filter_int) * new_len);
+ *   new_prog = kmalloc(sizeof(struct bpf_insn) * new_len);
  *   sk_convert_filter(old_prog, old_len, new_prog, &new_len);
  *
  * User BPF's register A is mapped to our BPF register 6, user BPF
@@ -336,10 +336,10 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
  * ctx == 'struct seccomp_data *'.
  */
 int sk_convert_filter(struct sock_filter *prog, int len,
-		      struct sock_filter_int *new_prog, int *new_len)
+		      struct bpf_insn *new_prog, int *new_len)
 {
 	int new_flen = 0, pass = 0, target, i;
-	struct sock_filter_int *new_insn;
+	struct bpf_insn *new_insn;
 	struct sock_filter *fp;
 	int *addrs = NULL;
 	u8 bpf_src;
@@ -365,8 +365,8 @@ do_pass:
 	new_insn++;
 
 	for (i = 0; i < len; fp++, i++) {
-		struct sock_filter_int tmp_insns[6] = { };
-		struct sock_filter_int *insn = tmp_insns;
+		struct bpf_insn tmp_insns[6] = { };
+		struct bpf_insn *insn = tmp_insns;
 
 		if (addrs)
 			addrs[i] = new_insn - new_prog;
@@ -913,7 +913,7 @@ static struct sk_filter *__sk_migrate_filter(struct sk_filter *fp,
 	 * representation.
 	 */
 	BUILD_BUG_ON(sizeof(struct sock_filter) !=
-		     sizeof(struct sock_filter_int));
+		     sizeof(struct bpf_insn));
 
 	/* Conversion cannot happen on overlapping memory areas,
 	 * so we need to keep the user BPF around until the 2nd
@@ -945,7 +945,7 @@ static struct sk_filter *__sk_migrate_filter(struct sk_filter *fp,
 
 	fp->len = new_len;
 
-	/* 2nd pass: remap sock_filter insns into sock_filter_int insns. */
+	/* 2nd pass: remap sock_filter insns into bpf_insn insns. */
 	err = sk_convert_filter(old_prog, old_len, fp->insnsi, &new_len);
 	if (err)
 		/* 2nd sk_convert_filter() can fail only if it fails
-- 
1.7.9.5
