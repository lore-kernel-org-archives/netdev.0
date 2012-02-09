From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 1/2] stmmac: request_irq when use an ext wake irq line
Date: Thu,  9 Feb 2012 08:55:13 +0100
Message-ID: <1328774114-28894-1-git-send-email-peppe.cavallaro@st.com>
Cc: Francesco Virlinzi <francesco.virlinzi@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:37965 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750790Ab2BIHzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 02:55:37 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6CAC3B4
	for <netdev@vger.kernel.org>; Thu,  9 Feb 2012 07:55:25 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 060421B45
	for <netdev@vger.kernel.org>; Thu,  9 Feb 2012 07:55:25 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Virlinzi <francesco.virlinzi@st.com>

In case of we use an external Wake-Up IRQ line
(priv->wol_irq != dev->irq) we need to invoke the
request_irq.

Signed-off-by: Francesco Virlinzi <francesco.virlinzi@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 96fa2da..36ee77f 100644
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
-- 
1.7.4.4
