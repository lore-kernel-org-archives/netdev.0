From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e/i40evf: try again after failure
Date: Wed, 17 Feb 2016 19:38:51 -0800
Message-ID: <1455766737-11911-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:4847 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424864AbcBRDjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 22:39:06 -0500
In-Reply-To: <1455766737-11911-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This is the "Don't Give Up" patch.  Previously the
driver could fail an allocation, and then possibly stall
a queue forever, by never coming back to continue receiving
or allocating buffers.

With this patch, the driver will keep polling trying to allocate
receive buffers until it succeeds.  This should keep all receive
queues running even in the face of memory pressure.

Also update copyright year in file header.

Change-ID: I2b103d1ce95b9831288a7222c3343ffa1988b81b
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 51 ++++++++++++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   |  6 ++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 51 ++++++++++++++++++++++-----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h |  4 +--
 4 files changed, 89 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 353e5a0..8049206 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1195,8 +1195,10 @@ static inline void i40e_release_rx_desc(struct i40e_ring *rx_ring, u32 val)
  * i40e_alloc_rx_buffers_ps - Replace used receive buffers; packet split
  * @rx_ring: ring to place buffers on
  * @cleaned_count: number of buffers to replace
+ *
+ * Returns true if any errors on allocation
  **/
-void i40e_alloc_rx_buffers_ps(struct i40e_ring *rx_ring, u16 cleaned_count)
+bool i40e_alloc_rx_buffers_ps(struct i40e_ring *rx_ring, u16 cleaned_count)
 {
 	u16 i = rx_ring->next_to_use;
 	union i40e_rx_desc *rx_desc;
@@ -1204,7 +1206,7 @@ void i40e_alloc_rx_buffers_ps(struct i40e_ring *rx_ring, u16 cleaned_count)
 
 	/* do nothing if no valid netdev defined */
 	if (!rx_ring->netdev || !cleaned_count)
-		return;
+		return false;
 
 	while (cleaned_count--) {
 		rx_desc = I40E_RX_DESC(rx_ring, i);
@@ -1251,17 +1253,29 @@ void i40e_alloc_rx_buffers_ps(struct i40e_ring *rx_ring, u16 cleaned_count)
 			i = 0;
 	}
 
+	if (rx_ring->next_to_use != i)
+		i40e_release_rx_desc(rx_ring, i);
+
+	return false;
+
 no_buffers:
 	if (rx_ring->next_to_use != i)
 		i40e_release_rx_desc(rx_ring, i);
+
+	/* make sure to come back via polling to try again after
+	 * allocation failure
+	 */
+	return true;
 }
 
 /**
  * i40e_alloc_rx_buffers_1buf - Replace used receive buffers; single buffer
  * @rx_ring: ring to place buffers on
  * @cleaned_count: number of buffers to replace
+ *
+ * Returns true if any errors on allocation
  **/
-void i40e_alloc_rx_buffers_1buf(struct i40e_ring *rx_ring, u16 cleaned_count)
+bool i40e_alloc_rx_buffers_1buf(struct i40e_ring *rx_ring, u16 cleaned_count)
 {
 	u16 i = rx_ring->next_to_use;
 	union i40e_rx_desc *rx_desc;
@@ -1270,7 +1284,7 @@ void i40e_alloc_rx_buffers_1buf(struct i40e_ring *rx_ring, u16 cleaned_count)
 
 	/* do nothing if no valid netdev defined */
 	if (!rx_ring->netdev || !cleaned_count)
-		return;
+		return false;
 
 	while (cleaned_count--) {
 		rx_desc = I40E_RX_DESC(rx_ring, i);
@@ -1297,6 +1311,8 @@ void i40e_alloc_rx_buffers_1buf(struct i40e_ring *rx_ring, u16 cleaned_count)
 			if (dma_mapping_error(rx_ring->dev, bi->dma)) {
 				rx_ring->rx_stats.alloc_buff_failed++;
 				bi->dma = 0;
+				dev_kfree_skb(bi->skb);
+				bi->skb = NULL;
 				goto no_buffers;
 			}
 		}
@@ -1308,9 +1324,19 @@ void i40e_alloc_rx_buffers_1buf(struct i40e_ring *rx_ring, u16 cleaned_count)
 			i = 0;
 	}
 
+	if (rx_ring->next_to_use != i)
+		i40e_release_rx_desc(rx_ring, i);
+
+	return false;
+
 no_buffers:
 	if (rx_ring->next_to_use != i)
 		i40e_release_rx_desc(rx_ring, i);
+
+	/* make sure to come back via polling to try again after
+	 * allocation failure
+	 */
+	return true;
 }
 
 /**
@@ -1494,7 +1520,7 @@ static inline void i40e_rx_hash(struct i40e_ring *ring,
  *
  * Returns true if there's any budget left (e.g. the clean is finished)
  **/
