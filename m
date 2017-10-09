From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 13/15] nfp: bpf: pad code with valid nops
Date: Sun,  8 Oct 2017 21:04:15 -0700
Message-ID: <20171009040417.22172-14-jakub.kicinski@netronome.com>
References: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:48796 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751745AbdJIEF5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:05:57 -0400
Received: by mail-pf0-f182.google.com with SMTP id b79so239228pfk.5
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 21:05:57 -0700 (PDT)
In-Reply-To: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to append up to 8 nops after last instruction to make
sure the CPU will not fetch garbage instructions with invalid
ECC if the code store was not initialized.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 12 +++++++++++-
 drivers/net/ethernet/netronome/nfp/nfp_asm.h |  2 ++
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index f4aedc89bfc8..e0600d037773 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -426,6 +426,11 @@ emit_ld_field(struct nfp_prog *nfp_prog, swreg dst, u8 bmask, swreg src,
 	emit_ld_field_any(nfp_prog, sc, shift, dst, bmask, src, false);
 }
 
+static void emit_nop(struct nfp_prog *nfp_prog)
+{
+	__emit_immed(nfp_prog, UR_REG_IMM, UR_REG_IMM, 0, 0, 0, 0, 0, 0, 0);
+}
+
 /* --- Wrappers --- */
 static bool pack_immed(u32 imm, u16 *val, enum immed_shift *shift)
 {
@@ -1550,7 +1555,7 @@ static void nfp_outro(struct nfp_prog *nfp_prog)
 static int nfp_translate(struct nfp_prog *nfp_prog)
 {
 	struct nfp_insn_meta *meta;
-	int err;
+	int i, err;
 
 	nfp_intro(nfp_prog);
 	if (nfp_prog->error)
@@ -1582,6 +1587,11 @@ static int nfp_translate(struct nfp_prog *nfp_prog)
 	if (nfp_prog->error)
 		return nfp_prog->error;
 
+	for (i = 0; i < NFP_USTORE_PREFETCH_WINDOW; i++)
+		emit_nop(nfp_prog);
+	if (nfp_prog->error)
+		return nfp_prog->error;
+
 	return nfp_fixup_branches(nfp_prog);
 }
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_asm.h b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
index d95087e5fb73..c4c18dd5630a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_asm.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
@@ -362,6 +362,8 @@ int swreg_to_unrestricted(swreg dst, swreg lreg, swreg rreg,
 int swreg_to_restricted(swreg dst, swreg lreg, swreg rreg,
 			struct nfp_insn_re_regs *reg, bool has_imm8);
 
+#define NFP_USTORE_PREFETCH_WINDOW	8
+
 int nfp_ustore_check_valid_no_ecc(u64 insn);
 u64 nfp_ustore_calc_ecc_insn(u64 insn);
 
-- 
2.14.1
