From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/15] net: sched: get rid of struct tc_to_netdev
Date: Sat,  5 Aug 2017 16:53:37 +0200
Message-ID: <20170805145337.17728-16-jiri@resnulli.us>
References: <20170805145337.17728-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36828 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752515AbdHEOyF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 10:54:05 -0400
Received: by mail-wr0-f195.google.com with SMTP id y67so4765388wrb.3
        for <netdev@vger.kernel.org>; Sat, 05 Aug 2017 07:54:04 -0700 (PDT)
In-Reply-To: <20170805145337.17728-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Get rid of struct tc_to_netdev which is now just unnecessary container
and rather pass per-type structures down to drivers directly.
Along with that, consolidate the naming of per-type structure variables
in cls_*.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           |  7 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |  8 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |  2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c          |  8 ++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  4 +-
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c     |  7 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c    |  8 ++-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  8 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  6 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     | 10 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  6 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   | 12 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h    |  2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  8 +--
 drivers/net/ethernet/netronome/nfp/bpf/main.c      |  5 +-
 drivers/net/ethernet/netronome/nfp/flower/main.h   |  4 +-
 .../net/ethernet/netronome/nfp/flower/offload.c    |  4 +-
 drivers/net/ethernet/netronome/nfp/nfp_app.h       |  8 +--
 drivers/net/ethernet/netronome/nfp/nfp_port.c      |  4 +-
 drivers/net/ethernet/netronome/nfp/nfp_port.h      |  3 +-
 drivers/net/ethernet/sfc/efx.h                     |  2 +-
 drivers/net/ethernet/sfc/falcon/efx.h              |  2 +-
 drivers/net/ethernet/sfc/falcon/tx.c               |  7 +-
 drivers/net/ethernet/sfc/tx.c                      |  7 +-
 drivers/net/ethernet/ti/netcp_core.c               |  7 +-
 include/linux/netdevice.h                          | 19 +----
 net/dsa/slave.c                                    |  4 +-
 net/sched/cls_bpf.c                                | 21 +++---
 net/sched/cls_flower.c                             | 54 ++++++--------
 net/sched/cls_matchall.c                           | 27 +++----
 net/sched/cls_u32.c                                | 83 ++++++++++------------
 net/sched/sch_mqprio.c                             | 13 ++--
 32 files changed, 170 insertions(+), 200 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 37d3e5b..2fd9b80 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1919,16 +1919,17 @@ static void xgbe_poll_controller(struct net_device *netdev)
 #endif /* End CONFIG_NET_POLL_CONTROLLER */
 
 static int xgbe_setup_tc(struct net_device *netdev, enum tc_setup_type type,
-			 struct tc_to_netdev *tc_to_netdev)
+			 void *type_data)
 {
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct tc_mqprio_qopt *mqprio = type_data;
 	u8 tc;
 
 	if (type != TC_SETUP_MQPRIO)
 		return -EOPNOTSUPP;
 
-	tc_to_netdev->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
-	tc = tc_to_netdev->mqprio->num_tc;
+	mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+	tc = mqprio->num_tc;
 
 	if (tc > pdata->hw_feat.tc_cnt)
 		return -EINVAL;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 8687afc..1216c1f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -4285,14 +4285,16 @@ int bnx2x_setup_tc(struct net_device *dev, u8 num_tc)
 }
 
 int __bnx2x_setup_tc(struct net_device *dev, enum tc_setup_type type,
-		     struct tc_to_netdev *tc)
+		     void *type_data)
 {
+	struct tc_mqprio_qopt *mqprio = type_data;
+
 	if (type != TC_SETUP_MQPRIO)
 		return -EOPNOTSUPP;
 
-	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+	mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
 
-	return bnx2x_setup_tc(dev, tc->mqprio->num_tc);
+	return bnx2x_setup_tc(dev, mqprio->num_tc);
 }
 
 /* called with rtnl_lock */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 04eb950..a5265e1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -487,7 +487,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev);
 /* setup_tc callback */
 int bnx2x_setup_tc(struct net_device *dev, u8 num_tc);
 int __bnx2x_setup_tc(struct net_device *dev, enum tc_setup_type type,
-		     struct tc_to_netdev *tc);
+		     void *type_data);
 
 int bnx2x_get_vf_config(struct net_device *dev, int vf,
 			struct ifla_vf_info *ivi);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index a78f72a..6e14fc4 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7238,14 +7238,16 @@ int bnxt_setup_mq_tc(struct net_device *dev, u8 tc)
 }
 
 static int bnxt_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			 struct tc_to_netdev *ntc)
+			 void *type_data)
 {
+	struct tc_mqprio_qopt *mqprio = type_data;
+
 	if (type != TC_SETUP_MQPRIO)
 		return -EOPNOTSUPP;
 
-	ntc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+	mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
 
-	return bnxt_setup_mq_tc(dev, ntc->mqprio->num_tc);
+	return bnxt_setup_mq_tc(dev, mqprio->num_tc);
 }
 
 #ifdef CONFIG_RFS_ACCEL
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 1319931..d80b20d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2908,7 +2908,7 @@ static int cxgb_setup_tc_cls_u32(struct net_device *dev,
 }
 
 static int cxgb_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			 struct tc_to_netdev *tc)
