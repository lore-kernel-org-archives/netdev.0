From: Shuyu Wei <sy.w-1ViLX0X+lBJBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] ethernet:arc: Move arc_emac_tx_clean() into arc_emac_tx()
 and disable tx interrupt
Date: Tue, 5 Jan 2016 17:16:54 +0800
Message-ID: <BLU436-SMTP1175E4C81F4C2DFF5BF8FEA8FF30@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline; filename="mail.txt"
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Doing tx_clean() inside poll() may scramble the tx ring buffer if 
tx() is running. This will cause tx to stop working, which can be
reproduced by simultaneously downloading two large files at high speed.

Moving tx_clean() into tx() will prevent this. And tx interrupt is no
longer needed now.

Signed-off-by: Shuyu Wei <shuyu.w-1ViLX0X+lBJBDgjK7y7TUQ@public.gmane.org>
---

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index abe1eab..34531b3 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -311,12 +311,10 @@ static int arc_emac_poll(struct napi_struct *napi, int budget)
 	struct arc_emac_priv *priv = netdev_priv(ndev);
 	unsigned int work_done;
 
-	arc_emac_tx_clean(ndev);
-
 	work_done = arc_emac_rx(ndev, budget);
 	if (work_done < budget) {
 		napi_complete(napi);
-		arc_reg_or(priv, R_ENABLE, RXINT_MASK | TXINT_MASK);
+		arc_reg_or(priv, R_ENABLE, RXINT_MASK);
 	}
 
 	return work_done;
@@ -345,9 +343,9 @@ static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
 	/* Reset all flags except "MDIO complete" */
 	arc_reg_set(priv, R_STATUS, status);
 
-	if (status & (RXINT_MASK | TXINT_MASK)) {
+	if (status & RXINT_MASK) {
 		if (likely(napi_schedule_prep(&priv->napi))) {
-			arc_reg_clr(priv, R_ENABLE, RXINT_MASK | TXINT_MASK);
+			arc_reg_clr(priv, R_ENABLE, RXINT_MASK);
 			__napi_schedule(&priv->napi);
 		}
 	}
@@ -458,7 +456,7 @@ static int arc_emac_open(struct net_device *ndev)
 	arc_reg_set(priv, R_TX_RING, (unsigned int)priv->txbd_dma);
 
 	/* Enable interrupts */
-	arc_reg_set(priv, R_ENABLE, RXINT_MASK | TXINT_MASK | ERR_MASK);
+	arc_reg_set(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
 
 	/* Set CONTROL */
 	arc_reg_set(priv, R_CTRL,
@@ -529,7 +527,7 @@ static int arc_emac_stop(struct net_device *ndev)
 	netif_stop_queue(ndev);
 
 	/* Disable interrupts */
-	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | TXINT_MASK | ERR_MASK);
+	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
 
 	/* Disable EMAC */
 	arc_reg_clr(priv, R_CTRL, EN_MASK);
@@ -587,6 +585,8 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
 	__le32 *info = &priv->txbd[*txbd_curr].info;
 	dma_addr_t addr;
 
+	arc_emac_tx_clean(ndev);
+
 	if (skb_padto(skb, ETH_ZLEN))
 		return NETDEV_TX_OK;
