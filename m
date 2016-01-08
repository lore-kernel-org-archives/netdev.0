From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/5] i40e: Fix Rx hash reported to the stack by our driver
Date: Fri,  8 Jan 2016 02:14:42 -0800
Message-ID: <1452248083-78628-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1452248083-78628-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:38757 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754400AbcAHKO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 05:14:58 -0500
In-Reply-To: <1452248083-78628-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

If the driver calls skb_set_hash even with a zero hash, that
indicates to the stack that the hash calculation is offloaded
in hardware. So the Stack doesn't do a SW hash which is required
for load balancing if the user decides to turn of rx-hashing
on our device.

This patch fixes the path so that we do not call skb_set_hash
if the feature is disabled.

Change-ID: Ic4debfa4ff91b5a72e447348a75768ed7a2d3e1b
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 54 ++++++++++++++-------------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 54 ++++++++++++++-------------
 2 files changed, 58 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index e9e9a37..720516b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1422,31 +1422,12 @@ checksum_fail:
 }
 
 /**
- * i40e_rx_hash - returns the hash value from the Rx descriptor
- * @ring: descriptor ring
- * @rx_desc: specific descriptor
- **/
-static inline u32 i40e_rx_hash(struct i40e_ring *ring,
-			       union i40e_rx_desc *rx_desc)
-{
-	const __le64 rss_mask =
-		cpu_to_le64((u64)I40E_RX_DESC_FLTSTAT_RSS_HASH <<
-			    I40E_RX_DESC_STATUS_FLTSTAT_SHIFT);
-
-	if ((ring->netdev->features & NETIF_F_RXHASH) &&
-	    (rx_desc->wb.qword1.status_error_len & rss_mask) == rss_mask)
-		return le32_to_cpu(rx_desc->wb.qword0.hi_dword.rss);
-	else
-		return 0;
-}
-
-/**
- * i40e_ptype_to_hash - get a hash type
+ * i40e_ptype_to_htype - get a hash type
  * @ptype: the ptype value from the descriptor
  *
  * Returns a hash type to be used by skb_set_hash
  **/
-static inline enum pkt_hash_types i40e_ptype_to_hash(u8 ptype)
+static inline enum pkt_hash_types i40e_ptype_to_htype(u8 ptype)
 {
 	struct i40e_rx_ptype_decoded decoded = decode_rx_desc_ptype(ptype);
 
@@ -1464,6 +1445,30 @@ static inline enum pkt_hash_types i40e_ptype_to_hash(u8 ptype)
 }
 
 /**
+ * i40e_rx_hash - set the hash value in the skb
+ * @ring: descriptor ring
+ * @rx_desc: specific descriptor
+ **/
+static inline void i40e_rx_hash(struct i40e_ring *ring,
+				union i40e_rx_desc *rx_desc,
+				struct sk_buff *skb,
+				u8 rx_ptype)
+{
+	u32 hash;
+	const __le64 rss_mask  =
+		cpu_to_le64((u64)I40E_RX_DESC_FLTSTAT_RSS_HASH <<
+			    I40E_RX_DESC_STATUS_FLTSTAT_SHIFT);
+
+	if (ring->netdev->features & NETIF_F_RXHASH)
+		return;
+
+	if ((rx_desc->wb.qword1.status_error_len & rss_mask) == rss_mask) {
+		hash = le32_to_cpu(rx_desc->wb.qword0.hi_dword.rss);
+		skb_set_hash(skb, hash, i40e_ptype_to_htype(rx_ptype));
+	}
+}
+
+/**
  * i40e_clean_rx_irq_ps - Reclaim resources after receive; packet split
  * @rx_ring:  rx ring to clean
  * @budget:   how many cleans we're allowed
@@ -1612,8 +1617,8 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 			continue;
 		}
 
-		skb_set_hash(skb, i40e_rx_hash(rx_ring, rx_desc),
-			     i40e_ptype_to_hash(rx_ptype));
+		i40e_rx_hash(rx_ring, rx_desc, skb, rx_ptype);
+
 		if (unlikely(rx_status & I40E_RXD_QW1_STATUS_TSYNVALID_MASK)) {
 			i40e_ptp_rx_hwtstamp(vsi->back, skb, (rx_status &
 					   I40E_RXD_QW1_STATUS_TSYNINDX_MASK) >>
@@ -1741,8 +1746,7 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 			continue;
 		}
 
-		skb_set_hash(skb, i40e_rx_hash(rx_ring, rx_desc),
-			     i40e_ptype_to_hash(rx_ptype));
+		i40e_rx_hash(rx_ring, rx_desc, skb, rx_ptype);
 		if (unlikely(rx_status & I40E_RXD_QW1_STATUS_TSYNVALID_MASK)) {
 			i40e_ptp_rx_hwtstamp(vsi->back, skb, (rx_status &
 					   I40E_RXD_QW1_STATUS_TSYNINDX_MASK) >>
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 4ca4065..7a00657 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -886,31 +886,12 @@ checksum_fail:
 }
 
 /**
- * i40e_rx_hash - returns the hash value from the Rx descriptor
- * @ring: descriptor ring
- * @rx_desc: specific descriptor
- **/
-static inline u32 i40e_rx_hash(struct i40e_ring *ring,
-			       union i40e_rx_desc *rx_desc)
-{
-	const __le64 rss_mask =
-		cpu_to_le64((u64)I40E_RX_DESC_FLTSTAT_RSS_HASH <<
-			    I40E_RX_DESC_STATUS_FLTSTAT_SHIFT);
-
-	if ((ring->netdev->features & NETIF_F_RXHASH) &&
-	    (rx_desc->wb.qword1.status_error_len & rss_mask) == rss_mask)
-		return le32_to_cpu(rx_desc->wb.qword0.hi_dword.rss);
-	else
-		return 0;
-}
-
-/**
- * i40e_ptype_to_hash - get a hash type
+ * i40e_ptype_to_htype - get a hash type
  * @ptype: the ptype value from the descriptor
  *
  * Returns a hash type to be used by skb_set_hash
  **/
