From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 05/12] sky2: receive fill
Date: Mon, 09 Jul 2007 15:33:37 -0700
Message-ID: <20070709223453.290284388@linux-foundation.org>
References: <20070709223332.966231494@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41292 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755706AbXGIWhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 18:37:00 -0400
Content-Disposition: inline; filename=sky2-rx-update.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify receive buffer refill logic. Rather than trying to update
incrementally; do receive ring refill at end of receive processing.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-07-09 15:30:10.000000000 -0700
+++ b/drivers/net/sky2.c	2007-07-09 15:30:10.000000000 -0700
@@ -65,7 +65,6 @@
 #define RX_MAX_PENDING		(RX_LE_SIZE/6 - 2)
 #define RX_DEF_PENDING		RX_MAX_PENDING
 #define RX_SKB_ALIGN		8
-#define RX_BUF_WRITE		16
 
 #define TX_RING_SIZE		512
 #define TX_DEF_PENDING		(TX_RING_SIZE - 1)
@@ -1138,6 +1137,11 @@ nomem:
 	return NULL;
 }
 
+static inline void sky2_rx_update(struct sky2_port *sky2, unsigned rxq)
+{
+	sky2_put_idx(sky2->hw, rxq, sky2->rx_put);
+}
+
 /*
  * Allocate and setup receiver buffer pool.
  * Normal case this ends up creating one list element for skb
@@ -1229,7 +1233,7 @@ static int sky2_rx_start(struct sky2_por
 	}
 
 	/* Tell chip about available buffers */
-	sky2_put_idx(hw, rxq, sky2->rx_put);
+	sky2_rx_update(sky2, rxq);
 	return 0;
 nomem:
 	sky2_rx_clean(sky2);
@@ -2147,14 +2151,14 @@ static inline void sky2_tx_done(struct n
 /* Process status response ring */
 static int sky2_status_intr(struct sky2_hw *hw, int to_do)
 {
-	struct sky2_port *sky2;
 	int work_done = 0;
-	unsigned buf_write[2] = { 0, 0 };
+	unsigned rx[2] = { 0, 0 };
 	u16 hwidx = sky2_read16(hw, STAT_PUT_IDX);
 
 	rmb();
 
 	while (hw->st_idx != hwidx) {
+		struct sky2_port *sky2;
 		struct sky2_status_le *le  = hw->st_le + hw->st_idx;
 		unsigned port = le->css & CSS_LINK_BIT;
 		struct net_device *dev;
@@ -2171,10 +2175,11 @@ static int sky2_status_intr(struct sky2_
 
 		switch (le->opcode & ~HW_OWNER) {
 		case OP_RXSTAT:
+			++rx[port];
 			skb = sky2_receive(dev, length, status);
 			if (unlikely(!skb)) {
 				sky2->net_stats.rx_dropped++;
-				goto force_update;
+				break;
 			}
 
 			/* This chip reports checksum status differently */
@@ -2201,13 +2206,6 @@ static int sky2_status_intr(struct sky2_
 #endif
 				netif_receive_skb(skb);
 
-			/* Update receiver after 16 frames */
-			if (++buf_write[port] == RX_BUF_WRITE) {
-force_update:
-				sky2_put_idx(hw, rxqaddr[port], sky2->rx_put);
-				buf_write[port] = 0;
-			}
-
 			/* Stop after net poll weight */
 			if (++work_done >= to_do)
 				goto exit_loop;
@@ -2263,24 +2261,18 @@ force_update:
 			if (net_ratelimit())
 				printk(KERN_WARNING PFX
 				       "unknown status opcode 0x%x\n", le->opcode);
-			goto exit_loop;
 		}
 	}
 
 	/* Fully processed status ring so clear irq */
 	sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
-	mmiowb();
 
 exit_loop:
-	if (buf_write[0]) {
-		sky2 = netdev_priv(hw->dev[0]);
-		sky2_put_idx(hw, Q_R1, sky2->rx_put);
-	}
+	if (rx[0])
+		sky2_rx_update(netdev_priv(hw->dev[0]), Q_R1);
 
-	if (buf_write[1]) {
-		sky2 = netdev_priv(hw->dev[1]);
-		sky2_put_idx(hw, Q_R2, sky2->rx_put);
-	}
+	if (rx[1])
+		sky2_rx_update(netdev_priv(hw->dev[1]), Q_R2);
 
 	return work_done;
 }

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

