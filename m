From: Joe Perches <joe@perches.com>
Subject: [PATCH] gianfar: Use pr_<level>, netdev_<level> and netif_<level>
Date: Tue, 14 Jun 2011 11:57:47 -0700
Message-ID: <1f8bdbed8f110b214daaff8350ae9bde68c9cc12.1308076047.git.joe@perches.com>
Cc: =?UTF-8?q?Sebastian=20P=C3=B6hn?= <sebastian.belden@googlemail.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3021 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752842Ab1FNS5s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 14:57:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the current logging styles.

Add #define DEBUG to get same output for <foo>_dbg messages.
Convert a few bare printks to pr_err.

Fix a likely copy/paste defect where a test was done with RX values:
        if (num_rx_qs > MAX_RX_QS) {
but TX limits were emitted:
        printk(KERN_ERR "num_rx_qs(=%d) greater than MAX_RX_QS(=%d)\n",
                              num_tx_qs, MAX_TX_QS);

Signed-off-by: Joe Perches <joe@perches.com>

---

Sebastian Poehn <sebastian.belden@googlemail.com>
recently submitted a largish patch to gianfar as well.
This may conflict with it.

 drivers/net/gianfar.c         |  113 +++++++++++++++++-----------------------
 drivers/net/gianfar_ethtool.c |   21 ++++----
 2 files changed, 58 insertions(+), 76 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 3564551..69cd3d3 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -62,6 +62,9 @@
  *  The driver then cleans up the buffer.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#define DEBUG
+
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/errno.h>
@@ -213,8 +216,7 @@ static int gfar_init_bds(struct net_device *ndev)
 			} else {
 				skb = gfar_new_skb(ndev);
 				if (!skb) {
-					pr_err("%s: Can't allocate RX buffers\n",
-							ndev->name);
+					netdev_err(ndev, "Can't allocate RX buffers\n");
 					goto err_rxalloc_fail;
 				}
 				rx_queue->rx_skbuff[j] = skb;
@@ -258,9 +260,8 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 			sizeof(struct rxbd8) * priv->total_rx_ring_size,
 			&addr, GFP_KERNEL);
 	if (!vaddr) {
-		if (netif_msg_ifup(priv))
-			pr_err("%s: Could not allocate buffer descriptors!\n",
-			       ndev->name);
+		netif_err(priv, ifup, ndev,
+			  "Could not allocate buffer descriptors!\n");
 		return -ENOMEM;
 	}
 
@@ -290,9 +291,8 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 		tx_queue->tx_skbuff = kmalloc(sizeof(*tx_queue->tx_skbuff) *
 				  tx_queue->tx_ring_size, GFP_KERNEL);
 		if (!tx_queue->tx_skbuff) {
-			if (netif_msg_ifup(priv))
-				pr_err("%s: Could not allocate tx_skbuff\n",
-						ndev->name);
+			netif_err(priv, ifup, ndev,
+				  "Could not allocate tx_skbuff\n");
 			goto cleanup;
 		}
 
@@ -306,9 +306,8 @@ static int gfar_alloc_skb_resources(struct net_device *ndev)
 				  rx_queue->rx_ring_size, GFP_KERNEL);
 
 		if (!rx_queue->rx_skbuff) {
-			if (netif_msg_ifup(priv))
-				pr_err("%s: Could not allocate rx_skbuff\n",
-				       ndev->name);
+			netif_err(priv, ifup, ndev,
+				  "Could not allocate rx_skbuff\n");
 			goto cleanup;
 		}
 
@@ -628,9 +627,9 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	num_tx_qs = tx_queues ? *tx_queues : 1;
 
 	if (num_tx_qs > MAX_TX_QS) {
-		printk(KERN_ERR "num_tx_qs(=%d) greater than MAX_TX_QS(=%d)\n",
-				num_tx_qs, MAX_TX_QS);
-		printk(KERN_ERR "Cannot do alloc_etherdev, aborting\n");
+		pr_err("num_tx_qs(=%d) greater than MAX_TX_QS(=%d)\n",
+		       num_tx_qs, MAX_TX_QS);
+		pr_err("Cannot do alloc_etherdev, aborting\n");
 		return -EINVAL;
 	}
 
