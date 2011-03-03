From: Joe Perches <joe@perches.com>
Subject: [PATCH] mv643xx_eth: Use netdev_<level> and pr_<level>
Date: Wed, 02 Mar 2011 19:50:35 -0800
Message-ID: <1299124235.4208.129.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4068 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932136Ab1CCDuh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 22:50:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the current logging styles.

Signed-off-by: Joe Perches <joe@perches.com>

---

Hey Lennart.

I don't know if this module is still being maintained.
If so, here's a conversion to the current logging styles.

 drivers/net/mv643xx_eth.c |   74 ++++++++++++++++++++-------------------------
 1 files changed, 33 insertions(+), 41 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 02076e1..34425b9 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -35,6 +35,8 @@
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/init.h>
 #include <linux/dma-mapping.h>
 #include <linux/in.h>
@@ -627,9 +629,8 @@ err:
 		if ((cmd_sts & (RX_FIRST_DESC | RX_LAST_DESC)) !=
 			(RX_FIRST_DESC | RX_LAST_DESC)) {
 			if (net_ratelimit())
-				dev_printk(KERN_ERR, &mp->dev->dev,
-					   "received packet spanning "
-					   "multiple descriptors\n");
+				netdev_err(mp->dev,
+					   "received packet spanning multiple descriptors\n");
 		}
 
 		if (cmd_sts & ERROR_SUMMARY)
@@ -868,15 +869,14 @@ static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (has_tiny_unaligned_frags(skb) && __skb_linearize(skb)) {
 		txq->tx_dropped++;
-		dev_printk(KERN_DEBUG, &dev->dev,
-			   "failed to linearize skb with tiny "
-			   "unaligned fragment\n");
+		netdev_printk(KERN_DEBUG, dev,
+			      "failed to linearize skb with tiny unaligned fragment\n");
 		return NETDEV_TX_BUSY;
 	}
 
 	if (txq->tx_ring_size - txq->tx_desc_count < MAX_SKB_FRAGS + 1) {
 		if (net_ratelimit())
-			dev_printk(KERN_ERR, &dev->dev, "tx queue full?!\n");
+			netdev_err(dev, "tx queue full?!\n");
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
@@ -959,7 +959,7 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 			skb = __skb_dequeue(&txq->tx_skb);
 
 		if (cmd_sts & ERROR_SUMMARY) {
-			dev_printk(KERN_INFO, &mp->dev->dev, "tx error\n");
+			netdev_info(mp->dev, "tx error\n");
 			mp->dev->stats.tx_errors++;
 		}
 
@@ -1122,20 +1122,20 @@ static int smi_bus_read(struct mii_bus *bus, int addr, int reg)
 	int ret;
 
 	if (smi_wait_ready(msp)) {
-		printk(KERN_WARNING "mv643xx_eth: SMI bus busy timeout\n");
+		pr_warn("SMI bus busy timeout\n");
 		return -ETIMEDOUT;
 	}
 
 	writel(SMI_OPCODE_READ | (reg << 21) | (addr << 16), smi_reg);
 
 	if (smi_wait_ready(msp)) {
-		printk(KERN_WARNING "mv643xx_eth: SMI bus busy timeout\n");
+		pr_warn("SMI bus busy timeout\n");
 		return -ETIMEDOUT;
 	}
 
 	ret = readl(smi_reg);
 	if (!(ret & SMI_READ_VALID)) {
-		printk(KERN_WARNING "mv643xx_eth: SMI bus read not valid\n");
+		pr_warn("SMI bus read not valid\n");
 		return -ENODEV;
 	}
 
@@ -1148,7 +1148,7 @@ static int smi_bus_write(struct mii_bus *bus, int addr, int reg, u16 val)
 	void __iomem *smi_reg = msp->base + SMI_REG;
 
 	if (smi_wait_ready(msp)) {
-		printk(KERN_WARNING "mv643xx_eth: SMI bus busy timeout\n");
+		pr_warn("SMI bus busy timeout\n");
 		return -ETIMEDOUT;
 	}
 
@@ -1156,7 +1156,7 @@ static int smi_bus_write(struct mii_bus *bus, int addr, int reg, u16 val)
 		(addr << 16) | (val & 0xffff), smi_reg);
 
 	if (smi_wait_ready(msp)) {
-		printk(KERN_WARNING "mv643xx_eth: SMI bus busy timeout\n");
+		pr_warn("SMI bus busy timeout\n");
 		return -ETIMEDOUT;
 	}
 
@@ -1566,9 +1566,8 @@ mv643xx_eth_set_ringparam(struct net_device *dev, struct ethtool_ringparam *er)
 	if (netif_running(dev)) {
 		mv643xx_eth_stop(dev);
 		if (mv643xx_eth_open(dev)) {
-			dev_printk(KERN_ERR, &dev->dev,
-				   "fatal error on re-opening device after "
-				   "ring param change\n");
+			netdev_err(dev,
+				   "fatal error on re-opening device after ring param change\n");
 			return -ENOMEM;
 		}
 	}
