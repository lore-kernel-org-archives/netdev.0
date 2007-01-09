From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 12/12] forcedeth: statistics optimization
Date: Tue, 09 Jan 2007 13:30:32 -0500
Message-ID: <45A3DF48.9010400@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070901090709000700090701"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:5250 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932401AbXAIVX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 16:23:29 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070901090709000700090701
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch optimizes the data paths that can support hw counters. It 
removes the sw counted statistics.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------070901090709000700090701
Content-Type: text/plain;
 name="patch-stats-opti"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-stats-opti"

--- orig/drivers/net/forcedeth.c	2007-01-08 18:32:08.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-01-08 18:42:58.000000000 -0500
@@ -1351,10 +1351,19 @@
 {
 	struct fe_priv *np = netdev_priv(dev);
 
-	/* It seems that the nic always generates interrupts and doesn't
-	 * accumulate errors internally. Thus the current values in np->stats
-	 * are already up to date.
-	 */
+	/* If the nic supports hw counters then retrieve latest values */
+	if (np->driver_data & (DEV_HAS_STATISTICS_V1|DEV_HAS_STATISTICS_V2)) {
+		nv_get_hw_stats(dev);
+
+		/* copy to net_device stats */
+		np->stats.tx_bytes = np->estats.tx_bytes;
+		np->stats.tx_fifo_errors = np->estats.tx_fifo_errors;
+		np->stats.tx_carrier_errors = np->estats.tx_carrier_errors;
+		np->stats.rx_crc_errors = np->estats.rx_crc_errors;
+		np->stats.rx_over_errors = np->estats.rx_over_errors;
+		np->stats.rx_errors = np->estats.rx_errors_total;
+		np->stats.tx_errors = np->estats.tx_errors_total;
+	}
 	return &np->stats;
 }
 
@@ -1944,16 +1953,8 @@
 		np->get_tx_ctx->dma = 0;
 
 		if (flags & NV_TX2_LASTPACKET) {
-			if (flags & NV_TX2_ERROR) {
-				if (flags & NV_TX2_UNDERFLOW)
-					np->stats.tx_fifo_errors++;
-				if (flags & NV_TX2_CARRIERLOST)
-					np->stats.tx_carrier_errors++;
-				np->stats.tx_errors++;
-			} else {
+			if (!(flags & NV_TX2_ERROR))
 				np->stats.tx_packets++;
-				np->stats.tx_bytes += np->get_tx_ctx->skb->len;
-			}
 			dev_kfree_skb_any(np->get_tx_ctx->skb);
 			np->get_tx_ctx->skb = NULL;
 		}
@@ -2290,7 +2291,6 @@
 				if (flags & NV_RX2_ERROR4) {
 					len = nv_getlen(dev, skb->data, len);
 					if (len < 0) {
-						np->stats.rx_errors++;
 						dev_kfree_skb(skb);
 						goto next_pkt;
 					}
@@ -2303,11 +2303,6 @@
 				}
 				/* the rest are hard errors */
 				else {
-					if (flags & NV_RX2_CRCERR)
-						np->stats.rx_crc_errors++;
-					if (flags & NV_RX2_OVERFLOW)
-						np->stats.rx_over_errors++;
-					np->stats.rx_errors++;
 					dev_kfree_skb(skb);
 					goto next_pkt;
 				}

--------------070901090709000700090701--
