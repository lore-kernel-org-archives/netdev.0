From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 5/6] PS3: gelic: add support for port link status
Date: Thu, 13 Dec 2007 21:13:30 +0900
Message-ID: <20071213211121.BF89.MOKUNO@sm.sony.co.jp>
References: <20071213181146.BF69.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "Linux/PPC Development" <linuxppc-dev@ozlabs.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW2.Sony.CO.JP ([137.153.0.14]:38995 "EHLO mgw2.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751291AbXLMMOs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 07:14:48 -0500
In-Reply-To: <20071213181146.BF69.MOKUNO@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PS3: gelic: add support for port link status

Add support for interrupt driven port link status detection.

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
---
 drivers/net/ps3_gelic_net.c |   77 ++++++++++++++++++++++++++++----------------
 drivers/net/ps3_gelic_net.h |    2 +
 2 files changed, 52 insertions(+), 27 deletions(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -87,6 +87,28 @@ static inline void gelic_card_rx_irq_off
 {
 	gelic_card_set_irq_mask(card, card->ghiintmask & ~GELIC_CARD_RXINT);
 }
+
+static void
+gelic_card_get_ether_port_status(struct gelic_card *card, int inform)
+{
+	u64 v2;
+	struct net_device *ether_netdev;
+
+	lv1_net_control(bus_id(card), dev_id(card),
+			GELIC_LV1_GET_ETH_PORT_STATUS,
+			GELIC_LV1_VLAN_TX_ETHERNET, 0, 0,
+			&card->ether_port_status, &v2);
+
+	if (inform) {
+		ether_netdev = card->netdev;
+		if (card->ether_port_status & GELIC_LV1_ETHER_LINK_UP)
+			netif_carrier_on(ether_netdev);
+		else
+			netif_carrier_off(ether_netdev);
+	}
+}
+
+
 /**
  * gelic_descr_get_status -- returns the status of a descriptor
  * @descr: descriptor to look at
@@ -1032,6 +1054,10 @@ static irqreturn_t gelic_card_interrupt(
 		gelic_card_kick_txdma(card, card->tx_chain.tail);
 		spin_unlock_irqrestore(&card->tx_dma_lock, flags);
 	}
+
+	/* ether port status changed */
+	if (status & GELIC_CARD_PORT_STATUS_CHANGED)
+		gelic_card_get_ether_port_status(card, 1);
 	return IRQ_HANDLED;
 }
 
@@ -1128,13 +1154,14 @@ static int gelic_net_open(struct net_dev
 	napi_enable(&card->napi);
 
 	card->tx_dma_progress = 0;
-	card->ghiintmask = GELIC_CARD_RXINT | GELIC_CARD_TXINT;
+	card->ghiintmask = GELIC_CARD_RXINT | GELIC_CARD_TXINT |
+		GELIC_CARD_PORT_STATUS_CHANGED;
 
 	gelic_card_set_irq_mask(card, card->ghiintmask);
 	gelic_card_enable_rxdmac(card);
 
 	netif_start_queue(netdev);
-	netif_carrier_on(netdev);
+	gelic_card_get_ether_port_status(card, 1);
 
 	return 0;
 
@@ -1157,39 +1184,35 @@ static int gelic_ether_get_settings(stru
 				    struct ethtool_cmd *cmd)
 {
 	struct gelic_card *card = netdev_priv(netdev);
-	int status;
-	u64 v1, v2;
-	int speed, duplex;
 
-	speed = duplex = -1;
-	status = lv1_net_control(bus_id(card), dev_id(card),
-				 GELIC_LV1_GET_ETH_PORT_STATUS,
-				 GELIC_LV1_VLAN_TX_ETHERNET, 0, 0,
-				 &v1, &v2);
-	if (status) {
-		/* link down */
-	} else {
-		if (v1 & GELIC_LV1_ETHER_FULL_DUPLEX) {
-			duplex = DUPLEX_FULL;
-		} else {
-			duplex = DUPLEX_HALF;
-		}
+	gelic_card_get_ether_port_status(card, 0);
 
-		if (v1 & GELIC_LV1_ETHER_SPEED_10) {
-			speed = SPEED_10;
-		} else if (v1 & GELIC_LV1_ETHER_SPEED_100) {
-			speed = SPEED_100;
-		} else if (v1 & GELIC_LV1_ETHER_SPEED_1000) {
-			speed = SPEED_1000;
-		}
+	if (card->ether_port_status & GELIC_LV1_ETHER_FULL_DUPLEX)
+		cmd->duplex = DUPLEX_FULL;
+	else
+		cmd->duplex = DUPLEX_HALF;
+
+	switch (card->ether_port_status & GELIC_LV1_ETHER_SPEED_MASK) {
+	case GELIC_LV1_ETHER_SPEED_10:
+		cmd->speed = SPEED_10;
+		break;
+	case GELIC_LV1_ETHER_SPEED_100:
+		cmd->speed = SPEED_100;
+		break;
+	case GELIC_LV1_ETHER_SPEED_1000:
+		cmd->speed = SPEED_1000;
+		break;
+	default:
+		pr_info("%s: speed unknown\n", __func__);
+		cmd->speed = SPEED_10;
+		break;
 	}
+
 	cmd->supported = SUPPORTED_TP | SUPPORTED_Autoneg |
 			SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
 			SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
 			SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full;
 	cmd->advertising = cmd->supported;
-	cmd->speed = speed;
-	cmd->duplex = duplex;
 	cmd->autoneg = AUTONEG_ENABLE; /* always enabled */
 	cmd->port = PORT_TP;
 
--- a/drivers/net/ps3_gelic_net.h
+++ b/drivers/net/ps3_gelic_net.h
@@ -261,6 +261,8 @@ struct gelic_card {
 	atomic_t tx_timeout_task_counter;
 	wait_queue_head_t waitq;
 
+	u64 ether_port_status;
+
 	struct gelic_descr *tx_top, *rx_top;
 	struct gelic_descr descr[0];
 };

