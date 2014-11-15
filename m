From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/12] i40e: Handle a single mss packet with more than 8 frags
Date: Fri, 14 Nov 2014 22:08:26 -0800
Message-ID: <1416031715-32498-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Serey Kong <serey.kong@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4893 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353AbaKOGIj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2014 01:08:39 -0500
In-Reply-To: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Serey Kong <serey.kong@intel.com>

This handles the case where a single packet with more than 8 data
descriptors triggers a Malicious Driver Detect event in the device.

Change-ID: I2bfd657fd036bed616863e121f6aa86a35d2194c
Signed-off-by: Serey Kong <serey.kong@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 14 ++++++++++----
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 14 ++++++++++----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h |  1 +
 4 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 3195d82..9731026 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2113,12 +2113,12 @@ static void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 			const u8 hdr_len, u32 td_cmd, u32 td_offset)
 #endif
 {
-	unsigned int data_len = skb->data_len;
-	unsigned int size = skb_headlen(skb);
 	struct skb_frag_struct *frag;
 	struct i40e_tx_buffer *tx_bi;
 	struct i40e_tx_desc *tx_desc;
 	u16 i = tx_ring->next_to_use;
+	unsigned int data_len;
+	unsigned int size;
 	u32 td_tag = 0;
 	dma_addr_t dma;
 	u16 gso_segs;
@@ -2129,10 +2129,16 @@ static void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 			 I40E_TX_FLAGS_VLAN_SHIFT;
 	}
 
-	if (tx_flags & (I40E_TX_FLAGS_TSO | I40E_TX_FLAGS_FSO))
+	if (tx_flags & (I40E_TX_FLAGS_TSO | I40E_TX_FLAGS_FSO)) {
 		gso_segs = skb_shinfo(skb)->gso_segs;
-	else
+	} else {
 		gso_segs = 1;
+		if (skb_shinfo(skb)->nr_frags >= I40E_MAX_BUFFER_TXD)
+			skb_linearize(skb);
+	}
+
+	data_len = skb->data_len;
+	size = skb_headlen(skb);
 
 	/* multiply data chunks by size of headers */
 	first->bytecount = skb->len - hdr_len + (gso_segs * hdr_len);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index e60d3ac..52f692d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -112,6 +112,7 @@ enum i40e_dyn_idx_t {
 
 #define i40e_rx_desc i40e_32byte_rx_desc
 
+#define I40E_MAX_BUFFER_TXD	8
 #define I40E_MIN_TX_LEN		17
 #define I40E_MAX_DATA_PER_TXD	8192
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 04c7c15..b9a554f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1358,12 +1358,12 @@ static void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 			struct i40e_tx_buffer *first, u32 tx_flags,
 			const u8 hdr_len, u32 td_cmd, u32 td_offset)
 {
-	unsigned int data_len = skb->data_len;
-	unsigned int size = skb_headlen(skb);
 	struct skb_frag_struct *frag;
 	struct i40e_tx_buffer *tx_bi;
 	struct i40e_tx_desc *tx_desc;
 	u16 i = tx_ring->next_to_use;
+	unsigned int data_len;
+	unsigned int size;
 	u32 td_tag = 0;
 	dma_addr_t dma;
 	u16 gso_segs;
@@ -1374,10 +1374,16 @@ static void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 			 I40E_TX_FLAGS_VLAN_SHIFT;
 	}
 
-	if (tx_flags & (I40E_TX_FLAGS_TSO | I40E_TX_FLAGS_FSO))
+	if (tx_flags & (I40E_TX_FLAGS_TSO | I40E_TX_FLAGS_FSO)) {
 		gso_segs = skb_shinfo(skb)->gso_segs;
-	else
+	} else {
 		gso_segs = 1;
+		if (skb_shinfo(skb)->nr_frags >= I40E_MAX_BUFFER_TXD)
+			skb_linearize(skb);
+	}
+
+	data_len = skb->data_len;
+	size = skb_headlen(skb);
 
 	/* multiply data chunks by size of headers */
 	first->bytecount = skb->len - hdr_len + (gso_segs * hdr_len);
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index c7f2962..1dcf105 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -112,6 +112,7 @@ enum i40e_dyn_idx_t {
 
 #define i40e_rx_desc i40e_32byte_rx_desc
 
+#define I40E_MAX_BUFFER_TXD	8
 #define I40E_MIN_TX_LEN		17
 #define I40E_MAX_DATA_PER_TXD	8192
 
-- 
1.9.3
