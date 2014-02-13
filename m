From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 07/10] net: bcmgenet: add MDIO routines
Date: Thu, 13 Feb 2014 09:00:41 -0800
Message-ID: <CAGVrzcba6dfpJUkzVvj2VQGxVgs+CyVkJOmqQNTE902BdU5dww@mail.gmail.com>
References: <1392269395-23513-1-git-send-email-f.fainelli@gmail.com>
 <1392269395-23513-8-git-send-email-f.fainelli@gmail.com> <20140213115008.GB5871@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"cernekee@gmail.com" <cernekee@gmail.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:58344 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbaBMRBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 12:01:21 -0500
In-Reply-To: <20140213115008.GB5871@e106331-lin.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mark,

2014-02-13 3:50 GMT-08:00 Mark Rutland <mark.rutland@arm.com>:
> On Thu, Feb 13, 2014 at 05:29:52AM +0000, Florian Fainelli wrote:
>> This patch adds support for configuring the port multiplexer hardware
>> which resides in front of the GENET Ethernet MAC controller. This allows
>> us to support:
>>
>> - internal PHYs (using drivers/net/phy/bcm7xxx.c)
>> - MoCA PHYs which are an entirely separate hardware block not covered
>>   here
>> - external PHYs and switches
>>
>> Note that MoCA and switches are currently supported using the emulated
>> "fixed PHY" driver.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>> Changes since v1:
>> - fixed MDIO crash/warning when Device Tree probing fails
>> - removed the use of priv->phy_type and use priv->phy_interface
>>   directly
>>
>>  drivers/net/ethernet/broadcom/genet/bcmmii.c | 481 +++++++++++++++++++++++++++
>>  1 file changed, 481 insertions(+)
>>  create mode 100644 drivers/net/ethernet/broadcom/genet/bcmmii.c
>
> [...]
>
>> +static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
>> +{
>> +       struct device_node *dn = priv->pdev->dev.of_node;
>> +       struct device *kdev = &priv->pdev->dev;
>> +       struct device_node *mdio_dn;
>> +       const __be32 *fixed_link;
>
> This looks a bit odd. Could we not have a common parser for fixed-link
> properties?

Do you remember the fixed-link revamp that Thomas Petazzoni submitted
a while ago? I was planning on using it, but there were still some
disagreements on how to do it, so I ended up using the good old
"fixed-link" property as-is.

>
>> +       u32 propval;
>> +       int ret, sz;
>> +
>> +       mdio_dn = of_get_next_child(dn, NULL);
>> +       if (!mdio_dn) {
>> +               dev_err(kdev, "unable to find MDIO bus node\n");
>> +               return -ENODEV;
>> +       }
>
> Could you please check that this is the node you expect (by looking at
> the compatible string list).

Makes sense.

>
>> +
>> +       ret = of_mdiobus_register(priv->mii_bus, mdio_dn);
>> +       if (ret) {
>> +               dev_err(kdev, "failed to register MDIO bus\n");
>> +               return ret;
>> +       }
>> +
>> +       /* Check if we have an internal or external PHY */
>> +       priv->phy_dn = of_parse_phandle(dn, "phy-handle", 0);
>> +       if (priv->phy_dn) {
>> +               if (!of_property_read_u32(priv->phy_dn, "max-speed", &propval))
>> +                       priv->phy_speed = propval;
>
> Is there no way to find this out without reading values directly off of
> the PHY? It seems like something we should have an abstraction for.

In fact, this is a remnant from when I did not submit the patch doing
this in of_mdiobus_register(), so this is now useless.

>
>> +       } else {
>> +               /* Read the link speed from the fixed-link property */
>> +               fixed_link = of_get_property(dn, "fixed-link", &sz);
>> +               if (!fixed_link || sz < sizeof(*fixed_link)) {
>> +                       ret = -ENODEV;
>> +                       goto out;
>> +               }
>> +
>> +               priv->phy_speed = be32_to_cpu(fixed_link[2]);
>
> Similarly can we not have a common fixed-link parser? Or abstraction
> such that you query the phy regardless of what it is and how its binding
> represents this?

I do not think I need this line anymore. I will do some more testing
and will remove this parsing. I do agree that we need a common
fixed-link parser, but that is part of the discussion initiated by
Thomas Petazzoni.

Thanks for the review!
-- 
Florian
