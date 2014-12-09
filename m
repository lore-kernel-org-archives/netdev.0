From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [RFC PATCH net-next 11/11] net: fec: remove disable_irq from netpoll controller, use netpoll_irq_lock
Date: Tue,  9 Dec 2014 15:37:22 +0100
Message-ID: <1418135842-21389-12-git-send-email-sd@queasysnail.net>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:54274 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757255AbaLIOjp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 09:39:45 -0500
In-Reply-To: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

disable_irq() may sleep, replace it with a spin_lock in the interrupt
handler and netpoll controller.

No actual testing done, only compiled.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/ethernet/freescale/fec.h      |  2 ++
 drivers/net/ethernet/freescale/fec_main.c | 14 ++++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 469691ad4a1e..fe8931465a53 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -16,6 +16,7 @@
 #include <linux/clocksource.h>
 #include <linux/net_tstamp.h>
 #include <linux/ptp_clock_kernel.h>
+#include <linux/netpoll.h>
 
 #if defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x) || \
     defined(CONFIG_M520x) || defined(CONFIG_M532x) || \
@@ -509,6 +510,7 @@ struct fec_enet_private {
 	int	speed;
 	struct	completion mdio_done;
 	int	irq[FEC_IRQ_NUM];
+	struct netpoll_irq_lock netpoll_locks[FEC_IRQ_NUM];
 	bool	bufdesc_ex;
 	int	pause_flag;
 	u32	quirks;
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index d2955ce24d0b..b7579c5acedb 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1558,6 +1558,18 @@ fec_enet_interrupt(int irq, void *dev_id)
 	const unsigned napi_mask = FEC_ENET_RXF | FEC_ENET_TXF;
 	uint int_events;
 	irqreturn_t ret = IRQ_NONE;
+	int i;
+	struct netpoll_irq_lock *netpoll_lock = NULL;
+
+	for (i = 0; i < FEC_IRQ_NUM; i++) {
+		if (fep->irq[i] == irq) {
+			netpoll_lock = &fep->netpoll_locks[i];
+			netpoll_irq_lock(netpoll_lock);
+			break;
+		}
+	}
+	if (!netpoll_lock)
+		return ret;
 
 	int_events = readl(fep->hwp + FEC_IEVENT);
 	writel(int_events & ~napi_mask, fep->hwp + FEC_IEVENT);
@@ -1579,6 +1591,7 @@ fec_enet_interrupt(int irq, void *dev_id)
 	if (fep->ptp_clock)
 		fec_ptp_check_pps_event(fep);
 
+	netpoll_irq_unlock(netpoll_lock);
 	return ret;
 }
 
@@ -3237,6 +3250,7 @@ fec_probe(struct platform_device *pdev)
 
 	for (i = 0; i < FEC_IRQ_NUM; i++) {
 		irq = platform_get_irq(pdev, i);
+		netpoll_irq_lock_init(&fep->netpoll_locks[i]);
 		if (irq < 0) {
 			if (i)
 				break;
-- 
2.1.3
