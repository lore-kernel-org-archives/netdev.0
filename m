From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/18] fm10k: Don't assume page fragments are page size
Date: Tue, 15 Sep 2015 17:36:33 -0700
Message-ID: <1442363803-47237-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49360 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752914AbbIPAhJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 20:37:09 -0400
In-Reply-To: <1442363803-47237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

This change pulls out the optimization that assumed that all fragments
would be limited to page size.  That hasn't been the case for some time now
and to assume this is incorrect as the TCP allocator can provide up to a
32K page fragment.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Acked-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index b5b2925..6ad03e0 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1079,9 +1079,7 @@ netdev_tx_t fm10k_xmit_frame_ring(struct sk_buff *skb,
 	struct fm10k_tx_buffer *first;
 	int tso;
 	u32 tx_flags = 0;
-#if PAGE_SIZE > FM10K_MAX_DATA_PER_TXD
 	unsigned short f;
-#endif
 	u16 count = TXD_USE_COUNT(skb_headlen(skb));
 
 	/* need: 1 descriptor per page * PAGE_SIZE/FM10K_MAX_DATA_PER_TXD,
@@ -1089,12 +1087,9 @@ netdev_tx_t fm10k_xmit_frame_ring(struct sk_buff *skb,
 	 *       + 2 desc gap to keep tail from touching head
 	 * otherwise try next time
 	 */
-#if PAGE_SIZE > FM10K_MAX_DATA_PER_TXD
 	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++)
 		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
-#else
-	count += skb_shinfo(skb)->nr_frags;
-#endif
+
 	if (fm10k_maybe_stop_tx(tx_ring, count + 3)) {
 		tx_ring->tx_stats.tx_busy++;
 		return NETDEV_TX_BUSY;
-- 
2.4.3
