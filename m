From: dhananjay@netxen.com
Subject: [patch 6/6] netxen: optimize tx handling
Date: Thu, 20 Dec 2007 18:37:02 -0800
Message-ID: <20071221024309.711781822@netxen.com>
References: <20071221023656.409657310@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:36121 "EHLO dut46.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754806AbXLUCvQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 21:51:16 -0500
Content-Disposition: inline; filename=xmit.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netxen driver allows limited number of threads simultaneously posting skb's
in tx ring. If transmit slot is unavailable, driver calls schedule() or
loops in xmit_frame().

This patch returns TX_BUSY and lets the stack reschedule the packet if
transmit slot is unavailable. Also removes unnecessary check for tx timeout
in the driver itself, the network stack does that anyway.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Index: netdev-2.6/drivers/net/netxen/netxen_nic_main.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_main.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_main.c
@@ -986,28 +986,6 @@ static int netxen_nic_xmit_frame(struct 
 		return NETDEV_TX_OK;
 	}
 
-	/*
-	 * Everything is set up. Now, we just need to transmit it out.
-	 * Note that we have to copy the contents of buffer over to
-	 * right place. Later on, this can be optimized out by de-coupling the
-	 * producer index from the buffer index.
-	 */
-      retry_getting_window:
-	spin_lock_bh(&adapter->tx_lock);
-	if (adapter->total_threads >= MAX_XMIT_PRODUCERS) {
-		spin_unlock_bh(&adapter->tx_lock);
-		/*
-		 * Yield CPU
-		 */
-		if (!in_atomic())
-			schedule();
-		else {
-			for (i = 0; i < 20; i++)
-				cpu_relax();	/*This a nop instr on i386 */
-		}
-		goto retry_getting_window;
-	}
-	local_producer = adapter->cmd_producer;
 	/* There 4 fragments per descriptor */
 	no_of_desc = (frag_count + 3) >> 2;
 	if (netdev->features & NETIF_F_TSO) {
@@ -1021,16 +999,19 @@ static int netxen_nic_xmit_frame(struct 
 			}
 		}
 	}
+
+	spin_lock_bh(&adapter->tx_lock);
+	if (adapter->total_threads >= MAX_XMIT_PRODUCERS) {
+		goto out_requeue;
+	}
+	local_producer = adapter->cmd_producer;
 	k = adapter->cmd_producer;
 	max_tx_desc_count = adapter->max_tx_desc_count;
 	last_cmd_consumer = adapter->last_cmd_consumer;
 	if ((k + no_of_desc) >=
 	    ((last_cmd_consumer <= k) ? last_cmd_consumer + max_tx_desc_count :
 	     last_cmd_consumer)) {
-		netif_stop_queue(netdev);
-		adapter->flags |= NETXEN_NETDEV_STATUS;
-		spin_unlock_bh(&adapter->tx_lock);
-		return NETDEV_TX_BUSY;
+		goto out_requeue;
 	}
 	k = get_index_range(k, max_tx_desc_count, no_of_desc);
 	adapter->cmd_producer = k;
@@ -1083,6 +1064,8 @@ static int netxen_nic_xmit_frame(struct 
 						  adapter->max_tx_desc_count);
 			hwdesc = &hw->cmd_desc_head[producer];
 			memset(hwdesc, 0, sizeof(struct cmd_desc_type0));
+			pbuf = &adapter->cmd_buf_arr[producer];
+			pbuf->skb = NULL;
 		}
 		frag = &skb_shinfo(skb)->frags[i - 1];
 		len = frag->size;
@@ -1138,6 +1121,8 @@ static int netxen_nic_xmit_frame(struct 
 		}
 		/* copy the MAC/IP/TCP headers to the cmd descriptor list */
 		hwdesc = &hw->cmd_desc_head[producer];
+		pbuf = &adapter->cmd_buf_arr[producer];
+		pbuf->skb = NULL;
 
 		/* copy the first 64 bytes */
 		memcpy(((void *)hwdesc) + 2,
@@ -1146,6 +1131,8 @@ static int netxen_nic_xmit_frame(struct 
 
 		if (more_hdr) {
 			hwdesc = &hw->cmd_desc_head[producer];
+			pbuf = &adapter->cmd_buf_arr[producer];
+			pbuf->skb = NULL;
 			/* copy the next 64 bytes - should be enough except
 			 * for pathological case
 			 */
@@ -1179,14 +1166,17 @@ static int netxen_nic_xmit_frame(struct 
 	}
 
 	adapter->stats.xmitfinished++;
-	spin_unlock_bh(&adapter->tx_lock);
-
 	netdev->trans_start = jiffies;
 
-	DPRINTK(INFO, "wrote CMD producer %x to phantom\n", producer);
-
-	DPRINTK(INFO, "Done. Send\n");
+	spin_unlock_bh(&adapter->tx_lock);
 	return NETDEV_TX_OK;
+
+out_requeue:
+	netif_stop_queue(netdev);
+	adapter->flags |= NETXEN_NETDEV_STATUS;
+
+	spin_unlock_bh(&adapter->tx_lock);
+	return NETDEV_TX_BUSY;
 }
 
 static void netxen_watchdog(unsigned long v)
Index: netdev-2.6/drivers/net/netxen/netxen_nic_init.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_init.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_init.c
@@ -1229,7 +1229,6 @@ int netxen_process_cmd_ring(struct netxe
 	struct pci_dev *pdev;
 	struct netxen_skb_frag *frag;
 	u32 i;
-	struct sk_buff *skb = NULL;
 	int done;
 
 	spin_lock(&adapter->tx_lock);
@@ -1259,9 +1258,8 @@ int netxen_process_cmd_ring(struct netxe
 	while ((last_consumer != consumer) && (count1 < MAX_STATUS_HANDLE)) {
 		buffer = &adapter->cmd_buf_arr[last_consumer];
 		pdev = adapter->pdev;
-		frag = &buffer->frag_array[0];
-		skb = buffer->skb;
-		if (skb && (cmpxchg(&buffer->skb, skb, 0) == skb)) {
+		if (buffer->skb) {
+			frag = &buffer->frag_array[0];
 			pci_unmap_single(pdev, frag->dma, frag->length,
 					 PCI_DMA_TODEVICE);
 			frag->dma = 0ULL;
@@ -1274,8 +1272,8 @@ int netxen_process_cmd_ring(struct netxe
 			}
 
 			adapter->stats.skbfreed++;
-			dev_kfree_skb_any(skb);
-			skb = NULL;
+			dev_kfree_skb_any(buffer->skb);
+			buffer->skb = NULL;
 		} else if (adapter->proc_cmd_buf_counter == 1) {
 			adapter->stats.txnullskb++;
 		}

-- 
