From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH CFT 04/30] net: fec: fix interrupt handling races
Date: Fri, 27 Jun 2014 16:19:13 +0100
Message-ID: <E1X0Xvl-0001N2-Q0@rmk-PC.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:45185 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752794AbaF0PTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 11:19:17 -0400
In-Reply-To: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While running: while :; do iperf -c <HOST> -P 4; done, transmit timeouts
are regularly reported.  With the tx ring dumping in place, we can see
that all entries are in use, and the hardware has finished transmitting
these packets.  However, the driver has not reclaimed these ring
entries.

This can occur if the interrupt handler is invoked at the wrong moment -
eg:

	CPU0				CPU1
	fec_enet_tx()
					interrupt, IEVENT = FEC_ENET_TXF
					FEC_ENET_TXF cleared
					napi_schedule_prep()
	napi_complete()

The result is that we clear the transmit interrupt, but we don't trigger
any cleaning of the transmit ring.  Instead, use a different strategy:

- When receiving a transmit or receive interrupt, disable both tx and rx
  interrupts, but do not acknowledge them.  Schedule a napi poll.  Don't
  loop.

- When we are polled, read IEVENT, acknowledging the pending transmit
  and receive interrupts, before then going on to process the
  appropriate rings.

This allows us to avoid the race, and has a number of other advantages:
- we cut down on the number of transmit interrupts we have to process.
- we only look at the rings which have pending events.
- we gain additional throughput: the iperf total bandwidth increases
  from about 180Mbps to 240Mbps:

[  3]  0.0-10.0 sec  68.1 MBytes  57.0 Mbits/sec
[  5]  0.0-10.0 sec  72.4 MBytes  60.5 Mbits/sec
[  4]  0.0-10.1 sec  76.1 MBytes  63.5 Mbits/sec
[  6]  0.0-10.1 sec  71.9 MBytes  59.9 Mbits/sec
[SUM]  0.0-10.1 sec   288 MBytes   241 Mbits/sec

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 40 +++++++++++++++++--------------
 1 file changed, 22 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 045ea71f2b59..4e695b742030 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1369,29 +1369,25 @@ fec_enet_interrupt(int irq, void *dev_id)
 {
 	struct net_device *ndev = dev_id;
 	struct fec_enet_private *fep = netdev_priv(ndev);
+	const unsigned napi_mask = FEC_ENET_RXF | FEC_ENET_TXF;
 	uint int_events;
 	irqreturn_t ret = IRQ_NONE;
 
-	do {
-		int_events = readl(fep->hwp + FEC_IEVENT);
-		writel(int_events, fep->hwp + FEC_IEVENT);
+	int_events = readl(fep->hwp + FEC_IEVENT);
+	writel(int_events & ~napi_mask, fep->hwp + FEC_IEVENT);
 
-		if (int_events & (FEC_ENET_RXF | FEC_ENET_TXF)) {
-			ret = IRQ_HANDLED;
+	if (int_events & napi_mask) {
+		ret = IRQ_HANDLED;
 
-			/* Disable the RX interrupt */
-			if (napi_schedule_prep(&fep->napi)) {
-				writel(FEC_RX_DISABLED_IMASK,
-					fep->hwp + FEC_IMASK);
-				__napi_schedule(&fep->napi);
-			}
-		}
+		/* Disable the NAPI interrupts */
+		writel(FEC_ENET_MII, fep->hwp + FEC_IMASK);
+		napi_schedule(&fep->napi);
+	}
 
-		if (int_events & FEC_ENET_MII) {
-			ret = IRQ_HANDLED;
-			complete(&fep->mdio_done);
-		}
-	} while (int_events);
+	if (int_events & FEC_ENET_MII) {
+		ret = IRQ_HANDLED;
+		complete(&fep->mdio_done);
+	}
 
 	return ret;
 }
@@ -1399,8 +1395,16 @@ fec_enet_interrupt(int irq, void *dev_id)
 static int fec_enet_rx_napi(struct napi_struct *napi, int budget)
 {
 	struct net_device *ndev = napi->dev;
-	int pkts = fec_enet_rx(ndev, budget);
 	struct fec_enet_private *fep = netdev_priv(ndev);
+	int pkts;
+
+	/*
+	 * Clear any pending transmit or receive interrupts before
+	 * processing the rings to avoid racing with the hardware.
+	 */
+	writel(FEC_ENET_RXF | FEC_ENET_TXF, fep->hwp + FEC_IEVENT);
+
+	pkts = fec_enet_rx(ndev, budget);
 
 	fec_enet_tx(ndev);
 
-- 
1.8.3.1
