From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] igb: Correcting and improving small packet check and padding
Date: Fri, 19 Oct 2012 04:45:05 -0700
Message-ID: <1350647114-6768-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350647114-6768-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tushar Dave <tushar.n.dave@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64516 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753948Ab2JSLpn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 07:45:43 -0400
In-Reply-To: <1350647114-6768-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@intel.com>

Current implementation mess up the tail pointer. This patch sets skb->tail
correctly.
Also, the small packet check and padding is optimized by using unlikely and
calling skb_pad directly.

Signed-off-by: Tushar Dave <tushar.n.dave@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index e1ceb37..c611cff 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4467,10 +4467,11 @@ static netdev_tx_t igb_xmit_frame(struct sk_buff *skb,
 	 * The minimum packet size with TCTL.PSP set is 17 so pad the skb
 	 * in order to meet this minimum size requirement.
 	 */
-	if (skb->len < 17) {
-		if (skb_padto(skb, 17))
+	if (unlikely(skb->len < 17)) {
+		if (skb_pad(skb, 17 - skb->len))
 			return NETDEV_TX_OK;
 		skb->len = 17;
+		skb_set_tail_pointer(skb, 17);
 	}
 
 	return igb_xmit_frame_ring(skb, igb_tx_queue_mapping(adapter, skb));
-- 
1.7.11.7
