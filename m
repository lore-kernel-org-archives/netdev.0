From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 5/5] bpf: rename ARG_PTR_TO_STACK
Date: Mon, 9 Jan 2017 10:19:50 -0800
Message-ID: <1483985990-1532850-6-git-send-email-ast@fb.com>
References: <1483985990-1532850-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Gianluca Borello <g.borello@gmail.com>,
        Josef Bacik <jbacik@fb.com>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:50329 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1164083AbdAISTx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 13:19:53 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v09IJfBI007392
        for <netdev@vger.kernel.org>; Mon, 9 Jan 2017 10:19:53 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 27v9y1959a-5
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 10:19:53 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 3629ae40d69811e699290002c9dfb610-2d9f5a50 for <netdev@vger.kernel.org>;        Mon,
 09 Jan 2017 10:19:51 -0800
In-Reply-To: <1483985990-1532850-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

since ARG_PTR_TO_STACK is no longer just pointer to stack
rename it to ARG_PTR_TO_MEM and adjust comment.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h      | 12 ++++++------
 kernel/bpf/helpers.c     |  4 ++--
 kernel/bpf/verifier.c    | 28 ++++++++++++++--------------
 kernel/trace/bpf_trace.c | 20 ++++++++++----------
 net/core/filter.c        | 40 ++++++++++++++++++++--------------------
 5 files changed, 52 insertions(+), 52 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index f74ae68086dc..94ea8d2383e6 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -69,14 +69,14 @@ enum bpf_arg_type {
 	/* the following constraints used to prototype bpf_memcmp() and other
 	 * functions that access data on eBPF program stack
 	 */
-	ARG_PTR_TO_STACK,	/* any pointer to eBPF program stack */
-	ARG_PTR_TO_RAW_STACK,	/* any pointer to eBPF program stack, area does not
-				 * need to be initialized, helper function must fill
-				 * all bytes or clear them in error case.
+	ARG_PTR_TO_MEM,		/* pointer to valid memory (stack, packet, map value) */
+	ARG_PTR_TO_UNINIT_MEM,	/* pointer to memory does not need to be initialized,
+				 * helper function must fill all bytes or clear
+				 * them in error case.
 				 */
 
-	ARG_CONST_STACK_SIZE,	/* number of bytes accessed from stack */
-	ARG_CONST_STACK_SIZE_OR_ZERO, /* number of bytes accessed from stack or 0 */
+	ARG_CONST_SIZE,		/* number of bytes accessed from memory */
+	ARG_CONST_SIZE_OR_ZERO,	/* number of bytes accessed from memory or 0 */
 
 	ARG_PTR_TO_CTX,		/* pointer to context */
 	ARG_ANYTHING,		/* any (initialized) argument is ok */
diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index 045cbe673356..3d24e238221e 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -176,6 +176,6 @@ const struct bpf_func_proto bpf_get_current_comm_proto = {
 	.func		= bpf_get_current_comm,
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
-	.arg1_type	= ARG_PTR_TO_RAW_STACK,
-	.arg2_type	= ARG_CONST_STACK_SIZE,
+	.arg1_type	= ARG_PTR_TO_UNINIT_MEM,
+	.arg2_type	= ARG_CONST_SIZE,
 };
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 3d4f7bf32aaf..2efdc9128e3c 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1034,8 +1034,8 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 		expected_type = PTR_TO_STACK;
 		if (type != PTR_TO_PACKET && type != expected_type)
 			goto err_type;
-	} else if (arg_type == ARG_CONST_STACK_SIZE ||
-		   arg_type == ARG_CONST_STACK_SIZE_OR_ZERO) {
+	} else if (arg_type == ARG_CONST_SIZE ||
+		   arg_type == ARG_CONST_SIZE_OR_ZERO) {
 		expected_type = CONST_IMM;
 		/* One exception. Allow UNKNOWN_VALUE registers when the
 		 * boundaries are known and don't cause unsafe memory accesses
@@ -1050,8 +1050,8 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 		expected_type = PTR_TO_CTX;
 		if (type != expected_type)
 			goto err_type;
-	} else if (arg_type == ARG_PTR_TO_STACK ||
-		   arg_type == ARG_PTR_TO_RAW_STACK) {
+	} else if (arg_type == ARG_PTR_TO_MEM ||
+		   arg_type == ARG_PTR_TO_UNINIT_MEM) {
 		expected_type = PTR_TO_STACK;
 		/* One exception here. In case function allows for NULL to be
 		 * passed in as argument, it's a CONST_IMM type. Final test
@@ -1062,7 +1062,7 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 		else if (type != PTR_TO_PACKET && type != PTR_TO_MAP_VALUE &&
 			 type != PTR_TO_MAP_VALUE_ADJ && type != expected_type)
 			goto err_type;
-		meta->raw_mode = arg_type == ARG_PTR_TO_RAW_STACK;
+		meta->raw_mode = arg_type == ARG_PTR_TO_UNINIT_MEM;
 	} else {
 		verbose("unsupported arg_type %d\n", arg_type);
 		return -EFAULT;
@@ -1108,9 +1108,9 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 			err = check_stack_boundary(env, regno,
 						   meta->map_ptr->value_size,
 						   false, NULL);
-	} else if (arg_type == ARG_CONST_STACK_SIZE ||
-		   arg_type == ARG_CONST_STACK_SIZE_OR_ZERO) {
-		bool zero_size_allowed = (arg_type == ARG_CONST_STACK_SIZE_OR_ZERO);
+	} else if (arg_type == ARG_CONST_SIZE ||
+		   arg_type == ARG_CONST_SIZE_OR_ZERO) {
+		bool zero_size_allowed = (arg_type == ARG_CONST_SIZE_OR_ZERO);
 
 		/* bpf_xxx(..., buf, len) call will access 'len' bytes
 		 * from stack pointer 'buf'. Check it
@@ -1118,7 +1118,7 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 		 */
 		if (regno == 0) {
 			/* kernel subsystem misconfigured verifier */
-			verbose("ARG_CONST_STACK_SIZE cannot be first argument\n");
+			verbose("ARG_CONST_SIZE cannot be first argument\n");
 			return -EACCES;
 		}
 
@@ -1235,15 +1235,15 @@ static int check_raw_mode(const struct bpf_func_proto *fn)
 {
 	int count = 0;
 
-	if (fn->arg1_type == ARG_PTR_TO_RAW_STACK)
+	if (fn->arg1_type == ARG_PTR_TO_UNINIT_MEM)
 		count++;
-	if (fn->arg2_type == ARG_PTR_TO_RAW_STACK)
+	if (fn->arg2_type == ARG_PTR_TO_UNINIT_MEM)
 		count++;
-	if (fn->arg3_type == ARG_PTR_TO_RAW_STACK)
+	if (fn->arg3_type == ARG_PTR_TO_UNINIT_MEM)
 		count++;
-	if (fn->arg4_type == ARG_PTR_TO_RAW_STACK)
+	if (fn->arg4_type == ARG_PTR_TO_UNINIT_MEM)
 		count++;
-	if (fn->arg5_type == ARG_PTR_TO_RAW_STACK)
+	if (fn->arg5_type == ARG_PTR_TO_UNINIT_MEM)
 		count++;
 
 	return count > 1 ? -EINVAL : 0;
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index fa77311dadb2..f883c43c96f3 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -76,8 +76,8 @@ static const struct bpf_func_proto bpf_probe_read_proto = {
 	.func		= bpf_probe_read,
 	.gpl_only	= true,
 	.ret_type	= RET_INTEGER,
-	.arg1_type	= ARG_PTR_TO_RAW_STACK,
-	.arg2_type	= ARG_CONST_STACK_SIZE,
+	.arg1_type	= ARG_PTR_TO_UNINIT_MEM,
+	.arg2_type	= ARG_CONST_SIZE,
 	.arg3_type	= ARG_ANYTHING,
 };
 
@@ -109,8 +109,8 @@ static const struct bpf_func_proto bpf_probe_write_user_proto = {
 	.gpl_only	= true,
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_ANYTHING,
-	.arg2_type	= ARG_PTR_TO_STACK,
-	.arg3_type	= ARG_CONST_STACK_SIZE,
+	.arg2_type	= ARG_PTR_TO_MEM,
+	.arg3_type	= ARG_CONST_SIZE,
 };
 
 static const struct bpf_func_proto *bpf_get_probe_write_proto(void)
@@ -213,8 +213,8 @@ static const struct bpf_func_proto bpf_trace_printk_proto = {
 	.func		= bpf_trace_printk,
 	.gpl_only	= true,
 	.ret_type	= RET_INTEGER,
-	.arg1_type	= ARG_PTR_TO_STACK,
-	.arg2_type	= ARG_CONST_STACK_SIZE,
+	.arg1_type	= ARG_PTR_TO_MEM,
+	.arg2_type	= ARG_CONST_SIZE,
 };
 
 const struct bpf_func_proto *bpf_get_trace_printk_proto(void)
@@ -329,8 +329,8 @@ static const struct bpf_func_proto bpf_perf_event_output_proto = {
 	.arg1_type	= ARG_PTR_TO_CTX,
 	.arg2_type	= ARG_CONST_MAP_PTR,
 	.arg3_type	= ARG_ANYTHING,
-	.arg4_type	= ARG_PTR_TO_STACK,
-	.arg5_type	= ARG_CONST_STACK_SIZE,
+	.arg4_type	= ARG_PTR_TO_MEM,
+	.arg5_type	= ARG_CONST_SIZE,
 };
 
 static DEFINE_PER_CPU(struct pt_regs, bpf_pt_regs);
@@ -492,8 +492,8 @@ static const struct bpf_func_proto bpf_perf_event_output_proto_tp = {
 	.arg1_type	= ARG_PTR_TO_CTX,
 	.arg2_type	= ARG_CONST_MAP_PTR,
 	.arg3_type	= ARG_ANYTHING,
-	.arg4_type	= ARG_PTR_TO_STACK,
-	.arg5_type	= ARG_CONST_STACK_SIZE,
+	.arg4_type	= ARG_PTR_TO_MEM,
+	.arg5_type	= ARG_CONST_SIZE,
 };
 
 BPF_CALL_3(bpf_get_stackid_tp, void *, tp_buff, struct bpf_map *, map,
diff --git a/net/core/filter.c b/net/core/filter.c
index 1969b3f118c1..f4d16a905754 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1416,8 +1416,8 @@ static const struct bpf_func_proto bpf_skb_store_bytes_proto = {
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_PTR_TO_CTX,
 	.arg2_type	= ARG_ANYTHING,
-	.arg3_type	= ARG_PTR_TO_STACK,
-	.arg4_type	= ARG_CONST_STACK_SIZE,
+	.arg3_type	= ARG_PTR_TO_MEM,
+	.arg4_type	= ARG_CONST_SIZE,
 	.arg5_type	= ARG_ANYTHING,
 };
 
@@ -1447,8 +1447,8 @@ static const struct bpf_func_proto bpf_skb_load_bytes_proto = {
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_PTR_TO_CTX,
 	.arg2_type	= ARG_ANYTHING,
-	.arg3_type	= ARG_PTR_TO_RAW_STACK,
-	.arg4_type	= ARG_CONST_STACK_SIZE,
+	.arg3_type	= ARG_PTR_TO_UNINIT_MEM,
+	.arg4_type	= ARG_CONST_SIZE,
 };
 
 BPF_CALL_2(bpf_skb_pull_data, struct sk_buff *, skb, u32, len)
@@ -1601,10 +1601,10 @@ static const struct bpf_func_proto bpf_csum_diff_proto = {
 	.gpl_only	= false,
 	.pkt_access	= true,
 	.ret_type	= RET_INTEGER,
-	.arg1_type	= ARG_PTR_TO_STACK,
-	.arg2_type	= ARG_CONST_STACK_SIZE_OR_ZERO,
-	.arg3_type	= ARG_PTR_TO_STACK,
-	.arg4_type	= ARG_CONST_STACK_SIZE_OR_ZERO,
+	.arg1_type	= ARG_PTR_TO_MEM,
+	.arg2_type	= ARG_CONST_SIZE_OR_ZERO,
+	.arg3_type	= ARG_PTR_TO_MEM,
+	.arg4_type	= ARG_CONST_SIZE_OR_ZERO,
 	.arg5_type	= ARG_ANYTHING,
 };
 
@@ -2306,8 +2306,8 @@ static const struct bpf_func_proto bpf_skb_event_output_proto = {
 	.arg1_type	= ARG_PTR_TO_CTX,
 	.arg2_type	= ARG_CONST_MAP_PTR,
 	.arg3_type	= ARG_ANYTHING,
-	.arg4_type	= ARG_PTR_TO_STACK,
-	.arg5_type	= ARG_CONST_STACK_SIZE,
+	.arg4_type	= ARG_PTR_TO_MEM,
+	.arg5_type	= ARG_CONST_SIZE,
 };
 
 static unsigned short bpf_tunnel_key_af(u64 flags)
@@ -2377,8 +2377,8 @@ static const struct bpf_func_proto bpf_skb_get_tunnel_key_proto = {
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_PTR_TO_CTX,
-	.arg2_type	= ARG_PTR_TO_RAW_STACK,
-	.arg3_type	= ARG_CONST_STACK_SIZE,
+	.arg2_type	= ARG_PTR_TO_UNINIT_MEM,
+	.arg3_type	= ARG_CONST_SIZE,
 	.arg4_type	= ARG_ANYTHING,
 };
 
@@ -2412,8 +2412,8 @@ static const struct bpf_func_proto bpf_skb_get_tunnel_opt_proto = {
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_PTR_TO_CTX,
-	.arg2_type	= ARG_PTR_TO_RAW_STACK,
-	.arg3_type	= ARG_CONST_STACK_SIZE,
+	.arg2_type	= ARG_PTR_TO_UNINIT_MEM,
+	.arg3_type	= ARG_CONST_SIZE,
 };
 
 static struct metadata_dst __percpu *md_dst;
@@ -2483,8 +2483,8 @@ static const struct bpf_func_proto bpf_skb_set_tunnel_key_proto = {
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_PTR_TO_CTX,
-	.arg2_type	= ARG_PTR_TO_STACK,
-	.arg3_type	= ARG_CONST_STACK_SIZE,
+	.arg2_type	= ARG_PTR_TO_MEM,
+	.arg3_type	= ARG_CONST_SIZE,
 	.arg4_type	= ARG_ANYTHING,
 };
 
@@ -2509,8 +2509,8 @@ static const struct bpf_func_proto bpf_skb_set_tunnel_opt_proto = {
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_PTR_TO_CTX,
-	.arg2_type	= ARG_PTR_TO_STACK,
-	.arg3_type	= ARG_CONST_STACK_SIZE,
+	.arg2_type	= ARG_PTR_TO_MEM,
+	.arg3_type	= ARG_CONST_SIZE,
 };
 
 static const struct bpf_func_proto *
@@ -2593,8 +2593,8 @@ static const struct bpf_func_proto bpf_xdp_event_output_proto = {
 	.arg1_type	= ARG_PTR_TO_CTX,
 	.arg2_type	= ARG_CONST_MAP_PTR,
 	.arg3_type	= ARG_ANYTHING,
-	.arg4_type	= ARG_PTR_TO_STACK,
-	.arg5_type	= ARG_CONST_STACK_SIZE,
+	.arg4_type	= ARG_PTR_TO_MEM,
+	.arg5_type	= ARG_CONST_SIZE,
 };
 
 static const struct bpf_func_proto *
-- 
2.8.0
