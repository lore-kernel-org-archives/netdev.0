From: Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: usbnet: driver_info->stop required to stop USB interrupts?
Date: Tue, 18 Mar 2014 13:52:41 -0700
Message-ID: <CANEJEGtizt-1bnUp9X=7JiHXKZ=W+4huhMUmHxYpHnbzjWssSw@mail.gmail.com>
References: <CANEJEGsvqkT_H4i+UZpBaWMYmgXHmpD8SZ4tU1OHzLd8gyznow@mail.gmail.com>
	<CANEJEGv03ohVwoS0Pd1Z3az9k-C=dTzG4qE1SBL6Um97QC1Ehw@mail.gmail.com>
	<CAODwPW_t9COeg0LWfkiqXC_yTbSNhUHX-8T95KRZHfOTSiZK1Q@mail.gmail.com>
	<1394529263.16128.6.camel@linux-fkkt.site>
	<CAODwPW8rQptt+jnfZ+KjpuOOpKi9ktb-y2kCYGZJo_ava1ktjg@mail.gmail.com>
	<CAODwPW-CqigMBvwZtb+KLY5XbT+LDssPpvDZj86ej183DMiPkQ@mail.gmail.com>
	<1395093343.3961.2.camel@linux-fkkt.site>
	<CANEJEGuaVPNZKFiXY9CywFuqghgiQqV_sii7TE3STCNvXLQ3pQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Julius Werner <jwerner-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CANEJEGuaVPNZKFiXY9CywFuqghgiQqV_sii7TE3STCNvXLQ3pQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 18, 2014 at 1:51 PM, Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> On Mon, Mar 17, 2014 at 2:55 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
>> I am hping for the reporter of the original bug to test it.
>
> Oliver,
> on a haswell system running ChromeOS-3.8 kernel, this patch as-is
> resulted in a "Bad Spinlock Magic" error and subsequent pagefault.
> I believe the sequence was:
>    usbnet_open -> tasklet_schedule(dev->bh) -> usbnet_bh -> wake_up
> (&dev->wait) -> panic

BTW, full console output is available on this public patch:
    https://code.google.com/p/chromium/issues/detail?id=353648

cheers,
grant

>
> I tried adding the following change on top of your patch but believe
> the plumbing still isn't quite correct since the USB device (eth0) is
> reporting a link but no TX or RX of traffic:
>  @@ -805,6 +807,9 @@ int usbnet_open (struct net_device *net)
>                 goto done;
>         }
>
> +       /* usbnet_bh() expects the spinlock to be initialized. */
> +       init_waitqueue_head(&dev->wait);
> +
>         /* hard_mtu or rx_urb_size may change in reset() */
>         usbnet_update_max_qlen(dev);
>
> I suspect this hunk of your patch is now causing different problems at
> init time:
> @@ -1438,10 +1440,8 @@ static void usbnet_bh (unsigned long param)
>         clear_bit(EVENT_RX_KILL, &dev->flags);
>
>         // waiting for all pending urbs to complete?
> -       if (dev->wait) {
> -               if ((dev->txq.qlen + dev->rxq.qlen + dev->done.qlen) == 0) {
> -                       wake_up (dev->wait);
> -               }
> +       if ((dev->txq.qlen + dev->rxq.qlen + dev->done.qlen) == 0) {
> +               wake_up (&dev->wait);
>
>         // or are we maybe short a few urbs?
>         } else if (netif_running (dev->net) &&
>
> Please advise on what you'd like me to try next.
>
> cheers,
> grant
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
