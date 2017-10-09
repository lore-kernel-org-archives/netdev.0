From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 12/15] nfp: bpf: calculate code store ECC
Date: Sun,  8 Oct 2017 21:04:14 -0700
Message-ID: <20171009040417.22172-13-jakub.kicinski@netronome.com>
References: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:53943 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751686AbdJIEF5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:05:57 -0400
Received: by mail-pf0-f178.google.com with SMTP id n73so5855498pfg.10
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 21:05:57 -0700 (PDT)
In-Reply-To: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the initial PoC firmware I simply disabled ECC on the instruction
store.  Do the ECC calculation for generated instructions in the driver.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 20 +++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_asm.c | 37 ++++++++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_asm.h |  3 +++
 3 files changed, 60 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 9b6c98ccebfe..f4aedc89bfc8 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -1715,6 +1715,23 @@ static int nfp_bpf_optimize(struct nfp_prog *nfp_prog)
 	return 0;
 }
 
+static int nfp_bpf_ustore_calc(struct nfp_prog *nfp_prog)
+{
+	int i;
+
+	for (i = 0; i < nfp_prog->prog_len; i++) {
+		int err;
+
+		err = nfp_ustore_check_valid_no_ecc(nfp_prog->prog[i]);
+		if (err)
+			return err;
+
+		nfp_prog->prog[i] = nfp_ustore_calc_ecc_insn(nfp_prog->prog[i]);
+	}
+
+	return 0;
+}
+
 /**
  * nfp_bpf_jit() - translate BPF code into NFP assembly
  * @filter:	kernel BPF filter struct
@@ -1766,8 +1783,11 @@ nfp_bpf_jit(struct bpf_prog *filter, void *prog_mem,
 		pr_err("Translation failed with error %d (translated: %u)\n",
 		       ret, nfp_prog->n_translated);
 		ret = -EINVAL;
+		goto out;
 	}
 
+	ret = nfp_bpf_ustore_calc(nfp_prog);
+
 	res->n_instr = nfp_prog->prog_len;
 	res->dense_mode = false;
 out:
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_asm.c b/drivers/net/ethernet/netronome/nfp/nfp_asm.c
index 1decc638ea6f..de76e7444fc2 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_asm.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_asm.c
@@ -215,3 +215,40 @@ int swreg_to_restricted(swreg dst, swreg lreg, swreg rreg,
 
 	return 0;
 }
+
+#define NFP_USTORE_ECC_POLY_WORDS		7
+#define NFP_USTORE_OP_BITS			45
+
+static const u64 nfp_ustore_ecc_polynomials[NFP_USTORE_ECC_POLY_WORDS] = {
+	0x0ff800007fffULL,
+	0x11f801ff801fULL,
+	0x1e387e0781e1ULL,
+	0x17cb8e388e22ULL,
+	0x1af5b2c93244ULL,
+	0x1f56d5525488ULL,
+	0x0daf69a46910ULL,
+};
+
+static bool parity(u64 value)
+{
+	return hweight64(value) & 1;
+}
+
+int nfp_ustore_check_valid_no_ecc(u64 insn)
+{
+	if (insn & ~GENMASK_ULL(NFP_USTORE_OP_BITS, 0))
+		return -EINVAL;
+
+	return 0;
+}
+
+u64 nfp_ustore_calc_ecc_insn(u64 insn)
+{
+	u8 ecc = 0;
+	int i;
+
+	for (i = 0; i < NFP_USTORE_ECC_POLY_WORDS; i++)
+		ecc |= parity(nfp_ustore_ecc_polynomials[i] & insn) << i;
+
+	return insn | (u64)ecc << NFP_USTORE_OP_BITS;
+}
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_asm.h b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
index 40a51a45afd7..d95087e5fb73 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_asm.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
@@ -362,4 +362,7 @@ int swreg_to_unrestricted(swreg dst, swreg lreg, swreg rreg,
 int swreg_to_restricted(swreg dst, swreg lreg, swreg rreg,
 			struct nfp_insn_re_regs *reg, bool has_imm8);
 
+int nfp_ustore_check_valid_no_ecc(u64 insn);
+u64 nfp_ustore_calc_ecc_insn(u64 insn);
+
 #endif
-- 
2.14.1
