From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] net: cdc_ether.c: Add SE J105i to device whitelist
Date: Tue, 05 Jan 2010 12:52:20 -0800
Message-ID: <1262724740.16627.381.camel@localhost.localdomain>
References: <1261601807-8385-1-git-send-email-tloo@saltstorm.net>
	 <1261604906.609.106.camel@localhost.localdomain>
	 <878wcdx6tt.fsf@nemi.mork.no>
	 <1262639441.16627.322.camel@localhost.localdomain>
	 <87iqbhuhre.fsf@nemi.mork.no>
	 <1262691113.16627.361.camel@localhost.localdomain>
	 <87eim4vhvh.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-KTN3VVAYV8CfYEW4fjG3"
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33599 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755333Ab0AEUx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 15:53:29 -0500
In-Reply-To: <87eim4vhvh.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KTN3VVAYV8CfYEW4fjG3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Hi Bjorn,

> >> I believe the WWAN cards also can be treated like every other USB
> >> Ethernet device, as far as the kernel is concerned.  Any differences are
> >> easily resolved by userspace applications. 
> >
> > and this is where you are totally wrong. It is not easy for userspace to
> > identify the type of an interface and resolve things.
> 
> No?  Well, I probably have a too limited view of this, but I found it
> easy enough to create a pre-up/post-down script which checked whether
> the network interface being brought up/down belongs to a supported WWAN
> card and then do the necessary magic on one of the related cdc-wdm
> channels. This was implemented by poking around in the sysfs.  I fail to
> see why one needs a special network device name to do that.

this has nothing do with pre-up/post-down scripts.

The kernel already knows the type of the device. Userspace does not. And
detecting if from userspace is more complicated than just having the
kernel export it.

Also connection managers like NetworkManager and ConnMan do needs these
additional information. The actual interfaces names are not guaranteed
to be unique or static.

> > Take WiFi for example. We need to actually connect to a network before
> > these are useful. Same applies for 3G cards (aka WWAN) devices. You have
> > to register with the network, attach to GPRS etc. before any of this
> > becomes really useful. If the the USB network interface does automatic
> > connect and does tethering then it is not a WWAN device. Then it is an
> > Ethernet device.
> 
> I can live with that defintion of the difference between a WWAN/3G
> device (wwan%d) and a USB Ethernet device (usb%d).
> 
> But I still don't see why this doesn't make a phone (supporting the same
> commands as a 3G card) a WWAN device.  A phone can't do an automatic
> connection any more than a WWAN card can.  Both *must* be configured
> with at least one PDP context, register with the network, attach to GPRS
> etc.

Yes, the phone can do that. We call that provision which your provider
normally provides for you. Especially since the telephony stack is
running inside the phone. In case of 3G data cards, the telephony stack
is running on your machine. This is a big difference.

> Yes, some phones can be configured to auto-connect using it's own
> UI. But there's really nothing preventing anyone from implementing the
> same feature for a WWAN card.  What would that make that card then?
> 
> > And that you can use your phone via a TTY and configure a second PDP
> > context and then run PPP has nothing to do with its network device.
> 
> I was talking about the network device.  

You were talking about configuring the PDP context. That can't be done
via the network interface. And also it is not guaranteed that you can
actually modify the PDP context from your host. It might be specific to
the phone itself.

> My experience with these devices is limited to the Ericsson F3507g, but
> I assume that many of them will behave identically.  It allows you to
> define multiple PDP contexts and select which one you connect with,
> either you use PPP or the network device.  The list of defined contexts
> are in fact shared.

That is your assumption. It is not mandatory. You can have dedicated PDP
context for the tethering interface. And that is what the USB Ethernet
device of your phone is. If you can overwrite it or change it via your
host OS, then be happy, but it is not required to make this device work.

A pure MBM data card for example needs a telephony stack to make this
card work.

> >> So I'm still trying to figure out what makes a WWAN device special wrt
> >> the kernel.  Thanks for explaining.
> >
> > It has nothing to do with the kernel. It classifies the network device
> > type for userspace. Like you classify /dev/sda as "disk" and /dev/sda1
> > as "partition".
> >
> > So please modify your patch as outlined in my first response. It should
> > take you only like 5 minutes to do so. Then your phone will show up and
> > gets a proper classification.
> 
> Sorry for the confusion, but the patch was not mine.  I just stumbled
> across the discussion and first wondered why the heck the mbm_info stuff
> was added (hadn't noticed before) and then why the heck this device
> should be treated differenctly if it shows up as a similar one.

The point here clearly is that it is not a MBM device. Like it or not,
it is a phone and not a 3G data card/modem.

See attached patch for what I mean :)

Regards

Marcel


--=-KTN3VVAYV8CfYEW4fjG3
Content-Disposition: attachment; filename="0001-net-cdc_ether.c-Add-SE-J105i-to-device-whitelist.patch"
Content-Type: text/x-patch; name="0001-net-cdc_ether.c-Add-SE-J105i-to-device-whitelist.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From f8c35427986bad983f2b321c15cdcbe15cc45a4c Mon Sep 17 00:00:00 2001
From: Marcel Holtmann <marcel@holtmann.org>
Date: Tue, 5 Jan 2010 12:49:47 -0800
Subject: [PATCH] net: cdc_ether.c: Add SE J105i to device whitelist

This patch adds the Sony Ericsson J105i (Naite)
mobile phone to the cdc_ether device whitelist,
enabling access to the modem.

I would think more SE models of this generation
(2009Q3) with builtin HSDPA modules also needs
to be added to this list.

Signed-off-by: Thomas Loo <tloo@saltstorm.net>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/net/usb/cdc_ether.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 21e183a..a099d92 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -435,6 +435,14 @@ static const struct driver_info mbm_info = {
 	.status =	cdc_status,
 };
 
+static const struct driver_info mdlm_info = {
+	.description =	"MDLM Ethernet Device",
+	.flags =	FLAG_ETHER,
+	.bind = 	cdc_bind,
+	.unbind =	usbnet_cdc_unbind,
+	.status =	cdc_status,
+};
+
 /*-------------------------------------------------------------------------*/
 
 
@@ -584,6 +592,11 @@ static const struct usb_device_id	products [] = {
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long) &mbm_info,
 }, {
+	/* Sony Ericsson J105i (Naite) */
+	USB_DEVICE_AND_INTERFACE_INFO(0x0fce, 0xd12d, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long) &mdlm_info,
+}, {
 	/* Toshiba F3507g */
 	USB_DEVICE_AND_INTERFACE_INFO(0x0930, 0x130b, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-- 
1.6.5.2


--=-KTN3VVAYV8CfYEW4fjG3--

