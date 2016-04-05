From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/3] e1000: Double Tx descriptors needed check for 82544
Date: Tue,  5 Apr 2016 15:30:51 -0700
Message-ID: <1459895451-45300-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459895451-45300-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:12327 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933820AbcDEWay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 18:30:54 -0400
In-Reply-To: <1459895451-45300-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

The 82544 has code that adds one additional descriptor per data buffer.
However we weren't taking that into account when determining the descriptors
needed for the next transmit at the end of the xmit_frame path.

This change takes that into account by doubling the number of descriptors
needed for the 82544 so that we can avoid a potential issue where we could
hang the Tx ring by loading frames with xmit_more enabled and then stopping
the ring without writing the tail.

In addition it adds a few more descriptors to account for some additional
workarounds that have been added over time.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index d213fb4..ae90d4f 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -3256,12 +3256,29 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 			     nr_frags, mss);
 
 	if (count) {
+		/* The descriptors needed is higher than other Intel drivers
+		 * due to a number of workarounds.  The breakdown is below:
+		 * Data descriptors: MAX_SKB_FRAGS + 1
+		 * Context Descriptor: 1
+		 * Keep head from touching tail: 2
+		 * Workarounds: 3
+		 */
+		int desc_needed = MAX_SKB_FRAGS + 7;
+
 		netdev_sent_queue(netdev, skb->len);
 		skb_tx_timestamp(skb);
 
 		e1000_tx_queue(adapter, tx_ring, tx_flags, count);
+
+		/* 82544 potentially requires twice as many data descriptors
+		 * in order to guarantee buffers don't end on evenly-aligned
+		 * dwords
+		 */
+		if (adapter->pcix_82544)
+			desc_needed += MAX_SKB_FRAGS + 1;
+
 		/* Make sure there is space in the ring for the next send. */
-		e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
+		e1000_maybe_stop_tx(netdev, tx_ring, desc_needed);
 
 		if (!skb->xmit_more ||
 		    netif_xmit_stopped(netdev_get_tx_queue(netdev, 0))) {
-- 
2.5.5
