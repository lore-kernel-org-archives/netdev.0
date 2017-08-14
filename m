From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v2] ravb: add wake-on-lan support via magic packet
Date: Mon, 14 Aug 2017 12:24:06 +0200
Message-ID: <CAMuHMdXmyoMeq8K0BpEzviX1BymR0WyOHeXmNnuR-BBs1asn_Q@mail.gmail.com>
References: <20170730140646.11781-1-niklas.soderlund+renesas@ragnatech.se>
 <20170730170738.GA29373@lunn.ch> <20170730195154.GE1382@bigcity.dyn.berto.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Lunn <andrew@lunn.ch>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        Ulf Hansson <ulf.hansson@linaro.org>
To: =?UTF-8?Q?Niklas_S=C3=B6derlund?= <niklas.soderlund@ragnatech.se>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20170730195154.GE1382@bigcity.dyn.berto.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew, Niklas,

On Sun, Jul 30, 2017 at 9:51 PM, Niklas S=C3=B6derlund
<niklas.soderlund@ragnatech.se> wrote:
> On 2017-07-30 19:07:38 +0200, Andrew Lunn wrote:
>> > @@ -2041,6 +2073,11 @@ static int ravb_probe(struct platform_device *p=
dev)
>> >
>> >     priv->chip_id =3D chip_id;
>> >
>> > +   /* Get clock, if not found that's OK but Wake-On-Lan is unavailabl=
e */
>> > +   priv->clk =3D devm_clk_get(&pdev->dev, NULL);
>> > +   if (IS_ERR(priv->clk))
>> > +           priv->clk =3D NULL;
>>
>> Can you get EPROBE_DEFER returned?
>
> I don't think so, but I'm not sure :-)
>
> The clock I'm trying to get is the module clock of the ravb itself, so
> if that clock is not available (and enabled) no register writes to the
> ravb would be possible in the first place, so i guess it's safe to
> assume -EPROBE_DEFER can not happen here?

In theory, the devm_clk_get() can fail.
In practice, it cannot, as the EtherAVB device is part of a clock domain,
through its "power-domains" property in DT.
Hence if the clock (which is the module clock, provided by the SoC's system
clock controller (CPG/MSSR)) is not yet available, the PM Domain subsystem
will prevent the device from being probed.

> I'm just trying to play it safe here since the clock is only needed to
> support WoL, I though it best to not change behavior here. Try to get
> the clock, if we can great we can do WoL if not then user-space will be
> prevented from enabling WoL and nothing in the current behavior changes.

And all this explicit clock handling is done only because
device_set_wakeup_enable() does not yet prevent the PM Domain code from
powering down the device during system suspend.  Once that's handled by gen=
pd,
all clock magic can be removed.

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
