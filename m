From: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Subject: Re: Problem with non aligned DMA in usbnet on ARM
Date: Wed, 11 Aug 2010 10:54:54 +0100
Message-ID: <20100811095454.GA22543@n2100.arm.linux.org.uk>
References: <AANLkTi=ycg=adcizNWKMCb7EdfDANM=6Es7r_gF1LbhV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Martin Fuzzey <mfuzzey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTi=ycg=adcizNWKMCb7EdfDANM=6Es7r_gF1LbhV-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 11, 2010 at 11:41:41AM +0200, Martin Fuzzey wrote:
> Digging a bit showed that the driver was submitting a non aligned data
> pointer in the URB.
> This is due to:
> skb_reserve (skb, NET_IP_ALIGN);
> 
> in net/usb/usbnet.c rx_submit()
> 
> NET_IP_ALIGN is defined as 2 in skbuff.h (default value as not defined
> by ARM) hence the data buffer address was offset by 2 whereas the hcd
> requires 4 byte alignment to work at all and cache line (32 byte here)
> alignment to work reliably.

x86 also has NET_IP_ALIGN as 2, so it will also be IP-header aligned there
too, so the restriction won't be from the USB stack.

> Removing this call to skb_reserve() fixes the problem for me.

However, that makes parsing and creating IP headers really inefficient,
especially as we take a trap each time a misaligned access is performed.

> 3) Change the HCD to copy if not aligned
> I'd like to avoid that.

You haven't said what HCD you're using.

> On a related note, this is the second time I've run into this type of
> problem.It would be much easier to debug if the HCD warned (or
> refused) misaligned URBs.

If HCD can't cope with misaligned URBs, it should fail across the board -
or be made to warn across the board - but I suspect it's a specific HCD
that you're using which is only applicable to ARM.

In that case, I'd say the HCD must handle misaligned URBs itself so
behaviour is consistent between all implementations on different
platforms.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
