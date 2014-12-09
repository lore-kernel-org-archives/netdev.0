From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [RFC PATCH net-next 07/11] pasemi: remove disable_irq from netpoll controller, use netpoll_irq_lock
Date: Tue,  9 Dec 2014 15:37:18 +0100
Message-ID: <1418135842-21389-8-git-send-email-sd@queasysnail.net>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>,
	Olof Johansson <olof@lixom.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:53480 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757058AbaLIOj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 09:39:27 -0500
In-Reply-To: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

disable_irq() may sleep, replace it with a spin_lock in the interrupt
handlers and netpoll controller.

No actual testing done, only compiled.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Cc: Olof Johansson <olof@lixom.net>
---
 drivers/net/ethernet/pasemi/pasemi_mac.c | 25 +++++++++++++++----------
 drivers/net/ethernet/pasemi/pasemi_mac.h |  3 +++
 2 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 30d934d66356..da937a1e3b9b 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -426,6 +426,7 @@ static int pasemi_mac_setup_rx_resources(const struct net_device *dev)
 	chno = ring->chan.chno;
 
 	spin_lock_init(&ring->lock);
+	netpoll_irq_lock_init(&ring->netpoll_lock);
 
 	ring->size = RX_RING_SIZE;
 	ring->ring_info = kzalloc(sizeof(struct pasemi_mac_buffer) *
@@ -509,6 +510,7 @@ pasemi_mac_setup_tx_resources(const struct net_device *dev)
 	chno = ring->chan.chno;
 
 	spin_lock_init(&ring->lock);
+	netpoll_irq_lock_init(&ring->netpoll_lock);
 
 	ring->size = TX_RING_SIZE;
 	ring->ring_info = kzalloc(sizeof(struct pasemi_mac_buffer) *
@@ -954,13 +956,16 @@ restart:
 
 static irqreturn_t pasemi_mac_rx_intr(int irq, void *data)
 {
-	const struct pasemi_mac_rxring *rxring = data;
+	struct pasemi_mac_rxring *rxring = data;
 	struct pasemi_mac *mac = rxring->mac;
 	const struct pasemi_dmachan *chan = &rxring->chan;
 	unsigned int reg;
 
-	if (!(*chan->status & PAS_STATUS_CAUSE_M))
+	netpoll_irq_lock(&rxring->netpoll_lock);
+	if (!(*chan->status & PAS_STATUS_CAUSE_M)) {
+		netpoll_irq_unlock(&rxring->netpoll_lock);
 		return IRQ_NONE;
+	}
 
 	/* Don't reset packet count so it won't fire again but clear
 	 * all others.
@@ -976,6 +981,7 @@ static irqreturn_t pasemi_mac_rx_intr(int irq, void *data)
 
 	write_iob_reg(PAS_IOB_DMA_RXCH_RESET(chan->chno), reg);
 
+	netpoll_irq_unlock(&rxring->netpoll_lock);
 	return IRQ_HANDLED;
 }
 
@@ -1000,8 +1006,11 @@ static irqreturn_t pasemi_mac_tx_intr(int irq, void *data)
 	struct pasemi_mac *mac = txring->mac;
 	unsigned int reg;
 
-	if (!(*chan->status & PAS_STATUS_CAUSE_M))
+	netpoll_irq_lock(&txring->netpoll_lock);
+	if (!(*chan->status & PAS_STATUS_CAUSE_M)) {
+		netpoll_irq_unlock(&txring->netpoll_lock);
 		return IRQ_NONE;
+	}
 
 	reg = 0;
 
@@ -1017,6 +1026,7 @@ static irqreturn_t pasemi_mac_tx_intr(int irq, void *data)
 	if (reg)
 		write_iob_reg(PAS_IOB_DMA_TXCH_RESET(chan->chno), reg);
 
+	netpoll_irq_unlock(&txring->netpoll_lock);
 	return IRQ_HANDLED;
 }
 
@@ -1628,20 +1638,15 @@ static int pasemi_mac_poll(struct napi_struct *napi, int budget)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /*
  * Polling 'interrupt' - used by things like netconsole to send skbs
- * without having to re-enable interrupts. It's not called while
- * the interrupt routine is executing.
+ * without having to re-enable interrupts. The interrupt routine
+ * protects itself with netpoll_irq_lock.
  */
 static void pasemi_mac_netpoll(struct net_device *dev)
 {
 	const struct pasemi_mac *mac = netdev_priv(dev);
 
-	disable_irq(mac->tx->chan.irq);
 	pasemi_mac_tx_intr(mac->tx->chan.irq, mac->tx);
-	enable_irq(mac->tx->chan.irq);
-
-	disable_irq(mac->rx->chan.irq);
 	pasemi_mac_rx_intr(mac->rx->chan.irq, mac->rx);
-	enable_irq(mac->rx->chan.irq);
 }
 #endif
 
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.h b/drivers/net/ethernet/pasemi/pasemi_mac.h
index a5807703ab96..78ff0c6947b4 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.h
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.h
@@ -22,6 +22,7 @@
 
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
+#include <linux/netpoll.h>
 #include <linux/spinlock.h>
 #include <linux/phy.h>
 
@@ -43,6 +44,7 @@ struct pasemi_mac_txring {
 	struct pasemi_mac_buffer *ring_info;
 	struct pasemi_mac *mac;	/* Needed in intr handler */
 	struct timer_list clean_timer;
+	struct netpoll_irq_lock netpoll_lock;
 };
 
 struct pasemi_mac_rxring {
@@ -55,6 +57,7 @@ struct pasemi_mac_rxring {
 	unsigned int	 next_to_clean;
 	struct pasemi_mac_buffer *ring_info;
 	struct pasemi_mac *mac;	/* Needed in intr handler */
+	struct netpoll_irq_lock netpoll_lock;
 };
 
 struct pasemi_mac_csring {
-- 
2.1.3
