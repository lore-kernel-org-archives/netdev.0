From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 1/3] bpf: reduce verifier memory consumption
Date: Tue, 28 Oct 2014 15:11:41 -0700
Message-ID: <1414534303-9906-2-git-send-email-ast@plumgrid.com>
References: <1414534303-9906-1-git-send-email-ast@plumgrid.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:51031 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754888AbaJ1WL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 18:11:58 -0400
Received: by mail-pa0-f43.google.com with SMTP id eu11so1709702pac.30
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2014 15:11:57 -0700 (PDT)
In-Reply-To: <1414534303-9906-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

verifier keeps track of register state spilled to stack.
registers are 8-byte wide and always aligned, so instead of tracking them
in every byte-sized stack slot, use MAX_BPF_STACK / 8 array to track
spilled register state.
Though verifier runs in user context and its state freed immediately
after verification, it makes sense to reduce its memory usage.
This optimization reduces sizeof(struct verifier_state)
from 12464 to 1712 on 64-bit and from 6232 to 1112 on 32-bit.

Note, this patch doesn't change existing limits, which are there to bound
time and memory during verification: 4k total number of insns in a program,
1k number of jumps (states to visit) and 32k number of processed insn
(since an insn may be visited multiple times). Theoretical worst case memory
during verification is 1712 * 1k = 17Mbyte. Out-of-memory situation triggers
cleanup and rejects the program.

Suggested-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 kernel/bpf/verifier.c |  101 ++++++++++++++++++++++++++++---------------------
 1 file changed, 57 insertions(+), 44 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 9f81818f2941..b6a1f7c14a67 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -153,22 +153,19 @@ struct reg_state {
 
 enum bpf_stack_slot_type {
 	STACK_INVALID,    /* nothing was stored in this stack slot */
-	STACK_SPILL,      /* 1st byte of register spilled into stack */
-	STACK_SPILL_PART, /* other 7 bytes of register spill */
+	STACK_SPILL,      /* register spilled into stack */
 	STACK_MISC	  /* BPF program wrote some data into this slot */
 };
 
-struct bpf_stack_slot {
-	enum bpf_stack_slot_type stype;
-	struct reg_state reg_st;
-};
+#define BPF_REG_SIZE 8	/* size of eBPF register in bytes */
 
 /* state of the program:
  * type of all registers and stack info
  */
 struct verifier_state {
 	struct reg_state regs[MAX_BPF_REG];
-	struct bpf_stack_slot stack[MAX_BPF_STACK];
+	u8 stack_slot_type[MAX_BPF_STACK];
+	struct reg_state spilled_regs[MAX_BPF_STACK / BPF_REG_SIZE];
 };
 
 /* linked list of verifier states used to prune search */
@@ -259,10 +256,10 @@ static void print_verifier_state(struct verifier_env *env)
 				env->cur_state.regs[i].map_ptr->key_size,
 				env->cur_state.regs[i].map_ptr->value_size);
 	}
-	for (i = 0; i < MAX_BPF_STACK; i++) {
-		if (env->cur_state.stack[i].stype == STACK_SPILL)
+	for (i = 0; i < MAX_BPF_STACK; i += BPF_REG_SIZE) {
+		if (env->cur_state.stack_slot_type[i] == STACK_SPILL)
 			verbose(" fp%d=%s", -MAX_BPF_STACK + i,
-				reg_type_str[env->cur_state.stack[i].reg_st.type]);
+				reg_type_str[env->cur_state.spilled_regs[i / BPF_REG_SIZE].type]);
 	}
 	verbose("\n");
 }
