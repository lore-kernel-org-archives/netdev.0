From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/5] net: systemport: add bcm_sysport_netif_{enable,stop}
Date: Tue,  1 Jul 2014 21:08:37 -0700
Message-ID: <1404274120-5717-3-git-send-email-f.fainelli@gmail.com>
References: <1404274120-5717-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:58411 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbaGBEJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:09:09 -0400
Received: by mail-qa0-f54.google.com with SMTP id v10so8644182qac.13
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:09:09 -0700 (PDT)
In-Reply-To: <1404274120-5717-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Factor common code that either enables or disables the network
interface with the networking stack. We are going to reuse these
functions for suspend/resume callbacks.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 40 ++++++++++++++++++++----------
 1 file changed, 27 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index bbe74494c629..8f6ab266b178 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1295,6 +1295,22 @@ static void topctrl_flush(struct bcm_sysport_priv *priv)
 	topctrl_writel(priv, 0, TX_FLUSH_CNTL);
 }
 
+static void bcm_sysport_netif_start(struct net_device *dev)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+
+	/* Enable NAPI */
+	napi_enable(&priv->napi);
+
+	phy_start(priv->phydev);
+
+	/* Enable TX interrupts for the 32 TXQs */
+	intrl2_1_mask_clear(priv, 0xffffffff);
+
+	/* Last call before we start the real business */
+	netif_tx_start_all_queues(dev);
+}
+
 static int bcm_sysport_open(struct net_device *dev)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
@@ -1394,19 +1410,10 @@ static int bcm_sysport_open(struct net_device *dev)
 	if (ret)
 		goto out_clear_rx_int;
 
-	/* Enable NAPI */
-	napi_enable(&priv->napi);
-
 	/* Turn on UniMAC TX/RX */
 	umac_enable_set(priv, CMD_RX_EN | CMD_TX_EN, 1);
 
-	phy_start(priv->phydev);
-
-	/* Enable TX interrupts for the 32 TXQs */
-	intrl2_1_mask_clear(priv, 0xffffffff);
-
-	/* Last call before we start the real business */
-	netif_tx_start_all_queues(dev);
+	bcm_sysport_netif_start(dev);
 
 	return 0;
 
@@ -1425,11 +1432,9 @@ out_phy_disconnect:
 	return ret;
 }
 
-static int bcm_sysport_stop(struct net_device *dev)
+static void bcm_sysport_netif_stop(struct net_device *dev)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
-	unsigned int i;
-	int ret;
 
 	/* stop all software from updating hardware */
 	netif_tx_stop_all_queues(dev);
@@ -1441,6 +1446,15 @@ static int bcm_sysport_stop(struct net_device *dev)
 	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
 	intrl2_1_mask_set(priv, 0xffffffff);
 	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
+}
+
+static int bcm_sysport_stop(struct net_device *dev)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	unsigned int i;
+	int ret;
+
+	bcm_sysport_netif_stop(dev);
 
 	/* Disable UniMAC RX */
 	umac_enable_set(priv, CMD_RX_EN, 0);
-- 
1.9.1
