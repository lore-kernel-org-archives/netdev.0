From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/7] bpf: Track alignment of register values in the
 verifier.
Date: Thu, 11 May 2017 22:31:14 -0400 (EDT)
Message-ID: <20170511.223114.1433952443872548282.davem@davemloft.net>
References: <20170511.120516.2089919860112370473.davem@davemloft.net>
        <06d46f08-2c62-d167-1fe5-a49284c614bb@fb.com>
        <20170511.211406.1201174799693258613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57306 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756143AbdELCbQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 22:31:16 -0400
In-Reply-To: <20170511.211406.1201174799693258613.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 11 May 2017 21:14:06 -0400 (EDT)

> Indeed, we have to accumulate.  I was just thinking about this earlier
> today.

I've just pushed the following fix, thanks a lot.

====================
[PATCH] bpf: Handle multiple variable additions into packet pointers in verifier.

We must accumulate into reg->aux_off rather than use a plain assignment.

Add a test for this situation to test_align.

Reported-by: Alexei Starovoitov <ast@fb.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 kernel/bpf/verifier.c                    |  2 +-
 tools/testing/selftests/bpf/test_align.c | 37 ++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index e74fb1b..39f2dcb 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1531,7 +1531,7 @@ static int check_packet_ptr_add(struct bpf_verifier_env *env,
 		dst_reg->id = ++env->id_gen;
 
 		/* something was added to pkt_ptr, set range to zero */
-		dst_reg->aux_off = dst_reg->off;
+		dst_reg->aux_off += dst_reg->off;
 		dst_reg->off = 0;
 		dst_reg->range = 0;
 		if (had_id)
diff --git a/tools/testing/selftests/bpf/test_align.c b/tools/testing/selftests/bpf/test_align.c
index ed24255..9644d4e 100644
--- a/tools/testing/selftests/bpf/test_align.c
+++ b/tools/testing/selftests/bpf/test_align.c
@@ -273,6 +273,20 @@ static struct bpf_align_test tests[] = {
 			BPF_EXIT_INSN(),
 			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_5, 0),
 
+			/* Test multiple accumulations of unknown values
+			 * into a packet pointer.
+			 */
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 14),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_5, BPF_REG_6),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 4),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_5, BPF_REG_6),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_5),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 4),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_4, 1),
+			BPF_EXIT_INSN(),
+			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_5, 0),
+
 			BPF_MOV64_IMM(BPF_REG_0, 0),
 			BPF_EXIT_INSN(),
 		},
@@ -314,6 +328,29 @@ static struct bpf_align_test tests[] = {
 			 * requirements.
 			 */
 			"23: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=pkt(id=2,off=18,r=18),aux_off_align=4 R5=pkt(id=2,off=14,r=18),aux_off_align=4 R6=inv54,min_align=4 R10=fp",
+
+			/* Constant offset is added to R5 packet pointer,
+			 * resulting in reg->off value of 14.
+			 */
+			"26: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv,aux_off_align=4 R5=pkt(id=0,off=14,r=8) R6=inv54,min_align=4 R10=fp",
+			/* Variable offset is added to R5, resulting in an
+			 * auxiliary offset of 14, and an auxiliary alignment of 4.
+			 */
+			"27: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv,aux_off_align=4 R5=pkt(id=3,off=0,r=0),aux_off=14,aux_off_align=4 R6=inv54,min_align=4 R10=fp",
+			/* Constant is added to R5 again, setting reg->off to 4. */
+			"28: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv,aux_off_align=4 R5=pkt(id=3,off=4,r=0),aux_off=14,aux_off_align=4 R6=inv54,min_align=4 R10=fp",
+			/* And once more we add a variable, which causes an accumulation
+			 * of reg->off into reg->aux_off_align, with resulting value of
+			 * 18.  The auxiliary alignment stays at 4.
+			 */
+			"29: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv,aux_off_align=4 R5=pkt(id=4,off=0,r=0),aux_off=18,aux_off_align=4 R6=inv54,min_align=4 R10=fp",
+			/* At the time the word size load is performed from R5,
+			 * it's total offset is NET_IP_ALIGN + reg->off (0) +
+			 * reg->aux_off (18) which is 20.  Then the variable offset
+			 * is considered using reg->aux_off_align which is 4 and meets
+			 * the load's requirements.
+			 */
+			"33: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=pkt(id=4,off=4,r=4),aux_off=18,aux_off_align=4 R5=pkt(id=4,off=0,r=4),aux_off=18,aux_off_align=4 R6=inv54,min_align=4 R10=fp",
 		},
 	},
 };
-- 
2.1.2.532.g19b5d50
