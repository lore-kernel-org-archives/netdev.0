From: Tony Lindgren <tony@atomide.com>
Subject: [PATCH 4/6] net: davinci_emac: Fix incomplete code for getting the phy from device tree
Date: Thu, 15 Jan 2015 14:45:12 -0800
Message-ID: <1421361914-4612-5-git-send-email-tony@atomide.com>
References: <1421361914-4612-1-git-send-email-tony@atomide.com>
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	Brian Hutchinson <b.hutchman@gmail.com>,
	Felipe Balbi <balbi@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-03-ewr.mailhop.org ([204.13.248.66]:33081 "EHLO
	mho-01-ewr.mailhop.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932244AbbAOWtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 17:49:06 -0500
In-Reply-To: <1421361914-4612-1-git-send-email-tony@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like the phy_id is never set up beyond getting the phandle.
Note that we can remove the ifdef for phy_node as there is a stub
for of_phy_connec() if CONFIG_OF is not set.

Cc: Brian Hutchinson <b.hutchman@gmail.com>
Cc: Felipe Balbi <balbi@ti.com>
Signed-off-by: Tony Lindgren <tony@atomide.com>
---
 drivers/net/ethernet/ti/davinci_emac.c | 23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 59fdcdd..e44c8d8 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -62,6 +62,7 @@
 #include <linux/of.h>
 #include <linux/of_address.h>
 #include <linux/of_device.h>
+#include <linux/of_mdio.h>
 #include <linux/of_irq.h>
 #include <linux/of_net.h>
 
@@ -343,9 +344,7 @@ struct emac_priv {
 	u32 multicast_hash_cnt[EMAC_NUM_MULTICAST_BITS];
 	u32 rx_addr_type;
 	const char *phy_id;
-#ifdef CONFIG_OF
 	struct device_node *phy_node;
-#endif
 	struct phy_device *phydev;
 	spinlock_t lock;
 	/*platform specific members*/
@@ -1603,8 +1602,20 @@ static int emac_dev_open(struct net_device *ndev)
 	cpdma_ctlr_start(priv->dma);
 
 	priv->phydev = NULL;
+
+	if (priv->phy_node) {
+		priv->phydev = of_phy_connect(ndev, priv->phy_node,
+					      &emac_adjust_link, 0, 0);
+		if (!priv->phydev) {
+			dev_err(emac_dev, "could not connect to phy %s\n",
+				priv->phy_node->full_name);
+			ret = -ENODEV;
+			goto err;
+		}
+	}
+
 	/* use the first phy on the bus if pdata did not give us a phy id */
-	if (!priv->phy_id) {
+	if (!priv->phydev && !priv->phy_id) {
 		struct device *phy;
 
 		phy = bus_find_device(&mdio_bus_type, NULL, NULL,
@@ -1613,7 +1624,7 @@ static int emac_dev_open(struct net_device *ndev)
 			priv->phy_id = dev_name(phy);
 	}
 
-	if (priv->phy_id && *priv->phy_id) {
+	if (!priv->phydev && priv->phy_id && *priv->phy_id) {
 		priv->phydev = phy_connect(ndev, priv->phy_id,
 					   &emac_adjust_link,
 					   PHY_INTERFACE_MODE_MII);
@@ -1634,7 +1645,9 @@ static int emac_dev_open(struct net_device *ndev)
 			"(mii_bus:phy_addr=%s, id=%x)\n",
 			priv->phydev->drv->name, dev_name(&priv->phydev->dev),
 			priv->phydev->phy_id);
-	} else {
+	}
+
+	if (!priv->phydev) {
 		/* No PHY , fix the link, speed and duplex settings */
 		dev_notice(emac_dev, "no phy, defaulting to 100/full\n");
 		priv->link = 1;
-- 
2.1.4
