From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: propagate tc filter chain index down the ndo_setup_tc call
Date: Tue,  6 Jun 2017 17:00:16 +0200
Message-ID: <20170606150016.2419-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34402 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751390AbdFFPAU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 11:00:20 -0400
Received: by mail-wm0-f67.google.com with SMTP id 70so10793713wme.1
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 08:00:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

We need to push the chain index down to the drivers, so they have the
information to which chain the rule belongs. For now, no driver supports
multichain offload, so only chain 0 is supported. This is needed to
prevent chain squashes during offload for now. Later this will be used
to implement multichain offload.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c            |  3 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     |  4 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h     |  4 ++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.c           |  4 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     |  7 +++++--
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c      |  4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c     |  4 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c         |  3 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c       |  7 +++++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c      |  3 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c   |  6 +++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c    |  7 ++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c      |  6 +++++-
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c |  7 +++++--
 drivers/net/ethernet/sfc/efx.h                      |  4 ++--
 drivers/net/ethernet/sfc/falcon/efx.h               |  4 ++--
 drivers/net/ethernet/sfc/falcon/tx.c                |  4 ++--
 drivers/net/ethernet/sfc/tx.c                       |  4 ++--
 drivers/net/ethernet/ti/netcp_core.c                |  4 ++--
 include/linux/netdevice.h                           |  4 ++--
 net/dsa/slave.c                                     | 11 ++++++-----
 net/sched/cls_bpf.c                                 |  1 +
 net/sched/cls_flower.c                              | 10 ++++++----
 net/sched/cls_matchall.c                            |  9 +++++----
 net/sched/cls_u32.c                                 | 12 ++++++++----
 net/sched/sch_mqprio.c                              |  5 +++--
 26 files changed, 88 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 5a2ad9c..a934bd5 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1846,7 +1846,8 @@ static void xgbe_poll_controller(struct net_device *netdev)
 }
 #endif /* End CONFIG_NET_POLL_CONTROLLER */
 
-static int xgbe_setup_tc(struct net_device *netdev, u32 handle, __be16 proto,
+static int xgbe_setup_tc(struct net_device *netdev, u32 handle, u32 chain_index,
+			 __be16 proto,
 			 struct tc_to_netdev *tc_to_netdev)
 {
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index eccb3d1..b92e2ca 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -4273,8 +4273,8 @@ int bnx2x_setup_tc(struct net_device *dev, u8 num_tc)
 	return 0;
 }
 
-int __bnx2x_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
-		     struct tc_to_netdev *tc)
+int __bnx2x_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
+		     __be16 proto, struct tc_to_netdev *tc)
 {
 	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 243cb97..c26688d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -486,8 +486,8 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev);
 
 /* setup_tc callback */
 int bnx2x_setup_tc(struct net_device *dev, u8 num_tc);
-int __bnx2x_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
-		     struct tc_to_netdev *tc);
+int __bnx2x_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
+		     __be16 proto, struct tc_to_netdev *tc);
 
 int bnx2x_get_vf_config(struct net_device *dev, int vf,
 			struct ifla_vf_info *ivi);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c1cd72a..11e8a86 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7103,8 +7103,8 @@ int bnxt_setup_mq_tc(struct net_device *dev, u8 tc)
 	return 0;
 }
 
