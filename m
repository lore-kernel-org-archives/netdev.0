From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 1/7] net: rework ndo tc op to consume additional
 qdisc handle parameter
Date: Wed, 03 Feb 2016 01:27:55 -0800
Message-ID: <20160203092755.1356.84088.stgit@john-Precision-Tower-5810>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: amir@vadai.me, ogerlitz@mellanox.com, jiri@resnulli.us,
	jhs@mojatatu.com, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33078 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397AbcBCJ2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 04:28:12 -0500
Received: by mail-pa0-f50.google.com with SMTP id cy9so10736529pac.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 01:28:11 -0800 (PST)
In-Reply-To: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ndo_setup_tc() op was added to support drivers offloading tx
qdiscs however only support for mqprio was ever added. So we
only ever added support for passing the number of traffic classes
to the driver.

This patch generalizes the ndo_setup_tc op so that a handle can
be provided to indicate if the offload is for ingress or egress
or potentially even child qdiscs.

CC: Murali Karicheri <m-karicheri2@ti.com>
CC: Shradha Shah <sshah@solarflare.com>
CC: Or Gerlitz <ogerlitz@mellanox.com>
CC: Ariel Elior <ariel.elior@qlogic.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Bruce Allan <bruce.w.allan@intel.com>
CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    7 +++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c        |    5 ++++-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  |   10 +++++++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c      |    9 ++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   11 ++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |   12 ++++++++++--
 drivers/net/ethernet/sfc/efx.h                   |    2 +-
 drivers/net/ethernet/sfc/tx.c                    |    5 ++++-
 drivers/net/ethernet/ti/netcp_core.c             |    5 ++++-
 include/linux/netdevice.h                        |    2 +-
 net/sched/sch_mqprio.c                           |    5 +++--
 13 files changed, 63 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 9695a4c..1c7ff51 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -4272,6 +4272,13 @@ int bnx2x_setup_tc(struct net_device *dev, u8 num_tc)
 	return 0;
 }
 
+int __bnx2x_setup_tc(struct net_device *dev, u32 handle, u8 num_tc)
+{
+	if (handle != TC_H_ROOT)
+		return -EINVAL;
+	return bnx2x_setup_tc(dev, num_tc);
+}
+
 /* called with rtnl_lock */
 int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 4cbb03f8..e92d6e7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -486,6 +486,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev);
 
 /* setup_tc callback */
 int bnx2x_setup_tc(struct net_device *dev, u8 num_tc);
+int __bnx2x_setup_tc(struct net_device *dev, u32 handle, u8 num_tc);
 
 int bnx2x_get_vf_config(struct net_device *dev, int vf,
 			struct ifla_vf_info *ivi);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 6c4e3a6..b17bb17 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12994,7 +12994,7 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= poll_bnx2x,
 #endif
-	.ndo_setup_tc		= bnx2x_setup_tc,
+	.ndo_setup_tc		= __bnx2x_setup_tc,
 #ifdef CONFIG_BNX2X_SRIOV
 	.ndo_set_vf_mac		= bnx2x_set_vf_mac,
 	.ndo_set_vf_vlan	= bnx2x_set_vf_vlan,
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 5dc89e5..ff08faf 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5370,10 +5370,13 @@ static int bnxt_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-static int bnxt_setup_tc(struct net_device *dev, u8 tc)
+static int bnxt_setup_tc(struct net_device *dev, u32 handle, u8 tc)
 {
 	struct bnxt *bp = netdev_priv(dev);
 
+	if (handle != TC_H_ROOT)
+		return -EINVAL;
+
 	if (tc > bp->max_tc) {
 		netdev_err(dev, "too many traffic classes requested: %d Max supported is %d\n",
 			   tc, bp->max_tc);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 662569d..12701a4 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1204,6 +1204,14 @@ err_queueing_scheme:
 	return err;
 }
 
+static int __fm10k_setup_tc(struct net_device *dev, u32 handle, u8 tc)
+{
+	if (handle != TC_H_ROOT)
+		return -EINVAL;
+
+	return fm10k_setup_tc(dev, tc);
+}
+
 static int fm10k_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
 	switch (cmd) {
@@ -1386,7 +1394,7 @@ static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_vlan_rx_kill_vid	= fm10k_vlan_rx_kill_vid,
 	.ndo_set_rx_mode	= fm10k_set_rx_mode,
 	.ndo_get_stats64	= fm10k_get_stats64,
-	.ndo_setup_tc		= fm10k_setup_tc,
+	.ndo_setup_tc		= __fm10k_setup_tc,
 	.ndo_set_vf_mac		= fm10k_ndo_set_vf_mac,
 	.ndo_set_vf_vlan	= fm10k_ndo_set_vf_vlan,
 	.ndo_set_vf_rate	= fm10k_ndo_set_vf_bw,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 8f3b53e..ae70e7c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5306,6 +5306,13 @@ exit:
 	return ret;
 }
 
+static int __i40e_setup_tc(struct net_device *netdev, u32 handle, u8 tc)
+{
+	if (handle != TC_H_ROOT)
+		return -EINVAL;
+	return i40e_setup_tc(netdev, tc);
+}
+
 /**
  * i40e_open - Called when a network interface is made active
  * @netdev: network interface device structure
@@ -8890,7 +8897,7 @@ static const struct net_device_ops i40e_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= i40e_netpoll,
 #endif
-	.ndo_setup_tc		= i40e_setup_tc,
+	.ndo_setup_tc		= __i40e_setup_tc,
 #ifdef I40E_FCOE
 	.ndo_fcoe_enable	= i40e_fcoe_enable,
 	.ndo_fcoe_disable	= i40e_fcoe_disable,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c4003a8..61ec625 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8200,6 +8200,15 @@ int ixgbe_setup_tc(struct net_device *dev, u8 tc)
 	return 0;
 }
 
+int __ixgbe_setup_tc(struct net_device *dev, u32 handle, u8 tc)
+{
+	/* Only support egress tc setup for now */
+	if (handle != TC_H_ROOT)
+		return -EINVAL;
+
+	return ixgbe_setup_tc(dev, tc);
+}
+
 #ifdef CONFIG_PCI_IOV
 void ixgbe_sriov_reinit(struct ixgbe_adapter *adapter)
 {
@@ -8658,7 +8667,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_get_vf_config	= ixgbe_ndo_get_vf_config,
 	.ndo_get_stats64	= ixgbe_get_stats64,
 #ifdef CONFIG_IXGBE_DCB
-	.ndo_setup_tc		= ixgbe_setup_tc,
+	.ndo_setup_tc		= __ixgbe_setup_tc,
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ixgbe_netpoll,
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 0c7e3f6..d5c6c16 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -69,6 +69,14 @@ int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 	return 0;
 }
 
