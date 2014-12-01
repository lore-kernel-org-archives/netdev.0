From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next] net: bcmgenet: enable driver to work without a
 device tree
Date: Mon, 1 Dec 2014 13:13:22 -0800
Message-ID: <CAGXr9JGgPD_LTCqbdNBgZi+pGboadRX0A3ZbdmAxp3rNBb12ww@mail.gmail.com>
References: <20141010183501.0189F1008A3@puck.mtv.corp.google.com>
	<54382CA0.6040105@gmail.com>
	<CAGXr9JH2w1xoUwzzfdC4gi99iu3Eo4zkyWCsZi1b_x_gm+OKqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f171.google.com ([209.85.220.171]:44598 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932513AbaLAVNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 16:13:23 -0500
Received: by mail-vc0-f171.google.com with SMTP id hy4so5062415vcb.16
        for <netdev@vger.kernel.org>; Mon, 01 Dec 2014 13:13:22 -0800 (PST)
In-Reply-To: <CAGXr9JH2w1xoUwzzfdC4gi99iu3Eo4zkyWCsZi1b_x_gm+OKqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Getting back to this (finally). I have made changes per your comments.
Sending a new patch shortly.

-- Petri

On Fri, Oct 10, 2014 at 12:46 PM, Petri Gynther <pgynther@google.com> wrote:
> Hi Florian,
>
> On Fri, Oct 10, 2014 at 11:59 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> On 10/10/2014 11:35 AM, Petri Gynther wrote:
>>> Broadcom 7xxx MIPS-based STB platforms do not use device trees.
>>> Modify bcmgenet driver so that it can be used on those platforms.
>>>
>>> Signed-off-by: Petri Gynther <pgynther@google.com>
>>> ---
>>
>> [snip]
>>
>>> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
>>> index dbf524e..5191e3f 100644
>>> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
>>> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
>>> @@ -17,6 +17,17 @@
>>>  #include <linux/if_vlan.h>
>>>  #include <linux/phy.h>
>>>
>>> +struct bcmgenet_platform_data {
>>> +     void __iomem    *base_reg;
>>> +     int             irq0;
>>> +     int             irq1;
>>
>> Why would these members here? The platform device should provide those
>> as standard resources that the driver fetches using
>> platform_get_resource() and platform_get_irq().
>>
>
> I modeled this on struct bcmemac_platform_data that was used in the
> legacy BRCMSTB code.
> include/linux/brcmstb/brcmstb.h:
>
> struct bcmemac_platform_data {
>         /* used by the BSP code only */
>         uintptr_t               base_reg;
>         int                     irq0;
>         int                     irq1;
>
>         int                     phy_type;
>         int                     phy_id;
>         int                     phy_speed;
>         u8                      macaddr[ETH_ALEN];
> };
>
> The legacy BRCMSTB code stores all relevant GENET info in this struct
> and then creates the resources from that info:
>
> static void __init brcm_register_genet(int id, struct bcmemac_platform_data *pd)
> {
>         struct resource res[3];
>         struct platform_device *pdev;
>
>         memset(&res, 0, sizeof(res));
>         res[0].start = BPHYSADDR(pd->base_reg);
>         res[0].end = BPHYSADDR(pd->base_reg + 0x4fff);
>         res[0].flags = IORESOURCE_MEM;
>
>         res[1].start = res[1].end = pd->irq0;
>         res[1].flags = IORESOURCE_IRQ;
>
>         res[2].start = res[2].end = pd->irq1;
>         res[2].flags = IORESOURCE_IRQ;
>
>         brcm_alloc_macaddr(pd->macaddr);
>
>         pdev = platform_device_alloc("bcmgenet", id);
>         platform_device_add_resources(pdev, res, 3);
>         platform_device_add_data(pdev, pd, sizeof(*pd));
>         platform_device_add(pdev);
> }
>
>>> +     int             phy_type;
>>> +     int             phy_addr;
>>> +     int             phy_speed;
>>> +     u8              macaddr[ETH_ALEN];
>>> +     int             genet_version;
>>> +};
>>
>> I would rather we put this in include/linux/platform_data/bcmgenet.h
>> where it belongs.
>>
>
> I wasn't aware of the directory include/linux/platform_data/. Yes,
> that's where this belongs.
>
>>> +
>>>  /* total number of Buffer Descriptors, same for Rx/Tx */
>>>  #define TOTAL_DESC                           256
>>>
>>> diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
>>> index 9ff799a..e5ff913 100644
>>> --- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
>>> +++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
>>> @@ -157,6 +157,21 @@ static void bcmgenet_mii_setup(struct net_device *dev)
>>>       phy_print_status(phydev);
>>>  }
>>>
>>> +static int bcmgenet_moca_fphy_update(struct net_device *dev,
>>> +                                  struct fixed_phy_status *status)
>>> +{
>>> +     struct bcmgenet_priv *priv = netdev_priv(dev);
>>> +     struct phy_device *phydev = priv->phydev;
>>> +
>>> +     /*
>>> +      * MoCA daemon updates phydev->autoneg to reflect the link status.
>>> +      * Update MoCA fixed PHY status accordingly, so that the PHY state
>>> +      * machine becomes aware of the real link status.
>>> +      */
>>> +     status->link = phydev->autoneg;
>>> +     return 0;
>>> +}
>>
>> I don't want to see that in the upstream driver, please enable the link
>> interrupts like I suggested before and do not use the autoneg field at
>> all, which should require no MoCA daemon modifications.
>>
>
> I added debug printk's to bcmgenet_isr0 to check on UMAC_IRQ_LINK_UP
> and UMAC_IRQ_LINK_DOWN.
> I am not getting those interrupts on eth1 (MoCA) port when coax is
> removed/inserted.
> But, they do work on eth0.
>
> I'll modify init_umac() to enable those interrupts for MoCA port and retest.
>
>> [snip]
>>
>>>
>>>       priv->phydev = phydev;
>>> @@ -437,6 +464,104 @@ static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
>>>       return 0;
>>>  }
>>>
>>> +static int bcmgenet_mii_pd_init(struct bcmgenet_priv *priv)
>>> +{
>>> +     struct device *kdev = &priv->pdev->dev;
>>> +     struct bcmgenet_platform_data *pd = kdev->platform_data;
>>> +     struct mii_bus *mdio = priv->mii_bus;
>>> +     int phy_addr = pd->phy_addr;
>>> +     struct phy_device *phydev;
>>> +     int ret;
>>> +     int i;
>>> +
>>> +     /* Disable automatic MDIO bus scan */
>>> +     mdio->phy_mask = ~0;
>>> +
>>> +     /* Clear all the IRQ properties */
>>> +     if (mdio->irq)
>>> +             for (i = 0; i < PHY_MAX_ADDR; i++)
>>> +                     mdio->irq[i] = PHY_POLL;
>>> +
>>> +     /* Register the MDIO bus */
>>> +     ret = mdiobus_register(mdio);
>>> +     if (ret) {
>>> +             dev_err(kdev, "failed to register MDIO bus\n");
>>> +             return ret;
>>> +     }
>>> +
>>> +     /*
>>> +      * bcmgenet_platform_data needs to pass a valid PHY address for
>>> +      * internal/external PHY or -1 for MoCA PHY.
>>> +      */
>>> +     if (phy_addr >= 0 && phy_addr < PHY_MAX_ADDR) {
>>
>> We do too much low-level PHY device handling, and since you already have
>> the phy_type provided via platform_data, we can use that hint to do the
>> following:
>>
>> 1) an internal or external PHY with MDIO accesses should leave the bus
>> auto-probing on with the specified PHY address in the mdio bus phy_mask
>>
>> 2) a MoCA PHY or an external PHY with MDIO accesses disabled should use
>> the fixed-0 MII bus instead.
>>
>> This would look like this:
>>
>> if (pd->phy_type != PHY_INTERFACE_MODE_MOCA || pd->mdio_enabled)
>>         mdio->phy_mask = ~(1 << pd->phy_addr);
>>
>>         ...
>>         mdiobus_register()
>>
>>         priv->phydev = mdio->bus->phy_map[pd->phy_addr];
>>
>>         phydev->phy_flags |= mask;
>>
>> if (pd->phy_type == PHY_INTERFACE_MODE_MOCA || !pd->mdio_enabled)
>>         priv->phydev = fixed_phy_register(...);
>>
>> and in both cases, later on you do connect to the PHY device
>>
>> I can cook a patch to illustrate what I think this could look like since
>> I realize using pseudo-code to explain might not be the best thing.
>>
>
> I think I understand what you mean. I'll make a change.
>
>>> +             /*
>>> +              * 10/100/1000 Ethernet port with external or internal PHY.
>>> +              */
>>> +             phydev = get_phy_device(mdio, phy_addr, false);
>>> +             if (!phydev || IS_ERR(phydev)) {
>>> +                     dev_err(kdev, "failed to create PHY device\n");
>>> +                     mdiobus_unregister(mdio);
>>> +                     return 1;
>>> +             }
>>> +
>>> +             phydev->irq = PHY_POLL;
>>> +
>>> +             ret = phy_device_register(phydev);
>>> +             if (ret) {
>>> +                     dev_err(kdev, "failed to register PHY device\n");
>>> +                     phy_device_free(phydev);
>>> +                     mdiobus_unregister(mdio);
>>> +                     return 1;
>>> +             }
>>> +
>>> +             priv->phydev = phydev;
>>> +             priv->phy_interface = pd->phy_type;
>>> +     } else {
>>> +             /*
>>> +              * MoCA port with no MDIO-accessible PHY.
>>> +              * We need to use 1000/HD fixed PHY to represent the link layer.
>>> +              * MoCA daemon interacts with this PHY via ethtool.
>>> +              */
>>> +             struct fixed_phy_status moca_fphy_status = {
>>> +                     .link = 0,
>>> +                     .duplex = 0,
>>
>> This should be DUPLEX_FULL here, the link between GENET and the MoCA
>> Ethernet convergence layer is full-duplex by nature (despite we report
>> the PHY being half-duplex, which is a mistake in the downstream driver),
>> the MoCA medium on the coaxial cable is half-duplex though, but that is
>> handled by the MoCA HW.
>>
>> NB: I had issues in the past using a half-duplex link with the MoCA
>> ethernet convergence layer, causing various types of packet loss because
>> we use a simplified signaling internally in the hardware.
>>
>
> I picked this setting from 3.3 GENET driver. I'll test 1000/FULL on my
> platform to see if it works.
>
>>> +                     .speed = 1000,
>>> +                     .pause = 0,
>>> +                     .asym_pause = 0,
>>> +             };
>>> +
>>> +             phydev = fixed_phy_register(PHY_POLL, &moca_fphy_status, NULL);
>>> +             if (!phydev || IS_ERR(phydev)) {
>>> +                     dev_err(kdev, "failed to register fixed PHY device\n");
>>> +                     mdiobus_unregister(mdio);
>>> +                     return 1;
>>> +             }
>>> +
>>> +             phydev->autoneg = AUTONEG_DISABLE;
>>> +
>>> +             ret = fixed_phy_set_link_update(phydev,
>>> +                                             bcmgenet_moca_fphy_update);
>>> +             if (ret) {
>>> +                     dev_err(kdev, "failed to set fixed PHY link update\n");
>>> +             }
>>
>> Should not we propagate this error to the caller?
>
> Good catch. Yes.
>
>> --
>> Florian
