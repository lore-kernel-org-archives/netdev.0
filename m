From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 1/3] bpf: allow helpers access the packet directly
Date: Thu, 11 Aug 2016 18:17:16 -0700
Message-ID: <1470964638-1313057-2-git-send-email-ast@fb.com>
References: <1470964638-1313057-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:44862 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751207AbcHLBRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 21:17:22 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7C1HE4o015937
	for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 18:17:21 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 24s0h1s9kp-5
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 18:17:21 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 83a1d650602a11e693a60002c992ebde-57c806e0 for <netdev@vger.kernel.org>;	Thu,
 11 Aug 2016 18:17:19 -0700
In-Reply-To: <1470964638-1313057-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The helper functions like bpf_map_lookup_elem(map, key) were only
allowing 'key' to point to the initialized stack area.
That is causing performance degradation when programs need to process
millions of packets per second and need to copy contents of the packet
into the stack just to pass the stack pointer into the lookup() function.
Allow such helpers read from the packet directly.
All helpers that expect ARG_PTR_TO_MAP_KEY, ARG_PTR_TO_MAP_VALUE,
ARG_PTR_TO_STACK assume byte aligned pointer, so no alignment concerns,
only need to check that helper will not be accessing beyond
the packet range verified by the prior 'if (ptr < data_end)' condition.
For now allow this feature for XDP programs only. Later it can be
relaxed for the clsact programs as well.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c | 61 ++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 43 insertions(+), 18 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 7094c69ac199..202e4a8b2805 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -930,14 +930,14 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 			  enum bpf_arg_type arg_type,
 			  struct bpf_call_arg_meta *meta)
 {
-	struct reg_state *reg = env->cur_state.regs + regno;
-	enum bpf_reg_type expected_type;
+	struct reg_state *regs = env->cur_state.regs, *reg = &regs[regno];
+	enum bpf_reg_type expected_type, type = reg->type;
 	int err = 0;
 
 	if (arg_type == ARG_DONTCARE)
 		return 0;
 
-	if (reg->type == NOT_INIT) {
+	if (type == NOT_INIT) {
 		verbose("R%d !read_ok\n", regno);
 		return -EACCES;
 	}
@@ -950,16 +950,29 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 		return 0;
 	}
 
+	if (type == PTR_TO_PACKET && !may_write_pkt_data(env->prog->type)) {
+		verbose("helper access to the packet is not allowed for clsact\n");
+		return -EACCES;
+	}
+
 	if (arg_type == ARG_PTR_TO_MAP_KEY ||
 	    arg_type == ARG_PTR_TO_MAP_VALUE) {
 		expected_type = PTR_TO_STACK;
+		if (type != PTR_TO_PACKET && type != expected_type)
+			goto err_type;
 	} else if (arg_type == ARG_CONST_STACK_SIZE ||
 		   arg_type == ARG_CONST_STACK_SIZE_OR_ZERO) {
 		expected_type = CONST_IMM;
+		if (type != expected_type)
+			goto err_type;
 	} else if (arg_type == ARG_CONST_MAP_PTR) {
 		expected_type = CONST_PTR_TO_MAP;
+		if (type != expected_type)
+			goto err_type;
 	} else if (arg_type == ARG_PTR_TO_CTX) {
 		expected_type = PTR_TO_CTX;
+		if (type != expected_type)
+			goto err_type;
 	} else if (arg_type == ARG_PTR_TO_STACK ||
 		   arg_type == ARG_PTR_TO_RAW_STACK) {
 		expected_type = PTR_TO_STACK;
@@ -967,20 +980,16 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 		 * passed in as argument, it's a CONST_IMM type. Final test
 		 * happens during stack boundary checking.
 		 */
-		if (reg->type == CONST_IMM && reg->imm == 0)
-			expected_type = CONST_IMM;
+		if (type == CONST_IMM && reg->imm == 0)
+			/* final test in check_stack_boundary() */;
+		else if (type != PTR_TO_PACKET && type != expected_type)
+			goto err_type;
 		meta->raw_mode = arg_type == ARG_PTR_TO_RAW_STACK;
 	} else {
 		verbose("unsupported arg_type %d\n", arg_type);
 		return -EFAULT;
 	}
 
-	if (reg->type != expected_type) {
-		verbose("R%d type=%s expected=%s\n", regno,
-			reg_type_str[reg->type], reg_type_str[expected_type]);
-		return -EACCES;
-	}
-
 	if (arg_type == ARG_CONST_MAP_PTR) {
 		/* bpf_map_xxx(map_ptr) call: remember that map_ptr */
 		meta->map_ptr = reg->map_ptr;
@@ -998,8 +1007,13 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 			verbose("invalid map_ptr to access map->key\n");
 			return -EACCES;
 		}
-		err = check_stack_boundary(env, regno, meta->map_ptr->key_size,
-					   false, NULL);
+		if (type == PTR_TO_PACKET)
+			err = check_packet_access(env, regno, 0,
+						  meta->map_ptr->key_size);
+		else
+			err = check_stack_boundary(env, regno,
+						   meta->map_ptr->key_size,
+						   false, NULL);
 	} else if (arg_type == ARG_PTR_TO_MAP_VALUE) {
 		/* bpf_map_xxx(..., map_ptr, ..., value) call:
 		 * check [value, value + map->value_size) validity
@@ -1009,9 +1023,13 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 			verbose("invalid map_ptr to access map->value\n");
 			return -EACCES;
 		}
-		err = check_stack_boundary(env, regno,
-					   meta->map_ptr->value_size,
-					   false, NULL);
+		if (type == PTR_TO_PACKET)
+			err = check_packet_access(env, regno, 0,
+						  meta->map_ptr->value_size);
+		else
+			err = check_stack_boundary(env, regno,
+						   meta->map_ptr->value_size,
+						   false, NULL);
 	} else if (arg_type == ARG_CONST_STACK_SIZE ||
 		   arg_type == ARG_CONST_STACK_SIZE_OR_ZERO) {
 		bool zero_size_allowed = (arg_type == ARG_CONST_STACK_SIZE_OR_ZERO);
@@ -1025,11 +1043,18 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 			verbose("ARG_CONST_STACK_SIZE cannot be first argument\n");
 			return -EACCES;
 		}
-		err = check_stack_boundary(env, regno - 1, reg->imm,
-					   zero_size_allowed, meta);
+		if (regs[regno - 1].type == PTR_TO_PACKET)
+			err = check_packet_access(env, regno - 1, 0, reg->imm);
+		else
+			err = check_stack_boundary(env, regno - 1, reg->imm,
+						   zero_size_allowed, meta);
 	}
 
 	return err;
+err_type:
+	verbose("R%d type=%s expected=%s\n", regno,
+		reg_type_str[type], reg_type_str[expected_type]);
+	return -EACCES;
 }
 
 static int check_map_func_compatibility(struct bpf_map *map, int func_id)
-- 
2.8.0
