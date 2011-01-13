From: Daniel Hellstrom <daniel@gaisler.com>
Subject: [PATCH 07/10] GRETH: fixed skb buffer memory leak on frame errors
Date: Thu, 13 Jan 2011 09:25:32 +0100
Message-ID: <1294907135-24884-7-git-send-email-daniel@gaisler.com>
References: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail201c2.megamailservers.com ([69.49.111.102]:39241 "EHLO
	mail201c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932796Ab1AMJAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 04:00:09 -0500
In-Reply-To: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A new SKB buffer should not be allocated when the old SKB is reused.

Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
---
 drivers/net/greth.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 72a4317..888dc65 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -880,10 +880,9 @@ static int greth_rx_gbit(struct net_device *dev, int limit)
 			}
 		}
 
-		/* Allocate new skb to replace current */
-		newskb = netdev_alloc_skb(dev, MAX_FRAME_SIZE + NET_IP_ALIGN);
-
-		if (!bad && newskb) {
+		/* Allocate new skb to replace current, not needed if the
+		 * current skb can be reused */
+		if (!bad && (newskb=netdev_alloc_skb(dev, MAX_FRAME_SIZE + NET_IP_ALIGN))) {
 			skb_reserve(newskb, NET_IP_ALIGN);
 
 			dma_addr = dma_map_single(greth->dev,
@@ -920,11 +919,22 @@ static int greth_rx_gbit(struct net_device *dev, int limit)
 				if (net_ratelimit())
 					dev_warn(greth->dev, "Could not create DMA mapping, dropping packet\n");
 				dev_kfree_skb(newskb);
+				/* reusing current skb, so it is a drop */
 				dev->stats.rx_dropped++;
 			}
+		} else if (bad) {
+			/* Bad Frame transfer, the skb is reused */
+			dev->stats.rx_dropped++;
 		} else {
+			/* Failed Allocating a new skb. This is rather stupid
+			 * but the current "filled" skb is reused, as if
+			 * transfer failure. One could argue that RX descriptor
+			 * table handling should be divided into cleaning and
+			 * filling as the TX part of the driver
+			 */
 			if (net_ratelimit())
 				dev_warn(greth->dev, "Could not allocate SKB, dropping packet\n");
+			/* reusing current skb, so it is a drop */
 			dev->stats.rx_dropped++;
 		}
 
-- 
1.5.4

