From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf: fix loading of BPF_MAXINSNS sized programs
Date: Wed,  7 Dec 2016 01:15:44 +0100
Message-ID: <7aad2a49d7a717fd018b338bb9d7167bafd1fdb8.1481069166.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43285 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753548AbcLGAP6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 19:15:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

General assumption is that single program can hold up to BPF_MAXINSNS,
that is, 4096 number of instructions. It is the case with cBPF and
that limit was carried over to eBPF. When recently testing digest, I
noticed that it's actually not possible to feed 4096 instructions
via bpf(2).

The check for > BPF_MAXINSNS was added back then to bpf_check() in
cbd357008604 ("bpf: verifier (add ability to receive verification log)").
However, 09756af46893 ("bpf: expand BPF syscall with program load/unload")
added yet another check that comes before that into bpf_prog_load(),
but this time bails out already in case of >= BPF_MAXINSNS.

Fix it up and perform the check early in bpf_prog_load(), so we can drop
the second one in bpf_check(). It makes sense, because also a 0 insn
program is useless and we don't want to waste any resources doing work
up to bpf_check() point. The existing bpf(2) man page documents E2BIG
as the official error for such cases, so just stick with it as well.

Fixes: 09756af46893 ("bpf: expand BPF syscall with program load/unload")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 ( net-next is just fine imho. )

 kernel/bpf/syscall.c  | 4 ++--
 kernel/bpf/verifier.c | 3 ---
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index c0d2b42..88f609f 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -786,8 +786,8 @@ static int bpf_prog_load(union bpf_attr *attr)
 	/* eBPF programs must be GPL compatible to use GPL-ed functions */
 	is_gpl = license_is_gpl_compatible(license);
 
-	if (attr->insn_cnt >= BPF_MAXINSNS)
-		return -EINVAL;
+	if (attr->insn_cnt == 0 || attr->insn_cnt > BPF_MAXINSNS)
+		return -E2BIG;
 
 	if (type == BPF_PROG_TYPE_KPROBE &&
 	    attr->kern_version != LINUX_VERSION_CODE)
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index cb37339..da9fb2a 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3133,9 +3133,6 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	struct bpf_verifier_env *env;
 	int ret = -EINVAL;
 
-	if ((*prog)->len <= 0 || (*prog)->len > BPF_MAXINSNS)
-		return -E2BIG;
-
 	/* 'struct bpf_verifier_env' can be global, but since it's not small,
 	 * allocate/free it every time bpf_check() is called
 	 */
-- 
1.9.3
