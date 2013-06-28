From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [RFC PATCH] usb: hcd: warn about URB buffers that are not DMA aligned and are about to be DMA mapped
Date: Fri, 28 Jun 2013 14:58:23 +0200
Message-ID: <3357770.hCSJD4DdXz@linux-5eaq.site>
References: <20130614133803.25747.98705.stgit@localhost6.localdomain6> <51BD94F5.2060803@iki.fi> <51CD83FF.2030704@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-usb@vger.kernel.org, Ming Lei <tom.leiming@gmail.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Network Development <netdev@vger.kernel.org>
To: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:42708 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228Ab3F1M4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 08:56:54 -0400
In-Reply-To: <51CD83FF.2030704@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 28 June 2013 15:39:27 Jussi Kivilinna wrote:
> On 16.06.2013 13:35, Jussi Kivilinna wrote:
> > On 16.06.2013 11:21, Oliver Neukum wrote:
> >> On Saturday 15 June 2013 16:22:30 Jussi Kivilinna wrote:
> >>
> >>> Hm.. rethink this a bit.
> >>>
> >>> Transfer buffer might be dma aligned but shorter than cacheline and end of cacheline
> >>> used as something else. Manual alignment by host driver does not catch that
> >>> or fix that.
> >>> So, yes.. dma mapping should work with unaligned buffers, but maybe the actual
> >>> problem is multiple buffers from same cacheline.
> >>
> >> The buffers kmalloc() returns are OK in that regard. A driver that uses
> >> a buffer for anything but buffering is buggy.
> > 
> > Ok, I'll look at that direction. Thanks.
> > 
> 
> So if I understood correctly, drivers that allocate these as part of larger structures (struct *_device etc) are doing wrong thing and are potentially buggy. And this is because cachelines of buffers can be DMA mapped after usb_submit_urb() and editing same cacheline while URB is in-flight can therefore be hazardous.
> 
> I checked setup_packet and transfer_buffer usage of some drivers in 3.9.8 and made some observations. Should these be fixed?
> 
> URB setup_packet and transfer_buffer part of same structure (might share same cacheline for same URB):
>  * iforce:
>   - http://lxr.linux.no/linux+v3.9.8/drivers/input/joystick/iforce/iforce-usb.c#L173
>   - http://lxr.linux.no/linux+v3.9.8/drivers/input/joystick/iforce/iforce.h#L101

Buggy

>  * usbvision:
>   - http://lxr.linux.no/linux+v3.9.8/drivers/media/usb/usbvision/usbvision-core.c#L1445
>   - http://lxr.linux.no/linux+v3.9.8/drivers/media/usb/usbvision/usbvision.h#L366

Buggy

>  * catc:
>   - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/catc.c#L499
>   - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/catc.c#L500
>   - ctrl_buf, ctrl_dr: http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/catc.c#L162
>  * rtl8150:
>   - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/rtl8150.c#L200
>   - http://lxr.linux.no/linux+v3.9.8/drivers/net/usb/rtl8150.c#L128
>  * rt2x000usb:
>   - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rt2x00/rt2x00usb.c#L212
>   - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rt2x00/rt2x00usb.c#L169
>  * rtl8187:
>   - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rtl818x/rtl8187/dev.c#L156
>   - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rtl818x/rtl8187/dev.c#L130
>  * uss720:
>   - http://lxr.linux.no/linux+v3.9.8/drivers/usb/misc/uss720.c#L176
>   - http://lxr.linux.no/linux+v3.9.8/drivers/usb/misc/uss720.c#L72

Well, I didn't look through them all, but we must assume that they are buggy.

> URB transfer_buffer array (transfer buffers preloaded as array, element size less than cacheline):
>  * rtlwifi:
>   - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rtlwifi/usb.c#L152
>   - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rtlwifi/wifi.h#L1859
>   - http://lxr.linux.no/linux+v3.9.8/drivers/net/wireless/rtlwifi/usb.c#L980

Good catch.

This is a very large number. I suggest you split it up.

	Regards
		Oliver