@@ -638,9 +637,9 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	num_rx_qs = rx_queues ? *rx_queues : 1;
 
 	if (num_rx_qs > MAX_RX_QS) {
-		printk(KERN_ERR "num_rx_qs(=%d) greater than MAX_RX_QS(=%d)\n",
-				num_tx_qs, MAX_TX_QS);
-		printk(KERN_ERR "Cannot do alloc_etherdev, aborting\n");
+		pr_err("num_rx_qs(=%d) greater than MAX_RX_QS(=%d)\n",
+		       num_rx_qs, MAX_RX_QS);
+		pr_err("Cannot do alloc_etherdev, aborting\n");
 		return -EINVAL;
 	}
 
@@ -1163,8 +1162,7 @@ static int gfar_probe(struct platform_device *ofdev)
 	err = register_netdev(dev);
 
 	if (err) {
-		printk(KERN_ERR "%s: Cannot register net device, aborting.\n",
-				dev->name);
+		pr_err("%s: Cannot register net device, aborting\n", dev->name);
 		goto register_fail;
 	}
 
@@ -1215,17 +1213,17 @@ static int gfar_probe(struct platform_device *ofdev)
 	gfar_init_sysfs(dev);
 
 	/* Print out the device info */
-	printk(KERN_INFO DEVICE_NAME "%pM\n", dev->name, dev->dev_addr);
+	netdev_info(dev, "mac: %pM\n", dev->dev_addr);
 
 	/* Even more device info helps when determining which kernel */
 	/* provided which set of benchmarks. */
-	printk(KERN_INFO "%s: Running with NAPI enabled\n", dev->name);
+	netdev_info(dev, "Running with NAPI enabled\n");
 	for (i = 0; i < priv->num_rx_queues; i++)
-		printk(KERN_INFO "%s: RX BD ring size for Q[%d]: %d\n",
-			dev->name, i, priv->rx_queue[i]->rx_ring_size);
+		netdev_info(dev, "RX BD ring size for Q[%d]: %d\n",
+			    i, priv->rx_queue[i]->rx_ring_size);
 	for(i = 0; i < priv->num_tx_queues; i++)
-		 printk(KERN_INFO "%s: TX BD ring size for Q[%d]: %d\n",
-			dev->name, i, priv->tx_queue[i]->tx_ring_size);
+		netdev_info(dev, "TX BD ring size for Q[%d]: %d\n",
+			    i, priv->tx_queue[i]->tx_ring_size);
 
 	return 0;
 
@@ -1858,34 +1856,30 @@ static int register_grp_irqs(struct gfar_priv_grp *grp)
 		 * Transmit, and Receive */
 		if ((err = request_irq(grp->interruptError, gfar_error, 0,
 				grp->int_name_er,grp)) < 0) {
-			if (netif_msg_intr(priv))
-				printk(KERN_ERR "%s: Can't get IRQ %d\n",
-					dev->name, grp->interruptError);
+			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
+				  grp->interruptError);
 
 			goto err_irq_fail;
 		}
 
 		if ((err = request_irq(grp->interruptTransmit, gfar_transmit,
 				0, grp->int_name_tx, grp)) < 0) {
-			if (netif_msg_intr(priv))
-				printk(KERN_ERR "%s: Can't get IRQ %d\n",
-					dev->name, grp->interruptTransmit);
+			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
+				  grp->interruptTransmit);
 			goto tx_irq_fail;
 		}
 
 		if ((err = request_irq(grp->interruptReceive, gfar_receive, 0,
 				grp->int_name_rx, grp)) < 0) {
-			if (netif_msg_intr(priv))
-				printk(KERN_ERR "%s: Can't get IRQ %d\n",
-					dev->name, grp->interruptReceive);
+			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
+				  grp->interruptReceive);
 			goto rx_irq_fail;
 		}
 	} else {
 		if ((err = request_irq(grp->interruptTransmit, gfar_interrupt, 0,
 				grp->int_name_tx, grp)) < 0) {
-			if (netif_msg_intr(priv))
-				printk(KERN_ERR "%s: Can't get IRQ %d\n",
-					dev->name, grp->interruptTransmit);
+			netif_err(priv, intr, dev, "Can't get IRQ %d\n",
+				  grp->interruptTransmit);
 			goto err_irq_fail;
 		}
 	}
