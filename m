From: Oliver Neukum <oneukum@suse.com>
Subject: [RFC/RFT PATCH 1/9] net: usb: usbnet: add ksettings method
Date: Wed, 15 Mar 2017 16:02:40 +0100
Message-ID: <20170315150248.10997-2-oneukum@suse.com>
References: <20170315150248.10997-1-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59846 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753882AbdCOPDj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 11:03:39 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id 0450AACCA
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 15:03:38 +0000 (UTC)
In-Reply-To: <20170315150248.10997-1-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the new ksettings API of the ethtool
methods to usbnet.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
---
 drivers/net/usb/usbnet.c   | 35 +++++++++++++++++++++++++++++++++++
 include/linux/usb/usbnet.h |  4 ++++
 2 files changed, 39 insertions(+)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 3de65ea..3d7103a 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -947,6 +947,41 @@ EXPORT_SYMBOL_GPL(usbnet_open);
  * they'll probably want to use this base set.
  */
 
+int usbnet_get_ksettings(struct net_device *net,
+				struct ethtool_link_ksettings *cmd)
+{
+	struct usbnet *dev = netdev_priv(net);
+
+	if (!dev->mii.mdio_read)
+		return -EOPNOTSUPP;
+
+	return mii_ethtool_get_link_ksettings(&dev->mii, cmd);
+}
+EXPORT_SYMBOL_GPL(usbnet_get_ksettings);
+
+int usbnet_set_ksettings(struct net_device *net,
+				const struct ethtool_link_ksettings *cmd)
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
+
+}
+EXPORT_SYMBOL_GPL(usbnet_set_ksettings);
+
 int usbnet_get_settings (struct net_device *net, struct ethtool_cmd *cmd)
 {
 	struct usbnet *dev = netdev_priv(net);
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 6e0ce8c..c32ee9a 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -261,6 +261,10 @@ extern void usbnet_pause_rx(struct usbnet *);
 extern void usbnet_resume_rx(struct usbnet *);
 extern void usbnet_purge_paused_rxq(struct usbnet *);
 
+extern int usbnet_get_ksettings(struct net_device *net,
+				struct ethtool_link_ksettings *cmd);
+extern int usbnet_set_ksettings(struct net_device *net,
+				const struct ethtool_link_ksettings *cmd);
 extern int usbnet_get_settings(struct net_device *net,
 			       struct ethtool_cmd *cmd);
 extern int usbnet_set_settings(struct net_device *net,
-- 
2.10.2
