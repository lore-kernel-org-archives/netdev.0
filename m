From: greearb@candelatech.com
Subject: [PATCH v4] e1000: Support RX-ALL flag.
Date: Thu, 29 Mar 2012 15:47:50 -0700
Message-ID: <1333061270-4379-1-git-send-email-greearb@candelatech.com>
Cc: jeffrey.t.kirsher@intel.com, Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36726 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760218Ab2C2Wr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 18:47:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows the NIC to receive errored frames (bad FCS, etc)
and pass them up the stack.  This can be useful when using
sniffers.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 a680ee6... ab2f748... M	drivers/net/ethernet/intel/e1000/e1000_main.c
 drivers/net/ethernet/intel/e1000/e1000_main.c |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index a680ee6..ab2f748 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -826,9 +826,10 @@ static int e1000_set_features(struct net_device *netdev,
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
 	netdev->hw_features |= NETIF_F_RXFCS;
+	netdev->hw_features |= NETIF_F_RXALL;
 
 	if (pci_using_dac) {
 		netdev->features |= NETIF_F_HIGHDMA;
@@ -1807,7 +1809,7 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	rctl &= ~(3 << E1000_RCTL_MO_SHIFT);
 
 	rctl |= E1000_RCTL_BAM | E1000_RCTL_LBM_NO |
-		E1000_RCTL_RDMTS_HALF |
+		E1000_RCTL_RDMTS_HALF | E1000_RCTL_DPF |
 		(hw->mc_filter_type << E1000_RCTL_MO_SHIFT);
 
 	if (hw->tbi_compatibility_on == 1)
@@ -1840,6 +1842,16 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 			break;
 	}
 
+	/* This is useful for sniffing bad packets. */
+	if (adapter->netdev->features & NETIF_F_RXALL) {
+		/* UPE and MPE will be handled by normal PROMISC logic
+		 * in e1000e_set_rx_mode */
+		rctl |= (E1000_RCTL_SBP | /* Receive bad packets */
+			 E1000_RCTL_PMCF); /* RX All MAC Ctrl Pkts */
+
+		rctl &= ~(E1000_RCTL_DPF); /* Allow filtered pause */
+	}
+
 	ew32(RCTL, rctl);
 }
 
@@ -3845,6 +3857,8 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 				                       irq_flags);
 				length--;
 			} else {
+				if (netdev->features & NETIF_F_RXALL)
+					goto process_skb;
 				/* recycle both page and skb */
 				buffer_info->skb = skb;
 				/* an error means any chain goes out the window
@@ -3857,6 +3871,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		}
 
 #define rxtop rx_ring->rx_skb_top
+process_skb:
 		if (!(status & E1000_RXD_STAT_EOP)) {
 			/* this descriptor is only the beginning (or middle) */
 			if (!rxtop) {
@@ -4066,12 +4081,15 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
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
1.7.3.4
