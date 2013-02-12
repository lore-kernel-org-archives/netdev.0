From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net] ixgbe: Only set gso_type to SKB_GSO_TCPV4 as RSC does
 not support IPv6
Date: Tue, 12 Feb 2013 11:45:44 -0800
Message-ID: <20130212193624.17818.13843.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, davem@davemloft.net, mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57995 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933153Ab3BLTrn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2013 14:47:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original fix that was applied for setting gso_type required more change
than necessary because it was assumed ixgbe does RSC on IPv6 frames and this
is not correct.  RSC is only supported with IPv4/TCP frames only.  As such we
can simplify the fix and avoid the unnecessary move of eth_type_trans.

The previous patch "ixgbe: fix gso type" and this patch reduce the entire fix
to one line that sets gso_type to TCPV4 if the frame is RSC.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

Sorry about not speaking up last week which would have allowed us to avoid
this patch but I was out on a business trip and had limited access to email
between flights.

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e1b2d22..b3e3294 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1401,10 +1401,7 @@ static void ixgbe_set_rsc_gso_size(struct ixgbe_ring *ring,
 	/* set gso_size to avoid messing up TCP MSS */
 	skb_shinfo(skb)->gso_size = DIV_ROUND_UP((skb->len - hdr_len),
 						 IXGBE_CB(skb)->append_cnt);
-	if (skb->protocol == __constant_htons(ETH_P_IPV6))
-		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
-	else
-		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
 }
 
 static void ixgbe_update_rsc_stats(struct ixgbe_ring *rx_ring,
@@ -1439,8 +1436,6 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
 {
 	struct net_device *dev = rx_ring->netdev;
 
-	skb->protocol = eth_type_trans(skb, dev);
-
 	ixgbe_update_rsc_stats(rx_ring, skb);
 
 	ixgbe_rx_hash(rx_ring, rx_desc, skb);
@@ -1456,6 +1451,8 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
 	}
 
 	skb_record_rx_queue(skb, rx_ring->queue_index);
+
+	skb->protocol = eth_type_trans(skb, dev);
 }
 
 static void ixgbe_rx_skb(struct ixgbe_q_vector *q_vector,
