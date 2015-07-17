From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 1/2] bpf: introduce bpf_skb_vlan_push/pop() helpers
Date: Thu, 16 Jul 2015 19:58:03 -0700
Message-ID: <1437101884-2081-2-git-send-email-ast@plumgrid.com>
References: <1437101884-2081-1-git-send-email-ast@plumgrid.com>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35520 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbbGQC6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 22:58:11 -0400
Received: by pactm7 with SMTP id tm7so53182400pac.2
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 19:58:10 -0700 (PDT)
In-Reply-To: <1437101884-2081-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to let eBPF programs call skb_vlan_push/pop via helper functions
eBPF JITs need to recognize helpers that change skb->data, since
skb->data and hlen are cached as part of JIT code generation.
- arm64 JIT is using bpf_load_pointer() without caching, so it's ok as-is.
- x64 JIT recognizes bpf_skb_vlan_push/pop() calls and re-caches skb->data/hlen
  after such calls (experiments showed that conditional re-caching is slower).
- s390 JIT falls back to interpreter for now when bpf_skb_vlan_push() is present
  in the program (re-caching is tbd).

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
with these helpers the phys2virt gateway I showed at nfws can be done
in scalable way without creating a ton of vlan netdevs.

 arch/s390/net/bpf_jit_comp.c |    4 +++
 arch/x86/net/bpf_jit_comp.c  |   80 ++++++++++++++++++++++--------------------
 include/linux/bpf.h          |    2 ++
 include/linux/filter.h       |    1 +
 include/uapi/linux/bpf.h     |    2 ++
 net/core/filter.c            |   47 +++++++++++++++++++++++++
 6 files changed, 98 insertions(+), 38 deletions(-)

diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index fee782acc2ee..79c731e8d178 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -973,6 +973,10 @@ static noinline int bpf_jit_insn(struct bpf_jit *jit, struct bpf_prog *fp, int i
 		 */
 		const u64 func = (u64)__bpf_call_base + imm;
 
+		if (bpf_helper_changes_skb_data((void *)func))
+			/* TODO reload skb->data, hlen */
+			return -1;
+
 		REG_SET_SEEN(BPF_REG_5);
 		jit->seen |= SEEN_FUNC;
 		/* lg %w1,<d(imm)>(%l) */
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 579a8fd74be0..6c335a8fc086 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -315,6 +315,26 @@ static void emit_bpf_tail_call(u8 **pprog)
 	*pprog = prog;
 }
 
