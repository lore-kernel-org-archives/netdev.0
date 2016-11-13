From: Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net 2/2] r8152: rx descriptor check
Date: Sun, 13 Nov 2016 15:38:27 -0500
Message-ID: <db74cad7-fd1b-3dcf-38df-88b4d4ae904c@pobox.com>
References: <1394712342-15778-226-Taiwan-albertk@realtek.com>
 <1394712342-15778-228-Taiwan-albertk@realtek.com>
 <20161113.123954.2134945576362221851.davem@davemloft.net>
 <cd36fce8-2f17-debd-d514-e3cbe7ed3762@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cd36fce8-2f17-debd-d514-e3cbe7ed3762-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 16-11-13 03:34 PM, Mark Lord wrote:
>
> The system I use it with is a 32-bit ppc476, with non-coherent RAM,
> and using 16KB page sizes.
> 
> The dongle instantly becomes a lot more reliable when r8152.c is updated
> to use usb_alloc_coherent() for URB buffers, rather than kmalloc().
> 
> Not sure why that would be though, as the USB stack normally would handle
> kmalloc'd buffers just fine.  It is calling the appropriate routines,
> which boil down to invalidating the dcache lines (for inbound bulk xfers)
> as part of usb_submit_urb(), and yet the problem there persists.
> 
> It could be caused by cache-line sharing with other allocations, but that seems
> unlikely as the kmalloc() size is 16384 bytes per buffer.  Perhaps the driver
> is somehow accessing the buffer space again after doing usb_submit_urb()?
> That would certainly produce this kind of behaviour.
> 
> Or maybe there's just a memory barrier missing somewhere in path.
> 
> The really weird thing is that ASIX-based dongles (which use a different driver)
> don't have this problem, and yet they also use kmalloc'd buffers.
> 
> I have access to the test system only for a day or two a week,
> and it takes a few hours to do a good test as to whether something helps or not.
> I'll continue to poke at it as time and New Ideas permit.

Oh, and the problems did not exist with the 3.14.xx kernels and earlier.
They began to show up when we tried 3.16.xx and all newer kernels.

The difference there is that RX checksums were enabled in hardware as of 3.16.xx,
and thus the network stack began accepting bad packets from the r8152 driver.

I don't know if the ASIX driver uses hardware checksums or just software checksums.
That might explain why it is more reliable here.
-- 
Mark Lord
Real-Time Remedies Inc.
mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
