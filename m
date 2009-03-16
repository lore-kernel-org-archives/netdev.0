From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-2.6 PATCH 9/10] Neterion: New driver: Ethtool related
Date: Mon, 16 Mar 2009 21:53:01 +0000
Message-ID: <1237240381.3106.79.camel@achroite>
References: <1237018915.4966.437.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:58067 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753597AbZCPVxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 17:53:12 -0400
In-Reply-To: <1237018915.4966.437.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-03-14 at 00:22 -0800, Ramkrishna Vepa wrote:
> This patch implements all ethtool related entry point functions for t=
he driver.
>=20
> Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> ---
> diff -urpN patch_8/drivers/net/vxge/vxge-ethtool.c patch_9/drivers/ne=
t/vxge/vxge-ethtool.c
> --- patch_8/drivers/net/vxge/vxge-ethtool.c	1969-12-31 16:00:00.00000=
0000 -0800
> +++ patch_9/drivers/net/vxge/vxge-ethtool.c	2009-03-13 00:15:35.00000=
0000 -0700
[...
> +/*
> + * vxge_ethtool_sset - Sets different link parameters.
> + * @dev: device pointer.
> + * @info: pointer to the structure with parameters given by ethtool =
to set
> + * link information.
> + *
> + * The function sets different link parameters provided by the user =
onto
> + * the NIC.
> + * Return value:
> + * 0 on success.
> + */
> +
> +static int vxge_ethtool_sset(struct net_device *dev, struct ethtool_=
cmd *info)
> +{
> +	if ((info->autoneg =3D=3D AUTONEG_ENABLE) ||
> +	    (info->speed !=3D SPEED_10000) || (info->duplex !=3D DUPLEX_FUL=
L))
> +		return -EINVAL;
> +
> +	if (netif_running(dev)) {
> +		vxge_close(dev);
> +		vxge_open(dev);

Why?

> +	}
> +
> +	return 0;
> +}
> +
> +/*
> + * vxge_ethtool_gset - Return link specific information.
> + * @dev: device pointer.
> + * @info: pointer to the structure with parameters given by ethtool
> + * to return link information.
> + *
> + * Returns link specific information like speed, duplex etc.. to eth=
tool.
> + * Return value :
> + * return 0 on success.
> + */
> +int vxge_ethtool_gset(struct net_device *dev, struct ethtool_cmd
> +*info)
> +{
> +	info->supported =3D (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
> +
> +#ifdef ADVERTISED_10000baseT_Full
> +	info->advertising =3D ADVERTISED_10000baseT_Full;
> +#else
> +	info->advertising =3D SUPPORTED_10000baseT_Full;
> +#endif
> +
> +#ifdef ADVERTISED_FIBRE
> +	info->advertising  |=3D ADVERTISED_FIBRE;
> +#else
> +	info->advertising  |=3D SUPPORTED_FIBRE;
> +#endif

Do not use #ifdef here.  You can be sure that these definitions aren't
going away.

[...]
> +/*
> + * vxge_ethtool_gdrvinfo - Returns driver specific information.
> + * @dev: device pointer.
> + * @info: pointer to the structure with parameters given by ethtool =
to
> + * return driver information.
> + *
> + * Returns driver specefic information like name, version etc.. to e=
thtool.
> + */
> +static void vxge_ethtool_gdrvinfo(struct net_device *dev,
> +			struct ethtool_drvinfo *info)
> +{
> +	struct vxgedev *vdev;
> +	char version[80];
> +	vdev =3D (struct vxgedev *)netdev_priv(dev);
> +	sprintf(version, "%s", DRV_VERSION);

What is the point of this intermediate copy?

> +	strncpy(info->driver, VXGE_DRIVER_NAME, sizeof(VXGE_DRIVER_NAME));
> +	strncpy(info->version, version, sizeof(version));
> +	strncpy(info->fw_version, vdev->fw_version, VXGE_HW_FW_VERSION_LEN)=
;
> +	strncpy(info->bus_info, pci_name(vdev->pdev), sizeof(info->bus_info=
));
=EF=BB=BF
Use strlcpy() to ensure null-termination.

[...]
> +static int vxge_ethtool_idnic(struct net_device *dev, u32 data)
> +{
> +	u32 port[3] =3D {0, 1, 2};
> +	int i;
> +	struct vxgedev *vdev =3D (struct vxgedev *)netdev_priv(dev);
> +	struct __hw_device  *hldev =3D (struct __hw_device  *)
> +			pci_get_drvdata(vdev->pdev);
> +
> +	if (vdev->id_timer.function =3D=3D NULL) {
> +		init_timer(&vdev->id_timer);
> +		vdev->id_timer.function =3D vxge_phy_id;
> +		vdev->id_timer.data =3D (unsigned long) vdev;
> +	}
> +	mod_timer(&vdev->id_timer, jiffies);
> +	set_current_state(TASK_INTERRUPTIBLE);
> +	if (data)
> +		schedule_timeout(data * HZ);
> +	else
> +		schedule_timeout(MAX_SCHEDULE_TIMEOUT);

Just schedule() will do.

[...]
> +static u32 vxge_ethtool_op_get_tso(struct net_device *dev)
> +{
> +	return (dev->features & NETIF_F_TSO) !=3D 0;
> +}

This is the same as ethtool_op_get_tso; just point to that.

[...]
> +int vxge_ethtool_self_test_count(struct net_device *dev)
> +{
> +	return VXGE_TEST_LEN;
> +}
> +
> +static int vxge_ethtool_get_stats_count(struct net_device *dev)
> +{
> +	struct vxgedev *vdev =3D (struct vxgedev *)netdev_priv(dev);
> +	return VXGE_TITLE_LEN + (vdev->no_of_vpath *
> +		VXGE_HW_VPATH_STATS_LEN) +
> +		(vdev->max_config_port * VXGE_HW_AGGR_STATS_LEN) +
> +		(vdev->max_config_port * VXGE_HW_PORT_STATS_LEN) +
> +		(vdev->no_of_vpath * VXGE_HW_VPATH_TX_STATS_LEN) +
> +		(vdev->no_of_vpath * VXGE_HW_VPATH_RX_STATS_LEN) +
> +
> +		(vdev->no_of_vpath * VXGE_SW_STATS_LEN) + DRIVER_STAT_LEN;
> +
> +}

These operations are deprecated; you should implement get_strings_count
instead.

> +int vxge_ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
> +{
> +	if (data)
> +		dev->features |=3D NETIF_F_HW_CSUM;
> +	else
> +		dev->features &=3D ~NETIF_F_HW_CSUM;
> +
> +	return 0;
> +}

This is the same as ethtool_op_set_tx_hw_csum; just point to that.

[...]
> +struct ethtool_ops netdev_ethtool_ops =3D {
> +	.get_settings =3D vxge_ethtool_gset,
> +	.set_settings =3D vxge_ethtool_sset,
> +	.get_drvinfo =3D vxge_ethtool_gdrvinfo,
> +	.get_regs_len =3D vxge_ethtool_get_regs_len,
> +	.get_regs =3D vxge_ethtool_gregs,
> +	.get_link =3D ethtool_op_get_link,
> +
> +	.get_eeprom_len =3D vxge_get_eeprom_len,
> +
> +	.get_eeprom =3D NULL,
> +	.set_eeprom =3D NULL,

So what is the point of reporting the EEPROM length?

> +	.get_pauseparam =3D vxge_ethtool_getpause_data,
> +	.set_pauseparam =3D vxge_ethtool_setpause_data,
> +	.get_rx_csum =3D vxge_get_rx_csum,
> +	.set_rx_csum =3D vxge_set_rx_csum,
> +	.get_tx_csum =3D ethtool_op_get_tx_csum,
> +	.set_tx_csum =3D vxge_ethtool_op_set_tx_csum,
> +	.get_sg =3D ethtool_op_get_sg,
> +	.set_sg =3D ethtool_op_set_sg,
> +
> +	.get_tso =3D vxge_ethtool_op_get_tso,
> +	.set_tso =3D vxge_ethtool_op_set_tso,
> +
> +	.self_test_count =3D vxge_ethtool_self_test_count,
> +	.self_test =3D NULL,
[...]

Don't claim to have tests you don't actually implement.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

