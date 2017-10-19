From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 09/20] mlxsw: spectrum: Convert ndo_setup_tc offloads to block callbacks
Date: Thu, 19 Oct 2017 15:50:37 +0200
Message-ID: <20171019135048.4306-10-jiri@resnulli.us>
References: <20171019135048.4306-1-jiri@resnulli.us>
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
Received: from mail-wr0-f194.google.com ([209.85.128.194]:49475 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753776AbdJSNu6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 09:50:58 -0400
Received: by mail-wr0-f194.google.com with SMTP id g90so8407647wrd.6
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 06:50:58 -0700 (PDT)
In-Reply-To: <20171019135048.4306-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Benefit from the newly introduced block callback infrastructure and
convert ndo_setup_tc calls for matchall and flower offloads to block
callbacks.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 82 +++++++++++++++++++-------
 1 file changed, 60 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index e1e11c7..08e321a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1697,17 +1697,9 @@ static void mlxsw_sp_port_del_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 }
 
 static int mlxsw_sp_setup_tc_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
-					  struct tc_cls_matchall_offload *f)
+					  struct tc_cls_matchall_offload *f,
+					  bool ingress)
 {
-	bool ingress;
-
-	if (is_classid_clsact_ingress(f->common.classid))
-		ingress = true;
-	else if (is_classid_clsact_egress(f->common.classid))
-		ingress = false;
-	else
-		return -EOPNOTSUPP;
-
 	if (f->common.chain_index)
 		return -EOPNOTSUPP;
 
@@ -1725,17 +1717,9 @@ static int mlxsw_sp_setup_tc_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 
 static int
 mlxsw_sp_setup_tc_cls_flower(struct mlxsw_sp_port *mlxsw_sp_port,
-			     struct tc_cls_flower_offload *f)
+			     struct tc_cls_flower_offload *f,
+			     bool ingress)
 {
-	bool ingress;
-
-	if (is_classid_clsact_ingress(f->common.classid))
-		ingress = true;
-	else if (is_classid_clsact_egress(f->common.classid))
-		ingress = false;
-	else
-		return -EOPNOTSUPP;
-
 	switch (f->command) {
 	case TC_CLSFLOWER_REPLACE:
 		return mlxsw_sp_flower_replace(mlxsw_sp_port, ingress, f);
@@ -1749,6 +1733,59 @@ mlxsw_sp_setup_tc_cls_flower(struct mlxsw_sp_port *mlxsw_sp_port,
 	}
 }
 
+static int mlxsw_sp_setup_tc_block_cb(enum tc_setup_type type, void *type_data,
+				      void *cb_priv, bool ingress)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = cb_priv;
+
+	switch (type) {
+	case TC_SETUP_CLSMATCHALL:
+		return mlxsw_sp_setup_tc_cls_matchall(mlxsw_sp_port, type_data,
+						      ingress);
+	case TC_SETUP_CLSFLOWER:
+		return mlxsw_sp_setup_tc_cls_flower(mlxsw_sp_port, type_data,
+						    ingress);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int mlxsw_sp_setup_tc_block_cb_ig(enum tc_setup_type type,
+					 void *type_data, void *cb_priv)
+{
+	return mlxsw_sp_setup_tc_block_cb(type, type_data, cb_priv, true);
+}
+
+static int mlxsw_sp_setup_tc_block_cb_eg(enum tc_setup_type type,
+					 void *type_data, void *cb_priv)
+{
+	return mlxsw_sp_setup_tc_block_cb(type, type_data, cb_priv, false);
+}
+
+static int mlxsw_sp_setup_tc_block(struct mlxsw_sp_port *mlxsw_sp_port,
+				   struct tc_block_offload *f)
+{
+	tc_setup_cb_t *cb;
+
+	if (f->binder_type == TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS)
+		cb = mlxsw_sp_setup_tc_block_cb_ig;
+	else if (f->binder_type == TCF_BLOCK_BINDER_TYPE_CLSACT_EGRESS)
+		cb = mlxsw_sp_setup_tc_block_cb_eg;
+	else
+		return -EOPNOTSUPP;
+
+	switch (f->command) {
+	case TC_BLOCK_BIND:
+		return tcf_block_cb_register(f->block, cb, mlxsw_sp_port,
+					     mlxsw_sp_port);
+	case TC_BLOCK_UNBIND:
+		tcf_block_cb_unregister(f->block, cb, mlxsw_sp_port);
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 static int mlxsw_sp_setup_tc(struct net_device *dev, enum tc_setup_type type,
 			     void *type_data)
 {
@@ -1756,9 +1793,10 @@ static int mlxsw_sp_setup_tc(struct net_device *dev, enum tc_setup_type type,
 
 	switch (type) {
 	case TC_SETUP_CLSMATCHALL:
-		return mlxsw_sp_setup_tc_cls_matchall(mlxsw_sp_port, type_data);
 	case TC_SETUP_CLSFLOWER:
-		return mlxsw_sp_setup_tc_cls_flower(mlxsw_sp_port, type_data);
+		return 0; /* will be removed after conversion from ndo */
+	case TC_SETUP_BLOCK:
+		return mlxsw_sp_setup_tc_block(mlxsw_sp_port, type_data);
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
2.9.5
