From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 1/2] bpf: allow extended BPF programs access skb fields
Date: Fri, 13 Mar 2015 11:57:42 -0700
Message-ID: <1426273064-4837-2-git-send-email-ast@plumgrid.com>
References: <1426273064-4837-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35175 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754134AbbCMS5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 14:57:54 -0400
Received: by pdbfp1 with SMTP id fp1so30895774pdb.2
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 11:57:53 -0700 (PDT)
In-Reply-To: <1426273064-4837-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

introduce user accessible mirror of in-kernel 'struct sk_buff':
struct __sk_buff {
    __u32 len;
    __u32 pkt_type;
    __u32 mark;
    __u32 queue_mapping;
};

bpf programs can do:

int bpf_prog(struct __sk_buff *skb)
{
    __u32 var = skb->pkt_type;

which will be compiled to bpf assembler as:

dst_reg = *(u32 *)(src_reg + 4) // 4 == offsetof(struct __sk_buff, pkt_type)

bpf verifier will check validity of access and will convert it to:

dst_reg = *(u8 *)(src_reg + offsetof(struct sk_buff, __pkt_type_offset))
dst_reg &= 7

since skb->pkt_type is a bitfield.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/bpf.h      |    5 +-
 include/uapi/linux/bpf.h |   10 +++
 kernel/bpf/syscall.c     |    2 +-
 kernel/bpf/verifier.c    |  152 +++++++++++++++++++++++++++++++++++++++++-----
 net/core/filter.c        |  100 ++++++++++++++++++++++++------
 5 files changed, 234 insertions(+), 35 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 80f2e0fc3d02..2c17ebdfb5ae 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -103,6 +103,9 @@ struct bpf_verifier_ops {
 	 * with 'type' (read or write) is allowed
 	 */
 	bool (*is_valid_access)(int off, int size, enum bpf_access_type type);
+
+	u32 (*convert_ctx_access)(int dst_reg, int src_reg, int ctx_off,
+				  struct bpf_insn *insn);
 };
 
 struct bpf_prog_type_list {
@@ -133,7 +136,7 @@ struct bpf_map *bpf_map_get(struct fd f);
 void bpf_map_put(struct bpf_map *map);
 
 /* verify correctness of eBPF program */
-int bpf_check(struct bpf_prog *fp, union bpf_attr *attr);
+int bpf_check(struct bpf_prog **fp, union bpf_attr *attr);
 #else
 static inline void bpf_register_prog_type(struct bpf_prog_type_list *tl)
 {
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 3fa1af8a58d7..936e9257da95 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -168,4 +168,14 @@ enum bpf_func_id {
 	__BPF_FUNC_MAX_ID,
 };
 
+/* user accessible mirror of in-kernel sk_buff.
+ * new fields can only be added to the end of this structure
+ */
+struct __sk_buff {
+	__u32 len;
+	__u32 pkt_type;
+	__u32 mark;
+	__u32 queue_mapping;
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 669719ccc9ee..ea75c654af1b 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -519,7 +519,7 @@ static int bpf_prog_load(union bpf_attr *attr)
 		goto free_prog;
 
 	/* run eBPF verifier */
-	err = bpf_check(prog, attr);
+	err = bpf_check(&prog, attr);
 	if (err < 0)
 		goto free_used_maps;
 
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index e6b522496250..c22ebd36fa4b 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1620,11 +1620,10 @@ static int do_check(struct verifier_env *env)
 				return err;
 
 		} else if (class == BPF_LDX) {
-			if (BPF_MODE(insn->code) != BPF_MEM ||
-			    insn->imm != 0) {
-				verbose("BPF_LDX uses reserved fields\n");
-				return -EINVAL;
-			}
+			enum bpf_reg_type src_reg_type;
+
+			/* check for reserved fields is already done */
+
 			/* check src operand */
 			err = check_reg_arg(regs, insn->src_reg, SRC_OP);
 			if (err)
@@ -1643,6 +1642,29 @@ static int do_check(struct verifier_env *env)
 			if (err)
 				return err;
 
+			src_reg_type = regs[insn->src_reg].type;
+
+			if (insn->imm == 0 && BPF_SIZE(insn->code) == BPF_W) {
+				/* saw a valid insn
+				 * dst_reg = *(u32 *)(src_reg + off)
+				 * use reserved 'imm' field to mark this insn
+				 */
+				insn->imm = src_reg_type;
+
+			} else if (src_reg_type != insn->imm &&
+				   (src_reg_type == PTR_TO_CTX ||
+				    insn->imm == PTR_TO_CTX)) {
+				/* ABuser program is trying to use the same insn
+				 * dst_reg = *(u32*) (src_reg + off)
+				 * with different pointer types:
+				 * src_reg == ctx in one branch and
+				 * src_reg == stack|map in some other branch.
+				 * Reject it.
+				 */
+				verbose("same insn cannot be used with different pointers\n");
+				return -EINVAL;
+			}
+
 		} else if (class == BPF_STX) {
 			if (BPF_MODE(insn->code) == BPF_XADD) {
 				err = check_xadd(env, insn);
@@ -1790,6 +1812,13 @@ static int replace_map_fd_with_map_ptr(struct verifier_env *env)
 	int i, j;
 
 	for (i = 0; i < insn_cnt; i++, insn++) {
+		if (BPF_CLASS(insn->code) == BPF_LDX &&
+		    (BPF_MODE(insn->code) != BPF_MEM ||
+		     insn->imm != 0)) {
+			verbose("BPF_LDX uses reserved fields\n");
+			return -EINVAL;
+		}
+
 		if (insn[0].code == (BPF_LD | BPF_IMM | BPF_DW)) {
 			struct bpf_map *map;
 			struct fd f;
@@ -1881,6 +1910,92 @@ static void convert_pseudo_ld_imm64(struct verifier_env *env)
 			insn->src_reg = 0;
 }
 
+static void adjust_branches(struct bpf_prog *prog, int pos, int delta)
+{
+	struct bpf_insn *insn = prog->insnsi;
+	int insn_cnt = prog->len;
+	int i;
+
+	for (i = 0; i < insn_cnt; i++, insn++) {
+		if (BPF_CLASS(insn->code) != BPF_JMP ||
+		    BPF_OP(insn->code) == BPF_CALL ||
+		    BPF_OP(insn->code) == BPF_EXIT)
+			continue;
+
+		/* adjust offset of jmps if necessary */
+		if (i < pos && i + insn->off + 1 > pos)
+			insn->off += delta;
+		else if (i > pos && i + insn->off + 1 < pos)
+			insn->off -= delta;
+	}
+}
+
+/* convert load instructions that access fields of 'struct __sk_buff'
+ * into sequence of instructions that access fields of 'struct sk_buff'
+ */
+static int convert_ctx_accesses(struct verifier_env *env)
+{
+	struct bpf_insn *insn = env->prog->insnsi;
+	int insn_cnt = env->prog->len;
+	struct bpf_insn insn_buf[16];
+	struct bpf_prog *new_prog;
+	u32 cnt;
+	int i;
+
+	if (!env->prog->aux->ops->convert_ctx_access)
+		return 0;
+
+	for (i = 0; i < insn_cnt; i++, insn++) {
+		if (insn->code != (BPF_LDX | BPF_MEM | BPF_W))
+			continue;
+
+		if (insn->imm != PTR_TO_CTX) {
+			/* clear internal mark */
+			insn->imm = 0;
+			continue;
+		}
+
+		cnt = env->prog->aux->ops->
+			convert_ctx_access(insn->dst_reg, insn->src_reg,
+					   insn->off, insn_buf);
+		if (cnt == 0 || cnt >= ARRAY_SIZE(insn_buf)) {
+			verbose("bpf verifier is misconfigured\n");
+			return -EINVAL;
+		}
+
+		if (cnt == 1) {
+			memcpy(insn, insn_buf, sizeof(*insn));
+			continue;
+		}
+
+		/* several new insns need to be inserted. Make room for them */
+		insn_cnt += cnt - 1;
+		new_prog = bpf_prog_realloc(env->prog,
+					    bpf_prog_size(insn_cnt),
+					    GFP_USER);
+		if (!new_prog)
+			return -ENOMEM;
+
+		new_prog->len = insn_cnt;
+
+		memmove(new_prog->insnsi + i + cnt, new_prog->insns + i + 1,
+			sizeof(*insn) * (insn_cnt - i - cnt));
+
+		/* copy substitute insns in place of load instruction */
+		memcpy(new_prog->insnsi + i, insn_buf, sizeof(*insn) * cnt);
+
+		/* adjust branches in the whole program */
+		adjust_branches(new_prog, i, cnt - 1);
+
+		/* keep walking new program and skip insns we just inserted */
+		env->prog = new_prog;
+		insn = new_prog->insnsi + i + cnt - 1;
+		i += cnt - 1;
+	}
+
+	return 0;
+}
+
 static void free_states(struct verifier_env *env)
 {
 	struct verifier_state_list *sl, *sln;
@@ -1903,13 +2018,13 @@ static void free_states(struct verifier_env *env)
 	kfree(env->explored_states);
 }
 
-int bpf_check(struct bpf_prog *prog, union bpf_attr *attr)
+int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 {
 	char __user *log_ubuf = NULL;
 	struct verifier_env *env;
 	int ret = -EINVAL;
 
-	if (prog->len <= 0 || prog->len > BPF_MAXINSNS)
+	if ((*prog)->len <= 0 || (*prog)->len > BPF_MAXINSNS)
 		return -E2BIG;
 
 	/* 'struct verifier_env' can be global, but since it's not small,
@@ -1919,7 +2034,7 @@ int bpf_check(struct bpf_prog *prog, union bpf_attr *attr)
 	if (!env)
 		return -ENOMEM;
 
-	env->prog = prog;
+	env->prog = *prog;
 
 	/* grab the mutex to protect few globals used by verifier */
 	mutex_lock(&bpf_verifier_lock);
@@ -1951,7 +2066,7 @@ int bpf_check(struct bpf_prog *prog, union bpf_attr *attr)
 	if (ret < 0)
 		goto skip_full_check;
 
-	env->explored_states = kcalloc(prog->len,
+	env->explored_states = kcalloc(env->prog->len,
 				       sizeof(struct verifier_state_list *),
 				       GFP_USER);
 	ret = -ENOMEM;
@@ -1968,6 +2083,10 @@ skip_full_check:
 	while (pop_stack(env, NULL) >= 0);
 	free_states(env);
 
+	if (ret == 0)
+		/* program is valid, convert *(u32*)(ctx + off) accesses */
+		ret = convert_ctx_accesses(env);
+
 	if (log_level && log_len >= log_size - 1) {
 		BUG_ON(log_len >= log_size);
 		/* verifier log exceeded user supplied buffer */
@@ -1983,18 +2102,18 @@ skip_full_check:
 
 	if (ret == 0 && env->used_map_cnt) {
 		/* if program passed verifier, update used_maps in bpf_prog_info */
-		prog->aux->used_maps = kmalloc_array(env->used_map_cnt,
-						     sizeof(env->used_maps[0]),
-						     GFP_KERNEL);
+		env->prog->aux->used_maps = kmalloc_array(env->used_map_cnt,
+							  sizeof(env->used_maps[0]),
+							  GFP_KERNEL);
 
-		if (!prog->aux->used_maps) {
+		if (!env->prog->aux->used_maps) {
 			ret = -ENOMEM;
 			goto free_log_buf;
 		}
 
-		memcpy(prog->aux->used_maps, env->used_maps,
+		memcpy(env->prog->aux->used_maps, env->used_maps,
 		       sizeof(env->used_maps[0]) * env->used_map_cnt);
-		prog->aux->used_map_cnt = env->used_map_cnt;
+		env->prog->aux->used_map_cnt = env->used_map_cnt;
 
 		/* program is valid. Convert pseudo bpf_ld_imm64 into generic
 		 * bpf_ld_imm64 instructions
@@ -2006,11 +2125,12 @@ free_log_buf:
 	if (log_level)
 		vfree(log_buf);
 free_env:
-	if (!prog->aux->used_maps)
+	if (!env->prog->aux->used_maps)
 		/* if we didn't copy map pointers into bpf_prog_info, release
 		 * them now. Otherwise free_bpf_prog_info() will release them.
 		 */
 		release_maps(env);
+	*prog = env->prog;
 	kfree(env);
 	mutex_unlock(&bpf_verifier_lock);
 	return ret;
diff --git a/net/core/filter.c b/net/core/filter.c
index 7a4eb7030dba..23b7c087cece 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -150,10 +150,43 @@ static u64 __get_random_u32(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
 	return prandom_u32();
 }
 
+static u32 convert_skb_access(int skb_field, int dst_reg, int src_reg,
+			      struct bpf_insn *insn_buf)
+{
+	struct bpf_insn *insn = insn_buf;
+
+	switch (skb_field) {
+	case SKF_AD_MARK:
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
+
+		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+				      offsetof(struct sk_buff, mark));
+		break;
+
+	case SKF_AD_PKTTYPE:
+		*insn++ = BPF_LDX_MEM(BPF_B, dst_reg, src_reg, PKT_TYPE_OFFSET());
+		*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, PKT_TYPE_MAX);
+#ifdef __BIG_ENDIAN_BITFIELD
+		*insn++ = BPF_ALU32_IMM(BPF_RSH, dst_reg, 5);
+#endif
+		break;
+
+	case SKF_AD_QUEUE:
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, queue_mapping) != 2);
+
+		*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg,
+				      offsetof(struct sk_buff, queue_mapping));
+		break;
+	}
+
+	return insn - insn_buf;
+}
+
 static bool convert_bpf_extensions(struct sock_filter *fp,
 				   struct bpf_insn **insnp)
 {
 	struct bpf_insn *insn = *insnp;
+	u32 cnt;
 
 	switch (fp->k) {
 	case SKF_AD_OFF + SKF_AD_PROTOCOL:
@@ -167,13 +200,8 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 		break;
 
 	case SKF_AD_OFF + SKF_AD_PKTTYPE:
-		*insn++ = BPF_LDX_MEM(BPF_B, BPF_REG_A, BPF_REG_CTX,
-				      PKT_TYPE_OFFSET());
-		*insn = BPF_ALU32_IMM(BPF_AND, BPF_REG_A, PKT_TYPE_MAX);
-#ifdef __BIG_ENDIAN_BITFIELD
-		insn++;
-                *insn = BPF_ALU32_IMM(BPF_RSH, BPF_REG_A, 5);
-#endif
+		cnt = convert_skb_access(SKF_AD_PKTTYPE, BPF_REG_A, BPF_REG_CTX, insn);
+		insn += cnt - 1;
 		break;
 
 	case SKF_AD_OFF + SKF_AD_IFINDEX:
@@ -197,10 +225,8 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 		break;
 
 	case SKF_AD_OFF + SKF_AD_MARK:
-		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
-
-		*insn = BPF_LDX_MEM(BPF_W, BPF_REG_A, BPF_REG_CTX,
-				    offsetof(struct sk_buff, mark));
+		cnt = convert_skb_access(SKF_AD_MARK, BPF_REG_A, BPF_REG_CTX, insn);
+		insn += cnt - 1;
 		break;
 
 	case SKF_AD_OFF + SKF_AD_RXHASH:
@@ -211,10 +237,8 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 		break;
 
 	case SKF_AD_OFF + SKF_AD_QUEUE:
-		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, queue_mapping) != 2);
-
-		*insn = BPF_LDX_MEM(BPF_H, BPF_REG_A, BPF_REG_CTX,
-				    offsetof(struct sk_buff, queue_mapping));
+		cnt = convert_skb_access(SKF_AD_QUEUE, BPF_REG_A, BPF_REG_CTX, insn);
+		insn += cnt - 1;
 		break;
 
 	case SKF_AD_OFF + SKF_AD_VLAN_TAG:
@@ -1147,13 +1171,55 @@ sk_filter_func_proto(enum bpf_func_id func_id)
 static bool sk_filter_is_valid_access(int off, int size,
 				      enum bpf_access_type type)
 {
-	/* skb fields cannot be accessed yet */
-	return false;
+	/* only read is allowed */
+	if (type != BPF_READ)
+		return false;
+
+	/* check bounds */
+	if (off < 0 || off >= sizeof(struct __sk_buff))
+		return false;
+
+	/* disallow misaligned access */
+	if (off % size != 0)
+		return false;
+
+	/* all __sk_buff fields are __u32 */
+	if (size != 4)
+		return false;
+
+	return true;
+}
+
+static u32 sk_filter_convert_ctx_access(int dst_reg, int src_reg, int ctx_off,
+					struct bpf_insn *insn_buf)
+{
+	struct bpf_insn *insn = insn_buf;
+
+	switch (ctx_off) {
+	case offsetof(struct __sk_buff, len):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);
+
+		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+				      offsetof(struct sk_buff, len));
+		break;
+
+	case offsetof(struct __sk_buff, mark):
+		return convert_skb_access(SKF_AD_MARK, dst_reg, src_reg, insn);
+
+	case offsetof(struct __sk_buff, pkt_type):
+		return convert_skb_access(SKF_AD_PKTTYPE, dst_reg, src_reg, insn);
+
+	case offsetof(struct __sk_buff, queue_mapping):
+		return convert_skb_access(SKF_AD_QUEUE, dst_reg, src_reg, insn);
+	}
+
+	return insn - insn_buf;
 }
 
 static const struct bpf_verifier_ops sk_filter_ops = {
 	.get_func_proto = sk_filter_func_proto,
 	.is_valid_access = sk_filter_is_valid_access,
+	.convert_ctx_access = sk_filter_convert_ctx_access,
 };
 
 static struct bpf_prog_type_list sk_filter_type __read_mostly = {
-- 
1.7.9.5