-static int bnxt_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
-			 struct tc_to_netdev *ntc)
+static int bnxt_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
+			 __be16 proto, struct tc_to_netdev *ntc)
 {
 	if (ntc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 8c69046..c3902c5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2698,12 +2698,15 @@ static int cxgb_set_tx_maxrate(struct net_device *dev, int index, u32 rate)
 	return err;
 }
 
-static int cxgb_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
-			 struct tc_to_netdev *tc)
+static int cxgb_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
+			 __be16 proto, struct tc_to_netdev *tc)
 {
 	struct port_info *pi = netdev2pinfo(dev);
 	struct adapter *adap = netdev2adap(dev);
 
+	if (chain_index)
+		return -EOPNOTSUPP;
+
 	if (!(adap->flags & FULL_INIT_DONE)) {
 		dev_err(adap->pdev_dev,
 			"Failed to setup tc on port %d. Link Down?\n",
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 9a520e4..a5501af 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -342,8 +342,8 @@ static void dpaa_get_stats64(struct net_device *net_dev,
 	}
 }
 
-static int dpaa_setup_tc(struct net_device *net_dev, u32 handle, __be16 proto,
-			 struct tc_to_netdev *tc)
+static int dpaa_setup_tc(struct net_device *net_dev, u32 handle,
+			 u32 chain_index, __be16 proto, struct tc_to_netdev *tc)
 {
 	struct dpaa_priv *priv = netdev_priv(net_dev);
 	u8 num_tc;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 24f2f6f..5e37387 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1265,8 +1265,8 @@ int fm10k_setup_tc(struct net_device *dev, u8 tc)
 	return err;
 }
 
-static int __fm10k_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
-			    struct tc_to_netdev *tc)
+static int __fm10k_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
+			    __be16 proto, struct tc_to_netdev *tc)
 {
 	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e4eb978..be808c9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5509,7 +5509,8 @@ static int i40e_setup_tc(struct net_device *netdev, u8 tc)
 	return ret;
 }
 
-static int __i40e_setup_tc(struct net_device *netdev, u32 handle, __be16 proto,
+static int __i40e_setup_tc(struct net_device *netdev, u32 handle,
+			   u32 chain_index, __be16 proto,
 			   struct tc_to_netdev *tc)
 {
 	if (tc->type != TC_SETUP_MQPRIO)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 54463f0..812319a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9200,11 +9200,14 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 	return err;
 }
 
-static int __ixgbe_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
-			    struct tc_to_netdev *tc)
+static int __ixgbe_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
+			    __be16 proto, struct tc_to_netdev *tc)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 
+	if (chain_index)
+		return -EOPNOTSUPP;
+
 	if (TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS) &&
 	    tc->type == TC_SETUP_CLSU32) {
 		switch (tc->cls_u32->command) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 8243674..c1de75f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -86,7 +86,8 @@ int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 	return 0;
 }
 
-static int __mlx4_en_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
+static int __mlx4_en_setup_tc(struct net_device *dev, u32 handle,
+			      u32 chain_index, __be16 proto,
 			      struct tc_to_netdev *tc)
 {
 	if (tc->type != TC_SETUP_MQPRIO)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index cdff04b..5afec0f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2991,13 +2991,17 @@ static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
 }
 
 static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
-			      __be16 proto, struct tc_to_netdev *tc)
+			      u32 chain_index, __be16 proto,
+			      struct tc_to_netdev *tc)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
 	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
 		goto mqprio;
 
+	if (chain_index)
+		return -EOPNOTSUPP;
+
 	switch (tc->type) {
 	case TC_SETUP_CLSFLOWER:
 		switch (tc->cls_flower->command) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 79462c0..70c2b8d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -652,7 +652,8 @@ static int mlx5e_rep_get_phys_port_name(struct net_device *dev,
 }
 
 static int mlx5e_rep_ndo_setup_tc(struct net_device *dev, u32 handle,
-				  __be16 proto, struct tc_to_netdev *tc)
+				  u32 chain_index, __be16 proto,
+				  struct tc_to_netdev *tc)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
@@ -664,9 +665,13 @@ static int mlx5e_rep_ndo_setup_tc(struct net_device *dev, u32 handle,
 		struct net_device *uplink_dev = mlx5_eswitch_get_uplink_netdev(esw);
 
 		return uplink_dev->netdev_ops->ndo_setup_tc(uplink_dev, handle,
+							    chain_index,
 							    proto, tc);
 	}
 
