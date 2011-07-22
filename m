From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/10] ixgbe: Update ATR to use recorded TX queues instead of CPU for routing
Date: Thu, 21 Jul 2011 23:09:04 -0700
Message-ID: <1311314951-11142-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1311314951-11142-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61288 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753394Ab1GVGJQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2011 02:09:16 -0400
In-Reply-To: <1311314951-11142-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to update ATR so that it will use the recorded RX
queue instead of the CPU in the case of routing.  This change is meant to
help ixgbe default behavior to more closely match that of the kernel.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index de30796..f05ddf3 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6795,11 +6795,10 @@ static int ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, u16 size)
 static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
-	int txq = smp_processor_id();
+	int txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) :
+					       smp_processor_id();
 #ifdef IXGBE_FCOE
-	__be16 protocol;
-
-	protocol = vlan_get_protocol(skb);
+	__be16 protocol = vlan_get_protocol(skb);
 
 	if (((protocol == htons(ETH_P_FCOE)) ||
 	    (protocol == htons(ETH_P_FIP))) &&
-- 
1.7.6

