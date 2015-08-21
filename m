From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: bcmgenet: Avoid sleeping in bcmgenet_timeout
Date: Thu, 20 Aug 2015 18:04:22 -0700
Message-ID: <1440119062-19677-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:33409 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbbHUBGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 21:06:45 -0400
Received: by pdrh1 with SMTP id h1so20446336pdr.0
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 18:06:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcmgenet_timeout() executes in atomic context, yet we will invoke
napi_disable() which does sleep. Looking back at the changes, disabling
TX napi and re-enabling it is completely useless, since we reclaim all
TX buffers and re-enable interrupts, and wake up the TX queues.

Fixes: 13ea657806cf ("net: bcmgenet: improve TX timeout")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Hi David,

Sorry this is caming very late, if this does not make it to 4.2, can you
queue this for the 4.2.1 stable tree when it shows up?

Thank you!

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 64c1e9db6b0b..12a020c105bb 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2820,8 +2820,6 @@ static void bcmgenet_timeout(struct net_device *dev)
 
 	netif_dbg(priv, tx_err, dev, "bcmgenet_timeout\n");
 
-	bcmgenet_disable_tx_napi(priv);
-
 	for (q = 0; q < priv->hw_params->tx_queues; q++)
 		bcmgenet_dump_tx_queue(&priv->tx_rings[q]);
 	bcmgenet_dump_tx_queue(&priv->tx_rings[DESC_INDEX]);
@@ -2837,8 +2835,6 @@ static void bcmgenet_timeout(struct net_device *dev)
 	bcmgenet_intrl2_0_writel(priv, int0_enable, INTRL2_CPU_MASK_CLEAR);
 	bcmgenet_intrl2_1_writel(priv, int1_enable, INTRL2_CPU_MASK_CLEAR);
 
-	bcmgenet_enable_tx_napi(priv);
-
 	dev->trans_start = jiffies;
 
 	dev->stats.tx_errors++;
-- 
2.1.0
