From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Subject: [PATCH net-next v6 01/11] bpf: Add eBPF program subtype and is_valid_subtype() verifier
Date: Wed, 29 Mar 2017 01:46:40 +0200
Message-ID: <20170328234650.19695-2-mic@digikod.net>
References: <20170328234650.19695-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>,
        Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        Shuah Khan <shuah-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Tejun Heo <tj@k
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170328234650.19695-1-mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The goal of the program subtype is to be able to have different static
fine-grained verifications for a unique program type.

The struct bpf_verifier_ops gets a new optional function:
is_valid_subtype(). This new verifier is called at the beginning of the
eBPF program verification to check if the (optional) program subtype is
valid.

For now, only Landlock eBPF programs are using a program subtype (see
next commit) but this could be used by other program types in the future.

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

Signed-off-by: Mickaël Salaün <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Cc: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Link: https://lkml.kernel.org/r/20160827205559.GA43880-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org
---
 include/linux/bpf.h                         |  7 ++-
 include/linux/filter.h                      |  2 +
 include/uapi/linux/bpf.h                    | 11 ++++
 kernel/bpf/syscall.c                        | 89 +++++++++++++++++++----------
 kernel/bpf/verifier.c                       | 16 +++++-
 kernel/trace/bpf_trace.c                    | 15 +++--
 net/core/filter.c                           | 48 ++++++++++------
 samples/bpf/bpf_load.c                      |  3 +-
 samples/bpf/cookie_uid_helper_example.c     |  2 +-
 samples/bpf/fds_example.c                   |  2 +-
 samples/bpf/sock_example.c                  |  3 +-
 samples/bpf/test_cgrp2_attach.c             |  2 +-
 samples/bpf/test_cgrp2_attach2.c            |  2 +-
 samples/bpf/test_cgrp2_sock.c               |  2 +-
 tools/include/uapi/linux/bpf.h              | 11 ++++
 tools/lib/bpf/bpf.c                         |  5 +-
 tools/lib/bpf/bpf.h                         |  2 +-
 tools/lib/bpf/libbpf.c                      |  4 +-
 tools/perf/tests/bpf.c                      |  2 +-
 tools/testing/selftests/bpf/test_tag.c      |  2 +-
 tools/testing/selftests/bpf/test_verifier.c | 16 +++++-
 21 files changed, 175 insertions(+), 71 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 2ae39a3e9ead..1cb407bd8ef7 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -156,19 +156,22 @@ struct bpf_prog;
 
 struct bpf_verifier_ops {
 	/* return eBPF function prototype for verification */
-	const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id);
+	const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id,
+				      union bpf_prog_subtype *prog_subtype);
 
 	/* return true if 'size' wide access at offset 'off' within bpf_context
 	 * with 'type' (read or write) is allowed
 	 */
 	bool (*is_valid_access)(int off, int size, enum bpf_access_type type,
-				enum bpf_reg_type *reg_type);
+				enum bpf_reg_type *reg_type,
+				union bpf_prog_subtype *prog_subtype);
 	int (*gen_prologue)(struct bpf_insn *insn, bool direct_write,
 			    const struct bpf_prog *prog);
 	u32 (*convert_ctx_access)(enum bpf_access_type type,
 				  const struct bpf_insn *src,
 				  struct bpf_insn *dst,
 				  struct bpf_prog *prog);
