From: Phil Sutter <phil.sutter@viprinet.com>
Subject: [PATCH 2/2] wimax: i2400m-usb - use a private struct ethtool_ops
Date: Mon, 26 Mar 2012 13:23:56 +0200
Message-ID: <1332761036-8913-2-git-send-email-phil.sutter@viprinet.com>
References: <1332761036-8913-1-git-send-email-phil.sutter@viprinet.com>
Cc: netdev@vger.kernel.org, inaky.perez-gonzalez@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.vipri.net ([89.207.250.15]:35034 "EHLO zimbra.vipri.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932271Ab2CZLcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2012 07:32:04 -0400
In-Reply-To: <1332761036-8913-1-git-send-email-phil.sutter@viprinet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This way the USB variant of the driver uses usb_make_path in order to
provide bus-info compatible to other USB drivers (like e.g. asix.c).

Signed-off-by: Phil Sutter <phil.sutter@viprinet.com>
---
 drivers/net/wimax/i2400m/usb.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 2c1b8b6..096a228 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -339,6 +339,23 @@ int i2400mu_bus_reset(struct i2400m *i2400m, enum i2400m_reset_type rt)
 	return result;
 }
 
+static void i2400mu_get_drvinfo(struct net_device *net_dev,
+                                struct ethtool_drvinfo *info)
+{
+	struct i2400m *i2400m = net_dev_to_i2400m(net_dev);
+	struct i2400mu *i2400mu = container_of(i2400m, struct i2400mu, i2400m);
+	struct usb_device *udev = i2400mu->usb_dev;
+
+	strncpy(info->driver, KBUILD_MODNAME, sizeof(info->driver) - 1);
+	strncpy(info->fw_version,
+	        i2400m->fw_name ? : "N/A", sizeof(info->fw_version) - 1);
+	usb_make_path(udev, info->bus_info, sizeof(info->bus_info));
+}
+
+static const struct ethtool_ops i2400mu_ethtool_ops = {
+	.get_drvinfo = i2400mu_get_drvinfo,
+	.get_link = ethtool_op_get_link,
+};
 
 static
 void i2400mu_netdev_setup(struct net_device *net_dev)
@@ -347,6 +364,7 @@ void i2400mu_netdev_setup(struct net_device *net_dev)
 	struct i2400mu *i2400mu = container_of(i2400m, struct i2400mu, i2400m);
 	i2400mu_init(i2400mu);
 	i2400m_netdev_setup(net_dev);
+	net_dev->ethtool_ops = &i2400mu_ethtool_ops;
 }
 
 
-- 
1.7.3.4
