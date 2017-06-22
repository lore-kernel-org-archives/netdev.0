From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net-next] bpf: possibly avoid extra masking for narrower load in verifier
Date: Thu, 22 Jun 2017 15:07:39 -0700
Message-ID: <20170622220739.1482337-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <ast@fb.com>, <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36635 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751221AbdFVWHm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 18:07:42 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5MM3lPd020134
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2017 15:07:41 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b8n5w0a4f-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2017 15:07:41 -0700
Received: from facebook.com (2401:db00:11:d0af:face:0:2d:0)     by
 mx-out.facebook.com (10.212.236.89) with ESMTP id
 3515bc6c579711e7bd2e0002c95209d8-a31378f0 for <netdev@vger.kernel.org>;        Thu,
 22 Jun 2017 15:07:40 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 31fd85816dbe ("bpf: permits narrower load from bpf program
context fields") permits narrower load for certain ctx fields.
The commit however will already generate a masking even if
the prog-specific ctx conversion produces the result with
narrower size.

For example, for __sk_buff->protocol, the ctx conversion
loads the data into register with 2-byte load.
A narrower 2-byte load should not generate masking.
For __sk_buff->vlan_present, the conversion function
set the result as either 0 or 1, essentially a byte.
The narrower 2-byte or 1-byte load should not generate masking.

To avoid unnecessary masking, prog-specific *_is_valid_access
now passes converted_op_size back to verifier, which indicates
the valid data width after perceived future conversion.
Based on this information, verifier is able to avoid
unnecessary marking.

Since we want more information back from prog-specific
*_is_valid_access checking, all of them are packed into
one data structure for more clarity.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Yonghong Song <yhs@fb.com>
---
 include/linux/bpf.h          | 11 +++++-
 include/linux/bpf_verifier.h |  3 +-
 kernel/bpf/verifier.c        | 29 ++++++++++----
 kernel/trace/bpf_trace.c     | 17 +++++---
 net/core/filter.c            | 92 +++++++++++++++++++++++++-------------------
 5 files changed, 97 insertions(+), 55 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 1bcbf0a..deca4e7 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -149,6 +149,15 @@ enum bpf_reg_type {
 
 struct bpf_prog;
 
+/* The information passed from prog-specific *_is_valid_access
+ * back to the verifier.
+ */
+struct bpf_insn_access_aux {
+	enum bpf_reg_type reg_type;
+	int ctx_field_size;
+	int converted_op_size;
+};
+
 struct bpf_verifier_ops {
 	/* return eBPF function prototype for verification */
 	const struct bpf_func_proto *(*get_func_proto)(enum bpf_func_id func_id);
@@ -157,7 +166,7 @@ struct bpf_verifier_ops {
 	 * with 'type' (read or write) is allowed
 	 */
 	bool (*is_valid_access)(int off, int size, enum bpf_access_type type,
-				enum bpf_reg_type *reg_type, int *ctx_field_size);
+				struct bpf_insn_access_aux *info);
 	int (*gen_prologue)(struct bpf_insn *insn, bool direct_write,
 			    const struct bpf_prog *prog);
 	u32 (*convert_ctx_access)(enum bpf_access_type type,
diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index 189741c..621076f 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -73,7 +73,8 @@ struct bpf_insn_aux_data {
 		enum bpf_reg_type ptr_type;	/* pointer type for load/store insns */
 		struct bpf_map *map_ptr;	/* pointer for call insn into lookup_elem */
 	};
-	int ctx_field_size; /* the ctx field size for load/store insns, maybe 0 */
+	int ctx_field_size; /* the ctx field size for load insn, maybe 0 */
+	int converted_op_size; /* the valid value width after perceived conversion */
 };
 
 #define MAX_USED_MAPS 64 /* max number of maps accessed by one eBPF program */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 44b97d9..74ea96e 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -761,22 +761,34 @@ static int check_packet_access(struct bpf_verifier_env *env, u32 regno, int off,
 static int check_ctx_access(struct bpf_verifier_env *env, int insn_idx, int off, int size,
 			    enum bpf_access_type t, enum bpf_reg_type *reg_type)
 {
-	int ctx_field_size = 0;
+	struct bpf_insn_access_aux info = { .reg_type = *reg_type };
 
 	/* for analyzer ctx accesses are already validated and converted */
 	if (env->analyzer_ops)
 		return 0;
 
 	if (env->prog->aux->ops->is_valid_access &&
-	    env->prog->aux->ops->is_valid_access(off, size, t, reg_type, &ctx_field_size)) {
-		/* a non zero ctx_field_size indicates:
+	    env->prog->aux->ops->is_valid_access(off, size, t, &info)) {
+		/* a non zero info.ctx_field_size indicates:
 		 * . For this field, the prog type specific ctx conversion algorithm
 		 *   only supports whole field access.
 		 * . This ctx access is a candiate for later verifier transformation
 		 *   to load the whole field and then apply a mask to get correct result.
+		 * a non zero info.converted_op_size indicates perceived actual converted
+		 * value width in convert_ctx_access.
 		 */
-		if (ctx_field_size)
-			env->insn_aux_data[insn_idx].ctx_field_size = ctx_field_size;
+		if ((info.ctx_field_size && !info.converted_op_size) ||
+		    (!info.ctx_field_size &&  info.converted_op_size)) {
+			verbose("verifier bug in is_valid_access prog type=%u off=%d size=%d\n",
+				env->prog->type, off, size);
+			return -EACCES;
+		}
+
+		if (info.ctx_field_size) {
+			env->insn_aux_data[insn_idx].ctx_field_size = info.ctx_field_size;
+			env->insn_aux_data[insn_idx].converted_op_size = info.converted_op_size;
+		}
+		*reg_type = info.reg_type;
 
 		/* remember the offset of last byte accessed in ctx */
 		if (env->prog->aux->max_ctx_offset < off + size)
@@ -3388,7 +3400,7 @@ static int convert_ctx_accesses(struct bpf_verifier_env *env)
 	struct bpf_insn insn_buf[16], *insn;
 	struct bpf_prog *new_prog;
 	enum bpf_access_type type;
-	int i, cnt, off, size, ctx_field_size, is_narrower_load, delta = 0;
+	int i, cnt, off, size, ctx_field_size, converted_op_size, is_narrower_load, delta = 0;
 
 	if (ops->gen_prologue) {
 		cnt = ops->gen_prologue(insn_buf, env->seen_direct_write,
@@ -3431,7 +3443,8 @@ static int convert_ctx_accesses(struct bpf_verifier_env *env)
 		off = insn->off;
 		size = bpf_size_to_bytes(BPF_SIZE(insn->code));
 		ctx_field_size = env->insn_aux_data[i + delta].ctx_field_size;
-		is_narrower_load = (type == BPF_READ && size < ctx_field_size);
+		converted_op_size = env->insn_aux_data[i + delta].converted_op_size;
+		is_narrower_load = type == BPF_READ && size < ctx_field_size;
 
 		/* If the read access is a narrower load of the field,
 		 * convert to a 4/8-byte load, to minimum program type specific
@@ -3453,7 +3466,7 @@ static int convert_ctx_accesses(struct bpf_verifier_env *env)
 			verbose("bpf verifier is misconfigured\n");
 			return -EINVAL;
 		}
-		if (is_narrower_load) {
+		if (is_narrower_load && size < converted_op_size) {
 			if (ctx_field_size <= 4)
 				insn_buf[cnt++] = BPF_ALU32_IMM(BPF_AND, insn->dst_reg,
 							(1 << size * 8) - 1);
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 9d3ec82..97c46b4 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -479,7 +479,7 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 
 /* bpf+kprobe programs can access fields of 'struct pt_regs' */
 static bool kprobe_prog_is_valid_access(int off, int size, enum bpf_access_type type,
-					enum bpf_reg_type *reg_type, int *ctx_field_size)
+					struct bpf_insn_access_aux *info)
 {
 	if (off < 0 || off >= sizeof(struct pt_regs))
 		return false;
@@ -562,7 +562,7 @@ static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
 }
 
 static bool tp_prog_is_valid_access(int off, int size, enum bpf_access_type type,
-				    enum bpf_reg_type *reg_type, int *ctx_field_size)
+				    struct bpf_insn_access_aux *info)
 {
 	if (off < sizeof(void *) || off >= PERF_MAX_TRACE_SIZE)
 		return false;
@@ -581,7 +581,7 @@ const struct bpf_verifier_ops tracepoint_prog_ops = {
 };
 
 static bool pe_prog_is_valid_access(int off, int size, enum bpf_access_type type,
-				    enum bpf_reg_type *reg_type, int *ctx_field_size)
+				    struct bpf_insn_access_aux *info)
 {
 	int sample_period_off;
 
@@ -595,12 +595,17 @@ static bool pe_prog_is_valid_access(int off, int size, enum bpf_access_type type
 	/* permit 1, 2, 4 byte narrower and 8 normal read access to sample_period */
 	sample_period_off = offsetof(struct bpf_perf_event_data, sample_period);
 	if (off >= sample_period_off && off < sample_period_off + sizeof(__u64)) {
-		*ctx_field_size = 8;
+		int allowed;
+
 #ifdef __LITTLE_ENDIAN
-		return (off & 0x7) == 0 && size <= 8 && (size & (size - 1)) == 0;
+		allowed = (off & 0x7) == 0 && size <= 8 && (size & (size - 1)) == 0;
 #else
-		return ((off & 0x7) + size) == 8 && size <= 8 && (size & (size - 1)) == 0;
+		allowed = ((off & 0x7) + size) == 8 && size <= 8 && (size & (size - 1)) == 0;
 #endif
+		if (!allowed)
+			return false;
+		info->ctx_field_size = 8;
+		info->converted_op_size = 8;
 	} else {
 		if (size != sizeof(long))
 			return false;
diff --git a/net/core/filter.c b/net/core/filter.c
index 60ed6f3..4b78800 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2856,8 +2856,37 @@ lwt_xmit_func_proto(enum bpf_func_id func_id)
 	}
 }
 
+static void __set_access_aux_info(int off, struct bpf_insn_access_aux *info)
+{
+	info->ctx_field_size = 4;
+	switch (off) {
+	case offsetof(struct __sk_buff, pkt_type) ...
+	     offsetof(struct __sk_buff, pkt_type) + sizeof(__u32) - 1:
+	case offsetof(struct __sk_buff, vlan_present) ...
+	     offsetof(struct __sk_buff, vlan_present) + sizeof(__u32) - 1:
+		info->converted_op_size = 1;
+		break;
+	case offsetof(struct __sk_buff, queue_mapping) ...
+	     offsetof(struct __sk_buff, queue_mapping) + sizeof(__u32) - 1:
+	case offsetof(struct __sk_buff, protocol) ...
+	     offsetof(struct __sk_buff, protocol) + sizeof(__u32) - 1:
+	case offsetof(struct __sk_buff, vlan_tci) ...
+	     offsetof(struct __sk_buff, vlan_tci) + sizeof(__u32) - 1:
+	case offsetof(struct __sk_buff, vlan_proto) ...
+	     offsetof(struct __sk_buff, vlan_proto) + sizeof(__u32) - 1:
+	case offsetof(struct __sk_buff, tc_index) ...
+	     offsetof(struct __sk_buff, tc_index) + sizeof(__u32) - 1:
+	case offsetof(struct __sk_buff, tc_classid) ...
+	     offsetof(struct __sk_buff, tc_classid) + sizeof(__u32) - 1:
+		info->converted_op_size = 2;
+		break;
+	default:
+		info->converted_op_size = 4;
+	}
+}
+
 static bool __is_valid_access(int off, int size, enum bpf_access_type type,
-			      int *ctx_field_size)
+			      struct bpf_insn_access_aux *info)
 {
 	if (off < 0 || off >= sizeof(struct __sk_buff))
 		return false;
@@ -2875,24 +2904,32 @@ static bool __is_valid_access(int off, int size, enum bpf_access_type type,
 		break;
 	case offsetof(struct __sk_buff, data) ...
 	     offsetof(struct __sk_buff, data) + sizeof(__u32) - 1:
+		if (size != sizeof(__u32))
+			return false;
+		info->reg_type = PTR_TO_PACKET;
+		break;
 	case offsetof(struct __sk_buff, data_end) ...
 	     offsetof(struct __sk_buff, data_end) + sizeof(__u32) - 1:
 		if (size != sizeof(__u32))
 			return false;
+		info->reg_type = PTR_TO_PACKET_END;
 		break;
 	default:
-		/* permit narrower load for not cb/data/data_end fields */
-		*ctx_field_size = 4;
 		if (type == BPF_WRITE) {
 			if (size != sizeof(__u32))
 				return false;
 		} else {
-			if (size != sizeof(__u32))
+			int allowed;
+
+			/* permit narrower load for not cb/data/data_end fields */
 #ifdef __LITTLE_ENDIAN
-				return (off & 0x3) == 0 && (size == 1 || size == 2);
+			allowed = (off & 0x3) == 0 && size <= 4 && (size & (size - 1)) == 0;
 #else
-				return (off & 0x3) + size == 4 && (size == 1 || size == 2);
+			allowed = (off & 0x3) + size == 4 && size <= 4 && (size & (size - 1)) == 0;
 #endif
+			if (!allowed)
+				return false;
+			__set_access_aux_info(off, info);
 		}
 	}
 
@@ -2901,8 +2938,7 @@ static bool __is_valid_access(int off, int size, enum bpf_access_type type,
 
 static bool sk_filter_is_valid_access(int off, int size,
 				      enum bpf_access_type type,
-				      enum bpf_reg_type *reg_type,
-				      int *ctx_field_size)
+				      struct bpf_insn_access_aux *info)
 {
 	switch (off) {
 	case offsetof(struct __sk_buff, tc_classid) ...
@@ -2924,13 +2960,12 @@ static bool sk_filter_is_valid_access(int off, int size,
 		}
 	}
 
-	return __is_valid_access(off, size, type, ctx_field_size);
+	return __is_valid_access(off, size, type, info);
 }
 
 static bool lwt_is_valid_access(int off, int size,
 				enum bpf_access_type type,
-				enum bpf_reg_type *reg_type,
-				int *ctx_field_size)
+				struct bpf_insn_access_aux *info)
 {
 	switch (off) {
 	case offsetof(struct __sk_buff, tc_classid) ...
@@ -2950,22 +2985,12 @@ static bool lwt_is_valid_access(int off, int size,
 		}
 	}
 
-	switch (off) {
-	case offsetof(struct __sk_buff, data):
-		*reg_type = PTR_TO_PACKET;
-		break;
-	case offsetof(struct __sk_buff, data_end):
-		*reg_type = PTR_TO_PACKET_END;
-		break;
-	}
-
-	return __is_valid_access(off, size, type, ctx_field_size);
+	return __is_valid_access(off, size, type, info);
 }
 
 static bool sock_filter_is_valid_access(int off, int size,
 					enum bpf_access_type type,
-					enum bpf_reg_type *reg_type,
-					int *ctx_field_size)
+					struct bpf_insn_access_aux *info)
 {
 	if (type == BPF_WRITE) {
 		switch (off) {
@@ -3028,8 +3053,7 @@ static int tc_cls_act_prologue(struct bpf_insn *insn_buf, bool direct_write,
 
 static bool tc_cls_act_is_valid_access(int off, int size,
 				       enum bpf_access_type type,
-				       enum bpf_reg_type *reg_type,
-				       int *ctx_field_size)
+				       struct bpf_insn_access_aux *info)
 {
 	if (type == BPF_WRITE) {
 		switch (off) {
@@ -3045,16 +3069,7 @@ static bool tc_cls_act_is_valid_access(int off, int size,
 		}
 	}
 
-	switch (off) {
-	case offsetof(struct __sk_buff, data):
-		*reg_type = PTR_TO_PACKET;
-		break;
-	case offsetof(struct __sk_buff, data_end):
-		*reg_type = PTR_TO_PACKET_END;
-		break;
-	}
-
-	return __is_valid_access(off, size, type, ctx_field_size);
+	return __is_valid_access(off, size, type, info);
 }
 
 static bool __is_valid_xdp_access(int off, int size)
@@ -3071,18 +3086,17 @@ static bool __is_valid_xdp_access(int off, int size)
 
 static bool xdp_is_valid_access(int off, int size,
 				enum bpf_access_type type,
-				enum bpf_reg_type *reg_type,
-				int *ctx_field_size)
+				struct bpf_insn_access_aux *info)
 {
 	if (type == BPF_WRITE)
 		return false;
 
 	switch (off) {
 	case offsetof(struct xdp_md, data):
-		*reg_type = PTR_TO_PACKET;
+		info->reg_type = PTR_TO_PACKET;
 		break;
 	case offsetof(struct xdp_md, data_end):
-		*reg_type = PTR_TO_PACKET_END;
+		info->reg_type = PTR_TO_PACKET_END;
 		break;
 	}
 
-- 
2.9.3