+static int __mlx4_en_setup_tc(struct net_device *dev, u32 handle, u8 up)
+{
+	if (handle != TC_H_ROOT)
+		return -EINVAL;
+
+	return mlx4_en_setup_tc(dev, up);
+}
+
 #ifdef CONFIG_RFS_ACCEL
 
 struct mlx4_en_filter {
@@ -2466,7 +2474,7 @@ static const struct net_device_ops mlx4_netdev_ops = {
 #endif
 	.ndo_set_features	= mlx4_en_set_features,
 	.ndo_fix_features	= mlx4_en_fix_features,
-	.ndo_setup_tc		= mlx4_en_setup_tc,
+	.ndo_setup_tc		= __mlx4_en_setup_tc,
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= mlx4_en_filter_rfs,
 #endif
@@ -2504,7 +2512,7 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
 #endif
 	.ndo_set_features	= mlx4_en_set_features,
 	.ndo_fix_features	= mlx4_en_fix_features,
-	.ndo_setup_tc		= mlx4_en_setup_tc,
+	.ndo_setup_tc		= __mlx4_en_setup_tc,
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= mlx4_en_filter_rfs,
 #endif
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 1082747..7815fa0 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -32,7 +32,7 @@ netdev_tx_t efx_hard_start_xmit(struct sk_buff *skb,
 				struct net_device *net_dev);
 netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb);
 void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
-int efx_setup_tc(struct net_device *net_dev, u8 num_tc);
+int efx_setup_tc(struct net_device *net_dev, u32 handle, u8 num_tc);
 unsigned int efx_tx_max_skb_descs(struct efx_nic *efx);
 extern unsigned int efx_piobuf_size;
 extern bool efx_separate_tx_channels;
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index f7a0ec1..8f1d53e 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -562,7 +562,7 @@ void efx_init_tx_queue_core_txq(struct efx_tx_queue *tx_queue)
 				     efx->n_tx_channels : 0));
 }
 
-int efx_setup_tc(struct net_device *net_dev, u8 num_tc)
+int efx_setup_tc(struct net_device *net_dev, u32 handle, u8 num_tc)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_channel *channel;
@@ -570,6 +570,9 @@ int efx_setup_tc(struct net_device *net_dev, u8 num_tc)
 	unsigned tc;
 	int rc;
 
+	if (handle != TC_H_ROOT)
+		return -EINVAL;
+
 	if (efx_nic_rev(efx) < EFX_REV_FALCON_B0 || num_tc > EFX_MAX_TX_TC)
 		return -EINVAL;
 
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index c61d66d..40cde81 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1835,13 +1835,16 @@ static u16 netcp_select_queue(struct net_device *dev, struct sk_buff *skb,
 	return 0;
 }
 
-static int netcp_setup_tc(struct net_device *dev, u8 num_tc)
+static int netcp_setup_tc(struct net_device *dev, u32 handle, u8 num_tc)
 {
 	int i;
 
 	/* setup tc must be called under rtnl lock */
 	ASSERT_RTNL();
 
+	if (handle != TC_H_ROOT)
+		return -EINVAL;
+
 	/* Sanity-check the number of traffic classes requested */
 	if ((dev->real_num_tx_queues <= 1) ||
 	    (dev->real_num_tx_queues < num_tc))
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 289c231..e8d01a1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1150,7 +1150,7 @@ struct net_device_ops {
 	int			(*ndo_set_vf_rss_query_en)(
 						   struct net_device *dev,
 						   int vf, bool setting);
-	int			(*ndo_setup_tc)(struct net_device *dev, u8 tc);
+	int			(*ndo_setup_tc)(struct net_device *dev, u32 handle, u8 tc);
 #if IS_ENABLED(CONFIG_FCOE)
 	int			(*ndo_fcoe_enable)(struct net_device *dev);
 	int			(*ndo_fcoe_disable)(struct net_device *dev);
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index 6bc2617..4cec88a 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -39,7 +39,7 @@ static void mqprio_destroy(struct Qdisc *sch)
 	}
 
 	if (priv->hw_owned && dev->netdev_ops->ndo_setup_tc)
-		dev->netdev_ops->ndo_setup_tc(dev, 0);
+		dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0);
 	else
 		netdev_set_num_tc(dev, 0);
 }
@@ -141,7 +141,8 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 	 */
 	if (qopt->hw) {
 		priv->hw_owned = 1;
-		err = dev->netdev_ops->ndo_setup_tc(dev, qopt->num_tc);
+		err = dev->netdev_ops->ndo_setup_tc(dev, sch->handle,
+						    qopt->num_tc);
 		if (err)
 			goto err;
 	} else {
