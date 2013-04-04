From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/13] ixgbe: Drop check for PAGE_SIZE from ixgbe_xmit_frame_ring
Date: Thu,  4 Apr 2013 04:37:50 -0700
Message-ID: <1365075480-20183-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29187 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757852Ab3DDLiW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 07:38:22 -0400
In-Reply-To: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The check for PAGE_SIZE is pointless now that the default configuration is to
allocate 32K for all buffers.  Since the Tx descriptor limit is 16K we can
just drop the check and always compare the descriptors to the maximum size
supported.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 5cee5de..d49a148d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6425,9 +6425,7 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 	struct ixgbe_tx_buffer *first;
 	int tso;
 	u32 tx_flags = 0;
-#if PAGE_SIZE > IXGBE_MAX_DATA_PER_TXD
 	unsigned short f;
-#endif
 	u16 count = TXD_USE_COUNT(skb_headlen(skb));
 	__be16 protocol = skb->protocol;
 	u8 hdr_len = 0;
@@ -6439,12 +6437,9 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 	 *       + 1 desc for context descriptor,
 	 * otherwise try next time
 	 */
-#if PAGE_SIZE > IXGBE_MAX_DATA_PER_TXD
 	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++)
 		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
-#else
-	count += skb_shinfo(skb)->nr_frags;
-#endif
+
 	if (ixgbe_maybe_stop_tx(tx_ring, count + 3)) {
 		tx_ring->tx_stats.tx_busy++;
 		return NETDEV_TX_BUSY;
-- 
1.7.11.7
