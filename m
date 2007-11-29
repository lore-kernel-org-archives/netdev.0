From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [6/12] pasemi_mac: Fix TX cleaning
Date: Wed, 28 Nov 2007 20:56:54 -0600
Message-ID: <20071129025654.GG17215@lixom.net>
References: <20071129025410.GA17215@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:36868 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758755AbXK2Cxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 21:53:43 -0500
Content-Disposition: inline
In-Reply-To: <20071129025410.GA17215@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: Fix TX cleaning

This is a bit awkward. We don't have a timer-delayed interrupt on TX
complete, but we have a count threshold. So set that reasonably high
(32 packets), and schedule the NAPI poll when it goes off. Also bump a
regular timer that will take care of rotting packets for the last 1..31
ones in case we don't trigger a TX interrupt (and there's no RX activity
that would otherwise trigger the poll).

The longer-term fix is to separate TX from RX NAPI and do two separate
poll loops.

Signed-off-by: Olof Johansson <olof@lixom.net>

---
 drivers/net/pasemi_mac.c |   41 +++++++++++++++++++++++++++++++++--------
 drivers/net/pasemi_mac.h |    1 +
 2 files changed, 34 insertions(+), 8 deletions(-)

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -805,27 +805,43 @@ static irqreturn_t pasemi_mac_rx_intr(in
 	return IRQ_HANDLED;
 }
 
+#define TX_CLEAN_INTERVAL HZ
+
+static void pasemi_mac_tx_timer(unsigned long data)
+{
+	struct pasemi_mac_txring *txring = (struct pasemi_mac_txring *)data;
+	struct pasemi_mac *mac = txring->mac;
+
+	pasemi_mac_clean_tx(txring);
+
+	mod_timer(&txring->clean_timer, jiffies + TX_CLEAN_INTERVAL);
+
+	pasemi_mac_restart_tx_intr(mac);
+}
+
 static irqreturn_t pasemi_mac_tx_intr(int irq, void *data)
 {
 	struct pasemi_mac_txring *txring = data;
 	const struct pasemi_dmachan *chan = &txring->chan;
-	unsigned int reg, pcnt;
+	struct pasemi_mac *mac = txring->mac;
+	unsigned int reg;
 
 	if (!(*chan->status & PAS_STATUS_CAUSE_M))
 		return IRQ_NONE;
 
-	pasemi_mac_clean_tx(txring);
-
-	pcnt = *chan->status & PAS_STATUS_PCNT_M;
-
-	reg = PAS_IOB_DMA_TXCH_RESET_PCNT(pcnt) | PAS_IOB_DMA_TXCH_RESET_PINTC;
+	reg = 0;
 
 	if (*chan->status & PAS_STATUS_SOFT)
 		reg |= PAS_IOB_DMA_TXCH_RESET_SINTC;
 	if (*chan->status & PAS_STATUS_ERROR)
 		reg |= PAS_IOB_DMA_TXCH_RESET_DINTC;
 
-	write_iob_reg(PAS_IOB_DMA_TXCH_RESET(chan->chno), reg);
+	mod_timer(&txring->clean_timer, jiffies + (TX_CLEAN_INTERVAL)*2);
+
+	netif_rx_schedule(mac->netdev, &mac->napi);
+
+	if (reg)
+		write_iob_reg(PAS_IOB_DMA_TXCH_RESET(chan->chno), reg);
 
 	return IRQ_HANDLED;
 }
@@ -973,7 +989,7 @@ static int pasemi_mac_open(struct net_de
 		      PAS_IOB_DMA_RXCH_CFG_CNTTH(0));
 
 	write_iob_reg(PAS_IOB_DMA_TXCH_CFG(mac->tx->chan.chno),
-		      PAS_IOB_DMA_TXCH_CFG_CNTTH(128));
+		      PAS_IOB_DMA_TXCH_CFG_CNTTH(32));
 
 	write_mac_reg(mac, PAS_MAC_IPC_CHNL,
 		      PAS_MAC_IPC_CHNL_DCHNO(mac->rx->chan.chno) |
@@ -1054,6 +1070,12 @@ static int pasemi_mac_open(struct net_de
 	if (mac->phydev)
 		phy_start(mac->phydev);
 
+	init_timer(&mac->tx->clean_timer);
+	mac->tx->clean_timer.function = pasemi_mac_tx_timer;
+	mac->tx->clean_timer.data = (unsigned long)mac->tx;
+	mac->tx->clean_timer.expires = jiffies+HZ;
+	add_timer(&mac->tx->clean_timer);
+
 	return 0;
 
 out_rx_int:
@@ -1087,6 +1109,8 @@ static int pasemi_mac_close(struct net_d
 		phy_disconnect(mac->phydev);
 	}
 
+	del_timer_sync(&mac->tx->clean_timer);
+
 	netif_stop_queue(dev);
 	napi_disable(&mac->napi);
 
@@ -1304,6 +1328,7 @@ static int pasemi_mac_poll(struct napi_s
 		netif_rx_complete(dev, napi);
 
 		pasemi_mac_restart_rx_intr(mac);
+		pasemi_mac_restart_tx_intr(mac);
 	}
 	return pkts;
 }
Index: k.org/drivers/net/pasemi_mac.h
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.h
+++ k.org/drivers/net/pasemi_mac.h
@@ -34,6 +34,7 @@ struct pasemi_mac_txring {
 	unsigned int	 next_to_clean;
 	struct pasemi_mac_buffer *ring_info;
 	struct pasemi_mac *mac;	/* Needed in intr handler */
+	struct timer_list clean_timer;
 };
 
 struct pasemi_mac_rxring {
