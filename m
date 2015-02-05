From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/16] ixgbevf: enable multiple queue support
Date: Thu,  5 Feb 2015 01:35:39 -0800
Message-ID: <1423128950-12388-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55122 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756646AbbBEJgE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 04:36:04 -0500
In-Reply-To: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch enables multiple queues and RSS support for the VF.
Maximum of 2 queues are supported due to available vectors.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 22 +++++++++++++++++++---
 2 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 8c44ab2..65cda34 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -124,6 +124,7 @@ struct ixgbevf_ring {
 
 #define MAX_RX_QUEUES IXGBE_VF_MAX_RX_QUEUES
 #define MAX_TX_QUEUES IXGBE_VF_MAX_TX_QUEUES
+#define IXGBEVF_MAX_RSS_QUEUES 2
 
 #define IXGBEVF_DEFAULT_TXD   1024
 #define IXGBEVF_DEFAULT_RXD   512
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index c9b49bf..815808f 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1794,7 +1794,8 @@ static int ixgbevf_configure_dcb(struct ixgbevf_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	unsigned int def_q = 0;
 	unsigned int num_tcs = 0;
-	unsigned int num_rx_queues = 1;
+	unsigned int num_rx_queues = adapter->num_rx_queues;
+	unsigned int num_tx_queues = adapter->num_tx_queues;
 	int err;
 
 	spin_lock_bh(&adapter->mbx_lock);
@@ -1808,6 +1809,9 @@ static int ixgbevf_configure_dcb(struct ixgbevf_adapter *adapter)
 		return err;
 
 	if (num_tcs > 1) {
+		/* we need only one Tx queue */
+		num_tx_queues = 1;
+
 		/* update default Tx ring register index */
 		adapter->tx_ring[0]->reg_idx = def_q;
 
@@ -1816,7 +1820,8 @@ static int ixgbevf_configure_dcb(struct ixgbevf_adapter *adapter)
 	}
 
 	/* if we have a bad config abort request queue reset */
-	if (adapter->num_rx_queues != num_rx_queues) {
+	if ((adapter->num_rx_queues != num_rx_queues) ||
+	    (adapter->num_tx_queues != num_tx_queues)) {
 		/* force mailbox timeout to prevent further messages */
 		hw->mbx.timeout = 0;
 
@@ -2181,8 +2186,19 @@ static void ixgbevf_set_num_queues(struct ixgbevf_adapter *adapter)
 		return;
 
 	/* we need as many queues as traffic classes */
-	if (num_tcs > 1)
+	if (num_tcs > 1) {
 		adapter->num_rx_queues = num_tcs;
+	} else {
+		u16 rss = min_t(u16, num_online_cpus(), IXGBEVF_MAX_RSS_QUEUES);
+
+		switch (hw->api_version) {
+		case ixgbe_mbox_api_11:
+			adapter->num_rx_queues = rss;
+			adapter->num_tx_queues = rss;
+		default:
+			break;
+		}
+	}
 }
 
 /**
-- 
1.9.3
