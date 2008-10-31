From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] atlx: use embedded net_device_stats
Date: Fri, 31 Oct 2008 16:52:03 -0700
Message-ID: <20081031235325.698875766@vyatta.com>
References: <20081031235202.019379082@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52172 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750965AbYJaXyW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 19:54:22 -0400
Content-Disposition: inline; filename=atl2-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is now a net_device_stats structure inside net_device that should
be used if possible by devices. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/atlx/atl1.c	2008-10-31 16:04:14.000000000 -0700
+++ b/drivers/net/atlx/atl1.c	2008-10-31 16:37:50.000000000 -0700
@@ -1662,6 +1662,7 @@ static void atl1_via_workaround(struct a
 
 static void atl1_inc_smb(struct atl1_adapter *adapter)
 {
+	struct net_device *netdev = adapter->netdev;
 	struct stats_msg_block *smb = adapter->smb.smb;
 
 	/* Fill out the OS statistics structure */
@@ -1704,30 +1705,30 @@ static void atl1_inc_smb(struct atl1_ada
 	adapter->soft_stats.tx_trunc += smb->tx_trunc;
 	adapter->soft_stats.tx_pause += smb->tx_pause;
 
-	adapter->net_stats.rx_packets = adapter->soft_stats.rx_packets;
-	adapter->net_stats.tx_packets = adapter->soft_stats.tx_packets;
-	adapter->net_stats.rx_bytes = adapter->soft_stats.rx_bytes;
-	adapter->net_stats.tx_bytes = adapter->soft_stats.tx_bytes;
-	adapter->net_stats.multicast = adapter->soft_stats.multicast;
-	adapter->net_stats.collisions = adapter->soft_stats.collisions;
-	adapter->net_stats.rx_errors = adapter->soft_stats.rx_errors;
-	adapter->net_stats.rx_over_errors =
+	netdev->stats.rx_packets = adapter->soft_stats.rx_packets;
+	netdev->stats.tx_packets = adapter->soft_stats.tx_packets;
+	netdev->stats.rx_bytes = adapter->soft_stats.rx_bytes;
+	netdev->stats.tx_bytes = adapter->soft_stats.tx_bytes;
+	netdev->stats.multicast = adapter->soft_stats.multicast;
+	netdev->stats.collisions = adapter->soft_stats.collisions;
+	netdev->stats.rx_errors = adapter->soft_stats.rx_errors;
+	netdev->stats.rx_over_errors =
 		adapter->soft_stats.rx_missed_errors;
-	adapter->net_stats.rx_length_errors =
+	netdev->stats.rx_length_errors =
 		adapter->soft_stats.rx_length_errors;
-	adapter->net_stats.rx_crc_errors = adapter->soft_stats.rx_crc_errors;
-	adapter->net_stats.rx_frame_errors =
+	netdev->stats.rx_crc_errors = adapter->soft_stats.rx_crc_errors;
+	netdev->stats.rx_frame_errors =
 		adapter->soft_stats.rx_frame_errors;
-	adapter->net_stats.rx_fifo_errors = adapter->soft_stats.rx_fifo_errors;
-	adapter->net_stats.rx_missed_errors =
+	netdev->stats.rx_fifo_errors = adapter->soft_stats.rx_fifo_errors;
+	netdev->stats.rx_missed_errors =
 		adapter->soft_stats.rx_missed_errors;
-	adapter->net_stats.tx_errors = adapter->soft_stats.tx_errors;
-	adapter->net_stats.tx_fifo_errors = adapter->soft_stats.tx_fifo_errors;
-	adapter->net_stats.tx_aborted_errors =
+	netdev->stats.tx_errors = adapter->soft_stats.tx_errors;
+	netdev->stats.tx_fifo_errors = adapter->soft_stats.tx_fifo_errors;
+	netdev->stats.tx_aborted_errors =
 		adapter->soft_stats.tx_aborted_errors;
-	adapter->net_stats.tx_window_errors =
+	netdev->stats.tx_window_errors =
 		adapter->soft_stats.tx_window_errors;
-	adapter->net_stats.tx_carrier_errors =
+	netdev->stats.tx_carrier_errors =
 		adapter->soft_stats.tx_carrier_errors;
 }
 
@@ -1860,7 +1861,7 @@ static u16 atl1_alloc_rx_buffers(struct 
 				       adapter->rx_buffer_len + NET_IP_ALIGN);
 		if (unlikely(!skb)) {
 			/* Better luck next round */
-			adapter->net_stats.rx_dropped++;
+			adapter->netdev->stats.rx_dropped++;
 			break;
 		}
 
@@ -2982,7 +2983,7 @@ static int __devinit atl1_probe(struct p
 	netdev->open = &atl1_open;
 	netdev->stop = &atl1_close;
 	netdev->hard_start_xmit = &atl1_xmit_frame;
-	netdev->get_stats = &atlx_get_stats;
+
 	netdev->set_multicast_list = &atlx_set_multi;
 	netdev->set_mac_address = &atl1_set_mac;
 	netdev->change_mtu = &atl1_change_mtu;
@@ -3172,8 +3173,6 @@ static struct atl1_stats atl1_gstrings_s
 	{"tx_bytes", ATL1_STAT(soft_stats.tx_bytes)},
 	{"rx_errors", ATL1_STAT(soft_stats.rx_errors)},
 	{"tx_errors", ATL1_STAT(soft_stats.tx_errors)},
-	{"rx_dropped", ATL1_STAT(net_stats.rx_dropped)},
-	{"tx_dropped", ATL1_STAT(net_stats.tx_dropped)},
 	{"multicast", ATL1_STAT(soft_stats.multicast)},
 	{"collisions", ATL1_STAT(soft_stats.collisions)},
 	{"rx_length_errors", ATL1_STAT(soft_stats.rx_length_errors)},
--- a/drivers/net/atlx/atl1.h	2008-10-31 16:04:34.000000000 -0700
+++ b/drivers/net/atlx/atl1.h	2008-10-31 16:08:20.000000000 -0700
@@ -754,7 +754,7 @@ struct atl1_hw {
 struct atl1_adapter {
 	struct net_device *netdev;
 	struct pci_dev *pdev;
-	struct net_device_stats net_stats;
+
 	struct atl1_sft_stats soft_stats;
 	struct vlan_group *vlgrp;
 	u32 rx_buffer_len;
--- a/drivers/net/atlx/atl2.c	2008-10-31 16:03:26.000000000 -0700
+++ b/drivers/net/atlx/atl2.c	2008-10-31 16:39:03.000000000 -0700
@@ -418,7 +418,7 @@ static void atl2_intr_rx(struct atl2_ada
 				 * Check that some rx space is free. If not,
 				 * free one and mark stats->rx_dropped++.
 				 */
-				adapter->net_stats.rx_dropped++;
+				netdev->stats.rx_dropped++;
 				break;
 			}
 			skb_reserve(skb, NET_IP_ALIGN);
@@ -435,20 +435,20 @@ static void atl2_intr_rx(struct atl2_ada
 			} else
 #endif
 			netif_rx(skb);
-			adapter->net_stats.rx_bytes += rx_size;
-			adapter->net_stats.rx_packets++;
+			netdev->stats.rx_bytes += rx_size;
+			netdev->stats.rx_packets++;
 			netdev->last_rx = jiffies;
 		} else {
-			adapter->net_stats.rx_errors++;
+			netdev->stats.rx_errors++;
 
 			if (rxd->status.ok && rxd->status.pkt_size <= 60)
-				adapter->net_stats.rx_length_errors++;
+				netdev->stats.rx_length_errors++;
 			if (rxd->status.mcast)
-				adapter->net_stats.multicast++;
+				netdev->stats.multicast++;
 			if (rxd->status.crc)
-				adapter->net_stats.rx_crc_errors++;
+				netdev->stats.rx_crc_errors++;
 			if (rxd->status.align)
-				adapter->net_stats.rx_frame_errors++;
+				netdev->stats.rx_frame_errors++;
 		}
 
 		/* advance write ptr */
@@ -463,6 +463,7 @@ static void atl2_intr_rx(struct atl2_ada
 
 static void atl2_intr_tx(struct atl2_adapter *adapter)
 {
+	struct net_device *netdev = adapter->netdev;
 	u32 txd_read_ptr;
 	u32 txs_write_ptr;
 	struct tx_pkt_status *txs;
@@ -522,20 +523,20 @@ static void atl2_intr_tx(struct atl2_ada
 
 		/* tx statistics: */
 		if (txs->ok) {
-			adapter->net_stats.tx_bytes += txs->pkt_size;
-			adapter->net_stats.tx_packets++;
+			netdev->stats.tx_bytes += txs->pkt_size;
+			netdev->stats.tx_packets++;
 		}
 		else
-			adapter->net_stats.tx_errors++;
+			netdev->stats.tx_errors++;
 
 		if (txs->defer)
-			adapter->net_stats.collisions++;
+			netdev->stats.collisions++;
 		if (txs->abort_col)
-			adapter->net_stats.tx_aborted_errors++;
+			netdev->stats.tx_aborted_errors++;
 		if (txs->late_col)
-			adapter->net_stats.tx_window_errors++;
+			netdev->stats.tx_window_errors++;
 		if (txs->underun)
-			adapter->net_stats.tx_fifo_errors++;
+			netdev->stats.tx_fifo_errors++;
 	} while (1);
 
 	if (free_hole) {
@@ -621,7 +622,7 @@ static irqreturn_t atl2_intr(int irq, vo
 
 	/* link event */
 	if (status & (ISR_PHY | ISR_MANUAL)) {
-		adapter->net_stats.tx_carrier_errors++;
+		adapter->netdev->stats.tx_carrier_errors++;
 		atl2_check_for_link(adapter);
 	}
 
@@ -900,19 +901,6 @@ static int atl2_xmit_frame(struct sk_buf
 }
 
 /*
- * atl2_get_stats - Get System Network Statistics
- * @netdev: network interface device structure
- *
- * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
- */
-static struct net_device_stats *atl2_get_stats(struct net_device *netdev)
-{
-	struct atl2_adapter *adapter = netdev_priv(netdev);
-	return &adapter->net_stats;
-}
-
-/*
  * atl2_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
  * @new_mtu: new value for maximum frame size
@@ -1050,16 +1038,18 @@ static void atl2_tx_timeout(struct net_d
 static void atl2_watchdog(unsigned long data)
 {
 	struct atl2_adapter *adapter = (struct atl2_adapter *) data;
-	u32 drop_rxd, drop_rxs;
-	unsigned long flags;
 
 	if (!test_bit(__ATL2_DOWN, &adapter->flags)) {
+		u32 drop_rxd, drop_rxs;
+		unsigned long flags;
+
 		spin_lock_irqsave(&adapter->stats_lock, flags);
 		drop_rxd = ATL2_READ_REG(&adapter->hw, REG_STS_RXD_OV);
 		drop_rxs = ATL2_READ_REG(&adapter->hw, REG_STS_RXS_OV);
-		adapter->net_stats.rx_over_errors += (drop_rxd+drop_rxs);
 		spin_unlock_irqrestore(&adapter->stats_lock, flags);
 
+		adapter->netdev->stats.rx_over_errors += drop_rxd + drop_rxs;
+
 		/* Reset the timer */
 		mod_timer(&adapter->watchdog_timer, jiffies + 4 * HZ);
 	}
@@ -1396,7 +1386,6 @@ static int __devinit atl2_probe(struct p
 	netdev->open = &atl2_open;
 	netdev->stop = &atl2_close;
 	netdev->hard_start_xmit = &atl2_xmit_frame;
-	netdev->get_stats = &atl2_get_stats;
 	netdev->set_multicast_list = &atl2_set_multi;
 	netdev->set_mac_address = &atl2_set_mac;
 	netdev->change_mtu = &atl2_change_mtu;
--- a/drivers/net/atlx/atl2.h	2008-10-31 16:03:50.000000000 -0700
+++ b/drivers/net/atlx/atl2.h	2008-10-31 16:08:21.000000000 -0700
@@ -453,7 +453,6 @@ struct atl2_adapter {
 	/* OS defined structs */
 	struct net_device *netdev;
 	struct pci_dev *pdev;
-	struct net_device_stats net_stats;
 #ifdef NETIF_F_HW_VLAN_TX
 	struct vlan_group *vlgrp;
 #endif
--- a/drivers/net/atlx/atlx.c	2008-10-31 16:09:07.000000000 -0700
+++ b/drivers/net/atlx/atlx.c	2008-10-31 16:09:15.000000000 -0700
@@ -182,19 +182,6 @@ static void atlx_clear_phy_int(struct at
 }
 
 /*
- * atlx_get_stats - Get System Network Statistics
- * @netdev: network interface device structure
- *
- * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
- */
-static struct net_device_stats *atlx_get_stats(struct net_device *netdev)
-{
-	struct atlx_adapter *adapter = netdev_priv(netdev);
-	return &adapter->net_stats;
-}
-
-/*
  * atlx_tx_timeout - Respond to a Tx Hang
  * @netdev: network interface device structure
  */

-- 

