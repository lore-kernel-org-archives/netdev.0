From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] sky2: add GRO support
Date: Wed, 1 Apr 2009 14:39:46 -0700
Message-ID: <20090401143946.64449a05@nehalam>
References: <20090401142020.395f51bb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41614 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934643AbZDAVkH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2009 17:40:07 -0400
In-Reply-To: <20090401142020.395f51bb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for generic receive offload. Also cleanup counters so
that only updated once per interrupt.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
----
Note: this is experimental at this point (so please hold for 2.6.31)


--- a/drivers/net/sky2.c	2009-04-01 11:51:55.822315655 -0700
+++ b/drivers/net/sky2.c	2009-04-01 13:13:40.275066435 -0700
@@ -2344,11 +2344,46 @@ static inline void sky2_tx_done(struct n
 	}
 }
 
+static inline void sky2_skb_rx(const struct sky2_port *sky2,
+			       u32 status, struct sk_buff *skb)
+{
+#ifdef SKY2_VLAN_TAG_USED
+	u16 vlan_tag = be16_to_cpu(sky2->rx_tag);
+	if (sky2->vlgrp && (status & GMR_FS_VLAN)) {
+		if (skb->ip_summed == CHECKSUM_NONE)
+			vlan_hwaccel_receive_skb(skb, sky2->vlgrp, vlan_tag);
+		else
+			vlan_gro_receive(&sky2->hw->napi, sky2->vlgrp,
+					 vlan_tag, skb);
+		return;
+	}
+#endif
+	if (skb->ip_summed == CHECKSUM_NONE)
+		netif_receive_skb(skb);
+	else
+		napi_gro_receive(&sky2->hw->napi, skb);
+}
+
+static void sky2_rx_done(struct sky2_hw *hw, unsigned port,
+			       unsigned packets, unsigned bytes)
+{
+	struct net_device *dev = hw->dev[port];
+
+	if (dev) {
+		dev->stats.rx_packets += packets;
+		dev->stats.rx_bytes += bytes;
+		dev->last_rx = jiffies;
+		sky2_rx_update(netdev_priv(dev), rxqaddr[port]);
+	}
+}
+
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
@@ -2375,7 +2410,8 @@ static int sky2_status_intr(struct sky2_
 		le->opcode = 0;
 		switch (opcode & ~HW_OWNER) {
 		case OP_RXSTAT:
-			++rx[port];
+			total_packets[port]++;
+			total_bytes[port] += length;
 			skb = sky2_receive(dev, length, status);
 			if (unlikely(!skb)) {
 				dev->stats.rx_dropped++;
@@ -2393,18 +2429,8 @@ static int sky2_status_intr(struct sky2_
 			}
 
 			skb->protocol = eth_type_trans(skb, dev);
-			dev->stats.rx_packets++;
-			dev->stats.rx_bytes += skb->len;
-			dev->last_rx = jiffies;
 
-#ifdef SKY2_VLAN_TAG_USED
-			if (sky2->vlgrp && (status & GMR_FS_VLAN)) {
-				vlan_hwaccel_receive_skb(skb,
-							 sky2->vlgrp,
-							 be16_to_cpu(sky2->rx_tag));
-			} else
-#endif
-				netif_receive_skb(skb);
+			sky2_skb_rx(sky2, status, skb);
 
 			/* Stop after net poll weight */
 			if (++work_done >= to_do)
@@ -2474,11 +2500,9 @@ static int sky2_status_intr(struct sky2_
 	sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
 
 exit_loop:
-	if (rx[0])
-		sky2_rx_update(netdev_priv(hw->dev[0]), Q_R1);
 
-	if (rx[1])
-		sky2_rx_update(netdev_priv(hw->dev[1]), Q_R2);
+	sky2_rx_done(hw, 0, total_packets[0], total_bytes[0]);
+	sky2_rx_done(hw, 1, total_packets[1], total_bytes[1]);
 
 	return work_done;
 }
@@ -4245,6 +4269,7 @@ static __devinit struct net_device *sky2
 	sky2->port = port;
 
 	dev->features |= NETIF_F_TSO | NETIF_F_IP_CSUM | NETIF_F_SG;
+	dev->features |= NETIF_F_GRO;
 	if (highmem)
 		dev->features |= NETIF_F_HIGHDMA;
 
