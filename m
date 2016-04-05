From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCH net 3/4] lib/test_bpf: Add test to check for result of 32-bit add that overflows
Date: Tue,  5 Apr 2016 15:32:55 +0530
Message-ID: <9c799e59e71c022271c6287769d45a32f29de4bd.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
References: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: Alexei Starovoitov <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
In-Reply-To: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
References: <5e3cf7c4a971e6d2ff7a2d50bbec2e6e26883b84.1459850410.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BPF_ALU32 and BPF_ALU64 tests for adding two 32-bit values that results in
32-bit overflow.

Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Paul Mackerras <paulus@samba.org>
Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
---
 lib/test_bpf.c | 64 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 64 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 7e6fb49..2fb31aa 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -2444,6 +2444,22 @@ static struct bpf_test tests[] = {
 		{ { 0, 4294967295U } },
 	},
 	{
+		"ALU_ADD_X: 2 + 4294967294 = 0",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2),
+			BPF_LD_IMM64(R1, 4294967294U),
+			BPF_ALU32_REG(BPF_ADD, R0, R1),
+			BPF_JMP_IMM(BPF_JEQ, R0, 0, 2),
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
 		"ALU64_ADD_X: 1 + 2 = 3",
 		.u.insns_int = {
 			BPF_LD_IMM64(R0, 1),
@@ -2467,6 +2483,23 @@ static struct bpf_test tests[] = {
 		{ },
 		{ { 0, 4294967295U } },
 	},
+	{
+		"ALU64_ADD_X: 2 + 4294967294 = 4294967296",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 2),
+			BPF_LD_IMM64(R1, 4294967294U),
+			BPF_LD_IMM64(R2, 4294967296ULL),
+			BPF_ALU64_REG(BPF_ADD, R0, R1),
+			BPF_JMP_REG(BPF_JEQ, R0, R2, 2),
+			BPF_MOV32_IMM(R0, 0),
+			BPF_EXIT_INSN(),
+			BPF_MOV32_IMM(R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
 	/* BPF_ALU | BPF_ADD | BPF_K */
 	{
 		"ALU_ADD_K: 1 + 2 = 3",
@@ -2502,6 +2535,21 @@ static struct bpf_test tests[] = {
 		{ { 0, 4294967295U } },
 	},
 	{
+		"ALU_ADD_K: 4294967294 + 2 = 0",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 4294967294U),
+			BPF_ALU32_IMM(BPF_ADD, R0, 2),
+			BPF_JMP_IMM(BPF_JEQ, R0, 0, 2),
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
 		"ALU_ADD_K: 0 + (-1) = 0x00000000ffffffff",
 		.u.insns_int = {
 			BPF_LD_IMM64(R2, 0x0),
@@ -2551,6 +2599,22 @@ static struct bpf_test tests[] = {
 		{ { 0, 2147483647 } },
 	},
 	{
+		"ALU64_ADD_K: 4294967294 + 2 = 4294967296",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 4294967294U),
+			BPF_LD_IMM64(R1, 4294967296ULL),
+			BPF_ALU64_IMM(BPF_ADD, R0, 2),
+			BPF_JMP_REG(BPF_JEQ, R0, R1, 2),
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_EXIT_INSN(),
+			BPF_ALU32_IMM(BPF_MOV, R0, 1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 1 } },
+	},
+	{
 		"ALU64_ADD_K: 2147483646 + -2147483647 = -1",
 		.u.insns_int = {
 			BPF_LD_IMM64(R0, 2147483646),
-- 
2.7.4
