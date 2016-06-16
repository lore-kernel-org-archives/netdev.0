From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net 1/2] bpf: fix matching of data/data_end in verifier
Date: Wed, 15 Jun 2016 18:25:38 -0700
Message-ID: <1466040339-3756110-2-git-send-email-ast@fb.com>
References: <1466040339-3756110-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Sasha Goldshtein <goldshtn@gmail.com>,
	<netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:21214 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753247AbcFPBZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 21:25:42 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5G1OLMg031822
	for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 18:25:41 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 23k7kv2pjs-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 18:25:41 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 3c666ff8336111e6910d0002c9dfb610-54d366e0 for <netdev@vger.kernel.org>;	Wed,
 15 Jun 2016 18:25:39 -0700
In-Reply-To: <1466040339-3756110-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ctx structure passed into bpf programs is different depending on bpf
program type. The verifier incorrectly marked ctx->data and ctx->data_end
access based on ctx offset only. That caused loads in tracing programs
int bpf_prog(struct pt_regs *ctx) { .. ctx->ax .. }
to be incorrectly marked as PTR_TO_PACKET which later caused verifier
to reject the program that was actually valid in tracing context.
Fix this by doing program type specific matching of ctx offsets.

Fixes: 969bf05eb3ce ("bpf: direct packet access")
Reported-by: Sasha Goldshtein <goldshtn@gmail.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h      | 28 +++++++++++++++++++++++++++-
 kernel/bpf/verifier.c    | 41 +++++++----------------------------------
 kernel/trace/bpf_trace.c |  6 ++++--
 net/core/filter.c        | 16 ++++++++++++++--
 4 files changed, 52 insertions(+), 39 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 8ee27b8afe81..8269cafc6eb1 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -111,6 +111,31 @@ enum bpf_access_type {
 	BPF_WRITE = 2
 };
 
