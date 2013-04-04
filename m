From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/13] igb: Pull adapter out of main path in igb_xmit_frame_ring
Date: Thu,  4 Apr 2013 04:37:56 -0700
Message-ID: <1365075480-20183-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:6786 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758883Ab3DDLiY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 07:38:24 -0400
In-Reply-To: <1365075480-20183-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

We only need the adapter pointer in the case of ptp.  As such we can pull the
adapter out of the main path and place it inside the if statement to avoid
the temptation of accessing the adapter pointer in the fast path.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 29facb5..6043245 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4593,7 +4593,6 @@ static inline int igb_maybe_stop_tx(struct igb_ring *tx_ring, const u16 size)
 netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 				struct igb_ring *tx_ring)
 {
-	struct igb_adapter *adapter = netdev_priv(tx_ring->netdev);
 	struct igb_tx_buffer *first;
 	int tso;
 	u32 tx_flags = 0;
@@ -4628,15 +4627,17 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 
 	skb_tx_timestamp(skb);
 
-	if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
-		     !(adapter->ptp_tx_skb))) {
-		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
-		tx_flags |= IGB_TX_FLAGS_TSTAMP;
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
+		struct igb_adapter *adapter = netdev_priv(tx_ring->netdev);
+		if (!(adapter->ptp_tx_skb)) {
+			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+			tx_flags |= IGB_TX_FLAGS_TSTAMP;
 
-		adapter->ptp_tx_skb = skb_get(skb);
-		adapter->ptp_tx_start = jiffies;
-		if (adapter->hw.mac.type == e1000_82576)
-			schedule_work(&adapter->ptp_tx_work);
+			adapter->ptp_tx_skb = skb_get(skb);
+			adapter->ptp_tx_start = jiffies;
+			if (adapter->hw.mac.type == e1000_82576)
+				schedule_work(&adapter->ptp_tx_work);
+		}
 	}
 
 	if (vlan_tx_tag_present(skb)) {
-- 
1.7.11.7
