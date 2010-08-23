From: Anton Blanchard <anton@samba.org>
Subject: [patch 07/20] ibmveth: Add scatter-gather support
Date: Mon, 23 Aug 2010 10:09:37 +1000
Message-ID: <20100823001238.941872212@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51823 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751607Ab0HWA2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:28:03 -0400
Content-Disposition: inline; filename=veth_sg
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ibmveth can scatter gather up to 6 segments. If we go over this then
we have no option but to call skb_linearize, like other drivers with
similar limitations do.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 08:52:30.283755038 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 08:52:30.633730198 +1000
@@ -897,6 +897,7 @@ static const struct ethtool_ops netdev_e
 	.get_strings		= ibmveth_get_strings,
 	.get_sset_count		= ibmveth_get_sset_count,
 	.get_ethtool_stats	= ibmveth_get_ethtool_stats,
+	.set_sg			= ethtool_op_set_sg,
 };
 
 static int ibmveth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
@@ -906,96 +907,158 @@ static int ibmveth_ioctl(struct net_devi
 
 #define page_offset(v) ((unsigned long)(v) & ((1 << 12) - 1))
 
-static netdev_tx_t ibmveth_start_xmit(struct sk_buff *skb,
-				      struct net_device *netdev)
+static int ibmveth_send(struct ibmveth_adapter *adapter,
+			union ibmveth_buf_desc *descs)
 {
-	struct ibmveth_adapter *adapter = netdev_priv(netdev);
-	union ibmveth_buf_desc desc;
-	unsigned long lpar_rc;
 	unsigned long correlator;
 	unsigned int retry_count;
-	unsigned int tx_dropped = 0;
-	unsigned int tx_bytes = 0;
-	unsigned int tx_packets = 0;
-	unsigned int tx_send_failed = 0;
-	unsigned int tx_map_failed = 0;
-	int used_bounce = 0;
-	unsigned long data_dma_addr;
+	unsigned long ret;
+
+	/*
+	 * The retry count sets a maximum for the number of broadcast and
+	 * multicast destinations within the system.
+	 */
+	retry_count = 1024;
+	correlator = 0;
+	do {
+		ret = h_send_logical_lan(adapter->vdev->unit_address,
+					     descs[0].desc, descs[1].desc,
+					     descs[2].desc, descs[3].desc,
+					     descs[4].desc, descs[5].desc,
+					     correlator, &correlator);
+	} while ((ret == H_BUSY) && (retry_count--));
+
+	if (ret != H_SUCCESS && ret != H_DROPPED) {
+		ibmveth_error_printk("tx: h_send_logical_lan failed with "
+				     "rc=%ld\n", ret);
+		return 1;
+	}
+
+	return 0;
+}
 
-	desc.fields.flags_len = IBMVETH_BUF_VALID | skb->len;
+static netdev_tx_t ibmveth_start_xmit(struct sk_buff *skb,
+				      struct net_device *netdev)
+{
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
+	unsigned int desc_flags;
+	union ibmveth_buf_desc descs[6];
+	int last, i;
+	int force_bounce = 0;
+
+	/*
+	 * veth handles a maximum of 6 segments including the header, so
+	 * we have to linearize the skb if there are more than this.
+	 */
+	if (skb_shinfo(skb)->nr_frags > 5 && __skb_linearize(skb)) {
+		netdev->stats.tx_dropped++;
+		goto out;
+	}
 
+	/* veth can't checksum offload UDP */
 	if (skb->ip_summed == CHECKSUM_PARTIAL &&
 	    ip_hdr(skb)->protocol != IPPROTO_TCP && skb_checksum_help(skb)) {
 		ibmveth_error_printk("tx: failed to checksum packet\n");
-		tx_dropped++;
+		netdev->stats.tx_dropped++;
 		goto out;
 	}
 
+	desc_flags = IBMVETH_BUF_VALID;
+
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		unsigned char *buf = skb_transport_header(skb) + skb->csum_offset;
+		unsigned char *buf = skb_transport_header(skb) +
+						skb->csum_offset;
 
-		desc.fields.flags_len |= (IBMVETH_BUF_NO_CSUM | IBMVETH_BUF_CSUM_GOOD);
+		desc_flags |= (IBMVETH_BUF_NO_CSUM | IBMVETH_BUF_CSUM_GOOD);
 
 		/* Need to zero out the checksum */
 		buf[0] = 0;
 		buf[1] = 0;
 	}
 
-	if (skb->len < tx_copybreak) {
-		used_bounce = 1;
-	} else {
-		data_dma_addr = dma_map_single(&adapter->vdev->dev, skb->data,
-					       skb->len, DMA_TO_DEVICE);
-		if (dma_mapping_error(&adapter->vdev->dev, data_dma_addr)) {
-			if (!firmware_has_feature(FW_FEATURE_CMO))
-				ibmveth_error_printk("tx: unable to map "
-						     "xmit buffer\n");
-			tx_map_failed++;
-			used_bounce = 1;
-		}
-	}
+retry_bounce:
+	memset(descs, 0, sizeof(descs));
 
-	if (used_bounce) {
+	/*
+	 * If a linear packet is below the rx threshold then
+	 * copy it into the static bounce buffer. This avoids the
+	 * cost of a TCE insert and remove.
+	 */
+	if (force_bounce || (!skb_is_nonlinear(skb) &&
+				(skb->len < tx_copybreak))) {
 		skb_copy_from_linear_data(skb, adapter->bounce_buffer,
 					  skb->len);
-		desc.fields.address = adapter->bounce_buffer_dma;
-	} else
-		desc.fields.address = data_dma_addr;
 
-	/* send the frame. Arbitrarily set retrycount to 1024 */
-	correlator = 0;
-	retry_count = 1024;
-	do {
-		lpar_rc = h_send_logical_lan(adapter->vdev->unit_address,
-					     desc.desc, 0, 0, 0, 0, 0,
-					     correlator, &correlator);
-	} while ((lpar_rc == H_BUSY) && (retry_count--));
+		descs[0].fields.flags_len = desc_flags | skb->len;
+		descs[0].fields.address = adapter->bounce_buffer_dma;
 
-	if(lpar_rc != H_SUCCESS && lpar_rc != H_DROPPED) {
-		ibmveth_error_printk("tx: h_send_logical_lan failed with rc=%ld\n", lpar_rc);
-		ibmveth_error_printk("tx: valid=%d, len=%d, address=0x%08x\n",
-				     (desc.fields.flags_len & IBMVETH_BUF_VALID) ? 1 : 0,
-				     skb->len, desc.fields.address);
-		tx_send_failed++;
-		tx_dropped++;
+		if (ibmveth_send(adapter, descs)) {
+			adapter->tx_send_failed++;
+			netdev->stats.tx_dropped++;
+		} else {
+			netdev->stats.tx_packets++;
+			netdev->stats.tx_bytes += skb->len;
+		}
+
+		goto out;
+	}
+
+	/* Map the header */
+	descs[0].fields.address = dma_map_single(&adapter->vdev->dev, skb->data,
+						 skb_headlen(skb),
+						 DMA_TO_DEVICE);
+	if (dma_mapping_error(&adapter->vdev->dev, descs[0].fields.address))
+		goto map_failed;
+
+	descs[0].fields.flags_len = desc_flags | skb_headlen(skb);
+
+	/* Map the frags */
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		unsigned long dma_addr;
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+		dma_addr = dma_map_page(&adapter->vdev->dev, frag->page,
+					frag->page_offset, frag->size,
+					DMA_TO_DEVICE);
+
+		if (dma_mapping_error(&adapter->vdev->dev, dma_addr))
+			goto map_failed_frags;
+
+		descs[i+1].fields.flags_len = desc_flags | frag->size;
+		descs[i+1].fields.address = dma_addr;
+	}
+
+	if (ibmveth_send(adapter, descs)) {
+		adapter->tx_send_failed++;
+		netdev->stats.tx_dropped++;
 	} else {
-		tx_packets++;
-		tx_bytes += skb->len;
+		netdev->stats.tx_packets++;
+		netdev->stats.tx_bytes += skb->len;
 	}
 
-	if (!used_bounce)
-		dma_unmap_single(&adapter->vdev->dev, data_dma_addr,
-				 skb->len, DMA_TO_DEVICE);
+	for (i = 0; i < skb_shinfo(skb)->nr_frags + 1; i++)
+		dma_unmap_page(&adapter->vdev->dev, descs[i].fields.address,
+			       descs[i].fields.flags_len & IBMVETH_BUF_LEN_MASK,
+			       DMA_TO_DEVICE);
 
 out:
-	netdev->stats.tx_dropped += tx_dropped;
-	netdev->stats.tx_bytes += tx_bytes;
-	netdev->stats.tx_packets += tx_packets;
-	adapter->tx_send_failed += tx_send_failed;
-	adapter->tx_map_failed += tx_map_failed;
-
 	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
+
+map_failed_frags:
+	last = i+1;
+	for (i = 0; i < last; i++)
+		dma_unmap_page(&adapter->vdev->dev, descs[i].fields.address,
+			       descs[i].fields.flags_len & IBMVETH_BUF_LEN_MASK,
+			       DMA_TO_DEVICE);
+
+map_failed:
+	if (!firmware_has_feature(FW_FEATURE_CMO))
+		ibmveth_error_printk("tx: unable to map xmit buffer\n");
+	adapter->tx_map_failed++;
+	skb_linearize(skb);
+	force_bounce = 1;
+	goto retry_bounce;
 }
 
 static int ibmveth_poll(struct napi_struct *napi, int budget)
@@ -1316,6 +1379,7 @@ static int __devinit ibmveth_probe(struc
 	netdev->netdev_ops = &ibmveth_netdev_ops;
 	netdev->ethtool_ops = &netdev_ethtool_ops;
 	SET_NETDEV_DEV(netdev, &dev->dev);
+	netdev->features |= NETIF_F_SG;
 
 	memcpy(netdev->dev_addr, &adapter->mac_addr, netdev->addr_len);
 


