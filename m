From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH] net: mvneta: properly disable HW PHY polling and ensure
 adjust_link() works
Date: Wed, 04 Sep 2013 18:08:59 +0200
Message-ID: <52275B1B.8060405@free-electrons.com>
References: <1378304478-21237-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Lior Amsalem <alior@marvell.com>,
	Jochen De Smet <jochen.armkernel@leahnim.org>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Ryan Press <ryan@presslab.us>, vdonnefort@lacie.com,
	Ethan Tuttle <ethan@ethantuttle.com>, stable@vger.kernel.org,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	=?UTF-8?B?Q2jDqW55IFl2ZXMtR2FlbA==?= <yves@cheny.fr>,
	Peter Sanford <psanford@nearbuy.io>, Willy Tarreau <w@1wt.eu>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1378304478-21237-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/09/2013 16:21, Thomas Petazzoni wrote:
> This commit fixes a long-standing bug that has been reported by many
> users: on some Armada 370 platforms, only the network interface that
> has been used in U-Boot to tftp the kernel works properly in
> Linux. The other network interfaces can see a 'link up', but are
> unable to transmit data. The reports were generally made on the Armad=
a
> 370-based Mirabox, but have also been given on the Armada 370-RD
> board.
>=20
> The network MAC in the Armada 370/XP (supported by the mvneta driver
> in Linux) has a functionality that allows it to continuously poll the
> PHY and directly update the MAC configuration accordingly (speed,
> duplex, etc.). The very first versions of the driver submitted for
> review were using this hardware mechanism, but due to this, the drive=
r
> was not integrated with the kernel phylib. Following reviews, the
> driver was changed to use the phylib, and therefore a software based
> polling. In software based polling, Linux regularly talks to the PHY
> over the MDIO bus, and sees if the link status has changed. If it's
> the case then the adjust_link() callback of the driver is called to
> update the MAC configuration accordingly.
>=20
> However, it turns out that the adjust_link() callback was not
> configuring the hardware in a completely correct way: while it was
> setting the speed and duplex bits correctly, it wasn't telling the
> hardware to actually take into account those bits rather than what th=
e
> hardware-based PHY polling mechanism has concluded. So, in fact the
> adjust_link() callback was basically a no-op.
>=20
> However, the network happened to be working because on the network
> interfaces used by U-Boot for tftp on Armada 370 platforms because th=
e
> hardware PHY polling was enabled by the bootloader, and left enabled
> by Linux. However, the second network interface not used for tftp (or
> both network interfaces if the kernel is loaded from USB, NAND or SD
> card) didn't had the hardware PHY polling enabled.
>=20
> This patch fixes this situation by:
>=20
>  (1) Making sure that the hardware PHY polling is disabled by clearin=
g
>      the MVNETA_PHY_POLLING_ENABLE bit in the MVNETA_UNIT_CONTROL
>      register in the driver ->probe() function.
>=20
>  (2) Making sure that the duplex and speed selections made by the
>      adjust_link() callback are taken into account by clearing the
>      MVNETA_GMAC_AN_SPEED_EN and MVNETA_GMAC_AN_DUPLEX_EN bits in the
>      MVNETA_GMAC_AUTONEG_CONFIG register.
>=20
> This patch has been tested on Armada 370 Mirabox, and now both networ=
k
> interfaces are usable after boot.
>=20

Well done Thomas!

I have successfully tested it on Armada 370 Mirabox:

Tested-by: Gregory CLEMENT <gregory.clement@free-electrons.com>

Thanks

> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Cc: Willy Tarreau <w@1wt.eu>
> Cc: Jochen De Smet <jochen.armkernel@leahnim.org>
> Cc: Peter Sanford <psanford@nearbuy.io>
> Cc: Ethan Tuttle <ethan@ethantuttle.com>
> Cc: Ch=C3=A9ny Yves-Gael <yves@cheny.fr>
> Cc: Ryan Press <ryan@presslab.us>
> Cc: Simon Guinot <simon.guinot@sequanux.org>
> Cc: vdonnefort@lacie.com
> Cc: stable@vger.kernel.org
> ---
> David, this patch is a fix for a problem that has been here since 3.8
> (when the mvneta driver was introduced), so I've Cc'ed stable@ and if
> possible I'd like to patch to be included for 3.12.
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 13 ++++++++++++-
>  1 file changed, 12 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethe=
rnet/marvell/mvneta.c
> index b017818..90ab292 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -138,7 +138,9 @@
>  #define      MVNETA_GMAC_FORCE_LINK_PASS         BIT(1)
>  #define      MVNETA_GMAC_CONFIG_MII_SPEED        BIT(5)
>  #define      MVNETA_GMAC_CONFIG_GMII_SPEED       BIT(6)
> +#define      MVNETA_GMAC_AN_SPEED_EN             BIT(7)
>  #define      MVNETA_GMAC_CONFIG_FULL_DUPLEX      BIT(12)
> +#define      MVNETA_GMAC_AN_DUPLEX_EN            BIT(13)
>  #define MVNETA_MIB_COUNTERS_BASE                 0x3080
>  #define      MVNETA_MIB_LATE_COLLISION           0x7c
>  #define MVNETA_DA_FILT_SPEC_MCAST                0x3400
> @@ -915,6 +917,13 @@ static void mvneta_defaults_set(struct mvneta_po=
rt *pp)
>  	/* Assign port SDMA configuration */
>  	mvreg_write(pp, MVNETA_SDMA_CONFIG, val);
> =20
> +	/* Disable PHY polling in hardware, since we're using the
> +	 * kernel phylib to do this.
> +	 */
> +	val =3D mvreg_read(pp, MVNETA_UNIT_CONTROL);
> +	val &=3D ~MVNETA_PHY_POLLING_ENABLE;
> +	mvreg_write(pp, MVNETA_UNIT_CONTROL, val);
> +
>  	mvneta_set_ucast_table(pp, -1);
>  	mvneta_set_special_mcast_table(pp, -1);
>  	mvneta_set_other_mcast_table(pp, -1);
> @@ -2307,7 +2316,9 @@ static void mvneta_adjust_link(struct net_devic=
e *ndev)
>  			val =3D mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
>  			val &=3D ~(MVNETA_GMAC_CONFIG_MII_SPEED |
>  				 MVNETA_GMAC_CONFIG_GMII_SPEED |
> -				 MVNETA_GMAC_CONFIG_FULL_DUPLEX);
> +				 MVNETA_GMAC_CONFIG_FULL_DUPLEX |
> +				 MVNETA_GMAC_AN_SPEED_EN |
> +				 MVNETA_GMAC_AN_DUPLEX_EN);
> =20
>  			if (phydev->duplex)
>  				val |=3D MVNETA_GMAC_CONFIG_FULL_DUPLEX;
>=20


--=20
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
