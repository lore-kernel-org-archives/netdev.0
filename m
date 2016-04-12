From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/5] bpf, verifier: add ARG_PTR_TO_RAW_STACK type
Date: Wed, 13 Apr 2016 00:10:51 +0200
Message-ID: <cc47b1789237bd7d9ddc6116f838f8b86125323c.1460497071.git.daniel@iogearbox.net>
References: <cover.1460497071.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, bblanco@plumgrid.com,
	brendan.d.gregg@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34342 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934073AbcDLWLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 18:11:13 -0400
In-Reply-To: <cover.1460497071.git.daniel@iogearbox.net>
In-Reply-To: <cover.1460497071.git.daniel@iogearbox.net>
References: <cover.1460497071.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When passing buffers from eBPF stack space into a helper function, we have
ARG_PTR_TO_STACK argument type for helpers available. The verifier makes sure
that such buffers are initialized, within boundaries, etc.

However, the downside with this is that we have a couple of helper functions
such as bpf_skb_load_bytes() that fill out the passed buffer in the expected
success case anyway, so zero initializing them prior to the helper call is
unneeded/wasted instructions in the eBPF program that can be avoided.

Therefore, add a new helper function argument type called ARG_PTR_TO_RAW_STACK.
The idea is to skip the STACK_MISC check in check_stack_boundary() and color
the related stack slots as STACK_MISC after we checked all call arguments.

Helper functions using ARG_PTR_TO_RAW_STACK must make sure that every path of
the helper function will fill the provided buffer area, so that we cannot leak
any uninitialized stack memory. This f.e. means that error paths need to
memset() the buffers, but the expected fast-path doesn't have to do this
anymore.

