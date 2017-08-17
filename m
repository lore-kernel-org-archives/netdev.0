From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/2] bpf: reuse tc bpf prologue for sk skb progs
Date: Thu, 17 Aug 2017 17:22:37 +0200
Message-ID: <efce6714acbd646c1e83876504ae7c5fb5e12625.1502983087.git.daniel@iogearbox.net>
References: <cover.1502983087.git.daniel@iogearbox.net>
Cc: john.fastabend@gmail.com, ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60889 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753168AbdHQPWn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 11:22:43 -0400
In-Reply-To: <cover.1502983087.git.daniel@iogearbox.net>
In-Reply-To: <cover.1502983087.git.daniel@iogearbox.net>
References: <cover.1502983087.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Given both program types are effecitvely doing the same in the
prologue, just reuse the one that we had for tc and only adapt
to the corresponding drop verdict value. That way, we don't need
to have the duplicate from 8a31db561566 ("bpf: add access to sock
fields and pkt data from sk_skb programs") to maintain.

Reported-by: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/core/filter.c | 47 ++++++++++-------------------------------------
 1 file changed, 10 insertions(+), 37 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index e9f8dce..9865a98 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3456,8 +3456,8 @@ static bool sock_filter_is_valid_access(int off, int size,
 	return true;
 }
 
-static int tc_cls_act_prologue(struct bpf_insn *insn_buf, bool direct_write,
-			       const struct bpf_prog *prog)
+static int bpf_unclone_prologue(struct bpf_insn *insn_buf, bool direct_write,
+				const struct bpf_prog *prog, int drop_verdict)
 {
 	struct bpf_insn *insn = insn_buf;
 
@@ -3484,7 +3484,7 @@ static int tc_cls_act_prologue(struct bpf_insn *insn_buf, bool direct_write,
 	 * return TC_ACT_SHOT;
 	 */
 	*insn++ = BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2);
-	*insn++ = BPF_ALU32_IMM(BPF_MOV, BPF_REG_0, TC_ACT_SHOT);
+	*insn++ = BPF_ALU32_IMM(BPF_MOV, BPF_REG_0, drop_verdict);
 	*insn++ = BPF_EXIT_INSN();
 
 	/* restore: */
@@ -3495,6 +3495,12 @@ static int tc_cls_act_prologue(struct bpf_insn *insn_buf, bool direct_write,
 	return insn - insn_buf;
 }
 
+static int tc_cls_act_prologue(struct bpf_insn *insn_buf, bool direct_write,
+			       const struct bpf_prog *prog)
+{
+	return bpf_unclone_prologue(insn_buf, direct_write, prog, TC_ACT_SHOT);
+}
+
 static bool tc_cls_act_is_valid_access(int off, int size,
 				       enum bpf_access_type type,
 				       struct bpf_insn_access_aux *info)
@@ -3601,40 +3607,7 @@ static bool sock_ops_is_valid_access(int off, int size,
 static int sk_skb_prologue(struct bpf_insn *insn_buf, bool direct_write,
 			   const struct bpf_prog *prog)
 {
-	struct bpf_insn *insn = insn_buf;
-
-	if (!direct_write)
-		return 0;
-
-	/* if (!skb->cloned)
-	 *       goto start;
-	 *
-	 * (Fast-path, otherwise approximation that we might be
-	 *  a clone, do the rest in helper.)
-	 */
-	*insn++ = BPF_LDX_MEM(BPF_B, BPF_REG_6, BPF_REG_1, CLONED_OFFSET());
-	*insn++ = BPF_ALU32_IMM(BPF_AND, BPF_REG_6, CLONED_MASK);
-	*insn++ = BPF_JMP_IMM(BPF_JEQ, BPF_REG_6, 0, 7);
-
-	/* ret = bpf_skb_pull_data(skb, 0); */
-	*insn++ = BPF_MOV64_REG(BPF_REG_6, BPF_REG_1);
-	*insn++ = BPF_ALU64_REG(BPF_XOR, BPF_REG_2, BPF_REG_2);
-	*insn++ = BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
-			       BPF_FUNC_skb_pull_data);
-	/* if (!ret)
-	 *      goto restore;
-	 * return SK_DROP;
-	 */
-	*insn++ = BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2);
-	*insn++ = BPF_ALU32_IMM(BPF_MOV, BPF_REG_0, SK_DROP);
-	*insn++ = BPF_EXIT_INSN();
-
-	/* restore: */
-	*insn++ = BPF_MOV64_REG(BPF_REG_1, BPF_REG_6);
-	/* start: */
-	*insn++ = prog->insnsi[0];
-
-	return insn - insn_buf;
+	return bpf_unclone_prologue(insn_buf, direct_write, prog, SK_DROP);
 }
 
 static bool sk_skb_is_valid_access(int off, int size,
-- 
1.9.3
