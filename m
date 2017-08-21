From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v7 02/10] bpf: Add eBPF program subtype and is_valid_subtype() verifier
Date: Mon, 21 Aug 2017 02:09:25 +0200
Message-ID: <20170821000933.13024-3-mic@digikod.net>
References: <20170821000933.13024-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>, Jann Horn <jann@thejh.net>,
        Jonathan Corbet <corbet@lwn.net>,
        Matthew Garrett <mjg59@srcf.ucam.org>,
        Michael Kerrisk <mtk.manpages@gmail.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <paul@paul-moore.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Shuah Khan <shuah@kernel.org>,
        Tejun Heo <tj@kernel.or
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-9522-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170821000933.13024-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

The goal of the program subtype is to be able to have different static
fine-grained verifications for a unique program type.

The struct bpf_verifier_ops gets a new optional function:
is_valid_subtype(). This new verifier is called at the beginning of the
eBPF program verification to check if the (optional) program subtype is
valid.

For now, only Landlock eBPF programs are using a program subtype (see
next commit) but this could be used by other program types in the future.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Link: https://lkml.kernel.org/r/20160827205559.GA43880@ast-mbp.thefacebook.com
---

Changes since v6:
* rename Landlock version to ABI to better reflect its purpose
* fix unsigned integer checks
* fix pointer cast
* constify pointers
* rebase

Changes since v5:
* use a prog_subtype pointer and make it future-proof
* add subtype test
* constify bpf_load_program()'s subtype argument
* cleanup subtype initialization
* rebase

Changes since v4:
* replace the "status" field with "version" (more generic)
* replace the "access" field with "ability" (less confusing)

