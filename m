From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Thu, 05 Jul 2012 11:49:20 +0200
Message-ID: <1341481760.2583.3579.camel@edumazet-glaptop>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
	 <1341474192.2583.3299.camel@edumazet-glaptop>
	 <CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
	 <1341477192.2583.3415.camel@edumazet-glaptop>
	 <CACVXFVPTXB7t=zwkm+HTgDaF3bA02bzff_52S+UAr51PfpvpCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:52698 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753374Ab2GEJtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 05:49:25 -0400
Received: by eeit10 with SMTP id t10so3144641eei.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 02:49:24 -0700 (PDT)
In-Reply-To: <CACVXFVPTXB7t=zwkm+HTgDaF3bA02bzff_52S+UAr51PfpvpCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-05 at 16:42 +0800, Ming Lei wrote:
> On Thu, Jul 5, 2012 at 4:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Thu, 2012-07-05 at 16:27 +0800, Ming Lei wrote:
> >
> >> After some investigation, the problem is caused by enabling
> >> DEBUG_SLAB, so it is not a regression.
> >>
> >
> > Strange, unless your machine is a _very_ slow one maybe ?
> 
> It is a beagle-xm board, and its cpu is ARMv7, 1GHz.

OK, driver seems buggy, please try following patch (on both sides if
possible)

 drivers/net/usb/smsc95xx.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index b1112e7..0a4ae35 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1084,26 +1084,23 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			if (skb->len == size) {
 				if (dev->net->features & NETIF_F_RXCSUM)
 					smsc95xx_rx_csum_offload(skb);
-				skb_trim(skb, skb->len - 4); /* remove fcs */
+				__skb_trim(skb, skb->len - 4); /* remove fcs */
 				skb->truesize = size + sizeof(struct sk_buff);
 
 				return 1;
 			}
 
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
