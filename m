From: ganesh.venkatesan@intel.com
Subject: [PATCH 3/6 2.5] e100 - fix stat counters rx_length_error and
 rx_over_error
Date: Thu, 29 Jul 2004 08:26:38 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290652280.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--- linux-2.5/drivers/net/e100.c	2004-07-29 00:26:06.001930872 -0700
+++ linux-2.5/drivers/net/e100.c.mod	2004-07-29 00:27:27.360562480 -0700
@@ -551,6 +551,7 @@ struct nic {
 	u32 rx_fc_pause;
 	u32 rx_fc_unsupported;
 	u32 rx_tco_frames;
+	u32 rx_over_length_errors;
 
 	u8 rev_id;
 	u16 leds;
@@ -1146,9 +1147,11 @@ static void e100_update_stats(struct nic
 		ns->tx_errors += le32_to_cpu(s->tx_max_collisions) +
 			le32_to_cpu(s->tx_lost_crs);
 		ns->rx_dropped += le32_to_cpu(s->rx_resource_errors);
-		ns->rx_length_errors += le32_to_cpu(s->rx_short_frame_errors);
+		ns->rx_length_errors += le32_to_cpu(s->rx_short_frame_errors) +
+			nic->rx_over_length_errors;
 		ns->rx_crc_errors += le32_to_cpu(s->rx_crc_errors);
 		ns->rx_frame_errors += le32_to_cpu(s->rx_alignment_errors);
+		ns->rx_over_errors += le32_to_cpu(s->rx_overrun_errors);
 		ns->rx_fifo_errors += le32_to_cpu(s->rx_overrun_errors);
 		ns->rx_errors += le32_to_cpu(s->rx_crc_errors) +
 			le32_to_cpu(s->rx_alignment_errors) +
@@ -1459,7 +1462,7 @@ static inline int e100_rx_indicate(struc
 		dev_kfree_skb_any(skb);
 	} else if(actual_size > nic->netdev->mtu + VLAN_ETH_HLEN) {
 		/* Don't indicate oversized frames */
-		nic->net_stats.rx_over_errors++;
+		nic->rx_over_length_errors++;
 		nic->net_stats.rx_dropped++;
 		dev_kfree_skb_any(skb);
 	} else {
