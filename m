From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 2/7] net: rework setup_tc ndo op to consume general
 tc operand
Date: Wed, 03 Feb 2016 01:28:15 -0800
Message-ID: <20160203092815.1356.28318.stgit@john-Precision-Tower-5810>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: amir@vadai.me, ogerlitz@mellanox.com, jiri@resnulli.us,
	jhs@mojatatu.com, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33852 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752192AbcBCJ2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 04:28:33 -0500
Received: by mail-pa0-f43.google.com with SMTP id uo6so10866047pac.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 01:28:32 -0800 (PST)
In-Reply-To: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates setup_tc so we can pass additional parameters into
the ndo op in a generic way. To do this we provide structured union
and type flag.

This lets each classifier and qdisc provide its own set of attributes
without having to add new ndo ops or grow the signature of the
callback.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    7 ++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h |    3 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c       |    8 ++++++--
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |    7 ++++---
 drivers/net/ethernet/intel/i40e/i40e_main.c     |    7 ++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |    7 ++++---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    7 ++++---
 drivers/net/ethernet/sfc/efx.h                  |    3 ++-
 drivers/net/ethernet/sfc/tx.c                   |    9 ++++++---
 drivers/net/ethernet/ti/netcp_core.c            |   13 +++++++------
 include/linux/netdevice.h                       |   20 +++++++++++++++++++-
 net/sched/sch_mqprio.c                          |    9 ++++++---
 12 files changed, 68 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 1c7ff51..e925831 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -4272,11 +4272,12 @@ int bnx2x_setup_tc(struct net_device *dev, u8 num_tc)
 	return 0;
 }
 
-int __bnx2x_setup_tc(struct net_device *dev, u32 handle, u8 num_tc)
+int __bnx2x_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
+		     struct tc_to_netdev *tc)
 {
-	if (handle != TC_H_ROOT)
+	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
-	return bnx2x_setup_tc(dev, num_tc);
+	return bnx2x_setup_tc(dev, tc->tc);
 }
 
 /* called with rtnl_lock */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index e92d6e7..ef2c776 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -486,7 +486,8 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev);
 
 /* setup_tc callback */
 int bnx2x_setup_tc(struct net_device *dev, u8 num_tc);
-int __bnx2x_setup_tc(struct net_device *dev, u32 handle, u8 num_tc);
+int __bnx2x_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
+		     struct tc_to_netdev *tc);
 
 int bnx2x_get_vf_config(struct net_device *dev, int vf,
 			struct ifla_vf_info *ivi);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index ff08faf..169920a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5370,13 +5370,17 @@ static int bnxt_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-static int bnxt_setup_tc(struct net_device *dev, u32 handle, u8 tc)
+static int bnxt_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
+			 struct tc_to_netdev *ntc)
 {
 	struct bnxt *bp = netdev_priv(dev);
+	u8 tc;
 
-	if (handle != TC_H_ROOT)
+	if (handle != TC_H_ROOT || ntc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
+	tc = ntc->tc;
+
 	if (tc > bp->max_tc) {
 		netdev_err(dev, "too many traffic classes requested: %d Max supported is %d\n",
 			   tc, bp->max_tc);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 12701a4..dc1a821 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1204,12 +1204,13 @@ err_queueing_scheme:
 	return err;
 }
 
-static int __fm10k_setup_tc(struct net_device *dev, u32 handle, u8 tc)
+static int __fm10k_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
+			    struct tc_to_netdev *tc)
 {
-	if (handle != TC_H_ROOT)
+	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
-	return fm10k_setup_tc(dev, tc);
+	return fm10k_setup_tc(dev, tc->tc);
 }
 
 static int fm10k_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ae70e7c..8a84328 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5306,11 +5306,12 @@ exit:
 	return ret;
 }
 
-static int __i40e_setup_tc(struct net_device *netdev, u32 handle, u8 tc)
+static int __i40e_setup_tc(struct net_device *netdev, u32 handle, __be16 proto,
+			   struct tc_to_netdev *tc)
 {
-	if (handle != TC_H_ROOT)
+	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
-	return i40e_setup_tc(netdev, tc);
+	return i40e_setup_tc(netdev, tc->tc);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 61ec625..03e236c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8200,13 +8200,14 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 	return 0;
 }
 
-int __ixgbe_setup_tc(struct net_device *dev, u32 handle, u8 tc)
+int __ixgbe_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
+		     struct tc_to_netdev *tc)
 {
 	/* Only support egress tc setup for now */
-	if (handle != TC_H_ROOT)
+	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
-	return ixgbe_setup_tc(dev, tc);
+	return ixgbe_setup_tc(dev, tc->tc);
 }
 
 #ifdef CONFIG_PCI_IOV
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index d5c6c16..01d6a96 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -69,12 +69,13 @@ int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 	return 0;
 }
 
-static int __mlx4_en_setup_tc(struct net_device *dev, u32 handle, u8 up)
+static int __mlx4_en_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
+			      struct tc_to_netdev *tc)
 {
-	if (handle != TC_H_ROOT)
+	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
-	return mlx4_en_setup_tc(dev, up);
+	return mlx4_en_setup_tc(dev, tc->tc);
 }
 
 #ifdef CONFIG_RFS_ACCEL
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 7815fa0..5e3f93f 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -32,7 +32,8 @@ netdev_tx_t efx_hard_start_xmit(struct sk_buff *skb,
 				struct net_device *net_dev);
 netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb);
 void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