+	if (chain_index)
+		return -EOPNOTSUPP;
+
 	switch (tc->type) {
 	case TC_SETUP_CLSFLOWER:
 		switch (tc->cls_flower->command) {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index f60e2ba..a2316d0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1699,11 +1699,15 @@ static void mlxsw_sp_port_del_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 }
 
 static int mlxsw_sp_setup_tc(struct net_device *dev, u32 handle,
-			     __be16 proto, struct tc_to_netdev *tc)
+			     u32 chain_index, __be16 proto,
+			     struct tc_to_netdev *tc)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 	bool ingress = TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS);
 
+	if (chain_index)
+		return -EOPNOTSUPP;
+
 	switch (tc->type) {
 	case TC_SETUP_MATCHALL:
 		switch (tc->cls_mall->command) {
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index c3235d0..1ae7a63 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2682,11 +2682,14 @@ static void nfp_net_stat64(struct net_device *netdev,
 }
 
 static int
-nfp_net_setup_tc(struct net_device *netdev, u32 handle, __be16 proto,
-		 struct tc_to_netdev *tc)
+nfp_net_setup_tc(struct net_device *netdev, u32 handle, u32 chain_index,
+		 __be16 proto, struct tc_to_netdev *tc)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 
+	if (chain_index)
+		return -EOPNOTSUPP;
+
 	return nfp_app_setup_tc(nn->app, netdev, handle, proto, tc);
 }
 
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index a0c52e3..fcea937 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -32,8 +32,8 @@ netdev_tx_t efx_hard_start_xmit(struct sk_buff *skb,
 				struct net_device *net_dev);
 netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb);
 void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
-int efx_setup_tc(struct net_device *net_dev, u32 handle, __be16 proto,
-		 struct tc_to_netdev *tc);
+int efx_setup_tc(struct net_device *net_dev, u32 handle, u32 chain_index,
+		 __be16 proto, struct tc_to_netdev *tc);
 unsigned int efx_tx_max_skb_descs(struct efx_nic *efx);
 extern unsigned int efx_piobuf_size;
 extern bool efx_separate_tx_channels;
diff --git a/drivers/net/ethernet/sfc/falcon/efx.h b/drivers/net/ethernet/sfc/falcon/efx.h
index c89456f..e5a7a40 100644
--- a/drivers/net/ethernet/sfc/falcon/efx.h
+++ b/drivers/net/ethernet/sfc/falcon/efx.h
@@ -32,8 +32,8 @@ netdev_tx_t ef4_hard_start_xmit(struct sk_buff *skb,
 				struct net_device *net_dev);
 netdev_tx_t ef4_enqueue_skb(struct ef4_tx_queue *tx_queue, struct sk_buff *skb);
 void ef4_xmit_done(struct ef4_tx_queue *tx_queue, unsigned int index);
-int ef4_setup_tc(struct net_device *net_dev, u32 handle, __be16 proto,
-		 struct tc_to_netdev *tc);
+int ef4_setup_tc(struct net_device *net_dev, u32 handle, u32 chain_index,
+		 __be16 proto, struct tc_to_netdev *tc);
 unsigned int ef4_tx_max_skb_descs(struct ef4_nic *efx);
 extern bool ef4_separate_tx_channels;
 
diff --git a/drivers/net/ethernet/sfc/falcon/tx.c b/drivers/net/ethernet/sfc/falcon/tx.c
index f6daf09..f1520a4 100644
--- a/drivers/net/ethernet/sfc/falcon/tx.c
+++ b/drivers/net/ethernet/sfc/falcon/tx.c
@@ -425,8 +425,8 @@ void ef4_init_tx_queue_core_txq(struct ef4_tx_queue *tx_queue)
 				     efx->n_tx_channels : 0));
 }
 
-int ef4_setup_tc(struct net_device *net_dev, u32 handle, __be16 proto,
-		 struct tc_to_netdev *ntc)
+int ef4_setup_tc(struct net_device *net_dev, u32 handle, u32 chain_index,
+		 __be16 proto, struct tc_to_netdev *ntc)
 {
 	struct ef4_nic *efx = netdev_priv(net_dev);
 	struct ef4_channel *channel;
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 3bdf87f..02d41eb 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -653,8 +653,8 @@ void efx_init_tx_queue_core_txq(struct efx_tx_queue *tx_queue)
 				     efx->n_tx_channels : 0));
 }
 
