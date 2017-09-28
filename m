From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 2/4] ravb: Add optional PHY reset during system resume
Date: Thu, 28 Sep 2017 20:45:00 +0200
Message-ID: <CAMuHMdWOAnT3xONPfU8pJi9fbAgtWL2GyRbooAxrfGDb=bsB_A@mail.gmail.com>
References: <1506614014-4398-1-git-send-email-geert+renesas@glider.be>
 <1506614014-4398-3-git-send-email-geert+renesas@glider.be> <406f7aff-e386-31f3-39d3-17523443c265@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Andrew Lunn <andrew@lunn.ch>,
        =?UTF-8?Q?Niklas_S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:38190 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750775AbdI1SpC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 14:45:02 -0400
In-Reply-To: <406f7aff-e386-31f3-39d3-17523443c265@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Thu, Sep 28, 2017 at 7:22 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 09/28/2017 08:53 AM, Geert Uytterhoeven wrote:
>> If the optional "reset-gpios" property is specified in DT, the generic
>> MDIO bus code takes care of resetting the PHY during device probe.
>> However, the PHY may still have to be reset explicitly after system
>> resume.
>>
>> This allows to restore Ethernet operation after resume from s2ram on
>> Salvator-XS, where the enable pin of the regulator providing PHY power
>> is connected to PRESETn, and PSCI suspend powers down the SoC.
>>
>> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
>> ---
>>  drivers/net/ethernet/renesas/ravb_main.c | 9 +++++++++
>>  1 file changed, 9 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
>> index fdf30bfa403bf416..96d1d48e302f8c9a 100644
>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
>> @@ -19,6 +19,7 @@
>>  #include <linux/etherdevice.h>
>>  #include <linux/ethtool.h>
>>  #include <linux/if_vlan.h>
>> +#include <linux/gpio/consumer.h>
>>  #include <linux/kernel.h>
>>  #include <linux/list.h>
>>  #include <linux/module.h>
>> @@ -2268,6 +2269,7 @@ static int __maybe_unused ravb_resume(struct device *dev)
>>  {
>>       struct net_device *ndev = dev_get_drvdata(dev);
>>       struct ravb_private *priv = netdev_priv(ndev);
>> +     struct mii_bus *bus = priv->mii_bus;
>>       int ret = 0;
>>
>>       if (priv->wol_enabled) {
>> @@ -2302,6 +2304,13 @@ static int __maybe_unused ravb_resume(struct device *dev)
>>        * reopen device if it was running before system suspended.
>>        */
>>
>> +     /* PHY reset */
>> +     if (bus->reset_gpiod) {
>> +             gpiod_set_value_cansleep(bus->reset_gpiod, 1);
>> +             udelay(bus->reset_delay_us);
>> +             gpiod_set_value_cansleep(bus->reset_gpiod, 0);
>> +     }
>
> This is a clever hack, but unfortunately this is also misusing the MDIO
> bus reset line into a PHY reset line. As commented in patch 3, if this
> reset line is tied to the PHY, then this should be a PHY property and

OK.

> you cannot (ab)use the MDIO bus GPIO reset logic anymore...

And then I should add reset-gpios support to drivers/net/phy/micrel.c?
Or is there already generic code to handle per-PHY reset? I couldn't find it.

> Should not you also try to manage this reset line during ravb_open() to
> achiever better power savings?

I don't know. The Micrel KSZ9031RNXVA datasheet doesn't mention if it's
safe or not to assert reset for a prolonged time.

Thanks!

Gr{oetje,eeting}s,

                        Geert
