From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 3/9] stmmac: support wake up irq from external sources (v2)
Date: Tue, 30 Aug 2011 16:20:58 +0200
Message-ID: <1314714064-29101-4-git-send-email-peppe.cavallaro@st.com>
References: <1314714064-29101-1-git-send-email-peppe.cavallaro@st.com>
Cc: Deepak Sikri <deepak.sikri@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:44836 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753257Ab1H3OVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 10:21:30 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 96A1DB2
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 14:21:28 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5BB442261
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 14:21:28 +0000 (GMT)
In-Reply-To: <1314714064-29101-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepak Sikri <deepak.sikri@st.com>

On some platforms e.g. SPEAr the wake up irq differs from the
GMAC interrupt source.
With this patch an external wake up irq can be passed through the
platform code and named as "eth_wake_irq".

In case the wake up interrupt is not passed from the platform
so the driver will continue to use the mac irq (ndev->irq)

Signed-off-by: Deepak Sikri <deepak.sikri@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac.h         |    1 +
 drivers/net/stmmac/stmmac_ethtool.c |    4 ++--
 drivers/net/stmmac/stmmac_main.c    |   14 +++++++++++++-
 3 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index de1929b..619e3af 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -72,6 +72,7 @@ struct stmmac_priv {
 	spinlock_t lock;
 	int wolopts;
 	int wolenabled;
+	int wol_irq;
 #ifdef CONFIG_STMMAC_TIMER
 	struct stmmac_timer *tm;
 #endif
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index 7ed8fb6..79df79d 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -321,10 +321,10 @@ static int stmmac_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	if (wol->wolopts) {
 		pr_info("stmmac: wakeup enable\n");
 		device_set_wakeup_enable(priv->device, 1);
-		enable_irq_wake(dev->irq);
+		enable_irq_wake(priv->wol_irq);
 	} else {
 		device_set_wakeup_enable(priv->device, 0);
-		disable_irq_wake(dev->irq);
+		disable_irq_wake(priv->wol_irq);
 	}
 
 	spin_lock_irq(&priv->lock);
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index da11405..931cbf6 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1512,7 +1512,7 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 
 	if (device_can_wakeup(priv->device)) {
 		priv->wolopts = WAKE_MAGIC; /* Magic Frame as default */
-		enable_irq_wake(dev->irq);
+		enable_irq_wake(priv->wol_irq);
 	}
 
 	return 0;
@@ -1585,6 +1585,18 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 		pr_info("\tPMT module supported\n");
 		device_set_wakeup_capable(&pdev->dev, 1);
 	}
+	/*
+	 * On some platforms e.g. SPEAr the wake up irq differs from the mac irq
+	 * The external wake up irq can be passed through the platform code
+	 * named as "eth_wake_irq"
+	 *
+	 * In case the wake up interrupt is not passed from the platform
+	 * so the driver will continue to use the mac irq (ndev->irq)
+	 */
+	priv->wol_irq = platform_get_irq_byname(pdev, "eth_wake_irq");
+	if (priv->wol_irq == -ENXIO)
+		priv->wol_irq = ndev->irq;
+
 
 	platform_set_drvdata(pdev, ndev);
 
-- 
1.7.4.4
