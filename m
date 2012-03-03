From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/10] e100: Support RXALL feature flag.
Date: Fri,  2 Mar 2012 18:24:19 -0800
Message-ID: <1330741468-23900-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:47073 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886Ab2CCCYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 21:24:33 -0500
In-Reply-To: <1330741468-23900-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows the NIC to receive packets with bad FCS
and other errors.  Good for sniffing packets on flakey
networks.

v4:  Only flax rx-over-length errors if pkt is beyond
   maximum expected packet size, not just beyond the MTU.
   This matches the existing logic for this counter.

Signed-off-by: Ben Greear <greearb@candelatech.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e100.c |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 6f9f70a..4d8a616 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -462,7 +462,7 @@ struct config {
 /*5*/	u8 X(tx_dma_max_count:7, dma_max_count_enable:1);
 /*6*/	u8 X(X(X(X(X(X(X(late_scb_update:1, direct_rx_dma:1),
 	   tno_intr:1), cna_intr:1), standard_tcb:1), standard_stat_counter:1),
-	   rx_discard_overruns:1), rx_save_bad_frames:1);
+	   rx_save_overruns : 1), rx_save_bad_frames : 1);
 /*7*/	u8 X(X(X(X(X(rx_discard_short_frames:1, tx_underrun_retry:2),
 	   pad7:2), rx_extended_rfd:1), tx_two_frames_in_fifo:1),
 	   tx_dynamic_tbd:1);
@@ -1165,6 +1165,12 @@ static void e100_configure(struct nic *nic, struct cb *cb, struct sk_buff *skb)
 		}
 	}
 
+	if (netdev->features & NETIF_F_RXALL) {
+		config->rx_save_overruns = 0x1; /* 1=save, 0=discard */
+		config->rx_save_bad_frames = 0x1;       /* 1=save, 0=discard */
+		config->rx_discard_short_frames = 0x0;  /* 1=discard, 0=save */
+	}
+
 	netif_printk(nic, hw, KERN_DEBUG, nic->netdev,
 		     "[00-07]=%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X\n",
 		     c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7]);
@@ -1999,6 +2005,16 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 	skb_put(skb, actual_size);
 	skb->protocol = eth_type_trans(skb, nic->netdev);
 
+	/* If we are receiving all frames, then don't bother
+	 * checking for errors.
+	 */
+	if (unlikely(dev->features & NETIF_F_RXALL)) {
+		if (actual_size > ETH_DATA_LEN + VLAN_ETH_HLEN + fcs_pad)
+			/* Received oversized frame, but keep it. */
+			nic->rx_over_length_errors++;
+		goto process_skb;
+	}
+
 	if (unlikely(!(rfd_status & cb_ok))) {
 		/* Don't indicate if hardware indicates errors */
 		dev_kfree_skb_any(skb);
@@ -2007,6 +2023,7 @@ static int e100_rx_indicate(struct nic *nic, struct rx *rx,
 		nic->rx_over_length_errors++;
 		dev_kfree_skb_any(skb);
 	} else {
+process_skb:
 		dev->stats.rx_packets++;
 		dev->stats.rx_bytes += (actual_size - fcs_pad);
 		netif_receive_skb(skb);
@@ -2758,7 +2775,7 @@ static int e100_set_features(struct net_device *netdev,
 	struct nic *nic = netdev_priv(netdev);
 	netdev_features_t changed = features ^ netdev->features;
 
-	if (!(changed & (NETIF_F_RXFCS)))
+	if (!(changed & (NETIF_F_RXFCS | NETIF_F_RXALL)))
 		return 0;
 
 	netdev->features = features;
@@ -2794,6 +2811,7 @@ static int __devinit e100_probe(struct pci_dev *pdev,
 
 	netdev->hw_features |= NETIF_F_RXFCS;
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
+	netdev->hw_features |= NETIF_F_RXALL;
 
 	netdev->netdev_ops = &e100_netdev_ops;
 	SET_ETHTOOL_OPS(netdev, &e100_ethtool_ops);
-- 
1.7.7.6
