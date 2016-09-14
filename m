From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v3 05/22] bpf,landlock: Add eBPF program subtype and is_valid_subtype() verifier
Date: Wed, 14 Sep 2016 09:23:58 +0200
Message-ID: <20160914072415.26021-6-mic@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
        linux-api@vger.kernel.org, linux-security-module@vger.
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-4590-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

The program subtype goal is to be able to have different static
fine-grained verifications for a unique program type.

The struct bpf_verifier_ops gets a new optional function:
is_valid_subtype(). This new verifier is called at the begening of the
eBPF program verification to check if the (optional) program subtype is
valid.

For now, only Landlock eBPF programs are using a program subtype but
this could be used by other program types in the future.

Cf. the next commit to see how the subtype is used by Landlock LSM.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Link: https://lkml.kernel.org/r/20160827205559.GA43880@ast-mbp.thefacebook.com
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
---
 include/linux/bpf.h      |  8 ++++++--
 include/linux/filter.h   |  1 +
 include/uapi/linux/bpf.h |  9 +++++++++
 kernel/bpf/syscall.c     |  5 +++--
 kernel/bpf/verifier.c    |  9 +++++++--
 kernel/trace/bpf_trace.c | 12 ++++++++----
 net/core/filter.c        | 21 +++++++++++++--------
 7 files changed, 47 insertions(+), 18 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index eae4ce4542c1..9aa01d9d3d80 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -149,17 +149,21 @@ struct bpf_prog;
 
 struct bpf_verifier_ops {
 	/* return eBPF function prototype for verification */
-	const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id);
+	const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id,
+			union bpf_prog_subtype *prog_subtype);
 
 	/* return true if 'size' wide access at offset 'off' within bpf_context
 	 * with 'type' (read or write) is allowed
 	 */
 	bool (*is_valid_access)(int off, int size, enum bpf_access_type type,
-				enum bpf_reg_type *reg_type);
+				enum bpf_reg_type *reg_type,
+				union bpf_prog_subtype *prog_subtype);
 
 	u32 (*convert_ctx_access)(enum bpf_access_type type, int dst_reg,
 				  int src_reg, int ctx_off,
 				  struct bpf_insn *insn, struct bpf_prog *prog);
