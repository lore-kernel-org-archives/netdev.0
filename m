From: Santiago Leon <santil@us.ibm.com>
Subject: [PATCH] ibmveth change buffer pools dynamically
Date: Tue, 25 Apr 2006 11:19:59 -0500
Message-ID: <1145981998.16266.5.camel@santilt>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-fxFNYytfLwB/+/dCwu0G"
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:21165 "EHLO
	e32.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751573AbWDYQVE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Apr 2006 12:21:04 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k3PGL3nF006804
	for <netdev@vger.kernel.org>; Tue, 25 Apr 2006 12:21:03 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3PGHGs4233180
	for <netdev@vger.kernel.org>; Tue, 25 Apr 2006 10:17:16 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k3PGL2TH029937
	for <netdev@vger.kernel.org>; Tue, 25 Apr 2006 10:21:02 -0600
To: jgarzik@pobox.com, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-fxFNYytfLwB/+/dCwu0G
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This patch provides a sysfs interface to change some properties of the
ibmveth buffer pools (size of the buffers, number of buffers per pool,
and whether a pool is active).  Ethernet drivers use ethtool to provide
this type of functionality.  However, the buffers in the ibmveth driver
can have an arbitrary size (not only regular, mini, and jumbo which are
the only sizes that ethtool can change), and also ibmveth can have an
arbitrary number of buffer pools 

Under heavy load we have seen dropped packets which obviously kills TCP
performance.  We have created several fixes that mitigate this issue,
but we definitely need a way of changing the number of buffers for an
adapter dynamically.  Also, changing the size of the buffers allows
users to change the MTU to something big (bigger than a jumbo frame)
greatly improving performance on partition to partition transfers.

The patch creates directories pool1...pool4 in the device directory in
sysfs, each with files: num, size, and active (which default to the
values in the mainline version).

Comments and suggestions are welcome...
-- 
Santiago A. Leon
Power Linux Development
IBM Linux Technology Center

--=-fxFNYytfLwB/+/dCwu0G
Content-Disposition: attachment; filename=ibmveth_flexbuff_ml.patch
Content-Type: text/x-patch; name=ibmveth_flexbuff_ml.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- a/drivers/net/ibmveth.h	2006-01-02 21:21:10.000000000 -0600
+++ b/drivers/net/ibmveth.h	2006-04-18 10:20:00.102520432 -0500
@@ -75,10 +75,13 @@
 
 #define IbmVethNumBufferPools 5
 #define IBMVETH_BUFF_OH 22 /* Overhead: 14 ethernet header + 8 opaque handle */
+#define IBMVETH_MAX_MTU 68
+#define IBMVETH_MAX_POOL_COUNT 4096
+#define IBMVETH_MAX_BUF_SIZE (1024 * 128)
 
-/* pool_size should be sorted */
 static int pool_size[] = { 512, 1024 * 2, 1024 * 16, 1024 * 32, 1024 * 64 };
 static int pool_count[] = { 256, 768, 256, 256, 256 };
+static int pool_active[] = { 1, 1, 0, 0, 0};
 
 #define IBM_VETH_INVALID_MAP ((u16)0xffff)
 
@@ -94,6 +97,7 @@ struct ibmveth_buff_pool {
     dma_addr_t *dma_addr;
     struct sk_buff **skbuff;
     int active;
+    struct kobject kobj;
 };
 
 struct ibmveth_rx_q {
@@ -118,6 +122,7 @@ struct ibmveth_adapter {
     dma_addr_t filter_list_dma;
     struct ibmveth_buff_pool rx_buff_pool[IbmVethNumBufferPools];
     struct ibmveth_rx_q rx_queue;
+    int pool_config;
 
     /* adapter specific stats */
     u64 replenish_task_cycles;
--- a/drivers/net/ibmveth.c	2006-01-02 21:21:10.000000000 -0600
+++ b/drivers/net/ibmveth.c	2006-04-18 10:19:55.624532480 -0500
@@ -96,6 +96,7 @@ static void ibmveth_proc_register_adapte
 static void ibmveth_proc_unregister_adapter(struct ibmveth_adapter *adapter);
 static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance, struct pt_regs *regs);
 static inline void ibmveth_rxq_harvest_buffer(struct ibmveth_adapter *adapter);
+static struct kobj_type ktype_veth_pool;
 
 #ifdef CONFIG_PROC_FS
 #define IBMVETH_PROC_DIR "net/ibmveth"
@@ -133,12 +134,13 @@ static inline int ibmveth_rxq_frame_leng
 }
 
 /* setup the initial settings for a buffer pool */
