From: <Woojung.Huh@microchip.com>
Subject: [PATCH v2 net-next 2/2] lan78xx: add ndo_get_stats64
Date: Wed, 16 Mar 2016 22:10:42 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404C94C8@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:37088 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754937AbcCPWKo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 18:10:44 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <woojung.huh@microchip.com>

Add lan78xx_get_stats64 of ndo_get_stats64 to report
all statistics counters including errors from HW statistics.

Read from HW when auto suspend is disabled, use saved counter when
auto suspend is enabled because periodic call to ndo_get_stats64
prevents USB auto suspend.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 49 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index f20890e..d36d5eb 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -3261,6 +3261,54 @@ void lan78xx_tx_timeout(struct net_device *net)
 	tasklet_schedule(&dev->bh);
 }
 
+struct rtnl_link_stats64 *lan78xx_get_stats64(struct net_device *netdev,
+					      struct rtnl_link_stats64 *storage)
+{
+	struct lan78xx_net *dev = netdev_priv(netdev);
+	struct lan78xx_statstage64 stats;
+
+	/* curr_stat is updated by timer.
+	 * periodic reading from HW will prevent from entering USB auto suspend.
+	 * if autosuspend is disabled, read from HW.
+	 */
+	if (!dev->udev->dev.power.runtime_auto)
+		lan78xx_update_stats(dev);
+
+	mutex_lock(&dev->stats.access_lock);
+	memcpy(&stats, &dev->stats.curr_stat, sizeof(stats));
+	mutex_unlock(&dev->stats.access_lock);
+
+	/* calc by driver */
+	storage->rx_packets = (__u64)netdev->stats.rx_packets;
+	storage->tx_packets = (__u64)netdev->stats.tx_packets;
+	storage->rx_bytes = (__u64)netdev->stats.rx_bytes;
+	storage->tx_bytes = (__u64)netdev->stats.tx_bytes;
+
+	/* use counter */
+	storage->rx_length_errors = stats.rx_undersize_frame_errors +
+				    stats.rx_oversize_frame_errors;
+	storage->rx_crc_errors = stats.rx_fcs_errors;
+	storage->rx_frame_errors = stats.rx_alignment_errors;
+	storage->rx_fifo_errors = stats.rx_dropped_frames;
+	storage->rx_over_errors = stats.rx_oversize_frame_errors;
+	storage->rx_errors = stats.rx_fcs_errors +
+			     stats.rx_alignment_errors +
+			     stats.rx_fragment_errors +
+			     stats.rx_jabber_errors +
+			     stats.rx_undersize_frame_errors +
+			     stats.rx_oversize_frame_errors +
+			     stats.rx_dropped_frames;
+
+	storage->tx_carrier_errors = stats.tx_carrier_errors;
+	storage->tx_errors = stats.tx_fcs_errors +
+			     stats.tx_excess_deferral_errors +
+			     stats.tx_carrier_errors;
+
+	storage->multicast = stats.rx_multicast_frames;
+
+	return storage;
+}
+
 static const struct net_device_ops lan78xx_netdev_ops = {
 	.ndo_open		= lan78xx_open,
 	.ndo_stop		= lan78xx_stop,
@@ -3274,6 +3322,7 @@ static const struct net_device_ops lan78xx_netdev_ops = {
 	.ndo_set_features	= lan78xx_set_features,
 	.ndo_vlan_rx_add_vid	= lan78xx_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= lan78xx_vlan_rx_kill_vid,
+	.ndo_get_stats64	= lan78xx_get_stats64,
 };
 
 static void lan78xx_stat_monitor(unsigned long param)
-- 
2.7.0
