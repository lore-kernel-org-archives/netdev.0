From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH 2/2] mqprio: Modify mqprio to pass user parameters
 via ndo_setup_tc.
Date: Wed, 15 Mar 2017 10:39:25 -0700
Message-ID: <20170315173924.16349.41751.stgit@localhost.localdomain>
References: <20170315172929.16349.95037.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: thomas.lendacky@amd.com, bkenward@solarflare.com,
        amritha.nambiar@intel.com, madalin.bucur@nxp.com, w-kwok2@ti.com,
        saeedm@mellanox.com, ariel.elior@cavium.com, m-karicheri2@ti.com,
        jeffrey.t.kirsher@intel.com, Yuval.Mintz@cavium.com,
        ecree@solarflare.com, michael.chan@broadcom.com,
        tariqt@mellanox.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36679 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751480AbdCOSLH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 14:11:07 -0400
Received: by mail-pg0-f68.google.com with SMTP id m5so3059712pgk.3
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 11:11:06 -0700 (PDT)
In-Reply-To: <20170315172929.16349.95037.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amritha Nambiar <amritha.nambiar@intel.com>

The configurable priority to traffic class mapping and the user specified
queue ranges are used to configure the traffic class, overriding the
hardware defaults when the 'hw' option is set to 0. However, when the 'hw'
option is non-zero, the hardware QOS defaults are used.

This patch makes it so that we can pass the data the user provided to
ndo_setup_tc. This allows us to pull in the queue configuration if the
user requested it as well as any additional hardware offload type
requested by using a value other than 1 for the hw value.

