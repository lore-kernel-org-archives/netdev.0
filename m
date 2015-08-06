From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH 1/3] net: mvpp2: remove excessive spinlocks from driver initialization
Date: Thu,  6 Aug 2015 19:00:28 +0200
Message-ID: <1438880430-5480-2-git-send-email-mw@semihalf.com>
References: <y>
 <1438880430-5480-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, jason@lakedaemon.net,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com,
	ezequiel.garcia@free-electrons.com, alior@marvell.com,
	jaz@semihalf.com, Marcin Wojtas <mw@semihalf.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:36283 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220AbbHFRAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 13:00:52 -0400
Received: by lagz9 with SMTP id z9so7265559lag.3
        for <netdev@vger.kernel.org>; Thu, 06 Aug 2015 10:00:50 -0700 (PDT)
In-Reply-To: <1438880430-5480-1-git-send-email-mw@semihalf.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using spinlocks protection during one-time driver initialization is not
necessary. Moreover it resulted in invalid GFP_KERNEL allocation under the lock.

This commit removes redundant spinlocks from buffer manager part of mvpp2
initialization.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
Reported-by: Alexandre Fournier <alexandre.fournier@wisp-e.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 3e8b1bf..f94bd12 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -913,8 +913,6 @@ struct mvpp2_bm_pool {
 	/* Occupied buffers indicator */
 	atomic_t in_use;
 	int in_use_thresh;
-
-	spinlock_t lock;
 };
 
 struct mvpp2_buff_hdr {
@@ -3376,7 +3374,6 @@ static int mvpp2_bm_pool_create(struct platform_device *pdev,
 	bm_pool->pkt_size = 0;
 	bm_pool->buf_num = 0;
 	atomic_set(&bm_pool->in_use, 0);
-	spin_lock_init(&bm_pool->lock);
 
 	return 0;
 }
@@ -3647,7 +3644,6 @@ static struct mvpp2_bm_pool *
 mvpp2_bm_pool_use(struct mvpp2_port *port, int pool, enum mvpp2_bm_type type,
 		  int pkt_size)
 {
-	unsigned long flags = 0;
 	struct mvpp2_bm_pool *new_pool = &port->priv->bm_pools[pool];
 	int num;
 
@@ -3656,8 +3652,6 @@ mvpp2_bm_pool_use(struct mvpp2_port *port, int pool, enum mvpp2_bm_type type,
 		return NULL;
 	}
 
-	spin_lock_irqsave(&new_pool->lock, flags);
-
 	if (new_pool->type == MVPP2_BM_FREE)
 		new_pool->type = type;
 
@@ -3686,8 +3680,6 @@ mvpp2_bm_pool_use(struct mvpp2_port *port, int pool, enum mvpp2_bm_type type,
 		if (num != pkts_num) {
 			WARN(1, "pool %d: %d of %d allocated\n",
 			     new_pool->id, num, pkts_num);
-			/* We need to undo the bufs_add() allocations */
-			spin_unlock_irqrestore(&new_pool->lock, flags);
 			return NULL;
 		}
 	}
@@ -3695,15 +3687,12 @@ mvpp2_bm_pool_use(struct mvpp2_port *port, int pool, enum mvpp2_bm_type type,
 	mvpp2_bm_pool_bufsize_set(port->priv, new_pool,
 				  MVPP2_RX_BUF_SIZE(new_pool->pkt_size));
 
-	spin_unlock_irqrestore(&new_pool->lock, flags);
-
 	return new_pool;
 }
 
 /* Initialize pools for swf */
 static int mvpp2_swf_bm_pool_init(struct mvpp2_port *port)
 {
-	unsigned long flags = 0;
 	int rxq;
 
 	if (!port->pool_long) {
@@ -3714,9 +3703,7 @@ static int mvpp2_swf_bm_pool_init(struct mvpp2_port *port)
 		if (!port->pool_long)
 			return -ENOMEM;
 
-		spin_lock_irqsave(&port->pool_long->lock, flags);
 		port->pool_long->port_map |= (1 << port->id);
-		spin_unlock_irqrestore(&port->pool_long->lock, flags);
 
 		for (rxq = 0; rxq < rxq_number; rxq++)
 			mvpp2_rxq_long_pool_set(port, rxq, port->pool_long->id);
@@ -3730,9 +3717,7 @@ static int mvpp2_swf_bm_pool_init(struct mvpp2_port *port)
 		if (!port->pool_short)
 			return -ENOMEM;
 
-		spin_lock_irqsave(&port->pool_short->lock, flags);
 		port->pool_short->port_map |= (1 << port->id);
-		spin_unlock_irqrestore(&port->pool_short->lock, flags);
 
 		for (rxq = 0; rxq < rxq_number; rxq++)
 			mvpp2_rxq_short_pool_set(port, rxq,
-- 
1.8.3.1
