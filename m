From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] test_bpf: add similarly conflicting jump test case only for classic
Date: Tue, 26 May 2015 19:45:18 +0200
Message-ID: <7e621bdbd1df285fc9685f3a068accd8bb22d429.1432661933.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@plumgrid.com,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45668 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbbEZRpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 13:45:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While 3b52960266a3 ("test_bpf: add more eBPF jump torture cases")
added the int3 bug test case only for eBPF, which needs exactly 11
passes to converge, here's a version for classic BPF that would
need 70 passes on x86_64 to actually converge for being sucessfully
JITed. Effectively, all jumps are being optimized out resulting in
a JIT image of only 89 bytes (from originally 4096 BPF insns) only
returning K (if we would allow for it).

Might be useful for folks wanting to test out backporting the fix in
commit 3f7352bf21f8 ("x86: bpf_jit: fix compilation of large bpf
programs") who don't have eBPF. With the fix, it's delegated to the
interpreter, if the last pass still results in shrinking, in other
words this one here won't be JITed on x86_64.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 lib/test_bpf.c | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index c07b8e7..849a39f 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -314,6 +314,33 @@ static int bpf_fill_maxinsns10(struct bpf_test *self)
 	return 0;
 }
 
+static int bpf_fill_maxinsns11(struct bpf_test *self)
+{
+	unsigned int len = BPF_MAXINSNS, plen, rlen;
+	struct sock_filter *insn;
+	int i, j;
+
+	insn = kmalloc_array(len, sizeof(*insn), GFP_KERNEL);
+	if (!insn)
+		return -ENOMEM;
+
+	plen = 68;
+	rlen = (len % plen) - 1;
+
+	for (i = 0; i + plen < len; i += plen)
+		for (j = 0; j < plen; j++)
+			insn[i + j] = __BPF_JUMP(BPF_JMP | BPF_JA, plen - 1 - j, 0, 0);
+	for (j = 0; j < rlen; j++)
+		insn[i + j] = __BPF_JUMP(BPF_JMP | BPF_JA, rlen - 1 - j, 0, 0);
+
+	insn[len - 1] = __BPF_STMT(BPF_RET | BPF_K, 0xababcbac);
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
@@ -4335,6 +4362,15 @@ static struct bpf_test tests[] = {
 		{ { 0, 0xabababac } },
 		.fill_helper = bpf_fill_maxinsns10,
 	},
+	{	/* Mainly checking JIT here. */
+		"BPF_MAXINSNS: Jump, gap, jump, ...",
+		{ },
+		CLASSIC | FLAG_NO_DATA,
+		{ },
+		{ { 0, 0xababcbac } },
+		.fill_helper = bpf_fill_maxinsns11,
+	},
+
 };
 
 static struct net_device dev;
-- 
1.9.3
