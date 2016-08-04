From: Appana Durga Kedareswara Rao <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: RE: [RFC PATCH v2 1/4] Documentation: DT: net: Add Xilinx
 gmiitorgmii converter device tree binding documentation
Date: Thu, 4 Aug 2016 10:34:30 +0000
Message-ID: <C246CAC1457055469EF09E3A7AC4E11A4A5DCC2F@XAP-PVEXMBX01.xlnx.xilinx.com>
References: <1467623084-15471-1-git-send-email-appanad@xilinx.com>
 <1467623084-15471-2-git-send-email-appanad@xilinx.com>
 <20160704140458.GC3282@lunn.ch>
 <03CA77BA8AF6F1469AEDFBDA1322A7B74A193913@XAP-PVEXMBX02.xlnx.xilinx.com>
 <20160706142121.GI19800@lunn.ch>
 <03CA77BA8AF6F1469AEDFBDA1322A7B74A19393B@XAP-PVEXMBX02.xlnx.xilinx.com>
 <C246CAC1457055469EF09E3A7AC4E11A4A5C2387@XAP-PVEXMBX01.xlnx.xilinx.com>
 <20160727080526.GH11538@lunn.ch>
 <971c966a-5335-310b-0a1a-3f1b7ee2f841@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Michal Simek <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	Soren Brinkmann <sorenb-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org" <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Punnaiah Choudary Kalluri <punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <971c966a-5335-310b-0a1a-3f1b7ee2f841-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Florian,

> 
> On 27/07/2016 01:05, Andrew Lunn wrote:
> > Hi Appana
> >
> > Here is roughly what i was thinking:
> >
> > struct priv {
> >        phy_device *master;
> >        phy_device *slave;
> >        struct phy_driver *slave_drv;
> > };
> >
> > phy_status_clone(phy_device *master, phy_device *slave) {
> > 	master->speed = slave->speed;
> > 	master->duplex = slave->duplex;
> > 	master->pause = slave->pause;
> > }
> >
> > read_status(struct phy_device *phydev) {
> > 	struct priv *priv = phydev->priv;
> >
> > 	/* Get the status from the slave, and duplicate in into the
> > 	 * master */
> > 	 slave_drv->read_status(priv->slave);
> > 	 phy_status_clone(priv->master, priv->slave);
> >
> > 	 /* Update the gmiitorgmii with the current link parameters */
> > 	 update_link(master);
> > }
> >
> > config_init(struct phy_device *phydev) {
> > 	struct priv *priv = phydev->priv;
> >
> > 	/* Configure the slave, and duplicate in into the master */
> > 	slave_drv->config_init(priv->slave);
> > 	phy_status_clone(priv->master, priv->slave); }
> >
> > struct phy_driver master_drv = {
> >        .read_status = read_status,
> >        .config_init = config_init,
> >        .soft_reset  = ...
> >        .suspend = ...
> > };
> >
> > probe(mdio_device *mdio)
> > {
> > 	struct priv *priv = devm_alloc();
> >
> > 	/* Use the phy-handle property to find the slave phy */
> > 	node_phy = of_parse_phandle(mdio->of_node, "phy", 0);
> > 	priv->slave = of_phy_find_device(node_phy);
> >
> > 	/* Create the master phy on the control address. Use the phy
> > 	   ID from the slave. */
> > 	priv->master = phy_device_create(mdio->bus, mdio->addr,
> > 	  				 phy->slave->phy_id,
> > 					 phy->slave->is_c45,
> > 					 phy->slave->c45_ids);
> >
> > 	slave_dev_drv = phydev->mdio.dev.driver;
> > 	priv->slave_drv = to_phy_driver(slave_dev_drv);
> > 	priv->master->mdio.dev.driver = master_drv;
> 
> The key here is really that except for the phy_driver::read_status callback, we
> want to defer every operation to the slave (full MDIO register range compatible)
> PHY.

Will fix it in the next version...

> 
> > }
> >
> > It would however be nice to only have one phydev structure, so you are
> > not copying status and settings backwards and forwards from one to the
> > other all the time, and need a wrapper for every function in
> > phy_driver. Studying the structures a bit, that might be possible. You
> > would then only need to wrap the read_status(), so that when the link
> > speed/duplex changes, you can configure the converter as appropriate.
> 
> Agreed.

Will implement as suggested by Andrew...

Regards,
Kedar.

> --
> Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
