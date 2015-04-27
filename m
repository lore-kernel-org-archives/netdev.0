From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] bpf: fix 64-bit divide
Date: Mon, 27 Apr 2015 14:40:37 -0700
Message-ID: <1430170837-9394-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34080 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965326AbbD0Vkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 17:40:45 -0400
Received: by pdbqa5 with SMTP id qa5so141791005pdb.1
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 14:40:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ALU64_DIV instruction should be dividing 64-bit by 64-bit,
whereas do_div() does 64-bit by 32-bit divide.
x64 and arm64 JITs correctly implement 64 by 64 unsigned divide.
llvm BPF backend emits code assuming that ALU64_DIV does 64 by 64.

Fixes: 89aa075832b0 ("net: sock: allow eBPF programs to be attached to sockets")
Reported-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
The bug is old and sneaked in during the very first eBPF code drop:
Fixes: bd4cf0ed331a ("net: filter: rework/optimize internal BPF interpreter's instruction set")
but it's not affecting classic and shouldn't be backported further
than commit 89aa075832b0 (which is the above Fixes tag).
It was found by exhaustive tests being written by Michael Holzheu.

 kernel/bpf/core.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 4139a0f8b558..54f0e7fcd0e2 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -357,8 +357,8 @@ select_insn:
 	ALU64_MOD_X:
 		if (unlikely(SRC == 0))
 			return 0;
-		tmp = DST;
-		DST = do_div(tmp, SRC);
+		div64_u64_rem(DST, SRC, &tmp);
+		DST = tmp;
 		CONT;
 	ALU_MOD_X:
 		if (unlikely(SRC == 0))
@@ -367,8 +367,8 @@ select_insn:
 		DST = do_div(tmp, (u32) SRC);
 		CONT;
 	ALU64_MOD_K:
-		tmp = DST;
-		DST = do_div(tmp, IMM);
+		div64_u64_rem(DST, IMM, &tmp);
+		DST = tmp;
 		CONT;
 	ALU_MOD_K:
 		tmp = (u32) DST;
@@ -377,7 +377,7 @@ select_insn:
 	ALU64_DIV_X:
 		if (unlikely(SRC == 0))
 			return 0;
-		do_div(DST, SRC);
+		DST = div64_u64(DST, SRC);
 		CONT;
 	ALU_DIV_X:
 		if (unlikely(SRC == 0))
@@ -387,7 +387,7 @@ select_insn:
 		DST = (u32) tmp;
 		CONT;
 	ALU64_DIV_K:
-		do_div(DST, IMM);
+		DST = div64_u64(DST, IMM);
 		CONT;
 	ALU_DIV_K:
 		tmp = (u32) DST;
-- 
1.7.9.5
