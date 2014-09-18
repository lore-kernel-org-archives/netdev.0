From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/11] ixgbe: Do not schedule an uninitialized workqueue entry
Date: Thu, 18 Sep 2014 05:26:53 -0700
Message-ID: <1411043221-7163-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17651 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751401AbaIRM1F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 08:27:05 -0400
In-Reply-To: <1411043221-7163-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

If a hardware Tx timestamp is requested, an uninitialized
workqueue entry may be scheduled, especially on an 82598 adapter.
Add a check for a PTP clock to avoid that. Also only apply the
unlikely to the first term of the conditional. That will make the
rest of the checks be in the cold path.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index bcd697c..06ef5a3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7108,9 +7108,10 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 		tx_flags |= IXGBE_TX_FLAGS_SW_VLAN;
 	}
 
-	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
-		     !test_and_set_bit_lock(__IXGBE_PTP_TX_IN_PROGRESS,
-					    &adapter->state))) {
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+	    adapter->ptp_clock &&
+	    !test_and_set_bit_lock(__IXGBE_PTP_TX_IN_PROGRESS,
+				   &adapter->state)) {
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 		tx_flags |= IXGBE_TX_FLAGS_TSTAMP;
 
-- 
1.9.3
