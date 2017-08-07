From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v5 net-next 07/12] selftests/bpf: add test for bogus
 operations on pointers
Date: Mon, 7 Aug 2017 15:28:45 +0100
Message-ID: <e77ace0c-aa3b-7e87-9d1c-522b2f7d2ab7@solarflare.com>
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

Tests non-add/sub operations (AND, LSH) on pointers decaying them to
 unknown scalars.
Also tests that a pkt_ptr add which could potentially overflow is rejected
 (find_good_pkt_pointers ignores it and doesn't give us any reg->range).

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 tools/testing/selftests/bpf/test_align.c | 66 +++++++++++++++++++++++++++++++-
 1 file changed, 64 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/bpf/test_align.c b/tools/testing/selftests/bpf/test_align.c
index 74cc4a6..b081683 100644
--- a/tools/testing/selftests/bpf/test_align.c
+++ b/tools/testing/selftests/bpf/test_align.c
@@ -441,6 +441,62 @@ static struct bpf_align_test tests[] = {
 			{23, "R5=pkt(id=2,off=0,r=4,umin_value=14,umax_value=2054,var_off=(0x2; 0xffc))"},
 		},
 	},
+	{
+		.descr = "dubious pointer arithmetic",
+		.insns = {
+			PREP_PKT_POINTERS,
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			/* ptr & const => unknown & const */
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_5, 0x40),
+			/* ptr << const => unknown << const */
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_5, 2),
+			/* We have a (4n) value.  Let's make a packet offset
+			 * out of it.  First add 14, to make it a (4n+2)
+			 */
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 14),
+			/* Then make sure it's nonnegative */
+			BPF_JMP_IMM(BPF_JSGE, BPF_REG_5, 0, 1),
+			BPF_EXIT_INSN(),
+			/* Add it to packet pointer */
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_6, BPF_REG_5),
+			/* Check bounds and perform a read */
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_6),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 4),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_4, 1),
+			BPF_EXIT_INSN(),
+			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.result = REJECT,
+		.matches = {
+			{4, "R5=pkt(id=0,off=0,r=0,imm=0)"},
+			/* ptr & 0x40 == either 0 or 0x40 */
+			{5, "R5=inv(id=0,umax_value=64,var_off=(0x0; 0x40))"},
+			/* ptr << 2 == unknown, (4n) */
+			{7, "R5=inv(id=0,smax_value=9223372036854775804,umax_value=18446744073709551612,var_off=(0x0; 0xfffffffffffffffc))"},
+			/* (4n) + 14 == (4n+2).  We blow our bounds, because
+			 * the add could overflow.
+			 */
+			{8, "R5=inv(id=0,var_off=(0x2; 0xfffffffffffffffc))"},
+			/* Checked s>=0 */
+			{10, "R5=inv(id=0,umin_value=2,umax_value=9223372036854775806,var_off=(0x2; 0x7ffffffffffffffc))"},
+			/* packet pointer + nonnegative (4n+2) */
+			{12, "R6=pkt(id=1,off=0,r=0,umin_value=2,umax_value=9223372036854775806,var_off=(0x2; 0x7ffffffffffffffc))"},
+			{14, "R4=pkt(id=1,off=4,r=0,umin_value=2,umax_value=9223372036854775806,var_off=(0x2; 0x7ffffffffffffffc))"},
+			/* NET_IP_ALIGN + (4n+2) == (4n), alignment is fine.
+			 * We checked the bounds, but it might have been able
+			 * to overflow if the packet pointer started in the
+			 * upper half of the address space.
+			 * So we did not get a 'range' on R6, and the access
+			 * attempt will fail.
+			 */
+			{16, "R6=pkt(id=1,off=0,r=0,umin_value=2,umax_value=9223372036854775806,var_off=(0x2; 0x7ffffffffffffffc))"},
+		}
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
@@ -470,10 +526,15 @@ static int do_test_single(struct bpf_align_test *test)
 	fd_prog = bpf_verify_program(prog_type ? : BPF_PROG_TYPE_SOCKET_FILTER,
 				     prog, prog_len, 1, "GPL", 0,
 				     bpf_vlog, sizeof(bpf_vlog), 2);
-	if (fd_prog < 0) {
+	if (fd_prog < 0 && test->result != REJECT) {
 		printf("Failed to load program.\n");
 		printf("%s", bpf_vlog);
 		ret = 1;
+	} else if (fd_prog >= 0 && test->result == REJECT) {
+		printf("Unexpected success to load!\n");
+		printf("%s", bpf_vlog);
+		ret = 1;
+		close(fd_prog);
 	} else {
 		ret = 0;
 		/* We make a local copy so that we can strtok() it */
@@ -506,7 +567,8 @@ static int do_test_single(struct bpf_align_test *test)
 				break;
 			}
 		}
-		close(fd_prog);
+		if (fd_prog >= 0)
+			close(fd_prog);
 	}
 	return ret;
 }