-static void ibmveth_init_buffer_pool(struct ibmveth_buff_pool *pool, u32 pool_index, u32 pool_size, u32 buff_size)
+static void ibmveth_init_buffer_pool(struct ibmveth_buff_pool *pool, u32 pool_index, u32 pool_size, u32 buff_size, u32 pool_active)
 {
 	pool->size = pool_size;
 	pool->index = pool_index;
 	pool->buff_size = buff_size;
 	pool->threshold = pool_size / 2;
+	pool->active = pool_active;
 }
 
 /* allocate and setup an buffer pool - called during open */
@@ -180,7 +182,6 @@ static int ibmveth_alloc_buffer_pool(str
 	atomic_set(&pool->available, 0);
 	pool->producer_index = 0;
 	pool->consumer_index = 0;
-	pool->active = 0;
 
 	return 0;
 }
@@ -301,7 +302,6 @@ static void ibmveth_free_buffer_pool(str
 		kfree(pool->skbuff);
 		pool->skbuff = NULL;
 	}
-	pool->active = 0;
 }
 
 /* remove a buffer from a pool */
@@ -433,7 +433,9 @@ static void ibmveth_cleanup(struct ibmve
 	}
 
 	for(i = 0; i<IbmVethNumBufferPools; i++)
-		ibmveth_free_buffer_pool(adapter, &adapter->rx_buff_pool[i]);
+		if (adapter->rx_buff_pool[i].active)
+			ibmveth_free_buffer_pool(adapter, 
+						 &adapter->rx_buff_pool[i]);
 }
 
 static int ibmveth_open(struct net_device *netdev)
