From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 10/11] net: bcmgenet: suspend and resume from Wake-on-LAN
Date: Mon, 21 Jul 2014 15:29:28 -0700
Message-ID: <1405981769-24618-11-git-send-email-f.fainelli@gmail.com>
References: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:52877 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755078AbaGUW36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 18:29:58 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so10643371pab.16
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 15:29:57 -0700 (PDT)
In-Reply-To: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update bcmgenet_suspend() to prepare the hardware for being put into
Wake-on-LAN mode if the device can wakeup the system, and Wake-on-LAN is
enabled. Whether we resume from Wake-on-LAN or not, make sure that
bcmgenet_resume() disables the UniMAC MagicPacket matching mode and puts
the hardware in a state where it can receive all incoming packets.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 1925ae1dc1e6..62ef49c85980 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2635,6 +2635,12 @@ static int bcmgenet_suspend(struct device *d)
 	bcmgenet_tx_reclaim_all(dev);
 	bcmgenet_fini_dma(priv);
 
+	/* Prepare the device for Wake-on-LAN and switch to the slow clock */
+	if (device_may_wakeup(d) && priv->wolopts) {
+		bcmgenet_power_down(priv, GENET_POWER_WOL_MAGIC);
+		clk_prepare_enable(priv->clk_wol);
+	}
+
 	/* Turn off the clocks */
 	clk_disable_unprepare(priv->clk);
 
@@ -2663,6 +2669,12 @@ static int bcmgenet_resume(struct device *d)
 	if (ret)
 		goto out_clk_disable;
 
+	if (priv->wolopts)
+		ret = bcmgenet_wol_resume(priv);
+
+	if (ret)
+		goto out_clk_disable;
+
 	/* disable ethernet MAC while updating its registers */
 	umac_enable_set(priv, CMD_TX_EN | CMD_RX_EN, false);
 
-- 
1.9.1
