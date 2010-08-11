From: Martin Fuzzey <mfuzzey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Problem with non aligned DMA in usbnet on ARM
Date: Wed, 11 Aug 2010 21:07:27 +0200
Message-ID: <4C62F4EF.1050808@gmail.com>
References: <AANLkTi=ycg=adcizNWKMCb7EdfDANM=6Es7r_gF1LbhV@mail.gmail.com> <20100811095454.GA22543@n2100.arm.linux.org.uk> <AANLkTimX46QKAGhiyo8AodaXVjuzoxr5-5z2V4gRr1Vu@mail.gmail.com> <20100811150443.GB8867@kroah.com> <AANLkTimmJDKbh3_pRY_ASKvjsf4YuuUMh3edh5LvDv-p@mail.gmail.com> <20100811174238.GA12382@kroah.com>
Reply-To: mfuzzey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100811174238.GA12382-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Greg KH wrote:
>> So the question is are hcds expected to accept arbitarilly aligned but
>> heap allocated pointers (such as the result of kmalloc() + 1)?
>>     
>
> It sounds like your HCD doesn't like this, so perhaps we should make
> that rule :)
>
> If you allocate the urb with a kmalloc() call with no offset, does it
> all work properly? 
Yes
>  The driver should be calling usb_alloc_urb() which
> does this automatically for them, right?  Or is it trying to allocate
> things on its own somehow?
>
>   
It's not the URB itself (which is allocated by usb_alloc_urb) but rather
the buffer pointer within the URB that causes the problem.

It's the asix driver (or more exactly the usbnet core used by that driver).
It does (rx_submit() in drivers/net/usb/usbnet.c):

urb = usb_alloc_urb();
skb = alloc_skb (...);
skb_reserve (skb, NET_IP_ALIGN);
usb_fill_bulk_urb (urb,...  skb->data);
usb_submit_urb(urb)

skb->data as returned by alloc_skb() is aligned
but skb_reserve adds 2.

Thus removing the skb_reserve() call makes it work.
BUT if I do that the IP header is no longer aligned so accesses further
up the network stack have to be fixed up by exception handlers which is
expensive (even with hcds which don't require this)

cheers,
Martin

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
