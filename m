From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH RFC 2/9] net: filter: account filter length in bytes
Date: Tue, 11 Mar 2014 10:19:13 +0100
Message-ID: <1394529560-3490-3-git-send-email-pablo@netfilter.org>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, kaber@trash.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34658 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751688AbaCKJTi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2014 05:19:38 -0400
In-Reply-To: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts the len field in the struct sock_filter structure
from length in filter lines to bytes. I have added the new function
sk_bpf_flen() which allows you to obtain the filter in number of
blocks (which is what you usually need to iterate over a BPF filter).

The corresponding BPF jit implementation has been also adjusted.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 arch/arm/net/bpf_jit_32.c       |   19 ++++++++++---------
 arch/powerpc/net/bpf_jit_comp.c |    4 ++--
 arch/s390/net/bpf_jit_comp.c    |   10 +++++-----
 arch/sparc/net/bpf_jit_comp.c   |    2 +-
 arch/x86/net/bpf_jit_comp.c     |    2 +-
 include/linux/filter.h          |   10 ++++------
 include/net/sock.h              |    4 ++--
 net/core/filter.c               |   22 +++++++++++++++-------
 net/core/sock_diag.c            |    4 ++--
 9 files changed, 42 insertions(+), 35 deletions(-)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index 65bd347..844e97b 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -135,7 +135,7 @@ static u16 saved_regs(struct jit_ctx *ctx)
 {
 	u16 ret = 0;
 
-	if ((ctx->skf->len > 1) ||
+	if ((sk_bpf_flen(ctx->skf) > 1) ||
 	    (ctx->skf->insns[0].code == BPF_S_RET_A))
 		ret |= 1 << r_A;
 
@@ -283,7 +283,7 @@ static u16 imm_offset(u32 k, struct jit_ctx *ctx)
 		ctx->imms[i] = k;
 
 	/* constants go just after the epilogue */
-	offset =  ctx->offsets[ctx->skf->len];
+	offset =  ctx->offsets[sk_bpf_flen(ctx->skf)];
 	offset += ctx->prologue_bytes;
 	offset += ctx->epilogue_bytes;
 	offset += i * 4;
@@ -423,7 +423,7 @@ static inline void emit_err_ret(u8 cond, struct jit_ctx *ctx)
 		emit(ARM_MOV_R(ARM_R0, ARM_R0), ctx);
 	} else {
 		_emit(cond, ARM_MOV_I(ARM_R0, 0), ctx);
-		_emit(cond, ARM_B(b_imm(ctx->skf->len, ctx)), ctx);
+		_emit(cond, ARM_B(b_imm(sk_bpf_flen(ctx->skf), ctx)), ctx);
 	}
 }
 
@@ -476,10 +476,10 @@ static int build_body(struct jit_ctx *ctx)
 	const struct sk_filter *prog = ctx->skf;
 	const struct sock_filter *inst;
 	unsigned i, load_order, off, condt;
-	int imm12;
+	int imm12, flen = sk_bpf_flen(ctx->skf);
 	u32 k;
 
