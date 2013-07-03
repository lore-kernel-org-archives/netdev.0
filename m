From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [PATCH] usbnet: cdc_ncm: remove huawei devices handled by
 cdc_ncm_huawei.c
Date: Wed, 3 Jul 2013 15:13:34 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307031511140.25159@eeeadesso>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no> <alpine.LNX.2.02.1307021855270.19053@eeeadesso> <alpine.LNX.2.02.1307022202570.26010@eeeadesso> <alpine.LNX.2.02.1307022207060.26010@eeeadesso>
 <alpine.LNX.2.02.1307022210470.26010@eeeadesso> <alpine.LNX.2.02.1307022213380.26010@eeeadesso> <alpine.LNX.2.02.1307030836270.12831@eeeadesso> <alpine.LNX.2.02.1307030908090.13789@eeeadesso> <871u7gvz2z.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:37364 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228Ab3GCNNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 09:13:13 -0400
Received: by mail-wg0-f46.google.com with SMTP id c11so105390wgh.13
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 06:13:12 -0700 (PDT)
In-Reply-To: <871u7gvz2z.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some huawei devices implements an NCM-like protocol, but require applications 
to manage the link in a different mamner.
So another driver is needed to handle them.

Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 62686be..31f43f7 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1236,17 +1236,6 @@ static const struct usb_device_id cdc_devs[] = {
 	  .driver_info = (unsigned long)&wwan_info,
 	},
 
-	/* Huawei NCM devices disguised as vendor specific */
-	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x16),
-	  .driver_info = (unsigned long)&wwan_info,
-	},
-	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x46),
-	  .driver_info = (unsigned long)&wwan_info,
-	},
-	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x76),
-	  .driver_info = (unsigned long)&wwan_info,
-	},
-
 	/* Infineon(now Intel) HSPA Modem platform */
 	{ USB_DEVICE_AND_INTERFACE_INFO(0x1519, 0x0443,
 		USB_CLASS_COMM,




On Wed, 3 Jul 2013, Bj?rn Mork wrote:

==Date: Wed, 03 Jul 2013 10:15:32 +0200
==From: Bj?rn Mork <bjorn@mork.no>
==To: Enrico Mioso <mrkiko.rs@gmail.com>
==Cc: netdev@vger.kernel.org
==Subject: Re: Huaei E3131 - status
==
==Enrico Mioso <mrkiko.rs@gmail.com> writes:
==
==> Ok ... As Bjorn stated, cdc-wdm is handling the notifications now - or, better: 
==> is not handling them, as it is not made to do these things! The connection 
==> stays up and the character device seems to work properly. Obviously cdc-wdm 
==> notices me about one single unknown notifications.
==> We're ignoring all the notifications from the NCM erspective, but all works 
==> because the device probably doesn't rely on them so much.
==> Aniway - now I'm conscious about why it works. Now it's time to improve the 
==> situation of the driver, and might be the api. Waiting for suggestions and 
==> injuries! :)
==
==The only notification actually used for anything by cdc_ncm is
==USB_CDC_NOTIFY_NETWORK_CONNECTION, which it uses to set the link up or
==down. That functionality is disabled in your driver, leaving the link
==always up.
==
==This is of course not entirely correct if we apply a strict NCM
==specification to this driver. But it does no harm either.  You have
==added support for the embedded management channel, which must be used to
==configure and connect the device.  Connection status will also be
==reported here, and the managing userspace application (for example
==ModemManager) will use this to pick up the actual network connection
==state.  So the link state reported by NCM is redundant for these
==devices.
==
==The issue is that the few simple notifications standardized in CDC NCM
==are sufficient for management of ethernet connections, but not for
==3G/LTE connections.  That's why you need access to the additional vendor
==specific management channel in the first place.  And when you have that
==channel, then the additional NCM notifications are redundant at best.
==Or confusing at worst.
==
==The second notification implemented by cdc_ncm is
==USB_CDC_NOTIFY_SPEED_CHANGE, which is shown in your logs.  But there is
==nothing cdc_ncm can do with this, so it will just log it.  That's mostly
==useless, both for wired and wireless devices.  3G/LTE management
==applications will pick up the same information via the appropriate
==management channel instead.
==
==So the main reason why you should implement support for these
==notifications eventually is not so much to handle them, but to silence
==cdc-wdm. It will otherwise complain, which will confuse some users.  But
==this is a really minor issue, and I see no reason why it should hold
==back this driver.  It is perfectly usable as it is, and all necessary
==features are implemented.
==
==
==Bj?rn
==
