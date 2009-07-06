From: Mike Rapoport <mike@compulab.co.il>
Subject: [PATCH v3] dm9000: add checksum offload support
Date: Mon, 06 Jul 2009 09:52:15 +0300
Message-ID: <4A519F1F.90706@compulab.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Dooks <ben-linux-arm@fluff.org>,
	Yeasah Pell <yeasah@comrex.com>, romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from legaljet.webserversystems.com ([67.18.134.218]:54988 "EHLO
	compulab.site5.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654AbZGFGwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 02:52:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Yeasah Pell <yeasah@comrex.com>

Add checksum offload support for DM9000A and DM9000B chips.

--
v2 changes: added a local copy of ip_summed to save IO cycles in dm9000_send_packet
v3 changes: trans_start updating is removed.

Signed-off-by: Yeasah Pell <yeasah@comrex.com>
Signed-off-by: Mike Rapoport <mike@compulab.co.il>
---
 drivers/net/dm9000.c |  107 ++++++++++++++++++++++++++++++++++++++++++--------
 drivers/net/dm9000.h |   18 ++++++++
 2 files changed, 108 insertions(+), 17 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index dd771de..50333da 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -92,6 +92,7 @@ typedef struct board_info {
 	u16		tx_pkt_cnt;
 	u16		queue_pkt_len;
 	u16		queue_start_addr;
+	u16		queue_ip_summed;
 	u16		dbug_cnt;
 	u8		io_mode;		/* 0:word, 2:byte */
 	u8		phy_addr;
@@ -124,6 +125,10 @@ typedef struct board_info {

 	struct mii_if_info mii;
 	u32		msg_enable;
+
+	int		rx_csum;
+	int		can_csum;
+	int		ip_summed;
 } board_info_t;

 /* debug code */
@@ -460,6 +465,40 @@ static int dm9000_nway_reset(struct net_device *dev)
 	return mii_nway_restart(&dm->mii);
 }

+static uint32_t dm9000_get_rx_csum(struct net_device *dev)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+	return dm->rx_csum;
+}
+
+static int dm9000_set_rx_csum(struct net_device *dev, uint32_t data)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+	unsigned long flags;
+
+	if (dm->can_csum) {
+		dm->rx_csum = data;
+
+		spin_lock_irqsave(&dm->lock, flags);
+		iow(dm, DM9000_RCSR, dm->rx_csum ? RCSR_CSUM : 0);
+		spin_unlock_irqrestore(&dm->lock, flags);
+
+		return 0;
+	}
+
+	return -EOPNOTSUPP;
+}
+
+static int dm9000_set_tx_csum(struct net_device *dev, uint32_t data)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+	int ret = -EOPNOTSUPP;
+
+	if (dm->can_csum)
+		ret = ethtool_op_set_tx_csum(dev, data);
+	return ret;
+}
+
 static u32 dm9000_get_link(struct net_device *dev)
 {
 	board_info_t *dm = to_dm9000_board(dev);
@@ -540,6 +579,10 @@ static const struct ethtool_ops dm9000_ethtool_ops = {
  	.get_eeprom_len		= dm9000_get_eeprom_len,
  	.get_eeprom		= dm9000_get_eeprom,
  	.set_eeprom		= dm9000_set_eeprom,
+	.get_rx_csum		= dm9000_get_rx_csum,
+	.set_rx_csum		= dm9000_set_rx_csum,
+	.get_tx_csum		= ethtool_op_get_tx_csum,
+	.set_tx_csum		= dm9000_set_tx_csum,
 };

 static void dm9000_show_carrier(board_info_t *db,
@@ -685,6 +728,9 @@ dm9000_init_dm9000(struct net_device *dev)
 	/* I/O mode */
 	db->io_mode = ior(db, DM9000_ISR) >> 6;	/* ISR bit7:6 keeps I/O mode */

+	/* Checksum mode */
+	dm9000_set_rx_csum(dev, db->rx_csum);
+
 	/* GPIO0 on pre-activate PHY */
 	iow(db, DM9000_GPR, 0);	/* REG_1F bit0 activate phyxcer */
 	iow(db, DM9000_GPCR, GPCR_GEP_CNTL);	/* Let GPIO0 output */
@@ -743,6 +789,29 @@ static void dm9000_timeout(struct net_device *dev)
 	spin_unlock_irqrestore(&db->lock, flags);
 }

+static void dm9000_send_packet(struct net_device *dev,
+			       int ip_summed,
+			       u16 pkt_len)
+{
+	board_info_t *dm = to_dm9000_board(dev);
+
+	/* The DM9000 is not smart enough to leave fragmented packets alone. */
+	if (dm->ip_summed != ip_summed) {
+		if (ip_summed == CHECKSUM_NONE)
+			iow(dm, DM9000_TCCR, 0);
+		else
+			iow(dm, DM9000_TCCR, TCCR_IP | TCCR_UDP | TCCR_TCP);
+		dm->ip_summed = ip_summed;
+	}
+
+	/* Set TX length to DM9000 */
+	iow(dm, DM9000_TXPLL, pkt_len);
+	iow(dm, DM9000_TXPLH, pkt_len >> 8);
+
+	/* Issue TX polling command */
+	iow(dm, DM9000_TCR, TCR_TXREQ);	/* Cleared after TX complete */
+}
+
 /*
  *  Hardware start transmission.
  *  Send a packet to media from the upper layer.
@@ -769,17 +838,11 @@ dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	db->tx_pkt_cnt++;
 	/* TX control: First packet immediately send, second packet queue */
 	if (db->tx_pkt_cnt == 1) {
-		/* Set TX length to DM9000 */
-		iow(db, DM9000_TXPLL, skb->len);
-		iow(db, DM9000_TXPLH, skb->len >> 8);
-
-		/* Issue TX polling command */
-		iow(db, DM9000_TCR, TCR_TXREQ);	/* Cleared after TX complete */
-
-		dev->trans_start = jiffies;	/* save the time stamp */
+		dm9000_send_packet(dev, skb->ip_summed, skb->len);
 	} else {
 		/* Second packet */
 		db->queue_pkt_len = skb->len;
+		db->queue_ip_summed = skb->ip_summed;
 		netif_stop_queue(dev);
 	}

@@ -809,12 +872,9 @@ static void dm9000_tx_done(struct net_device *dev, board_info_t *db)
 			dev_dbg(db->dev, "tx done, NSR %02x\n", tx_status);

 		/* Queue packet check & send */
-		if (db->tx_pkt_cnt > 0) {
-			iow(db, DM9000_TXPLL, db->queue_pkt_len);
-			iow(db, DM9000_TXPLH, db->queue_pkt_len >> 8);
-			iow(db, DM9000_TCR, TCR_TXREQ);
-			dev->trans_start = jiffies;
-		}
+		if (db->tx_pkt_cnt > 0)
+			dm9000_send_packet(dev, db->queue_ip_summed,
+					   db->queue_pkt_len);
 		netif_wake_queue(dev);
 	}
 }
