From: Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>
Subject: RE: [RFC PATCH v5 3/3] net: phy: Add gmiitorgmii converter support
Date: Wed, 10 Aug 2016 05:27:45 +0000
Message-ID: <C246CAC1457055469EF09E3A7AC4E11A4A5E0D49@XAP-PVEXMBX01.xlnx.xilinx.com>
References: <1470735283-23611-1-git-send-email-appanad@xilinx.com>
 <1470735283-23611-4-git-send-email-appanad@xilinx.com>
 <8919e4fe-69c5-9b16-cc37-e423b757609c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>, "robh+dt@kernel.org"
 <robh+dt@kernel.org>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "Michal
 Simek" <michals@xilinx.com>, Soren Brinkmann <sorenb@xilinx.com>,
 "andrew@lunn.ch" <andrew@lunn.ch>, Punnaiah Choudary Kalluri
 <punnaia@xilinx.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <8919e4fe-69c5-9b16-cc37-e423b757609c@gmail.com>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Florian,

	Thanks for the review...

> >
> > This converter sits between the MAC and the external phy MAC <==>
> > GMII2RGMII <==> RGMII_PHY
> 
> This looks good, just a few things, see below:

Thanks...

> > +config XILINX_GMII2RGMII
> > +       tristate "Xilinx GMII2RGMII converter driver"
> > +       default y
> 
> Don't force that, or at least make the default based on the potential
> users/drivers here.

Ok sure will fix in the next version...

> 
> > +       ---help---
> > +         This driver support xilinx GMII to RGMII IP core it provides
> > +         the Reduced Gigabit Media Independent Interface(RGMII) between
> > +         Ethernet physical media devices and the Gigabit Ethernet controller.
> > +
> >  endif # PHYLIB

<snip>

> > +#define XILINX_GMII2RGMII_REG		0x10
> > +#define XILINX_GMII2RGMII_SPEED_MASK	0x2040
> 
> BMCR_SPEED1000 | BMCR_SPEED100 would be clearer here.

Sure will fix...

> 
> > +
> > +struct gmii2rgmii {
> > +	struct phy_device *phy_dev;
> > +	struct phy_driver *phy_drv;
> > +	struct phy_driver conv_phy_drv;
> > +	int addr;
> > +};
> > +
> > +static int xgmiitorgmii_read_status(struct phy_device *phydev) {
> > +	struct gmii2rgmii *priv = (struct gmii2rgmii *)phydev->priv;
> 
> Casting is not required here, priv is void *.

Ok will remove...

> 
> > +	u16 val = 0;
> > +
> > +	priv->phy_drv->read_status(phydev);
> > +
> > +	val = mdiobus_read(phydev->mdio.bus, priv->addr,
> XILINX_GMII2RGMII_REG);
> > +	val &= XILINX_GMII2RGMII_SPEED_MASK;
> > +
> > +	switch (phydev->speed) {
> > +	case SPEED_1000:
> > +		val |= BMCR_SPEED1000;
> 
> Is the fall through really intentional here? See genphy_setup_forced() for
> instance.

Ok will fix...

> 
> > +	case SPEED_100:
> > +		val |= BMCR_SPEED100;
> > +	case SPEED_10:
> > +		val |= BMCR_SPEED10;
> > +	}
> > +
> > +	mdiobus_write(phydev->mdio.bus, priv->addr,
> XILINX_GMII2RGMII_REG,
> > +val);
> > +
> > +	return 0;
> > +}
> [snip]
> 
> > +static int __init xgmiitorgmii_init(void) {
> > +	return mdio_driver_register(&xgmiitorgmii_driver);
> > +}
> > +module_init(xgmiitorgmii_init);
> > +
> > +static void __exit xgmiitorgmii_cleanup(void) {
> > +	mdio_driver_unregister(&xgmiitorgmii_driver);
> > +}
> > +module_exit(xgmiitorgmii_cleanup);
> 
> mdio_module_driver() does eliminate a bit of this boilerplate code.

Sure will fix in the next version...

Regards,
Kedar.
> --
> Florian
