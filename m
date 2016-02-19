From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 6/6] bpf: don't emit mov A,A on return
Date: Fri, 19 Feb 2016 23:05:27 +0100
Message-ID: <95179341a66646597556bdd334413a3d65db2ea4.1455899111.git.daniel@iogearbox.net>
References: <cover.1455899111.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35350 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993131AbcBSWFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 17:05:41 -0500
In-Reply-To: <cover.1455899111.git.daniel@iogearbox.net>
In-Reply-To: <cover.1455899111.git.daniel@iogearbox.net>
References: <cover.1455899111.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While debugging with bpf_jit_disasm I noticed emissions of 'mov %eax,%eax',
and found that this comes from BPF_RET | BPF_A translations from classic
BPF. Emitting this is unnecessary as BPF_REG_A is mapped into BPF_REG_0
already, therefore only emit a mov when immediates are used as return value.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 8a0b8c3..a3aba15 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -530,12 +530,14 @@ do_pass:
 			*insn = BPF_MOV64_REG(BPF_REG_A, BPF_REG_TMP);
 			break;
 
-		/* RET_K, RET_A are remaped into 2 insns. */
+		/* RET_K is remaped into 2 insns. RET_A case doesn't need an
+		 * extra mov as BPF_REG_0 is already mapped into BPF_REG_A.
+		 */
 		case BPF_RET | BPF_A:
 		case BPF_RET | BPF_K:
-			*insn++ = BPF_MOV32_RAW(BPF_RVAL(fp->code) == BPF_K ?
-						BPF_K : BPF_X, BPF_REG_0,
-						BPF_REG_A, fp->k);
+			if (BPF_RVAL(fp->code) == BPF_K)
+				*insn++ = BPF_MOV32_RAW(BPF_K, BPF_REG_0,
+							0, fp->k);
 			*insn = BPF_EXIT_INSN();
 			break;
 
-- 
1.9.3
