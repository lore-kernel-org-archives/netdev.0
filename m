From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 6/6] ibmveth: Remove use of bitfields
Date: Fri, 17 Aug 2007 09:16:56 -0500
Message-ID: <200708171416.l7HEGu64024033@d03av04.boulder.ibm.com>
References: <11873601831813-patch-mail.ibm.com>
Cc: santil@linux.vnet.ibm.com, rcjenn@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	brking@linux.vnet.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:39231 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755290AbXHQOQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 10:16:59 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7HEGwZQ027725
	for <netdev@vger.kernel.org>; Fri, 17 Aug 2007 10:16:58 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7HEGw57216746
	for <netdev@vger.kernel.org>; Fri, 17 Aug 2007 08:16:58 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7HEGvQ7024080
	for <netdev@vger.kernel.org>; Fri, 17 Aug 2007 08:16:58 -0600
In-Reply-To: <11873601831813-patch-mail.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Removes the use of bitfields from the ibmveth driver. This results
in slightly smaller object code.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
---

 linux-2.6-bjking1/drivers/net/ibmveth.c |   90 ++++++++++++++++----------------
 linux-2.6-bjking1/drivers/net/ibmveth.h |   56 ++++++++-----------
 2 files changed, 68 insertions(+), 78 deletions(-)

diff -puN drivers/net/ibmveth.h~ibmveth_nobitfields drivers/net/ibmveth.h
--- linux-2.6/drivers/net/ibmveth.h~ibmveth_nobitfields	2007-08-09 15:15:27.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.h	2007-08-09 15:15:27.000000000 -0500
@@ -39,6 +39,12 @@
 #define IbmVethMcastRemoveFilter     0x2UL
 #define IbmVethMcastClearFilterTable 0x3UL
 
+#define IBMVETH_ILLAN_PADDED_PKT_CSUM	0x0000000000002000ULL
+#define IBMVETH_ILLAN_TRUNK_PRI_MASK	0x0000000000000F00ULL
+#define IBMVETH_ILLAN_IPV6_TCP_CSUM		0x0000000000000004ULL
+#define IBMVETH_ILLAN_IPV4_TCP_CSUM		0x0000000000000002ULL
+#define IBMVETH_ILLAN_ACTIVE_TRUNK		0x0000000000000001ULL
+
 /* hcall macros */
 #define h_register_logical_lan(ua, buflst, rxq, fltlst, mac) \
   plpar_hcall_norets(H_REGISTER_LOGICAL_LAN, ua, buflst, rxq, fltlst, mac)
