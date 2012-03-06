From: greearb@candelatech.com
Subject: [PATCH 2/2] igb: Support RX-ALL feature flag.
Date: Mon,  5 Mar 2012 17:30:41 -0800
Message-ID: <1330997441-13324-2-git-send-email-greearb@candelatech.com>
References: <1330997441-13324-1-git-send-email-greearb@candelatech.com>
Cc: jeffrey.t.kirsher@intel.com, Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57210 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758084Ab2CFBbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 20:31:07 -0500
In-Reply-To: <1330997441-13324-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows the NIC to receive all frames available, including
those with bad FCS, un-matched vlans, ethernet control frames,
and more.

Tested by sending frames with bad FCS.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 aed2174... 89eb1f8... M	drivers/net/ethernet/intel/igb/e1000_defines.h
:100644 100644 e4058ac... 41b905d... M	drivers/net/ethernet/intel/igb/igb_main.c
 drivers/net/ethernet/intel/igb/e1000_defines.h |    2 +
 drivers/net/ethernet/intel/igb/igb_main.c      |   33 ++++++++++++++++++++++-
 2 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index aed2174..89eb1f8 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -134,6 +134,8 @@
 #define E1000_RCTL_SZ_256         0x00030000    /* rx buffer size 256 */
 #define E1000_RCTL_VFE            0x00040000    /* vlan filter enable */
 #define E1000_RCTL_CFIEN          0x00080000    /* canonical form enable */
+#define E1000_RCTL_DPF            0x00400000    /* Discard Pause Frames */
+#define E1000_RCTL_PMCF           0x00800000    /* pass MAC control frames */
 #define E1000_RCTL_SECRC          0x04000000    /* Strip Ethernet CRC */
 
 /*
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index e4058ac..41b905d 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1769,10 +1769,21 @@ static int igb_set_features(struct net_device *netdev,
 	netdev_features_t features)
 {
 	netdev_features_t changed = netdev->features ^ features;
+	struct igb_adapter *adapter = netdev_priv(netdev);
 
 	if (changed & NETIF_F_HW_VLAN_RX)
 		igb_vlan_mode(netdev, features);
 
+	if (!(changed & NETIF_F_RXALL))
+		return 0;
+
+	netdev->features = features;
+
+	if (netif_running(netdev))
+		igb_reinit_locked(adapter);
+	else
+		igb_reset(adapter);
+
 	return 0;
 }
 
@@ -1954,6 +1965,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 	/* copy netdev features into list of user selectable features */
 	netdev->hw_features |= netdev->features;
+	netdev->hw_features |= NETIF_F_RXALL;
 
 	/* set this bit last since it cannot be part of hw_features */
 	netdev->features |= NETIF_F_HW_VLAN_FILTER;
@@ -3003,6 +3015,22 @@ void igb_setup_rctl(struct igb_adapter *adapter)
 		wr32(E1000_QDE, ALL_QUEUES);
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
 	wr32(E1000_RCTL, rctl);
 }
 
@@ -6101,8 +6129,9 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, int budget)
 			goto next_desc;
 		}
 
-		if (igb_test_staterr(rx_desc,
-				     E1000_RXDEXT_ERR_FRAME_ERR_MASK)) {
+		if (unlikely((igb_test_staterr(rx_desc,
+					       E1000_RXDEXT_ERR_FRAME_ERR_MASK))
+			     && !(rx_ring->netdev->features & NETIF_F_RXALL))) {
 			dev_kfree_skb_any(skb);
 			goto next_desc;
 		}
-- 
1.7.3.4
