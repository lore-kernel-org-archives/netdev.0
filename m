From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv3 net-next 14/15] nfp: bpf: add support for legacy redirect action
Date: Wed, 14 Sep 2016 20:00:22 +0100
Message-ID: <1473879623-15382-15-git-send-email-jakub.kicinski@netronome.com>
References: <1473879623-15382-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37315 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761983AbcINTA4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 15:00:56 -0400
Received: by mail-wm0-f52.google.com with SMTP id k186so25379063wmd.0
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 12:00:55 -0700 (PDT)
In-Reply-To: <1473879623-15382-1-git-send-email-jakub.kicinski@netronome.com>
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
index 97230464317e..b4a35347fd5f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
@@ -71,6 +71,7 @@ enum static_regs {
 
 enum nfp_bpf_action_type {
 	NN_ACT_TC_DROP,
+	NN_ACT_TC_REDIR,
 };
 
 /* Software register representation, hardware encoding in asm.h */
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
index 42a8afb67fc8..60a99e0bf459 100644
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
index 0537a53e2174..1ec8e5b74651 100644
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
