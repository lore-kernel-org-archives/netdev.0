From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Need help with MCS7830 driver and 802.1q VLAN Tagging
Date: Thu, 7 Aug 2008 18:06:36 +0100
Message-ID: <20080807170635.GC10471@solarflare.com>
References: <20080807153617.GA4001@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Marc Haber <mh+netdev@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:35264 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752350AbYHGRGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 13:06:41 -0400
Content-Disposition: inline
In-Reply-To: <20080807153617.GA4001@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marc Haber wrote:
> Hi,
> 
> I am having difficulties with the MCS7830 driver in recent Linux
> versions (last version I tried was 2.6.26.1, didn't try 2.6.26.2 yet).
> It looks like the MCS7830 has an issue which prevents VLAN tagged
> ethernet frames from being transmitted and/or received when the frame
> size is near the ethernet MTU.
> 
> This behavior was known around the millennium for a lot of ethernet
> drivers (including tulip) drivers. The host OS does not know that the
> frame is destined to go out via a VLAN tagged interface and thus
> builds frames with a size of up to 1500 octets. Then the VLAN tag gets
> added, which results in a 1504 octet frame, which seems to be dropped
> either by the MCS7830 hardware or its driver.
[...]

This could be a general problem with USB Ethernet drivers, as usbnet.c
doesn't seem to take account of VLAN header overhead.

Does the following help?

Ben.

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 8463efb..d24d22e 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -42,6 +42,7 @@
 #include <linux/mii.h>
 #include <linux/usb.h>
 #include <linux/usb/usbnet.h>
+#include <linux/if_vlan.h>
 
 #define DRIVER_VERSION		"22-Aug-2005"
 
@@ -226,7 +227,7 @@ EXPORT_SYMBOL_GPL(usbnet_skb_return);
 static int usbnet_change_mtu (struct net_device *net, int new_mtu)
 {
 	struct usbnet	*dev = netdev_priv(net);
-	int		ll_mtu = new_mtu + net->hard_header_len;
+	int		ll_mtu = new_mtu + VLAN_HLEN + net->hard_header_len;
 	int		old_hard_mtu = dev->hard_mtu;
 	int		old_rx_urb_size = dev->rx_urb_size;
 
@@ -237,7 +238,7 @@ static int usbnet_change_mtu (struct net_device *net, int new_mtu)
 		return -EDOM;
 	net->mtu = new_mtu;
 
-	dev->hard_mtu = net->mtu + net->hard_header_len;
+	dev->hard_mtu = ll_mtu;
 	if (dev->rx_urb_size == old_hard_mtu) {
 		dev->rx_urb_size = dev->hard_mtu;
 		if (dev->rx_urb_size > old_rx_urb_size)
@@ -1173,7 +1174,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	/* rx and tx sides can use different message sizes;
 	 * bind() should set rx_urb_size in that case.
 	 */
-	dev->hard_mtu = net->mtu + net->hard_header_len;
+	dev->hard_mtu = net->mtu + VLAN_HLEN + net->hard_header_len;
 #if 0
 // dma_supported() is deeply broken on almost all architectures
 	// possible with some EHCI controllers
@@ -1208,8 +1209,8 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 			strcpy(net->name, "wlan%d");
 
 		/* maybe the remote can't receive an Ethernet MTU */
-		if (net->mtu > (dev->hard_mtu - net->hard_header_len))
-			net->mtu = dev->hard_mtu - net->hard_header_len;
+		if (net->mtu > (dev->hard_mtu - VLAN_HLEN - net->hard_header_len))
+			net->mtu = dev->hard_mtu - VLAN_HLEN - net->hard_header_len;
 	} else if (!info->in || !info->out)
 		status = usbnet_get_endpoints (dev, udev);
 	else {

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
