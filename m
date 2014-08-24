From: Daniel Borkmann <dborkman@redhat.com>
Subject: [RFC PATCH net-next 1/3] ixgbe: support netdev_ops->ndo_xmit_flush()
Date: Sun, 24 Aug 2014 15:42:16 +0200
Message-ID: <1408887738-7661-2-git-send-email-dborkman@redhat.com>
References: <1408887738-7661-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1580 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752573AbaHXNmX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Aug 2014 09:42:23 -0400
In-Reply-To: <1408887738-7661-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements the deferred tail pointer flush API for the ixgbe
driver. Similar version also proposed longer time ago by Alexander Duyck.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 28 +++++++++++++++++++++++----
 1 file changed, 24 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 87bd53f..4e073cf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6957,10 +6957,6 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 		i = 0;
 
 	tx_ring->next_to_use = i;
-
-	/* notify HW of packet */
-	ixgbe_write_tail(tx_ring, i);
-
 	return;
 dma_error:
 	dev_err(tx_ring->dev, "TX DMA map failed\n");
@@ -7301,6 +7297,29 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 	return __ixgbe_xmit_frame(skb, netdev, NULL);
 }
 
+static inline struct ixgbe_ring *
+__ixgb_tx_queue_mapping(struct ixgbe_adapter *adapter, u16 queue)
+{
+	if (unlikely(queue >= adapter->num_tx_queues))
+		queue = queue % adapter->num_tx_queues;
+
+	return adapter->tx_ring[queue];
+}
+
+static void ixgbe_xmit_flush(struct net_device *netdev, u16 queue)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_ring *tx_ring;
+
+	tx_ring = __ixgb_tx_queue_mapping(adapter, queue);
+	ixgbe_write_tail(tx_ring, tx_ring->next_to_use);
+
+	/* we need this if more than one processor can write to our tail
+	 * at a time, it synchronizes IO on IA64/Altix systems
+	 */
+	mmiowb();
+}
+
 /**
  * ixgbe_set_mac - Change the Ethernet Address of the NIC
  * @netdev: network interface device structure
@@ -7914,6 +7933,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
 	.ndo_start_xmit		= ixgbe_xmit_frame,
+	.ndo_xmit_flush		= ixgbe_xmit_flush,
 	.ndo_select_queue	= ixgbe_select_queue,
 	.ndo_set_rx_mode	= ixgbe_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,
-- 
1.7.11.7
