From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH 3/9] net: davinci_cpdma: requeue on early end-of-queue
Date: Mon, 13 Sep 2010 14:07:25 -0400
Message-ID: <1284401251-8846-4-git-send-email-cyril@ti.com>
References: <1284401251-8846-1-git-send-email-cyril@ti.com>
Cc: michael.williamson@criticallink.com, caglarakyuz@gmail.com,
	bparrot@ti.com, Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1284401251-8846-1-git-send-email-cyril@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When chaining descriptors to the end of a cpdma queue, there is a chance that
the cpdma engine has already traversed the last descriptor and signalled an
end-of-queue.  The original cpdma code detected this condition and requeued
descriptors on submission.

With this patch, an early end-of-queue condition is detected on descriptor
submission as well.  This is necessary on davinci style emac controllers, and
prevents transmit timeouts when sending out a burst of packets.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
Signed-off-by: Michael Williamson <michael.williamson@criticallink.com>
Signed-off-by: Caglar Akyuz <caglarakyuz@gmail.com>
---
 drivers/net/davinci_cpdma.c |   12 ++++++++++--
 drivers/net/davinci_cpdma.h |    1 +
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/davinci_cpdma.c b/drivers/net/davinci_cpdma.c
index ab7ecd7..abc2b14 100644
--- a/drivers/net/davinci_cpdma.c
+++ b/drivers/net/davinci_cpdma.c
@@ -488,6 +488,7 @@ static void __cpdma_chan_submit(struct cpdma_chan *chan,
 	struct cpdma_desc __iomem	*prev = chan->tail;
 	struct cpdma_desc_pool		*pool = ctlr->pool;
 	dma_addr_t			desc_dma;
+	u32				mode;
 
 	desc_dma = desc_phys(pool, desc);
 
@@ -507,8 +508,10 @@ static void __cpdma_chan_submit(struct cpdma_chan *chan,
 	chan->stats.tail_enqueue++;
 
 	/* next check if EOQ has been triggered already */
-	if (desc_read(prev, hw_mode) & CPDMA_DESC_EOQ &&
-	    chan->state == CPDMA_STATE_ACTIVE) {
+	mode = desc_read(prev, hw_mode);
+	if (((mode & (CPDMA_DESC_EOQ | CPDMA_DESC_OWNER)) == CPDMA_DESC_EOQ) &&
+	    (chan->state == CPDMA_STATE_ACTIVE)) {
+		desc_write(prev, hw_mode, mode & ~CPDMA_DESC_EOQ);
 		chan_write(chan, hdp, desc_dma);
 		chan->stats.misqueued++;
 	}
@@ -618,6 +621,11 @@ static int __cpdma_chan_process(struct cpdma_chan *chan)
 	chan->count--;
 	chan->stats.good_dequeue++;
 
+	if (status & CPDMA_DESC_EOQ) {
+		chan->stats.requeue++;
+		chan_write(chan, hdp, desc_phys(pool, chan->head));
+	}
+
 	spin_unlock_irqrestore(&chan->lock, flags);
 
 	__cpdma_chan_free(chan, desc, outlen, status);
diff --git a/drivers/net/davinci_cpdma.h b/drivers/net/davinci_cpdma.h
index d50ee35..9baacca 100644
--- a/drivers/net/davinci_cpdma.h
+++ b/drivers/net/davinci_cpdma.h
@@ -56,6 +56,7 @@ struct cpdma_chan_stats {
 	u32			empty_dequeue;
 	u32			busy_dequeue;
 	u32			good_dequeue;
+	u32			requeue;
 	u32			teardown_dequeue;
 };
 
-- 
1.7.0.4

