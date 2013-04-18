From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 05/15] igb: Support to read and export
 SFF-8472/8079 data
Date: Thu, 18 Apr 2013 16:37:48 -0700
Message-ID: <1366328268.2248.60.camel@jtkirshe-mobl>
References: <1366327822-10741-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1366327822-10741-6-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-RUCMpvESgCDo9W30h4Ku"
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	=?ISO-8859-1?Q?Aur=E9lien?= Guillaume <footplus@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1985 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936643Ab3DRXhu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 19:37:50 -0400
In-Reply-To: <1366327822-10741-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RUCMpvESgCDo9W30h4Ku
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-04-18 at 16:30 -0700, Jeff Kirsher wrote:
> From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>
>=20
> This patch adds support to read and export SFF-8472/8079 (SFP data)
> over i2c, through Ethtool.
>=20
> v2: Changed implementation to accommodate any offset within SFF module
>     length boundary.
>=20
> Reported-by: Aur=C3=A9lien Guillaume <footplus@gmail.com>
> CC: Aur=C3=A9lien Guillaume <footplus@gmail.com>
> CC: Ben Hutchings <bhuntchings@solarflare.com>

Looks like Akeem made a typo in your email Ben.

> Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/igb/igb.h         |  8 +++
>  drivers/net/ethernet/intel/igb/igb_ethtool.c | 81 ++++++++++++++++++++++=
++++++
>  2 files changed, 89 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/=
intel/igb/igb.h
> index 2515140..7cb0398 100644
> --- a/drivers/net/ethernet/intel/igb/igb.h
> +++ b/drivers/net/ethernet/intel/igb/igb.h
> @@ -178,6 +178,14 @@ enum igb_tx_flags {
>  #define TXD_USE_COUNT(S) DIV_ROUND_UP((S), IGB_MAX_DATA_PER_TXD)
>  #define DESC_NEEDED (MAX_SKB_FRAGS + 4)
> =20
> +/* EEPROM byte offsets */
> +#define IGB_SFF_8472_SWAP		0x5C
> +#define IGB_SFF_8472_COMP		0x5E
> +
> +/* Bitmasks */
> +#define IGB_SFF_ADDRESSING_MODE		0x4
> +#define IGB_SFF_8472_UNSUP		0x00
> +
>  /* wrapper around a pointer to a socket buffer,
>   * so a DMA handle can be stored along with the buffer */
>  struct igb_tx_buffer {
> diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/e=
thernet/intel/igb/igb_ethtool.c
> index 8499c48..6afd727 100644
> --- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
> +++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
> @@ -2622,6 +2622,85 @@ static int igb_set_eee(struct net_device *netdev,
>  	return 0;
>  }
> =20
> +static int igb_get_module_info(struct net_device *netdev,
> +			       struct ethtool_modinfo *modinfo)
> +{
> +	struct igb_adapter *adapter =3D netdev_priv(netdev);
> +	struct e1000_hw *hw =3D &adapter->hw;
> +	u32 status =3D E1000_SUCCESS;
> +	u16 sff8472_rev, addr_mode;
> +	bool page_swap =3D false;
> +
> +	if ((hw->phy.media_type =3D=3D e1000_media_type_copper) ||
> +	    (hw->phy.media_type =3D=3D e1000_media_type_unknown))
> +		return -EOPNOTSUPP;
> +
> +	/* Check whether we support SFF-8472 or not */
> +	status =3D igb_read_phy_reg_i2c(hw, IGB_SFF_8472_COMP, &sff8472_rev);
> +	if (status !=3D E1000_SUCCESS)
> +		return -EIO;
> +
> +	/* addressing mode is not supported */
> +	status =3D igb_read_phy_reg_i2c(hw, IGB_SFF_8472_SWAP, &addr_mode);
> +	if (status !=3D E1000_SUCCESS)
> +		return -EIO;
> +
> +	/* addressing mode is not supported */
> +	if ((addr_mode & 0xFF) & IGB_SFF_ADDRESSING_MODE) {
> +		hw_dbg("Address change required to access page 0xA2, but not supported=
. Please report the module type to the driver maintainers.\n");
> +		page_swap =3D true;
> +	}
> +
> +	if ((sff8472_rev & 0xFF) =3D=3D IGB_SFF_8472_UNSUP || page_swap) {
> +		/* We have an SFP, but it does not support SFF-8472 */
> +		modinfo->type =3D ETH_MODULE_SFF_8079;
> +		modinfo->eeprom_len =3D ETH_MODULE_SFF_8079_LEN;
> +	} else {
> +		/* We have an SFP which supports a revision of SFF-8472 */
> +		modinfo->type =3D ETH_MODULE_SFF_8472;
> +		modinfo->eeprom_len =3D ETH_MODULE_SFF_8472_LEN;
> +	}
> +
> +	return 0;
> +}
> +
> +static int igb_get_module_eeprom(struct net_device *netdev,
> +				 struct ethtool_eeprom *ee, u8 *data)
> +{
> +	struct igb_adapter *adapter =3D netdev_priv(netdev);
> +	struct e1000_hw *hw =3D &adapter->hw;
> +	u32 status =3D E1000_SUCCESS;
> +	u16 *dataword;
> +	u16 first_word, last_word;
> +	int i =3D 0;
> +
> +	if (ee->len =3D=3D 0)
> +		return -EINVAL;
> +
> +	first_word =3D ee->offset >> 1;
> +	last_word =3D (ee->offset + ee->len - 1) >> 1;
> +
> +	dataword =3D kmalloc(sizeof(u16) * (last_word - first_word + 1),
> +			   GFP_KERNEL);
> +	if (!dataword)
> +		return -ENOMEM;
> +
> +	/* Read EEPROM block, SFF-8079/SFF-8472, word at a time */
> +	for (i =3D 0; i < last_word - first_word + 1; i++) {
> +		status =3D igb_read_phy_reg_i2c(hw, first_word + i, &dataword[i]);
> +		if (status !=3D E1000_SUCCESS)
> +			/* Error occurred while reading module */
> +			return -EIO;
> +
> +		be16_to_cpus(&dataword[i]);
> +	}
> +
> +	memcpy(data, (u8 *)dataword + (ee->offset & 1), ee->len);
> +	kfree(dataword);
> +
> +	return 0;
> +}
> +
>  static int igb_ethtool_begin(struct net_device *netdev)
>  {
>  	struct igb_adapter *adapter =3D netdev_priv(netdev);
> @@ -2666,6 +2745,8 @@ static const struct ethtool_ops igb_ethtool_ops =3D=
 {
>  	.set_rxnfc		=3D igb_set_rxnfc,
>  	.get_eee		=3D igb_get_eee,
>  	.set_eee		=3D igb_set_eee,
> +	.get_module_info	=3D igb_get_module_info,
> +	.get_module_eeprom	=3D igb_get_module_eeprom,
>  	.begin			=3D igb_ethtool_begin,
>  	.complete		=3D igb_ethtool_complete,
>  };



--=-RUCMpvESgCDo9W30h4Ku
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRcIPMAAoJEOVv75VaS+3O0VQQAIvcfOKeWkDAweTv5T9SOSQL
KOXTXuoUDBhEvsKoB7exHbFUzBEXgHZXBO74Ete45X+FkUwKDNvHWbVuF50rIYeZ
/A4QRYH8FKDxZVeU0TFM5Xo4qPGPqwIZg1JkeGSgFpzNTepCb6GX3O4MvzAbaEQM
NPuSeh9umpCStf1t3WckW2PpAkFtf64QwZNJa5BnFZXs4/Z31ANGTiXSSp2xrsiu
bFD4h4Tl/L+hUAH+uT00z9f98tpozpAMSpDTqwuodygd2qEdtndGl7nTBaKBbhBK
dkAhojCmnogXuLJiEX4hY2HmktdMzNpNmQV9HeuxanF3i1cDf9w3FN57v9qXYN+f
MTJyXxiwRVmkOcRLqQ5Ppn91r+LO0Ml3XxRyrxKIRumKQ/TF5Kh8cg2Hx1LHabSO
njWCahAVO0VHRyDKiDitp5/BPgiVXg18f8oY0cMUh+7LXWN0j3glGEDspDdh0vWC
E+eIuASSDZbrmKzpe3M9j0RWW25+s9pgsWjbihjc1xf7NSZn1unBWn7jkc4p/1iR
ZLltJduL6ViRXxhzzCsVGmPJAOOO89saEPdgZeWtcc+aOe+VtikOcyD7VRCaCDzi
N1Bzz7mA6Xruf4StbYaP7Qi5YKmDw32kirKilxMH7lXgelH50YyAUNSJOzQAoOz3
sN20ghKfjAA92PTqK6ro
=Kmr2
-----END PGP SIGNATURE-----

--=-RUCMpvESgCDo9W30h4Ku--