-	for (i = 0; i < prog->len; i++) {
+	for (i = 0; i < flen; i++) {
 		inst = &(prog->insns[i]);
 		/* K as an immediate value operand */
 		k = inst->k;
@@ -773,8 +773,8 @@ cmp_x:
 				ctx->ret0_fp_idx = i;
 			emit_mov_i(ARM_R0, k, ctx);
 b_epilogue:
-			if (i != ctx->skf->len - 1)
-				emit(ARM_B(b_imm(prog->len, ctx)), ctx);
+			if (i != flen - 1)
+				emit(ARM_B(b_imm(flen, ctx)), ctx);
 			break;
 		case BPF_S_MISC_TAX:
 			/* X = A */
@@ -867,6 +867,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 	struct jit_ctx ctx;
 	unsigned tmp_idx;
 	unsigned alloc_size;
+	int flen = sk_bpf_flen(fp);
 
 	if (!bpf_jit_enable)
 		return;
@@ -875,7 +876,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 	ctx.skf		= fp;
 	ctx.ret0_fp_idx = -1;
 
-	ctx.offsets = kzalloc(4 * (ctx.skf->len + 1), GFP_KERNEL);
+	ctx.offsets = kzalloc(4 * (flen + 1), GFP_KERNEL);
 	if (ctx.offsets == NULL)
 		return;
 
@@ -922,7 +923,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 
 	if (bpf_jit_enable > 1)
 		/* there are 2 passes here */
-		bpf_jit_dump(fp->len, alloc_size, 2, ctx.target);
+		bpf_jit_dump(flen, alloc_size, 2, ctx.target);
 
 	fp->run_filter = (void *)ctx.target;
 out:
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index 6491d72..a4d8db3 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -134,7 +134,7 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 			      unsigned int *addrs)
 {
 	const struct sock_filter *filter = fp->insns;
-	int flen = fp->len;
+	int flen = sk_bpf_flen(fp);
 	u8 *func;
 	unsigned int true_cond;
 	int i;
@@ -581,7 +581,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 	unsigned int *addrs;
 	struct codegen_context cgctx;
 	int pass;
-	int flen = fp->len;
+	int flen = sk_bpf_flen(fp);
 
 	if (!bpf_jit_enable)
 		return;
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 23089df..54906d9 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -826,11 +826,11 @@ void bpf_jit_compile(struct sk_filter *fp)
 	unsigned long size, prg_len, lit_len;
 	struct bpf_jit jit, cjit;
 	unsigned int *addrs;
-	int pass, i;
+	int pass, i, flen = sk_bpf_flen(fp);
 
 	if (!bpf_jit_enable)
 		return;
-	addrs = kcalloc(fp->len, sizeof(*addrs), GFP_KERNEL);
+	addrs = kcalloc(flen, sizeof(*addrs), GFP_KERNEL);
 	if (addrs == NULL)
 		return;
 	memset(&jit, 0, sizeof(cjit));
@@ -842,9 +842,9 @@ void bpf_jit_compile(struct sk_filter *fp)
 
 		bpf_jit_prologue(&jit);
 		bpf_jit_noleaks(&jit, fp->insns);
-		for (i = 0; i < fp->len; i++) {
+		for (i = 0; i < flen; i++) {
 			if (bpf_jit_insn(&jit, fp->insns + i, addrs, i,
-					 i == fp->len - 1))
+					 i == len - 1))
 				goto out;
 		}
 		bpf_jit_epilogue(&jit);
@@ -870,7 +870,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 		cjit = jit;
 	}
 	if (bpf_jit_enable > 1) {
-		bpf_jit_dump(fp->len, jit.end - jit.start, pass, jit.start);
+		bpf_jit_dump(flen, jit.end - jit.start, pass, jit.start);
 		if (jit.start)
 			print_fn_code(jit.start, jit.mid - jit.start);
 	}
diff --git a/arch/sparc/net/bpf_jit_comp.c b/arch/sparc/net/bpf_jit_comp.c
index ee1cd30..15e6b00 100644
--- a/arch/sparc/net/bpf_jit_comp.c
+++ b/arch/sparc/net/bpf_jit_comp.c
@@ -359,7 +359,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 	unsigned int cleanup_addr, proglen, oldproglen = 0;
 	u32 temp[8], *prog, *func, seen = 0, pass;
 	const struct sock_filter *filter = fp->insns;
-	int i, flen = fp->len, pc_ret0 = -1;
+	int i, flen = sk_bpf_flen(fp), pc_ret0 = -1;
 	unsigned int *addrs;
 	void *image;
 
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index bfadd14..81bf69a 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -193,7 +193,7 @@ void bpf_jit_compile(struct sk_filter *fp)
 	unsigned int cleanup_addr; /* epilogue code offset */
 	unsigned int *addrs;
 	const struct sock_filter *filter = fp->insns;
