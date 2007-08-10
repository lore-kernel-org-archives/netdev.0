From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 5/6] ibmveth: Remove dead frag processing code
Date: Fri, 10 Aug 2007 14:29:20 -0500
Message-ID: <200708101929.l7AJTK6c007045@d01av04.pok.ibm.com>
References: <11867741331983-patch-mail.ibm.com>
Cc: rcjenn@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, brking@linux.vnet.ibm.com
To: santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:46489 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937222AbXHJT3W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 15:29:22 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7AJUeab030373
	for <netdev@vger.kernel.org>; Fri, 10 Aug 2007 15:30:40 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l7AJTL86331478
	for <netdev@vger.kernel.org>; Fri, 10 Aug 2007 15:29:22 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7AJTLbl007090
	for <netdev@vger.kernel.org>; Fri, 10 Aug 2007 15:29:21 -0400
In-Reply-To: <11867741331983-patch-mail.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Removes dead frag processing code from ibmveth. Since NETIF_F_SG was
not set, this code was never executed. Also, since the ibmveth
interface can only handle 6 fragments, core networking code would need
to be modified in order to efficiently enable this support.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
---

 linux-2.6-bjking1/drivers/net/ibmveth.c |  100 +++++---------------------------
 linux-2.6-bjking1/drivers/net/ibmveth.h |    5 -
 2 files changed, 17 insertions(+), 88 deletions(-)

diff -puN drivers/net/ibmveth.c~ibmveth_remove_frag drivers/net/ibmveth.c
--- linux-2.6/drivers/net/ibmveth.c~ibmveth_remove_frag	2007-08-09 15:15:18.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.c	2007-08-09 15:15:18.000000000 -0500
@@ -28,7 +28,6 @@
 /**************************************************************************/
 /*
   TODO:
-  - remove frag processing code - no longer needed
   - add support for sysfs
   - possibly remove procfs support
 */
@@ -127,9 +126,6 @@ struct ibmveth_stat ibmveth_stats[] = {
 	{ "replenish_add_buff_success", IBMVETH_STAT_OFF(replenish_add_buff_success) },
 	{ "rx_invalid_buffer", IBMVETH_STAT_OFF(rx_invalid_buffer) },
 	{ "rx_no_buffer", IBMVETH_STAT_OFF(rx_no_buffer) },
-	{ "tx_multidesc_send", IBMVETH_STAT_OFF(tx_multidesc_send) },
-	{ "tx_linearized", IBMVETH_STAT_OFF(tx_linearized) },
-	{ "tx_linearize_failed", IBMVETH_STAT_OFF(tx_linearize_failed) },
 	{ "tx_map_failed", IBMVETH_STAT_OFF(tx_map_failed) },
 	{ "tx_send_failed", IBMVETH_STAT_OFF(tx_send_failed) },
 };
