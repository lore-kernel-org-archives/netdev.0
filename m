From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 15/21] ibmveth: Convert driver specific error functions to netdev_err
Date: Fri, 03 Sep 2010 23:29:19 -0500
Message-ID: <20100904042919.2655.12105.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:41755 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753750Ab0IDE3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 00:29:48 -0400
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844RlX7004340
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:27:47 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o844TlVv131672
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:29:47 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844Tlu2002000
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:29:47 -0600
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netdev_err to standardise the error output.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:19:14.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:19:15.000000000 -0500
@@ -57,12 +57,6 @@
 
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
@@ -558,7 +552,8 @@ static int ibmveth_open(struct net_devic
 	adapter->filter_list_addr = (void*) get_zeroed_page(GFP_KERNEL);
 
 	if(!adapter->buffer_list_addr || !adapter->filter_list_addr) {
-		ibmveth_error_printk("unable to allocate filter or buffer list pages\n");
+		netdev_err(netdev, "unable to allocate filter or buffer list "
+			   "pages\n");
 		ibmveth_cleanup(adapter);
 		napi_disable(&adapter->napi);
 		return -ENOMEM;
@@ -568,7 +563,7 @@ static int ibmveth_open(struct net_devic
 	adapter->rx_queue.queue_addr = kmalloc(adapter->rx_queue.queue_len, GFP_KERNEL);
 
 	if(!adapter->rx_queue.queue_addr) {
-		ibmveth_error_printk("unable to allocate rx queue pages\n");
+		netdev_err(netdev, "unable to allocate rx queue pages\n");
 		ibmveth_cleanup(adapter);
 		napi_disable(&adapter->napi);
 		return -ENOMEM;
@@ -587,7 +582,8 @@ static int ibmveth_open(struct net_devic
 	if ((dma_mapping_error(dev, adapter->buffer_list_dma)) ||
 	    (dma_mapping_error(dev, adapter->filter_list_dma)) ||
 	    (dma_mapping_error(dev, adapter->rx_queue.queue_dma))) {
-		ibmveth_error_printk("unable to map filter or buffer list pages\n");
+		netdev_err(netdev, "unable to map filter or buffer list "
+			   "pages\n");
 		ibmveth_cleanup(adapter);
 		napi_disable(&adapter->napi);
 		return -ENOMEM;
@@ -612,8 +608,10 @@ static int ibmveth_open(struct net_devic
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
@@ -627,7 +625,7 @@ static int ibmveth_open(struct net_devic
 		if(!adapter->rx_buff_pool[i].active)
 			continue;
 		if (ibmveth_alloc_buffer_pool(&adapter->rx_buff_pool[i])) {
-			ibmveth_error_printk("unable to alloc pool\n");
+			netdev_err(netdev, "unable to alloc pool\n");
 			adapter->rx_buff_pool[i].active = 0;
 			ibmveth_cleanup(adapter);
 			napi_disable(&adapter->napi);
@@ -637,7 +635,8 @@ static int ibmveth_open(struct net_devic
 
 	netdev_dbg(netdev, "registering irq 0x%x\n", netdev->irq);
 	if((rc = request_irq(netdev->irq, ibmveth_interrupt, 0, netdev->name, netdev)) != 0) {
-		ibmveth_error_printk("unable to request irq 0x%x, rc %d\n", netdev->irq, rc);
+		netdev_err(netdev, "unable to request irq 0x%x, rc %d\n",
+			   netdev->irq, rc);
 		do {
 			rc = h_free_logical_lan(adapter->vdev->unit_address);
 		} while (H_IS_LONG_BUSY(rc) || (rc == H_BUSY));
@@ -650,7 +649,7 @@ static int ibmveth_open(struct net_devic
 	adapter->bounce_buffer =
 	    kmalloc(netdev->mtu + IBMVETH_BUFF_OH, GFP_KERNEL);
 	if (!adapter->bounce_buffer) {
-		ibmveth_error_printk("unable to allocate bounce buffer\n");
+		netdev_err(netdev, "unable to allocate bounce buffer\n");
 		ibmveth_cleanup(adapter);
 		napi_disable(&adapter->napi);
 		return -ENOMEM;
@@ -659,7 +658,7 @@ static int ibmveth_open(struct net_devic
 	    dma_map_single(&adapter->vdev->dev, adapter->bounce_buffer,
 			   netdev->mtu + IBMVETH_BUFF_OH, DMA_BIDIRECTIONAL);
 	if (dma_mapping_error(dev, adapter->bounce_buffer_dma)) {
-		ibmveth_error_printk("unable to map bounce buffer\n");
+		netdev_err(netdev, "unable to map bounce buffer\n");
 		ibmveth_cleanup(adapter);
 		napi_disable(&adapter->napi);
 		return -ENOMEM;
@@ -695,8 +694,8 @@ static int ibmveth_close(struct net_devi
 
 	if(lpar_rc != H_SUCCESS)
 	{
-		ibmveth_error_printk("h_free_logical_lan failed with %lx, continuing with close\n",
-				     lpar_rc);
+		netdev_err(netdev, "h_free_logical_lan failed with %lx, "
+			   "continuing with close\n", lpar_rc);
 	}
 
 	free_irq(netdev->irq, netdev);
@@ -806,9 +805,9 @@ static int ibmveth_set_csum_offload(stru
 					 set_attr, &ret_attr);
 
 		if (ret != H_SUCCESS) {
-			ibmveth_error_printk("unable to change IPv4 checksum "
-					     "offload settings. %d rc=%ld\n",
-					     data, ret);
+			netdev_err(dev, "unable to change IPv4 checksum "
+					"offload settings. %d rc=%ld\n",
+					data, ret);
 
 			ret = h_illan_attributes(adapter->vdev->unit_address,
 						 set_attr, clr_attr, &ret_attr);
@@ -819,9 +818,9 @@ static int ibmveth_set_csum_offload(stru
 					 clr_attr6, set_attr6, &ret_attr);
 
 		if (ret6 != H_SUCCESS) {
-			ibmveth_error_printk("unable to change IPv6 checksum "
-					     "offload settings. %d rc=%ld\n",
-					     data, ret);
+			netdev_err(dev, "unable to change IPv6 checksum "
+					"offload settings. %d rc=%ld\n",
+					data, ret);
 
 			ret = h_illan_attributes(adapter->vdev->unit_address,
 						 set_attr6, clr_attr6,
@@ -835,8 +834,9 @@ static int ibmveth_set_csum_offload(stru
 			rc1 = -EIO;
 	} else {
 		rc1 = -EIO;
-		ibmveth_error_printk("unable to change checksum offload settings."
-				     " %d rc=%ld ret_attr=%lx\n", data, ret, ret_attr);
+		netdev_err(dev, "unable to change checksum offload settings."
+				     " %d rc=%ld ret_attr=%lx\n", data, ret,
+				     ret_attr);
 	}
 
 	if (restart)
@@ -952,8 +952,8 @@ static int ibmveth_send(struct ibmveth_a
 	} while ((ret == H_BUSY) && (retry_count--));
 
 	if (ret != H_SUCCESS && ret != H_DROPPED) {
-		ibmveth_error_printk("tx: h_send_logical_lan failed with "
-				     "rc=%ld\n", ret);
+		netdev_err(adapter->netdev, "tx: h_send_logical_lan failed "
+			   "with rc=%ld\n", ret);
 		return 1;
 	}
 
@@ -986,7 +986,7 @@ static netdev_tx_t ibmveth_start_xmit(st
 	      ipv6_hdr(skb)->nexthdr != IPPROTO_TCP)) &&
 	    skb_checksum_help(skb)) {
 
-		ibmveth_error_printk("tx: failed to checksum packet\n");
+		netdev_err(netdev, "tx: failed to checksum packet\n");
 		netdev->stats.tx_dropped++;
 		goto out;
 	}
@@ -1082,7 +1082,7 @@ map_failed_frags:
 
 map_failed:
 	if (!firmware_has_feature(FW_FEATURE_CMO))
-		ibmveth_error_printk("tx: unable to map xmit buffer\n");
+		netdev_err(netdev, "tx: unable to map xmit buffer\n");
 	adapter->tx_map_failed++;
 	skb_linearize(skb);
 	force_bounce = 1;
@@ -1198,7 +1198,8 @@ static void ibmveth_set_multicast_list(s
 					   IbmVethMcastDisableFiltering,
 					   0);
 		if(lpar_rc != H_SUCCESS) {
-			ibmveth_error_printk("h_multicast_ctrl rc=%ld when entering promisc mode\n", lpar_rc);
+			netdev_err(netdev, "h_multicast_ctrl rc=%ld when "
+				   "entering promisc mode\n", lpar_rc);
 		}
 	} else {
 		struct netdev_hw_addr *ha;
@@ -1209,7 +1210,9 @@ static void ibmveth_set_multicast_list(s
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
@@ -1220,7 +1223,9 @@ static void ibmveth_set_multicast_list(s
 						   IbmVethMcastAddFilter,
 						   mcast_addr);
 			if(lpar_rc != H_SUCCESS) {
-				ibmveth_error_printk("h_multicast_ctrl rc=%ld when adding an entry to the filter table\n", lpar_rc);
+				netdev_err(netdev, "h_multicast_ctrl rc=%ld "
+					   "when adding an entry to the filter "
+					   "table\n", lpar_rc);
 			}
 		}
 
@@ -1229,7 +1234,8 @@ static void ibmveth_set_multicast_list(s
 					   IbmVethMcastEnableFiltering,
 					   0);
 		if(lpar_rc != H_SUCCESS) {
-			ibmveth_error_printk("h_multicast_ctrl rc=%ld when enabling filtering\n", lpar_rc);
+			netdev_err(netdev, "h_multicast_ctrl rc=%ld when "
+				   "enabling filtering\n", lpar_rc);
 		}
 	}
 }
@@ -1361,17 +1367,15 @@ static int __devinit ibmveth_probe(struc
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
 
@@ -1501,7 +1505,8 @@ const char * buf, size_t count)
 		if (value && !pool->active) {
 			if (netif_running(netdev)) {
 				if(ibmveth_alloc_buffer_pool(pool)) {
-					ibmveth_error_printk("unable to alloc pool\n");
+					netdev_err(netdev,
+						   "unable to alloc pool\n");
 					return -ENOMEM;
 				}
 				pool->active = 1;
@@ -1527,7 +1532,7 @@ const char * buf, size_t count)
 			}
 
 			if (i == IbmVethNumBufferPools) {
-				ibmveth_error_printk("no active pool >= MTU\n");
+				netdev_err(netdev, "no active pool >= MTU\n");
 				return -EPERM;
 			}
 
@@ -1635,7 +1640,8 @@ static struct vio_driver ibmveth_driver
 
 static int __init ibmveth_module_init(void)
 {
-	ibmveth_printk("%s: %s %s\n", ibmveth_driver_name, ibmveth_driver_string, ibmveth_driver_version);
+	printk(KERN_DEBUG "%s: %s %s\n", ibmveth_driver_name,
+	       ibmveth_driver_string, ibmveth_driver_version);
 
 	return vio_register_driver(&ibmveth_driver);
 }
