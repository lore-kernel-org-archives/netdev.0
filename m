From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/5] net: dsa: bcm_sf2: Use device managed helpers
Date: Thu, 18 Aug 2016 15:30:15 -0700
Message-ID: <1471559416-13249-5-git-send-email-f.fainelli@gmail.com>
References: <1471559416-13249-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35409 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753576AbcHSAuO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 20:50:14 -0400
Received: by mail-pf0-f195.google.com with SMTP id h186so540212pfg.2
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 17:50:14 -0700 (PDT)
In-Reply-To: <1471559416-13249-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have converted the drivers into a proper platform device
driver, we can use the device managed helper functions to simplify the
error paths a bit wrt. register resources and IRQs.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 36 +++++++++++++-----------------------
 1 file changed, 13 insertions(+), 23 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index fe1cc92f72a8..9f8e007b01d6 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -1630,6 +1630,7 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 	struct bcm_sf2_priv *priv;
 	struct dsa_switch *ds;
 	void __iomem **base;
+	struct resource *r;
 	unsigned int i;
 	u32 reg, rev;
 	int ret;
@@ -1655,11 +1656,11 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 
 	base = &priv->core;
 	for (i = 0; i < BCM_SF2_REGS_NUM; i++) {
-		*base = of_iomap(dn, i);
-		if (*base == NULL) {
+		r = platform_get_resource(pdev, IORESOURCE_MEM, i);
+		*base = devm_ioremap_resource(&pdev->dev, r);
+		if (IS_ERR(*base)) {
 			pr_err("unable to find register: %s\n", reg_names[i]);
-			ret = -ENOMEM;
-			goto out_unmap;
+			return PTR_ERR(*base);
 		}
 		base++;
 	}
@@ -1667,30 +1668,30 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 	ret = bcm_sf2_sw_rst(priv);
 	if (ret) {
 		pr_err("unable to software reset switch: %d\n", ret);
-		goto out_unmap;
+		return ret;
 	}
 
 	ret = bcm_sf2_mdio_register(ds);
 	if (ret) {
 		pr_err("failed to register MDIO bus\n");
-		goto out_unmap;
+		return ret;
 	}
 
 	/* Disable all interrupts and request them */
 	bcm_sf2_intr_disable(priv);
 
-	ret = request_irq(priv->irq0, bcm_sf2_switch_0_isr, 0,
-			  "switch_0", priv);
+	ret = devm_request_irq(&pdev->dev, priv->irq0, bcm_sf2_switch_0_isr, 0,
+			       "switch_0", priv);
 	if (ret < 0) {
 		pr_err("failed to request switch_0 IRQ\n");
 		goto out_mdio;
 	}
 
-	ret = request_irq(priv->irq1, bcm_sf2_switch_1_isr, 0,
-			  "switch_1", priv);
+	ret = devm_request_irq(&pdev->dev, priv->irq1, bcm_sf2_switch_1_isr, 0,
+			       "switch_1", priv);
 	if (ret < 0) {
 		pr_err("failed to request switch_1 IRQ\n");
-		goto out_free_irq0;
+		goto out_mdio;
 	}
 
 	/* Reset the MIB counters */
@@ -1720,7 +1721,7 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 
 	ret = dsa_register_switch(ds, dn);
 	if (ret)
-		goto out_free_irq1;
+		goto out_mdio;
 
 	pr_info("Starfighter 2 top: %x.%02x, core: %x.%02x base: 0x%p, IRQs: %d, %d\n",
 		priv->hw_params.top_rev >> 8, priv->hw_params.top_rev & 0xff,
@@ -1729,19 +1730,8 @@ static int bcm_sf2_sw_probe(struct platform_device *pdev)
 
 	return 0;
 
-out_free_irq1:
-	free_irq(priv->irq1, priv);
-out_free_irq0:
-	free_irq(priv->irq0, priv);
 out_mdio:
 	bcm_sf2_mdio_unregister(priv);
-out_unmap:
-	base = &priv->core;
-	for (i = 0; i < BCM_SF2_REGS_NUM; i++) {
-		if (*base)
-			iounmap(*base);
-		base++;
-	}
 	return ret;
 }
 
-- 
2.7.4
