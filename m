From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/6] ixgbevf: Add fix to VF to handle multi-descriptor buffers
Date: Mon, 24 Sep 2012 02:00:06 -0700
Message-ID: <1348477207-27030-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1348477207-27030-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2616 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752210Ab2IXJAP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 05:00:15 -0400
In-Reply-To: <1348477207-27030-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change fixes the ixgbevf driver so that it can correctly drop a frame
should it receive a jumbo frame.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  5 +++++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 14 ++++++++++++--
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index eb26fda..383b4e1 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -261,6 +261,11 @@ enum ixbgevf_state_t {
 	__IXGBEVF_DOWN
 };
 
+struct ixgbevf_cb {
+	struct sk_buff *prev;
+};
+#define IXGBE_CB(skb) ((struct ixgbevf_cb *)(skb)->cb)
+
 enum ixgbevf_boards {
 	board_82599_vf,
 	board_X540_vf,
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 37bbd86..2ba15ae 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -433,11 +433,21 @@ static bool ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 
 		if (!(staterr & IXGBE_RXD_STAT_EOP)) {
 			skb->next = next_buffer->skb;
-			skb->next->prev = skb;
+			IXGBE_CB(skb->next)->prev = skb;
 			adapter->non_eop_descs++;
 			goto next_desc;
 		}
 
+		/* we should not be chaining buffers, if we did drop the skb */
+		if (IXGBE_CB(skb)->prev) {
+			do {
+				struct sk_buff *this = skb;
+				skb = IXGBE_CB(skb)->prev;
+				dev_kfree_skb(this);
+			} while (skb);
+			goto next_desc;
+		}
+
 		/* ERR_MASK will only have valid bits if EOP set */
 		if (unlikely(staterr & IXGBE_RXDADV_ERR_FRAME_ERR_MASK)) {
 			dev_kfree_skb_irq(skb);
@@ -1439,7 +1449,7 @@ static void ixgbevf_clean_rx_ring(struct ixgbevf_adapter *adapter,
 			rx_buffer_info->skb = NULL;
 			do {
 				struct sk_buff *this = skb;
-				skb = skb->prev;
+				skb = IXGBE_CB(skb)->prev;
 				dev_kfree_skb(this);
 			} while (skb);
 		}
-- 
1.7.11.4
