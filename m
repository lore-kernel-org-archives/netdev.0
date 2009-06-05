From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 08/10] ixgbe: Re-adjust ring layouts to have better
	cacheline efficiency
Date: Thu, 04 Jun 2009 19:02:04 -0700
Message-ID: <20090605020203.8468.58021.stgit@localhost.localdomain>
References: <20090605015948.8468.25862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:53549 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753201AbZFECCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 22:02:20 -0400
In-Reply-To: <20090605015948.8468.25862.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This patch rearranges the ixgbe_ring struct to make better use of
cacheline efficiency.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h |   35 +++++++++++++++++++----------------
 1 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index f2206e2..cd22323 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -121,19 +121,18 @@ struct ixgbe_queue_stats {
 
 struct ixgbe_ring {
 	void *desc;			/* descriptor ring memory */
-	dma_addr_t dma;			/* phys. address of descriptor ring */
-	unsigned int size;		/* length in bytes */
-	unsigned int count;		/* amount of descriptors */
-	unsigned int next_to_use;
-	unsigned int next_to_clean;
-	u8 atr_sample_rate;
-	u8 atr_count;
-
-	int queue_index; /* needed for multiqueue queue management */
 	union {
 		struct ixgbe_tx_buffer *tx_buffer_info;
 		struct ixgbe_rx_buffer *rx_buffer_info;
 	};
+	u8 atr_sample_rate;
+	u8 atr_count;
+	u16 count;			/* amount of descriptors */
+	u16 rx_buf_len;
+	u16 next_to_use;
+	u16 next_to_clean;
+
+	u8 queue_index; /* needed for multiqueue queue management */
 
 	u16 head;
 	u16 tail;
@@ -141,20 +140,24 @@ struct ixgbe_ring {
 	unsigned int total_bytes;
 	unsigned int total_packets;
 
-	u16 reg_idx; /* holds the special value that gets the hardware register
-		      * offset associated with this ring, which is different
-		      * for DCB and RSS modes */
-
 #ifdef CONFIG_IXGBE_DCA
 	/* cpu for tx queue */
 	int cpu;
 #endif
+
+	u16 work_limit;			/* max work per interrupt */
+	u16 reg_idx;			/* holds the special value that gets
+					 * the hardware register offset
+					 * associated with this ring, which is
+					 * different for DCB and RSS modes
+					 */
+
 	struct ixgbe_queue_stats stats;
 	unsigned long reinit_state;
+	u64 rsc_count;			/* stat for coalesced packets */
 
-	u16 work_limit;                /* max work per interrupt */
-	u16 rx_buf_len;
-	u64 rsc_count;                 /* stat for coalesced packets */
+	unsigned int size;		/* length in bytes */
+	dma_addr_t dma;			/* phys. address of descriptor ring */
 };
 
 enum ixgbe_ring_f_enum {

