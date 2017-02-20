From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v1 2/2] net: emac: add support for device-tree based PHY
 discovery and setup
Date: Sun, 19 Feb 2017 21:13:02 -0800
Message-ID: <2109609d-c6a7-5c6f-d6aa-657107765778@gmail.com>
References: <8f94c394faf5665ae693f41832f2446dfc7c989e.1487539319.git.chunkeey@googlemail.com>
 <bb3937e10a1dcba640c5cddbf03c0dcdeb15b50b.1487539319.git.chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>, Andrew Lunn <andrew@lunn.ch>,
        Rob Herring <robh+dt@kernel.org>
To: Christian Lamparter <chunkeey@googlemail.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34999 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751015AbdBTFNL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 00:13:11 -0500
In-Reply-To: <bb3937e10a1dcba640c5cddbf03c0dcdeb15b50b.1487539319.git.chunkeey@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/19/2017 01:22 PM, Christian Lamparter wrote:
> This patch adds glue-code that allows the EMAC driver to interface
> with the existing dt-supported PHYs in drivers/net/phy.
> 
> Because currently, the emac driver maintains a small library of
> supported phys for in a private phy.c file located in the drivers
> directory.
> 
> The support is limited to mostly single ethernet transceiver like the:
> CIS8201, BCM5248, ET1011C, Marvell 88E1111 and 88E1112, AR8035.
> 
> However, routers like the Netgear WNDR4700 and Cisco Meraki MX60(W)
> have a 5-port switch (AR8327N) attached to the EMAC. The switch chip
> is supported by the qca8k mdio driver, which uses the generic phy
> library. Another reason is that PHYLIB also supports the BCM54610,
> which was used for the Western Digital My Book Live.
> 
> This will now also make EMAC select PHYLIB.

This looks mostly good, except one thing below:

> 
> Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>
> ---

> +static int emac_dt_phy_connect(struct emac_instance *dev,
> +			       struct device_node *phy_handle)
> +{
> +	u32 phy_flags = 0;
> +	int res;
> +
> +	res = of_property_read_u32(phy_handle, "phy-flags", &phy_flags);
> +	if (res < 0 && res != -EINVAL)
> +		return res;

phy-flags is not documented in the binding document, but looking at how
you pass it down, I don't think you should do this.

> +
> +	dev->phy.def = devm_kzalloc(&dev->ofdev->dev, sizeof(*dev->phy.def),
> +				    GFP_KERNEL);
> +	if (!dev->phy.def)
> +		return -ENOMEM;
> +
> +	dev->phy_dev = of_phy_connect(dev->ndev, phy_handle,
> +				      &emac_adjust_link, phy_flags,
> +				      dev->phy_mode);

phy_flags is meant to allow the MAC driver to pass information down to
the PHY driver, e.g: lane swap needed, a revision that could not be read
by the PHY itself, board-level workarounds etc.

> +	if (!dev->phy_dev) {
> +		dev_err(&dev->ofdev->dev, "failed to connect to PHY.\n");
> +		return -ENODEV;
> +	}
-- 
Florian