-int efx_setup_tc(struct net_device *net_dev, u32 handle, __be16 proto,
-		 struct tc_to_netdev *ntc)
+int efx_setup_tc(struct net_device *net_dev, u32 handle, u32 chain_index,
+		 __be16 proto, struct tc_to_netdev *ntc)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_channel *channel;
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index e6222e5..9d52c3a 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1877,8 +1877,8 @@ static u16 netcp_select_queue(struct net_device *dev, struct sk_buff *skb,
 	return 0;
 }
 
-static int netcp_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
-			  struct tc_to_netdev *tc)
+static int netcp_setup_tc(struct net_device *dev, u32 handle, u32 chain_index,
+			  __be16 proto, struct tc_to_netdev *tc)
 {
 	u8 num_tc;
 	int i;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c50c921..524c777 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -972,7 +972,7 @@ struct xfrmdev_ops {
  *      with PF and querying it may introduce a theoretical security risk.
  * int (*ndo_set_vf_rss_query_en)(struct net_device *dev, int vf, bool setting);
  * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_buff *skb);
- * int (*ndo_setup_tc)(struct net_device *dev, u32 handle,
+ * int (*ndo_setup_tc)(struct net_device *dev, u32 handle, u32 chain_index,
  *		       __be16 protocol, struct tc_to_netdev *tc);
  *	Called to setup any 'tc' scheduler, classifier or action on @dev.
  *	This is always called from the stack with the rtnl lock held and netif
@@ -1222,7 +1222,7 @@ struct net_device_ops {
 						   struct net_device *dev,
 						   int vf, bool setting);
 	int			(*ndo_setup_tc)(struct net_device *dev,
-						u32 handle,
+						u32 handle, u32 chain_index,
 						__be16 protocol,
 						struct tc_to_netdev *tc);
 #if IS_ENABLED(CONFIG_FCOE)
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 1cfdb31..5f3caee 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -836,10 +836,13 @@ static void dsa_slave_del_cls_matchall(struct net_device *dev,
 }
 
 static int dsa_slave_setup_tc(struct net_device *dev, u32 handle,
-			      __be16 protocol, struct tc_to_netdev *tc)
+			      u32 chain_index, __be16 protocol,
+			      struct tc_to_netdev *tc)
 {
 	bool ingress = TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS);
-	int ret = -EOPNOTSUPP;
+
+	if (chain_index)
+		return -EOPNOTSUPP;
 
 	switch (tc->type) {
 	case TC_SETUP_MATCHALL:
@@ -853,10 +856,8 @@ static int dsa_slave_setup_tc(struct net_device *dev, u32 handle,
 			return 0;
 		}
 	default:
-		break;
+		return -EOPNOTSUPP;
 	}
-
-	return ret;
 }
 
 void dsa_cpu_port_ethtool_init(struct ethtool_ops *ops)
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index a9c56ad..be0cfdf 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -162,6 +162,7 @@ static int cls_bpf_offload_cmd(struct tcf_proto *tp, struct cls_bpf_prog *prog,
 	bpf_offload.gen_flags = prog->gen_flags;
 
 	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+					    tp->chain->index,
 					    tp->protocol, &offload);
 
 	if (!err && (cmd == TC_CLSBPF_ADD || cmd == TC_CLSBPF_REPLACE))
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 33feaee..7832eb9 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -239,7 +239,8 @@ static void fl_hw_destroy_filter(struct tcf_proto *tp, struct cls_fl_filter *f)
 	tc->type = TC_SETUP_CLSFLOWER;
 	tc->cls_flower = &offload;
 
