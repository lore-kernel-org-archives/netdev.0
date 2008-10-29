From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] macvlan: add support for ethtool get settings
Date: Wed, 29 Oct 2008 12:53:43 -0700
Message-ID: <20081029125343.695eeb3c@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53078 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752618AbYJ2T7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 15:59:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If macvlan's are used, it is useful to propgate speed and other settings
from underlying device up for application usage.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/macvlan.c	2008-10-29 09:42:06.000000000 -0700
+++ b/drivers/net/macvlan.c	2008-10-29 09:52:11.000000000 -0700
@@ -333,10 +333,34 @@ static u32 macvlan_ethtool_get_rx_csum(s
 	return lowerdev->ethtool_ops->get_rx_csum(lowerdev);
 }
 
+static int macvlan_ethtool_get_settings(struct net_device *dev,
+					struct ethtool_cmd *cmd)
+{
+	const struct macvlan_dev *vlan = netdev_priv(dev);
+	struct net_device *lowerdev = vlan->lowerdev;
+
+	if (!lowerdev->ethtool_ops->get_settings)
+		return -EOPNOTSUPP;
+
+	return lowerdev->ethtool_ops->get_settings(lowerdev, cmd);
+}
+
+static u32 macvlan_ethtool_get_flags(struct net_device *dev)
+{
+	const struct macvlan_dev *vlan = netdev_priv(dev);
+	struct net_device *lowerdev = vlan->lowerdev;
+
+	if (!lowerdev->ethtool_ops->get_flags)
+		return 0;
+	return lowerdev->ethtool_ops->get_flags(lowerdev);
+}
+
 static const struct ethtool_ops macvlan_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
+	.get_settings		= macvlan_ethtool_get_settings,
 	.get_rx_csum		= macvlan_ethtool_get_rx_csum,
 	.get_drvinfo		= macvlan_ethtool_get_drvinfo,
+	.get_flags		= macvlan_ethtool_get_flags,
 };
 
 static void macvlan_setup(struct net_device *dev)
