From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv4 net-next 07/15] bpf: recognize 64bit immediate loads as consts
Date: Thu, 15 Sep 2016 20:12:27 +0100
Message-ID: <1473966755-30106-8-git-send-email-jakub.kicinski@netronome.com>
References: <1473966755-30106-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37974 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753925AbcIOTOO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 15:14:14 -0400
Received: by mail-wm0-f46.google.com with SMTP id 1so1154893wmz.1
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 12:14:13 -0700 (PDT)
In-Reply-To: <1473966755-30106-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running as parser interpret BPF_LD | BPF_IMM | BPF_DW
instructions as loading CONST_IMM with the value stored
in imm.  The verifier will continue not recognizing those
due to concerns about search space/program complexity
increase.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
v3:
 - limit to parsers.
---
 kernel/bpf/verifier.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index d93e78331b90..f5bed7cce08d 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1766,9 +1766,19 @@ static int check_ld_imm(struct bpf_verifier_env *env, struct bpf_insn *insn)
 	if (err)
 		return err;
 
-	if (insn->src_reg == 0)
-		/* generic move 64-bit immediate into a register */
+	if (insn->src_reg == 0) {
+		/* generic move 64-bit immediate into a register,
+		 * only analyzer needs to collect the ld_imm value.
+		 */
+		u64 imm = ((u64)(insn + 1)->imm << 32) | (u32)insn->imm;
+
+		if (!env->analyzer_ops)
+			return 0;
+
+		regs[insn->dst_reg].type = CONST_IMM;
+		regs[insn->dst_reg].imm = imm;
 		return 0;
+	}
 
 	/* replace_map_fd_with_map_ptr() should have caught bad ld_imm64 */
 	BUG_ON(insn->src_reg != BPF_PSEUDO_MAP_FD);
-- 
1.9.1