-static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
+static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, const int budget)
 {
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 	u16 rx_packet_len, rx_header_len, rx_sph, rx_hbo;
@@ -1504,6 +1530,7 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 	u16 i = rx_ring->next_to_clean;
 	union i40e_rx_desc *rx_desc;
 	u32 rx_error, rx_status;
+	bool failure = false;
 	u8 rx_ptype;
 	u64 qword;
 
@@ -1516,7 +1543,9 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 		u16 vlan_tag;
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= I40E_RX_BUFFER_WRITE) {
-			i40e_alloc_rx_buffers_ps(rx_ring, cleaned_count);
+			failure = failure ||
+				  i40e_alloc_rx_buffers_ps(rx_ring,
+							   cleaned_count);
 			cleaned_count = 0;
 		}
 
@@ -1546,6 +1575,7 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 							rx_ring->rx_hdr_len);
 			if (!skb) {
 				rx_ring->rx_stats.alloc_buff_failed++;
+				failure = true;
 				break;
 			}
 
@@ -1675,7 +1705,7 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 	rx_ring->q_vector->rx.total_packets += total_rx_packets;
 	rx_ring->q_vector->rx.total_bytes += total_rx_bytes;
 
-	return total_rx_packets;
+	return failure ? budget : total_rx_packets;
 }
 
 /**
@@ -1693,6 +1723,7 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 	union i40e_rx_desc *rx_desc;
 	u32 rx_error, rx_status;
 	u16 rx_packet_len;
+	bool failure = false;
 	u8 rx_ptype;
 	u64 qword;
 	u16 i;
@@ -1703,7 +1734,9 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 		u16 vlan_tag;
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= I40E_RX_BUFFER_WRITE) {
-			i40e_alloc_rx_buffers_1buf(rx_ring, cleaned_count);
+			failure = failure ||
+				  i40e_alloc_rx_buffers_1buf(rx_ring,
+							     cleaned_count);
 			cleaned_count = 0;
 		}
 
@@ -1802,7 +1835,7 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 	rx_ring->q_vector->rx.total_packets += total_rx_packets;
 	rx_ring->q_vector->rx.total_bytes += total_rx_bytes;
 
-	return total_rx_packets;
+	return failure ? budget : total_rx_packets;
 }
 
 static u32 i40e_buildreg_itr(const int type, const u16 itr)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 3f081e2..5c73f3d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2016 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -316,8 +316,8 @@ struct i40e_ring_container {
 #define i40e_for_each_ring(pos, head) \
 	for (pos = (head).ring; pos != NULL; pos = pos->next)
 
-void i40e_alloc_rx_buffers_ps(struct i40e_ring *rxr, u16 cleaned_count);
-void i40e_alloc_rx_buffers_1buf(struct i40e_ring *rxr, u16 cleaned_count);
+bool i40e_alloc_rx_buffers_ps(struct i40e_ring *rxr, u16 cleaned_count);
+bool i40e_alloc_rx_buffers_1buf(struct i40e_ring *rxr, u16 cleaned_count);
 void i40e_alloc_rx_headers(struct i40e_ring *rxr);
 netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 void i40e_clean_tx_ring(struct i40e_ring *tx_ring);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 6210424..616daae 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -667,8 +667,10 @@ static inline void i40e_release_rx_desc(struct i40e_ring *rx_ring, u32 val)
  * i40evf_alloc_rx_buffers_ps - Replace used receive buffers; packet split
  * @rx_ring: ring to place buffers on
  * @cleaned_count: number of buffers to replace
+ *
+ * Returns true if any errors on allocation
  **/
-void i40evf_alloc_rx_buffers_ps(struct i40e_ring *rx_ring, u16 cleaned_count)
+bool i40evf_alloc_rx_buffers_ps(struct i40e_ring *rx_ring, u16 cleaned_count)
 {
 	u16 i = rx_ring->next_to_use;
 	union i40e_rx_desc *rx_desc;
@@ -676,7 +678,7 @@ void i40evf_alloc_rx_buffers_ps(struct i40e_ring *rx_ring, u16 cleaned_count)
 
 	/* do nothing if no valid netdev defined */
 	if (!rx_ring->netdev || !cleaned_count)
-		return;
+		return false;
 
 	while (cleaned_count--) {
 		rx_desc = I40E_RX_DESC(rx_ring, i);
@@ -723,17 +725,29 @@ void i40evf_alloc_rx_buffers_ps(struct i40e_ring *rx_ring, u16 cleaned_count)
 			i = 0;
 	}
 
+	if (rx_ring->next_to_use != i)
+		i40e_release_rx_desc(rx_ring, i);
+
+	return false;
+
 no_buffers:
 	if (rx_ring->next_to_use != i)
 		i40e_release_rx_desc(rx_ring, i);
+
+	/* make sure to come back via polling to try again after
+	 * allocation failure
+	 */
+	return true;
 }
 
 /**
  * i40evf_alloc_rx_buffers_1buf - Replace used receive buffers; single buffer
  * @rx_ring: ring to place buffers on
  * @cleaned_count: number of buffers to replace
+ *
+ * Returns true if any errors on allocation
  **/
