From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/3] bpf: direct packet write and access for helpers for clsact progs
Date: Tue, 20 Sep 2016 00:26:13 +0200
Message-ID: <69708f67b388878c5e0e89da9d6006c698d628cb.1474323281.git.daniel@iogearbox.net>
References: <cover.1474323281.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
        jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49351 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752798AbcISW02 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 18:26:28 -0400
In-Reply-To: <cover.1474323281.git.daniel@iogearbox.net>
In-Reply-To: <cover.1474323281.git.daniel@iogearbox.net>
References: <cover.1474323281.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work implements direct packet access for helpers and direct packet
write in a similar fashion as already available for XDP types via commits
4acf6c0b84c9 ("bpf: enable direct packet data write for xdp progs") and
6841de8b0d03 ("bpf: allow helpers access the packet directly"), and as a
complementary feature to the already available direct packet read for tc
(cls/act) programs.

For enabling this, we need to introduce two helpers, bpf_skb_pull_data()
and bpf_csum_update(). The first is generally needed for both, read and
write, because they would otherwise only be limited to the current linear
skb head. Usually, when the data_end test fails, programs just bail out,
or, in the direct read case, use bpf_skb_load_bytes() as an alternative
to overcome this limitation. If such data sits in non-linear parts, we
can just pull them in once with the new helper, retest and eventually
access them.

