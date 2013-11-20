From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC v1 4/7] net: phy: suspend unused PHYs on mdio_bus in late_initcall
Date: Wed, 20 Nov 2013 14:36:14 -0800
Message-ID: <CAGVrzcbQFYGjy=mPXZ6rh_LGAAMcpSRNjm2WFyMZ8C+FffbyLQ@mail.gmail.com>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1384978913-8052-5-git-send-email-sebastian.hesselbarth@gmail.com>
 <CAGVrzcYBexBWrh2Nz8tu0KRLQ4YPjtJux9N-TC07-Hxf3On1FQ@mail.gmail.com> <528D2403.5040204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <528D2403.5040204@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/11/20 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>:
> On 11/20/2013 09:58 PM, Florian Fainelli wrote:
>>
>> 2013/11/20 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>:
>>>
>>> Since phy_attach ensures PHYs are resumed, we can now suspend all
>>> PHYs that have no attached netdev after initcalls.
>>
>>
>> I do like the idea, but I think you might want to make sure that the
>> MDIO bus suspend policy was set to "auto" (which is the default afair)
>> not to expose unexpected behavior.
>
>
> Ok, TBH I haven't looked through all of phy internals. If we are fine
> with the overall approach, I could use some guidance in the individual
> patches and policies.
>
>
>>>
>>> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
>>> ---
>>> Cc: David S. Miller <davem@davemloft.net>
>>> Cc: netdev@vger.kernel.org
>>> Cc: linux-arm-kernel@lists.infradead.org
>>> Cc: linux-kernel@vger.kernel.org
>>> ---
>>>   drivers/net/phy/mdio_bus.c |   27 +++++++++++++++++++++++++++
>>>   1 files changed, 27 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
>>> index 5617876..10eba58 100644
>>> --- a/drivers/net/phy/mdio_bus.c
>>> +++ b/drivers/net/phy/mdio_bus.c
>>> @@ -320,6 +320,33 @@ static int mdio_bus_match(struct device *dev, struct
>>> device_driver *drv)
>>>                  (phydev->phy_id & phydrv->phy_id_mask));
>>>   }
>>>
>>> +static int mdio_bus_suspend_unused(struct device *busdev, void *data)
>>> +{
>>> +       struct mii_bus *bus = to_mii_bus(busdev);
>>> +       struct phy_device *phydev;
>>> +       struct phy_driver *phydrv;
>>> +       int i;
>>> +
>>> +       for (i = 0; i < PHY_MAX_ADDR; i++) {
>>> +               if (!bus->phy_map[i])
>>> +                       continue;
>>> +
>>> +               phydev = to_phy_device(&bus->phy_map[i]->dev);
>>> +               phydrv = to_phy_driver(phydev->dev.driver);
>>> +               if (!phydev->attached_dev && phydrv && phydrv->suspend)
>>> +                       phy_suspend(phydev);
>>> +       }
>>> +
>>> +       return 0;
>>
>>
>> You might want to reuse mdio_bus_phy_may_suspend() here to have a
>> central place checking for phydev->attached_dev and phydrv->suspend
>> just in case we need to add more callbacks in the future or implicit
>> PHY state machine hooks. That might also take care of my concern
>> expressed above.
>
>
> Unfortunately, mdio_bus_phy_may_suspend() doesn't help here. It will
> correctly tell that unconnected PHYs may_suspend but also that PHYs
> connected to PM aware drivers may_suspend.

I agree for the first part which is why I was suggesting it, we are
sure we will return early because of the if (!netdev) branch.

>
> I tried it and it will also suspend the PHY taken by mv643xx_eth.
>
> But actually, as phy_suspend/resume check for phydrv->suspend
> themselves, we can just call it on !phydev->attached_dev and remove
> the additional checks.

Sure, sounds good.
-- 
Florian