+			 void *type_data)
 {
 	struct port_info *pi = netdev2pinfo(dev);
 	struct adapter *adap = netdev2adap(dev);
@@ -2922,7 +2922,7 @@ static int cxgb_setup_tc(struct net_device *dev, enum tc_setup_type type,
 
 	switch (type) {
 	case TC_SETUP_CLSU32:
-		return cxgb_setup_tc_cls_u32(dev, tc->cls_u32);
+		return cxgb_setup_tc_cls_u32(dev, type_data);
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index bfb44c9..733d54c 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -343,17 +343,18 @@ static void dpaa_get_stats64(struct net_device *net_dev,
 }
 
 static int dpaa_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
-			 struct tc_to_netdev *tc)
+			 void *type_data)
 {
 	struct dpaa_priv *priv = netdev_priv(net_dev);
+	struct tc_mqprio_qopt *mqprio = type_data;
 	u8 num_tc;
 	int i;
 
 	if (type != TC_SETUP_MQPRIO)
 		return -EOPNOTSUPP;
 
-	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
-	num_tc = tc->mqprio->num_tc;
+	mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+	num_tc = mqprio->num_tc;
 
 	if (num_tc == priv->num_tc)
 		return 0;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 7088812..e69d49d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1266,14 +1266,16 @@ int fm10k_setup_tc(struct net_device *dev, u8 tc)
 }
 
 static int __fm10k_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			    struct tc_to_netdev *tc)
+			    void *type_data)
 {
+	struct tc_mqprio_qopt *mqprio = type_data;
+
 	if (type != TC_SETUP_MQPRIO)
 		return -EOPNOTSUPP;
 
-	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+	mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
 
-	return fm10k_setup_tc(dev, tc->mqprio->num_tc);
+	return fm10k_setup_tc(dev, mqprio->num_tc);
 }
 
 static void fm10k_assign_l2_accel(struct fm10k_intfc *interface,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1f46338..a7e5a76 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5657,14 +5657,16 @@ static int i40e_setup_tc(struct net_device *netdev, u8 tc)
 }
 
 static int __i40e_setup_tc(struct net_device *netdev, enum tc_setup_type type,
-			   struct tc_to_netdev *tc)
+			   void *type_data)
 {
+	struct tc_mqprio_qopt *mqprio = type_data;
+
 	if (type != TC_SETUP_MQPRIO)
 		return -EOPNOTSUPP;
 
-	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+	mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
 
-	return i40e_setup_tc(netdev, tc->mqprio->num_tc);
+	return i40e_setup_tc(netdev, mqprio->num_tc);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0a35031..c6b1324 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9258,13 +9258,13 @@ static int ixgbe_setup_tc_mqprio(struct net_device *dev,
 }
 
 static int __ixgbe_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			    struct tc_to_netdev *tc)
+			    void *type_data)
 {
 	switch (type) {
 	case TC_SETUP_CLSU32:
-		return ixgbe_setup_tc_cls_u32(dev, tc->cls_u32);
+		return ixgbe_setup_tc_cls_u32(dev, type_data);
 	case TC_SETUP_MQPRIO:
-		return ixgbe_setup_tc_mqprio(dev, tc->mqprio);
+		return ixgbe_setup_tc_mqprio(dev, type_data);
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 1667e86..6e67ca7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -131,17 +131,19 @@ int mlx4_en_alloc_tx_queue_per_tc(struct net_device *dev, u8 tc)
 }
 
 static int __mlx4_en_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			      struct tc_to_netdev *tc)
+			      void *type_data)
 {
+	struct tc_mqprio_qopt *mqprio = type_data;
+
 	if (type != TC_SETUP_MQPRIO)
 		return -EOPNOTSUPP;
 
-	if (tc->mqprio->num_tc && tc->mqprio->num_tc != MLX4_EN_NUM_UP_HIGH)
+	if (mqprio->num_tc && mqprio->num_tc != MLX4_EN_NUM_UP_HIGH)
 		return -EINVAL;
 
-	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+	mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
 
-	return mlx4_en_alloc_tx_queue_per_tc(dev, tc->mqprio->num_tc);
+	return mlx4_en_alloc_tx_queue_per_tc(dev, mqprio->num_tc);
 }
 
 #ifdef CONFIG_RFS_ACCEL
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 15f2a94..ae09162 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3053,13 +3053,13 @@ static int mlx5e_setup_tc_cls_flower(struct net_device *dev,
 }
 
 static int mlx5e_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			  struct tc_to_netdev *tc)
