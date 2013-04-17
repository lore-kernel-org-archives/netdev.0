From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 1/5] net/davinci_cpdma: don't check for jiffies with interrupts
Date: Wed, 17 Apr 2013 23:52:12 +0200
Message-ID: <1366235536-15744-2-git-send-email-bigeasy@linutronix.de>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de>
Cc: netdev@vger.kernel.org, tglx@linutronix.de,
	"David S. Miller" <davem@davemloft.net>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:41209 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966525Ab3DQVwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 17:52:37 -0400
In-Reply-To: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__cpdma_chan_process() holds the lock with interrupts off (and its
caller as well), same goes for cpdma_ctlr_start(). With interrupts off,
jiffies will not make any progress and if the wait condition never gets
true we wait for ever.
Tgis patch adds a a simple udelay and counting down attempt.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/ti/davinci_cpdma.c |   20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index ee13dc7..3e34187 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -20,6 +20,7 @@
 #include <linux/err.h>
 #include <linux/dma-mapping.h>
 #include <linux/io.h>
+#include <linux/delay.h>
 
 #include "davinci_cpdma.h"
 
@@ -312,14 +313,16 @@ int cpdma_ctlr_start(struct cpdma_ctlr *ctlr)
 	}
 
 	if (ctlr->params.has_soft_reset) {
-		unsigned long timeout = jiffies + HZ/10;
+		unsigned timeout = 10 * 100;
 
 		dma_reg_write(ctlr, CPDMA_SOFTRESET, 1);
-		while (time_before(jiffies, timeout)) {
+		while (timeout) {
 			if (dma_reg_read(ctlr, CPDMA_SOFTRESET) == 0)
 				break;
+			udelay(10);
+			timeout--;
 		}
-		WARN_ON(!time_before(jiffies, timeout));
+		WARN_ON(!timeout);
 	}
 
 	for (i = 0; i < ctlr->num_chan; i++) {
@@ -868,7 +871,7 @@ int cpdma_chan_stop(struct cpdma_chan *chan)
 	struct cpdma_desc_pool	*pool = ctlr->pool;
 	unsigned long		flags;
 	int			ret;
-	unsigned long		timeout;
+	unsigned		timeout;
 
 	spin_lock_irqsave(&chan->lock, flags);
 	if (chan->state != CPDMA_STATE_ACTIVE) {
@@ -883,14 +886,15 @@ int cpdma_chan_stop(struct cpdma_chan *chan)
 	dma_reg_write(ctlr, chan->td, chan_linear(chan));
 
 	/* wait for teardown complete */
-	timeout = jiffies + HZ/10;	/* 100 msec */
-	while (time_before(jiffies, timeout)) {
+	timeout = 100 * 100; /* 100 ms */
+	while (timeout) {
 		u32 cp = chan_read(chan, cp);
 		if ((cp & CPDMA_TEARDOWN_VALUE) == CPDMA_TEARDOWN_VALUE)
 			break;
-		cpu_relax();
+		udelay(10);
+		timeout--;
 	}
-	WARN_ON(!time_before(jiffies, timeout));
+	WARN_ON(!timeout);
 	chan_write(chan, cp, CPDMA_TEARDOWN_VALUE);
 
 	/* handle completed packets */
-- 
1.7.10.4
