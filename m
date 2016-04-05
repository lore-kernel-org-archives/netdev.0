From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, verifier: further improve search pruning
Date: Tue,  5 Apr 2016 22:33:17 +0200
Message-ID: <5ace6a7fbfd0da742cfaa2704d5eab7a7d0cea89.1459886148.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43140 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544AbcDEUd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 16:33:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The verifier needs to go through every path of the program in
order to check that it terminates safely, which can be quite a
lot of instructions that need to be processed f.e. in cases with
more branchy programs. With search pruning from f1bca824dabb ("bpf:
add search pruning optimization to verifier") the search space can
already be reduced significantly when the verifier detects that
a previously walked path with same register and stack contents
terminated already (see verifier's states_equal()), so the search
can skip walking those states.

When working with larger programs of > ~2000 (out of max 4096)
insns, we found that the current limit of 32k instructions is easily
hit. For example, a case we ran into is that the search space cannot
be pruned due to branches at the beginning of the program that make
use of certain stack space slots (STACK_MISC), which are never used
in the remaining program (STACK_INVALID). Therefore, the verifier
needs to walk paths for the slots in STACK_INVALID state, but also
all remaining paths with a stack structure, where the slots are in
STACK_MISC, which can nearly double the search space needed. After
various experiments, we find that a limit of 64k processed insns is
a more reasonable choice when dealing with larger programs in practice.
This still allows to reject extreme crafted cases that can have a
much higher complexity (f.e. > ~300k) within the 4096 insns limit
due to search pruning not being able to take effect.

Furthermore, we found that a lot of states can be pruned after a
call instruction, f.e. we were able to reduce the search state by
~35% in some cases with this heuristic, trade-off is to keep a bit
more states in env->explored_states. Usually, call instructions
have a number of preceding register assignments and/or stack stores,
where search pruning has a better chance to suceed in states_equal()
test. The current code marks the branch targets with STATE_LIST_MARK
in case of conditional jumps, and the next (t + 1) instruction in
case of unconditional jump so that f.e. a backjump will walk it. We
also did experiments with using t + insns[t].off + 1 as a marker in
the unconditionally jump case instead of t + 1 with the rationale
that these two branches of execution that converge after the label
might have more potential of pruning. We found that it was a bit
better, but not necessarily significantly better than the current
state, perhaps also due to clang not generating back jumps often.
Hence, we left that as is for now.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 2e08f8e..212e52a 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -202,6 +202,9 @@ struct verifier_env {
 	bool allow_ptr_leaks;
 };
 
+#define BPF_COMPLEXITY_LIMIT_INSNS	65536
+#define BPF_COMPLEXITY_LIMIT_STACK	1024
+
 /* verbose verifier prints what it's seeing
  * bpf_check() is called under lock, so no race to access these global vars
  */
@@ -454,7 +457,7 @@ static struct verifier_state *push_stack(struct verifier_env *env, int insn_idx,
 	elem->next = env->head;
 	env->head = elem;
 	env->stack_size++;
-	if (env->stack_size > 1024) {
+	if (env->stack_size > BPF_COMPLEXITY_LIMIT_STACK) {
 		verbose("BPF program is too complex\n");
 		goto err;
 	}
@@ -1539,6 +1542,8 @@ peek_stack:
 				goto peek_stack;
 			else if (ret < 0)
 				goto err_free;
+			if (t + 1 < insn_cnt)
+				env->explored_states[t + 1] = STATE_LIST_MARK;
 		} else if (opcode == BPF_JA) {
 			if (BPF_SRC(insns[t].code) != BPF_K) {
 				ret = -EINVAL;
@@ -1743,7 +1748,7 @@ static int do_check(struct verifier_env *env)
 		insn = &insns[insn_idx];
 		class = BPF_CLASS(insn->code);
 
-		if (++insn_processed > 32768) {
+		if (++insn_processed > BPF_COMPLEXITY_LIMIT_INSNS) {
 			verbose("BPF program is too large. Proccessed %d insn\n",
 				insn_processed);
 			return -E2BIG;
-- 
1.9.3
