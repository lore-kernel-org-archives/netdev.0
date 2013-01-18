From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH 3/4] net: ethernet: ti cpsw: Split up DMA descriptor pool
Date: Fri, 18 Jan 2013 11:06:11 +0100
Message-ID: <1358503572-5057-3-git-send-email-sebastian@breakpoint.cc>
References: <1358503572-5057-1-git-send-email-sebastian@breakpoint.cc>
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Rakesh Ranjan <rakesh.ranjan@vnl.in>,
	Bruno Bittner <Bruno.Bittner@sick.com>,
	Holger Dengler <dengler@linutronix.de>,
	Jan Altenberg <jan@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43934 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751324Ab3ARKGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 05:06:40 -0500
In-Reply-To: <1358503572-5057-1-git-send-email-sebastian@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>

Split the buffer pool into a RX and a TX block so neither of the
channels can influence the other. It is possible to fillup the pool by
sending a lot of large packets on a slow half-duplex link.

Cc: Rakesh Ranjan <rakesh.ranjan@vnl.in>
Cc: Bruno Bittner <Bruno.Bittner@sick.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
[dengler: patch description]
Signed-off-by: Holger Dengler <dengler@linutronix.de>
[jan: forward ported]
Signed-off-by: Jan Altenberg <jan@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/ti/davinci_cpdma.c |   35 +++++++++++++++++++++++++++---
 1 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 709c437..70325cd 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -217,16 +217,41 @@ desc_from_phys(struct cpdma_desc_pool *pool, dma_addr_t dma)
 }
 
 static struct cpdma_desc __iomem *
-cpdma_desc_alloc(struct cpdma_desc_pool *pool, int num_desc)
+cpdma_desc_alloc(struct cpdma_desc_pool *pool, int num_desc, bool is_rx)
 {
 	unsigned long flags;
 	int index;
 	struct cpdma_desc __iomem *desc = NULL;
+	static int last_index = 4096;
 
 	spin_lock_irqsave(&pool->lock, flags);
 
-	index = bitmap_find_next_zero_area(pool->bitmap, pool->num_desc, 0,
-					   num_desc, 0);
+	/*
+	 * The pool is split into two areas rx and tx. So we make sure
+	 * that we can't run out of pool buffers for RX when TX has
+	 * tons of stuff queued.
+	 */
+	if (is_rx) {
+		index = bitmap_find_next_zero_area(pool->bitmap,
+				pool->num_desc/2, 0, num_desc, 0);
+	 } else {
+		if (last_index >= pool->num_desc)
+			last_index = pool->num_desc / 2;
+
+		index = bitmap_find_next_zero_area(pool->bitmap,
+				pool->num_desc, last_index, num_desc, 0);
+
+		if (!(index < pool->num_desc)) {
+			index = bitmap_find_next_zero_area(pool->bitmap,
+				pool->num_desc, pool->num_desc/2, num_desc, 0);
+		}
+
+		if (index < pool->num_desc)
+			last_index = index + 1;
+		else
+			last_index = pool->num_desc / 2;
+	}
+
 	if (index < pool->num_desc) {
 		bitmap_set(pool->bitmap, index, num_desc);
 		desc = pool->iomap + pool->desc_size * index;
@@ -660,6 +685,7 @@ int cpdma_chan_submit(struct cpdma_chan *chan, void *token, void *data,
 	unsigned long			flags;
 	u32				mode;
 	int				ret = 0;
+	bool				is_rx;
 
 	spin_lock_irqsave(&chan->lock, flags);
 
@@ -668,7 +694,8 @@ int cpdma_chan_submit(struct cpdma_chan *chan, void *token, void *data,
 		goto unlock_ret;
 	}
 
-	desc = cpdma_desc_alloc(ctlr->pool, 1);
+	is_rx = (chan->rxfree != 0);
+	desc = cpdma_desc_alloc(ctlr->pool, 1, is_rx);
 	if (!desc) {
 		chan->stats.desc_alloc_fail++;
 		ret = -ENOMEM;
-- 
1.7.6.5
