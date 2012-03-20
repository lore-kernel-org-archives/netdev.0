From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 1/1] ARC VMAC driver.
Date: Tue, 20 Mar 2012 11:00:28 +0100
Message-ID: <4F68553C.2020402@openwrt.org>
References: <CALtMJECEj7dtseSas9708L6xKs2fobS9_m3bVY_BCe6icLWRsA@mail.gmail.com> <1332232945-27869-1-git-send-email-afenkart@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andreas Fenkart <afenkart@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43428 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757547Ab2CTKBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 06:01:31 -0400
Received: by bkcik5 with SMTP id ik5so4953545bkc.19
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2012 03:01:30 -0700 (PDT)
In-Reply-To: <1332232945-27869-1-git-send-email-afenkart@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas,

Le 03/20/12 09:42, Andreas Fenkart a =C3=A9crit :
> This is a driver for the MAC IP block from ARC International. It
> is based on an existing driver found in ARC Linux distribution,
> but essentially, a full rewrite.
>
> Signed-off-by: Andreas Fenkart<afenkart@gmail.com>

I have some phylib-related comments inline.

> ---
>   drivers/net/ethernet/Kconfig   |    9 +
>   drivers/net/ethernet/Makefile  |    1 +
>   drivers/net/ethernet/arcvmac.c | 1472 +++++++++++++++++++++++++++++=
+++++++++++
>   drivers/net/ethernet/arcvmac.h |  269 ++++++++
>   4 files changed, 1751 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kcon=
fig
> index 597f4d4..4b6baf8 100644
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -23,6 +23,15 @@ source "drivers/net/ethernet/aeroflex/Kconfig"
>   source "drivers/net/ethernet/alteon/Kconfig"
>   source "drivers/net/ethernet/amd/Kconfig"
>   source "drivers/net/ethernet/apple/Kconfig"
> +
> +config ARCVMAC
> +	tristate "ARC VMAC ethernet driver"
> +	select MII
> +	select PHYLIB
> +	select CRC32
> +	help
> +	  MAC present Zoran43xx, IP from ARC international
> +
>   source "drivers/net/ethernet/atheros/Kconfig"
>   source "drivers/net/ethernet/cadence/Kconfig"
>   source "drivers/net/ethernet/adi/Kconfig"
> diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Mak=
efile
> index be5dde0..cb61799 100644
> --- a/drivers/net/ethernet/Makefile
> +++ b/drivers/net/ethernet/Makefile
> @@ -9,6 +9,7 @@ obj-$(CONFIG_GRETH) +=3D aeroflex/
>   obj-$(CONFIG_NET_VENDOR_ALTEON) +=3D alteon/
>   obj-$(CONFIG_NET_VENDOR_AMD) +=3D amd/
>   obj-$(CONFIG_NET_VENDOR_APPLE) +=3D apple/
> +obj-$(CONFIG_ARCVMAC) +=3D arcvmac.o
>   obj-$(CONFIG_NET_VENDOR_ATHEROS) +=3D atheros/
>   obj-$(CONFIG_NET_ATMEL) +=3D cadence/
>   obj-$(CONFIG_NET_BFIN) +=3D adi/
> diff --git a/drivers/net/ethernet/arcvmac.c b/drivers/net/ethernet/ar=
cvmac.c
> new file mode 100644
> index 0000000..d512806
> --- /dev/null
> +++ b/drivers/net/ethernet/arcvmac.c
> @@ -0,0 +1,1472 @@
> +/*
> + * ARC VMAC Driver
> + *
> + * Copyright (C) 2009-2012 Andreas Fenkart
> + * All Rights Reserved.
> + *
> + * This program is free software; you can redistribute it and/or mod=
ify
> + * it under the terms of the GNU General Public License as published=
 by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1=
307  USA
> + *
> + * Initial work taken from arc linux distribution, any bugs are mine
> + *
> + *	-----<snip>-----
> + * Copyright (C) 2003-2006 Codito Technologies, for linux-2.4 port
> + * Copyright (C) 2006-2007 Celunite Inc, for linux-2.6 port
> + * Authors: amit.bhor@celunite.com, sameer.dhavale@celunite.com
> + *	-----<snip>-----
> + */
> +
> +#include<linux/clk.h>
> +#include<linux/crc32.h>
> +#include<linux/delay.h>
> +#include<linux/dma-mapping.h>
> +#include<linux/etherdevice.h>
> +#include<linux/init.h>
> +#include<linux/interrupt.h>
> +#include<linux/io.h>
> +#include<linux/kernel.h>
> +#include<linux/module.h>
> +#include<linux/moduleparam.h>
> +#include<linux/netdevice.h>
> +#include<linux/phy.h>
> +#include<linux/platform_device.h>
> +#include<linux/slab.h>
> +#include<linux/sched.h>
> +#include<linux/types.h>
> +
> +#include "arcvmac.h"
> +
> +/* Register access macros */
> +#define vmac_writel(port, value, reg)	\
> +	writel(cpu_to_le32(value), (port)->regs + VMAC_##reg)
> +#define vmac_readl(port, reg)	le32_to_cpu(readl((port)->regs + VMAC_=
##reg))
> +
> +static int get_register_map(struct vmac_priv *ap);
> +static int put_register_map(struct vmac_priv *ap);
> +static void update_vmac_stats_unlocked(struct net_device *dev);
> +static int vmac_tx_reclaim_unlocked(struct net_device *dev, bool for=
ce);
> +
> +static unsigned char *read_mac_reg(struct net_device *dev,
> +				   unsigned char hwaddr[ETH_ALEN])
> +{
> +	struct vmac_priv *ap =3D netdev_priv(dev);
> +	u32 mac_lo, mac_hi;
> +
> +	WARN_ON(!hwaddr);
> +	mac_lo =3D vmac_readl(ap, ADDRL);
> +	mac_hi =3D vmac_readl(ap, ADDRH);
> +
> +	hwaddr[0] =3D (mac_lo>>  0)&  0xff;
> +	hwaddr[1] =3D (mac_lo>>  8)&  0xff;
> +	hwaddr[2] =3D (mac_lo>>  16)&  0xff;
> +	hwaddr[3] =3D (mac_lo>>  24)&  0xff;
> +	hwaddr[4] =3D (mac_hi>>  0)&  0xff;
> +	hwaddr[5] =3D (mac_hi>>  8)&  0xff;
> +	return hwaddr;
> +}
> +
> +static void write_mac_reg(struct net_device *dev, unsigned char* hwa=
ddr)
> +{
> +	struct vmac_priv *ap =3D netdev_priv(dev);
> +	u32 mac_lo, mac_hi;
> +
> +	mac_lo =3D hwaddr[3]<<  24 | hwaddr[2]<<  16 | hwaddr[1]<<  8 |
> +		hwaddr[0];
> +	mac_hi =3D hwaddr[5]<<  8 | hwaddr[4];
> +
> +	vmac_writel(ap, mac_lo, ADDRL);
> +	vmac_writel(ap, mac_hi, ADDRH);
> +}
> +
> +static void vmac_mdio_xmit(struct vmac_priv *ap, u32 val)
> +{
> +	init_completion(&ap->mdio_complete);
> +	vmac_writel(ap, val, MDIO_DATA);
> +	wait_for_completion(&ap->mdio_complete);

I would rather switch to a variant which allows a timeout, just in case=
=20
the MDIO transaction never completes, so you are not stuck here, and yo=
u=20
can guarantee the maximum waiting time. You might also want to test if=20
you need the _interruptible variant too in case you have a process like=
=20
ethtool calling into your driver's ethtool ops callbacks. Then you also=
=20
need to propagate the error to the callers.

> +}
> +
> +static int vmac_mdio_read(struct mii_bus *bus, int phy_id, int phy_r=
eg)
> +{
> +	struct vmac_priv *vmac =3D bus->priv;
> +	u32 val;
> +
> +	/* only 5 bits allowed for phy-addr and reg_offset */
> +	WARN_ON(phy_id&  ~0x1f || phy_reg&  ~0x1f);

A WARN_ON() here is a little too hard, just return -EINVAL.

> +
> +	val =3D MDIO_BASE | MDIO_OP_READ;
> +	val |=3D phy_id<<  23 | phy_reg<<  18;
> +	vmac_mdio_xmit(vmac, val);
> +
> +	val =3D vmac_readl(vmac, MDIO_DATA);
> +	return val&  MDIO_DATA_MASK;
> +}
> +
> +static int vmac_mdio_write(struct mii_bus *bus, int phy_id, int phy_=
reg,
> +			   u16 value)
> +{
> +	struct vmac_priv *vmac =3D bus->priv;
> +	u32 val;
> +
> +	/* only 5 bits allowed for phy-addr and reg_offset */
> +	WARN_ON(phy_id&  ~0x1f || phy_reg&  ~0x1f);

Same here.

> +
> +	val =3D MDIO_BASE | MDIO_OP_WRITE;
> +	val |=3D phy_id<<  23 | phy_reg<<  18;
> +	val |=3D (value&  MDIO_DATA_MASK);
> +	vmac_mdio_xmit(vmac, val);
> +
> +	return 0;
> +}
> +
> +static void vmac_handle_link_change(struct net_device *dev)
> +{
> +	struct vmac_priv *ap =3D netdev_priv(dev);
> +	struct phy_device *phydev =3D ap->phy_dev;
> +	unsigned long flags;
> +	bool report_change =3D false;
> +
> +	spin_lock_irqsave(&ap->lock, flags);
> +
> +	if (phydev->duplex !=3D ap->duplex) {
> +		u32 tmp;
> +
> +		tmp =3D vmac_readl(ap, ENABLE);
> +
> +		if (phydev->duplex)
> +			tmp |=3D ENFL_MASK;
> +		else
> +			tmp&=3D ~ENFL_MASK;
> +
> +		vmac_writel(ap, tmp, ENABLE);
> +
> +		ap->duplex =3D phydev->duplex;
> +		report_change =3D true;
> +	}
> +
> +	if (phydev->speed !=3D ap->speed) {
> +		ap->speed =3D phydev->speed;
> +		report_change =3D true;
> +	}
> +
> +	if (phydev->link !=3D ap->link) {
> +		ap->link =3D phydev->link;
> +		report_change =3D true;
> +	}
> +
> +	spin_unlock_irqrestore(&ap->lock, flags);
> +
> +	if (report_change)
> +		phy_print_status(ap->phy_dev);
> +}
> +
> +static int __devinit vmac_mii_probe(struct net_device *dev)
> +{
> +	struct vmac_priv *ap =3D netdev_priv(dev);
> +	struct phy_device *phydev =3D NULL;
> +	struct clk *vmac_clk;
> +	unsigned long clock_rate;
> +	int phy_addr, err;
> +
> +	/* find the first phy */
> +	for (phy_addr =3D 0; phy_addr<  PHY_MAX_ADDR; phy_addr++) {
> +		if (ap->mii_bus->phy_map[phy_addr]) {
> +			phydev =3D ap->mii_bus->phy_map[phy_addr];
> +			break;
> +		}
> +	}

Use phy_find_first() instead of open-coding the iteration.

> +
> +	if (!phydev) {
> +		dev_err(&ap->pdev->dev, "no PHY found\n");
> +		return -ENODEV;
> +	}
> +
> +	/* FIXME: add pin_irq, if avail */
> +
> +	phydev =3D phy_connect(dev, dev_name(&phydev->dev),
> +			&vmac_handle_link_change, 0,
> +			     PHY_INTERFACE_MODE_MII);
> +
> +	if (IS_ERR(phydev)) {
> +		err =3D PTR_ERR(phydev);
> +		dev_err(&ap->pdev->dev, "could not attach to PHY %d\n", err);
> +		goto err_out;
> +	}
> +
> +	phydev->supported&=3D PHY_BASIC_FEATURES;
> +	phydev->supported |=3D SUPPORTED_Asym_Pause | SUPPORTED_Pause;
> +
> +	vmac_clk =3D clk_get(&ap->pdev->dev, "arcvmac");
> +	if (IS_ERR(vmac_clk)) {
> +		err =3D PTR_ERR(vmac_clk);
> +		goto err_disconnect;
> +	}
> +
> +	clock_rate =3D clk_get_rate(vmac_clk);
> +	clk_put(vmac_clk);
> +
> +	dev_dbg(&ap->pdev->dev, "vmac_clk: %lu Hz\n", clock_rate);
> +
> +	if (clock_rate<  25000000)
> +		phydev->supported&=3D ~(SUPPORTED_100baseT_Half |
> +				       SUPPORTED_100baseT_Full);
> +
> +	phydev->advertising =3D phydev->supported;
> +
> +	ap->link =3D 0;
> +	ap->speed =3D 0;
> +	ap->duplex =3D -1;
> +	ap->phy_dev =3D phydev;
> +
> +	return 0;
> +
> +err_disconnect:
> +	phy_disconnect(phydev);
> +err_out:
> +	return err;
> +}
> +
> +static int __devinit vmac_mii_init(struct vmac_priv *ap)
> +{
> +	unsigned long flags;
> +	int err, i;
> +
> +	spin_lock_irqsave(&ap->lock, flags);
> +
> +	ap->mii_bus =3D mdiobus_alloc();
> +	if (!ap->mii_bus)
> +		return -ENOMEM;
> +
> +	ap->mii_bus->name =3D "vmac_mii_bus";
> +	ap->mii_bus->read =3D&vmac_mdio_read;
> +	ap->mii_bus->write =3D&vmac_mdio_write;
> +
> +	snprintf(ap->mii_bus->id, MII_BUS_ID_SIZE, "%x", 0);

Please use an unique name such as:

snprintf(ap->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x", ap->pdev->name,=20
ap->pdev->id);

> +
> +	ap->mii_bus->priv =3D ap;
> +
> +	err =3D -ENOMEM;
> +	ap->mii_bus->irq =3D kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL=
);
> +	if (!ap->mii_bus->irq)
> +		goto err_out;

This is a little unusual, rather do this:
if (!ap->mii_bus->irq) {
	err =3D -ENOMEM;
	goto err_out;
}

> +
> +	for (i =3D 0; i<  PHY_MAX_ADDR; i++)
> +		ap->mii_bus->irq[i] =3D PHY_POLL;
> +
> +	spin_unlock_irqrestore(&ap->lock, flags);
> +
> +	/* locking: mdio concurrency */
> +
> +	err =3D mdiobus_register(ap->mii_bus);
> +	if (err)
> +		goto err_out_free_mdio_irq;
> +
> +	err =3D vmac_mii_probe(ap->dev);
> +	if (err)
> +		goto err_out_unregister_bus;
> +
> +	return 0;
> +
> +err_out_unregister_bus:
> +	mdiobus_unregister(ap->mii_bus);
> +err_out_free_mdio_irq:
> +	kfree(ap->mii_bus->irq);
> +err_out:
> +	mdiobus_free(ap->mii_bus);
> +	return err;
> +}
> +
--
=46lorian
