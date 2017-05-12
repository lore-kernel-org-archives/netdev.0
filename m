From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] ravb: add wake-on-lan support via magic packet
Date: Fri, 12 May 2017 14:47:53 +0200
Message-ID: <CAMuHMdUXqWJMh7syd3muMs8v9wx5bJNRj_3+xEAXTQTfAv0BFA@mail.gmail.com>
References: <20170511222735.10706-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: =?UTF-8?Q?Niklas_S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170511222735.10706-1-niklas.soderlund+renesas@ragnatech.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Niklas,

On Fri, May 12, 2017 at 12:27 AM, Niklas S=C3=B6derlund
<niklas.soderlund+renesas@ragnatech.se> wrote:
> WoL is enabled in the suspend callback by setting MagicPacket detection
> and disabling all interrupts expect MagicPacket. In the resume path the
> driver needs to reset the hardware to rearm the WoL logic, this prevents
> the driver from simply restoring the registers and to take advantage of
> that ravb was not suspended to reduce resume time. To reset the
> hardware the driver closes the device, sets it in reset mode and reopens
> the device just like it would do in a normal suspend/resume scenario
> without WoL enabled, but it both closes and opens the device in the
> resume callback since the device needs to be reset for WoL to work.
>
> One quirk needed for WoL is that the module clock needs to be prevented
> from being switched off by Runtime PM. To keep the clock alive the
> suspend callback need to call clk_enable() directly to increase the
> usage count of the clock. Then when Runtime PM decreases the clock usage
> count it won't reach 0 and be switched off.
>
> Signed-off-by: Niklas S=C3=B6derlund <niklas.soderlund+renesas@ragnatech.=
se>

Thanks for your patch!

Wake-on-LAN now works for me on Salvator-X (both H3 and M3).

However, after a few cycles, Ethernet stopped working, because CMA ran out =
of
memory:

    cma: cma_alloc: alloc failed, req-size: 6 pages, ret: -4
    dpm_run_callback(): ravb_resume+0x0/0x148 returns -12
    PM: Device e6800000.ethernet failed to resume: error -12

Are we still missing some ravb patches in net-next, or is this a different
issue?

When using PSCI suspend/resume, and Wake-on-LAN cannot work due to
PSCI firmware issues, Ethernet fails to come up afterwards:

    ravb e6800000.ethernet eth0: failed to switch device to config mode
    ravb e6800000.ethernet eth0: device will be stopped after h/w
processes are done.
    ravb e6800000.ethernet eth0: failed to switch device to config mode
    dpm_run_callback(): ravb_resume+0x0/0x148 returns -110
    PM: Device e6800000.ethernet failed to resume: error -110

Your resume routine cannot assume RAVB is in a sane mode, as it will
have been reset if PSCI suspend was used.

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