+
+	bool (*is_valid_subtype)(union bpf_prog_subtype *prog_subtype);
 };
 
 struct bpf_prog_type_list {
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 1f09c521adfe..88470cdd3ee1 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -406,6 +406,7 @@ struct bpf_prog {
 	kmemcheck_bitfield_end(meta);
 	u32			len;		/* Number of filter blocks */
 	enum bpf_prog_type	type;		/* Type of BPF program */
+	union bpf_prog_subtype	subtype;	/* For fine-grained verifications */
 	struct bpf_prog_aux	*aux;		/* Auxiliary fields */
 	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
 	unsigned int		(*bpf_func)(const struct sk_buff *skb,
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index b68de57f7ab8..667b6ef3ff1e 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -127,6 +127,14 @@ enum bpf_attach_type {
 
 #define BPF_F_NO_PREALLOC	(1U << 0)
 
+union bpf_prog_subtype {
+	struct {
+		__u32		id; /* enum landlock_hook_id */
+		__u16		origin; /* LANDLOCK_FLAG_ORIGIN_* */
+		__aligned_u64	access; /* LANDLOCK_FLAG_ACCESS_* */
+	} landlock_hook;
+} __attribute__((aligned(8)));
+
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
 		__u32	map_type;	/* one of enum bpf_map_type */
@@ -155,6 +163,7 @@ union bpf_attr {
 		__u32		log_size;	/* size of user buffer */
 		__aligned_u64	log_buf;	/* user supplied buffer */
 		__u32		kern_version;	/* checked when prog_type=kprobe */
+		union bpf_prog_subtype prog_subtype;	/* checked when prog_type=landlock */
 	};
 
 	struct { /* anonymous struct used by BPF_OBJ_* commands */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 776c752604b0..8b3f4d2b4802 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -572,7 +572,7 @@ static void fixup_bpf_calls(struct bpf_prog *prog)
 				continue;
 			}
 
-			fn = prog->aux->ops->get_func_proto(insn->imm);
+			fn = prog->aux->ops->get_func_proto(insn->imm, &prog->subtype);
 			/* all functions that have prototype and verifier allowed
 			 * programs to call them, must be real in-kernel functions
 			 */
@@ -710,7 +710,7 @@ struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type)
 EXPORT_SYMBOL_GPL(bpf_prog_get_type);
 
 /* last field in 'union bpf_attr' used by this command */
-#define	BPF_PROG_LOAD_LAST_FIELD kern_version
+#define	BPF_PROG_LOAD_LAST_FIELD prog_subtype
 
 static int bpf_prog_load(union bpf_attr *attr)
 {
@@ -768,6 +768,7 @@ static int bpf_prog_load(union bpf_attr *attr)
 	err = find_prog_type(type, prog);
 	if (err < 0)
 		goto free_prog;
+	prog->subtype = attr->prog_subtype;
 
 	/* run eBPF verifier */
 	err = bpf_check(&prog, attr);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 608cbffb0e86..c434817e6ef4 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -684,7 +684,8 @@ static int check_ctx_access(struct verifier_env *env, int off, int size,
 			    enum bpf_access_type t, enum bpf_reg_type *reg_type)
 {
 	if (env->prog->aux->ops->is_valid_access &&
-	    env->prog->aux->ops->is_valid_access(off, size, t, reg_type)) {
+	    env->prog->aux->ops->is_valid_access(off, size, t, reg_type,
+		    &env->prog->subtype)) {
 		/* remember the offset of last byte accessed in ctx */
 		if (env->prog->aux->max_ctx_offset < off + size)
 			env->prog->aux->max_ctx_offset = off + size;
@@ -1173,7 +1174,7 @@ static int check_call(struct verifier_env *env, int func_id)
 	}
 
 	if (env->prog->aux->ops->get_func_proto)
-		fn = env->prog->aux->ops->get_func_proto(func_id);
+		fn = env->prog->aux->ops->get_func_proto(func_id, &env->prog->subtype);
 
 	if (!fn) {
 		verbose("unknown func %d\n", func_id);
@@ -2768,6 +2769,10 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	if ((*prog)->len <= 0 || (*prog)->len > BPF_MAXINSNS)
 		return -E2BIG;
 
+	if ((*prog)->aux->ops->is_valid_subtype &&
+	    !(*prog)->aux->ops->is_valid_subtype(&(*prog)->subtype))
+		return -EINVAL;
+
 	/* 'struct verifier_env' can be global, but since it's not small,
 	 * allocate/free it every time bpf_check() is called
 	 */
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 5dcb99281259..51cf0f254bf2 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -435,7 +435,8 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 	}
 }
 
-static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
+static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id,
+		union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_perf_event_output:
@@ -449,7 +450,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 
 /* bpf+kprobe programs can access fields of 'struct pt_regs' */
 static bool kprobe_prog_is_valid_access(int off, int size, enum bpf_access_type type,
-					enum bpf_reg_type *reg_type)
+					enum bpf_reg_type *reg_type,
+					union bpf_prog_subtype *prog_subtype)
 {
 	if (off < 0 || off >= sizeof(struct pt_regs))
 		return false;
@@ -517,7 +519,8 @@ static const struct bpf_func_proto bpf_get_stackid_proto_tp = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
-static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
+static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id,
+		union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_perf_event_output:
@@ -530,7 +533,8 @@ static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
 }
 
 static bool tp_prog_is_valid_access(int off, int size, enum bpf_access_type type,
-				    enum bpf_reg_type *reg_type)
+				    enum bpf_reg_type *reg_type,
+				    union bpf_prog_subtype *prog_subtype)
 {
 	if (off < sizeof(void *) || off >= PERF_MAX_TRACE_SIZE)
 		return false;
diff --git a/net/core/filter.c b/net/core/filter.c
index 9e9d99e52814..e61f02d0dd64 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2411,7 +2411,8 @@ static const struct bpf_func_proto bpf_xdp_event_output_proto = {
 };
 
 static const struct bpf_func_proto *
-sk_filter_func_proto(enum bpf_func_id func_id)
+sk_filter_func_proto(enum bpf_func_id func_id,
+		union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_map_lookup_elem:
@@ -2437,7 +2438,8 @@ sk_filter_func_proto(enum bpf_func_id func_id)
 }
 
 static const struct bpf_func_proto *
-tc_cls_act_func_proto(enum bpf_func_id func_id)
+tc_cls_act_func_proto(enum bpf_func_id func_id,
+		union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_skb_store_bytes:
@@ -2485,18 +2487,18 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 	case BPF_FUNC_skb_under_cgroup:
 		return &bpf_skb_under_cgroup_proto;
 	default:
-		return sk_filter_func_proto(func_id);
+		return sk_filter_func_proto(func_id, prog_subtype);
 	}
 }
 
 static const struct bpf_func_proto *
-xdp_func_proto(enum bpf_func_id func_id)
+xdp_func_proto(enum bpf_func_id func_id, union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_perf_event_output:
 		return &bpf_xdp_event_output_proto;
 	default:
-		return sk_filter_func_proto(func_id);
+		return sk_filter_func_proto(func_id, prog_subtype);
 	}
 }
 
@@ -2515,7 +2517,8 @@ static bool __is_valid_access(int off, int size, enum bpf_access_type type)
 
 static bool sk_filter_is_valid_access(int off, int size,
 				      enum bpf_access_type type,
-				      enum bpf_reg_type *reg_type)
+				      enum bpf_reg_type *reg_type,
+				      union bpf_prog_subtype *prog_subtype)
 {
 	switch (off) {
 	case offsetof(struct __sk_buff, tc_classid):
@@ -2539,7 +2542,8 @@ static bool sk_filter_is_valid_access(int off, int size,
 
 static bool tc_cls_act_is_valid_access(int off, int size,
 				       enum bpf_access_type type,
-				       enum bpf_reg_type *reg_type)
+				       enum bpf_reg_type *reg_type,
+				       union bpf_prog_subtype *prog_subtype)
 {
 	if (type == BPF_WRITE) {
 		switch (off) {
@@ -2582,7 +2586,8 @@ static bool __is_valid_xdp_access(int off, int size,
 
 static bool xdp_is_valid_access(int off, int size,
 				enum bpf_access_type type,
-				enum bpf_reg_type *reg_type)
+				enum bpf_reg_type *reg_type,
+				union bpf_prog_subtype *prog_subtype)
 {
 	if (type == BPF_WRITE)
 		return false;
-- 
2.9.3
