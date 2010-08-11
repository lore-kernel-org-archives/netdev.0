From: Martin Fuzzey <mfuzzey-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Problem with non aligned DMA in usbnet on ARM
Date: Wed, 11 Aug 2010 11:41:41 +0200
Message-ID: <AANLkTi=ycg=adcizNWKMCb7EdfDANM=6Es7r_gF1LbhV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi all,

I have a DLINK DUB-E100 USB / Ethernet adapter with using the Asix
AX88772 chipset.
This device works fine on linux x86 using the usbnet based asix driver
however on ARM (iMX21 SoC, kernel 2.6.35) transmit works but receive
fails with:
"asix_rx_fixup() Bad Header Length"

Digging a bit showed that the driver was submitting a non aligned data
pointer in the URB.
This is due to:
skb_reserve (skb, NET_IP_ALIGN);

in net/usb/usbnet.c rx_submit()

NET_IP_ALIGN is defined as 2 in skbuff.h (default value as not defined
by ARM) hence the data buffer address was offset by 2 whereas the hcd
requires 4 byte alignment to work at all and cache line (32 byte here)
alignment to work reliably.
Note that usbnet uses skb->data as the buffer submitted to USB in the URB.

Removing this call to skb_reserve() fixes the problem for me.

However the comments in skbuff.h make it clear that this is done
deliberately knowing that it will cause non aligned DMA but seem to
suggest that this should work anyway (even if less efficiently).

My understanding, based on previous discussions on -usb a year back
while I was working on the usb hcd is that the hcd does _not_ have to
support unaligned DMA.

So what is the correct fix for this problem?
The options seem to be:
1) Remove skb_reserve() from usbnet
But this will cause the ip header to be non aligned on platforms that
don't have the DMA alignment requirement.

2) Define NET_IP_ALIGN to 0 for ARM
Seems a bit intrusive to me.

3) Change the HCD to copy if not aligned
I'd like to avoid that.

4) Change usbnet to use seperate buffers for the usb side and skb.
Copy between them so both remain aligned
Seems unlikely that the gain further up the stack from ensuring the ip
header is aligned will offset the cost of the copy.

Any ideas?

On a related note, this is the second time I've run into this type of
problem.It would be much easier to debug if the HCD warned (or
refused) misaligned URBs. If HCDs provided information on their
alignment requirements then the USB core could do this in a uniform
way. For example adding an alignment field to struct hc_driver or
struct usb_hcd?

Cheers,

Martin
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