@@ -846,14 +906,14 @@ dm9000_rx(struct net_device *dev)
 		rxbyte = readb(db->io_data);

 		/* Status check: this byte must be 0 or 1 */
-		if (rxbyte > DM9000_PKT_RDY) {
+		if (rxbyte & DM9000_PKT_ERR) {
 			dev_warn(db->dev, "status check fail: %d\n", rxbyte);
 			iow(db, DM9000_RCR, 0x00);	/* Stop Device */
 			iow(db, DM9000_ISR, IMR_PAR);	/* Stop INT request */
 			return;
 		}

-		if (rxbyte != DM9000_PKT_RDY)
+		if (!(rxbyte & DM9000_PKT_RDY))
 			return;

 		/* A packet ready now  & Get status/length */
@@ -914,6 +974,12 @@ dm9000_rx(struct net_device *dev)

 			/* Pass to upper layer */
 			skb->protocol = eth_type_trans(skb, dev);
+			if (db->rx_csum) {
+				if ((((rxbyte & 0x1c) << 3) & rxbyte) == 0)
+					skb->ip_summed = CHECKSUM_UNNECESSARY;
+				else
+					skb->ip_summed = CHECKSUM_NONE;
+			}
 			netif_rx(skb);
 			dev->stats.rx_packets++;

@@ -922,7 +988,7 @@ dm9000_rx(struct net_device *dev)

 			(db->dumpblk)(db->io_data, RxLen);
 		}
-	} while (rxbyte == DM9000_PKT_RDY);
+	} while (rxbyte & DM9000_PKT_RDY);
 }

 static irqreturn_t dm9000_interrupt(int irq, void *dev_id)
@@ -1349,6 +1415,13 @@ dm9000_probe(struct platform_device *pdev)
 		db->type = TYPE_DM9000E;
 	}

+	/* dm9000a/b are capable of hardware checksum offload */
+	if (db->type == TYPE_DM9000A || db->type == TYPE_DM9000B) {
+		db->can_csum = 1;
+		db->rx_csum = 1;
+		ndev->features |= NETIF_F_IP_CSUM;
+	}
+
 	/* from this point we assume that we have found a DM9000 */

 	/* driver system function */
diff --git a/drivers/net/dm9000.h b/drivers/net/dm9000.h
index ba25cf5..80817c2 100644
--- a/drivers/net/dm9000.h
+++ b/drivers/net/dm9000.h
@@ -45,6 +45,10 @@
 #define DM9000_CHIPR           0x2C
 #define DM9000_SMCR            0x2F

+#define DM9000_ETXCSR          0x30
+#define DM9000_TCCR	       0x31
+#define DM9000_RCSR	       0x32
+
 #define CHIPR_DM9000A	       0x19
 #define CHIPR_DM9000B	       0x1B

@@ -131,7 +135,21 @@

 #define GPCR_GEP_CNTL       (1<<0)

+#define TCCR_IP		    (1<<0)
+#define TCCR_TCP	    (1<<1)
+#define TCCR_UDP	    (1<<2)
+
+#define RCSR_UDP_BAD	    (1<<7)
+#define RCSR_TCP_BAD	    (1<<6)
+#define RCSR_IP_BAD	    (1<<5)
+#define RCSR_UDP	    (1<<4)
+#define RCSR_TCP	    (1<<3)
+#define RCSR_IP		    (1<<2)
+#define RCSR_CSUM	    (1<<1)
+#define RCSR_DISCARD	    (1<<0)
+
 #define DM9000_PKT_RDY		0x01	/* Packet ready to receive */
+#define DM9000_PKT_ERR		0x02
 #define DM9000_PKT_MAX		1536	/* Received packet max size */

 /* DM9000A / DM9000B definitions */
-- 
1.6.0.6



-- 
Sincerely yours,
Mike.

