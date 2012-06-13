From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next.git 1/4 (v5)] phy: add the EEE support and the way to
 access to the MMD registers.
Date: Thu, 14 Jun 2012 00:28:57 +0100
Message-ID: <1339630137.2612.83.camel@bwh-desktop.uk.solarflarecom.com>
References: <1339574463-1207-1-git-send-email-peppe.cavallaro@st.com>
	 <1339574463-1207-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>,
	<rayagond@vayavyalabs.com>, <davem@davemloft.net>,
	<yuvalmin@broadcom.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:61576 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754854Ab2FMX3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 19:29:02 -0400
In-Reply-To: <1339574463-1207-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-13 at 10:01 +0200, Giuseppe CAVALLARO wrote:
> This patch adds the support for the Energy-Efficient Ethernet (EEE)
> to the Physical Abstraction Layer.
> To support the EEE we have to access to the MMD registers 3.20 and
> 7.60/61. So two new functions have been added to read/write the MMD
> registers (clause 45).
>=20
> An Ethernet driver (I tested the stmmac) can invoke the phy_init_eee =
to properly
> check if the EEE is supported by the PHYs and it can also set the clo=
ck
> stop enable bit in the 3.0 register.
> The phy_get_eee_err can be used for reporting the number of time wher=
e
> the PHY failed to complete its normal wake sequence.
>=20
> In the end, this patch also adds the EEE ethtool support implementing=
:
>  o phy_ethtool_set_eee
>  o phy_ethtool_get_eee
>=20
> v1: initial patch
> v2: fixed some errors especially on naming convention
> v3: renamed again the mmd read/write functions thank to Ben's feedbac=
k
> v4: moved file to phy.c and added the ethtool support.
> v5: fixed phy_adv_to_eee, phy_eee_to_supported, phy_eee_to_adv return
>     values according to ethtool API (thanks to Ben's feedback).
>     Renamed some macros to avoid too long names.

Sorry, I spotted some more little issues:

[...]
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
[...]
> +/**
> + * phy_read_mmd_indirect - reads data from the MMC register (clause =
22 to
> + * access to clause 45)

The short description has to fit on the same line as the name; the
kernel-doc processing tools will not unwrap these two lines.

> + * @bus: the target MII bus
> + * @prtad: MMD Address
> + * @devad: MMD DEVAD
> + * @addr: PHY address on the MII bus
> + *
> + * Description: Reads data from the MMD regisetrs of the

Typo: regisetrs -> registers.

> + * phy addr. To read these register we have:
> + * 1) Write reg 13 // DEVAD
> + * 2) Write reg 14 // MMD Address
> + * 3) Write reg 13 // MMD Data Command for MMD DEVAD
> + * 3) Read  reg 14 // Read MMD data
> + */
> +static int phy_read_mmd_indirect(struct mii_bus *bus, int prtad, int=
 devad,
> +				 int addr)
> +{
> +	u32 ret;
> +
> +	mmd_phy_indirect(bus, prtad, devad, addr);
> +
> +	/* Read the content of the MMD's selected register */
> +	ret =3D bus->read(bus, addr, MII_MMD_DATA);
> +
> +	return ret;
> +}
> +
> +/**
> + * phy_write_mmd_indirect - writes data to the MMC register (clause =
22 to
> + * access to clause 45)

Same line-wrapping problem here.

> + * @bus: the target MII bus
> + * @prtad: MMD Address
> + * @devad: MMD DEVAD
> + * @addr: PHY address on the MII bus
> + * @data: data to write in the MMD register
> + *
> + * Description: Reads data from the MMD regisetrs of the
> + * phy addr. To read these register we have:
> + * 1) Write reg 13 // DEVAD
> + * 2) Write reg 14 // MMD Address
> + * 3) Write reg 13 // MMD Data Command for MMD DEVAD
> + * 3) Write reg 14 // Write MMD data
> + */
> +static void phy_write_mmd_indirect(struct mii_bus *bus, int prtad, i=
nt devad,
> +				   int addr, u32 data)
> +{
> +	mmd_phy_indirect(bus, prtad, devad, addr);
> +
> +	/* Write the data into MMD's selected register */
> +	bus->write(bus, addr, MII_MMD_DATA, data);
> +}
> +
> +/* phy_init_eee

If this is meant to be a kernel-doc comment, it needs to start with
'/**\n' and have a short summary must be added after the function name.

> + * @phydev: target phy_device struct
> + * @clk_stop_enable: PHY may stop the clock during LPI
> + *
> + * Description: it checks if the Energy-Efficient Ethernet (EEE)
> + * is supported by looking at the MMD registers 3.20 and 7.60/61
> + * and it programs the MMD register 3.0 setting the "Clock stop enab=
le"
> + * bit if required.
> + * In fact, the clk_stop_enable can be passed to:
> + *  1 =3D The PHY may stop the clock during LPI
> + *  0 =3D Clock not stoppable

I think these last three lines are redundant with the short description
of clk_stop_enable.

> + */
> +int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
> +{
> +	int ret =3D -EPROTONOSUPPORT;
> +
> +	/* According to 802.3az,the EEE is supported only in full duplex-mo=
de.
> +	 * Also EEE feature is active when core is operating with MII, GMII
> +	 * or RGMII.
> +	 */
> +	if ((phydev->duplex =3D=3D DUPLEX_FULL) &&
> +	    ((phydev->interface =3D=3D PHY_INTERFACE_MODE_MII) ||
> +	    (phydev->interface =3D=3D PHY_INTERFACE_MODE_GMII) ||
> +	    (phydev->interface =3D=3D PHY_INTERFACE_MODE_RGMII))) {
> +		int eee_cap, eee_link;
> +
> +		/* EEE ability must be supported in both local and remote
> +		 * PHY devices.
> +		 */
> +		eee_cap =3D phy_read_mmd_indirect(phydev->bus, MDIO_AN_EEE_LPABLE,
> +						MDIO_MMD_AN, phydev->addr);
> +		if (eee_cap < 0)
> +			return eee_cap;
> +
> +		eee_link =3D phy_read_mmd_indirect(phydev->bus, MDIO_PCS_EEE_ABLE,
> +						 MDIO_MMD_PCS, phydev->addr);
> +		if (eee_link < 0)
> +			return eee_link;
> +
> +		if (eee_cap && eee_link) {

I don't see any harm in setting the 'clock stop' bit if requested, even
if EEE is not supported and therefore we will never receive LPI from th=
e
link partner.

But you also use this condition to decide whether to enable TX LPI, so
it's important that it does match the specification (=C2=A778.3) for wh=
ether
EEE is supported - but it doesn't.  You need to work out what mode was
autonegotiated, then check that the relevant bit is set in both our EEE
advertising (*not* supported) and the LP EEE advertising masks.

[...]
> +/* phy_get_eee_err
[...]
> +/* phy_ethtool_get_eee
[...]
> +/* phy_ethtool_set_eee
[...]

Also not valid kernel-doc comments.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