+			  void *type_data)
 {
 	switch (type) {
 	case TC_SETUP_CLSFLOWER:
-		return mlx5e_setup_tc_cls_flower(dev, tc->cls_flower);
+		return mlx5e_setup_tc_cls_flower(dev, type_data);
 	case TC_SETUP_MQPRIO:
-		return mlx5e_setup_tc_mqprio(dev, tc->mqprio);
+		return mlx5e_setup_tc_mqprio(dev, type_data);
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index e5cf2e7..3df994d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -651,10 +651,10 @@ static int mlx5e_rep_get_phys_port_name(struct net_device *dev,
 	return 0;
 }
 
-static int mlx5e_rep_setup_tc_cls_flower(struct net_device *dev,
-					 struct tc_to_netdev *tc)
+static int
+mlx5e_rep_setup_tc_cls_flower(struct net_device *dev,
+			      struct tc_cls_flower_offload *cls_flower)
 {
-	struct tc_cls_flower_offload *cls_flower = tc->cls_flower;
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
 	if (TC_H_MAJ(cls_flower->common.handle) != TC_H_MAJ(TC_H_INGRESS) ||
@@ -666,7 +666,7 @@ static int mlx5e_rep_setup_tc_cls_flower(struct net_device *dev,
 
 		dev = mlx5_eswitch_get_uplink_netdev(esw);
 		return dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
-						     tc);
+						     cls_flower);
 	}
 
 	switch (cls_flower->command) {
@@ -682,11 +682,11 @@ static int mlx5e_rep_setup_tc_cls_flower(struct net_device *dev,
 }
 
 static int mlx5e_rep_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			      struct tc_to_netdev *tc)
+			      void *type_data)
 {
 	switch (type) {
 	case TC_SETUP_CLSFLOWER:
-		return mlx5e_rep_setup_tc_cls_flower(dev, tc);
+		return mlx5e_rep_setup_tc_cls_flower(dev, type_data);
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
index 5a0f4a4..2917d96 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
@@ -33,6 +33,8 @@
 #ifndef __MLX5_EN_TC_H__
 #define __MLX5_EN_TC_H__
 
+#include <net/pkt_cls.h>
+
 #define MLX5E_TC_FLOW_ID_MASK 0x0000ffff
 
 int mlx5e_tc_init(struct mlx5e_priv *priv);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 1ca3204..eb7c454 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1736,17 +1736,15 @@ mlxsw_sp_setup_tc_cls_flower(struct mlxsw_sp_port *mlxsw_sp_port,
 }
 
 static int mlxsw_sp_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			     struct tc_to_netdev *tc)
+			     void *type_data)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 
 	switch (type) {
 	case TC_SETUP_CLSMATCHALL:
-		return mlxsw_sp_setup_tc_cls_matchall(mlxsw_sp_port,
-						      tc->cls_mall);
+		return mlxsw_sp_setup_tc_cls_matchall(mlxsw_sp_port, type_data);
 	case TC_SETUP_CLSFLOWER:
-		return mlxsw_sp_setup_tc_cls_flower(mlxsw_sp_port,
-						    tc->cls_flower);
+		return mlxsw_sp_setup_tc_cls_flower(mlxsw_sp_port, type_data);
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index 152a7ab..f981f60 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -121,10 +121,9 @@ static void nfp_bpf_vnic_clean(struct nfp_app *app, struct nfp_net *nn)
 }
 
 static int nfp_bpf_setup_tc(struct nfp_app *app, struct net_device *netdev,
-			    enum tc_setup_type type,
-			    struct tc_to_netdev *tc)
+			    enum tc_setup_type type, void *type_data)
 {
-	struct tc_cls_bpf_offload *cls_bpf = tc->cls_bpf;
+	struct tc_cls_bpf_offload *cls_bpf = type_data;
 	struct nfp_net *nn = netdev_priv(netdev);
 
 	if (type != TC_SETUP_CLSBPF || !nfp_net_ebpf_capable(nn) ||
diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.h b/drivers/net/ethernet/netronome/nfp/flower/main.h
index eb94d08..71e4f4f 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.h
@@ -38,8 +38,8 @@
 #include <linux/hashtable.h>
 #include <linux/time64.h>
 #include <linux/types.h>
+#include <net/pkt_cls.h>
 
-struct tc_to_netdev;
 struct net_device;
 struct nfp_app;
 
@@ -135,7 +135,7 @@ int nfp_flower_metadata_init(struct nfp_app *app);
 void nfp_flower_metadata_cleanup(struct nfp_app *app);
 
 int nfp_flower_setup_tc(struct nfp_app *app, struct net_device *netdev,
-			enum tc_setup_type type, struct tc_to_netdev *tc);
+			enum tc_setup_type type, void *type_data);
 int nfp_flower_compile_flow_match(struct tc_cls_flower_offload *flow,
 				  struct nfp_fl_key_ls *key_ls,
 				  struct net_device *netdev,
diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index 8197836..01767c7 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -385,9 +385,9 @@ nfp_flower_repr_offload(struct nfp_app *app, struct net_device *netdev,
 }
 
 int nfp_flower_setup_tc(struct nfp_app *app, struct net_device *netdev,
-			enum tc_setup_type type, struct tc_to_netdev *tc)
+			enum tc_setup_type type, void *type_data)
 {
-	struct tc_cls_flower_offload *cls_flower = tc->cls_flower;
+	struct tc_cls_flower_offload *cls_flower = type_data;
 
 	if (type != TC_SETUP_CLSFLOWER ||
 	    TC_H_MAJ(cls_flower->common.handle) != TC_H_MAJ(TC_H_INGRESS) ||
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.h b/drivers/net/ethernet/netronome/nfp/nfp_app.h
index 7a2f950..f34e877 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.h
@@ -42,7 +42,6 @@ struct bpf_prog;
 struct net_device;
 struct pci_dev;
 struct sk_buff;
-struct tc_to_netdev;
 struct sk_buff;
 struct nfp_app;
 struct nfp_cpp;
@@ -109,7 +108,7 @@ struct nfp_app_type {
 	void (*ctrl_msg_rx)(struct nfp_app *app, struct sk_buff *skb);
 
 	int (*setup_tc)(struct nfp_app *app, struct net_device *netdev,
-			enum tc_setup_type type, struct tc_to_netdev *tc);
+			enum tc_setup_type type, void *type_data);
 	bool (*tc_busy)(struct nfp_app *app, struct nfp_net *nn);
 	int (*xdp_offload)(struct nfp_app *app, struct nfp_net *nn,
 			   struct bpf_prog *prog);
@@ -238,12 +237,11 @@ static inline bool nfp_app_tc_busy(struct nfp_app *app, struct nfp_net *nn)
 
 static inline int nfp_app_setup_tc(struct nfp_app *app,
 				   struct net_device *netdev,
-				   enum tc_setup_type type,
-				   struct tc_to_netdev *tc)
+				   enum tc_setup_type type, void *type_data)
 {
 	if (!app || !app->type->setup_tc)
 		return -EOPNOTSUPP;
-	return app->type->setup_tc(app, netdev, type, tc);
+	return app->type->setup_tc(app, netdev, type, type_data);
 }
 
 static inline int nfp_app_xdp_offload(struct nfp_app *app, struct nfp_net *nn,
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.c b/drivers/net/ethernet/netronome/nfp/nfp_port.c
index e8abab2..0cf65e5 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
@@ -89,7 +89,7 @@ const struct switchdev_ops nfp_port_switchdev_ops = {
 };
 
 int nfp_port_setup_tc(struct net_device *netdev, enum tc_setup_type type,
-		      struct tc_to_netdev *tc)
+		      void *type_data)
 {
 	struct nfp_port *port;
 
@@ -97,7 +97,7 @@ int nfp_port_setup_tc(struct net_device *netdev, enum tc_setup_type type,
 	if (!port)
 		return -EOPNOTSUPP;
 
-	return nfp_app_setup_tc(port->app, netdev, type, tc);
+	return nfp_app_setup_tc(port->app, netdev, type, type_data);
 }
 
 struct nfp_port *
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
index 252f06d..c88e376 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -36,7 +36,6 @@
 
 #include <net/devlink.h>
 
-struct tc_to_netdev;
 struct net_device;
 struct nfp_app;
 struct nfp_pf;
@@ -110,7 +109,7 @@ struct nfp_port {
 extern const struct switchdev_ops nfp_port_switchdev_ops;
 
 int nfp_port_setup_tc(struct net_device *netdev, enum tc_setup_type type,
-		      struct tc_to_netdev *tc);
+		      void *type_data);
 
 struct nfp_port *nfp_port_from_netdev(struct net_device *netdev);
 struct nfp_port *
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index b0c6004..d407adf 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -33,7 +33,7 @@ netdev_tx_t efx_hard_start_xmit(struct sk_buff *skb,
 netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb);
 void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
 int efx_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
-		 struct tc_to_netdev *tc);
+		 void *type_data);
 unsigned int efx_tx_max_skb_descs(struct efx_nic *efx);
 extern unsigned int efx_piobuf_size;
 extern bool efx_separate_tx_channels;
diff --git a/drivers/net/ethernet/sfc/falcon/efx.h b/drivers/net/ethernet/sfc/falcon/efx.h
index 4497511..4f3bb30 100644
--- a/drivers/net/ethernet/sfc/falcon/efx.h
+++ b/drivers/net/ethernet/sfc/falcon/efx.h
@@ -33,7 +33,7 @@ netdev_tx_t ef4_hard_start_xmit(struct sk_buff *skb,
 netdev_tx_t ef4_enqueue_skb(struct ef4_tx_queue *tx_queue, struct sk_buff *skb);
 void ef4_xmit_done(struct ef4_tx_queue *tx_queue, unsigned int index);
 int ef4_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
-		 struct tc_to_netdev *tc);
+		 void *type_data);
 unsigned int ef4_tx_max_skb_descs(struct ef4_nic *efx);
 extern bool ef4_separate_tx_channels;
 
