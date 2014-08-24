From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v5 net-next 01/29] bpf: x86: add missing 'shift by register' instructions to x64 eBPF JIT
Date: Sun, 24 Aug 2014 13:21:02 -0700
Message-ID: <1408911690-7598-2-git-send-email-ast@plumgrid.com>
References: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Namhyung Kim <namhyung@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

'shift by register' operations are supported by eBPF interpreter, but were
accidently left out of x64 JIT compiler. Fix it and add a testcase.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 arch/x86/net/bpf_jit_comp.c |   42 ++++++++++++++++++++++++++++++++++++++++++
 lib/test_bpf.c              |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 80 insertions(+)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 5c8cb8043c5a..b08a98c59530 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -515,6 +515,48 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 			EMIT3(0xC1, add_1reg(b3, dst_reg), imm32);
 			break;
 
+		case BPF_ALU | BPF_LSH | BPF_X:
+		case BPF_ALU | BPF_RSH | BPF_X:
+		case BPF_ALU | BPF_ARSH | BPF_X:
+		case BPF_ALU64 | BPF_LSH | BPF_X:
+		case BPF_ALU64 | BPF_RSH | BPF_X:
+		case BPF_ALU64 | BPF_ARSH | BPF_X:
+
+			/* check for bad case when dst_reg == rcx */
+			if (dst_reg == BPF_REG_4) {
+				/* mov r11, dst_reg */
+				EMIT_mov(AUX_REG, dst_reg);
+				dst_reg = AUX_REG;
+			}
+
+			if (src_reg != BPF_REG_4) { /* common case */
+				EMIT1(0x51); /* push rcx */
+
+				/* mov rcx, src_reg */
+				EMIT_mov(BPF_REG_4, src_reg);
+			}
+
+			/* shl %rax, %cl | shr %rax, %cl | sar %rax, %cl */
+			if (BPF_CLASS(insn->code) == BPF_ALU64)
+				EMIT1(add_1mod(0x48, dst_reg));
+			else if (is_ereg(dst_reg))
+				EMIT1(add_1mod(0x40, dst_reg));
+
+			switch (BPF_OP(insn->code)) {
+			case BPF_LSH: b3 = 0xE0; break;
+			case BPF_RSH: b3 = 0xE8; break;
+			case BPF_ARSH: b3 = 0xF8; break;
+			}
+			EMIT2(0xD3, add_1reg(b3, dst_reg));
+
+			if (src_reg != BPF_REG_4)
+				EMIT1(0x59); /* pop rcx */
+
+			if (insn->dst_reg == BPF_REG_4)
+				/* mov dst_reg, r11 */
+				EMIT_mov(insn->dst_reg, AUX_REG);
+			break;
+
 		case BPF_ALU | BPF_END | BPF_FROM_BE:
 			switch (imm32) {
 			case 16:
diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 89e0345733bd..8c66c6aace04 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -1342,6 +1342,44 @@ static struct bpf_test tests[] = {
 		{ { 0, -1 } }
 	},
 	{
+		"INT: shifts by register",
+		.u.insns_int = {
+			BPF_MOV64_IMM(R0, -1234),
+			BPF_MOV64_IMM(R1, 1),
+			BPF_ALU32_REG(BPF_RSH, R0, R1),
+			BPF_JMP_IMM(BPF_JEQ, R0, 0x7ffffd97, 1),
+			BPF_EXIT_INSN(),
+			BPF_MOV64_IMM(R2, 1),
+			BPF_ALU64_REG(BPF_LSH, R0, R2),
+			BPF_MOV32_IMM(R4, -1234),
+			BPF_JMP_REG(BPF_JEQ, R0, R4, 1),
+			BPF_EXIT_INSN(),
+			BPF_ALU64_IMM(BPF_AND, R4, 63),
+			BPF_ALU64_REG(BPF_LSH, R0, R4), /* R0 <= 46 */
+			BPF_MOV64_IMM(R3, 47),
+			BPF_ALU64_REG(BPF_ARSH, R0, R3),
+			BPF_JMP_IMM(BPF_JEQ, R0, -617, 1),
+			BPF_EXIT_INSN(),
+			BPF_MOV64_IMM(R2, 1),
+			BPF_ALU64_REG(BPF_LSH, R4, R2), /* R4 = 46 << 1 */
+			BPF_JMP_IMM(BPF_JEQ, R4, 92, 1),
+			BPF_EXIT_INSN(),
+			BPF_MOV64_IMM(R4, 4),
+			BPF_ALU64_REG(BPF_LSH, R4, R4), /* R4 = 4 << 4 */
+			BPF_JMP_IMM(BPF_JEQ, R4, 64, 1),
+			BPF_EXIT_INSN(),
+			BPF_MOV64_IMM(R4, 5),
+			BPF_ALU32_REG(BPF_LSH, R4, R4), /* R4 = 5 << 5 */
+			BPF_JMP_IMM(BPF_JEQ, R4, 160, 1),
+			BPF_EXIT_INSN(),
+			BPF_MOV64_IMM(R0, -1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, -1 } }
+	},
+	{
 		"INT: DIV + ABS",
 		.u.insns_int = {
 			BPF_ALU64_REG(BPF_MOV, R6, R1),
-- 
1.7.9.5
