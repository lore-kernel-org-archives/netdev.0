From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 2/9] nfp: bpf: refactor nfp_bpf_check_ptr()
Date: Mon, 23 Oct 2017 11:58:07 -0700
Message-ID: <20171023185814.4797-3-jakub.kicinski@netronome.com>
References: <20171023185814.4797-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:44884 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751785AbdJWS61 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 14:58:27 -0400
Received: by mail-pg0-f66.google.com with SMTP id j3so12491751pga.1
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 11:58:27 -0700 (PDT)
In-Reply-To: <20171023185814.4797-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nfp_bpf_check_ptr() mostly looks at the pointer register.
Add a temporary variable to shorten the code.

While at it make sure we print error messages if translation
fails to help users identify the problem (to be carried in
ext_ack in due course).

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/verifier.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
index e361c0e3b788..4d2ed84a82e0 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
@@ -113,17 +113,23 @@ nfp_bpf_check_exit(struct nfp_prog *nfp_prog,
 
 static int
 nfp_bpf_check_ptr(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
-		  const struct bpf_verifier_env *env, u8 reg)
+		  const struct bpf_verifier_env *env, u8 reg_no)
 {
-	if (env->cur_state.regs[reg].type != PTR_TO_CTX &&
-	    env->cur_state.regs[reg].type != PTR_TO_PACKET)
+	const struct bpf_reg_state *reg = &env->cur_state.regs[reg_no];
+
+	if (reg->type != PTR_TO_CTX &&
+	    reg->type != PTR_TO_PACKET) {
+		pr_info("unsupported ptr type: %d\n", reg->type);
 		return -EINVAL;
+	}
 
-	if (meta->ptr.type != NOT_INIT &&
-	    meta->ptr.type != env->cur_state.regs[reg].type)
+	if (meta->ptr.type != NOT_INIT && meta->ptr.type != reg->type) {
+		pr_info("ptr type changed for instruction %d -> %d\n",
+			meta->ptr.type, reg->type);
 		return -EINVAL;
+	}
 
-	meta->ptr = env->cur_state.regs[reg];
+	meta->ptr = *reg;
 
 	return 0;
 }
-- 
2.14.1
