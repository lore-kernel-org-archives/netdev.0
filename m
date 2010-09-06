From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] stmmac: fix sleep inside atomic
Date: Mon,  6 Sep 2010 05:06:19 +0200
Message-ID: <1283742379-9610-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:56382 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750766Ab0IFKEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 06:04:40 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 32FE98E
	for <netdev@vger.kernel.org>; Mon,  6 Sep 2010 10:04:37 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9420A27A5
	for <netdev@vger.kernel.org>; Mon,  6 Sep 2010 10:04:37 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We cannot use spinlock when kmalloc is invoked with
GFP_KERNEL flag because it can sleep.
So this patch reviews the usage of spinlock within the
stmmac_resume function avoing this bug.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac_main.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index bbb7951..a9befd6 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1865,15 +1865,15 @@ static int stmmac_resume(struct platform_device *pdev)
 	if (!netif_running(dev))
 		return 0;
 
-	spin_lock(&priv->lock);
-
 	if (priv->shutdown) {
 		/* Re-open the interface and re-init the MAC/DMA
-		   and the rings. */
+		   and the rings (i.e. on hibernation stage) */
 		stmmac_open(dev);
-		goto out_resume;
+		return 0;
 	}
 
+	spin_lock(&priv->lock);
+
 	/* Power Down bit, into the PM register, is cleared
 	 * automatically as soon as a magic packet or a Wake-up frame
 	 * is received. Anyway, it's better to manually clear
@@ -1901,7 +1901,6 @@ static int stmmac_resume(struct platform_device *pdev)
 
 	netif_start_queue(dev);
 
-out_resume:
 	spin_unlock(&priv->lock);
 	return 0;
 }
-- 
1.5.5.6