+	bool (*is_valid_subtype)(union bpf_prog_subtype *prog_subtype);
 };
 
 struct bpf_prog_type_list {
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 511fe910bf1d..f5eb40a9aaa1 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -419,6 +419,8 @@ struct bpf_prog {
 	enum bpf_prog_type	type;		/* Type of BPF program */
 	u32			len;		/* Number of filter blocks */
 	u8			tag[BPF_TAG_SIZE];
+	u8			has_subtype;
+	union bpf_prog_subtype	subtype;	/* Fine-grained verifications */
 	struct bpf_prog_aux	*aux;		/* Auxiliary fields */
 	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
 	unsigned int		(*bpf_func)(const void *ctx,
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 28317a04c34d..0eb71ab9b4fd 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -147,6 +147,15 @@ enum bpf_attach_type {
  */
 #define BPF_F_NO_COMMON_LRU	(1U << 1)
 
+union bpf_prog_subtype {
+	struct {
+		__u32		version; /* cf. documentation */
+		__u32		event; /* enum landlock_subtype_event */
+		__aligned_u64	ability; /* LANDLOCK_SUBTYPE_ABILITY_* */
+		__aligned_u64	option; /* LANDLOCK_SUBTYPE_OPTION_* */
+	} landlock_rule;
+} __attribute__((aligned(8)));
+
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
 		__u32	map_type;	/* one of enum bpf_map_type */
@@ -176,6 +185,8 @@ union bpf_attr {
 		__u32		log_size;	/* size of user buffer */
 		__aligned_u64	log_buf;	/* user supplied buffer */
 		__u32		kern_version;	/* checked when prog_type=kprobe */
+		__aligned_u64	prog_subtype;	/* bpf_prog_subtype address */
+		__u32		prog_subtype_size;
 	};
 
 	struct { /* anonymous struct used by BPF_OBJ_* commands */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index c35ebfe6d84d..3d07b10ade5e 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -783,8 +783,44 @@ struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type)
 }
 EXPORT_SYMBOL_GPL(bpf_prog_get_type);
 
+static int check_user_buf(void __user *uptr, unsigned int size_req,
+			  unsigned int size_max)
+{
+	if (!access_ok(VERIFY_READ, uptr, 1))
+		return -EFAULT;
+
+	if (size_req > PAGE_SIZE)	/* silly large */
+		return -E2BIG;
+
+	/* If we're handed a bigger struct than we know of,
+	 * ensure all the unknown bits are 0 - i.e. new
+	 * user-space does not rely on any kernel feature
+	 * extensions we dont know about yet.
+	 */
+	if (size_req > size_max) {
+		unsigned char __user *addr;
+		unsigned char __user *end;
+		unsigned char val;
+		int err;
+
+		addr = uptr + size_max;
+		end  = uptr + size_req;
+
+		for (; addr < end; addr++) {
+			err = get_user(val, addr);
+			if (err)
+				return err;
+			if (val)
+				return -E2BIG;
+		}
+		return size_max;
+	}
+
+	return size_req;
+}
+
 /* last field in 'union bpf_attr' used by this command */
-#define	BPF_PROG_LOAD_LAST_FIELD kern_version
+#define	BPF_PROG_LOAD_LAST_FIELD prog_subtype_size
 
 static int bpf_prog_load(union bpf_attr *attr)
 {
@@ -843,6 +879,26 @@ static int bpf_prog_load(union bpf_attr *attr)
 	if (err < 0)
 		goto free_prog;
 
+	/* copy eBPF program subtype from user space */
+	if (attr->prog_subtype) {
+		__u32 size;
+
+		size = check_user_buf((void __user *)attr->prog_subtype,
+				      attr->prog_subtype_size,
+				      sizeof(prog->subtype));
+		if (size < 0) {
+			err = size;
+			goto free_prog;
+		}
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
@@ -981,34 +1037,9 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	if (!capable(CAP_SYS_ADMIN) && sysctl_unprivileged_bpf_disabled)
 		return -EPERM;
 
-	if (!access_ok(VERIFY_READ, uattr, 1))
-		return -EFAULT;
-
-	if (size > PAGE_SIZE)	/* silly large */
-		return -E2BIG;
-
-	/* If we're handed a bigger struct than we know of,
-	 * ensure all the unknown bits are 0 - i.e. new
-	 * user-space does not rely on any kernel feature
-	 * extensions we dont know about yet.
-	 */
-	if (size > sizeof(attr)) {
-		unsigned char __user *addr;
-		unsigned char __user *end;
-		unsigned char val;
-
-		addr = (void __user *)uattr + sizeof(attr);
-		end  = (void __user *)uattr + size;
-
-		for (; addr < end; addr++) {
-			err = get_user(val, addr);
-			if (err)
-				return err;
-			if (val)
-				return -E2BIG;
-		}
-		size = sizeof(attr);
-	}
+	size = check_user_buf((void __user *)uattr, size, sizeof(attr));
+	if (size < 0)
+		return size;
 
 	/* copy attributes from user space, may be less than sizeof(bpf_attr) */
 	if (copy_from_user(&attr, uattr, size) != 0)
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 09923cc5c7c7..1f44f7ce35f4 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -742,7 +742,8 @@ static int check_ctx_access(struct bpf_verifier_env *env, int off, int size,
 		return 0;
 
 	if (env->prog->aux->ops->is_valid_access &&
-	    env->prog->aux->ops->is_valid_access(off, size, t, reg_type)) {
+	    env->prog->aux->ops->is_valid_access(off, size, t, reg_type,
+						 &env->prog->subtype)) {
 		/* remember the offset of last byte accessed in ctx */
 		if (env->prog->aux->max_ctx_offset < off + size)
 			env->prog->aux->max_ctx_offset = off + size;
@@ -1296,7 +1297,8 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 	}
 
 	if (env->prog->aux->ops->get_func_proto)
-		fn = env->prog->aux->ops->get_func_proto(func_id);
+		fn = env->prog->aux->ops->get_func_proto(func_id,
+							 &env->prog->subtype);
 
 	if (!fn) {
 		verbose("unknown func %s#%d\n", func_id_name(func_id), func_id);
@@ -3365,7 +3367,7 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 		}
 
 patch_call_imm:
-		fn = prog->aux->ops->get_func_proto(insn->imm);
+		fn = prog->aux->ops->get_func_proto(insn->imm, &prog->subtype);
 		/* all functions that have prototype and verifier allowed
 		 * programs to call them, must be real in-kernel functions
 		 */
@@ -3408,6 +3410,14 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
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
index cee9802cf3e0..e71ee1bb7abf 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -469,7 +469,8 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 	}
 }
 
-static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
+static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id,
+		union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_perf_event_output:
@@ -483,7 +484,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 
 /* bpf+kprobe programs can access fields of 'struct pt_regs' */
 static bool kprobe_prog_is_valid_access(int off, int size, enum bpf_access_type type,
-					enum bpf_reg_type *reg_type)
+					enum bpf_reg_type *reg_type,
+					union bpf_prog_subtype *prog_subtype)
 {
 	if (off < 0 || off >= sizeof(struct pt_regs))
 		return false;
@@ -558,7 +560,8 @@ static const struct bpf_func_proto bpf_get_stackid_proto_tp = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
-static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
+static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id,
+		union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_perf_event_output:
@@ -571,7 +574,8 @@ static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
 }
 
 static bool tp_prog_is_valid_access(int off, int size, enum bpf_access_type type,
-				    enum bpf_reg_type *reg_type)
+				    enum bpf_reg_type *reg_type,
+				    union bpf_prog_subtype *prog_subtype)
 {
 	if (off < sizeof(void *) || off >= PERF_MAX_TRACE_SIZE)
 		return false;
@@ -595,7 +599,8 @@ static struct bpf_prog_type_list tracepoint_tl __ro_after_init = {
 };
 
 static bool pe_prog_is_valid_access(int off, int size, enum bpf_access_type type,
-				    enum bpf_reg_type *reg_type)
+				    enum bpf_reg_type *reg_type,
+				    union bpf_prog_subtype *prog_subtype)
 {
 	if (off < 0 || off >= sizeof(struct bpf_perf_event_data))
 		return false;
diff --git a/net/core/filter.c b/net/core/filter.c
index dfb9f61a2fd5..c7ef3938a598 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2638,7 +2638,8 @@ static const struct bpf_func_proto bpf_get_socket_uid_proto = {
 };
 
 static const struct bpf_func_proto *
-bpf_base_func_proto(enum bpf_func_id func_id)
+bpf_base_func_proto(enum bpf_func_id func_id,
+		    union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_map_lookup_elem:
@@ -2666,7 +2667,8 @@ bpf_base_func_proto(enum bpf_func_id func_id)
 }
 
 static const struct bpf_func_proto *
-sk_filter_func_proto(enum bpf_func_id func_id)
+sk_filter_func_proto(enum bpf_func_id func_id,
+		     union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_skb_load_bytes:
@@ -2676,12 +2678,13 @@ sk_filter_func_proto(enum bpf_func_id func_id)
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
+		      union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_skb_store_bytes:
@@ -2739,12 +2742,13 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
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
+	       union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_perf_event_output:
@@ -2754,23 +2758,25 @@ xdp_func_proto(enum bpf_func_id func_id)
 	case BPF_FUNC_xdp_adjust_head:
 		return &bpf_xdp_adjust_head_proto;
 	default:
-		return bpf_base_func_proto(func_id);
+		return bpf_base_func_proto(func_id, prog_subtype);
 	}
 }
 
 static const struct bpf_func_proto *
-cg_skb_func_proto(enum bpf_func_id func_id)
+cg_skb_func_proto(enum bpf_func_id func_id,
+		  union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_skb_load_bytes:
 		return &bpf_skb_load_bytes_proto;
 	default:
-		return bpf_base_func_proto(func_id);
+		return bpf_base_func_proto(func_id, prog_subtype);
 	}
 }
 
 static const struct bpf_func_proto *
-lwt_inout_func_proto(enum bpf_func_id func_id)
+lwt_inout_func_proto(enum bpf_func_id func_id,
+		     union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_skb_load_bytes:
@@ -2792,12 +2798,13 @@ lwt_inout_func_proto(enum bpf_func_id func_id)
 	case BPF_FUNC_skb_under_cgroup:
 		return &bpf_skb_under_cgroup_proto;
 	default:
-		return bpf_base_func_proto(func_id);
+		return bpf_base_func_proto(func_id, prog_subtype);
 	}
 }
 
 static const struct bpf_func_proto *
