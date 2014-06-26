From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/3] net: bcmgenet: disable clock before register_netdev
Date: Thu, 26 Jun 2014 10:26:20 -0700
Message-ID: <1403803582-13472-2-git-send-email-f.fainelli@gmail.com>
References: <1403803582-13472-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:35628 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757295AbaFZR0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 13:26:35 -0400
Received: by mail-qg0-f44.google.com with SMTP id j107so3337772qga.17
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 10:26:35 -0700 (PDT)
In-Reply-To: <1403803582-13472-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As soon as register_netdev() is called, the network device notifiers are
running which means that other parts of the kernel, or user-space
programs can call the network device ndo_open() callback and use the
interface.

Disable the Ethernet device clock before we register the network device
such that we do not create the following situation:

CPU0				CPU1
register_netdev()
				bcmgenet_open()
				clk_prepare_enable()
clk_disable_unprepare()

and leave the hardware block gated off, while we think it should be
gated on.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 5ba1cfbd60da..d17953cc5f49 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2535,14 +2535,14 @@ static int bcmgenet_probe(struct platform_device *pdev)
 	netif_set_real_num_tx_queues(priv->dev, priv->hw_params->tx_queues + 1);
 	netif_set_real_num_rx_queues(priv->dev, priv->hw_params->rx_queues + 1);
 
-	err = register_netdev(dev);
-	if (err)
-		goto err_clk_disable;
-
 	/* Turn off the main clock, WOL clock is handled separately */
 	if (!IS_ERR(priv->clk))
 		clk_disable_unprepare(priv->clk);
 
+	err = register_netdev(dev);
+	if (err)
+		goto err;
+
 	return err;
 
 err_clk_disable:
-- 
1.9.1
