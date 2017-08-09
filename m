From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/5] net: sched: use newly added classid identity helpers
Date: Wed,  9 Aug 2017 14:30:33 +0200
Message-ID: <20170809123035.7663-4-jiri@resnulli.us>
References: <20170809123035.7663-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, oss-drivers@netronome.com,
        ganeshgr@chelsio.com, jeffrey.t.kirsher@intel.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:38817 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752741AbdHIMan (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 08:30:43 -0400
Received: by mail-wm0-f67.google.com with SMTP id y206so6601661wmd.5
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 05:30:43 -0700 (PDT)
In-Reply-To: <20170809123035.7663-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Instead of checking handle, which does not have the inner class
information and drivers wrongly assume clsact->egress as ingress, use
the newly introduced classid identification helpers.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c       |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c   |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c    |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c      | 18 ++++++++++++++++--
 drivers/net/ethernet/netronome/nfp/bpf/main.c       |  2 +-
 drivers/net/ethernet/netronome/nfp/flower/offload.c |  2 +-
 net/dsa/slave.c                                     |  9 ++++++++-
 8 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index d80b20d..afa6fd6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2892,7 +2892,7 @@ static int cxgb_set_tx_maxrate(struct net_device *dev, int index, u32 rate)
 static int cxgb_setup_tc_cls_u32(struct net_device *dev,
 				 struct tc_cls_u32_offload *cls_u32)
 {
-	if (TC_H_MAJ(cls_u32->common.handle) != TC_H_MAJ(TC_H_INGRESS) ||
+	if (is_classid_clsact_ingress(cls_u32->common.classid) ||
 	    cls_u32->common.chain_index)
 		return -EOPNOTSUPP;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c6b1324..f9fd8d8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9230,7 +9230,7 @@ static int ixgbe_setup_tc_cls_u32(struct net_device *dev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 
-	if (TC_H_MAJ(cls_u32->common.handle) != TC_H_MAJ(TC_H_INGRESS) ||
+	if (is_classid_clsact_ingress(cls_u32->common.classid) ||
 	    cls_u32->common.chain_index)
 		return -EOPNOTSUPP;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 981f841..8633ca5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3031,7 +3031,7 @@ static int mlx5e_setup_tc_cls_flower(struct net_device *dev,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
-	if (TC_H_MAJ(cls_flower->common.handle) != TC_H_MAJ(TC_H_INGRESS) ||
+	if (is_classid_clsact_ingress(cls_flower->common.classid) ||
 	    cls_flower->common.chain_index)
 		return -EOPNOTSUPP;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index f3c494a..f34c00f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -657,7 +657,7 @@ mlx5e_rep_setup_tc_cls_flower(struct net_device *dev,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
-	if (TC_H_MAJ(cls_flower->common.handle) != TC_H_MAJ(TC_H_INGRESS) ||
+	if (is_classid_clsact_ingress(cls_flower->common.classid) ||
 	    cls_flower->common.chain_index)
 		return -EOPNOTSUPP;
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index eb7c454..a996003 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1696,7 +1696,14 @@ static void mlxsw_sp_port_del_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 static int mlxsw_sp_setup_tc_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 					  struct tc_cls_matchall_offload *f)
 {
-	bool ingress = TC_H_MAJ(f->common.handle) == TC_H_MAJ(TC_H_INGRESS);
+	bool ingress;
+
+	if (is_classid_clsact_ingress(f->common.classid))
+		ingress = true;
+	else if (is_classid_clsact_egress(f->common.classid))
+		ingress = false;
+	else
+		return -EOPNOTSUPP;
 
 	if (f->common.chain_index)
 		return -EOPNOTSUPP;
@@ -1717,7 +1724,14 @@ static int
 mlxsw_sp_setup_tc_cls_flower(struct mlxsw_sp_port *mlxsw_sp_port,
 			     struct tc_cls_flower_offload *f)
 {
-	bool ingress = TC_H_MAJ(f->common.handle) == TC_H_MAJ(TC_H_INGRESS);
+	bool ingress;
+
+	if (is_classid_clsact_ingress(f->common.classid))
+		ingress = true;
+	else if (is_classid_clsact_egress(f->common.classid))
+		ingress = false;
+	else
+		return -EOPNOTSUPP;
 
 	if (f->common.chain_index)
 		return -EOPNOTSUPP;
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index f981f60..0e68649 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -127,7 +127,7 @@ static int nfp_bpf_setup_tc(struct nfp_app *app, struct net_device *netdev,
 	struct nfp_net *nn = netdev_priv(netdev);
 
 	if (type != TC_SETUP_CLSBPF || !nfp_net_ebpf_capable(nn) ||
-	    TC_H_MAJ(cls_bpf->common.handle) != TC_H_MAJ(TC_H_INGRESS) ||
+	    is_classid_clsact_ingress(cls_bpf->common.classid) ||
 	    cls_bpf->common.protocol != htons(ETH_P_ALL) ||
 	    cls_bpf->common.chain_index)
 		return -EOPNOTSUPP;
diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index 01767c7..3ad5aaa 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -390,7 +390,7 @@ int nfp_flower_setup_tc(struct nfp_app *app, struct net_device *netdev,
 	struct tc_cls_flower_offload *cls_flower = type_data;
 
 	if (type != TC_SETUP_CLSFLOWER ||
-	    TC_H_MAJ(cls_flower->common.handle) != TC_H_MAJ(TC_H_INGRESS) ||
+	    is_classid_clsact_ingress(cls_flower->common.classid) ||
 	    !eth_proto_is_802_3(cls_flower->common.protocol) ||
 	    cls_flower->common.chain_index)
 		return -EOPNOTSUPP;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 8c79011..78e78a6 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -914,7 +914,14 @@ static void dsa_slave_del_cls_matchall(struct net_device *dev,
 static int dsa_slave_setup_tc_cls_matchall(struct net_device *dev,
 					   struct tc_cls_matchall_offload *cls)
 {
-	bool ingress = TC_H_MAJ(cls->common.handle) == TC_H_MAJ(TC_H_INGRESS);
+	bool ingress;
+
+	if (is_classid_clsact_ingress(cls->common.classid))
+		ingress = true;
+	else if (is_classid_clsact_egress(cls->common.classid))
+		ingress = false;
+	else
+		return -EOPNOTSUPP;
 
 	if (cls->common.chain_index)
 		return -EOPNOTSUPP;
-- 
2.9.3