diff --git a/drivers/net/ethernet/sfc/falcon/tx.c b/drivers/net/ethernet/sfc/falcon/tx.c
index 0f125e1..6a75f41 100644
--- a/drivers/net/ethernet/sfc/falcon/tx.c
+++ b/drivers/net/ethernet/sfc/falcon/tx.c
@@ -426,9 +426,10 @@ void ef4_init_tx_queue_core_txq(struct ef4_tx_queue *tx_queue)
 }
 
 int ef4_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
-		 struct tc_to_netdev *ntc)
+		 void *type_data)
 {
 	struct ef4_nic *efx = netdev_priv(net_dev);
+	struct tc_mqprio_qopt *mqprio = type_data;
 	struct ef4_channel *channel;
 	struct ef4_tx_queue *tx_queue;
 	unsigned tc, num_tc;
@@ -437,12 +438,12 @@ int ef4_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
 	if (type != TC_SETUP_MQPRIO)
 		return -EOPNOTSUPP;
 
-	num_tc = ntc->mqprio->num_tc;
+	num_tc = mqprio->num_tc;
 
 	if (ef4_nic_rev(efx) < EF4_REV_FALCON_B0 || num_tc > EF4_MAX_TX_TC)
 		return -EINVAL;
 
-	ntc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+	mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
 
 	if (num_tc == net_dev->num_tc)
 		return 0;
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 53ba30c..32bf1fe 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -654,9 +654,10 @@ void efx_init_tx_queue_core_txq(struct efx_tx_queue *tx_queue)
 }
 
 int efx_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
