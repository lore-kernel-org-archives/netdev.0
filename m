From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH 2/4] net: ethernet: davinci_cpdma: fix descriptor handling
Date: Fri, 18 Jan 2013 11:06:10 +0100
Message-ID: <1358503572-5057-2-git-send-email-sebastian@breakpoint.cc>
References: <1358503572-5057-1-git-send-email-sebastian@breakpoint.cc>
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Rakesh Ranjan <rakesh.ranjan@vnl.in>,
	Bruno Bittner <Bruno.Bittner@sick.com>, stable@vger.kernel.org,
	Holger Dengler <dengler@linutronix.de>,
	Jan Altenberg <jan@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1358503572-5057-1-git-send-email-sebastian@breakpoint.cc>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>

According to the datasheet there is a miss-queued buffer condition
handling required in the processing. This is implemented correctly
when descriptors are queued for TX, but during TX cleanup of already
transmitted descriptors the condition is not handled correctly. That
leads to a stall of the TX queue which fills up and never gets processed.

Cc: Rakesh Ranjan <rakesh.ranjan@vnl.in>
Cc: Bruno Bittner <Bruno.Bittner@sick.com>
Cc: stable@vger.kernel.org
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
[dengler: patch description]
Signed-off-by: Holger Dengler <dengler@linutronix.de>
[jan: forward ported]
Signed-off-by: Jan Altenberg <jan@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/ti/davinci_cpdma.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index dd5f2db..709c437 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -756,7 +756,8 @@ static int __cpdma_chan_process(struct cpdma_chan *chan)
 	chan->count--;
 	chan->stats.good_dequeue++;
 
-	if (status & CPDMA_DESC_EOQ) {
+	if ((status & CPDMA_DESC_EOQ) && (chan->head) &&
+			(!(status & CPDMA_DESC_TD_COMPLETE))) {
 		chan->stats.requeue++;
 		chan_write(chan, hdp, desc_phys(pool, chan->head));
 	}
-- 
1.7.6.5
