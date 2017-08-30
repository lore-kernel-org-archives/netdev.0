From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next v4 02/13] phy: add the mvebu cp110 comphy driver
Date: Wed, 30 Aug 2017 13:39:47 +0200
Message-ID: <20170830113947.GI31552@kwain>
References: <20170830082924.3180-1-antoine.tenart@free-electrons.com>
 <20170830082924.3180-3-antoine.tenart@free-electrons.com>
 <088b395c-35cd-9af7-5171-2d0fdd31d144@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="l0l+eSofNeLXHSnY"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, andrew@lunn.ch, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <088b395c-35cd-9af7-5171-2d0fdd31d144@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--l0l+eSofNeLXHSnY
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Kishon,

On Wed, Aug 30, 2017 at 05:02:55PM +0530, Kishon Vijay Abraham I wrote:
> On Wednesday 30 August 2017 01:59 PM, Antoine Tenart wrote:
> > On the CP110 unit, which can be found on various Marvell platforms such
> > as the 7k and 8k (currently), a comphy (common PHYs) hardware block can
> > be found. This block provides a number of PHYs which can be used in
> > various modes by other controllers (network, SATA ...). These common
> > PHYs must be configured for the controllers using them to work correctly
> > either at boot time, or when the system runs to switch the mode used.
> > This patch adds a driver for this comphy hardware block, providing
> > callbacks for the its PHYs so that consumers can configure the modes
> > used.
> >=20
> > As of this commit, two modes are supported by the comphy driver: sgmii
> > and 10gkr.
> >=20
> > Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
>=20
> Acked-by: Kishon Vijay Abraham I <kishon@ti.com>

Thanks for the review!

@Dave: As stated by Kishon in the previous version of the series, the
       two generic PHY patches can go through the net-next tree.

Thanks,
Antoine

