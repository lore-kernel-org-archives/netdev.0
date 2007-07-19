From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 1/4] ibmveth: Enable TCP checksum offload
Date: Thu, 19 Jul 2007 10:48:07 -0500
Message-ID: <46883.358321111$1184860101@news.gmane.org>
Cc: rcjenn@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, brking@linux.vnet.ibm.com
To: santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:39750 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752889AbXGSPsJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 11:48:09 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6JFm8Ri002332
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 11:48:08 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6JFm8Uu525150
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 11:48:08 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6JFm8dJ031568
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 11:48:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patchset enables TCP checksum offload support for IPV4
on ibmveth. This completely eliminates the generation and checking of
the checksum for packets that are completely virtual and never
touch a physical network. A simple TCP_STREAM netperf run on
a virtual network with maximum mtu set yielded a ~30% increase
in throughput. This feature is enabled by default on systems that
support it, but can be disabled with a module option.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
---

 linux-2.6-bjking1/drivers/net/ibmveth.c |   53 ++++++++++++++++++++++++++++++++
 linux-2.6-bjking1/drivers/net/ibmveth.h |   41 +++++++++++++++++++++++-
 2 files changed, 92 insertions(+), 2 deletions(-)

diff -puN drivers/net/ibmveth.c~ibmveth_csum_offload drivers/net/ibmveth.c
--- linux-2.6/drivers/net/ibmveth.c~ibmveth_csum_offload	2007-07-18 16:55:06.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.c	2007-07-19 08:36:05.000000000 -0500
@@ -47,6 +47,8 @@
 #include <linux/mm.h>
 #include <linux/ethtool.h>
 #include <linux/proc_fs.h>
+#include <linux/in.h>
+#include <linux/ip.h>
 #include <asm/semaphore.h>
 #include <asm/hvcall.h>
 #include <asm/atomic.h>
@@ -131,6 +133,11 @@ static inline int ibmveth_rxq_frame_leng
 	return (adapter->rx_queue.queue_addr[adapter->rx_queue.index].length);
 }
 
