From: Daniel Drake <drake@endlessm.com>
Subject: Re: r8169 Wake-on-LAN causes immediate ACPI GPE wakeup
Date: Fri, 6 Oct 2017 10:44:02 +0800
Message-ID: <CAD8Lp44=tBOTRZcZeuATLwV3+8_PDWd=HPPYs76qMfRtwrRv+A@mail.gmail.com>
References: <CAD8Lp45YVtw48+8jSq6gtu1xA7Rt+qr6vvVZF4AC-QXeCKNj4w@mail.gmail.com>
 <CAJZ5v0i+Ct9HbT+vMchW0dNxYO2WvyY5Tmz1a+3k0FLmbFGE2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
        ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Linux Upstreaming Team <linux@endlessm.com>,
        Linux PM <linux-pm@vger.kernel.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJZ5v0i+Ct9HbT+vMchW0dNxYO2WvyY5Tmz1a+3k0FLmbFGE2w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 6, 2017 at 9:24 AM, Rafael J. Wysocki <rafael@kernel.org> wrote:
>> On the other hand, the RP05 (root port) _PRW says it will wake up the
>> system via GPE09, and the _L09 handler at least has one codepath which
>> could potentially do a Notify(PXSX, 2) to indicate an ethernet wakeup.
>
> Which can only happen in the S0 system state.

Not quite sure I understand your comment here. Of course the _L09
handler (and any other ACPI code) can only execute in S0 state.
However if Linux leaves GPE09 enabled during S3 suspend, and then
detects that it has an event pending on resume, it will execute _L09
during resume. (However, we have not observed GPE09 firing at all)

>> But in testing:
>>  - If GPE08 is enabled as a wakeup source, the system will always wake
>> up as soon as it goes to sleep
>
> What exactly do you mean by "enabled as a wakeup source"?

Linux associates the ethernet PCI device with PCI0.RP05.PXSX, which
has _PRW referencing GPE08.
r8169 has already done device_set_wakeup_enable() at probe time.
So when going into suspend, acpi_enable_wakeup_devices() and the code
beneath that will ensure that GPE08 is enabled when the system goes
into suspend.
See acpi_hw_enable_wakeup_gpe_block().

To disable it, "echo disabled > power/wakeup" for the ethernet device in sysfs.

To test with GPE09 instead, I modified the _PRW method in the DSDT to
point at GPE09, and again used sysfs to control whether the GPE is
enabled during suspend or not.

Thanks
Daniel
