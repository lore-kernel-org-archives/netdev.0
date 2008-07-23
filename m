From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: [PATCH 13/16 v4] ibmveth: enable driver for CMO
Date: Wed, 23 Jul 2008 13:34:52 -0500
Message-ID: <20080723183451.GP12905@linux.vnet.ibm.com>
References: <20080723181932.GC12905@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Brian King <brking@linux.vnet.ibm.com>,
	Santiago Leon <santil@us.ibm.com>,
	Nathan Fontenot <nfont@austin.ibm.com>,
	David Darrington <ddarring@linux.vnet.ibm.com>
To: paulus@samba.org, benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:57499 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675AbYGWSe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 14:34:59 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6NIYw8L017181
	for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 14:34:58 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6NIYra6177014
	for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 12:34:53 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6NIYpWD030655
	for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 12:34:53 -0600
Content-Disposition: inline
In-Reply-To: <20080723181932.GC12905@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable ibmveth for Cooperative Memory Overcommitment (CMO).  For this driver
it means calculating a desired amount of IO memory based on the current MTU
and updating this value with the bus when MTU changes occur.  Because DMA
mappings can fail, we have added a bounce buffer for temporary cases where
the driver can not map IO memory for the buffer pool.

The following changes are made to enable the driver for CMO:
 * DMA mapping errors will not result in error messages if entitlement has
   been exceeded and resources were not available.
 * DMA mapping errors are handled gracefully, ibmveth_replenish_buffer_pool()
   is corrected to check the return from dma_map_single and fail gracefully.
 * The driver will have a get_desired_dma function defined to function
   in a CMO environment.
 * When the MTU is changed, the driver will update the device IO entitlement

Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>
Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
Signed-off-by: Santiago Leon <santil@us.ibm.com>

---
We would like to take this patch through linuxppc-dev with the full
change set for this feature.  We are copying netdev for review and ack.

---
 drivers/net/ibmveth.c |  169 ++++++++++++++++++++++++++++++++++++++++----------
 drivers/net/ibmveth.h |    5 +
 2 files changed, 140 insertions(+), 34 deletions(-)

Index: b/drivers/net/ibmveth.c
===================================================================
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -33,6 +33,7 @@
 */
 
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/types.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
@@ -52,7 +53,9 @@
 #include <asm/hvcall.h>
 #include <asm/atomic.h>
 #include <asm/vio.h>
+#include <asm/iommu.h>
 #include <asm/uaccess.h>
+#include <asm/firmware.h>
 #include <linux/seq_file.h>
 
 #include "ibmveth.h"
@@ -94,8 +97,10 @@ static void ibmveth_proc_register_adapte
 static void ibmveth_proc_unregister_adapter(struct ibmveth_adapter *adapter);
 static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance);
 static void ibmveth_rxq_harvest_buffer(struct ibmveth_adapter *adapter);
+static unsigned long ibmveth_get_desired_dma(struct vio_dev *vdev);
 static struct kobj_type ktype_veth_pool;
 
+
 #ifdef CONFIG_PROC_FS
 #define IBMVETH_PROC_DIR "ibmveth"
 static struct proc_dir_entry *ibmveth_proc_dir;
@@ -226,16 +231,16 @@ static void ibmveth_replenish_buffer_poo
 	u32 i;
 	u32 count = pool->size - atomic_read(&pool->available);
 	u32 buffers_added = 0;
