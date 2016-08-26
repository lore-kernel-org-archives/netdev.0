From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFCv2 05/16] bpf: recognize 64bit immediate loads as consts
Date: Fri, 26 Aug 2016 19:06:04 +0100
Message-ID: <1472234775-29453-6-git-send-email-jakub.kicinski@netronome.com>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:38435 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753308AbcHZSQF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 14:16:05 -0400
Received: by mail-wm0-f50.google.com with SMTP id o80so3561651wme.1
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 11:16:05 -0700 (PDT)
In-Reply-To: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When verifier sees a generic BPF_LD | BPF_IMM | BPF_DW
it should mark the dst register as CONST_IMM with
the loaded value stored in imm.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 kernel/bpf/verifier.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index abb61f3f6900..db68a0e5db1e 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1787,9 +1787,14 @@ static int check_ld_imm(struct verifier_env *env, struct bpf_insn *insn)
 	if (err)
 		return err;
 
-	if (insn->src_reg == 0)
+	if (insn->src_reg == 0) {
 		/* generic move 64-bit immediate into a register */
+		u64 imm = ((u64)(insn + 1)->imm << 32) | (u32)insn->imm;
+
+		regs[insn->dst_reg].type = CONST_IMM;
+		regs[insn->dst_reg].imm = imm;
 		return 0;
+	}
 
 	/* replace_map_fd_with_map_ptr() should have caught bad ld_imm64 */
 	BUG_ON(insn->src_reg != BPF_PSEUDO_MAP_FD);
-- 
1.9.1