+static inline int ibmveth_rxq_csum_good(struct ibmveth_adapter *adapter)
+{
+	return (adapter->rx_queue.queue_addr[adapter->rx_queue.index].csum_good);
+}
+
 /* setup the initial settings for a buffer pool */
 static void ibmveth_init_buffer_pool(struct ibmveth_buff_pool *pool, u32 pool_index, u32 pool_size, u32 buff_size, u32 pool_active)
 {
@@ -684,6 +691,24 @@ static int ibmveth_start_xmit(struct sk_
 					desc[0].fields.length, DMA_TO_DEVICE);
 	desc[0].fields.valid   = 1;
 
+	if (skb->ip_summed == CHECKSUM_PARTIAL &&
+	    ip_hdr(skb)->protocol != IPPROTO_TCP && skb_checksum_help(skb)) {
+		ibmveth_error_printk("tx: failed to checksum packet\n");
+		tx_dropped++;
+		goto out;
+	}
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		unsigned char *buf = skb_transport_header(skb) + skb->csum_offset;
+
+		desc[0].fields.no_csum = 1;
+		desc[0].fields.csum_good = 1;
+
+		/* Need to zero out the checksum */
+		buf[0] = 0;
+		buf[1] = 0;
+	}
+
 	if(dma_mapping_error(desc[0].fields.address)) {
 		ibmveth_error_printk("tx: unable to map initial fragment\n");
 		tx_map_failed++;
@@ -702,6 +727,10 @@ static int ibmveth_start_xmit(struct sk_
 				frag->size, DMA_TO_DEVICE);
 		desc[curfrag+1].fields.length = frag->size;
 		desc[curfrag+1].fields.valid  = 1;
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			desc[curfrag+1].fields.no_csum = 1;
+			desc[curfrag+1].fields.csum_good = 1;
+		}
 
 		if(dma_mapping_error(desc[curfrag+1].fields.address)) {
 			ibmveth_error_printk("tx: unable to map fragment %d\n", curfrag);
@@ -792,7 +821,11 @@ static int ibmveth_poll(struct net_devic
 			} else {
 				int length = ibmveth_rxq_frame_length(adapter);
 				int offset = ibmveth_rxq_frame_offset(adapter);
+				int csum_good = ibmveth_rxq_csum_good(adapter);
+
 				skb = ibmveth_rxq_get_buffer(adapter);
+				if (csum_good)
+					skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 				ibmveth_rxq_harvest_buffer(adapter);
 
@@ -962,8 +995,10 @@ static void ibmveth_poll_controller(stru
 static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 {
 	int rc, i;
+	long ret;
 	struct net_device *netdev;
 	struct ibmveth_adapter *adapter = NULL;
+	union ibmveth_illan_attributes set_attr, ret_attr;
 
 	unsigned char *mac_addr_p;
 	unsigned int *mcastFilterSize_p;
@@ -1058,6 +1093,24 @@ static int __devinit ibmveth_probe(struc
 
 	ibmveth_debug_printk("registering netdev...\n");
 
+	ret = h_illan_attributes(dev->unit_address, 0, 0, &ret_attr.desc);
+
+	if (ret == H_SUCCESS && !ret_attr.fields.active_trunk &&
+	    !ret_attr.fields.trunk_priority &&
+	    ret_attr.fields.csum_offload_padded_pkt_support) {
+		set_attr.desc = 0;
+		set_attr.fields.tcp_csum_offload_ipv4 = 1;
+
+		ret = h_illan_attributes(dev->unit_address, 0, set_attr.desc,
+					 &ret_attr.desc);
+
+		if (ret == H_SUCCESS)
+			netdev->features |= NETIF_F_IP_CSUM;
+		else
+			ret = h_illan_attributes(dev->unit_address, set_attr.desc,
+						 0, &ret_attr.desc);
+	}
+
 	rc = register_netdev(netdev);
 
 	if(rc) {
diff -puN drivers/net/ibmveth.h~ibmveth_csum_offload drivers/net/ibmveth.h
--- linux-2.6/drivers/net/ibmveth.h~ibmveth_csum_offload	2007-07-18 16:55:06.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.h	2007-07-19 08:35:25.000000000 -0500
@@ -67,6 +67,21 @@ static inline long h_send_logical_lan(un
 	return rc;
 }
 
+static inline long h_illan_attributes(unsigned long unit_address,
+				      unsigned long reset_mask, unsigned long set_mask,
+				      unsigned long *ret_attributes)
+{
+	long rc;
+	unsigned long retbuf[PLPAR_HCALL_BUFSIZE];
+
+	rc = plpar_hcall(H_ILLAN_ATTRIBUTES, retbuf, unit_address,
+			 reset_mask, set_mask);
+
+	*ret_attributes = retbuf[0];
+
+	return rc;
+}
+
 #define h_multicast_ctrl(ua, cmd, mac) \
   plpar_hcall_norets(H_MULTICAST_CTRL, ua, cmd, mac)
 
@@ -144,7 +159,9 @@ struct ibmveth_adapter {
 struct ibmveth_buf_desc_fields {
     u32 valid : 1;
     u32 toggle : 1;
-    u32 reserved : 6;
+    u32 reserved : 4;
+    u32 no_csum : 1;
+    u32 csum_good : 1;
     u32 length : 24;
     u32 address;
 };
@@ -154,10 +171,30 @@ union ibmveth_buf_desc {
     struct ibmveth_buf_desc_fields fields;
 };
 
+struct ibmveth_illan_attributes_fields {
+	u32 reserved;
+	u32 reserved2 : 18;
+	u32 csum_offload_padded_pkt_support : 1;
+	u32 reserved3 : 1;
+	u32 trunk_priority : 4;
+	u32 reserved4 : 5;
+	u32 tcp_csum_offload_ipv6 : 1;
+	u32 tcp_csum_offload_ipv4 : 1;
+	u32 active_trunk : 1;
+};
+
+union ibmveth_illan_attributes {
+	u64 desc;
+	struct ibmveth_illan_attributes_fields fields;
+};
+
 struct ibmveth_rx_q_entry {
     u16 toggle : 1;
     u16 valid : 1;
-    u16 reserved : 14;
+    u16 reserved : 4;
+    u16 no_csum : 1;
+    u16 csum_good : 1;
+    u16 reserved2 : 8;
     u16 offset;
     u32 length;
     u64 correlator;
_
