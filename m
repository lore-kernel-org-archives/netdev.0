From: Vincent Palatin <vpalatin@chromium.org>
Subject: [PATCH] stmmac: do not sleep in atomic context for mdio_reset
Date: Wed,  1 Jun 2016 08:53:48 -0700
Message-ID: <1464796428-25623-1-git-send-email-vpalatin@chromium.org>
Cc: linux-kernel@vger.kernel.org,
	Alexandre Torgue <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Vincent Palatin <vpalatin@chromium.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35097 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbcFAPx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 11:53:59 -0400
Received: by mail-pf0-f169.google.com with SMTP id g64so17589645pfb.2
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 08:53:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

stmmac_mdio_reset() has been updated to use msleep rather udelay
(as some PHY requires a one second delay there).
It called from stmmac_resume() within the spin_lock_irqsave block
atomic context triggering 'scheduling while atomic'.

The stmmac_priv lock usage is not fully documented, but it seems
to protect the access to the MAC registers / DMA structures rather
than the MDIO bus or the PHY (which have separate locking),
so we can push the spin_lock after the stmmac_mdio_reset call.

Signed-off-by: Vincent Palatin <vpalatin@chromium.org>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index eac45d0..a473c18 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3450,8 +3450,6 @@ int stmmac_resume(struct device *dev)
 	if (!netif_running(ndev))
 		return 0;
 
-	spin_lock_irqsave(&priv->lock, flags);
-
 	/* Power Down bit, into the PM register, is cleared
 	 * automatically as soon as a magic packet or a Wake-up frame
 	 * is received. Anyway, it's better to manually clear
@@ -3459,7 +3457,9 @@ int stmmac_resume(struct device *dev)
 	 * from another devices (e.g. serial console).
 	 */
 	if (device_may_wakeup(priv->device)) {
+		spin_lock_irqsave(&priv->lock, flags);
 		priv->hw->mac->pmt(priv->hw, 0);
+		spin_unlock_irqrestore(&priv->lock, flags);
 		priv->irq_wake = 0;
 	} else {
 		pinctrl_pm_select_default_state(priv->device);
@@ -3473,6 +3473,8 @@ int stmmac_resume(struct device *dev)
 
 	netif_device_attach(ndev);
 
+	spin_lock_irqsave(&priv->lock, flags);
+
 	priv->cur_rx = 0;
 	priv->dirty_rx = 0;
 	priv->dirty_tx = 0;
-- 
2.8.0.rc3.226.g39d4020
