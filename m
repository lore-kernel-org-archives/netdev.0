From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/11] ixgbevf: implement ethtool get/set coalesce
Date: Thu, 24 Oct 2013 08:27:37 -0700
Message-ID: <1382628458-26601-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1382628458-26601-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:61169 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755720Ab3JXP1t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Oct 2013 11:27:49 -0400
In-Reply-To: <1382628458-26601-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch adds support for ethtool's get_coalesce and set_coalesce command for
the ixgbevf driver. This enables dynamically updating the minimum time between
interrupts.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      | 81 +++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  2 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  2 +-
 3 files changed, 84 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index 84329b0..21adb1b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -634,6 +634,85 @@ static int ixgbevf_nway_reset(struct net_device *netdev)
 	return 0;
 }
 
+static int ixgbevf_get_coalesce(struct net_device *netdev,
+				struct ethtool_coalesce *ec)
+{
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+
+	/* only valid if in constant ITR mode */
+	if (adapter->rx_itr_setting <= 1)
+		ec->rx_coalesce_usecs = adapter->rx_itr_setting;
+	else
+		ec->rx_coalesce_usecs = adapter->rx_itr_setting >> 2;
+
+	/* if in mixed tx/rx queues per vector mode, report only rx settings */
+	if (adapter->q_vector[0]->tx.count && adapter->q_vector[0]->rx.count)
+		return 0;
+
+	/* only valid if in constant ITR mode */
+	if (adapter->tx_itr_setting <= 1)
+		ec->tx_coalesce_usecs = adapter->tx_itr_setting;
+	else
+		ec->tx_coalesce_usecs = adapter->tx_itr_setting >> 2;
+
+	return 0;
+}
+
+static int ixgbevf_set_coalesce(struct net_device *netdev,
+				struct ethtool_coalesce *ec)
+{
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+	struct ixgbevf_q_vector *q_vector;
+	int num_vectors, i;
+	u16 tx_itr_param, rx_itr_param;
+
+	/* don't accept tx specific changes if we've got mixed RxTx vectors */
+	if (adapter->q_vector[0]->tx.count && adapter->q_vector[0]->rx.count
+	    && ec->tx_coalesce_usecs)
+		return -EINVAL;
+
+
+	if ((ec->rx_coalesce_usecs > (IXGBE_MAX_EITR >> 2)) ||
+	    (ec->tx_coalesce_usecs > (IXGBE_MAX_EITR >> 2)))
+		return -EINVAL;
+
+	if (ec->rx_coalesce_usecs > 1)
+		adapter->rx_itr_setting = ec->rx_coalesce_usecs << 2;
+	else
+		adapter->rx_itr_setting = ec->rx_coalesce_usecs;
+
+	if (adapter->rx_itr_setting == 1)
+		rx_itr_param = IXGBE_20K_ITR;
+	else
+		rx_itr_param = adapter->rx_itr_setting;
+
+
+	if (ec->tx_coalesce_usecs > 1)
+		adapter->tx_itr_setting = ec->tx_coalesce_usecs << 2;
+	else
+		adapter->tx_itr_setting = ec->tx_coalesce_usecs;
+
+	if (adapter->tx_itr_setting == 1)
+		tx_itr_param = IXGBE_10K_ITR;
+	else
+		tx_itr_param = adapter->tx_itr_setting;
+
+	num_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+
+	for (i = 0; i < num_vectors; i++) {
+		q_vector = adapter->q_vector[i];
+		if (q_vector->tx.count && !q_vector->rx.count)
+			/* tx only */
+			q_vector->itr = tx_itr_param;
+		else
+			/* rx only or mixed */
+			q_vector->itr = rx_itr_param;
+		ixgbevf_write_eitr(q_vector);
+	}
+
+	return 0;
+}
+
 static const struct ethtool_ops ixgbevf_ethtool_ops = {
 	.get_settings           = ixgbevf_get_settings,
 	.get_drvinfo            = ixgbevf_get_drvinfo,
@@ -649,6 +728,8 @@ static const struct ethtool_ops ixgbevf_ethtool_ops = {
 	.get_sset_count         = ixgbevf_get_sset_count,
 	.get_strings            = ixgbevf_get_strings,
 	.get_ethtool_stats      = ixgbevf_get_ethtool_stats,
+	.get_coalesce           = ixgbevf_get_coalesce,
+	.set_coalesce           = ixgbevf_set_coalesce,
 };
 
 void ixgbevf_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 64a2b91..d7837dcc 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -293,6 +293,8 @@ void ixgbevf_free_tx_resources(struct ixgbevf_adapter *, struct ixgbevf_ring *);
 void ixgbevf_update_stats(struct ixgbevf_adapter *adapter);
 int ethtool_ioctl(struct ifreq *ifr);
 
+extern void ixgbevf_write_eitr(struct ixgbevf_q_vector *q_vector);
+
 void ixgbe_napi_add_all(struct ixgbevf_adapter *adapter);
 void ixgbe_napi_del_all(struct ixgbevf_adapter *adapter);
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index c0f9aad..8407fd2 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -580,7 +580,7 @@ static int ixgbevf_poll(struct napi_struct *napi, int budget)
  * ixgbevf_write_eitr - write VTEITR register in hardware specific way
  * @q_vector: structure containing interrupt and ring information
  */
-static void ixgbevf_write_eitr(struct ixgbevf_q_vector *q_vector)
+void ixgbevf_write_eitr(struct ixgbevf_q_vector *q_vector)
 {
 	struct ixgbevf_adapter *adapter = q_vector->adapter;
 	struct ixgbe_hw *hw = &adapter->hw;
-- 
1.8.3.1