Since there's no such helper needing more than at most one ARG_PTR_TO_RAW_STACK
argument, we can keep it simple and don't need to check for multiple areas.
Should in future such a use-case really appear, we have check_raw_mode() that
will make sure we implement support for it first.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h   |  5 +++++
 kernel/bpf/verifier.c | 59 ++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 59 insertions(+), 5 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index b2365a6..5fb3c61 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -66,6 +66,11 @@ enum bpf_arg_type {
 	 * functions that access data on eBPF program stack
 	 */
 	ARG_PTR_TO_STACK,	/* any pointer to eBPF program stack */
+	ARG_PTR_TO_RAW_STACK,	/* any pointer to eBPF program stack, area does not
+				 * need to be initialized, helper function must fill
+				 * all bytes or clear them in error case.
+				 */
+
 	ARG_CONST_STACK_SIZE,	/* number of bytes accessed from stack */
 	ARG_CONST_STACK_SIZE_OR_ZERO, /* number of bytes accessed from stack or 0 */
 
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 202f8f7..9c843a5 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -207,6 +207,9 @@ struct verifier_env {
 
 struct bpf_call_arg_meta {
 	struct bpf_map *map_ptr;
+	bool raw_mode;
+	int regno;
+	int access_size;
 };
 
 /* verbose verifier prints what it's seeing
@@ -789,7 +792,8 @@ static int check_xadd(struct verifier_env *env, struct bpf_insn *insn)
  * and all elements of stack are initialized
  */
 static int check_stack_boundary(struct verifier_env *env, int regno,
-				int access_size, bool zero_size_allowed)
+				int access_size, bool zero_size_allowed,
+				struct bpf_call_arg_meta *meta)
 {
 	struct verifier_state *state = &env->cur_state;
 	struct reg_state *regs = state->regs;
@@ -815,6 +819,12 @@ static int check_stack_boundary(struct verifier_env *env, int regno,
 		return -EACCES;
 	}
 
+	if (meta && meta->raw_mode) {
+		meta->access_size = access_size;
+		meta->regno = regno;
+		return 0;
+	}
+
 	for (i = 0; i < access_size; i++) {
 		if (state->stack_slot_type[MAX_BPF_STACK + off + i] != STACK_MISC) {
 			verbose("invalid indirect read from stack off %d+%d size %d\n",
@@ -859,7 +869,8 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 		expected_type = CONST_PTR_TO_MAP;
 	} else if (arg_type == ARG_PTR_TO_CTX) {
 		expected_type = PTR_TO_CTX;
-	} else if (arg_type == ARG_PTR_TO_STACK) {
+	} else if (arg_type == ARG_PTR_TO_STACK ||
+		   arg_type == ARG_PTR_TO_RAW_STACK) {
 		expected_type = PTR_TO_STACK;
 		/* One exception here. In case function allows for NULL to be
 		 * passed in as argument, it's a CONST_IMM type. Final test
@@ -867,6 +878,7 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 		 */
 		if (reg->type == CONST_IMM && reg->imm == 0)
 			expected_type = CONST_IMM;
+		meta->raw_mode = arg_type == ARG_PTR_TO_RAW_STACK;
 	} else {
 		verbose("unsupported arg_type %d\n", arg_type);
 		return -EFAULT;
@@ -896,7 +908,7 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 			return -EACCES;
 		}
 		err = check_stack_boundary(env, regno, meta->map_ptr->key_size,
-					   false);
+					   false, NULL);
 	} else if (arg_type == ARG_PTR_TO_MAP_VALUE) {
 		/* bpf_map_xxx(..., map_ptr, ..., value) call:
 		 * check [value, value + map->value_size) validity
@@ -907,7 +919,8 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 			return -EACCES;
 		}
 		err = check_stack_boundary(env, regno,
-					   meta->map_ptr->value_size, false);
+					   meta->map_ptr->value_size,
+					   false, NULL);
 	} else if (arg_type == ARG_CONST_STACK_SIZE ||
 		   arg_type == ARG_CONST_STACK_SIZE_OR_ZERO) {
 		bool zero_size_allowed = (arg_type == ARG_CONST_STACK_SIZE_OR_ZERO);
@@ -922,7 +935,7 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 			return -EACCES;
 		}
 		err = check_stack_boundary(env, regno - 1, reg->imm,
-					   zero_size_allowed);
+					   zero_size_allowed, meta);
 	}
 
 	return err;
@@ -953,6 +966,24 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 	return 0;
 }
 
+static int check_raw_mode(const struct bpf_func_proto *fn)
+{
+	int count = 0;
+
+	if (fn->arg1_type == ARG_PTR_TO_RAW_STACK)
+		count++;
+	if (fn->arg2_type == ARG_PTR_TO_RAW_STACK)
+		count++;
+	if (fn->arg3_type == ARG_PTR_TO_RAW_STACK)
+		count++;
+	if (fn->arg4_type == ARG_PTR_TO_RAW_STACK)
+		count++;
+	if (fn->arg5_type == ARG_PTR_TO_RAW_STACK)
+		count++;
+
+	return count > 1 ? -EINVAL : 0;
+}
+
 static int check_call(struct verifier_env *env, int func_id)
 {
 	struct verifier_state *state = &env->cur_state;
@@ -984,6 +1015,15 @@ static int check_call(struct verifier_env *env, int func_id)
 
 	memset(&meta, 0, sizeof(meta));
 
+	/* We only support one arg being in raw mode at the moment, which
+	 * is sufficient for the helper functions we have right now.
+	 */
+	err = check_raw_mode(fn);
+	if (err) {
+		verbose("kernel subsystem misconfigured func %d\n", func_id);
+		return err;
+	}
+
 	/* check args */
 	err = check_func_arg(env, BPF_REG_1, fn->arg1_type, &meta);
 	if (err)
@@ -1001,6 +1041,15 @@ static int check_call(struct verifier_env *env, int func_id)
 	if (err)
 		return err;
 
+	/* Mark slots with STACK_MISC in case of raw mode, stack offset
+	 * is inferred from register state.
+	 */
+	for (i = 0; i < meta.access_size; i++) {
+		err = check_mem_access(env, meta.regno, i, BPF_B, BPF_WRITE, -1);
+		if (err)
+			return err;
+	}
+
 	/* reset caller saved regs */
 	for (i = 0; i < CALLER_SAVED_REGS; i++) {
 		reg = regs + caller_saved[i];
-- 
1.9.3
