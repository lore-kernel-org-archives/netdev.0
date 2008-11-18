From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 5/6] mv643xx_eth: move receive error handling out of line
Date: Tue, 18 Nov 2008 23:30:09 +0100
Message-ID: <20081118223008.GW5006@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:38086 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065AbYKRWaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 17:30:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   59 +++++++++++++++++++++++---------------------
 1 files changed, 31 insertions(+), 28 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 9f3ee7d..d56724a 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -543,35 +543,38 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 		 * on, or the error summary bit is set, the packet needs
 		 * to be dropped.
 		 */
-		if (((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
-					(RX_FIRST_DESC | RX_LAST_DESC))
-				|| (cmd_sts & ERROR_SUMMARY)) {
-			stats->rx_dropped++;
-
-			if ((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
-				(RX_FIRST_DESC | RX_LAST_DESC)) {
-				if (net_ratelimit())
-					dev_printk(KERN_ERR, &mp->dev->dev,
-						   "received packet spanning "
-						   "multiple descriptors\n");
-			}
+		if ((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC | ERROR_SUMMARY))
+			!= (RX_FIRST_DESC | RX_LAST_DESC))
+			goto err;
 
-			if (cmd_sts & ERROR_SUMMARY)
-				stats->rx_errors++;
+		/*
+		 * The -4 is for the CRC in the trailer of the
+		 * received packet
+		 */
+		skb_put(skb, byte_cnt - 2 - 4);
 
-			dev_kfree_skb(skb);
-		} else {
-			/*
-			 * The -4 is for the CRC in the trailer of the
-			 * received packet
-			 */
-			skb_put(skb, byte_cnt - 2 - 4);
-
-			if (cmd_sts & LAYER_4_CHECKSUM_OK)
-				skb->ip_summed = CHECKSUM_UNNECESSARY;
-			skb->protocol = eth_type_trans(skb, mp->dev);
-			netif_receive_skb(skb);
+		if (cmd_sts & LAYER_4_CHECKSUM_OK)
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		skb->protocol = eth_type_trans(skb, mp->dev);
+		netif_receive_skb(skb);
+
+		continue;
+
+err:
+		stats->rx_dropped++;
+
+		if ((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
+			(RX_FIRST_DESC | RX_LAST_DESC)) {
+			if (net_ratelimit())
+				dev_printk(KERN_ERR, &mp->dev->dev,
+					   "received packet spanning "
+					   "multiple descriptors\n");
 		}
+
+		if (cmd_sts & ERROR_SUMMARY)
+			stats->rx_errors++;
+
+		dev_kfree_skb(skb);
 	}
 
 	if (rx < budget)
-- 
1.5.6.4
