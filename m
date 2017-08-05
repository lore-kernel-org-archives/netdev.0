From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/15] net: sched: make type an argument for ndo_setup_tc
Date: Sat,  5 Aug 2017 16:53:23 +0200
Message-ID: <20170805145337.17728-2-jiri@resnulli.us>
References: <20170805145337.17728-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:38799 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751900AbdHEOxn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 10:53:43 -0400
Received: by mail-wr0-f193.google.com with SMTP id g32so4759614wrd.5
        for <netdev@vger.kernel.org>; Sat, 05 Aug 2017 07:53:42 -0700 (PDT)
In-Reply-To: <20170805145337.17728-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Since the type is always present, push it to be a separate argument to
ndo_setup_tc. On the way, name the type enum and use it for arg type.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c            |  6 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     |  7 ++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h     |  5 +++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.c           |  7 ++++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     |  7 ++++---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c      |  7 ++++---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c     |  7 ++++---
 drivers/net/ethernet/intel/i40e/i40e_main.c         |  6 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c       |  9 +++++----
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c      |  6 +++---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c   |  8 ++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c    |  9 +++++----
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c      | 10 +++++-----
 drivers/net/ethernet/netronome/nfp/bpf/main.c       |  5 +++--
 drivers/net/ethernet/netronome/nfp/flower/main.h    |  3 ++-
 drivers/net/ethernet/netronome/nfp/flower/offload.c |  5 +++--
 drivers/net/ethernet/netronome/nfp/nfp_app.h        |  6 ++++--
 drivers/net/ethernet/netronome/nfp/nfp_port.c       |  7 ++++---
 drivers/net/ethernet/netronome/nfp/nfp_port.h       |  5 +++--
 drivers/net/ethernet/sfc/efx.h                      |  5 +++--
 drivers/net/ethernet/sfc/falcon/efx.h               |  5 +++--
 drivers/net/ethernet/sfc/falcon/tx.c                |  7 ++++---
 drivers/net/ethernet/sfc/tx.c                       |  7 ++++---
 drivers/net/ethernet/ti/netcp_core.c                |  7 ++++---
 include/linux/netdevice.h                           |  9 +++++----
 net/dsa/slave.c                                     |  6 +++---
 net/sched/cls_bpf.c                                 |  4 ++--
 net/sched/cls_flower.c                              | 14 ++++++--------
 net/sched/cls_matchall.c                            | 10 ++++------
 net/sched/cls_u32.c                                 | 20 ++++++++------------
 net/sched/sch_mqprio.c                              | 13 ++++++-------
 31 files changed, 122 insertions(+), 110 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index ecef3ee..6a6ea3b 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1918,14 +1918,14 @@ static void xgbe_poll_controller(struct net_device *netdev)
 }
 #endif /* End CONFIG_NET_POLL_CONTROLLER */
 
-static int xgbe_setup_tc(struct net_device *netdev, u32 handle, u32 chain_index,
-			 __be16 proto,
+static int xgbe_setup_tc(struct net_device *netdev, enum tc_setup_type type,
+			 u32 handle, u32 chain_index, __be16 proto,
 			 struct tc_to_netdev *tc_to_netdev)
 {
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
 	u8 tc;
 
-	if (tc_to_netdev->type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	tc_to_netdev->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 67fe3d8..4395d1c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -4284,10 +4284,11 @@ int bnx2x_setup_tc(struct net_device *dev, u8 num_tc)
 	return 0;
 }
 
-int __bnx2x_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
-		     __be16 proto, struct tc_to_netdev *tc)
+int __bnx2x_setup_tc(struct net_device *dev, enum tc_setup_type type,
+		     u32 handle, u32 chain_index, __be16 proto,
+		     struct tc_to_netdev *tc)
 {
-	if (tc->type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index c26688d..1ac4eb0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -486,8 +486,9 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev);
 
 /* setup_tc callback */
 int bnx2x_setup_tc(struct net_device *dev, u8 num_tc);
-int __bnx2x_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
-		     __be16 proto, struct tc_to_netdev *tc);
+int __bnx2x_setup_tc(struct net_device *dev, enum tc_setup_type type,
+		     u32 handle, u32 chain_index, __be16 proto,
+		     struct tc_to_netdev *tc);
 
 int bnx2x_get_vf_config(struct net_device *dev, int vf,
 			struct ifla_vf_info *ivi);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 156fb37..b98d9f3 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7237,10 +7237,11 @@ int bnxt_setup_mq_tc(struct net_device *dev, u8 tc)
 	return 0;
 }
 