-		 struct tc_to_netdev *ntc)
+		 void *type_data)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
+	struct tc_mqprio_qopt *mqprio = type_data;
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
 	unsigned tc, num_tc;
@@ -665,12 +666,12 @@ int efx_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
 	if (type != TC_SETUP_MQPRIO)
 		return -EOPNOTSUPP;
 
-	num_tc = ntc->mqprio->num_tc;
+	num_tc = mqprio->num_tc;
 
 	if (num_tc > EFX_MAX_TX_TC)
 		return -EINVAL;
 
-	ntc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+	mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
 
 	if (num_tc == net_dev->num_tc)
 		return 0;
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index caba0ab..eb96a69 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1878,8 +1878,9 @@ static u16 netcp_select_queue(struct net_device *dev, struct sk_buff *skb,
 }
 
 static int netcp_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			  struct tc_to_netdev *tc)
+			  void *type_data)
 {
+	struct tc_mqprio_qopt *mqprio = type_data;
 	u8 num_tc;
 	int i;
 
@@ -1889,8 +1890,8 @@ static int netcp_setup_tc(struct net_device *dev, enum tc_setup_type type,
 	if (type != TC_SETUP_MQPRIO)
 		return -EOPNOTSUPP;
 
-	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
-	num_tc = tc->mqprio->num_tc;
+	mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+	num_tc = mqprio->num_tc;
 
 	/* Sanity-check the number of traffic classes requested */
 	if ((dev->real_num_tx_queues <= 1) ||
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6e2f7e3..1d238d5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -771,9 +771,6 @@ static inline bool netdev_phys_item_id_same(struct netdev_phys_item_id *a,
 typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
 				       struct sk_buff *skb);
 
-/* These structures hold the attributes of qdisc and classifiers
- * that are being passed to the netdevice through the setup_tc op.
- */
 enum tc_setup_type {
 	TC_SETUP_MQPRIO,
 	TC_SETUP_CLSU32,
@@ -782,18 +779,6 @@ enum tc_setup_type {
 	TC_SETUP_CLSBPF,
 };
 
-struct tc_cls_u32_offload;
-
-struct tc_to_netdev {
-	union {
-		struct tc_cls_u32_offload *cls_u32;
-		struct tc_cls_flower_offload *cls_flower;
-		struct tc_cls_matchall_offload *cls_mall;
-		struct tc_cls_bpf_offload *cls_bpf;
-		struct tc_mqprio_qopt *mqprio;
-	};
-};
-
 /* These structures hold the attributes of xdp state that are being passed
  * to the netdevice through the xdp op.
  */
@@ -977,7 +962,7 @@ struct xfrmdev_ops {
  * int (*ndo_set_vf_rss_query_en)(struct net_device *dev, int vf, bool setting);
  * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
  * int (*ndo_setup_tc)(struct net_device *dev, enum tc_setup_type type,
- *		       struct tc_to_netdev *tc);
+ *		       void *type_data);
  *	Called to setup any 'tc' scheduler, classifier or action on @dev.
  *	This is always called from the stack with the rtnl lock held and netif
  *	tx queues stopped. This allows the netdevice to perform queue
@@ -1226,7 +1211,7 @@ struct net_device_ops {
 						   int vf, bool setting);
 	int			(*ndo_setup_tc)(struct net_device *dev,
 						enum tc_setup_type type,
-						struct tc_to_netdev *tc);
+						void *type_data);
 #if IS_ENABLED(CONFIG_FCOE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
 	int			(*ndo_fcoe_disable)(struct net_device *dev);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index dbd1c6c..25b2ba7 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -870,11 +870,11 @@ static int dsa_slave_setup_tc_cls_matchall(struct net_device *dev,
 }
 
 static int dsa_slave_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			      struct tc_to_netdev *tc)
+			      void *type_data)
 {
 	switch (type) {
 	case TC_SETUP_CLSMATCHALL:
-		return dsa_slave_setup_tc_cls_matchall(dev, tc->cls_mall);
+		return dsa_slave_setup_tc_cls_matchall(dev, type_data);
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index dde8efd..2d4d06e 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -147,21 +147,18 @@ static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 			       enum tc_clsbpf_command cmd)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
-	struct tc_cls_bpf_offload bpf_offload = {};
-	struct tc_to_netdev offload;
+	struct tc_cls_bpf_offload cls_bpf = {};
 	int err;
 
-	offload.cls_bpf = &bpf_offload;
+	tc_cls_common_offload_init(&cls_bpf.common, tp);
+	cls_bpf.command = cmd;
+	cls_bpf.exts = &prog->exts;
+	cls_bpf.prog = prog->filter;
+	cls_bpf.name = prog->bpf_name;
+	cls_bpf.exts_integrated = prog->exts_integrated;
+	cls_bpf.gen_flags = prog->gen_flags;
 
-	tc_cls_common_offload_init(&bpf_offload.common, tp);
-	bpf_offload.command = cmd;
-	bpf_offload.exts = &prog->exts;
-	bpf_offload.prog = prog->filter;
-	bpf_offload.name = prog->bpf_name;
-	bpf_offload.exts_integrated = prog->exts_integrated;
-	bpf_offload.gen_flags = prog->gen_flags;
-
-	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSBPF, &offload);
+	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSBPF, &cls_bpf);
 	if (!err && (cmd == TC_CLSBPF_ADD || cmd == TC_CLSBPF_REPLACE))
 		prog->gen_flags |= TCA_CLS_FLAGS_IN_HW;
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index ccdf2f5..1474bac 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -88,7 +88,6 @@ struct cls_fl_filter {
 	u32 handle;
 	u32 flags;
 	struct rcu_head	rcu;
-	struct tc_to_netdev tc;
 	struct net_device *hw_dev;
 };
 
