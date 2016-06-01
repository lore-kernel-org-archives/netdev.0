From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 10/12] nfp: bpf: optimize register init
Date: Wed,  1 Jun 2016 17:50:12 +0100
Message-ID: <1464799814-4453-11-git-send-email-jakub.kicinski@netronome.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36856 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932667AbcFAQv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 12:51:59 -0400
Received: by mail-wm0-f54.google.com with SMTP id n184so41577118wmn.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 09:51:58 -0700 (PDT)
In-Reply-To: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can skip move of skb pointer to R6 since this pointer
has no meaning on the card.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
index b31e673a6fe8..a83e7404598f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
@@ -824,6 +824,29 @@ nfp_prog_prepare(struct nfp_prog *nfp_prog, const struct bpf_insn *prog,
 }
 
 /* --- Optimizations --- */
+static void nfp_bpf_opt_reg_init(struct nfp_prog *nfp_prog)
+{
+	struct nfp_insn_meta *meta;
+
+	list_for_each_entry(meta, &nfp_prog->insns, l) {
+		struct bpf_insn insn = meta->insn;
+
+		/* Programs converted from cBPF start with register xoring */
+		if (insn.code == (BPF_ALU64 | BPF_XOR | BPF_X) &&
+		    insn.src_reg == insn.dst_reg)
+			continue;
+
+		/* Programs start with R6 = R1 but we ignore the skb pointer */
+		if (insn.code == (BPF_ALU64 | BPF_MOV | BPF_X) &&
+		    insn.src_reg == 1 && insn.dst_reg == 6)
+			meta->skip = true;
+
+		/* Return as soon as something doesn't match */
+		if (!meta->skip)
+			return;
+	}
+}
+
 /* Remove masking after load since our load guarantees this is not needed */
 static void nfp_bpf_opt_ld_mask(struct nfp_prog *nfp_prog)
 {
@@ -900,6 +923,7 @@ static void nfp_bpf_opt_ld_shift(struct nfp_prog *nfp_prog)
 
 static void nfp_bpf_optimize(struct nfp_prog *nfp_prog)
 {
+	nfp_bpf_opt_reg_init(nfp_prog);
 	nfp_bpf_opt_ld_mask(nfp_prog);
 	nfp_bpf_opt_ld_shift(nfp_prog);
 }
-- 
1.9.1
