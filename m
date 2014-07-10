From: varkabhadram@gmail.com
Subject: [PATCH net v2 3/7] net: cpmac: dynamic debug fixes
Date: Thu, 10 Jul 2014 11:05:41 +0530
Message-ID: <1404970545-26508-4-git-send-email-varkabhadram@gmail.com>
References: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>
Cc: mugunthanvnm@ti.com, linux@rainbow-software.org, balbi@ti.com,
	george.cherian@ti.com, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:48286 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbaGJFhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 01:37:13 -0400
Received: by mail-pa0-f50.google.com with SMTP id bj1so10581296pad.9
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2014 22:37:12 -0700 (PDT)
In-Reply-To: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

This patch does the following changes
1. convert printk(KERN_DEBUG.. to netdev_dbg() if we have net_device object
   or convert to dev_dbg() if we have device object.
2. convert printk(KERN_WARNING.. to netdev_warn() if we have net_device object
   or convert to dev_warn() if we have device object
3. convert printk() to pr_*

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/ti/cpmac.c |  136 ++++++++++++++++++---------------------
 1 file changed, 62 insertions(+), 74 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 1d8ef39..9faf669 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -228,21 +228,20 @@ static void cpmac_dump_regs(struct net_device *dev)
 		if (i % 16 == 0) {
 			if (i)
 				pr_cont("\n");
-			printk(KERN_DEBUG "%s: reg[%p]:", dev->name,
-			       priv->regs + i);
+			netdev_dbg(dev, "reg[%p]:", priv->regs + i);
 		}
-		printk(" %08x", cpmac_read(priv->regs, i));
+		pr_debug(" %08x", cpmac_read(priv->regs, i));
 	}
-	printk("\n");
+	pr_debug("\n");
 }
 
 static void cpmac_dump_desc(struct net_device *dev, struct cpmac_desc *desc)
 {
 	int i;
-	printk(KERN_DEBUG "%s: desc[%p]:", dev->name, desc);
+	netdev_dbg(dev, "desc[%p]:", desc);
 	for (i = 0; i < sizeof(*desc) / 4; i++)
-		printk(" %08x", ((u32 *)desc)[i]);
-	printk("\n");
+		pr_debug(" %08x", ((u32 *)desc)[i]);
+	pr_debug("\n");
 }
 
 static void cpmac_dump_all_desc(struct net_device *dev)
@@ -258,17 +257,16 @@ static void cpmac_dump_all_desc(struct net_device *dev)
 static void cpmac_dump_skb(struct net_device *dev, struct sk_buff *skb)
 {
 	int i;
-	printk(KERN_DEBUG "%s: skb 0x%p, len=%d\n", dev->name, skb, skb->len);
+	netdev_dbg(dev, "skb 0x%p, len=%d\n", skb, skb->len);
 	for (i = 0; i < skb->len; i++) {
 		if (i % 16 == 0) {
 			if (i)
 				pr_cont("\n");
-			printk(KERN_DEBUG "%s: data[%p]:", dev->name,
-			       skb->data + i);
+			netdev_dbg(dev, "data[%p]:", skb->data + i);
 		}
-		printk(" %02x", ((u8 *)skb->data)[i]);
+		pr_debug(" %02x", ((u8 *)skb->data)[i]);
 	}
-	printk("\n");
+	pr_debug("\n");
 }
 
 static int cpmac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
@@ -300,7 +298,7 @@ static int cpmac_mdio_reset(struct mii_bus *bus)
 
 	cpmac_clk = clk_get(&bus->dev, "cpmac");
 	if (IS_ERR(cpmac_clk)) {
-		printk(KERN_ERR "unable to get cpmac clock\n");
+		pr_err("unable to get cpmac clock\n");
 		return -1;
 	}
 	ar7_device_reset(AR7_RESET_BIT_MDIO);
