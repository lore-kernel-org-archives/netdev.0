From: Max Filippov <jcmvbkbc@gmail.com>
Subject: Re: [PATCH v2 3/4] net: ethoc: set up MII management bus clock
Date: Thu, 30 Jan 2014 04:14:31 +0400
Message-ID: <CAMo8Bf+5W6mE8sbnN=_xpeU8wOe2-HQoD32LV+mDT-=rq3ZB7w@mail.gmail.com>
References: <1390975218-13863-1-git-send-email-jcmvbkbc@gmail.com>
	<1390975218-13863-4-git-send-email-jcmvbkbc@gmail.com>
	<52E8A74F.9060603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Chris Zankel <chris@zankel.net>,
	Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52E8A74F.9060603@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 29, 2014 at 11:01 AM, Florian Fainelli <f.fainelli@gmail.co=
m> wrote:
> Le 28/01/2014 22:00, Max Filippov a =C3=A9crit :
>
>> MII management bus clock is derived from the MAC clock by dividing i=
t by
>> MIIMODER register CLKDIV field value. This value may need to be set =
up
>> in case it is undefined or its default value is too high (and
>> communication with PHY is too slow) or too low (and communication wi=
th
>> PHY is impossible). The value of CLKDIV is not specified directly, b=
ut
>> is derived from the MAC clock for the default MII management bus fre=
quency
>> of 2.5MHz. The MAC clock may be specified in the platform data, or a=
s
>> either 'clock-frequency' or 'clocks' device tree attribute.
>>
>> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
>> ---
>> Changes v1->v2:
>> - drop MDIO bus frequency configurability, always configure for stan=
dard
>>    2.5MHz;
>> - allow using common clock framework to provide ethoc clock.
>>
>>   drivers/net/ethernet/ethoc.c | 37 ++++++++++++++++++++++++++++++++=
+++--
>>   include/net/ethoc.h          |  1 +
>>   2 files changed, 36 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/eth=
oc.c
>> index 5643b2d..5854d41 100644
>> --- a/drivers/net/ethernet/ethoc.c
>> +++ b/drivers/net/ethernet/ethoc.c
>> @@ -13,6 +13,7 @@
>>
>>   #include <linux/dma-mapping.h>
>>   #include <linux/etherdevice.h>
>> +#include <linux/clk.h>
>>   #include <linux/crc32.h>
>>   #include <linux/interrupt.h>
>>   #include <linux/io.h>
>> @@ -216,6 +217,7 @@ struct ethoc {
>>
>>         struct phy_device *phy;
>>         struct mii_bus *mdio;
>> +       struct clk *clk;
>>         s8 phy_id;
>>   };
>>
>> @@ -925,6 +927,8 @@ static int ethoc_probe(struct platform_device *p=
dev)
>>         int num_bd;
>>         int ret =3D 0;
>>         bool random_mac =3D false;
>> +       u32 eth_clkfreq =3D 0;
>> +       struct ethoc_platform_data *pdata =3D dev_get_platdata(&pdev=
->dev);
>>
>>         /* allocate networking device */
>>         netdev =3D alloc_etherdev(sizeof(struct ethoc));
>> @@ -1038,8 +1042,7 @@ static int ethoc_probe(struct platform_device =
*pdev)
>>         }
>>
>>         /* Allow the platform setup code to pass in a MAC address. *=
/
>> -       if (dev_get_platdata(&pdev->dev)) {
>> -               struct ethoc_platform_data *pdata =3D
>> dev_get_platdata(&pdev->dev);
>> +       if (pdata) {
>>                 memcpy(netdev->dev_addr, pdata->hwaddr, IFHWADDRLEN)=
;
>>                 priv->phy_id =3D pdata->phy_id;
>>         } else {
>> @@ -1077,6 +1080,32 @@ static int ethoc_probe(struct platform_device
>> *pdev)
>>         if (random_mac)
>>                 netdev->addr_assign_type =3D NET_ADDR_RANDOM;
>>
>> +       /* Allow the platform setup code to adjust MII management bu=
s
>> clock. */
>> +       if (pdata)
>> +               eth_clkfreq =3D pdata->eth_clkfreq;
>
> Since this is a new member, why not make it a struct clk pointer dire=
ctly so
> you could simplify the code path?

Basically this is to provide flexibility for the user: it may be more
appropriate to
specify frequency if it's known and fixed, otherwise clk_get below
would find the
clock registered for this device/generic clock.

>> +       else
>> +               of_property_read_u32(pdev->dev.of_node,
>> +                                    "clock-frequency", &eth_clkfreq=
);
>> +       if (!eth_clkfreq) {
>> +               struct clk *clk =3D clk_get(&pdev->dev, NULL);

This should have been devm_clk_get.

>> +
>> +               if (!IS_ERR(clk)) {
>> +                       priv->clk =3D clk;
>> +                       clk_prepare_enable(clk);
>> +                       eth_clkfreq =3D clk_get_rate(clk);
>> +               }
>> +       }
>> +       if (eth_clkfreq) {
>> +               u32 clkdiv =3D MIIMODER_CLKDIV(eth_clkfreq / 2500000=
 + 1);
>> +
>> +               if (!clkdiv)
>> +                       clkdiv =3D 2;
>> +               dev_dbg(&pdev->dev, "setting MII clkdiv to %u\n", cl=
kdiv);
>> +               ethoc_write(priv, MIIMODER,
>> +                           (ethoc_read(priv, MIIMODER) & MIIMODER_N=
OPRE)
>> |
>> +                           clkdiv);
>> +       }
>
>
> This does look a bit convoluted, and it looks like the clk_get() or g=
etting
> the clock-frequency property should boil down to being the same thing=
 with
> of_clk_get() as it should resolve all clocks phandles and fetch their
> frequencies appropriately.

I can drop clock-frequency property checking to encourage usage of comm=
on
clock framework. I don't quite understand the rest of the objection, co=
uld you
please rephrase it? clk_get calls of_clk_get internally.

>> +
>>         /* register MII bus */
>>         priv->mdio =3D mdiobus_alloc();
>>         if (!priv->mdio) {
>> @@ -1141,6 +1170,8 @@ free_mdio:
>>         kfree(priv->mdio->irq);
>>         mdiobus_free(priv->mdio);
>>   free:
>> +       if (priv->clk)
>> +               clk_disable_unprepare(priv->clk);
>
>
> This should probbaly be if (!IS_ERR(priv-clk)).

No, I haven't changed priv->clk when get_clk returned error.

>>         free_netdev(netdev);
>>   out:
>>         return ret;
>> @@ -1165,6 +1196,8 @@ static int ethoc_remove(struct platform_device
>> *pdev)
>>                         kfree(priv->mdio->irq);
>>                         mdiobus_free(priv->mdio);
>>                 }
>> +               if (priv->clk)
>> +                       clk_disable_unprepare(priv->clk);
>
>
> Same here

Ditto.

>>                 unregister_netdev(netdev);
>>                 free_netdev(netdev);
>>         }
>> diff --git a/include/net/ethoc.h b/include/net/ethoc.h
>> index 96f3789..2a2d6bb 100644
>> --- a/include/net/ethoc.h
>> +++ b/include/net/ethoc.h
>> @@ -16,6 +16,7 @@
>>   struct ethoc_platform_data {
>>         u8 hwaddr[IFHWADDRLEN];
>>         s8 phy_id;
>> +       u32 eth_clkfreq;
>>   };
>>
>>   #endif /* !LINUX_NET_ETHOC_H */
>>

--=20
Thanks.
-- Max
