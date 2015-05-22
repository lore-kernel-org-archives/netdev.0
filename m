From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] test_bpf: add more eBPF jump torture cases
Date: Sat, 23 May 2015 01:10:07 +0200
Message-ID: <b23d3a10edbe46ac70bcc57a05ece597e1b6c09c.1432335952.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, edumazet@google.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42224 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757053AbbEVXKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 19:10:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add two more eBPF test cases for JITs, i.e. the second one revealed a
bug in the x86_64 JIT compiler, where only an int3 filled image from
the allocator was emitted and later wrongly set by the compiler as the
bpf_func program code since optimization pass boundary was surpassed
w/o actually emitting opcodes.

Interpreter:

  [   45.782892] test_bpf: #242 BPF_MAXINSNS: Very long jump backwards jited:0 11 PASS
  [   45.783062] test_bpf: #243 BPF_MAXINSNS: Edge hopping nuthouse jited:0 14705 PASS

After x86_64 JIT (fixed):

  [   80.495638] test_bpf: #242 BPF_MAXINSNS: Very long jump backwards jited:1 6 PASS
  [   80.495957] test_bpf: #243 BPF_MAXINSNS: Edge hopping nuthouse jited:1 17157 PASS

Reference: http://thread.gmane.org/gmane.linux.network/364729
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 (Testcase to Alexei's patch.)

 lib/test_bpf.c | 67 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 67 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 9b012a8..c07b8e7 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -263,6 +263,57 @@ static int bpf_fill_maxinsns8(struct bpf_test *self)
 	return 0;
 }
 
+static int bpf_fill_maxinsns9(struct bpf_test *self)
+{
+	unsigned int len = BPF_MAXINSNS;
+	struct bpf_insn *insn;
+	int i;
+
+	insn = kmalloc_array(len, sizeof(*insn), GFP_KERNEL);
+	if (!insn)
+		return -ENOMEM;
+
+	insn[0] = BPF_JMP_IMM(BPF_JA, 0, 0, len - 2);
+	insn[1] = BPF_ALU32_IMM(BPF_MOV, R0, 0xcbababab);
+	insn[2] = BPF_EXIT_INSN();
+
+	for (i = 3; i < len - 2; i++)
+		insn[i] = BPF_ALU32_IMM(BPF_MOV, R0, 0xfefefefe);
+
+	insn[len - 2] = BPF_EXIT_INSN();
+	insn[len - 1] = BPF_JMP_IMM(BPF_JA, 0, 0, -(len - 1));
+
+	self->u.ptr.insns = insn;
+	self->u.ptr.len = len;
+
+	return 0;
+}
+
+static int bpf_fill_maxinsns10(struct bpf_test *self)
+{
+	unsigned int len = BPF_MAXINSNS, hlen = len - 2;
+	struct bpf_insn *insn;
+	int i;
+
+	insn = kmalloc_array(len, sizeof(*insn), GFP_KERNEL);
+	if (!insn)
+		return -ENOMEM;
+
+	for (i = 0; i < hlen / 2; i++)
+		insn[i] = BPF_JMP_IMM(BPF_JA, 0, 0, hlen - 2 - 2 * i);
+	for (i = hlen - 1; i > hlen / 2; i--)
+		insn[i] = BPF_JMP_IMM(BPF_JA, 0, 0, hlen - 1 - 2 * i);
+
+	insn[hlen / 2] = BPF_JMP_IMM(BPF_JA, 0, 0, hlen / 2 - 1);
+	insn[hlen]     = BPF_ALU32_IMM(BPF_MOV, R0, 0xabababac);
+	insn[hlen + 1] = BPF_EXIT_INSN();
+
+	self->u.ptr.insns = insn;
+	self->u.ptr.len = len;
+
+	return 0;
+}
+
 static struct bpf_test tests[] = {
 	{
 		"TAX",
@@ -4268,6 +4319,22 @@ static struct bpf_test tests[] = {
 		{ { 0, 0xffffffff } },
 		.fill_helper = bpf_fill_maxinsns8,
 	},
+	{	/* Mainly checking JIT here. */
+		"BPF_MAXINSNS: Very long jump backwards",
+		{ },
+		INTERNAL | FLAG_NO_DATA,
+		{ },
+		{ { 0, 0xcbababab } },
+		.fill_helper = bpf_fill_maxinsns9,
+	},
+	{	/* Mainly checking JIT here. */
+		"BPF_MAXINSNS: Edge hopping nuthouse",
+		{ },
+		INTERNAL | FLAG_NO_DATA,
+		{ },
+		{ { 0, 0xabababac } },
+		.fill_helper = bpf_fill_maxinsns10,
+	},
 };
 
 static struct net_device dev;
-- 
1.9.3
