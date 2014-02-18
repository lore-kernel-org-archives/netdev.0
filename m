From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH] sh_eth: call of_mdiobus_register() to register phys
Date: Tue, 18 Feb 2014 16:00:59 +0000
Message-ID: <530383BB.60102@codethink.co.uk>
References: <1392650895-1422-1-git-send-email-ben.dooks@codethink.co.uk> <53023B60.4030201@cogentembedded.com> <53022EE4.50607@codethink.co.uk> <53038C6A.1000600@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, horms+renesas@verge.net.au,
	linux-sh@vger.kernel.org, magnus@opensource.se,
	linux-kernel@lists.codethink.co.uk
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <53038C6A.1000600@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/02/14 16:38, Sergei Shtylyov wrote:
> Hello.
>
> On 02/17/2014 06:46 PM, Ben Dooks wrote:
>
>>>> If the sh_eth device is registered using OF, then the driver
>
>>>     Which is not supported yet as my DT patch hasn't been merged.
>>> This patch seems somewhat premature.
>
>> I've got your OF patches in my local tree to test with, this
>> is what I found during that testing.
>
>     The issue is that I didn't post my v3 patch to netdev due to
> net-next.git repo being closed at this moment and DaveM not wanting to
> see any patch targeted to it during this time. I've now posted v4 of my
> Ether DT patch to netdev.

Ok, I will look for these tomorrow.

>>>> should call of_mdiobus_register() to register any PHYs connected
>>>> to the system.
>
>>>     That's not necessary (but good to have).
>
>> Well, it is necessary if you then want any PHYS bound to
>> the device to have their OF information to hand,
>
>     Ether DT support worked for me without this fragment, at least.

Yes, it just that the PHY is not being linked to the relevant
OF node. The PHY gets bound, it will not be able to find the
DT info passed.

>>>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
>>>> ---
>>>>   drivers/net/ethernet/renesas/sh_eth.c | 13 +++++++++++++
>>>>   1 file changed, 13 insertions(+)
>
>>>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c
>>>> b/drivers/net/ethernet/renesas/sh_eth.c
>>>> index 06970ac..165f0c4 100644
>>>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>>>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
>>> [...]
>>>> @@ -2629,6 +2630,18 @@ static int sh_mdio_init(struct net_device
>>>> *ndev, int id,
>>>>       snprintf(mdp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
>>>>            mdp->pdev->name, id);
>>>>
>>>> +    if (ndev->dev.parent->of_node) {
>>>> +        dev_set_drvdata(&ndev->dev, mdp->mii_bus);
>>>> +        ret = of_mdiobus_register(mdp->mii_bus,
>>>> +                      ndev->dev.parent->of_node);
>>>> +        if (ret != 0) {
>>>> +            dev_err(&ndev->dev, "of_mdiobus_register() failed\n");
>>>> +            goto out_free_bus;
>>>> +        }
>
>> I should probably only set the drvdata if the
>> of_mdiobus_register() succeeds.
>
>     Yes. Probably should use *goto* as well since in that case the
> success path would be the same as the existing one.

I will look into that, not the biggest fan of gotos for
success cases.

>>>> +        return 0;
>>>> +    }
>>>> +
>>>>       /* PHY IRQ */
>>>>       mdp->mii_bus->irq = devm_kzalloc(&ndev->dev,
>>>>                        sizeof(int) * PHY_MAX_ADDR,
>
>>>      Hm, I can only hope this works with PHY IRQ in DT mode.
>>> Would you mind if I include your patch into my Ether DT patch?
>
>> You are welcome to include it in your series, but I would like
>> to keep the credit for finding this.
>
>     OK.
>
>> Also, FYI, for some reason the probe is not finding the correct
>> IRQ for this. I will have a look later when I get the board back
>> as to why this is:
>
>> net eth0: attached PHY 1 (IRQ -1) to driver Micrel KSZ8041RNLI
>
>     Thanks for quickly fixing this. I've yet to study of_mdio.c code...
>
> WBR, Sergei

No problem,


-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
