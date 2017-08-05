From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/15] mlx5e_rep: push cls_flower setup_tc processing into a separate function
Date: Sat,  5 Aug 2017 16:53:29 +0200
Message-ID: <20170805145337.17728-8-jiri@resnulli.us>
References: <20170805145337.17728-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36800 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751779AbdHEOxw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 10:53:52 -0400
Received: by mail-wr0-f194.google.com with SMTP id y67so4765150wrb.3
        for <netdev@vger.kernel.org>; Sat, 05 Aug 2017 07:53:51 -0700 (PDT)
In-Reply-To: <20170805145337.17728-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Let mlx5e_rep_setup_tc (former mlx5e_rep_ndo_setup_tc) be a splitter for
specific setup_tc types and push out cls_flower specific code into
a separate function.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c | 49 ++++++++++++++----------
 1 file changed, 29 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 0e6bab1..e6cc642 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -651,38 +651,47 @@ static int mlx5e_rep_get_phys_port_name(struct net_device *dev,
 	return 0;
 }
 
-static int mlx5e_rep_ndo_setup_tc(struct net_device *dev,
-				  enum tc_setup_type type, u32 handle,
-				  u32 chain_index, __be16 proto,
-				  struct tc_to_netdev *tc)
+static int mlx5e_rep_setup_tc_cls_flower(struct net_device *dev,
+					 u32 handle, u32 chain_index,
+					 __be16 proto,
+					 struct tc_to_netdev *tc)
 {
+	struct tc_cls_flower_offload *cls_flower = tc->cls_flower;
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
-	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
+	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS) ||
+	    chain_index)
 		return -EOPNOTSUPP;
 
-	if (type == TC_SETUP_CLSFLOWER && tc->cls_flower->egress_dev) {
+	if (cls_flower->egress_dev) {
 		struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
-		struct net_device *uplink_dev = mlx5_eswitch_get_uplink_netdev(esw);
 
-		return uplink_dev->netdev_ops->ndo_setup_tc(uplink_dev, type,
-							    handle, chain_index,
-							    proto, tc);
+		dev = mlx5_eswitch_get_uplink_netdev(esw);
+		return dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
+						     handle, chain_index,
+						     proto, tc);
 	}
 
-	if (chain_index)
+	switch (cls_flower->command) {
+	case TC_CLSFLOWER_REPLACE:
+		return mlx5e_configure_flower(priv, proto, cls_flower);
+	case TC_CLSFLOWER_DESTROY:
+		return mlx5e_delete_flower(priv, cls_flower);
+	case TC_CLSFLOWER_STATS:
+		return mlx5e_stats_flower(priv, cls_flower);
+	default:
 		return -EOPNOTSUPP;
+	}
+}
 
+static int mlx5e_rep_setup_tc(struct net_device *dev, enum tc_setup_type type,
+			      u32 handle, u32 chain_index, __be16 proto,
+			      struct tc_to_netdev *tc)
+{
 	switch (type) {
 	case TC_SETUP_CLSFLOWER:
-		switch (tc->cls_flower->command) {
-		case TC_CLSFLOWER_REPLACE:
-			return mlx5e_configure_flower(priv, proto, tc->cls_flower);
-		case TC_CLSFLOWER_DESTROY:
-			return mlx5e_delete_flower(priv, tc->cls_flower);
-		case TC_CLSFLOWER_STATS:
-			return mlx5e_stats_flower(priv, tc->cls_flower);
-		}
+		return mlx5e_rep_setup_tc_cls_flower(dev, handle, chain_index,
+						     proto, tc);
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -774,7 +783,7 @@ static const struct net_device_ops mlx5e_netdev_ops_rep = {
 	.ndo_stop                = mlx5e_rep_close,
 	.ndo_start_xmit          = mlx5e_xmit,
 	.ndo_get_phys_port_name  = mlx5e_rep_get_phys_port_name,
-	.ndo_setup_tc            = mlx5e_rep_ndo_setup_tc,
+	.ndo_setup_tc            = mlx5e_rep_setup_tc,
 	.ndo_get_stats64         = mlx5e_rep_get_stats,
 	.ndo_has_offload_stats	 = mlx5e_has_offload_stats,
 	.ndo_get_offload_stats	 = mlx5e_get_offload_stats,
-- 
2.9.3
