From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.18-rc4-mm1: eth0: trigger_send() called with the transmitter busy
Date: Tue, 15 Aug 2006 18:39:54 +0200
Message-ID: <200608151839.55184.rjw@sisk.pl>
References: <20060813012454.f1d52189.akpm@osdl.org> <200608151210.31440.rjw@sisk.pl> <44E1EA66.2060408@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>,
	Kernel development list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Linux ACPI <linux-acpi@vger.kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
To: Laurent Riffard <laurent.riffard@free.fr>
In-Reply-To: <44E1EA66.2060408@free.fr>
Content-Disposition: inline
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 15 August 2006 17:38, Laurent Riffard wrote:
>=20
> Le 15.08.2006 12:10, Rafael J. Wysocki a =E9crit :
> > On Tuesday 15 August 2006 01:01, Laurent Riffard wrote:
> >> Le 14.08.2006 23:25, Rafael J. Wysocki a =E9crit :
> >>> On Monday 14 August 2006 22:06, Laurent Riffard wrote:
> >>>> Le 14.08.2006 19:47, Laurent Riffard a =E9crit :
> >>>>> Le 14.08.2006 18:50, Andrew Morton a =E9crit :
> >>>>>> On Mon, 14 Aug 2006 16:38:47 +0200
> >>>>>> Laurent Riffard <laurent.riffard@free.fr> wrote:
]--snip--[
> >> Note that I always have had a warning sowhere in acpi_pci_link_set=
 during suspend:
> >>  BUG: sleeping function called from invalid context at include/asm=
/semaphore.h:99
> > Bad.  If that's 100% reproducible, could you please try to nail it =
down?
>=20
> I wasn't clear: I always had this "BUG: sleeping function called ....=
" since one year
> or more. It never prevents from suspending. Do you want me to track d=
own what cause=20
> this message?

Something like that, more or less, but the trace below shows this. ;-)
It doesn't seem to be harmful, though.

> Here is a more complete trace:=20
>=20
>  Stopping tasks: =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D|
>  Shrinking memory...  ^H-^H\^Hdone (10908 pages freed)
]--snip--[
>  Suspending device platform
>  swsusp: Need to copy 60817 pages
>  Intel machine check architecture supported.
>  Intel machine check reporting enabled on CPU#0.
>  BUG: sleeping function called from invalid context at include/asm/se=
maphore.h:99
>  in_atomic():0, irqs_disabled():1
>   [<c0103894>] show_trace_log_lvl+0x12/0x25
>   [<c0103975>] show_trace+0xd/0x10
>   [<c01040aa>] dump_stack+0x19/0x1b
>   [<c0112ef9>] __might_sleep+0x8d/0x95
>   [<c01daf53>] acpi_os_wait_semaphore+0x93/0x158
>   [<c01ffb9d>] acpi_ut_acquire_mutex+0x69/0xd4
>   [<c01f3231>] acpi_ns_get_node+0x8e/0x112
>   [<c01f259a>] acpi_ns_evaluate+0x62/0x258
>   [<c01f8aa1>] acpi_rs_set_srs_method_data+0xf1/0x125
>   [<c01f8341>] acpi_set_current_resources+0x8b/0xb0
>   [<c0204ca5>] acpi_pci_link_set+0x10e/0x1e0
>   [<c0204dc2>] irqrouter_resume+0x4b/0x62

Here we go.  linux-acpi added to the Cc list.

>   [<c021d04a>] __sysdev_resume+0x14/0x57
>   [<c021d1c0>] sysdev_resume+0x19/0x4b
>   [<c0221bf9>] device_power_up+0x8/0xf
>   [<c0134271>] swsusp_suspend+0x51/0x78
>   [<c013466a>] pm_suspend_disk+0x51/0xe2
>   [<c01337d0>] enter_state+0x52/0x164
>   [<c0133968>] state_store+0x86/0x9c
>   [<c01831b8>] subsys_attr_store+0x20/0x25
>   [<c01832c8>] sysfs_write_file+0xaa/0xcf
>   [<c015472c>] vfs_write+0x8c/0x138
>   [<c0154c44>] sys_write+0x3b/0x60
>   [<c0102c2d>] sysenter_past_esp+0x56/0x8d
>   =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
]--snip--[
> >> Or must really netconsole be stopped during device_suspend ?
> >=20
> > Yes, it must.  For now, the consoles are suspend-unfriendly, so to =
speak. ;-)
> >=20
>=20
> I think I found something related to netconsole and your patch=20
> "suspend_console/resume_console". I was booting to runlevel 1 and I w=
as using=20
> this script to suspend:
>=20
> <=3D=3D=3D script begin =3D=3D=3D>
> #!/bin/sh
> # don't want to {fsck *and* reboot} if something goes wrong
> mount -oremount,ro /
> # enable write caching on HD
> hdparm -W1 /dev/hd[ab]
> echo 6 > /proc/sys/kernel/printk
> sleep 2
> echo disk > /sys/power/state
> <=3D=3D=3D script end =3D=3D=3D>
>=20
> The important point is the "sleep 2" line. If it is present, I can su=
spend the box.
> Remove the "sleep command" and it will hang after displaying:
>    Stopping tasks: =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D|
>    Shrinking memory... done (0 pages freed)
>=20
> If netconsole is disabled (ie not called from command line), I do not=
 need this =20
> "sleep", suspend always works.=20

It behaves like that with the "suspend_console/resume_console" patch or
without it?

Rafael


--=20
You never change things by fighting the existing reality.
		R. Buckminster Fuller
-
To unsubscribe from this list: send the line "unsubscribe linux-acpi" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
