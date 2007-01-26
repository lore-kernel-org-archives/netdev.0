From: shemminger@linux-foundation.org
Subject: [PATCH 4/5] sky2: software rx/tx stats
Date: Fri, 26 Jan 2007 11:38:39 -0800
Message-ID: <20070126194004.281546000@linux-foundation.org>
References: <20070126193835.658962000@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52041 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161218AbXAZTot (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 14:44:49 -0500
Content-Disposition: inline; filename=sky2-stats.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maintain packet statistics in software rather than hardware.
This is slightly slower, but allows easier debugging of problems
where packets are still being received by PHY but not being handled
by hardware.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


---
 drivers/net/sky2.c |   21 +++++----------------
 1 file changed, 5 insertions(+), 16 deletions(-)

--- sky2-2.6.orig/drivers/net/sky2.c	2007-01-26 11:27:40.000000000 -0800
+++ sky2-2.6/drivers/net/sky2.c	2007-01-26 11:27:42.000000000 -0800
@@ -1510,6 +1510,9 @@
 			if (unlikely(netif_msg_tx_done(sky2)))
 				printk(KERN_DEBUG "%s: tx done %u\n",
 				       dev->name, idx);
+			sky2->net_stats.tx_packets++;
+			sky2->net_stats.tx_bytes += re->skb->len;
+
 			dev_kfree_skb_any(re->skb);
 		}
 
@@ -2132,6 +2135,8 @@
 				goto force_update;
 
 			skb->protocol = eth_type_trans(skb, dev);
+			sky2->net_stats.rx_packets++;
+			sky2->net_stats.rx_bytes += skb->len;
 			dev->last_rx = jiffies;
 
 #ifdef SKY2_VLAN_TAG_USED
@@ -2893,25 +2898,9 @@
 	}
 }
 
-/* Use hardware MIB variables for critical path statistics and
- * transmit feedback not reported at interrupt.
- * Other errors are accounted for in interrupt handler.
- */
 static struct net_device_stats *sky2_get_stats(struct net_device *dev)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
-	u64 data[13];
-
-	sky2_phy_stats(sky2, data, ARRAY_SIZE(data));
-
-	sky2->net_stats.tx_bytes = data[0];
-	sky2->net_stats.rx_bytes = data[1];
-	sky2->net_stats.tx_packets = data[2] + data[4] + data[6];
-	sky2->net_stats.rx_packets = data[3] + data[5] + data[7];
-	sky2->net_stats.multicast = data[3] + data[5];
-	sky2->net_stats.collisions = data[10];
-	sky2->net_stats.tx_aborted_errors = data[12];
-
 	return &sky2->net_stats;
 }
 

--
Stephen Hemminger <shemminger@linux-foundation.org>

