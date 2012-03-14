From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net/usbnet: reserve headroom on rx skbs
Date: Wed, 14 Mar 2012 09:56:25 -0700
Message-ID: <1331744185.6022.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Oliver Neukum <oneukum@suse.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:44933 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755748Ab2CNQ42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 12:56:28 -0400
Received: by dadp12 with SMTP id p12so3217461dad.11
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2012 09:56:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

network drivers should reserve some headroom on incoming skbs so that we
dont need expensive reallocations, eg forwarding packets in tunnels.

This NET_SKB_PAD padding is done in various helpers, like
__netdev_alloc_skb_ip_align() in this patch, combining NET_SKB_PAD and
NET_IP_ALIGN magic.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Oliver Neukum <oneukum@suse.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/net/usb/usbnet.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 83dcc53..5903aea 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -328,13 +328,13 @@ static int rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 	unsigned long		lockflags;
 	size_t			size = dev->rx_urb_size;
 
-	if ((skb = alloc_skb (size + NET_IP_ALIGN, flags)) == NULL) {
+	skb = __netdev_alloc_skb_ip_align(dev->net, size, flags);
+	if (!skb) {
 		netif_dbg(dev, rx_err, dev->net, "no rx skb\n");
 		usbnet_defer_kevent (dev, EVENT_RX_MEMORY);
 		usb_free_urb (urb);
 		return -ENOMEM;
 	}
-	skb_reserve (skb, NET_IP_ALIGN);
 
 	entry = (struct skb_data *) skb->cb;
 	entry->urb = urb;
