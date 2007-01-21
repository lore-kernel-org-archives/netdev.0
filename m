From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 6/12] forcedeth: tx limiting
Date: Sun, 21 Jan 2007 18:10:42 -0500
Message-ID: <45B3F2F2.4010907@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080200070901010707070509"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:6368 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838AbXAVBFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jan 2007 20:05:33 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080200070901010707070509
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch optimizes the logic for tx limiting. It adds a flag to check
on the completion side instead of recalculating the number of empty
slots. Also, it removes the fields that were previous used for limiting
since they have no value.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------080200070901010707070509
Content-Type: text/plain;
 name="patch-tx-limiting"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-tx-limiting"

--- orig/drivers/net/forcedeth.c	2007-01-19 11:01:30.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-01-19 11:03:13.000000000 -0500
@@ -518,12 +518,6 @@
 #define TX_RING_MIN		64
 #define RING_MAX_DESC_VER_1	1024
 #define RING_MAX_DESC_VER_2_3	16384
-/*
- * Difference between the get and put pointers for the tx ring.
- * This is used to throttle the amount of data outstanding in the
- * tx ring.
- */
-#define TX_LIMIT_DIFFERENCE	1
 
 /* rx/tx mac addr + type + vlan + align + slack*/
 #define NV_RX_HEADERS		(64)
@@ -777,8 +771,7 @@
 	union ring_type tx_ring;
 	u32 tx_flags;
 	int tx_ring_size;
-	int tx_limit_start;
-	int tx_limit_stop;
+	int tx_stop;
 
 	/* vlan fields */
 	struct vlan_group *vlangrp;
@@ -1583,9 +1576,10 @@
 	}
 
 	empty_slots = nv_get_empty_tx_slots(np);
-	if ((empty_slots - np->tx_limit_stop) <= entries) {
+	if (empty_slots <= entries) {
 		spin_lock_irq(&np->lock);
 		netif_stop_queue(dev);
+		np->tx_stop = 1;
 		spin_unlock_irq(&np->lock);
 		return NETDEV_TX_BUSY;
 	}
@@ -1704,9 +1698,10 @@
 	}
 
 	empty_slots = nv_get_empty_tx_slots(np);
-	if ((empty_slots - np->tx_limit_stop) <= entries) {
+	if (empty_slots <= entries) {
 		spin_lock_irq(&np->lock);
 		netif_stop_queue(dev);
+		np->tx_stop = 1;
 		spin_unlock_irq(&np->lock);
 		return NETDEV_TX_BUSY;
 	}
@@ -1813,6 +1808,7 @@
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
 	struct sk_buff *skb;
+	struct ring_desc* orig_get_tx = np->get_tx.orig;
 
 	while (np->get_tx.orig != np->put_tx.orig) {
 		flags = le32_to_cpu(np->get_tx.orig->flaglen);
@@ -1858,8 +1854,10 @@
 		if (np->get_tx_ctx++ == np->last_tx_ctx)
 			np->get_tx_ctx = np->first_tx_ctx;
 	}
-	if (nv_get_empty_tx_slots(np) > np->tx_limit_start)
+	if ((np->tx_stop == 1) && (np->get_tx.orig != orig_get_tx)) {
+		np->tx_stop = 0;
 		netif_wake_queue(dev);
+	}
 }
 
 static void nv_tx_done_optimized(struct net_device *dev)
@@ -1867,6 +1865,7 @@
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
 	struct sk_buff *skb;
+	struct ring_desc_ex* orig_get_tx = np->get_tx.ex;
 
 	while (np->get_tx.ex == np->put_tx.ex) {
 		flags = le32_to_cpu(np->get_tx.ex->flaglen);
@@ -1895,8 +1894,10 @@
 		if (np->get_tx_ctx++ == np->last_tx_ctx)
 			np->get_tx_ctx = np->first_tx_ctx;
 	}
-	if (nv_get_empty_tx_slots(np) > np->tx_limit_start)
+	if ((np->tx_stop == 1) && (np->get_tx.ex != orig_get_tx)) {
+		np->tx_stop = 0;
 		netif_wake_queue(dev);
+	}
 }
 
 /*
@@ -4001,8 +4002,6 @@
 	/* set new values */
 	np->rx_ring_size = ring->rx_pending;
 	np->tx_ring_size = ring->tx_pending;
-	np->tx_limit_stop = TX_LIMIT_DIFFERENCE;
-	np->tx_limit_start = TX_LIMIT_DIFFERENCE;
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
 		np->rx_ring.orig = (struct ring_desc*)rxtx_ring;
 		np->tx_ring.orig = &np->rx_ring.orig[np->rx_ring_size];
@@ -4967,8 +4966,6 @@
 
 	np->rx_ring_size = RX_RING_DEFAULT;
 	np->tx_ring_size = TX_RING_DEFAULT;
-	np->tx_limit_stop = TX_LIMIT_DIFFERENCE;
-	np->tx_limit_start = TX_LIMIT_DIFFERENCE;
 
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
 		np->rx_ring.orig = pci_alloc_consistent(pci_dev,

--------------080200070901010707070509--
