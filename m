From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] igb: Streamline RSS queue and queue pairing assignment logic.
Date: Wed, 20 Jun 2012 01:44:59 -0700
Message-ID: <1340181903-16382-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1340181903-16382-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:31665 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755305Ab2FTIpI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 04:45:08 -0400
In-Reply-To: <1340181903-16382-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

Rather than spread out the complexity of the RSS queue and queue pairing
assignment logic, place it all in one location for simplicity and
readability.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |    9 ++--
 drivers/net/ethernet/intel/igb/igb_main.c |   79 +++++++++++++++++++----------
 2 files changed, 55 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index ae6d3f3..3ced7b5 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -65,13 +65,10 @@ struct igb_adapter;
 #define MAX_Q_VECTORS                      8
 
 /* Transmit and receive queues */
-#define IGB_MAX_RX_QUEUES		((adapter->vfs_allocated_count ? 2 : \
-					(hw->mac.type > e1000_82575 ? 8 : 4)))
-#define IGB_MAX_RX_QUEUES_I210             4
+#define IGB_MAX_RX_QUEUES                  8
+#define IGB_MAX_RX_QUEUES_82575            4
 #define IGB_MAX_RX_QUEUES_I211             2
-#define IGB_MAX_TX_QUEUES                  16
-#define IGB_MAX_TX_QUEUES_I210             4
-#define IGB_MAX_TX_QUEUES_I211             2
+#define IGB_MAX_TX_QUEUES                  8
 #define IGB_MAX_VF_MC_ENTRIES              30
 #define IGB_MAX_VF_FUNCTIONS               8
 #define IGB_MAX_VFTA_ENTRIES               128
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6409054..a7c9c5d 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1048,11 +1048,6 @@ static int igb_set_interrupt_capability(struct igb_adapter *adapter)
 	if (!(adapter->flags & IGB_FLAG_QUEUE_PAIRS))
 		numvecs += adapter->num_tx_queues;
 
-	/* i210 and i211 can only have 4 MSIX vectors for rx/tx queues. */
-	if ((adapter->hw.mac.type == e1000_i210)
-		|| (adapter->hw.mac.type == e1000_i211))
-		numvecs = 4;
-
 	/* store the number of vectors reserved for queues */
 	adapter->num_q_vectors = numvecs;
 
@@ -2338,6 +2333,7 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
+	u32 max_rss_queues;
 
 	pci_read_config_word(pdev, PCI_COMMAND, &hw->bus.pci_cmd_word);
 
@@ -2370,40 +2366,69 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 		} else
 			adapter->vfs_allocated_count = max_vfs;
 		break;
-	case e1000_i210:
-	case e1000_i211:
-		adapter->vfs_allocated_count = 0;
-		break;
 	default:
 		break;
 	}
 #endif /* CONFIG_PCI_IOV */
+
+	/* Determine the maximum number of RSS queues supported. */
 	switch (hw->mac.type) {
+	case e1000_i211:
+		max_rss_queues = IGB_MAX_RX_QUEUES_I211;
+		break;
+	case e1000_82575:
 	case e1000_i210:
-		adapter->rss_queues = min_t(u32, IGB_MAX_RX_QUEUES_I210,
-			num_online_cpus());
+		max_rss_queues = IGB_MAX_RX_QUEUES_82575;
+		break;
+	case e1000_i350:
+		/* I350 cannot do RSS and SR-IOV at the same time */
+		if (!!adapter->vfs_allocated_count) {
+			max_rss_queues = 1;
+			break;
+		}
+		/* fall through */
+	case e1000_82576:
+		if (!!adapter->vfs_allocated_count) {
+			max_rss_queues = 2;
+			break;
+		}
+		/* fall through */
+	case e1000_82580:
+	default:
+		max_rss_queues = IGB_MAX_RX_QUEUES;
 		break;
+	}
+
+	adapter->rss_queues = min_t(u32, max_rss_queues, num_online_cpus());
+
+	/* Determine if we need to pair queues. */
+	switch (hw->mac.type) {
+	case e1000_82575:
 	case e1000_i211:
-		adapter->rss_queues = min_t(u32, IGB_MAX_RX_QUEUES_I211,
-			num_online_cpus());
+		/* Device supports enough interrupts without queue pairing. */
 		break;
+	case e1000_82576:
+		/*
+		 * If VFs are going to be allocated with RSS queues then we
+		 * should pair the queues in order to conserve interrupts due
+		 * to limited supply.
+		 */
+		if ((adapter->rss_queues > 1) &&
+		    (adapter->vfs_allocated_count > 6))
+			adapter->flags |= IGB_FLAG_QUEUE_PAIRS;
+		/* fall through */
+	case e1000_82580:
+	case e1000_i350:
+	case e1000_i210:
 	default:
-		adapter->rss_queues = min_t(u32, IGB_MAX_RX_QUEUES,
-		num_online_cpus());
+		/*
+		 * If rss_queues > half of max_rss_queues, pair the queues in
+		 * order to conserve interrupts due to limited supply.
+		 */
+		if (adapter->rss_queues > (max_rss_queues / 2))
+			adapter->flags |= IGB_FLAG_QUEUE_PAIRS;
 		break;
 	}
-	/* i350 cannot do RSS and SR-IOV at the same time */
-	if (hw->mac.type == e1000_i350 && adapter->vfs_allocated_count)
-		adapter->rss_queues = 1;
-
-	/*
-	 * if rss_queues > 4 or vfs are going to be allocated with rss_queues
-	 * then we should combine the queues into a queue pair in order to
-	 * conserve interrupts due to limited supply
-	 */
-	if ((adapter->rss_queues > 4) ||
-	    ((adapter->rss_queues > 1) && (adapter->vfs_allocated_count > 6)))
-		adapter->flags |= IGB_FLAG_QUEUE_PAIRS;
 
 	/* Setup and initialize a copy of the hw vlan table array */
 	adapter->shadow_vfta = kzalloc(sizeof(u32) *
-- 
1.7.10.2
