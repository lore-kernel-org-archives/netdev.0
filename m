From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/5] bpf: Add eBPF program subtype and is_valid_subtype() verifier
Date: Wed, 26 Oct 2016 17:58:39 -0700
Message-ID: <1477529922-4806-3-git-send-email-dsa@cumulusnetworks.com>
References: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch,
        David Ahern <dsa@cumulusnetworks.com>,
        =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34141 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934551AbcJ0A6v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 20:58:51 -0400
Received: by mail-pf0-f169.google.com with SMTP id n85so6095232pfi.1
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 17:58:51 -0700 (PDT)
In-Reply-To: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The program subtype's goal is to be able to have different static
fine-grained verifications for a unique program type.

The struct bpf_verifier_ops gets a new optional function:
is_valid_subtype(). This new verifier is called at the begening of the
eBPF program verification to check if the (optional) program subtype is
valid.

For now, only Landlock eBPF programs are using a program subtype but
this could be used by other program types in the future.

Cf. the next commit to see how the subtype is used by Landlock LSM.

Changes since v3:
* remove the "origin" field
* add an "option" field
* cleanup comments

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
[ Patch from Mickaël modified to add subtype arg to pe_prog_is_valid_access
  which was missing, removed the landlock references since they are not
  relevant for this use case and added cgroup struct to subtype, and
  fixed some checkpatch errors ]

---
 include/linux/bpf.h      |  7 +++++--
 include/linux/filter.h   |  1 +
 include/uapi/linux/bpf.h |  8 ++++++++
 kernel/bpf/syscall.c     |  7 +++++--
 kernel/bpf/verifier.c    | 10 ++++++++--
 kernel/trace/bpf_trace.c | 16 +++++++++++-----
 net/core/filter.c        | 26 ++++++++++++++++----------
 7 files changed, 54 insertions(+), 21 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index edcd96ded8aa..1c602a0938e8 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -152,18 +152,21 @@ struct bpf_prog;
 
 struct bpf_verifier_ops {
 	/* return eBPF function prototype for verification */
-	const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id);
+	const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id,
+					union bpf_prog_subtype *prog_subtype);
 
 	/* return true if 'size' wide access at offset 'off' within bpf_context
 	 * with 'type' (read or write) is allowed
 	 */
 	bool (*is_valid_access)(int off, int size, enum bpf_access_type type,
-				enum bpf_reg_type *reg_type);
+				enum bpf_reg_type *reg_type,
+				union bpf_prog_subtype *prog_subtype);
 	int (*gen_prologue)(struct bpf_insn *insn, bool direct_write,
 			    const struct bpf_prog *prog);
 	u32 (*convert_ctx_access)(enum bpf_access_type type, int dst_reg,
 				  int src_reg, int ctx_off,
 				  struct bpf_insn *insn, struct bpf_prog *prog);
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
index 73da296c2125..160c24ffdce2 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -118,6 +118,13 @@ enum bpf_attach_type {
 
 #define BPF_F_NO_PREALLOC	(1U << 0)
 
+union bpf_prog_subtype {
+	struct {
+		__u32 sock:1,    /* ebpf prog applies to sock struct */
+		      reserved:31;
+	} cgroup;
+} __attribute__((aligned(8)));
+
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
 		__u32	map_type;	/* one of enum bpf_map_type */
@@ -146,6 +153,7 @@ union bpf_attr {
 		__u32		log_size;	/* size of user buffer */
 		__aligned_u64	log_buf;	/* user supplied buffer */
 		__u32		kern_version;	/* checked when prog_type=kprobe */
+		union bpf_prog_subtype prog_subtype;
 	};
 
 	struct { /* anonymous struct used by BPF_OBJ_* commands */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 3c4c9ed2d576..fbf81156e49d 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -578,7 +578,9 @@ static void fixup_bpf_calls(struct bpf_prog *prog)
 				continue;
 			}
 
-			fn = prog->aux->ops->get_func_proto(insn->imm);
+			fn = prog->aux->ops->get_func_proto(insn->imm,
+							   &prog->subtype);
+
 			/* all functions that have prototype and verifier allowed
 			 * programs to call them, must be real in-kernel functions
 			 */
@@ -716,7 +718,7 @@ struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type)
 EXPORT_SYMBOL_GPL(bpf_prog_get_type);
 
 /* last field in 'union bpf_attr' used by this command */
