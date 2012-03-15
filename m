From: "ASIX Allan Email [office]" <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Subject: RE: [PATCH net-next] asix: asix_rx_fixup surgery to reduce skb truesizes
Date: Thu, 15 Mar 2012 19:34:34 +0800
Message-ID: <001401cd029f$999ab140$ccd013c0$@com.tw>
References: <1331792312.2543.16.camel@edumazet-laptop> <CANEJEGtndncj1biMZSBC1rt36a66iWGp7wU_OxCxpA_PVBGZqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: "'Greg Kroah-Hartman'" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"'David Miller'" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "'netdev'" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"'Aurelien Jacobs'" <aurel-U/apLSaFET4dnm+yROfE0A@public.gmane.org>,
	"'Trond Wuellner'" <trond-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	"'Paul Stewart'" <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: "'Grant Grundler'" <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	"'Eric Dumazet'" <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CANEJEGtndncj1biMZSBC1rt36a66iWGp7wU_OxCxpA_PVBGZqA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: zh-tw
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dear Grant and All,

We are going to do some testing on the revised asix.c driver with ASIX's different USB to LAN solutions (AX88178/AX88772B/AX88772A/AX88772). Please advise where can I download the latest revised asix.c driver source with this driver patch for further testing? (Sorry I am newbie on Linux kernel driver patch threads. =_="") Thanks a lot.

---
Best regards,
Allan Chou

-----Original Message-----
From: grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org [mailto:grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org] On Behalf Of Grant Grundler
Sent: Thursday, March 15, 2012 2:42 PM
To: Eric Dumazet
Cc: Greg Kroah-Hartman; David Miller; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev; Aurelien Jacobs; Trond Wuellner; Paul Stewart; Allan Chou
Subject: Re: [PATCH net-next] asix: asix_rx_fixup surgery to reduce skb truesizes

Adding ASIX (Allan Chou)

On Wed, Mar 14, 2012 at 11:18 PM, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> asix_rx_fixup() is complex, and does some unnecessary memory copies (at
> least on x86 where NET_IP_ALIGN is 0)
>
> Also, it tends to provide skbs with a big truesize (4096+256 with
> MTU=1500) to upper stack, so incoming trafic consume a lot of memory and
> I noticed early packet drops because we hit socket rcvbuf too fast.
>
> Switch to a different strategy, using copybreak so that we provide nice
> skbs to upper stack (including the NET_SKB_PAD to avoid future head
> reallocations in some paths)

Your rewrite is definitely cleaner/simpler. If it works, ship it! :)

I'm traveling right now and don't have access to the HW to test it.
I'm hoping that ASIX could run a few simple tests as well.

> With this patch, I no longer see packets drops or tcp collapses on
> various tcp workload with a AX88772 adapter.
>
> Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Aurelien Jacobs <aurel-U/apLSaFET4dnm+yROfE0A@public.gmane.org>
> Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
> Cc: Trond Wuellner <trond-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Cc: Grant Grundler <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

Reviewed-by: Grant Grundler <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>

thanks!
grant