Changes since v3:
* remove the "origin" field
* add an "option" field
* cleanup comments
---
 include/linux/bpf.h                         |  7 ++-
 include/linux/filter.h                      |  2 +
 include/uapi/linux/bpf.h                    | 11 +++++
 kernel/bpf/syscall.c                        | 22 ++++++++-
 kernel/bpf/verifier.c                       | 17 +++++--
 kernel/trace/bpf_trace.c                    | 15 ++++--
 net/core/filter.c                           | 71 ++++++++++++++++++-----------
 samples/bpf/bpf_load.c                      |  3 +-
 samples/bpf/cookie_uid_helper_example.c     |  2 +-
 samples/bpf/fds_example.c                   |  2 +-
 samples/bpf/sock_example.c                  |  3 +-
 samples/bpf/test_cgrp2_attach.c             |  2 +-
 samples/bpf/test_cgrp2_attach2.c            |  2 +-
 samples/bpf/test_cgrp2_sock.c               |  2 +-
 tools/include/uapi/linux/bpf.h              | 11 +++++
 tools/lib/bpf/bpf.c                         | 10 +++-
 tools/lib/bpf/bpf.h                         |  5 +-
 tools/lib/bpf/libbpf.c                      |  4 +-
 tools/perf/tests/bpf.c                      |  2 +-
 tools/testing/selftests/bpf/test_align.c    |  2 +-
 tools/testing/selftests/bpf/test_tag.c      |  2 +-
 tools/testing/selftests/bpf/test_verifier.c | 17 ++++++-
 22 files changed, 158 insertions(+), 56 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 830f472d8df5..aef2e6f6d763 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -159,13 +159,15 @@ bpf_ctx_record_field_size(struct bpf_insn_access_aux *aux, u32 size)
 
 struct bpf_verifier_ops {
 	/* return eBPF function prototype for verification */
-	const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id);
+	const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id,
+				      const union bpf_prog_subtype *prog_subtype);
 
 	/* return true if 'size' wide access at offset 'off' within bpf_context
 	 * with 'type' (read or write) is allowed
 	 */
 	bool (*is_valid_access)(int off, int size, enum bpf_access_type type,
-				struct bpf_insn_access_aux *info);
+				struct bpf_insn_access_aux *info,
+				const union bpf_prog_subtype *prog_subtype);
 	int (*gen_prologue)(struct bpf_insn *insn, bool direct_write,
 			    const struct bpf_prog *prog);
 	u32 (*convert_ctx_access)(enum bpf_access_type type,
@@ -174,6 +176,7 @@ struct bpf_verifier_ops {
 				  struct bpf_prog *prog, u32 *target_size);
 	int (*test_run)(struct bpf_prog *prog, const union bpf_attr *kattr,
 			union bpf_attr __user *uattr);
+	bool (*is_valid_subtype)(const union bpf_prog_subtype *prog_subtype);
 };
 
 struct bpf_prog_aux {
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 7015116331af..0c3fadbb5a58 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -464,6 +464,8 @@ struct bpf_prog {
 	u32			len;		/* Number of filter blocks */
 	u32			jited_len;	/* Size of jited insns in bytes */
 	u8			tag[BPF_TAG_SIZE];
+	u8			has_subtype;
+	union bpf_prog_subtype	subtype;	/* Fine-grained verifications */
 	struct bpf_prog_aux	*aux;		/* Auxiliary fields */
 	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
 	unsigned int		(*bpf_func)(const void *ctx,
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 843818dff96d..8541ab85e432 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -177,6 +177,15 @@ enum bpf_attach_type {
 /* Specify numa node during map creation */
 #define BPF_F_NUMA_NODE		(1U << 2)
 
+union bpf_prog_subtype {
+	struct {
+		__u32		abi; /* minimal ABI version, cf. user doc */
+		__u32		event; /* enum landlock_subtype_event */
+		__aligned_u64	ability; /* LANDLOCK_SUBTYPE_ABILITY_* */
+		__aligned_u64	option; /* LANDLOCK_SUBTYPE_OPTION_* */
+	} landlock_rule;
+} __attribute__((aligned(8)));
+
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
 		__u32	map_type;	/* one of enum bpf_map_type */
@@ -212,6 +221,8 @@ union bpf_attr {
 		__aligned_u64	log_buf;	/* user supplied buffer */
 		__u32		kern_version;	/* checked when prog_type=kprobe */
 		__u32		prog_flags;
+		__aligned_u64	prog_subtype;	/* bpf_prog_subtype address */
+		__u32		prog_subtype_size;
 	};
 
 	struct { /* anonymous struct used by BPF_OBJ_* commands */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 9378f3ba2cbf..6b663dd786c6 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -970,7 +970,7 @@ struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type)
 EXPORT_SYMBOL_GPL(bpf_prog_get_type);
 
 /* last field in 'union bpf_attr' used by this command */
-#define	BPF_PROG_LOAD_LAST_FIELD prog_flags
+#define	BPF_PROG_LOAD_LAST_FIELD prog_subtype_size
 
 static int bpf_prog_load(union bpf_attr *attr)
 {
@@ -1034,6 +1034,26 @@ static int bpf_prog_load(union bpf_attr *attr)
 	if (err < 0)
 		goto free_prog;
 
+	/* copy eBPF program subtype from user space */
+	if (attr->prog_subtype) {
+		u32 size;
+
+		err = check_uarg_tail_zero(u64_to_user_ptr(attr->prog_subtype),
+					   sizeof(prog->subtype),
+					   attr->prog_subtype_size);
+		if (err)
+			goto free_prog;
+		size = min_t(u32, attr->prog_subtype_size, sizeof(prog->subtype));
+
+		/* prog->subtype is __GFP_ZERO */
+		if (copy_from_user(&prog->subtype,
+				   u64_to_user_ptr(attr->prog_subtype), size)
+				   != 0)
+			return -EFAULT;
+		prog->has_subtype = 1;
+	} else if (attr->prog_subtype_size != 0)
+		return -EINVAL;
+
 	/* run eBPF verifier */
 	err = bpf_check(&prog, attr);
 	if (err < 0)
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index e42c096ba20d..74933f5aba0e 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -952,7 +952,8 @@ static int check_ctx_access(struct bpf_verifier_env *env, int insn_idx, int off,
 		return 0;
 
 	if (env->prog->aux->ops->is_valid_access &&
-	    env->prog->aux->ops->is_valid_access(off, size, t, &info)) {
+	    env->prog->aux->ops->is_valid_access(off, size, t, &info,
+						 &env->prog->subtype)) {
 		/* A non zero info.ctx_field_size indicates that this field is a
 		 * candidate for later verifier transformation to load the whole
 		 * field and then apply a mask when accessed with a narrower
@@ -962,7 +963,6 @@ static int check_ctx_access(struct bpf_verifier_env *env, int insn_idx, int off,
 		 */
 		env->insn_aux_data[insn_idx].ctx_field_size = info.ctx_field_size;
 		*reg_type = info.reg_type;
-
 		/* remember the offset of last byte accessed in ctx */
 		if (env->prog->aux->max_ctx_offset < off + size)
 			env->prog->aux->max_ctx_offset = off + size;
@@ -1636,7 +1636,8 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 	}
 
 	if (env->prog->aux->ops->get_func_proto)
-		fn = env->prog->aux->ops->get_func_proto(func_id);
+		fn = env->prog->aux->ops->get_func_proto(func_id,
+							 &env->prog->subtype);
 
 	if (!fn) {
 		verbose("unknown func %s#%d\n", func_id_name(func_id), func_id);
@@ -4190,7 +4191,7 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 		}
 
 patch_call_imm:
-		fn = prog->aux->ops->get_func_proto(insn->imm);
+		fn = prog->aux->ops->get_func_proto(insn->imm, &prog->subtype);
 		/* all functions that have prototype and verifier allowed
 		 * programs to call them, must be real in-kernel functions
 		 */
@@ -4233,6 +4234,14 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	struct bpf_verifier_env *env;
 	int ret = -EINVAL;
 
+	if ((*prog)->aux->ops->is_valid_subtype) {
+		if (!(*prog)->aux->ops->is_valid_subtype(&(*prog)->subtype))
+			return -EINVAL;
+	} else if ((*prog)->has_subtype) {
+		/* do not accept a subtype if the program does not handle it */
+		return -EINVAL;
+	}
+
 	/* 'struct bpf_verifier_env' can be global, but since it's not small,
 	 * allocate/free it every time bpf_check() is called
 	 */
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index dc498b605d5d..33e9e05a3220 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -492,7 +492,8 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 	}
 }
 
-static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
+static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id,
+		const union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_perf_event_output:
@@ -506,7 +507,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 
 /* bpf+kprobe programs can access fields of 'struct pt_regs' */
 static bool kprobe_prog_is_valid_access(int off, int size, enum bpf_access_type type,
-					struct bpf_insn_access_aux *info)
+					struct bpf_insn_access_aux *info,
+					const union bpf_prog_subtype *prog_subtype)
 {
 	if (off < 0 || off >= sizeof(struct pt_regs))
 		return false;
@@ -576,7 +578,8 @@ static const struct bpf_func_proto bpf_get_stackid_proto_tp = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
-static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
+static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id,
+		const union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_perf_event_output:
@@ -589,7 +592,8 @@ static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
 }
 
 static bool tp_prog_is_valid_access(int off, int size, enum bpf_access_type type,
-				    struct bpf_insn_access_aux *info)
+				    struct bpf_insn_access_aux *info,
+				    const union bpf_prog_subtype *prog_subtype)
 {
 	if (off < sizeof(void *) || off >= PERF_MAX_TRACE_SIZE)
 		return false;
@@ -608,7 +612,8 @@ const struct bpf_verifier_ops tracepoint_prog_ops = {
 };
 
 static bool pe_prog_is_valid_access(int off, int size, enum bpf_access_type type,
-				    struct bpf_insn_access_aux *info)
+				    struct bpf_insn_access_aux *info,
+				    const union bpf_prog_subtype *prog_subtype)
 {
 	const int size_sp = FIELD_SIZEOF(struct bpf_perf_event_data,
 					 sample_period);
diff --git a/net/core/filter.c b/net/core/filter.c
index fa2115695037..dc4a75aa635f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3111,7 +3111,8 @@ static const struct bpf_func_proto bpf_setsockopt_proto = {
 };
 
 static const struct bpf_func_proto *
-bpf_base_func_proto(enum bpf_func_id func_id)
+bpf_base_func_proto(enum bpf_func_id func_id,
+		    const union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_map_lookup_elem:
@@ -3139,7 +3140,8 @@ bpf_base_func_proto(enum bpf_func_id func_id)
 }
 
 static const struct bpf_func_proto *
-sk_filter_func_proto(enum bpf_func_id func_id)
+sk_filter_func_proto(enum bpf_func_id func_id,
+		     const union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_skb_load_bytes:
@@ -3149,12 +3151,13 @@ sk_filter_func_proto(enum bpf_func_id func_id)
 	case BPF_FUNC_get_socket_uid:
 		return &bpf_get_socket_uid_proto;
 	default:
-		return bpf_base_func_proto(func_id);
+		return bpf_base_func_proto(func_id, prog_subtype);
 	}
 }
 
 static const struct bpf_func_proto *
-tc_cls_act_func_proto(enum bpf_func_id func_id)
+tc_cls_act_func_proto(enum bpf_func_id func_id,
+		      const union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_skb_store_bytes:
@@ -3216,12 +3219,13 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 	case BPF_FUNC_get_socket_uid:
 		return &bpf_get_socket_uid_proto;
 	default:
-		return bpf_base_func_proto(func_id);
+		return bpf_base_func_proto(func_id, prog_subtype);
 	}
 }
 
 static const struct bpf_func_proto *
-xdp_func_proto(enum bpf_func_id func_id)
+xdp_func_proto(enum bpf_func_id func_id,
+	       const union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_perf_event_output:
@@ -3235,12 +3239,13 @@ xdp_func_proto(enum bpf_func_id func_id)
 	case BPF_FUNC_redirect_map:
 		return &bpf_redirect_map_proto;
 	default:
-		return bpf_base_func_proto(func_id);
+		return bpf_base_func_proto(func_id, prog_subtype);
 	}
 }
 
 static const struct bpf_func_proto *