@@ -1874,7 +1873,7 @@ static int rxq_init(struct mv643xx_eth_private *mp, int index)
 	}
 
 	if (rxq->rx_desc_area == NULL) {
-		dev_printk(KERN_ERR, &mp->dev->dev,
+		netdev_err(mp->dev,
 			   "can't allocate rx ring (%d bytes)\n", size);
 		goto out;
 	}
@@ -1884,8 +1883,7 @@ static int rxq_init(struct mv643xx_eth_private *mp, int index)
 	rxq->rx_skb = kmalloc(rxq->rx_ring_size * sizeof(*rxq->rx_skb),
 								GFP_KERNEL);
 	if (rxq->rx_skb == NULL) {
-		dev_printk(KERN_ERR, &mp->dev->dev,
-			   "can't allocate rx skb ring\n");
+		netdev_err(mp->dev, "can't allocate rx skb ring\n");
 		goto out_free;
 	}
 
@@ -1944,8 +1942,7 @@ static void rxq_deinit(struct rx_queue *rxq)
 	}
 
 	if (rxq->rx_desc_count) {
-		dev_printk(KERN_ERR, &mp->dev->dev,
-			   "error freeing rx ring -- %d skbs stuck\n",
+		netdev_err(mp->dev, "error freeing rx ring -- %d skbs stuck\n",
 			   rxq->rx_desc_count);
 	}
 
@@ -1987,7 +1984,7 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 	}
 
 	if (txq->tx_desc_area == NULL) {
-		dev_printk(KERN_ERR, &mp->dev->dev,
+		netdev_err(mp->dev,
 			   "can't allocate tx ring (%d bytes)\n", size);
 		return -ENOMEM;
 	}
@@ -2093,7 +2090,7 @@ static void handle_link_event(struct mv643xx_eth_private *mp)
 		if (netif_carrier_ok(dev)) {
 			int i;
 
-			printk(KERN_INFO "%s: link down\n", dev->name);
+			netdev_info(dev, "link down\n");
 
 			netif_carrier_off(dev);
 
@@ -2124,10 +2121,8 @@ static void handle_link_event(struct mv643xx_eth_private *mp)
 	duplex = (port_status & FULL_DUPLEX) ? 1 : 0;
 	fc = (port_status & FLOW_CONTROL_ENABLED) ? 1 : 0;
 
-	printk(KERN_INFO "%s: link up, %d Mb/s, %s duplex, "
-			 "flow control %sabled\n", dev->name,
-			 speed, duplex ? "full" : "half",
-			 fc ? "en" : "dis");
+	netdev_info(dev, "link up, %d Mb/s, %s duplex, flow control %sabled\n",
+		    speed, duplex ? "full" : "half", fc ? "en" : "dis");
 
 	if (!netif_carrier_ok(dev))
 		netif_carrier_on(dev);
@@ -2337,7 +2332,7 @@ static int mv643xx_eth_open(struct net_device *dev)
 	err = request_irq(dev->irq, mv643xx_eth_irq,
 			  IRQF_SHARED, dev->name, dev);
 	if (err) {
-		dev_printk(KERN_ERR, &dev->dev, "can't assign irq\n");
+		netdev_err(dev, "can't assign irq\n");
 		return -EAGAIN;
 	}
 
@@ -2483,9 +2478,8 @@ static int mv643xx_eth_change_mtu(struct net_device *dev, int new_mtu)
 	 */
 	mv643xx_eth_stop(dev);
 	if (mv643xx_eth_open(dev)) {
-		dev_printk(KERN_ERR, &dev->dev,
-			   "fatal error on re-opening device after "
-			   "MTU change\n");
+		netdev_err(dev,
+			   "fatal error on re-opening device after MTU change\n");
 	}
 
 	return 0;
@@ -2508,7 +2502,7 @@ static void mv643xx_eth_tx_timeout(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
 
-	dev_printk(KERN_INFO, &dev->dev, "tx timeout\n");
+	netdev_info(dev, "tx timeout\n");
 
 	schedule_work(&mp->tx_timeout_task);
 }
@@ -2603,8 +2597,8 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	int ret;
 
 	if (!mv643xx_eth_version_printed++)
-		printk(KERN_NOTICE "MV-643xx 10/100/1000 ethernet "
-			"driver version %s\n", mv643xx_eth_driver_version);
+		pr_notice("MV-643xx 10/100/1000 ethernet driver version %s\n",
+			  mv643xx_eth_driver_version);
 
 	ret = -EINVAL;
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -2871,14 +2865,12 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	pd = pdev->dev.platform_data;
 	if (pd == NULL) {
-		dev_printk(KERN_ERR, &pdev->dev,
-			   "no mv643xx_eth_platform_data\n");
+		dev_err(&pdev->dev, "no mv643xx_eth_platform_data\n");
 		return -ENODEV;
 	}
 
 	if (pd->shared == NULL) {
-		dev_printk(KERN_ERR, &pdev->dev,
-			   "no mv643xx_eth_platform_data->shared\n");
+		dev_err(&pdev->dev, "no mv643xx_eth_platform_data->shared\n");
 		return -ENODEV;
 	}
 
@@ -2957,11 +2949,11 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	if (err)
 		goto out;
 
-	dev_printk(KERN_NOTICE, &dev->dev, "port %d with MAC address %pM\n",
-		   mp->port_num, dev->dev_addr);
+	netdev_notice(dev, "port %d with MAC address %pM\n",
+		      mp->port_num, dev->dev_addr);
 
 	if (mp->tx_desc_sram_size > 0)
-		dev_printk(KERN_NOTICE, &dev->dev, "configured with sram\n");
+		netdev_notice(dev, "configured with sram\n");
 
 	return 0;
 