@@ -489,9 +491,6 @@ static int ibmveth_open(struct net_devic
 	adapter->rx_queue.num_slots = rxq_entries;
 	adapter->rx_queue.toggle = 1;
 
-	/* call change_mtu to init the buffer pools based in initial mtu */
-	ibmveth_change_mtu(netdev, netdev->mtu);
-
 	memcpy(&mac_address, netdev->dev_addr, netdev->addr_len);
 	mac_address = mac_address >> 16;
 
@@ -522,6 +521,17 @@ static int ibmveth_open(struct net_devic
 		return -ENONET; 
 	}
 
+	for(i = 0; i<IbmVethNumBufferPools; i++) {
+		if(!adapter->rx_buff_pool[i].active)
+			continue;
+		if (ibmveth_alloc_buffer_pool(&adapter->rx_buff_pool[i])) {
+			ibmveth_error_printk("unable to alloc pool\n");
+			adapter->rx_buff_pool[i].active = 0;
+			ibmveth_cleanup(adapter);
+			return -ENOMEM ;
+		}
+	}
+
 	ibmveth_debug_printk("registering irq 0x%x\n", netdev->irq);
 	if((rc = request_irq(netdev->irq, &ibmveth_interrupt, 0, netdev->name, netdev)) != 0) {
 		ibmveth_error_printk("unable to request irq 0x%x, rc %d\n", netdev->irq, rc);
@@ -550,7 +560,8 @@ static int ibmveth_close(struct net_devi
     
 	ibmveth_debug_printk("close starting\n");
 
-	netif_stop_queue(netdev);
+	if (!adapter->pool_config)
+		netif_stop_queue(netdev);
 
 	free_irq(netdev->irq, netdev);
 
@@ -876,46 +887,22 @@ static void ibmveth_set_multicast_list(s
 static int ibmveth_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct ibmveth_adapter *adapter = dev->priv;
+	int new_mtu_oh = new_mtu + IBMVETH_BUFF_OH;
 	int i;
-	int prev_smaller = 1;
 
-	if ((new_mtu < 68) || 
-	    (new_mtu > (pool_size[IbmVethNumBufferPools-1]) - IBMVETH_BUFF_OH))
+	if (new_mtu < IBMVETH_MAX_MTU)
 		return -EINVAL;
 
+	/* Look for an active buffer pool that can hold the new MTU */
 	for(i = 0; i<IbmVethNumBufferPools; i++) {
-		int activate = 0;
-		if (new_mtu > (pool_size[i]  - IBMVETH_BUFF_OH)) { 
-			activate = 1;
-			prev_smaller= 1;
-		} else {
-			if (prev_smaller)
-				activate = 1;
-			prev_smaller= 0;
-		}
-
-		if (activate && !adapter->rx_buff_pool[i].active) {
-			struct ibmveth_buff_pool *pool = 
-						&adapter->rx_buff_pool[i];
-			if(ibmveth_alloc_buffer_pool(pool)) {
-				ibmveth_error_printk("unable to alloc pool\n");
-				return -ENOMEM;
-			}
-			adapter->rx_buff_pool[i].active = 1;
-		} else if (!activate && adapter->rx_buff_pool[i].active) {
-			adapter->rx_buff_pool[i].active = 0;
-			h_free_logical_lan_buffer(adapter->vdev->unit_address,
-					  (u64)pool_size[i]);
+		if (!adapter->rx_buff_pool[i].active)
+			continue;
+		if (new_mtu_oh < adapter->rx_buff_pool[i].buff_size) {
+			dev->mtu = new_mtu;
+			return 0;
 		}
-
 	}
-
-	/* kick the interrupt handler so that the new buffer pools get
-	   replenished or deallocated */
-	ibmveth_interrupt(dev->irq, dev, NULL);
-
-	dev->mtu = new_mtu;
-	return 0;	
+	return -EINVAL;
 }
 
 static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
@@ -960,6 +947,7 @@ static int __devinit ibmveth_probe(struc
 	adapter->vdev = dev;
 	adapter->netdev = netdev;
 	adapter->mcastFilterSize= *mcastFilterSize_p;
+	adapter->pool_config = 0;
 	
 	/* 	Some older boxes running PHYP non-natively have an OF that
 		returns a 8-byte local-mac-address field (and the first 
@@ -994,9 +982,16 @@ static int __devinit ibmveth_probe(struc
 
 	memcpy(&netdev->dev_addr, &adapter->mac_addr, netdev->addr_len);
 
-	for(i = 0; i<IbmVethNumBufferPools; i++)
+	for(i = 0; i<IbmVethNumBufferPools; i++) {
+		struct kobject *kobj = &adapter->rx_buff_pool[i].kobj;
 		ibmveth_init_buffer_pool(&adapter->rx_buff_pool[i], i, 
-					 pool_count[i], pool_size[i]);
+					 pool_count[i], pool_size[i], 
+					 pool_active[i]);
+		kobj->parent = &dev->dev.kobj;
+		sprintf(kobj->name, "pool%d", i);
+		kobj->ktype = &ktype_veth_pool;
+		kobject_register(kobj);
+	}
 
 	ibmveth_debug_printk("adapter @ 0x%p\n", adapter);
 
@@ -1025,6 +1020,10 @@ static int __devexit ibmveth_remove(stru
 {
 	struct net_device *netdev = dev->dev.driver_data;
 	struct ibmveth_adapter *adapter = netdev->priv;
+	int i;
+
+	for(i = 0; i<IbmVethNumBufferPools; i++)
+		kobject_unregister(&adapter->rx_buff_pool[i].kobj);
 
 	unregister_netdev(netdev);
 
@@ -1169,6 +1168,132 @@ static void ibmveth_proc_unregister_driv
 }
 #endif /* CONFIG_PROC_FS */
 
+static struct attribute veth_active_attr;
+static struct attribute veth_num_attr;
+static struct attribute veth_size_attr;
+
+static ssize_t veth_pool_show(struct kobject * kobj,
+                              struct attribute * attr, char * buf)
+{
+	struct ibmveth_buff_pool *pool = container_of(kobj, 
+						      struct ibmveth_buff_pool,
+						      kobj);
+
+	if (attr == &veth_active_attr)
+		return sprintf(buf, "%d\n", pool->active);
+	else if (attr == &veth_num_attr)
+		return sprintf(buf, "%d\n", pool->size);
+	else if (attr == &veth_size_attr)
+		return sprintf(buf, "%d\n", pool->buff_size);
+	return 0;
+}
+
+static ssize_t veth_pool_store(struct kobject * kobj, struct attribute * attr,
+const char * buf, size_t count)
+{
+	struct ibmveth_buff_pool *pool = container_of(kobj, 
+						      struct ibmveth_buff_pool,
+						      kobj);
+	struct net_device *netdev = 
+	    container_of(kobj->parent, struct device, kobj)->driver_data;
+	struct ibmveth_adapter *adapter = netdev->priv;
+	long value = simple_strtol(buf, NULL, 10);
+	long rc;
+
+	if (attr == &veth_active_attr) {
+		if (value && !pool->active) {
+			if(ibmveth_alloc_buffer_pool(pool)) {
+                                ibmveth_error_printk("unable to alloc pool\n");
+                                return -ENOMEM;
+                        }
+			pool->active = 1;
+			adapter->pool_config = 1;
+			ibmveth_close(netdev);
+			adapter->pool_config = 0;
+			if ((rc = ibmveth_open(netdev)))
+				return rc;
+		} else if (!value && pool->active) {
+			int mtu = netdev->mtu + IBMVETH_BUFF_OH;
+			int i;
+			/* Make sure there is a buffer pool with buffers that
+			   can hold a packet of the size of the MTU */
+			for(i = 0; i<IbmVethNumBufferPools; i++) {
+				if (pool == &adapter->rx_buff_pool[i])
+					continue;
+				if (!adapter->rx_buff_pool[i].active)
+					continue;
+				if (mtu < adapter->rx_buff_pool[i].buff_size) {
+					pool->active = 0;
+					h_free_logical_lan_buffer(adapter->
+								  vdev->
+								  unit_address,
+								  pool->
+								  buff_size);
+				}
+			}
+			if (pool->active) {
+				ibmveth_error_printk("no active pool >= MTU\n");
+				return -EPERM;
+			}
+		}
+	} else if (attr == &veth_num_attr) {
+		if (value <= 0 || value > IBMVETH_MAX_POOL_COUNT)
+			return -EINVAL;
+		else {
+			adapter->pool_config = 1;
+			ibmveth_close(netdev);
+			adapter->pool_config = 0;
+			pool->size = value;
+			if ((rc = ibmveth_open(netdev)))
+				return rc;
+		}
+	} else if (attr == &veth_size_attr) {
+		if (value <= IBMVETH_BUFF_OH || value > IBMVETH_MAX_BUF_SIZE)
+			return -EINVAL;
+		else {
+			adapter->pool_config = 1;
+			ibmveth_close(netdev);
+			adapter->pool_config = 0;
+			pool->buff_size = value;
+			if ((rc = ibmveth_open(netdev)))
+				return rc;
+		}
+	}
+
+	/* kick the interrupt handler to allocate/deallocate pools */
+	ibmveth_interrupt(netdev->irq, netdev, NULL);
+	return count;
+}
+
+
+#define ATTR(_name, _mode)      \
+        struct attribute veth_##_name##_attr = {               \
+        .name = __stringify(_name), .mode = _mode, .owner = THIS_MODULE \
+        };
+
+static ATTR(active, 0644);
+static ATTR(num, 0644);
+static ATTR(size, 0644);
+
+static struct attribute * veth_pool_attrs[] = {
+	&veth_active_attr,
+	&veth_num_attr,
+	&veth_size_attr,
+	NULL,
+};
+
+static struct sysfs_ops veth_pool_ops = {
+	.show   = veth_pool_show,
+	.store  = veth_pool_store,
+};
+
+static struct kobj_type ktype_veth_pool = {
+	.release        = NULL,
+	.sysfs_ops      = &veth_pool_ops,
+	.default_attrs  = veth_pool_attrs,
+};
+
+
 static struct vio_device_id ibmveth_device_table[] __devinitdata= {
 	{ "network", "IBM,l-lan"},
 	{ "", "" }

--=-fxFNYytfLwB/+/dCwu0G--

