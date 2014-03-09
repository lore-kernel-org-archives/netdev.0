From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH RFC 3/3] Altera TSE: Add Altera Triple Speed Ethernet
 (TSE) Driver
Date: Sun, 09 Mar 2014 16:32:20 +0000
Message-ID: <1394382740.2861.135.camel@deadeye.wl.decadent.org.uk>
References: <1393792922-2381-1-git-send-email-vbridgers2013@gmail.com>
	 <1393792922-2381-4-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-nDHwT3YWLqxI5ssW4qBT"
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, rob@landley.net
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1393792922-2381-4-git-send-email-vbridgers2013@gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-nDHwT3YWLqxI5ssW4qBT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-03-02 at 14:42 -0600, Vince Bridgers wrote:
[....]
> --- /dev/null
> +++ b/drivers/net/ethernet/altera/altera_msgdma.c
[...]
> +void msgdma_reset(struct altera_tse_private *priv)
> +{
> +	int counter;
> +	struct msgdma_csr *txcsr =3D
> +		(struct msgdma_csr *)priv->tx_dma_csr;
> +	struct msgdma_csr *rxcsr =3D
> +		(struct msgdma_csr *)priv->rx_dma_csr;

Don't remove the __iomem qualifier here (or anywhere).

[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/altera/altera_sgdma.c
> @@ -0,0 +1,558 @@
> +/* Altera TSE SGDMA and MSGDMA Linux driver
> + * Copyright (C) 2014 Altera Corporation. All rights reserved
> + *
> + * This program is free software; you can redistribute it and/or modify =
it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOU=
T
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License=
 for
> + * more details.
> + *
> + * You should have received a copy of the GNU General Public License alo=
ng with
> + * this program.  If not, see <http://www.gnu.org/licenses/>.
> + */
> +
> +#include <linux/list.h>
> +#include "altera_utils.h"
> +#include "altera_tse.h"
> +#include "altera_sgdmahw.h"
> +#include "altera_sgdma.h"
> +
> +static void sgdma_descrip(struct sgdma_descrip *desc,
> +			  struct sgdma_descrip *ndesc,
> +			  unsigned int ndesc_phys,
> +			  dma_addr_t raddr,
> +			  dma_addr_t waddr,
> +			  u16 length,
> +			  int generate_eop,
> +			  int rfixed,
> +			  int wfixed);

[...]
> +int sgdma_initialize(struct altera_tse_private *priv)
> +{
> +	priv->descripsz =3D sizeof(struct sgdma_descrip);
> +	priv->txdescrips =3D priv->txdescmem/priv->descripsz;
> +	priv->rxdescrips =3D priv->rxdescmem/priv->descripsz;
> +
> +	priv->txctrlreg =3D SGDMA_CTRLREG_ILASTD;
> +
> +	priv->rxctrlreg =3D SGDMA_CTRLREG_IDESCRIP |
> +		      SGDMA_CTRLREG_ILASTD;
> +
> +	INIT_LIST_HEAD(&priv->txlisthd);
> +	INIT_LIST_HEAD(&priv->rxlisthd);
> +
> +	priv->rxdescphys =3D (dma_addr_t) 0;
> +	priv->txdescphys =3D (dma_addr_t) 0;

0 is *not* a reserved DMA address...

[...]
> +	if (dma_mapping_error(priv->device, priv->rxdescphys)) {

...which is why you have to use dma_mapping_error() to check it...

[...]
> +void sgdma_uninitialize(struct altera_tse_private *priv)
> +{
> +	if (priv->rxdescphys)
> +		dma_unmap_single(priv->device, priv->rxdescphys,
> +				 priv->rxdescmem, DMA_BIDIRECTIONAL);
> +
> +	if (priv->txdescphys)
> +		dma_unmap_single(priv->device, priv->txdescphys,
> +				 priv->txdescmem, DMA_BIDIRECTIONAL);
> +}

...so these conditions are wrong.

Looking back up the function:

> +	priv->rxdescphys =3D dma_map_single(priv->device, priv->rx_dma_desc,
> +					  priv->rxdescmem, DMA_BIDIRECTIONAL);
> +

rx_dma_desc is an MMIO pointer (similarly, tx_dma_desc).  What makes you
think that it's valid to DMA-map that?  It seems like you only use
rxdescmem with DMA sync functions, which suggests that the descriptor
access is very much reliant on quirks of the current NIOS port.

[...]
> +/* status is returned on upper 16 bits,
> + * length is returned in lower 16 bits
> + */
> +u32 sgdma_rx_status(struct altera_tse_private *priv)
> +{
> +	struct sgdma_csr *csr =3D (struct sgdma_csr *)priv->rx_dma_csr;
> +	struct sgdma_descrip *base =3D (struct sgdma_descrip *)priv->rx_dma_des=
c;
> +	struct sgdma_descrip *desc =3D NULL;
> +	int pktsrx;
> +	unsigned int rxstatus =3D 0;
> +	unsigned int pktlength =3D 0;
> +	unsigned int pktstatus =3D 0;
> +	struct tse_buffer *rxbuffer =3D NULL;
> +
> +	dma_sync_single_for_cpu(priv->device,
> +				priv->rxdescphys,
> +				priv->rxdescmem,
> +				DMA_BIDIRECTIONAL);

You want to sync *all* your RX buffers, every time you receive a packet?

> +	/* Issue read memory barrier before accessing rx descriptor */
> +	rmb();

Yes but why?  What is the prior read operation?

[...]
> +/* Private functions */
> +static void sgdma_descrip(struct sgdma_descrip *desc,
> +			  struct sgdma_descrip *ndesc,
> +			  unsigned int ndesc_phys,
> +			  dma_addr_t raddr,
> +			  dma_addr_t waddr,
> +			  u16 length,
> +			  int generate_eop,
> +			  int rfixed,
> +			  int wfixed)

This seems to be an unwieldy number of parameters, and the last three
are clearly redundant with each other as you end up doing:

[...]
> +	ctrl |=3D generate_eop;
> +	ctrl |=3D rfixed;
> +	ctrl |=3D wfixed;

[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/altera/altera_tse.c
[...]
> +#define RX_DESCRIPTORS 64
> +static int dma_rx_num =3D RX_DESCRIPTORS;
> +module_param(dma_rx_num, int, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(dma_rx_num, "Number of descriptors in the RX list");
> +
> +#define TX_DESCRIPTORS 64
> +static int dma_tx_num =3D TX_DESCRIPTORS;
> +module_param(dma_tx_num, int, S_IRUGO | S_IWUSR);
> +MODULE_PARM_DESC(dma_tx_num, "Number of descriptors in the TX list");

Module parameters for this are not acceptable.  Implement the ethtool
{get,set}_ringparam operations instead.

[...]
> +static void tse_free_tx_buffer(struct altera_tse_private *priv,
> +			       struct tse_buffer *buffer)
> +{
> +	if (buffer->dma_addr) {
> +		if (buffer->mapped_as_page)

The mapped_as_page field is never set, so remove the field and this
condition.

> +			dma_unmap_page(priv->device, buffer->dma_addr,
> +				       buffer->len, DMA_TO_DEVICE);
> +		else
> +			dma_unmap_single(priv->device, buffer->dma_addr,
> +					 buffer->len, DMA_TO_DEVICE);
> +		buffer->dma_addr =3D 0;
> +	}
> +	if (buffer->skb) {
> +		dev_kfree_skb_any(buffer->skb);
> +		buffer->skb =3D NULL;
> +	}
> +}
[...]
> +/* NAPI polling function
> + */
> +static int tse_poll(struct napi_struct *napi, int budget)
> +{
> +	struct altera_tse_private *priv =3D
> +			container_of(napi, struct altera_tse_private, napi);
> +	int rxcomplete =3D 0;
> +	int txcomplete =3D 0;
> +	unsigned long int flags;
> +
> +	txcomplete =3D tse_tx_complete(priv);
> +
> +	rxcomplete =3D tse_rx(priv, budget);
> +
> +	if (txcomplete+rxcomplete !=3D budget) {
> +		napi_gro_flush(napi, false);
> +		__napi_complete(napi);
> +
> +		dev_dbg(priv->device,
> +			"NAPI Complete, did %d packets with budget %d\n",
> +			txcomplete+rxcomplete, budget);
> +	}
> +	spin_lock_irqsave(&priv->rxdma_irq_lock, flags);
> +	priv->enable_rxirq(priv);
> +	priv->enable_txirq(priv);
> +	spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
> +	return rxcomplete + txcomplete;

So you count all the TX and RX completions, yet TX completion handling
is *not* limited by the budget.

I'm surprised this doesn't immediately produce warning messages from
NAPI.  You must *never* return a value greater than budget, and you
shou;ld not count TX completions.

> +}
[...]
> +static int tse_change_mtu(struct net_device *dev, int new_mtu)
> +{
> +	struct altera_tse_private *priv =3D netdev_priv(dev);
> +	unsigned int max_mtu =3D priv->max_mtu;
> +	unsigned int min_mtu =3D ETH_ZLEN + ETH_FCS_LEN;
> +
> +	if (netif_running(dev)) {
> +		dev_err(priv->device, "must be stopped to change its MTU\n");
> +		return -EBUSY;
> +	}

This is true for many devices, but that is your problem as the driver
writer.  You should restart the hardware if necessary.

[...]
> +static void altera_tse_set_mcfilter(struct net_device *dev)
> +{
> +	struct altera_tse_private *priv =3D netdev_priv(dev);
> +	struct altera_tse_mac *mac =3D (struct altera_tse_mac *)priv->mac_dev;
> +	int i;
> +	struct netdev_hw_addr *ha;
> +
> +	/* clear the hash filter */
> +	for (i =3D 0; i < 64; i++)
> +		iowrite32(0, &(mac->hash_table[i]));

This means you drop all multicast traffic for a while, every time a new
multicast address is added.

Instead, you should construct a complete new bitmap before updating the
filter.

[...]
> +static int altera_tse_get_phy_iface_prop(struct platform_device *pdev,
> +					 phy_interface_t *iface)
> +{
> +	const void *prop;
> +	int len;
> +
> +	prop =3D of_get_property(pdev->dev.of_node, "phy-mode", &len);
> +	if (!prop)
> +		return -ENOENT;
> +	if (len < 4)
> +		return -EINVAL;
> +
> +	if (!strncmp((char *)prop, "mii", 3)) {
> +		*iface =3D PHY_INTERFACE_MODE_MII;
> +		return 0;
> +	} else if (!strncmp((char *)prop, "gmii", 4)) {
> +		*iface =3D PHY_INTERFACE_MODE_GMII;
> +		return 0;
> +	} else if (!strncmp((char *)prop, "rgmii-id", 8)) {
> +		*iface =3D PHY_INTERFACE_MODE_RGMII_ID;
> +		return 0;
> +	} else if (!strncmp((char *)prop, "rgmii", 5)) {
> +		*iface =3D PHY_INTERFACE_MODE_RGMII;
> +		return 0;
> +	} else if (!strncmp((char *)prop, "sgmii", 5)) {
> +		*iface =3D PHY_INTERFACE_MODE_SGMII;
> +		return 0;
> +	}

Is there really no common function for this?  Maybe you should add one.

> +	return -EINVAL;
> +}
> +
> +static int request_and_map(struct platform_device *pdev, const char *nam=
e,
> +			   struct resource **res, void __iomem **ptr)

The fact that you return the MMIO pointer by reference is problematic,
because the callers actually want to initialise pointers to specific
structure types.  They have to cast, and in fact they do the cast
wrongly as they don't include the __iomem qualifier.

Perhaps you could change this function to return the MMIO pointer
directly and use ERR_PTR for errors?

[...]
> +	ndev->mem_start =3D control_port->start;
> +	ndev->mem_end =3D control_port->end;

Not necessary, these fields are for ancient ISA crap where the user
might have to tell the driver which addresses to use.

[...]
> +	altera_tse_netdev_ops.ndo_set_rx_mode =3D tse_set_rx_mode;
> +
> +	if (priv->hash_filter)
> +		altera_tse_netdev_ops.ndo_set_rx_mode =3D
> +			tse_set_rx_mode_hashfilter;

Now imagine someone uses two instances of this IP block with different
capabilities.

[...]
> +/* Remove Altera TSE MAC device
> + */
> +static int altera_tse_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev =3D platform_get_drvdata(pdev);
> +
> +	platform_set_drvdata(pdev, NULL);

Redundant, driver core does this.

> +	if (ndev) {
> +		altera_tse_mdio_destroy(ndev);

I think this needs to be done after unregister_netdev(), but I'm not
sure.

> +		netif_carrier_off(ndev);

Redundant.

> +		unregister_netdev(ndev);
> +		free_netdev(ndev);
> +	}
> +
> +	return 0;
> +}
[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/altera/altera_tse_ethtool.c
[...]
> +#define TSE_STATS_LEN 31
> +
> +static char stat_gstrings[][ETH_GSTRING_LEN] =3D {

Please either use TSE_STATS_LEN as the outer dimension, or define
TSE_STATS_LEN using ARRAY_SIZE().

[...]
> +static void tse_get_drvinfo(struct net_device *dev,
> +			    struct ethtool_drvinfo *info)
> +{
> +	struct altera_tse_private *priv =3D netdev_priv(dev);
> +	u32 rev =3D ioread32(&priv->mac_dev->megacore_revision);
> +
> +	strcpy(info->driver, "Altera TSE MAC IP Driver");

This should match the driver name elsewhere, i.e.
ALTERA_TSE_RESOURCE_NAME.

> +	strcpy(info->version, "v8.0");
> +	snprintf(info->fw_version, ETHTOOL_FWVERS_LEN, "v%d.%d",
> +		 rev & 0xFFFF, (rev & 0xFFFF0000) >> 16);

That appears to be a hardware version, not a firmware version.

> +	sprintf(info->bus_info, "AVALON");

I don't think that's helpful.  Either put some sort of address here or
leave it blank.

> +}
[...]
> +static int tse_sset_count(struct net_device *dev, int sset)
> +{
> +	switch (sset) {
> +	case ETH_SS_STATS:
> +		return TSE_STATS_LEN;
> +	default:
> +		return -EOPNOTSUPP;

EINVAL

> +	}
> +}
> +
[...]
> +static int tse_get_settings(struct net_device *dev, struct ethtool_cmd *=
cmd)
> +{
> +	struct altera_tse_private *priv =3D netdev_priv(dev);
> +	struct phy_device *phydev =3D priv->phydev;
> +
> +	if (phydev =3D=3D NULL)
> +		return -ENODEV;

EOPNOTSUPP

> +	return phy_ethtool_gset(phydev, cmd);
> +}
> +
> +static int tse_set_settings(struct net_device *dev, struct ethtool_cmd *=
cmd)
> +{
> +	struct altera_tse_private *priv =3D netdev_priv(dev);
> +	struct phy_device *phydev =3D priv->phydev;
> +
> +	if (phydev =3D=3D NULL)
> +		return -ENODEV;

EOPNOTSUPP

> +	return phy_ethtool_sset(phydev, cmd);
> +}
[...]

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-nDHwT3YWLqxI5ssW4qBT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxyXlOe/yOyVhhEJAQq7kQ//akhwyvW7PF58jYExvoZxB+yrdPqJJG6O
X8iD0/RnFLNop/3tk07zjPkH+BtpGqChwKMVwLLd8IuNZ2XYlwhdvdUl7rsP9Rlp
jVJJDBcsPvk+WxFwREBAOAIm0Y5QPxUGtvMWD6l5cEoW2h8mvm6dSyxwEZIY9xCq
sOacQtbWxWEFcbsnJ2nnCXG4xzvk3CWOy4U3cHQJTWqavF3zGJ3qMAuHLFC0W6vi
I6W/wr1wefw8Sw6w4wac4XMe//9Qq+Sjz6UH3ggyzgxtISUa+GcsKPyKhfZ9yfDD
4Gv8yVc6Ok1FXgDTGXp4RQYI7k4LIVRHw9j6ucctZiBY3cy+OdeTUcbnQ8J//fxO
3vMatBWdkTrVubDKUU+LYHq3CKBk8ke6KSc8yLCjxPvMCO38lwEa6Mmo8F9nOJRV
t1whu/a0aEDu5oiVt30oUjR44dkDQE+X4D2wImRNiGBJstr4t2/85QNIyfC19IjK
5iho3otbFTTKdIVMhnzsqjuPsFfvlRx6YngR7SgatQO4UJ4g73fjkq0xc0B2ZRze
OZJYlwqI1H1WQAIFntT8Jz0E/r2C2dRQjpx2B9jMzqYT09eg6WdDLq/lu5J6hD0Z
2m3WjFBQnqPvKvkbXXDE9PU8DVDuVZfeIdUKP4sVbBeHYzJ/TTNYzrYLwaU8n0Zx
QwSWHYXboW4=
=flyS
-----END PGP SIGNATURE-----

--=-nDHwT3YWLqxI5ssW4qBT--
