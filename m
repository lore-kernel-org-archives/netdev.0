From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH 2/4] enic: fixes for review items from Ben Hutchings
Date: Wed, 24 Sep 2008 11:23:32 -0700
Message-ID: <20080924182332.22778.55520.stgit@palito_client100.nuovasystems.com>
References: <20080924182154.22778.76605.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:1317 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754545AbYIXSYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 14:24:23 -0400
In-Reply-To: <20080924182154.22778.76605.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: fixes for review items from Ben Hutchings

Fixes for review items from Ben Hutchings:
 - use netdev->net_stats rather than private net_stats
 - use ethtool op .get_sset_count rather than .get_stats_count
 - err out if setting Tx/Rx csum or TSO using ethtool and setting is
   not enabled for device.
 - pass in jiffies + constant to round_jiffies
 - return err if new MTU is out-of-bounds

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic.h      |    1 -
 drivers/net/enic/enic_main.c |   62 +++++++++++++++++++++++++-----------------
 2 files changed, 37 insertions(+), 26 deletions(-)

diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index fb83c92..9e0d484 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -75,7 +75,6 @@ struct enic {
 	struct vnic_enet_config config;
 	struct vnic_dev_bar bar0;
 	struct vnic_dev *vdev;
-	struct net_device_stats net_stats;
 	struct timer_list notify_timer;
 	struct work_struct reset;
 	struct msix_entry msix_entry[ENIC_MSIX_MAX];
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 6284594..c741bbf 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -44,7 +44,6 @@
 #include "enic.h"
 
 #define ENIC_NOTIFY_TIMER_PERIOD	(2 * HZ)
-#define ENIC_JUMBO_FIRST_BUF_SIZE	256
 
 /* Supported devices */
 static struct pci_device_id enic_id_table[] = {
@@ -168,9 +167,14 @@ static void enic_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 	}
 }
 
-static int enic_get_stats_count(struct net_device *netdev)
+static int enic_get_sset_count(struct net_device *netdev, int sset)
 {
-	return enic_n_tx_stats + enic_n_rx_stats;
+	switch (sset) {
+	case ETH_SS_STATS:
+		return enic_n_tx_stats + enic_n_rx_stats;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static void enic_get_ethtool_stats(struct net_device *netdev,
@@ -200,8 +204,10 @@ static int enic_set_rx_csum(struct net_device *netdev, u32 data)
 {
 	struct enic *enic = netdev_priv(netdev);
 
-	enic->csum_rx_enabled =
-		(data && ENIC_SETTING(enic, RXCSUM)) ? 1 : 0;
+	if (data && !ENIC_SETTING(enic, RXCSUM))
+		return -EINVAL;
+
+	enic->csum_rx_enabled = !!data;
 
 	return 0;
 }
@@ -210,7 +216,10 @@ static int enic_set_tx_csum(struct net_device *netdev, u32 data)
 {
 	struct enic *enic = netdev_priv(netdev);
 
-	if (data && ENIC_SETTING(enic, TXCSUM))
+	if (data && !ENIC_SETTING(enic, TXCSUM))
+		return -EINVAL;
+
+	if (data)
 		netdev->features |= NETIF_F_HW_CSUM;
 	else
 		netdev->features &= ~NETIF_F_HW_CSUM;
@@ -222,7 +231,10 @@ static int enic_set_tso(struct net_device *netdev, u32 data)
 {
 	struct enic *enic = netdev_priv(netdev);
 
-	if (data && ENIC_SETTING(enic, TSO))
+	if (data && !ENIC_SETTING(enic, TSO))
+		return -EINVAL;
+
+	if (data)
 		netdev->features |=
 			NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN;
 	else
@@ -251,7 +263,7 @@ static struct ethtool_ops enic_ethtool_ops = {
 	.set_msglevel = enic_set_msglevel,
 	.get_link = ethtool_op_get_link,
 	.get_strings = enic_get_strings,
-	.get_stats_count = enic_get_stats_count,
+	.get_sset_count = enic_get_sset_count,
 	.get_ethtool_stats = enic_get_ethtool_stats,
 	.get_rx_csum = enic_get_rx_csum,
 	.set_rx_csum = enic_set_rx_csum,
@@ -653,25 +665,26 @@ static int enic_hard_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 static struct net_device_stats *enic_get_stats(struct net_device *netdev)
 {
 	struct enic *enic = netdev_priv(netdev);
+	struct net_device_stats *net_stats = &netdev->stats;
 	struct vnic_stats *stats;
 
 	spin_lock(&enic->devcmd_lock);
 	vnic_dev_stats_dump(enic->vdev, &stats);
 	spin_unlock(&enic->devcmd_lock);
 
-	enic->net_stats.tx_packets = stats->tx.tx_frames_ok;
-	enic->net_stats.tx_bytes = stats->tx.tx_bytes_ok;
-	enic->net_stats.tx_errors = stats->tx.tx_errors;
-	enic->net_stats.tx_dropped = stats->tx.tx_drops;
+	net_stats->tx_packets = stats->tx.tx_frames_ok;
+	net_stats->tx_bytes = stats->tx.tx_bytes_ok;
+	net_stats->tx_errors = stats->tx.tx_errors;
+	net_stats->tx_dropped = stats->tx.tx_drops;
 
-	enic->net_stats.rx_packets = stats->rx.rx_frames_ok;
-	enic->net_stats.rx_bytes = stats->rx.rx_bytes_ok;
-	enic->net_stats.rx_errors = stats->rx.rx_errors;
-	enic->net_stats.multicast = stats->rx.rx_multicast_frames_ok;
-	enic->net_stats.rx_crc_errors = stats->rx.rx_crc_errors;
-	enic->net_stats.rx_dropped = stats->rx.rx_no_bufs;
+	net_stats->rx_packets = stats->rx.rx_frames_ok;
+	net_stats->rx_bytes = stats->rx.rx_bytes_ok;
+	net_stats->rx_errors = stats->rx.rx_errors;
+	net_stats->multicast = stats->rx.rx_multicast_frames_ok;
+	net_stats->rx_crc_errors = stats->rx.rx_crc_errors;
+	net_stats->rx_dropped = stats->rx.rx_no_bufs;
 
-	return &enic->net_stats;
+	return net_stats;
 }
 
 static void enic_reset_mcaddrs(struct enic *enic)
@@ -1110,7 +1123,8 @@ static void enic_notify_timer(unsigned long data)
 
 	enic_notify_check(enic);
 
-	mod_timer(&enic->notify_timer, round_jiffies(ENIC_NOTIFY_TIMER_PERIOD));
+	mod_timer(&enic->notify_timer,
+		round_jiffies(jiffies + ENIC_NOTIFY_TIMER_PERIOD));
 }
 
 static void enic_free_intr(struct enic *enic)
@@ -1314,14 +1328,12 @@ static int enic_change_mtu(struct net_device *netdev, int new_mtu)
 	struct enic *enic = netdev_priv(netdev);
 	int running = netif_running(netdev);
 
+	if (new_mtu < ENIC_MIN_MTU || new_mtu > ENIC_MAX_MTU)
+		return -EINVAL;
+
 	if (running)
 		enic_stop(netdev);
 
-	if (new_mtu < ENIC_MIN_MTU)
-		new_mtu = ENIC_MIN_MTU;
-	if (new_mtu > ENIC_MAX_MTU)
-		new_mtu = ENIC_MAX_MTU;
-
 	netdev->mtu = new_mtu;
 
 	if (netdev->mtu > enic->port_mtu)

