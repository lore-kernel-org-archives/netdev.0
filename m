From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Fri, 22 Apr 2016 14:45:01 -0500
Message-ID: <571A7F3D.1070609@codeaurora.org>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
 <570EC541.6080603@gmail.com> <570FFB6B.5060305@codeaurora.org>
 <57100962.40404@gmail.com> <571915F5.5070504@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Greg Kroah-Hartman <greg@kroah.com>, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org,
	Rob Herring <robh+dt@kernel.org>, andrew@lunn.ch,
	bjorn.andersson@linaro.org, Mark Langsdorf <mlangsdo@redhat.com>,
	Jon Masters <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <571915F5.5070504@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Timur Tabi wrote:
>>
>
> So I've done some more research, and I believe that the internal phy is
> not a candidate for phylib, but the external phy (which is a real phy)
> might be.  There's no MDIO bus to the internal phy.
>
> Does this mean that I will need to enable a PHY driver, and that driver
> will control the external phy?  If so, then does that mean that I would
> delete all to code in my driver that calls emac_phy_read() and
> emac_phy_write()?  For example, I wouldn't need emac_phy_link_check()
> any more?

So I think I have it partially working, but I'm not sure if I'm doing 
things correctly, and I'd like some help.

The external phy is an Atheros 8031, so I load the at803x driver.  I 
added this code to my driver:

	mii_bus = devm_mdiobus_alloc(&pdev->dev);
	mii_bus->phy_mask = ~(1 << adpt->hw.phy_addr);
	mii_bus->read = emac_mdio_read;
	mii_bus->write = emac_mdio_write;
	mii_bus->reset = emac_mdio_reset;
	mii_bus->parent = &pdev->dev;
	mii_bus->priv = hw;

	mdiobus_register(mii_bus);

When I call mdiobus_register, I can see that the at803x_probe() probe 
function is called, so a connection is made.

The problem is that after that point, it appears that the at803x driver 
is never called again.  I tried bring the interface up and down, and 
connecting and disconnecting an Ethernet cable, but that didn't trigger 
anything.  I would expect the PHY driver to do more than just probe.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
