From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH 2/2] net: ethernet: stmmac: do not use xmit_lock in tx completion handler
Date: Sat,  3 Dec 2016 00:06:06 +0100
Message-ID: <1480719966-12839-3-git-send-email-LinoSanfilippo@gmx.de>
References: <1480719966-12839-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480719966-12839-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver already uses its private lock for synchronization between the
xmit function and the xmit completion handler, making the additional use of
the xmit_lock unnecessary.
Furthermore the driver does not set NETIF_F_LLTX resulting in xmit to be
called with the xmit_lock held and then taking the private lock.
On the other hand the xmit completion handler uses the reverse locking
order, by first taking the private lock, and then the xmit_lock, which
leads to the potential danger of a deadlock.

Fix this issue by not taking the xmit_lock in the completion handler.
By doing this also remove an unnecessary double check for a stopped tx
queue.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

Please note that this patch is only compile tested.

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 48a4e84..8def423 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1380,14 +1380,9 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 
 	if (unlikely(netif_queue_stopped(priv->dev) &&
 		     stmmac_tx_avail(priv) > STMMAC_TX_THRESH)) {
-		netif_tx_lock(priv->dev);
-		if (netif_queue_stopped(priv->dev) &&
-		    stmmac_tx_avail(priv) > STMMAC_TX_THRESH) {
-			netif_dbg(priv, tx_done, priv->dev,
-				  "%s: restart transmit\n", __func__);
-			netif_wake_queue(priv->dev);
-		}
-		netif_tx_unlock(priv->dev);
+		netif_dbg(priv, tx_done, priv->dev,
+			  "%s: restart transmit\n", __func__);
+		netif_wake_queue(priv->dev);
 	}
 
 	if ((priv->eee_enabled) && (!priv->tx_path_in_lpi_mode)) {
-- 
1.9.1
