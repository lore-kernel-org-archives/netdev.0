From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 1/1] alx: add a simple AR816x/AR817x device driver
Date: Tue, 18 Jun 2013 02:18:06 +0100
Message-ID: <1371518286.3495.60.camel@deadeye.wl.decadent.org.uk>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1370899746-14219-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-VuAr50JaUHMZJ1/BsKrs"
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51295 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751763Ab3FRBSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 21:18:16 -0400
In-Reply-To: <1370899746-14219-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-VuAr50JaUHMZJ1/BsKrs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-06-10 at 23:29 +0200, Johannes Berg wrote:
> This is a very simple driver, based on the original vendor
> driver that Qualcomm/Atheros published/submitted previously.
> I have heavily reworked the driver to be a bit saner, and
> in the process removed a number of features: TSO/GSO, VLAN
> acceleration and multiqueue. I've also ruthlessly stripped
> things not useful to me, e.g. register access support.
>=20
> Right now it only supports a single TX and RX queue and no
> special features other than checksum offload.
[...]
> --- a/drivers/net/ethernet/atheros/Kconfig
> +++ b/drivers/net/ethernet/atheros/Kconfig
> @@ -67,4 +67,22 @@ config ATL1C
>  	  To compile this driver as a module, choose M here.  The module
>  	  will be called atl1c.
> =20
> +config ALX
> +	tristate "Qualcomm Atheros AR816x/AR817x support"
> +	depends on PCI
> +	select CRC32
> +	select NET_CORE

Why NET_CORE?  It looks like a lot of drivers are selecting it because
MII depends on it, but this doesn't select MII.  (Actually, it's
ridiculous that MII depends on NET_CORE.  I'll see what I can do about
that.)

