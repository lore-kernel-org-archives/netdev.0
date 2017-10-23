From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 1/9] nfp: bpf: add helper for emitting nops
Date: Mon, 23 Oct 2017 11:58:06 -0700
Message-ID: <20171023185814.4797-2-jakub.kicinski@netronome.com>
References: <20171023185814.4797-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:53185 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751673AbdJWS61 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 14:58:27 -0400
Received: by mail-pf0-f194.google.com with SMTP id e64so17769286pfk.9
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 11:58:27 -0700 (PDT)
In-Reply-To: <20171023185814.4797-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The need to emitting a few nops will become more common soon
as we add stack and map support.  Add a helper.  This allows
for code to be shorter but also may be handy for marking the
nops with a "reason" to ease applying optimizations.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 23fb11a41cc4..eb8c905936ac 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -494,6 +494,12 @@ static swreg re_load_imm_any(struct nfp_prog *nfp_prog, u32 imm, swreg tmp_reg)
 	return tmp_reg;
 }
 
+static void wrp_nops(struct nfp_prog *nfp_prog, unsigned int count)
+{
+	while (count--)
+		emit_nop(nfp_prog);
+}
+
 static void
 wrp_br_special(struct nfp_prog *nfp_prog, enum br_mask mask,
 	       enum br_special special)
@@ -1799,7 +1805,7 @@ static void nfp_outro(struct nfp_prog *nfp_prog)
 static int nfp_translate(struct nfp_prog *nfp_prog)
 {
 	struct nfp_insn_meta *meta;
-	int i, err;
+	int err;
 
 	nfp_intro(nfp_prog);
 	if (nfp_prog->error)
@@ -1831,8 +1837,7 @@ static int nfp_translate(struct nfp_prog *nfp_prog)
 	if (nfp_prog->error)
 		return nfp_prog->error;
 
-	for (i = 0; i < NFP_USTORE_PREFETCH_WINDOW; i++)
-		emit_nop(nfp_prog);
+	wrp_nops(nfp_prog, NFP_USTORE_PREFETCH_WINDOW);
 	if (nfp_prog->error)
 		return nfp_prog->error;
 
-- 
2.14.1
