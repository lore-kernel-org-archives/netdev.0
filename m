From: greearb@candelatech.com
Subject: [PATCH 2/2] ixgbe: Support RX-ALL feature flag.
Date: Mon,  5 Mar 2012 17:18:24 -0800
Message-ID: <1330996704-13076-2-git-send-email-greearb@candelatech.com>
References: <1330996704-13076-1-git-send-email-greearb@candelatech.com>
Cc: jeffrey.t.kirsher@intel.com, Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40987 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758142Ab2CFBU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 20:20:56 -0500
In-Reply-To: <1330996704-13076-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows the NIC to receive all frames available, including
those with bad FCS, ethernet control frames, and more.

Tested by sending frames with bad FCS.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 b6e51f9... c32be9d... M	drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   23 ++++++++++++++++++++++-
 1 files changed, 22 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b6e51f9..c32be9d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1605,7 +1605,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 
 		/* ERR_MASK will only have valid bits if EOP set */
 		if (unlikely(ixgbe_test_staterr(rx_desc,
-					    IXGBE_RXDADV_ERR_FRAME_ERR_MASK))) {
+					    IXGBE_RXDADV_ERR_FRAME_ERR_MASK) &&
+			     !(adapter->netdev->features & NETIF_F_RXALL))) {
 			dev_kfree_skb_any(skb);
 			goto next_desc;
 		}
@@ -3441,6 +3442,7 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 	fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
 
 	/* set all bits that we expect to always be set */
+	fctrl &= ~IXGBE_FCTRL_SBP; /* disable store-bad-packets */
 	fctrl |= IXGBE_FCTRL_BAM;
 	fctrl |= IXGBE_FCTRL_DPF; /* discard pause frames when FC enabled */
 	fctrl |= IXGBE_FCTRL_PMCF;
@@ -3489,6 +3491,18 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 		IXGBE_WRITE_REG(hw, IXGBE_VMOLR(adapter->num_vfs), vmolr);
 	}
 
+	/* This is useful for sniffing bad packets. */
+	if (adapter->netdev->features & NETIF_F_RXALL) {
+		/* UPE and MPE will be handled by normal PROMISC logic
+		 * in e1000e_set_rx_mode */
+		fctrl |= (IXGBE_FCTRL_SBP | /* Receive bad packets */
+			  IXGBE_FCTRL_BAM | /* RX All Bcast Pkts */
+			  IXGBE_FCTRL_PMCF); /* RX All MAC Ctrl Pkts */
+
+		fctrl &= ~(IXGBE_FCTRL_DPF);
+		/* NOTE:  VLAN filtering is disabled by setting PROMISC */
+	}
+
 	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl);
 
 	if (netdev->features & NETIF_F_HW_VLAN_RX)
@@ -7443,6 +7457,7 @@ static int ixgbe_set_features(struct net_device *netdev,
 	netdev_features_t data)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	netdev_features_t changed = netdev->features ^ data;
 	bool need_reset = false;
 
 	/* Make sure RSC matches LRO, reset if change */
@@ -7479,6 +7494,10 @@ static int ixgbe_set_features(struct net_device *netdev,
 		need_reset = true;
 	}
 
+	if (changed & NETIF_F_RXALL)
+		need_reset = true;
+
+	netdev->features = data;
 	if (need_reset)
 		ixgbe_do_reset(netdev);
 
@@ -7757,6 +7776,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		break;
 	}
 
+	netdev->hw_features |= NETIF_F_RXALL;
+
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
 	netdev->vlan_features |= NETIF_F_IP_CSUM;
-- 
1.7.3.4
