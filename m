From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 01/11] net: usb: usbnet: add new api ethtool_{get|set}_link_ksettings
Date: Thu, 16 Mar 2017 23:18:47 +0100
Message-ID: <1489702737-2401-2-git-send-email-tremyfr@gmail.com>
References: <1489702737-2401-1-git-send-email-tremyfr@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: oliver@neukum.org, jacmet@sunsite.dk,
        steve.glendinning@shawell.net, UNGLinuxDriver@microchip.com,
        gregkh@linuxfoundation.org, davem@davemloft.net,
        robert.foss@collabora.com, allan@asix.com.tw, grundler@google.com,
        jarod@redhat.com, peter.chen@nxp.com, stefan.bruens@rwth-aachen.de,
        akpm@linux-foundation.org, adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35651 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752562AbdCPWUG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 18:20:06 -0400
In-Reply-To: <1489702737-2401-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We add the new api {get|set}_link_ksettings to this driver.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/usb/usbnet.c   |   36 ++++++++++++++++++++++++++++++++++++
 include/linux/usb/usbnet.h |    4 ++++
 2 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 3de65ea..1b40b18 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -980,6 +980,40 @@ int usbnet_set_settings (struct net_device *net, struct ethtool_cmd *cmd)
 }
 EXPORT_SYMBOL_GPL(usbnet_set_settings);
 
+int usbnet_get_link_ksettings(struct net_device *net,
+			      struct ethtool_link_ksettings *cmd)
+{
+	struct usbnet *dev = netdev_priv(net);
+
+	if (!dev->mii.mdio_read)
+		return -EOPNOTSUPP;
+
+	return mii_ethtool_get_link_ksettings(&dev->mii, cmd);
+}
+EXPORT_SYMBOL_GPL(usbnet_get_link_ksettings);
+
+int usbnet_set_link_ksettings(struct net_device *net,
+			      const struct ethtool_link_ksettings *cmd)
+{
+	struct usbnet *dev = netdev_priv(net);
+	int retval;
+
+	if (!dev->mii.mdio_write)
+		return -EOPNOTSUPP;
+
+	retval = mii_ethtool_set_link_ksettings(&dev->mii, cmd);
+
+	/* link speed/duplex might have changed */
+	if (dev->driver_info->link_reset)
+		dev->driver_info->link_reset(dev);
+
+	/* hard_mtu or rx_urb_size may change in link_reset() */
+	usbnet_update_max_qlen(dev);
+
+	return retval;
+}
+EXPORT_SYMBOL_GPL(usbnet_set_link_ksettings);
+
 u32 usbnet_get_link (struct net_device *net)
 {
 	struct usbnet *dev = netdev_priv(net);
@@ -1046,6 +1080,8 @@ void usbnet_set_msglevel (struct net_device *net, u32 level)
 	.get_msglevel		= usbnet_get_msglevel,
 	.set_msglevel		= usbnet_set_msglevel,
 	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_link_ksettings	= usbnet_get_link_ksettings,
+	.set_link_ksettings	= usbnet_set_link_ksettings,
 };
 
 /*-------------------------------------------------------------------------*/
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 6e0ce8c..5bd8007 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -265,6 +265,10 @@ extern int usbnet_get_settings(struct net_device *net,
 			       struct ethtool_cmd *cmd);
 extern int usbnet_set_settings(struct net_device *net,
 			       struct ethtool_cmd *cmd);
+extern int usbnet_get_link_ksettings(struct net_device *net,
+				     struct ethtool_link_ksettings *cmd);
+extern int usbnet_set_link_ksettings(struct net_device *net,
+				     const struct ethtool_link_ksettings *cmd);
 extern u32 usbnet_get_link(struct net_device *net);
 extern u32 usbnet_get_msglevel(struct net_device *);
 extern void usbnet_set_msglevel(struct net_device *, u32);
-- 
1.7.4.4
