From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/8] ixgbe: Improve statistics accuracy for DDP traffic
Date: Sun, 16 Sep 2012 21:15:42 -0700
Message-ID: <1347855342-6610-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1347855342-6610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46001 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750819Ab2IQEPu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 00:15:50 -0400
In-Reply-To: <1347855342-6610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Noticed that the byte and packet count statistics are under-
counting traffic handled by the DDP offload when there is more
than one DDP completion processed in a single call to
ixgbe_clean_rx_irq. This patch fixes that.

I tried to optimize the setting of the rss value so that it
only would have to be computed once, and only when there is
a DDP completion present.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 32 +++++++++++++--------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b3b846b..2dc9d91 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1785,7 +1785,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 #ifdef IXGBE_FCOE
 	struct ixgbe_adapter *adapter = q_vector->adapter;
-	int ddp_bytes = 0;
+	int ddp_bytes;
+	unsigned int mss = 0;
 #endif /* IXGBE_FCOE */
 	u16 cleaned_count = ixgbe_desc_unused(rx_ring);
 
@@ -1839,6 +1840,20 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		/* if ddp, not passing to ULD unless for FCP_RSP or error */
 		if (ixgbe_rx_is_fcoe(rx_ring, rx_desc)) {
 			ddp_bytes = ixgbe_fcoe_ddp(adapter, rx_desc, skb);
+			/* include DDPed FCoE data */
+			if (ddp_bytes > 0) {
+				if (!mss) {
+					mss = rx_ring->netdev->mtu -
+						sizeof(struct fcoe_hdr) -
+						sizeof(struct fc_frame_header) -
+						sizeof(struct fcoe_crc_eof);
+					if (mss > 512)
+						mss &= ~511;
+				}
+				total_rx_bytes += ddp_bytes;
+				total_rx_packets += DIV_ROUND_UP(ddp_bytes,
+								 mss);
+			}
 			if (!ddp_bytes) {
 				dev_kfree_skb_any(skb);
 				continue;
@@ -1852,21 +1867,6 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		budget--;
 	} while (likely(budget));
 
-#ifdef IXGBE_FCOE
-	/* include DDPed FCoE data */
-	if (ddp_bytes > 0) {
-		unsigned int mss;
-
-		mss = rx_ring->netdev->mtu - sizeof(struct fcoe_hdr) -
-			sizeof(struct fc_frame_header) -
-			sizeof(struct fcoe_crc_eof);
-		if (mss > 512)
-			mss &= ~511;
-		total_rx_bytes += ddp_bytes;
-		total_rx_packets += DIV_ROUND_UP(ddp_bytes, mss);
-	}
-
-#endif /* IXGBE_FCOE */
 	u64_stats_update_begin(&rx_ring->syncp);
 	rx_ring->stats.packets += total_rx_packets;
 	rx_ring->stats.bytes += total_rx_bytes;
-- 
1.7.11.4
