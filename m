From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v5 net-next 15/29] bpf: verifier (add state prunning optimization)
Date: Sun, 24 Aug 2014 13:21:16 -0700
Message-ID: <1408911690-7598-16-git-send-email-ast@plumgrid.com>
References: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Namhyung Kim <namhyung@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

since verifier walks all possible paths it's important to recognize
equivalent verifier states to speed up verification.

If one of the old states is more strict than the current state, it means
the current state doesn't need to be explored further, since verifier already
concluded that more strict state leads to valid bpf_exit.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 kernel/bpf/verifier.c |  134 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 134 insertions(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 14a0262b101c..49374066a5bd 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -220,6 +220,7 @@ struct verifier_env {
 	struct verifier_stack_elem *head; /* stack of verifier states to be processed */
 	int stack_size;			/* number of states to be processed */
 	struct verifier_state cur_state; /* current verifier state */
+	struct verifier_state_list **branch_landing; /* search prunning optimization */
 	struct bpf_map *used_maps[MAX_USED_MAPS]; /* array of map's used by eBPF program */
 	u32 used_map_cnt;		/* number of used maps */
 };
@@ -1256,6 +1257,8 @@ enum {
 	BRANCH = 2,
 };
 
+#define STATE_END ((struct verifier_state_list *) -1L)
+
 #define PUSH_INT(I) \
 	do { \
 		if (cur_stack >= insn_cnt) { \
@@ -1297,6 +1300,9 @@ enum {
 			ret = -EINVAL; \
 			goto free_st; \
 		} \
+		if (E == BRANCH) \
+			/* mark branch target for state pruning */ \
+			env->branch_landing[w] = STATE_END; \
 		if (st[w] == 0) { \
 			/* tree-edge */ \
 			st[T] = DISCOVERED | E; \
@@ -1364,6 +1370,10 @@ peek_stack:
 				PUSH_INSN(t, t + 1, FALLTHROUGH);
 				PUSH_INSN(t, t + insns[t].off + 1, BRANCH);
 			}
+			/* tell verifier to check for equivalent verifier states
+			 * after every call and jump
+			 */
+			env->branch_landing[t + 1] = STATE_END;
 		} else {
 			/* all other non-branch instructions with single
 			 * fall-through edge
@@ -1395,6 +1405,88 @@ free_st:
 	return ret;
 }
 
+/* compare two verifier states
+ *
+ * all states stored in state_list are known to be valid, since
+ * verifier reached 'bpf_exit' instruction through them
+ *
+ * this function is called when verifier exploring different branches of
+ * execution popped from the state stack. If it sees an old state that has
+ * more strict register state and more strict stack state then this execution
+ * branch doesn't need to be explored further, since verifier already
+ * concluded that more strict state leads to valid finish.
+ *
+ * Therefore two states are equivalent if register state is more conservative
+ * and explored stack state is more conservative than the current one.
+ * Example:
+ *       explored                   current
+ * (slot1=INV slot2=MISC) == (slot1=MISC slot2=MISC)
+ * (slot1=MISC slot2=MISC) != (slot1=INV slot2=MISC)
+ *
+ * In other words if current stack state (one being explored) has more
+ * valid slots than old one that already passed validation, it means
+ * the verifier can stop exploring and conclude that current state is valid too
+ *
+ * Similarly with registers. If explored state has register type as invalid
+ * whereas register type in current state is meaningful, it means that
+ * the current state will reach 'bpf_exit' instruction safely
+ */
+static bool states_equal(struct verifier_state *old, struct verifier_state *cur)
+{
+	int i;
+
+	for (i = 0; i < MAX_BPF_REG; i++) {
+		if (memcmp(&old->regs[i], &cur->regs[i],
+			   sizeof(old->regs[0])) != 0) {
+			if (old->regs[i].type == NOT_INIT ||
+			    old->regs[i].type == UNKNOWN_VALUE)
+				continue;
+			return false;
+		}
+	}
+
+	for (i = 0; i < MAX_BPF_STACK; i++) {
+		if (memcmp(&old->stack[i], &cur->stack[i],
+			   sizeof(old->stack[0])) != 0) {
+			if (old->stack[i].stype == STACK_INVALID)
+				continue;
+			return false;
+		}
+	}
+	return true;
+}
+
+static int is_state_visited(struct verifier_env *env, int insn_idx)
+{
+	struct verifier_state_list *new_sl;
+	struct verifier_state_list *sl;
+
+	sl = env->branch_landing[insn_idx];
+	if (!sl)
+		/* no branch jump to this insn, ignore it */
+		return 0;
+
+	while (sl != STATE_END) {
+		if (states_equal(&sl->state, &env->cur_state))
+			/* reached equivalent register/stack state,
+			 * prune the search
+			 */
+			return 1;
+		sl = sl->next;
+	}
+	new_sl = kmalloc(sizeof(struct verifier_state_list), GFP_KERNEL);
+
+	if (!new_sl)
+		/* ignore ENOMEM, it doesn't affect correctness */
+		return 0;
+
+	/* add new state to the head of linked list */
+	memcpy(&new_sl->state, &env->cur_state, sizeof(env->cur_state));
+	new_sl->next = env->branch_landing[insn_idx];
+	env->branch_landing[insn_idx] = new_sl;
+	return 0;
+}
+
 static int do_check(struct verifier_env *env)
 {
 	struct verifier_state *state = &env->cur_state;
@@ -1426,6 +1518,17 @@ static int do_check(struct verifier_env *env)
 			return -E2BIG;
 		}
 
+		if (is_state_visited(env, insn_idx)) {
+			if (log_level) {
+				if (do_print_state)
+					verbose("\nfrom %d to %d: safe\n",
+						prev_insn_idx, insn_idx);
+				else
+					verbose("%d: safe\n", insn_idx);
+			}
+			goto process_bpf_exit;
+		}
+
 		if (log_level && do_print_state) {
 			verbose("\nfrom %d to %d:", prev_insn_idx, insn_idx);
 			print_verifier_state(env);
@@ -1536,6 +1639,7 @@ static int do_check(struct verifier_env *env)
 				 * something into it earlier
 				 */
 				_(check_reg_arg(regs, BPF_REG_0, SRC_OP));
+process_bpf_exit:
 				insn_idx = pop_stack(env, &prev_insn_idx);
 				if (insn_idx < 0) {
 					break;
@@ -1670,6 +1774,28 @@ static void convert_pseudo_ld_imm64(struct verifier_env *env)
 			insn->src_reg = 0;
 }
 
+static void free_states(struct verifier_env *env)
+{
+	struct verifier_state_list *sl, *sln;
+	int i;
+
+	if (!env->branch_landing)
+		return;
+
+	for (i = 0; i < env->prog->len; i++) {
+		sl = env->branch_landing[i];
+
+		if (sl)
+			while (sl != STATE_END) {
+				sln = sl->next;
+				kfree(sl);
+				sl = sln;
+			}
+	}
+
+	kfree(env->branch_landing);
+}
+
 int bpf_check(struct bpf_prog *prog, struct nlattr *tb[BPF_PROG_ATTR_MAX + 1])
 {
 	void __user *log_ubuf = NULL;
@@ -1719,6 +1845,13 @@ int bpf_check(struct bpf_prog *prog, struct nlattr *tb[BPF_PROG_ATTR_MAX + 1])
 	if (ret < 0)
 		goto skip_full_check;
 
+	env->branch_landing = kcalloc(prog->len,
+				      sizeof(struct verifier_state_list *),
+				      GFP_KERNEL);
+	ret = -ENOMEM;
+	if (!env->branch_landing)
+		goto skip_full_check;
+
 	ret = check_cfg(env);
 	if (ret < 0)
 		goto skip_full_check;
@@ -1727,6 +1860,7 @@ int bpf_check(struct bpf_prog *prog, struct nlattr *tb[BPF_PROG_ATTR_MAX + 1])
 
 skip_full_check:
 	while (pop_stack(env, NULL) >= 0);
+	free_states(env);
 
 	if (log_level && log_len >= log_size - 1) {
 		BUG_ON(log_len >= log_size);
-- 
1.7.9.5
