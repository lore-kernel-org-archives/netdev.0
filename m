From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] bpf: fix verifier memory corruption
Date: Tue, 14 Apr 2015 15:57:13 -0700
Message-ID: <1429052233-8252-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:36243 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179AbbDNW5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 18:57:24 -0400
Received: by pdea3 with SMTP id a3so28658544pde.3
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 15:57:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to missing bounds check the DAG pass of the BPF verifier can corrupt
the memory which can cause random crashes during program loading:

[8.449451] BUG: unable to handle kernel paging request at ffffffffffffffff
[8.451293] IP: [<ffffffff811de33d>] kmem_cache_alloc_trace+0x8d/0x2f0
[8.452329] Oops: 0000 [#1] SMP
[8.452329] Call Trace:
[8.452329]  [<ffffffff8116cc82>] bpf_check+0x852/0x2000
[8.452329]  [<ffffffff8116b7e4>] bpf_prog_load+0x1e4/0x310
[8.452329]  [<ffffffff811b190f>] ? might_fault+0x5f/0xb0
[8.452329]  [<ffffffff8116c206>] SyS_bpf+0x806/0xa30

Fixes: f1bca824dabb ("bpf: add search pruning optimization to verifier")
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
Many things need to align for this crash to be seen, yet I managed to hit it.
In my case JA was last insn, 't' was 255 and explored_states array
had 256 elements. I've double checked other similar paths and all seems clean.

 kernel/bpf/verifier.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index a28e09c7825d..36508e69e92a 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1380,7 +1380,8 @@ peek_stack:
 			/* tell verifier to check for equivalent states
 			 * after every call and jump
 			 */
-			env->explored_states[t + 1] = STATE_LIST_MARK;
+			if (t + 1 < insn_cnt)
+				env->explored_states[t + 1] = STATE_LIST_MARK;
 		} else {
 			/* conditional jump with two edges */
 			ret = push_insn(t, t + 1, FALLTHROUGH, env);
-- 
1.7.9.5
