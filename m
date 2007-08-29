From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 07/12] sky2: use net_device internal stats
Date: Wed, 29 Aug 2007 12:58:16 -0700
Message-ID: <20070829195843.025028477@linux-foundation.org>
References: <20070829193922.078561651@linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49210 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755026AbXH2UBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 16:01:36 -0400
Content-Disposition: inline; filename=sky2-int-stats.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver can just use the internal network stats block.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-08-29 11:41:10.000000000 -0700
+++ b/drivers/net/sky2.c	2007-08-29 11:41:16.000000000 -0700
@@ -1606,8 +1606,8 @@ static void sky2_tx_complete(struct sky2
 				printk(KERN_DEBUG "%s: tx done %u\n",
 				       dev->name, idx);
 
-			sky2->net_stats.tx_packets++;
-			sky2->net_stats.tx_bytes += re->skb->len;
+			dev->stats.tx_packets++;
+			dev->stats.tx_bytes += re->skb->len;
 
 			dev_kfree_skb_any(re->skb);
 			sky2->tx_next = RING_NEXT(idx, TX_RING_SIZE);
@@ -2163,12 +2163,12 @@ resubmit:
 len_mismatch:
 	/* Truncation of overlength packets
 	   causes PHY length to not match MAC length */
-	++sky2->net_stats.rx_length_errors;
+	++dev->stats.rx_length_errors;
 
 error:
-	++sky2->net_stats.rx_errors;
+	++dev->stats.rx_errors;
 	if (status & GMR_FS_RX_FF_OV) {
-		sky2->net_stats.rx_over_errors++;
+		dev->stats.rx_over_errors++;
 		goto resubmit;
 	}
 
@@ -2177,11 +2177,11 @@ error:
 		       dev->name, status, length);
 
 	if (status & (GMR_FS_LONG_ERR | GMR_FS_UN_SIZE))
-		sky2->net_stats.rx_length_errors++;
+		dev->stats.rx_length_errors++;
 	if (status & GMR_FS_FRAGMENT)
-		sky2->net_stats.rx_frame_errors++;
+		dev->stats.rx_frame_errors++;
 	if (status & GMR_FS_CRC_ERR)
-		sky2->net_stats.rx_crc_errors++;
+		dev->stats.rx_crc_errors++;
 
 	goto resubmit;
 }
@@ -2228,7 +2228,7 @@ static int sky2_status_intr(struct sky2_
 			++rx[port];
 			skb = sky2_receive(dev, length, status);
 			if (unlikely(!skb)) {
-				sky2->net_stats.rx_dropped++;
+				dev->stats.rx_dropped++;
 				break;
 			}
 
@@ -2243,8 +2243,8 @@ static int sky2_status_intr(struct sky2_
 			}
 
 			skb->protocol = eth_type_trans(skb, dev);
-			sky2->net_stats.rx_packets++;
-			sky2->net_stats.rx_bytes += skb->len;
+			dev->stats.rx_packets++;
+			dev->stats.rx_bytes += skb->len;
 			dev->last_rx = jiffies;
 
 #ifdef SKY2_VLAN_TAG_USED
@@ -2429,12 +2429,12 @@ static void sky2_mac_intr(struct sky2_hw
 		gma_read16(hw, port, GM_TX_IRQ_SRC);
 
 	if (status & GM_IS_RX_FF_OR) {
-		++sky2->net_stats.rx_fifo_errors;
+		++dev->stats.rx_fifo_errors;
 		sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_CLI_RX_FO);
 	}
 
 	if (status & GM_IS_TX_FF_UR) {
-		++sky2->net_stats.tx_fifo_errors;
+		++dev->stats.tx_fifo_errors;
 		sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_CLI_TX_FU);
 	}
 }
@@ -3087,12 +3087,6 @@ static void sky2_get_strings(struct net_
 	}
 }
 
-static struct net_device_stats *sky2_get_stats(struct net_device *dev)
-{
-	struct sky2_port *sky2 = netdev_priv(dev);
-	return &sky2->net_stats;
-}
-
 static int sky2_set_mac_address(struct net_device *dev, void *p)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
@@ -3802,7 +3796,7 @@ static __devinit struct net_device *sky2
 	dev->stop = sky2_down;
 	dev->do_ioctl = sky2_ioctl;
 	dev->hard_start_xmit = sky2_xmit_frame;
-	dev->get_stats = sky2_get_stats;
+
 	dev->set_multicast_list = sky2_set_multicast;
 	dev->set_mac_address = sky2_set_mac_address;
 	dev->change_mtu = sky2_change_mtu;
--- a/drivers/net/sky2.h	2007-08-29 11:41:10.000000000 -0700
+++ b/drivers/net/sky2.h	2007-08-29 11:41:16.000000000 -0700
@@ -2019,8 +2019,6 @@ struct sky2_port {
 #ifdef CONFIG_SKY2_DEBUG
 	struct dentry	     *debugfs;
 #endif
-	struct net_device_stats net_stats;
-
 };
 
 struct sky2_hw {

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

