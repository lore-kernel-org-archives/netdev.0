From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH 2/2] net: ethernet: altera: TSE: do not use tx queue lock in tx completion handler
Date: Wed, 30 Nov 2016 23:48:32 +0100
Message-ID: <1480546112-3099-2-git-send-email-LinoSanfilippo@gmx.de>
References: <1480546112-3099-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: nios2-dev@lists.rocketboards.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: vbridger@opensource.altera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480546112-3099-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver already uses its private lock for synchronization between xmit
and xmit completion handler making the additional use of the xmit_lock
unnecessary.
Furthermore the driver does not set NETIF_F_LLTX resulting in xmit to be
called with the xmit_lock held and then taking the private lock while xmit
completion handler does the reverse, first take the private lock, then the
xmit_lock.
Fix these issues by not taking the xmit_lock in the tx completion handler.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/altera/altera_tse_main.c | 2 --
 1 file changed, 2 deletions(-)

 Please note that this is only compile tested since I do not have the
 concerning hardware.

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index 16c4163..cddc532 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -463,7 +463,6 @@ static int tse_tx_complete(struct altera_tse_private *priv)
 
 	if (unlikely(netif_queue_stopped(priv->dev) &&
 		     tse_tx_avail(priv) > TSE_TX_THRESH(priv))) {
-		netif_tx_lock(priv->dev);
 		if (netif_queue_stopped(priv->dev) &&
 		    tse_tx_avail(priv) > TSE_TX_THRESH(priv)) {
 			if (netif_msg_tx_done(priv))
@@ -471,7 +470,6 @@ static int tse_tx_complete(struct altera_tse_private *priv)
 					   __func__);
 			netif_wake_queue(priv->dev);
 		}
-		netif_tx_unlock(priv->dev);
 	}
 
 	spin_unlock(&priv->tx_lock);
-- 
2.7.4
