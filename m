From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next] vlan: Pass ethtool get_ts_info queries to real device.
Date: Fri, 21 Nov 2014 14:16:20 +0100
Message-ID: <1416575780-19132-1-git-send-email-richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:58857 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757965AbaKUNX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 08:23:58 -0500
Received: by mail-wg0-f49.google.com with SMTP id x12so6499932wgg.8
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 05:23:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a6111d3c "vlan: Pass SIOC[SG]HWTSTAMP ioctls to real device"
intended to enable hardware time stamping on VLAN interfaces, but
passing SIOCSHWTSTAMP is only half of the story. This patch adds
the second half, by letting user space find out the time stamping
capabilities of the device backing a VLAN interface.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 net/8021q/vlan_dev.c |   19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 0d441ec..960aeb8 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -26,6 +26,7 @@
 #include <linux/slab.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
+#include <linux/net_tstamp.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <net/arp.h>
@@ -669,6 +670,23 @@ static void vlan_ethtool_get_drvinfo(struct net_device *dev,
 	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
 }
 
+static int vlan_ethtool_get_ts_info(struct net_device *dev,
+				    struct ethtool_ts_info *info)
+{
+	const struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
+	const struct ethtool_ops *ops = vlan->real_dev->ethtool_ops;
+
+	if (ops->get_ts_info) {
+		return ops->get_ts_info(vlan->real_dev, info);
+	} else {
+		info->so_timestamping = SOF_TIMESTAMPING_RX_SOFTWARE |
+			SOF_TIMESTAMPING_SOFTWARE;
+		info->phc_index = -1;
+	}
+
+	return 0;
+}
+
 static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct vlan_pcpu_stats *p;
@@ -752,6 +770,7 @@ static const struct ethtool_ops vlan_ethtool_ops = {
 	.get_settings	        = vlan_ethtool_get_settings,
 	.get_drvinfo	        = vlan_ethtool_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
+	.get_ts_info		= vlan_ethtool_get_ts_info,
 };
 
 static const struct net_device_ops vlan_netdev_ops = {
-- 
1.7.10.4
