From: greearb@candelatech.com
Subject: [PATCH v2 08/10] e1000e:  Support RXALL feature flag.
Date: Wed,  8 Feb 2012 11:54:43 -0800
Message-ID: <1328730885-10941-9-git-send-email-greearb@candelatech.com>
References: <1328730885-10941-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55722 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755304Ab2BHT4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 14:56:22 -0500
In-Reply-To: <1328730885-10941-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows the NIC to receive all frames available, including
those with bad FCS, un-matched vlans, ethernet control frames,
and more.

Tested by sending frames with bad FCS.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 1af30b9... 3a50259... M	drivers/net/ethernet/intel/e1000e/defines.h
:100644 100644 2f9434c... 9905f45... M	drivers/net/ethernet/intel/e1000e/netdev.c
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
index 2f9434c..9905f45 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -929,7 +929,8 @@ static bool e1000_clean_rx_irq(struct e1000_ring *rx_ring, int *work_done,
 			goto next_desc;
 		}
 
-		if (staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK) {
+		if (unlikely((staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK) &&
+			     !(netdev->features & NETIF_F_RXALL))) {
 			/* recycle */
 			buffer_info->skb = skb;
 			goto next_desc;
@@ -1258,7 +1259,8 @@ static bool e1000_clean_rx_irq_ps(struct e1000_ring *rx_ring, int *work_done,
 			goto next_desc;
 		}
 
-		if (staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK) {
+		if (unlikely((staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK) &&
+			     !(netdev->features & NETIF_F_RXALL))) {
 			dev_kfree_skb_irq(skb);
 			goto next_desc;
 		}
@@ -1457,7 +1459,8 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_ring *rx_ring, int *work_done,
 
 		/* errors is only valid for DD + EOP descriptors */
 		if (unlikely((staterr & E1000_RXD_STAT_EOP) &&
-			     (staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK))) {
+			     ((staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK) &&
+			      !(netdev->features & NETIF_F_RXALL)))) {
 			/* recycle both page and skb */
 			buffer_info->skb = skb;
 			/* an error means any chain goes out the window too */
@@ -3002,6 +3005,22 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
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
@@ -6010,7 +6029,8 @@ static int e1000_set_features(struct net_device *netdev,
 		adapter->flags |= FLAG_TSO_FORCE;
 
 	if (!(changed & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX |
-			 NETIF_F_RXCSUM | NETIF_F_RXHASH | NETIF_F_RXFCS)))
+			 NETIF_F_RXCSUM | NETIF_F_RXHASH | NETIF_F_RXFCS |
+			 NETIF_F_RXALL)))
 		return 0;
 
 	/*
@@ -6238,6 +6258,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	netdev->hw_features = netdev->features;
 	netdev->hw_features |= NETIF_F_RXFCS;
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
+	netdev->hw_features |= NETIF_F_RXALL;
 
 	if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER)
 		netdev->features |= NETIF_F_HW_VLAN_FILTER;
-- 
1.7.3.4