At the same time, this also makes sure the skb is uncloned, which is, of
course, a necessary condition for direct write. As this needs to be an
invariant for the write part only, the verifier detects writes and adds
a prologue that is calling bpf_skb_pull_data() to effectively unclone the
skb from the very beginning in case it is indeed cloned. The heuristic
makes use of a similar trick that was done in 233577a22089 ("net: filter:
constify detection of pkt_type_offset"). This comes at zero cost for other
programs that do not use the direct write feature. Should a program use
this feature only sparsely and has read access for the most parts with,
for example, drop return codes, then such write action can be delegated
to a tail called program for mitigating this cost of potential uncloning
to a late point in time where it would have been paid similarly with the
bpf_skb_store_bytes() as well. Advantage of direct write is that the
writes are inlined whereas the helper cannot make any length assumptions
and thus needs to generate a call to memcpy() also for small sizes, as well
as cost of helper call itself with sanity checks are avoided. Plus, when
direct read is already used, we don't need to cache or perform rechecks
on the data boundaries (due to verifier invalidating previous checks for
helpers that change skb->data), so more complex programs using rewrites
can benefit from switching to direct read plus write.

For direct packet access to helpers, we save the otherwise needed copy into
a temp struct sitting on stack memory when use-case allows. Both facilities
are enabled via may_access_direct_pkt_data() in verifier. For now, we limit
this to map helpers and csum_diff, and can successively enable other helpers
where we find it makes sense. Helpers that definitely cannot be allowed for
this are those part of bpf_helper_changes_skb_data() since they can change
underlying data, and those that write into memory as this could happen for
packet typed args when still cloned. bpf_csum_update() helper accommodates
for the fact that we need to fixup checksum_complete when using direct write
instead of bpf_skb_store_bytes(), meaning the programs can use available
helpers like bpf_csum_diff(), and implement csum_add(), csum_sub(),
csum_block_add(), csum_block_sub() equivalents in eBPF together with the
new helper. A usage example will be provided for iproute2's examples/bpf/
directory.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h      |   4 +-
 include/linux/skbuff.h   |  14 ++++-
 include/uapi/linux/bpf.h |  21 ++++++++
 kernel/bpf/helpers.c     |   3 ++
 kernel/bpf/verifier.c    |  54 ++++++++++++++-----
 net/core/filter.c        | 134 +++++++++++++++++++++++++++++++++++++++++------
 6 files changed, 196 insertions(+), 34 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 9a904f6..5691fdc 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -96,6 +96,7 @@ enum bpf_return_type {
 struct bpf_func_proto {
 	u64 (*func)(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 	bool gpl_only;
+	bool pkt_access;
 	enum bpf_return_type ret_type;
 	enum bpf_arg_type arg1_type;
 	enum bpf_arg_type arg2_type;
@@ -151,7 +152,8 @@ struct bpf_verifier_ops {
 	 */
 	bool (*is_valid_access)(int off, int size, enum bpf_access_type type,
 				enum bpf_reg_type *reg_type);
-
+	int (*gen_prologue)(struct bpf_insn *insn, bool direct_write,
+			    const struct bpf_prog *prog);
 	u32 (*convert_ctx_access)(enum bpf_access_type type, int dst_reg,
 				  int src_reg, int ctx_off,
 				  struct bpf_insn *insn, struct bpf_prog *prog);
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4c5662f..c6dab3f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -676,13 +676,23 @@ struct sk_buff {
 	 */
 	kmemcheck_bitfield_begin(flags1);
 	__u16			queue_mapping;
+
+/* if you move cloned around you also must adapt those constants */
+#ifdef __BIG_ENDIAN_BITFIELD
+#define CLONED_MASK	(1 << 7)
+#else
+#define CLONED_MASK	1
+#endif
+#define CLONED_OFFSET()		offsetof(struct sk_buff, __cloned_offset)
+
+	__u8			__cloned_offset[0];
 	__u8			cloned:1,
 				nohdr:1,
 				fclone:2,
 				peeked:1,
 				head_frag:1,
-				xmit_more:1;
-	/* one bit hole */
+				xmit_more:1,
+				__unused:1; /* one bit hole */
 	kmemcheck_bitfield_end(flags1);
 
 	/* fields enclosed in headers_start/headers_end are copied
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index f896dfa..e07432b 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -398,6 +398,27 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_skb_change_tail,
 
+	/**
+	 * bpf_skb_pull_data(skb, len)
+	 * The helper will pull in non-linear data in case the
+	 * skb is non-linear and not all of len are part of the
+	 * linear section. Only needed for read/write with direct
+	 * packet access.
+	 * @skb: pointer to skb
+	 * @len: len to make read/writeable
+	 * Return: 0 on success or negative error
+	 */
+	BPF_FUNC_skb_pull_data,
+
+	/**
+	 * bpf_csum_update(skb, csum)
+	 * Adds csum into skb->csum in case of CHECKSUM_COMPLETE.
+	 * @skb: pointer to skb
+	 * @csum: csum to add
+	 * Return: csum on success or negative error
+	 */
+	BPF_FUNC_csum_update,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index a5b8bf8..3991840 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -36,6 +36,7 @@ BPF_CALL_2(bpf_map_lookup_elem, struct bpf_map *, map, void *, key)
 const struct bpf_func_proto bpf_map_lookup_elem_proto = {
 	.func		= bpf_map_lookup_elem,
 	.gpl_only	= false,
+	.pkt_access	= true,
 	.ret_type	= RET_PTR_TO_MAP_VALUE_OR_NULL,
 	.arg1_type	= ARG_CONST_MAP_PTR,
 	.arg2_type	= ARG_PTR_TO_MAP_KEY,
@@ -51,6 +52,7 @@ BPF_CALL_4(bpf_map_update_elem, struct bpf_map *, map, void *, key,
 const struct bpf_func_proto bpf_map_update_elem_proto = {
 	.func		= bpf_map_update_elem,
 	.gpl_only	= false,
+	.pkt_access	= true,
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_CONST_MAP_PTR,
 	.arg2_type	= ARG_PTR_TO_MAP_KEY,
@@ -67,6 +69,7 @@ BPF_CALL_2(bpf_map_delete_elem, struct bpf_map *, map, void *, key)
 const struct bpf_func_proto bpf_map_delete_elem_proto = {
 	.func		= bpf_map_delete_elem,
 	.gpl_only	= false,
+	.pkt_access	= true,
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_CONST_MAP_PTR,
 	.arg2_type	= ARG_PTR_TO_MAP_KEY,
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index bc138f3..3a75ee3 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -196,6 +196,7 @@ struct verifier_env {
 	u32 used_map_cnt;		/* number of used maps */
 	u32 id_gen;			/* used to generate unique reg IDs */
 	bool allow_ptr_leaks;
+	bool seen_direct_write;
 };
 
 #define BPF_COMPLEXITY_LIMIT_INSNS	65536
@@ -204,6 +205,7 @@ struct verifier_env {
 struct bpf_call_arg_meta {
 	struct bpf_map *map_ptr;
 	bool raw_mode;
+	bool pkt_access;
 	int regno;
 	int access_size;
 };
@@ -654,10 +656,17 @@ static int check_map_access(struct verifier_env *env, u32 regno, int off,
 
 #define MAX_PACKET_OFF 0xffff
 
-static bool may_write_pkt_data(enum bpf_prog_type type)
+static bool may_access_direct_pkt_data(struct verifier_env *env,
+				       const struct bpf_call_arg_meta *meta)
 {
-	switch (type) {
+	switch (env->prog->type) {
+	case BPF_PROG_TYPE_SCHED_CLS:
+	case BPF_PROG_TYPE_SCHED_ACT:
 	case BPF_PROG_TYPE_XDP:
+		if (meta)
+			return meta->pkt_access;
+
+		env->seen_direct_write = true;
 		return true;
 	default:
 		return false;
@@ -817,7 +826,7 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
 			err = check_stack_read(state, off, size, value_regno);
 		}
 	} else if (state->regs[regno].type == PTR_TO_PACKET) {
-		if (t == BPF_WRITE && !may_write_pkt_data(env->prog->type)) {
+		if (t == BPF_WRITE && !may_access_direct_pkt_data(env, NULL)) {
 			verbose("cannot write into packet\n");
 			return -EACCES;
 		}
@@ -950,8 +959,8 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 		return 0;
 	}
 
-	if (type == PTR_TO_PACKET && !may_write_pkt_data(env->prog->type)) {
-		verbose("helper access to the packet is not allowed for clsact\n");
+	if (type == PTR_TO_PACKET && !may_access_direct_pkt_data(env, meta)) {
+		verbose("helper access to the packet is not allowed\n");
 		return -EACCES;
 	}
 
@@ -1191,6 +1200,7 @@ static int check_call(struct verifier_env *env, int func_id)
 	changes_data = bpf_helper_changes_skb_data(fn->func);
 
 	memset(&meta, 0, sizeof(meta));
+	meta.pkt_access = fn->pkt_access;
 
 	/* We only support one arg being in raw mode at the moment, which
 	 * is sufficient for the helper functions we have right now.
@@ -2675,18 +2685,35 @@ static void convert_pseudo_ld_imm64(struct verifier_env *env)
  */
 static int convert_ctx_accesses(struct verifier_env *env)
 {
-	struct bpf_insn *insn = env->prog->insnsi;
-	int insn_cnt = env->prog->len;
-	struct bpf_insn insn_buf[16];
+	const struct bpf_verifier_ops *ops = env->prog->aux->ops;
+	struct bpf_insn insn_buf[16], *insn;
 	struct bpf_prog *new_prog;
 	enum bpf_access_type type;
-	int i;
+	int i, insn_cnt, cnt;
 
-	if (!env->prog->aux->ops->convert_ctx_access)
+	if (ops->gen_prologue) {
+		cnt = ops->gen_prologue(insn_buf, env->seen_direct_write,
+					env->prog);
+		if (cnt >= ARRAY_SIZE(insn_buf)) {
+			verbose("bpf verifier is misconfigured\n");
+			return -EINVAL;
+		} else if (cnt) {
+			new_prog = bpf_patch_insn_single(env->prog, 0,
+							 insn_buf, cnt);
+			if (!new_prog)
+				return -ENOMEM;
+			env->prog = new_prog;
+		}
+	}
+
+	if (!ops->convert_ctx_access)
 		return 0;
 
+	insn_cnt = env->prog->len;
+	insn = env->prog->insnsi;
+
 	for (i = 0; i < insn_cnt; i++, insn++) {
-		u32 insn_delta, cnt;
+		u32 insn_delta;
 
 		if (insn->code == (BPF_LDX | BPF_MEM | BPF_W) ||
 		    insn->code == (BPF_LDX | BPF_MEM | BPF_DW))
@@ -2703,9 +2730,8 @@ static int convert_ctx_accesses(struct verifier_env *env)
 			continue;
 		}
 
-		cnt = env->prog->aux->ops->
-			convert_ctx_access(type, insn->dst_reg, insn->src_reg,
-					   insn->off, insn_buf, env->prog);
+		cnt = ops->convert_ctx_access(type, insn->dst_reg, insn->src_reg,
+					      insn->off, insn_buf, env->prog);
 		if (cnt == 0 || cnt >= ARRAY_SIZE(insn_buf)) {
 			verbose("bpf verifier is misconfigured\n");
 			return -EINVAL;
diff --git a/net/core/filter.c b/net/core/filter.c
index 298b146..0920c2a 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1362,6 +1362,11 @@ static inline int bpf_try_make_writable(struct sk_buff *skb,
 	return err;
 }
 
+static int bpf_try_make_head_writable(struct sk_buff *skb)
+{
+	return bpf_try_make_writable(skb, skb_headlen(skb));
+}
+
 static inline void bpf_push_mac_rcsum(struct sk_buff *skb)
 {
 	if (skb_at_tc_ingress(skb))
@@ -1441,6 +1446,28 @@ static const struct bpf_func_proto bpf_skb_load_bytes_proto = {
 	.arg4_type	= ARG_CONST_STACK_SIZE,
 };
 
+BPF_CALL_2(bpf_skb_pull_data, struct sk_buff *, skb, u32, len)
+{
+	/* Idea is the following: should the needed direct read/write
+	 * test fail during runtime, we can pull in more data and redo
+	 * again, since implicitly, we invalidate previous checks here.
+	 *
+	 * Or, since we know how much we need to make read/writeable,
+	 * this can be done once at the program beginning for direct
+	 * access case. By this we overcome limitations of only current
+	 * headroom being accessible.
+	 */
+	return bpf_try_make_writable(skb, len ? : skb_headlen(skb));
+}
+
+static const struct bpf_func_proto bpf_skb_pull_data_proto = {
+	.func		= bpf_skb_pull_data,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+};
+
 BPF_CALL_5(bpf_l3_csum_replace, struct sk_buff *, skb, u32, offset,
 	   u64, from, u64, to, u64, flags)
 {
@@ -1567,6 +1594,7 @@ BPF_CALL_5(bpf_csum_diff, __be32 *, from, u32, from_size,
 static const struct bpf_func_proto bpf_csum_diff_proto = {
 	.func		= bpf_csum_diff,
 	.gpl_only	= false,
+	.pkt_access	= true,
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_PTR_TO_STACK,
 	.arg2_type	= ARG_CONST_STACK_SIZE_OR_ZERO,
@@ -1575,6 +1603,26 @@ static const struct bpf_func_proto bpf_csum_diff_proto = {
 	.arg5_type	= ARG_ANYTHING,
 };
 
+BPF_CALL_2(bpf_csum_update, struct sk_buff *, skb, __wsum, csum)
+{
+	/* The interface is to be used in combination with bpf_csum_diff()
+	 * for direct packet writes. csum rotation for alignment as well
+	 * as emulating csum_sub() can be done from the eBPF program.
+	 */
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		return (skb->csum = csum_add(skb->csum, csum));
+
+	return -ENOTSUPP;
+}
+
+static const struct bpf_func_proto bpf_csum_update_proto = {
+	.func		= bpf_csum_update,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+};
+
 static inline int __bpf_rx_skb(struct net_device *dev, struct sk_buff *skb)
 {
 	return dev_forward_skb(dev, skb);
@@ -1602,6 +1650,8 @@ static inline int __bpf_tx_skb(struct net_device *dev, struct sk_buff *skb)
 BPF_CALL_3(bpf_clone_redirect, struct sk_buff *, skb, u32, ifindex, u64, flags)
 {
 	struct net_device *dev;
+	struct sk_buff *clone;
+	int ret;
 
 	if (unlikely(flags & ~(BPF_F_INGRESS)))
 		return -EINVAL;
@@ -1610,14 +1660,25 @@ BPF_CALL_3(bpf_clone_redirect, struct sk_buff *, skb, u32, ifindex, u64, flags)
 	if (unlikely(!dev))
 		return -EINVAL;
 
-	skb = skb_clone(skb, GFP_ATOMIC);
-	if (unlikely(!skb))
+	clone = skb_clone(skb, GFP_ATOMIC);
+	if (unlikely(!clone))
 		return -ENOMEM;
 
-	bpf_push_mac_rcsum(skb);
+	/* For direct write, we need to keep the invariant that the skbs
+	 * we're dealing with need to be uncloned. Should uncloning fail
+	 * here, we need to free the just generated clone to unclone once
+	 * again.
+	 */
+	ret = bpf_try_make_head_writable(skb);
+	if (unlikely(ret)) {
+		kfree_skb(clone);
+		return -ENOMEM;
+	}
+
+	bpf_push_mac_rcsum(clone);
 
 	return flags & BPF_F_INGRESS ?
-	       __bpf_rx_skb(dev, skb) : __bpf_tx_skb(dev, skb);
+	       __bpf_rx_skb(dev, clone) : __bpf_tx_skb(dev, clone);
 }
 
 static const struct bpf_func_proto bpf_clone_redirect_proto = {
@@ -2063,19 +2124,14 @@ static const struct bpf_func_proto bpf_skb_change_tail_proto = {
 
 bool bpf_helper_changes_skb_data(void *func)
 {
-	if (func == bpf_skb_vlan_push)
-		return true;
-	if (func == bpf_skb_vlan_pop)
-		return true;
-	if (func == bpf_skb_store_bytes)
-		return true;
-	if (func == bpf_skb_change_proto)
-		return true;
-	if (func == bpf_skb_change_tail)
-		return true;
-	if (func == bpf_l3_csum_replace)
-		return true;
-	if (func == bpf_l4_csum_replace)
+	if (func == bpf_skb_vlan_push ||
+	    func == bpf_skb_vlan_pop ||
+	    func == bpf_skb_store_bytes ||
+	    func == bpf_skb_change_proto ||
+	    func == bpf_skb_change_tail ||
+	    func == bpf_skb_pull_data ||
+	    func == bpf_l3_csum_replace ||
+	    func == bpf_l4_csum_replace)
 		return true;
 
 	return false;
@@ -2440,8 +2496,12 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 		return &bpf_skb_store_bytes_proto;
 	case BPF_FUNC_skb_load_bytes:
 		return &bpf_skb_load_bytes_proto;
+	case BPF_FUNC_skb_pull_data:
+		return &bpf_skb_pull_data_proto;
 	case BPF_FUNC_csum_diff:
 		return &bpf_csum_diff_proto;
+	case BPF_FUNC_csum_update:
+		return &bpf_csum_update_proto;
 	case BPF_FUNC_l3_csum_replace:
 		return &bpf_l3_csum_replace_proto;
 	case BPF_FUNC_l4_csum_replace:
@@ -2533,6 +2593,45 @@ static bool sk_filter_is_valid_access(int off, int size,
 	return __is_valid_access(off, size, type);
 }
 
+static int tc_cls_act_prologue(struct bpf_insn *insn_buf, bool direct_write,
+			       const struct bpf_prog *prog)
+{
+	struct bpf_insn *insn = insn_buf;
+
+	if (!direct_write)
+		return 0;
+
+	/* if (!skb->cloned)
+	 *       goto start;
+	 *
+	 * (Fast-path, otherwise approximation that we might be
+	 *  a clone, do the rest in helper.)
+	 */
+	*insn++ = BPF_LDX_MEM(BPF_B, BPF_REG_6, BPF_REG_1, CLONED_OFFSET());
+	*insn++ = BPF_ALU32_IMM(BPF_AND, BPF_REG_6, CLONED_MASK);
+	*insn++ = BPF_JMP_IMM(BPF_JEQ, BPF_REG_6, 0, 7);
+
+	/* ret = bpf_skb_pull_data(skb, 0); */
+	*insn++ = BPF_MOV64_REG(BPF_REG_6, BPF_REG_1);
+	*insn++ = BPF_ALU64_REG(BPF_XOR, BPF_REG_2, BPF_REG_2);
+	*insn++ = BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+			       BPF_FUNC_skb_pull_data);
+	/* if (!ret)
+	 *      goto restore;
+	 * return TC_ACT_SHOT;
+	 */
+	*insn++ = BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2);
+	*insn++ = BPF_ALU32_IMM(BPF_MOV, BPF_REG_0, TC_ACT_SHOT);
+	*insn++ = BPF_EXIT_INSN();
+
+	/* restore: */
+	*insn++ = BPF_MOV64_REG(BPF_REG_1, BPF_REG_6);
+	/* start: */
+	*insn++ = prog->insnsi[0];
+
+	return insn - insn_buf;
+}
+
 static bool tc_cls_act_is_valid_access(int off, int size,
 				       enum bpf_access_type type,
 				       enum bpf_reg_type *reg_type)
@@ -2810,6 +2909,7 @@ static const struct bpf_verifier_ops tc_cls_act_ops = {
 	.get_func_proto		= tc_cls_act_func_proto,
 	.is_valid_access	= tc_cls_act_is_valid_access,
 	.convert_ctx_access	= tc_cls_act_convert_ctx_access,
+	.gen_prologue		= tc_cls_act_prologue,
 };
 
 static const struct bpf_verifier_ops xdp_ops = {
-- 
1.9.3
