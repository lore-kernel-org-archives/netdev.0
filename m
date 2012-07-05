From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Thu, 5 Jul 2012 18:32:11 +0800
Message-ID: <CACVXFVNZ=64+=w1ZapXeXq7oYz0OBbBRLuH8rNSeDHyz7zGOZw@mail.gmail.com>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
	<1341474192.2583.3299.camel@edumazet-glaptop>
	<CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
	<1341477192.2583.3415.camel@edumazet-glaptop>
	<CACVXFVPTXB7t=zwkm+HTgDaF3bA02bzff_52S+UAr51PfpvpCg@mail.gmail.com>
	<1341481760.2583.3579.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:37527 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753821Ab2GEKcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 06:32:12 -0400
Received: by gglu4 with SMTP id u4so7191581ggl.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 03:32:11 -0700 (PDT)
In-Reply-To: <1341481760.2583.3579.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 5, 2012 at 5:49 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2012-07-05 at 16:42 +0800, Ming Lei wrote:
>> On Thu, Jul 5, 2012 at 4:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Thu, 2012-07-05 at 16:27 +0800, Ming Lei wrote:
>> >
>> >> After some investigation, the problem is caused by enabling
>> >> DEBUG_SLAB, so it is not a regression.
>> >>
>> >
>> > Strange, unless your machine is a _very_ slow one maybe ?
>>
>> It is a beagle-xm board, and its cpu is ARMv7, 1GHz.
>
> OK, driver seems buggy, please try following patch (on both sides if
> possible)
>
>  drivers/net/usb/smsc95xx.c |   11 ++++-------
>  1 file changed, 4 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> index b1112e7..0a4ae35 100644
> --- a/drivers/net/usb/smsc95xx.c
> +++ b/drivers/net/usb/smsc95xx.c
> @@ -1084,26 +1084,23 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
>                         if (skb->len == size) {
>                                 if (dev->net->features & NETIF_F_RXCSUM)
>                                         smsc95xx_rx_csum_offload(skb);
> -                               skb_trim(skb, skb->len - 4); /* remove fcs */
> +                               __skb_trim(skb, skb->len - 4); /* remove fcs */
>                                 skb->truesize = size + sizeof(struct sk_buff);
>
>                                 return 1;
>                         }
>
> -                       ax_skb = skb_clone(skb, GFP_ATOMIC);
> +                       ax_skb = netdev_alloc_skb_ip_align(dev->net, size);
>                         if (unlikely(!ax_skb)) {
>                                 netdev_warn(dev->net, "Error allocating skb\n");
>                                 return 0;
>                         }
>
> -                       ax_skb->len = size;
> -                       ax_skb->data = packet;
> -                       skb_set_tail_pointer(ax_skb, size);
> +                       memcpy(skb_put(ax_skb, size), packet, size);
>
>                         if (dev->net->features & NETIF_F_RXCSUM)
>                                 smsc95xx_rx_csum_offload(ax_skb);
> -                       skb_trim(ax_skb, ax_skb->len - 4); /* remove fcs */
> -                       ax_skb->truesize = size + sizeof(struct sk_buff);
> +                       __skb_trim(ax_skb, ax_skb->len - 4); /* remove fcs */
>
>                         usbnet_skb_return(dev, ax_skb);
>                 }
>
>

After testing on beagle-xm, the patch is good and network is OK, but
iperf performance is still no improvement, see below:

[root@root]#iperf -c 192.168.0.103 -w 131072 -t 10
------------------------------------------------------------
Client connecting to 192.168.0.103, TCP port 5001
TCP window size:   256 KByte (WARNING: requested   128 KByte)
------------------------------------------------------------
[  3] local 192.168.0.119 port 46776 connected with 192.168.0.103 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  41.4 MBytes  34.7 Mbits/sec



Thanks,
-- 
Ming Lei
