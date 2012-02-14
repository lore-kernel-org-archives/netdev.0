From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 2/4] stmmac: request_irq when use an ext wake irq line (v2)
Date: Tue, 14 Feb 2012 08:11:46 +0100
Message-ID: <1329203508-19612-3-git-send-email-peppe.cavallaro@st.com>
References: <1329203508-19612-1-git-send-email-peppe.cavallaro@st.com>
Cc: Francesco Virlinzi <francesco.virlinzi@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:40222 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754889Ab2BNHMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 02:12:14 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 331ABCB
	for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 07:12:12 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 022E917E5
	for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 07:12:11 +0000 (GMT)
In-Reply-To: <1329203508-19612-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Virlinzi <francesco.virlinzi@st.com>

In case of we use an external Wake-Up IRQ line
(priv->wol_irq != dev->irq) we need to invoke the
request_irq.

Signed-off-by: Francesco Virlinzi <francesco.virlinzi@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 96fa2da..970a3f4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1047,6 +1047,17 @@ static int stmmac_open(struct net_device *dev)
 		goto open_error;
 	}
 
+	/* Request the Wake IRQ in case of another line is used for WoL */
+	if (priv->wol_irq != dev->irq) {
+		ret = request_irq(priv->wol_irq, stmmac_interrupt,
+				  IRQF_SHARED, dev->name, dev);
+		if (unlikely(ret < 0)) {
+			pr_err("%s: ERROR: allocating the ext WoL IRQ %d "
+			       "(error: %d)\n",	__func__, priv->wol_irq, ret);
+			goto open_error_wolirq;
+		}
+	}
+
 	/* Enable the MAC Rx/Tx */
 	stmmac_set_mac(priv->ioaddr, true);
 
@@ -1087,6 +1098,9 @@ static int stmmac_open(struct net_device *dev)
 
 	return 0;
 
+open_error_wolirq:
+	free_irq(dev->irq, dev);
+
 open_error:
 #ifdef CONFIG_STMMAC_TIMER
 	kfree(priv->tm);
@@ -1127,6 +1141,8 @@ static int stmmac_release(struct net_device *dev)
 
 	/* Free the IRQ lines */
 	free_irq(dev->irq, dev);
+	if (priv->wol_irq != dev->irq)
+		free_irq(priv->wol_irq, dev);
 
 	/* Stop TX/RX DMA and clear the descriptors */
 	priv->hw->dma->stop_tx(priv->ioaddr);
-- 
1.7.4.4
