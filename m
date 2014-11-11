From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/2] net: bcmgenet: connect and disconnect from the PHY state machine
Date: Mon, 10 Nov 2014 18:06:20 -0800
Message-ID: <1415671581-2835-2-git-send-email-f.fainelli@gmail.com>
References: <1415671581-2835-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:45357 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbaKKCG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 21:06:27 -0500
Received: by mail-pd0-f171.google.com with SMTP id r10so9074466pdi.30
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 18:06:27 -0800 (PST)
In-Reply-To: <1415671581-2835-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy_disconnect() is the only way to guarantee that we are not going to
schedule more work on the PHY state machine workqueue for that
particular PHY device.

This fixes an issue where a network interface was suspended prior to a
system suspend/resume cycle and would then be resumed as part of
mdio_bus_resume(), since the GENET interface clocks would have been
disabled, this basically resulted in bus errors to appear since we are
invoking the GENET driver adjust_link() callback.

Fixes: b6e978e50444 ("net: bcmgenet: add suspend/resume callbacks")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 6 ++++++
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 2 +-
 3 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index fdc9ec09e453..34055fd59c74 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2140,6 +2140,9 @@ static int bcmgenet_open(struct net_device *dev)
 		goto err_irq0;
 	}
 
+	phy_connect_direct(dev, priv->phydev, bcmgenet_mii_setup,
+			   priv->phy_interface);
+
 	bcmgenet_netif_start(dev);
 
 	return 0;
@@ -2184,6 +2187,9 @@ static int bcmgenet_close(struct net_device *dev)
 
 	bcmgenet_netif_stop(dev);
 
+	/* Really kill the PHY state machine and disconnect from it */
+	phy_disconnect(priv->phydev);
+
 	/* Disable MAC receive */
 	umac_enable_set(priv, CMD_RX_EN, false);
 
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index dbf524ea3b19..44b55b8c220f 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -620,6 +620,7 @@ int bcmgenet_mii_init(struct net_device *dev);
 int bcmgenet_mii_config(struct net_device *dev);
 void bcmgenet_mii_exit(struct net_device *dev);
 void bcmgenet_mii_reset(struct net_device *dev);
+void bcmgenet_mii_setup(struct net_device *dev);
 
 /* Wake-on-LAN routines */
 void bcmgenet_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol);
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 9ff799a9f801..9c5fee782ccf 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -77,7 +77,7 @@ static int bcmgenet_mii_write(struct mii_bus *bus, int phy_id,
 /* setup netdev link state when PHY link status change and
  * update UMAC and RGMII block when link up
  */
-static void bcmgenet_mii_setup(struct net_device *dev)
+void bcmgenet_mii_setup(struct net_device *dev)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	struct phy_device *phydev = priv->phydev;
-- 
1.9.1
