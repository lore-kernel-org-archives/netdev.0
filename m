From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 2/8] vxge: Fix starvation of receive ring
 controller when blasted by short packets.
Date: Mon, 29 Mar 2010 04:08:30 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.11003290407500.4435-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:48127 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858Ab0C2IXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 04:23:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Fix starvation of receive ring controller when blasted by short packets. This was because the driver was posting 64 rxds initially while the ring controller 
was expecting to read 256 replenished rxds. While the driver was coming up, 
the internal rxd memory filled up the 64 buffers provided and the ring 
controller was left waiting for the remaining 192 rxds to complete the write
back of completed rxds to the host and generation of an interrupt.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch1/drivers/net/vxge/vxge-config.c patch2/drivers/net/vxge/vxge-config.c
--- patch1/drivers/net/vxge/vxge-config.c	2010-03-19 15:49:16.000000000 +0530
+++ patch2/drivers/net/vxge/vxge-config.c	2010-03-19 16:16:11.000000000 +0530
@@ -1217,14 +1217,13 @@ __vxge_hw_ring_mempool_item_alloc(struct
 }
 
 /*
- * __vxge_hw_ring_initial_replenish - Initial replenish of RxDs
+ * __vxge_hw_ring_replenish - Initial replenish of RxDs
  * This function replenishes the RxDs from reserve array to work array
  */
 enum vxge_hw_status
-vxge_hw_ring_replenish(struct __vxge_hw_ring *ring, u16 min_flag)
+vxge_hw_ring_replenish(struct __vxge_hw_ring *ring)
 {
 	void *rxd;
-	int i = 0;
 	struct __vxge_hw_channel *channel;
 	enum vxge_hw_status status = VXGE_HW_OK;
 
@@ -1245,11 +1244,6 @@ vxge_hw_ring_replenish(struct __vxge_hw_
 		}
 
 		vxge_hw_ring_rxd_post(ring, rxd);
-		if (min_flag) {
-			i++;
-			if (i == VXGE_HW_RING_MIN_BUFF_ALLOCATION)
-				break;
-		}
 	}
 	status = VXGE_HW_OK;
 exit:
@@ -1354,7 +1348,7 @@ __vxge_hw_ring_create(struct __vxge_hw_v
 	 * Currently we don't have a case when the 1) is done without the 2).
 	 */
 	if (ring->rxd_init) {
-		status = vxge_hw_ring_replenish(ring, 1);
+		status = vxge_hw_ring_replenish(ring);
 		if (status != VXGE_HW_OK) {
 			__vxge_hw_ring_delete(vp);
 			goto exit;
@@ -1416,7 +1410,7 @@ enum vxge_hw_status __vxge_hw_ring_reset
 		goto exit;
 
 	if (ring->rxd_init) {
-		status = vxge_hw_ring_replenish(ring, 1);
+		status = vxge_hw_ring_replenish(ring);
 		if (status != VXGE_HW_OK)
 			goto exit;
 	}
diff -urpN patch1/drivers/net/vxge/vxge-main.c patch2/drivers/net/vxge/vxge-main.c
--- patch1/drivers/net/vxge/vxge-main.c	2010-03-19 15:49:16.000000000 +0530
+++ patch2/drivers/net/vxge/vxge-main.c	2010-03-19 16:11:49.000000000 +0530
@@ -444,7 +444,7 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *
 		ring->ndev->name, __func__, __LINE__);
 	ring->pkts_processed = 0;
 
-	vxge_hw_ring_replenish(ringh, 0);
+	vxge_hw_ring_replenish(ringh);
 
 	do {
 		prefetch((char *)dtr + L1_CACHE_BYTES);
diff -urpN patch1/drivers/net/vxge/vxge-traffic.h patch2/drivers/net/vxge/vxge-traffic.h
--- patch1/drivers/net/vxge/vxge-traffic.h	2010-03-19 15:55:56.000000000 +0530
+++ patch2/drivers/net/vxge/vxge-traffic.h	2010-03-19 16:12:31.000000000 +0530
@@ -1955,7 +1955,7 @@ vxge_hw_ring_rxd_post_post(
 	void *rxdh);
 
 enum vxge_hw_status
-vxge_hw_ring_replenish(struct __vxge_hw_ring *ring_handle, u16 min_flag);
+vxge_hw_ring_replenish(struct __vxge_hw_ring *ring_handle);
 
 void
 vxge_hw_ring_rxd_post_post_wmb(
@@ -2087,7 +2087,6 @@ void vxge_hw_fifo_txdl_free(
 
 #define VXGE_HW_RING_NEXT_BLOCK_POINTER_OFFSET	(VXGE_HW_BLOCK_SIZE-8)
 #define VXGE_HW_RING_MEMBLOCK_IDX_OFFSET		(VXGE_HW_BLOCK_SIZE-16)
-#define VXGE_HW_RING_MIN_BUFF_ALLOCATION		64
 
 /*
  * struct __vxge_hw_ring_rxd_priv - Receive descriptor HW-private data.

