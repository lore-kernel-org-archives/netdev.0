From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: ax88179_178a problems on AMD platform with ASMedia xhci
 controller
Date: Wed, 5 Mar 2014 09:40:11 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6D14D1@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6CF469@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6CF469-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Of David Laight
> I've just installed the latest 3.14.0-rc5 kernel on an AMD box that
> has the ASMedia 1042 xhci controller and an ASX ax88179 USB3 Ge card.
> 
> This is still working as badly as it did last time I tried it.
> (When I added a lot of diagnostics to try to find out what was wrong.)
> 
> When I ran 'ifconfig eth1 192.168.x.x' the kernel message buffer
> is spammed with messages from the generic ethernet code reporting:
>     "kevent 4 may have been missed".
> This is because ax88179_status(...) contains:
> 	if (netif_carrier_ok() != link) {
> 		usbnet_link_change(...);
> 		...
> but the corresponding netif_carrier_on() doesn't happen until
> much later (possibly for the same reason that transmits are delayed).

Actually I remember debugging that.
The problem seemed to be that the controller only actions one control
transfer each time the doorbell was rung.
I didn't get as far as re-ringing the bell in the completion routine.
Doing so might make it work a lot better.

> I think the hardware reports its status every 128ms.
> 
> If I ping the interface (from the only other system on that ethernet
> network), the ping times vary, but are typically larger than 20ms and
> anything upto 200ms (some outward ones are faster).
> I did add some diagnostics a while ago (rc2 ish) and thought the delays
> were in the transmit path.
> 
> dmesg also gets spammed with "ERROR Transfer event TRB DMA ptr not part of
> current TD". I don't remember looking at why (for this case).
> 
> I've just looked t the ping timings closely. The elapsed times (ms) are:
> 7, 30, 53, 76, 99, 122, 18, 41, 64, 87, 110, 5, 28 ...
> So each response is about 22ms later than the previous on - until the delay
> would exceed 128ms, when 128ms is removed.
> So something is only looking at something every 128ms.
> 
> This might be related to the status indications every 128ms, but I
> thought I'd determined that the delay was between the tx setup and
> end of tx interrupt.

It might be that the wrong doorbell is being rung.
Maybe the 'tx' doorbell is actually rung when the rx interrupt packet
is resupplied in response to the 128ms status poll.

	David




--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
