From: Jann Horn <jannh@google.com>
Subject: [PATCH] bpf: fix double-fdput in replace_map_fd_with_map_ptr()
Date: Tue, 26 Apr 2016 22:26:26 +0200
Message-ID: <1461702386-17490-1-git-send-email-jannh@google.com>
Cc: netdev@vger.kernel.org, Jann Horn <jannh@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37758 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753829AbcDZU0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 16:26:32 -0400
Received: by mail-wm0-f53.google.com with SMTP id n3so21736116wmn.0
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 13:26:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bpf(BPF_PROG_LOAD, ...) was invoked with a BPF program whose bytecode
references a non-map file descriptor as a map file descriptor, the error
handling code called fdput() twice instead of once (in __bpf_map_get() and
in replace_map_fd_with_map_ptr()). If the file descriptor table of the
current task is shared, this causes f_count to be decremented too much,
allowing the struct file to be freed while it is still in use
(use-after-free). This can be exploited to gain root privileges by an
unprivileged user.

This bug was introduced in
commit 0246e64d9a5f ("bpf: handle pseudo BPF_LD_IMM64 insn"), but is only
exploitable since
commit 1be7f75d1668 ("bpf: enable non-root eBPF programs") because
previously, CAP_SYS_ADMIN was required to reach the vulnerable code.

(posted publicly according to request by maintainer)

Signed-off-by: Jann Horn <jannh@google.com>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 kernel/bpf/verifier.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 2e08f8e..8291251 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2029,7 +2029,6 @@ static int replace_map_fd_with_map_ptr(struct verifier_env *env)
 			if (IS_ERR(map)) {
 				verbose("fd %d is not pointing to valid bpf_map\n",
 					insn->imm);
-				fdput(f);
 				return PTR_ERR(map);
 			}
 
-- 
2.8.0.rc3.226.g39d4020
