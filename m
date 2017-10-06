From: "Rafael J. Wysocki" <rafael@kernel.org>
Subject: Re: r8169 Wake-on-LAN causes immediate ACPI GPE wakeup
Date: Fri, 6 Oct 2017 03:24:34 +0200
Message-ID: <CAJZ5v0i+Ct9HbT+vMchW0dNxYO2WvyY5Tmz1a+3k0FLmbFGE2w@mail.gmail.com>
References: <CAD8Lp45YVtw48+8jSq6gtu1xA7Rt+qr6vvVZF4AC-QXeCKNj4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
        ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Linux Upstreaming Team <linux@endlessm.com>,
        Linux PM <linux-pm@vger.kernel.org>
To: Daniel Drake <drake@endlessm.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <CAD8Lp45YVtw48+8jSq6gtu1xA7Rt+qr6vvVZF4AC-QXeCKNj4w@mail.gmail.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 5, 2017 at 10:57 AM, Daniel Drake <drake@endlessm.com> wrote:
> Hi,
>
> On the Acer laptop models Aspire ES1-533, Aspire ES1-732, PackardBell
> ENTE69AP and Gateway NE533, we are seeing a problem where the system
> immediately wakes up after being put into S3 suspend.
>
> This problem has been seen on all kernel versions that we have tried,
> including 4.14-rc3.
>
> After disabling wakeup sources one by one, we found that the r8169
> ethernet is responsible for these wakeups here, the hardware is:
>
> 01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (rev 15)
>     Subsystem: Acer Incorporated [ALI] Device 1084
>     Flags: bus master, fast devsel, latency 0, IRQ 124
>     I/O ports at 1000 [size=256]
>     Memory at 91204000 (64-bit, non-prefetchable) [size=4K]
>     Memory at 91200000 (64-bit, non-prefetchable) [size=16K]
>     Capabilities: [40] Power Management version 3
>     Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
>     Capabilities: [70] Express Endpoint, MSI 01
>     Capabilities: [b0] MSI-X: Enable- Count=4 Masked-
>     Capabilities: [100] Advanced Error Reporting
>     Capabilities: [140] Virtual Channel
>     Capabilities: [160] Device Serial Number 01-00-00-00-68-4c-e0-00
>     Capabilities: [170] Latency Tolerance Reporting
>     Capabilities: [178] L1 PM Substates
>     Kernel driver in use: r8169
>
> This driver enables WOL by default. The system wakes up immediately
> when it is put into S3 suspend, even if there is no ethernet cable
> plugged in.
>
> The problem was also reproduced with the r8168 vendor driver, however
> it does not occur under Windows, where we can suspend the system just
> fine and also wake it up with a magic WOL packet.
>
> Further investigation takes us into ACPI-land. The complete DSDT is here:
> https://gist.github.com/dsd/62293b6d8c30a5204128709813a55ffb
>
> Both Windows and Linux associate PCI0.RP05.PXSX with this device, so
> let's consider this part of the DSDT:
>
>   Device (RP05)
>   {
>       Method (_ADR, 0, NotSerialized)  // _ADR: Address
>       {
>           If (RPA5 != Zero)
>           {
>               Return (RPA5) /* \RPA5 */
>           }
>           Else
>           {
>               Return (0x00130002)
>           }
>       }
>
>       Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
>       {
>           Return (GPRW (0x09, 0x04))
>       }
>
>       Device (PXSX)
>       {
>           Name (_ADR, Zero)  // _ADR: Address
>           Name (_PRW, Package (0x02)  // _PRW: Power Resources for Wake
>           {
>               0x08,
>               0x04
>           })
>       }
>
>   }
>
> RP05 corresponds to
> 00:13.0 PCI bridge: Intel Corporation Device 5ada (rev fb)
>
> I am not familiar with this subdevice approach, where PXSX (with
> address 0) is detected as a child of the PCI bridge, however both
> Windows and Linux associate PXSX with the ethernet device, so I guess
> it is correct.
>
> Now to focus on the _PRW power resource for wakeup. The PXSX
> (ethernet) device says that it will wake up the system using GPE08.
> However if you look at the _L08 GPE08 event handler, you will see that
> it does not do anything related to RP05/PXSX (it instead calls into
> RP02, which does not even physically exist on this platform) -
> suspicious.

Well, it is broken, but that doesn't matter for wakeups from S3.

> On the other hand, the RP05 (root port) _PRW says it will wake up the
> system via GPE09, and the _L09 handler at least has one codepath which
> could potentially do a Notify(PXSX, 2) to indicate an ethernet wakeup.

Which can only happen in the S0 system state.

> But in testing:
>  - If GPE08 is enabled as a wakeup source, the system will always wake
> up as soon as it goes to sleep

What exactly do you mean by "enabled as a wakeup source"?

>  - I have never seen a wakeup on GPE09
>  - Disabling GPE08 and all other GPE wakeups, the system sleeps fine,
> and Wake-on-LAN works fine too

Again, what exactly do you mean by "Disabling GPE08 and all other GPE
wakeups"?  That is, what exactly do you do to disable/enable them?

> So in summary, the messy situation is that the DSDT suggests that
> GPE08 will be used for ethernet wakeups, however that GPE seems to
> fire instantly during suspend, and actually wake-on-LAN does not
> appear to use ACPI GPEs to wake the system it all - it must use some
> other mechanism. Windows is for some reason ignoring the ethernet
> device _PRW information so it does not suffer this issue.

Oh well.

> Does anyone have suggestions for how Linux should work with this?
>
> What logic should we use to ignore the _PRW in this case, or how can
> we quirk it?

User space can do that via /proc/acpi/wakeup.  The kernel not so much.

I guess it might be possible to add a DMI-based quirk for this system
to ignore _PRW for a specific ACPI device object, but that would be
super-ugly.

> Also, is there a standard behaviour defined for ethernet drivers
> regarding wake-on-LAN?

I'm not aware of any. :-)

> r8169 appears to enable wake-on-LAN by default
> if it believes the hardware is capable of it, but other ethernet
> drivers seem to default to WOL off. (I don't expect users of the
> affected consumer laptops here to care about WOL support.)

Defaulting to off is generally safer, because you avoid spurious
wakeups when the user doesn't care about WoL.

Thanks,
Rafael
