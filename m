From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH] net: dsa: bcm_sf2: Unwind errors in correct order
Date: Fri, 29 Jul 2016 12:35:57 -0700
Message-ID: <1469820957-21496-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35980 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbcG2TgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 15:36:01 -0400
Received: by mail-pf0-f194.google.com with SMTP id y134so5903585pfg.3
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2016 12:36:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case we cannot complete bcm_sf2_sw_setup() for any reason, and we
go to the out_unmap label, but the MDIO bus has not been registered yet,
we will hit the BUG condition in drivers/net/phy/mdio_bus.c about the
bus not being registered. Fix this by dedicating a specific lable for
when we fail after the MDIO bus has been successfully registered.

Fixes: 461cd1b03e32 ("net: dsa: bcm_sf2: Register our slave MDIO bus")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index cd1d630ae3a9..b2b838724a9b 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1622,7 +1622,7 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 			  "switch_0", priv);
 	if (ret < 0) {
 		pr_err("failed to request switch_0 IRQ\n");
-		goto out_unmap;
+		goto out_mdio;
 	}
 
 	ret = request_irq(priv->irq1, bcm_sf2_switch_1_isr, 0,
@@ -1679,6 +1679,8 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 
 out_free_irq0:
 	free_irq(priv->irq0, priv);
+out_mdio:
+	bcm_sf2_mdio_unregister(priv);
 out_unmap:
 	base = &priv->core;
 	for (i = 0; i < BCM_SF2_REGS_NUM; i++) {
@@ -1686,7 +1688,6 @@ out_unmap:
 			iounmap(*base);
 		base++;
 	}
-	bcm_sf2_mdio_unregister(priv);
 	return ret;
 }
 
-- 
2.7.4
