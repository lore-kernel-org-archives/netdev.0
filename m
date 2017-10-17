From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/20] nfp: flower: Convert ndo_setup_tc offloads to block callbacks
Date: Tue, 17 Oct 2017 22:06:10 +0200
Message-ID: <20171017200615.4530-16-jiri@resnulli.us>
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
Received: from mail-wm0-f65.google.com ([74.125.82.65]:44918 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764065AbdJQUGa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:06:30 -0400
Received: by mail-wm0-f65.google.com with SMTP id 196so10186835wma.1
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:06:30 -0700 (PDT)
In-Reply-To: <20171017200615.4530-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Benefit from the newly introduced block callback infrastructure and
convert ndo_setup_tc calls for flower offloads to block callbacks.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/netronome/nfp/flower/offload.c    | 56 ++++++++++++++++++----
 1 file changed, 48 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index 6f239c2..f8523df 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -449,6 +449,10 @@ static int
 nfp_flower_repr_offload(struct nfp_app *app, struct net_device *netdev,
 			struct tc_cls_flower_offload *flower)
 {
+	if (!eth_proto_is_802_3(flower->common.protocol) ||
+	    flower->common.chain_index)
+		return -EOPNOTSUPP;
+
 	switch (flower->command) {
 	case TC_CLSFLOWER_REPLACE:
 		return nfp_flower_add_offload(app, netdev, flower);
@@ -461,16 +465,52 @@ nfp_flower_repr_offload(struct nfp_app *app, struct net_device *netdev,
 	return -EOPNOTSUPP;
 }
 
-int nfp_flower_setup_tc(struct nfp_app *app, struct net_device *netdev,
-			enum tc_setup_type type, void *type_data)
+static int nfp_flower_setup_tc_block_cb(enum tc_setup_type type,
+					void *type_data, void *cb_priv)
+{
+	struct nfp_net *nn = cb_priv;
+
+	switch (type) {
+	case TC_SETUP_CLSFLOWER:
+		return nfp_flower_repr_offload(nn->app, nn->port->netdev,
+					       type_data);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int nfp_flower_setup_tc_block(struct net_device *netdev,
+				     struct tc_block_offload *f)
 {
-	struct tc_cls_flower_offload *cls_flower = type_data;
+	struct nfp_net *nn = netdev_priv(netdev);
 
-	if (type != TC_SETUP_CLSFLOWER ||
-	    !is_classid_clsact_ingress(cls_flower->common.classid) ||
-	    !eth_proto_is_802_3(cls_flower->common.protocol) ||
-	    cls_flower->common.chain_index)
+	if (f->binder_type != TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS)
 		return -EOPNOTSUPP;
 
-	return nfp_flower_repr_offload(app, netdev, cls_flower);
+	switch (f->command) {
+	case TC_BLOCK_BIND:
+		return tcf_block_cb_register(f->block,
+					     nfp_flower_setup_tc_block_cb,
+					     nn, nn);
+	case TC_BLOCK_UNBIND:
+		tcf_block_cb_unregister(f->block,
+					nfp_flower_setup_tc_block_cb,
+					nn);
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+int nfp_flower_setup_tc(struct nfp_app *app, struct net_device *netdev,
+			enum tc_setup_type type, void *type_data)
+{
+	switch (type) {
+	case TC_SETUP_CLSFLOWER:
+		return 0; /* will be removed after conversion from ndo */
+	case TC_SETUP_BLOCK:
+		return nfp_flower_setup_tc_block(netdev, type_data);
+	default:
+		return -EOPNOTSUPP;
+	}
 }
-- 
2.9.5