@@ -368,8 +366,8 @@ static struct sk_buff *cpmac_rx_one(struct cpmac_priv *priv,
 	cpmac_write(priv->regs, CPMAC_RX_ACK(0), (u32)desc->mapping);
 	if (unlikely(!desc->datalen)) {
 		if (netif_msg_rx_err(priv) && net_ratelimit())
-			printk(KERN_WARNING "%s: rx: spurious interrupt\n",
-			       priv->dev->name);
+			netdev_warn(priv->dev, "rx: spurious interrupt\n");
+
 		return NULL;
 	}
 
@@ -389,15 +387,14 @@ static struct sk_buff *cpmac_rx_one(struct cpmac_priv *priv,
 						    DMA_FROM_DEVICE);
 		desc->hw_data = (u32)desc->data_mapping;
 		if (unlikely(netif_msg_pktdata(priv))) {
-			printk(KERN_DEBUG "%s: received packet:\n",
-			       priv->dev->name);
+			netdev_dbg(priv->dev, "received packet:\n");
 			cpmac_dump_skb(priv->dev, result);
 		}
 	} else {
 		if (netif_msg_rx_err(priv) && net_ratelimit())
-			printk(KERN_WARNING
-			       "%s: low on skbs, dropping packet\n",
-			       priv->dev->name);
+			netdev_warn(priv->dev,
+				    "low on skbs, dropping packet\n");
+
 		priv->dev->stats.rx_dropped++;
 	}
 
@@ -417,8 +414,8 @@ static int cpmac_poll(struct napi_struct *napi, int budget)
 	spin_lock(&priv->rx_lock);
 	if (unlikely(!priv->rx_head)) {
 		if (netif_msg_rx_err(priv) && net_ratelimit())
-			printk(KERN_WARNING "%s: rx: polling, but no queue\n",
-			       priv->dev->name);
+			netdev_warn(priv->dev, "rx: polling, but no queue\n");
+
 		spin_unlock(&priv->rx_lock);
 		napi_complete(napi);
 		return 0;
@@ -437,9 +434,9 @@ static int cpmac_poll(struct napi_struct *napi, int budget)
 			 */
 			if (unlikely(restart)) {
 				if (netif_msg_rx_err(priv))
-					printk(KERN_ERR "%s: poll found a"
-						" duplicate EOQ: %p and %p\n",
-						priv->dev->name, restart, desc);
+					netdev_err(priv->dev, "poll found a"
+						   " duplicate EOQ: %p and %p\n",
+						   restart, desc);
 				goto fatal_error;
 			}
 
@@ -485,15 +482,13 @@ static int cpmac_poll(struct napi_struct *napi, int budget)
 		priv->dev->stats.rx_errors++;
 		priv->dev->stats.rx_fifo_errors++;
 		if (netif_msg_rx_err(priv) && net_ratelimit())
-			printk(KERN_WARNING "%s: rx dma ring overrun\n",
-			       priv->dev->name);
+			netdev_warn(priv->dev, "rx dma ring overrun\n");
 
 		if (unlikely((restart->dataflags & CPMAC_OWN) == 0)) {
 			if (netif_msg_drv(priv))
-				printk(KERN_ERR "%s: cpmac_poll is trying to "
-					"restart rx from a descriptor that's "
-					"not free: %p\n",
-					priv->dev->name, restart);
+				netdev_err(priv->dev, "cpmac_poll is trying "
+					"to restart rx from a descriptor "
+					"that's not free: %p\n", restart);
 			goto fatal_error;
 		}
 
@@ -503,8 +498,8 @@ static int cpmac_poll(struct napi_struct *napi, int budget)
 	priv->rx_head = desc;
 	spin_unlock(&priv->rx_lock);
 	if (unlikely(netif_msg_rx_status(priv)))
-		printk(KERN_DEBUG "%s: poll processed %d packets\n",
-		       priv->dev->name, received);
+		netdev_dbg(priv->dev, "poll processed %d packets\n", received);
+
 	if (processed == 0) {
 		/* we ran out of packets to read,
 		 * revert to interrupt-driven mode
@@ -521,13 +516,12 @@ fatal_error:
 	 * Reset hardware to try to recover rather than wedging.
 	 */
 	if (netif_msg_drv(priv)) {
-		printk(KERN_ERR "%s: cpmac_poll is confused. "
-				"Resetting hardware\n", priv->dev->name);
+		netdev_err(priv->dev, "cpmac_poll is confused. "
+			   "Resetting hardware\n");
 		cpmac_dump_all_desc(priv->dev);
-		printk(KERN_DEBUG "%s: RX_PTR(0)=0x%08x RX_ACK(0)=0x%08x\n",
-			priv->dev->name,
-			cpmac_read(priv->regs, CPMAC_RX_PTR(0)),
-			cpmac_read(priv->regs, CPMAC_RX_ACK(0)));
+		netdev_dbg(priv->dev, "RX_PTR(0)=0x%08x RX_ACK(0)=0x%08x\n",
+			   cpmac_read(priv->regs, CPMAC_RX_PTR(0)),
+			   cpmac_read(priv->regs, CPMAC_RX_ACK(0)));
 	}
 
 	spin_unlock(&priv->rx_lock);
@@ -562,8 +556,8 @@ static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	desc = &priv->desc_ring[queue];
 	if (unlikely(desc->dataflags & CPMAC_OWN)) {
 		if (netif_msg_tx_err(priv) && net_ratelimit())
-			printk(KERN_WARNING "%s: tx dma ring full\n",
-			       dev->name);
+			netdev_warn(dev, "tx dma ring full\n");
+
 		return NETDEV_TX_BUSY;
 	}
 
@@ -577,8 +571,7 @@ static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	desc->datalen = len;
 	desc->buflen = len;
 	if (unlikely(netif_msg_tx_queued(priv)))
-		printk(KERN_DEBUG "%s: sending 0x%p, len=%d\n", dev->name, skb,
-		       skb->len);
+		netdev_dbg(dev, "sending 0x%p, len=%d\n", skb, skb->len);
 	if (unlikely(netif_msg_hw(priv)))
 		cpmac_dump_desc(dev, desc);
 	if (unlikely(netif_msg_pktdata(priv)))
@@ -604,8 +597,8 @@ static void cpmac_end_xmit(struct net_device *dev, int queue)
 				 DMA_TO_DEVICE);
 
 		if (unlikely(netif_msg_tx_done(priv)))
-			printk(KERN_DEBUG "%s: sent 0x%p, len=%d\n", dev->name,
-			       desc->skb, desc->skb->len);
+			netdev_dbg(dev, "sent 0x%p, len=%d\n",
+				   desc->skb, desc->skb->len);
 
 		dev_kfree_skb_irq(desc->skb);
 		desc->skb = NULL;
@@ -613,8 +606,7 @@ static void cpmac_end_xmit(struct net_device *dev, int queue)
 			netif_wake_subqueue(dev, queue);
 	} else {
 		if (netif_msg_tx_err(priv) && net_ratelimit())
-			printk(KERN_WARNING
-			       "%s: end_xmit: spurious interrupt\n", dev->name);
+			netdev_warn(dev, "end_xmit: spurious interrupt\n");
 		if (__netif_subqueue_stopped(dev, queue))
 			netif_wake_subqueue(dev, queue);
 	}