@@ -2354,9 +2348,7 @@ static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 		frame_size += VLAN_HLEN;
 
 	if ((frame_size < 64) || (frame_size > JUMBO_FRAME_SIZE)) {
-		if (netif_msg_drv(priv))
-			printk(KERN_ERR "%s: Invalid MTU setting\n",
-					dev->name);
+		netif_err(priv, drv, dev, "Invalid MTU setting\n");
 		return -EINVAL;
 	}
 
@@ -2776,9 +2768,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 				gfar_process_frame(dev, skb, amount_pull);
 
 			} else {
-				if (netif_msg_rx_err(priv))
-					printk(KERN_WARNING
-					       "%s: Missing skb!\n", dev->name);
+				netif_warn(priv, rx_err, dev, "Missing skb!\n");
 				rx_queue->stats.rx_dropped++;
 				priv->extra_stats.rx_skbmissing++;
 			}
@@ -2981,10 +2971,9 @@ static void adjust_link(struct net_device *dev)
 					ecntrl &= ~(ECNTRL_R100);
 				break;
 			default:
-				if (netif_msg_link(priv))
-					printk(KERN_WARNING
-						"%s: Ack!  Speed (%d) is not 10/100/1000!\n",
-						dev->name, phydev->speed);
+				netif_warn(priv, link, dev,
+					   "Ack!  Speed (%d) is not 10/100/1000!\n",
+					   phydev->speed);
 				break;
 			}
 
@@ -3189,8 +3178,8 @@ static irqreturn_t gfar_error(int irq, void *grp_id)
 
 	/* Hmm... */
 	if (netif_msg_rx_err(priv) || netif_msg_tx_err(priv))
-		printk(KERN_DEBUG "%s: error interrupt (ievent=0x%08x imask=0x%08x)\n",
-		       dev->name, events, gfar_read(&regs->imask));
+		netdev_dbg(dev, "error interrupt (ievent=0x%08x imask=0x%08x)\n",
+			   events, gfar_read(&regs->imask));
 
 	/* Update the error counters */
 	if (events & IEVENT_TXE) {
@@ -3203,9 +3192,8 @@ static irqreturn_t gfar_error(int irq, void *grp_id)
 		if (events & IEVENT_XFUN) {
 			unsigned long flags;
 
-			if (netif_msg_tx_err(priv))
-				printk(KERN_DEBUG "%s: TX FIFO underrun, "
-				       "packet dropped.\n", dev->name);
+			netif_dbg(priv, tx_err, dev,
+				  "TX FIFO underrun, packet dropped\n");
 			dev->stats.tx_dropped++;
 			priv->extra_stats.tx_underrun++;
 
@@ -3218,8 +3206,7 @@ static irqreturn_t gfar_error(int irq, void *grp_id)
 			unlock_tx_qs(priv);
 			local_irq_restore(flags);
 		}
-		if (netif_msg_tx_err(priv))
-			printk(KERN_DEBUG "%s: Transmit Error\n", dev->name);
+		netif_dbg(priv, tx_err, dev, "Transmit Error\n");
 	}
 	if (events & IEVENT_BSY) {
 		dev->stats.rx_errors++;
@@ -3227,29 +3214,25 @@ static irqreturn_t gfar_error(int irq, void *grp_id)
 
 		gfar_receive(irq, grp_id);
 
-		if (netif_msg_rx_err(priv))
-			printk(KERN_DEBUG "%s: busy error (rstat: %x)\n",
-			       dev->name, gfar_read(&regs->rstat));
+		netif_dbg(priv, rx_err, dev, "busy error (rstat: %x)\n",
+			  gfar_read(&regs->rstat));
 	}
 	if (events & IEVENT_BABR) {
 		dev->stats.rx_errors++;
 		priv->extra_stats.rx_babr++;
 
-		if (netif_msg_rx_err(priv))
-			printk(KERN_DEBUG "%s: babbling RX error\n", dev->name);
+		netif_dbg(priv, rx_err, dev, "babbling RX error\n");
 	}
 	if (events & IEVENT_EBERR) {
 		priv->extra_stats.eberr++;
-		if (netif_msg_rx_err(priv))
-			printk(KERN_DEBUG "%s: bus error\n", dev->name);
+		netif_dbg(priv, rx_err, dev, "bus error\n");
 	}
