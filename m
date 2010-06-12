From: Joe Perches <joe@perches.com>
Subject: Re: Broken rndis_host with #define DEBUG (by
 a475f603d23392f386e45cf377b17c30ed3bbb80)
Date: Sat, 12 Jun 2010 14:10:38 -0700
Message-ID: <1276377038.21640.67.camel@Joe-Laptop.home>
References: <20100612233907.2036688tfjxqq9hc@hayate.sektori.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S.Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	David Brownell <dbrownell@users.sourceforge.net>
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1093 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752343Ab0FLVKl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jun 2010 17:10:41 -0400
In-Reply-To: <20100612233907.2036688tfjxqq9hc@hayate.sektori.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-06-12 at 23:39 +0300, Jussi Kivilinna wrote:
> Commit a475f603d23392f386e45cf377b17c30ed3bbb80 "drivers/net/usb: Use  
> netif_<level> logging facilities" causes problems with rndis_host.
> 
> rndis_host oopses with #define DEBUG, in generic_rndis_bind() when  
> calling netif_dbg(). Problem is that (netdev)->dev.parent is NULL  
> (used in netdev_printk) while generic_rndis_bind is called.

Thanks.

Here's a revert until these macros get converted to functions.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/rndis_host.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 28d3ee1..49c3044 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -342,8 +342,8 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 
 	dev->maxpacket = usb_maxpacket(dev->udev, dev->out, 1);
 	if (dev->maxpacket == 0) {
-		netif_dbg(dev, probe, dev->net,
-			  "dev->maxpacket can't be 0\n");
+		if (netif_msg_probe(dev))
+			dev_dbg(&intf->dev, "dev->maxpacket can't be 0\n");
 		retval = -EINVAL;
 		goto fail_and_release;
 	}
@@ -401,15 +401,17 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 	}
 	if ((flags & FLAG_RNDIS_PHYM_WIRELESS) &&
 			*phym != RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN) {
-		netif_dbg(dev, probe, dev->net,
-			  "driver requires wireless physical medium, but device is not\n");
+		if (netif_msg_probe(dev))
+			dev_dbg(&intf->dev, "driver requires wireless "
+				"physical medium, but device is not.\n");
 		retval = -ENODEV;
 		goto halt_fail_and_release;
 	}
 	if ((flags & FLAG_RNDIS_PHYM_NOT_WIRELESS) &&
 			*phym == RNDIS_PHYSICAL_MEDIUM_WIRELESS_LAN) {
-		netif_dbg(dev, probe, dev->net,
-			  "driver requires non-wireless physical medium, but device is wireless.\n");
+		if (netif_msg_probe(dev))
+			dev_dbg(&intf->dev, "driver requires non-wireless "
+				"physical medium, but device is wireless.\n");
 		retval = -ENODEV;
 		goto halt_fail_and_release;
 	}