@@ -225,20 +224,17 @@ static void fl_destroy_filter(struct rcu_head *head)
 
 static void fl_hw_destroy_filter(struct tcf_proto *tp, struct cls_fl_filter *f)
 {
-	struct tc_cls_flower_offload offload = {0};
+	struct tc_cls_flower_offload cls_flower = {};
 	struct net_device *dev = f->hw_dev;
-	struct tc_to_netdev *tc = &f->tc;
 
 	if (!tc_can_offload(dev, tp))
 		return;
 
-	tc_cls_common_offload_init(&offload.common, tp);
-	offload.command = TC_CLSFLOWER_DESTROY;
-	offload.cookie = (unsigned long)f;
+	tc_cls_common_offload_init(&cls_flower.common, tp);
+	cls_flower.command = TC_CLSFLOWER_DESTROY;
+	cls_flower.cookie = (unsigned long) f;
 
-	tc->cls_flower = &offload;
-
-	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER, tc);
+	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER, &cls_flower);
 }
 
 static int fl_hw_replace_filter(struct tcf_proto *tp,
@@ -247,8 +243,7 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 				struct cls_fl_filter *f)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
-	struct tc_cls_flower_offload offload = {0};
-	struct tc_to_netdev *tc = &f->tc;
+	struct tc_cls_flower_offload cls_flower = {};
 	int err;
 
 	if (!tc_can_offload(dev, tp)) {
@@ -258,22 +253,21 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 			return tc_skip_sw(f->flags) ? -EINVAL : 0;
 		}
 		dev = f->hw_dev;
-		offload.egress_dev = true;
+		cls_flower.egress_dev = true;
 	} else {
 		f->hw_dev = dev;
 	}
 
-	tc_cls_common_offload_init(&offload.common, tp);
-	offload.command = TC_CLSFLOWER_REPLACE;
-	offload.cookie = (unsigned long)f;
-	offload.dissector = dissector;
-	offload.mask = mask;
-	offload.key = &f->mkey;
-	offload.exts = &f->exts;
-
-	tc->cls_flower = &offload;
+	tc_cls_common_offload_init(&cls_flower.common, tp);
+	cls_flower.command = TC_CLSFLOWER_REPLACE;
+	cls_flower.cookie = (unsigned long) f;
+	cls_flower.dissector = dissector;
+	cls_flower.mask = mask;
+	cls_flower.key = &f->mkey;
+	cls_flower.exts = &f->exts;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER, tc);
+	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
+					    &cls_flower);
 	if (!err)
 		f->flags |= TCA_CLS_FLAGS_IN_HW;
 