-void i40evf_alloc_rx_buffers_1buf(struct i40e_ring *rx_ring, u16 cleaned_count)
+bool i40evf_alloc_rx_buffers_1buf(struct i40e_ring *rx_ring, u16 cleaned_count)
 {
 	u16 i = rx_ring->next_to_use;
 	union i40e_rx_desc *rx_desc;
@@ -742,7 +756,7 @@ void i40evf_alloc_rx_buffers_1buf(struct i40e_ring *rx_ring, u16 cleaned_count)
 
 	/* do nothing if no valid netdev defined */
 	if (!rx_ring->netdev || !cleaned_count)
-		return;
+		return false;
 
 	while (cleaned_count--) {
 		rx_desc = I40E_RX_DESC(rx_ring, i);
@@ -769,6 +783,8 @@ void i40evf_alloc_rx_buffers_1buf(struct i40e_ring *rx_ring, u16 cleaned_count)
 			if (dma_mapping_error(rx_ring->dev, bi->dma)) {
 				rx_ring->rx_stats.alloc_buff_failed++;
 				bi->dma = 0;
+				dev_kfree_skb(bi->skb);
+				bi->skb = NULL;
 				goto no_buffers;
 			}
 		}
@@ -780,9 +796,19 @@ void i40evf_alloc_rx_buffers_1buf(struct i40e_ring *rx_ring, u16 cleaned_count)
 			i = 0;
 	}
 
+	if (rx_ring->next_to_use != i)
+		i40e_release_rx_desc(rx_ring, i);
+
+	return false;
+
 no_buffers:
 	if (rx_ring->next_to_use != i)
 		i40e_release_rx_desc(rx_ring, i);
+
+	/* make sure to come back via polling to try again after
+	 * allocation failure
+	 */
+	return true;
 }
 
 /**
@@ -965,7 +991,7 @@ static inline void i40e_rx_hash(struct i40e_ring *ring,
  *
  * Returns true if there's any budget left (e.g. the clean is finished)
  **/
-static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
+static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, const int budget)
 {
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 	u16 rx_packet_len, rx_header_len, rx_sph, rx_hbo;
@@ -975,6 +1001,7 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 	u16 i = rx_ring->next_to_clean;
 	union i40e_rx_desc *rx_desc;
 	u32 rx_error, rx_status;
+	bool failure = false;
 	u8 rx_ptype;
 	u64 qword;
 
@@ -984,7 +1011,9 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 		u16 vlan_tag;
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= I40E_RX_BUFFER_WRITE) {
-			i40evf_alloc_rx_buffers_ps(rx_ring, cleaned_count);
+			failure = failure ||
+				  i40evf_alloc_rx_buffers_ps(rx_ring,
+							     cleaned_count);
 			cleaned_count = 0;
 		}
 
@@ -1009,6 +1038,7 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 							rx_ring->rx_hdr_len);
 			if (!skb) {
 				rx_ring->rx_stats.alloc_buff_failed++;
+				failure = true;
 				break;
 			}
 
@@ -1131,7 +1161,7 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 	rx_ring->q_vector->rx.total_packets += total_rx_packets;
 	rx_ring->q_vector->rx.total_bytes += total_rx_bytes;
 
-	return total_rx_packets;
+	return failure ? budget : total_rx_packets;
 }
 
 /**
@@ -1149,6 +1179,7 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 	union i40e_rx_desc *rx_desc;
 	u32 rx_error, rx_status;
 	u16 rx_packet_len;
+	bool failure = false;
 	u8 rx_ptype;
 	u64 qword;
 	u16 i;
@@ -1159,7 +1190,9 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 		u16 vlan_tag;
 		/* return some buffers to hardware, one at a time is too slow */
 		if (cleaned_count >= I40E_RX_BUFFER_WRITE) {
-			i40evf_alloc_rx_buffers_1buf(rx_ring, cleaned_count);
+			failure = failure ||
+				  i40evf_alloc_rx_buffers_1buf(rx_ring,
+							       cleaned_count);
 			cleaned_count = 0;
 		}
 
@@ -1240,7 +1273,7 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 	rx_ring->q_vector->rx.total_packets += total_rx_packets;
 	rx_ring->q_vector->rx.total_bytes += total_rx_bytes;
 
-	return total_rx_packets;
+	return failure ? budget : total_rx_packets;
 }
 
 static u32 i40e_buildreg_itr(const int type, const u16 itr)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index da701c5..d8071ba 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -313,8 +313,8 @@ struct i40e_ring_container {
 #define i40e_for_each_ring(pos, head) \
 	for (pos = (head).ring; pos != NULL; pos = pos->next)
 
-void i40evf_alloc_rx_buffers_ps(struct i40e_ring *rxr, u16 cleaned_count);
-void i40evf_alloc_rx_buffers_1buf(struct i40e_ring *rxr, u16 cleaned_count);
+bool i40evf_alloc_rx_buffers_ps(struct i40e_ring *rxr, u16 cleaned_count);
+bool i40evf_alloc_rx_buffers_1buf(struct i40e_ring *rxr, u16 cleaned_count);
 void i40evf_alloc_rx_headers(struct i40e_ring *rxr);
 netdev_tx_t i40evf_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 void i40evf_clean_tx_ring(struct i40e_ring *tx_ring);
-- 
2.5.0
