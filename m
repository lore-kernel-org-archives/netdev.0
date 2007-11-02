From: David Brownell <david-b@pacbell.net>
Subject: Re: build #337 failed for 2.6.24-rc1-gb1d08ac In function `usbnet_set_settings':
Date: Fri, 2 Nov 2007 11:45:15 -0700
Message-ID: <200711021145.15542.david-b@pacbell.net>
References: <200711012024.57412.toralf.foerster@gmx.de> <200711011632.18333.david-b@pacbell.net> <20071101234443.GD7227@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Toralf =?iso-8859-1?q?F=F6rster?= <toralf.foerster@gmx.de>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp119.sbc.mail.sp1.yahoo.com ([69.147.64.92]:45278 "HELO
	smtp119.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756794AbXKBSpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2007 14:45:18 -0400
In-Reply-To: <20071101234443.GD7227@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 01 November 2007, Adrian Bunk wrote:
> The following combination of options is simply an unusual one:
> 
> CONFIG_MII=m
> CONFIG_USB_USBNET=y
> CONFIG_USB_USBNET_MII=n

I though that had been fixed for ages ...

This should do a better job of it.

- Dave

==========	CUT HERE
Simplify handling of the MII-dependent usbnet based adapters:  stick
to forward dependencies, and explicitly handle the core dependency.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
 drivers/net/usb/Kconfig  |   23 ++++++++++++-----------
 drivers/net/usb/usbnet.c |    9 ++++++++-
 2 files changed, 20 insertions(+), 12 deletions(-)

--- a.orig/drivers/net/usb/Kconfig	2007-10-21 10:35:16.000000000 -0700
+++ a/drivers/net/usb/Kconfig	2007-11-02 11:32:15.000000000 -0700
@@ -93,13 +93,8 @@ config USB_RTL8150
 	  To compile this driver as a module, choose M here: the
 	  module will be called rtl8150.
 
-config USB_USBNET_MII
-	tristate
-	default n
-
 config USB_USBNET
 	tristate "Multi-purpose USB Networking Framework"
-	select MII if USB_USBNET_MII != n
 	---help---
 	  This driver supports several kinds of network links over USB,
 	  with "minidrivers" built around a common network driver core
@@ -131,11 +126,19 @@ config USB_USBNET
 	  To compile this driver as a module, choose M here: the
 	  module will be called usbnet.
 
+# usbnet core will support MII when MII is static, or both are modules
+config USB_NET_MII
+	tristate
+	depends on USB_USBNET && NET_ETHERNET && (MII = y || MII = USB_USBNET)
+	default MII
+
+comment "MII support is needed for most Ethernet adapters"
+	depends on USB_USBNET && USB_NET_MII=n
+
 config USB_NET_AX8817X
 	tristate "ASIX AX88xxx Based USB 2.0 Ethernet Adapters"
-	depends on USB_USBNET && NET_ETHERNET
+	depends on USB_USBNET && USB_NET_MII
 	select CRC32
-	select USB_USBNET_MII
 	default y
 	help
 	  This option adds support for ASIX AX88xxx based USB 2.0
@@ -188,9 +191,8 @@ config USB_NET_CDCETHER
 
 config USB_NET_DM9601
 	tristate "Davicom DM9601 based USB 1.1 10/100 ethernet devices"
-	depends on USB_USBNET
+	depends on USB_USBNET && USB_NET_MII
 	select CRC32
-	select USB_USBNET_MII
 	help
 	  This option adds support for Davicom DM9601 based USB 1.1
 	  10/100 Ethernet adapters.
@@ -224,8 +226,7 @@ config USB_NET_PLUSB
 
 config USB_NET_MCS7830
 	tristate "MosChip MCS7830 based Ethernet adapters"
-	depends on USB_USBNET
-	select USB_USBNET_MII
+	depends on USB_USBNET && USB_NET_MII
 	help
 	  Choose this option if you're using a 10/100 Ethernet USB2
 	  adapter based on the MosChip 7830 controller. This includes
--- a.orig/drivers/net/usb/usbnet.c	2007-10-13 15:16:10.000000000 -0700
+++ a/drivers/net/usb/usbnet.c	2007-11-02 11:39:59.000000000 -0700
@@ -682,10 +682,17 @@ done_nopm:
 /* ethtool methods; minidrivers may need to add some more, but
  * they'll probably want to use this base set.
  */
+#undef HAVE_MII
 
-#if defined(CONFIG_MII) || defined(CONFIG_MII_MODULE)
+#if defined(CONFIG_MII)
 #define HAVE_MII
 
+#elif defined(CONFIG_MII_MODULE) && defined(MODULE)
+#define HAVE_MII
+#endif
+
+#ifdef HAVE_MII
+
 int usbnet_get_settings (struct net_device *net, struct ethtool_cmd *cmd)
 {
 	struct usbnet *dev = netdev_priv(net);

