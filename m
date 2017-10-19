From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 14/20] mlx5e_rep: Convert ndo_setup_tc offloads to block callbacks
Date: Thu, 19 Oct 2017 15:50:42 +0200
Message-ID: <20171019135048.4306-15-jiri@resnulli.us>
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
Received: from mail-wm0-f67.google.com ([74.125.82.67]:53276 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753806AbdJSNvC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 09:51:02 -0400
Received: by mail-wm0-f67.google.com with SMTP id q132so16556756wmd.2
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 06:51:02 -0700 (PDT)
In-Reply-To: <20171019135048.4306-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Benefit from the newly introduced block callback infrastructure and
convert ndo_setup_tc calls for flower offloads to block callbacks.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c | 44 ++++++++++++++++++++----
 1 file changed, 38 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 4edd92d..f59d81a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -659,13 +659,10 @@ static int mlx5e_rep_get_phys_port_name(struct net_device *dev,
 }
 
 static int
-mlx5e_rep_setup_tc_cls_flower(struct net_device *dev,
+mlx5e_rep_setup_tc_cls_flower(struct mlx5e_priv *priv,
 			      struct tc_cls_flower_offload *cls_flower)
 {
-	struct mlx5e_priv *priv = netdev_priv(dev);
-
-	if (!is_classid_clsact_ingress(cls_flower->common.classid) ||
-	    cls_flower->common.chain_index)
+	if (cls_flower->common.chain_index)
 		return -EOPNOTSUPP;
 
 	switch (cls_flower->command) {
@@ -680,12 +677,47 @@ mlx5e_rep_setup_tc_cls_flower(struct net_device *dev,
 	}
 }
 
+static int mlx5e_rep_setup_tc_cb(enum tc_setup_type type, void *type_data,
+				 void *cb_priv)
+{
+	struct mlx5e_priv *priv = cb_priv;
+
+	switch (type) {
+	case TC_SETUP_CLSFLOWER:
+		return mlx5e_rep_setup_tc_cls_flower(priv, type_data);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int mlx5e_rep_setup_tc_block(struct net_device *dev,
+				    struct tc_block_offload *f)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	if (f->binder_type != TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS)
+		return -EOPNOTSUPP;
+
+	switch (f->command) {
+	case TC_BLOCK_BIND:
+		return tcf_block_cb_register(f->block, mlx5e_rep_setup_tc_cb,
+					     priv, priv);
+	case TC_BLOCK_UNBIND:
+		tcf_block_cb_unregister(f->block, mlx5e_rep_setup_tc_cb, priv);
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 static int mlx5e_rep_setup_tc(struct net_device *dev, enum tc_setup_type type,
 			      void *type_data)
 {
 	switch (type) {
 	case TC_SETUP_CLSFLOWER:
-		return mlx5e_rep_setup_tc_cls_flower(dev, type_data);
+		return 0; /* will be removed after conversion from ndo */
+	case TC_SETUP_BLOCK:
+		return mlx5e_rep_setup_tc_block(dev, type_data);
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
2.9.5
