From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/4] net: systemport: use the new fixed PHY helpers
Date: Mon, 19 May 2014 12:43:43 -0700
Message-ID: <1400528625-32744-3-git-send-email-f.fainelli@gmail.com>
References: <1400528625-32744-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, thomas.petazzoni@free-electrons.com,
	devicetree@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:40947 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932525AbaESTpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 15:45:12 -0400
In-Reply-To: <1400528625-32744-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_phy_connect_fixed_link() is becoming obsolete, and also required
platform code to register the fixed PHYs at the specified addresses for
those to be usable. Get rid of it and use the new of_phy_is_fixed_link()
plus of_phy_register_fixed_link() helpers to transition over the new
scheme.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 18 ++++++++++++++++--
 drivers/net/ethernet/broadcom/bcmsysport.h |  1 +
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index d40c5b969e9e..6368a085bdae 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1327,8 +1327,8 @@ static int bcm_sysport_open(struct net_device *dev)
 	/* Read CRC forward */
 	priv->crc_fwd = !!(umac_readl(priv, UMAC_CMD) & CMD_CRC_FWD);
 
-	priv->phydev = of_phy_connect_fixed_link(dev, bcm_sysport_adj_link,
-							priv->phy_interface);
+	priv->phydev = of_phy_connect(dev, priv->phy_dn, bcm_sysport_adj_link,
+					0, priv->phy_interface);
 	if (!priv->phydev) {
 		netdev_err(dev, "could not attach to PHY\n");
 		return -ENODEV;
@@ -1551,6 +1551,20 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 	if (priv->phy_interface < 0)
 		priv->phy_interface = PHY_INTERFACE_MODE_GMII;
 
+	/* SYSTEMPORT uses the old 'fixed-link' 5-digit property which is
+	 * deprecated, we need to register the fixed PHY using the Ethernet
+	 * MAC node since we do not have a 'fixed-link' subnode.
+	 */
+	if (of_phy_is_fixed_link(dn)) {
+		ret = of_phy_register_fixed_link(dn);
+		if (ret) {
+			dev_err(&pdev->dev, "failed to register fixed PHY\n");
+			goto err;
+		}
+
+		priv->phy_dn = dn;
+	}
+
 	/* Initialize netdevice members */
 	macaddr = of_get_mac_address(dn);
 	if (!macaddr || !is_valid_ether_addr(macaddr)) {
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index abdeb62616df..73fd04a94797 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -656,6 +656,7 @@ struct bcm_sysport_priv {
 	unsigned int		rx_c_index;
 
 	/* PHY device */
+	struct device_node	*phy_dn;
 	struct phy_device	*phydev;
 	phy_interface_t		phy_interface;
 	int			old_pause;
-- 
1.9.1
