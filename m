From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v2 net-next 1/5] selftests/bpf: add a test for a bug in
 liveness-based pruning
Date: Wed, 23 Aug 2017 15:09:46 +0100
Message-ID: <83dbbb0c-3cbc-e033-0ceb-f31db6eb57c2@solarflare.com>
References: <f9208b68-466e-c6cb-4d0c-c567e40bdc15@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:32768 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754001AbdHWOJ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 10:09:57 -0400
In-Reply-To: <f9208b68-466e-c6cb-4d0c-c567e40bdc15@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Writes in straight-line code should not prevent reads from propagating
 along jumps.  With current verifier code, the jump from 3 to 5 does not
 add a read mark on 3:R0 (because 5:R0 has a write mark), meaning that
 the jump from 1 to 3 gets pruned as safe even though R0 is NOT_INIT.

Verifier output:
0: (61) r2 = *(u32 *)(r1 +0)
1: (35) if r2 >= 0x0 goto pc+1
 R1=ctx(id=0,off=0,imm=0) R2=inv(id=0,umax_value=4294967295,var_off=(0x0; 0xffffffff)) R10=fp0
2: (b7) r0 = 0
3: (35) if r2 >= 0x0 goto pc+1
 R0=inv0 R1=ctx(id=0,off=0,imm=0) R2=inv(id=0,umax_value=4294967295,var_off=(0x0; 0xffffffff)) R10=fp0
4: (b7) r0 = 0
5: (95) exit

from 3 to 5: safe

from 1 to 3: safe
processed 8 insns, stack depth 0

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 tools/testing/selftests/bpf/test_verifier.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index c03542c..c912734 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -6487,6 +6487,22 @@ static struct bpf_test tests[] = {
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_LWT_IN,
 	},
+	{
+		"liveness pruning and write screening",
+		.insns = {
+			/* Get an unknown value */
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1, 0),
+			/* branch conditions teach us nothing about R2 */
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_2, 0, 1),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_2, 0, 1),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R0 !read_ok",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_LWT_IN,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
