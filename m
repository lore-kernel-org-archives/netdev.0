From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: rndis gadget: Inconsistent locking
Date: Sun, 26 Dec 2010 15:49:01 -0800
Message-ID: <1293407341.2255.1038.camel@helium>
References: <AANLkTik=Uui7Xk9ZfFvQQKj94ZJUJ_n+bZbTQXbe+08i@mail.gmail.com>
	 <AANLkTi==UqNNzokLcLWDpjM0cqM6aXjppsi4p6ogMAqX@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Neil Jones <neiljay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTi==UqNNzokLcLWDpjM0cqM6aXjppsi4p6ogMAqX-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-12-08 at 15:11 +0000, Neil Jones wrote:
> 
> Im getting another lockdep warning when using the RNDIS gadget:



Probably this is either


 (a) a recent regression, maybe caused by a change ISTR in the network
layer stats handling ... which broke another USB + NET driver in much
the same way, wish I remembered details of which driver, the fix
there was simple and maybe a good model for fixing this one.

or (b)  ... maybe a
DWC-specific USB device controller driver oddity.  (Seemed less likely
to me when I glanced at the stackdumps below.

Has this shown up with other USB device controller drivers, or just the
DWC (DesignWare)? UDC driver?

I'll say I'm not keen on adding a thread to the driver.  It's worked
fine without one for many years, even running lockdep.  Whatever change
(network stack or using DWC) caused the locking issue can be fixed
without a new thread.

- Dave



The first thing I noticed was that very little of the dumped stack
context was part of the RNDIS gadget ... often a sign that the issue
is in the call down to the code dumping its stack (or its context).

(Or if my recollection is right ... that there was an incompatible
change in a network statistics call, and whoever changed that didn't
update all affected callers.  (ergo breakage here and in another driver.
> 
>  WARNING: at kernel/softirq.c:98 ___local_bh_disable+0xc4/0xd0()
>  Modules linked in: g_ether
> 
>  Call trace:
>  [<40003bf8>] _show_stack+0x68/0x7c
>  [<40003c20>] _dump_stack+0x14/0x28
>  [<40013c3c>] _warn_slowpath_common+0x5c/0x7c
>  [<40013c74>] _warn_slowpath_null+0x18/0x2c
>  [<4001b17c>] ___local_bh_disable+0xc0/0xd0
>  [<4001b1a0>] _local_bh_disable+0x14/0x28
>  [<402e57f8>] __raw_spin_lock_bh+0x18/0x54
>  [<40257f4c>] _dev_txq_stats_fold+0x7c/0x13c
>  [<402580c4>] _dev_get_stats+0xb8/0xc0
>  [<781d4e60>] _rndis_msg_parser+0x288/0xa04 [g_ether]
>  [<781d5600>] _rndis_command_complete+0x24/0x70 [g_ether]
>  [<401d66fc>] _dwc_otg_request_done+0xd8/0x220
>  [<401d928c>] _ep0_complete_request+0x3f4/0x578
>  [<401d95bc>] _handle_ep0+0x1ac/0x146c
>  [<401daf7c>] _dwc_otg_pcd_handle_in_ep_intr+0x1c0/0x8bc
>  [<401db8dc>] _dwc_otg_pcd_handle_intr+0x264/0x294
>  [<401d6288>] _dwc_otg_pcd_irq+0x10/0x30
>  [<40054cf4>] _handle_IRQ_event+0x4c/0x184
>  [<40057b4c>] _handle_level_irq+0xac/0x15c
>  [<4000b204>] _metag_soc_irq_demux+0xac/0xb4
>  [<40002dd4>] _do_IRQ+0x4c/0x78
>  [<40004000>] _trigger_handler+0x38/0xac
>  [<40000b18>] ___TBIBoingVec+0xc/0x10
>  [<40003588>] _cpu_idle+0x54/0x78
> 
>  no locks held by swapper/0.
>  ---[ end trace 77ac3cfee0ae5b25 ]---
> 
> It looks like we are calling spin_lock_bh in the completion function
> which is running in hard_irq, I think the driver should defer handling
> this msg (and maybe all requests) to a workqueue?
> 
> Cheers
> 
> Neil
> 
> 
> 
> On Wed, Dec 8, 2010 at 3:03 PM, Neil Jones <neiljay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > Hi,
> >
> > Im getting another lockdep warning when using the RNDIS gadget:
> >
> >  WARNING: at kernel/softirq.c:98 ___local_bh_disable+0xc4/0xd0()
> >  Modules linked in: g_ether
> >
> >  Call trace:
> >  [<40003bf8>] _show_stack+0x68/0x7c
> >  [<40003c20>] _dump_stack+0x14/0x28
> >  [<40013c3c>] _warn_slowpath_common+0x5c/0x7c
> >  [<40013c74>] _warn_slowpath_null+0x18/0x2c
> >  [<4001b17c>] ___local_bh_disable+0xc0/0xd0
> >  [<4001b1a0>] _local_bh_disable+0x14/0x28
> >  [<402e57f8>] __raw_spin_lock_bh+0x18/0x54
> >  [<40257f4c>] _dev_txq_stats_fold+0x7c/0x13c
> >  [<402580c4>] _dev_get_stats+0xb8/0xc0
> >  [<781d4e60>] _rndis_msg_parser+0x288/0xa04 [g_ether]
> >  [<781d5600>] _rndis_command_complete+0x24/0x70 [g_ether]
> >  [<401d66fc>] _dwc_otg_request_done+0xd8/0x220
> >  [<401d928c>] _ep0_complete_request+0x3f4/0x578
> >  [<401d95bc>] _handle_ep0+0x1ac/0x146c
> >  [<401daf7c>] _dwc_otg_pcd_handle_in_ep_intr+0x1c0/0x8bc
> >  [<401db8dc>] _dwc_otg_pcd_handle_intr+0x264/0x294
> >  [<401d6288>] _dwc_otg_pcd_irq+0x10/0x30
> >  [<40054cf4>] _handle_IRQ_event+0x4c/0x184
> >  [<40057b4c>] _handle_level_irq+0xac/0x15c
> >  [<4000b204>] _metag_soc_irq_demux+0xac/0xb4
> >  [<40002dd4>] _do_IRQ+0x4c/0x78
> >  [<40004000>] _trigger_handler+0x38/0xac
> >  [<40000b18>] ___TBIBoingVec+0xc/0x10
> >  [<40003588>] _cpu_idle+0x54/0x78
> >
> >  no locks held by swapper/0.
> >  ---[ end trace 77ac3cfee0ae5b25 ]---
> >
> > It
> >
> --
> To unsubscribe from this list: send the line "unsubscribe linux-usb" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