[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/alx.h
[...]
> +struct alx_priv {
> +	struct net_device *dev;
> +
> +	struct alx_hw hw;
> +
> +	/* all descriptor memory */
> +	struct {
> +		dma_addr_t dma;
> +		void *virt;
> +		int size;
> +	} descmem;
> +
> +	u32 int_mask;
> +
> +	int tx_ringsz;
> +	int rx_ringsz;
> +	int rxbuf_size;

Sizes could all be unsigned?

[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/ethtool.c
[...]
> +static int alx_get_settings(struct net_device *netdev, struct ethtool_cm=
d *ecmd)
> +{
> +	struct alx_priv *alx =3D netdev_priv(netdev);
> +	struct alx_hw *hw =3D &alx->hw;
> +
> +	ecmd->supported =3D SUPPORTED_10baseT_Half |
> +			  SUPPORTED_10baseT_Full |
> +			  SUPPORTED_100baseT_Half |
> +			  SUPPORTED_100baseT_Full |
> +			  SUPPORTED_Autoneg |
> +			  SUPPORTED_TP |
> +			  SUPPORTED_Pause;
> +	if (alx_hw_giga(hw))
> +		ecmd->supported |=3D SUPPORTED_1000baseT_Full;
> +
> +	ecmd->advertising =3D ADVERTISED_TP;
> +	if (hw->adv_cfg & ADVERTISED_Autoneg)
> +		ecmd->advertising |=3D hw->adv_cfg;
> +
> +	ecmd->port =3D PORT_TP;
> +	ecmd->phy_address =3D 0;
> +	if (hw->adv_cfg & ADVERTISED_Autoneg)
> +		ecmd->autoneg =3D AUTONEG_ENABLE;
> +	else
> +		ecmd->autoneg =3D AUTONEG_DISABLE;
> +	ecmd->transceiver =3D XCVR_INTERNAL;
> +
> +	if (hw->flowctrl & ALX_FC_ANEG && hw->adv_cfg & ADVERTISED_Autoneg) {
> +		if (hw->flowctrl & ALX_FC_RX) {
> +			ecmd->advertising |=3D ADVERTISED_Pause;
> +
> +			if (!(hw->flowctrl & ALX_FC_TX))
> +				ecmd->advertising |=3D ADVERTISED_Asym_Pause;
> +		} else if (hw->flowctrl & ALX_FC_TX) {
> +			ecmd->advertising |=3D ADVERTISED_Asym_Pause;
> +		}

If Asym_Pause can be advertised then it should be in the supported mask
too...

> +	}
> +
> +	if (hw->link_speed !=3D SPEED_UNKNOWN) {
> +		ethtool_cmd_speed_set(ecmd,
> +				      hw->link_speed - hw->link_speed % 10);
> +		ecmd->duplex =3D hw->link_speed % 10;

Please use separate fields for speed and duplex.

> +	} else {
> +		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
> +		ecmd->duplex =3D DUPLEX_UNKNOWN;
> +	}
> +
> +	return 0;
> +}
> +
> +static int alx_set_settings(struct net_device *netdev, struct ethtool_cm=
d *ecmd)
> +{
> +	struct alx_priv *alx =3D netdev_priv(netdev);
> +	struct alx_hw *hw =3D &alx->hw;
> +	u32 adv_cfg;
> +
> +	ASSERT_RTNL();
> +
> +	if (ecmd->autoneg =3D=3D AUTONEG_ENABLE) {
> +		if (ecmd->advertising & ADVERTISED_1000baseT_Half)
> +			return -EINVAL;

Now what about 10000, 40000, etc...  You should break out the code that
sets ecmd->supported from alx_get_settings() and then do something like:

	if (ecmd->advertising & ~alx_get_supported_mask())
		return -EINVAL;

here.

> +		adv_cfg =3D ecmd->advertising | ADVERTISED_Autoneg;
> +	} else {
> +		int speed =3D ethtool_cmd_speed(ecmd);
> +
> +		switch (speed + ecmd->duplex) {
> +		case SPEED_10 + DUPLEX_HALF:
> +			adv_cfg =3D ADVERTISED_10baseT_Half;
> +			break;
> +		case SPEED_10 + DUPLEX_FULL:
> +			adv_cfg =3D ADVERTISED_10baseT_Full;
> +			break;
> +		case SPEED_100 + DUPLEX_HALF:
> +			adv_cfg =3D ADVERTISED_100baseT_Half;
> +			break;
> +		case SPEED_100 + DUPLEX_FULL:
> +			adv_cfg =3D ADVERTISED_100baseT_Full;
> +			break;
> +		default:
> +			return -EINVAL;
> +		}
> +	}
> +
> +	hw->adv_cfg =3D adv_cfg;
> +	return alx_setup_speed_duplex(hw, adv_cfg, hw->flowctrl);
> +}
> +
> +static void alx_get_pauseparam(struct net_device *netdev,
> +			       struct ethtool_pauseparam *pause)
> +{
> +	struct alx_priv *alx =3D netdev_priv(netdev);
> +	struct alx_hw *hw =3D &alx->hw;
> +
> +	if (hw->flowctrl & ALX_FC_ANEG &&
> +	    hw->adv_cfg & ADVERTISED_Autoneg)
> +		pause->autoneg =3D AUTONEG_ENABLE;
> +	else
> +		pause->autoneg =3D AUTONEG_DISABLE;

Those macros are meant for ethtool_cmd::autoneg, not
ethtool_pauseparam::autoneg.  (Not that it makes the slightest
difference in practice.)

> +	if (hw->flowctrl & ALX_FC_TX)
> +		pause->tx_pause =3D 1;
> +	else
> +		pause->tx_pause =3D 0;
> +
> +	if (hw->flowctrl & ALX_FC_RX)
> +		pause->rx_pause =3D 1;
> +	else
> +		pause->rx_pause =3D 0;

Could be written more concisely as pause->tx_pause =3D !!(hw_flowtrl &
ALX_FC_TX) etc.

> +}
> +
> +
> +static int alx_set_pauseparam(struct net_device *netdev,
> +			      struct ethtool_pauseparam *pause)
> +{
> +	struct alx_priv *alx =3D netdev_priv(netdev);
> +	struct alx_hw *hw =3D &alx->hw;
> +	int err =3D 0;
> +	bool reconfig_phy =3D false;
> +	u8 fc =3D 0;
> +
> +	if (pause->tx_pause)
> +		fc |=3D ALX_FC_TX;
> +	if (pause->rx_pause)
> +		fc |=3D ALX_FC_RX;
> +	if (pause->autoneg)
> +		fc |=3D ALX_FC_ANEG;
> +
> +	ASSERT_RTNL();
> +
> +	/* restart auto-neg for auto-mode */
> +	if (hw->adv_cfg & ADVERTISED_Autoneg) {
> +		if (!((fc ^ hw->flowctrl) & ALX_FC_ANEG))
> +			reconfig_phy =3D true;
> +		if (fc & hw->flowctrl & ALX_FC_ANEG &&
> +		    (fc ^ hw->flowctrl) & (ALX_FC_RX | ALX_FC_TX))
> +			reconfig_phy =3D true;
> +	}
> +
> +	if (reconfig_phy) {
> +		err =3D alx_setup_speed_duplex(hw, hw->adv_cfg, fc);
> +		return err;
> +	}
> +
> +	/* flow control on mac */
> +	if ((fc ^ hw->flowctrl) & (ALX_FC_RX | ALX_FC_TX))
> +		alx_cfg_mac_flowcontrol(hw, fc);
> +
> +	hw->flowctrl =3D fc;

This assignment is needed in the autoneg case too.

> +	return 0;
> +}
[...]
> +static void alx_get_wol(struct net_device *netdev, struct ethtool_wolinf=
o *wol)
> +{
> +	struct alx_priv *alx =3D netdev_priv(netdev);
> +	struct alx_hw *hw =3D &alx->hw;
> +
> +	wol->supported =3D WAKE_MAGIC | WAKE_PHY;
> +	wol->wolopts =3D 0;
> +
> +	if (hw->sleep_ctrl & ALX_SLEEP_WOL_MAGIC)
> +		wol->wolopts |=3D WAKE_MAGIC;
> +	if (hw->sleep_ctrl & ALX_SLEEP_WOL_PHY)
> +		wol->wolopts |=3D WAKE_PHY;
> +}
> +
> +static int alx_set_wol(struct net_device *netdev, struct ethtool_wolinfo=
 *wol)
> +{
> +	struct alx_priv *alx =3D netdev_priv(netdev);
> +	struct alx_hw *hw =3D &alx->hw;
> +
> +	if (wol->wolopts & (WAKE_ARP | WAKE_MAGICSECURE |
> +			    WAKE_UCAST | WAKE_BCAST | WAKE_MCAST))
> +		return -EOPNOTSUPP;

What if we define a new WOL mode?  And the operation is supported, just
not with the given mode.  So:

	if (wol->wolopts & ~(WAKE_MAGIC | WAKE_PHY))
		return -EINVAL;

> +	hw->sleep_ctrl =3D 0;
> +
> +	if (wol->wolopts & WAKE_MAGIC)
> +		hw->sleep_ctrl |=3D ALX_SLEEP_WOL_MAGIC;
> +	if (wol->wolopts & WAKE_PHY)
> +		hw->sleep_ctrl |=3D ALX_SLEEP_WOL_PHY;
> +
> +	device_set_wakeup_enable(&alx->hw.pdev->dev, hw->sleep_ctrl);
> +
> +	return 0;
> +}
> +
> +static void alx_get_drvinfo(struct net_device *netdev,
> +			    struct ethtool_drvinfo *drvinfo)
> +{
> +	struct alx_priv *alx =3D netdev_priv(netdev);
> +
> +	strlcpy(drvinfo->driver, alx_drv_name, sizeof(drvinfo->driver));
> +	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
> +	strlcpy(drvinfo->bus_info, pci_name(alx->hw.pdev),
> +		sizeof(drvinfo->bus_info));
> +}

There is no need to implement get_drvinfo, as the ethtool core provides
this information by default.

[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/atheros/alx/hw.c
[...]
> +int alx_get_perm_macaddr(struct alx_hw *hw, u8 *addr)
> +{
> +	u32 val, mac0, mac1;
> +	u16 i;
> +	bool loaded_intn =3D false, loaded_extn =3D false;
> +
> +read_mcadr:
> +	/* try to get it from register first */
> +	mac0 =3D alx_read_mem32(hw, ALX_STAD0);
> +	mac1 =3D alx_read_mem32(hw, ALX_STAD1);
> +
> +	/* addr should be big-endian */
> +	*(__be32 *)(addr + 2) =3D cpu_to_be32(mac0);

This is a potential alignment error.  Better to break out the bytes one
by one, I think.

> +	*(__be16 *)addr =3D cpu_to_be16(mac1);
> +
> +	if (is_valid_ether_addr(addr))
> +		return 0;
[...]
> +void alx_set_macaddr(struct alx_hw *hw, const u8 *addr)
> +{
> +	u32 val;
> +
> +	/* for example: 00-0B-6A-F6-00-DC * STAD0=3D6AF600DC, STAD1=3D000B */
> +	val =3D be32_to_cpu(*(__be32 *)(addr + 2));

Again here.

> +	alx_write_mem32(hw, ALX_STAD0, val);
> +	val =3D be16_to_cpu(*(__be16 *)addr);
> +	alx_write_mem32(hw, ALX_STAD1, val);
> +}
[...]
> +void alx_add_mc_addr(struct alx_hw *hw, const u8 *addr)
> +{
> +	u32 crc32, bit, reg;
> +
> +	crc32 =3D ether_crc(ETH_ALEN, addr);
> +
> +	/* The HASH Table  is a register array of 2 32-bit registers.
> +	 * It is treated like an array of 64 bits.  We want to set
> +	 * bit BitArray[hash_value]. So we figure out what register
> +	 * the bit is in, read it, OR in the new bit, then write
> +	 * back the new value.  The register is determined by the
> +	 * upper 7 bits of the hash value and the bit within that

Just bit 5, not the upper 7 bits!

> +	 * register are determined by the lower 5 bits of the value.
> +	 */
> +	reg =3D (crc32 >> 31) & 0x1;
> +	bit =3D (crc32 >> 26) & 0x1F;
> +
> +	hw->mc_hash[reg] |=3D BIT(bit);
> +}
[...]
> +void alx_reset_pcie(struct alx_hw *hw)
> +{
> +	u8 rev =3D alx_hw_revision(hw);
> +	u32 val;
> +	u16 val16;
> +
> +	/* Workaround for PCI problem when BIOS sets MMRBC incorrectly. */
> +	pci_read_config_word(hw->pdev, PCI_COMMAND, &val16);
> +	if (!(val16 & ALX_PCI_CMD) || (val16 & PCI_COMMAND_INTX_DISABLE)) {
> +		val16 =3D (val16 | ALX_PCI_CMD) & ~PCI_COMMAND_INTX_DISABLE;
> +		pci_write_config_word(hw->pdev, PCI_COMMAND, val16);
> +	}
[...]

I don't understand what this is trying to work around but it looks
extremely dodgy.  The driver already appears to be doing
pci_{save,restore}_state() in suspend/resume which is the right thing to
do.

I haven't looked at main.c but might spend some time on that later.

I couldn't find where auto-negotiated flow control is programmed after
the link comes up.  Maybe it isn't?

Ben.

--=20
Ben Hutchings
Humans are not rational beings; they are rationalising beings.

--=-VuAr50JaUHMZJ1/BsKrs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUb+1Tue/yOyVhhEJAQrzKxAAnPK8dBZ+NLRRkZynOGRNwktrzkGpYZlN
a8ByMfcYmIJBovU7pXvjI5dgvxzkEiTOWIAsMqjI7rYkvqk79a2LAlziJFOEMuUb
Fi7HuD/5E8OBfgFnUR2wAvsASJuehjKOIG5xjtTvVcCn3FOgeM+YmBFkGsrsN3Uo
gncB1nYi0hig8uGWxfe+wFUp4cEhuRVoYkM0Ns4tyUTkT9/6glvE5Sc0HJ75LwB6
BOZNh1vUvq+gsPUG9I8WyyWbgNsRDapJTVk/FPVnmb1y9myRCdXtkm1fCpBR1Amo
pRjm+Xe7HMv4PdHDf1hPZNkXL3xwcNTyxaXv/98sQZmj0U91HV9dB//vKLjxwfrE
WTuLQfOOKC/0vCwe0wC2uF+w3nYldqQ0bVD4zxTACG00z6+WX6mvvVdWfqeF/cuf
1lZ3UhBCi6vuwRfF0SkOFXsTYRKSpTKT0Ar5IcdWiwjA/mBWK+7u1AO5ns/fWQLM
pEwRG6p+NR/LdNQsxqhXzMJq/MUb6FcVmltJ5MVbGYijuqqZ41iRvd3uQ7QpdLwB
H6F6PV8s7/EYlc+M6P91qtWoUVGqHjmQ7j08/zlYhx3x0hIIfdDEIx5hEq47G2UM
stVLq6HurgydYQDtk0g+NBt3qgWF/jzEZvzRr44TpEtqSyW89OsRpV4XdDl81vXB
/KjMompWo/g=
=aYfQ
-----END PGP SIGNATURE-----

--=-VuAr50JaUHMZJ1/BsKrs--
