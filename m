From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 14/21] ibmveth: Convert driver specific debug to netdev_dbg
Date: Fri, 03 Sep 2010 23:29:14 -0500
Message-ID: <20100904042914.2655.33761.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:40317 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386Ab0IDE3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 00:29:42 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844HglO007073
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:17:42 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o844TfsG207820
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:29:41 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844Tfcx001788
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:29:41 -0600
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_dbg to standardise the debug output.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:19:11.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:19:12.000000000 -0500
@@ -64,18 +64,12 @@
   printk(KERN_ERR "(%s:%3.3d ua:%x) ERROR: " fmt, __FILE__, __LINE__ , adapter->vdev->unit_address, ## args)
 
 #ifdef DEBUG
-#define ibmveth_debug_printk_no_adapter(fmt, args...) \
-  printk(KERN_DEBUG "(%s:%3.3d): " fmt, __FILE__, __LINE__ , ## args)
-#define ibmveth_debug_printk(fmt, args...) \
-  printk(KERN_DEBUG "(%s:%3.3d ua:%x): " fmt, __FILE__, __LINE__ , adapter->vdev->unit_address, ## args)
 #define ibmveth_assert(expr) \
   if(!(expr)) {                                   \
     printk(KERN_DEBUG "assertion failed (%s:%3.3d ua:%x): %s\n", __FILE__, __LINE__, adapter->vdev->unit_address, #expr); \
     BUG(); \
   }
 #else
-#define ibmveth_debug_printk_no_adapter(fmt, args...)
-#define ibmveth_debug_printk(fmt, args...)
 #define ibmveth_assert(expr)
 #endif
 
@@ -248,7 +242,8 @@ static void ibmveth_replenish_buffer_poo
 		skb = netdev_alloc_skb(adapter->netdev, pool->buff_size);
 
 		if(!skb) {
-			ibmveth_debug_printk("replenish: unable to allocate skb\n");
+			netdev_dbg(adapter->netdev,
+				   "replenish: unable to allocate skb\n");
 			adapter->replenish_no_mem++;
 			break;
 		}
@@ -440,7 +435,8 @@ static void ibmveth_rxq_recycle_buffer(s
 	lpar_rc = h_add_logical_lan_buffer(adapter->vdev->unit_address, desc.desc);
 
 	if(lpar_rc != H_SUCCESS) {
-		ibmveth_debug_printk("h_add_logical_lan_buffer failed during recycle rc=%ld", lpar_rc);
+		netdev_dbg(adapter->netdev, "h_add_logical_lan_buffer failed "
+			   "during recycle rc=%ld", lpar_rc);
 		ibmveth_remove_buffer_from_pool(adapter, adapter->rx_queue.queue_addr[adapter->rx_queue.index].correlator);
 	}
 
@@ -551,7 +547,7 @@ static int ibmveth_open(struct net_devic
 	int i;
 	struct device *dev;
 
-	ibmveth_debug_printk("open starting\n");
+	netdev_dbg(netdev, "open starting\n");
 
 	napi_enable(&adapter->napi);
 
@@ -607,9 +603,9 @@ static int ibmveth_open(struct net_devic
 	rxq_desc.fields.flags_len = IBMVETH_BUF_VALID | adapter->rx_queue.queue_len;
 	rxq_desc.fields.address = adapter->rx_queue.queue_dma;
 
-	ibmveth_debug_printk("buffer list @ 0x%p\n", adapter->buffer_list_addr);
-	ibmveth_debug_printk("filter list @ 0x%p\n", adapter->filter_list_addr);
-	ibmveth_debug_printk("receive q   @ 0x%p\n", adapter->rx_queue.queue_addr);
+	netdev_dbg(netdev, "buffer list @ 0x%p\n", adapter->buffer_list_addr);
+	netdev_dbg(netdev, "filter list @ 0x%p\n", adapter->filter_list_addr);
+	netdev_dbg(netdev, "receive q   @ 0x%p\n", adapter->rx_queue.queue_addr);
 
 	h_vio_signal(adapter->vdev->unit_address, VIO_IRQ_DISABLE);
 
@@ -639,7 +635,7 @@ static int ibmveth_open(struct net_devic
 		}
 	}
 
-	ibmveth_debug_printk("registering irq 0x%x\n", netdev->irq);
+	netdev_dbg(netdev, "registering irq 0x%x\n", netdev->irq);
 	if((rc = request_irq(netdev->irq, ibmveth_interrupt, 0, netdev->name, netdev)) != 0) {
 		ibmveth_error_printk("unable to request irq 0x%x, rc %d\n", netdev->irq, rc);
 		do {
@@ -669,12 +665,12 @@ static int ibmveth_open(struct net_devic
 		return -ENOMEM;
 	}
 
-	ibmveth_debug_printk("initial replenish cycle\n");
+	netdev_dbg(netdev, "initial replenish cycle\n");
 	ibmveth_interrupt(netdev->irq, netdev);
 
 	netif_start_queue(netdev);
 
-	ibmveth_debug_printk("open complete\n");
+	netdev_dbg(netdev, "open complete\n");
 
 	return 0;
 }
@@ -684,7 +680,7 @@ static int ibmveth_close(struct net_devi
 	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	long lpar_rc;
 
-	ibmveth_debug_printk("close starting\n");
+	netdev_dbg(netdev, "close starting\n");
 
 	napi_disable(&adapter->napi);
 
@@ -709,7 +705,7 @@ static int ibmveth_close(struct net_devi
 
 	ibmveth_cleanup(adapter);
 
-	ibmveth_debug_printk("close complete\n");
+	netdev_dbg(netdev, "close complete\n");
 
 	return 0;
 }
@@ -1109,7 +1105,7 @@ static int ibmveth_poll(struct napi_stru
 		if (!ibmveth_rxq_buffer_valid(adapter)) {
 			wmb(); /* suggested by larson1 */
 			adapter->rx_invalid_buffer++;
-			ibmveth_debug_printk("recycling invalid buffer\n");
+			netdev_dbg(netdev, "recycling invalid buffer\n");
 			ibmveth_rxq_recycle_buffer(adapter);
 		} else {
 			struct sk_buff *skb, *new_skb;
@@ -1359,8 +1355,8 @@ static int __devinit ibmveth_probe(struc
 	unsigned int *mcastFilterSize_p;
 
 
-	ibmveth_debug_printk_no_adapter("entering ibmveth_probe for UA 0x%x\n",
-					dev->unit_address);
+	dev_dbg(&dev->dev, "entering ibmveth_probe for UA 0x%x\n",
+		dev->unit_address);
 
 	mac_addr_p = (unsigned char *) vio_get_attribute(dev,
 						VETH_MAC_ADDR, NULL);
@@ -1429,25 +1425,25 @@ static int __devinit ibmveth_probe(struc
 			kobject_uevent(kobj, KOBJ_ADD);
 	}
 
-	ibmveth_debug_printk("adapter @ 0x%p\n", adapter);
+	netdev_dbg(netdev, "adapter @ 0x%p\n", adapter);
 
 	adapter->buffer_list_dma = DMA_ERROR_CODE;
 	adapter->filter_list_dma = DMA_ERROR_CODE;
 	adapter->rx_queue.queue_dma = DMA_ERROR_CODE;
 
-	ibmveth_debug_printk("registering netdev...\n");
+	netdev_dbg(netdev, "registering netdev...\n");
 
 	ibmveth_set_csum_offload(netdev, 1, ibmveth_set_tx_csum_flags);
 
 	rc = register_netdev(netdev);
 
 	if(rc) {
-		ibmveth_debug_printk("failed to register netdev rc=%d\n", rc);
+		netdev_dbg(netdev, "failed to register netdev rc=%d\n", rc);
 		free_netdev(netdev);
 		return rc;
 	}
 
-	ibmveth_debug_printk("registered\n");
+	netdev_dbg(netdev, "registered\n");
 
 	return 0;
 }
