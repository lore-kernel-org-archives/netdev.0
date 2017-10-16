From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 3/4] bpf: move knowledge about post-translation offsets out of verifier
Date: Mon, 16 Oct 2017 16:40:55 -0700
Message-ID: <20171016234056.1964-4-jakub.kicinski@netronome.com>
References: <20171016234056.1964-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:57224 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932483AbdJPXlN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 19:41:13 -0400
Received: by mail-pg0-f43.google.com with SMTP id m18so8065658pgd.13
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 16:41:13 -0700 (PDT)
In-Reply-To: <20171016234056.1964-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the fact that verifier ops are now separate from program
ops to define a separate set of callbacks for verification of
already translated programs.

Since we expect the analyzer ops to be defined only for
a small subset of all program types initialize their array
by hand (don't use linux/bpf_types.h).

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 include/linux/bpf.h   |  3 +++
 kernel/bpf/verifier.c | 55 +++++++++++++++------------------------------------
 net/core/filter.c     | 40 +++++++++++++++++++++++++++++++++++++
 3 files changed, 59 insertions(+), 39 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 1d704dd5765f..068b4175c03a 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -291,6 +291,9 @@ DECLARE_PER_CPU(int, bpf_prog_active);
 #undef BPF_PROG_TYPE
 #undef BPF_MAP_TYPE
 
+extern const struct bpf_verifier_ops tc_cls_act_analyzer_ops;
+extern const struct bpf_verifier_ops xdp_analyzer_ops;
+
 struct bpf_prog *bpf_prog_get(u32 ufd);
 struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type);
 struct bpf_prog * __must_check bpf_prog_add(struct bpf_prog *prog, int i);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 84b5a00975e4..a2bbfbf00baf 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -822,36 +822,6 @@ static int check_packet_access(struct bpf_verifier_env *env, u32 regno, int off,
 	return err;
 }
 
-static bool analyzer_is_valid_access(struct bpf_verifier_env *env, int off,
-				     struct bpf_insn_access_aux *info)
-{
-	switch (env->prog->type) {
-	case BPF_PROG_TYPE_XDP:
-		switch (off) {
-		case offsetof(struct xdp_buff, data):
-			info->reg_type = PTR_TO_PACKET;
-			return true;
-		case offsetof(struct xdp_buff, data_end):
-			info->reg_type = PTR_TO_PACKET_END;
-			return true;
-		}
-		return false;
-	case BPF_PROG_TYPE_SCHED_CLS:
-		switch (off) {
-		case offsetof(struct sk_buff, data):
-			info->reg_type = PTR_TO_PACKET;
-			return true;
-		case offsetof(struct sk_buff, cb) +
-		     offsetof(struct bpf_skb_data_end, data_end):
-			info->reg_type = PTR_TO_PACKET_END;
-			return true;
-		}
-		return false;
-	default:
-		return false;
-	}
-}
-
 /* check access to 'struct bpf_context' fields.  Supports fixed offsets only */
 static int check_ctx_access(struct bpf_verifier_env *env, int insn_idx, int off, int size,
 			    enum bpf_access_type t, enum bpf_reg_type *reg_type)
@@ -860,13 +830,8 @@ static int check_ctx_access(struct bpf_verifier_env *env, int insn_idx, int off,
 		.reg_type = *reg_type,
 	};
 
