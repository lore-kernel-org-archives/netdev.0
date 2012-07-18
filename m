From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] ixgbe: Retire RSS enabled and capable flags
Date: Wed, 18 Jul 2012 13:31:55 -0700
Message-ID: <1342643516-2696-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5779 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755976Ab2GRUcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 16:32:04 -0400
In-Reply-To: <1342643516-2696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

All of our hardware supports RSS even if it is only for a single queue.  So
instead of toting around the RSS enable flag I am updating the code so that
all devices are enabled and if we want to disable RSS it is indicated via
the RSS mask.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    2 --
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    4 ---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c     |   10 +-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   29 ++++++----------------
 4 files changed, 8 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 67743aa..4ca10e6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -446,8 +446,6 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_IMIR_ENABLED                 (u32)(1 << 12)
 #define IXGBE_FLAG_MQ_CAPABLE                   (u32)(1 << 13)
 #define IXGBE_FLAG_DCB_ENABLED                  (u32)(1 << 14)
-#define IXGBE_FLAG_RSS_ENABLED                  (u32)(1 << 16)
-#define IXGBE_FLAG_RSS_CAPABLE                  (u32)(1 << 17)
 #define IXGBE_FLAG_VMDQ_CAPABLE                 (u32)(1 << 18)
 #define IXGBE_FLAG_VMDQ_ENABLED                 (u32)(1 << 19)
 #define IXGBE_FLAG_FAN_FAIL_CAPABLE             (u32)(1 << 20)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 8e1be50..4104ea25 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2245,10 +2245,6 @@ static int ixgbe_get_rss_hash_opts(struct ixgbe_adapter *adapter,
 {
 	cmd->data = 0;
 
-	/* if RSS is disabled then report no hashing */
-	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
-		return 0;
-
 	/* Report default options for RSS on ixgbe */
 	switch (cmd->flow_type) {
 	case TCP_V4_FLOW:
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 676e93f..38d1b65 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -265,9 +265,6 @@ static bool ixgbe_cache_ring_rss(struct ixgbe_adapter *adapter)
 {
 	int i;
 
-	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
-		return false;
-
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		adapter->rx_ring[i]->reg_idx = i;
 	for (i = 0; i < adapter->num_tx_queues; i++)
@@ -602,11 +599,6 @@ static bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
 	struct ixgbe_ring_feature *f;
 	u16 rss_i;
 
-	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED)) {
-		adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
-		return false;
-	}
-
 	/* set mask for 16 queue limit of RSS */
 	f = &adapter->ring_feature[RING_F_RSS];
 	rss_i = f->limit;
@@ -1062,7 +1054,6 @@ static void ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	}
 
 	adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
-	adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
 	if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) {
 		e_err(probe,
 		      "ATR is not supported while multiple "
@@ -1073,6 +1064,7 @@ static void ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
 		ixgbe_disable_sriov(adapter);
 
+	adapter->ring_feature[RING_F_RSS].limit = 1;
 	ixgbe_set_num_queues(adapter);
 	adapter->num_q_vectors = 1;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 454e556..a3dc965 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2891,9 +2891,6 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 	int i, j;
 	u16 rss_i = adapter->ring_feature[RING_F_RSS].indices;
 
-	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
-		rss_i = 1;
-
 	/*
 	 * Program table for at least 2 queues w/ SR-IOV so that VFs can
 	 * make full use of any rings they may have.  We will use the
@@ -2923,7 +2920,7 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_RXCSUM, rxcsum);
 
 	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
-		if (adapter->flags & IXGBE_FLAG_RSS_ENABLED)
+		if (adapter->ring_feature[RING_F_RSS].mask)
 			mrqc = IXGBE_MRQC_RSSEN;
 	} else {
 		u8 tcs = netdev_get_num_tc(adapter->netdev);
@@ -3102,6 +3099,7 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 static void ixgbe_setup_psrtype(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
+	int rss_i = adapter->ring_feature[RING_F_RSS].indices;
 	int p;
 
 	/* PSRTYPE must be initialized in non 82598 adapters */
@@ -3114,13 +3112,10 @@ static void ixgbe_setup_psrtype(struct ixgbe_adapter *adapter)
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		return;
 
-	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
-		int rss_i = adapter->ring_feature[RING_F_RSS].indices;
-		if (rss_i > 3)
-			psrtype |= 2 << 29;
-		else if (rss_i > 1)
-			psrtype |= 1 << 29;
-	}
+	if (rss_i > 3)
+		psrtype |= 2 << 29;
+	else if (rss_i > 1)
+		psrtype |= 1 << 29;
 
 	for (p = 0; p < adapter->num_rx_pools; p++)
 		IXGBE_WRITE_REG(hw, IXGBE_PSRTYPE(adapter->num_vfs + p),
@@ -4408,7 +4403,6 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	/* Set capability flags */
 	rss = min_t(int, IXGBE_MAX_RSS_INDICES, num_online_cpus());
 	adapter->ring_feature[RING_F_RSS].limit = rss;
-	adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
 		if (hw->device_id == IXGBE_DEV_ID_82598AT)
@@ -6756,10 +6750,6 @@ static netdev_features_t ixgbe_fix_features(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	/* return error if RXHASH is being enabled when RSS is not supported */
-	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED))
-		features &= ~NETIF_F_RXHASH;
-
 	/* If Rx checksum is disabled, then RSC/LRO should also be disabled */
 	if (!(features & NETIF_F_RXCSUM))
 		features &= ~NETIF_F_LRO;
@@ -6802,7 +6792,7 @@ static int ixgbe_set_features(struct net_device *netdev,
 	if (!(features & NETIF_F_NTUPLE)) {
 		if (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE) {
 			/* turn off Flow Director, set ATR and reset */
-			if ((adapter->flags & IXGBE_FLAG_RSS_ENABLED) &&
+			if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) &&
 			    !(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
 				adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
 			need_reset = true;
@@ -7294,11 +7284,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_sw_init;
 
-	if (!(adapter->flags & IXGBE_FLAG_RSS_ENABLED)) {
-		netdev->hw_features &= ~NETIF_F_RXHASH;
-		netdev->features &= ~NETIF_F_RXHASH;
-	}
-
 	/* WOL not supported for all devices */
 	adapter->wol = 0;
 	hw->eeprom.ops.read(hw, 0x2c, &adapter->eeprom_cap);
-- 
1.7.10.4