> > ---
> >  drivers/phy/marvell/Kconfig                  |  11 +
> >  drivers/phy/marvell/Makefile                 |   1 +
> >  drivers/phy/marvell/phy-mvebu-cp110-comphy.c | 644 +++++++++++++++++++=
++++++++
> >  3 files changed, 656 insertions(+)
> >  create mode 100644 drivers/phy/marvell/phy-mvebu-cp110-comphy.c
> >=20
> > diff --git a/drivers/phy/marvell/Kconfig b/drivers/phy/marvell/Kconfig
> > index 048d8893bc2e..68e321225400 100644
> > --- a/drivers/phy/marvell/Kconfig
> > +++ b/drivers/phy/marvell/Kconfig
> > @@ -21,6 +21,17 @@ config PHY_BERLIN_USB
> >  	help
> >  	  Enable this to support the USB PHY on Marvell Berlin SoCs.
> > =20
> > +config PHY_MVEBU_CP110_COMPHY
> > +	tristate "Marvell CP110 comphy driver"
> > +	depends on ARCH_MVEBU || COMPILE_TEST
> > +	depends on OF
> > +	select GENERIC_PHY
> > +	help
> > +	  This driver allows to control the comphy, an hardware block providi=
ng
> > +	  shared serdes PHYs on Marvell Armada 7k/8k (in the CP110). Its serd=
es
> > +	  lanes can be used by various controllers (Ethernet, sata, usb,
> > +	  PCIe...).
> > +
> >  config PHY_MVEBU_SATA
> >  	def_bool y
> >  	depends on ARCH_DOVE || MACH_DOVE || MACH_KIRKWOOD
> > diff --git a/drivers/phy/marvell/Makefile b/drivers/phy/marvell/Makefile
> > index 3fc188f59118..0cf6a7cbaf9f 100644
> > --- a/drivers/phy/marvell/Makefile
> > +++ b/drivers/phy/marvell/Makefile
> > @@ -1,6 +1,7 @@
> >  obj-$(CONFIG_ARMADA375_USBCLUSTER_PHY)	+=3D phy-armada375-usb2.o
> >  obj-$(CONFIG_PHY_BERLIN_SATA)		+=3D phy-berlin-sata.o
> >  obj-$(CONFIG_PHY_BERLIN_USB)		+=3D phy-berlin-usb.o
> > +obj-$(CONFIG_PHY_MVEBU_CP110_COMPHY)	+=3D phy-mvebu-cp110-comphy.o
> >  obj-$(CONFIG_PHY_MVEBU_SATA)		+=3D phy-mvebu-sata.o
> >  obj-$(CONFIG_PHY_PXA_28NM_HSIC)		+=3D phy-pxa-28nm-hsic.o
> >  obj-$(CONFIG_PHY_PXA_28NM_USB2)		+=3D phy-pxa-28nm-usb2.o
> > diff --git a/drivers/phy/marvell/phy-mvebu-cp110-comphy.c b/drivers/phy=
/marvell/phy-mvebu-cp110-comphy.c
> > new file mode 100644
> > index 000000000000..73ebad6634a7
> > --- /dev/null
> > +++ b/drivers/phy/marvell/phy-mvebu-cp110-comphy.c
> > @@ -0,0 +1,644 @@
> > +/*
> > + * Copyright (C) 2017 Marvell
> > + *
> > + * Antoine Tenart <antoine.tenart@free-electrons.com>
> > + *
> > + * This file is licensed under the terms of the GNU General Public
> > + * License version 2. This program is licensed "as is" without any
> > + * warranty of any kind, whether express or implied.
> > + */
> > +
> > +#include <linux/io.h>
> > +#include <linux/iopoll.h>
> > +#include <linux/mfd/syscon.h>
> > +#include <linux/module.h>
> > +#include <linux/phy/phy.h>
> > +#include <linux/platform_device.h>
> > +#include <linux/regmap.h>
> > +
> > +/* Relative to priv->base */
> > +#define MVEBU_COMPHY_SERDES_CFG0(n)		(0x0 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_SERDES_CFG0_PU_PLL	BIT(1)
> > +#define     MVEBU_COMPHY_SERDES_CFG0_GEN_RX(n)	((n) << 3)
> > +#define     MVEBU_COMPHY_SERDES_CFG0_GEN_TX(n)	((n) << 7)
> > +#define     MVEBU_COMPHY_SERDES_CFG0_PU_RX	BIT(11)
> > +#define     MVEBU_COMPHY_SERDES_CFG0_PU_TX	BIT(12)
> > +#define     MVEBU_COMPHY_SERDES_CFG0_HALF_BUS	BIT(14)
> > +#define MVEBU_COMPHY_SERDES_CFG1(n)		(0x4 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_SERDES_CFG1_RESET	BIT(3)
> > +#define     MVEBU_COMPHY_SERDES_CFG1_RX_INIT	BIT(4)
> > +#define     MVEBU_COMPHY_SERDES_CFG1_CORE_RESET	BIT(5)
> > +#define     MVEBU_COMPHY_SERDES_CFG1_RF_RESET	BIT(6)
> > +#define MVEBU_COMPHY_SERDES_CFG2(n)		(0x8 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_SERDES_CFG2_DFE_EN	BIT(4)
> > +#define MVEBU_COMPHY_SERDES_STATUS0(n)		(0x18 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_SERDES_STATUS0_TX_PLL_RDY	BIT(2)
> > +#define     MVEBU_COMPHY_SERDES_STATUS0_RX_PLL_RDY	BIT(3)
> > +#define     MVEBU_COMPHY_SERDES_STATUS0_RX_INIT		BIT(4)
> > +#define MVEBU_COMPHY_PWRPLL_CTRL(n)		(0x804 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_PWRPLL_CTRL_RFREQ(n)	((n) << 0)
> > +#define     MVEBU_COMPHY_PWRPLL_PHY_MODE(n)	((n) << 5)
> > +#define MVEBU_COMPHY_IMP_CAL(n)			(0x80c + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_IMP_CAL_TX_EXT(n)	((n) << 10)
> > +#define     MVEBU_COMPHY_IMP_CAL_TX_EXT_EN	BIT(15)
> > +#define MVEBU_COMPHY_DFE_RES(n)			(0x81c + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_DFE_RES_FORCE_GEN_TBL	BIT(15)
> > +#define MVEBU_COMPHY_COEF(n)			(0x828 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_COEF_DFE_EN		BIT(14)
> > +#define     MVEBU_COMPHY_COEF_DFE_CTRL		BIT(15)
> > +#define MVEBU_COMPHY_GEN1_S0(n)			(0x834 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_GEN1_S0_TX_AMP(n)	((n) << 1)
> > +#define     MVEBU_COMPHY_GEN1_S0_TX_EMPH(n)	((n) << 7)
> > +#define MVEBU_COMPHY_GEN1_S1(n)			(0x838 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_GEN1_S1_RX_MUL_PI(n)	((n) << 0)
> > +#define     MVEBU_COMPHY_GEN1_S1_RX_MUL_PF(n)	((n) << 3)
> > +#define     MVEBU_COMPHY_GEN1_S1_RX_MUL_FI(n)	((n) << 6)
> > +#define     MVEBU_COMPHY_GEN1_S1_RX_MUL_FF(n)	((n) << 8)
> > +#define     MVEBU_COMPHY_GEN1_S1_RX_DFE_EN	BIT(10)
> > +#define     MVEBU_COMPHY_GEN1_S1_RX_DIV(n)	((n) << 11)
> > +#define MVEBU_COMPHY_GEN1_S2(n)			(0x8f4 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_GEN1_S2_TX_EMPH(n)	((n) << 0)
> > +#define     MVEBU_COMPHY_GEN1_S2_TX_EMPH_EN	BIT(4)
> > +#define MVEBU_COMPHY_LOOPBACK(n)		(0x88c + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_LOOPBACK_DBUS_WIDTH(n)	((n) << 1)
> > +#define MVEBU_COMPHY_VDD_CAL0(n)		(0x908 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_VDD_CAL0_CONT_MODE	BIT(15)
> > +#define MVEBU_COMPHY_EXT_SELV(n)		(0x914 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_EXT_SELV_RX_SAMPL(n)	((n) << 5)
> > +#define MVEBU_COMPHY_MISC_CTRL0(n)		(0x93c + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_MISC_CTRL0_ICP_FORCE	BIT(5)
> > +#define     MVEBU_COMPHY_MISC_CTRL0_REFCLK_SEL	BIT(10)
> > +#define MVEBU_COMPHY_RX_CTRL1(n)		(0x940 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_RX_CTRL1_RXCLK2X_SEL	BIT(11)
> > +#define     MVEBU_COMPHY_RX_CTRL1_CLK8T_EN	BIT(12)
> > +#define MVEBU_COMPHY_SPEED_DIV(n)		(0x954 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_SPEED_DIV_TX_FORCE	BIT(7)
> > +#define MVEBU_SP_CALIB(n)			(0x96c + (n) * 0x1000)
> > +#define     MVEBU_SP_CALIB_SAMPLER(n)		((n) << 8)
> > +#define     MVEBU_SP_CALIB_SAMPLER_EN		BIT(12)
> > +#define MVEBU_COMPHY_TX_SLEW_RATE(n)		(0x974 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_TX_SLEW_RATE_EMPH(n)	((n) << 5)
> > +#define     MVEBU_COMPHY_TX_SLEW_RATE_SLC(n)	((n) << 10)
> > +#define MVEBU_COMPHY_DLT_CTRL(n)		(0x984 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_DLT_CTRL_DTL_FLOOP_EN	BIT(2)
> > +#define MVEBU_COMPHY_FRAME_DETECT0(n)		(0xa14 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_FRAME_DETECT0_PATN(n)	((n) << 7)
> > +#define MVEBU_COMPHY_FRAME_DETECT3(n)		(0xa20 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_FRAME_DETECT3_LOST_TIMEOUT_EN	BIT(12)
> > +#define MVEBU_COMPHY_DME(n)			(0xa28 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_DME_ETH_MODE		BIT(7)
> > +#define MVEBU_COMPHY_TRAINING0(n)		(0xa68 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_TRAINING0_P2P_HOLD	BIT(15)
> > +#define MVEBU_COMPHY_TRAINING5(n)		(0xaa4 + (n) * 0x1000)
> > +#define	    MVEBU_COMPHY_TRAINING5_RX_TIMER(n)	((n) << 0)
> > +#define MVEBU_COMPHY_TX_TRAIN_PRESET(n)		(0xb1c + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_TX_TRAIN_PRESET_16B_AUTO_EN	BIT(8)
> > +#define     MVEBU_COMPHY_TX_TRAIN_PRESET_PRBS11		BIT(9)
> > +#define MVEBU_COMPHY_GEN1_S3(n)			(0xc40 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_GEN1_S3_FBCK_SEL	BIT(9)
> > +#define MVEBU_COMPHY_GEN1_S4(n)			(0xc44 + (n) * 0x1000)
> > +#define	    MVEBU_COMPHY_GEN1_S4_DFE_RES(n)	((n) << 8)
> > +#define MVEBU_COMPHY_TX_PRESET(n)		(0xc68 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_TX_PRESET_INDEX(n)	((n) << 0)
> > +#define MVEBU_COMPHY_GEN1_S5(n)			(0xd38 + (n) * 0x1000)
> > +#define     MVEBU_COMPHY_GEN1_S5_ICP(n)		((n) << 0)
> > +
> > +/* Relative to priv->regmap */
> > +#define MVEBU_COMPHY_CONF1(n)			(0x1000 + (n) * 0x28)
> > +#define     MVEBU_COMPHY_CONF1_PWRUP		BIT(1)
> > +#define     MVEBU_COMPHY_CONF1_USB_PCIE		BIT(2)	/* 0: Ethernet/SATA */
> > +#define MVEBU_COMPHY_CONF6(n)			(0x1014 + (n) * 0x28)
> > +#define     MVEBU_COMPHY_CONF6_40B		BIT(18)
> > +#define MVEBU_COMPHY_SELECTOR			0x1140
> > +#define     MVEBU_COMPHY_SELECTOR_PHY(n)	((n) * 0x4)
> > +
> > +#define MVEBU_COMPHY_LANES	6
> > +#define MVEBU_COMPHY_PORTS	3
> > +
> > +struct mvebu_comhy_conf {
> > +	enum phy_mode mode;
> > +	unsigned lane;
> > +	unsigned port;
> > +	u32 mux;
> > +};
> > +
> > +#define MVEBU_COMPHY_CONF(_lane, _port, _mode, _mux)	\
> > +	{						\
> > +		.lane =3D _lane,				\
> > +		.port =3D _port,				\
> > +		.mode =3D _mode,				\
> > +		.mux =3D _mux,				\
> > +	}
> > +
> > +static const struct mvebu_comhy_conf mvebu_comphy_cp110_modes[] =3D {
> > +	/* lane 0 */
> > +	MVEBU_COMPHY_CONF(0, 1, PHY_MODE_SGMII, 0x1),
> > +	/* lane 1 */
> > +	MVEBU_COMPHY_CONF(1, 2, PHY_MODE_SGMII, 0x1),
> > +	/* lane 2 */
> > +	MVEBU_COMPHY_CONF(2, 0, PHY_MODE_SGMII, 0x1),
> > +	MVEBU_COMPHY_CONF(2, 0, PHY_MODE_10GKR, 0x1),
> > +	/* lane 3 */
> > +	MVEBU_COMPHY_CONF(3, 1, PHY_MODE_SGMII, 0x2),
> > +	/* lane 4 */
> > +	MVEBU_COMPHY_CONF(4, 0, PHY_MODE_SGMII, 0x2),
> > +	MVEBU_COMPHY_CONF(4, 0, PHY_MODE_10GKR, 0x2),
> > +	MVEBU_COMPHY_CONF(4, 1, PHY_MODE_SGMII, 0x1),
> > +	/* lane 5 */
> > +	MVEBU_COMPHY_CONF(5, 2, PHY_MODE_SGMII, 0x1),
> > +};
> > +
> > +struct mvebu_comphy_priv {
> > +	void __iomem *base;
> > +	struct regmap *regmap;
> > +	struct device *dev;
> > +	int modes[MVEBU_COMPHY_LANES];
> > +};
> > +
> > +struct mvebu_comphy_lane {
> > +	struct mvebu_comphy_priv *priv;
> > +	unsigned id;
> > +	enum phy_mode mode;
> > +	int port;
> > +};
> > +
> > +static int mvebu_comphy_get_mux(int lane, int port, enum phy_mode mode)
> > +{
> > +	int i, n =3D ARRAY_SIZE(mvebu_comphy_cp110_modes);
> > +
> > +	/* Unused PHY mux value is 0x0 */
> > +	if (mode =3D=3D PHY_MODE_INVALID)
> > +		return 0;
> > +
> > +	for (i =3D 0; i < n; i++) {
> > +		if (mvebu_comphy_cp110_modes[i].lane =3D=3D lane &&
> > +		    mvebu_comphy_cp110_modes[i].port =3D=3D port &&
> > +		    mvebu_comphy_cp110_modes[i].mode =3D=3D mode)
> > +			break;
> > +	}
> > +
> > +	if (i =3D=3D n)
> > +		return -EINVAL;
> > +
> > +	return mvebu_comphy_cp110_modes[i].mux;
> > +}
> > +
> > +static void mvebu_comphy_ethernet_init_reset(struct mvebu_comphy_lane =
*lane,
> > +					     enum phy_mode mode)
> > +{
> > +	struct mvebu_comphy_priv *priv =3D lane->priv;
> > +	u32 val;
> > +
> > +	regmap_read(priv->regmap, MVEBU_COMPHY_CONF1(lane->id), &val);
> > +	val &=3D ~MVEBU_COMPHY_CONF1_USB_PCIE;
> > +	val |=3D MVEBU_COMPHY_CONF1_PWRUP;
> > +	regmap_write(priv->regmap, MVEBU_COMPHY_CONF1(lane->id), val);
> > +
> > +	/* Select baud rates and PLLs */
> > +	val =3D readl(priv->base + MVEBU_COMPHY_SERDES_CFG0(lane->id));
> > +	val &=3D ~(MVEBU_COMPHY_SERDES_CFG0_PU_PLL |
> > +		 MVEBU_COMPHY_SERDES_CFG0_PU_RX |
> > +		 MVEBU_COMPHY_SERDES_CFG0_PU_TX |
> > +		 MVEBU_COMPHY_SERDES_CFG0_HALF_BUS |
> > +		 MVEBU_COMPHY_SERDES_CFG0_GEN_RX(0xf) |
> > +		 MVEBU_COMPHY_SERDES_CFG0_GEN_TX(0xf));
> > +	if (mode =3D=3D PHY_MODE_10GKR)
> > +		val |=3D MVEBU_COMPHY_SERDES_CFG0_GEN_RX(0xe) |
> > +		       MVEBU_COMPHY_SERDES_CFG0_GEN_TX(0xe);
> > +	else if (mode =3D=3D PHY_MODE_SGMII)
> > +		val |=3D MVEBU_COMPHY_SERDES_CFG0_GEN_RX(0x6) |
> > +		       MVEBU_COMPHY_SERDES_CFG0_GEN_TX(0x6) |
> > +		       MVEBU_COMPHY_SERDES_CFG0_HALF_BUS;
> > +	writel(val, priv->base + MVEBU_COMPHY_SERDES_CFG0(lane->id));
> > +
> > +	/* reset */
> > +	val =3D readl(priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> > +	val &=3D ~(MVEBU_COMPHY_SERDES_CFG1_RESET |
> > +		 MVEBU_COMPHY_SERDES_CFG1_CORE_RESET |
> > +		 MVEBU_COMPHY_SERDES_CFG1_RF_RESET);
> > +	writel(val, priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> > +
> > +	/* de-assert reset */
> > +	val =3D readl(priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> > +	val |=3D MVEBU_COMPHY_SERDES_CFG1_RESET |
> > +	       MVEBU_COMPHY_SERDES_CFG1_CORE_RESET;
> > +	writel(val, priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> > +
> > +	/* wait until clocks are ready */
> > +	mdelay(1);
> > +
> > +	/* exlicitly disable 40B, the bits isn't clear on reset */
> > +	regmap_read(priv->regmap, MVEBU_COMPHY_CONF6(lane->id), &val);
> > +	val &=3D ~MVEBU_COMPHY_CONF6_40B;
> > +	regmap_write(priv->regmap, MVEBU_COMPHY_CONF6(lane->id), val);
> > +
> > +	/* refclk selection */
> > +	val =3D readl(priv->base + MVEBU_COMPHY_MISC_CTRL0(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_MISC_CTRL0_REFCLK_SEL;
> > +	if (mode =3D=3D PHY_MODE_10GKR)
> > +		val |=3D MVEBU_COMPHY_MISC_CTRL0_ICP_FORCE;
> > +	writel(val, priv->base + MVEBU_COMPHY_MISC_CTRL0(lane->id));
> > +
> > +	/* power and pll selection */
> > +	val =3D readl(priv->base + MVEBU_COMPHY_PWRPLL_CTRL(lane->id));
> > +	val &=3D ~(MVEBU_COMPHY_PWRPLL_CTRL_RFREQ(0x1f) |
> > +		 MVEBU_COMPHY_PWRPLL_PHY_MODE(0x7));
> > +	val |=3D MVEBU_COMPHY_PWRPLL_CTRL_RFREQ(0x1) |
> > +	       MVEBU_COMPHY_PWRPLL_PHY_MODE(0x4);
> > +	writel(val, priv->base + MVEBU_COMPHY_PWRPLL_CTRL(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_LOOPBACK(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_LOOPBACK_DBUS_WIDTH(0x7);
> > +	val |=3D MVEBU_COMPHY_LOOPBACK_DBUS_WIDTH(0x1);
> > +	writel(val, priv->base + MVEBU_COMPHY_LOOPBACK(lane->id));
> > +}
> > +
> > +static int mvebu_comphy_init_plls(struct mvebu_comphy_lane *lane,
> > +				  enum phy_mode mode)
> > +{
> > +	struct mvebu_comphy_priv *priv =3D lane->priv;
> > +	u32 val;
> > +
> > +	/* SERDES external config */
> > +	val =3D readl(priv->base + MVEBU_COMPHY_SERDES_CFG0(lane->id));
> > +	val |=3D MVEBU_COMPHY_SERDES_CFG0_PU_PLL |
> > +	       MVEBU_COMPHY_SERDES_CFG0_PU_RX |
> > +	       MVEBU_COMPHY_SERDES_CFG0_PU_TX;
> > +	writel(val, priv->base + MVEBU_COMPHY_SERDES_CFG0(lane->id));
> > +
> > +	/* check rx/tx pll */
> > +	readl_poll_timeout(priv->base + MVEBU_COMPHY_SERDES_STATUS0(lane->id),
> > +			   val,
> > +			   val & (MVEBU_COMPHY_SERDES_STATUS0_RX_PLL_RDY |
> > +				  MVEBU_COMPHY_SERDES_STATUS0_TX_PLL_RDY),
> > +			   1000, 150000);
> > +	if (!(val & (MVEBU_COMPHY_SERDES_STATUS0_RX_PLL_RDY |
> > +		     MVEBU_COMPHY_SERDES_STATUS0_TX_PLL_RDY)))
> > +		return -ETIMEDOUT;
> > +
> > +	/* rx init */
> > +	val =3D readl(priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> > +	val |=3D MVEBU_COMPHY_SERDES_CFG1_RX_INIT;
> > +	writel(val, priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> > +
> > +	/* check rx */
> > +	readl_poll_timeout(priv->base + MVEBU_COMPHY_SERDES_STATUS0(lane->id),
> > +			   val, val & MVEBU_COMPHY_SERDES_STATUS0_RX_INIT,
> > +			   1000, 10000);
> > +	if (!(val & MVEBU_COMPHY_SERDES_STATUS0_RX_INIT))
> > +		return -ETIMEDOUT;
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_SERDES_CFG1_RX_INIT;
> > +	writel(val, priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> > +
> > +	return 0;
> > +}
> > +
> > +static int mvebu_comphy_set_mode_sgmii(struct phy *phy)
> > +{
> > +	struct mvebu_comphy_lane *lane =3D phy_get_drvdata(phy);
> > +	struct mvebu_comphy_priv *priv =3D lane->priv;
> > +	u32 val;
> > +
> > +	mvebu_comphy_ethernet_init_reset(lane, PHY_MODE_SGMII);
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_RX_CTRL1(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_RX_CTRL1_CLK8T_EN;
> > +	val |=3D MVEBU_COMPHY_RX_CTRL1_RXCLK2X_SEL;
> > +	writel(val, priv->base + MVEBU_COMPHY_RX_CTRL1(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_DLT_CTRL(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_DLT_CTRL_DTL_FLOOP_EN;
> > +	writel(val, priv->base + MVEBU_COMPHY_DLT_CTRL(lane->id));
> > +
> > +	regmap_read(priv->regmap, MVEBU_COMPHY_CONF1(lane->id), &val);
> > +	val &=3D ~MVEBU_COMPHY_CONF1_USB_PCIE;
> > +	val |=3D MVEBU_COMPHY_CONF1_PWRUP;
> > +	regmap_write(priv->regmap, MVEBU_COMPHY_CONF1(lane->id), val);
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_GEN1_S0(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_GEN1_S0_TX_EMPH(0xf);
> > +	val |=3D MVEBU_COMPHY_GEN1_S0_TX_EMPH(0x1);
> > +	writel(val, priv->base + MVEBU_COMPHY_GEN1_S0(lane->id));
> > +
> > +	return mvebu_comphy_init_plls(lane, PHY_MODE_SGMII);
> > +}
> > +
> > +static int mvebu_comphy_set_mode_10gkr(struct phy *phy)
> > +{
> > +	struct mvebu_comphy_lane *lane =3D phy_get_drvdata(phy);
> > +	struct mvebu_comphy_priv *priv =3D lane->priv;
> > +	u32 val;
> > +
> > +	mvebu_comphy_ethernet_init_reset(lane, PHY_MODE_10GKR);
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_RX_CTRL1(lane->id));
> > +	val |=3D MVEBU_COMPHY_RX_CTRL1_RXCLK2X_SEL |
> > +	       MVEBU_COMPHY_RX_CTRL1_CLK8T_EN;
> > +	writel(val, priv->base + MVEBU_COMPHY_RX_CTRL1(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_DLT_CTRL(lane->id));
> > +	val |=3D MVEBU_COMPHY_DLT_CTRL_DTL_FLOOP_EN;
> > +	writel(val, priv->base + MVEBU_COMPHY_DLT_CTRL(lane->id));
> > +
> > +	/* Speed divider */
> > +	val =3D readl(priv->base + MVEBU_COMPHY_SPEED_DIV(lane->id));
> > +	val |=3D MVEBU_COMPHY_SPEED_DIV_TX_FORCE;
> > +	writel(val, priv->base + MVEBU_COMPHY_SPEED_DIV(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_SERDES_CFG2(lane->id));
> > +	val |=3D MVEBU_COMPHY_SERDES_CFG2_DFE_EN;
> > +	writel(val, priv->base + MVEBU_COMPHY_SERDES_CFG2(lane->id));
> > +
> > +	/* DFE resolution */
> > +	val =3D readl(priv->base + MVEBU_COMPHY_DFE_RES(lane->id));
> > +	val |=3D MVEBU_COMPHY_DFE_RES_FORCE_GEN_TBL;
> > +	writel(val, priv->base + MVEBU_COMPHY_DFE_RES(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_GEN1_S0(lane->id));
> > +	val &=3D ~(MVEBU_COMPHY_GEN1_S0_TX_AMP(0x1f) |
> > +		 MVEBU_COMPHY_GEN1_S0_TX_EMPH(0xf));
> > +	val |=3D MVEBU_COMPHY_GEN1_S0_TX_AMP(0x1c) |
> > +	       MVEBU_COMPHY_GEN1_S0_TX_EMPH(0xe);
> > +	writel(val, priv->base + MVEBU_COMPHY_GEN1_S0(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_GEN1_S2(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_GEN1_S2_TX_EMPH(0xf);
> > +	val |=3D MVEBU_COMPHY_GEN1_S2_TX_EMPH_EN;
> > +	writel(val, priv->base + MVEBU_COMPHY_GEN1_S2(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_TX_SLEW_RATE(lane->id));
> > +	val |=3D MVEBU_COMPHY_TX_SLEW_RATE_EMPH(0x3) |
> > +	       MVEBU_COMPHY_TX_SLEW_RATE_SLC(0x3f);
> > +	writel(val, priv->base + MVEBU_COMPHY_TX_SLEW_RATE(lane->id));
> > +
> > +	/* Impedance calibration */
> > +	val =3D readl(priv->base + MVEBU_COMPHY_IMP_CAL(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_IMP_CAL_TX_EXT(0x1f);
> > +	val |=3D MVEBU_COMPHY_IMP_CAL_TX_EXT(0xe) |
> > +	       MVEBU_COMPHY_IMP_CAL_TX_EXT_EN;
> > +	writel(val, priv->base + MVEBU_COMPHY_IMP_CAL(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_GEN1_S5(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_GEN1_S5_ICP(0xf);
> > +	writel(val, priv->base + MVEBU_COMPHY_GEN1_S5(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_GEN1_S1(lane->id));
> > +	val &=3D ~(MVEBU_COMPHY_GEN1_S1_RX_MUL_PI(0x7) |
> > +		 MVEBU_COMPHY_GEN1_S1_RX_MUL_PF(0x7) |
> > +		 MVEBU_COMPHY_GEN1_S1_RX_MUL_FI(0x3) |
> > +		 MVEBU_COMPHY_GEN1_S1_RX_MUL_FF(0x3));
> > +	val |=3D MVEBU_COMPHY_GEN1_S1_RX_DFE_EN |
> > +	       MVEBU_COMPHY_GEN1_S1_RX_MUL_PI(0x2) |
> > +	       MVEBU_COMPHY_GEN1_S1_RX_MUL_PF(0x2) |
> > +	       MVEBU_COMPHY_GEN1_S1_RX_MUL_FF(0x1) |
> > +	       MVEBU_COMPHY_GEN1_S1_RX_DIV(0x3);
> > +	writel(val, priv->base + MVEBU_COMPHY_GEN1_S1(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_COEF(lane->id));
> > +	val &=3D ~(MVEBU_COMPHY_COEF_DFE_EN | MVEBU_COMPHY_COEF_DFE_CTRL);
> > +	writel(val, priv->base + MVEBU_COMPHY_COEF(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_GEN1_S4(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_GEN1_S4_DFE_RES(0x3);
> > +	val |=3D MVEBU_COMPHY_GEN1_S4_DFE_RES(0x1);
> > +	writel(val, priv->base + MVEBU_COMPHY_GEN1_S4(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_GEN1_S3(lane->id));
> > +	val |=3D MVEBU_COMPHY_GEN1_S3_FBCK_SEL;
> > +	writel(val, priv->base + MVEBU_COMPHY_GEN1_S3(lane->id));
> > +
> > +	/* rx training timer */
> > +	val =3D readl(priv->base + MVEBU_COMPHY_TRAINING5(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_TRAINING5_RX_TIMER(0x3ff);
> > +	val |=3D MVEBU_COMPHY_TRAINING5_RX_TIMER(0x13);
> > +	writel(val, priv->base + MVEBU_COMPHY_TRAINING5(lane->id));
> > +
> > +	/* tx train peak to peak hold */
> > +	val =3D readl(priv->base + MVEBU_COMPHY_TRAINING0(lane->id));
> > +	val |=3D MVEBU_COMPHY_TRAINING0_P2P_HOLD;
> > +	writel(val, priv->base + MVEBU_COMPHY_TRAINING0(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_TX_PRESET(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_TX_PRESET_INDEX(0xf);
> > +	val |=3D MVEBU_COMPHY_TX_PRESET_INDEX(0x2);	/* preset coeff */
> > +	writel(val, priv->base + MVEBU_COMPHY_TX_PRESET(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_FRAME_DETECT3(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_FRAME_DETECT3_LOST_TIMEOUT_EN;
> > +	writel(val, priv->base + MVEBU_COMPHY_FRAME_DETECT3(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_TX_TRAIN_PRESET(lane->id));
> > +	val |=3D MVEBU_COMPHY_TX_TRAIN_PRESET_16B_AUTO_EN |
> > +	       MVEBU_COMPHY_TX_TRAIN_PRESET_PRBS11;
> > +	writel(val, priv->base + MVEBU_COMPHY_TX_TRAIN_PRESET(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_FRAME_DETECT0(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_FRAME_DETECT0_PATN(0x1ff);
> > +	val |=3D MVEBU_COMPHY_FRAME_DETECT0_PATN(0x88);
> > +	writel(val, priv->base + MVEBU_COMPHY_FRAME_DETECT0(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_DME(lane->id));
> > +	val |=3D MVEBU_COMPHY_DME_ETH_MODE;
> > +	writel(val, priv->base + MVEBU_COMPHY_DME(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_VDD_CAL0(lane->id));
> > +	val |=3D MVEBU_COMPHY_VDD_CAL0_CONT_MODE;
> > +	writel(val, priv->base + MVEBU_COMPHY_VDD_CAL0(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_SP_CALIB(lane->id));
> > +	val &=3D ~MVEBU_SP_CALIB_SAMPLER(0x3);
> > +	val |=3D MVEBU_SP_CALIB_SAMPLER(0x3) |
> > +	       MVEBU_SP_CALIB_SAMPLER_EN;
> > +	writel(val, priv->base + MVEBU_SP_CALIB(lane->id));
> > +	val &=3D ~MVEBU_SP_CALIB_SAMPLER_EN;
> > +	writel(val, priv->base + MVEBU_SP_CALIB(lane->id));
> > +
> > +	/* External rx regulator */
> > +	val =3D readl(priv->base + MVEBU_COMPHY_EXT_SELV(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_EXT_SELV_RX_SAMPL(0x1f);
> > +	val |=3D MVEBU_COMPHY_EXT_SELV_RX_SAMPL(0x1a);
> > +	writel(val, priv->base + MVEBU_COMPHY_EXT_SELV(lane->id));
> > +
> > +	return mvebu_comphy_init_plls(lane, PHY_MODE_10GKR);
> > +}
> > +
> > +static int mvebu_comphy_power_on(struct phy *phy)
> > +{
> > +	struct mvebu_comphy_lane *lane =3D phy_get_drvdata(phy);
> > +	struct mvebu_comphy_priv *priv =3D lane->priv;
> > +	int ret;
> > +	u32 mux, val;
> > +
> > +	mux =3D mvebu_comphy_get_mux(lane->id, lane->port, lane->mode);
> > +	if (mux < 0)
> > +		return -ENOTSUPP;
> > +
> > +	regmap_read(priv->regmap, MVEBU_COMPHY_SELECTOR, &val);
> > +	val &=3D ~(0xf << MVEBU_COMPHY_SELECTOR_PHY(lane->id));
> > +	val |=3D mux << MVEBU_COMPHY_SELECTOR_PHY(lane->id);
> > +	regmap_write(priv->regmap, MVEBU_COMPHY_SELECTOR, val);
> > +
> > +	switch (lane->mode) {
> > +	case PHY_MODE_SGMII:
> > +		ret =3D mvebu_comphy_set_mode_sgmii(phy);
> > +		break;
> > +	case PHY_MODE_10GKR:
> > +		ret =3D mvebu_comphy_set_mode_10gkr(phy);
> > +		break;
> > +	default:
> > +		return -ENOTSUPP;
> > +	}
> > +
> > +	/* digital reset */
> > +	val =3D readl(priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> > +	val |=3D MVEBU_COMPHY_SERDES_CFG1_RF_RESET;
> > +	writel(val, priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> > +
> > +	return ret;
> > +}
> > +
> > +static int mvebu_comphy_set_mode(struct phy *phy, enum phy_mode mode)
> > +{
> > +	struct mvebu_comphy_lane *lane =3D phy_get_drvdata(phy);
> > +
> > +	if (mvebu_comphy_get_mux(lane->id, lane->port, mode) < 0)
> > +		return -EINVAL;
> > +
> > +	lane->mode =3D mode;
> > +	return 0;
> > +}
> > +
> > +static int mvebu_comphy_power_off(struct phy *phy)
> > +{
> > +	struct mvebu_comphy_lane *lane =3D phy_get_drvdata(phy);
> > +	struct mvebu_comphy_priv *priv =3D lane->priv;
> > +	u32 val;
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> > +	val &=3D ~(MVEBU_COMPHY_SERDES_CFG1_RESET |
> > +		 MVEBU_COMPHY_SERDES_CFG1_CORE_RESET |
> > +		 MVEBU_COMPHY_SERDES_CFG1_RF_RESET);
> > +	writel(val, priv->base + MVEBU_COMPHY_SERDES_CFG1(lane->id));
> > +
> > +	regmap_read(priv->regmap, MVEBU_COMPHY_SELECTOR, &val);
> > +	val &=3D ~(0xf << MVEBU_COMPHY_SELECTOR_PHY(lane->id));
> > +	regmap_write(priv->regmap, MVEBU_COMPHY_SELECTOR, val);
> > +
> > +	return 0;
> > +}
> > +
> > +static const struct phy_ops mvebu_comphy_ops =3D {
> > +	.power_on	=3D mvebu_comphy_power_on,
> > +	.power_off	=3D mvebu_comphy_power_off,
> > +	.set_mode	=3D mvebu_comphy_set_mode,
> > +	.owner		=3D THIS_MODULE,
> > +};
> > +
> > +static struct phy *mvebu_comphy_xlate(struct device *dev,
> > +				      struct of_phandle_args *args)
> > +{
> > +	struct mvebu_comphy_lane *lane;
> > +	struct phy *phy;
> > +
> > +	if (WARN_ON(args->args[0] >=3D MVEBU_COMPHY_PORTS))
> > +		return ERR_PTR(-EINVAL);
> > +
> > +	phy =3D of_phy_simple_xlate(dev, args);
> > +	if (IS_ERR(phy))
> > +		return phy;
> > +
> > +	lane =3D phy_get_drvdata(phy);
> > +	if (lane->port >=3D 0)
> > +		return ERR_PTR(-EBUSY);
> > +	lane->port =3D args->args[0];
> > +
> > +	return phy;
> > +}
> > +
> > +static int mvebu_comphy_probe(struct platform_device *pdev)
> > +{
> > +	struct mvebu_comphy_priv *priv;
> > +	struct phy_provider *provider;
> > +	struct device_node *child;
> > +	struct resource *res;
> > +
> > +	priv =3D devm_kzalloc(&pdev->dev, sizeof(*priv), GFP_KERNEL);
> > +	if (!priv)
> > +		return -ENOMEM;
> > +
> > +	priv->dev =3D &pdev->dev;
> > +	priv->regmap =3D
> > +		syscon_regmap_lookup_by_phandle(pdev->dev.of_node,
> > +						"marvell,system-controller");
> > +	if (IS_ERR(priv->regmap))
> > +		return PTR_ERR(priv->regmap);
> > +	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> > +	priv->base =3D devm_ioremap_resource(&pdev->dev, res);
> > +	if (!priv->base)
> > +		return -ENOMEM;
> > +
> > +	for_each_available_child_of_node(pdev->dev.of_node, child) {
> > +		struct mvebu_comphy_lane *lane;
> > +		struct phy *phy;
> > +		int ret;
> > +		u32 val;
> > +
> > +		ret =3D of_property_read_u32(child, "reg", &val);
> > +		if (ret < 0) {
> > +			dev_err(&pdev->dev, "missing 'reg' property (%d)\n",
> > +				ret);
> > +			continue;
> > +		}
> > +
> > +		if (val >=3D MVEBU_COMPHY_LANES) {
> > +			dev_err(&pdev->dev, "invalid 'reg' property\n");
> > +			continue;
> > +		}
> > +
> > +		lane =3D devm_kzalloc(&pdev->dev, sizeof(*lane), GFP_KERNEL);
> > +		if (!lane)
> > +			return -ENOMEM;
> > +
> > +		phy =3D devm_phy_create(&pdev->dev, child, &mvebu_comphy_ops);
> > +		if (IS_ERR(phy))
> > +			return PTR_ERR(phy);
> > +
> > +		lane->priv =3D priv;
> > +		lane->mode =3D PHY_MODE_INVALID;
> > +		lane->id =3D val;
> > +		lane->port =3D -1;
> > +		phy_set_drvdata(phy, lane);
> > +
> > +		/*
> > +		 * Once all modes are supported in this driver we should call
> > +		 * mvebu_comphy_power_off(phy) here to avoid relying on the
> > +		 * bootloader/firmware configuration.
> > +		 */
> > +	}
> > +
> > +	dev_set_drvdata(&pdev->dev, priv);
> > +	provider =3D devm_of_phy_provider_register(&pdev->dev,
> > +						 mvebu_comphy_xlate);
> > +	return PTR_ERR_OR_ZERO(provider);
> > +}
> > +
> > +static const struct of_device_id mvebu_comphy_of_match_table[] =3D {
> > +	{ .compatible =3D "marvell,comphy-cp110" },
> > +	{ },
> > +};
> > +MODULE_DEVICE_TABLE(of, mvebu_comphy_of_match_table);
> > +
> > +static struct platform_driver mvebu_comphy_driver =3D {
> > +	.probe	=3D mvebu_comphy_probe,
> > +	.driver	=3D {
> > +		.name =3D "mvebu-comphy",
> > +		.of_match_table =3D mvebu_comphy_of_match_table,
> > +	},
> > +};
> > +module_platform_driver(mvebu_comphy_driver);
> > +
> > +MODULE_AUTHOR("Antoine Tenart <antoine.tenart@free-electrons.com>");
> > +MODULE_DESCRIPTION("Common PHY driver for mvebu SoCs");
> > +MODULE_LICENSE("GPL v2");
> >=20

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--l0l+eSofNeLXHSnY
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmmpAMACgkQXE2LyK3b
vNgedhAAggZUmjxcBqEG/gW/livg73P9+g3n6djDleMBuBT4X6qo0hDBFzDKydTO
gUnjFOtPZD+RI5ufVF3XgT2amAsd+7oNAXgtGuCPhcIxQRHd2cYpuFQWT6zqqie1
hBxrLDyFiwSZIBWeAynOXX2keXZm9z+ECto1xgO/VCcqqL2FIsy3vH6nghvE4kWx
HR1lam12yROGyfoN9Rlq2+YEDrKowSYgYmIFHItjofGqreiptxf8wZSY+5U1w4T9
EyRt0tWdlfIpfTWLPb24jVknkdMUg78vFHouMCw7lS+WXMCdfMA+o2JHuWwXQ+oC
fVGxXhLRuq2ZQ9IUnEVwouYMZd7hHcvQFBbZepv8N7CSoI7cIqomo6f1KfTE1rQ2
22wKFNwH70WK8zbf4Ze4Xiw/G9TsRSl/9AkhXQCfP5uL9aFqsW1J4bv8FLJ5HyfK
wZwlHea8/Ccx2MxKxRpkZtitcq/21RCO9XWFOg/un1oPO+l1Zha96tWusygSpUSp
y/ovK9psojCPpLyzfJrcoAdqvwkLxX8xNI2NUW862ruReZFNZlkRCh2cfh26lnxi
wlvdq1Hk+Ne2PJ/AzQ/R/F30/ZveQIIe9wC37fhfPsDHtiyjrV/2W1NmGcZtkfqi
anksCMCymVKr+9ClAT/+2/fHLGLqDk8Pqv5rH1VJBV2r5b1QtwE=
=emn4
-----END PGP SIGNATURE-----

--l0l+eSofNeLXHSnY--
