From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: systemport: Fix missing Wake-on-LAN interrupt for SYSTEMPORT Lite
Date: Thu,  1 Jun 2017 18:02:39 -0700
Message-ID: <20170602010239.18732-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34830 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750892AbdFBBCp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 21:02:45 -0400
Received: by mail-qk0-f196.google.com with SMTP id v195so7922776qka.2
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 18:02:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On SYSTEMPORT Lite, since we have the main interrupt source in the first
cell, the second cell is the Wake-on-LAN interrupt, yet the code was not
properly updated to fetch the second cell, and instead looked at the
third and non-existing cell for Wake-on-LAN.

Fixes: 44a4524c54af ("net: systemport: Add support for SYSTEMPORT Lite")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 099b374c1b17..5274501428e4 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -2026,9 +2026,12 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 	priv->num_rx_desc_words = params->num_rx_desc_words;
 
 	priv->irq0 = platform_get_irq(pdev, 0);
-	if (!priv->is_lite)
+	if (!priv->is_lite) {
 		priv->irq1 = platform_get_irq(pdev, 1);
-	priv->wol_irq = platform_get_irq(pdev, 2);
+		priv->wol_irq = platform_get_irq(pdev, 2);
+	} else {
+		priv->wol_irq = platform_get_irq(pdev, 1);
+	}
 	if (priv->irq0 <= 0 || (priv->irq1 <= 0 && !priv->is_lite)) {
 		dev_err(&pdev->dev, "invalid interrupts\n");
 		ret = -EINVAL;
-- 
2.9.3
