From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: adjust verifier heuristics
Date: Thu, 18 May 2017 03:00:06 +0200
Message-ID: <57a6fc1f937d985a5851016221c98a29fb1cc46a.1495068621.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54955 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752721AbdERBAR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 21:00:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current limits with regards to processing program paths do not
really reflect today's needs anymore due to programs becoming
more complex and verifier smarter, keeping track of more data
such as const ALU operations, alignment tracking, spilling of
PTR_TO_MAP_VALUE_ADJ registers, and other features allowing for
smarter matching of what LLVM generates.

This also comes with the side-effect that we result in fewer
opportunities to prune search states and thus often need to do
more work to prove safety than in the past due to different
register states and stack layout where we mismatch. Generally,
it's quite hard to determine what caused a sudden increase in
complexity, it could be caused by something as trivial as a
single branch somewhere at the beginning of the program where
LLVM assigned a stack slot that is marked differently throughout
other branches and thus causing a mismatch, where verifier
then needs to prove safety for the whole rest of the program.
Subsequently, programs with even less than half the insn size
limit can get rejected. We noticed that while some programs
load fine under pre 4.11, they get rejected due to hitting
limits on more recent kernels. We saw that in the vast majority
of cases (90+%) pruning failed due to register mismatches. In
case of stack mismatches, majority of cases failed due to
different stack slot types (invalid, spill, misc) rather than
differences in spilled registers.

This patch makes pruning more aggressive by also adding markers
that sit at conditional jumps as well. Currently, we only mark
jump targets for pruning. For example in direct packet access,
these are usually error paths where we bail out. We found that
adding these markers, it can reduce number of processed insns
by up to 30%. Another option is to ignore reg->id in probing
PTR_TO_MAP_VALUE_OR_NULL registers, which can help pruning
slightly as well by up to 7% observed complexity reduction as
stand-alone. Meaning, if a previous path with register type
PTR_TO_MAP_VALUE_OR_NULL for map X was found to be safe, then
in the current state a PTR_TO_MAP_VALUE_OR_NULL register for
the same map X must be safe as well. Last but not least the
patch also adds a scheduling point and bumps the current limit
for instructions to be processed to a more adequate value.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 39f2dcb..1eddb71 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -140,7 +140,7 @@ struct bpf_verifier_stack_elem {
 	struct bpf_verifier_stack_elem *next;
 };
 
-#define BPF_COMPLEXITY_LIMIT_INSNS	65536
+#define BPF_COMPLEXITY_LIMIT_INSNS	98304
 #define BPF_COMPLEXITY_LIMIT_STACK	1024
 
 #define BPF_MAP_PTR_POISON ((void *)0xeB9F + POISON_POINTER_DELTA)
@@ -2640,6 +2640,7 @@ static int check_cfg(struct bpf_verifier_env *env)
 				env->explored_states[t + 1] = STATE_LIST_MARK;
 		} else {
 			/* conditional jump with two edges */
+			env->explored_states[t] = STATE_LIST_MARK;
 			ret = push_insn(t, t + 1, FALLTHROUGH, env);
 			if (ret == 1)
 				goto peek_stack;
@@ -2798,6 +2799,12 @@ static bool states_equal(struct bpf_verifier_env *env,
 		     rcur->type != NOT_INIT))
 			continue;
 
+		/* Don't care about the reg->id in this case. */
+		if (rold->type == PTR_TO_MAP_VALUE_OR_NULL &&
+		    rcur->type == PTR_TO_MAP_VALUE_OR_NULL &&
+		    rold->map_ptr == rcur->map_ptr)
+			continue;
+
 		if (rold->type == PTR_TO_PACKET && rcur->type == PTR_TO_PACKET &&
 		    compare_ptrs_to_packet(rold, rcur))
 			continue;
@@ -2932,6 +2939,9 @@ static int do_check(struct bpf_verifier_env *env)
 			goto process_bpf_exit;
 		}
 
+		if (need_resched())
+			cond_resched();
+
 		if (log_level > 1 || (log_level && do_print_state)) {
 			if (log_level > 1)
 				verbose("%d:", insn_idx);
-- 
1.9.3
