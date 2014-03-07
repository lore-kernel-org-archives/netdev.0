From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 11/12] i40e/i40evf: carefully fill tx ring
Date: Thu,  6 Mar 2014 18:59:23 -0800
Message-ID: <1394161164-26645-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394161164-26645-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62505 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752378AbaCGC7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 21:59:35 -0500
In-Reply-To: <1394161164-26645-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

We need to make sure that we stay away from the cache line
where the DD bit (done) may be getting written back for
the transmit ring since the hardware may be writing the
whole cache line for a partial update.

Change-ID: Id0b6dfc01f654def6a2a021af185803be1915d7e
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 4 ++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index e4497f8..2081bdb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2102,7 +2102,7 @@ static int i40e_xmit_descriptor_count(struct sk_buff *skb,
 
 	/* need: 1 descriptor per page * PAGE_SIZE/I40E_MAX_DATA_PER_TXD,
 	 *       + 1 desc for skb_head_len/I40E_MAX_DATA_PER_TXD,
-	 *       + 2 desc gap to keep tail from touching head,
+	 *       + 4 desc gap to avoid the cache line where head is,
 	 *       + 1 desc for context descriptor,
 	 * otherwise try next time
 	 */
@@ -2113,7 +2113,7 @@ static int i40e_xmit_descriptor_count(struct sk_buff *skb,
 	count += skb_shinfo(skb)->nr_frags;
 #endif
 	count += TXD_USE_COUNT(skb_headlen(skb));
-	if (i40e_maybe_stop_tx(tx_ring, count + 3)) {
+	if (i40e_maybe_stop_tx(tx_ring, count + 4 + 1)) {
 		tx_ring->tx_stats.tx_busy++;
 		return 0;
 	}
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 01bfab7..b1d87c6 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1482,7 +1482,7 @@ static int i40e_xmit_descriptor_count(struct sk_buff *skb,
 
 	/* need: 1 descriptor per page * PAGE_SIZE/I40E_MAX_DATA_PER_TXD,
 	 *       + 1 desc for skb_head_len/I40E_MAX_DATA_PER_TXD,
-	 *       + 2 desc gap to keep tail from touching head,
+	 *       + 4 desc gap to avoid the cache line where head is,
 	 *       + 1 desc for context descriptor,
 	 * otherwise try next time
 	 */
@@ -1493,7 +1493,7 @@ static int i40e_xmit_descriptor_count(struct sk_buff *skb,
 	count += skb_shinfo(skb)->nr_frags;
 #endif
 	count += TXD_USE_COUNT(skb_headlen(skb));
-	if (i40e_maybe_stop_tx(tx_ring, count + 3)) {
+	if (i40e_maybe_stop_tx(tx_ring, count + 4 + 1)) {
 		tx_ring->tx_stats.tx_busy++;
 		return 0;
 	}
-- 
1.8.3.1
