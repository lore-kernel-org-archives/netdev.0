From: Neil Jones <neiljay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: rndis gadget: Inconsistent locking
Date: Fri, 7 Jan 2011 09:30:16 +0000
Message-ID: <AANLkTi=OS+jernOe8y1fbMbx5Rf+JRcvzqGY4Z2LKqsH@mail.gmail.com>
References: <AANLkTik=Uui7Xk9ZfFvQQKj94ZJUJ_n+bZbTQXbe+08i@mail.gmail.com>
	<AANLkTi==UqNNzokLcLWDpjM0cqM6aXjppsi4p6ogMAqX@mail.gmail.com>
	<1293407341.2255.1038.camel@helium>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1293407341.2255.1038.camel@helium>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>Has this shown up with other USB device controller drivers, or just th=
e
>DWC (DesignWare)? UDC driver?

Yes Michal Nazarewicz has seen this on a S3C UDC, heres his stack trace=
:

 WARNING: at kernel/softirq.c:143 local_bh_enable_ip+0x44/0xc0()
[...]
[<c0049024>] (local_bh_enable_ip+0x44/0xc0) from [<c025ef18>]
(dev_txq_stats_fold+0xac/0x108)
[<c025ef18>] (dev_txq_stats_fold+0xac/0x108) from [<c025f018>]
(dev_get_stats+0xa4/0xac)
[<c025f018>] (dev_get_stats+0xa4/0xac) from [<c01f72bc>]
(gen_ndis_query_resp+0x4c/0x43c)
[<c01f72bc>] (gen_ndis_query_resp+0x4c/0x43c) from [<c01f784c>]
(rndis_msg_parser+0x1a0/0x32c)
[<c01f784c>] (rndis_msg_parser+0x1a0/0x32c) from [<c01f79f8>]
(rndis_command_complete+0x20/0x4c)
[<c01f79f8>] (rndis_command_complete+0x20/0x4c) from [<c01f3278>]
(done+0x5c/0x70)
[<c01f3278>] (done+0x5c/0x70) from [<c01f3c60>] (complete_tx+0xf0/0x1a8=
)
[<c01f3c60>] (complete_tx+0xf0/0x1a8) from [<c01f3d8c>]
(process_ep_in_intr+0x74/0x14c)
[<c01f3d8c>] (process_ep_in_intr+0x74/0x14c) from [<c01f470c>]
(s3c_udc_irq+0x2c8/0x3f4)
[<c01f470c>] (s3c_udc_irq+0x2c8/0x3f4) from [<c006dfd0>]
(handle_IRQ_event+0x24/0xe4)
[<c006dfd0>] (handle_IRQ_event+0x24/0xe4) from [<c006fe40>]
(handle_level_irq+0xb0/0x12c)
[<c006fe40>] (handle_level_irq+0xb0/0x12c) from [<c0027074>]
(asm_do_IRQ+0x74/0x98)
[<c0027074>] (asm_do_IRQ+0x74/0x98) from [<c0027ca4>] (__irq_usr+0x44/0=
xc0)

