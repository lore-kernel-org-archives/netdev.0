From: Daniel Drake <drake@endlessm.com>
Subject: Re: r8169 Wake-on-LAN causes immediate ACPI GPE wakeup
Date: Fri, 6 Oct 2017 10:34:58 +0800
Message-ID: <CAD8Lp47MOpD0C-4ZNix20nLCEtiDb0NjywNODbyp-TbynOsrOw@mail.gmail.com>
References: <CAD8Lp45YVtw48+8jSq6gtu1xA7Rt+qr6vvVZF4AC-QXeCKNj4w@mail.gmail.com>
 <20171006001649.GA21884@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
        linux-acpi@vger.kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Linux Upstreaming Team <linux@endlessm.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20171006001649.GA21884@electric-eye.fr.zoreil.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 6, 2017 at 8:16 AM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Daniel Drake <drake@endlessm.com> :
> [...]
>> Also, is there a standard behaviour defined for ethernet drivers
>> regarding wake-on-LAN? r8169 appears to enable wake-on-LAN by default
>> if it believes the hardware is capable of it,
>
> If so it isn't its designed behavior.
>
> The r8169 driver does not enable specific WoL event source (unicast packet,
> link, etc.). It should keep the current settings unless one of those holds:
> - explicit wol config from userspace (obviously :o) )
> - runtime pm requires different settings to resume. The change should
>   be temporary (save before suspend, restore after resume).
>
> The device is supposed to require both an event source + Config1.PMEnable.
>
> A problem may happen if some event source bit is already set while
> Config1.PMEnable is not. The driver has been forcing Config1.PMEnable
> since 5d06a99f543e734ceb53bbc9e550537be97f0c49. One may thus experience
> transition from inconsistent wol settings to enabled ones (if you want
> to dig it, check beforehand if Config1.PMEnable is really read-write or
> hardwired to 1).

The code in question here is in rtl_init_one():

    device_set_wakeup_enable(&pdev->dev, tp->features & RTL_FEATURE_WOL);

This enables wakeups regardless of current WOL settings, as long as
the hardware supports the WOL feature.
Should we remove this line? rtl8169_set_wol() looks like it will do
the right thing here if WOL is later enabled.

Daniel
