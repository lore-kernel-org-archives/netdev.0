From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/16] e1000e: Support RXALL feature flag.
Date: Fri, 24 Feb 2012 02:12:59 -0800
Message-ID: <1330078389-8203-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43469 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756194Ab2BXKNP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 05:13:15 -0500
In-Reply-To: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows the NIC to receive all frames available, including
those with bad FCS, un-matched vlans, ethernet control frames,
and more.

Tested by sending frames with bad FCS.

Signed-off-by: Ben Greear <greearb@candelatech.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/defines.h |    1 +
 drivers/net/ethernet/intel/e1000e/netdev.c  |   29 +++++++++++++++++++++++---
 2 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
index 1af30b9..3a50259 100644
--- a/drivers/net/ethernet/intel/e1000e/defines.h
+++ b/drivers/net/ethernet/intel/e1000e/defines.h
@@ -177,6 +177,7 @@
 #define E1000_RCTL_VFE            0x00040000    /* vlan filter enable */
 #define E1000_RCTL_CFIEN          0x00080000    /* canonical form enable */
 #define E1000_RCTL_CFI            0x00100000    /* canonical form indicator */
+#define E1000_RCTL_DPF            0x00400000    /* Discard Pause Frames */
 #define E1000_RCTL_PMCF           0x00800000    /* pass MAC control frames */
 #define E1000_RCTL_BSEX           0x02000000    /* Buffer size extension */
 #define E1000_RCTL_SECRC          0x04000000    /* Strip Ethernet CRC */
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 340442c..c30e99e 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -926,7 +926,8 @@ static bool e1000_clean_rx_irq(struct e1000_ring *rx_ring, int *work_done,
 			goto next_desc;
 		}
 
-		if (staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK) {
+		if (unlikely((staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK) &&
+			     !(netdev->features & NETIF_F_RXALL))) {
 			/* recycle */
 			buffer_info->skb = skb;
 			goto next_desc;
@@ -1255,7 +1256,8 @@ static bool e1000_clean_rx_irq_ps(struct e1000_ring *rx_ring, int *work_done,
 			goto next_desc;
 		}
 
-		if (staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK) {
+		if (unlikely((staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK) &&
+			     !(netdev->features & NETIF_F_RXALL))) {
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
 		}
@@ -1454,7 +1456,8 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_ring *rx_ring, int *work_done,
 
 		/* errors is only valid for DD + EOP descriptors */
 		if (unlikely((staterr & E1000_RXD_STAT_EOP) &&
-			     (staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK))) {
+			     ((staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK) &&
+			      !(netdev->features & NETIF_F_RXALL)))) {
 			/* recycle both page and skb */
 			buffer_info->skb = skb;
 			/* an error means any chain goes out the window too */
@@ -2997,6 +3000,22 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 		ew32(PSRCTL, psrctl);
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
 	ew32(RFCTL, rfctl);
 	ew32(RCTL, rctl);
 	/* just started the receive unit, no need to restart */
@@ -6005,7 +6024,8 @@ static int e1000_set_features(struct net_device *netdev,
 		adapter->flags |= FLAG_TSO_FORCE;
 
 	if (!(changed & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX |
-			 NETIF_F_RXCSUM | NETIF_F_RXHASH | NETIF_F_RXFCS)))
+			 NETIF_F_RXCSUM | NETIF_F_RXHASH | NETIF_F_RXFCS |
+			 NETIF_F_RXALL)))
 		return 0;
 
 	/*
@@ -6233,6 +6253,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	netdev->hw_features = netdev->features;
 	netdev->hw_features |= NETIF_F_RXFCS;
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
+	netdev->hw_features |= NETIF_F_RXALL;
 
 	if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER)
 		netdev->features |= NETIF_F_HW_VLAN_FILTER;
-- 
1.7.7.6
