From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] staging: netlogic: Fix build error due to missed API change
Date: Mon, 11 Jan 2016 00:57:43 +0100
Message-ID: <1452470263-25993-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45094 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757294AbcAJX5q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jan 2016 18:57:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a number of build errors due to moving the phy_map and centralizing
interrupt allocation.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/staging/netlogic/xlr_net.c | 29 +++++++++++++----------------
 1 file changed, 13 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/netlogic/xlr_net.c b/drivers/staging/netlogic/xlr_net.c
index cbc25b7e70a2..0b4e819f5164 100644
--- a/drivers/staging/netlogic/xlr_net.c
+++ b/drivers/staging/netlogic/xlr_net.c
@@ -165,13 +165,18 @@ static void xlr_net_fmn_handler(int bkt, int src_stnid, int size,
 	}
 }
 
+static struct phy_device *xlr_get_phydev(struct xlr_net_priv *priv)
+{
+	return mdiobus_get_phy(priv->mii_bus, priv->phy_addr);
+}
+
 /*
  * Ethtool operation
  */
 static int xlr_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 {
 	struct xlr_net_priv *priv = netdev_priv(ndev);
-	struct phy_device *phydev = priv->mii_bus->phy_map[priv->phy_addr];
+	struct phy_device *phydev = xlr_get_phydev(priv);
 
 	if (!phydev)
 		return -ENODEV;
@@ -181,7 +186,7 @@ static int xlr_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 static int xlr_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 {
 	struct xlr_net_priv *priv = netdev_priv(ndev);
-	struct phy_device *phydev = priv->mii_bus->phy_map[priv->phy_addr];
+	struct phy_device *phydev = xlr_get_phydev(priv);
 
 	if (!phydev)
 		return -ENODEV;
@@ -218,7 +223,7 @@ static int xlr_net_open(struct net_device *ndev)
 {
 	u32 err;
 	struct xlr_net_priv *priv = netdev_priv(ndev);
-	struct phy_device *phydev = priv->mii_bus->phy_map[priv->phy_addr];
+	struct phy_device *phydev = xlr_get_phydev(priv);
 
 	/* schedule a link state check */
 	phy_start(phydev);
@@ -239,7 +244,7 @@ static int xlr_net_open(struct net_device *ndev)
 static int xlr_net_stop(struct net_device *ndev)
 {
 	struct xlr_net_priv *priv = netdev_priv(ndev);
-	struct phy_device *phydev = priv->mii_bus->phy_map[priv->phy_addr];
+	struct phy_device *phydev = xlr_get_phydev(priv);
 
 	phy_stop(phydev);
 	netif_tx_stop_all_queues(ndev);
@@ -268,7 +273,7 @@ static void __maybe_unused xlr_wakeup_queue(unsigned long dev)
 {
 	struct net_device *ndev = (struct net_device *) dev;
 	struct xlr_net_priv *priv = netdev_priv(ndev);
-	struct phy_device *phydev = priv->mii_bus->phy_map[priv->phy_addr];
+	struct phy_device *phydev = xlr_get_phydev(priv);
 
 	if (phydev->link)
 		netif_tx_wake_queue(netdev_get_tx_queue(ndev, priv->wakeup_q));
@@ -771,7 +776,7 @@ static void xlr_sgmii_init(struct xlr_net_priv *priv)
 
 void xlr_set_gmac_speed(struct xlr_net_priv *priv)
 {
-	struct phy_device *phydev = priv->mii_bus->phy_map[priv->phy_addr];
+	struct phy_device *phydev = xlr_get_phydev(priv);
 	int speed;
 
 	if (phydev->interface == PHY_INTERFACE_MODE_SGMII)
@@ -813,7 +818,7 @@ void xlr_set_gmac_speed(struct xlr_net_priv *priv)
 static void xlr_gmac_link_adjust(struct net_device *ndev)
 {
 	struct xlr_net_priv *priv = netdev_priv(ndev);
-	struct phy_device *phydev = priv->mii_bus->phy_map[priv->phy_addr];
+	struct phy_device *phydev = xlr_get_phydev(priv);
 	u32 intreg;
 
 	intreg = xlr_nae_rdreg(priv->base_addr, R_INTREG);
@@ -830,7 +835,7 @@ static void xlr_gmac_link_adjust(struct net_device *ndev)
 
 static int xlr_mii_probe(struct xlr_net_priv *priv)
 {
-	struct phy_device *phydev = priv->mii_bus->phy_map[priv->phy_addr];
+	struct phy_device *phydev = xlr_get_phydev(priv);
 
 	if (!phydev) {
 		pr_err("no PHY found on phy_addr %d\n", priv->phy_addr);
@@ -876,14 +881,6 @@ static int xlr_setup_mdio(struct xlr_net_priv *priv,
 	priv->mii_bus->read = xlr_mii_read;
 	priv->mii_bus->write = xlr_mii_write;
 	priv->mii_bus->parent = &pdev->dev;
-	priv->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
-	if (priv->mii_bus->irq == NULL) {
-		pr_err("irq alloc failed\n");
-		mdiobus_free(priv->mii_bus);
-		return -ENOMEM;
-	}
-
-	priv->mii_bus->irq[priv->phy_addr] = priv->ndev->irq;
 
 	/* Scan only the enabled address */
 	priv->mii_bus->phy_mask = ~(1 << priv->phy_addr);
-- 
2.6.4
