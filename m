From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net] drivers : stmmac : Fixes for IEEE 1588 Timestamping
Date: Wed, 18 Dec 2013 17:35:19 -0600
Message-ID: <CAOwfj2Muc4szDNiJc5SjXsw4Oy_LkrBJeiDUY7-09N=paCSSKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:56592 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab3LRXfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 18:35:21 -0500
Received: by mail-wi0-f180.google.com with SMTP id hm19so1413152wib.13
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 15:35:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From e9278f13a922433adbf3a81ef9d7823a99bd8d88 Mon Sep 17 00:00:00 2001
From: Vince Bridgers <vbridger2013@gmail.com>
Date: Wed, 18 Dec 2013 14:29:26 -0600
Subject: [PATCH 1/1] Fix release of incorrect spinlock in stmmac_ptp.c, and
 masked configuration of control variable adv_ts

Two issues addressed with this patch:
1) The functions stmmac_adjust_freq and stmmac_adjust_time were
releasing the incorrect spinlock
   at the end of the function - priv->lock instead of priv->ptp_lock.
2) Setting the control data variable priv->adv_ts according to
hardware capabilities was masked
   by message level settings, so it was not being set correctly in the
case that the Synopsys
   MAC only supported advanced timestamping.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   20 +++++++++-----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c  |    4 ++--
 2 files changed, 11 insertions(+), 13 deletions(-)

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
-- 
1.7.9.5
