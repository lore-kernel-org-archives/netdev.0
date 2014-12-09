From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [RFC PATCH net-next 08/11] ll_temac: remove disable_irq from netpoll controller, use netpoll_irq_lock
Date: Tue,  9 Dec 2014 15:37:19 +0100
Message-ID: <1418135842-21389-9-git-send-email-sd@queasysnail.net>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>,
	Michal Simek <michal.simek@xilinx.com>,
	=?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:53669 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757090AbaLIOjc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 09:39:32 -0500
In-Reply-To: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

disable_irq() may sleep, replace it with a spin_lock in the interrupt
handler and netpoll controller.

No actual testing done, only compiled.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Cc: Michal Simek <michal.simek@xilinx.com>
Cc: "S=C3=B6ren Brinkmann" <soren.brinkmann@xilinx.com>
---
 drivers/net/ethernet/xilinx/ll_temac.h      |  3 +++
 drivers/net/ethernet/xilinx/ll_temac_main.c | 13 +++++++------
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac.h b/drivers/net/ether=
net/xilinx/ll_temac.h
index 522abe2ff25a..09906958a689 100644
--- a/drivers/net/ethernet/xilinx/ll_temac.h
+++ b/drivers/net/ethernet/xilinx/ll_temac.h
@@ -3,6 +3,7 @@
 #define XILINX_LL_TEMAC_H
=20
 #include <linux/netdevice.h>
+#include <linux/netpoll.h>
 #include <linux/of.h>
 #include <linux/spinlock.h>
=20
@@ -368,6 +369,8 @@ struct temac_local {
 	int tx_bd_next;
 	int tx_bd_tail;
 	int rx_bd_ci;
+
+	struct netpoll_irq_lock netpoll_lock;
 };
=20
 /* xilinx_temac.c */
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/=
ethernet/xilinx/ll_temac_main.c
index 9c2d91ea0af4..37c3f9588208 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -815,6 +815,7 @@ static irqreturn_t ll_temac_tx_irq(int irq, void *_=
ndev)
 	struct temac_local *lp =3D netdev_priv(ndev);
 	unsigned int status;
=20
+	netpoll_irq_lock(&lp->netpoll_lock);
 	status =3D lp->dma_in(lp, TX_IRQ_REG);
 	lp->dma_out(lp, TX_IRQ_REG, status);
=20
@@ -823,6 +824,8 @@ static irqreturn_t ll_temac_tx_irq(int irq, void *_=
ndev)
 	if (status & 0x080)
 		dev_err(&ndev->dev, "DMA error 0x%x\n", status);
=20
+	netpoll_irq_unlock(&lp->netpoll_lock);
+
 	return IRQ_HANDLED;
 }
=20
@@ -832,6 +835,7 @@ static irqreturn_t ll_temac_rx_irq(int irq, void *_=
ndev)
 	struct temac_local *lp =3D netdev_priv(ndev);
 	unsigned int status;
=20
+	netpoll_irq_lock(&lp->netpoll_lock);
 	/* Read and clear the status registers */
 	status =3D lp->dma_in(lp, RX_IRQ_REG);
 	lp->dma_out(lp, RX_IRQ_REG, status);
@@ -839,6 +843,8 @@ static irqreturn_t ll_temac_rx_irq(int irq, void *_=
ndev)
 	if (status & (IRQ_COAL | IRQ_DLY))
 		ll_temac_recv(lp->ndev);
=20
+	netpoll_irq_unlock(&lp->netpoll_lock);
+
 	return IRQ_HANDLED;
 }
=20
@@ -905,14 +911,8 @@ temac_poll_controller(struct net_device *ndev)
 {
 	struct temac_local *lp =3D netdev_priv(ndev);
=20
-	disable_irq(lp->tx_irq);
-	disable_irq(lp->rx_irq);
-
 	ll_temac_rx_irq(lp->tx_irq, ndev);
 	ll_temac_tx_irq(lp->rx_irq, ndev);
-
-	enable_irq(lp->tx_irq);
-	enable_irq(lp->rx_irq);
 }
 #endif
=20
@@ -1037,6 +1037,7 @@ static int temac_of_probe(struct platform_device =
*op)
 	lp->dev =3D &op->dev;
 	lp->options =3D XTE_OPTION_DEFAULTS;
 	spin_lock_init(&lp->rx_lock);
+	netpoll_irq_lock_init(&lp->netpoll_lock);
 	mutex_init(&lp->indirect_mutex);
=20
 	/* map device registers */
--=20
2.1.3
