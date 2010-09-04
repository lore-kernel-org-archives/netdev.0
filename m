From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 03/21] ibmveth: Remove LLTX
Date: Fri, 03 Sep 2010 23:28:15 -0500
Message-ID: <20100904042815.2655.71537.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
References: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:39218 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759Ab0IDE2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 00:28:43 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844KHcc008200
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:20:17 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o844Sh7J246336
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:28:43 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844Sgef031586
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:28:43 -0600
In-Reply-To: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ibmveth adapter needs locking in the transmit routine to protect
the bounce_buffer but it sets LLTX and forgets to add any of its own
locking.

Just remove the deprecated LLTX option. Remove the stats lock in the process.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Santiago Leon <santil@linux.vnet.ibm.com>
---

Index: net-next-2.6/drivers/net/ibmveth.c
===================================================================
--- net-next-2.6.orig//drivers/net/ibmveth.c	2010-09-03 22:18:39.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.c	2010-09-03 22:18:40.000000000 -0500
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
--- net-next-2.6.orig//drivers/net/ibmveth.h	2010-09-03 22:18:39.000000000 -0500
+++ net-next-2.6/drivers/net/ibmveth.h	2010-09-03 22:18:40.000000000 -0500
@@ -158,7 +158,6 @@ struct ibmveth_adapter {
     u64 rx_no_buffer;
     u64 tx_map_failed;
     u64 tx_send_failed;
-    spinlock_t stats_lock;
 };
 
 struct ibmveth_buf_desc_fields {
