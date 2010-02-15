From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/7] drivers/net/sky2: Convert to use netif_printk macros
Date: Mon, 15 Feb 2010 10:34:21 -0800
Message-ID: <da1b6188355eb489797927a64db283cdb03ef654.1266258417.git.joe@perches.com>
References: <cover.1266258417.git.joe@perches.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1072 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756066Ab0BOSea (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2010 13:34:30 -0500
In-Reply-To: <cover.1266258417.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some unlikely(netif_msg_<foo>(sky2)) tests are also
removed by this change.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/sky2.c |   65 +++++++++++++++++++++------------------------------
 1 files changed, 27 insertions(+), 38 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index dfff8e5..a1198f1 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1613,8 +1613,7 @@ static int sky2_up(struct net_device *dev)
 	sky2_write32(hw, B0_IMSK, imask);
 	sky2_read32(hw, B0_IMSK);
 
-	if (netif_msg_ifup(sky2))
-		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
+	netif_info(sky2, ifup, dev, "enabling interface\n");
 
 	return 0;
 
@@ -1697,9 +1696,8 @@ static netdev_tx_t sky2_xmit_frame(struct sk_buff *skb,
 		goto mapping_error;
 
 	slot = sky2->tx_prod;
-	if (unlikely(netif_msg_tx_queued(sky2)))
-		printk(KERN_DEBUG "%s: tx queued, slot %u, len %d\n",
-		       dev->name, slot, skb->len);
+	netif_printk(sky2, tx_queued, KERN_DEBUG, dev,
+		     "tx queued, slot %u, len %d\n", slot, skb->len);
 
 	/* Send high bits if needed */
 	upper = upper_32_bits(mapping);
@@ -1864,9 +1862,8 @@ static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
 		sky2_tx_unmap(sky2->hw->pdev, re);
 
 		if (skb) {
-			if (unlikely(netif_msg_tx_done(sky2)))
-				printk(KERN_DEBUG "%s: tx done %u\n",
-				       dev->name, idx);
+			netif_printk(sky2, tx_done, KERN_DEBUG, dev,
+				     "tx done %u\n", idx);
 
 			dev->stats.tx_packets++;
 			dev->stats.tx_bytes += skb->len;
@@ -1961,8 +1958,7 @@ static int sky2_down(struct net_device *dev)
 	if (!sky2->tx_le)
 		return 0;
 
-	if (netif_msg_ifdown(sky2))
-		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
+	netif_info(sky2, ifdown, dev, "disabling interface\n");
 
 	/* Disable port IRQ */
 	sky2_write32(hw, B0_IMSK,
@@ -2028,12 +2024,11 @@ static void sky2_link_up(struct sky2_port *sky2)
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG),
 		    LINKLED_ON | LINKLED_BLINK_OFF | LINKLED_LINKSYNC_OFF);
 
-	if (netif_msg_link(sky2))
-		printk(KERN_INFO PFX
-		       "%s: Link is up at %d Mbps, %s duplex, flow control %s\n",
-		       sky2->netdev->name, sky2->speed,
-		       sky2->duplex == DUPLEX_FULL ? "full" : "half",
-		       fc_name[sky2->flow_status]);
+	netif_info(sky2, link, sky2->netdev,
+		   "Link is up at %d Mbps, %s duplex, flow control %s\n",
+		   sky2->speed,
+		   sky2->duplex == DUPLEX_FULL ? "full" : "half",
+		   fc_name[sky2->flow_status]);
 }
 
 static void sky2_link_down(struct sky2_port *sky2)
@@ -2053,8 +2048,7 @@ static void sky2_link_down(struct sky2_port *sky2)
 	/* Turn off link LED */
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG), LINKLED_OFF);
 
-	if (netif_msg_link(sky2))
-		printk(KERN_INFO PFX "%s: Link is down.\n", sky2->netdev->name);
+	netif_info(sky2, link, sky2->netdev, "Link is down\n");
 
 	sky2_phy_init(hw, port);
 }
@@ -2144,9 +2138,8 @@ static void sky2_phy_intr(struct sky2_hw *hw, unsigned port)
 	istatus = gm_phy_read(hw, port, PHY_MARV_INT_STAT);
 	phystat = gm_phy_read(hw, port, PHY_MARV_PHY_STAT);
 
