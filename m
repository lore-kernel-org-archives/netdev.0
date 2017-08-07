From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v5 net-next 10/12] selftests/bpf: variable offset negative
 tests
Date: Mon, 7 Aug 2017 15:29:51 +0100
Message-ID: <54be71f8-308d-da11-a447-abe780edc2b7@solarflare.com>
References: <ad840039-8d4a-b2a9-b2eb-a8f079926b53@solarflare.com>
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
In-Reply-To: <ad840039-8d4a-b2a9-b2eb-a8f079926b53@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Variable ctx accesses and stack accesses aren't allowed, because we can't
 determine what type of value will be read.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 tools/testing/selftests/bpf/test_verifier.c | 41 +++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 876b878..65aa562 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -5980,6 +5980,47 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result = REJECT,
 	},
+	{
+		"variable-offset ctx access",
+		.insns = {
+			/* Get an unknown value */
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1, 0),
+			/* Make it small and 4-byte aligned */
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_2, 4),
+			/* add it to skb.  We now have either &skb->len or
+			 * &skb->pkt_type, but we don't know which
+			 */
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_2),
+			/* dereference it */
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "variable ctx access var_off=(0x0; 0x4)",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_LWT_IN,
+	},
+	{
+		"variable-offset stack access",
+		.insns = {
+			/* Fill the top 8 bytes of the stack */
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			/* Get an unknown value */
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1, 0),
+			/* Make it small and 4-byte aligned */
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_2, 4),
+			BPF_ALU64_IMM(BPF_SUB, BPF_REG_2, 8),
+			/* add it to fp.  We now have either fp-4 or fp-8, but
+			 * we don't know which
+			 */
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_2, BPF_REG_10),
+			/* dereference it */
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_2, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "variable stack access var_off=(0xfffffffffffffff8; 0x4)",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_LWT_IN,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