-static inline enum pkt_hash_types i40e_ptype_to_hash(u8 ptype)
+static inline enum pkt_hash_types i40e_ptype_to_htype(u8 ptype)
 {
 	struct i40e_rx_ptype_decoded decoded = decode_rx_desc_ptype(ptype);
 
@@ -928,6 +909,30 @@ static inline enum pkt_hash_types i40e_ptype_to_hash(u8 ptype)
 }
 
 /**
+ * i40e_rx_hash - set the hash value in the skb
+ * @ring: descriptor ring
+ * @rx_desc: specific descriptor
+ **/
+static inline void i40e_rx_hash(struct i40e_ring *ring,
+				union i40e_rx_desc *rx_desc,
+				struct sk_buff *skb,
+				u8 rx_ptype)
+{
+	u32 hash;
+	const __le64 rss_mask  =
+		cpu_to_le64((u64)I40E_RX_DESC_FLTSTAT_RSS_HASH <<
+			    I40E_RX_DESC_STATUS_FLTSTAT_SHIFT);
+
+	if (ring->netdev->features & NETIF_F_RXHASH)
+		return;
+
+	if ((rx_desc->wb.qword1.status_error_len & rss_mask) == rss_mask) {
+		hash = le32_to_cpu(rx_desc->wb.qword0.hi_dword.rss);
+		skb_set_hash(skb, hash, i40e_ptype_to_htype(rx_ptype));
+	}
+}
+
+/**
  * i40e_clean_rx_irq_ps - Reclaim resources after receive; packet split
  * @rx_ring:  rx ring to clean
  * @budget:   how many cleans we're allowed
@@ -1068,8 +1073,8 @@ static int i40e_clean_rx_irq_ps(struct i40e_ring *rx_ring, int budget)
 			continue;
 		}
 
-		skb_set_hash(skb, i40e_rx_hash(rx_ring, rx_desc),
-			     i40e_ptype_to_hash(rx_ptype));
+		i40e_rx_hash(rx_ring, rx_desc, skb, rx_ptype);
+
 		/* probably a little skewed due to removing CRC */
 		total_rx_bytes += skb->len;
 		total_rx_packets++;
@@ -1185,8 +1190,7 @@ static int i40e_clean_rx_irq_1buf(struct i40e_ring *rx_ring, int budget)
 			continue;
 		}
 
-		skb_set_hash(skb, i40e_rx_hash(rx_ring, rx_desc),
-			     i40e_ptype_to_hash(rx_ptype));
+		i40e_rx_hash(rx_ring, rx_desc, skb, rx_ptype);
 		/* probably a little skewed due to removing CRC */
 		total_rx_bytes += skb->len;
 		total_rx_packets++;
-- 
2.5.0
