From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] ravb: add wake-on-lan support via magic packet
Date: Tue, 16 May 2017 09:48:51 +0200
Message-ID: <CAMuHMdWZ8XLX0Zu0D54Ex+3RaFNm_fJyFQvyo+qz10HpB2nGqQ@mail.gmail.com>
References: <20170511222735.10706-1-niklas.soderlund+renesas@ragnatech.se>
 <CAMuHMdUXqWJMh7syd3muMs8v9wx5bJNRj_3+xEAXTQTfAv0BFA@mail.gmail.com>
 <20170512125853.GH31437@bigcity.dyn.berto.se> <20170512143242.GA13939@bigcity.dyn.berto.se>
 <CAMuHMdU+uiiZfh5u+tL_bVJinhP-c0_iF4ZQh8=9NHN+aqUs=Q@mail.gmail.com> <20170512211222.GI31437@bigcity.dyn.berto.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: =?UTF-8?Q?Niklas_S=C3=B6derlund?= <niklas.soderlund@ragnatech.se>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170512211222.GI31437@bigcity.dyn.berto.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Niklas,

On Fri, May 12, 2017 at 11:12 PM, Niklas S=C3=B6derlund
<niklas.soderlund@ragnatech.se> wrote:
> On 2017-05-12 16:43:55 +0200, Geert Uytterhoeven wrote:
>> On Fri, May 12, 2017 at 4:32 PM, Niklas S=C3=B6derlund
>> <niklas.soderlund@ragnatech.se> wrote:
>> > On 2017-05-12 14:58:53 +0200, Niklas S=C3=B6derlund wrote:
>> >> On 2017-05-12 14:47:53 +0200, Geert Uytterhoeven wrote:
>> >> > On Fri, May 12, 2017 at 12:27 AM, Niklas S=C3=B6derlund
>> >> > <niklas.soderlund+renesas@ragnatech.se> wrote:
>> >> > When using PSCI suspend/resume, and Wake-on-LAN cannot work due to
>> >> > PSCI firmware issues, Ethernet fails to come up afterwards:
>> >> >
>> >> >     ravb e6800000.ethernet eth0: failed to switch device to config =
mode
>> >> >     ravb e6800000.ethernet eth0: device will be stopped after h/w
>> >> > processes are done.
>> >> >     ravb e6800000.ethernet eth0: failed to switch device to config =
mode
>> >> >     dpm_run_callback(): ravb_resume+0x0/0x148 returns -110
>> >> >     PM: Device e6800000.ethernet failed to resume: error -110
>> >> >
>> >> > Your resume routine cannot assume RAVB is in a sane mode, as it wil=
l
>> >> > have been reset if PSCI suspend was used.
>> >>
>> >> Ouch, yes this is true thanks for reporting will look in to it.
>> >>
>> >> The problem is that in the resume handler if WoL is enabled it will t=
ry
>> >> to close the device before reinitializing it from reset state. If WoL=
 is
>> >> not enabled the device will be closed at suspend time so no need to
>> >> close it before restoring operation from reset in the resume handler.

>> With renesas-drivers, it will refuse to use PSCI suspend if any other wa=
ke-up
>> sources are configured, i.e. try
>>
>>     echo disabled > /sys/devices/platform/soc/e6800000.ethernet/power/wa=
keup
>>
>> Good luck, and have a nice weekend!
>
> Thanks this allowed me to reproduce the same error as you. And after
> future digging I don't believe the problem being in the logic of the
> ravb suspend/resume functions. The problem is that the module clock is
> never turned on after PCSI system suspend if its usage count is above 0
> at suspend time, so the errors we both now observe are due to the module
> clock being disabled.
>
> If I set DEBUG in renesas-cpg-mssr.c and observe when each module clock
> is turned OFF and ON, the fault is clear. If WoL is enabled the clock is
> never turned on when the system is resuming, while if WoL is disabled it
> is. I verified this by removing the calls to clk_enable() and
> clk_disable() from this patch, and by doing so the PCSI system suspend
> works perfect with WoL enabled and the ravb comes up fine after toggling
> SW23 (while ofc WoL no longer works in s2idle due to the module clock is
> switched off at suspend time).
>
> I checked drivers/clk/renesas and I can't find a suspend/resume handler
> for the clock driver, how is this intended to work? If a clock have a
> usage count higher then 0 when the system is PSCI System Suspended it
> seems like it won't be turned back on when the system is resumed from
> this sleep stage. I might have misunderstood something and I need to
> alter the logic in the ravb driver to let the clock driver know it
> should turn on the clock at resume time?

Ah, you found a real use case for suspend/resume support in the clock
drivers ;-)

Due to PSCI system suspend powering down the whole SoC, all clock
settings are lost.

Thanks, I will look into this...

> Whit all this being said I still like to withdraw this patch as I found
> another fault with it, ravb_wol_restore() will unconditionally be called
> while ravb_wol_setup() will only be called if netif_running(ndev). This
> is en easy fix and I will send out a v2 once we figure out what to do
> about the clock.

The clock issue is external to the ravb driver. If it works with
s2idle, it should
be OK.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. Bu=
t
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds
