From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] ravb: add wake-on-lan support via magic packet
Date: Fri, 12 May 2017 16:43:55 +0200
Message-ID: <CAMuHMdU+uiiZfh5u+tL_bVJinhP-c0_iF4ZQh8=9NHN+aqUs=Q@mail.gmail.com>
References: <20170511222735.10706-1-niklas.soderlund+renesas@ragnatech.se>
 <CAMuHMdUXqWJMh7syd3muMs8v9wx5bJNRj_3+xEAXTQTfAv0BFA@mail.gmail.com>
 <20170512125853.GH31437@bigcity.dyn.berto.se> <20170512143242.GA13939@bigcity.dyn.berto.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: =?UTF-8?Q?Niklas_S=C3=B6derlund?= <niklas.soderlund@ragnatech.se>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170512143242.GA13939@bigcity.dyn.berto.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Niklas,

On Fri, May 12, 2017 at 4:32 PM, Niklas S=C3=B6derlund
<niklas.soderlund@ragnatech.se> wrote:
> On 2017-05-12 14:58:53 +0200, Niklas S=C3=B6derlund wrote:
>> On 2017-05-12 14:47:53 +0200, Geert Uytterhoeven wrote:
>> > On Fri, May 12, 2017 at 12:27 AM, Niklas S=C3=B6derlund
>> > <niklas.soderlund+renesas@ragnatech.se> wrote:
>> > > WoL is enabled in the suspend callback by setting MagicPacket detect=
ion
>> > > and disabling all interrupts expect MagicPacket. In the resume path =
the
>> > > driver needs to reset the hardware to rearm the WoL logic, this prev=
ents
>> > > the driver from simply restoring the registers and to take advantage=
 of
>> > > that ravb was not suspended to reduce resume time. To reset the
>> > > hardware the driver closes the device, sets it in reset mode and reo=
pens
>> > > the device just like it would do in a normal suspend/resume scenario
>> > > without WoL enabled, but it both closes and opens the device in the
>> > > resume callback since the device needs to be reset for WoL to work.
>> > >
>> > > One quirk needed for WoL is that the module clock needs to be preven=
ted
>> > > from being switched off by Runtime PM. To keep the clock alive the
>> > > suspend callback need to call clk_enable() directly to increase the
>> > > usage count of the clock. Then when Runtime PM decreases the clock u=
sage
>> > > count it won't reach 0 and be switched off.
>> > >
>> > > Signed-off-by: Niklas S=C3=B6derlund <niklas.soderlund+renesas@ragna=
tech.se>
>> >
>> > Thanks for your patch!
>> >
>> > Wake-on-LAN now works for me on Salvator-X (both H3 and M3).
>> >
>> > However, after a few cycles, Ethernet stopped working, because CMA ran=
 out of
>> > memory:
>> >
>> >     cma: cma_alloc: alloc failed, req-size: 6 pages, ret: -4
>> >     dpm_run_callback(): ravb_resume+0x0/0x148 returns -12
>> >     PM: Device e6800000.ethernet failed to resume: error -12
>> >
>> > Are we still missing some ravb patches in net-next, or is this a diffe=
rent
>> > issue?
>>
>> Interesting, I did a 100 loop test on H3 based on v4.11 without any
>> issues. What are you using as a base for your test and I will test if I
>> can reproduce it.
>
> I re-ran my test based on renesas-drivers-2017-05-02-v4.11 using the
> arm64 defconfig. And was not able to see this :-(
>
> My TC is basically a expect script that do:
>
> ethtool -s eth0 wol g
>
> for (i =3D 0; i < 100; i++) {
>     echo s2idle > /sys/power/mem_sleep
>     echo mem > /sys/power/state
>
>     sleep 5
>
>     HOST: etherwake -i net0 2e:09:0a:00:83:90
>
>     WAIT_FOR_CONSOLE
> }
>
> I use the default DT and arm64 defconfig and no other modifications. I'm
> testing on H3 ES1.x board. What can be the different for us?

I'm not using "echo s2idle > /sys/power/mem_sleep", as renesas-drivers stil=
l
has my patches to not use PSCI suspend if any other wake-up sources
are configured.

I'll retry later...

>> > When using PSCI suspend/resume, and Wake-on-LAN cannot work due to
>> > PSCI firmware issues, Ethernet fails to come up afterwards:
>> >
>> >     ravb e6800000.ethernet eth0: failed to switch device to config mod=
e
>> >     ravb e6800000.ethernet eth0: device will be stopped after h/w
>> > processes are done.
>> >     ravb e6800000.ethernet eth0: failed to switch device to config mod=
e
>> >     dpm_run_callback(): ravb_resume+0x0/0x148 returns -110
>> >     PM: Device e6800000.ethernet failed to resume: error -110
>> >
>> > Your resume routine cannot assume RAVB is in a sane mode, as it will
>> > have been reset if PSCI suspend was used.
>>
>> Ouch, yes this is true thanks for reporting will look in to it.
>>
>> The problem is that in the resume handler if WoL is enabled it will try
>> to close the device before reinitializing it from reset state. If WoL is
>> not enabled the device will be closed at suspend time so no need to
>> close it before restoring operation from reset in the resume handler.
>
> I was not able to reproduce this fault neither :-( But here I see
> something is wrong, nothing is outputted on the console if WoL is
> enabled:
>
> echo 0 > /sys/module/printk/parameters/console_suspend
> i2cset -f -y 7 0x30 0x20 0x0F
> <Flip SW23>
> echo mem > /sys/power/state
> <Flip SW23>
> <System wakes up>
>
> While:
> ethtool -s eth0 wol g
> echo 0 > /sys/module/printk/parameters/console_suspend
> i2cset -f -y 7 0x30 0x20 0x0F
> <Flip SW23>
> echo mem > /sys/power/state
> <Flip SW23>
> <Nothing happens on the console, not even firmware info is printed>
>
> Are you enabling anything else then console_suspend to be able to
> capture output at this point? I'm using the same setup tag and config as
> I described above.

With renesas-drivers, it will refuse to use PSCI suspend if any other wake-=
up
sources are configured, i.e. try

    echo disabled > /sys/devices/platform/soc/e6800000.ethernet/power/wakeu=
p

Good luck, and have a nice weekend!

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
