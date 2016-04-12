From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/5] bpf, verifier: add bpf_call_arg_meta for passing meta data
Date: Wed, 13 Apr 2016 00:10:50 +0200
Message-ID: <cb4d47b254633d35fd6e77e2b8e045bc6bb4761e.1460497071.git.daniel@iogearbox.net>
References: <cover.1460497071.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, bblanco@plumgrid.com,
	brendan.d.gregg@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34331 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932656AbcDLWLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 18:11:10 -0400
In-Reply-To: <cover.1460497071.git.daniel@iogearbox.net>
In-Reply-To: <cover.1460497071.git.daniel@iogearbox.net>
References: <cover.1460497071.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, when the verifier checks calls in check_call() function, we
call check_func_arg() for all 5 arguments e.g. to make sure expected types
are correct. In some cases, we collect meta data (here: map pointer) to
perform additional checks such as checking stack boundary on key/value
sizes for subsequent arguments. As we're going to extend the meta data,
add a generic struct bpf_call_arg_meta that we can use for passing into
check_func_arg().

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c | 40 +++++++++++++++++++++++-----------------
 1 file changed, 23 insertions(+), 17 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 6c5d7cd..202f8f7 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -205,6 +205,10 @@ struct verifier_env {
 #define BPF_COMPLEXITY_LIMIT_INSNS	65536
 #define BPF_COMPLEXITY_LIMIT_STACK	1024
 
+struct bpf_call_arg_meta {
+	struct bpf_map *map_ptr;
+};
+
 /* verbose verifier prints what it's seeing
  * bpf_check() is called under lock, so no race to access these global vars
  */
@@ -822,7 +826,8 @@ static int check_stack_boundary(struct verifier_env *env, int regno,
 }
 
 static int check_func_arg(struct verifier_env *env, u32 regno,
-			  enum bpf_arg_type arg_type, struct bpf_map **mapp)
+			  enum bpf_arg_type arg_type,
+			  struct bpf_call_arg_meta *meta)
 {
 	struct reg_state *reg = env->cur_state.regs + regno;
 	enum bpf_reg_type expected_type;
@@ -875,14 +880,13 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 
 	if (arg_type == ARG_CONST_MAP_PTR) {
 		/* bpf_map_xxx(map_ptr) call: remember that map_ptr */
-		*mapp = reg->map_ptr;
-
+		meta->map_ptr = reg->map_ptr;
 	} else if (arg_type == ARG_PTR_TO_MAP_KEY) {
 		/* bpf_map_xxx(..., map_ptr, ..., key) call:
 		 * check that [key, key + map->key_size) are within
 		 * stack limits and initialized
 		 */
-		if (!*mapp) {
+		if (!meta->map_ptr) {
 			/* in function declaration map_ptr must come before
 			 * map_key, so that it's verified and known before
 			 * we have to check map_key here. Otherwise it means
@@ -891,19 +895,19 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 			verbose("invalid map_ptr to access map->key\n");
 			return -EACCES;
 		}
-		err = check_stack_boundary(env, regno, (*mapp)->key_size,
+		err = check_stack_boundary(env, regno, meta->map_ptr->key_size,
 					   false);
 	} else if (arg_type == ARG_PTR_TO_MAP_VALUE) {
 		/* bpf_map_xxx(..., map_ptr, ..., value) call:
 		 * check [value, value + map->value_size) validity
 		 */
-		if (!*mapp) {
+		if (!meta->map_ptr) {
 			/* kernel subsystem misconfigured verifier */
 			verbose("invalid map_ptr to access map->value\n");
 			return -EACCES;
 		}
-		err = check_stack_boundary(env, regno, (*mapp)->value_size,
-					   false);
+		err = check_stack_boundary(env, regno,
+					   meta->map_ptr->value_size, false);
 	} else if (arg_type == ARG_CONST_STACK_SIZE ||
 		   arg_type == ARG_CONST_STACK_SIZE_OR_ZERO) {
 		bool zero_size_allowed = (arg_type == ARG_CONST_STACK_SIZE_OR_ZERO);
@@ -954,8 +958,8 @@ static int check_call(struct verifier_env *env, int func_id)
 	struct verifier_state *state = &env->cur_state;
 	const struct bpf_func_proto *fn = NULL;
 	struct reg_state *regs = state->regs;
-	struct bpf_map *map = NULL;
 	struct reg_state *reg;
+	struct bpf_call_arg_meta meta;
 	int i, err;
 
 	/* find function prototype */
@@ -978,20 +982,22 @@ static int check_call(struct verifier_env *env, int func_id)
 		return -EINVAL;
 	}
 
+	memset(&meta, 0, sizeof(meta));
+
 	/* check args */
-	err = check_func_arg(env, BPF_REG_1, fn->arg1_type, &map);
+	err = check_func_arg(env, BPF_REG_1, fn->arg1_type, &meta);
 	if (err)
 		return err;
-	err = check_func_arg(env, BPF_REG_2, fn->arg2_type, &map);
+	err = check_func_arg(env, BPF_REG_2, fn->arg2_type, &meta);
 	if (err)
 		return err;
-	err = check_func_arg(env, BPF_REG_3, fn->arg3_type, &map);
+	err = check_func_arg(env, BPF_REG_3, fn->arg3_type, &meta);
 	if (err)
 		return err;
-	err = check_func_arg(env, BPF_REG_4, fn->arg4_type, &map);
+	err = check_func_arg(env, BPF_REG_4, fn->arg4_type, &meta);
 	if (err)
 		return err;
-	err = check_func_arg(env, BPF_REG_5, fn->arg5_type, &map);
+	err = check_func_arg(env, BPF_REG_5, fn->arg5_type, &meta);
 	if (err)
 		return err;
 
@@ -1013,18 +1019,18 @@ static int check_call(struct verifier_env *env, int func_id)
 		 * can check 'value_size' boundary of memory access
 		 * to map element returned from bpf_map_lookup_elem()
 		 */
-		if (map == NULL) {
+		if (meta.map_ptr == NULL) {
 			verbose("kernel subsystem misconfigured verifier\n");
 			return -EINVAL;
 		}
-		regs[BPF_REG_0].map_ptr = map;
+		regs[BPF_REG_0].map_ptr = meta.map_ptr;
 	} else {
 		verbose("unknown return type %d of func %d\n",
 			fn->ret_type, func_id);
 		return -EINVAL;
 	}
 
-	err = check_map_func_compatibility(map, func_id);
+	err = check_map_func_compatibility(meta.map_ptr, func_id);
 	if (err)
 		return err;
 
-- 
1.9.3