+	struct sk_buff *skb;
+	unsigned int free_index, index;
+	u64 correlator;
+	unsigned long lpar_rc;
+	dma_addr_t dma_addr;
 
 	mb();
 
 	for(i = 0; i < count; ++i) {
-		struct sk_buff *skb;
-		unsigned int free_index, index;
-		u64 correlator;
 		union ibmveth_buf_desc desc;
-		unsigned long lpar_rc;
-		dma_addr_t dma_addr;
 
 		skb = alloc_skb(pool->buff_size, GFP_ATOMIC);
 
@@ -255,6 +260,9 @@ static void ibmveth_replenish_buffer_poo
 		dma_addr = dma_map_single(&adapter->vdev->dev, skb->data,
 				pool->buff_size, DMA_FROM_DEVICE);
 
+		if (dma_mapping_error(dma_addr))
+			goto failure;
+
 		pool->free_map[free_index] = IBM_VETH_INVALID_MAP;
 		pool->dma_addr[index] = dma_addr;
 		pool->skbuff[index] = skb;
@@ -267,20 +275,9 @@ static void ibmveth_replenish_buffer_poo
 
 		lpar_rc = h_add_logical_lan_buffer(adapter->vdev->unit_address, desc.desc);
 
-		if(lpar_rc != H_SUCCESS) {
-			pool->free_map[free_index] = index;
-			pool->skbuff[index] = NULL;
-			if (pool->consumer_index == 0)
-				pool->consumer_index = pool->size - 1;
-			else
-				pool->consumer_index--;
-			dma_unmap_single(&adapter->vdev->dev,
-					pool->dma_addr[index], pool->buff_size,
-					DMA_FROM_DEVICE);
-			dev_kfree_skb_any(skb);
-			adapter->replenish_add_buff_failure++;
-			break;
-		} else {
+		if (lpar_rc != H_SUCCESS)
+			goto failure;
+		else {
 			buffers_added++;
 			adapter->replenish_add_buff_success++;
 		}
@@ -288,6 +285,24 @@ static void ibmveth_replenish_buffer_poo
 
 	mb();
 	atomic_add(buffers_added, &(pool->available));
+	return;
+
+failure:
+	pool->free_map[free_index] = index;
+	pool->skbuff[index] = NULL;
+	if (pool->consumer_index == 0)
+		pool->consumer_index = pool->size - 1;
+	else
+		pool->consumer_index--;
+	if (!dma_mapping_error(dma_addr))
+		dma_unmap_single(&adapter->vdev->dev,
+		                 pool->dma_addr[index], pool->buff_size,
+		                 DMA_FROM_DEVICE);
+	dev_kfree_skb_any(skb);
+	adapter->replenish_add_buff_failure++;
+
+	mb();
+	atomic_add(buffers_added, &(pool->available));
 }
 
 /* replenish routine */
@@ -297,7 +312,7 @@ static void ibmveth_replenish_task(struc
 
 	adapter->replenish_task_cycles++;
 
-	for(i = 0; i < IbmVethNumBufferPools; i++)
+	for (i = (IbmVethNumBufferPools - 1); i >= 0; i--)
 		if(adapter->rx_buff_pool[i].active)
 			ibmveth_replenish_buffer_pool(adapter,
 						     &adapter->rx_buff_pool[i]);
@@ -472,6 +487,18 @@ static void ibmveth_cleanup(struct ibmve
 		if (adapter->rx_buff_pool[i].active)
 			ibmveth_free_buffer_pool(adapter,
 						 &adapter->rx_buff_pool[i]);
+
+	if (adapter->bounce_buffer != NULL) {
+		if (!dma_mapping_error(adapter->bounce_buffer_dma)) {
+			dma_unmap_single(&adapter->vdev->dev,
+					adapter->bounce_buffer_dma,
+					adapter->netdev->mtu + IBMVETH_BUFF_OH,
+					DMA_BIDIRECTIONAL);
+			adapter->bounce_buffer_dma = DMA_ERROR_CODE;
+		}
+		kfree(adapter->bounce_buffer);
+		adapter->bounce_buffer = NULL;
+	}
 }
 
 static int ibmveth_register_logical_lan(struct ibmveth_adapter *adapter,
@@ -607,6 +634,24 @@ static int ibmveth_open(struct net_devic
 		return rc;
 	}
 
+	adapter->bounce_buffer =
+	    kmalloc(netdev->mtu + IBMVETH_BUFF_OH, GFP_KERNEL);
+	if (!adapter->bounce_buffer) {
+		ibmveth_error_printk("unable to allocate bounce buffer\n");
+		ibmveth_cleanup(adapter);
+		napi_disable(&adapter->napi);
+		return -ENOMEM;
+	}
+	adapter->bounce_buffer_dma =
+	    dma_map_single(&adapter->vdev->dev, adapter->bounce_buffer,
+			   netdev->mtu + IBMVETH_BUFF_OH, DMA_BIDIRECTIONAL);
+	if (dma_mapping_error(adapter->bounce_buffer_dma)) {
+		ibmveth_error_printk("unable to map bounce buffer\n");
+		ibmveth_cleanup(adapter);
+		napi_disable(&adapter->napi);
+		return -ENOMEM;
+	}
+
 	ibmveth_debug_printk("initial replenish cycle\n");
 	ibmveth_interrupt(netdev->irq, netdev);
 
@@ -853,10 +898,12 @@ static int ibmveth_start_xmit(struct sk_
 	unsigned int tx_packets = 0;
 	unsigned int tx_send_failed = 0;
 	unsigned int tx_map_failed = 0;
+	int used_bounce = 0;
+	unsigned long data_dma_addr;
 
 	desc.fields.flags_len = IBMVETH_BUF_VALID | skb->len;
-	desc.fields.address = dma_map_single(&adapter->vdev->dev, skb->data,
-					     skb->len, DMA_TO_DEVICE);
+	data_dma_addr = dma_map_single(&adapter->vdev->dev, skb->data,
+				       skb->len, DMA_TO_DEVICE);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL &&
 	    ip_hdr(skb)->protocol != IPPROTO_TCP && skb_checksum_help(skb)) {
@@ -875,12 +922,16 @@ static int ibmveth_start_xmit(struct sk_
 		buf[1] = 0;
 	}
 
-	if (dma_mapping_error(desc.fields.address)) {
-		ibmveth_error_printk("tx: unable to map xmit buffer\n");
+	if (dma_mapping_error(data_dma_addr)) {
+		if (!firmware_has_feature(FW_FEATURE_CMO))
+			ibmveth_error_printk("tx: unable to map xmit buffer\n");
+		skb_copy_from_linear_data(skb, adapter->bounce_buffer,
+					  skb->len);
+		desc.fields.address = adapter->bounce_buffer_dma;
 		tx_map_failed++;
-		tx_dropped++;
-		goto out;
-	}
+		used_bounce = 1;
+	} else
+		desc.fields.address = data_dma_addr;
 
 	/* send the frame. Arbitrarily set retrycount to 1024 */
 	correlator = 0;
@@ -904,8 +955,9 @@ static int ibmveth_start_xmit(struct sk_
 		netdev->trans_start = jiffies;
 	}
 
-	dma_unmap_single(&adapter->vdev->dev, desc.fields.address,
-			 skb->len, DMA_TO_DEVICE);
+	if (!used_bounce)
+		dma_unmap_single(&adapter->vdev->dev, data_dma_addr,
+				 skb->len, DMA_TO_DEVICE);
 
 out:	spin_lock_irqsave(&adapter->stats_lock, flags);
 	netdev->stats.tx_dropped += tx_dropped;
@@ -1053,8 +1105,9 @@ static void ibmveth_set_multicast_list(s
 static int ibmveth_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct ibmveth_adapter *adapter = dev->priv;
+	struct vio_dev *viodev = adapter->vdev;
 	int new_mtu_oh = new_mtu + IBMVETH_BUFF_OH;
-	int i, rc;
+	int i;
 
 	if (new_mtu < IBMVETH_MAX_MTU)
 		return -EINVAL;
@@ -1085,10 +1138,15 @@ static int ibmveth_change_mtu(struct net
 				ibmveth_close(adapter->netdev);
 				adapter->pool_config = 0;
 				dev->mtu = new_mtu;
-				if ((rc = ibmveth_open(adapter->netdev)))
-					return rc;
-			} else
-				dev->mtu = new_mtu;
+				vio_cmo_set_dev_desired(viodev,
+						ibmveth_get_desired_dma
+						(viodev));
+				return ibmveth_open(adapter->netdev);
+			}
+			dev->mtu = new_mtu;
+			vio_cmo_set_dev_desired(viodev,
+						ibmveth_get_desired_dma
+						(viodev));
 			return 0;
 		}
 	}
@@ -1103,6 +1161,46 @@ static void ibmveth_poll_controller(stru
 }
 #endif
 
+/**
+ * ibmveth_get_desired_dma - Calculate IO memory desired by the driver
+ *
+ * @vdev: struct vio_dev for the device whose desired IO mem is to be returned
+ *
+ * Return value:
+ *	Number of bytes of IO data the driver will need to perform well.
+ */
+static unsigned long ibmveth_get_desired_dma(struct vio_dev *vdev)
+{
+	struct net_device *netdev = dev_get_drvdata(&vdev->dev);
+	struct ibmveth_adapter *adapter;
+	unsigned long ret;
+	int i;
+	int rxqentries = 1;
+
+	/* netdev inits at probe time along with the structures we need below*/
+	if (netdev == NULL)
+		return IOMMU_PAGE_ALIGN(IBMVETH_IO_ENTITLEMENT_DEFAULT);
+
+	adapter = netdev_priv(netdev);
+
+	ret = IBMVETH_BUFF_LIST_SIZE + IBMVETH_FILT_LIST_SIZE;
+	ret += IOMMU_PAGE_ALIGN(netdev->mtu);
+
+	for (i = 0; i < IbmVethNumBufferPools; i++) {
+		/* add the size of the active receive buffers */
+		if (adapter->rx_buff_pool[i].active)
+			ret +=
+			    adapter->rx_buff_pool[i].size *
+			    IOMMU_PAGE_ALIGN(adapter->rx_buff_pool[i].
+			            buff_size);
+		rxqentries += adapter->rx_buff_pool[i].size;
+	}
+	/* add the size of the receive queue entries */
+	ret += IOMMU_PAGE_ALIGN(rxqentries * sizeof(struct ibmveth_rx_q_entry));
+
+	return ret;
+}
+
 static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 {
 	int rc, i;
@@ -1247,6 +1345,8 @@ static int __devexit ibmveth_remove(stru
 	ibmveth_proc_unregister_adapter(adapter);
 
 	free_netdev(netdev);
+	dev_set_drvdata(&dev->dev, NULL);
+
 	return 0;
 }
 
@@ -1491,6 +1591,7 @@ static struct vio_driver ibmveth_driver 
 	.id_table	= ibmveth_device_table,
 	.probe		= ibmveth_probe,
 	.remove		= ibmveth_remove,
+	.get_desired_dma = ibmveth_get_desired_dma,
 	.driver		= {
 		.name	= ibmveth_driver_name,
 		.owner	= THIS_MODULE,
Index: b/drivers/net/ibmveth.h
===================================================================
--- a/drivers/net/ibmveth.h
+++ b/drivers/net/ibmveth.h
@@ -93,9 +93,12 @@ static inline long h_illan_attributes(un
   plpar_hcall_norets(H_CHANGE_LOGICAL_LAN_MAC, ua, mac)
 
 #define IbmVethNumBufferPools 5
+#define IBMVETH_IO_ENTITLEMENT_DEFAULT 4243456 /* MTU of 1500 needs 4.2Mb */
 #define IBMVETH_BUFF_OH 22 /* Overhead: 14 ethernet header + 8 opaque handle */
 #define IBMVETH_MAX_MTU 68
 #define IBMVETH_MAX_POOL_COUNT 4096
+#define IBMVETH_BUFF_LIST_SIZE 4096
+#define IBMVETH_FILT_LIST_SIZE 4096
 #define IBMVETH_MAX_BUF_SIZE (1024 * 128)
 
 static int pool_size[] = { 512, 1024 * 2, 1024 * 16, 1024 * 32, 1024 * 64 };
@@ -143,6 +146,8 @@ struct ibmveth_adapter {
     struct ibmveth_rx_q rx_queue;
     int pool_config;
     int rx_csum;
+    void *bounce_buffer;
+    dma_addr_t bounce_buffer_dma;
 
     /* adapter specific stats */
     u64 replenish_task_cycles;