+/* types of values stored in eBPF registers */
+enum bpf_reg_type {
+	NOT_INIT = 0,		 /* nothing was written into register */
+	UNKNOWN_VALUE,		 /* reg doesn't contain a valid pointer */
+	PTR_TO_CTX,		 /* reg points to bpf_context */
+	CONST_PTR_TO_MAP,	 /* reg points to struct bpf_map */
+	PTR_TO_MAP_VALUE,	 /* reg points to map element value */
+	PTR_TO_MAP_VALUE_OR_NULL,/* points to map elem value or NULL */
+	FRAME_PTR,		 /* reg == frame_pointer */
+	PTR_TO_STACK,		 /* reg == frame_pointer + imm */
+	CONST_IMM,		 /* constant integer value */
+
+	/* PTR_TO_PACKET represents:
+	 * skb->data
+	 * skb->data + imm
+	 * skb->data + (u16) var
+	 * skb->data + (u16) var + imm
+	 * if (range > 0) then [ptr, ptr + range - off) is safe to access
+	 * if (id > 0) means that some 'var' was added
+	 * if (off > 0) menas that 'imm' was added
+	 */
+	PTR_TO_PACKET,
+	PTR_TO_PACKET_END,	 /* skb->data + headlen */
+};
+
 struct bpf_prog;
 
 struct bpf_verifier_ops {
@@ -120,7 +145,8 @@ struct bpf_verifier_ops {
 	/* return true if 'size' wide access at offset 'off' within bpf_context
 	 * with 'type' (read or write) is allowed
 	 */
-	bool (*is_valid_access)(int off, int size, enum bpf_access_type type);
+	bool (*is_valid_access)(int off, int size, enum bpf_access_type type,
+				enum bpf_reg_type *reg_type);
 
 	u32 (*convert_ctx_access)(enum bpf_access_type type, int dst_reg,
 				  int src_reg, int ctx_off,
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 668e07903c8f..eec9f90ba030 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -126,31 +126,6 @@
  * are set to NOT_INIT to indicate that they are no longer readable.
  */
 
-/* types of values stored in eBPF registers */
-enum bpf_reg_type {
-	NOT_INIT = 0,		 /* nothing was written into register */
-	UNKNOWN_VALUE,		 /* reg doesn't contain a valid pointer */
-	PTR_TO_CTX,		 /* reg points to bpf_context */
-	CONST_PTR_TO_MAP,	 /* reg points to struct bpf_map */
-	PTR_TO_MAP_VALUE,	 /* reg points to map element value */
-	PTR_TO_MAP_VALUE_OR_NULL,/* points to map elem value or NULL */
-	FRAME_PTR,		 /* reg == frame_pointer */
-	PTR_TO_STACK,		 /* reg == frame_pointer + imm */
-	CONST_IMM,		 /* constant integer value */
-
-	/* PTR_TO_PACKET represents:
-	 * skb->data
-	 * skb->data + imm
-	 * skb->data + (u16) var
-	 * skb->data + (u16) var + imm
-	 * if (range > 0) then [ptr, ptr + range - off) is safe to access
-	 * if (id > 0) means that some 'var' was added
-	 * if (off > 0) menas that 'imm' was added
-	 */
-	PTR_TO_PACKET,
-	PTR_TO_PACKET_END,	 /* skb->data + headlen */
-};
-
 struct reg_state {
 	enum bpf_reg_type type;
 	union {
@@ -695,10 +670,10 @@ static int check_packet_access(struct verifier_env *env, u32 regno, int off,
 
 /* check access to 'struct bpf_context' fields */
 static int check_ctx_access(struct verifier_env *env, int off, int size,
-			    enum bpf_access_type t)
+			    enum bpf_access_type t, enum bpf_reg_type *reg_type)
 {
 	if (env->prog->aux->ops->is_valid_access &&
-	    env->prog->aux->ops->is_valid_access(off, size, t)) {
+	    env->prog->aux->ops->is_valid_access(off, size, t, reg_type)) {
 		/* remember the offset of last byte accessed in ctx */
 		if (env->prog->aux->max_ctx_offset < off + size)
 			env->prog->aux->max_ctx_offset = off + size;
@@ -798,21 +773,19 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
 			mark_reg_unknown_value(state->regs, value_regno);
 
 	} else if (reg->type == PTR_TO_CTX) {
+		enum bpf_reg_type reg_type = UNKNOWN_VALUE;
+
 		if (t == BPF_WRITE && value_regno >= 0 &&
 		    is_pointer_value(env, value_regno)) {
 			verbose("R%d leaks addr into ctx\n", value_regno);
 			return -EACCES;
 		}
-		err = check_ctx_access(env, off, size, t);
+		err = check_ctx_access(env, off, size, t, &reg_type);
 		if (!err && t == BPF_READ && value_regno >= 0) {
 			mark_reg_unknown_value(state->regs, value_regno);
-			if (off == offsetof(struct __sk_buff, data) &&
-			    env->allow_ptr_leaks)
+			if (env->allow_ptr_leaks)
 				/* note that reg.[id|off|range] == 0 */
-				state->regs[value_regno].type = PTR_TO_PACKET;
-			else if (off == offsetof(struct __sk_buff, data_end) &&
-				 env->allow_ptr_leaks)
-				state->regs[value_regno].type = PTR_TO_PACKET_END;
+				state->regs[value_regno].type = reg_type;
 		}
 
 	} else if (reg->type == FRAME_PTR || reg->type == PTR_TO_STACK) {
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 720b7bb01d43..e7af6cb9d5cf 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -349,7 +349,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 }
 
 /* bpf+kprobe programs can access fields of 'struct pt_regs' */
-static bool kprobe_prog_is_valid_access(int off, int size, enum bpf_access_type type)
+static bool kprobe_prog_is_valid_access(int off, int size, enum bpf_access_type type,
+					enum bpf_reg_type *reg_type)
 {
 	/* check bounds */
 	if (off < 0 || off >= sizeof(struct pt_regs))
@@ -427,7 +428,8 @@ static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
 	}
 }
 
-static bool tp_prog_is_valid_access(int off, int size, enum bpf_access_type type)
+static bool tp_prog_is_valid_access(int off, int size, enum bpf_access_type type,
+				    enum bpf_reg_type *reg_type)
 {
 	if (off < sizeof(void *) || off >= PERF_MAX_TRACE_SIZE)
 		return false;
diff --git a/net/core/filter.c b/net/core/filter.c
index 68adb5f52110..c4b330c85c02 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2085,7 +2085,8 @@ static bool __is_valid_access(int off, int size, enum bpf_access_type type)
 }
 
 static bool sk_filter_is_valid_access(int off, int size,
-				      enum bpf_access_type type)
+				      enum bpf_access_type type,
+				      enum bpf_reg_type *reg_type)
 {
 	switch (off) {
 	case offsetof(struct __sk_buff, tc_classid):
@@ -2108,7 +2109,8 @@ static bool sk_filter_is_valid_access(int off, int size,
 }
 
 static bool tc_cls_act_is_valid_access(int off, int size,
-				       enum bpf_access_type type)
+				       enum bpf_access_type type,
+				       enum bpf_reg_type *reg_type)
 {
 	if (type == BPF_WRITE) {
 		switch (off) {
@@ -2123,6 +2125,16 @@ static bool tc_cls_act_is_valid_access(int off, int size,
 			return false;
 		}
 	}
+
+	switch (off) {
+	case offsetof(struct __sk_buff, data):
+		*reg_type = PTR_TO_PACKET;
+		break;
+	case offsetof(struct __sk_buff, data_end):
+		*reg_type = PTR_TO_PACKET_END;
+		break;
+	}
+
 	return __is_valid_access(off, size, type);
 }
 
-- 
2.8.0
