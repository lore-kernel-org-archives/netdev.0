From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2] test_bpf: add similarly conflicting jump test case only for classic
Date: Tue, 26 May 2015 22:35:43 +0200
Message-ID: <81f8411227ef0e1829b2b9511094112c3f4f3ca5.1432671849.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@plumgrid.com,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60815 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbbEZUfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 16:35:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While 3b52960266a3 ("test_bpf: add more eBPF jump torture cases")
added the int3 bug test case only for eBPF, which needs exactly 11
passes to converge, here's a version for classic BPF with 11 passes,
and one that would need 70 passes on x86_64 to actually converge for
being successfully JITed. Effectively, all jumps are being optimized
out resulting in a JIT image of just 89 bytes (from originally max
BPF insns), only returning K.

Might be useful as a receipe for folks wanting to craft a test case
when backporting the fix in commit 3f7352bf21f8 ("x86: bpf_jit: fix
compilation of large bpf programs") while not having eBPF. The 2nd
one is delegated to the interpreter as the last pass still results
in shrinking, in other words, this one won't be JITed on x86_64.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 v1 -> v2:
  - Fixed newline, added 2nd case

 lib/test_bpf.c | 57 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 57 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index c07b8e7..7f58c73 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -314,6 +314,47 @@ static int bpf_fill_maxinsns10(struct bpf_test *self)
 	return 0;
 }
 
+static int __bpf_fill_ja(struct bpf_test *self, unsigned int len,
+			 unsigned int plen)
+{
+	struct sock_filter *insn;
+	unsigned int rlen;
+	int i, j;
+
+	insn = kmalloc_array(len, sizeof(*insn), GFP_KERNEL);
+	if (!insn)
+		return -ENOMEM;
+
+	rlen = (len % plen) - 1;
+
+	for (i = 0; i + plen < len; i += plen)
+		for (j = 0; j < plen; j++)
+			insn[i + j] = __BPF_JUMP(BPF_JMP | BPF_JA,
+						 plen - 1 - j, 0, 0);
+	for (j = 0; j < rlen; j++)
+		insn[i + j] = __BPF_JUMP(BPF_JMP | BPF_JA, rlen - 1 - j,
+					 0, 0);
+
+	insn[len - 1] = __BPF_STMT(BPF_RET | BPF_K, 0xababcbac);
+
+	self->u.ptr.insns = insn;
+	self->u.ptr.len = len;
+
+	return 0;
+}
+
+static int bpf_fill_maxinsns11(struct bpf_test *self)
+{
+	/* Hits 70 passes on x86_64, so cannot get JITed there. */
+	return __bpf_fill_ja(self, BPF_MAXINSNS, 68);
+}
+
+static int bpf_fill_ja(struct bpf_test *self)
+{
+	/* Hits exactly 11 passes on x86_64 JIT. */
+	return __bpf_fill_ja(self, 12, 9);
+}
+
 static struct bpf_test tests[] = {
 	{
 		"TAX",
@@ -4252,6 +4293,14 @@ static struct bpf_test tests[] = {
 		{ },
 		{ { 0, 1 } },
 	},
+	{
+		"JMP_JA: Jump, gap, jump, ...",
+		{ },
+		CLASSIC | FLAG_NO_DATA,
+		{ },
+		{ { 0, 0xababcbac } },
+		.fill_helper = bpf_fill_ja,
+	},
 	{	/* Mainly checking JIT here. */
 		"BPF_MAXINSNS: Maximum possible literals",
 		{ },
@@ -4335,6 +4384,14 @@ static struct bpf_test tests[] = {
 		{ { 0, 0xabababac } },
 		.fill_helper = bpf_fill_maxinsns10,
 	},
+	{
+		"BPF_MAXINSNS: Jump, gap, jump, ...",
+		{ },
+		CLASSIC | FLAG_NO_DATA,
+		{ },
+		{ { 0, 0xababcbac } },
+		.fill_helper = bpf_fill_maxinsns11,
+	},
 };
 
 static struct net_device dev;
-- 
1.9.3
