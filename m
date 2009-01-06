From: Wu Fengguang <wfg@linux.intel.com>
Subject: Re: [PATCH] dm9601: handle corrupt mac address
Date: Tue, 6 Jan 2009 17:50:08 +0800
Message-ID: <20090106095008.GA19365@localhost>
References: <20090106061414.GA3677@localhost> <87hc4cvp05.fsf@macbook.be.48ers.dk> <20090106082928.GB19690@localhost> <874p0cvnae.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dbrownell@users.sourceforge.net, netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:40394 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750711AbZAFJuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 04:50:10 -0500
Content-Disposition: inline
In-Reply-To: <874p0cvnae.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 06, 2009 at 09:42:01AM +0100, Peter Korsgaard wrote:
> >>>>> "Wu" == Wu Fengguang <wfg@linux.intel.com> writes:
> 
> Hi,
> 
>  >> Do we automatically get a random address in netdev nowadays without
>  >> calling random_ether_addr? I didn't know that.
> 
>  Wu> I confirmed based on both code review and tests.
>  Wu> The logic goes like this in usbnet.c:
> 
>  Wu>   80 // randomly generated ethernet address
>  Wu>   81 static u8       node_id [ETH_ALEN];
>  Wu> ...
>  Wu> 1118 int
>  Wu> 1119 usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
>  Wu> 1120 {
>  Wu> ...
>  Wu> 1168         dev->net = net;
>  Wu> 1169         strcpy (net->name, "usb%d");
>  Wu> 1170         memcpy (net->dev_addr, node_id, sizeof node_id);
>  Wu> ...
> 
> So what happens if you plug in 2 devices without an EEPROM? Do they
> get the same MAC address? That seems broken.

Good catch. The following patch for this case was tested OK.

But this simple fix will make the mac address change between
ifup/ifdowns, is this acceptable?

Thanks,
Fengguang
---
usbnet: use different random mac addresses for multiple usbnet devices

It is a bug to use the same mac address for possibly 2+ connected
usbnet devices.  Fix this concern raised by Peter Korsgaard.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 drivers/net/usb/usbnet.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

--- linux-2.6.orig/drivers/net/usb/usbnet.c
+++ linux-2.6/drivers/net/usb/usbnet.c
@@ -77,9 +77,6 @@
 
 /*-------------------------------------------------------------------------*/
 
-// randomly generated ethernet address
-static u8	node_id [ETH_ALEN];
-
 static const char driver_name [] = "usbnet";
 
 /* use ethtool to change the level for any given device */
@@ -1167,7 +1164,7 @@ usbnet_probe (struct usb_interface *udev
 
 	dev->net = net;
 	strcpy (net->name, "usb%d");
-	memcpy (net->dev_addr, node_id, sizeof node_id);
+	random_ether_addr(net->dev_addr);
 
 	/* rx and tx sides can use different message sizes;
 	 * bind() should set rx_urb_size in that case.
@@ -1310,7 +1307,6 @@ static int __init usbnet_init(void)
 	BUILD_BUG_ON (sizeof (((struct sk_buff *)0)->cb)
 			< sizeof (struct skb_data));
 
-	random_ether_addr(node_id);
 	return 0;
 }
 module_init(usbnet_init);
