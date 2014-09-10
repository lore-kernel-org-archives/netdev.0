From: Beniamino Galvani <b.galvani@gmail.com>
Subject: [PATCH v2 1/2] net: arc_emac: enable tx interrupts
Date: Wed, 10 Sep 2014 22:50:02 +0200
Message-ID: <1410382203-10395-2-git-send-email-b.galvani@gmail.com>
References: <1410382203-10395-1-git-send-email-b.galvani@gmail.com>
Cc: Romain Perier <romain.perier@gmail.com>,
	=?UTF-8?q?Heiko=20St=C3=BCbner?= <heiko@sntech.de>,
	Arnd Bergmann <arnd@arndb.de>,
	Tobias Klauser <tklauser@distanz.ch>,
	Jingoo Han <jg1.han@samsung.com>,
	Max Schwarz <max.schwarz@online.de>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Beniamino Galvani <b.galvani@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410382203-10395-1-git-send-email-b.galvani@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the current implementation the cleaning of tx ring is done by the
NAPI poll handler, which is scheduled after rx interrupts. Thus, in
absence of received packets the reclaim of used tx buffers is never
executed, blocking further transmission.

This can be easily reproduced starting the transmission of a UDP flow
with iperf, which blocks almost immediately because skbs are not
returned to the stack and the socket send buffer becomes full.

The patch enables tx interrupts so that the tx reclaim is scheduled
after completed transmissions.

Signed-off-by: Beniamino Galvani <b.galvani@gmail.com>
---
 drivers/net/ethernet/arc/emac_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index dbea847..1d08f63 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -300,7 +300,7 @@ static int arc_emac_poll(struct napi_struct *napi, int budget)
 	work_done = arc_emac_rx(ndev, budget);
 	if (work_done < budget) {
 		napi_complete(napi);
-		arc_reg_or(priv, R_ENABLE, RXINT_MASK);
+		arc_reg_or(priv, R_ENABLE, RXINT_MASK | TXINT_MASK);
 	}
 
 	return work_done;
@@ -329,9 +329,9 @@ static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
 	/* Reset all flags except "MDIO complete" */
 	arc_reg_set(priv, R_STATUS, status);
 
-	if (status & RXINT_MASK) {
+	if (status & (RXINT_MASK | TXINT_MASK)) {
 		if (likely(napi_schedule_prep(&priv->napi))) {
-			arc_reg_clr(priv, R_ENABLE, RXINT_MASK);
+			arc_reg_clr(priv, R_ENABLE, RXINT_MASK | TXINT_MASK);
 			__napi_schedule(&priv->napi);
 		}
 	}
@@ -442,7 +442,7 @@ static int arc_emac_open(struct net_device *ndev)
 	arc_reg_set(priv, R_TX_RING, (unsigned int)priv->txbd_dma);
 
 	/* Enable interrupts */
-	arc_reg_set(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
+	arc_reg_set(priv, R_ENABLE, RXINT_MASK | TXINT_MASK | ERR_MASK);
 
 	/* Set CONTROL */
 	arc_reg_set(priv, R_CTRL,
@@ -513,7 +513,7 @@ static int arc_emac_stop(struct net_device *ndev)
 	netif_stop_queue(ndev);
 
 	/* Disable interrupts */
-	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
+	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | TXINT_MASK | ERR_MASK);
 
 	/* Disable EMAC */
 	arc_reg_clr(priv, R_CTRL, EN_MASK);
-- 
1.9.1
