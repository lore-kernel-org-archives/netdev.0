From: Hector Palacios <hector.palacios@digi.com>
Subject: [PATCH] net/fec: infinite spin on sirq-net-tx on real-time
Date: Mon, 6 Feb 2012 10:33:30 +0100
Message-ID: <1328520810-28030-1-git-send-email-hector.palacios@digi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <shawn.guo@linaro.org>, <jgq516@gmail.com>,
	<rostedt@goodmis.org>, <tim.sander@hbm.com>,
	<u.kleine-koenig@pengutronix.de>, <tglx@linutronix.de>,
	Hector Palacios <hector.palacios@digi.com>,
	Zeng Zhaoming <b32542@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail46.messagelabs.com ([216.82.241.196]:61714 "EHLO
	mail46.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754075Ab2BFJnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 04:43:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If softirqd is a real time task, an inifinite spin is hit
if the FEC driver tries to send a packet before the autonegotiation
with the PHY has completed.

This was seen when booting the platform with DHCP on. The driver
sends the DHCP request before the PHY has completed autonegotiation.
As a consequence, the driver's dev_hard_start_xmit returns NETDEV_TX_BUSY.
NETDEV_TX_BUSY is part of NET_TX_MASK thus the packet is requeued (the
skb->next = nskb) in dev_hard_start_xmit(). And the NETDEV_TX_BUSY is
passed back to sch_derect_xmit() which calls dev_requeue_skb() which
then calls __netif_schedule(q) which will call __netif_reschedule(q)
which will then do raise_softirq_irqoff(NET_TX_SOFTIRQ).

Thus, as soon as ksoftirq exits this routine, it will restart the
process over again. As the fec driver never finished with its
negotiations, the process starts over again and we never move forward.

Newsgroup reference: linux-rt-users http://www.spinics.net/lists/linux-rt-users/msg07551.html

Signed-off-by: Zeng Zhaoming <b32542@freescale.com>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
Signed-off-by: Hector Palacios <hector.palacios@digi.com>
---
 drivers/net/ethernet/freescale/fec.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index c136230..3fa7d3b 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -284,6 +284,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	if (!fep->link) {
 		/* Link is down or autonegotiation is in progress. */
+		netif_stop_queue(dev);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -530,6 +531,7 @@ fec_stop(struct net_device *ndev)
 	udelay(10);
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
+	fep->link = 0;
 
 	/* We have to keep ENET enabled to have MII interrupt stay working */
 	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC)
@@ -866,6 +868,7 @@ static void fec_enet_adjust_link(struct net_device *ndev)
 	if (phy_dev->link) {
 		if (fep->full_duplex != phy_dev->duplex) {
 			fec_restart(ndev, phy_dev->duplex);
+			netif_wake_queue(dev);
 			status_change = 1;
 		}
 	}
-- 
1.7.1