@@ -284,21 +278,19 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 
 static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 {
-	struct tc_cls_flower_offload offload = {0};
+	struct tc_cls_flower_offload cls_flower = {};
 	struct net_device *dev = f->hw_dev;
-	struct tc_to_netdev *tc = &f->tc;
 
 	if (!tc_can_offload(dev, tp))
 		return;
 
-	tc_cls_common_offload_init(&offload.common, tp);
-	offload.command = TC_CLSFLOWER_STATS;
-	offload.cookie = (unsigned long)f;
-	offload.exts = &f->exts;
-
-	tc->cls_flower = &offload;
+	tc_cls_common_offload_init(&cls_flower.common, tp);
+	cls_flower.command = TC_CLSFLOWER_STATS;
+	cls_flower.cookie = (unsigned long) f;
+	cls_flower.exts = &f->exts;
 
-	dev->netdev_ops->ndo_setup_tc(dev, TC_CLSFLOWER_STATS, tc);
+	dev->netdev_ops->ndo_setup_tc(dev, TC_CLSFLOWER_STATS,
+				      &cls_flower);
 }
 
 static void __fl_delete(struct tcf_proto *tp, struct cls_fl_filter *f)
diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index 174c700..c9f6500 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -54,18 +54,16 @@ static int mall_replace_hw_filter(struct tcf_proto *tp,
 				  unsigned long cookie)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
-	struct tc_to_netdev offload;
-	struct tc_cls_matchall_offload mall_offload = {0};
+	struct tc_cls_matchall_offload cls_mall = {};
 	int err;
 
-	tc_cls_common_offload_init(&mall_offload.common, tp);
-	offload.cls_mall = &mall_offload;
-	offload.cls_mall->command = TC_CLSMATCHALL_REPLACE;
-	offload.cls_mall->exts = &head->exts;
-	offload.cls_mall->cookie = cookie;
+	tc_cls_common_offload_init(&cls_mall.common, tp);
+	cls_mall.command = TC_CLSMATCHALL_REPLACE;
+	cls_mall.exts = &head->exts;
+	cls_mall.cookie = cookie;
 
 	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSMATCHALL,
-					    &offload);
+					    &cls_mall);
 	if (!err)
 		head->flags |= TCA_CLS_FLAGS_IN_HW;
 
@@ -77,16 +75,13 @@ static void mall_destroy_hw_filter(struct tcf_proto *tp,
 				   unsigned long cookie)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
-	struct tc_to_netdev offload;
-	struct tc_cls_matchall_offload mall_offload = {0};
+	struct tc_cls_matchall_offload cls_mall = {};
 
-	tc_cls_common_offload_init(&mall_offload.common, tp);
-	offload.cls_mall = &mall_offload;
-	offload.cls_mall->command = TC_CLSMATCHALL_DESTROY;
-	offload.cls_mall->exts = NULL;
-	offload.cls_mall->cookie = cookie;
+	tc_cls_common_offload_init(&cls_mall.common, tp);
+	cls_mall.command = TC_CLSMATCHALL_DESTROY;
+	cls_mall.cookie = cookie;
 
-	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSMATCHALL, &offload);
+	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSMATCHALL, &cls_mall);
 }
 
 static void mall_destroy(struct tcf_proto *tp)
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index c0f59c4..4ed51d3 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -431,39 +431,35 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
 static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
-	struct tc_cls_u32_offload u32_offload = {0};
-	struct tc_to_netdev offload;
+	struct tc_cls_u32_offload cls_u32 = {};
 
-	offload.cls_u32 = &u32_offload;
+	if (!tc_should_offload(dev, tp, 0))
+		return;
 
-	if (tc_should_offload(dev, tp, 0)) {
-		tc_cls_common_offload_init(&u32_offload.common, tp);
-		offload.cls_u32->command = TC_CLSU32_DELETE_KNODE;
-		offload.cls_u32->knode.handle = handle;
-		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &offload);
-	}
+	tc_cls_common_offload_init(&cls_u32.common, tp);
+	cls_u32.command = TC_CLSU32_DELETE_KNODE;
+	cls_u32.knode.handle = handle;
+
+	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &cls_u32);
 }
 
 static int u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h,
 				u32 flags)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
-	struct tc_cls_u32_offload u32_offload = {0};
-	struct tc_to_netdev offload;
+	struct tc_cls_u32_offload cls_u32 = {};
 	int err;
 
 	if (!tc_should_offload(dev, tp, flags))
 		return tc_skip_sw(flags) ? -EINVAL : 0;
 
