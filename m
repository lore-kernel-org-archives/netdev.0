From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 4/5] mv643xx_eth: fix NULL pointer dereference in rxq_process()
Date: Sun, 24 Aug 2008 04:05:48 +0200
Message-ID: <20080824020548.GE8762@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>, Nicolas Pitre <nico@cam.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:57610 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbYHXCFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 22:05:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we are low on memory, the assumption that every descriptor in the
receive ring will have an skbuff associated with it does not hold.

rxq_process() was assuming that if the receive descriptor it is working
on is not owned by the hardware, it can safely be processed and handed
to the networking stack.  But a descriptor in the receive ring not being
owned by the hardware can also happen when we are low on memory and did
not manage to refill the receive ring fully.

This patch changes rxq_process()'s bailout condition from "the first
receive descriptor to be processed is owned by the hardware" to "the
first receive descriptor to be processed is owned by the hardware OR
the number of valid receive descriptors in the ring is zero".

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 30e6d4b..e33dfc0 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -527,7 +527,7 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 	int rx;
 
 	rx = 0;
-	while (rx < budget) {
+	while (rx < budget && rxq->rx_desc_count) {
 		struct rx_desc *rx_desc;
 		unsigned int cmd_sts;
 		struct sk_buff *skb;
-- 
1.5.6.4