+
+static void emit_load_skb_data_hlen(u8 **pprog)
+{
+	u8 *prog = *pprog;
+	int cnt = 0;
+
+	/* r9d = skb->len - skb->data_len (headlen)
+	 * r10 = skb->data
+	 */
+	/* mov %r9d, off32(%rdi) */
+	EMIT3_off32(0x44, 0x8b, 0x8f, offsetof(struct sk_buff, len));
+
+	/* sub %r9d, off32(%rdi) */
+	EMIT3_off32(0x44, 0x2b, 0x8f, offsetof(struct sk_buff, data_len));
+
+	/* mov %r10, off32(%rdi) */
+	EMIT3_off32(0x4c, 0x8b, 0x97, offsetof(struct sk_buff, data));
+	*pprog = prog;
+}
+
 static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 		  int oldproglen, struct jit_context *ctx)
 {
@@ -329,36 +349,8 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 
 	emit_prologue(&prog);
 
-	if (seen_ld_abs) {
-		/* r9d : skb->len - skb->data_len (headlen)
-		 * r10 : skb->data
-		 */
-		if (is_imm8(offsetof(struct sk_buff, len)))
-			/* mov %r9d, off8(%rdi) */
-			EMIT4(0x44, 0x8b, 0x4f,
-			      offsetof(struct sk_buff, len));
-		else
-			/* mov %r9d, off32(%rdi) */
-			EMIT3_off32(0x44, 0x8b, 0x8f,
-				    offsetof(struct sk_buff, len));
-
-		if (is_imm8(offsetof(struct sk_buff, data_len)))
-			/* sub %r9d, off8(%rdi) */
-			EMIT4(0x44, 0x2b, 0x4f,
-			      offsetof(struct sk_buff, data_len));
-		else
-			EMIT3_off32(0x44, 0x2b, 0x8f,
-				    offsetof(struct sk_buff, data_len));
-
-		if (is_imm8(offsetof(struct sk_buff, data)))
-			/* mov %r10, off8(%rdi) */
-			EMIT4(0x4c, 0x8b, 0x57,
-			      offsetof(struct sk_buff, data));
-		else
-			/* mov %r10, off32(%rdi) */
-			EMIT3_off32(0x4c, 0x8b, 0x97,
-				    offsetof(struct sk_buff, data));
-	}
+	if (seen_ld_abs)
+		emit_load_skb_data_hlen(&prog);
 
 	for (i = 0; i < insn_cnt; i++, insn++) {
 		const s32 imm32 = insn->imm;
@@ -367,6 +359,7 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 		u8 b1 = 0, b2 = 0, b3 = 0;
 		s64 jmp_offset;
 		u8 jmp_cond;
+		bool reload_skb_data;
 		int ilen;
 		u8 *func;
 
@@ -818,12 +811,18 @@ xadd:			if (is_imm8(insn->off))
 			func = (u8 *) __bpf_call_base + imm32;
 			jmp_offset = func - (image + addrs[i]);
 			if (seen_ld_abs) {
-				EMIT2(0x41, 0x52); /* push %r10 */
-				EMIT2(0x41, 0x51); /* push %r9 */
-				/* need to adjust jmp offset, since
-				 * pop %r9, pop %r10 take 4 bytes after call insn
-				 */
-				jmp_offset += 4;
+				reload_skb_data = bpf_helper_changes_skb_data(func);
+				if (reload_skb_data) {
+					EMIT1(0x57); /* push %rdi */
+					jmp_offset += 22; /* pop, mov, sub, mov */
+				} else {
+					EMIT2(0x41, 0x52); /* push %r10 */
+					EMIT2(0x41, 0x51); /* push %r9 */
+					/* need to adjust jmp offset, since
+					 * pop %r9, pop %r10 take 4 bytes after call insn
+					 */
+					jmp_offset += 4;
+				}
 			}
 			if (!imm32 || !is_simm32(jmp_offset)) {
 				pr_err("unsupported bpf func %d addr %p image %p\n",
@@ -832,8 +831,13 @@ xadd:			if (is_imm8(insn->off))
 			}
 			EMIT1_off32(0xE8, jmp_offset);
 			if (seen_ld_abs) {
-				EMIT2(0x41, 0x59); /* pop %r9 */
-				EMIT2(0x41, 0x5A); /* pop %r10 */
+				if (reload_skb_data) {
+					EMIT1(0x5F); /* pop %rdi */
+					emit_load_skb_data_hlen(&prog);
+				} else {
+					EMIT2(0x41, 0x59); /* pop %r9 */
+					EMIT2(0x41, 0x5A); /* pop %r10 */
+				}
 			}
 			break;
 
diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 4383476a0d48..139d6d2e123f 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -192,5 +192,7 @@ extern const struct bpf_func_proto bpf_ktime_get_ns_proto;
 extern const struct bpf_func_proto bpf_get_current_pid_tgid_proto;
 extern const struct bpf_func_proto bpf_get_current_uid_gid_proto;
 extern const struct bpf_func_proto bpf_get_current_comm_proto;
+extern const struct bpf_func_proto bpf_skb_vlan_push_proto;
+extern const struct bpf_func_proto bpf_skb_vlan_pop_proto;
 
 #endif /* _LINUX_BPF_H */
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 17724f6ea983..69d00555ce35 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -411,6 +411,7 @@ void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp);
 
 u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 void bpf_int_jit_compile(struct bpf_prog *fp);
+bool bpf_helper_changes_skb_data(void *func);
 
 #ifdef CONFIG_BPF_JIT
 typedef void (*bpf_jit_fill_hole_t)(void *area, unsigned int size);
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 2de87e58b12b..2f6c83d714e9 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -256,6 +256,8 @@ enum bpf_func_id {
 	 * Return: classid if != 0
 	 */
 	BPF_FUNC_get_cgroup_classid,
+	BPF_FUNC_skb_vlan_push, /* bpf_skb_vlan_push(skb, vlan_proto, vlan_tci) */
+	BPF_FUNC_skb_vlan_pop,  /* bpf_skb_vlan_pop(skb) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 247450a5e387..3683ab09a48a 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1437,6 +1437,49 @@ static const struct bpf_func_proto bpf_get_cgroup_classid_proto = {
 	.arg1_type      = ARG_PTR_TO_CTX,
 };
 
+static u64 bpf_skb_vlan_push(u64 r1, u64 vlan_proto, u64 vlan_tci, u64 r4, u64 r5)
+{
+	struct sk_buff *skb = (struct sk_buff *) (long) r1;
+
+	if (unlikely(vlan_proto != htons(ETH_P_8021Q) &&
+		     vlan_proto != htons(ETH_P_8021AD)))
+		vlan_proto = htons(ETH_P_8021Q);
+
+	return skb_vlan_push(skb, vlan_proto, vlan_tci);
+}
+
+const struct bpf_func_proto bpf_skb_vlan_push_proto = {
+	.func           = bpf_skb_vlan_push,
+	.gpl_only       = false,
+	.ret_type       = RET_INTEGER,
+	.arg1_type      = ARG_PTR_TO_CTX,
+	.arg2_type      = ARG_ANYTHING,
+	.arg3_type      = ARG_ANYTHING,
+};
+
+static u64 bpf_skb_vlan_pop(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct sk_buff *skb = (struct sk_buff *) (long) r1;
+
+	return skb_vlan_pop(skb);
+}
+
+const struct bpf_func_proto bpf_skb_vlan_pop_proto = {
+	.func           = bpf_skb_vlan_pop,
+	.gpl_only       = false,
+	.ret_type       = RET_INTEGER,
+	.arg1_type      = ARG_PTR_TO_CTX,
+};
+
+bool bpf_helper_changes_skb_data(void *func)
+{
+	if (func == bpf_skb_vlan_push)
+		return true;
+	if (func == bpf_skb_vlan_pop)
+		return true;
+	return false;
+}
+
 static const struct bpf_func_proto *
 sk_filter_func_proto(enum bpf_func_id func_id)
 {
@@ -1476,6 +1519,10 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_clone_redirect_proto;
 	case BPF_FUNC_get_cgroup_classid:
 		return &bpf_get_cgroup_classid_proto;
+	case BPF_FUNC_skb_vlan_push:
+		return &bpf_skb_vlan_push_proto;
+	case BPF_FUNC_skb_vlan_pop:
+		return &bpf_skb_vlan_pop_proto;
 	default:
 		return sk_filter_func_proto(func_id);
 	}
-- 
1.7.9.5
