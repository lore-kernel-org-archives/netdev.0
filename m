From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: [PATCH v4 net-next 07/13] selftests/bpf: add a test
	to test_align
Date: Thu, 3 Aug 2017 17:13:45 +0100
Message-ID: <dad7355f-f25a-95aa-5137-67457ff6b7d6@solarflare.com>
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

New test adds 14 to the unknown value before adding to the packet pointer,
 meaning there's no 'fixed offset' field and instead we add into the
 var_off, yielding a '4n+2' value.

Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
---
 tools/testing/selftests/bpf/test_align.c | 67 ++++++++++++++++++++++++++++++++
 1 file changed, 67 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_align.c b/tools/testing/selftests/bpf/test_align.c
index 62232e4d..74cc4a6 100644
--- a/tools/testing/selftests/bpf/test_align.c
+++ b/tools/testing/selftests/bpf/test_align.c
@@ -374,6 +374,73 @@ static struct bpf_align_test tests[] = {
 			{33, "R5=pkt(id=4,off=18,r=22,umax_value=2040,var_off=(0x0; 0x7fc))"},
 		},
 	},
+	{
+		.descr = "packet variable offset 2",
+		.insns = {
+			/* Create an unknown offset, (4n+2)-aligned */
+			LOAD_UNKNOWN(BPF_REG_6),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_6, 2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 14),
+			/* Add it to the packet pointer */
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_5, BPF_REG_6),
+			/* Check bounds and perform a read */
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_5),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 4),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_4, 1),
+			BPF_EXIT_INSN(),
+			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_5, 0),
+			/* Make a (4n) offset from the value we just read */
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_6, 0xff),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_6, 2),
+			/* Add it to the packet pointer */
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_5, BPF_REG_6),
+			/* Check bounds and perform a read */
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_5),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 4),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_4, 1),
+			BPF_EXIT_INSN(),
+			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_5, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.matches = {
+			/* Calculated offset in R6 has unknown value, but known
+			 * alignment of 4.
+			 */
+			{8, "R2=pkt(id=0,off=0,r=8,imm=0)"},
+			{8, "R6=inv(id=0,umax_value=1020,var_off=(0x0; 0x3fc))"},
+			/* Adding 14 makes R6 be (4n+2) */
+			{9, "R6=inv(id=0,umin_value=14,umax_value=1034,var_off=(0x2; 0x7fc))"},
+			/* Packet pointer has (4n+2) offset */
+			{11, "R5=pkt(id=1,off=0,r=0,umin_value=14,umax_value=1034,var_off=(0x2; 0x7fc))"},
+			{13, "R4=pkt(id=1,off=4,r=0,umin_value=14,umax_value=1034,var_off=(0x2; 0x7fc))"},
+			/* At the time the word size load is performed from R5,
+			 * its total fixed offset is NET_IP_ALIGN + reg->off (0)
+			 * which is 2.  Then the variable offset is (4n+2), so
+			 * the total offset is 4-byte aligned and meets the
+			 * load's requirements.
+			 */
+			{15, "R5=pkt(id=1,off=0,r=4,umin_value=14,umax_value=1034,var_off=(0x2; 0x7fc))"},
+			/* Newly read value in R6 was shifted left by 2, so has
+			 * known alignment of 4.
+			 */
+			{18, "R6=inv(id=0,umax_value=1020,var_off=(0x0; 0x3fc))"},
+			/* Added (4n) to packet pointer's (4n+2) var_off, giving
+			 * another (4n+2).
+			 */
+			{19, "R5=pkt(id=2,off=0,r=0,umin_value=14,umax_value=2054,var_off=(0x2; 0xffc))"},
+			{21, "R4=pkt(id=2,off=4,r=0,umin_value=14,umax_value=2054,var_off=(0x2; 0xffc))"},
+			/* At the time the word size load is performed from R5,
+			 * its total fixed offset is NET_IP_ALIGN + reg->off (0)
+			 * which is 2.  Then the variable offset is (4n+2), so
+			 * the total offset is 4-byte aligned and meets the
+			 * load's requirements.
+			 */
+			{23, "R5=pkt(id=2,off=0,r=4,umin_value=14,umax_value=2054,var_off=(0x2; 0xffc))"},
+		},
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