(taken from Michal's original patch here:
<https://patchwork.kernel.org/patch/195562/>)

Neil




On Sun, Dec 26, 2010 at 11:49 PM, David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org> =
wrote:
> On Wed, 2010-12-08 at 15:11 +0000, Neil Jones wrote:
>>
>> Im getting another lockdep warning when using the RNDIS gadget:
>
>
>
> Probably this is either
>
>
> =C2=A0(a) a recent regression, maybe caused by a change ISTR in the n=
etwork
> layer stats handling ... which broke another USB + NET driver in much
> the same way, wish I remembered details of which driver, the fix
> there was simple and maybe a good model for fixing this one.
>
> or (b) =C2=A0... maybe a
> DWC-specific USB device controller driver oddity. =C2=A0(Seemed less =
likely
> to me when I glanced at the stackdumps below.
>
> Has this shown up with other USB device controller drivers, or just t=
he
> DWC (DesignWare)? UDC driver?
>
> I'll say I'm not keen on adding a thread to the driver. =C2=A0It's wo=
rked
> fine without one for many years, even running lockdep. =C2=A0Whatever=
 change
> (network stack or using DWC) caused the locking issue can be fixed
> without a new thread.
>
> - Dave
>
>
>
> The first thing I noticed was that very little of the dumped stack
> context was part of the RNDIS gadget ... often a sign that the issue
> is in the call down to the code dumping its stack (or its context).
>
> (Or if my recollection is right ... that there was an incompatible
> change in a network statistics call, and whoever changed that didn't
> update all affected callers. =C2=A0(ergo breakage here and in another=
 driver.
>>
>> =C2=A0WARNING: at kernel/softirq.c:98 ___local_bh_disable+0xc4/0xd0(=
)
>> =C2=A0Modules linked in: g_ether
>>
>> =C2=A0Call trace:
>> =C2=A0[<40003bf8>] _show_stack+0x68/0x7c
>> =C2=A0[<40003c20>] _dump_stack+0x14/0x28
>> =C2=A0[<40013c3c>] _warn_slowpath_common+0x5c/0x7c
>> =C2=A0[<40013c74>] _warn_slowpath_null+0x18/0x2c
>> =C2=A0[<4001b17c>] ___local_bh_disable+0xc0/0xd0
>> =C2=A0[<4001b1a0>] _local_bh_disable+0x14/0x28
>> =C2=A0[<402e57f8>] __raw_spin_lock_bh+0x18/0x54
>> =C2=A0[<40257f4c>] _dev_txq_stats_fold+0x7c/0x13c
>> =C2=A0[<402580c4>] _dev_get_stats+0xb8/0xc0
>> =C2=A0[<781d4e60>] _rndis_msg_parser+0x288/0xa04 [g_ether]
>> =C2=A0[<781d5600>] _rndis_command_complete+0x24/0x70 [g_ether]
>> =C2=A0[<401d66fc>] _dwc_otg_request_done+0xd8/0x220
>> =C2=A0[<401d928c>] _ep0_complete_request+0x3f4/0x578
>> =C2=A0[<401d95bc>] _handle_ep0+0x1ac/0x146c
>> =C2=A0[<401daf7c>] _dwc_otg_pcd_handle_in_ep_intr+0x1c0/0x8bc
>> =C2=A0[<401db8dc>] _dwc_otg_pcd_handle_intr+0x264/0x294
>> =C2=A0[<401d6288>] _dwc_otg_pcd_irq+0x10/0x30
>> =C2=A0[<40054cf4>] _handle_IRQ_event+0x4c/0x184
>> =C2=A0[<40057b4c>] _handle_level_irq+0xac/0x15c
>> =C2=A0[<4000b204>] _metag_soc_irq_demux+0xac/0xb4
>> =C2=A0[<40002dd4>] _do_IRQ+0x4c/0x78
>> =C2=A0[<40004000>] _trigger_handler+0x38/0xac
>> =C2=A0[<40000b18>] ___TBIBoingVec+0xc/0x10
>> =C2=A0[<40003588>] _cpu_idle+0x54/0x78
>>
>> =C2=A0no locks held by swapper/0.
>> =C2=A0---[ end trace 77ac3cfee0ae5b25 ]---
>>
>> It looks like we are calling spin_lock_bh in the completion function
>> which is running in hard_irq, I think the driver should defer handli=
ng
>> this msg (and maybe all requests) to a workqueue?
>>
>> Cheers
>>
>> Neil
>>
>>
>>
>> On Wed, Dec 8, 2010 at 3:03 PM, Neil Jones <neiljay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote=
:
>> > Hi,
>> >
>> > Im getting another lockdep warning when using the RNDIS gadget:
>> >
>> > =C2=A0WARNING: at kernel/softirq.c:98 ___local_bh_disable+0xc4/0xd=
0()
>> > =C2=A0Modules linked in: g_ether
>> >
>> > =C2=A0Call trace:
>> > =C2=A0[<40003bf8>] _show_stack+0x68/0x7c
>> > =C2=A0[<40003c20>] _dump_stack+0x14/0x28
>> > =C2=A0[<40013c3c>] _warn_slowpath_common+0x5c/0x7c
>> > =C2=A0[<40013c74>] _warn_slowpath_null+0x18/0x2c
>> > =C2=A0[<4001b17c>] ___local_bh_disable+0xc0/0xd0
>> > =C2=A0[<4001b1a0>] _local_bh_disable+0x14/0x28
>> > =C2=A0[<402e57f8>] __raw_spin_lock_bh+0x18/0x54
>> > =C2=A0[<40257f4c>] _dev_txq_stats_fold+0x7c/0x13c
>> > =C2=A0[<402580c4>] _dev_get_stats+0xb8/0xc0
>> > =C2=A0[<781d4e60>] _rndis_msg_parser+0x288/0xa04 [g_ether]
>> > =C2=A0[<781d5600>] _rndis_command_complete+0x24/0x70 [g_ether]
>> > =C2=A0[<401d66fc>] _dwc_otg_request_done+0xd8/0x220
>> > =C2=A0[<401d928c>] _ep0_complete_request+0x3f4/0x578
>> > =C2=A0[<401d95bc>] _handle_ep0+0x1ac/0x146c
>> > =C2=A0[<401daf7c>] _dwc_otg_pcd_handle_in_ep_intr+0x1c0/0x8bc
>> > =C2=A0[<401db8dc>] _dwc_otg_pcd_handle_intr+0x264/0x294
>> > =C2=A0[<401d6288>] _dwc_otg_pcd_irq+0x10/0x30
>> > =C2=A0[<40054cf4>] _handle_IRQ_event+0x4c/0x184
>> > =C2=A0[<40057b4c>] _handle_level_irq+0xac/0x15c
>> > =C2=A0[<4000b204>] _metag_soc_irq_demux+0xac/0xb4
>> > =C2=A0[<40002dd4>] _do_IRQ+0x4c/0x78
>> > =C2=A0[<40004000>] _trigger_handler+0x38/0xac
>> > =C2=A0[<40000b18>] ___TBIBoingVec+0xc/0x10
>> > =C2=A0[<40003588>] _cpu_idle+0x54/0x78
>> >
>> > =C2=A0no locks held by swapper/0.
>> > =C2=A0---[ end trace 77ac3cfee0ae5b25 ]---
>> >
>> > It
>> >
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-usb"=
 in
>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.h=
tml
>
>
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
