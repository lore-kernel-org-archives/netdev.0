From: Grant Grundler <grundler@google.com>
Subject: Re: [PATCH 4/4] USBNET: ax88179_178a: enable tso if host supports sg dma
Date: Thu, 1 Aug 2013 08:30:55 -0700
Message-ID: <CANEJEGuY3WzxnN4NEKx0RxAJNPO_hy+yt2AqhuTqHQavmawTcw@mail.gmail.com>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
	<1375267909-30373-5-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>,
	Freddy Xin <freddy@asix.com.tw>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:46451 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756281Ab3HAPa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 11:30:56 -0400
Received: by mail-oa0-f47.google.com with SMTP id g12so4048793oah.6
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 08:30:56 -0700 (PDT)
In-Reply-To: <1375267909-30373-5-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 31, 2013 at 3:51 AM, Ming Lei <ming.lei@canonical.com> wrote:
> This patch enables 'can_dma_sg' flag for ax88179_178a device
> if the attached host controller supports building packet from
> discontinuous buffers(DMA SG is possible), so both frame header
> and skb data buffers can be passed to usb stack via urb->sg,
> then skb data copy can be saved.
>
> With the patch, CPU utilization decreased much in iperf test at
> client mode.
>
> Signed-off-by: Ming Lei <ming.lei@canonical.com>
> ---
>  drivers/net/usb/ax88179_178a.c |   30 ++++++++++++++++++++++++++++++
>  1 file changed, 30 insertions(+)
>
> diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
> index 5a468f3..c75bded 100644
> --- a/drivers/net/usb/ax88179_178a.c
> +++ b/drivers/net/usb/ax88179_178a.c
> @@ -1031,12 +1031,20 @@ static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
>         dev->mii.phy_id = 0x03;
>         dev->mii.supports_gmii = 1;
>
> +       if (dev->udev->bus->no_sg_limit)
> +               dev->can_dma_sg = 1;
> +
>         dev->net->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>                               NETIF_F_RXCSUM;
>
>         dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>                                  NETIF_F_RXCSUM;
>
> +       if (dev->can_dma_sg) {
> +               dev->net->features |= NETIF_F_SG | NETIF_F_TSO;
> +               dev->net->hw_features |= NETIF_F_SG | NETIF_F_TSO;
> +       }
> +
>         /* Enable checksum offload */
>         *tmp = AX_RXCOE_IP | AX_RXCOE_TCP | AX_RXCOE_UDP |
>                AX_RXCOE_TCPV6 | AX_RXCOE_UDPV6;
> @@ -1170,12 +1178,30 @@ ax88179_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
>         int mss = skb_shinfo(skb)->gso_size;
>         int headroom;
>         int tailroom;
> +       struct skb_data *entry = (struct skb_data *)skb->cb;
>
>         tx_hdr1 = skb->len;
>         tx_hdr2 = mss;
>         if (((skb->len + 8) % frame_size) == 0)
>                 tx_hdr2 |= 0x80008000;  /* Enable padding */
>
> +       if (dev->can_dma_sg) {
> +               if (!(entry->header = kmalloc(8, GFP_ATOMIC)))
> +                       goto no_sg;
> +
> +               entry->length = 8;
> +               cpu_to_le32s(&tx_hdr1);
> +               cpu_to_le32s(&tx_hdr2);

http://lxr.free-electrons.com/source/include/linux/byteorder/generic.h#L111
http://lxr.free-electrons.com/ident?i=__cpu_to_le32s

IIRC, cpu_to_leXX() macros return the endian "corrected" value.
In other words, they need to be assigned to something, no?

thanks,
grant

> +               memcpy(entry->header, &tx_hdr1, 4);
> +               memcpy(entry->header + 4, &tx_hdr2, 4);
> +
> +               return skb;
> +       } else {
> +no_sg:
> +               entry->header = NULL;
> +               entry->length = 0;
> +       }
> +
>         headroom = skb_headroom(skb);
>         tailroom = skb_tailroom(skb);
>
> @@ -1323,6 +1349,10 @@ static int ax88179_reset(struct usbnet *dev)
>
>         dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>                                  NETIF_F_RXCSUM;
> +       if (dev->can_dma_sg) {
> +               dev->net->features |= NETIF_F_SG | NETIF_F_TSO;
> +               dev->net->hw_features |= NETIF_F_SG | NETIF_F_TSO;
> +       }
>
>         /* Enable checksum offload */
>         *tmp = AX_RXCOE_IP | AX_RXCOE_TCP | AX_RXCOE_UDP |
> --
> 1.7.9.5
>
