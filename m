From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 5/5] bpf, test: add couple of test cases
Date: Thu, 17 Dec 2015 23:51:57 +0100
Message-ID: <9c2e19af98fcb41b3058cb7c32577b5ac1920858.1450391511.git.daniel@iogearbox.net>
References: <cover.1450391511.git.daniel@iogearbox.net>
Cc: ast@kernel.org, holzheu@linux.vnet.ibm.com, zlim.lnx@gmail.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53900 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964900AbbLQWwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 17:52:06 -0500
In-Reply-To: <cover.1450391511.git.daniel@iogearbox.net>
In-Reply-To: <cover.1450391511.git.daniel@iogearbox.net>
References: <cover.1450391511.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add couple of test cases for interpreter but also JITs, f.e. to test that
when imm32 moves are being done, upper 32bits of the regs are being zero
extended.

Without JIT:

  [...]
  [ 1114.129301] test_bpf: #43 MOV REG64 jited:0 128 PASS
  [ 1114.130626] test_bpf: #44 MOV REG32 jited:0 139 PASS
  [ 1114.132055] test_bpf: #45 LD IMM64 jited:0 124 PASS
  [...]

With JIT (generated code can as usual be nicely verified with the help of
bpf_jit_disasm tool):

  [...]
  [ 1062.726782] test_bpf: #43 MOV REG64 jited:1 6 PASS
  [ 1062.726890] test_bpf: #44 MOV REG32 jited:1 6 PASS
  [ 1062.726993] test_bpf: #45 LD IMM64 jited:1 6 PASS
  [...]

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 lib/test_bpf.c | 120 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 120 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 10cd186..27a7a26 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -1685,6 +1685,126 @@ static struct bpf_test tests[] = {
 		{ },
 		{ { 0, 0x35d97ef2 } }
 	},
