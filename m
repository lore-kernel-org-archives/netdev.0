From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v8 2/3] net: hisilicon: new hip04 MDIO driver
Date: Mon, 21 Apr 2014 22:21:50 +0400
Message-ID: <535561BE.9070303@cogentembedded.com>
References: <1397869980-21187-1-git-send-email-zhangfei.gao@linaro.org> <1397869980-21187-3-git-send-email-zhangfei.gao@linaro.org> <53555C28.4050303@cogentembedded.com> <CAGVrzcb8Ykxi72x3iBStjTL+OO1BhDc_yZnnPq8ZHra+mtrBEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>,
	David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Mark Rutland <mark.rutland@arm.com>,
	David Laight <David.Laight@aculab.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, xuwei5@hisilicon.com,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:41753 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800AbaDUSVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 14:21:53 -0400
Received: by mail-la0-f54.google.com with SMTP id mc6so3429957lab.41
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2014 11:21:52 -0700 (PDT)
In-Reply-To: <CAGVrzcb8Ykxi72x3iBStjTL+OO1BhDc_yZnnPq8ZHra+mtrBEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/21/2014 10:03 PM, Florian Fainelli wrote:

>>> Hisilicon hip04 platform mdio driver
>>> Reuse Marvell phy drivers/net/phy/marvell.c

>>> Signed-off-by: Zhangfei Gao <zhangfei.gao@linaro.org>
>> [...]

>>> diff --git a/drivers/net/ethernet/hisilicon/hip04_mdio.c
>>> b/drivers/net/ethernet/hisilicon/hip04_mdio.c
>>> new file mode 100644
>>> index 0000000..19826a3
>>> --- /dev/null
>>> +++ b/drivers/net/ethernet/hisilicon/hip04_mdio.c
>>> @@ -0,0 +1,185 @@

[...]

>>> +static int hip04_mdio_reset(struct mii_bus *bus)
>>> +{
>>> +       int temp, err, i;
>>> +
>>> +       for (i = 0; i < PHY_MAX_ADDR; i++) {
>>> +               hip04_mdio_write(bus, i, 22, 0);

>>     Why? What kind of a register this is? <uapi/linux/mii.h> tells me it's
>> MII_SREVISION...

> I think this rather means clause 22 as opposed to clause 45.

    No, the corresponding hip04_mdio_write()'s parameter is a register #, so 
this is a write of 0 to register #22. A comment certainly wouldn't hurt here...

>>> +               temp = hip04_mdio_read(bus, i, MII_BMCR);

>>     You're not checking for error...

>>> +               temp |= BMCR_RESET;
>>> +               err = hip04_mdio_write(bus, i, MII_BMCR, temp);

>>     Hmm, why you're open coding BMCR reset? There's phy_init_hw() doing this
>> correctly...

> Except that this runs way before we have created the PHY driver, so we
> can't use that function just yet.

    Ah, you're right.

> I already asked about this, and he
> explained that this was because the PHY devices he uses are not
> responding correcty to MII_PHYSID1/2 reads.

    So, this manual reset loop helps with reading the ID registers? A comment 
wouldn't hurt either...

>>> +               if (err < 0)
>>> +                       return err;

    I'm not at all sure we want to leave the reset loop on a first write error.

>>> +       }
>>> +
>>> +       mdelay(500);

    I'm not sure this is enough, given that in phy_init_hw() we poll for 600 
ms + 1 ms.

>>> +       return 0;
>>> +}
>>> +
>>> +static int hip04_mdio_probe(struct platform_device *pdev)
>>> +{
>>> +       struct resource *r;
>>> +       struct mii_bus *bus;
>>> +       struct hip04_mdio_priv *priv;
>>> +       int ret;
>>> +
>>> +       bus = mdiobus_alloc_size(sizeof(struct hip04_mdio_priv));
>>> +       if (!bus) {
>>> +               dev_err(&pdev->dev, "Cannot allocate MDIO bus\n");
>>> +               return -ENOMEM;
>>> +       }
>>> +
>>> +       bus->name = "hip04_mdio_bus";
>>> +       bus->read = hip04_mdio_read;
>>> +       bus->write = hip04_mdio_write;
>>> +       bus->reset = hip04_mdio_reset;

>>     Ah... However I don't think it a good implementation of that bus
>> method...

    I assumed this method exists to do a hardware reset of the whole bus, not 
to do a loop of soft-resetting all PHYs...

WBR, Sergei