-	offload.cls_u32 = &u32_offload;
-
-	tc_cls_common_offload_init(&u32_offload.common, tp);
-	offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
-	offload.cls_u32->hnode.divisor = h->divisor;
-	offload.cls_u32->hnode.handle = h->handle;
-	offload.cls_u32->hnode.prio = h->prio;
+	tc_cls_common_offload_init(&cls_u32.common, tp);
+	cls_u32.command = TC_CLSU32_NEW_HNODE;
+	cls_u32.hnode.divisor = h->divisor;
+	cls_u32.hnode.handle = h->handle;
+	cls_u32.hnode.prio = h->prio;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &offload);
+	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &cls_u32);
 	if (tc_skip_sw(flags))
 		return err;
 
@@ -473,52 +469,47 @@ static int u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h,
 static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
-	struct tc_cls_u32_offload u32_offload = {0};
-	struct tc_to_netdev offload;
+	struct tc_cls_u32_offload cls_u32 = {};
 
-	offload.cls_u32 = &u32_offload;
+	if (!tc_should_offload(dev, tp, 0))
+		return;
 
-	if (tc_should_offload(dev, tp, 0)) {
-		tc_cls_common_offload_init(&u32_offload.common, tp);
-		offload.cls_u32->command = TC_CLSU32_DELETE_HNODE;
-		offload.cls_u32->hnode.divisor = h->divisor;
-		offload.cls_u32->hnode.handle = h->handle;
-		offload.cls_u32->hnode.prio = h->prio;
+	tc_cls_common_offload_init(&cls_u32.common, tp);
+	cls_u32.command = TC_CLSU32_DELETE_HNODE;
+	cls_u32.hnode.divisor = h->divisor;
+	cls_u32.hnode.handle = h->handle;
+	cls_u32.hnode.prio = h->prio;
 
-		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &offload);
-	}
+	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &cls_u32);
 }
 
 static int u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n,
 				u32 flags)
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
-	struct tc_cls_u32_offload u32_offload = {0};
-	struct tc_to_netdev offload;
+	struct tc_cls_u32_offload cls_u32 = {};
 	int err;
 
-	offload.cls_u32 = &u32_offload;
-
 	if (!tc_should_offload(dev, tp, flags))
 		return tc_skip_sw(flags) ? -EINVAL : 0;
 
-	tc_cls_common_offload_init(&u32_offload.common, tp);
-	offload.cls_u32->command = TC_CLSU32_REPLACE_KNODE;
-	offload.cls_u32->knode.handle = n->handle;
-	offload.cls_u32->knode.fshift = n->fshift;
+	tc_cls_common_offload_init(&cls_u32.common, tp);
+	cls_u32.command = TC_CLSU32_REPLACE_KNODE;
+	cls_u32.knode.handle = n->handle;
+	cls_u32.knode.fshift = n->fshift;
 #ifdef CONFIG_CLS_U32_MARK
-	offload.cls_u32->knode.val = n->val;
-	offload.cls_u32->knode.mask = n->mask;
+	cls_u32.knode.val = n->val;
+	cls_u32.knode.mask = n->mask;
 #else
-	offload.cls_u32->knode.val = 0;
-	offload.cls_u32->knode.mask = 0;
+	cls_u32.knode.val = 0;
+	cls_u32.knode.mask = 0;
 #endif
-	offload.cls_u32->knode.sel = &n->sel;
-	offload.cls_u32->knode.exts = &n->exts;
+	cls_u32.knode.sel = &n->sel;
+	cls_u32.knode.exts = &n->exts;
 	if (n->ht_down)
-		offload.cls_u32->knode.link_handle = n->ht_down->handle;
+		cls_u32.knode.link_handle = n->ht_down->handle;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &offload);
+	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, &cls_u32);
 
 	if (!err)
 		n->flags |= TCA_CLS_FLAGS_IN_HW;
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 09b577d..2165a05 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -39,10 +39,9 @@ static void mqprio_destroy(struct Qdisc *sch)
 	}
 
 	if (priv->hw_offload && dev->netdev_ops->ndo_setup_tc) {
-		struct tc_mqprio_qopt offload = { 0 };
-		struct tc_to_netdev tc = { { .mqprio = &offload } };
+		struct tc_mqprio_qopt mqprio = {};
 
-		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_MQPRIO, &tc);
+		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_MQPRIO, &mqprio);
 	} else {
 		netdev_set_num_tc(dev, 0);
 	}
@@ -147,14 +146,14 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 	 * supplied and verified mapping
 	 */
 	if (qopt->hw) {
-		struct tc_mqprio_qopt offload = *qopt;
-		struct tc_to_netdev tc = { { .mqprio = &offload } };
+		struct tc_mqprio_qopt mqprio = *qopt;
 
-		err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_MQPRIO, &tc);
+		err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_MQPRIO,
+						    &mqprio);
 		if (err)
 			return err;
 
-		priv->hw_offload = offload.hw;
+		priv->hw_offload = mqprio.hw;
 	} else {
 		netdev_set_num_tc(dev, qopt->num_tc);
 		for (i = 0; i < qopt->num_tc; i++)
-- 
2.9.3
