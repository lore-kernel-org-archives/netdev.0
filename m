From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] ixgbe: Enable FCoE FSO and CRC offloads based on CAPABLE instead of ENABLED flag
Date: Thu, 19 Jul 2012 18:24:06 -0700
Message-ID: <1342747446-16132-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342747446-16132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9033 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752793Ab2GTBYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 21:24:16 -0400
In-Reply-To: <1342747446-16132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Instead of only setting the FCOE segmentation offload and CRC offload flags
if we enable FCoE, we could just set them always since there are no
modifications needed to the hardware or adapter FCoE structure in order to
use these features.

The advantage to this is that if FCoE enablement fails, for example because
SR-IOV was enabled on 82599, we will still have use of the FCoE
segmentation offload and Tx/Rx CRC offloads which should still help to
improve the FCoE performance.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c |   16 +++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 ++++-
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index e79ba39..ae73ef1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -616,11 +616,11 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 	int i, fcoe_q, fcoe_i;
 	u32 etqf;
 
-	/* leave registers unconfigued if FCoE is disabled */
-	if (!(adapter->flags & IXGBE_FLAG_FCOE_ENABLED))
+	/* Minimal functionality for FCoE requires at least CRC offloads */
+	if (!(adapter->netdev->features & NETIF_F_FCOE_CRC))
 		return;
 
-	/* Enable L2 EtherType filter for FCoE, necessary for FCoE Rx CRC */
+	/* Enable L2 EtherType filter for FCoE, needed for FCoE CRC and DDP */
 	etqf = ETH_P_FCOE | IXGBE_ETQF_FCOE | IXGBE_ETQF_FILTER_EN;
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
 		etqf |= IXGBE_ETQF_POOL_ENABLE;
@@ -629,6 +629,10 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_ETQF(IXGBE_ETQF_FILTER_FCOE), etqf);
 	IXGBE_WRITE_REG(hw, IXGBE_ETQS(IXGBE_ETQF_FILTER_FCOE), 0);
 
+	/* leave registers un-configured if FCoE is disabled */
+	if (!(adapter->flags & IXGBE_FLAG_FCOE_ENABLED))
+		return;
+
 	/* Use one or more Rx queues for FCoE by redirection table */
 	for (i = 0; i < IXGBE_FCRETA_SIZE; i++) {
 		fcoe_i = fcoe->offset + (i % fcoe->indices);
@@ -804,7 +808,7 @@ int ixgbe_fcoe_enable(struct net_device *netdev)
 
 	/* enable FCoE and notify stack */
 	adapter->flags |= IXGBE_FLAG_FCOE_ENABLED;
-	netdev->features |= NETIF_F_FSO | NETIF_F_FCOE_CRC | NETIF_F_FCOE_MTU;
+	netdev->features |= NETIF_F_FCOE_MTU;
 	netdev_features_change(netdev);
 
 	/* release existing queues and reallocate them */
@@ -844,9 +848,7 @@ int ixgbe_fcoe_disable(struct net_device *netdev)
 
 	/* disable FCoE and notify stack */
 	adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
-	netdev->features &= ~(NETIF_F_FCOE_CRC |
-			      NETIF_F_FSO |
-			      NETIF_F_FCOE_MTU);
+	netdev->features &= ~NETIF_F_FCOE_MTU;
 
 	netdev_features_change(netdev);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index aa01558..c521007 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6382,7 +6382,7 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 #ifdef IXGBE_FCOE
 	/* setup tx offload for FCoE */
 	if ((protocol == __constant_htons(ETH_P_FCOE)) &&
-	    (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)) {
+	    (tx_ring->netdev->features & (NETIF_F_FSO | NETIF_F_FCOE_CRC))) {
 		tso = ixgbe_fso(tx_ring, first, &hdr_len);
 		if (tso < 0)
 			goto out_drop;
@@ -7257,6 +7257,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 		adapter->ring_feature[RING_F_FCOE].limit = IXGBE_FCRETA_SIZE;
 
+		netdev->features |= NETIF_F_FSO |
+				    NETIF_F_FCOE_CRC;
+
 		netdev->vlan_features |= NETIF_F_FSO |
 					 NETIF_F_FCOE_CRC |
 					 NETIF_F_FCOE_MTU;
-- 
1.7.10.4
