From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v5 net-next 09/12] selftests/bpf: add tests for subtraction &
 negative numbers
Date: Mon, 7 Aug 2017 15:29:34 +0100
Message-ID: <0a32f4c8-a48c-688d-90a2-9a414d96181f@solarflare.com>
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

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 tools/testing/selftests/bpf/test_align.c | 104 +++++++++++++++++++++++++++++++
 1 file changed, 104 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_align.c b/tools/testing/selftests/bpf/test_align.c
index b081683..8591c89 100644
--- a/tools/testing/selftests/bpf/test_align.c
+++ b/tools/testing/selftests/bpf/test_align.c
@@ -497,6 +497,110 @@ static struct bpf_align_test tests[] = {
 			{16, "R6=pkt(id=1,off=0,r=0,umin_value=2,umax_value=9223372036854775806,var_off=(0x2; 0x7ffffffffffffffc))"},
 		}
 	},
+	{
+		.descr = "variable subtraction",
+		.insns = {
+			/* Create an unknown offset, (4n+2)-aligned */
+			LOAD_UNKNOWN(BPF_REG_6),
+			BPF_MOV64_REG(BPF_REG_7, BPF_REG_6),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_6, 2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 14),
+			/* Create another unknown, (4n)-aligned, and subtract
+			 * it from the first one
+			 */
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_7, 2),
+			BPF_ALU64_REG(BPF_SUB, BPF_REG_6, BPF_REG_7),
+			/* Bounds-check the result */
+			BPF_JMP_IMM(BPF_JSGE, BPF_REG_6, 0, 1),
+			BPF_EXIT_INSN(),
+			/* Add it to the packet pointer */
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_5, BPF_REG_6),
+			/* Check bounds and perform a read */
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_5),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 4),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_4, 1),
+			BPF_EXIT_INSN(),
+			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_5, 0),
+			BPF_EXIT_INSN(),
+		},
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.matches = {
+			/* Calculated offset in R6 has unknown value, but known
+			 * alignment of 4.
+			 */
+			{7, "R2=pkt(id=0,off=0,r=8,imm=0)"},
+			{9, "R6=inv(id=0,umax_value=1020,var_off=(0x0; 0x3fc))"},
+			/* Adding 14 makes R6 be (4n+2) */
+			{10, "R6=inv(id=0,umin_value=14,umax_value=1034,var_off=(0x2; 0x7fc))"},
+			/* New unknown value in R7 is (4n) */
+			{11, "R7=inv(id=0,umax_value=1020,var_off=(0x0; 0x3fc))"},
+			/* Subtracting it from R6 blows our unsigned bounds */
+			{12, "R6=inv(id=0,smin_value=-1006,smax_value=1034,var_off=(0x2; 0xfffffffffffffffc))"},
+			/* Checked s>= 0 */
+			{14, "R6=inv(id=0,umin_value=2,umax_value=1034,var_off=(0x2; 0x7fc))"},
+			/* At the time the word size load is performed from R5,
+			 * its total fixed offset is NET_IP_ALIGN + reg->off (0)
+			 * which is 2.  Then the variable offset is (4n+2), so
+			 * the total offset is 4-byte aligned and meets the
+			 * load's requirements.
+			 */
+			{20, "R5=pkt(id=1,off=0,r=4,umin_value=2,umax_value=1034,var_off=(0x2; 0x7fc))"},
+		},
+	},
+	{
+		.descr = "pointer variable subtraction",
+		.insns = {
+			/* Create an unknown offset, (4n+2)-aligned and bounded
+			 * to [14,74]
+			 */
+			LOAD_UNKNOWN(BPF_REG_6),
+			BPF_MOV64_REG(BPF_REG_7, BPF_REG_6),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_6, 0xf),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_6, 2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 14),
+			/* Subtract it from the packet pointer */
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_2),
+			BPF_ALU64_REG(BPF_SUB, BPF_REG_5, BPF_REG_6),
+			/* Create another unknown, (4n)-aligned and >= 74.
+			 * That in fact means >= 76, since 74 % 4 == 2
+			 */
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_7, 2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_7, 76),
+			/* Add it to the packet pointer */
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_5, BPF_REG_7),
+			/* Check bounds and perform a read */
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_5),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 4),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_4, 1),
+			BPF_EXIT_INSN(),
+			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_5, 0),
+			BPF_EXIT_INSN(),
+		},
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.matches = {
+			/* Calculated offset in R6 has unknown value, but known
+			 * alignment of 4.
+			 */
+			{7, "R2=pkt(id=0,off=0,r=8,imm=0)"},
+			{10, "R6=inv(id=0,umax_value=60,var_off=(0x0; 0x3c))"},
+			/* Adding 14 makes R6 be (4n+2) */
+			{11, "R6=inv(id=0,umin_value=14,umax_value=74,var_off=(0x2; 0x7c))"},
+			/* Subtracting from packet pointer overflows ubounds */
+			{13, "R5=pkt(id=1,off=0,r=8,umin_value=18446744073709551542,umax_value=18446744073709551602,var_off=(0xffffffffffffff82; 0x7c))"},
+			/* New unknown value in R7 is (4n), >= 76 */
+			{15, "R7=inv(id=0,umin_value=76,umax_value=1096,var_off=(0x0; 0x7fc))"},
+			/* Adding it to packet pointer gives nice bounds again */
+			{16, "R5=pkt(id=2,off=0,r=0,umin_value=2,umax_value=1082,var_off=(0x2; 0x7fc))"},
+			/* At the time the word size load is performed from R5,
+			 * its total fixed offset is NET_IP_ALIGN + reg->off (0)
+			 * which is 2.  Then the variable offset is (4n+2), so
+			 * the total offset is 4-byte aligned and meets the
+			 * load's requirements.
+			 */
+			{20, "R5=pkt(id=2,off=0,r=4,umin_value=2,umax_value=1082,var_off=(0x2; 0x7fc))"},
+		},
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