-	if ((events & IEVENT_RXC) && netif_msg_rx_status(priv))
-		printk(KERN_DEBUG "%s: control frame\n", dev->name);
+	if (events & IEVENT_RXC)
+		netif_dbg(priv, rx_status, dev, "control frame\n");
 
 	if (events & IEVENT_BABT) {
 		priv->extra_stats.tx_babt++;
-		if (netif_msg_tx_err(priv))
-			printk(KERN_DEBUG "%s: babbling TX error\n", dev->name);
+		netif_dbg(priv, tx_err, dev, "babbling TX error\n");
 	}
 	return IRQ_HANDLED;
 }
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 493d743..92d7ac0 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -16,6 +16,8 @@
  *  by reference.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/errno.h>
@@ -375,13 +377,13 @@ static int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals
 	/* Check the bounds of the values */
 	if (cvals->rx_coalesce_usecs > GFAR_MAX_COAL_USECS) {
 		pr_info("Coalescing is limited to %d microseconds\n",
-				GFAR_MAX_COAL_USECS);
+			GFAR_MAX_COAL_USECS);
 		return -EINVAL;
 	}
 
 	if (cvals->rx_max_coalesced_frames > GFAR_MAX_COAL_FRAMES) {
 		pr_info("Coalescing is limited to %d frames\n",
-				GFAR_MAX_COAL_FRAMES);
+			GFAR_MAX_COAL_FRAMES);
 		return -EINVAL;
 	}
 
@@ -404,13 +406,13 @@ static int gfar_scoalesce(struct net_device *dev, struct ethtool_coalesce *cvals
 	/* Check the bounds of the values */
 	if (cvals->tx_coalesce_usecs > GFAR_MAX_COAL_USECS) {
 		pr_info("Coalescing is limited to %d microseconds\n",
-				GFAR_MAX_COAL_USECS);
+			GFAR_MAX_COAL_USECS);
 		return -EINVAL;
 	}
 
 	if (cvals->tx_max_coalesced_frames > GFAR_MAX_COAL_FRAMES) {
 		pr_info("Coalescing is limited to %d frames\n",
-				GFAR_MAX_COAL_FRAMES);
+			GFAR_MAX_COAL_FRAMES);
 		return -EINVAL;
 	}
 
@@ -464,8 +466,7 @@ static int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rva
 		return -EINVAL;
 
 	if (!is_power_of_2(rvals->rx_pending)) {
-		printk("%s: Ring sizes must be a power of 2\n",
-				dev->name);
+		netdev_err(dev, "Ring sizes must be a power of 2\n");
 		return -EINVAL;
 	}
 
@@ -473,8 +474,7 @@ static int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rva
 		return -EINVAL;
 
 	if (!is_power_of_2(rvals->tx_pending)) {
-		printk("%s: Ring sizes must be a power of 2\n",
-				dev->name);
+		netdev_err(dev, "Ring sizes must be a power of 2\n");
 		return -EINVAL;
 	}
 
@@ -700,7 +700,7 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u
 		cmp_rqfpr = RQFPR_IPV6 |RQFPR_UDP;
 		break;
 	default:
-		printk(KERN_ERR "Right now this class is not supported\n");
+		pr_err("Right now this class is not supported\n");
 		return 0;
 	}
 
@@ -715,8 +715,7 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u
 	}
 
 	if (i == MAX_FILER_IDX + 1) {
-		printk(KERN_ERR "No parse rule found, ");
-		printk(KERN_ERR "can't create hash rules\n");
+		pr_err("No parse rule found, can't create hash rules\n");
 		return 0;
 	}
 
-- 
1.7.6.rc0

