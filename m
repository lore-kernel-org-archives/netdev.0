From: Tony Lindgren <tony@atomide.com>
Subject: [PATCH 2/3] net: davinci_emac: Get device dm816x MAC address using the cpsw code
Date: Wed, 28 Jan 2015 11:33:05 -0800
Message-ID: <1422473586-18100-3-git-send-email-tony@atomide.com>
References: <1422473586-18100-1-git-send-email-tony@atomide.com>
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	Brian Hutchinson <b.hutchman@gmail.com>,
	Felipe Balbi <balbi@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.ore.mailhop.org ([54.186.10.118]:35257 "EHLO
	smtp5.ore.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753172AbbA2BSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 20:18:49 -0500
In-Reply-To: <1422473586-18100-1-git-send-email-tony@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At least on dm81xx, we can get the davinci_emac MAC address the same
way as on am33xx cpsw.

Let's also use ether_addr_copy() for davinci_emac while at it.

Cc: Brian Hutchinson <b.hutchman@gmail.com>
Cc: Felipe Balbi <balbi@ti.com>
Signed-off-by: Tony Lindgren <tony@atomide.com>
---
 drivers/net/ethernet/ti/davinci_emac.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 5fae435..a716938 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -69,6 +69,7 @@
 #include <asm/irq.h>
 #include <asm/page.h>
 
+#include "cpsw.h"
 #include "davinci_cpdma.h"
 
 static int debug_level;
@@ -1838,7 +1839,7 @@ davinci_emac_of_get_pdata(struct platform_device *pdev, struct emac_priv *priv)
 	if (!is_valid_ether_addr(pdata->mac_addr)) {
 		mac_addr = of_get_mac_address(np);
 		if (mac_addr)
-			memcpy(pdata->mac_addr, mac_addr, ETH_ALEN);
+			ether_addr_copy(pdata->mac_addr, mac_addr);
 	}
 
 	of_property_read_u32(np, "ti,davinci-ctrl-reg-offset",
@@ -1879,6 +1880,22 @@ davinci_emac_of_get_pdata(struct platform_device *pdev, struct emac_priv *priv)
 	return  pdata;
 }
 
+static int davinci_emac_try_get_mac(struct platform_device *pdev,
+				    int instance, u8 *mac_addr)
+{
+	int error = -EINVAL;
+
+	if (!pdev->dev.of_node)
+		return error;
+
+	if (of_device_is_compatible(pdev->dev.of_node, "ti,dm816-emac"))
+		error = cpsw_am33xx_cm_get_macid(&pdev->dev, 0x30,
+						 instance,
+						 mac_addr);
+
+	return error;
+}
+
 /**
  * davinci_emac_probe - EMAC device probe
  * @pdev: The DaVinci EMAC device that we are removing
@@ -2009,6 +2026,10 @@ static int davinci_emac_probe(struct platform_device *pdev)
 	}
 	ndev->irq = res->start;
 
+	rc = davinci_emac_try_get_mac(pdev, res_ctrl ? 0 : 1, priv->mac_addr);
+	if (!rc)
+		ether_addr_copy(ndev->dev_addr, priv->mac_addr);
+
 	if (!is_valid_ether_addr(priv->mac_addr)) {
 		/* Use random MAC if none passed */
 		eth_hw_addr_random(ndev);
-- 
2.1.4