> Cc: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> ---
>  drivers/net/usb/asix.c |   90 +++++++++------------------------------
>  1 file changed, 21 insertions(+), 69 deletions(-)
>
> diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
> index 8e84f5b..27d5440 100644
> --- a/drivers/net/usb/asix.c
> +++ b/drivers/net/usb/asix.c
> @@ -305,88 +305,40 @@ asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
>
>  static int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
>  {
> -       u8  *head;
> -       u32  header;
> -       char *packet;
> -       struct sk_buff *ax_skb;
> -       u16 size;
> +       int offset = 0;
>
> -       head = (u8 *) skb->data;
> -       memcpy(&header, head, sizeof(header));
> -       le32_to_cpus(&header);
> -       packet = head + sizeof(header);
> -
> -       skb_pull(skb, 4);
> -
> -       while (skb->len > 0) {
> -               if ((header & 0x07ff) != ((~header >> 16) & 0x07ff))
> -                       netdev_err(dev->net, "asix_rx_fixup() Bad Header Length\n");
> +       while (offset + sizeof(u32) < skb->len) {
> +               struct sk_buff *ax_skb;
> +               u16 size;
> +               u32 header = get_unaligned_le32(skb->data + offset);
>
> +               offset += sizeof(u32);
> +
>                /* get the packet length */
> -               size = (u16) (header & 0x000007ff);
> -
> -               if ((skb->len) - ((size + 1) & 0xfffe) == 0) {
> -                       u8 alignment = (unsigned long)skb->data & 0x3;
> -                       if (alignment != 0x2) {
> -                               /*
> -                                * not 16bit aligned so use the room provided by
> -                                * the 32 bit header to align the data
> -                                *
> -                                * note we want 16bit alignment as MAC header is
> -                                * 14bytes thus ip header will be aligned on
> -                                * 32bit boundary so accessing ipheader elements
> -                                * using a cast to struct ip header wont cause
> -                                * an unaligned accesses.
> -                                */
> -                               u8 realignment = (alignment + 2) & 0x3;
> -                               memmove(skb->data - realignment,
> -                                       skb->data,
> -                                       size);
> -                               skb->data -= realignment;
> -                               skb_set_tail_pointer(skb, size);
> -                       }
> -                       return 2;
> +               size = (u16) (header & 0x7ff);
> +               if (size != ((~header >> 16) & 0x07ff)) {
> +                       netdev_err(dev->net, "asix_rx_fixup() Bad Header Length\n");
> +                       return 0;
>                }
>
> -               if (size > dev->net->mtu + ETH_HLEN) {
> +               if ((size > dev->net->mtu + ETH_HLEN) ||
> +                   (size + offset > skb->len)) {
>                        netdev_err(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
>                                   size);
>                        return 0;
>                }
> -               ax_skb = skb_clone(skb, GFP_ATOMIC);
> -               if (ax_skb) {
> -                       u8 alignment = (unsigned long)packet & 0x3;
> -                       ax_skb->len = size;
> -
> -                       if (alignment != 0x2) {
> -                               /*
> -                                * not 16bit aligned use the room provided by
> -                                * the 32 bit header to align the data
> -                                */
> -                               u8 realignment = (alignment + 2) & 0x3;
> -                               memmove(packet - realignment, packet, size);
> -                               packet -= realignment;
> -                       }
> -                       ax_skb->data = packet;
> -                       skb_set_tail_pointer(ax_skb, size);
> -                       usbnet_skb_return(dev, ax_skb);
> -               } else {
> +               ax_skb = netdev_alloc_skb_ip_align(dev->net, size);
> +               if (!ax_skb)
>                        return 0;
> -               }
> -
> -               skb_pull(skb, (size + 1) & 0xfffe);
>
> -               if (skb->len < sizeof(header))
> -                       break;
> +               skb_put(ax_skb, size);
> +               memcpy(ax_skb->data, skb->data + offset, size);
> +               usbnet_skb_return(dev, ax_skb);
>
> -               head = (u8 *) skb->data;
> -               memcpy(&header, head, sizeof(header));
> -               le32_to_cpus(&header);
> -               packet = head + sizeof(header);
> -               skb_pull(skb, 4);
> +               offset += (size + 1) & 0xfffe;
>        }
>
> -       if (skb->len < 0) {
> +       if (skb->len != offset) {
>                netdev_err(dev->net, "asix_rx_fixup() Bad SKB Length %d\n",
>                           skb->len);
>                return 0;
> @@ -1541,7 +1493,7 @@ static const struct driver_info ax88772_info = {
>        .status = asix_status,
>        .link_reset = ax88772_link_reset,
>        .reset = ax88772_reset,
> -       .flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR,
> +       .flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR | FLAG_MULTI_PACKET,
>        .rx_fixup = asix_rx_fixup,
>        .tx_fixup = asix_tx_fixup,
>  };
>
>

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