-	if (netif_msg_intr(sky2))
-		printk(KERN_INFO PFX "%s: phy interrupt status 0x%x 0x%x\n",
-		       sky2->netdev->name, istatus, phystat);
+	netif_info(sky2, intr, sky2->netdev, "phy interrupt status 0x%x 0x%x\n",
+		   istatus, phystat);
 
 	if (istatus & PHY_M_IS_AN_COMPL) {
 		if (sky2_autoneg_done(sky2, phystat) == 0)
@@ -2200,8 +2193,7 @@ static void sky2_tx_timeout(struct net_device *dev)
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 
-	if (netif_msg_timer(sky2))
-		printk(KERN_ERR PFX "%s: tx timeout\n", dev->name);
+	netif_err(sky2, timer, dev, "tx timeout\n");
 
 	printk(KERN_DEBUG PFX "%s: transmit ring %u .. %u report=%u done=%u\n",
 	       dev->name, sky2->tx_cons, sky2->tx_prod,
@@ -2396,9 +2388,9 @@ static struct sk_buff *sky2_receive(struct net_device *dev,
 		count -= VLAN_HLEN;
 #endif
 
-	if (unlikely(netif_msg_rx_status(sky2)))
-		printk(KERN_DEBUG PFX "%s: rx slot %u status 0x%x len %d\n",
-		       dev->name, sky2->rx_next, status, length);
+	netif_printk(sky2, rx_status, KERN_DEBUG, dev,
+		     "rx slot %u status 0x%x len %d\n",
+		     sky2->rx_next, status, length);
 
 	sky2->rx_next = (sky2->rx_next + 1) % sky2->rx_pending;
 	prefetch(sky2->rx_ring + sky2->rx_next);
@@ -2439,9 +2431,10 @@ len_error:
 	/* Truncation of overlength packets
 	   causes PHY length to not match MAC length */
 	++dev->stats.rx_length_errors;
-	if (netif_msg_rx_err(sky2) && net_ratelimit())
-		pr_info(PFX "%s: rx length error: status %#x length %d\n",
-			dev->name, status, length);
+	if (net_ratelimit())
+		netif_info(sky2, rx_err, dev,
+			   "rx length error: status %#x length %d\n",
+			   status, length);
 	goto resubmit;
 
 error:
@@ -2451,9 +2444,9 @@ error:
 		goto resubmit;
 	}
 
-	if (netif_msg_rx_err(sky2) && net_ratelimit())
-		printk(KERN_INFO PFX "%s: rx error, status 0x%x length %d\n",
-		       dev->name, status, length);
+	if (net_ratelimit())
+		netif_info(sky2, rx_err, dev,
+			   "rx error, status 0x%x length %d\n", status, length);
 
 	if (status & (GMR_FS_LONG_ERR | GMR_FS_UN_SIZE))
 		dev->stats.rx_length_errors++;
@@ -2733,9 +2726,7 @@ static void sky2_mac_intr(struct sky2_hw *hw, unsigned port)
 	struct sky2_port *sky2 = netdev_priv(dev);
 	u8 status = sky2_read8(hw, SK_REG(port, GMAC_IRQ_SRC));
 
-	if (netif_msg_intr(sky2))
-		printk(KERN_INFO PFX "%s: mac interrupt status 0x%x\n",
-		       dev->name, status);
+	netif_info(sky2, intr, dev, "mac interrupt status 0x%x\n", status);
 
 	if (status & GM_IS_RX_CO_OV)
 		gma_read16(hw, port, GM_RX_IRQ_SRC);
@@ -4529,9 +4520,7 @@ static void __devinit sky2_show_addr(struct net_device *dev)
 {
 	const struct sky2_port *sky2 = netdev_priv(dev);
 
-	if (netif_msg_probe(sky2))
-		printk(KERN_INFO PFX "%s: addr %pM\n",
-		       dev->name, dev->dev_addr);
+	netif_info(sky2, probe, dev, "addr %pM\n", dev->dev_addr);
 }
 
 /* Handle software interrupt used during MSI test */
-- 
1.7.0.14.g7e948

