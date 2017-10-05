From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net] bpf: fix liveness marking
Date: Thu, 5 Oct 2017 16:20:56 -0700
Message-ID: <20171005232056.2234669-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Edward Cree <ecree@solarflare.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46808 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751083AbdJEXVG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 19:21:06 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v95NJ1pt014062
        for <netdev@vger.kernel.org>; Thu, 5 Oct 2017 16:21:05 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2ddv7agj83-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 16:21:05 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

while processing Rx = Ry instruction the verifier does
regs[insn->dst_reg] = regs[insn->src_reg]
which often clears write mark (when Ry doesn't have it)
that was just set by check_reg_arg(Rx) prior to the assignment.
That causes mark_reg_read() to keep marking Rx in this block as
REG_LIVE_READ (since the logic incorrectly misses that it's
screened by the write) and in many of its parents (until lucky
write into the same Rx or beginning of the program).
That causes is_state_visited() logic to miss many pruning opportunities.

Furthermore mark_reg_read() logic propagates the read mark
for BPF_REG_FP as well (though it's readonly) which causes
harmless but unnecssary work during is_state_visited().
Note that do_propagate_liveness() skips FP correctly,
so do the same in mark_reg_read() as well.
It saves 0.2 seconds for the test below

program               before  after
bpf_lb-DLB_L3.o       2604    2304
bpf_lb-DLB_L4.o       11159   3723
bpf_lb-DUNKNOWN.o     1116    1110
bpf_lxc-DDROP_ALL.o   34566   28004
bpf_lxc-DUNKNOWN.o    53267   39026
bpf_netdev.o          17843   16943
bpf_overlay.o         8672    7929
time                  ~11 sec  ~4 sec

Fixes: dc503a8ad984 ("bpf/verifier: track liveness for pruning")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index b914fbe1383e..8b8d6ba39e23 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -653,6 +653,10 @@ static void mark_reg_read(const struct bpf_verifier_state *state, u32 regno)
 {
 	struct bpf_verifier_state *parent = state->parent;
 
+	if (regno == BPF_REG_FP)
+		/* We don't need to worry about FP liveness because it's read-only */
+		return;
+
 	while (parent) {
 		/* if read wasn't screened by an earlier write ... */
 		if (state->regs[regno].live & REG_LIVE_WRITTEN)
@@ -2345,6 +2349,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 				 * copy register state to dest reg
 				 */
 				regs[insn->dst_reg] = regs[insn->src_reg];
+				regs[insn->dst_reg].live |= REG_LIVE_WRITTEN;
 			} else {
 				/* R1 = (u32) R2 */
 				if (is_pointer_value(env, insn->src_reg)) {
-- 
2.9.5