@@ -695,8 +687,7 @@ static void cpmac_clear_rx(struct net_device *dev)
 	for (i = 0; i < priv->ring_size; i++) {
 		if ((desc->dataflags & CPMAC_OWN) == 0) {
 			if (netif_msg_rx_err(priv) && net_ratelimit())
-				printk(KERN_WARNING "%s: packet dropped\n",
-				       dev->name);
+				netdev_warn(dev, "packet dropped\n");
 			if (unlikely(netif_msg_hw(priv)))
 				cpmac_dump_desc(dev, desc);
 			desc->dataflags = CPMAC_OWN;
@@ -756,13 +747,13 @@ static void cpmac_check_status(struct net_device *dev)
 			 * error codes actually are. So just log them and hope..
 			 */
 			if (rx_code)
-				printk(KERN_WARNING "%s: host error %d on rx "
-				     "channel %d (macstatus %08x), resetting\n",
-				     dev->name, rx_code, rx_channel, macstatus);
+				netdev_warn(dev, "host error %d on rx "
+					"channel %d (macstatus %08x), resetting\n",
+					rx_code, rx_channel, macstatus);
 			if (tx_code)
-				printk(KERN_WARNING "%s: host error %d on tx "
-				     "channel %d (macstatus %08x), resetting\n",
-				     dev->name, tx_code, tx_channel, macstatus);
+				netdev_warn(dev, "host error %d on tx "
+					"channel %d (macstatus %08x), resetting\n",
+					tx_code, tx_channel, macstatus);
 		}
 
 		netif_tx_stop_all_queues(dev);
@@ -787,8 +778,7 @@ static irqreturn_t cpmac_irq(int irq, void *dev_id)
 	status = cpmac_read(priv->regs, CPMAC_MAC_INT_VECTOR);
 
 	if (unlikely(netif_msg_intr(priv)))
-		printk(KERN_DEBUG "%s: interrupt status: 0x%08x\n", dev->name,
-		       status);
+		netdev_dbg(dev, "interrupt status: 0x%08x\n", status);
 
 	if (status & MAC_INT_TX)
 		cpmac_end_xmit(dev, (status & 7));
@@ -817,7 +807,7 @@ static void cpmac_tx_timeout(struct net_device *dev)
 	dev->stats.tx_errors++;
 	spin_unlock(&priv->lock);
 	if (netif_msg_tx_err(priv) && net_ratelimit())
-		printk(KERN_WARNING "%s: transmit timeout\n", dev->name);
+		netdev_warn(dev, "transmit timeout\n");
 
 	atomic_inc(&priv->reset_pending);
 	barrier();
@@ -953,8 +943,8 @@ static int cpmac_open(struct net_device *dev)
 	mem = platform_get_resource_byname(priv->pdev, IORESOURCE_MEM, "regs");
 	if (!request_mem_region(mem->start, resource_size(mem), dev->name)) {
 		if (netif_msg_drv(priv))
-			printk(KERN_ERR "%s: failed to request registers\n",
-			       dev->name);
+			netdev_err(dev, "failed to request registers\n");
+
 		res = -ENXIO;
 		goto fail_reserve;
 	}
@@ -962,8 +952,8 @@ static int cpmac_open(struct net_device *dev)
 	priv->regs = ioremap(mem->start, resource_size(mem));
 	if (!priv->regs) {
 		if (netif_msg_drv(priv))
-			printk(KERN_ERR "%s: failed to remap registers\n",
-			       dev->name);
+			netdev_err(dev, "failed to remap registers\n");
+
 		res = -ENXIO;
 		goto fail_remap;
 	}
@@ -1005,8 +995,8 @@ static int cpmac_open(struct net_device *dev)
 	res = request_irq(dev->irq, cpmac_irq, IRQF_SHARED, dev->name, dev);
 	if (res) {
 		if (netif_msg_drv(priv))
-			printk(KERN_ERR "%s: failed to obtain irq\n",
-			       dev->name);
+			netdev_err(dev, "failed to obtain irq\n");
+
 		goto fail_irq;
 	}
 
@@ -1123,7 +1113,7 @@ static int cpmac_probe(struct platform_device *pdev)
 
 	if (phy_id == PHY_MAX_ADDR) {
 		dev_err(&pdev->dev, "no PHY present, falling back "
-					"to switch on MDIO bus 0\n");
+			"to switch on MDIO bus 0\n");
 		strncpy(mdio_bus_id, "fixed-0", MII_BUS_ID_SIZE); /* fixed phys bus */
 		phy_id = pdev->id;
 	}
