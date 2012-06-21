From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] ixgbe: simplify padding and length checks
Date: Thu, 21 Jun 2012 05:15:10 -0700
Message-ID: <1340280910-22651-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:30552 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757071Ab2FUMPR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2012 08:15:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>

The check for length <= 0 is bogus because length is unsigned, and network
stack never sends zero length packets (unless it is totally broken).

The check for really small packets can be optimized (using unlikely)
and calling skb_pad directly.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index cbb05d6..9afe0cb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6383,17 +6383,12 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_ring *tx_ring;
 
-	if (skb->len <= 0) {
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
-
 	/*
 	 * The minimum packet size for olinfo paylen is 17 so pad the skb
 	 * in order to meet this minimum size requirement.
 	 */
-	if (skb->len < 17) {
-		if (skb_padto(skb, 17))
+	if (unlikely(skb->len < 17)) {
+		if (skb_pad(skb, 17 - skb->len))
 			return NETDEV_TX_OK;
 		skb->len = 17;
 	}
-- 
1.7.10.2