-lwt_xmit_func_proto(enum bpf_func_id func_id)
+lwt_xmit_func_proto(enum bpf_func_id func_id,
+		    union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_skb_get_tunnel_key:
@@ -2827,7 +2834,7 @@ lwt_xmit_func_proto(enum bpf_func_id func_id)
 	case BPF_FUNC_set_hash_invalid:
 		return &bpf_set_hash_invalid_proto;
 	default:
-		return lwt_inout_func_proto(func_id);
+		return lwt_inout_func_proto(func_id, prog_subtype);
 	}
 }
 
@@ -2857,7 +2864,8 @@ static bool __is_valid_access(int off, int size)
 
 static bool sk_filter_is_valid_access(int off, int size,
 				      enum bpf_access_type type,
-				      enum bpf_reg_type *reg_type)
+				      enum bpf_reg_type *reg_type,
+				      union bpf_prog_subtype *prog_subtype)
 {
 	switch (off) {
 	case offsetof(struct __sk_buff, tc_classid):
@@ -2881,7 +2889,8 @@ static bool sk_filter_is_valid_access(int off, int size,
 
 static bool lwt_is_valid_access(int off, int size,
 				enum bpf_access_type type,
-				enum bpf_reg_type *reg_type)
+				enum bpf_reg_type *reg_type,
+				union bpf_prog_subtype *prog_subtype)
 {
 	switch (off) {
 	case offsetof(struct __sk_buff, tc_classid):
@@ -2914,7 +2923,8 @@ static bool lwt_is_valid_access(int off, int size,
 
 static bool sock_filter_is_valid_access(int off, int size,
 					enum bpf_access_type type,
-					enum bpf_reg_type *reg_type)
+					enum bpf_reg_type *reg_type,
+					union bpf_prog_subtype *prog_subtype)
 {
 	if (type == BPF_WRITE) {
 		switch (off) {
@@ -2977,7 +2987,8 @@ static int tc_cls_act_prologue(struct bpf_insn *insn_buf, bool direct_write,
 
 static bool tc_cls_act_is_valid_access(int off, int size,
 				       enum bpf_access_type type,
-				       enum bpf_reg_type *reg_type)
+				       enum bpf_reg_type *reg_type,
+				       union bpf_prog_subtype *prog_subtype)
 {
 	if (type == BPF_WRITE) {
 		switch (off) {
@@ -3019,7 +3030,8 @@ static bool __is_valid_xdp_access(int off, int size)
 
 static bool xdp_is_valid_access(int off, int size,
 				enum bpf_access_type type,
-				enum bpf_reg_type *reg_type)
+				enum bpf_reg_type *reg_type,
+				union bpf_prog_subtype *prog_subtype)
 {
 	if (type == BPF_WRITE)
 		return false;
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index dcdce1270d38..4a3460d7c01f 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -73,6 +73,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	char buf[256];
 	int fd, efd, err, id;
 	struct perf_event_attr attr = {};
+	union bpf_prog_subtype *st = NULL;
 
 	attr.type = PERF_TYPE_TRACEPOINT;
 	attr.sample_type = PERF_SAMPLE_RAW;
@@ -99,7 +100,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	}
 
 	fd = bpf_load_program(prog_type, prog, insns_cnt, license, kern_version,
-			      bpf_log_buf, BPF_LOG_BUF_SIZE);
+			      bpf_log_buf, BPF_LOG_BUF_SIZE, st);
 	if (fd < 0) {
 		printf("bpf_load_program() err=%d\n%s", errno, bpf_log_buf);
 		return -1;
diff --git a/samples/bpf/cookie_uid_helper_example.c b/samples/bpf/cookie_uid_helper_example.c
index f6e5e58931c5..7427428312d6 100644
--- a/samples/bpf/cookie_uid_helper_example.c
+++ b/samples/bpf/cookie_uid_helper_example.c
@@ -148,7 +148,7 @@ static void prog_load(void)
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
index 1ea08ce35567..725c9a7d3dd9 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -147,6 +147,15 @@ enum bpf_attach_type {
  */
 #define BPF_F_NO_COMMON_LRU	(1U << 1)
 
+union bpf_prog_subtype {
+	struct {
+		__u32		version; /* cf. documentation */
+		__u32		event; /* enum landlock_subtype_event */
+		__aligned_u64	ability; /* LANDLOCK_SUBTYPE_ABILITY_* */
+		__aligned_u64	option; /* LANDLOCK_SUBTYPE_OPTION_* */
+	} landlock_rule;
+} __attribute__((aligned(8)));
+
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
 		__u32	map_type;	/* one of enum bpf_map_type */
@@ -176,6 +185,8 @@ union bpf_attr {
 		__u32		log_size;	/* size of user buffer */
 		__aligned_u64	log_buf;	/* user supplied buffer */
 		__u32		kern_version;	/* checked when prog_type=kprobe */
+		__aligned_u64	prog_subtype;	/* bpf_prog_subtype address */
+		__u32		prog_subtype_size;
 	};
 
 	struct { /* anonymous struct used by BPF_OBJ_* commands */
diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 9b58d20e8c93..34fa03c95389 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -88,7 +88,8 @@ int bpf_create_map_in_map(enum bpf_map_type map_type, int key_size,
 
 int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 		     size_t insns_cnt, const char *license,
-		     __u32 kern_version, char *log_buf, size_t log_buf_sz)
+		     __u32 kern_version, char *log_buf, size_t log_buf_sz,
+		     const union bpf_prog_subtype *subtype)
 {
 	int fd;
 	union bpf_attr attr;
@@ -102,6 +103,8 @@ int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 	attr.log_size = 0;
 	attr.log_level = 0;
 	attr.kern_version = kern_version;
+	attr.prog_subtype = ptr_to_u64(subtype);
+	attr.prog_subtype_size = subtype ? sizeof(*subtype) : 0;
 
 	fd = sys_bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
 	if (fd >= 0 || !log_buf || !log_buf_sz)
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index 93f021932623..dfb320653ac1 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -34,7 +34,7 @@ int bpf_create_map_in_map(enum bpf_map_type map_type, int key_size,
 int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 		     size_t insns_cnt, const char *license,
 		     __u32 kern_version, char *log_buf,
-		     size_t log_buf_sz);
+		     size_t log_buf_sz, const union bpf_prog_subtype *subtype);
 
 int bpf_map_update_elem(int fd, const void *key, const void *value,
 			__u64 flags);
diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index ac6eb863b2a4..645b0a96e66f 100644
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
index 1a04fe77487d..8ae07f5ecdc0 100644
--- a/tools/perf/tests/bpf.c
+++ b/tools/perf/tests/bpf.c
@@ -306,7 +306,7 @@ static int check_env(void)
 
 	err = bpf_load_program(BPF_PROG_TYPE_KPROBE, insns,
 			       sizeof(insns) / sizeof(insns[0]),
-			       license, kver_int, NULL, 0);
+			       license, kver_int, NULL, 0, NULL);
 	if (err < 0) {
 		pr_err("Missing basic BPF support, skip this test: %s\n",
 		       strerror(errno));
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
index f4f43c98cf7f..daa87dd7c80e 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -55,6 +55,8 @@ struct bpf_test {
 		REJECT
 	} result, result_unpriv;
 	enum bpf_prog_type prog_type;
+	bool has_prog_subtype;
+	union bpf_prog_subtype prog_subtype;
 };
 
 /* Note we want this to be 64 bit aligned so that the end of our array is
@@ -4524,6 +4526,16 @@ static struct bpf_test tests[] = {
 		.errstr = "R1 type=map_value_or_null expected=map_ptr",
 		.result = REJECT,
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
@@ -4639,6 +4651,8 @@ static void do_test_single(struct bpf_test *test, bool unpriv,
 	int fd_prog, expected_ret;
 	const char *expected_err;
 	int i;
+	union bpf_prog_subtype *prog_subtype =
+		test->has_prog_subtype ? &test->prog_subtype : NULL;
 
 	for (i = 0; i < MAX_NR_MAPS; i++)
 		map_fds[i] = -1;
@@ -4647,7 +4661,7 @@ static void do_test_single(struct bpf_test *test, bool unpriv,
 
 	fd_prog = bpf_load_program(prog_type ? : BPF_PROG_TYPE_SOCKET_FILTER,
 				   prog, prog_len, "GPL", 0, bpf_vlog,
-				   sizeof(bpf_vlog));
+				   sizeof(bpf_vlog), prog_subtype);
 
 	expected_ret = unpriv && test->result_unpriv != UNDEF ?
 		       test->result_unpriv : test->result;
-- 
2.11.0
