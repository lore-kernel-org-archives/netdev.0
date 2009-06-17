From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/9] sky2: receive counter update
Date: Wed, 17 Jun 2009 10:30:36 -0700
Message-ID: <20090617173139.956656294@vyatta.com>
References: <20090617173031.703636683@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45318 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756972AbZFQReD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 13:34:03 -0400
Content-Disposition: inline; filename=sky2-rxupdate.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since it is likely that there are multiple packets received per
interrupt, only update the receive counters once after all
packets are processed.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2009-06-17 10:29:55.361810536 -0700
+++ b/drivers/net/sky2.c	2009-06-17 10:29:56.510685400 -0700
@@ -2357,11 +2357,25 @@ static inline void sky2_tx_done(struct n
 	}
 }
 
+static inline void sky2_rx_done(struct sky2_hw *hw, unsigned port,
+				unsigned packets, unsigned bytes)
+{
+	if (packets) {
+		struct net_device *dev = hw->dev[port];
+
+		dev->stats.rx_packets += packets;
+		dev->stats.rx_bytes += bytes;
+		dev->last_rx = jiffies;
+		sky2_rx_update(netdev_priv(dev), rxqaddr[port]);
+	}
+}
+
 /* Process status response ring */
 static int sky2_status_intr(struct sky2_hw *hw, int to_do, u16 idx)
 {
 	int work_done = 0;
-	unsigned rx[2] = { 0, 0 };
+	unsigned int total_bytes[2] = { 0 };
+	unsigned int total_packets[2] = { 0 };
 
 	rmb();
 	do {
@@ -2388,7 +2402,8 @@ static int sky2_status_intr(struct sky2_
 		le->opcode = 0;
 		switch (opcode & ~HW_OWNER) {
 		case OP_RXSTAT:
-			++rx[port];
+			total_packets[port]++;
+			total_bytes[port] += length;
 			skb = sky2_receive(dev, length, status);
 			if (unlikely(!skb)) {
 				dev->stats.rx_dropped++;
@@ -2406,9 +2421,6 @@ static int sky2_status_intr(struct sky2_
 			}
 
 			skb->protocol = eth_type_trans(skb, dev);
-			dev->stats.rx_packets++;
-			dev->stats.rx_bytes += skb->len;
-			dev->last_rx = jiffies;
 
 #ifdef SKY2_VLAN_TAG_USED
 			if (sky2->vlgrp && (status & GMR_FS_VLAN)) {
@@ -2487,11 +2499,8 @@ static int sky2_status_intr(struct sky2_
 	sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
 
 exit_loop:
-	if (rx[0])
-		sky2_rx_update(netdev_priv(hw->dev[0]), Q_R1);
-
-	if (rx[1])
-		sky2_rx_update(netdev_priv(hw->dev[1]), Q_R2);
+	sky2_rx_done(hw, 0, total_packets[0], total_bytes[0]);
+	sky2_rx_done(hw, 1, total_packets[1], total_bytes[1]);
 
 	return work_done;
 }

-- 

