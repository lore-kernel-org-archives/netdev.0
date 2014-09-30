From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 1/2] bpf: add search pruning optimization to verifier
Date: Mon, 29 Sep 2014 18:50:01 -0700
Message-ID: <1412041802-24858-2-git-send-email-ast@plumgrid.com>
References: <1412041802-24858-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36486 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755286AbaI3BuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 21:50:13 -0400
Received: by mail-pd0-f169.google.com with SMTP id p10so6325666pdj.14
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 18:50:12 -0700 (PDT)
In-Reply-To: <1412041802-24858-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

consider C program represented in eBPF:
int filter(int arg)
{
    int a, b, c, *ptr;

    if (arg == 1)
        ptr = &a;
    else if (arg == 2)
        ptr = &b;
    else
        ptr = &c;

    *ptr = 0;
    return 0;
}
eBPF verifier has to follow all possible paths through the program
to recognize that '*ptr = 0' instruction would be safe to execute
in all situations.
It's doing it by picking a path towards the end and observes changes
to registers and stack at every insn until it reaches bpf_exit.
Then it comes back to one of the previous branches and goes towards
the end again with potentially different values in registers.
When program has a lot of branches, the number of possible combinations
of branches is huge, so verifer has a hard limit of walking no more
than 32k instructions. This limit can be reached and complex (but valid)
programs could be rejected. Therefore it's important to recognize equivalent
verifier states to prune this depth first search.

Basic idea can be illustrated by the program (where .. are some eBPF insns):
    1: ..
    2: if (rX == rY) goto 4
    3: ..
    4: ..
    5: ..
    6: bpf_exit
In the first pass towards bpf_exit the verifier will walk insns: 1, 2, 3, 4, 5, 6
Since insn#2 is a branch the verifier will remember its state in verifier stack
to come back to it later.
Since insn#4 is marked as 'branch target', the verifier will remember its state
in explored_states[4] linked list.
Once it reaches insn#6 successfully it will pop the state recorded at insn#2 and
will continue.
Without search pruning optimization verifier would have to walk 4, 5, 6 again,
effectively simulating execution of insns 1, 2, 4, 5, 6
With search pruning it will check whether state at #4 after jumping from #2
is equivalent to one recorded in explored_states[4] during first pass.
If there is an equivalent state, verifier can prune the search at #4 and declare
this path to be safe as well.
In other words two states at #4 are equivalent if execution of 1, 2, 3, 4 insns
and 1, 2, 4 insns produces equivalent registers and stack.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 kernel/bpf/verifier.c |  146 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 146 insertions(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index a086dd3210a8..801f5f3b9307 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -199,6 +199,7 @@ struct verifier_env {
 	struct verifier_stack_elem *head; /* stack of verifier states to be processed */
 	int stack_size;			/* number of states to be processed */
 	struct verifier_state cur_state; /* current verifier state */
+	struct verifier_state_list **explored_states; /* search pruning optimization */
 	struct bpf_map *used_maps[MAX_USED_MAPS]; /* array of map's used by eBPF program */
 	u32 used_map_cnt;		/* number of used maps */
 };
@@ -1219,6 +1220,8 @@ enum {
 	BRANCH = 2,
 };
 
+#define STATE_LIST_MARK ((struct verifier_state_list *) -1L)
+
 static int *insn_stack;	/* stack of insns to process */
 static int cur_stack;	/* current stack index */
 static int *insn_state;
@@ -1241,6 +1244,10 @@ static int push_insn(int t, int w, int e, struct verifier_env *env)
 		return -EINVAL;
 	}
 
