From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 06/16] mlx5e: push cls_flower and mqprio setup_tc processing into separate functions
Date: Mon,  7 Aug 2017 10:15:22 +0200
Message-ID: <20170807081532.32760-7-jiri@resnulli.us>
References: <20170807081532.32760-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com,
        yisen.zhuang@huawei.com, salil.mehta@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36746 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752495AbdHGIPo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 04:15:44 -0400
Received: by mail-wm0-f66.google.com with SMTP id d40so135222wma.3
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 01:15:44 -0700 (PDT)
In-Reply-To: <20170807081532.32760-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Let mlx5e_setup_tc (former mlx5e_ndo_setup_tc) be a splitter for specific
setup_tc types and push out cls_flower and mqprio specific codes into
separate functions. Also change the return values so they are the same
as in the rest of the drivers.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 56 +++++++++++++----------
 1 file changed, 31 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 4052e225f..adf35da 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2998,12 +2998,16 @@ static int mlx5e_modify_channels_vsd(struct mlx5e_channels *chs, bool vsd)
 	return 0;
 }
 
-static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
+static int mlx5e_setup_tc_mqprio(struct net_device *netdev,
+				 struct tc_mqprio_qopt *mqprio)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5e_channels new_channels = {};
+	u8 tc = mqprio->num_tc;
 	int err = 0;
 
+	mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+
 	if (tc && tc != MLX5E_MAX_NUM_TC)
 		return -EINVAL;
 
@@ -3027,39 +3031,41 @@ static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
 	return err;
 }
 
-static int mlx5e_ndo_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			      u32 handle, u32 chain_index, __be16 proto,
-			      struct tc_to_netdev *tc)
+static int mlx5e_setup_tc_cls_flower(struct net_device *dev,
+				     u32 handle, u32 chain_index, __be16 proto,
+				     struct tc_cls_flower_offload *cls_flower)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
-	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
-		goto mqprio;
+	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS) ||
+	    chain_index)
+		return -EOPNOTSUPP;
 
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
 
+static int mlx5e_setup_tc(struct net_device *dev, enum tc_setup_type type,
+			  u32 handle, u32 chain_index, __be16 proto,
+			  struct tc_to_netdev *tc)
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
+		return mlx5e_setup_tc_cls_flower(dev, handle, chain_index,
+						 proto, tc->cls_flower);
+	case TC_SETUP_MQPRIO:
+		return mlx5e_setup_tc_mqprio(dev, tc->mqprio);
 	default:
 		return -EOPNOTSUPP;
 	}
-
-mqprio:
-	if (type != TC_SETUP_MQPRIO)
-		return -EINVAL;
-
-	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
-
-	return mlx5e_setup_tc(dev, tc->mqprio->num_tc);
 }
 
 static void
@@ -3695,7 +3701,7 @@ static const struct net_device_ops mlx5e_netdev_ops_basic = {
 	.ndo_open                = mlx5e_open,
 	.ndo_stop                = mlx5e_close,
 	.ndo_start_xmit          = mlx5e_xmit,
-	.ndo_setup_tc            = mlx5e_ndo_setup_tc,
+	.ndo_setup_tc            = mlx5e_setup_tc,
 	.ndo_select_queue        = mlx5e_select_queue,
 	.ndo_get_stats64         = mlx5e_get_stats,
 	.ndo_set_rx_mode         = mlx5e_set_rx_mode,
@@ -3720,7 +3726,7 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_open                = mlx5e_open,
 	.ndo_stop                = mlx5e_close,
 	.ndo_start_xmit          = mlx5e_xmit,
-	.ndo_setup_tc            = mlx5e_ndo_setup_tc,
+	.ndo_setup_tc            = mlx5e_setup_tc,
 	.ndo_select_queue        = mlx5e_select_queue,
 	.ndo_get_stats64         = mlx5e_get_stats,
 	.ndo_set_rx_mode         = mlx5e_set_rx_mode,
-- 
2.9.3
