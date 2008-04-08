From: Inaky Perez-Gonzalez <inaky-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [ANN] WiMAX stack and drivers for Intel WiMAX Link 5050
Date: Tue, 8 Apr 2008 13:59:03 -0700
Message-ID: <200804081359.03611.inaky@linux.intel.com>
References: <200804011107.38563.inaky@linux.intel.com> <20080408135601.5dad3566@speedy>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: wimax-BPSAo7wm5JOHVYUYWc+uSQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080408135601.5dad3566@speedy>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 08 April 2008, Stephen Hemminger wrote:
> This is the short (not in depth) code review of kernel component of Wimax.
> 
> Generic stack: drivers/net/wimax
> 
> 1. Why spread those over 8 files of 100 lines each. Better to have a single
>    file with 1000 lines and get reduced namespace and better compiler inlining
>    etc.

Style difference, simplifies maintenance. Each file is logically grouped. 
Everything for doing X is in file X. I know you are a fan of big files, 
I am not :)

There is almost no inlining because each X only does stuff from itself. If
there is a need for inlined stuff (I missed it) it should go to one of the
header files --internal or external.

> 2. The debug infrastructure is a mess of ugly macros that are unlikely
>    to accepted in the current form, rework or delete it.

Ok, I'll figure a way to clean it up. Need to move most to inlines,
still making sure anything that is disabled is compiled out.
 
> 3. Use of sysfs for family and version ok, but why bother?
>    Please don't build sysfs version checks into the API.

family ID: it makes it easy to map device<->family-id without
expensive look ups the kernel like an attribute with the device 
name would be. Rationale is most systems will have a single wimax
device in the kernel. include/linux/wimax.h and drivers/net/wimax/id-table.c
should have this documented...ouch, just remembered. The code drop
out there shouldn't be as complete (documentation wise) as what
I need to publish. Pls hold for it, will be available.

version: I anticipate the wimax API exported to user space is
going to undergo a lot of changes while we all agree on what
is the best interface. Because things might break, I want to
make sure user space stuff can detect that and fail cleanly. 
Hence the versioning. 

It is designed to be flexible so that adding new APIs allows 
old code to work (however, changing existing APIs is where it 
breaks). From the docs:

 * Each WiMAX device exports two sysfs files declaring the generic
 * netlink family ID associated to the interface and another one which
 * version it supports. The version code has to fit in one byte
 * (restrictions imposed by generic netlink); we use version / 10 for
 * the major version and version % 10 for the minor. This gives 9
 * minors for each major and 25 majors.
 *
 * The inexistence of any of this means the device does not support
 * the WiMAX extensions.
 *
 * The version change protocol is as follow:
 *
>* - Major versions: needs to be increased if an existing message is
>*   changed or removed. Doesn't need to be changed if a new message
>*   is added.
 *
>* - Minor verion: needs to be increased if new messages are being
>*   added or some other consideration that doesn't impact too much
>*   (like some kind of bug fix) and that is kind of left up in the
>*   air to common sense.
 *
 * Your user space code should not try to work if the major version it
 * was compiled for differs from what the kernel offers. As well, it
 * should not work if the minor version of the kernel interface is
 * lower than the one the user space code was compiled for.
 *
 * libwimax's wimax_open() takes care of all this for you.

> 
> 4. __wimax_flush_queue: is a nop, just remove

Removed in newer code.

> 5. Stack is using generic netlink instead use newer netlink interface
>    for management of devices: newlink/dellink instead see macvlan

Geeze, I hide out for one week and a new system pops up? 

What is the advantage of newlink dellink vs generic netlink? Pointers
to doc? Generic netlink is fitting the bill pretty well as of now,
so unless it is going away from the kernel, I feel we should not
move it.
 
> i2400m hardware driver
> 
> 1. sysfs
>   the inflight file is being used in a /proc style. Either change to
>   one value per file or move to /proc/net/i2400m/ethX or better yet use debugfs
>   /debugfs/i2400m/ethX/xxx

All that is gone from current tip.

> 2. Use internal dev->stats for network stats (may not need get_stats at all)

Noted, will do.

> 3. No ioctl stub if not implemented

Ack.

> 4. Use netdev_alloc_skb rather than alloc_skb for new code.

Any rationales for it? other than the padding and setting
skb->dev, they seem the same.

> 5. Use skb_copy_to_linear_data in i2400m_net_rx
>
> 6. Since hardware has to copy every received frame. Don't bother with
>    checksum offload, the copy does the checksum for you and is safer.

Current tip code receives data from the device to an skb and then 
clones the different packets to deliver to netdev. This is not 
needed/done any more.
 
> 7. Fine grain file organization in i2400m is bogus, put in one file and use
>    proper name scope. Having 100 line files is unneeded

Again, style differences, a 10k file is already way too big for me.
 
> 8. Fix the FIXME's?

En route, most of them fixed in tip.
 
> 9. Anyway to reuse existing usbnet infrastructure?

Nope, the 2400 is a pure IP device (as Marcel mentioned). As well, we need
to provide for using other bus connections (SDIO in the works), so that would
break it up. OTOH, the hw protocol makes it different to plug into USBNET,
as we can receive many packets in a single transaction.
 
> 10. Since device is USB, Rx is in workqueue, so no need to go through
>     netif_rx() softirq, should be able to go through netif_receive_skb

Good point. Ack.
 
> 11. net_device and private data are zero on allocation, so no need
>    for memset.

Ack
 
> 12. Since this is new code elminate all legacy ifdef's

Done in tip.

We need to keep backwards compatibility to certain kernels for OSV support.
]Trying to make that as unobstrusive as possible. The git tip tree will
be mostly backward-stuff clean.

Hey thanks a lot, this is great feedback

-- 
Inaky
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