+	if (e == BRANCH)
+		/* mark branch target for state pruning */
+		env->explored_states[w] = STATE_LIST_MARK;
+
 	if (insn_state[w] == 0) {
 		/* tree-edge */
 		insn_state[t] = DISCOVERED | e;
@@ -1314,6 +1321,10 @@ peek_stack:
 				goto peek_stack;
 			else if (ret < 0)
 				goto err_free;
+			/* tell verifier to check for equivalent states
+			 * after every call and jump
+			 */
+			env->explored_states[t + 1] = STATE_LIST_MARK;
 		} else {
 			/* conditional jump with two edges */
 			ret = push_insn(t, t + 1, FALLTHROUGH, env);
@@ -1364,6 +1375,95 @@ err_free:
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
+	sl = env->explored_states[insn_idx];
+	if (!sl)
+		/* this 'insn_idx' instruction wasn't marked, so we will not
+		 * be doing state search here
+		 */
+		return 0;
+
+	while (sl != STATE_LIST_MARK) {
+		if (states_equal(&sl->state, &env->cur_state))
+			/* reached equivalent register/stack state,
+			 * prune the search
+			 */
+			return 1;
+		sl = sl->next;
+	}
+
+	/* there were no equivalent states, remember current one.
+	 * technically the current state is not proven to be safe yet,
+	 * but it will either reach bpf_exit (which means it's safe) or
+	 * it will be rejected. Since there are no loops, we won't be
+	 * seeing this 'insn_idx' instruction again on the way to bpf_exit
+	 */
+	new_sl = kmalloc(sizeof(struct verifier_state_list), GFP_USER);
+	if (!new_sl)
+		return -ENOMEM;
+
+	/* add new state to the head of linked list */
+	memcpy(&new_sl->state, &env->cur_state, sizeof(env->cur_state));
+	new_sl->next = env->explored_states[insn_idx];
+	env->explored_states[insn_idx] = new_sl;
+	return 0;
+}
+
 static int do_check(struct verifier_env *env)
 {
 	struct verifier_state *state = &env->cur_state;
@@ -1396,6 +1496,21 @@ static int do_check(struct verifier_env *env)
 			return -E2BIG;
 		}
 
+		err = is_state_visited(env, insn_idx);
+		if (err < 0)
+			return err;
+		if (err == 1) {
+			/* found equivalent state, can prune the search */
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
@@ -1531,6 +1646,7 @@ static int do_check(struct verifier_env *env)
 				if (err)
 					return err;
 
+process_bpf_exit:
 				insn_idx = pop_stack(env, &prev_insn_idx);
 				if (insn_idx < 0) {
 					break;
@@ -1671,6 +1787,28 @@ static void convert_pseudo_ld_imm64(struct verifier_env *env)
 			insn->src_reg = 0;
 }
 
+static void free_states(struct verifier_env *env)
+{
+	struct verifier_state_list *sl, *sln;
+	int i;
+
+	if (!env->explored_states)
+		return;
+
+	for (i = 0; i < env->prog->len; i++) {
+		sl = env->explored_states[i];
+
+		if (sl)
+			while (sl != STATE_LIST_MARK) {
+				sln = sl->next;
+				kfree(sl);
+				sl = sln;
+			}
+	}
+
+	kfree(env->explored_states);
+}
+
 int bpf_check(struct bpf_prog *prog, union bpf_attr *attr)
 {
 	char __user *log_ubuf = NULL;
@@ -1719,6 +1857,13 @@ int bpf_check(struct bpf_prog *prog, union bpf_attr *attr)
 	if (ret < 0)
 		goto skip_full_check;
 
+	env->explored_states = kcalloc(prog->len,
+				       sizeof(struct verifier_state_list *),
+				       GFP_USER);
+	ret = -ENOMEM;
+	if (!env->explored_states)
+		goto skip_full_check;
+
 	ret = check_cfg(env);
 	if (ret < 0)
 		goto skip_full_check;
@@ -1727,6 +1872,7 @@ int bpf_check(struct bpf_prog *prog, union bpf_attr *attr)
 
 skip_full_check:
 	while (pop_stack(env, NULL) >= 0);
+	free_states(env);
 
 	if (log_level && log_len >= log_size - 1) {
 		BUG_ON(log_len >= log_size);
-- 
1.7.9.5