-lwt_inout_func_proto(enum bpf_func_id func_id)
+lwt_inout_func_proto(enum bpf_func_id func_id,
+		     const union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_skb_load_bytes:
@@ -3262,12 +3267,13 @@ lwt_inout_func_proto(enum bpf_func_id func_id)
 	case BPF_FUNC_skb_under_cgroup:
 		return &bpf_skb_under_cgroup_proto;
 	default:
-		return bpf_base_func_proto(func_id);
+		return bpf_base_func_proto(func_id, prog_subtype);
 	}
 }
 
 static const struct bpf_func_proto *
-	sock_ops_func_proto(enum bpf_func_id func_id)
+	sock_ops_func_proto(enum bpf_func_id func_id,
+			    const union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_setsockopt:
@@ -3275,11 +3281,13 @@ static const struct bpf_func_proto *
 	case BPF_FUNC_sock_map_update:
 		return &bpf_sock_map_update_proto;
 	default:
-		return bpf_base_func_proto(func_id);
+		return bpf_base_func_proto(func_id, prog_subtype);
 	}
 }
 
-static const struct bpf_func_proto *sk_skb_func_proto(enum bpf_func_id func_id)
+static const struct bpf_func_proto *
+sk_skb_func_proto(enum bpf_func_id func_id,
+		  const union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_skb_store_bytes:
@@ -3299,12 +3307,13 @@ static const struct bpf_func_proto *sk_skb_func_proto(enum bpf_func_id func_id)
 	case BPF_FUNC_sk_redirect_map:
 		return &bpf_sk_redirect_map_proto;
 	default:
-		return bpf_base_func_proto(func_id);
+		return bpf_base_func_proto(func_id, prog_subtype);
 	}
 }
 
 static const struct bpf_func_proto *
