From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [RFC PATCH net-next 09/11] xilinx/axienet: remove disable_irq from netpoll controller, use netpoll_irq_lock
Date: Tue,  9 Dec 2014 15:37:20 +0100
Message-ID: <1418135842-21389-10-git-send-email-sd@queasysnail.net>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	Michal Simek <michal.simek@xilinx.com>,
	=?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:53973 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757255AbaLIOji (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 09:39:38 -0500
In-Reply-To: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

disable_irq() may sleep, replace it with a spin_lock in the interrupt
handler and netpoll controller.

No actual testing done, only compiled.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Cc: Anirudha Sarangi <anirudh@xilinx.com>
Cc: John Linn <John.Linn@xilinx.com>
Cc: Michal Simek <michal.simek@xilinx.com>
Cc: "S=C3=B6ren Brinkmann" <soren.brinkmann@xilinx.com>
---
 drivers/net/ethernet/xilinx/xilinx_axienet.h      |  3 +++
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 15 +++++++++------
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet.h b/drivers/net=
/ethernet/xilinx/xilinx_axienet.h
index 44b8d2bad8c3..b871857cb258 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet.h
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet.h
@@ -9,6 +9,7 @@
 #define XILINX_AXIENET_H
=20
 #include <linux/netdevice.h>
+#include <linux/netpoll.h>
 #include <linux/spinlock.h>
 #include <linux/interrupt.h>
=20
@@ -455,6 +456,8 @@ struct axienet_local {
=20
 	u32 coalesce_count_rx;
 	u32 coalesce_count_tx;
+
+	struct netpoll_irq_lock netpoll_lock;
 };
=20
 /**
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/driver=
s/net/ethernet/xilinx/xilinx_axienet_main.c
index 4ea2d4e6f1d1..ff6be3d82618 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -806,6 +806,7 @@ static irqreturn_t axienet_tx_irq(int irq, void *_n=
dev)
 	struct net_device *ndev =3D _ndev;
 	struct axienet_local *lp =3D netdev_priv(ndev);
=20
+	netpoll_irq_lock(&lp->netpoll_lock);
 	status =3D axienet_dma_in32(lp, XAXIDMA_TX_SR_OFFSET);
 	if (status & (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_DELAY_MASK)) {
 		axienet_start_xmit_done(lp->ndev);
@@ -834,6 +835,7 @@ static irqreturn_t axienet_tx_irq(int irq, void *_n=
dev)
 	}
 out:
 	axienet_dma_out32(lp, XAXIDMA_TX_SR_OFFSET, status);
+	netpoll_irq_unlock(&lp->netpoll_lock);
 	return IRQ_HANDLED;
 }
=20
@@ -854,6 +856,7 @@ static irqreturn_t axienet_rx_irq(int irq, void *_n=
dev)
 	struct net_device *ndev =3D _ndev;
 	struct axienet_local *lp =3D netdev_priv(ndev);
=20
+	netpoll_irq_lock(&lp->netpoll_lock);
 	status =3D axienet_dma_in32(lp, XAXIDMA_RX_SR_OFFSET);
 	if (status & (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_DELAY_MASK)) {
 		axienet_recv(lp->ndev);
@@ -882,6 +885,7 @@ static irqreturn_t axienet_rx_irq(int irq, void *_n=
dev)
 	}
 out:
 	axienet_dma_out32(lp, XAXIDMA_RX_SR_OFFSET, status);
+	netpoll_irq_unlock(&lp->netpoll_lock);
 	return IRQ_HANDLED;
 }
=20
@@ -1035,18 +1039,15 @@ static int axienet_change_mtu(struct net_device=
 *ndev, int new_mtu)
  * axienet_poll_controller - Axi Ethernet poll mechanism.
  * @ndev:	Pointer to net_device structure
  *
- * This implements Rx/Tx ISR poll mechanisms. The interrupts are disab=
led prior
- * to polling the ISRs and are enabled back after the polling is done.
+ * This implements Rx/Tx ISR poll mechanisms. The ISRs use a spinlock =
to
+ * protect against reentrancy when polling.
  */
 static void axienet_poll_controller(struct net_device *ndev)
 {
 	struct axienet_local *lp =3D netdev_priv(ndev);
-	disable_irq(lp->tx_irq);
-	disable_irq(lp->rx_irq);
+
 	axienet_rx_irq(lp->tx_irq, ndev);
 	axienet_tx_irq(lp->rx_irq, ndev);
-	enable_irq(lp->tx_irq);
-	enable_irq(lp->rx_irq);
 }
 #endif
=20
@@ -1602,6 +1603,8 @@ static int axienet_of_probe(struct platform_devic=
e *op)
 	if (ret)
 		dev_warn(&op->dev, "error registering MDIO bus\n");
=20
+	netpoll_irq_lock_init(&lp->netpoll_lock);
+
 	ret =3D register_netdev(lp->ndev);
 	if (ret) {
 		dev_err(lp->dev, "register_netdev() error (%i)\n", ret);
--=20
2.1.3
