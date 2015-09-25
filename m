From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v2 6/7] net: mvneta: Allow different queues
Date: Fri, 25 Sep 2015 18:09:37 +0200
Message-ID: <1443197378-30717-7-git-send-email-gregory.clement@free-electrons.com>
References: <1443197378-30717-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Willy Tarreau <w@1wt.eu>, linux-arm-kernel@lists.infradead.org
To: Thomas Gleixner <tglx@linutronix.de>,
	Jason Cooper <jason@lakedaemon.net>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443197378-30717-1-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxime Ripard <maxime.ripard@free-electrons.com>

The mvneta driver allows to change the default RX queue trough the rxq_def
kernel parameter.

However, the current code doesn't allow to have any value but 0. It is
actively checked for in the driver's probe because the drivers makes a
number of assumption and takes a number of shortcuts in order to just use
that RX queue.

Remove these limitations in order to be able to specify any available
queue.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 80 +++++------------------------------
 1 file changed, 11 insertions(+), 69 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index a78ca1d6e414..401d018a96b8 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -478,7 +478,7 @@ struct mvneta_rx_queue {
 /* The hardware supports eight (8) rx queues, but we are only allowing
  * the first one to be used. Therefore, let's just allocate one queue.
  */
-static int rxq_number = 1;
+static int rxq_number = 8;
 static int txq_number = 8;
 
 static int rxq_def;
@@ -766,14 +766,7 @@ static void mvneta_port_up(struct mvneta_port *pp)
 	mvreg_write(pp, MVNETA_TXQ_CMD, q_map);
 
 	/* Enable all initialized RXQs. */
-	q_map = 0;
-	for (queue = 0; queue < rxq_number; queue++) {
-		struct mvneta_rx_queue *rxq = &pp->rxqs[queue];
-		if (rxq->descs != NULL)
-			q_map |= (1 << queue);
-	}
-
-	mvreg_write(pp, MVNETA_RXQ_CMD, q_map);
+	mvreg_write(pp, MVNETA_RXQ_CMD, BIT(rxq_def));
 }
 
 /* Stop the Ethernet port activity */
@@ -1436,17 +1429,6 @@ static u32 mvneta_skb_tx_csum(struct mvneta_port *pp, struct sk_buff *skb)
 	return MVNETA_TX_L4_CSUM_NOT;
 }
 
-/* Returns rx queue pointer (find last set bit) according to causeRxTx
- * value
- */
-static struct mvneta_rx_queue *mvneta_rx_policy(struct mvneta_port *pp,
-						u32 cause)
-{
-	int queue = fls(cause >> 8) - 1;
-
-	return (queue < 0 || queue >= rxq_number) ? NULL : &pp->rxqs[queue];
-}
-
 /* Drop packets received by the RXQ and free buffers */
 static void mvneta_rxq_drop_pkts(struct mvneta_port *pp,
 				 struct mvneta_rx_queue *rxq)
@@ -2144,33 +2126,8 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 	 * RX packets
 	 */
 	cause_rx_tx |= port->cause_rx_tx;
-	if (rxq_number > 1) {
-		while ((cause_rx_tx & MVNETA_RX_INTR_MASK_ALL) && (budget > 0)) {
-			int count;
-			struct mvneta_rx_queue *rxq;
-			/* get rx queue number from cause_rx_tx */
-			rxq = mvneta_rx_policy(pp, cause_rx_tx);
-			if (!rxq)
-				break;
-
-			/* process the packet in that rx queue */
-			count = mvneta_rx(pp, budget, rxq);
-			rx_done += count;
-			budget -= count;
-			if (budget > 0) {
-				/* set off the rx bit of the
-				 * corresponding bit in the cause rx
-				 * tx register, so that next iteration
-				 * will find the next rx queue where
-				 * packets are received on
-				 */
-				cause_rx_tx &= ~((1 << rxq->id) << 8);
-			}
-		}
-	} else {
-		rx_done = mvneta_rx(pp, budget, &pp->rxqs[rxq_def]);
-		budget -= rx_done;
-	}
+	rx_done = mvneta_rx(pp, budget, &pp->rxqs[rxq_def]);
+	budget -= rx_done;
 
 	if (budget > 0) {
 		cause_rx_tx = 0;
@@ -2382,26 +2339,19 @@ static void mvneta_cleanup_txqs(struct mvneta_port *pp)
 /* Cleanup all Rx queues */
 static void mvneta_cleanup_rxqs(struct mvneta_port *pp)
 {
-	int queue;
-
-	for (queue = 0; queue < rxq_number; queue++)
-		mvneta_rxq_deinit(pp, &pp->rxqs[queue]);
+	mvneta_rxq_deinit(pp, &pp->rxqs[rxq_def]);
 }
 
 
 /* Init all Rx queues */
 static int mvneta_setup_rxqs(struct mvneta_port *pp)
 {
-	int queue;
-
-	for (queue = 0; queue < rxq_number; queue++) {
-		int err = mvneta_rxq_init(pp, &pp->rxqs[queue]);
-		if (err) {
-			netdev_err(pp->dev, "%s: can't create rxq=%d\n",
-				   __func__, queue);
-			mvneta_cleanup_rxqs(pp);
-			return err;
-		}
+	int err = mvneta_rxq_init(pp, &pp->rxqs[rxq_def]);
+	if (err) {
+		netdev_err(pp->dev, "%s: can't create rxq=%d\n",
+			   __func__, rxq_def);
+		mvneta_cleanup_rxqs(pp);
+		return err;
 	}
 
 	return 0;
@@ -3049,14 +2999,6 @@ static int mvneta_probe(struct platform_device *pdev)
 	int err;
 	int cpu;
 
-	/* Our multiqueue support is not complete, so for now, only
-	 * allow the usage of the first RX queue
-	 */
-	if (rxq_def != 0) {
-		dev_err(&pdev->dev, "Invalid rxq_def argument: %d\n", rxq_def);
-		return -EINVAL;
-	}
-
 	dev = alloc_etherdev_mqs(sizeof(struct mvneta_port), txq_number, rxq_number);
 	if (!dev)
 		return -ENOMEM;
-- 
2.1.0
