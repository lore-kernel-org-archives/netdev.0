From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(8/20): remove ETH_FUNC_RET_STATUS and unused ETH_TARGET enums
Date: Mon, 28 Mar 2005 16:48:28 -0700
Message-ID: <20050328234827.GH29098@xyzzy>
References: <20050328233807.GA28423@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        James Chapman <jchapman@katalix.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328233807.GA28423@xyzzy>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The ETH_FUNC_RET_STATUS enum makes the driver code look more complex
than it needs to be so remove it. The ETH_TARGET enum was no longer
used so that goes as well.

Signed-off-by: James Chapman <jchapman@katalix.com>
Acked-by: Dale Farnsworth <dale@farnsworth.org>

Index: linux-2.5-enet/drivers/net/mv643xx_eth.h
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.h
+++ linux-2.5-enet/drivers/net/mv643xx_eth.h
@@ -385,25 +385,6 @@
 #define ETH_TX_ENABLE_INTERRUPT			(BIT23)
 #define ETH_AUTO_MODE				(BIT30)
 
-/* typedefs */
-
-typedef enum _eth_func_ret_status {
-	ETH_OK,			/* Returned as expected.		*/
-	ETH_ERROR,		/* Fundamental error.			*/
-	ETH_RETRY,		/* Could not process request. Try later.*/
-	ETH_END_OF_JOB,		/* Ring has nothing to process.		*/
-	ETH_QUEUE_FULL,		/* Ring resource error.			*/
-	ETH_QUEUE_LAST_RESOURCE	/* Ring resources about to exhaust.	*/
-} ETH_FUNC_RET_STATUS;
-
-typedef enum _eth_target {
-	ETH_TARGET_DRAM,
-	ETH_TARGET_DEVICE,
-	ETH_TARGET_CBS,
-	ETH_TARGET_PCI0,
-	ETH_TARGET_PCI1
-} ETH_TARGET;
-
 /* These are for big-endian machines.  Little endian needs different
  * definitions.
  */
Index: linux-2.5-enet/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.c
+++ linux-2.5-enet/drivers/net/mv643xx_eth.c
@@ -117,14 +117,14 @@
 static void eth_clear_mib_counters(unsigned int eth_port_num);
 
 /* Port data flow control routines */
-static ETH_FUNC_RET_STATUS eth_port_send(struct mv643xx_private *mp,
-					 struct pkt_info *p_pkt_info);
-static ETH_FUNC_RET_STATUS eth_tx_return_desc(struct mv643xx_private *mp,
-					      struct pkt_info *p_pkt_info);
-static ETH_FUNC_RET_STATUS eth_port_receive(struct mv643xx_private *mp,
-					    struct pkt_info *p_pkt_info);
-static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv643xx_private *mp,
-					      struct pkt_info *p_pkt_info);
+static int eth_port_send(struct mv643xx_private *mp,
+			 struct pkt_info *p_pkt_info);
+static int eth_tx_return_desc(struct mv643xx_private *mp,
+			      struct pkt_info *p_pkt_info);
+static int eth_port_receive(struct mv643xx_private *mp,
+			    struct pkt_info *p_pkt_info);
+static void eth_rx_return_buff(struct mv643xx_private *mp,
+			       struct pkt_info *p_pkt_info);
 
 static char mv643xx_driver_name[] = "mv643xx_eth";
 static char mv643xx_driver_version[] = "1.0";
@@ -220,11 +220,7 @@
 		pkt_info.buf_ptr = dma_map_single(NULL, skb->data, RX_SKB_SIZE,
 							DMA_FROM_DEVICE);
 		pkt_info.return_info = skb;
-		if (eth_rx_return_buff(mp, &pkt_info) != ETH_OK) {
-			printk(KERN_ERR
-				"%s: Error allocating RX Ring\n", dev->name);
-			break;
-		}
+		eth_rx_return_buff(mp, &pkt_info);
 		skb_reserve(skb, 2);
 	}
 	clear_bit(0, &mp->rx_task_busy);
