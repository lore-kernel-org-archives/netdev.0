From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 7/7] sky2: optimize receive restart
Date: Wed, 12 Jul 2006 15:23:48 -0700
Message-ID: <20060712222646.851734546@localhost.localdomain>
References: <20060712222341.686007133@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18057 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751043AbWGLWb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 18:31:58 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-delay-put.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the driver handles multiple packets per NAPI poll, it is
better to reload the receive ring, then tell the hardware. Otherwise,
under packet storm with flow control, the driver/hardware will degrade
down to one packet getting through per pause-exchange.

Likewise on transmit, don't wakeup until a little more than minimum
ring space is available.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/sky2.c	2006-07-12 14:07:05.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-07-12 14:27:34.000000000 -0700
@@ -65,6 +65,7 @@
 #define RX_MAX_PENDING		(RX_LE_SIZE/2 - 2)
 #define RX_DEF_PENDING		RX_MAX_PENDING
 #define RX_SKB_ALIGN		8
+#define RX_BUF_WRITE		16
 
 #define TX_RING_SIZE		512
 #define TX_DEF_PENDING		(TX_RING_SIZE - 1)
@@ -1390,7 +1391,7 @@
 	}
 
 	sky2->tx_cons = put;
-	if (tx_avail(sky2) > MAX_SKB_TX_LE)
+	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
 		netif_wake_queue(dev);
 }
 
@@ -1889,9 +1890,6 @@
 	re->skb->ip_summed = CHECKSUM_NONE;
 	sky2_rx_add(sky2, re->mapaddr);
 
-	/* Tell receiver about new buffers. */
-	sky2_put_idx(sky2->hw, rxqaddr[sky2->port], sky2->rx_put);
-
 	return skb;
 
 oversize:
@@ -1938,7 +1936,9 @@
 /* Process status response ring */
 static int sky2_status_intr(struct sky2_hw *hw, int to_do)
 {
+	struct sky2_port *sky2;
 	int work_done = 0;
+	unsigned buf_write[2] = { 0, 0 };
 	u16 hwidx = sky2_read16(hw, STAT_PUT_IDX);
 
 	rmb();
@@ -1946,7 +1946,6 @@
 	while (hw->st_idx != hwidx) {
 		struct sky2_status_le *le  = hw->st_le + hw->st_idx;
 		struct net_device *dev;
-		struct sky2_port *sky2;
 		struct sk_buff *skb;
 		u32 status;
 		u16 length;
@@ -1979,6 +1978,14 @@
 #endif
 				netif_receive_skb(skb);
 
+			/* Update receiver after 16 frames */
+			if (++buf_write[le->link] == RX_BUF_WRITE) {
+				sky2_put_idx(hw, rxqaddr[le->link],
+					     sky2->rx_put);
+				buf_write[le->link] = 0;
+			}
+
+			/* Stop after net poll weight */
 			if (++work_done >= to_do)
 				goto exit_loop;
 			break;
@@ -2017,6 +2024,16 @@
 	}
 
 exit_loop:
+	if (buf_write[0]) {
+		sky2 = netdev_priv(hw->dev[0]);
+		sky2_put_idx(hw, Q_R1, sky2->rx_put);
+	}
+
+	if (buf_write[1]) {
+		sky2 = netdev_priv(hw->dev[1]);
+		sky2_put_idx(hw, Q_R2, sky2->rx_put);
+	}
+
 	return work_done;
 }
 

--