-	int flen = fp->len;
+	int flen = sk_bpf_flen(fp);
 
 	if (!bpf_jit_enable)
 		return;
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 6c5d597..ab37714 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -22,10 +22,9 @@ struct compat_sock_fprog {
 struct sk_buff;
 struct sock;
 
-struct sk_filter
-{
+struct sk_filter {
 	atomic_t		refcnt;
-	unsigned int         	len;	/* Number of filter blocks */
+	unsigned int		size;	/* filter bytecode size in bytes */
 	struct rcu_head		rcu;
 	unsigned int		(*run_filter)(const struct sk_buff *skb,
 					      const struct sock_filter *filter);
@@ -35,10 +34,9 @@ struct sk_filter
 	};
 };
 
-static inline unsigned int sk_filter_size(unsigned int proglen)
+static inline unsigned int sk_bpf_flen(struct sk_filter *filter)
 {
-	return max(sizeof(struct sk_filter),
-		   offsetof(struct sk_filter, insns[proglen]));
+	return filter->size / sizeof(struct sock_filter);
 }
 
 extern int sk_filter(struct sock *sk, struct sk_buff *skb);
diff --git a/include/net/sock.h b/include/net/sock.h
index 5c3f7c3..7b9723c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1633,14 +1633,14 @@ static inline void sk_filter_release(struct sk_filter *fp)
 
 static inline void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp)
 {
-	atomic_sub(sk_filter_size(fp->len), &sk->sk_omem_alloc);
+	atomic_sub(fp->size, &sk->sk_omem_alloc);
 	sk_filter_release(fp);
 }
 
 static inline void sk_filter_charge(struct sock *sk, struct sk_filter *fp)
 {
 	atomic_inc(&fp->refcnt);
-	atomic_add(sk_filter_size(fp->len), &sk->sk_omem_alloc);
+	atomic_add(fp->size, &sk->sk_omem_alloc);
 }
 
 /*
diff --git a/net/core/filter.c b/net/core/filter.c
index 0f63e67..3ea0e7f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -647,7 +647,7 @@ static int __sk_prepare_filter(struct sk_filter *fp)
 
 	fp->run_filter = sk_run_filter;
 
-	err = sk_chk_filter(fp->insns, fp->len);
+	err = sk_chk_filter(fp->insns, sk_bpf_flen(fp));
 	if (err)
 		return err;
 
@@ -655,6 +655,12 @@ static int __sk_prepare_filter(struct sk_filter *fp)
 	return 0;
 }
 
+static unsigned int sk_filter_size(unsigned int proglen)
+{
+	return max(sizeof(struct sk_filter),
+		   offsetof(struct sk_filter, insns[proglen]));
+}
+
 /**
  *	sk_unattached_filter_create - create an unattached filter
  *	@fprog: the filter program
@@ -682,7 +688,7 @@ int sk_unattached_filter_create(struct sk_filter **pfp,
 	memcpy(fp->insns, fprog->filter, fsize);
 
 	atomic_set(&fp->refcnt, 1);
-	fp->len = fprog->len;
+	fp->size = fsize;
 
 	err = __sk_prepare_filter(fp);
 	if (err)
@@ -735,7 +741,7 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 	}
 
 	atomic_set(&fp->refcnt, 1);
-	fp->len = fprog->len;
+	fp->size = fsize;
 
 	err = __sk_prepare_filter(fp);
 	if (err) {
@@ -853,6 +859,7 @@ void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to)
 int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf, unsigned int len)
 {
 	struct sk_filter *filter;
+	unsigned int flen;
 	int i, ret;
 
 	lock_sock(sk);
@@ -861,15 +868,16 @@ int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf, unsigned int
 	ret = 0;
 	if (!filter)
 		goto out;
-	ret = filter->len;
+
+	ret = flen = sk_bpf_flen(filter);
 	if (!len)
 		goto out;
 	ret = -EINVAL;
-	if (len < filter->len)
+	if (len < flen)
 		goto out;
 
 	ret = -EFAULT;
-	for (i = 0; i < filter->len; i++) {
+	for (i = 0; i < flen; i++) {
 		struct sock_filter fb;
 
 		sk_decode_filter(&filter->insns[i], &fb);
@@ -877,7 +885,7 @@ int sk_get_filter(struct sock *sk, struct sock_filter __user *ubuf, unsigned int
 			goto out;
 	}
 
-	ret = filter->len;
+	ret = flen;
 out:
 	release_sock(sk);
 	return ret;
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index a0e9cf6..343bd58 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -65,7 +65,7 @@ int sock_diag_put_filterinfo(struct user_namespace *user_ns, struct sock *sk,
 	rcu_read_lock();
 
 	filter = rcu_dereference(sk->sk_filter);
-	len = filter ? filter->len * sizeof(struct sock_filter) : 0;
+	len = filter ? filter->size : 0;
 
 	attr = nla_reserve(skb, attrtype, len);
 	if (attr == NULL) {
@@ -77,7 +77,7 @@ int sock_diag_put_filterinfo(struct user_namespace *user_ns, struct sock *sk,
 		struct sock_filter *fb = (struct sock_filter *)nla_data(attr);
 		int i;
 
-		for (i = 0; i < filter->len; i++, fb++)
+		for (i = 0; i < sk_bpf_flen(filter); i++, fb++)
 			sk_decode_filter(&filter->insns[i], fb);
 	}
 
-- 
1.7.10.4
