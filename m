From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/12] ixgbe: Make certain that all frames fit minimum size requirements
Date: Sat, 17 Mar 2012 01:50:55 -0700
Message-ID: <1331974260-6383-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28252 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756125Ab2CQIvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Mar 2012 04:51:35 -0400
In-Reply-To: <1331974260-6383-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes certain that any packet we attempt to transmit will meet
minimum size requirements for the hardware.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index db1f17c..bf6d122 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7162,11 +7162,27 @@ out_drop:
 	return NETDEV_TX_OK;
 }
 
-static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
+				    struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_ring *tx_ring;
 
+	if (skb->len <= 0) {
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
+	/*
+	 * The minimum packet size for olinfo paylen is 17 so pad the skb
+	 * in order to meet this minimum size requirement.
+	 */
+	if (skb->len < 17) {
+		if (skb_padto(skb, 17))
+			return NETDEV_TX_OK;
+		skb->len = 17;
+	}
+
 	tx_ring = adapter->tx_ring[skb->queue_mapping];
 	return ixgbe_xmit_frame_ring(skb, adapter, tx_ring);
 }
-- 
1.7.7.6
