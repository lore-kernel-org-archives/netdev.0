From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 2/2] stmmac: do not fail when the timer cannot be used.
Date: Thu, 19 Nov 2009 08:42:08 +0100
Message-ID: <1258616528-739-2-git-send-email-peppe.cavallaro@st.com>
References: <1258616528-739-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:39155 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754009AbZKSIFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 03:05:23 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 4B0D2DE
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 07:42:29 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 0BB62863
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 07:42:28 +0000 (GMT)
In-Reply-To: <1258616528-739-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the external timer cannot be used the driver
will continue to work without mitigation.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac_main.c  |   52 ++++++++++++++++++++----------------
 drivers/net/stmmac/stmmac_timer.h |    1 +
 2 files changed, 30 insertions(+), 23 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index c2f14dc..e63bf93 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -416,13 +416,8 @@ static void init_dma_desc_rings(struct net_device *dev)
 	unsigned int txsize = priv->dma_tx_size;
 	unsigned int rxsize = priv->dma_rx_size;
 	unsigned int bfsize = priv->dma_buf_sz;
-	int buff2_needed = 0;
-	int dis_ic = 0;
+	int buff2_needed = 0, dis_ic = 0;
 
-#ifdef CONFIG_STMMAC_TIMER
-	/* Using Timers disable interrupts on completion for the reception */
-	dis_ic = 1;
-#endif
 	/* Set the Buffer size according to the MTU;
 	 * indeed, in case of jumbo we need to bump-up the buffer sizes.
 	 */
@@ -437,6 +432,11 @@ static void init_dma_desc_rings(struct net_device *dev)
 	else
 		bfsize = DMA_BUFFER_SIZE;
 
+#ifdef CONFIG_STMMAC_TIMER
+	/* Disable interrupts on completion for the reception if timer is on */
+	if (likely(priv->tm->enable))
+		dis_ic = 1;
+#endif
 	/* If the MTU exceeds 8k so use the second buffer in the chain */
 	if (bfsize >= BUF_SIZE_8KiB)
 		buff2_needed = 1;
@@ -809,20 +809,22 @@ static void stmmac_tx(struct stmmac_priv *priv)
 
 static inline void stmmac_enable_irq(struct stmmac_priv *priv)
 {
-#ifndef CONFIG_STMMAC_TIMER
-	writel(DMA_INTR_DEFAULT_MASK, priv->dev->base_addr + DMA_INTR_ENA);
-#else
-	priv->tm->timer_start(tmrate);
+#ifdef CONFIG_STMMAC_TIMER
+	if (likely(priv->tm->enable))
+		priv->tm->timer_start(tmrate);
+	else
 #endif
+	writel(DMA_INTR_DEFAULT_MASK, priv->dev->base_addr + DMA_INTR_ENA);
 }
 
 static inline void stmmac_disable_irq(struct stmmac_priv *priv)
 {
-#ifndef CONFIG_STMMAC_TIMER
-	writel(0, priv->dev->base_addr + DMA_INTR_ENA);
-#else
-	priv->tm->timer_stop();
+#ifdef CONFIG_STMMAC_TIMER
+	if (likely(priv->tm->enable))
+		priv->tm->timer_stop();
+	else
 #endif
+	writel(0, priv->dev->base_addr + DMA_INTR_ENA);
 }
 
 static int stmmac_has_work(struct stmmac_priv *priv)
@@ -1031,22 +1033,23 @@ static int stmmac_open(struct net_device *dev)
 	}
 
 #ifdef CONFIG_STMMAC_TIMER
-	priv->tm = kmalloc(sizeof(struct stmmac_timer *), GFP_KERNEL);
+	priv->tm = kzalloc(sizeof(struct stmmac_timer *), GFP_KERNEL);
 	if (unlikely(priv->tm == NULL)) {
 		pr_err("%s: ERROR: timer memory alloc failed \n", __func__);
 		return -ENOMEM;
 	}
 	priv->tm->freq = tmrate;
 
-	/* Test if the HW timer can be actually used.
-	 * In case of failure continue with no timer. */
+	/* Test if the external timer can be actually used.
+	 * In case of failure continue without timer. */
 	if (unlikely((stmmac_open_ext_timer(dev, priv->tm)) < 0)) {
-		pr_warning("stmmaceth: cannot attach the HW timer\n");
+		pr_warning("stmmaceth: cannot attach the external timer.\n");
 		tmrate = 0;
 		priv->tm->freq = 0;
 		priv->tm->timer_start = stmmac_no_timer_started;
 		priv->tm->timer_stop = stmmac_no_timer_stopped;
-	}
+	} else
+		priv->tm->enable = 1;
 #endif
 
 	/* Create and initialize the TX/RX descriptors chains. */
@@ -1322,9 +1325,11 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Interrupt on completition only for the latest segment */
 	priv->mac_type->ops->close_tx_desc(desc);
+
 #ifdef CONFIG_STMMAC_TIMER
-	/* Clean IC while using timers */
-	priv->mac_type->ops->clear_tx_ic(desc);
+	/* Clean IC while using timer */
+	if (likely(priv->tm->enable))
+		priv->mac_type->ops->clear_tx_ic(desc);
 #endif
 	/* To avoid raise condition */
 	priv->mac_type->ops->set_tx_owner(first);
@@ -2028,7 +2033,8 @@ static int stmmac_suspend(struct platform_device *pdev, pm_message_t state)
 
 #ifdef CONFIG_STMMAC_TIMER
 		priv->tm->timer_stop();
-		dis_ic = 1;
+		if (likely(priv->tm->enable))
+			dis_ic = 1;
 #endif
 		napi_disable(&priv->napi);
 
@@ -2037,7 +2043,7 @@ static int stmmac_suspend(struct platform_device *pdev, pm_message_t state)
 		stmmac_dma_stop_rx(dev->base_addr);
 		/* Clear the Rx/Tx descriptors */
 		priv->mac_type->ops->init_rx_desc(priv->dma_rx,
-						  priv->dma_rx_size, dis_ic);
+					priv->dma_rx_size, dis_ic);
 		priv->mac_type->ops->init_tx_desc(priv->dma_tx,
 						  priv->dma_tx_size);
 
diff --git a/drivers/net/stmmac/stmmac_timer.h b/drivers/net/stmmac/stmmac_timer.h
index f795cae..6863590 100644
--- a/drivers/net/stmmac/stmmac_timer.h
+++ b/drivers/net/stmmac/stmmac_timer.h
@@ -26,6 +26,7 @@ struct stmmac_timer {
 	void (*timer_start) (unsigned int new_freq);
 	void (*timer_stop) (void);
 	unsigned int freq;
+	unsigned int enable;
 };
 
 /* Open the HW timer device and return 0 in case of success */
-- 
1.6.0.4

