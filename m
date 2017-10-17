From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/20] mlx5e: Convert ndo_setup_tc offloads to block callbacks
Date: Tue, 17 Oct 2017 22:06:05 +0200
Message-ID: <20171017200615.4530-11-jiri@resnulli.us>
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
Received: from mail-wr0-f194.google.com ([209.85.128.194]:47459 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764052AbdJQUG0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:06:26 -0400
Received: by mail-wr0-f194.google.com with SMTP id y39so2906688wrd.4
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:06:25 -0700 (PDT)
In-Reply-To: <20171017200615.4530-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Benefit from the newly introduced block callback infrastructure and
convert ndo_setup_tc calls for flower offloads to block callbacks.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 45 ++++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  | 24 +++++-------
 3 files changed, 51 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index ca8845b..e613ce0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -1056,8 +1056,8 @@ int mlx5e_ethtool_get_ts_info(struct mlx5e_priv *priv,
 int mlx5e_ethtool_flash_device(struct mlx5e_priv *priv,
 			       struct ethtool_flash *flash);
 
-int mlx5e_setup_tc(struct net_device *dev, enum tc_setup_type type,
-		   void *type_data);
+int mlx5e_setup_tc_block_cb(enum tc_setup_type type, void *type_data,
+			    void *cb_priv);
 
 /* mlx5e generic netdev management API */
 struct net_device*
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 3a1969a..e810868 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3083,13 +3083,10 @@ static int mlx5e_setup_tc_mqprio(struct net_device *netdev,
 }
 
 #ifdef CONFIG_MLX5_ESWITCH
-static int mlx5e_setup_tc_cls_flower(struct net_device *dev,
+static int mlx5e_setup_tc_cls_flower(struct mlx5e_priv *priv,
 				     struct tc_cls_flower_offload *cls_flower)
 {
-	struct mlx5e_priv *priv = netdev_priv(dev);
-
-	if (!is_classid_clsact_ingress(cls_flower->common.classid) ||
-	    cls_flower->common.chain_index)
+	if (cls_flower->common.chain_index)
 		return -EOPNOTSUPP;
 
 	switch (cls_flower->command) {
@@ -3103,6 +3100,40 @@ static int mlx5e_setup_tc_cls_flower(struct net_device *dev,
 		return -EOPNOTSUPP;
 	}
 }
+
+int mlx5e_setup_tc_block_cb(enum tc_setup_type type, void *type_data,
+			    void *cb_priv)
+{
+	struct mlx5e_priv *priv = cb_priv;
+
+	switch (type) {
+	case TC_SETUP_CLSFLOWER:
+		return mlx5e_setup_tc_cls_flower(priv, type_data);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int mlx5e_setup_tc_block(struct net_device *dev,
+				struct tc_block_offload *f)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	if (f->binder_type != TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS)
+		return -EOPNOTSUPP;
+
+	switch (f->command) {
+	case TC_BLOCK_BIND:
+		return tcf_block_cb_register(f->block, mlx5e_setup_tc_block_cb,
+					     priv, priv);
+	case TC_BLOCK_UNBIND:
+		tcf_block_cb_unregister(f->block, mlx5e_setup_tc_block_cb,
+					priv);
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
 #endif
 
 int mlx5e_setup_tc(struct net_device *dev, enum tc_setup_type type,
@@ -3111,7 +3142,9 @@ int mlx5e_setup_tc(struct net_device *dev, enum tc_setup_type type,
 	switch (type) {
 #ifdef CONFIG_MLX5_ESWITCH
 	case TC_SETUP_CLSFLOWER:
-		return mlx5e_setup_tc_cls_flower(dev, type_data);
+		return 0; /* will be removed after conversion from ndo */
+	case TC_SETUP_BLOCK:
+		return mlx5e_setup_tc_block(dev, type_data);
 #endif
 	case TC_SETUP_MQPRIO:
 		return mlx5e_setup_tc_mqprio(dev, type_data);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 765fc74..4edd92d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -691,14 +691,6 @@ static int mlx5e_rep_setup_tc(struct net_device *dev, enum tc_setup_type type,
 	}
 }
 
-static int mlx5e_rep_setup_tc_cb(enum tc_setup_type type, void *type_data,
-				 void *cb_priv)
-{
-	struct net_device *dev = cb_priv;
-
-	return mlx5e_setup_tc(dev, type, type_data);
-}
-
 bool mlx5e_is_uplink_rep(struct mlx5e_priv *priv)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
@@ -987,6 +979,7 @@ mlx5e_vport_rep_load(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
 {
 	struct mlx5e_rep_priv *rpriv;
 	struct net_device *netdev;
+	struct mlx5e_priv *upriv;
 	int err;
 
 	rpriv = kzalloc(sizeof(*rpriv), GFP_KERNEL);
@@ -1018,8 +1011,9 @@ mlx5e_vport_rep_load(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
 		goto err_detach_netdev;
 	}
 
-	err = tc_setup_cb_egdev_register(netdev, mlx5e_rep_setup_tc_cb,
-					 mlx5_eswitch_get_uplink_netdev(esw));
+	upriv = netdev_priv(mlx5_eswitch_get_uplink_netdev(esw));
+	err = tc_setup_cb_egdev_register(netdev, mlx5e_setup_tc_block_cb,
+					 upriv);
 	if (err)
 		goto err_neigh_cleanup;
 
@@ -1033,8 +1027,8 @@ mlx5e_vport_rep_load(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
 	return 0;
 
 err_egdev_cleanup:
-	tc_setup_cb_egdev_unregister(netdev, mlx5e_rep_setup_tc_cb,
-				     mlx5_eswitch_get_uplink_netdev(esw));
+	tc_setup_cb_egdev_unregister(netdev, mlx5e_setup_tc_block_cb,
+				     upriv);
 
 err_neigh_cleanup:
 	mlx5e_rep_neigh_cleanup(rpriv);
@@ -1055,10 +1049,12 @@ mlx5e_vport_rep_unload(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5e_rep_priv *rpriv = priv->ppriv;
 	void *ppriv = priv->ppriv;
+	struct mlx5e_priv *upriv;
 
 	unregister_netdev(rep->netdev);
-	tc_setup_cb_egdev_unregister(netdev, mlx5e_rep_setup_tc_cb,
-				     mlx5_eswitch_get_uplink_netdev(esw));
+	upriv = netdev_priv(mlx5_eswitch_get_uplink_netdev(esw));
+	tc_setup_cb_egdev_unregister(netdev, mlx5e_setup_tc_block_cb,
+				     upriv);
 	mlx5e_rep_neigh_cleanup(rpriv);
 	mlx5e_detach_netdev(priv);
 	mlx5e_destroy_netdev(priv);
-- 
2.9.5
