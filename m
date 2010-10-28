From: Dmitry Artamonow <mad_soft@inbox.ru>
Subject: [PATCH] USB: gadget: fix ethernet gadget crash in gether_setup
Date: Thu, 28 Oct 2010 12:18:29 +0400
Message-ID: <1288253909-12084-1-git-send-email-mad_soft@inbox.ru>
Cc: David Brownell <dbrownell@users.sourceforge.net>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback1.mail.ru ([94.100.176.18]:42556 "EHLO
	fallback1.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758269Ab0KAP40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 11:56:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Crash is triggered by commit e6484930d7 ("net: allocate tx queues in
register_netdevice"), which moved tx netqueue creation into register_netdev.
So now calling netif_stop_queue() before register_netdev causes an oops.
Move netif_stop_queue() after net device registration to fix crash.

Signed-off-by: Dmitry Artamonow <mad_soft@inbox.ru>
---
 drivers/usb/gadget/u_ether.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/usb/gadget/u_ether.c b/drivers/usb/gadget/u_ether.c
index 6bb876d..cb23355 100644
--- a/drivers/usb/gadget/u_ether.c
+++ b/drivers/usb/gadget/u_ether.c
@@ -797,7 +797,6 @@ int gether_setup(struct usb_gadget *g, u8 ethaddr[ETH_ALEN])
 	 *  - iff DATA transfer is active, carrier is "on"
 	 *  - tx queueing enabled if open *and* carrier is "on"
 	 */
-	netif_stop_queue(net);
 	netif_carrier_off(net);
 
 	dev->gadget = g;
@@ -812,6 +811,7 @@ int gether_setup(struct usb_gadget *g, u8 ethaddr[ETH_ALEN])
 		INFO(dev, "MAC %pM\n", net->dev_addr);
 		INFO(dev, "HOST MAC %pM\n", dev->host_mac);
 
+		netif_stop_queue(net);
 		the_dev = dev;
 	}
 
-- 
1.7.0.4

