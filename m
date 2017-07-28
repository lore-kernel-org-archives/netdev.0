From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: fix bpf_prog_get_info_by_fd to dump correct xlated_prog_len
Date: Fri, 28 Jul 2017 17:05:25 +0200
Message-ID: <a88afb3f19e16a937683bc2bfa80100144fb3792.1501254197.git.daniel@iogearbox.net>
Cc: kafai@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46088 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751071AbdG1PFd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 11:05:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bpf_prog_size(prog->len) is not the correct length we want to dump
back to user space. The code in bpf_prog_get_info_by_fd() uses this
to copy prog->insnsi to user space, but bpf_prog_size(prog->len) also
includes the size of struct bpf_prog itself plus program instructions
and is usually used either in context of accounting or for bpf_prog_alloc()
et al, thus we copy out of bounds in bpf_prog_get_info_by_fd()
potentially. Use the correct bpf_prog_insn_size() instead.

Fixes: 1e2709769086 ("bpf: Add BPF_OBJ_GET_INFO_BY_FD")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/syscall.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 84bb399..6c772ad 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -1312,7 +1312,7 @@ static int bpf_prog_get_info_by_fd(struct bpf_prog *prog,
 	}
 
 	ulen = info.xlated_prog_len;
-	info.xlated_prog_len = bpf_prog_size(prog->len);
+	info.xlated_prog_len = bpf_prog_insn_size(prog);
 	if (info.xlated_prog_len && ulen) {
 		uinsns = u64_to_user_ptr(info.xlated_prog_insns);
 		ulen = min_t(u32, info.xlated_prog_len, ulen);
-- 
1.9.3