@@ -384,7 +380,7 @@
 	spin_lock(&mp->lock);
 
 	/* Check only queue 0 */
-	while (eth_tx_return_desc(mp, &pkt_info) == ETH_OK) {
+	while (eth_tx_return_desc(mp, &pkt_info) == 0) {
 		if (pkt_info.cmd_sts & BIT0) {
 			if (netif_msg_tx_err(mp))
 				printk(KERN_WARNING "%s: Error in TX: cmd_sts=%08x\n",
@@ -453,9 +449,9 @@
 	struct pkt_info pkt_info;
 
 #ifdef MV643XX_NAPI
-	while (eth_port_receive(mp, &pkt_info) == ETH_OK && budget > 0) {
+	while (eth_port_receive(mp, &pkt_info) == 0 && budget > 0) {
 #else
-	while (eth_port_receive(mp, &pkt_info) == ETH_OK) {
+	while (eth_port_receive(mp, &pkt_info) == 0) {
 #endif
 		mp->rx_ring_skbs--;
 		received_packets++;
@@ -1204,7 +1200,7 @@
 	struct mv643xx_private *mp = netdev_priv(dev);
 	struct pkt_info pkt_info;
 
-	while (eth_tx_return_desc(mp, &pkt_info) == ETH_OK) {
+	while (eth_tx_return_desc(mp, &pkt_info) == 0) {
 		if (pkt_info.return_info) {
 			if (skb_shinfo(pkt_info.return_info)->nr_frags)
 				dma_unmap_page(NULL, pkt_info.buf_ptr,
@@ -1294,7 +1290,7 @@
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	struct net_device_stats *stats = &mp->stats;
-	ETH_FUNC_RET_STATUS status;
+	int status;
 	unsigned long flags;
 	struct pkt_info pkt_info;
 
@@ -1356,10 +1352,9 @@
 		pkt_info.return_info = skb;
 		mp->tx_ring_skbs++;
 		status = eth_port_send(mp, &pkt_info);
-		if ((status == ETH_ERROR) || (status == ETH_QUEUE_FULL))
-			if (netif_msg_tx_err(mp))
-				printk(KERN_WARNING "%s: Error on transmitting "
-				       "packet\n", dev->name);
+		if (status < 0)
+			goto out;
+
 		stats->tx_bytes += pkt_info.byte_cnt;
 	} else {
 		unsigned int frag;
@@ -1415,19 +1410,9 @@
 		}
 
 		status = eth_port_send(mp, &pkt_info);
-		if (status != ETH_OK) {
-			if ((status == ETH_ERROR))
-				printk(KERN_WARNING "%s: Error on "
-					       "transmitting packet\n",
-					       dev->name);
-			if (status == ETH_QUEUE_FULL)
-				printk(KERN_WARNING "%s: Error on "
-					       "Queue Full\n",
-					       dev->name);
-			if (status == ETH_QUEUE_LAST_RESOURCE)
-				printk(KERN_WARNING "%s: Tx resource error\n",
-					       dev->name);
-		}
+		if (status < 0)
+			goto out;
+
 		stats->tx_bytes += pkt_info.byte_cnt;
 
 		/* Check for the remaining frags */
@@ -1454,24 +1439,9 @@
 							DMA_TO_DEVICE);
 
 			status = eth_port_send(mp, &pkt_info);
+			if (status < 0)
+				goto out;
 
-			if (status != ETH_OK) {
-				if ((status == ETH_ERROR))
-					if (netif_msg_tx_err(mp))
-						printk(KERN_WARNING "%s: Error on "
-						       "transmitting packet\n",
-						       dev->name);
-
-				if (status == ETH_QUEUE_LAST_RESOURCE)
-					if (netif_msg_tx_err(mp))
-						printk(KERN_WARNING "%s: Tx resource "
-						       "error\n", dev->name);
-
-				if (status == ETH_QUEUE_FULL)
-					if (netif_msg_tx_err(mp))
-						printk(KERN_WARNING "%s: Queue is full\n",
-						       dev->name);
-			}
 			stats->tx_bytes += pkt_info.byte_cnt;
 		}
 	}
@@ -1485,10 +1455,8 @@
 	pkt_info.return_info = skb;
 	mp->tx_ring_skbs++;
 	status = eth_port_send(mp, &pkt_info);
-	if ((status == ETH_ERROR) || (status == ETH_QUEUE_FULL))
-		if (netif_msg_tx_err(mp))
-			printk(KERN_WARNING "%s: Error on transmitting packet\n",
-			       dev->name);
+	if (status == 0)
+		goto out;
 
 	stats->tx_bytes += pkt_info.byte_cnt;
 #endif
@@ -1508,6 +1476,7 @@
 	stats->tx_packets++;
 	dev->trans_start = jiffies;
 
+out:
 	spin_unlock_irqrestore(&mp->lock, flags);
 
 	return 0;		/* success */
@@ -2713,17 +2682,20 @@
 /*
  * Modified to include the first descriptor pointer in case of SG
  */
-static ETH_FUNC_RET_STATUS eth_port_send(struct mv643xx_private *mp,
-					 struct pkt_info *p_pkt_info)
+static int eth_port_send(struct mv643xx_private *mp,
+			 struct pkt_info *p_pkt_info)
 {
 	int tx_desc_curr, tx_desc_used, tx_first_desc, tx_next_desc;
 	struct eth_tx_desc *current_descriptor;
 	struct eth_tx_desc *first_descriptor;
 	u32 command;
+	int status;
 
 	/* Do not process Tx ring in case of Tx ring resource error */
-	if (mp->tx_resource_err)
-		return ETH_QUEUE_FULL;
+	if (mp->tx_resource_err) {
+		status = -ENOBUFS;
+		goto out;
+	}
 
 	/*
 	 * The hardware requires that each buffer that is <= 8 bytes
@@ -2732,7 +2704,8 @@
 	if (p_pkt_info->byte_cnt <= 8 && p_pkt_info->buf_ptr & 0x7) {
 		printk(KERN_ERR "%s: packet size <= 8 (%d) problem\n",
 		       dev->name, p_pkt_info->byte_cnt);
-		return ETH_ERROR;
+		status = -EIO;
+		goto out;
 	}
 
 	/* Get the Tx Desc ring indexes */
@@ -2787,26 +2760,34 @@
 	if (tx_next_desc == tx_desc_used) {
 		mp->tx_resource_err = 1;
 		mp->tx_curr_desc_q = tx_first_desc;
-
-		return ETH_QUEUE_LAST_RESOURCE;
+		result = -ENOBUFS;
+		goto out;
 	}
 
 	mp->tx_curr_desc_q = tx_next_desc;
+	status = 0;
+
+out:
+	if (status == -ENOBUFS)
+		printk(KERN_ERR "%s: Tx queue full\n", dev->name);
 
-	return ETH_OK;
+	return status;
 }
 #else
-static ETH_FUNC_RET_STATUS eth_port_send(struct mv643xx_private *mp,
-					 struct pkt_info *p_pkt_info)
+static int eth_port_send(struct mv643xx_private *mp,
+			 struct pkt_info *p_pkt_info)
 {
 	int tx_desc_curr;
 	int tx_desc_used;
 	struct eth_tx_desc *current_descriptor;
 	unsigned int command_status;
+	int status;
 
 	/* Do not process Tx ring in case of Tx ring resource error */
-	if (mp->tx_resource_err)
-		return ETH_QUEUE_FULL;
+	if (mp->tx_resource_err) {
+		status = -ENOBUFS;
+		goto out;
+	}
 
 	/* Get the Tx Desc ring indexes */
 	tx_desc_curr = mp->tx_curr_desc_q;
@@ -2842,10 +2823,17 @@
 	/* Check for ring index overlap in the Tx desc ring */
 	if (tx_desc_curr == tx_desc_used) {
 		mp->tx_resource_err = 1;
-		return ETH_QUEUE_LAST_RESOURCE;
+		status = -ENOBUFS;
+		goto out;
 	}
 
-	return ETH_OK;
+	status = 0;
+
+out:
+	if (status == -ENOBUFS)
+		printk(KERN_ERR "%s: Error on Queue Full\n", mp->netdev->name);
+
+	return status;
 }
 #endif
 
@@ -2873,8 +2861,8 @@
  *	ETH_OK otherwise.
  *
  */
-static ETH_FUNC_RET_STATUS eth_tx_return_desc(struct mv643xx_private *mp,
-						struct pkt_info *p_pkt_info)
+static int eth_tx_return_desc(struct mv643xx_private *mp,
+			      struct pkt_info *p_pkt_info)
 {
 	int tx_desc_used;
 #ifdef MV643XX_CHECKSUM_OFFLOAD_TX
@@ -2892,17 +2880,17 @@
 
 	/* Sanity check */
 	if (p_tx_desc_used == NULL)
-		return ETH_ERROR;
+		return -EBADMSG;
 
 	/* Stop release. About to overlap the current available Tx descriptor */
 	if (tx_desc_used == tx_busy_desc && !mp->tx_resource_err)
-		return ETH_END_OF_JOB;
+		return -ENOMSG;
 
 	command_status = p_tx_desc_used->cmd_sts;
 
 	/* Still transmitting... */
 	if (command_status & (ETH_BUFFER_OWNED_BY_DMA))
-		return ETH_RETRY;
+		return -EBUSY;
 
 	/* Pass the packet information to the caller */
 	p_pkt_info->cmd_sts = command_status;
@@ -2915,7 +2903,7 @@
 	/* Any Tx return cancels the Tx resource error status */
 	mp->tx_resource_err = 0;
 
-	return ETH_OK;
+	return 0;
 }
 
 /*
@@ -2941,7 +2929,7 @@
  *	ETH_END_OF_JOB if there is no received data.
  *	ETH_OK otherwise.
  */
-static ETH_FUNC_RET_STATUS eth_port_receive(struct mv643xx_private *mp,
+static int eth_port_receive(struct mv643xx_private *mp,
 						struct pkt_info *p_pkt_info)
 {
 	int rx_next_curr_desc, rx_curr_desc, rx_used_desc;
@@ -2950,7 +2938,7 @@
 
 	/* Do not process Rx ring in case of Rx ring resource error */
 	if (mp->rx_resource_err)
-		return ETH_QUEUE_FULL;
+		return -ENOBUFS;
 
 	/* Get the Rx Desc ring 'curr and 'used' indexes */
 	rx_curr_desc = mp->rx_curr_desc_q;
@@ -2964,7 +2952,7 @@
 
 	/* Nothing to receive... */
 	if (command_status & (ETH_BUFFER_OWNED_BY_DMA))
-		return ETH_END_OF_JOB;
+		return -ENOMSG;
 
 	p_pkt_info->byte_cnt = (p_rx_desc->byte_cnt) - RX_BUF_OFFSET;
 	p_pkt_info->cmd_sts = command_status;
@@ -2991,7 +2979,7 @@
 	if (rx_next_curr_desc == rx_used_desc)
 		mp->rx_resource_err = 1;
 
-	return ETH_OK;
+	return 0;
 }
 
 /*
@@ -3014,8 +3002,8 @@
  *	ETH_ERROR in case the routine can not access Rx desc ring.
  *	ETH_OK otherwise.
  */
-static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv643xx_private *mp,
-						struct pkt_info *p_pkt_info)
+static void eth_rx_return_buff(struct mv643xx_private *mp,
+			       struct pkt_info *p_pkt_info)
 {
 	int used_rx_desc;	/* Where to return Rx resource */
 	volatile struct eth_rx_desc *p_used_rx_desc;
@@ -3046,8 +3034,6 @@
 
 	/* Any Rx return cancels the Rx resource error status */
 	mp->rx_resource_err = 0;
-
-	return ETH_OK;
 }
 
 /************* Begin ethtool support *************************/
