From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/4] ravb: Add optional PHY reset during system resume
Date: Thu, 28 Sep 2017 12:21:57 -0700
Message-ID: <1a474c45-29ea-82fa-1ab0-0febfdc38bcb@gmail.com>
References: <1506614014-4398-1-git-send-email-geert+renesas@glider.be>
 <1506614014-4398-3-git-send-email-geert+renesas@glider.be>
 <406f7aff-e386-31f3-39d3-17523443c265@gmail.com>
 <CAMuHMdWOAnT3xONPfU8pJi9fbAgtWL2GyRbooAxrfGDb=bsB_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Andrew Lunn <andrew@lunn.ch>,
        =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdWOAnT3xONPfU8pJi9fbAgtWL2GyRbooAxrfGDb=bsB_A@mail.gmail.com>
Content-Language: en-US
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/28/2017 11:45 AM, Geert Uytterhoeven wrote:
> Hi Florian,
> 
> On Thu, Sep 28, 2017 at 7:22 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 09/28/2017 08:53 AM, Geert Uytterhoeven wrote:
>>> If the optional "reset-gpios" property is specified in DT, the generic
>>> MDIO bus code takes care of resetting the PHY during device probe.
>>> However, the PHY may still have to be reset explicitly after system
>>> resume.
>>>
>>> This allows to restore Ethernet operation after resume from s2ram on
>>> Salvator-XS, where the enable pin of the regulator providing PHY power
>>> is connected to PRESETn, and PSCI suspend powers down the SoC.
>>>
>>> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
>>> ---
>>>  drivers/net/ethernet/renesas/ravb_main.c | 9 +++++++++
>>>  1 file changed, 9 insertions(+)
>>>
>>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
>>> index fdf30bfa403bf416..96d1d48e302f8c9a 100644
>>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
>>> @@ -19,6 +19,7 @@
>>>  #include <linux/etherdevice.h>
>>>  #include <linux/ethtool.h>
>>>  #include <linux/if_vlan.h>
>>> +#include <linux/gpio/consumer.h>
>>>  #include <linux/kernel.h>
>>>  #include <linux/list.h>
>>>  #include <linux/module.h>
>>> @@ -2268,6 +2269,7 @@ static int __maybe_unused ravb_resume(struct device *dev)
>>>  {
>>>       struct net_device *ndev = dev_get_drvdata(dev);
>>>       struct ravb_private *priv = netdev_priv(ndev);
>>> +     struct mii_bus *bus = priv->mii_bus;
>>>       int ret = 0;
>>>
>>>       if (priv->wol_enabled) {
>>> @@ -2302,6 +2304,13 @@ static int __maybe_unused ravb_resume(struct device *dev)
>>>        * reopen device if it was running before system suspended.
>>>        */
>>>
>>> +     /* PHY reset */
>>> +     if (bus->reset_gpiod) {
>>> +             gpiod_set_value_cansleep(bus->reset_gpiod, 1);
>>> +             udelay(bus->reset_delay_us);
>>> +             gpiod_set_value_cansleep(bus->reset_gpiod, 0);
>>> +     }
>>
>> This is a clever hack, but unfortunately this is also misusing the MDIO
>> bus reset line into a PHY reset line. As commented in patch 3, if this
>> reset line is tied to the PHY, then this should be a PHY property and
> 
> OK.
> 
>> you cannot (ab)use the MDIO bus GPIO reset logic anymore...
> 
> And then I should add reset-gpios support to drivers/net/phy/micrel.c?
> Or is there already generic code to handle per-PHY reset? I couldn't find it.

There is not such a thing unfortunately, but it would presumably be
called within drivers/net/phy/mdio_bus.c during bus->reset() time
because you need the PHY reset to be deasserted before you can
successfully read/write from the PHY, and if you can't read/write from
the PHY, the MDIO bus layer cannot read the PHY ID, and therefore cannot
match a PHY device with its driver, so things don't work.

NB: you could move this entirely to the Micrel PHY driver if you specify
a compatible string that has a the PHY OUI in it, because that bypasses
the need to match the PHY driver with the PHY device, but this may not
be an acceptable solution for non-DT platforms or other platforms where
the PHY can't be determined based on the board DTS.

I was going to suggest writing some sort of generic helper that walks
the list of child nodes from a MDIO bus device node and deassert reset
lines and enables clocks, but there is absolutely nothing generic about
that. Things like which of the reset should come first, and if there are
multiple, in which order, etc.

> 
>> Should not you also try to manage this reset line during ravb_open() to
>> achiever better power savings?
> 
> I don't know. The Micrel KSZ9031RNXVA datasheet doesn't mention if it's
> safe or not to assert reset for a prolonged time.
> 
> Thanks!
> 
> Gr{oetje,eeting}s,
> 
>                         Geert
> 
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org
> 
> In personal conversations with technical people, I call myself a hacker. But
> when I'm talking to journalists I just say "programmer" or something like that.
>                                 -- Linus Torvalds
> 


-- 
Florian
