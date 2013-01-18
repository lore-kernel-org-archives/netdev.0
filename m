From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH 1/4] net: ethernet: davinci cpdma: Enable interrupt while waiting for teardown complete
Date: Fri, 18 Jan 2013 11:06:09 +0100
Message-ID: <1358503572-5057-1-git-send-email-sebastian@breakpoint.cc>
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Rakesh Ranjan <rakesh.ranjan@vnl.in>,
	Bruno Bittner <Bruno.Bittner@sick.com>,
	Holger Dengler <dengler@linutronix.de>,
	Jan Altenberg <jan@linutronix.de>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:43931 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751177Ab3ARKGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 05:06:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>

A teardown might take some time. If the other CPU is going to queue
something it will spin and wait. Dropping the lock will allow to
continue processing. It will notice that the channel is in state
teardown and will not do anything.

Cc: Rakesh Ranjan <rakesh.ranjan@vnl.in>
Cc: Bruno Bittner <Bruno.Bittner@sick.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
[dengler: patch description]
Signed-off-by: Holger Dengler <dengler@linutronix.de>
[jan: forward ported]
Signed-off-by: Jan Altenberg <jan@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/ti/davinci_cpdma.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 4995673..dd5f2db 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -836,6 +836,8 @@ int cpdma_chan_stop(struct cpdma_chan *chan)
 	/* trigger teardown */
 	dma_reg_write(ctlr, chan->td, chan_linear(chan));
 
+	spin_unlock_irqrestore(&chan->lock, flags);
+
 	/* wait for teardown complete */
 	timeout = jiffies + HZ/10;	/* 100 msec */
 	while (time_before(jiffies, timeout)) {
@@ -845,6 +847,8 @@ int cpdma_chan_stop(struct cpdma_chan *chan)
 		cpu_relax();
 	}
 	WARN_ON(!time_before(jiffies, timeout));
+
+	spin_lock_irqsave(&chan->lock, flags);
 	chan_write(chan, cp, CPDMA_TEARDOWN_VALUE);
 
 	/* handle completed packets */
-- 
1.7.6.5
