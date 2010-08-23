From: Anton Blanchard <anton@samba.org>
Subject: [patch 13/20] ibmveth: Convert driver specific debug to netdev_dbg
Date: Mon, 23 Aug 2010 10:09:43 +1000
Message-ID: <20100823001239.510612310@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51855 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751748Ab0HWA3F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:29:05 -0400
Content-Disposition: inline; filename=veth_netdev_dbg
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_dbg to standardise the debug output.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 08:52:32.523596050 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 08:52:32.953565532 +1000
@@ -63,18 +63,12 @@
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
 
@@ -245,7 +239,8 @@ static void ibmveth_replenish_buffer_poo
 		skb = netdev_alloc_skb(adapter->netdev, pool->buff_size);
 
 		if(!skb) {
-			ibmveth_debug_printk("replenish: unable to allocate skb\n");
+			netdev_dbg(adapter->netdev,
+				   "replenish: unable to allocate skb\n");
 			adapter->replenish_no_mem++;
 			break;
 		}
@@ -437,7 +432,8 @@ static void ibmveth_rxq_recycle_buffer(s
 	lpar_rc = h_add_logical_lan_buffer(adapter->vdev->unit_address, desc.desc);
 
 	if(lpar_rc != H_SUCCESS) {
-		ibmveth_debug_printk("h_add_logical_lan_buffer failed during recycle rc=%ld", lpar_rc);
+		netdev_dbg(adapter->netdev, "h_add_logical_lan_buffer failed "
+			   "during recycle rc=%ld", lpar_rc);
 		ibmveth_remove_buffer_from_pool(adapter, adapter->rx_queue.queue_addr[adapter->rx_queue.index].correlator);
 	}
 
@@ -548,7 +544,7 @@ static int ibmveth_open(struct net_devic
 	int i;
 	struct device *dev;
 
-	ibmveth_debug_printk("open starting\n");
+	netdev_dbg(netdev, "open starting\n");
 
 	napi_enable(&adapter->napi);
 
@@ -604,9 +600,9 @@ static int ibmveth_open(struct net_devic
 	rxq_desc.fields.flags_len = IBMVETH_BUF_VALID | adapter->rx_queue.queue_len;
 	rxq_desc.fields.address = adapter->rx_queue.queue_dma;
 
-	ibmveth_debug_printk("buffer list @ 0x%p\n", adapter->buffer_list_addr);
-	ibmveth_debug_printk("filter list @ 0x%p\n", adapter->filter_list_addr);
-	ibmveth_debug_printk("receive q   @ 0x%p\n", adapter->rx_queue.queue_addr);
+	netdev_dbg(netdev, "buffer list @ 0x%p\n", adapter->buffer_list_addr);
+	netdev_dbg(netdev, "filter list @ 0x%p\n", adapter->filter_list_addr);
+	netdev_dbg(netdev, "receive q   @ 0x%p\n", adapter->rx_queue.queue_addr);
 
 	h_vio_signal(adapter->vdev->unit_address, VIO_IRQ_DISABLE);
 
@@ -636,7 +632,7 @@ static int ibmveth_open(struct net_devic
 		}
 	}
 
-	ibmveth_debug_printk("registering irq 0x%x\n", netdev->irq);
+	netdev_dbg(netdev, "registering irq 0x%x\n", netdev->irq);
 	if((rc = request_irq(netdev->irq, ibmveth_interrupt, 0, netdev->name, netdev)) != 0) {
 		ibmveth_error_printk("unable to request irq 0x%x, rc %d\n", netdev->irq, rc);
 		do {
@@ -666,12 +662,12 @@ static int ibmveth_open(struct net_devic
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
@@ -681,7 +677,7 @@ static int ibmveth_close(struct net_devi
 	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	long lpar_rc;
 
-	ibmveth_debug_printk("close starting\n");
+	netdev_dbg(netdev, "close starting\n");
 
 	napi_disable(&adapter->napi);
 
@@ -706,7 +702,7 @@ static int ibmveth_close(struct net_devi
 
 	ibmveth_cleanup(adapter);
 
-	ibmveth_debug_printk("close complete\n");
+	netdev_dbg(netdev, "close complete\n");
 
 	return 0;
 }
@@ -1072,7 +1068,7 @@ static int ibmveth_poll(struct napi_stru
 		if (!ibmveth_rxq_buffer_valid(adapter)) {
 			wmb(); /* suggested by larson1 */
 			adapter->rx_invalid_buffer++;
-			ibmveth_debug_printk("recycling invalid buffer\n");
+			netdev_dbg(netdev, "recycling invalid buffer\n");
 			ibmveth_rxq_recycle_buffer(adapter);
 		} else {
 			struct sk_buff *skb, *new_skb;
@@ -1324,8 +1320,8 @@ static int __devinit ibmveth_probe(struc
 	unsigned int *mcastFilterSize_p;
 
 
-	ibmveth_debug_printk_no_adapter("entering ibmveth_probe for UA 0x%x\n",
-					dev->unit_address);
+	dev_dbg(&dev->dev, "entering ibmveth_probe for UA 0x%x\n",
+		dev->unit_address);
 
 	mac_addr_p = (unsigned char *) vio_get_attribute(dev,
 						VETH_MAC_ADDR, NULL);
@@ -1394,13 +1390,13 @@ static int __devinit ibmveth_probe(struc
 			kobject_uevent(kobj, KOBJ_ADD);
 	}
 
-	ibmveth_debug_printk("adapter @ 0x%p\n", adapter);
+	netdev_dbg(netdev, "adapter @ 0x%p\n", adapter);
 
 	adapter->buffer_list_dma = DMA_ERROR_CODE;
 	adapter->filter_list_dma = DMA_ERROR_CODE;
 	adapter->rx_queue.queue_dma = DMA_ERROR_CODE;
 
-	ibmveth_debug_printk("registering netdev...\n");
+	netdev_dbg(netdev, "registering netdev...\n");
 
 	ret = h_illan_attributes(dev->unit_address, 0, 0, &ret_attr);
 
@@ -1421,12 +1417,12 @@ static int __devinit ibmveth_probe(struc
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


