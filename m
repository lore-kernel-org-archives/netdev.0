From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40e/i40evf: fix some minor type mismatches
Date: Sat, 12 Aug 2017 04:08:33 -0700
Message-ID: <20170812110848.18264-2-jeffrey.t.kirsher@intel.com>
References: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54045 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750811AbdHLLIw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 07:08:52 -0400
In-Reply-To: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This patch fixes two trivial type mismatches, one where
we were returning an enum type, but pretending it was an int,
and the other where we were using a void* for offset math, but
it is communicated more clearly and correctly to use a u8*,
which we then cast to void* for prefetch to use.

Change-ID: I8d9cf84a1ddbcff7f31eaad9e08880cad4a71f5f
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 8a969d8f0790..d6e80b1130f7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1526,7 +1526,7 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
  *
  * Returns a hash type to be used by skb_set_hash
  **/
-static inline int i40e_ptype_to_htype(u8 ptype)
+static inline enum pkt_hash_types i40e_ptype_to_htype(u8 ptype)
 {
 	struct i40e_rx_ptype_decoded decoded = decode_rx_desc_ptype(ptype);
 
@@ -1830,7 +1830,7 @@ static struct sk_buff *i40e_construct_skb(struct i40e_ring *rx_ring,
 	/* prefetch first cache line of first page */
 	prefetch(xdp->data);
 #if L1_CACHE_BYTES < 128
-	prefetch(xdp->data + L1_CACHE_BYTES);
+	prefetch((void *)(xdp->data + L1_CACHE_BYTES));
 #endif
 
 	/* allocate a skb to store the frags */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index d91676ccf125..4bf7e355cb0b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -858,7 +858,7 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
  *
  * Returns a hash type to be used by skb_set_hash
  **/
-static inline int i40e_ptype_to_htype(u8 ptype)
+static inline enum pkt_hash_types i40e_ptype_to_htype(u8 ptype)
 {
 	struct i40e_rx_ptype_decoded decoded = decode_rx_desc_ptype(ptype);
 
@@ -1122,7 +1122,7 @@ static struct sk_buff *i40e_construct_skb(struct i40e_ring *rx_ring,
 					  struct i40e_rx_buffer *rx_buffer,
 					  unsigned int size)
 {
-	void *va = page_address(rx_buffer->page) + rx_buffer->page_offset;
+	u8 *va = page_address(rx_buffer->page) + rx_buffer->page_offset;
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = i40e_rx_pg_size(rx_ring) / 2;
 #else
@@ -1134,7 +1134,7 @@ static struct sk_buff *i40e_construct_skb(struct i40e_ring *rx_ring,
 	/* prefetch first cache line of first page */
 	prefetch(va);
 #if L1_CACHE_BYTES < 128
-	prefetch(va + L1_CACHE_BYTES);
+	prefetch((void *)(va + L1_CACHE_BYTES));
 #endif
 
 	/* allocate a skb to store the frags */
-- 
2.14.0
