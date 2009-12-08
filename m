From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/2] ixgbe: Fix TX stats accounting
Date: Tue, 08 Dec 2009 09:22:03 -0800
Message-ID: <20091208172125.19464.29177.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:38859
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936480AbZLHRWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 12:22:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>

Here is an updated version, because ixgbe_get_ethtool_stats()
needs to call dev_get_stats() or "ethtool -S" wont give
correct tx_bytes/tx_packets values.

Several cpus can update netdev->stats.tx_bytes & netdev->stats.tx_packets
in parallel. In this case, TX stats are under estimated and false sharing
takes place.

After a pktgen session sending exactly 200000000 packets :
# ifconfig fiber0 | grep TX
          TX packets:198501982 errors:0 dropped:0 overruns:0 carrier:0


Multi queue devices should instead use txq->tx_bytes & txq->tx_packets
in their xmit() method (appropriate txq lock already held by caller, no
cache line miss), or use appropriate locking.

After patch, same pktgen session gives :

# ifconfig fiber0 | grep TX
          TX packets:200000000 errors:0 dropped:0 overruns:0 carrier:0

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |    1 +
 drivers/net/ixgbe/ixgbe_main.c    |   20 ++++----------------
 2 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 06a9d18..0bd49d3 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -990,6 +990,7 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 	char *p = NULL;
 
 	ixgbe_update_stats(adapter);
+	dev_get_stats(netdev);
 	for (i = 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
 		switch (ixgbe_gstrings_stats[i].type) {
 		case NETDEV_STATS:
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 247ed2a..4374f44 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -435,8 +435,6 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 	tx_ring->total_packets += total_packets;
 	tx_ring->stats.packets += total_packets;
 	tx_ring->stats.bytes += total_bytes;
-	netdev->stats.tx_bytes += total_bytes;
-	netdev->stats.tx_packets += total_packets;
 	return (count < tx_ring->work_limit);
 }
 
@@ -5327,6 +5325,7 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_ring *tx_ring;
+	struct netdev_queue *txq;
 	unsigned int first;
 	unsigned int tx_flags = 0;
 	u8 hdr_len = 0;
@@ -5424,6 +5423,9 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 				tx_ring->atr_count = 0;
 			}
 		}
+		txq = netdev_get_tx_queue(netdev, tx_ring->queue_index);
+		txq->tx_bytes += skb->len;
+		txq->tx_packets++;
 		ixgbe_tx_queue(adapter, tx_ring, tx_flags, count, skb->len,
 		               hdr_len);
 		ixgbe_maybe_stop_tx(netdev, tx_ring, DESC_NEEDED);
@@ -5438,19 +5440,6 @@ static netdev_tx_t ixgbe_xmit_frame(struct sk_buff *skb,
 }
 
 /**
- * ixgbe_get_stats - Get System Network Statistics
- * @netdev: network interface device structure
- *
- * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
- **/
-static struct net_device_stats *ixgbe_get_stats(struct net_device *netdev)
-{
-	/* only return the current stats */
-	return &netdev->stats;
-}
-
-/**
  * ixgbe_set_mac - Change the Ethernet Address of the NIC
  * @netdev: network interface device structure
  * @p: pointer to an address structure
@@ -5580,7 +5569,6 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_stop		= ixgbe_close,
 	.ndo_start_xmit		= ixgbe_xmit_frame,
 	.ndo_select_queue	= ixgbe_select_queue,
-	.ndo_get_stats		= ixgbe_get_stats,
 	.ndo_set_rx_mode        = ixgbe_set_rx_mode,
 	.ndo_set_multicast_list	= ixgbe_set_rx_mode,
 	.ndo_validate_addr	= eth_validate_addr,