-lwt_xmit_func_proto(enum bpf_func_id func_id)
+lwt_xmit_func_proto(enum bpf_func_id func_id,
+		    const union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_skb_get_tunnel_key:
@@ -3334,12 +3343,13 @@ lwt_xmit_func_proto(enum bpf_func_id func_id)
 	case BPF_FUNC_set_hash_invalid:
 		return &bpf_set_hash_invalid_proto;
 	default:
-		return lwt_inout_func_proto(func_id);
+		return lwt_inout_func_proto(func_id, prog_subtype);
 	}
 }
 
 static bool bpf_skb_is_valid_access(int off, int size, enum bpf_access_type type,
-				    struct bpf_insn_access_aux *info)
+				    struct bpf_insn_access_aux *info,
+			            const union bpf_prog_subtype *prog_subtype)
 {
 	const int size_default = sizeof(__u32);
 
@@ -3381,7 +3391,8 @@ static bool bpf_skb_is_valid_access(int off, int size, enum bpf_access_type type
 
 static bool sk_filter_is_valid_access(int off, int size,
 				      enum bpf_access_type type,
-				      struct bpf_insn_access_aux *info)
+				      struct bpf_insn_access_aux *info,
+				      const union bpf_prog_subtype *prog_subtype)
 {
 	switch (off) {
 	case bpf_ctx_range(struct __sk_buff, tc_classid):
@@ -3400,12 +3411,13 @@ static bool sk_filter_is_valid_access(int off, int size,
 		}
 	}
 
-	return bpf_skb_is_valid_access(off, size, type, info);
+	return bpf_skb_is_valid_access(off, size, type, info, prog_subtype);
 }
 
 static bool lwt_is_valid_access(int off, int size,
 				enum bpf_access_type type,
-				struct bpf_insn_access_aux *info)
+				struct bpf_insn_access_aux *info,
+				const union bpf_prog_subtype *prog_subtype)
 {
 	switch (off) {
 	case bpf_ctx_range(struct __sk_buff, tc_classid):
@@ -3433,12 +3445,13 @@ static bool lwt_is_valid_access(int off, int size,
 		break;
 	}
 
-	return bpf_skb_is_valid_access(off, size, type, info);
+	return bpf_skb_is_valid_access(off, size, type, info, prog_subtype);
 }
 
 static bool sock_filter_is_valid_access(int off, int size,
 					enum bpf_access_type type,
-					struct bpf_insn_access_aux *info)
+					struct bpf_insn_access_aux *info,
+					const union bpf_prog_subtype *prog_subtype)
 {
 	if (type == BPF_WRITE) {
 		switch (off) {
@@ -3507,7 +3520,8 @@ static int tc_cls_act_prologue(struct bpf_insn *insn_buf, bool direct_write,
 
 static bool tc_cls_act_is_valid_access(int off, int size,
 				       enum bpf_access_type type,
-				       struct bpf_insn_access_aux *info)
+				       struct bpf_insn_access_aux *info,
+				       const union bpf_prog_subtype *prog_subtype)
 {
 	if (type == BPF_WRITE) {
 		switch (off) {
@@ -3533,7 +3547,7 @@ static bool tc_cls_act_is_valid_access(int off, int size,
 		return false;
 	}
 
-	return bpf_skb_is_valid_access(off, size, type, info);
+	return bpf_skb_is_valid_access(off, size, type, info, prog_subtype);
 }
 
 static bool __is_valid_xdp_access(int off, int size)
@@ -3550,7 +3564,8 @@ static bool __is_valid_xdp_access(int off, int size)
 
 static bool xdp_is_valid_access(int off, int size,
 				enum bpf_access_type type,
-				struct bpf_insn_access_aux *info)
+				struct bpf_insn_access_aux *info,
+				const union bpf_prog_subtype *prog_subtype)
 {
 	if (type == BPF_WRITE)
 		return false;
@@ -3593,7 +3608,8 @@ static bool __is_valid_sock_ops_access(int off, int size)
 
 static bool sock_ops_is_valid_access(int off, int size,
 				     enum bpf_access_type type,
-				     struct bpf_insn_access_aux *info)
+				     struct bpf_insn_access_aux *info,
+			             const union bpf_prog_subtype *prog_subtype)
 {
 	if (type == BPF_WRITE) {
 		switch (off) {
@@ -3616,7 +3632,8 @@ static int sk_skb_prologue(struct bpf_insn *insn_buf, bool direct_write,
 
 static bool sk_skb_is_valid_access(int off, int size,
 				   enum bpf_access_type type,
-				   struct bpf_insn_access_aux *info)
+				   struct bpf_insn_access_aux *info,
+			           const union bpf_prog_subtype *prog_subtype)
 {
 	if (type == BPF_WRITE) {
 		switch (off) {
@@ -3640,7 +3657,7 @@ static bool sk_skb_is_valid_access(int off, int size,
 		break;
 	}
 
-	return bpf_skb_is_valid_access(off, size, type, info);
+	return bpf_skb_is_valid_access(off, size, type, info, prog_subtype);
 }
 
 static u32 bpf_convert_ctx_access(enum bpf_access_type type,
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 6aa50098dfb8..01a506f768da 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -71,6 +71,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	char buf[256];
 	int fd, efd, err, id;
 	struct perf_event_attr attr = {};
+	union bpf_prog_subtype *st = NULL;
 
 	attr.type = PERF_TYPE_TRACEPOINT;
 	attr.sample_type = PERF_SAMPLE_RAW;
@@ -101,7 +102,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	}
 
 	fd = bpf_load_program(prog_type, prog, insns_cnt, license, kern_version,
-			      bpf_log_buf, BPF_LOG_BUF_SIZE);
+			      bpf_log_buf, BPF_LOG_BUF_SIZE, st);
 	if (fd < 0) {
 		printf("bpf_load_program() err=%d\n%s", errno, bpf_log_buf);
 		return -1;
diff --git a/samples/bpf/cookie_uid_helper_example.c b/samples/bpf/cookie_uid_helper_example.c
index 9d751e209f31..df457c07d35d 100644
--- a/samples/bpf/cookie_uid_helper_example.c
+++ b/samples/bpf/cookie_uid_helper_example.c
@@ -159,7 +159,7 @@ static void prog_load(void)
 	};
 	prog_fd = bpf_load_program(BPF_PROG_TYPE_SOCKET_FILTER, prog,
 					ARRAY_SIZE(prog), "GPL", 0,
-					log_buf, sizeof(log_buf));
+					log_buf, sizeof(log_buf), NULL);
 	if (prog_fd < 0)
 		error(1, errno, "failed to load prog\n%s\n", log_buf);
 }
diff --git a/samples/bpf/fds_example.c b/samples/bpf/fds_example.c
index e29bd52ff9e8..0f4f5f6a9f9f 100644
--- a/samples/bpf/fds_example.c
+++ b/samples/bpf/fds_example.c
@@ -62,7 +62,7 @@ static int bpf_prog_create(const char *object)
 	} else {
 		return bpf_load_program(BPF_PROG_TYPE_SOCKET_FILTER,
 					insns, insns_cnt, "GPL", 0,
-					bpf_log_buf, BPF_LOG_BUF_SIZE);
+					bpf_log_buf, BPF_LOG_BUF_SIZE, NULL);
 	}
 }
 
diff --git a/samples/bpf/sock_example.c b/samples/bpf/sock_example.c
index 6fc6e193ef1b..3778f66deb76 100644
--- a/samples/bpf/sock_example.c
+++ b/samples/bpf/sock_example.c
@@ -60,7 +60,8 @@ static int test_sock(void)
 	size_t insns_cnt = sizeof(prog) / sizeof(struct bpf_insn);
 
 	prog_fd = bpf_load_program(BPF_PROG_TYPE_SOCKET_FILTER, prog, insns_cnt,
-				   "GPL", 0, bpf_log_buf, BPF_LOG_BUF_SIZE);
+				   "GPL", 0, bpf_log_buf, BPF_LOG_BUF_SIZE,
+				   NULL);
 	if (prog_fd < 0) {
 		printf("failed to load prog '%s'\n", strerror(errno));
 		goto cleanup;
diff --git a/samples/bpf/test_cgrp2_attach.c b/samples/bpf/test_cgrp2_attach.c
index 4bfcaf93fcf3..f8a91d2b7896 100644
--- a/samples/bpf/test_cgrp2_attach.c
+++ b/samples/bpf/test_cgrp2_attach.c
@@ -72,7 +72,7 @@ static int prog_load(int map_fd, int verdict)
 
 	return bpf_load_program(BPF_PROG_TYPE_CGROUP_SKB,
 				prog, insns_cnt, "GPL", 0,
-				bpf_log_buf, BPF_LOG_BUF_SIZE);
+				bpf_log_buf, BPF_LOG_BUF_SIZE, NULL);
 }
 
 static int usage(const char *argv0)
diff --git a/samples/bpf/test_cgrp2_attach2.c b/samples/bpf/test_cgrp2_attach2.c
index 3049b1f26267..31a0f4bd665f 100644
--- a/samples/bpf/test_cgrp2_attach2.c
+++ b/samples/bpf/test_cgrp2_attach2.c
@@ -45,7 +45,7 @@ static int prog_load(int verdict)
 
 	ret = bpf_load_program(BPF_PROG_TYPE_CGROUP_SKB,
 			       prog, insns_cnt, "GPL", 0,
-			       bpf_log_buf, BPF_LOG_BUF_SIZE);
+			       bpf_log_buf, BPF_LOG_BUF_SIZE, NULL);
 
 	if (ret < 0) {
 		log_err("Loading program");
diff --git a/samples/bpf/test_cgrp2_sock.c b/samples/bpf/test_cgrp2_sock.c
index c3cfb23e23b5..697f2db30e6a 100644
--- a/samples/bpf/test_cgrp2_sock.c
+++ b/samples/bpf/test_cgrp2_sock.c
@@ -38,7 +38,7 @@ static int prog_load(int idx)
 	size_t insns_cnt = sizeof(prog) / sizeof(struct bpf_insn);
 
 	return bpf_load_program(BPF_PROG_TYPE_CGROUP_SOCK, prog, insns_cnt,
-				"GPL", 0, bpf_log_buf, BPF_LOG_BUF_SIZE);
+				"GPL", 0, bpf_log_buf, BPF_LOG_BUF_SIZE, NULL);
 }
 
 static int usage(const char *argv0)
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index f8f6377fd541..2c0dc9d58ea0 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -180,6 +180,15 @@ enum bpf_sockmap_flags {
 /* Specify numa node during map creation */
 #define BPF_F_NUMA_NODE		(1U << 2)
 
+union bpf_prog_subtype {
+	struct {
+		__u32		abi; /* minimal ABI version, cf. user doc */
+		__u32		event; /* enum landlock_subtype_event */
+		__aligned_u64	ability; /* LANDLOCK_SUBTYPE_ABILITY_* */
+		__aligned_u64	option; /* LANDLOCK_SUBTYPE_OPTION_* */
+	} landlock_rule;
+} __attribute__((aligned(8)));
+
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
 		__u32	map_type;	/* one of enum bpf_map_type */
@@ -215,6 +224,8 @@ union bpf_attr {
 		__aligned_u64	log_buf;	/* user supplied buffer */
 		__u32		kern_version;	/* checked when prog_type=kprobe */
 		__u32		prog_flags;
+		__aligned_u64	prog_subtype;	/* bpf_prog_subtype address */
+		__u32		prog_subtype_size;
 	};
 
 	struct { /* anonymous struct used by BPF_OBJ_* commands */
diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index a0717610b116..a11cace703f3 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -116,7 +116,8 @@ int bpf_create_map_in_map(enum bpf_map_type map_type, int key_size,
 
 int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 		     size_t insns_cnt, const char *license,
-		     __u32 kern_version, char *log_buf, size_t log_buf_sz)
+		     __u32 kern_version, char *log_buf, size_t log_buf_sz,
+		     const union bpf_prog_subtype *subtype)
 {
 	int fd;
 	union bpf_attr attr;
@@ -130,6 +131,8 @@ int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 	attr.log_size = 0;
 	attr.log_level = 0;
 	attr.kern_version = kern_version;
+	attr.prog_subtype = ptr_to_u64(subtype);
+	attr.prog_subtype_size = subtype ? sizeof(*subtype) : 0;
 
 	fd = sys_bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
 	if (fd >= 0 || !log_buf || !log_buf_sz)
@@ -146,7 +149,8 @@ int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 int bpf_verify_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 		       size_t insns_cnt, int strict_alignment,
 		       const char *license, __u32 kern_version,
-		       char *log_buf, size_t log_buf_sz, int log_level)
+		       char *log_buf, size_t log_buf_sz, int log_level,
+		       const union bpf_prog_subtype *subtype)
 {
 	union bpf_attr attr;
 
@@ -160,6 +164,8 @@ int bpf_verify_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 	attr.log_level = log_level;
 	log_buf[0] = 0;
 	attr.kern_version = kern_version;
+	attr.prog_subtype = ptr_to_u64(subtype);
+	attr.prog_subtype_size = subtype ? sizeof(*subtype) : 0;
 	attr.prog_flags = strict_alignment ? BPF_F_STRICT_ALIGNMENT : 0;
 
 	return sys_bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index 90e9d4e85d08..bc66469cd1a4 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -40,11 +40,12 @@ int bpf_create_map_in_map(enum bpf_map_type map_type, int key_size,
 int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 		     size_t insns_cnt, const char *license,
 		     __u32 kern_version, char *log_buf,
-		     size_t log_buf_sz);
+		     size_t log_buf_sz, const union bpf_prog_subtype *subtype);
 int bpf_verify_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 		       size_t insns_cnt, int strict_alignment,
 		       const char *license, __u32 kern_version,
