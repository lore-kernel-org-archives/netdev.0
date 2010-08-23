From: Anton Blanchard <anton@samba.org>
Subject: [patch 03/20] ibmveth: Remove LLTX
Date: Mon, 23 Aug 2010 10:09:33 +1000
Message-ID: <20100823001238.571202133@samba.org>
References: <20100823000930.546065833@samba.org>
Cc: netdev@vger.kernel.org
To: brking@linux.vnet.ibm.com, santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:35034 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751249Ab0HWA1W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 20:27:22 -0400
Content-Disposition: inline; filename=veth_no_lltx
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ibmveth adapter needs locking in the transmit routine to protect
the bounce_buffer but it sets LLTX and forgets to add any of its own
locking.

Just remove the deprecated LLTX option. Remove the stats lock in the process.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.c	2010-08-23 08:52:27.963919704 +1000
+++ net-next-2.6/drivers/net/ibmveth.c	2010-08-23 08:52:28.563877123 +1000
@@ -903,7 +903,6 @@ static netdev_tx_t ibmveth_start_xmit(st
 	union ibmveth_buf_desc desc;
 	unsigned long lpar_rc;
 	unsigned long correlator;
-	unsigned long flags;
 	unsigned int retry_count;
 	unsigned int tx_dropped = 0;
 	unsigned int tx_bytes = 0;
@@ -965,20 +964,18 @@ static netdev_tx_t ibmveth_start_xmit(st
 	} else {
 		tx_packets++;
 		tx_bytes += skb->len;
-		netdev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
 	}
 
 	if (!used_bounce)
 		dma_unmap_single(&adapter->vdev->dev, data_dma_addr,
 				 skb->len, DMA_TO_DEVICE);
 
-out:	spin_lock_irqsave(&adapter->stats_lock, flags);
+out:
 	netdev->stats.tx_dropped += tx_dropped;
 	netdev->stats.tx_bytes += tx_bytes;
 	netdev->stats.tx_packets += tx_packets;
 	adapter->tx_send_failed += tx_send_failed;
 	adapter->tx_map_failed += tx_map_failed;
-	spin_unlock_irqrestore(&adapter->stats_lock, flags);
 
 	dev_kfree_skb(skb);
 	return NETDEV_TX_OK;
@@ -1290,8 +1287,6 @@ static int __devinit ibmveth_probe(struc
 	netdev->netdev_ops = &ibmveth_netdev_ops;
 	netdev->ethtool_ops = &netdev_ethtool_ops;
 	SET_NETDEV_DEV(netdev, &dev->dev);
- 	netdev->features |= NETIF_F_LLTX;
-	spin_lock_init(&adapter->stats_lock);
 
 	memcpy(netdev->dev_addr, &adapter->mac_addr, netdev->addr_len);
 
Index: net-next-2.6/drivers/net/ibmveth.h
===================================================================
--- net-next-2.6.orig/drivers/net/ibmveth.h	2010-08-23 08:52:27.963919704 +1000
+++ net-next-2.6/drivers/net/ibmveth.h	2010-08-23 08:52:28.563877123 +1000
@@ -158,7 +158,6 @@ struct ibmveth_adapter {
     u64 rx_no_buffer;
     u64 tx_map_failed;
     u64 tx_send_failed;
-    spinlock_t stats_lock;
 };
 
 struct ibmveth_buf_desc_fields {


