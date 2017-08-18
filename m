From: Chris Mi <chrism@mellanox.com>
Subject: [patch net-next] net/sched: Fix the logic error to decide the ingress qdisc
Date: Fri, 18 Aug 2017 07:24:20 -0400
Message-ID: <1503055460-36795-1-git-send-email-chrism@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59401 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750846AbdHRLYm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 07:24:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The offending commit used a newly added helper function.
But the logic is wrong. Without this fix, the affected NICs
can't do HW offload. Error -EOPNOTSUPP will be returned directly.

Fixes: a2e8da9378cc ("net/sched: use newly added classid identity helpers")
Signed-off-by: Chris Mi <chrism@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c       | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c   | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c    | 2 +-
 drivers/net/ethernet/netronome/nfp/bpf/main.c       | 2 +-
 drivers/net/ethernet/netronome/nfp/flower/offload.c | 2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 77538cd..e55a929 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2892,7 +2892,7 @@ static int cxgb_set_tx_maxrate(struct net_device *dev, int index, u32 rate)
 static int cxgb_setup_tc_cls_u32(struct net_device *dev,
 				 struct tc_cls_u32_offload *cls_u32)
 {
-	if (is_classid_clsact_ingress(cls_u32->common.classid) ||
+	if (!is_classid_clsact_ingress(cls_u32->common.classid) ||
 	    cls_u32->common.chain_index)
 		return -EOPNOTSUPP;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index f9fd8d8..56d7ef0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9230,7 +9230,7 @@ static int ixgbe_setup_tc_cls_u32(struct net_device *dev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 
-	if (is_classid_clsact_ingress(cls_u32->common.classid) ||
+	if (!is_classid_clsact_ingress(cls_u32->common.classid) ||
 	    cls_u32->common.chain_index)
 		return -EOPNOTSUPP;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 8633ca5..2fc3832 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3031,7 +3031,7 @@ static int mlx5e_setup_tc_cls_flower(struct net_device *dev,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
-	if (is_classid_clsact_ingress(cls_flower->common.classid) ||
+	if (!is_classid_clsact_ingress(cls_flower->common.classid) ||
 	    cls_flower->common.chain_index)
 		return -EOPNOTSUPP;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index f34c00f..7a9f53f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -657,7 +657,7 @@ static int mlx5e_rep_get_phys_port_name(struct net_device *dev,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
-	if (is_classid_clsact_ingress(cls_flower->common.classid) ||
+	if (!is_classid_clsact_ingress(cls_flower->common.classid) ||
 	    cls_flower->common.chain_index)
 		return -EOPNOTSUPP;
 
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index 0e68649..f4de3a7 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -127,7 +127,7 @@ static int nfp_bpf_setup_tc(struct nfp_app *app, struct net_device *netdev,
 	struct nfp_net *nn = netdev_priv(netdev);
 
 	if (type != TC_SETUP_CLSBPF || !nfp_net_ebpf_capable(nn) ||
-	    is_classid_clsact_ingress(cls_bpf->common.classid) ||
+	    !is_classid_clsact_ingress(cls_bpf->common.classid) ||
 	    cls_bpf->common.protocol != htons(ETH_P_ALL) ||
 	    cls_bpf->common.chain_index)
 		return -EOPNOTSUPP;
diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index 3ad5aaa..d868a57 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -390,7 +390,7 @@ int nfp_flower_setup_tc(struct nfp_app *app, struct net_device *netdev,
 	struct tc_cls_flower_offload *cls_flower = type_data;
 
 	if (type != TC_SETUP_CLSFLOWER ||
-	    is_classid_clsact_ingress(cls_flower->common.classid) ||
+	    !is_classid_clsact_ingress(cls_flower->common.classid) ||
 	    !eth_proto_is_802_3(cls_flower->common.protocol) ||
 	    cls_flower->common.chain_index)
 		return -EOPNOTSUPP;
-- 
1.8.3.1
