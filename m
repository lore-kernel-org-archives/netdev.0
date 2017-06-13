From: David Daney <david.daney@cavium.com>
Subject: [PATCH 2/4] test_bpf: Add test to make conditional jump cross a large number of insns.
Date: Tue, 13 Jun 2017 16:49:36 -0700
Message-ID: <20170613234938.4823-3-david.daney@cavium.com>
References: <20170613234938.4823-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
        David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613234938.4823-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On MIPS, conditional branches can only span 32k instructions.  To
exceed this limit in the JIT with the BPF maximum of 4k insns, we need
to choose eBPF insns that expand to more than 8 machine instructions.
Use BPF_LD_ABS as it is quite complex.  This forces the JIT to invert
the sense of the branch to branch around a long jump to the end.

This (somewhat) verifies that the branch inversion logic and target
address calculation of the long jumps are done correctly.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 lib/test_bpf.c | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index be88cba..9ecbf47 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -434,6 +434,30 @@ static int bpf_fill_ld_abs_vlan_push_pop(struct bpf_test *self)
 	return 0;
 }
 
+static int bpf_fill_jump_around_ld_abs(struct bpf_test *self)
+{
+	unsigned int len = BPF_MAXINSNS;
+	struct bpf_insn *insn;
+	int i = 0;
+
+	insn = kmalloc_array(len, sizeof(*insn), GFP_KERNEL);
+	if (!insn)
+		return -ENOMEM;
+
+	insn[i++] = BPF_MOV64_REG(R6, R1);
+	insn[i++] = BPF_LD_ABS(BPF_B, 0);
+	insn[i] = BPF_JMP_IMM(BPF_JEQ, R0, 10, len - i - 2);
+	i++;
+	while (i < len - 1)
+		insn[i++] = BPF_LD_ABS(BPF_B, 1);
+	insn[i] = BPF_EXIT_INSN();
+
+	self->u.ptr.insns = insn;
+	self->u.ptr.len = len;
+
+	return 0;
+}
+
 static int __bpf_fill_stxdw(struct bpf_test *self, int size)
 {
 	unsigned int len = BPF_MAXINSNS;
@@ -5022,6 +5046,14 @@ static struct bpf_test tests[] = {
 		{ { ETH_HLEN, 0xbef } },
 		.fill_helper = bpf_fill_ld_abs_vlan_push_pop,
 	},
+	{
+		"BPF_MAXINSNS: jump around ld_abs",
+		{ },
+		INTERNAL,
+		{ 10, 11 },
+		{ { 2, 10 } },
+		.fill_helper = bpf_fill_jump_around_ld_abs,
+	},
 	/*
 	 * LD_IND / LD_ABS on fragmented SKBs
 	 */
-- 
2.9.4
