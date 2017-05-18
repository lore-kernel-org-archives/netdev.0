From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] of_mdio: Fix broken PHY IRQ in case of probe deferral
Date: Thu, 18 May 2017 20:48:26 +0200
Message-ID: <CAMuHMdWYeSzofU57LmT_M3KkcHhvjfJy7nkHvcXkKzOYmvhqqA@mail.gmail.com>
References: <1495112345-24795-1-git-send-email-geert+renesas@glider.be> <f0ed61c3-062b-cec6-fe19-7412231e8ef1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
        Andrew Lunn <andrew@lunn.ch>, Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f0ed61c3-062b-cec6-fe19-7412231e8ef1@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

On Thu, May 18, 2017 at 8:25 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 05/18/2017 05:59 AM, Geert Uytterhoeven wrote:
>> If an Ethernet PHY is initialized before the interrupt controller it is
>> connected to, a message like the following is printed:
>>
>>     irq: no irq domain found for /interrupt-controller@e61c0000 !
>>
>> However, the actual error is ignored, leading to a non-functional (-1)
>> PHY interrupt later:
>>
>>     Micrel KSZ8041RNLI ee700000.ethernet-ffffffff:01: attached PHY driver [Micrel KSZ8041RNLI] (mii_bus:phy_addr=ee700000.ethernet-ffffffff:01, irq=-1)
>>
>> Depending on whether the PHY driver will fall back to polling, Ethernet
>> may or may not work.
>>
>> To fix this:
>>   1. Switch of_mdiobus_register_phy() from irq_of_parse_and_map() to
>>      of_irq_get().
>>      Unlike the former, the latter returns -EPROBE_DEFER if the
>>      interrupt controller is not yet available, so this condition can be
>>      detected.
>>      Other errors are handled the same as before, i.e. use the passed
>>      mdio->irq[addr] as interrupt.
>>   2. Propagate and handle errors from of_mdiobus_register_phy() and
>>      of_mdiobus_register_device().
>
> This most certainly works fine in the simple case where you have one PHY
> hanging off the MDIO bus, now what happens if you have several?
>
> Presumably, the first PHY that returns EPROBE_DEFER will make the entire
> bus registration return EPROB_DEFER as well, and so on, and so forth,
> but I am not sure if we will be properly unwinding the successful
> registration of PHYs that either don't have an interrupt, or did not
> return EPROBE_DEFER.
>
> It should be possible to mimic this behavior by using the fixed PHY, and
> possibly the dsa_loop.c driver which would create 4 ports, expecting 4
> fixed PHYs to be present.

mdiobus_unregister(), called from of_mdiobus_register() on failure,
should do the unwinding, right?

And when the driver is reprobed, all PHYs are reprobed, until they all
succeed.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