@@ -150,13 +156,13 @@ struct ibmveth_adapter {
 };
 
 struct ibmveth_buf_desc_fields {
-    u32 valid : 1;
-    u32 toggle : 1;
-    u32 reserved : 4;
-    u32 no_csum : 1;
-    u32 csum_good : 1;
-    u32 length : 24;
-    u32 address;
+	u32 flags_len;
+#define IBMVETH_BUF_VALID	0x80000000
+#define IBMVETH_BUF_TOGGLE	0x40000000
+#define IBMVETH_BUF_NO_CSUM	0x02000000
+#define IBMVETH_BUF_CSUM_GOOD	0x01000000
+#define IBMVETH_BUF_LEN_MASK	0x00FFFFFF
+	u32 address;
 };
 
 union ibmveth_buf_desc {
@@ -164,33 +170,17 @@ union ibmveth_buf_desc {
     struct ibmveth_buf_desc_fields fields;
 };
 
-struct ibmveth_illan_attributes_fields {
-	u32 reserved;
-	u32 reserved2 : 18;
-	u32 csum_offload_padded_pkt_support : 1;
-	u32 reserved3 : 1;
-	u32 trunk_priority : 4;
-	u32 reserved4 : 5;
-	u32 tcp_csum_offload_ipv6 : 1;
-	u32 tcp_csum_offload_ipv4 : 1;
-	u32 active_trunk : 1;
-};
-
-union ibmveth_illan_attributes {
-	u64 desc;
-	struct ibmveth_illan_attributes_fields fields;
-};
-
 struct ibmveth_rx_q_entry {
-    u16 toggle : 1;
-    u16 valid : 1;
-    u16 reserved : 4;
-    u16 no_csum : 1;
-    u16 csum_good : 1;
-    u16 reserved2 : 8;
-    u16 offset;
-    u32 length;
-    u64 correlator;
+	u32 flags_off;
+#define IBMVETH_RXQ_TOGGLE		0x80000000
+#define IBMVETH_RXQ_TOGGLE_SHIFT	31
+#define IBMVETH_RXQ_VALID		0x40000000
+#define IBMVETH_RXQ_NO_CSUM		0x02000000
+#define IBMVETH_RXQ_CSUM_GOOD		0x01000000
+#define IBMVETH_RXQ_OFF_MASK		0x0000FFFF
+
+	u32 length;
+	u64 correlator;
 };
 
 #endif /* _IBMVETH_H */
diff -puN drivers/net/ibmveth.c~ibmveth_nobitfields drivers/net/ibmveth.c
--- linux-2.6/drivers/net/ibmveth.c~ibmveth_nobitfields	2007-08-09 15:15:27.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.c	2007-08-09 15:15:27.000000000 -0500
@@ -131,19 +131,29 @@ struct ibmveth_stat ibmveth_stats[] = {
 };
 
 /* simple methods of getting data from the current rxq entry */
+static inline u32 ibmveth_rxq_flags(struct ibmveth_adapter *adapter)
+{
+	return adapter->rx_queue.queue_addr[adapter->rx_queue.index].flags_off;
+}
+
+static inline int ibmveth_rxq_toggle(struct ibmveth_adapter *adapter)
+{
+	return (ibmveth_rxq_flags(adapter) & IBMVETH_RXQ_TOGGLE) >> IBMVETH_RXQ_TOGGLE_SHIFT;
+}
+
 static inline int ibmveth_rxq_pending_buffer(struct ibmveth_adapter *adapter)
 {
-	return (adapter->rx_queue.queue_addr[adapter->rx_queue.index].toggle == adapter->rx_queue.toggle);
+	return (ibmveth_rxq_toggle(adapter) == adapter->rx_queue.toggle);
 }
 
 static inline int ibmveth_rxq_buffer_valid(struct ibmveth_adapter *adapter)
 {
-	return (adapter->rx_queue.queue_addr[adapter->rx_queue.index].valid);
+	return (ibmveth_rxq_flags(adapter) & IBMVETH_RXQ_VALID);
 }
 
 static inline int ibmveth_rxq_frame_offset(struct ibmveth_adapter *adapter)
 {
-	return (adapter->rx_queue.queue_addr[adapter->rx_queue.index].offset);
+	return (ibmveth_rxq_flags(adapter) & IBMVETH_RXQ_OFF_MASK);
 }
 
 static inline int ibmveth_rxq_frame_length(struct ibmveth_adapter *adapter)
@@ -153,7 +163,7 @@ static inline int ibmveth_rxq_frame_leng
 
 static inline int ibmveth_rxq_csum_good(struct ibmveth_adapter *adapter)
 {
-	return (adapter->rx_queue.queue_addr[adapter->rx_queue.index].csum_good);
+	return (ibmveth_rxq_flags(adapter) & IBMVETH_RXQ_CSUM_GOOD);
 }
 
 /* setup the initial settings for a buffer pool */
@@ -253,9 +263,7 @@ static void ibmveth_replenish_buffer_poo
 		correlator = ((u64)pool->index << 32) | index;
 		*(u64*)skb->data = correlator;
 
-		desc.desc = 0;
-		desc.fields.valid = 1;
-		desc.fields.length = pool->buff_size;
+		desc.fields.flags_len = IBMVETH_BUF_VALID | pool->buff_size;
 		desc.fields.address = dma_addr;
 
 		lpar_rc = h_add_logical_lan_buffer(adapter->vdev->unit_address, desc.desc);
@@ -396,9 +404,8 @@ static void ibmveth_rxq_recycle_buffer(s
 		return;
 	}
 
-	desc.desc = 0;
-	desc.fields.valid = 1;
-	desc.fields.length = adapter->rx_buff_pool[pool].buff_size;
+	desc.fields.flags_len = IBMVETH_BUF_VALID |
+		adapter->rx_buff_pool[pool].buff_size;
 	desc.fields.address = adapter->rx_buff_pool[pool].dma_addr[index];
 
 	lpar_rc = h_add_logical_lan_buffer(adapter->vdev->unit_address, desc.desc);
@@ -549,9 +556,7 @@ static int ibmveth_open(struct net_devic
 	memcpy(&mac_address, netdev->dev_addr, netdev->addr_len);
 	mac_address = mac_address >> 16;
 
-	rxq_desc.desc = 0;
-	rxq_desc.fields.valid = 1;
-	rxq_desc.fields.length = adapter->rx_queue.queue_len;
+	rxq_desc.fields.flags_len = IBMVETH_BUF_VALID | adapter->rx_queue.queue_len;
 	rxq_desc.fields.address = adapter->rx_queue.queue_dma;
 
 	ibmveth_debug_printk("buffer list @ 0x%p\n", adapter->buffer_list_addr);
@@ -693,7 +698,7 @@ static int ibmveth_set_csum_offload(stru
 				    void (*done) (struct net_device *, u32))
 {
 	struct ibmveth_adapter *adapter = dev->priv;
-	union ibmveth_illan_attributes set_attr, clr_attr, ret_attr;
+	u64 set_attr, clr_attr, ret_attr;
 	long ret;
 	int rc1 = 0, rc2 = 0;
 	int restart = 0;
@@ -705,21 +710,21 @@ static int ibmveth_set_csum_offload(stru
 		adapter->pool_config = 0;
 	}
 
-	set_attr.desc = 0;
-	clr_attr.desc = 0;
+	set_attr = 0;
+	clr_attr = 0;
 
 	if (data)
-		set_attr.fields.tcp_csum_offload_ipv4 = 1;
+		set_attr = IBMVETH_ILLAN_IPV4_TCP_CSUM;
 	else
-		clr_attr.fields.tcp_csum_offload_ipv4 = 1;
+		clr_attr = IBMVETH_ILLAN_IPV4_TCP_CSUM;
 
-	ret = h_illan_attributes(adapter->vdev->unit_address, 0, 0, &ret_attr.desc);
+	ret = h_illan_attributes(adapter->vdev->unit_address, 0, 0, &ret_attr);
 
-	if (ret == H_SUCCESS && !ret_attr.fields.active_trunk &&
-	    !ret_attr.fields.trunk_priority &&
-	    ret_attr.fields.csum_offload_padded_pkt_support) {
-		ret = h_illan_attributes(adapter->vdev->unit_address, clr_attr.desc,
-					 set_attr.desc, &ret_attr.desc);
+	if (ret == H_SUCCESS && !(ret_attr & IBMVETH_ILLAN_ACTIVE_TRUNK) &&
+	    !(ret_attr & IBMVETH_ILLAN_TRUNK_PRI_MASK) &&
+	    (ret_attr & IBMVETH_ILLAN_PADDED_PKT_CSUM)) {
+		ret = h_illan_attributes(adapter->vdev->unit_address, clr_attr,
+					 set_attr, &ret_attr);
 
 		if (ret != H_SUCCESS) {
 			rc1 = -EIO;
@@ -727,13 +732,13 @@ static int ibmveth_set_csum_offload(stru
 					     " %d rc=%ld\n", data, ret);
 
 			ret = h_illan_attributes(adapter->vdev->unit_address,
-						 set_attr.desc, clr_attr.desc, &ret_attr.desc);
+						 set_attr, clr_attr, &ret_attr);
 		} else
 			done(dev, data);
 	} else {
 		rc1 = -EIO;
 		ibmveth_error_printk("unable to change checksum offload settings."
-				     " %d rc=%ld ret_attr=%lx\n", data, ret, ret_attr.desc);
+				     " %d rc=%ld ret_attr=%lx\n", data, ret, ret_attr);
 	}
 
 	if (restart)
@@ -839,11 +844,9 @@ static int ibmveth_start_xmit(struct sk_
 	unsigned int tx_send_failed = 0;
 	unsigned int tx_map_failed = 0;
 
-	desc.desc = 0;
-	desc.fields.length  = skb->len;
+	desc.fields.flags_len = IBMVETH_BUF_VALID | skb->len;
 	desc.fields.address = dma_map_single(&adapter->vdev->dev, skb->data,
-					     desc.fields.length, DMA_TO_DEVICE);
-	desc.fields.valid   = 1;
+					     skb->len, DMA_TO_DEVICE);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL &&
 	    ip_hdr(skb)->protocol != IPPROTO_TCP && skb_checksum_help(skb)) {
@@ -855,8 +858,7 @@ static int ibmveth_start_xmit(struct sk_
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		unsigned char *buf = skb_transport_header(skb) + skb->csum_offset;
 
-		desc.fields.no_csum = 1;
-		desc.fields.csum_good = 1;
+		desc.fields.flags_len |= (IBMVETH_BUF_NO_CSUM | IBMVETH_BUF_CSUM_GOOD);
 
 		/* Need to zero out the checksum */
 		buf[0] = 0;
@@ -882,7 +884,8 @@ static int ibmveth_start_xmit(struct sk_
 	if(lpar_rc != H_SUCCESS && lpar_rc != H_DROPPED) {
 		ibmveth_error_printk("tx: h_send_logical_lan failed with rc=%ld\n", lpar_rc);
 		ibmveth_error_printk("tx: valid=%d, len=%d, address=0x%08x\n",
-				     desc.fields.valid, desc.fields.length, desc.fields.address);
+				     (desc.fields.flags_len & IBMVETH_BUF_VALID) ? 1 : 0,
+				     skb->len, desc.fields.address);
 		tx_send_failed++;
 		tx_dropped++;
 	} else {
@@ -892,7 +895,7 @@ static int ibmveth_start_xmit(struct sk_
 	}
 
 	dma_unmap_single(&adapter->vdev->dev, desc.fields.address,
-			 desc.fields.length, DMA_TO_DEVICE);
+			 skb->len, DMA_TO_DEVICE);
 
 out:	spin_lock_irqsave(&adapter->stats_lock, flags);
 	adapter->stats.tx_dropped += tx_dropped;
@@ -1108,7 +1111,7 @@ static int __devinit ibmveth_probe(struc
 	long ret;
 	struct net_device *netdev;
 	struct ibmveth_adapter *adapter;
-	union ibmveth_illan_attributes set_attr, ret_attr;
+	u64 set_attr, ret_attr;
 
 	unsigned char *mac_addr_p;
 	unsigned int *mcastFilterSize_p;
@@ -1202,23 +1205,20 @@ static int __devinit ibmveth_probe(struc
 
 	ibmveth_debug_printk("registering netdev...\n");
 
-	ret = h_illan_attributes(dev->unit_address, 0, 0, &ret_attr.desc);
+	ret = h_illan_attributes(dev->unit_address, 0, 0, &ret_attr);
 
-	if (ret == H_SUCCESS && !ret_attr.fields.active_trunk &&
-	    !ret_attr.fields.trunk_priority &&
-	    ret_attr.fields.csum_offload_padded_pkt_support) {
-		set_attr.desc = 0;
-		set_attr.fields.tcp_csum_offload_ipv4 = 1;
+	if (ret == H_SUCCESS && !(ret_attr & IBMVETH_ILLAN_ACTIVE_TRUNK) &&
+	    !(ret_attr & IBMVETH_ILLAN_TRUNK_PRI_MASK) &&
+	    (ret_attr & IBMVETH_ILLAN_PADDED_PKT_CSUM)) {
+		set_attr = IBMVETH_ILLAN_IPV4_TCP_CSUM;
 
-		ret = h_illan_attributes(dev->unit_address, 0, set_attr.desc,
-					 &ret_attr.desc);
+		ret = h_illan_attributes(dev->unit_address, 0, set_attr, &ret_attr);
 
 		if (ret == H_SUCCESS) {
 			adapter->rx_csum = 1;
 			netdev->features |= NETIF_F_IP_CSUM;
 		} else
-			ret = h_illan_attributes(dev->unit_address, set_attr.desc,
-						 0, &ret_attr.desc);
+			ret = h_illan_attributes(dev->unit_address, set_attr, 0, &ret_attr);
 	}
 
 	rc = register_netdev(netdev);
_
