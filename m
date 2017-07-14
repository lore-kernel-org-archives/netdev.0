From: Moritz Fischer <moritz.fischer-+aYTwkv1SeIAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] net: ethernet: nixge: Add support for National
 Instruments XGE netdev
Date: Thu, 13 Jul 2017 17:31:11 -0700
Message-ID: <20170714003111.GA13512@tyrael.ni.corp.natinst.com>
References: <1499980909-11702-1-git-send-email-mdf@kernel.org>
 <1499980909-11702-2-git-send-email-mdf@kernel.org>
 <20170713223636.GF3120@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="ZGiS0Q5IWpPtfppv"
Cc: Moritz Fischer <mdf-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170713223636.GF3120-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

thanks for the quick response.

On Fri, Jul 14, 2017 at 12:36:36AM +0200, Andrew Lunn wrote:
> > +++ b/drivers/net/ethernet/ni/nixge.c
> > @@ -0,0 +1,1246 @@
> > +/*
> > + * Copyright (c) 2016-2017, National Instruments Corp.
> > + *
> > + * Network Driver for Ettus Research XGE MAC
> > + *
> > + * This is largely based on the Xilinx AXI Ethernet Driver,
> > + * and uses the same DMA engine in the FPGA
>=20
> Hi Moritz=20
>=20
> Is the DMA code the same as in the AXI driver? Should it be pulled out
> into a library and shared?

Mostly, I'll see what I can do. At least the register definitions and
common structures can be pulled out into a common header file.

>=20
> > +struct nixge_priv {
> > +	struct net_device *ndev;
> > +	struct device *dev;
> > +
> > +	/* Connection to PHY device */
> > +	struct phy_device *phy_dev;
> > +	phy_interface_t		phy_interface;
>=20
> > +	/* protecting link parameters */
> > +	spinlock_t              lock;
> > +	int link;
> > +	int speed;
> > +	int duplex;
>=20
> All these seem to be pointless. They are set, but never used.

Will fix.
>=20
> > +
> > +static inline void nixge_dma_write_reg(struct nixge_priv *priv, off_t =
offset,
> > +				       u32 val)
>=20
> Please leave it up to the compile to inline.