@@ -539,8 +536,10 @@ static int bpf_size_to_bytes(int bpf_size)
 static int check_stack_write(struct verifier_state *state, int off, int size,
 			     int value_regno)
 {
-	struct bpf_stack_slot *slot;
 	int i;
+	/* caller checked that off % size == 0 and -MAX_BPF_STACK <= off < 0,
+	 * so it's aligned access and [off, off + size) are within stack limits
+	 */
 
 	if (value_regno >= 0 &&
 	    (state->regs[value_regno].type == PTR_TO_MAP_VALUE ||
@@ -548,30 +547,24 @@ static int check_stack_write(struct verifier_state *state, int off, int size,
 	     state->regs[value_regno].type == PTR_TO_CTX)) {
 
 		/* register containing pointer is being spilled into stack */
-		if (size != 8) {
+		if (size != BPF_REG_SIZE) {
 			verbose("invalid size of register spill\n");
 			return -EACCES;
 		}
 
-		slot = &state->stack[MAX_BPF_STACK + off];
-		slot->stype = STACK_SPILL;
 		/* save register state */
-		slot->reg_st = state->regs[value_regno];
-		for (i = 1; i < 8; i++) {
-			slot = &state->stack[MAX_BPF_STACK + off + i];
-			slot->stype = STACK_SPILL_PART;
-			slot->reg_st.type = UNKNOWN_VALUE;
-			slot->reg_st.map_ptr = NULL;
-		}
-	} else {
+		state->spilled_regs[(MAX_BPF_STACK + off) / BPF_REG_SIZE] =
+			state->regs[value_regno];
 
+		for (i = 0; i < BPF_REG_SIZE; i++)
+			state->stack_slot_type[MAX_BPF_STACK + off + i] = STACK_SPILL;
+	} else {
 		/* regular write of data into stack */
-		for (i = 0; i < size; i++) {
-			slot = &state->stack[MAX_BPF_STACK + off + i];
-			slot->stype = STACK_MISC;
-			slot->reg_st.type = UNKNOWN_VALUE;
-			slot->reg_st.map_ptr = NULL;
-		}
+		state->spilled_regs[(MAX_BPF_STACK + off) / BPF_REG_SIZE] =
+			(struct reg_state) {};
+
+		for (i = 0; i < size; i++)
+			state->stack_slot_type[MAX_BPF_STACK + off + i] = STACK_MISC;
 	}
 	return 0;
 }
@@ -579,19 +572,18 @@ static int check_stack_write(struct verifier_state *state, int off, int size,
 static int check_stack_read(struct verifier_state *state, int off, int size,
 			    int value_regno)
 {
+	u8 *slot_type;
 	int i;
-	struct bpf_stack_slot *slot;
 
-	slot = &state->stack[MAX_BPF_STACK + off];
+	slot_type = &state->stack_slot_type[MAX_BPF_STACK + off];
 
-	if (slot->stype == STACK_SPILL) {
-		if (size != 8) {
+	if (slot_type[0] == STACK_SPILL) {
+		if (size != BPF_REG_SIZE) {
 			verbose("invalid size of register spill\n");
 			return -EACCES;
 		}
-		for (i = 1; i < 8; i++) {
-			if (state->stack[MAX_BPF_STACK + off + i].stype !=
-			    STACK_SPILL_PART) {
+		for (i = 1; i < BPF_REG_SIZE; i++) {
+			if (slot_type[i] != STACK_SPILL) {
 				verbose("corrupted spill memory\n");
 				return -EACCES;
 			}
@@ -599,12 +591,12 @@ static int check_stack_read(struct verifier_state *state, int off, int size,
 
 		if (value_regno >= 0)
 			/* restore register state from stack */
-			state->regs[value_regno] = slot->reg_st;
+			state->regs[value_regno] =
+				state->spilled_regs[(MAX_BPF_STACK + off) / BPF_REG_SIZE];
 		return 0;
 	} else {
 		for (i = 0; i < size; i++) {
-			if (state->stack[MAX_BPF_STACK + off + i].stype !=
-			    STACK_MISC) {
+			if (slot_type[i] != STACK_MISC) {
 				verbose("invalid read from stack off %d+%d size %d\n",
 					off, i, size);
 				return -EACCES;
@@ -747,7 +739,7 @@ static int check_stack_boundary(struct verifier_env *env,
 	}
 
 	for (i = 0; i < access_size; i++) {
-		if (state->stack[MAX_BPF_STACK + off + i].stype != STACK_MISC) {
+		if (state->stack_slot_type[MAX_BPF_STACK + off + i] != STACK_MISC) {
 			verbose("invalid indirect read from stack off %d+%d size %d\n",
 				off, i, access_size);
 			return -EACCES;
@@ -1417,12 +1409,33 @@ static bool states_equal(struct verifier_state *old, struct verifier_state *cur)
 	}
 
 	for (i = 0; i < MAX_BPF_STACK; i++) {
-		if (memcmp(&old->stack[i], &cur->stack[i],
-			   sizeof(old->stack[0])) != 0) {
-			if (old->stack[i].stype == STACK_INVALID)
-				continue;
+		if (old->stack_slot_type[i] == STACK_INVALID)
+			continue;
+		if (old->stack_slot_type[i] != cur->stack_slot_type[i])
+			/* Ex: old explored (safe) state has STACK_SPILL in
+			 * this stack slot, but current has has STACK_MISC ->
+			 * this verifier states are not equivalent,
+			 * return false to continue verification of this path
+			 */
 			return false;
-		}
+		if (i % BPF_REG_SIZE)
+			continue;
+		if (memcmp(&old->spilled_regs[i / BPF_REG_SIZE],
+			   &cur->spilled_regs[i / BPF_REG_SIZE],
+			   sizeof(old->spilled_regs[0])))
+			/* when explored and current stack slot types are
+			 * the same, check that stored pointers types
+			 * are the same as well.
+			 * Ex: explored safe path could have stored
+			 * (struct reg_state) {.type = PTR_TO_STACK, .imm = -8}
+			 * but current path has stored:
+			 * (struct reg_state) {.type = PTR_TO_STACK, .imm = -16}
+			 * such verifier states are not equivalent.
+			 * return false to continue verification of this path
+			 */
+			return false;
+		else
+			continue;
 	}
 	return true;
 }
-- 
1.7.9.5