@@ -832,9 +828,8 @@ static int ibmveth_ioctl(struct net_devi
 static int ibmveth_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct ibmveth_adapter *adapter = netdev->priv;
-	union ibmveth_buf_desc desc[IbmVethMaxSendFrags];
+	union ibmveth_buf_desc desc;
 	unsigned long lpar_rc;
-	int nfrags = 0, curfrag;
 	unsigned long correlator;
 	unsigned long flags;
 	unsigned int retry_count;
@@ -844,25 +839,11 @@ static int ibmveth_start_xmit(struct sk_
 	unsigned int tx_send_failed = 0;
 	unsigned int tx_map_failed = 0;
 
-
-	if ((skb_shinfo(skb)->nr_frags + 1) > IbmVethMaxSendFrags) {
-		tx_dropped++;
-		goto out;
-	}
-
-	memset(&desc, 0, sizeof(desc));
-
-	/* nfrags = number of frags after the initial fragment */
-	nfrags = skb_shinfo(skb)->nr_frags;
-
-	if(nfrags)
-		adapter->tx_multidesc_send++;
-
-	/* map the initial fragment */
-	desc[0].fields.length  = nfrags ? skb->len - skb->data_len : skb->len;
-	desc[0].fields.address = dma_map_single(&adapter->vdev->dev, skb->data,
-					desc[0].fields.length, DMA_TO_DEVICE);
-	desc[0].fields.valid   = 1;
+	desc.desc = 0;
+	desc.fields.length  = skb->len;
+	desc.fields.address = dma_map_single(&adapter->vdev->dev, skb->data,
+					     desc.fields.length, DMA_TO_DEVICE);
+	desc.fields.valid   = 1;
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL &&
 	    ip_hdr(skb)->protocol != IPPROTO_TCP && skb_checksum_help(skb)) {
@@ -874,75 +855,34 @@ static int ibmveth_start_xmit(struct sk_
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		unsigned char *buf = skb_transport_header(skb) + skb->csum_offset;
 
-		desc[0].fields.no_csum = 1;
-		desc[0].fields.csum_good = 1;
+		desc.fields.no_csum = 1;
+		desc.fields.csum_good = 1;
 
 		/* Need to zero out the checksum */
 		buf[0] = 0;
 		buf[1] = 0;
 	}
 
-	if(dma_mapping_error(desc[0].fields.address)) {
-		ibmveth_error_printk("tx: unable to map initial fragment\n");
+	if (dma_mapping_error(desc.fields.address)) {
+		ibmveth_error_printk("tx: unable to map xmit buffer\n");
 		tx_map_failed++;
 		tx_dropped++;
 		goto out;
 	}
 
-	curfrag = nfrags;
-
-	/* map fragments past the initial portion if there are any */
-	while(curfrag--) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[curfrag];
-		desc[curfrag+1].fields.address
-			= dma_map_single(&adapter->vdev->dev,
-				page_address(frag->page) + frag->page_offset,
-				frag->size, DMA_TO_DEVICE);
-		desc[curfrag+1].fields.length = frag->size;
-		desc[curfrag+1].fields.valid  = 1;
-		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			desc[curfrag+1].fields.no_csum = 1;
-			desc[curfrag+1].fields.csum_good = 1;
-		}
-
-		if(dma_mapping_error(desc[curfrag+1].fields.address)) {
-			ibmveth_error_printk("tx: unable to map fragment %d\n", curfrag);
-			tx_map_failed++;
-			tx_dropped++;
-			/* Free all the mappings we just created */
-			while(curfrag < nfrags) {
-				dma_unmap_single(&adapter->vdev->dev,
-						 desc[curfrag+1].fields.address,
-						 desc[curfrag+1].fields.length,
-						 DMA_TO_DEVICE);
-				curfrag++;
-			}
-			goto out;
-		}
-	}
-
 	/* send the frame. Arbitrarily set retrycount to 1024 */
 	correlator = 0;
 	retry_count = 1024;
 	do {
 		lpar_rc = h_send_logical_lan(adapter->vdev->unit_address,
-					     desc[0].desc,
-					     desc[1].desc,
-					     desc[2].desc,
-					     desc[3].desc,
-					     desc[4].desc,
-					     desc[5].desc,
-					     correlator,
-					     &correlator);
+					     desc.desc, 0, 0, 0, 0, 0,
+					     correlator, &correlator);
 	} while ((lpar_rc == H_BUSY) && (retry_count--));
 
 	if(lpar_rc != H_SUCCESS && lpar_rc != H_DROPPED) {
-		int i;
 		ibmveth_error_printk("tx: h_send_logical_lan failed with rc=%ld\n", lpar_rc);
-		for(i = 0; i < 6; i++) {
-			ibmveth_error_printk("tx: desc[%i] valid=%d, len=%d, address=0x%d\n", i,
-					     desc[i].fields.valid, desc[i].fields.length, desc[i].fields.address);
-		}
+		ibmveth_error_printk("tx: valid=%d, len=%d, address=0x%08x\n",
+				     desc.fields.valid, desc.fields.length, desc.fields.address);
 		tx_send_failed++;
 		tx_dropped++;
 	} else {
@@ -951,11 +891,8 @@ static int ibmveth_start_xmit(struct sk_
 		netdev->trans_start = jiffies;
 	}
 
-	do {
-		dma_unmap_single(&adapter->vdev->dev,
-				desc[nfrags].fields.address,
-				desc[nfrags].fields.length, DMA_TO_DEVICE);
-	} while(--nfrags >= 0);
+	dma_unmap_single(&adapter->vdev->dev, desc.fields.address,
+			 desc.fields.length, DMA_TO_DEVICE);
 
 out:	spin_lock_irqsave(&adapter->stats_lock, flags);
 	adapter->stats.tx_dropped += tx_dropped;
@@ -1366,10 +1303,7 @@ static int ibmveth_seq_show(struct seq_f
 		   firmware_mac[3], firmware_mac[4], firmware_mac[5]);
 
 	seq_printf(seq, "\nAdapter Statistics:\n");
-	seq_printf(seq, "  TX:  skbuffs linearized:          %ld\n", adapter->tx_linearized);
-	seq_printf(seq, "       multi-descriptor sends:      %ld\n", adapter->tx_multidesc_send);
-	seq_printf(seq, "       skb_linearize failures:      %ld\n", adapter->tx_linearize_failed);
-	seq_printf(seq, "       vio_map_single failres:      %ld\n", adapter->tx_map_failed);
+	seq_printf(seq, "  TX:  vio_map_single failres:      %ld\n", adapter->tx_map_failed);
 	seq_printf(seq, "       send failures:               %ld\n", adapter->tx_send_failed);
 	seq_printf(seq, "  RX:  replenish task cycles:       %ld\n", adapter->replenish_task_cycles);
 	seq_printf(seq, "       alloc_skb_failures:          %ld\n", adapter->replenish_no_mem);
diff -puN drivers/net/ibmveth.h~ibmveth_remove_frag drivers/net/ibmveth.h
--- linux-2.6/drivers/net/ibmveth.h~ibmveth_remove_frag	2007-08-09 15:15:18.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.h	2007-08-09 15:15:18.000000000 -0500
@@ -25,8 +25,6 @@
 #ifndef _IBMVETH_H
 #define _IBMVETH_H
 
-#define IbmVethMaxSendFrags 6
-
 /* constants for H_MULTICAST_CTRL */
 #define IbmVethMcastReceptionModifyBit     0x80000UL
 #define IbmVethMcastReceptionEnableBit     0x20000UL
@@ -146,9 +144,6 @@ struct ibmveth_adapter {
     u64 replenish_add_buff_success;
     u64 rx_invalid_buffer;
     u64 rx_no_buffer;
-    u64 tx_multidesc_send;
-    u64 tx_linearized;
-    u64 tx_linearize_failed;
     u64 tx_map_failed;
     u64 tx_send_failed;
     spinlock_t stats_lock;
_
