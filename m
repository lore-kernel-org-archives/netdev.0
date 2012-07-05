From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Thu, 05 Jul 2012 16:56:36 +0200
Message-ID: <1341500196.2583.4222.camel@edumazet-glaptop>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
	 <1341474192.2583.3299.camel@edumazet-glaptop>
	 <CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
	 <1341477192.2583.3415.camel@edumazet-glaptop>
	 <CACVXFVPTXB7t=zwkm+HTgDaF3bA02bzff_52S+UAr51PfpvpCg@mail.gmail.com>
	 <1341481760.2583.3579.camel@edumazet-glaptop>
	 <CACVXFVNZ=64+=w1ZapXeXq7oYz0OBbBRLuH8rNSeDHyz7zGOZw@mail.gmail.com>
	 <1341484919.2583.3688.camel@edumazet-glaptop>
	 <CACVXFVPksMd8CGZWEGBXBXB5NZCg3QOZreOLavkV-Z2pjE-M_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:33264 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756525Ab2GEO4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 10:56:42 -0400
Received: by eaak11 with SMTP id k11so3284025eaa.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 07:56:41 -0700 (PDT)
In-Reply-To: <CACVXFVPksMd8CGZWEGBXBXB5NZCg3QOZreOLavkV-Z2pjE-M_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-05 at 22:01 +0800, Ming Lei wrote:

> At default SMSC95xx turbo mode is true, rx buffer will be very big
> (17.5K). Or the large rx buffer size puts limit on concurrent URBs/SKBs
> count.  Both two may cause the problem.

I see. So we should try to recycle these large rx buffers in usbnet
instead of allocating/freeing them for each incoming packet.

Following patch does the copybreak of all incoming frames.

It has nice property of not lying anymore on skb truesize ;)

It should be applied on both sender and receiver

 drivers/net/usb/smsc95xx.c |   19 +++----------------
 1 file changed, 3 insertions(+), 16 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index b1112e7..3d9566f 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1080,30 +1080,17 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 				return 0;
 			}
 
-			/* last frame in this batch */
-			if (skb->len == size) {
-				if (dev->net->features & NETIF_F_RXCSUM)
-					smsc95xx_rx_csum_offload(skb);
-				skb_trim(skb, skb->len - 4); /* remove fcs */
-				skb->truesize = size + sizeof(struct sk_buff);
-
-				return 1;
-			}
-
-			ax_skb = skb_clone(skb, GFP_ATOMIC);
+			ax_skb = netdev_alloc_skb_ip_align(dev->net, size);
 			if (unlikely(!ax_skb)) {
 				netdev_warn(dev->net, "Error allocating skb\n");
 				return 0;
 			}
 
-			ax_skb->len = size;
-			ax_skb->data = packet;
-			skb_set_tail_pointer(ax_skb, size);
+			memcpy(skb_put(ax_skb, size), packet, size);
 
 			if (dev->net->features & NETIF_F_RXCSUM)
 				smsc95xx_rx_csum_offload(ax_skb);
-			skb_trim(ax_skb, ax_skb->len - 4); /* remove fcs */
-			ax_skb->truesize = size + sizeof(struct sk_buff);
+			__skb_trim(ax_skb, ax_skb->len - 4); /* remove fcs */
 
 			usbnet_skb_return(dev, ax_skb);
 		}
