From: Andrew Lunn <andrew@lunn.ch>
Subject: DSA: Attaching phy twice?
Date: Sun, 8 Feb 2015 21:32:11 +0100
Message-ID: <20150208203211.GB23581@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39991 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758873AbbBHUer (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Feb 2015 15:34:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian

Have you seen messages like this before?

[    2.495126] Distributed Switch Architecture driver version 0.1
[    2.501358] mvneta f1070000.ethernet eth0: [0]: detected a Marvell 88E6172 switch
[    2.556441] libphy: dsa slave smi: probed
[    2.638292] net lan4: PHY already attached
[    2.733285] net lan3: PHY already attached
[    2.820749] net lan2: PHY already attached
[    2.910749] net lan1: PHY already attached
[    3.000772] net internet: PHY already attached

What appears to be happening is that dsa_slave_phy_setup() is finding
the phy for the port via device tree and using of_phy_connect(), or it
uses the fall back of taking a phy from the switch internal mdio bus
and calling phy_connect_direct(). So if a phy is found,
phy_attach_direct() gets called to attach the phy to the device.

Then in dsa_slave_create(), a second call to phy_attach() is
made. This is when we get the warning "PHY already attached", and it
returns EBUSY, which is ignored.

Is this code at the end of dsa_slave_create() doing anything useful?

	if (p->phy != NULL) {
		if (ds->drv->get_phy_flags)
			p->phy->dev_flags |= ds->drv->get_phy_flags(ds, port);

		phy_attach(slave_dev, dev_name(&p->phy->dev),
			   PHY_INTERFACE_MODE_GMII);

		p->phy->autoneg = AUTONEG_ENABLE;
		p->phy->speed = 0;
		p->phy->duplex = 0;
		p->phy->advertising = p->phy->supported | ADVERTISED_Autoneg;
	}

My quick testing suggests its not useful, so if you agree, i will
submit a patch removing it. Or am i missing something?

Thanks
	Andrew
