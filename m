From: Jonathan McDowell <noodles@earth.li>
Subject: [PATCH] Cleanup hso rfkill error handling [was: 2.6.28-rc2 / hso driver oops]
Date: Thu, 30 Oct 2008 10:27:46 +0000
Message-ID: <20081030102746.GI3162@earth.li>
References: <20081029164006.GH3162@earth.li> <1225309212.3068.44.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Andrew Bird <ajb@spheresystems.co.uk>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from the.earth.li ([217.147.81.2]:41919 "EHLO the.earth.li"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752778AbYJ3K1r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2008 06:27:47 -0400
Content-Disposition: inline
In-Reply-To: <1225309212.3068.44.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 07:40:11PM +0000, Ben Hutchings wrote:
> On Wed, 2008-10-29 at 16:40 +0000, Jonathan McDowell wrote:
> > Hi.
> > 
> > Tried out 2.6.28-rc2 today on my EEE 901 and my Option Icon 225 and got
> > the following oops:
> > 
> > hso: drivers/net/usb/hso.c: 1.2 Option Wireless
> > usbcore: registered new interface driver hso
> > usb 2-2: new full speed USB device using uhci_hcd and address 3
> > usb 2-2: configuration #1 chosen from 1 choice
> > hso0: Disabled Privacy Extensions
> > BUG: unable to handle kernel NULL pointer dereference at 000000d0
> > IP: [<c03589b9>] dev_driver_string+0x1/0x2a
> 
> Something passed a null device pointer to dev_printk().
> 
> [...]
> > [<f81b8265>] ? hso_create_net_device+0x305/0x32d [hso]
> [...]
> 
> I think that hso_create_rfkill() is the culprit here (and has been
> inlined into hso_create_net_device()).  It's using hso_dev->dev as the
> first argument to dev_err() and it doesn't look like that field is
> initialised except by kzalloc.  At a guess, it should be using
> &hso_dev->usb->dev.

Yup, this appears to be the problem, thanks. I think &hso_net->net->dev
is more intuitive for the error message, so I've used that. I've also
added missing line endings on the error messages and set our local
rfkill structure element to NULL on failure so we don't try to call
rfkill_unregister on driver removal if we failed to register at all.

The patch below Works For Me (TM); the device is detected fine, can be
removed without problems and connects ok. I'll have a prod at why the
rfkill stuff isn't working next, but I believe this cleanup of the error
handling is appropriate no matter what the issue with registration is.

Signed-Off-By: Jonathan McDowell <noodles@earth.li>

-----
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 1164c52..9d9622b 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2184,19 +2184,20 @@ static void hso_create_rfkill(struct hso_device *hso_dev,
 			     struct usb_interface *interface)
 {
 	struct hso_net *hso_net = dev2net(hso_dev);
-	struct device *dev = hso_dev->dev;
+	struct device *dev = &hso_net->net->dev;
 	char *rfkn;
 
 	hso_net->rfkill = rfkill_allocate(&interface_to_usbdev(interface)->dev,
 				 RFKILL_TYPE_WLAN);
 	if (!hso_net->rfkill) {
-		dev_err(dev, "%s - Out of memory", __func__);
+		dev_err(dev, "%s - Out of memory\n", __func__);
 		return;
 	}
 	rfkn = kzalloc(20, GFP_KERNEL);
 	if (!rfkn) {
 		rfkill_free(hso_net->rfkill);
-		dev_err(dev, "%s - Out of memory", __func__);
+		hso_net->rfkill = NULL;
+		dev_err(dev, "%s - Out of memory\n", __func__);
 		return;
 	}
 	snprintf(rfkn, 20, "hso-%d",
@@ -2209,7 +2210,8 @@ static void hso_create_rfkill(struct hso_device *hso_dev,
 		kfree(rfkn);
 		hso_net->rfkill->name = NULL;
 		rfkill_free(hso_net->rfkill);
-		dev_err(dev, "%s - Failed to register rfkill", __func__);
+		hso_net->rfkill = NULL;
+		dev_err(dev, "%s - Failed to register rfkill\n", __func__);
 		return;
 	}
 }
-----

J.

-- 
/-\                             | 101 things you can't have too much
|@/  Debian GNU/Linux Developer |         of : 32 - Answers.
\-                              |
