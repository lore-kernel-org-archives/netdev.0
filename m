From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH V10 2/7] net: sxgbe: add basic framework for Samsung 10Gb
 ethernet driver
Date: Sat, 22 Mar 2014 13:56:50 -0700
Message-ID: <008601cf4611$4172e1b0$c458a510$@samsung.com>
References: <005b01cf4530$56a1ba20$03e52e60$@samsung.com>
 <20140321235526.GA7727@electric-eye.fr.zoreil.com>
 <007a01cf4586$58a02c20$09e08460$@samsung.com>
 <20140322102907.GA12121@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org, 'David Miller' <davem@davemloft.net>,
	'GIRISH K S' <ks.giri@samsung.com>,
	'SIVAREDDY KALLAM' <siva.kallam@samsung.com>,
	'Vipul Chandrakant' <vipul.pandya@samsung.com>,
	'Ilho Lee' <ilho215.lee@samsung.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-reply-to: <20140322102907.GA12121@electric-eye.fr.zoreil.com>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Francois Romieu <romieu@fr.zoreil.com> wrote:
> Byungho An <bh74.an@samsung.com> :
> [...]
> > > Nit: you may consider reorganizing the variables in an inverted xmas
> > > tree fashion at some point.
> > Does it look better? No problem.
> 
> Marginally if not more. Consider it a guideline to avoid unusual or ugly
layout.
OK. I'll consider it.

> 
> [...]
> > > > +		       priv->ioaddr + SXGBE_MDIO_CLAUSE22_PORT_REG);
> > > > +		/* set mdio address register */
> > > > +		reg_val = (phyaddr << 16) | (phyreg & 0x1F);
> > > > +		writel(reg_val, priv->ioaddr + mii_addr);
> > > > +
> > > > +		/* set mdio control/data register */
> > > > +		reg_val = ((SXGBE_SMA_READ_CMD << 16) |
> > > SXGBE_SMA_SKIP_ADDRFRM |
> > > > +			   ((priv->clk_csr & 0x7) << 19) |
SXGBE_MII_BUSY);
> > > > +		writel(reg_val, priv->ioaddr + mii_data);
> > > > +	}
> > >
> > > The whole 'if (phyreg & MII_ADDR_C45) { ... } else { ... }' chunk is
> > > shared
> > with
> > > sxgbe_mdio_write(..., phydata = 0). Factor out ?
> > Not exactly same.
> 
> Almost :o)
> 
> static void sxgbe_mdio_ctrl_data(struct spgbe_priv_data *sp, u32 cmd,
> 				 u16 phydata)
> {
> 	u32 reg = phydata;
> 
> 	reg |= (cmd << 16) | SXGBE_SMA_SKIP_ADDRFRM |
> 	       ((sp->clk_csr & 0x7) << 19) | SXGBE_MII_BUSY;
> 	writel(reg, sp->ioaddr + sp->hw->mii.data); }
> 
> static void sxgbe_mdio_c45(struct spgbe_priv_data *sp, u32 cmd, int phyaddr,
> 			   int phyreg, u16 phydata)
> {
> 	u32 reg;
> 
> 	/* set mdio address register */
> 	reg = ((phyreg >> 16) & 0x1f) << 21;
> 	reg |= (phyaddr << 16) | (phyreg & 0xffff);
> 	writel(reg, sp->ioaddr + sp->hw->mii.addr);
> 
> 	sxgbe_mdio_ctrl_data(sp, cmd, phydata); }
> 
> static int sxgbe_mdio_c22(struct spgbe_priv_data *sp, u32 cmd, int phyaddr,
> 			  int phyreg, u16 phydata)
> {
> 	u32 reg
> 
> 	writel(1 << phyaddr, ioaddr + SXGBE_MDIO_CLAUSE22_PORT_REG);
> 
> 	/* set mdio address register */
> 	reg = (phyaddr << 16) | (phyreg & 0x1f);
> 	writel(reg, sp->ioaddr + sp->hw->mii.addr);
> 
> 	sxgbe_mdio_ctrl_data(sp, cmd, phydata); }
> 
> static int spgbe_mdio_access(struct spgbe_priv_data *sp, u32 cmd, int
phyaddr,
> 			     int phyreg, u16 phydata)
> {
> 	const struct mii_regs *mii = &sp->hw->mii;
> 	int rc;
> 
> 	rc = spgbe_mdio_busy_wait(sp->ioaddr, mii->data);
> 	if (rc < 0)
> 		return rc;
> 
> 	if (phyreg & MII_ADDR_C45) {
> 		spgbe_mdio_c45(sp, cmd, phyaddr, phyreg, phydata);
> 	} else {
> 		 /* Ports 0-3 only support C22. */
> 		if (phyaddr >= 4)
> 			return -ENODEV;
> 
> 		spgbe_mdio_c22(sp, cmd, phyaddr, phyreg, phydata);
> 	}
> 
> 	return spgbe_mdio_busy_wait(sp->ioaddr, mii->data); }
> 
> static int sxgbe_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg) {
> 	struct net_device *ndev = bus->priv;
> 	struct sxgbe_priv_data *priv = netdev_priv(ndev);
> 	int rc;
> 
> 	rc = sxgbe_mdio_access(priv, SXGBE_SMA_READ_CMD, phyaddr,
> phyreg, 0);
> 	if (rc < 0)
> 		return rc;
> 
> 	return readl(priv->ioaddr + priv->hw->mii.data) & 0xffff; }
> 
> static int sxgbe_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
> 			    u16 phydata)
> {
> 	struct net_device *ndev = bus->priv;
> 	struct sxgbe_priv_data *priv = netdev_priv(ndev);
> 
> 	return sxgbe_mdio_access(priv, SXGBE_SMA_WRITE_CMD, phyaddr,
> phyreg,
> 				 phydata);
> }
> 
> It fixes an unchecked sxgbe_mdio_busy_wait in sxgbe_mdio_write btw.
> 
> sxgbe_mdio_read and sxgbe_mdio_write are mostly the same. Their core is
> imho worth sharing. You're of course free to rewrite or used the code above
as
> fits your needs.
OK.

> 
> sxgbe_priv_data should probably be sxgbe_priv, sxgbe or sx. It's everywhere
> and it's a first class type in the code. It's exceedingly litterate whereas
common
> drivers choose to be more lean.
OK.

> 
> --
> Ueimor
