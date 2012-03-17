From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/12] ixgbe: Support RX-ALL feature flag.
Date: Sat, 17 Mar 2012 01:50:52 -0700
Message-ID: <1331974260-6383-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:56951 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755618Ab2CQIva (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 04:51:30 -0400
In-Reply-To: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows the NIC to receive all frames available, including
those with bad FCS, ethernet control frames, and more.

Tested by sending frames with bad FCS.

Signed-off-by: Ben Greear <greearb@candelatech.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   25 +++++++++++++++++++++++--
 1 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 986897b..cae763c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1482,8 +1482,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	struct sk_buff *skb;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 	const int current_node = numa_node_id();
-#ifdef IXGBE_FCOE
 	struct ixgbe_adapter *adapter = q_vector->adapter;
+#ifdef IXGBE_FCOE
 	int ddp_bytes = 0;
 #endif /* IXGBE_FCOE */
 	u16 i;
@@ -1612,7 +1612,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 
 		/* ERR_MASK will only have valid bits if EOP set */
 		if (unlikely(ixgbe_test_staterr(rx_desc,
-					    IXGBE_RXDADV_ERR_FRAME_ERR_MASK))) {
+					    IXGBE_RXDADV_ERR_FRAME_ERR_MASK) &&
+		    !(adapter->netdev->features & NETIF_F_RXALL))) {
 			dev_kfree_skb_any(skb);
 			goto next_desc;
 		}
@@ -3342,6 +3343,7 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 	fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
 
 	/* set all bits that we expect to always be set */
+	fctrl &= ~IXGBE_FCTRL_SBP; /* disable store-bad-packets */
 	fctrl |= IXGBE_FCTRL_BAM;
 	fctrl |= IXGBE_FCTRL_DPF; /* discard pause frames when FC enabled */
 	fctrl |= IXGBE_FCTRL_PMCF;
@@ -3390,6 +3392,18 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
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
@@ -7459,6 +7473,7 @@ static int ixgbe_set_features(struct net_device *netdev,
 	netdev_features_t data)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	netdev_features_t changed = netdev->features ^ data;
 	bool need_reset = false;
 
 	/* Make sure RSC matches LRO, reset if change */
@@ -7495,6 +7510,10 @@ static int ixgbe_set_features(struct net_device *netdev,
 		need_reset = true;
 	}
 
+	if (changed & NETIF_F_RXALL)
+		need_reset = true;
+
+	netdev->features = data;
 	if (need_reset)
 		ixgbe_do_reset(netdev);
 
@@ -7773,6 +7792,8 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		break;
 	}
 
+	netdev->hw_features |= NETIF_F_RXALL;
+
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
 	netdev->vlan_features |= NETIF_F_IP_CSUM;
-- 
1.7.7.6
