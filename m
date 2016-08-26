From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFCv2 15/16] nfp: bpf: add support for legacy redirect action
Date: Fri, 26 Aug 2016 19:06:14 +0100
Message-ID: <1472234775-29453-16-git-send-email-jakub.kicinski@netronome.com>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38521 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751569AbcHZSI4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 14:08:56 -0400
Received: by mail-wm0-f46.google.com with SMTP id o80so3286163wme.1
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 11:08:04 -0700 (PDT)
In-Reply-To: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Data path has redirect support so expressing redirect
to the port frame came from is a trivial matter of
setting the right result code.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_bpf.h         | 1 +
 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c     | 2 ++
 drivers/net/ethernet/netronome/nfp/nfp_net_offload.c | 4 ++++
 3 files changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
index 85b258a70b18..ccb8c2fa20d5 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
@@ -60,6 +60,7 @@ enum static_regs {
 
 enum nfp_bpf_action_type {
 	NN_ACT_TC_DROP,
+	NN_ACT_TC_REDIR,
 };
 
 /* Software register representation, hardware encoding in asm.h */
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
index ca73be6fcc3d..e784ed827afe 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
@@ -1440,6 +1440,7 @@ static void nfp_outro_tc_legacy(struct nfp_prog *nfp_prog)
 {
 	const u8 act2code[] = {
 		[NN_ACT_TC_DROP]  = 0x22,
+		[NN_ACT_TC_REDIR] = 0x24
 	};
 	/* Target for aborts */
 	nfp_prog->tgt_abort = nfp_prog_current_offset(nfp_prog);
@@ -1468,6 +1469,7 @@ static void nfp_outro(struct nfp_prog *nfp_prog)
 {
 	switch (nfp_prog->act) {
 	case NN_ACT_TC_DROP:
+	case NN_ACT_TC_REDIR:
 		nfp_outro_tc_legacy(nfp_prog);
 		break;
 	}
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
index 4b8ce01a8dd2..6399801c4196 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
@@ -123,6 +123,10 @@ nfp_net_bpf_get_act(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
 	list_for_each_entry(a, &actions, list) {
 		if (is_tcf_gact_shot(a))
 			return NN_ACT_TC_DROP;
+
+		if (is_tcf_mirred_redirect(a) &&
+		    tcf_mirred_ifindex(a) == nn->netdev->ifindex)
+			return NN_ACT_TC_REDIR;
 	}
 
 	return -ENOTSUPP;
-- 
1.9.1
