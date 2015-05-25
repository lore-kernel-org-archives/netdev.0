From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] tools: bpf_jit_disasm: fix segfault on disabled debugging log output
Date: Mon, 25 May 2015 14:08:03 +0200
Message-ID: <beb215366f62df41ce57bbb523e0c554719cf9c1.1432555472.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37954 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759AbbEYMIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 08:08:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With recent debugging, I noticed that bpf_jit_disasm segfaults when
there's no debugging output from the JIT compiler to the kernel log.

Reason is that when regexec(3) doesn't match on anything, start/end
offsets are not being filled out and contain some uninitialized garbage
from stack. Thus, we need zero out offsets first.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tools/net/bpf_jit_disasm.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/tools/net/bpf_jit_disasm.c b/tools/net/bpf_jit_disasm.c
index c5baf9c..618c2bc 100644
--- a/tools/net/bpf_jit_disasm.c
+++ b/tools/net/bpf_jit_disasm.c
@@ -123,6 +123,8 @@ static int get_last_jit_image(char *haystack, size_t hlen,
 	assert(ret == 0);
 
 	ptr = haystack;
+	memset(pmatch, 0, sizeof(pmatch));
+
 	while (1) {
 		ret = regexec(&regex, ptr, 1, pmatch, 0);
 		if (ret == 0) {
-- 
1.9.3
