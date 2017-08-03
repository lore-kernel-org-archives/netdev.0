From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: [PATCH v4 net-next 10/13] selftests/bpf: add tests
 for subtraction & negative numbers
Date: Thu, 3 Aug 2017 17:15:15 +0100
Message-ID: <e7eb1143-48c7-a327-20e1-c1a4d216e952@solarflare.com>
References: <22441d84-0a11-5c00-2d2a-25e7dbafa6c2@solarflare.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <22441d84-0a11-5c00-2d2a-25e7dbafa6c2-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
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