-int efx_setup_tc(struct net_device *net_dev, u32 handle, u8 num_tc);
+int efx_setup_tc(struct net_device *net_dev, u32 handle, __be16 proto,
+		 struct tc_to_netdev *tc);
 unsigned int efx_tx_max_skb_descs(struct efx_nic *efx);
 extern unsigned int efx_piobuf_size;
 extern bool efx_separate_tx_channels;
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 8f1d53e..2cdb571 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -562,17 +562,20 @@ void efx_init_tx_queue_core_txq(struct efx_tx_queue *tx_queue)
 				     efx->n_tx_channels : 0));
 }
 
-int efx_setup_tc(struct net_device *net_dev, u32 handle, u8 num_tc)
+int efx_setup_tc(struct net_device *net_dev, u32 handle, __be16 proto,
+		 struct tc_to_netdev *ntc)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
-	unsigned tc;
+	unsigned tc, num_tc;
 	int rc;
 
-	if (handle != TC_H_ROOT)
+	if (handle != TC_H_ROOT || ntc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
+	num_tc = ntc->tc;
+
 	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0 || num_tc > EFX_MAX_TX_TC)
 		return -EINVAL;
 
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 40cde81..8586a20 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1835,25 +1835,26 @@ static u16 netcp_select_queue(struct net_device *dev, struct sk_buff *skb,
 	return 0;
 }
 
-static int netcp_setup_tc(struct net_device *dev, u32 handle, u8 num_tc)
+static int netcp_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
+			  struct tc_to_netdev tc)
 {
 	int i;
 
 	/* setup tc must be called under rtnl lock */
 	ASSERT_RTNL();
 
-	if (handle != TC_H_ROOT)
+	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	/* Sanity-check the number of traffic classes requested */
 	if ((dev->real_num_tx_queues <= 1) ||
-	    (dev->real_num_tx_queues < num_tc))
+	    (dev->real_num_tx_queues < tc->tc))
 		return -EINVAL;
 
 	/* Configure traffic class to queue mappings */
-	if (num_tc) {
-		netdev_set_num_tc(dev, num_tc);
-		for (i = 0; i < num_tc; i++)
+	if (tc->tc) {
+		netdev_set_num_tc(dev, tc->tc);
+		for (i = 0; i < tc->tc; i++)
 			netdev_set_tc_queue(dev, i, 1, i);
 	} else {
 		netdev_reset_tc(dev);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e8d01a1..9090ff7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -778,6 +778,21 @@ static inline bool netdev_phys_item_id_same(struct netdev_phys_item_id *a,
 typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
 				       struct sk_buff *skb);
 
+/* This structure holds attributes of qdisc and classifiers
+ * that are being passed to the netdevice through the setup_tc op.
+ */
+enum {
+	TC_SETUP_MQPRIO,
+};
+
+struct tc_to_netdev {
+	unsigned int type;
+	union {
+		u8 tc;
+	};
+};
+
+
 /*
  * This structure defines the management hooks for network devices.
  * The following hooks can be defined; unless noted otherwise, they are
@@ -1150,7 +1165,10 @@ struct net_device_ops {
 	int			(*ndo_set_vf_rss_query_en)(
 						   struct net_device *dev,
 						   int vf, bool setting);
-	int			(*ndo_setup_tc)(struct net_device *dev, u32 handle, u8 tc);
+	int			(*ndo_setup_tc)(struct net_device *dev,
+						u32 handle,
+						__be16 protocol,
+						struct tc_to_netdev *tc);
 #if IS_ENABLED(CONFIG_FCOE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
 	int			(*ndo_fcoe_disable)(struct net_device *dev);
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 4cec88a..06b2797 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -28,6 +28,7 @@ static void mqprio_destroy(struct Qdisc *sch)
 {
 	struct net_device *dev = qdisc_dev(sch);
 	struct mqprio_sched *priv = qdisc_priv(sch);
+	struct tc_to_netdev tc = {.type = TC_SETUP_MQPRIO};
 	unsigned int ntx;
 
 	if (priv->qdiscs) {
@@ -39,7 +40,7 @@ static void mqprio_destroy(struct Qdisc *sch)
 	}
 
 	if (priv->hw_owned && dev->netdev_ops->ndo_setup_tc)
-		dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0);
+		dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0, &tc);
 	else
 		netdev_set_num_tc(dev, 0);
 }
@@ -140,9 +141,11 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 	 * supplied and verified mapping
 	 */
 	if (qopt->hw) {
+		struct tc_to_netdev tc = {.type = TC_SETUP_MQPRIO,
+					  .tc = qopt->num_tc};
+
 		priv->hw_owned = 1;
-		err = dev->netdev_ops->ndo_setup_tc(dev, sch->handle,
-						    qopt->num_tc);
+		err = dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0, &tc);
 		if (err)
 			goto err;
 	} else {
