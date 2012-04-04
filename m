From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/8] e1000: Support RX-ALL flag.
Date: Wed,  4 Apr 2012 00:55:53 -0700
Message-ID: <1333526160-24937-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1333526160-24937-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39155 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754925Ab2DDH4D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 03:56:03 -0400
In-Reply-To: <1333526160-24937-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows the NIC to receive errored frames (bad FCS, etc)
and pass them up the stack.  This can be useful when using
sniffers.

Signed-off-by: Ben Greear <greearb@candelatech.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c |   26 ++++++++++++++++++++++++-
 1 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 4348b6f..3d712f2 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -827,9 +827,10 @@ static int e1000_set_features(struct net_device *netdev,
 	if (changed & NETIF_F_HW_VLAN_RX)
 		e1000_vlan_mode(netdev, features);
 
-	if (!(changed & NETIF_F_RXCSUM))
+	if (!(changed & (NETIF_F_RXCSUM | NETIF_F_RXALL)))
 		return 0;
 
+	netdev->features = features;
 	adapter->rx_csum = !!(features & NETIF_F_RXCSUM);
 
 	if (netif_running(netdev))
@@ -1074,6 +1075,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	netdev->features |= netdev->hw_features;
 	netdev->hw_features |= NETIF_F_RXCSUM;
+	netdev->hw_features |= NETIF_F_RXALL;
 	netdev->hw_features |= NETIF_F_RXFCS;
 
 	if (pci_using_dac) {
@@ -1841,6 +1843,22 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 			break;
 	}
 
+	/* This is useful for sniffing bad packets. */
+	if (adapter->netdev->features & NETIF_F_RXALL) {
+		/* UPE and MPE will be handled by normal PROMISC logic
+		 * in e1000e_set_rx_mode */
+		rctl |= (E1000_RCTL_SBP | /* Receive bad packets */
+			 E1000_RCTL_BAM | /* RX All Bcast Pkts */
+			 E1000_RCTL_PMCF); /* RX All MAC Ctrl Pkts */
+
+		rctl &= ~(E1000_RCTL_VFE | /* Disable VLAN filter */
+			  E1000_RCTL_DPF | /* Allow filtered pause */
+			  E1000_RCTL_CFIEN); /* Dis VLAN CFIEN Filter */
+		/* Do not mess with E1000_CTRL_VME, it affects transmit as well,
+		 * and that breaks VLANs.
+		 */
+	}
+
 	ew32(RCTL, rctl);
 }
 
@@ -4057,6 +4075,8 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 				                       irq_flags);
 				length--;
 			} else {
+				if (netdev->features & NETIF_F_RXALL)
+					goto process_skb;
 				/* recycle both page and skb */
 				buffer_info->skb = skb;
 				/* an error means any chain goes out the window
@@ -4069,6 +4089,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		}
 
 #define rxtop rx_ring->rx_skb_top
+process_skb:
 		if (!(status & E1000_RXD_STAT_EOP)) {
 			/* this descriptor is only the beginning (or middle) */
 			if (!rxtop) {
@@ -4276,12 +4297,15 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 				                       flags);
 				length--;
 			} else {
+				if (netdev->features & NETIF_F_RXALL)
+					goto process_skb;
 				/* recycle */
 				buffer_info->skb = skb;
 				goto next_desc;
 			}
 		}
 
+process_skb:
 		total_rx_bytes += (length - 4); /* don't count FCS */
 		total_rx_packets++;
 
-- 
1.7.7.6