@@ -1164,24 +1154,22 @@ static int cpmac_probe(struct platform_device *pdev)
 
 	if (IS_ERR(priv->phy)) {
 		if (netif_msg_drv(priv))
-			printk(KERN_ERR "%s: Could not attach to PHY\n",
-			       dev->name);
+			dev_err(&pdev->dev, "Could not attach to PHY\n");
+
 		rc = PTR_ERR(priv->phy);
 		goto fail;
 	}
 
 	rc = register_netdev(dev);
 	if (rc) {
-		printk(KERN_ERR "cpmac: error %i registering device %s\n", rc,
-		       dev->name);
+		dev_err(&pdev->dev, "Could not register net device\n");
 		goto fail;
 	}
 
 	if (netif_msg_probe(priv)) {
-		printk(KERN_INFO
-		       "cpmac: device %s (regs: %p, irq: %d, phy: %s, "
-		       "mac: %pM)\n", dev->name, (void *)mem->start, dev->irq,
-		       priv->phy_name, dev->dev_addr);
+		dev_info(&pdev->dev, "regs: %p, irq: %d, phy: %s, "
+			 "mac: %pM\n", (void *)mem->start, dev->irq,
+			 priv->phy_name, dev->dev_addr);
 	}
 	return 0;
 
@@ -1223,7 +1211,7 @@ int cpmac_init(void)
 	cpmac_mii->priv = ioremap(AR7_REGS_MDIO, 256);
 
 	if (!cpmac_mii->priv) {
-		printk(KERN_ERR "Can't ioremap mdio registers\n");
+		pr_err("Can't ioremap mdio registers\n");
 		res = -ENXIO;
 		goto fail_alloc;
 	}
-- 
1.7.9.5