-	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol, tc);
+	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->chain->index,
+				      tp->protocol, tc);
 }
 
 static int fl_hw_replace_filter(struct tcf_proto *tp,
@@ -275,8 +276,8 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 	tc->type = TC_SETUP_CLSFLOWER;
 	tc->cls_flower = &offload;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol,
-					    tc);
+	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+					    tp->chain->index, tp->protocol, tc);
 	if (!err)
 		f->flags |= TCA_CLS_FLAGS_IN_HW;
 
@@ -302,7 +303,8 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 	tc->type = TC_SETUP_CLSFLOWER;
 	tc->cls_flower = &offload;
 
-	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol, tc);
+	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+				      tp->chain->index, tp->protocol, tc);
 }
 
 static void __fl_delete(struct tcf_proto *tp, struct cls_fl_filter *f)
diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index 51859b8..9dc26c3 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -64,8 +64,9 @@ static int mall_replace_hw_filter(struct tcf_proto *tp,
 	offload.cls_mall->exts = &head->exts;
 	offload.cls_mall->cookie = cookie;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol,
-					    &offload);
+	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
+					    tp->chain->index,
+					    tp->protocol, &offload);
 	if (!err)
 		head->flags |= TCA_CLS_FLAGS_IN_HW;
 
@@ -86,8 +87,8 @@ static void mall_destroy_hw_filter(struct tcf_proto *tp,
 	offload.cls_mall->exts = NULL;
 	offload.cls_mall->cookie = cookie;
 
-	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol,
-					     &offload);
+	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->chain->index,
+				      tp->protocol, &offload);
 }
 
 static void mall_destroy(struct tcf_proto *tp)
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index d20e72a..2d01195 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -441,7 +441,8 @@ static void u32_remove_hw_knode(struct tcf_proto *tp, u32 handle)
 		offload.cls_u32->command = TC_CLSU32_DELETE_KNODE;
 		offload.cls_u32->knode.handle = handle;
 		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
-					      tp->protocol, &offload);
+					      tp->chain->index, tp->protocol,
+					      &offload);
 	}
 }
 
@@ -465,7 +466,8 @@ static int u32_replace_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h,
 	offload.cls_u32->hnode.prio = h->prio;
 
 	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
-					    tp->protocol, &offload);
+					    tp->chain->index, tp->protocol,
+					    &offload);
 	if (tc_skip_sw(flags))
 		return err;
 
@@ -488,7 +490,8 @@ static void u32_clear_hw_hnode(struct tcf_proto *tp, struct tc_u_hnode *h)
 		offload.cls_u32->hnode.prio = h->prio;
 
 		dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
-					      tp->protocol, &offload);
+					      tp->chain->index, tp->protocol,
+					      &offload);
 	}
 }
 
@@ -522,7 +525,8 @@ static int u32_replace_hw_knode(struct tcf_proto *tp, struct tc_u_knode *n,
 		offload.cls_u32->knode.link_handle = n->ht_down->handle;
 
 	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle,
-					    tp->protocol, &offload);
+					    tp->chain->index, tp->protocol,
+					    &offload);
 
 	if (!err)
 		n->flags |= TCA_CLS_FLAGS_IN_HW;
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 0a4cf27..e0c0272 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -43,7 +43,7 @@ static void mqprio_destroy(struct Qdisc *sch)
 		struct tc_to_netdev tc = { .type = TC_SETUP_MQPRIO,
 					   { .mqprio = &offload } };
 
-		dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0, &tc);
+		dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0, 0, &tc);
 	} else {
 		netdev_set_num_tc(dev, 0);
 	}
@@ -152,7 +152,8 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 		struct tc_to_netdev tc = { .type = TC_SETUP_MQPRIO,
 					   { .mqprio = &offload } };
 
-		err = dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0, &tc);
+		err = dev->netdev_ops->ndo_setup_tc(dev, sch->handle,
+						    0, 0, &tc);
 		if (err)
 			return err;
 
-- 
2.9.3