-		       char *log_buf, size_t log_buf_sz, int log_level);
+		       char *log_buf, size_t log_buf_sz, int log_level,
+		       const union bpf_prog_subtype *subtype);
 
 int bpf_map_update_elem(int fd, const void *key, const void *value,
 			__u64 flags);
diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index 1cc3ea0ffdc3..ff59af4c1282 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -995,7 +995,7 @@ load_program(enum bpf_prog_type type, struct bpf_insn *insns,
 		pr_warning("Alloc log buffer for bpf loader error, continue without log\n");
 
 	ret = bpf_load_program(type, insns, insns_cnt, license,
-			       kern_version, log_buf, BPF_LOG_BUF_SIZE);
+			       kern_version, log_buf, BPF_LOG_BUF_SIZE, NULL);
 
 	if (ret >= 0) {
 		*pfd = ret;
@@ -1022,7 +1022,7 @@ load_program(enum bpf_prog_type type, struct bpf_insn *insns,
 
 			fd = bpf_load_program(BPF_PROG_TYPE_KPROBE, insns,
 					      insns_cnt, license, kern_version,
-					      NULL, 0);
+					      NULL, 0, NULL);
 			if (fd >= 0) {
 				close(fd);
 				ret = -LIBBPF_ERRNO__PROGTYPE;
diff --git a/tools/perf/tests/bpf.c b/tools/perf/tests/bpf.c
index 5876da126b58..a9585470275e 100644
--- a/tools/perf/tests/bpf.c
+++ b/tools/perf/tests/bpf.c
@@ -310,7 +310,7 @@ static int check_env(void)
 
 	err = bpf_load_program(BPF_PROG_TYPE_KPROBE, insns,
 			       sizeof(insns) / sizeof(insns[0]),
-			       license, kver_int, NULL, 0);
+			       license, kver_int, NULL, 0, NULL);
 	if (err < 0) {
 		pr_err("Missing basic BPF support, skip this test: %s\n",
 		       strerror(errno));
diff --git a/tools/testing/selftests/bpf/test_align.c b/tools/testing/selftests/bpf/test_align.c
index 8591c89c0828..46d528936b04 100644
--- a/tools/testing/selftests/bpf/test_align.c
+++ b/tools/testing/selftests/bpf/test_align.c
@@ -629,7 +629,7 @@ static int do_test_single(struct bpf_align_test *test)
 	prog_len = probe_filter_length(prog);
 	fd_prog = bpf_verify_program(prog_type ? : BPF_PROG_TYPE_SOCKET_FILTER,
 				     prog, prog_len, 1, "GPL", 0,
-				     bpf_vlog, sizeof(bpf_vlog), 2);
+				     bpf_vlog, sizeof(bpf_vlog), 2, NULL);
 	if (fd_prog < 0 && test->result != REJECT) {
 		printf("Failed to load program.\n");
 		printf("%s", bpf_vlog);
diff --git a/tools/testing/selftests/bpf/test_tag.c b/tools/testing/selftests/bpf/test_tag.c
index de409fc50c35..cf7892c87b5a 100644
--- a/tools/testing/selftests/bpf/test_tag.c
+++ b/tools/testing/selftests/bpf/test_tag.c
@@ -57,7 +57,7 @@ static int bpf_try_load_prog(int insns, int fd_map,
 
 	bpf_filler(insns, fd_map);
 	fd_prog = bpf_load_program(BPF_PROG_TYPE_SCHED_CLS, prog, insns, "", 0,
-				   NULL, 0);
+				   NULL, 0, NULL);
 	assert(fd_prog > 0);
 	if (fd_map > 0)
 		bpf_filler(insns, 0);
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index c03542c417db..3146839a51bf 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -68,6 +68,8 @@ struct bpf_test {
 	} result, result_unpriv;
 	enum bpf_prog_type prog_type;
 	uint8_t flags;
+	bool has_prog_subtype;
+	union bpf_prog_subtype prog_subtype;
 };
 
 /* Note we want this to be 64 bit aligned so that the end of our array is
@@ -6487,6 +6489,16 @@ static struct bpf_test tests[] = {
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_LWT_IN,
 	},
+	{
+		"superfluous subtype",
+		.insns = {
+			BPF_MOV32_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "",
+		.result = REJECT,
+		.has_prog_subtype = true,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
@@ -6602,6 +6614,8 @@ static void do_test_single(struct bpf_test *test, bool unpriv,
 	int map_fds[MAX_NR_MAPS];
 	const char *expected_err;
 	int i;
+	union bpf_prog_subtype *prog_subtype =
+		test->has_prog_subtype ? &test->prog_subtype : NULL;
 
 	for (i = 0; i < MAX_NR_MAPS; i++)
 		map_fds[i] = -1;
@@ -6610,7 +6624,8 @@ static void do_test_single(struct bpf_test *test, bool unpriv,
 
 	fd_prog = bpf_verify_program(prog_type ? : BPF_PROG_TYPE_SOCKET_FILTER,
 				     prog, prog_len, test->flags & F_LOAD_WITH_STRICT_ALIGNMENT,
-				     "GPL", 0, bpf_vlog, sizeof(bpf_vlog), 1);
+				     "GPL", 0, bpf_vlog, sizeof(bpf_vlog), 1,
+				     prog_subtype);
 
 	expected_ret = unpriv && test->result_unpriv != UNDEF ?
 		       test->result_unpriv : test->result;
-- 
2.14.1
