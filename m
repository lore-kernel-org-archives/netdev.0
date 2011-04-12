From: Sriramakrishnan A G <srk@ti.com>
Subject: [PATCH] net: davinci_emac: fix spinlock bug with dma channel cleanup
Date: Tue, 12 Apr 2011 10:12:31 +0530
Message-ID: <1302583351-10449-1-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davinci-linux-open-source@linux.davincidsp.com>,
	<davem@davemloft.net>, Sriramakrishnan A G <srk@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:39339 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971Ab1DLEmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 00:42:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA cleanup function was holding the spinlock across
a busy loop where it waits for HW to indicate teardown is complete.
This generates a backtrace, when DEBUG_SPINLOCK is enabled. Make the
locking more granular.

Signed-off-by: Sriramakrishnan A G <srk@ti.com>
---
 drivers/net/davinci_cpdma.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/davinci_cpdma.c b/drivers/net/davinci_cpdma.c
index ae47f23..57fd0fc 100644
--- a/drivers/net/davinci_cpdma.c
+++ b/drivers/net/davinci_cpdma.c
@@ -824,6 +824,8 @@ int cpdma_chan_stop(struct cpdma_chan *chan)
 	/* trigger teardown */
 	dma_reg_write(ctlr, chan->td, chan->chan_num);
 
+	spin_unlock_irqrestore(&chan->lock, flags);
+
 	/* wait for teardown complete */
 	timeout = jiffies + HZ/10;	/* 100 msec */
 	while (time_before(jiffies, timeout)) {
@@ -843,6 +845,7 @@ int cpdma_chan_stop(struct cpdma_chan *chan)
 	} while ((ret & CPDMA_DESC_TD_COMPLETE) == 0);
 
 	/* remaining packets haven't been tx/rx'ed, clean them up */
+	spin_lock_irqsave(&chan->lock, flags);
 	while (chan->head) {
 		struct cpdma_desc __iomem *desc = chan->head;
 		dma_addr_t next_dma;
-- 
1.6.2.4

