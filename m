From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 6/7] net: bcmgenet: power up and down integrated GPHY when unused
Date: Mon, 23 Mar 2015 15:09:56 -0700
Message-ID: <1427148597-28337-7-git-send-email-f.fainelli@gmail.com>
References: <1427148597-28337-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34878 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753727AbbCWWL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:11:26 -0400
Received: by pagv19 with SMTP id v19so29493515pag.2
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 15:11:25 -0700 (PDT)
In-Reply-To: <1427148597-28337-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Power up the GPHY while we are bringing-up the network interface, and
conversely, upon bring down, power the GPHY down. In order to avoid
creating hardware hazards, make sure that the GPHY gets powered on
during bcmgenet_open() prior to the UniMAC being reset as the UniMAC may
start creating activity towards the GPHY if we reverse the steps.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 11 ++++++++---
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   |  2 +-
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f86837f1656a..c6b15c3cf023 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -869,6 +869,8 @@ static int bcmgenet_power_down(struct bcmgenet_priv *priv,
 			reg |= (EXT_PWR_DOWN_PHY |
 				EXT_PWR_DOWN_DLL | EXT_PWR_DOWN_BIAS);
 			bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
+
+			bcmgenet_phy_power_set(priv->dev, false);
 		}
 		break;
 	default:
@@ -2465,9 +2467,6 @@ static void bcmgenet_netif_start(struct net_device *dev)
 
 	umac_enable_set(priv, CMD_TX_EN | CMD_RX_EN, true);
 
-	if (phy_is_internal(priv->phydev))
-		bcmgenet_power_up(priv, GENET_POWER_PASSIVE);
-
 	netif_tx_start_all_queues(dev);
 
 	phy_start(priv->phydev);
@@ -2486,6 +2485,12 @@ static int bcmgenet_open(struct net_device *dev)
 	if (!IS_ERR(priv->clk))
 		clk_prepare_enable(priv->clk);
 
+	/* If this is an internal GPHY, power it back on now, before UniMAC is
+	 * brought out of reset as absolutely no UniMAC activity is allowed
+	 */
+	if (phy_is_internal(priv->phydev))
+		bcmgenet_power_up(priv, GENET_POWER_PASSIVE);
+
 	/* take MAC out of reset */
 	bcmgenet_umac_reset(priv);
 
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index a27ef777cc81..7a59879d441f 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -664,6 +664,7 @@ int bcmgenet_mii_init(struct net_device *dev);
 int bcmgenet_mii_config(struct net_device *dev, bool init);
 void bcmgenet_mii_exit(struct net_device *dev);
 void bcmgenet_mii_reset(struct net_device *dev);
+void bcmgenet_phy_power_set(struct net_device *dev, bool enable);
 void bcmgenet_mii_setup(struct net_device *dev);
 
 /* Wake-on-LAN routines */
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 3320219003fb..6d3b66a103cc 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -168,7 +168,7 @@ void bcmgenet_mii_reset(struct net_device *dev)
 	}
 }
 
-static void bcmgenet_phy_power_set(struct net_device *dev, bool enable)
+void bcmgenet_phy_power_set(struct net_device *dev, bool enable)
 {
 	struct bcmgenet_priv *priv = netdev_priv(dev);
 	u32 reg = 0;
-- 
2.1.0
