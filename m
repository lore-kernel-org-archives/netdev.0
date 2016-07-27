From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH v2 1/4] Documentation: DT: net: Add Xilinx
 gmiitorgmii converter device tree binding documentation
Date: Wed, 27 Jul 2016 10:05:26 +0200
Message-ID: <20160727080526.GH11538@lunn.ch>
References: <1467623084-15471-1-git-send-email-appanad@xilinx.com>
 <1467623084-15471-2-git-send-email-appanad@xilinx.com>
 <20160704140458.GC3282@lunn.ch>
 <03CA77BA8AF6F1469AEDFBDA1322A7B74A193913@XAP-PVEXMBX02.xlnx.xilinx.com>
 <20160706142121.GI19800@lunn.ch>
 <03CA77BA8AF6F1469AEDFBDA1322A7B74A19393B@XAP-PVEXMBX02.xlnx.xilinx.com>
 <C246CAC1457055469EF09E3A7AC4E11A4A5C2387@XAP-PVEXMBX01.xlnx.xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "robh+dt@kernel.org" <robh+dt@kernel.org>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	Michal Simek <michals@xilinx.com>,
	Soren Brinkmann <sorenb@xilinx.com>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>
To: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <C246CAC1457055469EF09E3A7AC4E11A4A5C2387@XAP-PVEXMBX01.xlnx.xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Appana

Here is roughly what i was thinking:

struct priv {
       phy_device *master;
       phy_device *slave;
       struct phy_driver *slave_drv;
};

phy_status_clone(phy_device *master, phy_device *slave)
{
	master->speed = slave->speed;
	master->duplex = slave->duplex;
	master->pause = slave->pause;
}

read_status(struct phy_device *phydev)
{
	struct priv *priv = phydev->priv;

	/* Get the status from the slave, and duplicate in into the
	 * master */
	 slave_drv->read_status(priv->slave);
	 phy_status_clone(priv->master, priv->slave);

	 /* Update the gmiitorgmii with the current link parameters */
	 update_link(master);
}

config_init(struct phy_device *phydev)
{
	struct priv *priv = phydev->priv;

	/* Configure the slave, and duplicate in into the master */
	slave_drv->config_init(priv->slave);
	phy_status_clone(priv->master, priv->slave);
}

struct phy_driver master_drv = {
       .read_status = read_status,
       .config_init = config_init,
       .soft_reset  = ...
       .suspend = ...
};

probe(mdio_device *mdio)
{
	struct priv *priv = devm_alloc();

	/* Use the phy-handle property to find the slave phy */
	node_phy = of_parse_phandle(mdio->of_node, "phy", 0);
	priv->slave = of_phy_find_device(node_phy);

	/* Create the master phy on the control address. Use the phy
	   ID from the slave. */
	priv->master = phy_device_create(mdio->bus, mdio->addr,
	  				 phy->slave->phy_id,
					 phy->slave->is_c45,
					 phy->slave->c45_ids);

	slave_dev_drv = phydev->mdio.dev.driver;
	priv->slave_drv = to_phy_driver(slave_dev_drv);
	priv->master->mdio.dev.driver = master_drv;
}

It would however be nice to only have one phydev structure, so you are
not copying status and settings backwards and forwards from one to the
other all the time, and need a wrapper for every function in
phy_driver. Studying the structures a bit, that might be possible. You
would then only need to wrap the read_status(), so that when the link
speed/duplex changes, you can configure the converter as appropriate.

	     Andrew
