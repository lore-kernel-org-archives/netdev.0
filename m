From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 16/20] nfp: bpf: Convert ndo_setup_tc offloads to block callbacks
Date: Tue, 17 Oct 2017 22:06:11 +0200
Message-ID: <20171017200615.4530-17-jiri@resnulli.us>
References: <20171017200615.4530-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:45088 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764066AbdJQUGb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:06:31 -0400
Received: by mail-wr0-f194.google.com with SMTP id k7so2905929wre.2
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:06:30 -0700 (PDT)
In-Reply-To: <20171017200615.4530-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Benefit from the newly introduced block callback infrastructure and
convert ndo_setup_tc calls for bpf offloads to block callbacks.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/main.c | 54 ++++++++++++++++++++++-----
 1 file changed, 45 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index 6e74f8d..64f97b3 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -114,22 +114,58 @@ static void nfp_bpf_vnic_free(struct nfp_app *app, struct nfp_net *nn)
 	kfree(nn->app_priv);
 }
 
-static int nfp_bpf_setup_tc(struct nfp_app *app, struct net_device *netdev,
-			    enum tc_setup_type type, void *type_data)
+static int nfp_bpf_setup_tc_block_cb(enum tc_setup_type type,
+				     void *type_data, void *cb_priv)
 {
 	struct tc_cls_bpf_offload *cls_bpf = type_data;
+	struct nfp_net *nn = cb_priv;
+
+	switch (type) {
+	case TC_SETUP_CLSBPF:
+		if (!nfp_net_ebpf_capable(nn) ||
+		    cls_bpf->common.protocol != htons(ETH_P_ALL) ||
+		    cls_bpf->common.chain_index)
+			return -EOPNOTSUPP;
+		return nfp_net_bpf_offload(nn, cls_bpf);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int nfp_bpf_setup_tc_block(struct net_device *netdev,
+				  struct tc_block_offload *f)
+{
 	struct nfp_net *nn = netdev_priv(netdev);
 
-	if (type != TC_SETUP_CLSBPF || !nfp_net_ebpf_capable(nn) ||
-	    !is_classid_clsact_ingress(cls_bpf->common.classid) ||
-	    cls_bpf->common.protocol != htons(ETH_P_ALL) ||
-	    cls_bpf->common.chain_index)
+	if (f->binder_type != TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS)
 		return -EOPNOTSUPP;
 
-	if (nn->dp.bpf_offload_xdp)
-		return -EBUSY;
+	switch (f->command) {
+	case TC_BLOCK_BIND:
+		return tcf_block_cb_register(f->block,
+					     nfp_bpf_setup_tc_block_cb,
+					     nn, nn);
+	case TC_BLOCK_UNBIND:
+		tcf_block_cb_unregister(f->block,
+					nfp_bpf_setup_tc_block_cb,
+					nn);
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
 
-	return nfp_net_bpf_offload(nn, cls_bpf);
+static int nfp_bpf_setup_tc(struct nfp_app *app, struct net_device *netdev,
+			    enum tc_setup_type type, void *type_data)
+{
+	switch (type) {
+	case TC_SETUP_CLSBPF:
+		return 0; /* will be removed after conversion from ndo */
+	case TC_SETUP_BLOCK:
+		return nfp_bpf_setup_tc_block(netdev, type_data);
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static bool nfp_bpf_tc_busy(struct nfp_app *app, struct nfp_net *nn)
-- 
2.9.5
