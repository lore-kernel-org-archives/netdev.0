From: akpm@linux-foundation.org
Subject: [patch 18/19] mv643xx ethernet driver IRQ registration fix
Date: Tue, 06 Mar 2007 02:42:02 -0800
Message-ID: <200703061042.l26Ag25d019787@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	giri@lmc.cs.sunysb.edu, dale@farnsworth.org, pgiri@yahoo.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34872 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964785AbXCFKqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 05:46:15 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Giridhar Pemmasani <giri@lmc.cs.sunysb.edu>

During initialization, mv643xx driver registers IRQ before setting up tx/rx
rings.  This causes kernel oops because mv643xx_poll, which gets called
right after registering IRQ, calls netif_rx_complete, which accesses the rx
ring (I don't have the oops message anymore; I just remember this sequence
of calls).  Attached (tested) patch first initializes the rx/tx rings and
then registers the IRQ.

Signed-off-by: Giridhar Pemmasani <pgiri@yahoo.com>
Cc: Dale Farnsworth <dale@farnsworth.org>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/mv643xx_eth.c |   40 +++++++++++++++++++-----------------
 1 file changed, 22 insertions(+), 18 deletions(-)

diff -puN drivers/net/mv643xx_eth.c~mv643xx-ethernet-driver-irq-registration-fix drivers/net/mv643xx_eth.c
--- a/drivers/net/mv643xx_eth.c~mv643xx-ethernet-driver-irq-registration-fix
+++ a/drivers/net/mv643xx_eth.c
@@ -787,14 +787,6 @@ static int mv643xx_eth_open(struct net_d
 	unsigned int size;
 	int err;
 
-	err = request_irq(dev->irq, mv643xx_eth_int_handler,
-			IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
-	if (err) {
-		printk(KERN_ERR "Can not assign IRQ number to MV643XX_eth%d\n",
-								port_num);
-		return -EAGAIN;
-	}
-
 	eth_port_init(mp);
 
 	memset(&mp->timeout, 0, sizeof(struct timer_list));
@@ -806,8 +798,7 @@ static int mv643xx_eth_open(struct net_d
 								GFP_KERNEL);
 	if (!mp->rx_skb) {
 		printk(KERN_ERR "%s: Cannot allocate Rx skb ring\n", dev->name);
-		err = -ENOMEM;
-		goto out_free_irq;
+		return -ENOMEM;
 	}
 	mp->tx_skb = kmalloc(sizeof(*mp->tx_skb) * mp->tx_ring_size,
 								GFP_KERNEL);
@@ -861,13 +852,8 @@ static int mv643xx_eth_open(struct net_d
 							dev->name, size);
 		printk(KERN_ERR "%s: Freeing previously allocated TX queues...",
 							dev->name);
-		if (mp->rx_sram_size)
-			iounmap(mp->p_tx_desc_area);
-		else
-			dma_free_coherent(NULL, mp->tx_desc_area_size,
-					mp->p_tx_desc_area, mp->tx_desc_dma);
 		err = -ENOMEM;
-		goto out_free_tx_skb;
+		goto out_free_tx_ring;
 	}
 	memset((void *)mp->p_rx_desc_area, 0, size);
 
@@ -875,6 +861,14 @@ static int mv643xx_eth_open(struct net_d
 
 	mv643xx_eth_rx_refill_descs(dev);	/* Fill RX ring with skb's */
 
+	err = request_irq(dev->irq, mv643xx_eth_int_handler,
+			IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
+	if (err) {
+		printk(KERN_ERR "Can not assign IRQ number to MV643XX_eth%d\n",
+			port_num);
+		goto out_free_rx_ring;
+	}
+
 	/* Clear any pending ethernet port interrupts */
 	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
 	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
@@ -900,12 +894,22 @@ static int mv643xx_eth_open(struct net_d
 
 	return 0;
 
+out_free_rx_ring:
+	if (mp->rx_sram_size)
+		iounmap(mp->p_rx_desc_area);
+	else
+		dma_free_coherent(NULL, mp->rx_desc_area_size,
+			mp->p_rx_desc_area, mp->rx_desc_dma);
+out_free_tx_ring:
+	if (mp->tx_sram_size)
+		iounmap(mp->p_tx_desc_area);
+	else
+		dma_free_coherent(NULL, mp->tx_desc_area_size,
+				mp->p_tx_desc_area, mp->tx_desc_dma);
 out_free_tx_skb:
 	kfree(mp->tx_skb);
 out_free_rx_skb:
 	kfree(mp->rx_skb);
-out_free_irq:
-	free_irq(dev->irq, dev);
 
 	return err;
 }
_
