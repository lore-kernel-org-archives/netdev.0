From: Tony Lindgren <tony@atomide.com>
Subject: [PATCH 5/6] net: davinci_emac: Fix ioremap for devices with MDIO within the EMAC address space
Date: Thu, 15 Jan 2015 14:45:13 -0800
Message-ID: <1421361914-4612-6-git-send-email-tony@atomide.com>
References: <1421361914-4612-1-git-send-email-tony@atomide.com>
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	Brian Hutchinson <b.hutchman@gmail.com>,
	Felipe Balbi <balbi@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-03-ewr.mailhop.org ([204.13.248.66]:33108 "EHLO
	mho-01-ewr.mailhop.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932223AbbAOWtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 17:49:07 -0500
In-Reply-To: <1421361914-4612-1-git-send-email-tony@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some devices like dm816x have the MDIO registers within the first EMAC
instance address space. Let's fix the issue by allowing to pass an
optional second IO range for the EMAC control register area.

Cc: Brian Hutchinson <b.hutchman@gmail.com>
Cc: Felipe Balbi <balbi@ti.com>
Signed-off-by: Tony Lindgren <tony@atomide.com>
---
 drivers/net/ethernet/ti/davinci_emac.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index e44c8d8..1e5ea81 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1890,7 +1890,7 @@ davinci_emac_of_get_pdata(struct platform_device *pdev, struct emac_priv *priv)
 static int davinci_emac_probe(struct platform_device *pdev)
 {
 	int rc = 0;
-	struct resource *res;
+	struct resource *res, *res_ctrl;
 	struct net_device *ndev;
 	struct emac_priv *priv;
 	unsigned long hw_ram_addr;
@@ -1949,11 +1949,20 @@ static int davinci_emac_probe(struct platform_device *pdev)
 		rc = PTR_ERR(priv->remap_addr);
 		goto no_pdata;
 	}
+
+	res_ctrl = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	if (res_ctrl) {
+		priv->ctrl_base =
+			devm_ioremap_resource(&pdev->dev, res_ctrl);
+		if (IS_ERR(priv->ctrl_base))
+			goto no_pdata;
+	} else {
+		priv->ctrl_base = priv->remap_addr + pdata->ctrl_mod_reg_offset;
+	}
+
 	priv->emac_base = priv->remap_addr + pdata->ctrl_reg_offset;
 	ndev->base_addr = (unsigned long)priv->remap_addr;
 
-	priv->ctrl_base = priv->remap_addr + pdata->ctrl_mod_reg_offset;
-
 	hw_ram_addr = pdata->hw_ram_addr;
 	if (!hw_ram_addr)
 		hw_ram_addr = (u32 __force)res->start + pdata->ctrl_ram_offset;
-- 
2.1.4
