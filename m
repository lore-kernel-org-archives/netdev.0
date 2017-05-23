From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] net: phy: Update get_phy_c45_ids for Cortina PHYs
Date: Tue, 23 May 2017 11:12:01 -0700
Message-ID: <8768d0f5-6226-b3e0-b741-f742ff5ffee3@gmail.com>
References: <1495554799-23060-1-git-send-email-bogdan.purcareata@nxp.com>
 <1495554799-23060-2-git-send-email-bogdan.purcareata@nxp.com>
 <20170523160353.GB21169@lunn.ch>
 <DB5PR04MB1240098B96F6EEF3730DF054EAF90@DB5PR04MB1240.eurprd04.prod.outlook.com>
 <20170523165554.GB24029@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Bogdan Purcareata <bogdan.purcareata@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170523165554.GB24029@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/23/2017 09:55 AM, Andrew Lunn wrote:
>> The patches mentioned in the commit message add _some_ support for
>> the Cortina PHYs - mainly checking for devices at additional
>> locations. Once they are found, the phy IDs must be read from custom
>> locations.
>  
> As a general principle, we don't add hacks in generic code to handle
> broken devices. We add generic mechanisms to work around the
> brokenness.
> 
> In this case, by using ethernet-phy-id in the device tree, we are
> saying, this PHYs probing is totally borked, but we know it is there,
> at this address. Just load the driver.
> 
> Please try to make ethernet-phy-id work.

What Andrew is suggesting is to leverage the code in
drivers/of/of_mdio.c which does the following:

       is_c45 = of_device_is_compatible(child,
                                         "ethernet-phy-ieee802.3-c45");

        if (!is_c45 && !of_get_phy_id(child, &phy_id))
                phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
        else
                phy = get_phy_device(mdio, addr, is_c45);
        if (IS_ERR(phy))
                return;

If you know the PHY ID, and you did put it in the PHY node's compatible
string (in the format that of_get_phy_id() expects it to, and you also
did not add "ethernet-phy-ieee802.3-c45") then the PHY library will
directly create the PHY device, with the designated ID, at the specific
address.

While this works for clause 22 PHYs, I don't know if it also does for
clause 45 PHYs, but as Andrew is suggesting, I would be more inclined
into making this scheme work for all types (22 or 45) PHYs, rather than
hacking the core code that tries to identify devices in packages.

Can you give it a spin?
-- 
Florian