+	{	/* Mainly checking JIT here. */
+		"MOV REG64",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0xffffffffffffffffLL),
+			BPF_MOV64_REG(R1, R0),
+			BPF_MOV64_REG(R2, R1),
+			BPF_MOV64_REG(R3, R2),
+			BPF_MOV64_REG(R4, R3),
+			BPF_MOV64_REG(R5, R4),
+			BPF_MOV64_REG(R6, R5),
+			BPF_MOV64_REG(R7, R6),
+			BPF_MOV64_REG(R8, R7),
+			BPF_MOV64_REG(R9, R8),
+			BPF_ALU64_IMM(BPF_MOV, R0, 0),
+			BPF_ALU64_IMM(BPF_MOV, R1, 0),
+			BPF_ALU64_IMM(BPF_MOV, R2, 0),
+			BPF_ALU64_IMM(BPF_MOV, R3, 0),
+			BPF_ALU64_IMM(BPF_MOV, R4, 0),
+			BPF_ALU64_IMM(BPF_MOV, R5, 0),
+			BPF_ALU64_IMM(BPF_MOV, R6, 0),
+			BPF_ALU64_IMM(BPF_MOV, R7, 0),
+			BPF_ALU64_IMM(BPF_MOV, R8, 0),
+			BPF_ALU64_IMM(BPF_MOV, R9, 0),
+			BPF_ALU64_REG(BPF_ADD, R0, R0),
+			BPF_ALU64_REG(BPF_ADD, R0, R1),
+			BPF_ALU64_REG(BPF_ADD, R0, R2),
+			BPF_ALU64_REG(BPF_ADD, R0, R3),
+			BPF_ALU64_REG(BPF_ADD, R0, R4),
+			BPF_ALU64_REG(BPF_ADD, R0, R5),
+			BPF_ALU64_REG(BPF_ADD, R0, R6),
+			BPF_ALU64_REG(BPF_ADD, R0, R7),
+			BPF_ALU64_REG(BPF_ADD, R0, R8),
+			BPF_ALU64_REG(BPF_ADD, R0, R9),
+			BPF_ALU64_IMM(BPF_ADD, R0, 0xfefe),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xfefe } }
+	},
+	{	/* Mainly checking JIT here. */
+		"MOV REG32",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0xffffffffffffffffLL),
+			BPF_MOV64_REG(R1, R0),
+			BPF_MOV64_REG(R2, R1),
+			BPF_MOV64_REG(R3, R2),
+			BPF_MOV64_REG(R4, R3),
+			BPF_MOV64_REG(R5, R4),
+			BPF_MOV64_REG(R6, R5),
+			BPF_MOV64_REG(R7, R6),
+			BPF_MOV64_REG(R8, R7),
+			BPF_MOV64_REG(R9, R8),
+			BPF_ALU32_IMM(BPF_MOV, R0, 0),
+			BPF_ALU32_IMM(BPF_MOV, R1, 0),
+			BPF_ALU32_IMM(BPF_MOV, R2, 0),
+			BPF_ALU32_IMM(BPF_MOV, R3, 0),
+			BPF_ALU32_IMM(BPF_MOV, R4, 0),
+			BPF_ALU32_IMM(BPF_MOV, R5, 0),
+			BPF_ALU32_IMM(BPF_MOV, R6, 0),
+			BPF_ALU32_IMM(BPF_MOV, R7, 0),
+			BPF_ALU32_IMM(BPF_MOV, R8, 0),
+			BPF_ALU32_IMM(BPF_MOV, R9, 0),
+			BPF_ALU64_REG(BPF_ADD, R0, R0),
+			BPF_ALU64_REG(BPF_ADD, R0, R1),
+			BPF_ALU64_REG(BPF_ADD, R0, R2),
+			BPF_ALU64_REG(BPF_ADD, R0, R3),
+			BPF_ALU64_REG(BPF_ADD, R0, R4),
+			BPF_ALU64_REG(BPF_ADD, R0, R5),
+			BPF_ALU64_REG(BPF_ADD, R0, R6),
+			BPF_ALU64_REG(BPF_ADD, R0, R7),
+			BPF_ALU64_REG(BPF_ADD, R0, R8),
+			BPF_ALU64_REG(BPF_ADD, R0, R9),
+			BPF_ALU64_IMM(BPF_ADD, R0, 0xfefe),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xfefe } }
+	},
+	{	/* Mainly checking JIT here. */
+		"LD IMM64",
+		.u.insns_int = {
+			BPF_LD_IMM64(R0, 0xffffffffffffffffLL),
+			BPF_MOV64_REG(R1, R0),
+			BPF_MOV64_REG(R2, R1),
+			BPF_MOV64_REG(R3, R2),
+			BPF_MOV64_REG(R4, R3),
+			BPF_MOV64_REG(R5, R4),
+			BPF_MOV64_REG(R6, R5),
+			BPF_MOV64_REG(R7, R6),
+			BPF_MOV64_REG(R8, R7),
+			BPF_MOV64_REG(R9, R8),
+			BPF_LD_IMM64(R0, 0x0LL),
+			BPF_LD_IMM64(R1, 0x0LL),
+			BPF_LD_IMM64(R2, 0x0LL),
+			BPF_LD_IMM64(R3, 0x0LL),
+			BPF_LD_IMM64(R4, 0x0LL),
+			BPF_LD_IMM64(R5, 0x0LL),
+			BPF_LD_IMM64(R6, 0x0LL),
+			BPF_LD_IMM64(R7, 0x0LL),
+			BPF_LD_IMM64(R8, 0x0LL),
+			BPF_LD_IMM64(R9, 0x0LL),
+			BPF_ALU64_REG(BPF_ADD, R0, R0),
+			BPF_ALU64_REG(BPF_ADD, R0, R1),
+			BPF_ALU64_REG(BPF_ADD, R0, R2),
+			BPF_ALU64_REG(BPF_ADD, R0, R3),
+			BPF_ALU64_REG(BPF_ADD, R0, R4),
+			BPF_ALU64_REG(BPF_ADD, R0, R5),
+			BPF_ALU64_REG(BPF_ADD, R0, R6),
+			BPF_ALU64_REG(BPF_ADD, R0, R7),
+			BPF_ALU64_REG(BPF_ADD, R0, R8),
+			BPF_ALU64_REG(BPF_ADD, R0, R9),
+			BPF_ALU64_IMM(BPF_ADD, R0, 0xfefe),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0xfefe } }
+	},
 	{
 		"INT: ALU MIX",
 		.u.insns_int = {
-- 
1.9.3
