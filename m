From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH v3] sh_eth: call of_mdiobus_register() to register phys
Date: Wed, 26 Feb 2014 12:30:16 +0000
Message-ID: <530DDE58.9080308@codethink.co.uk>
References: <1393415873-10520-1-git-send-email-ben.dooks@codethink.co.uk> <530DDC32.9010002@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	nobuhiro.iwamatsu.yj@renesas.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <530DDC32.9010002@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26/02/14 12:21, Sergei Shtylyov wrote:
> Hello.
>
> On 26-02-2014 15:57, Ben Dooks wrote:
>
>> If the sh_eth device is registered using OF, then the driver
>> should call of_mdiobus_register() to register any PHYs connected
>> to the system.
>
>     I think you now should extend your changelog as you've decided to
> also use of_ohy_connect().

Ok, will fix.

>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
>
>> --
>> v2:
>>     - allocate mdio->irq array at init time
>>     - set devdata after succesful mdio registration
>> v3:
>>     - do not parse phy->irq in of setup (done by of_mdiobus)
>>     - use of_phy_connect to connect phy
>> ---
>>   drivers/net/ethernet/renesas/sh_eth.c | 46
>> ++++++++++++++++++++++++++---------
>>   1 file changed, 34 insertions(+), 12 deletions(-)
>
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c
>> b/drivers/net/ethernet/renesas/sh_eth.c
>> index a18cbe1..6d14abf 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> [...]
>> @@ -1764,17 +1765,31 @@ static int sh_eth_phy_init(struct net_device
>> *ndev)
>>       struct sh_eth_private *mdp = netdev_priv(ndev);
>>       char phy_id[MII_BUS_ID_SIZE + 3];
>
>     Shouldn't this variable be moved to where it's used now?
>
>>       struct phy_device *phydev = NULL;
>> -
>> -    snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
>> -         mdp->mii_bus->id, mdp->phy_id);
>> +    struct device_node *np = ndev->dev.parent->of_node;
>>
>>       mdp->link = 0;
>>       mdp->speed = 0;
>>       mdp->duplex = -1;
>>
>> -    /* Try connect to PHY */
>
>      Why remove the comment?

Didn't mean to.

>> -    phydev = phy_connect(ndev, phy_id, sh_eth_adjust_link,
>> -                 mdp->phy_interface);
>> +    if (np) {
>> +        struct device_node *pn;
>> +
>> +        pn = of_parse_phandle(np, "phy-handle", 0);
>> +        phydev = of_phy_connect(ndev, pn,
>> +                    sh_eth_adjust_link, 0,
>> +                    mdp->phy_interface);
>> +
>
>     Empty line hardly needed here.
>
>> +        if (!phydev)
>> +            phydev = ERR_PTR(ENOENT);
>
>     Not -ENOENT?
>
>> +    } else {
>> +        snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
>> +             mdp->mii_bus->id, mdp->phy_id);
>> +
>> +        /* Try connect to PHY */
>> +        phydev = phy_connect(ndev, phy_id, sh_eth_adjust_link,
>> +                     mdp->phy_interface);
>> +    }
>> +
>
>     Empty line can be omitted here as well...

I think the code looks too dense without these in.

>>       if (IS_ERR(phydev)) {
>>           dev_err(&ndev->dev, "phy_connect failed\n");
>
>     The message needs some adjustment now, like "can't connect to PHY\n".

Ok, will fix.

>> @@ -2638,6 +2653,18 @@ static int sh_mdio_init(struct net_device
>> *ndev, int id,
>>           goto out_free_bus;
>>       }
>>
>> +    if (ndev->dev.parent->of_node) {
>> +        ret = of_mdiobus_register(mdp->mii_bus,
>> +                      ndev->dev.parent->of_node);
>> +        if (ret != 0) {
>
>     You forgot to remove != 0...

Ok, will fix.

>> +            dev_err(&ndev->dev, "of_mdiobus_register() failed\n");
>> +            goto out_free_bus;
>> +        }
>> +
>> +        dev_set_drvdata(&ndev->dev, mdp->mii_bus);
>> +        return 0;
>
>     Still repetitive without *goto* (or *else*)...

I'm still unconvinced that a goto is the right thing here.

I will look into fixing this.

>> +    }
>> +
>>       for (i = 0; i < PHY_MAX_ADDR; i++)
>>           mdp->mii_bus->irq[i] = PHY_POLL;
>>       if (pd->phy_irq > 0)
> [...]
>> @@ -2727,11 +2753,7 @@ static struct sh_eth_plat_data
>> *sh_eth_parse_dt(struct device *dev)
>>           return NULL;
>>
>>       pdata->phy_interface = of_get_phy_mode(np);
>> -
>> -    phy = of_parse_phandle(np, "phy-handle", 0);
>> -    if (of_property_read_u32(phy, "reg", &pdata->phy))
>> -        return NULL;
>> -    pdata->phy_irq = irq_of_parse_and_map(phy, 0);
>> +    pdata->phy_irq = PHY_POLL;
>
>     You can completely omit this. It won't get used now anyway.

you're right, will delete.


-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
