From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: prevent leaking pointer via xadd on unpriviledged
Date: Thu, 29 Jun 2017 03:04:59 +0200
Message-ID: <1fe53aa29cf003f14acf4b490e5eff038718444a.1498697608.git.daniel@iogearbox.net>
Cc: ast@fb.com, kafai@fb.com, john.fastabend@gmail.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43758 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751602AbdF2BFN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 21:05:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Leaking kernel addresses on unpriviledged is generally disallowed,
for example, verifier rejects the following:

  0: (b7) r0 = 0
  1: (18) r2 = 0xffff897e82304400
  3: (7b) *(u64 *)(r1 +48) = r2
  R2 leaks addr into ctx

Doing pointer arithmetic on them is also forbidden, so that they
don't turn into unknown value and then get leaked out. However,
there's xadd as a special case, where we don't check the src reg
for being a pointer register, e.g. the following will pass:

  0: (b7) r0 = 0
  1: (7b) *(u64 *)(r1 +48) = r0
  2: (18) r2 = 0xffff897e82304400 ; map
  4: (db) lock *(u64 *)(r1 +48) += r2
  5: (95) exit

We could store the pointer into skb->cb, loose the type context,
and then read it out from there again to leak it eventually out
of a map value. Or more easily in a different variant, too:

   0: (bf) r6 = r1
   1: (7a) *(u64 *)(r10 -8) = 0
   2: (bf) r2 = r10
   3: (07) r2 += -8
   4: (18) r1 = 0x0
   6: (85) call bpf_map_lookup_elem#1
   7: (15) if r0 == 0x0 goto pc+3
   R0=map_value(ks=8,vs=8,id=0),min_value=0,max_value=0 R6=ctx R10=fp
   8: (b7) r3 = 0
   9: (7b) *(u64 *)(r0 +0) = r3
  10: (db) lock *(u64 *)(r0 +0) += r6
  11: (b7) r0 = 0
  12: (95) exit

  from 7 to 11: R0=inv,min_value=0,max_value=0 R6=ctx R10=fp
  11: (b7) r0 = 0
  12: (95) exit

Prevent this by checking xadd src reg for pointer types. Also
add a couple of test cases related to this.

Fixes: 1be7f75d1668 ("bpf: enable non-root eBPF programs")
Fixes: 17a5267067f3 ("bpf: verifier (add verifier core)")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c                       |  5 +++
 tools/testing/selftests/bpf/test_verifier.c | 66 +++++++++++++++++++++++++++++
 2 files changed, 71 insertions(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 339c8a1..a8a7256 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -989,6 +989,11 @@ static int check_xadd(struct bpf_verifier_env *env, struct bpf_insn *insn)
 	if (err)
 		return err;
 
+	if (is_pointer_value(env, insn->src_reg)) {
+		verbose("R%d leaks addr into mem\n", insn->src_reg);
+		return -EACCES;
+	}
+
 	/* check whether atomic_add can read the memory */
 	err = check_mem_access(env, insn->dst_reg, insn->off,
 			       BPF_SIZE(insn->code), BPF_READ, -1);
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index cabb19b..0ff8c55 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -3749,6 +3749,72 @@ struct test_val {
 		.errstr = "invalid bpf_context access",
 	},
 	{
+		"leak pointer into ctx 1",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_LD_MAP_FD(BPF_REG_2, 0),
+			BPF_STX_XADD(BPF_DW, BPF_REG_1, BPF_REG_2,
+				      offsetof(struct __sk_buff, cb[0])),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 2 },
+		.errstr_unpriv = "R2 leaks addr into mem",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"leak pointer into ctx 2",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_STX_XADD(BPF_DW, BPF_REG_1, BPF_REG_10,
+				      offsetof(struct __sk_buff, cb[0])),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "R10 leaks addr into mem",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"leak pointer into ctx 3",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_LD_MAP_FD(BPF_REG_2, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_2,
+				      offsetof(struct __sk_buff, cb[0])),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 1 },
+		.errstr_unpriv = "R2 leaks addr into ctx",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"leak pointer into map val",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 3),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_0, BPF_REG_3, 0),
+			BPF_STX_XADD(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 4 },
+		.errstr_unpriv = "R6 leaks addr into mem",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
 		"helper access to map: full range",
 		.insns = {
 			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-- 
1.9.3
