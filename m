From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 4/5] atl1: fix excessively indented code
Date: Sun, 15 Jul 2007 11:03:28 -0500
Message-ID: <11845154092630-git-send-email-jacliburn@bellsouth.net>
References: <11845154092908-git-send-email-jacliburn@bellsouth.net>
Cc: jacliburn@bellsouth.net, csnook@redhat.com,
	atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf18aec.mail.bellsouth.net ([205.152.59.66]:34572 "EHLO
	imf18aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759243AbXGOQDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 12:03:32 -0400
In-Reply-To: <11845154092908-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move excessively indented code to separate functions.  Also move ring
pointer initialization to its own function.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atl1/atl1_main.c |   86 ++++++++++++++++++++++++-----------------
 1 files changed, 50 insertions(+), 36 deletions(-)

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index b40f1c7..67ddf8d 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -220,8 +220,6 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 	tpd_ring->dma += offset;
 	tpd_ring->desc = (u8 *) ring_header->desc + offset;
 	tpd_ring->size = sizeof(struct tx_packet_desc) * tpd_ring->count;
-	atomic_set(&tpd_ring->next_to_use, 0);
-	atomic_set(&tpd_ring->next_to_clean, 0);
 
 	/* init RFD ring */
 	rfd_ring->dma = tpd_ring->dma + tpd_ring->size;
@@ -229,8 +227,7 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 	rfd_ring->dma += offset;
 	rfd_ring->desc = (u8 *) tpd_ring->desc + (tpd_ring->size + offset);
 	rfd_ring->size = sizeof(struct rx_free_desc) * rfd_ring->count;
-	rfd_ring->next_to_clean = 0;
-	atomic_set(&rfd_ring->next_to_use, 0);
+
 
 	/* init RRD ring */
 	rrd_ring->dma = rfd_ring->dma + rfd_ring->size;
@@ -238,8 +235,7 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 	rrd_ring->dma += offset;
 	rrd_ring->desc = (u8 *) rfd_ring->desc + (rfd_ring->size + offset);
 	rrd_ring->size = sizeof(struct rx_return_desc) * rrd_ring->count;
-	rrd_ring->next_to_use = 0;
-	atomic_set(&rrd_ring->next_to_clean, 0);
+
 
 	/* init CMB */
 	adapter->cmb.dma = rrd_ring->dma + rrd_ring->size;
@@ -263,6 +259,22 @@ err_nomem:
 	return -ENOMEM;
 }
 
+void atl1_init_ring_ptrs(struct atl1_adapter *adapter)
+{
+	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
+	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
+	struct atl1_rrd_ring *rrd_ring = &adapter->rrd_ring;
+
+	atomic_set(&tpd_ring->next_to_use, 0);
+	atomic_set(&tpd_ring->next_to_clean, 0);
+
+	rfd_ring->next_to_clean = 0;
+	atomic_set(&rfd_ring->next_to_use, 0);
+
+	rrd_ring->next_to_use = 0;
+	atomic_set(&rrd_ring->next_to_clean, 0);
+}
+
 /*
  * atl1_irq_enable - Enable default interrupt generation settings
  * @adapter: board private structure
@@ -472,6 +484,31 @@ next:
 	return num_alloc;
 }
 
+static void atl1_clean_alloc_flag(struct atl1_adapter *adapter,
+	struct rx_return_desc *rrd, u16 offset)
+{
+	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
+
+	while (rfd_ring->next_to_clean != (rrd->buf_indx + offset)) {
+		rfd_ring->buffer_info[rfd_ring->next_to_clean].alloced = 0;
+		if (++rfd_ring->next_to_clean == rfd_ring->count) {
+			rfd_ring->next_to_clean = 0;
+		}
+	}
+}
+
+static void atl1_update_rfd_index(struct atl1_adapter *adapter,
+	struct rx_return_desc *rrd)
+{
+	u16 num_buf;
+
+	num_buf = (rrd->xsz.xsum_sz.pkt_size + adapter->rx_buffer_len - 1) /
+		adapter->rx_buffer_len;
+	if (rrd->num_buf == num_buf)
+		/* clean alloc flag for bad rrd */
+		atl1_clean_alloc_flag(adapter, rrd, num_buf);
+}
+
 static void atl1_intr_rx(struct atl1_adapter *adapter)
 {
 	int i, count;
@@ -509,26 +546,8 @@ chk_rrd:
 			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
 				"bad RRD\n");
 			/* see if update RFD index */
-			if (rrd->num_buf > 1) {
-				u16 num_buf;
-				num_buf =
-				    (rrd->xsz.xsum_sz.pkt_size +
-				     adapter->rx_buffer_len -
-				     1) / adapter->rx_buffer_len;
-				if (rrd->num_buf == num_buf) {
-					/* clean alloc flag for bad rrd */
-					while (rfd_ring->next_to_clean !=
-					       (rrd->buf_indx + num_buf)) {
-						rfd_ring->buffer_info[rfd_ring->
-								      next_to_clean].alloced = 0;
-						if (++rfd_ring->next_to_clean ==
-						    rfd_ring->count) {
-							rfd_ring->
-							    next_to_clean = 0;
-						}
-					}
-				}
-			}
+			if (rrd->num_buf > 1)
+				atl1_update_rfd_index(adapter, rrd);
 
 			/* update rrd */
 			rrd->xsz.valid = 0;
@@ -542,12 +561,7 @@ chk_rrd:
 		}
 rrd_ok:
 		/* clean alloc flag for bad rrd */
-		while (rfd_ring->next_to_clean != rrd->buf_indx) {
-			rfd_ring->buffer_info[rfd_ring->next_to_clean].alloced =
-			    0;
-			if (++rfd_ring->next_to_clean == rfd_ring->count)
-				rfd_ring->next_to_clean = 0;
-		}
+		atl1_clean_alloc_flag(adapter, rrd, 0);
 
 		buffer_info = &rfd_ring->buffer_info[rrd->buf_indx];
 		if (++rfd_ring->next_to_clean == rfd_ring->count)
@@ -1058,7 +1072,8 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 	value <<= 16;
 	value += adapter->rfd_ring.count;
 	iowrite32(value, hw->hw_addr + REG_DESC_RFD_RRD_RING_SIZE);
-	iowrite32(adapter->tpd_ring.count, hw->hw_addr + REG_DESC_TPD_RING_SIZE);
+	iowrite32(adapter->tpd_ring.count, hw->hw_addr +
+		REG_DESC_TPD_RING_SIZE);
 
 	/* Load Ptr */
 	iowrite32(1, hw->hw_addr + REG_LOAD_PTR);
@@ -1258,9 +1273,7 @@ static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
 			iph->tot_len = 0;
 			iph->check = 0;
 			tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr,
-								 iph->daddr, 0,
-								 IPPROTO_TCP,
-								 0);
+				iph->daddr, 0, IPPROTO_TCP, 0);
 			ipofst = skb_network_offset(skb);
 			if (ipofst != ENET_HEADER_SIZE) /* 802.3 frame */
 				tso->tsopl |= 1 << TSO_PARAM_ETHTYPE_SHIFT;
@@ -1721,6 +1734,7 @@ s32 atl1_up(struct atl1_adapter *adapter)
 
 	/* hardware has been reset, we need to reload some things */
 	atl1_set_multi(netdev);
+	atl1_init_ring_ptrs(adapter);
 	atl1_restore_vlan(adapter);
 	err = atl1_alloc_rx_buffers(adapter);
 	if (unlikely(!err))		/* no RX BUFFER allocated */
-- 
1.5.2.2

