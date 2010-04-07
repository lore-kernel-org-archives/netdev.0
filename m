From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 4/7] au1000-eth: fix checkpatch errors.
Date: Wed, 7 Apr 2010 10:09:06 +0200
Message-ID: <201004071009.06717.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:51097 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932219Ab0DGIKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 04:10:14 -0400
Received: by ey-out-2122.google.com with SMTP id d26so91625eyd.19
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 01:10:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes multiple errors reported by checkpatch:
- else not on the ending brace of an if { }
- multiple occurences of for( instead of for (
- c99 comments
- assignment and tests on the same line
- test and statements on the same line
- macro with complex value not between parenthesis
- static variable with initialization value

No functionnal change.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 7d40177..49f56b4 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -298,9 +298,9 @@ au1000_adjust_link(struct net_device *dev)
 	spin_lock_irqsave(&aup->lock, flags);
 
 	if (phydev->link && (aup->old_speed != phydev->speed)) {
-		// speed changed
+		/* speed changed */
 
-		switch(phydev->speed) {
+		switch (phydev->speed) {
 		case SPEED_10:
 		case SPEED_100:
 			break;
@@ -317,7 +317,7 @@ au1000_adjust_link(struct net_device *dev)
 	}
 
 	if (phydev->link && (aup->old_duplex != phydev->duplex)) {
-		// duplex mode changed
+		/* duplex mode changed */
 
 		/* switching duplex mode requires to disable rx and tx! */
 		au1000_hard_stop(dev);
@@ -338,8 +338,8 @@ au1000_adjust_link(struct net_device *dev)
 		status_change = 1;
 	}
 
-	if(phydev->link != aup->old_link) {
-		// link state changed
+	if (phydev->link != aup->old_link) {
+		/* link state changed */
 
 		if (!phydev->link) {
 			/* link went down */
@@ -668,8 +668,7 @@ static inline void au1000_update_rx_stats(struct net_device *dev, u32 status)
 			ps->rx_crc_errors++;
 		if (status & RX_COLL)
 			ps->collisions++;
-	}
-	else
+	} else
 		ps->rx_bytes += status & RX_FRAME_LEN_MASK;
 
 }
@@ -714,8 +713,7 @@ static int au1000_rx(struct net_device *dev)
 			skb_put(skb, frmlen);
 			skb->protocol = eth_type_trans(skb, dev);
 			netif_rx(skb);	/* pass the packet to upper layers */
-		}
-		else {
+		} else {
 			if (au1000_debug > 4) {
 				if (status & RX_MISSED_FRAME)
 					printk("rx miss\n");
@@ -761,8 +759,7 @@ static void au1000_update_tx_stats(struct net_device *dev, u32 status)
 				ps->tx_errors++;
 				ps->tx_aborted_errors++;
 			}
-		}
-		else {
+		} else {
 			ps->tx_errors++;
 			ps->tx_aborted_errors++;
 			if (status & (TX_NO_CARRIER | TX_LOSS_CARRIER))
@@ -821,14 +818,16 @@ static int au1000_open(struct net_device *dev)
 	if (au1000_debug > 4)
 		printk("%s: open: dev=%p\n", dev->name, dev);
 
-	if ((retval = request_irq(dev->irq, au1000_interrupt, 0,
-					dev->name, dev))) {
+	retval = request_irq(dev->irq, au1000_interrupt, 0,
+					dev->name, dev);
+	if (retval) {
 		printk(KERN_ERR "%s: unable to get IRQ %d\n",
 				dev->name, dev->irq);
 		return retval;
 	}
 
-	if ((retval = au1000_init(dev))) {
+	retval = au1000_init(dev);
+	if (retval) {
 		printk(KERN_ERR "%s: error in au1000_init\n", dev->name);
 		free_irq(dev->irq, dev);
 		return retval;
@@ -897,8 +896,7 @@ static netdev_tx_t au1000_tx(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_queue(dev);
 		aup->tx_full = 1;
 		return NETDEV_TX_BUSY;
-	}
-	else if (buff_stat & TX_T_DONE) {
+	} else if (buff_stat & TX_T_DONE) {
 		au1000_update_tx_stats(dev, ptxd->status);
 		ptxd->len = 0;
 	}
@@ -911,12 +909,11 @@ static netdev_tx_t au1000_tx(struct sk_buff *skb, struct net_device *dev)
 	pDB = aup->tx_db_inuse[aup->tx_head];
 	skb_copy_from_linear_data(skb, (void *)pDB->vaddr, skb->len);
 	if (skb->len < ETH_ZLEN) {
-		for (i=skb->len; i<ETH_ZLEN; i++) {
+		for (i = skb->len; i < ETH_ZLEN; i++) {
 			((char *)pDB->vaddr)[i] = 0;
 		}
 		ptxd->len = ETH_ZLEN;
-	}
-	else
+	} else
 		ptxd->len = skb->len;
 
 	ps->tx_packets++;
@@ -976,9 +973,11 @@ static int au1000_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct au1000_private *aup = netdev_priv(dev);
 
-	if (!netif_running(dev)) return -EINVAL;
+	if (!netif_running(dev))
+		return -EINVAL;
 
-	if (!aup->phy_dev) return -EINVAL; // PHY not controllable
+	if (!aup->phy_dev)
+		return -EINVAL; /* PHY not controllable */
 
 	return phy_mii_ioctl(aup->phy_dev, if_mii(rq), cmd);
 }
@@ -997,7 +996,7 @@ static const struct net_device_ops au1000_netdev_ops = {
 
 static int __devinit au1000_probe(struct platform_device *pdev)
 {
-	static unsigned version_printed = 0;
+	static unsigned version_printed;
 	struct au1000_private *aup = NULL;
 	struct au1000_eth_platform_data *pd;
 	struct net_device *dev = NULL;
@@ -1140,7 +1139,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	if (aup->mii_bus->irq == NULL)
 		goto err_out;
 
-	for(i = 0; i < PHY_MAX_ADDR; ++i)
+	for (i = 0; i < PHY_MAX_ADDR; ++i)
 		aup->mii_bus->irq[i] = PHY_POLL;
 	/* if known, set corresponding PHY IRQs */
 	if (aup->phy_static_config)
diff --git a/drivers/net/au1000_eth.h b/drivers/net/au1000_eth.h
index f9d29a2..344c600 100644
--- a/drivers/net/au1000_eth.h
+++ b/drivers/net/au1000_eth.h
@@ -35,7 +35,7 @@
 #define NUM_TX_BUFFS 4
 #define MAX_BUF_SIZE 2048
 
-#define ETH_TX_TIMEOUT HZ/4
+#define ETH_TX_TIMEOUT (HZ/4)
 #define MAC_MIN_PKT_SIZE 64
 
 #define MULTICAST_FILTER_LIMIT 64
