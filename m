From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 4/5] mv643xx_eth: avoid reading ->byte_cnt twice during receive processing
Date: Sun, 14 Sep 2008 19:14:49 +0200
Message-ID: <20080914171449.GF28798@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:47777 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754127AbYINROu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 13:14:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the receive processing reads ->byte_cnt twice (once to
update interface statistics and once to properly size the data area
of the received skb), but since receive descriptors live in uncached
memory, caching this value in a local variable saves one uncached
access, and increases routing performance a tiny little bit more.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 4fbd62e..6564be1 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -477,6 +477,7 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 		struct rx_desc *rx_desc;
 		unsigned int cmd_sts;
 		struct sk_buff *skb;
+		u16 byte_cnt;
 
 		rx_desc = &rxq->rx_desc_area[rxq->rx_curr_desc];
 
@@ -499,6 +500,8 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 
 		mp->work_rx_refill |= 1 << rxq->index;
 
+		byte_cnt = rx_desc->byte_cnt;
+
 		/*
 		 * Update statistics.
 		 *
@@ -508,7 +511,7 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 		 * byte CRC at the end of the packet (which we do count).
 		 */
 		stats->rx_packets++;
-		stats->rx_bytes += rx_desc->byte_cnt - 2;
+		stats->rx_bytes += byte_cnt - 2;
 
 		/*
 		 * In case we received a packet without first / last bits
@@ -537,7 +540,7 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 			 * The -4 is for the CRC in the trailer of the
 			 * received packet
 			 */
-			skb_put(skb, rx_desc->byte_cnt - 2 - 4);
+			skb_put(skb, byte_cnt - 2 - 4);
 
 			if (cmd_sts & LAYER_4_CHECKSUM_OK) {
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
-- 
1.5.6.4
