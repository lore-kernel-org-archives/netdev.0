From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net] drivers: stmmac: Fixes for STMMAC IEEE 1588 Timestamping
Date: Thu, 19 Dec 2013 05:29:28 -0600
Message-ID: <CAOwfj2Pm8ekwrh1k2pviOySA-YOuxfmPOsCBUhJoYyX3d=LuZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	Rayagond K <rayagond@vayavyalabs.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:55268 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599Ab3LSL33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 06:29:29 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so900488wgh.26
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 03:29:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes two issues found in the stmmac driver when testing
hardware enabled PTP using linuxptp ptp4l.

1) Advanced timestamping capability was not being enabled correctly
since setting the state variable adv_ts was masked by the netif
message mask for printing status to the console as the driver loaded.

2) Incorrect spinlocks were released in the stmmac_adjust_freq and
stmmac_adjust_time functions, leading to unstable behaviour.

Vince

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8a7a23a..797b56a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -622,17 +622,15 @@ static int stmmac_init_ptp(struct stmmac_priv *priv)
     if (!(priv->dma_cap.time_stamp || priv->dma_cap.atime_stamp))
         return -EOPNOTSUPP;

-    if (netif_msg_hw(priv)) {
-        if (priv->dma_cap.time_stamp) {
-            pr_debug("IEEE 1588-2002 Time Stamp supported\n");
-            priv->adv_ts = 0;
-        }
-        if (priv->dma_cap.atime_stamp && priv->extend_desc) {
-            pr_debug
-                ("IEEE 1588-2008 Advanced Time Stamp supported\n");
-            priv->adv_ts = 1;
-        }
-    }
+    priv->adv_ts = 0;
+    if (priv->dma_cap.atime_stamp && priv->extend_desc)
+        priv->adv_ts = 1;
+
+    if (netif_msg_hw(priv) && priv->dma_cap.time_stamp)
+        pr_debug("IEEE 1588-2002 Time Stamp supported\n");
+
+    if (netif_msg_hw(priv) && priv->adv_ts)
+        pr_debug("IEEE 1588-2008 Advanced Time Stamp supported\n");

     priv->hw->ptp = &stmmac_ptp;
     priv->hwts_tx_en = 0;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
index b8b0eee..7680581 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
@@ -56,7 +56,7 @@ static int stmmac_adjust_freq(struct ptp_clock_info
*ptp, s32 ppb)

     priv->hw->ptp->config_addend(priv->ioaddr, addend);

-    spin_unlock_irqrestore(&priv->lock, flags);
+    spin_unlock_irqrestore(&priv->ptp_lock, flags);

     return 0;
 }
@@ -91,7 +91,7 @@ static int stmmac_adjust_time(struct ptp_clock_info
*ptp, s64 delta)

     priv->hw->ptp->adjust_systime(priv->ioaddr, sec, nsec, neg_adj);

-    spin_unlock_irqrestore(&priv->lock, flags);
+    spin_unlock_irqrestore(&priv->ptp_lock, flags);

     return 0;
 }
