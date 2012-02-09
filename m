From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 8/8] ixgbe: ethtool: stats user buffer overrun
Date: Thu,  9 Feb 2012 01:34:21 -0800
Message-ID: <1328780061-25000-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328780061-25000-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:23892 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757459Ab2BIJe3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 04:34:29 -0500
In-Reply-To: <1328780061-25000-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

If the number of tx/rx queues changes the ethtool ioctl
ETHTOOL_GSTATS may overrun the userspace buffer. This
occurs because the general practice in user space to
query stats is to issue a ETHTOOL_GSSET cmd to learn the
buffer size needed, allocate the buffer, then call
ETHTOOL_GSTIRNGS and ETHTOOL_GSTATS. If the number of
real_num_queues is changed or flow control attributes
are changed after ETHTOOL_GSSET but before the
ETHTOOL_GSTRINGS/ETHTOOL_GSTATS a user space buffer
overrun occurs.

To fix the overrun always return the max buffer size
needed from get_sset_count() then return all strings
and stats from get_strings()/get_ethtool_stats().

This _will_ change the output from the ioctl() call
which could break applications and script parsing in
theory. I believe these changes should not break existing
tools because the only changes will be more {tx|rx}_queues
and the {tx|rx}_pb_* stats will always be returned.
Existing scripts already need to handle changing number
of queues because this occurs today depending on system
and current features. The {tx|rx}_pb_* stats are at the
end of the output and should be handled by scripts today
regardless.

Finally get_ethtool_stats and get_strings are free-form
outputs tools parsing these outputs should be defensive
anyways. In the end these updates are better then
having a tool segfault because of a buffer overrun.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   88 +++++++++++++---------
 1 files changed, 51 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 1f31a04..a629754 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -120,19 +120,23 @@ static const struct ixgbe_stats ixgbe_gstrings_stats[] = {
 #endif /* IXGBE_FCOE */
 };
 
-#define IXGBE_QUEUE_STATS_LEN \
-	((((struct ixgbe_adapter *)netdev_priv(netdev))->num_tx_queues + \
-	((struct ixgbe_adapter *)netdev_priv(netdev))->num_rx_queues) * \
+/* ixgbe allocates num_tx_queues and num_rx_queues symmetrically so
+ * we set the num_rx_queues to evaluate to num_tx_queues. This is
+ * used because we do not have a good way to get the max number of
+ * rx queues with CONFIG_RPS disabled.
+ */
+#define IXGBE_NUM_RX_QUEUES netdev->num_tx_queues
+
+#define IXGBE_QUEUE_STATS_LEN ( \
+	(netdev->num_tx_queues + IXGBE_NUM_RX_QUEUES) * \
 	(sizeof(struct ixgbe_queue_stats) / sizeof(u64)))
 #define IXGBE_GLOBAL_STATS_LEN ARRAY_SIZE(ixgbe_gstrings_stats)
 #define IXGBE_PB_STATS_LEN ( \
-                 (((struct ixgbe_adapter *)netdev_priv(netdev))->flags & \
-                 IXGBE_FLAG_DCB_ENABLED) ? \
-                 (sizeof(((struct ixgbe_adapter *)0)->stats.pxonrxc) + \
-                  sizeof(((struct ixgbe_adapter *)0)->stats.pxontxc) + \
-                  sizeof(((struct ixgbe_adapter *)0)->stats.pxoffrxc) + \
-                  sizeof(((struct ixgbe_adapter *)0)->stats.pxofftxc)) \
-                  / sizeof(u64) : 0)
+			(sizeof(((struct ixgbe_adapter *)0)->stats.pxonrxc) + \
+			 sizeof(((struct ixgbe_adapter *)0)->stats.pxontxc) + \
+			 sizeof(((struct ixgbe_adapter *)0)->stats.pxoffrxc) + \
+			 sizeof(((struct ixgbe_adapter *)0)->stats.pxofftxc)) \
+			/ sizeof(u64))
 #define IXGBE_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + \
                          IXGBE_PB_STATS_LEN + \
                          IXGBE_QUEUE_STATS_LEN)
