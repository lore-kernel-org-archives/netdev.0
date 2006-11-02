From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 2/2] usbnet: use MII hooks only if CONFIG_MII is enabled
Date: Thu, 2 Nov 2006 12:29:12 -0800
Message-ID: <200611021229.17324.david-b@pacbell.net>
References: <Pine.LNX.4.64.0610231618510.3962@g5.osdl.org> <200610251922.09692.david-b@pacbell.net> <20061102071507.GB28382@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>, toralf.foerster@gmx.de,
	netdev@vger.kernel.org, linux-usb-devel@lists.sourceforge.net,
	link@miggy.org, akpm@osdl.org, zippel@linux-m68k.org,
	torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp108.sbc.mail.mud.yahoo.com ([68.142.198.207]:21838 "HELO
	smtp108.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1752630AbWKBUkd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 15:40:33 -0500
To: Greg KH <greg@kroah.com>
In-Reply-To: <20061102071507.GB28382@kroah.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 01 November 2006 11:15 pm, Greg KH wrote:

> Argh, there were just too many different versions of these patches
> floating around.  Can you resend the final versions please?

This should replace BOTH of Randy's patches.  It addresses all the
issues I've heard raised, and resolves the regresssion introduced
when adding the mcs7830 minidriver.

- Dave

============	CUT HERE
Fix mcs7830 patch

The recent mcs7830 update to make the MII support sharable goofed various
pre-existing configurations in two ways:
 
  - it made the usbnet infrastructure reference MII symbols even
    when they're not needed in the kernel being built
    
  - it didn't enable MII along with the mcs7830 minidriver

This patch fixes these two problems.

However, there does seem to be a Kconfig reverse dependency bug in that MII
gets wrongly enabled in some cases (like USBNET=y and USBNET_MII=n); I think
I've noticed that same problem in other situations too.  So the result can
mean kernels being bloated by stuff that's needlessly enabled ... better
than wrongly being disabled, but contributing to bloat.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>

Index: at91/drivers/usb/net/Kconfig
===================================================================
--- at91.orig/drivers/usb/net/Kconfig	2006-11-02 10:58:49.000000000 -0800
+++ at91/drivers/usb/net/Kconfig	2006-11-02 12:10:13.000000000 -0800
@@ -92,8 +92,13 @@ config USB_RTL8150
 	  To compile this driver as a module, choose M here: the
 	  module will be called rtl8150.
 
+config USB_USBNET_MII
+	tristate
+	default n
+
 config USB_USBNET
 	tristate "Multi-purpose USB Networking Framework"
+	select MII if USBNET_MII != n
 	---help---
 	  This driver supports several kinds of network links over USB,
 	  with "minidrivers" built around a common network driver core
@@ -129,7 +134,7 @@ config USB_NET_AX8817X
 	tristate "ASIX AX88xxx Based USB 2.0 Ethernet Adapters"
 	depends on USB_USBNET && NET_ETHERNET
 	select CRC32
-	select MII
+	select USB_USBNET_MII
 	default y
 	help
 	  This option adds support for ASIX AX88xxx based USB 2.0
@@ -210,6 +215,7 @@ config USB_NET_PLUSB
 config USB_NET_MCS7830
 	tristate "MosChip MCS7830 based Ethernet adapters"
 	depends on USB_USBNET
+	select USB_USBNET_MII
 	help
 	  Choose this option if you're using a 10/100 Ethernet USB2
 	  adapter based on the MosChip 7830 controller. This includes
Index: at91/drivers/usb/net/usbnet.c
===================================================================
--- at91.orig/drivers/usb/net/usbnet.c	2006-11-02 10:58:49.000000000 -0800
+++ at91/drivers/usb/net/usbnet.c	2006-11-02 11:09:29.000000000 -0800
@@ -669,6 +669,9 @@ done:
  * they'll probably want to use this base set.
  */
 
+#if defined(CONFIG_MII) || defined(CONFIG_MII_MODULE)
+#define HAVE_MII
+
 int usbnet_get_settings (struct net_device *net, struct ethtool_cmd *cmd)
 {
 	struct usbnet *dev = netdev_priv(net);
@@ -699,20 +702,6 @@ int usbnet_set_settings (struct net_devi
 }
 EXPORT_SYMBOL_GPL(usbnet_set_settings);
 
-
-void usbnet_get_drvinfo (struct net_device *net, struct ethtool_drvinfo *info)
-{
-	struct usbnet *dev = netdev_priv(net);
-
-	/* REVISIT don't always return "usbnet" */
-	strncpy (info->driver, driver_name, sizeof info->driver);
-	strncpy (info->version, DRIVER_VERSION, sizeof info->version);
-	strncpy (info->fw_version, dev->driver_info->description,
-		sizeof info->fw_version);
-	usb_make_path (dev->udev, info->bus_info, sizeof info->bus_info);
-}
-EXPORT_SYMBOL_GPL(usbnet_get_drvinfo);
-
 u32 usbnet_get_link (struct net_device *net)
 {
 	struct usbnet *dev = netdev_priv(net);
@@ -730,40 +719,57 @@ u32 usbnet_get_link (struct net_device *
 }
 EXPORT_SYMBOL_GPL(usbnet_get_link);
 
-u32 usbnet_get_msglevel (struct net_device *net)
+int usbnet_nway_reset(struct net_device *net)
 {
 	struct usbnet *dev = netdev_priv(net);
 
-	return dev->msg_enable;
+	if (!dev->mii.mdio_write)
+		return -EOPNOTSUPP;
+
+	return mii_nway_restart(&dev->mii);
 }
-EXPORT_SYMBOL_GPL(usbnet_get_msglevel);
+EXPORT_SYMBOL_GPL(usbnet_nway_reset);
 
-void usbnet_set_msglevel (struct net_device *net, u32 level)
+#endif	/* HAVE_MII */
+
+void usbnet_get_drvinfo (struct net_device *net, struct ethtool_drvinfo *info)
 {
 	struct usbnet *dev = netdev_priv(net);
 
-	dev->msg_enable = level;
+	/* REVISIT don't always return "usbnet" */
+	strncpy (info->driver, driver_name, sizeof info->driver);
+	strncpy (info->version, DRIVER_VERSION, sizeof info->version);
+	strncpy (info->fw_version, dev->driver_info->description,
+		sizeof info->fw_version);
+	usb_make_path (dev->udev, info->bus_info, sizeof info->bus_info);
 }
-EXPORT_SYMBOL_GPL(usbnet_set_msglevel);
+EXPORT_SYMBOL_GPL(usbnet_get_drvinfo);
 
-int usbnet_nway_reset(struct net_device *net)
+u32 usbnet_get_msglevel (struct net_device *net)
 {
 	struct usbnet *dev = netdev_priv(net);
 
-	if (!dev->mii.mdio_write)
-		return -EOPNOTSUPP;
+	return dev->msg_enable;
+}
+EXPORT_SYMBOL_GPL(usbnet_get_msglevel);
 
-	return mii_nway_restart(&dev->mii);
+void usbnet_set_msglevel (struct net_device *net, u32 level)
+{
+	struct usbnet *dev = netdev_priv(net);
+
+	dev->msg_enable = level;
 }
-EXPORT_SYMBOL_GPL(usbnet_nway_reset);
+EXPORT_SYMBOL_GPL(usbnet_set_msglevel);
 
 /* drivers may override default ethtool_ops in their bind() routine */
 static struct ethtool_ops usbnet_ethtool_ops = {
+#ifdef	HAVE_MII
 	.get_settings		= usbnet_get_settings,
 	.set_settings		= usbnet_set_settings,
-	.get_drvinfo		= usbnet_get_drvinfo,
 	.get_link		= usbnet_get_link,
 	.nway_reset		= usbnet_nway_reset,
+#endif
+	.get_drvinfo		= usbnet_get_drvinfo,
 	.get_msglevel		= usbnet_get_msglevel,
 	.set_msglevel		= usbnet_set_msglevel,
 };