-static int bnxt_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
-			 __be16 proto, struct tc_to_netdev *ntc)
+static int bnxt_setup_tc(struct net_device *dev, enum tc_setup_type type,
+			 u32 handle, u32 chain_index, __be16 proto,
+			 struct tc_to_netdev *ntc)
 {
-	if (ntc->type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	ntc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index fdf220a..89d2b0c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2889,8 +2889,9 @@ static int cxgb_set_tx_maxrate(struct net_device *dev, int index, u32 rate)
 	return err;
 }
 
-static int cxgb_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
-			 __be16 proto, struct tc_to_netdev *tc)
+static int cxgb_setup_tc(struct net_device *dev, enum tc_setup_type type,
+			 u32 handle, u32 chain_index, __be16 proto,
+			 struct tc_to_netdev *tc)
 {
 	struct port_info *pi = netdev2pinfo(dev);
 	struct adapter *adap = netdev2adap(dev);
@@ -2906,7 +2907,7 @@ static int cxgb_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
 	}
 
 	if (TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS) &&
-	    tc->type == TC_SETUP_CLSU32) {
+	    type == TC_SETUP_CLSU32) {
 		switch (tc->cls_u32->command) {
 		case TC_CLSU32_NEW_KNODE:
 		case TC_CLSU32_REPLACE_KNODE:
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 550ea1e..d86d766 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -342,14 +342,15 @@ static void dpaa_get_stats64(struct net_device *net_dev,
 	}
 }
 
-static int dpaa_setup_tc(struct net_device *net_dev, u32 handle,
-			 u32 chain_index, __be16 proto, struct tc_to_netdev *tc)
+static int dpaa_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
+			 u32 handle, u32 chain_index, __be16 proto,
+			 struct tc_to_netdev *tc)
 {
 	struct dpaa_priv *priv = netdev_priv(net_dev);
 	u8 num_tc;
 	int i;
 
-	if (tc->type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 5e37387..b301906 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1265,10 +1265,11 @@ int fm10k_setup_tc(struct net_device *dev, u8 tc)
 	return err;
 }
 
-static int __fm10k_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
-			    __be16 proto, struct tc_to_netdev *tc)
+static int __fm10k_setup_tc(struct net_device *dev, enum tc_setup_type type,
+			    u32 handle, u32 chain_index, __be16 proto,
+			    struct tc_to_netdev *tc)
 {
-	if (tc->type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4104944..7d47a71 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5656,11 +5656,11 @@ static int i40e_setup_tc(struct net_device *netdev, u8 tc)
 	return ret;
 }
 
-static int __i40e_setup_tc(struct net_device *netdev, u32 handle,
-			   u32 chain_index, __be16 proto,
+static int __i40e_setup_tc(struct net_device *netdev, enum tc_setup_type type,
+			   u32 handle, u32 chain_index, __be16 proto,
 			   struct tc_to_netdev *tc)
 {
-	if (tc->type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 091fcc7..d39db97 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9226,8 +9226,9 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 	return err;
 }
 
-static int __ixgbe_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
-			    __be16 proto, struct tc_to_netdev *tc)
+static int __ixgbe_setup_tc(struct net_device *dev, enum tc_setup_type type,
+			    u32 handle, u32 chain_index, __be16 proto,
+			    struct tc_to_netdev *tc)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 
@@ -9235,7 +9236,7 @@ static int __ixgbe_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
 		return -EOPNOTSUPP;
 
 	if (TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS) &&
-	    tc->type == TC_SETUP_CLSU32) {
+	    type == TC_SETUP_CLSU32) {
 		switch (tc->cls_u32->command) {
 		case TC_CLSU32_NEW_KNODE:
 		case TC_CLSU32_REPLACE_KNODE:
@@ -9255,7 +9256,7 @@ static int __ixgbe_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
 		}
 	}
 
-	if (tc->type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 3a291fc..5c33550 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -130,11 +130,11 @@ int mlx4_en_alloc_tx_queue_per_tc(struct net_device *dev, u8 tc)
 	return err;
 }
 
-static int __mlx4_en_setup_tc(struct net_device *dev, u32 handle,
-			      u32 chain_index, __be16 proto,
+static int __mlx4_en_setup_tc(struct net_device *dev, enum tc_setup_type type,
+			      u32 handle, u32 chain_index, __be16 proto,
 			      struct tc_to_netdev *tc)
 {
-	if (tc->type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	if (tc->mqprio->num_tc && tc->mqprio->num_tc != MLX4_EN_NUM_UP_HIGH)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 57f31fa..4052e225f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3027,8 +3027,8 @@ static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
 	return err;
 }
 
-static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
-			      u32 chain_index, __be16 proto,
+static int mlx5e_ndo_setup_tc(struct net_device *dev, enum tc_setup_type type,
+			      u32 handle, u32 chain_index, __be16 proto,
 			      struct tc_to_netdev *tc)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
@@ -3039,7 +3039,7 @@ static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
 	if (chain_index)
 		return -EOPNOTSUPP;
 
-	switch (tc->type) {
+	switch (type) {
 	case TC_SETUP_CLSFLOWER:
 		switch (tc->cls_flower->command) {
 		case TC_CLSFLOWER_REPLACE:
@@ -3054,7 +3054,7 @@ static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
 	}
 
 mqprio:
-	if (tc->type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 45e60be..d44049e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -651,7 +651,8 @@ static int mlx5e_rep_get_phys_port_name(struct net_device *dev,
 	return 0;
 }
 
-static int mlx5e_rep_ndo_setup_tc(struct net_device *dev, u32 handle,
+static int mlx5e_rep_ndo_setup_tc(struct net_device *dev,
+				  enum tc_setup_type type, u32 handle,
 				  u32 chain_index, __be16 proto,
 				  struct tc_to_netdev *tc)
 {
@@ -664,15 +665,15 @@ static int mlx5e_rep_ndo_setup_tc(struct net_device *dev, u32 handle,
 		struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 		struct net_device *uplink_dev = mlx5_eswitch_get_uplink_netdev(esw);
 
-		return uplink_dev->netdev_ops->ndo_setup_tc(uplink_dev, handle,
-							    chain_index,
+		return uplink_dev->netdev_ops->ndo_setup_tc(uplink_dev, type,
+							    handle, chain_index,
 							    proto, tc);
 	}
 
 	if (chain_index)
 		return -EOPNOTSUPP;
 
-	switch (tc->type) {
+	switch (type) {
 	case TC_SETUP_CLSFLOWER:
 		switch (tc->cls_flower->command) {
 		case TC_CLSFLOWER_REPLACE:
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 66d511d..1554242 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1693,8 +1693,8 @@ static void mlxsw_sp_port_del_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 	kfree(mall_tc_entry);
 }
 
-static int mlxsw_sp_setup_tc(struct net_device *dev, u32 handle,
-			     u32 chain_index, __be16 proto,
+static int mlxsw_sp_setup_tc(struct net_device *dev, enum tc_setup_type type,
+			     u32 handle, u32 chain_index, __be16 proto,
 			     struct tc_to_netdev *tc)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
@@ -1703,7 +1703,7 @@ static int mlxsw_sp_setup_tc(struct net_device *dev, u32 handle,
 	if (chain_index)
 		return -EOPNOTSUPP;
 
-	switch (tc->type) {
+	switch (type) {
 	case TC_SETUP_MATCHALL:
 		switch (tc->cls_mall->command) {
 		case TC_CLSMATCHALL_REPLACE:
@@ -1733,9 +1733,9 @@ static int mlxsw_sp_setup_tc(struct net_device *dev, u32 handle,
 		default:
 			return -EOPNOTSUPP;
 		}
+	default:
+		return -EOPNOTSUPP;
 	}
-
-	return -EOPNOTSUPP;
 }
 
 static const struct net_device_ops mlxsw_sp_port_netdev_ops = {
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index afbdf5f..7888808 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -121,7 +121,8 @@ static void nfp_bpf_vnic_clean(struct nfp_app *app, struct nfp_net *nn)
 }
 
 static int nfp_bpf_setup_tc(struct nfp_app *app, struct net_device *netdev,
-			    u32 handle, __be16 proto, struct tc_to_netdev *tc)
+			    enum tc_setup_type type, u32 handle, __be16 proto,
+			    struct tc_to_netdev *tc)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 
@@ -130,7 +131,7 @@ static int nfp_bpf_setup_tc(struct nfp_app *app, struct net_device *netdev,
 	if (proto != htons(ETH_P_ALL))
 		return -EOPNOTSUPP;
 
-	if (tc->type == TC_SETUP_CLSBPF && nfp_net_ebpf_capable(nn)) {
+	if (type == TC_SETUP_CLSBPF && nfp_net_ebpf_capable(nn)) {
 		if (!nn->dp.bpf_offload_xdp)
 			return nfp_net_bpf_offload(nn, tc->cls_bpf);
 		else
diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.h b/drivers/net/ethernet/netronome/nfp/flower/main.h
index 9e64c04..314e6e8 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/main.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/main.h
@@ -135,7 +135,8 @@ int nfp_flower_metadata_init(struct nfp_app *app);
 void nfp_flower_metadata_cleanup(struct nfp_app *app);
 
 int nfp_flower_setup_tc(struct nfp_app *app, struct net_device *netdev,
-			u32 handle, __be16 proto, struct tc_to_netdev *tc);
+			enum tc_setup_type type, u32 handle, __be16 proto,
+			struct tc_to_netdev *tc);
 int nfp_flower_compile_flow_match(struct tc_cls_flower_offload *flow,
 				  struct nfp_fl_key_ls *key_ls,
 				  struct net_device *netdev,
diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index 4ad10bd..d045cf8 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -385,7 +385,8 @@ nfp_flower_repr_offload(struct nfp_app *app, struct net_device *netdev,
 }
 
 int nfp_flower_setup_tc(struct nfp_app *app, struct net_device *netdev,
-			u32 handle, __be16 proto, struct tc_to_netdev *tc)
+			enum tc_setup_type type, u32 handle, __be16 proto,
+			struct tc_to_netdev *tc)
 {
 	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
 		return -EOPNOTSUPP;
@@ -393,7 +394,7 @@ int nfp_flower_setup_tc(struct nfp_app *app, struct net_device *netdev,
 	if (!eth_proto_is_802_3(proto))
 		return -EOPNOTSUPP;
 
-	if (tc->type != TC_SETUP_CLSFLOWER)
+	if (type != TC_SETUP_CLSFLOWER)
 		return -EINVAL;
 
 	return nfp_flower_repr_offload(app, netdev, tc->cls_flower);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.h b/drivers/net/ethernet/netronome/nfp/nfp_app.h
index 5d714e1..b3b03bb9 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.h
@@ -109,7 +109,8 @@ struct nfp_app_type {
 	void (*ctrl_msg_rx)(struct nfp_app *app, struct sk_buff *skb);
 
 	int (*setup_tc)(struct nfp_app *app, struct net_device *netdev,
-			u32 handle, __be16 proto, struct tc_to_netdev *tc);
+			enum tc_setup_type type, u32 handle, __be16 proto,
+			struct tc_to_netdev *tc);
 	bool (*tc_busy)(struct nfp_app *app, struct nfp_net *nn);
 	int (*xdp_offload)(struct nfp_app *app, struct nfp_net *nn,
 			   struct bpf_prog *prog);
@@ -238,12 +239,13 @@ static inline bool nfp_app_tc_busy(struct nfp_app *app, struct nfp_net *nn)
 
 static inline int nfp_app_setup_tc(struct nfp_app *app,
 				   struct net_device *netdev,
+				   enum tc_setup_type type,
 				   u32 handle, __be16 proto,
 				   struct tc_to_netdev *tc)
 {
 	if (!app || !app->type->setup_tc)
 		return -EOPNOTSUPP;
-	return app->type->setup_tc(app, netdev, handle, proto, tc);
+	return app->type->setup_tc(app, netdev, type, handle, proto, tc);
 }
 
 static inline int nfp_app_xdp_offload(struct nfp_app *app, struct nfp_net *nn,
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.c b/drivers/net/ethernet/netronome/nfp/nfp_port.c
index d16a7b7..9d776f9 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
@@ -88,8 +88,9 @@ const struct switchdev_ops nfp_port_switchdev_ops = {
 	.switchdev_port_attr_get	= nfp_port_attr_get,
 };
 
-int nfp_port_setup_tc(struct net_device *netdev, u32 handle, u32 chain_index,
-		      __be16 proto, struct tc_to_netdev *tc)
+int nfp_port_setup_tc(struct net_device *netdev, enum tc_setup_type type,
+		      u32 handle, u32 chain_index, __be16 proto,
+		      struct tc_to_netdev *tc)
 {
 	struct nfp_port *port;
 
@@ -100,7 +101,7 @@ int nfp_port_setup_tc(struct net_device *netdev, u32 handle, u32 chain_index,
 	if (!port)
 		return -EOPNOTSUPP;
 
-	return nfp_app_setup_tc(port->app, netdev, handle, proto, tc);
+	return nfp_app_setup_tc(port->app, netdev, type, handle, proto, tc);
 }
 
 struct nfp_port *
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
index 56c7692..239c540 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -109,8 +109,9 @@ struct nfp_port {
 
 extern const struct switchdev_ops nfp_port_switchdev_ops;
 
-int nfp_port_setup_tc(struct net_device *netdev, u32 handle, u32 chain_index,
-		      __be16 proto, struct tc_to_netdev *tc);
+int nfp_port_setup_tc(struct net_device *netdev, enum tc_setup_type type,
+		      u32 handle, u32 chain_index, __be16 proto,
+		      struct tc_to_netdev *tc);
 
 struct nfp_port *nfp_port_from_netdev(struct net_device *netdev);
 struct nfp_port *
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index fcea937..e41a717 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -32,8 +32,9 @@ netdev_tx_t efx_hard_start_xmit(struct sk_buff *skb,
 				struct net_device *net_dev);
 netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb);
 void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
-int efx_setup_tc(struct net_device *net_dev, u32 handle, u32 chain_index,
-		 __be16 proto, struct tc_to_netdev *tc);
+int efx_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
+		 u32 handle, u32 chain_index, __be16 proto,
+		 struct tc_to_netdev *tc);
 unsigned int efx_tx_max_skb_descs(struct efx_nic *efx);
 extern unsigned int efx_piobuf_size;
 extern bool efx_separate_tx_channels;
diff --git a/drivers/net/ethernet/sfc/falcon/efx.h b/drivers/net/ethernet/sfc/falcon/efx.h
index e5a7a40..f3bc67e 100644
--- a/drivers/net/ethernet/sfc/falcon/efx.h
+++ b/drivers/net/ethernet/sfc/falcon/efx.h
@@ -32,8 +32,9 @@ netdev_tx_t ef4_hard_start_xmit(struct sk_buff *skb,
 				struct net_device *net_dev);
 netdev_tx_t ef4_enqueue_skb(struct ef4_tx_queue *tx_queue, struct sk_buff *skb);
 void ef4_xmit_done(struct ef4_tx_queue *tx_queue, unsigned int index);
-int ef4_setup_tc(struct net_device *net_dev, u32 handle, u32 chain_index,
-		 __be16 proto, struct tc_to_netdev *tc);
+int ef4_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
+		 u32 handle, u32 chain_index, __be16 proto,
+		 struct tc_to_netdev *tc);
 unsigned int ef4_tx_max_skb_descs(struct ef4_nic *efx);
 extern bool ef4_separate_tx_channels;
 
diff --git a/drivers/net/ethernet/sfc/falcon/tx.c b/drivers/net/ethernet/sfc/falcon/tx.c
index f1520a4..6c47526 100644
--- a/drivers/net/ethernet/sfc/falcon/tx.c
+++ b/drivers/net/ethernet/sfc/falcon/tx.c
@@ -425,8 +425,9 @@ void ef4_init_tx_queue_core_txq(struct ef4_tx_queue *tx_queue)
 				     efx->n_tx_channels : 0));
 }
 
-int ef4_setup_tc(struct net_device *net_dev, u32 handle, u32 chain_index,
-		 __be16 proto, struct tc_to_netdev *ntc)
+int ef4_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
+		 u32 handle, u32 chain_index, __be16 proto,
+		 struct tc_to_netdev *ntc)
 {
 	struct ef4_nic *efx = netdev_priv(net_dev);
 	struct ef4_channel *channel;
@@ -434,7 +435,7 @@ int ef4_setup_tc(struct net_device *net_dev, u32 handle, u32 chain_index,
 	unsigned tc, num_tc;
 	int rc;
 
-	if (ntc->type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	num_tc = ntc->mqprio->num_tc;
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 02d41eb..0c08c10 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -653,8 +653,9 @@ void efx_init_tx_queue_core_txq(struct efx_tx_queue *tx_queue)
 				     efx->n_tx_channels : 0));
 }
 
-int efx_setup_tc(struct net_device *net_dev, u32 handle, u32 chain_index,
-		 __be16 proto, struct tc_to_netdev *ntc)
+int efx_setup_tc(struct net_device *net_dev, enum tc_setup_type type,
+		 u32 handle, u32 chain_index, __be16 proto,
+		 struct tc_to_netdev *ntc)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_channel *channel;
@@ -662,7 +663,7 @@ int efx_setup_tc(struct net_device *net_dev, u32 handle, u32 chain_index,
 	unsigned tc, num_tc;
 	int rc;
 
-	if (ntc->type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	num_tc = ntc->mqprio->num_tc;
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 9d52c3a..cb21742 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1877,8 +1877,9 @@ static u16 netcp_select_queue(struct net_device *dev, struct sk_buff *skb,
 	return 0;
 }
 
-static int netcp_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
-			  __be16 proto, struct tc_to_netdev *tc)
+static int netcp_setup_tc(struct net_device *dev, enum tc_setup_type type,
+			  u32 handle, u32 chain_index, __be16 proto,
+			  struct tc_to_netdev *tc)
 {
 	u8 num_tc;
 	int i;
@@ -1886,7 +1887,7 @@ static int netcp_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
 	/* setup tc must be called under rtnl lock */
 	ASSERT_RTNL();
 
-	if (tc->type != TC_SETUP_MQPRIO)
+	if (type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3a3cdc1..e4238e5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -774,7 +774,7 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
 /* These structures hold the attributes of qdisc and classifiers
  * that are being passed to the netdevice through the setup_tc op.
  */
-enum {
+enum tc_setup_type {
 	TC_SETUP_MQPRIO,
 	TC_SETUP_CLSU32,
 	TC_SETUP_CLSFLOWER,
@@ -785,7 +785,6 @@ enum {
 struct tc_cls_u32_offload;
 
 struct tc_to_netdev {
-	unsigned int type;
 	union {
 		struct tc_cls_u32_offload *cls_u32;
 		struct tc_cls_flower_offload *cls_flower;
@@ -978,8 +977,9 @@ struct xfrmdev_ops {
  *      with PF and querying it may introduce a theoretical security risk.
  * int (*ndo_set_vf_rss_query_en)(struct net_device *dev, int vf, bool setting);
  * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
- * int (*ndo_setup_tc)(struct net_device *dev, u32 handle, u32 chain_index,
- *		       __be16 protocol, struct tc_to_netdev *tc);
+ * int (*ndo_setup_tc)(struct net_device *dev, enum tc_setup_type type,
+ *		       u32 handle, u32 chain_index, __be16 protocol,
+ *		       struct tc_to_netdev *tc);
  *	Called to setup any 'tc' scheduler, classifier or action on @dev.
  *	This is always called from the stack with the rtnl lock held and netif
  *	tx queues stopped. This allows the netdevice to perform queue
@@ -1227,6 +1227,7 @@ struct net_device_ops {
 						   struct net_device *dev,
 						   int vf, bool setting);
 	int			(*ndo_setup_tc)(struct net_device *dev,
+						enum tc_setup_type type,
 						u32 handle, u32 chain_index,
 						__be16 protocol,
 						struct tc_to_netdev *tc);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 83252e8..2946fad 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -850,8 +850,8 @@ static void dsa_slave_del_cls_matchall(struct net_device *dev,
 	kfree(mall_tc_entry);
 }
 
-static int dsa_slave_setup_tc(struct net_device *dev, u32 handle,
-			      u32 chain_index, __be16 protocol,
+static int dsa_slave_setup_tc(struct net_device *dev, enum tc_setup_type type,
+			      u32 handle, u32 chain_index, __be16 protocol,
 			      struct tc_to_netdev *tc)
 {
 	bool ingress = TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS);
@@ -859,7 +859,7 @@ static int dsa_slave_setup_tc(struct net_device *dev, u32 handle,
 	if (chain_index)
 		return -EOPNOTSUPP;
 
-	switch (tc->type) {
+	switch (type) {
 	case TC_SETUP_MATCHALL:
 		switch (tc->cls_mall->command) {
 		case TC_CLSMATCHALL_REPLACE:
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index cf248c3..e2bf275 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -151,7 +151,6 @@ static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 	struct tc_to_netdev offload;
 	int err;
 
-	offload.type = TC_SETUP_CLSBPF;
 	offload.cls_bpf = &bpf_offload;
 
 	bpf_offload.command = cmd;
@@ -161,7 +160,8 @@ static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 	bpf_offload.exts_integrated = prog->exts_integrated;
 	bpf_offload.gen_flags = prog->gen_flags;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSBPF,
+					    tp->q->handle,
 					    tp->chain->index,
 					    tp->protocol, &offload);
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 7ab524f..ddeed17 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -236,11 +236,10 @@ static void fl_hw_destroy_filter(struct tcf_proto *tp, struct cls_fl_filter *f)
 	offload.prio = tp->prio;
 	offload.cookie = (unsigned long)f;
 
-	tc->type = TC_SETUP_CLSFLOWER;
 	tc->cls_flower = &offload;
 
-	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->chain->index,
-				      tp->protocol, tc);
+	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER, tp->q->handle,
+				      tp->chain->index, tp->protocol, tc);
 }
 
 static int fl_hw_replace_filter(struct tcf_proto *tp,
@@ -273,11 +272,11 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 	offload.key = &f->mkey;
 	offload.exts = &f->exts;
 
-	tc->type = TC_SETUP_CLSFLOWER;
 	tc->cls_flower = &offload;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
-					    tp->chain->index, tp->protocol, tc);
+	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSFLOWER,
+					    tp->q->handle, tp->chain->index,
+					    tp->protocol, tc);
 	if (!err)
 		f->flags |= TCA_CLS_FLAGS_IN_HW;
 
@@ -300,10 +299,9 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 	offload.cookie = (unsigned long)f;
 	offload.exts = &f->exts;
 
-	tc->type = TC_SETUP_CLSFLOWER;
 	tc->cls_flower = &offload;
 
-	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+	dev->netdev_ops->ndo_setup_tc(dev, TC_CLSFLOWER_STATS, tp->q->handle,
 				      tp->chain->index, tp->protocol, tc);
 }
 
diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index f35177b..6ffe0b8 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -58,14 +58,13 @@ static int mall_replace_hw_filter(struct tcf_proto *tp,
 	struct tc_cls_matchall_offload mall_offload = {0};
 	int err;
 
-	offload.type = TC_SETUP_MATCHALL;
 	offload.cls_mall = &mall_offload;
 	offload.cls_mall->command = TC_CLSMATCHALL_REPLACE;
 	offload.cls_mall->exts = &head->exts;
 	offload.cls_mall->cookie = cookie;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
-					    tp->chain->index,
+	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_MATCHALL,
+					    tp->q->handle, tp->chain->index,
 					    tp->protocol, &offload);
 	if (!err)
 		head->flags |= TCA_CLS_FLAGS_IN_HW;
@@ -81,14 +80,13 @@ static void mall_destroy_hw_filter(struct tcf_proto *tp,
 	struct tc_to_netdev offload;
 	struct tc_cls_matchall_offload mall_offload = {0};
 
-	offload.type = TC_SETUP_MATCHALL;
 	offload.cls_mall = &mall_offload;
 	offload.cls_mall->command = TC_CLSMATCHALL_DESTROY;
 	offload.cls_mall->exts = NULL;
 	offload.cls_mall->cookie = cookie;
 
-	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->chain->index,
-				      tp->protocol, &offload);
+	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_MATCHALL, tp->q->handle,
+				      tp->chain->index, tp->protocol, &offload);
 }
 
 static void mall_destroy(struct tcf_proto *tp)
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 9fd2437..d1bae4c 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -434,15 +434,14 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 	struct tc_cls_u32_offload u32_offload = {0};
 	struct tc_to_netdev offload;
 
-	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
 	if (tc_should_offload(dev, tp, 0)) {
 		offload.cls_u32->command = TC_CLSU32_DELETE_KNODE;
 		offload.cls_u32->knode.handle = handle;
-		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
-					      tp->chain->index, tp->protocol,
-					      &offload);
+		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32,
+					      tp->q->handle, tp->chain->index,
+					      tp->protocol, &offload);
 	}
 }
 
@@ -457,7 +456,6 @@ static int u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h,
 	if (!tc_should_offload(dev, tp, flags))
 		return tc_skip_sw(flags) ? -EINVAL : 0;
 
-	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
 	offload.cls_u32->command = TC_CLSU32_NEW_HNODE;
@@ -465,7 +463,7 @@ static int u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h,
 	offload.cls_u32->hnode.handle = h->handle;
 	offload.cls_u32->hnode.prio = h->prio;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, tp->q->handle,
 					    tp->chain->index, tp->protocol,
 					    &offload);
 	if (tc_skip_sw(flags))
@@ -480,7 +478,6 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 	struct tc_cls_u32_offload u32_offload = {0};
 	struct tc_to_netdev offload;
 
-	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
 	if (tc_should_offload(dev, tp, 0)) {
@@ -489,9 +486,9 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 		offload.cls_u32->hnode.handle = h->handle;
 		offload.cls_u32->hnode.prio = h->prio;
 
-		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
-					      tp->chain->index, tp->protocol,
-					      &offload);
+		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32,
+					      tp->q->handle, tp->chain->index,
+					      tp->protocol, &offload);
 	}
 }
 
@@ -503,7 +500,6 @@ static int u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n,
 	struct tc_to_netdev offload;
 	int err;
 
-	offload.type = TC_SETUP_CLSU32;
 	offload.cls_u32 = &u32_offload;
 
 	if (!tc_should_offload(dev, tp, flags))
@@ -524,7 +520,7 @@ static int u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n,
 	if (n->ht_down)
 		offload.cls_u32->knode.link_handle = n->ht_down->handle;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSU32, tp->q->handle,
 					    tp->chain->index, tp->protocol,
 					    &offload);
 
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index e0c0272..329610c 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -40,10 +40,10 @@ static void mqprio_destroy(struct Qdisc *sch)
 
 	if (priv->hw_offload && dev->netdev_ops->ndo_setup_tc) {
 		struct tc_mqprio_qopt offload = { 0 };
-		struct tc_to_netdev tc = { .type = TC_SETUP_MQPRIO,
-					   { .mqprio = &offload } };
+		struct tc_to_netdev tc = { { .mqprio = &offload } };
 
-		dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0, 0, &tc);
+		dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_MQPRIO,
+					      sch->handle, 0, 0, &tc);
 	} else {
 		netdev_set_num_tc(dev, 0);
 	}
@@ -149,11 +149,10 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 	 */
 	if (qopt->hw) {
 		struct tc_mqprio_qopt offload = *qopt;
-		struct tc_to_netdev tc = { .type = TC_SETUP_MQPRIO,
-					   { .mqprio = &offload } };
+		struct tc_to_netdev tc = { { .mqprio = &offload } };
 
-		err = dev->netdev_ops->ndo_setup_tc(dev, sch->handle,
-						    0, 0, &tc);
+		err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_MQPRIO,
+						    sch->handle, 0, 0, &tc);
 		if (err)
 			return err;
 
-- 
2.9.3