@@ -1078,8 +1082,15 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 		data[i] = (ixgbe_gstrings_stats[i].sizeof_stat ==
 		           sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
-	for (j = 0; j < adapter->num_tx_queues; j++) {
+	for (j = 0; j < IXGBE_NUM_RX_QUEUES; j++) {
 		ring = adapter->tx_ring[j];
+		if (!ring) {
+			data[i] = 0;
+			data[i+1] = 0;
+			i += 2;
+			continue;
+		}
+
 		do {
 			start = u64_stats_fetch_begin_bh(&ring->syncp);
 			data[i]   = ring->stats.packets;
@@ -1087,8 +1098,15 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
 		i += 2;
 	}
-	for (j = 0; j < adapter->num_rx_queues; j++) {
+	for (j = 0; j < IXGBE_NUM_RX_QUEUES; j++) {
 		ring = adapter->rx_ring[j];
+		if (!ring) {
+			data[i] = 0;
+			data[i+1] = 0;
+			i += 2;
+			continue;
+		}
+
 		do {
 			start = u64_stats_fetch_begin_bh(&ring->syncp);
 			data[i]   = ring->stats.packets;
@@ -1096,22 +1114,20 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
 		i += 2;
 	}
-	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-		for (j = 0; j < MAX_TX_PACKET_BUFFERS; j++) {
-			data[i++] = adapter->stats.pxontxc[j];
-			data[i++] = adapter->stats.pxofftxc[j];
-		}
-		for (j = 0; j < MAX_RX_PACKET_BUFFERS; j++) {
-			data[i++] = adapter->stats.pxonrxc[j];
-			data[i++] = adapter->stats.pxoffrxc[j];
-		}
+
+	for (j = 0; j < IXGBE_MAX_PACKET_BUFFERS; j++) {
+		data[i++] = adapter->stats.pxontxc[j];
+		data[i++] = adapter->stats.pxofftxc[j];
+	}
+	for (j = 0; j < IXGBE_MAX_PACKET_BUFFERS; j++) {
+		data[i++] = adapter->stats.pxonrxc[j];
+		data[i++] = adapter->stats.pxoffrxc[j];
 	}
 }
 
 static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
                               u8 *data)
 {
-	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	char *p = (char *)data;
 	int i;
 
@@ -1126,31 +1142,29 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 			       ETH_GSTRING_LEN);
 			p += ETH_GSTRING_LEN;
 		}
-		for (i = 0; i < adapter->num_tx_queues; i++) {
+		for (i = 0; i < netdev->num_tx_queues; i++) {
 			sprintf(p, "tx_queue_%u_packets", i);
 			p += ETH_GSTRING_LEN;
 			sprintf(p, "tx_queue_%u_bytes", i);
 			p += ETH_GSTRING_LEN;
 		}
-		for (i = 0; i < adapter->num_rx_queues; i++) {
+		for (i = 0; i < IXGBE_NUM_RX_QUEUES; i++) {
 			sprintf(p, "rx_queue_%u_packets", i);
 			p += ETH_GSTRING_LEN;
 			sprintf(p, "rx_queue_%u_bytes", i);
 			p += ETH_GSTRING_LEN;
 		}
-		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			for (i = 0; i < MAX_TX_PACKET_BUFFERS; i++) {
-				sprintf(p, "tx_pb_%u_pxon", i);
-				p += ETH_GSTRING_LEN;
-				sprintf(p, "tx_pb_%u_pxoff", i);
-				p += ETH_GSTRING_LEN;
-			}
-			for (i = 0; i < MAX_RX_PACKET_BUFFERS; i++) {
-				sprintf(p, "rx_pb_%u_pxon", i);
-				p += ETH_GSTRING_LEN;
-				sprintf(p, "rx_pb_%u_pxoff", i);
-				p += ETH_GSTRING_LEN;
-			}
+		for (i = 0; i < IXGBE_MAX_PACKET_BUFFERS; i++) {
+			sprintf(p, "tx_pb_%u_pxon", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "tx_pb_%u_pxoff", i);
+			p += ETH_GSTRING_LEN;
+		}
+		for (i = 0; i < IXGBE_MAX_PACKET_BUFFERS; i++) {
+			sprintf(p, "rx_pb_%u_pxon", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "rx_pb_%u_pxoff", i);
+			p += ETH_GSTRING_LEN;
 		}
 		/* BUG_ON(p - data != IXGBE_STATS_LEN * ETH_GSTRING_LEN); */
 		break;
-- 
1.7.7.6
