From: greearb@candelatech.com
Subject: [PATCH v3 11/16] e1000:  Support RX-ALL flag.
Date: Fri, 10 Feb 2012 17:04:29 -0800
Message-ID: <1328922274-23993-12-git-send-email-greearb@candelatech.com>
References: <1328922274-23993-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55880 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761219Ab2BKBGW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 20:06:22 -0500
In-Reply-To: <1328922274-23993-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows the NIC to receive errored frames (bad FCS, etc)
and pass them up the stack.  This can be useful when using
sniffers.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 64b73bc... 59b8207... M	drivers/net/ethernet/intel/e1000/e1000_main.c
 drivers/net/ethernet/intel/e1000/e1000_main.c |   26 ++++++++++++++++++++++++-
 1 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 64b73bc..59b8207 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -824,9 +824,10 @@ static int e1000_set_features(struct net_device *netdev,
 	if (changed & NETIF_F_HW_VLAN_RX)
 		e1000_vlan_mode(netdev, features);
 
-	if (!(changed & NETIF_F_RXCSUM))
+	if (!(changed & (NETIF_F_RXCSUM | NETIF_F_RXALL)))
 		return 0;
 
+	netdev->features = features;
 	adapter->rx_csum = !!(features & NETIF_F_RXCSUM);
 
 	if (netif_running(netdev))
@@ -1071,6 +1072,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	netdev->features |= netdev->hw_features;
 	netdev->hw_features |= NETIF_F_RXCSUM;
+	netdev->hw_features |= NETIF_F_RXALL;
 
 	if (pci_using_dac) {
 		netdev->features |= NETIF_F_HIGHDMA;
@@ -1837,6 +1839,22 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
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
 
@@ -4066,6 +4084,8 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 				                       irq_flags);
 				length--;
 			} else {
+				if (netdev->features & NETIF_F_RXALL)
+					goto process_skb;
 				/* recycle both page and skb */
 				buffer_info->skb = skb;
 				/* an error means any chain goes out the window
@@ -4078,6 +4098,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		}
 
 #define rxtop rx_ring->rx_skb_top
+process_skb:
 		if (!(status & E1000_RXD_STAT_EOP)) {
 			/* this descriptor is only the beginning (or middle) */
 			if (!rxtop) {
@@ -4288,12 +4309,15 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
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
 		/* adjust length to remove Ethernet CRC, this must be
 		 * done after the TBI_ACCEPT workaround above */
 		length -= 4;
-- 
1.7.3.4
