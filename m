From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 5/5] bpf, samples: add test cases for raw stack
Date: Wed, 13 Apr 2016 00:10:54 +0200
Message-ID: <7ddc9a78b0d6cf5acbb9b8c3135d4964d872e409.1460497071.git.daniel@iogearbox.net>
References: <cover.1460497071.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, bblanco@plumgrid.com,
	brendan.d.gregg@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34359 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934081AbcDLWLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 18:11:14 -0400
In-Reply-To: <cover.1460497071.git.daniel@iogearbox.net>
In-Reply-To: <cover.1460497071.git.daniel@iogearbox.net>
References: <cover.1460497071.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds test cases mostly around ARG_PTR_TO_RAW_STACK to check the
verifier behaviour.

  [...]
  #84 raw_stack: no skb_load_bytes OK
  #85 raw_stack: skb_load_bytes, no init OK
  #86 raw_stack: skb_load_bytes, init OK
  #87 raw_stack: skb_load_bytes, spilled regs around bounds OK
  #88 raw_stack: skb_load_bytes, spilled regs corruption OK
  #89 raw_stack: skb_load_bytes, spilled regs corruption 2 OK
  #90 raw_stack: skb_load_bytes, spilled regs + data OK
  #91 raw_stack: skb_load_bytes, invalid access 1 OK
  #92 raw_stack: skb_load_bytes, invalid access 2 OK
  #93 raw_stack: skb_load_bytes, invalid access 3 OK
  #94 raw_stack: skb_load_bytes, invalid access 4 OK
  #95 raw_stack: skb_load_bytes, invalid access 5 OK
  #96 raw_stack: skb_load_bytes, invalid access 6 OK
  #97 raw_stack: skb_load_bytes, large access OK
  Summary: 98 PASSED, 0 FAILED

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/test_verifier.c | 268 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 268 insertions(+)

diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
index 4b51a90..9eba8d1 100644
--- a/samples/bpf/test_verifier.c
+++ b/samples/bpf/test_verifier.c
@@ -309,6 +309,19 @@ static struct bpf_test tests[] = {
 		.result_unpriv = REJECT,
 	},
 	{
+		"check valid spill/fill, skb mark",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_1),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_6, -8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_10, -8),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.result_unpriv = ACCEPT,
+	},
+	{
 		"check corrupted spill/fill",
 		.insns = {
 			/* spill R1(ctx) into stack */
@@ -1180,6 +1193,261 @@ static struct bpf_test tests[] = {
 		.result_unpriv = REJECT,
 		.result = ACCEPT,
 	},
+	{
+		"raw_stack: no skb_load_bytes",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			/* Call to skb_load_bytes() omitted. */
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid read from stack off -8+0 size 8",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, no init",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, init",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_6, 0, 0xcafe),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, spilled regs around bounds",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, -8), /* spill ctx from R1 */
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1,  8), /* spill ctx from R1 */
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, -8), /* fill ctx into R0 */
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_6,  8), /* fill ctx into R2 */
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_2,
+				    offsetof(struct __sk_buff, priority)),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_2),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, spilled regs corruption",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0), /* spill ctx from R1 */
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0), /* fill ctx into R0 */
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "R0 invalid mem access 'inv'",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, spilled regs corruption 2",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, -8), /* spill ctx from R1 */
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1,  0), /* spill ctx from R1 */
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1,  8), /* spill ctx from R1 */
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, -8), /* fill ctx into R0 */
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_6,  8), /* fill ctx into R2 */
+			BPF_LDX_MEM(BPF_DW, BPF_REG_3, BPF_REG_6,  0), /* fill ctx into R3 */
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_2,
+				    offsetof(struct __sk_buff, priority)),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_2),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_3,
+				    offsetof(struct __sk_buff, pkt_type)),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_3),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "R3 invalid mem access 'inv'",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, spilled regs + data",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, -8), /* spill ctx from R1 */
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1,  0), /* spill ctx from R1 */
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1,  8), /* spill ctx from R1 */
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, -8), /* fill ctx into R0 */
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_6,  8), /* fill ctx into R2 */
+			BPF_LDX_MEM(BPF_DW, BPF_REG_3, BPF_REG_6,  0), /* fill data into R3 */
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_2,
+				    offsetof(struct __sk_buff, priority)),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_3),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, invalid access 1",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -513),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack type R3 off=-513 access_size=8",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, invalid access 2",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -1),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack type R3 off=-1 access_size=8",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, invalid access 3",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 0xffffffff),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 0xffffffff),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack type R3 off=-1 access_size=-1",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, invalid access 4",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -1),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 0x7fffffff),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack type R3 off=-1 access_size=2147483647",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, invalid access 5",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -512),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 0x7fffffff),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack type R3 off=-512 access_size=2147483647",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, invalid access 6",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -512),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack type R3 off=-512 access_size=0",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, large access",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -512),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 512),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
 };
 
 static int probe_filter_length(struct bpf_insn *fp)
-- 
1.9.3