-	if (env->analyzer_ops) {
-		if (analyzer_is_valid_access(env, off, &info)) {
-			*reg_type = info.reg_type;
-			return 0;
-		}
-	} else if (env->ops->is_valid_access &&
-		   env->ops->is_valid_access(off, size, t, &info)) {
+	if (env->ops->is_valid_access &&
+	    env->ops->is_valid_access(off, size, t, &info)) {
 		/* A non zero info.ctx_field_size indicates that this field is a
 		 * candidate for later verifier transformation to load the whole
 		 * field and then apply a mask when accessed with a narrower
@@ -874,9 +839,12 @@ static int check_ctx_access(struct bpf_verifier_env *env, int insn_idx, int off,
 		 * will only allow for whole field access and rejects any other
 		 * type of narrower access.
 		 */
-		env->insn_aux_data[insn_idx].ctx_field_size = info.ctx_field_size;
 		*reg_type = info.reg_type;
 
+		if (env->analyzer_ops)
+			return 0;
+
+		env->insn_aux_data[insn_idx].ctx_field_size = info.ctx_field_size;
 		/* remember the offset of last byte accessed in ctx */
 		if (env->prog->aux->max_ctx_offset < off + size)
 			env->prog->aux->max_ctx_offset = off + size;
@@ -4394,12 +4362,21 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	return ret;
 }
 
+static const struct bpf_verifier_ops * const bpf_analyzer_ops[] = {
+	[BPF_PROG_TYPE_XDP]		= &xdp_analyzer_ops,
+	[BPF_PROG_TYPE_SCHED_CLS]	= &tc_cls_act_analyzer_ops,
+};
+
 int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
 		 void *priv)
 {
 	struct bpf_verifier_env *env;
 	int ret;
 
+	if (prog->type >= ARRAY_SIZE(bpf_analyzer_ops) ||
+	    !bpf_analyzer_ops[prog->type])
+		return -EOPNOTSUPP;
+
 	env = kzalloc(sizeof(struct bpf_verifier_env), GFP_KERNEL);
 	if (!env)
 		return -ENOMEM;
@@ -4410,7 +4387,7 @@ int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
 	if (!env->insn_aux_data)
 		goto err_free_env;
 	env->prog = prog;
-	env->ops = bpf_verifier_ops[env->prog->type];
+	env->ops = bpf_analyzer_ops[env->prog->type];
 	env->analyzer_ops = ops;
 	env->analyzer_priv = priv;
 
diff --git a/net/core/filter.c b/net/core/filter.c
index 8cffd1585451..a908e5da5ffc 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3650,6 +3650,23 @@ static bool tc_cls_act_is_valid_access(int off, int size,
 	return bpf_skb_is_valid_access(off, size, type, info);
 }
 
+static bool
+tc_cls_act_is_valid_access_analyzer(int off, int size,
+				    enum bpf_access_type type,
+				    struct bpf_insn_access_aux *info)
+{
+	switch (off) {
+	case offsetof(struct sk_buff, data):
+		info->reg_type = PTR_TO_PACKET;
+		return true;
+	case offsetof(struct sk_buff, cb) +
+	     offsetof(struct bpf_skb_data_end, data_end):
+		info->reg_type = PTR_TO_PACKET_END;
+		return true;
+	}
+	return false;
+}
+
 static bool __is_valid_xdp_access(int off, int size)
 {
 	if (off < 0 || off >= sizeof(struct xdp_md))
@@ -3684,6 +3701,21 @@ static bool xdp_is_valid_access(int off, int size,
 	return __is_valid_xdp_access(off, size);
 }
 
+static bool xdp_is_valid_access_analyzer(int off, int size,
+					 enum bpf_access_type type,
+					 struct bpf_insn_access_aux *info)
+{
+	switch (off) {
+	case offsetof(struct xdp_buff, data):
+		info->reg_type = PTR_TO_PACKET;
+		return true;
+	case offsetof(struct xdp_buff, data_end):
+		info->reg_type = PTR_TO_PACKET_END;
+		return true;
+	}
+	return false;
+}
+
 void bpf_warn_invalid_xdp_action(u32 act)
 {
 	const u32 act_max = XDP_REDIRECT;
@@ -4329,6 +4361,10 @@ const struct bpf_verifier_ops tc_cls_act_verifier_ops = {
 	.gen_prologue		= tc_cls_act_prologue,
 };
 
+const struct bpf_verifier_ops tc_cls_act_analyzer_ops = {
+	.is_valid_access	= tc_cls_act_is_valid_access_analyzer,
+};
+
 const struct bpf_prog_ops tc_cls_act_prog_ops = {
 	.test_run		= bpf_prog_test_run_skb,
 };
@@ -4339,6 +4375,10 @@ const struct bpf_verifier_ops xdp_verifier_ops = {
 	.convert_ctx_access	= xdp_convert_ctx_access,
 };
 
+const struct bpf_verifier_ops xdp_analyzer_ops = {
+	.is_valid_access	= xdp_is_valid_access_analyzer,
+};
+
 const struct bpf_prog_ops xdp_prog_ops = {
 	.test_run		= bpf_prog_test_run_xdp,
 };
-- 
2.14.1
