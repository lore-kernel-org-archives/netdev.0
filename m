From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/3] ixgbe: IXGBE_RXD_STAT_VP set even with Rx stripping enabled
Date: Tue,  5 Jun 2012 21:08:55 -0700
Message-ID: <1338955735-8967-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1338955735-8967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49278 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752730Ab2FFEJA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 00:09:00 -0400
In-Reply-To: <1338955735-8967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

The hardware bit IXGBE_RXD_STAT_VP appears to be set even when Rx
stripping is disabled. This results in passing frames up the stack
which do not have the 802.1Q tag stripped but have the tci bits
set as if it was.

Working around this with a check for the feature flag bit. I
would welcome any better ideas or a pointer to exactly which
bits in the hardware register need to be cleared to get the
IXGBE_RXD_STAT_VP bit to be set per data sheet.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Marcus Dennis <marcusx.e.dennis@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b8b2087..17ad6a3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1390,6 +1390,8 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
 				     union ixgbe_adv_rx_desc *rx_desc,
 				     struct sk_buff *skb)
 {
+	struct net_device *dev = rx_ring->netdev;
+
 	ixgbe_update_rsc_stats(rx_ring, skb);
 
 	ixgbe_rx_hash(rx_ring, rx_desc, skb);
@@ -1401,14 +1403,15 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
 		ixgbe_ptp_rx_hwtstamp(rx_ring->q_vector, skb);
 #endif
 
-	if (ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_VP)) {
+	if ((dev->features & NETIF_F_HW_VLAN_RX) &&
+	    ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_VP)) {
 		u16 vid = le16_to_cpu(rx_desc->wb.upper.vlan);
 		__vlan_hwaccel_put_tag(skb, vid);
 	}
 
 	skb_record_rx_queue(skb, rx_ring->queue_index);
 
-	skb->protocol = eth_type_trans(skb, rx_ring->netdev);
+	skb->protocol = eth_type_trans(skb, dev);
 }
 
 static void ixgbe_rx_skb(struct ixgbe_q_vector *q_vector,
-- 
1.7.10.2
