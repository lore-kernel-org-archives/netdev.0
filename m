From: Borislav Petkov <bp@amd64.org>
Subject: Re: [PATCH rfc 5/5] r8169: provide some firmware information via
 ethtool.
Date: Thu, 28 Apr 2011 15:34:02 +0200
Message-ID: <20110428133402.GE10378@aftab>
References: <20110427203730.GH19708@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ciprian Docan <docan@eden.rutgers.edu>,
	Fejes =?iso-8859-1?Q?J=F3zsef?= <fejes@joco.name>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15228384.onlinehome-server.info ([87.106.30.177]:38904 "EHLO
	mail.x86-64.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799Ab1D1Nec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 09:34:32 -0400
Content-Disposition: inline
In-Reply-To: <20110427203730.GH19708@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 27, 2011 at 04:37:30PM -0400, Francois Romieu wrote:
> There is no real firmware version yet but the manpage of ethtool
> is rather terse about the driver information.
>=20
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Ciprian Docan <docan@eden.rutgers.edu>
> Cc: Fejes J=F3zsef <fejes@joco.name>
> Cc: Borislav Petkov <borislav.petkov@amd.com>
> Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
> ---
>  drivers/net/r8169.c |   45 +++++++++++++++++++++++++----------------=
----
>  1 files changed, 25 insertions(+), 20 deletions(-)
>=20
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 2606a20..76e81ac 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -1190,6 +1190,19 @@ static int rtl8169_set_wol(struct net_device *=
dev, struct ethtool_wolinfo *wol)
>  	return 0;
>  }
> =20
> +static const char *rtl_lookup_firmware_name(struct rtl8169_private *=
tp)
> +{
> +	int i;
> +
> +	for (i =3D 0; i < ARRAY_SIZE(rtl_firmware_infos); i++) {
> +		const struct rtl_firmware_info *info =3D rtl_firmware_infos + i;
> +
> +		if (info->mac_version =3D=3D tp->mac_version)
> +			return info->fw_name;
> +	}
> +	return NULL;
> +}
> +
>  static void rtl8169_get_drvinfo(struct net_device *dev,
>  				struct ethtool_drvinfo *info)
>  {
> @@ -1198,6 +1211,8 @@ static void rtl8169_get_drvinfo(struct net_devi=
ce *dev,
>  	strcpy(info->driver, MODULENAME);
>  	strcpy(info->version, RTL8169_VERSION);
>  	strcpy(info->bus_info, pci_name(tp->pci_dev));
> +	strncpy(info->fw_version, IS_ERR_OR_NULL(tp->fw) ? "N/A" :
> +		rtl_lookup_firmware_name(tp), sizeof(info->fw_version));
>  }
> =20
>  static int rtl8169_get_regs_len(struct net_device *dev)
> @@ -3502,33 +3517,23 @@ static void __devexit rtl8169_remove_one(stru=
ct pci_dev *pdev)
> =20
>  static void rtl_request_firmware(struct rtl8169_private *tp)
>  {
> -	int i;
> -
>  	/* Return early if the firmware is already loaded / cached. */
> -	if (!IS_ERR(tp->fw))
> -		goto out;
> -
> -	for (i =3D 0; i < ARRAY_SIZE(rtl_firmware_infos); i++) {
> -		const struct rtl_firmware_info *info =3D rtl_firmware_infos + i;
> +	if (IS_ERR(tp->fw)) {
> +		const char *name;
> =20
> -		if (info->mac_version =3D=3D tp->mac_version) {
> -			const char *name =3D info->fw_name;
> +		name =3D rtl_lookup_firmware_name(tp);
> +		if (name) {

Yep, looks good. Just a minor nitpick:

you could save yourself an indentation level by doing

		if (!name)
			continue;

so that the netif_warn() string below could stay unbroken for easier
grepping.

>  			int rc;
> =20
>  			rc =3D request_firmware(&tp->fw, name, &tp->pci_dev->dev);
> -			if (rc < 0) {
> -				netif_warn(tp, ifup, tp->dev, "unable to load "
> -					"firmware patch %s (%d)\n", name, rc);
> -				goto out_disable_request_firmware;
> -			}
> -			goto out;
> +			if (rc >=3D 0)
> +				return;
> +
> +			netif_warn(tp, ifup, tp->dev, "unable to load "
> +				"firmware patch %s (%d)\n", name, rc);
>  		}
> +		tp->fw =3D NULL;
>  	}
> -
> -out_disable_request_firmware:
> -	tp->fw =3D NULL;
> -out:
> -	return;
>  }
> =20
>  static int rtl8169_open(struct net_device *dev)
> --=20
> 1.7.4.4
>=20

Thanks.

--=20
Regards/Gruss,
Boris.

Advanced Micro Devices GmbH
Einsteinring 24, 85609 Dornach
General Managers: Alberto Bozzo, Andrew Bowd
Registration: Dornach, Gemeinde Aschheim, Landkreis Muenchen
Registergericht Muenchen, HRB Nr. 43632
