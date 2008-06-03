From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 33/39] mv643xx_eth: work around TX hang hardware issue
Date: Tue,  3 Jun 2008 13:02:48 +0200
Message-ID: <1212490974-23719-34-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48758 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753833AbYFCMAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:31 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under some conditions, the TXQ ('TX queue being served') bit can clear
before all packets queued for that TX queue have been transmitted.
This patch enables TXend interrupts, and uses those to re-kick TX
queues that claim to be idle but still have queued descriptors from
the interrupt handler.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   35 ++++++++++++++++++++++++++++++-----
 1 files changed, 30 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index fd9e492..8e4ca2b 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -87,6 +87,7 @@ static char mv643xx_eth_driver_version[] = "1.0";
 #define TX_BW_MTU(p)			(0x0458 + ((p) << 10))
 #define TX_BW_BURST(p)			(0x045c + ((p) << 10))
 #define INT_CAUSE(p)			(0x0460 + ((p) << 10))
+#define  INT_TX_END			0x07f80000
 #define  INT_RX				0x0007fbfc
 #define  INT_EXT			0x00000002
 #define INT_CAUSE_EXT(p)		(0x0464 + ((p) << 10))
@@ -601,7 +602,7 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 		netif_rx_complete(mep->dev, napi);
 		wrl(mep, INT_CAUSE(mep->port_num), 0);
 		wrl(mep, INT_CAUSE_EXT(mep->port_num), 0);
-		wrl(mep, INT_MASK(mep->port_num), INT_RX | INT_EXT);
+		wrl(mep, INT_MASK(mep->port_num), INT_TX_END | INT_RX | INT_EXT);
 	}
 
 	return rx;
@@ -1603,8 +1604,10 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 	struct mv643xx_eth_private *mep = netdev_priv(dev);
 	u32 int_cause;
 	u32 int_cause_ext;
+	u32 txq_active;
 
-	int_cause = rdl(mep, INT_CAUSE(mep->port_num)) & (INT_RX | INT_EXT);
+	int_cause = rdl(mep, INT_CAUSE(mep->port_num)) &
+			(INT_TX_END | INT_RX | INT_EXT);
 	if (int_cause == 0)
 		return IRQ_NONE;
 
@@ -1656,6 +1659,8 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 	}
 #endif
 
+	txq_active = rdl(mep, TXQ_COMMAND(mep->port_num));
+
 	/*
 	 * TxBuffer or TxError set for any of the 8 queues?
 	 */
@@ -1665,8 +1670,28 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 		for (i = 0; i < 8; i++)
 			if (mep->txq_mask & (1 << i))
 				txq_reclaim(mep->txq + i, 0);
+	}
 
-		__txq_maybe_wake(mep->txq + mep->txq_primary);
+	/*
+	 * Any TxEnd interrupts?
+	 */
+	if (int_cause & INT_TX_END) {
+		int i;
+
+		wrl(mep, INT_CAUSE(mep->port_num), ~(int_cause & INT_TX_END));
+		for (i = 0; i < 8; i++) {
+			struct tx_queue *txq = mep->txq + i;
+			if (txq->tx_desc_count && !((txq_active >> i) & 1))
+				txq_enable(txq);
+		}
+	}
+
+	/*
+	 * Enough space again in the primary TX queue for a full packet?
+	 */
+	if (int_cause_ext & INT_EXT_TX) {
+		struct tx_queue *txq = mep->txq + mep->txq_primary;
+		__txq_maybe_wake(txq);
 	}
 
 	return IRQ_HANDLED;
@@ -1850,7 +1875,7 @@ static int mv643xx_eth_open(struct net_device *dev)
 	wrl(mep, INT_MASK_EXT(mep->port_num),
 	    INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
 
-	wrl(mep, INT_MASK(mep->port_num), INT_RX | INT_EXT);
+	wrl(mep, INT_MASK(mep->port_num), INT_TX_END | INT_RX | INT_EXT);
 
 	return 0;
 
@@ -1986,7 +2011,7 @@ static void mv643xx_eth_netpoll(struct net_device *dev)
 
 	mv643xx_eth_irq(dev->irq, dev);
 
-	wrl(mep, INT_MASK(mep->port_num), INT_RX | INT_CAUSE_EXT);
+	wrl(mep, INT_MASK(mep->port_num), INT_TX_END | INT_RX | INT_CAUSE_EXT);
 }
 #endif
 
-- 
1.5.3.4

