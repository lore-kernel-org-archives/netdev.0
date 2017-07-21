From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net 1/2] selftests/bpf: subtraction bounds test
Date: Fri, 21 Jul 2017 14:36:57 +0100
Message-ID: <a12c5a59-d2e0-5866-d225-501d19a3ec7b@solarflare.com>
References: <2ebcb201-2f18-7276-f4f9-f2bbaffae179@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2ebcb201-2f18-7276-f4f9-f2bbaffae179@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a bug in the verifier's handling of BPF_SUB: [a,b] - [c,d] yields
 was [a-c, b-d] rather than the correct [a-d, b-c].  So here is a test
 which, with the bogus handling, will produce ranges of [0,0] and thus
 allowed accesses; whereas the correct handling will give a range of
 [-255, 255] (and hence the right-shift will give a range of [0, 255]) and
 the accesses will be rejected.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 tools/testing/selftests/bpf/test_verifier.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index af7d173..addea82 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -5980,6 +5980,34 @@ static struct bpf_test tests[] = {
 		.result = REJECT,
 		.result_unpriv = REJECT,
 	},
+	{
+		"subtraction bounds (map value)",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 9),
+			BPF_LDX_MEM(BPF_B, BPF_REG_1, BPF_REG_0, 0),
+			BPF_JMP_IMM(BPF_JGT, BPF_REG_1, 0xff, 7),
+			BPF_LDX_MEM(BPF_B, BPF_REG_3, BPF_REG_0, 1),
+			BPF_JMP_IMM(BPF_JGT, BPF_REG_3, 0xff, 5),
+			BPF_ALU64_REG(BPF_SUB, BPF_REG_1, BPF_REG_3),
+			BPF_ALU64_IMM(BPF_RSH, BPF_REG_1, 56),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
+		.result = REJECT,
+		.result_unpriv = REJECT,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