Will fix.
>=20
> > +static void __nixge_device_reset(struct nixge_priv *priv, off_t offset)
> > +{
> > +	u32 timeout;
> > +	/* Reset Axi DMA. This would reset NIXGE Ethernet core as well.
> > +	 * The reset process of Axi DMA takes a while to complete as all
> > +	 * pending commands/transfers will be flushed or completed during
> > +	 * this reset process.
> > +	 */
> > +	nixge_dma_write_reg(priv, offset, XAXIDMA_CR_RESET_MASK);
> > +	timeout =3D DELAY_OF_ONE_MILLISEC;
> > +	while (nixge_dma_read_reg(priv, offset) & XAXIDMA_CR_RESET_MASK) {
> > +		udelay(1);
>=20
> There is a link between the 1 and the value of DELAY_OF_ONE_MILLISEC.
> It would be good to try to link these two together.

D'oh ... Seems like a good candidate for iopoll ...
>=20
> > +		if (--timeout =3D=3D 0) {
> > +			netdev_err(priv->ndev, "%s: DMA reset timeout!\n",
> > +				   __func__);
> > +			break;
> > +		}
> > +	}
> > +}
> > +
>=20
> > +static void nixge_handle_link_change(struct net_device *ndev)
> > +{
> > +	struct nixge_priv *priv =3D netdev_priv(ndev);
> > +	struct phy_device *phydev =3D ndev->phydev;
> > +	unsigned long flags;
> > +	int status_change =3D 0;
> > +
> > +	spin_lock_irqsave(&priv->lock, flags);
> > +
> > +	if (phydev->link !=3D priv->link) {
> > +		if (!phydev->link) {
> > +			priv->speed =3D 0;
> > +			priv->duplex =3D -1;
> > +		}
> > +		priv->link =3D phydev->link;
> > +
> > +		status_change =3D 1;
> > +	}
> > +
> > +	spin_unlock_irqrestore(&priv->lock, flags);
> > +
> > +	if (status_change) {
> > +		if (phydev->link) {
> > +			netif_carrier_on(ndev);
> > +			netdev_info(ndev, "link up (%d/%s)\n",
> > +				    phydev->speed,
> > +				    phydev->duplex =3D=3D DUPLEX_FULL ?
> > +				    "Full" : "Half");
> > +		} else {
> > +			netif_carrier_off(ndev);
> > +			netdev_info(ndev, "link down\n");
> > +		}
>=20
> phy_print_status() should be used.

Will do.
>=20
> Also, the phylib will handle netif_carrier_off/on for you.

Good to know :)
>=20
> > +static int nixge_open(struct net_device *ndev)
> > +{
> > +	struct nixge_priv *priv =3D netdev_priv(ndev);
> > +	int ret;
> > +
> > +	nixge_device_reset(ndev);
> > +
> > +	/* start netif carrier down */
> > +	netif_carrier_off(ndev);
> > +
> > +	if (!ndev->phydev)
> > +		netdev_err(ndev, "no phy, phy_start() failed\n");
>=20
> Not really correct. You don't call phy_start(). And phy_start() cannot
> indicate a failure, it is a void function.

Will fix.
>=20
> It would be a lot better to bail out if there is no phy. Probably
> during probe.

Yeah.
>=20
> > +static s32 __nixge_set_mac_address(struct net_device *ndev, const void=
 *addr)
> > +{
> > +	struct nixge_priv *priv =3D netdev_priv(ndev);
> > +
> > +	if (addr)
> > +		memcpy(ndev->dev_addr, addr, ETH_ALEN);
> > +	if (!is_valid_ether_addr(ndev->dev_addr))
> > +		eth_random_addr(ndev->dev_addr);
>=20
> Messy. I would change this. Make addr mandatory. If it is invalid,
> return an error. That will make nixge_net_set_mac_address() do the
> right thing. When called from nixge_probe() should verify what it gets
> from the nvmem, and if it is invalid, pass a random MAC address.

Will fix.
>=20
> > +
> > +	nixge_ctrl_write_reg(priv, NIXGE_REG_MAC_LSB,
> > +			     (ndev->dev_addr[2]) << 24 |
> > +			     (ndev->dev_addr[3] << 16) |
> > +			     (ndev->dev_addr[4] << 8) |
> > +			     (ndev->dev_addr[5] << 0));
> > +
> > +	nixge_ctrl_write_reg(priv, NIXGE_REG_MAC_MSB,
> > +			     (ndev->dev_addr[1] | (ndev->dev_addr[0] << 8)));
> > +
> > +	return 0;
> > +}
> > +
>=20
> > +static void nixge_ethtools_get_drvinfo(struct net_device *ndev,
> > +				       struct ethtool_drvinfo *ed)
> > +{
> > +	strlcpy(ed->driver, "nixge", sizeof(ed->driver));
> > +	strlcpy(ed->version, "1.00a", sizeof(ed->version));
>=20
> Driver version is pretty pointless. What does 1.00a mean? Say it gets
> backported into F26. Is it still 1.00a even though lots of things
> around it have changed?

Maybe I can just drop drvinfo?
>=20
>=20
> > +int nixge_mdio_read(struct mii_bus *bus, int phy_id, int reg)
> > +{
> > +	struct nixge_priv *priv =3D bus->priv;
> > +	u32 status, tmp;
> > +	int err;
> > +	u16 device;
> > +
> > +	if (reg & MII_ADDR_C45) {
> > +		device =3D (reg >> 16) & 0x1f;
> > +
> > +		nixge_ctrl_write_reg(priv, NIXGE_REG_MDIO_ADDR, reg & 0xffff);
> > +
> > +		tmp =3D NIXGE_MDIO_CLAUSE45 | NIXGE_MDIO_OP(NIXGE_MDIO_OP_ADDRESS)
> > +			| NIXGE_MDIO_ADDR(phy_id) | NIXGE_MDIO_MMD(device);
> > +
> > +		nixge_ctrl_write_reg(priv, NIXGE_REG_MDIO_OP, tmp);
> > +		nixge_ctrl_write_reg(priv, NIXGE_REG_MDIO_CTRL, 1);
> > +
> > +		err =3D nixge_ctrl_poll_timeout(priv, NIXGE_REG_MDIO_CTRL, status,
> > +					      !status, 10, 1000);
> > +		if (err) {
> > +			dev_err(priv->dev, "timeout setting address");
> > +			return -ETIMEDOUT;
>=20
> Better to return err.

Agreed.
>=20
> > +		}
> > +
> > +		tmp =3D NIXGE_MDIO_CLAUSE45 | NIXGE_MDIO_OP(NIXGE_MDIO_OP_READ) |
> > +			NIXGE_MDIO_ADDR(phy_id) | NIXGE_MDIO_MMD(device);
> > +	} else {
> > +		device =3D reg & 0x1f;
> > +
> > +		tmp =3D NIXGE_MDIO_CLAUSE22 | NIXGE_MDIO_OP(MDIO_C22_READ) |
> > +			NIXGE_MDIO_ADDR(phy_id) | NIXGE_MDIO_MMD(device);
> > +	}
> > +
> > +	nixge_ctrl_write_reg(priv, NIXGE_REG_MDIO_OP, tmp);
> > +	nixge_ctrl_write_reg(priv, NIXGE_REG_MDIO_CTRL, 1);
> > +
> > +	err =3D nixge_ctrl_poll_timeout(priv, NIXGE_REG_MDIO_CTRL, status,
> > +				      !status, 10, 1000);
> > +	if (err) {
> > +		dev_err(priv->dev, "timeout setting read command");
> > +		return -ETIMEDOUT;
>=20
> Again, return err.

Agreed.
>=20
> > +	}
> > +
> > +	status =3D nixge_ctrl_read_reg(priv, NIXGE_REG_MDIO_DATA);
> > +
> > +	dev_dbg(priv->dev, "%s: phy_id =3D %x reg =3D %x got %x\n", __func__,
> > +		phy_id, reg & 0xffff, status);
> > +
> > +	return status;
> > +}
> > +
> > +int nixge_mdio_write(struct mii_bus *bus, int phy_id, int reg, u16 val)
> > +{
> > +	struct nixge_priv *priv =3D bus->priv;
> > +	u32 status, tmp;
> > +	int err;
> > +	u16 device;
> > +
> > +	/* FIXME: Currently don't do writes */
> > +	if (reg & MII_ADDR_C45)
> > +		return 0;
>=20
> -EOPNOTSUPP would be better.

Agreed, ultimately I wanna implement that.
>=20
> > +
> > +	device =3D reg & 0x1f;
> > +
> > +	tmp =3D NIXGE_MDIO_CLAUSE22 | NIXGE_MDIO_OP(MDIO_C22_WRITE) |
> > +		NIXGE_MDIO_ADDR(phy_id) | NIXGE_MDIO_MMD(device);
> > +
> > +	nixge_ctrl_write_reg(priv, NIXGE_REG_MDIO_DATA, val);
> > +	nixge_ctrl_write_reg(priv, NIXGE_REG_MDIO_OP, tmp);
> > +	nixge_ctrl_write_reg(priv, NIXGE_REG_MDIO_CTRL, 1);
> > +
> > +	err =3D nixge_ctrl_poll_timeout(priv, NIXGE_REG_MDIO_CTRL, status,
> > +				      !status, 10, 1000);
> > +	if (err) {
> > +		dev_err(priv->dev, "timeout setting write command");
> > +		return -ETIMEDOUT;
> > +	}
> > +
> > +	dev_dbg(priv->dev, "%x %x <- %x\n", phy_id, reg, val);
> > +
> > +	return 0;
> > +}
> > +
> > +int nixge_mdio_setup(struct nixge_priv *priv, struct device_node *np)
> > +{
> > +	struct mii_bus *bus;
> > +	struct resource res;
> > +	int err;
> > +
> > +	bus =3D mdiobus_alloc();
> > +	if (!bus)
> > +		return -ENOMEM;
> > +
> > +	of_address_to_resource(np, 0, &res);
> > +	snprintf(bus->id, MII_BUS_ID_SIZE, "%.8llx",
> > +		 (unsigned long long)res.start);
>=20
> There are more meaningful things you could use, e.g. dev_name(priv->dev)

Agreed.
>=20
> > +	bus->priv =3D priv;
> > +	bus->name =3D "NIXGE_MAC_mii_bus";
> > +	bus->read =3D nixge_mdio_read;
> > +	bus->write =3D nixge_mdio_write;
> > +	bus->parent =3D priv->dev;
> > +
> > +	priv->mii_bus =3D bus;
> > +	err =3D of_mdiobus_register(bus, np);
> > +	if (err)
> > +		goto err_register;
> > +
> > +	dev_info(priv->dev, "MDIO bus registered\n");
> > +
> > +	return 0;
> > +
> > +err_register:
> > +	mdiobus_free(bus);
> > +	return err;
> > +}
> > +
> > +static void *nixge_get_nvmem_address(struct device *dev)
> > +{
> > +	struct nvmem_cell *cell;
> > +	size_t cell_size;
> > +	char *mac;
> > +
> > +	cell =3D nvmem_cell_get(dev, "address");
> > +	if (IS_ERR(cell))
> > +		return cell;
> > +
> > +	mac =3D nvmem_cell_read(cell, &cell_size);
> > +	nvmem_cell_put(cell);
> > +
> > +	if (IS_ERR(mac))
> > +		return mac;
> > +
> > +	return mac;
>=20
> Pointless if()

D'oh ... will fix.
>=20
> > +}
> > +
> > +static int nixge_probe(struct platform_device *pdev)
> > +{
> > +	int err;
> > +	struct nixge_priv *priv;
> > +	struct net_device *ndev;
> > +	struct resource *dmares;
> > +	const char *mac_addr;
> > +
> > +	ndev =3D alloc_etherdev(sizeof(*priv));
> > +	if (!ndev)
> > +		return -ENOMEM;
> > +
> > +	platform_set_drvdata(pdev, ndev);
> > +	SET_NETDEV_DEV(ndev, &pdev->dev);
> > +
> > +	ndev->flags &=3D ~IFF_MULTICAST;  /* clear multicast */
> > +	ndev->features =3D NETIF_F_SG;
> > +	ndev->netdev_ops =3D &nixge_netdev_ops;
> > +	ndev->ethtool_ops =3D &nixge_ethtool_ops;
> > +
> > +	/* MTU range: 64 - 9000 */
> > +	ndev->min_mtu =3D 64;
> > +	ndev->max_mtu =3D NIXGE_JUMBO_MTU;
> > +
> > +	mac_addr =3D nixge_get_nvmem_address(&pdev->dev);
> > +	if (mac_addr)
> > +		ether_addr_copy(ndev->dev_addr, mac_addr);
> > +	else
> > +		eth_hw_addr_random(ndev);
> > +
> > +	priv =3D netdev_priv(ndev);
> > +	priv->ndev =3D ndev;
> > +	priv->dev =3D &pdev->dev;
> > +
> > +	priv->features =3D 0;
> > +	/* default to this for now ... */
> > +	priv->rxmem =3D 10000;
> > +
> > +	dmares =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> > +	priv->dma_regs =3D devm_ioremap_resource(&pdev->dev, dmares);
> > +	if (IS_ERR(priv->dma_regs)) {
> > +		dev_err(&pdev->dev, "failed to map dma regs\n");
> > +		return PTR_ERR(priv->dma_regs);
> > +	}
> > +	priv->ctrl_regs =3D priv->dma_regs + 0x4000;
> > +	__nixge_set_mac_address(ndev, mac_addr);
> > +
> > +	priv->tx_irq =3D platform_get_irq_byname(pdev, "tx-irq");
> > +	if (priv->tx_irq < 0) {
> > +		dev_err(&pdev->dev, "no tx irq available");
> > +		return priv->tx_irq;
> > +	}
> > +
> > +	priv->rx_irq =3D platform_get_irq_byname(pdev, "rx-irq");
> > +	if (priv->rx_irq < 0) {
> > +		dev_err(&pdev->dev, "no rx irq available");
> > +		return priv->rx_irq;
> > +	}
> > +
> > +	priv->coalesce_count_rx =3D XAXIDMA_DFT_RX_THRESHOLD;
> > +	priv->coalesce_count_tx =3D XAXIDMA_DFT_TX_THRESHOLD;
> > +
> > +	spin_lock_init(&priv->lock);
> > +
> > +	err =3D nixge_mdio_setup(priv, pdev->dev.of_node);
> > +	if (err) {
> > +		dev_warn(&pdev->dev, "error registering mdio bus");
> > +		goto free_netdev;
> > +	}
> > +
> > +	priv->phy_dev =3D phy_find_first(priv->mii_bus);
> > +	if (!priv->phy_dev) {
> > +		dev_err(&pdev->dev, "error finding a phy ...");
> > +		goto free_netdev;
> > +	}
>=20
> I don't recommend this. Enforce the binding has a phy-handle.

Yeah, will move the of_phy_connect into open() and just check for
phandle here.
>=20
> > +
> > +	err =3D register_netdev(priv->ndev);
> > +	if (err) {
> > +		dev_err(priv->dev, "register_netdev() error (%i)\n", err);
> > +		goto free_netdev;
> > +	}
> > +
> > +	err =3D phy_connect_direct(ndev, priv->phy_dev, &nixge_handle_link_ch=
ange,
> > +				 priv->phy_interface);
>=20
> and here use of_phy_connect().

I'll probably move that to the open()
>=20
> And where do you set phy_interface? You should be reading it from
> device tree.

True.
>=20
> > +	if (err) {
> > +		dev_err(&pdev->dev, "failed to attach to phy ...");
> > +		goto unregister_mdio;
> > +	}
> > +
> > +	/* not sure if this is the correct way of dealing with this ... */
> > +	ndev->phydev->supported &=3D ~(SUPPORTED_Autoneg);
> > +	ndev->phydev->advertising =3D ndev->phydev->supported;
> > +	ndev->phydev->autoneg =3D AUTONEG_DISABLE;
>=20
> What are you trying to achieve?

Basically can't do Autoneg, I'll need to take a closer look.

>=20
>      Andrew

Thanks for your feedback,

Moritz

--ZGiS0Q5IWpPtfppv
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZaBDNAAoJEL5CEHepFqov/QUIAIRAaFwJb1nUFLAJcA0ALLMU
XQD65f+7UvbREK/VFJwYf39qrubv+hZVbDrG+9ky2m4czzlOVksjmbXI+esim+Bd
ShFAjeDrfoOg5imvwefL/2MilfmkN9Q7x3I6kanzUE3bY3gOBpy0cQ2q3oypUKpR
8Sn5K7nw+JgJ3j896aIR50T6LunUg/xdKTPDjoywdvhd4SyRkIWeW+ss7vs0eJyq
89zl3Bx+Rz3JUI3qgOuRIT2YOOHwKUBZRq4SVDdGfVi4aHEyVzx96ZA53NnLV/Jn
zhkSlcu8ZCivIlcRgbSiD1+tioRFd0r/57GM98FmfUgiQnNHxwzYIESIOQym3lc=
=KUth
-----END PGP SIGNATURE-----

--ZGiS0Q5IWpPtfppv--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
