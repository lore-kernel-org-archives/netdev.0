From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/11] ixgbevf: Add flag to indicate when rx is in net poll
Date: Tue, 13 Nov 2012 06:03:18 -0800
Message-ID: <1352815405-751-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35423 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754644Ab2KMODa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 09:03:30 -0500
In-Reply-To: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

napi_gro_receive shouldn't be called from netpoll context.  Doing
so was causing kernel panics when jumbo frames larger than 2K were set.
Add a flag to check if the Rx ring processing is occurring from interrupt
context or from netpoll context and call netif_rx() if in the polling
context.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      | 1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 7 ++++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 2323ccd..9faaf54 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -229,6 +229,7 @@ struct ixgbevf_adapter {
 	 */
 	u32 flags;
 #define IXGBE_FLAG_IN_WATCHDOG_TASK             (u32)(1)
+#define IXGBE_FLAG_IN_NETPOLL                   (u32)(1 << 1)
 
 	/* OS defined structs */
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index ee5ff0e..00f9698 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -288,7 +288,10 @@ static void ixgbevf_receive_skb(struct ixgbevf_q_vector *q_vector,
 	if (is_vlan && test_bit(tag & VLAN_VID_MASK, adapter->active_vlans))
 		__vlan_hwaccel_put_tag(skb, tag);
 
-	napi_gro_receive(&q_vector->napi, skb);
+	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL))
+		napi_gro_receive(&q_vector->napi, skb);
+	else
+		netif_rx(skb);
 }
 
 /**
@@ -550,9 +553,11 @@ static int ixgbevf_poll(struct napi_struct *napi, int budget)
 	else
 		per_ring_budget = budget;
 
+	adapter->flags |= IXGBE_FLAG_IN_NETPOLL;
 	ixgbevf_for_each_ring(ring, q_vector->rx)
 		clean_complete &= ixgbevf_clean_rx_irq(q_vector, ring,
 						       per_ring_budget);
+	adapter->flags &= ~IXGBE_FLAG_IN_NETPOLL;
 
 	/* If all work not completed, return budget and keep polling */
 	if (!clean_complete)
-- 
1.7.11.7
