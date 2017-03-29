From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/13] i40e/i40evf: Use length to determine if descriptor is done
Date: Wed, 29 Mar 2017 03:12:09 -0700
Message-ID: <20170329101215.24513-8-jeffrey.t.kirsher@intel.com>
References: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21132 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755295AbdC2KMY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 06:12:24 -0400
In-Reply-To: <20170329101215.24513-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that we use the length of the packet instead of the
DD status bit to determine if a new descriptor is ready to be processed.
The obvious advantage is that it cuts down on reads as we don't really even
need the DD bit if going from a 0 to a non-zero value on size is enough to
inform us that the packet has been completed.

Change-ID: Iebdf9cdb36c454ef092df27199b92ad09c374231
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 24 ++++++++++++------------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 24 ++++++++++++------------
 2 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 2ca8d13baea5..012e55354043 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1757,6 +1757,7 @@ static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
  * i40e_fetch_rx_buffer - Allocate skb and populate it
  * @rx_ring: rx descriptor ring to transact packets on
  * @rx_desc: descriptor containing info written by hardware
+ * @size: size of buffer to add to skb
  *
  * This function allocates an skb on the fly, and populates it with the page
  * data from the current receive descriptor, taking care to set up the skb
@@ -1766,13 +1767,9 @@ static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
 static inline
 struct sk_buff *i40e_fetch_rx_buffer(struct i40e_ring *rx_ring,
 				     union i40e_rx_desc *rx_desc,
-				     struct sk_buff *skb)
+				     struct sk_buff *skb,
+				     unsigned int size)
 {
-	u64 local_status_error_len =
-		le64_to_cpu(rx_desc->wb.qword1.status_error_len);
-	unsigned int size =
-		(local_status_error_len & I40E_RXD_QW1_LENGTH_PBUF_MASK) >>
-		I40E_RXD_QW1_LENGTH_PBUF_SHIFT;
 	struct i40e_rx_buffer *rx_buffer;
 	struct page *page;
 
@@ -1890,6 +1887,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 
 	while (likely(total_rx_packets < budget)) {
 		union i40e_rx_desc *rx_desc;
+		unsigned int size;
 		u16 vlan_tag;
 		u8 rx_ptype;
 		u64 qword;
@@ -1906,19 +1904,21 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 		/* status_error_len will always be zero for unused descriptors
 		 * because it's cleared in cleanup, and overlaps with hdr_addr
 		 * which is always zero because packet split isn't used, if the
-		 * hardware wrote DD then it will be non-zero
+		 * hardware wrote DD then the length will be non-zero
 		 */
-		if (!i40e_test_staterr(rx_desc,
-				       BIT(I40E_RX_DESC_STATUS_DD_SHIFT)))
+		qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
+		size = (qword & I40E_RXD_QW1_LENGTH_PBUF_MASK) >>
+		       I40E_RXD_QW1_LENGTH_PBUF_SHIFT;
+		if (!size)
 			break;
 
 		/* This memory barrier is needed to keep us from reading
-		 * any other fields out of the rx_desc until we know the
-		 * DD bit is set.
+		 * any other fields out of the rx_desc until we have
+		 * verified the descriptor has been written back.
 		 */
 		dma_rmb();
 
-		skb = i40e_fetch_rx_buffer(rx_ring, rx_desc, skb);
+		skb = i40e_fetch_rx_buffer(rx_ring, rx_desc, skb, size);
 		if (!skb)
 			break;
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index f1a99a8dc7ea..e41eb46b02fe 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1116,6 +1116,7 @@ static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
  * i40evf_fetch_rx_buffer - Allocate skb and populate it
  * @rx_ring: rx descriptor ring to transact packets on
  * @rx_desc: descriptor containing info written by hardware
+ * @size: size of buffer to add to skb
  *
  * This function allocates an skb on the fly, and populates it with the page
  * data from the current receive descriptor, taking care to set up the skb
@@ -1125,13 +1126,9 @@ static bool i40e_add_rx_frag(struct i40e_ring *rx_ring,
 static inline
 struct sk_buff *i40evf_fetch_rx_buffer(struct i40e_ring *rx_ring,
 				       union i40e_rx_desc *rx_desc,
-				       struct sk_buff *skb)
+				       struct sk_buff *skb,
+				       unsigned int size)
 {
-	u64 local_status_error_len =
-		le64_to_cpu(rx_desc->wb.qword1.status_error_len);
-	unsigned int size =
-		(local_status_error_len & I40E_RXD_QW1_LENGTH_PBUF_MASK) >>
-		I40E_RXD_QW1_LENGTH_PBUF_SHIFT;
 	struct i40e_rx_buffer *rx_buffer;
 	struct page *page;
 
@@ -1244,6 +1241,7 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 
 	while (likely(total_rx_packets < budget)) {
 		union i40e_rx_desc *rx_desc;
+		unsigned int size;
 		u16 vlan_tag;
 		u8 rx_ptype;
 		u64 qword;
@@ -1260,19 +1258,21 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 		/* status_error_len will always be zero for unused descriptors
 		 * because it's cleared in cleanup, and overlaps with hdr_addr
 		 * which is always zero because packet split isn't used, if the
-		 * hardware wrote DD then it will be non-zero
+		 * hardware wrote DD then the length will be non-zero
 		 */
-		if (!i40e_test_staterr(rx_desc,
-				       BIT(I40E_RX_DESC_STATUS_DD_SHIFT)))
+		qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
+		size = (qword & I40E_RXD_QW1_LENGTH_PBUF_MASK) >>
+		       I40E_RXD_QW1_LENGTH_PBUF_SHIFT;
+		if (!size)
 			break;
 
 		/* This memory barrier is needed to keep us from reading
-		 * any other fields out of the rx_desc until we know the
-		 * DD bit is set.
+		 * any other fields out of the rx_desc until we have
+		 * verified the descriptor has been written back.
 		 */
 		dma_rmb();
 
-		skb = i40evf_fetch_rx_buffer(rx_ring, rx_desc, skb);
+		skb = i40evf_fetch_rx_buffer(rx_ring, rx_desc, skb, size);
 		if (!skb)
 			break;
 
-- 
2.12.0
