From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 11/12] nfp: bpf: add register rename
Date: Wed,  1 Jun 2016 17:50:13 +0100
Message-ID: <1464799814-4453-12-git-send-email-jakub.kicinski@netronome.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38244 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932670AbcFAQwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 12:52:00 -0400
Received: by mail-wm0-f42.google.com with SMTP id a20so35122984wma.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 09:51:59 -0700 (PDT)
In-Reply-To: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we use resources more wisely we may be able to use
programmable engines in a denser fashion.  Try to squeeze
used registers together.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c | 51 +++++++++++++++++++++++-
 1 file changed, 49 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
index a83e7404598f..b4dd04f4c653 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
@@ -847,6 +847,42 @@ static void nfp_bpf_opt_reg_init(struct nfp_prog *nfp_prog)
 	}
 }
 
+/* Try to rename registers so that program uses only low ones */
+static int nfp_bpf_opt_reg_rename(struct nfp_prog *nfp_prog)
+{
+	bool reg_used[__MAX_BPF_REG] = {};
+	u8 tgt_reg[__MAX_BPF_REG] = {};
+	struct nfp_insn_meta *meta;
+	unsigned int i, j;
+
+	list_for_each_entry(meta, &nfp_prog->insns, l) {
+		if (meta->skip)
+			continue;
+
+		reg_used[meta->insn.src_reg] = true;
+		reg_used[meta->insn.dst_reg] = true;
+	}
+
+	if (reg_used[BPF_REG_10]) {
+		pr_err("Detected use of stack ptr\n");
+		return -EINVAL;
+	}
+
+	for (i = 0, j = 0; i < ARRAY_SIZE(tgt_reg); i++) {
+		if (!reg_used[i])
+			continue;
+
+		tgt_reg[i] = j++;
+	}
+
+	list_for_each_entry(meta, &nfp_prog->insns, l) {
+		meta->insn.src_reg = tgt_reg[meta->insn.src_reg];
+		meta->insn.dst_reg = tgt_reg[meta->insn.dst_reg];
+	}
+
+	return 0;
+}
+
 /* Remove masking after load since our load guarantees this is not needed */
 static void nfp_bpf_opt_ld_mask(struct nfp_prog *nfp_prog)
 {
@@ -921,11 +957,20 @@ static void nfp_bpf_opt_ld_shift(struct nfp_prog *nfp_prog)
 	}
 }
 
-static void nfp_bpf_optimize(struct nfp_prog *nfp_prog)
+static int nfp_bpf_optimize(struct nfp_prog *nfp_prog)
 {
+	int ret;
+
 	nfp_bpf_opt_reg_init(nfp_prog);
+
+	ret = nfp_bpf_opt_reg_rename(nfp_prog);
+	if (ret)
+		return ret;
+
 	nfp_bpf_opt_ld_mask(nfp_prog);
 	nfp_bpf_opt_ld_shift(nfp_prog);
+
+	return 0;
 }
 
 /**
@@ -961,7 +1006,9 @@ nfp_bpf_jit(struct bpf_prog *filter, void *prog_mem, unsigned int prog_start,
 	if (ret)
 		goto out;
 
-	nfp_bpf_optimize(nfp_prog);
+	ret = nfp_bpf_optimize(nfp_prog);
+	if (ret)
+		goto out;
 
 	nfp_prog->prog = prog_mem;
 	nfp_prog->__prog_alloc_len = prog_sz;
-- 
1.9.1
