From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: Re: [PATCH net-next v9 1/1] net: phy: Cleanup the Edge-Rate feature
 in Microsemi PHYs.
Date: Sun, 9 Oct 2016 21:45:35 +0200
Message-ID: <20161009194534.GA20767@microsemi.com>
References: <1475828904-13839-1-git-send-email-allan.nielsen@microsemi.com>
 <1475828904-13839-2-git-send-email-allan.nielsen@microsemi.com>
 <20161007202225.GC8266@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: <netdev@vger.kernel.org>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0082.outbound.protection.outlook.com ([104.47.36.82]:43502
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750862AbcJIWS7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Oct 2016 18:18:59 -0400
Content-Disposition: inline
In-Reply-To: <20161007202225.GC8266@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 07/10/16 22:22, Andrew Lunn wrote:
> Overall, this is much better. I just have a few nitpicks.
It is good to hear that we are getting closer ;-)

> dt-bindings/net/mscc-phy-vsc8531.h is removed by this patch. It would
> be good to also remove the reference.
My bad.

> You don't need edge_slowdown and vddmac in the private structure,
> since they are never used after determining what rate_magic is.
Year... I was actually a bit confused about this... But assumed that you had
some conventions about saving "input" configuration.

Well, clearly not - I will clean this up.

Actually, there is no need to store rate_magic either... It is only used in the
init function. This means that there is no need for private date...

The code could look somthing like this (it is not tested, so just look at see if
you like the idea):

#ifdef CONFIG_OF_MDIO
static int vsc85xx_edge_rate_magic_get(struct phy_device *phydev)
{
	int rc;
	u8 sd;
	u16 vdd;
	struct device *dev = &phydev->mdio.dev;
	struct device_node *of_node = dev->of_node;
	u8 sd_array_size = ARRAY_SIZE(edge_table[0].slowdown);

	if (!of_node)
		return -ENODEV;

	rc = of_property_read_u16(of_node, "vsc8531,vddmac", &vdd);
	if (rc != 0)
		vdd = MSCC_VDDMAC_3300;

	rc = of_property_read_u8(of_node, "vsc8531,edge-slowdown", &sd);
	if (rc != 0)
		sd = 0;

	for (vdd = 0; vdd < ARRAY_SIZE(edge_table); vdd++)
		if (edge_table[vdd].vddmac == vddmac)
			for (sd = 0; sd < sd_array_size; sd++)
				if (edge_table[vdd].slowdown[sd] == slowdown)
					return (sd_array_size - sd - 1);

	return -EINVAL;
}
#else
static int vsc85xx_edge_rate_magic_get(struct phy_device *phydev)
{
	return 0;
}
#endif /* CONFIG_OF_MDIO */


static int vsc85xx_config_init(struct phy_device *phydev)
{
	int rc, rate_magic;
...
	rate_magic = vsc85xx_edge_rate_magic_get(phydev);
	if (rate_magic < 0)
		return rate_magic;

	rc = vsc85xx_edge_rate_cntl_set(phydev, rate_magic);
	if (rc)
		return rc;
...
}

This is clearly how I would prefere it, as it would simplify the implementation.

It should be no problem to have this tested, and have a new patch avialable
tomorrow.

/Allan
