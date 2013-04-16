From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH] net/cpsw: don't disable_irqs() after an interrupt has been received.
Date: Tue, 16 Apr 2013 20:21:00 +0200
Message-ID: <1366136460-30732-1-git-send-email-bigeasy@linutronix.de>
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Thomas Gleixner <tglx@linutronix.de>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:36052 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935113Ab3DPSVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 14:21:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver has usually four interrupts registered with the same ISR.
The ISR masks the interrupt source in DMA engine and CPSW, disables the
interrupt and schedules NAPI. After the NAPI routine completes, the
source is activated and interrupts are re-enabled.
With threaded-interrupts enabled, the enable/disable might go wrong.
After the RX interrupt arrived, the core marks the interrupt pending. If
the TX interrupt arrives before the RX started, then both lines are
marked pending and both disable the interrupt which then is disabled
twice. In NAPI complete the interrupt is enabled only once which means
the four interrupts are still masked and the device plays dead.

While playing with this on my beagle bone I didn't understand why
the interrupts are deactivated in the first place. According to my
testing, after calling cpsw_intr_disable() the interrupt is not active
anymore. I haven't seen the ISR being invoked again until after
cpsw_poll() enabled them (except for a different interrupt number).
Therefore I remove this.

In my testing I didn't notice anything unusual except one thing: I start
a wget of a 126MiB file (which is sttored on MMC) from the beagle bone.
On the first invocation I receive almost steady 5MiB/sec. In the
following invocations of wget I see the performance floating between
1MiB/sec and 4MiB/sec. It usually ends with overall around 2MiB/sec.
I couldn't notice nothing wrong. The only difference compared to the
first invocation is (most likely) that the file is now served from
memory and not read from MMC which should perform better but not worse.
After executing "while ((1)); do /bin/true; done" on the beagle bone
while the file was downloaded, I noticed that the speed rose to 9MiB/sec
- 10/MiB/sec. Now this looks like power/idle optimization on the beagle
bone side.

Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c |   16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e2ba702..acb229c 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -133,19 +133,6 @@ do {								\
 #define CPSW_CMINTMAX_INTVL	(1000 / CPSW_CMINTMIN_CNT)
 #define CPSW_CMINTMIN_INTVL	((1000 / CPSW_CMINTMAX_CNT) + 1)
 
-#define cpsw_enable_irq(priv)	\
-	do {			\
-		u32 i;		\
-		for (i = 0; i < priv->num_irqs; i++) \
-			enable_irq(priv->irqs_table[i]); \
-	} while (0);
-#define cpsw_disable_irq(priv)	\
-	do {			\
-		u32 i;		\
-		for (i = 0; i < priv->num_irqs; i++) \
-			disable_irq_nosync(priv->irqs_table[i]); \
-	} while (0);
-
 #define cpsw_slave_index(priv)				\
 		((priv->data.dual_emac) ? priv->emac_port :	\
 		priv->data.active_slave)
@@ -513,13 +500,11 @@ static irqreturn_t cpsw_interrupt(int irq, void *dev_id)
 
 	if (likely(netif_running(priv->ndev))) {
 		cpsw_intr_disable(priv);
-		cpsw_disable_irq(priv);
 		napi_schedule(&priv->napi);
 	} else {
 		priv = cpsw_get_slave_priv(priv, 1);
 		if (likely(priv) && likely(netif_running(priv->ndev))) {
 			cpsw_intr_disable(priv);
-			cpsw_disable_irq(priv);
 			napi_schedule(&priv->napi);
 		}
 	}
@@ -540,7 +525,6 @@ static int cpsw_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 		cpsw_intr_enable(priv);
 		cpdma_ctlr_eoi(priv->dma, CPDMA_EOI_RX);
-		cpsw_enable_irq(priv);
 	}
 
 	if (num_rx || num_tx)
-- 
1.7.10.4
