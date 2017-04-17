From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 1/2] bpf: fix cb access in socket filter programs on tail calls
Date: Mon, 17 Apr 2017 03:12:06 +0200
Message-ID: <c60acf3aec547185f9753494876fbd9b14ba54a2.1492390940.git.daniel@iogearbox.net>
References: <cover.1492390940.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, kubakici@wp.pl,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51322 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756945AbdDQBMR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2017 21:12:17 -0400
In-Reply-To: <cover.1492390940.git.daniel@iogearbox.net>
In-Reply-To: <cover.1492390940.git.daniel@iogearbox.net>
References: <cover.1492390940.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit ff936a04e5f2 ("bpf: fix cb access in socket filter programs")
added a fix for socket filter programs such that in i) AF_PACKET the
20 bytes of skb->cb[] area gets zeroed before use in order to not leak
data, and ii) socket filter programs attached to TCP/UDP sockets need
to save/restore these 20 bytes since they are also used by protocol
layers at that time.

The problem is that bpf_prog_run_save_cb() and bpf_prog_run_clear_cb()
only look at the actual attached program to determine whether to zero
or save/restore the skb->cb[] parts. There can be cases where the
actual attached program does not access the skb->cb[], but the program
tail calls into another program which does access this area. In such
a case, the zero or save/restore is currently not performed.

Since the programs we tail call into are unknown at verification time
and can dynamically change, we need to assume that whenever the attached
program performs a tail call, that later programs could access the
skb->cb[], and therefore we need to always set cb_access to 1.

Fixes: ff936a04e5f2 ("bpf: fix cb access in socket filter programs")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/syscall.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 7af0dcc..ee5c969 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -617,6 +617,13 @@ static void fixup_bpf_calls(struct bpf_prog *prog)
 			if (insn->imm == BPF_FUNC_xdp_adjust_head)
 				prog->xdp_adjust_head = 1;
 			if (insn->imm == BPF_FUNC_tail_call) {
+				/* If we tail call into other programs, we
+				 * cannot make any assumptions since they
+				 * can be replaced dynamically during runtime
+				 * in the program array.
+				 */
+				prog->cb_access = 1;
+
 				/* mark bpf_tail_call as different opcode
 				 * to avoid conditional branch in
 				 * interpeter for every normal call
-- 
1.9.3
