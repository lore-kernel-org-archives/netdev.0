From: Anton Blanchard <anton@samba.org>
Subject: [patch 14/20] ibmveth: Convert driver specific error functions to netdev_err
Date: Mon, 23 Aug 2010 10:09:44 +1000
Message-ID: <20100823001239.609670975@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51861 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751324Ab0HWA3N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:29:13 -0400
Content-Disposition: inline; filename=veth_netdev_printk
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_err to standardise the error output.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 08:52:32.953565532 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 08:52:33.000000000 +1000
@@ -56,12 +56,6 @@
 
 #undef DEBUG
 
-#define ibmveth_printk(fmt, args...) \
-  printk(KERN_DEBUG "%s: " fmt, __FILE__, ## args)
-
-#define ibmveth_error_printk(fmt, args...) \
-  printk(KERN_ERR "(%s:%3.3d ua:%x) ERROR: " fmt, __FILE__, __LINE__ , adapter->vdev->unit_address, ## args)
-
 #ifdef DEBUG
 #define ibmveth_assert(expr) \
   if(!(expr)) {                                   \
@@ -555,7 +549,8 @@ static int ibmveth_open(struct net_devic
 	adapter->filter_list_addr = kzalloc(4096, GFP_KERNEL);
 
 	if(!adapter->buffer_list_addr || !adapter->filter_list_addr) {
-		ibmveth_error_printk("unable to allocate filter or buffer list pages\n");
+		netdev_err(netdev, "unable to allocate filter or buffer list "
+			   "pages\n");
 		ibmveth_cleanup(adapter);
 		napi_disable(&adapter->napi);
 		return -ENOMEM;
@@ -565,7 +560,7 @@ static int ibmveth_open(struct net_devic
 	adapter->rx_queue.queue_addr = kmalloc(adapter->rx_queue.queue_len, GFP_KERNEL);
 
 	if(!adapter->rx_queue.queue_addr) {
-		ibmveth_error_printk("unable to allocate rx queue pages\n");
+		netdev_err(netdev, "unable to allocate rx queue pages\n");
 		ibmveth_cleanup(adapter);
 		napi_disable(&adapter->napi);
 		return -ENOMEM;
@@ -584,7 +579,8 @@ static int ibmveth_open(struct net_devic
 	if ((dma_mapping_error(dev, adapter->buffer_list_dma)) ||
 	    (dma_mapping_error(dev, adapter->filter_list_dma)) ||
 	    (dma_mapping_error(dev, adapter->rx_queue.queue_dma))) {
-		ibmveth_error_printk("unable to map filter or buffer list pages\n");
+		netdev_err(netdev, "unable to map filter or buffer list "
+			   "pages\n");
 		ibmveth_cleanup(adapter);
 		napi_disable(&adapter->napi);
 		return -ENOMEM;
@@ -609,8 +605,10 @@ static int ibmveth_open(struct net_devic
 	lpar_rc = ibmveth_register_logical_lan(adapter, rxq_desc, mac_address);
 
 	if(lpar_rc != H_SUCCESS) {
-		ibmveth_error_printk("h_register_logical_lan failed with %ld\n", lpar_rc);
-		ibmveth_error_printk("buffer TCE:0x%llx filter TCE:0x%llx rxq desc:0x%llx MAC:0x%llx\n",
+		netdev_err(netdev, "h_register_logical_lan failed with %ld\n",
+			   lpar_rc);
+		netdev_err(netdev, "buffer TCE:0x%llx filter TCE:0x%llx rxq "
+			   "desc:0x%llx MAC:0x%llx\n",
 				     adapter->buffer_list_dma,
 				     adapter->filter_list_dma,
 				     rxq_desc.desc,
@@ -624,7 +622,7 @@ static int ibmveth_open(struct net_devic
 		if(!adapter->rx_buff_pool[i].active)
 			continue;
 		if (ibmveth_alloc_buffer_pool(&adapter->rx_buff_pool[i])) {
-			ibmveth_error_printk("unable to alloc pool\n");
+			netdev_err(netdev, "unable to alloc pool\n");
 			adapter->rx_buff_pool[i].active = 0;
 			ibmveth_cleanup(adapter);
 			napi_disable(&adapter->napi);
@@ -634,7 +632,8 @@ static int ibmveth_open(struct net_devic
 
 	netdev_dbg(netdev, "registering irq 0x%x\n", netdev->irq);
 	if((rc = request_irq(netdev->irq, ibmveth_interrupt, 0, netdev->name, netdev)) != 0) {
-		ibmveth_error_printk("unable to request irq 0x%x, rc %d\n", netdev->irq, rc);
+		netdev_err(netdev, "unable to request irq 0x%x, rc %d\n",
+			   netdev->irq, rc);
 		do {
 			rc = h_free_logical_lan(adapter->vdev->unit_address);
 		} while (H_IS_LONG_BUSY(rc) || (rc == H_BUSY));
@@ -647,7 +646,7 @@ static int ibmveth_open(struct net_devic
 	adapter->bounce_buffer =
 	    kmalloc(netdev->mtu + IBMVETH_BUFF_OH, GFP_KERNEL);
 	if (!adapter->bounce_buffer) {
-		ibmveth_error_printk("unable to allocate bounce buffer\n");
+		netdev_err(netdev, "unable to allocate bounce buffer\n");
 		ibmveth_cleanup(adapter);
 		napi_disable(&adapter->napi);
 		return -ENOMEM;
@@ -656,7 +655,7 @@ static int ibmveth_open(struct net_devic
 	    dma_map_single(&adapter->vdev->dev, adapter->bounce_buffer,
 			   netdev->mtu + IBMVETH_BUFF_OH, DMA_BIDIRECTIONAL);
 	if (dma_mapping_error(dev, adapter->bounce_buffer_dma)) {
-		ibmveth_error_printk("unable to map bounce buffer\n");
+		netdev_err(netdev, "unable to map bounce buffer\n");
 		ibmveth_cleanup(adapter);
 		napi_disable(&adapter->napi);
 		return -ENOMEM;
@@ -692,8 +691,8 @@ static int ibmveth_close(struct net_devi
 
 	if(lpar_rc != H_SUCCESS)
 	{
-		ibmveth_error_printk("h_free_logical_lan failed with %lx, continuing with close\n",
-				     lpar_rc);
+		netdev_err(netdev, "h_free_logical_lan failed with %lx, "
+			   "continuing with close\n", lpar_rc);
 	}
 
 	free_irq(netdev->irq, netdev);
@@ -794,8 +793,8 @@ static int ibmveth_set_csum_offload(stru
 
 		if (ret != H_SUCCESS) {
 			rc1 = -EIO;
-			ibmveth_error_printk("unable to change checksum offload settings."
-					     " %d rc=%ld\n", data, ret);
+			netdev_err(dev, "unable to change checksum offload "
+				   "settings. %d rc=%ld\n", data, ret);
 
 			ret = h_illan_attributes(adapter->vdev->unit_address,
 						 set_attr, clr_attr, &ret_attr);
@@ -803,8 +802,9 @@ static int ibmveth_set_csum_offload(stru
 			done(dev, data);
 	} else {
 		rc1 = -EIO;
-		ibmveth_error_printk("unable to change checksum offload settings."
-				     " %d rc=%ld ret_attr=%lx\n", data, ret, ret_attr);
+		netdev_err(dev, "unable to change checksum offload settings."
+				     " %d rc=%ld ret_attr=%lx\n", data, ret,
+				     ret_attr);
 	}
 
 	if (restart)
@@ -920,8 +920,8 @@ static int ibmveth_send(struct ibmveth_a
 	} while ((ret == H_BUSY) && (retry_count--));
 
 	if (ret != H_SUCCESS && ret != H_DROPPED) {
-		ibmveth_error_printk("tx: h_send_logical_lan failed with "
-				     "rc=%ld\n", ret);
+		netdev_err(adapter->netdev, "tx: h_send_logical_lan failed "
+			   "with rc=%ld\n", ret);
 		return 1;
 	}
 
@@ -949,7 +949,7 @@ static netdev_tx_t ibmveth_start_xmit(st
 	/* veth can't checksum offload UDP */
 	if (skb->ip_summed == CHECKSUM_PARTIAL &&
 	    ip_hdr(skb)->protocol != IPPROTO_TCP && skb_checksum_help(skb)) {
-		ibmveth_error_printk("tx: failed to checksum packet\n");
+		netdev_err(netdev, "tx: failed to checksum packet\n");
 		netdev->stats.tx_dropped++;
 		goto out;
 	}
@@ -1045,7 +1045,7 @@ map_failed_frags:
 
 map_failed:
 	if (!firmware_has_feature(FW_FEATURE_CMO))
-		ibmveth_error_printk("tx: unable to map xmit buffer\n");
+		netdev_err(netdev, "tx: unable to map xmit buffer\n");
 	adapter->tx_map_failed++;
 	skb_linearize(skb);
 	force_bounce = 1;
@@ -1161,7 +1161,8 @@ static void ibmveth_set_multicast_list(s
 					   IbmVethMcastDisableFiltering,
 					   0);
 		if(lpar_rc != H_SUCCESS) {
-			ibmveth_error_printk("h_multicast_ctrl rc=%ld when entering promisc mode\n", lpar_rc);
+			netdev_err(netdev, "h_multicast_ctrl rc=%ld when "
+				   "entering promisc mode\n", lpar_rc);
 		}
 	} else {
 		struct netdev_hw_addr *ha;
@@ -1172,7 +1173,9 @@ static void ibmveth_set_multicast_list(s
 					   IbmVethMcastClearFilterTable,
 					   0);
 		if(lpar_rc != H_SUCCESS) {
-			ibmveth_error_printk("h_multicast_ctrl rc=%ld when attempting to clear filter table\n", lpar_rc);
+			netdev_err(netdev, "h_multicast_ctrl rc=%ld when "
+				   "attempting to clear filter table\n",
+				   lpar_rc);
 		}
 		/* add the addresses to the filter table */
 		netdev_for_each_mc_addr(ha, netdev) {
@@ -1183,7 +1186,9 @@ static void ibmveth_set_multicast_list(s
 						   IbmVethMcastAddFilter,
 						   mcast_addr);
 			if(lpar_rc != H_SUCCESS) {
-				ibmveth_error_printk("h_multicast_ctrl rc=%ld when adding an entry to the filter table\n", lpar_rc);
+				netdev_err(netdev, "h_multicast_ctrl rc=%ld "
+					   "when adding an entry to the filter "
+					   "table\n", lpar_rc);
 			}
 		}
 
@@ -1192,7 +1197,8 @@ static void ibmveth_set_multicast_list(s
 					   IbmVethMcastEnableFiltering,
 					   0);
 		if(lpar_rc != H_SUCCESS) {
-			ibmveth_error_printk("h_multicast_ctrl rc=%ld when enabling filtering\n", lpar_rc);
+			netdev_err(netdev, "h_multicast_ctrl rc=%ld when "
+				   "enabling filtering\n", lpar_rc);
 		}
 	}
 }
@@ -1326,17 +1332,15 @@ static int __devinit ibmveth_probe(struc
 	mac_addr_p = (unsigned char *) vio_get_attribute(dev,
 						VETH_MAC_ADDR, NULL);
 	if(!mac_addr_p) {
-		printk(KERN_ERR "(%s:%3.3d) ERROR: Can't find VETH_MAC_ADDR "
-				"attribute\n", __FILE__, __LINE__);
+		dev_err(&dev->dev, "Can't find VETH_MAC_ADDR attribute\n");
 		return 0;
 	}
 
 	mcastFilterSize_p = (unsigned int *) vio_get_attribute(dev,
 						VETH_MCAST_FILTER_SIZE, NULL);
 	if(!mcastFilterSize_p) {
-		printk(KERN_ERR "(%s:%3.3d) ERROR: Can't find "
-				"VETH_MCAST_FILTER_SIZE attribute\n",
-				__FILE__, __LINE__);
+		dev_err(&dev->dev, "Can't find VETH_MCAST_FILTER_SIZE "
+			"attribute\n");
 		return 0;
 	}
 
@@ -1480,7 +1484,8 @@ const char * buf, size_t count)
 		if (value && !pool->active) {
 			if (netif_running(netdev)) {
 				if(ibmveth_alloc_buffer_pool(pool)) {
-					ibmveth_error_printk("unable to alloc pool\n");
+					netdev_err(netdev,
+						   "unable to alloc pool\n");
 					return -ENOMEM;
 				}
 				pool->active = 1;
@@ -1506,7 +1511,7 @@ const char * buf, size_t count)
 			}
 
 			if (i == IbmVethNumBufferPools) {
-				ibmveth_error_printk("no active pool >= MTU\n");
+				netdev_err(netdev, "no active pool >= MTU\n");
 				return -EPERM;
 			}
 
@@ -1614,7 +1619,8 @@ static struct vio_driver ibmveth_driver
 
 static int __init ibmveth_module_init(void)
 {
-	ibmveth_printk("%s: %s %s\n", ibmveth_driver_name, ibmveth_driver_string, ibmveth_driver_version);
+	printk(KERN_DEBUG "%s: %s %s\n", ibmveth_driver_name,
+	       ibmveth_driver_string, ibmveth_driver_version);
 
 	return vio_register_driver(&ibmveth_driver);
 }


