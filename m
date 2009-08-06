From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] ixgbe: Disable packet split only on FCoE queues
	in 82599
Date: Thu, 06 Aug 2009 16:05:44 -0700
Message-ID: <20090806230544.28347.97373.stgit@localhost.localdomain>
References: <20090806230514.28347.51172.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:52433
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752978AbZHFXGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 19:06:04 -0400
In-Reply-To: <20090806230514.28347.51172.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

For 82599, packet split has to be disabled for FCoE direct data placement.
However, this is only required on received queues allocated for FCoE. This
patch adds a per ring flags to indicate if packet split is disabled on a
per queue basis, particularly for FCoE, as packet split must be disabled
for large receive using direct data placement (DDP).

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    2 ++
 drivers/net/ixgbe/ixgbe_main.c |   33 +++++++++++++++++----------------
 2 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index e11d83d..2c4dc82 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -136,6 +136,8 @@ struct ixgbe_ring {
 
 	u8 queue_index; /* needed for multiqueue queue management */
 
+#define IXGBE_RING_RX_PS_ENABLED                (u8)(1)
+	u8 flags;			/* per ring feature flags */
 	u16 head;
 	u16 tail;
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e361b7f..e3cb949 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -585,7 +585,7 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 		rx_desc = IXGBE_RX_DESC_ADV(*rx_ring, i);
 
 		if (!bi->page_dma &&
-		    (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)) {
+		    (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED)) {
 			if (!bi->page) {
 				bi->page = alloc_page(GFP_ATOMIC);
 				if (!bi->page) {
@@ -629,7 +629,7 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 		}
 		/* Refresh the desc even if buffer_addrs didn't change because
 		 * each write-back erases this info. */
-		if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
+		if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
 			rx_desc->read.pkt_addr = cpu_to_le64(bi->page_dma);
 			rx_desc->read.hdr_addr = cpu_to_le64(bi->dma);
 		} else {
@@ -726,7 +726,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			break;
 		(*work_done)++;
 
-		if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
+		if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
 			hdr_info = le16_to_cpu(ixgbe_get_hdr_info(rx_desc));
 			len = (hdr_info & IXGBE_RXDADV_HDRBUFLEN_MASK) >>
 			       IXGBE_RXDADV_HDRBUFLEN_SHIFT;
@@ -798,7 +798,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			rx_ring->stats.packets++;
 			rx_ring->stats.bytes += skb->len;
 		} else {
-			if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
+			if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
 				rx_buffer_info->skb = next_buffer->skb;
 				rx_buffer_info->dma = next_buffer->dma;
 				next_buffer->skb = skb;
@@ -1919,7 +1919,7 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
 	srrctl |= (IXGBE_RX_HDR_SIZE << IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT) &
 		  IXGBE_SRRCTL_BSIZEHDR_MASK;
 
-	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
+	if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
 #if (PAGE_SIZE / 2) > IXGBE_MAX_RXBUFFER
 		srrctl |= IXGBE_MAX_RXBUFFER >> IXGBE_SRRCTL_BSIZEPKT_SHIFT;
 #else
@@ -1992,11 +1992,6 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	/* Decide whether to use packet split mode or not */
 	adapter->flags |= IXGBE_FLAG_RX_PS_ENABLED;
 
-#ifdef IXGBE_FCOE
-	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
-		adapter->flags &= ~IXGBE_FLAG_RX_PS_ENABLED;
-#endif /* IXGBE_FCOE */
-
 	/* Set the RX buffer length according to the mode */
 	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
 		rx_buf_len = IXGBE_RX_HDR_SIZE;
@@ -2056,14 +2051,19 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		rx_ring->tail = IXGBE_RDT(j);
 		rx_ring->rx_buf_len = rx_buf_len;
 
+		if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)
+			rx_ring->flags |= IXGBE_RING_RX_PS_ENABLED;
+
 #ifdef IXGBE_FCOE
 		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
 			struct ixgbe_ring_feature *f;
 			f = &adapter->ring_feature[RING_F_FCOE];
-			if ((rx_buf_len < IXGBE_FCOE_JUMBO_FRAME_SIZE) &&
-			    (i >= f->mask) && (i < f->mask + f->indices))
-				rx_ring->rx_buf_len =
-				        IXGBE_FCOE_JUMBO_FRAME_SIZE;
+			if ((i >= f->mask) && (i < f->mask + f->indices)) {
+				rx_ring->flags &= ~IXGBE_RING_RX_PS_ENABLED;
+				if (rx_buf_len < IXGBE_FCOE_JUMBO_FRAME_SIZE)
+					rx_ring->rx_buf_len =
+					        IXGBE_FCOE_JUMBO_FRAME_SIZE;
+			}
 		}
 
 #endif /* IXGBE_FCOE */
@@ -2143,7 +2143,8 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
 		/* Enable 82599 HW-RSC */
 		for (i = 0; i < adapter->num_rx_queues; i++) {
-			j = adapter->rx_ring[i].reg_idx;
+			rx_ring = &adapter->rx_ring[i];
+			j = rx_ring->reg_idx;
 			rscctrl = IXGBE_READ_REG(hw, IXGBE_RSCCTL(j));
 			rscctrl |= IXGBE_RSCCTL_RSCEN;
 			/*
@@ -2151,7 +2152,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 			 * total size of max desc * buf_len is not greater
 			 * than 65535
 			 */
-			if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
+			if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
 #if (MAX_SKB_FRAGS > 16)
 				rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
 #elif (MAX_SKB_FRAGS > 8)

