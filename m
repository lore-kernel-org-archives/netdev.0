From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next v2 08/14] i40evf: store ring size in ring structs
Date: Thu, 20 Feb 2014 19:29:12 -0800
Message-ID: <1392953358-23908-9-git-send-email-aaron.f.brown@intel.com>
References: <1392953358-23908-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20978 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752823AbaBUDcR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Feb 2014 22:32:17 -0500
In-Reply-To: <1392953358-23908-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Keep the descriptor ring size in the actual ring structs instead of in
the adapter struct. This enables us to use common tx and rx code with
the i40e PF driver.

Also update copyrights.

Change-ID: I2861e599b2b4c76441c062ea14400f4750f54d0e
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  2 --
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 13 ++++++++-----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  3 ---
 3 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index c9a5056..ccb43d3 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -196,8 +196,6 @@ struct i40evf_adapter {
 
 	/* RX */
 	struct i40e_ring *rx_rings[I40E_MAX_VSI_QP];
-	int txd_count;
-	int rxd_count;
 	u64 hw_csum_rx_error;
 	int num_msix_vectors;
 	struct msix_entry *msix_entries;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index b0b1f4b..8b0db1c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Virtual Function Driver
- * Copyright(c) 2013 Intel Corporation.
+ * Copyright(c) 2013 - 2014 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -241,6 +241,7 @@ static int i40evf_set_ringparam(struct net_device *netdev,
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 	u32 new_rx_count, new_tx_count;
+	int i;
 
 	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
 		return -EINVAL;
@@ -256,12 +257,14 @@ static int i40evf_set_ringparam(struct net_device *netdev,
 	new_rx_count = ALIGN(new_rx_count, I40EVF_REQ_DESCRIPTOR_MULTIPLE);
 
 	/* if nothing to do return success */
-	if ((new_tx_count == adapter->txd_count) &&
-	    (new_rx_count == adapter->rxd_count))
+	if ((new_tx_count == adapter->tx_rings[0]->count) &&
+	    (new_rx_count == adapter->rx_rings[0]->count))
 		return 0;
 
-	adapter->txd_count = new_tx_count;
-	adapter->rxd_count = new_rx_count;
+	for (i = 0; i < adapter->vsi_res->num_queue_pairs; i++) {
+		adapter->tx_rings[0]->count = new_tx_count;
+		adapter->rx_rings[0]->count = new_rx_count;
+	}
 
 	if (netif_running(netdev))
 		i40evf_reinit_locked(adapter);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 40a5e78..d05d5c1 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2025,9 +2025,6 @@ static void i40evf_init_task(struct work_struct *work)
 
 	adapter->flags |= I40EVF_FLAG_RX_CSUM_ENABLED;
 
-	adapter->txd_count = I40EVF_DEFAULT_TXD;
-	adapter->rxd_count = I40EVF_DEFAULT_RXD;
-
 	netdev->netdev_ops = &i40evf_netdev_ops;
 	i40evf_set_ethtool_ops(netdev);
 	netdev->watchdog_timeo = 5 * HZ;
-- 
1.8.5.GIT