Finally it also provides a means for the device driver to return the level
supported for the offload type via the qopt->hw value. Previously we were
just always assuming the value to be 1, in the future values beyond just 1
may be supported.

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c          |    3 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c   |    5 ++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |    4 +++-
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c    |   16 ++++++++++------
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c   |    4 +++-
 drivers/net/ethernet/intel/i40e/i40e_main.c       |    7 +++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    4 +++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |    4 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    4 +++-
 drivers/net/ethernet/sfc/falcon/tx.c              |    4 +++-
 drivers/net/ethernet/sfc/tx.c                     |    4 +++-
 drivers/net/ethernet/ti/netcp_core.c              |   12 ++++++++----
 include/linux/netdevice.h                         |    2 +-
 net/sched/sch_mqprio.c                            |   17 +++++++++++------
 14 files changed, 62 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 248f60d171a5..983dd3026c7a 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1854,7 +1854,8 @@ static int xgbe_setup_tc(struct net_device *netdev, u32 handle, __be16 proto,
 	if (tc_to_netdev->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
-	tc = tc_to_netdev->tc;
+	tc_to_netdev->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+	tc = tc_to_netdev->mqprio->num_tc;
 
 	if (tc > pdata->hw_feat.tc_cnt)
 		return -EINVAL;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 9e8c06130c09..ad3e0631877e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -4277,7 +4277,10 @@ int __bnx2x_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 {
 	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
-	return bnx2x_setup_tc(dev, tc->tc);
+
+	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+
+	return bnx2x_setup_tc(dev, tc->mqprio->num_tc);
 }
 
 /* called with rtnl_lock */
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 235733e91c79..5e2515c6aee4 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6894,7 +6894,9 @@ static int bnxt_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 	if (ntc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
-	return bnxt_setup_mq_tc(dev, ntc->tc);
+	ntc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+
+	return bnxt_setup_mq_tc(dev, ntc->mqprio->num_tc);
 }
 
 #ifdef CONFIG_RFS_ACCEL
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index aa769cbc7425..d4bb8bf86a45 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -346,33 +346,37 @@ static int dpaa_setup_tc(struct net_device *net_dev, u32 handle, __be16 proto,
 			 struct tc_to_netdev *tc)
 {
 	struct dpaa_priv *priv = netdev_priv(net_dev);
+	u8 num_tc;
 	int i;
 
 	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
-	if (tc->tc == priv->num_tc)
+	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+	num_tc = tc->mqprio->num_tc;
+
+	if (num_tc == priv->num_tc)
 		return 0;
 
-	if (!tc->tc) {
+	if (!num_tc) {
 		netdev_reset_tc(net_dev);
 		goto out;
 	}
 
-	if (tc->tc > DPAA_TC_NUM) {
+	if (num_tc > DPAA_TC_NUM) {
 		netdev_err(net_dev, "Too many traffic classes: max %d supported.\n",
 			   DPAA_TC_NUM);
 		return -EINVAL;
 	}
 
-	netdev_set_num_tc(net_dev, tc->tc);
+	netdev_set_num_tc(net_dev, num_tc);
 
-	for (i = 0; i < tc->tc; i++)
+	for (i = 0; i < num_tc; i++)
 		netdev_set_tc_queue(net_dev, i, DPAA_TC_TXQ_NUM,
 				    i * DPAA_TC_TXQ_NUM);
 
 out:
-	priv->num_tc = tc->tc ? tc->tc : 1;
+	priv->num_tc = num_tc ? : 1;
 	netif_set_real_num_tx_queues(net_dev, priv->num_tc * DPAA_TC_TXQ_NUM);
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 01db688cf539..72481670478c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1226,7 +1226,9 @@ static int __fm10k_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
-	return fm10k_setup_tc(dev, tc->tc);
+	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+
+	return fm10k_setup_tc(dev, tc->mqprio->num_tc);
 }
 
 static void fm10k_assign_l2_accel(struct fm10k_intfc *interface,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index e8a8351c8ea9..a0f364343423 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5612,9 +5612,12 @@ static int __i40e_setup_tc(struct net_device *netdev, u32 handle, __be16 proto,
 			   struct tc_to_netdev *tc)
 #endif
 {
-	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
+	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
-	return i40e_setup_tc(netdev, tc->tc);
+
+	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+
+	return i40e_setup_tc(netdev, tc->mqprio->num_tc);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a7a430a7be2c..d45477db0227 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8948,7 +8948,9 @@ static int __ixgbe_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
-	return ixgbe_setup_tc(dev, tc->tc);
+	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+
+	return ixgbe_setup_tc(dev, tc->mqprio->num_tc);
 }
 
 #ifdef CONFIG_PCI_IOV
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 61420473fe5f..94fab20ef146 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -92,7 +92,9 @@ static int __mlx4_en_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
-	return mlx4_en_setup_tc(dev, tc->tc);
+	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+
+	return mlx4_en_setup_tc(dev, tc->mqprio->num_tc);
 }
 
 #ifdef CONFIG_RFS_ACCEL
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 8ef64c4db2c2..f96a73ea8e0b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2737,7 +2737,9 @@ static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
 	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
-	return mlx5e_setup_tc(dev, tc->tc);
+	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+
+	return mlx5e_setup_tc(dev, tc->mqprio->num_tc);
 }
 
 static void
diff --git a/drivers/net/ethernet/sfc/falcon/tx.c b/drivers/net/ethernet/sfc/falcon/tx.c
index 104fb15a73f2..f6daf09b8627 100644
--- a/drivers/net/ethernet/sfc/falcon/tx.c
+++ b/drivers/net/ethernet/sfc/falcon/tx.c
@@ -437,11 +437,13 @@ int ef4_setup_tc(struct net_device *net_dev, u32 handle, __be16 proto,
 	if (ntc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
-	num_tc = ntc->tc;
+	num_tc = ntc->mqprio->num_tc;
 
 	if (ef4_nic_rev(efx) < EF4_REV_FALCON_B0 || num_tc > EF4_MAX_TX_TC)
 		return -EINVAL;
 
+	ntc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+
 	if (num_tc == net_dev->num_tc)
 		return 0;
 
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index ff88d60aa6d5..3bdf87f31087 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -665,11 +665,13 @@ int efx_setup_tc(struct net_device *net_dev, u32 handle, __be16 proto,
 	if (ntc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
-	num_tc = ntc->tc;
+	num_tc = ntc->mqprio->num_tc;
 
 	if (num_tc > EFX_MAX_TX_TC)
 		return -EINVAL;
 
+	ntc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+
 	if (num_tc == net_dev->num_tc)
 		return 0;
 
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 7c7ae0890e90..9027c9c509b5 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1882,6 +1882,7 @@ static u16 netcp_select_queue(struct net_device *dev, struct sk_buff *skb,
 static int netcp_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 			  struct tc_to_netdev *tc)
 {
+	u8 num_tc;
 	int i;
 
 	/* setup tc must be called under rtnl lock */
@@ -1890,15 +1891,18 @@ static int netcp_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
+	tc->mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
+	num_tc = tc->mqprio->num_tc;
+
 	/* Sanity-check the number of traffic classes requested */
 	if ((dev->real_num_tx_queues <= 1) ||
-	    (dev->real_num_tx_queues < tc->tc))
+	    (dev->real_num_tx_queues < num_tc))
 		return -EINVAL;
 
 	/* Configure traffic class to queue mappings */
-	if (tc->tc) {
-		netdev_set_num_tc(dev, tc->tc);
-		for (i = 0; i < tc->tc; i++)
+	if (num_tc) {
+		netdev_set_num_tc(dev, num_tc);
+		for (i = 0; i < num_tc; i++)
 			netdev_set_tc_queue(dev, i, 1, i);
 	} else {
 		netdev_reset_tc(dev);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 97456b2539e4..b7365b587818 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -786,11 +786,11 @@ enum {
 struct tc_to_netdev {
 	unsigned int type;
 	union {
-		u8 tc;
 		struct tc_cls_u32_offload *cls_u32;
 		struct tc_cls_flower_offload *cls_flower;
 		struct tc_cls_matchall_offload *cls_mall;
 		struct tc_cls_bpf_offload *cls_bpf;
+		struct tc_mqprio_qopt *mqprio;
 	};
 	bool egress_dev;
 };
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 5f55bf149d9f..0a4cf27ea54b 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -28,7 +28,6 @@ static void mqprio_destroy(struct Qdisc *sch)
 {
 	struct net_device *dev = qdisc_dev(sch);
 	struct mqprio_sched *priv = qdisc_priv(sch);
-	struct tc_to_netdev tc = {.type = TC_SETUP_MQPRIO};
 	unsigned int ntx;
 
 	if (priv->qdiscs) {
@@ -39,10 +38,15 @@ static void mqprio_destroy(struct Qdisc *sch)
 		kfree(priv->qdiscs);
 	}
 
-	if (priv->hw_offload && dev->netdev_ops->ndo_setup_tc)
+	if (priv->hw_offload && dev->netdev_ops->ndo_setup_tc) {
+		struct tc_mqprio_qopt offload = { 0 };
+		struct tc_to_netdev tc = { .type = TC_SETUP_MQPRIO,
+					   { .mqprio = &offload } };
+
 		dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0, &tc);
-	else
+	} else {
 		netdev_set_num_tc(dev, 0);
+	}
 }
 
 static int mqprio_parse_opt(struct net_device *dev, struct tc_mqprio_qopt *qopt)
@@ -144,14 +148,15 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 	 * supplied and verified mapping
 	 */
 	if (qopt->hw) {
-		struct tc_to_netdev tc = {.type = TC_SETUP_MQPRIO,
-					  { .tc = qopt->num_tc }};
+		struct tc_mqprio_qopt offload = *qopt;
+		struct tc_to_netdev tc = { .type = TC_SETUP_MQPRIO,
+					   { .mqprio = &offload } };
 
 		err = dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0, &tc);
 		if (err)
 			return err;
 
-		priv->hw_offload = qopt->hw;
+		priv->hw_offload = offload.hw;
 	} else {
 		netdev_set_num_tc(dev, qopt->num_tc);
 		for (i = 0; i < qopt->num_tc; i++)