-#define	BPF_PROG_LOAD_LAST_FIELD kern_version
+#define	BPF_PROG_LOAD_LAST_FIELD prog_subtype
 
 static int bpf_prog_load(union bpf_attr *attr)
 {
@@ -774,6 +776,7 @@ static int bpf_prog_load(union bpf_attr *attr)
 	err = find_prog_type(type, prog);
 	if (err < 0)
 		goto free_prog;
+	prog->subtype = attr->prog_subtype;
 
 	/* run eBPF verifier */
 	err = bpf_check(&prog, attr);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 846d7ceaf202..e9c660363c41 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -655,7 +655,8 @@ static int check_ctx_access(struct bpf_verifier_env *env, int off, int size,
 		return 0;
 
 	if (env->prog->aux->ops->is_valid_access &&
-	    env->prog->aux->ops->is_valid_access(off, size, t, reg_type)) {
+	    env->prog->aux->ops->is_valid_access(off, size, t, reg_type,
+						&env->prog->subtype)) {
 		/* remember the offset of last byte accessed in ctx */
 		if (env->prog->aux->max_ctx_offset < off + size)
 			env->prog->aux->max_ctx_offset = off + size;
@@ -1177,7 +1178,8 @@ static int check_call(struct bpf_verifier_env *env, int func_id)
 	}
 
 	if (env->prog->aux->ops->get_func_proto)
-		fn = env->prog->aux->ops->get_func_proto(func_id);
+		fn = env->prog->aux->ops->get_func_proto(func_id,
+							&env->prog->subtype);
 
 	if (!fn) {
 		verbose("unknown func %d\n", func_id);
@@ -3076,6 +3078,10 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	if ((*prog)->len <= 0 || (*prog)->len > BPF_MAXINSNS)
 		return -E2BIG;
 
+	if ((*prog)->aux->ops->is_valid_subtype &&
+	    !(*prog)->aux->ops->is_valid_subtype(&(*prog)->subtype))
+		return -EINVAL;
+
 	/* 'struct bpf_verifier_env' can be global, but since it's not small,
 	 * allocate/free it every time bpf_check() is called
 	 */
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index fa77311dadb2..922bf7b99811 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -437,7 +437,9 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 	}
 }
 
-static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
+static const
+struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id,
+					      union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_perf_event_output:
@@ -451,7 +453,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 
 /* bpf+kprobe programs can access fields of 'struct pt_regs' */
 static bool kprobe_prog_is_valid_access(int off, int size, enum bpf_access_type type,
-					enum bpf_reg_type *reg_type)
+					enum bpf_reg_type *reg_type,
+					union bpf_prog_subtype *prog_subtype)
 {
 	if (off < 0 || off >= sizeof(struct pt_regs))
 		return false;
@@ -519,7 +522,8 @@ static const struct bpf_func_proto bpf_get_stackid_proto_tp = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
-static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
+static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id,
+		union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_perf_event_output:
@@ -532,7 +536,8 @@ static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
 }
 
 static bool tp_prog_is_valid_access(int off, int size, enum bpf_access_type type,
-				    enum bpf_reg_type *reg_type)
+				    enum bpf_reg_type *reg_type,
+				    union bpf_prog_subtype *prog_subtype)
 {
 	if (off < sizeof(void *) || off >= PERF_MAX_TRACE_SIZE)
 		return false;
@@ -554,7 +559,8 @@ static struct bpf_prog_type_list tracepoint_tl = {
 };
 
 static bool pe_prog_is_valid_access(int off, int size, enum bpf_access_type type,
-				    enum bpf_reg_type *reg_type)
+				    enum bpf_reg_type *reg_type,
+				    union bpf_prog_subtype *prog_subtype)
 {
 	if (off < 0 || off >= sizeof(struct bpf_perf_event_data))
 		return false;
diff --git a/net/core/filter.c b/net/core/filter.c
index 61e229c3a862..4207ab2e56ba 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2483,7 +2483,8 @@ static const struct bpf_func_proto bpf_xdp_event_output_proto = {
 };
 
 static const struct bpf_func_proto *
-sk_filter_func_proto(enum bpf_func_id func_id)
+sk_filter_func_proto(enum bpf_func_id func_id,
+		     union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_map_lookup_elem:
@@ -2511,7 +2512,8 @@ sk_filter_func_proto(enum bpf_func_id func_id)
 }
 
 static const struct bpf_func_proto *
-tc_cls_act_func_proto(enum bpf_func_id func_id)
+tc_cls_act_func_proto(enum bpf_func_id func_id,
+		      union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_skb_store_bytes:
@@ -2565,12 +2567,12 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
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
@@ -2578,18 +2580,19 @@ xdp_func_proto(enum bpf_func_id func_id)
 	case BPF_FUNC_get_smp_processor_id:
 		return &bpf_get_smp_processor_id_proto;
 	default:
-		return sk_filter_func_proto(func_id);
+		return sk_filter_func_proto(func_id, prog_subtype);
 	}
 }
 
 static const struct bpf_func_proto *
-cgroup_func_proto(enum bpf_func_id func_id)
+cgroup_func_proto(enum bpf_func_id func_id,
+		  union bpf_prog_subtype *prog_subtype)
 {
 	switch (func_id) {
 	case BPF_FUNC_skb_load_bytes:
 		return &bpf_skb_load_bytes_proto;
 	default:
-		return sk_filter_func_proto(func_id);
+		return sk_filter_func_proto(func_id, prog_subtype);
 	}
 }
 
@@ -2608,7 +2611,8 @@ static bool __is_valid_access(int off, int size, enum bpf_access_type type)
 
 static bool sk_filter_is_valid_access(int off, int size,
 				      enum bpf_access_type type,
-				      enum bpf_reg_type *reg_type)
+				      enum bpf_reg_type *reg_type,
+				      union bpf_prog_subtype *prog_subtype)
 {
 	switch (off) {
 	case offsetof(struct __sk_buff, tc_classid):
@@ -2671,7 +2675,8 @@ static int tc_cls_act_prologue(struct bpf_insn *insn_buf, bool direct_write,
 
 static bool tc_cls_act_is_valid_access(int off, int size,
 				       enum bpf_access_type type,
-				       enum bpf_reg_type *reg_type)
+				       enum bpf_reg_type *reg_type,
+				       union bpf_prog_subtype *prog_subtype)
 {
 	if (type == BPF_WRITE) {
 		switch (off) {
@@ -2714,7 +2719,8 @@ static bool __is_valid_xdp_access(int off, int size,
 
 static bool xdp_is_valid_access(int off, int size,
 				enum bpf_access_type type,
-				enum bpf_reg_type *reg_type)
+				enum bpf_reg_type *reg_type,
+				union bpf_prog_subtype *prog_subtype)
 {
 	if (type == BPF_WRITE)
 		return false;
-- 
2.1.4
