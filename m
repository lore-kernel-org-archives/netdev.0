From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [v5,net-next,2/9] net: stmmac: configure mtl rx and tx algorithms
Date: Tue, 21 Mar 2017 13:24:26 +0100
Message-ID: <20170321122426.GE30407@ulmo.ba.sec>
References: <aa027812f1ab084c3d1e578369cd35c3be3b7f96.1489169213.git.jpinto@synopsys.com>
 <20170321115804.GA5377@ulmo.ba.sec>
 <1020202a-5b96-0c11-a5de-fbd93ff02323@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="Dzs2zDY0zgkG72+7"
Cc: davem@davemloft.net, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, niklas.cassel@axis.com,
        netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36375 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755348AbdCUMdb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 08:33:31 -0400
Received: by mail-wr0-f194.google.com with SMTP id l37so22190140wrc.3
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 05:33:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1020202a-5b96-0c11-a5de-fbd93ff02323@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Dzs2zDY0zgkG72+7
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 21, 2017 at 12:02:03PM +0000, Joao Pinto wrote:
> =C3=80s 11:58 AM de 3/21/2017, Thierry Reding escreveu:
> > On Fri, Mar 10, 2017 at 06:24:52PM +0000, Joao Pinto wrote:
> >> This patch adds the RX and TX scheduling algorithms programming.
> >> It introduces the multiple queues configuration function
> >> (stmmac_mtl_configuration) in stmmac_main.
> >>
> >> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> >> ---
> >> Changes v4->v5:
> >> - patch title update (stmicro replaced by stmmac)
> >> Changes v3->v4:
> >> - Just to keep up with patch-set version
> >> Changes v2->v3:
> >> - Switch statements with a tab
> >> Changes v1->v2:
> >> - Just to keep up with patch-set version
> >>
> >>  drivers/net/ethernet/stmicro/stmmac/common.h      |  4 ++
> >>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h      | 10 +++++
> >>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 48 ++++++++++++++=
+++++++++
> >>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 31 +++++++++++++--
> >>  4 files changed, 90 insertions(+), 3 deletions(-)
> >=20
> > This patch breaks backwards-compatibility with DTBs that don't have an
> > of the multiple queue properties.
> >=20
> > See below...
> >=20
> >> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/ne=
t/ethernet/stmicro/stmmac/common.h
> >> index 04d9245..5a0a781 100644
> >> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> >> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> >> @@ -455,6 +455,10 @@ struct stmmac_ops {
> >>  	int (*rx_ipc)(struct mac_device_info *hw);
> >>  	/* Enable RX Queues */
> >>  	void (*rx_queue_enable)(struct mac_device_info *hw, u32 queue);
> >> +	/* Program RX Algorithms */
> >> +	void (*prog_mtl_rx_algorithms)(struct mac_device_info *hw, u32 rx_al=
g);
> >> +	/* Program TX Algorithms */
> >> +	void (*prog_mtl_tx_algorithms)(struct mac_device_info *hw, u32 tx_al=
g);
> >>  	/* Dump MAC registers */
> >>  	void (*dump_regs)(struct mac_device_info *hw, u32 *reg_space);
> >>  	/* Handle extra events on specific interrupts hw dependent */
> >> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/ne=
t/ethernet/stmicro/stmmac/dwmac4.h
> >> index db45134..748ab6f 100644
> >> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> >> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> >> @@ -161,6 +161,16 @@ enum power_event {
> >>  #define GMAC_HI_REG_AE			BIT(31)
> >> =20
> >>  /*  MTL registers */
> >> +#define MTL_OPERATION_MODE		0x00000c00
> >> +#define MTL_OPERATION_SCHALG_MASK	GENMASK(6, 5)
> >> +#define MTL_OPERATION_SCHALG_WRR	(0x0 << 5)
> >> +#define MTL_OPERATION_SCHALG_WFQ	(0x1 << 5)
> >> +#define MTL_OPERATION_SCHALG_DWRR	(0x2 << 5)
> >> +#define MTL_OPERATION_SCHALG_SP		(0x3 << 5)
> >> +#define MTL_OPERATION_RAA		BIT(2)
> >> +#define MTL_OPERATION_RAA_SP		(0x0 << 2)
> >> +#define MTL_OPERATION_RAA_WSP		(0x1 << 2)
> >> +
> >>  #define MTL_INT_STATUS			0x00000c20
> >>  #define MTL_INT_Q0			BIT(0)
> >> =20
> >> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drive=
rs/net/ethernet/stmicro/stmmac/dwmac4_core.c
> >> index 1e79e65..f966755 100644
> >> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> >> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> >> @@ -70,6 +70,52 @@ static void dwmac4_rx_queue_enable(struct mac_devic=
e_info *hw, u32 queue)
> >>  	writel(value, ioaddr + GMAC_RXQ_CTRL0);
> >>  }
> >> =20
> >> +static void dwmac4_prog_mtl_rx_algorithms(struct mac_device_info *hw,
> >> +					  u32 rx_alg)
> >> +{
> >> +	void __iomem *ioaddr =3D hw->pcsr;
> >> +	u32 value =3D readl(ioaddr + MTL_OPERATION_MODE);
> >> +
> >> +	value &=3D ~MTL_OPERATION_RAA;
> >> +	switch (rx_alg) {
> >> +	case MTL_RX_ALGORITHM_SP:
> >> +		value |=3D MTL_OPERATION_RAA_SP;
> >> +		break;
> >> +	case MTL_RX_ALGORITHM_WSP:
> >> +		value |=3D MTL_OPERATION_RAA_WSP;
> >> +		break;
> >> +	default:
> >> +		break;
> >> +	}
> >> +
> >> +	writel(value, ioaddr + MTL_OPERATION_MODE);
> >> +}
> >> +
> >> +static void dwmac4_prog_mtl_tx_algorithms(struct mac_device_info *hw,
> >> +					  u32 tx_alg)
> >> +{
> >> +	void __iomem *ioaddr =3D hw->pcsr;
> >> +	u32 value =3D readl(ioaddr + MTL_OPERATION_MODE);
> >> +
> >> +	value &=3D ~MTL_OPERATION_SCHALG_MASK;
> >> +	switch (tx_alg) {
> >> +	case MTL_TX_ALGORITHM_WRR:
> >> +		value |=3D MTL_OPERATION_SCHALG_WRR;
> >> +		break;
> >> +	case MTL_TX_ALGORITHM_WFQ:
> >> +		value |=3D MTL_OPERATION_SCHALG_WFQ;
> >> +		break;
> >> +	case MTL_TX_ALGORITHM_DWRR:
> >> +		value |=3D MTL_OPERATION_SCHALG_DWRR;
> >> +		break;
> >> +	case MTL_TX_ALGORITHM_SP:
> >> +		value |=3D MTL_OPERATION_SCHALG_SP;
> >> +		break;
> >> +	default:
> >> +		break;
> >> +	}
> >> +}
> >> +
> >>  static void dwmac4_dump_regs(struct mac_device_info *hw, u32 *reg_spa=
ce)
> >>  {
> >>  	void __iomem *ioaddr =3D hw->pcsr;
> >> @@ -457,6 +503,8 @@ static const struct stmmac_ops dwmac4_ops =3D {
> >>  	.core_init =3D dwmac4_core_init,
> >>  	.rx_ipc =3D dwmac4_rx_ipc_enable,
> >>  	.rx_queue_enable =3D dwmac4_rx_queue_enable,
> >> +	.prog_mtl_rx_algorithms =3D dwmac4_prog_mtl_rx_algorithms,
> >> +	.prog_mtl_tx_algorithms =3D dwmac4_prog_mtl_tx_algorithms,
> >>  	.dump_regs =3D dwmac4_dump_regs,
> >>  	.host_irq_status =3D dwmac4_irq_status,
> >>  	.flow_ctrl =3D dwmac4_flow_ctrl,
> >> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drive=
rs/net/ethernet/stmicro/stmmac/stmmac_main.c
> >> index 4498a38..af57f8d 100644
> >> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >> @@ -1645,6 +1645,31 @@ static void stmmac_init_tx_coalesce(struct stmm=
ac_priv *priv)
> >>  }
> >> =20
> >>  /**
> >> + *  stmmac_mtl_configuration - Configure MTL
> >> + *  @priv: driver private structure
> >> + *  Description: It is used for configurring MTL
> >> + */
> >> +static void stmmac_mtl_configuration(struct stmmac_priv *priv)
> >> +{
> >> +	u32 rx_queues_count =3D priv->plat->rx_queues_to_use;
> >> +	u32 tx_queues_count =3D priv->plat->tx_queues_to_use;
> >> +
> >> +	/* Configure MTL RX algorithms */
> >> +	if (rx_queues_count > 1 && priv->hw->mac->prog_mtl_rx_algorithms)
> >> +		priv->hw->mac->prog_mtl_rx_algorithms(priv->hw,
> >> +						priv->plat->rx_sched_algorithm);
> >> +
> >> +	/* Configure MTL TX algorithms */
> >> +	if (tx_queues_count > 1 && priv->hw->mac->prog_mtl_tx_algorithms)
> >> +		priv->hw->mac->prog_mtl_tx_algorithms(priv->hw,
> >> +						priv->plat->tx_sched_algorithm);
> >> +
> >> +	/* Enable MAC RX Queues */
> >> +	if (rx_queues_count > 1 && priv->hw->mac->rx_queue_enable)
> >> +		stmmac_mac_enable_rx_queues(priv);
> >=20
> > This is almost equivalent to the code removed from stmmac_hw_setup()
> > which happens to be the key for this driver to work for me. However, the
> > code above adds an additional check for rx_queues_count > 1 which is
> > going to be false for any existing DTB, because it is derived from the
> > values retrieved from new device tree properties.
> >=20
> > So I think for backwards compatibility we'd need something like this:
> >=20
> > 	if ((rx_queue_count =3D=3D 0 || rx_queue_count > 1) &&
> > 	    priv->hw->mac->rx_queue_enable)
> >=20
> > But then I'm beginning to think maybe we don't need a check here at all
> > because it would only prevent RX queue setup for rx_queue_count =3D=3D =
1 and
> > I think it would still be legitimate to set it up even then.
> >=20
> > stmmac_mac_enable_rx_queues() already checks for rx_count =3D=3D 1, but=
 that
> > is derived from the number of RX queues derived from the feature
> > registers and therefore refers to the number of queues that the hardware
> > supports as opposed to the number of queues configured in device tree.
> >=20
> > I can follow up with a patch to restore backwards-compatibility.
>=20
> Forhw configured as single queue you don't need to enable the rx queue, s=
ince
> they are enable by default. if you check in stmmac_platform.c I assure ba=
ckward
> compatibility by setting the number of rx and tx queues =3D 1 if nothing =
is
> declared. Please check here:
>=20
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/tree/d=
rivers/net/ethernet/stmicro/stmmac/stmmac_platform.c#n156

Ah yes, I just ran across that trying to debug why a subsequent patch
broke things again. I think the rx_queue_count > 1 condition is still
wrong in the above because it will still fail for the backwards-
compatibility case.

I still think any check other than priv->hw->mac->rx_queue_enable should
be dropped when calling stmmac_mac_enable_rx_queues(). A later patch is
going to move the check into that function anyway (via the for loop). I
need to step through the series some more since there are a couple of
other things I noticed that make the driver fail for Tegra186 now. Let
me report back once I'm through all of it.

Thierry

--Dzs2zDY0zgkG72+7
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljRG3cACgkQ3SOs138+
s6FE2Q/+Kq4/rh+e/6JNNn0t8ntGncr1FSzqGfWqCZS3f/40DxloMxiiPPMiLAvz
eJq5mTpxey7ZvxmtSFAxjJTAr05d3rwi92kCDGIIfxMdMi4W/dK/kuyd1KBu+kZu
hN1FF87YQVajmFgAs+4cCEQZELu8HuPqFooRSyIuyNcg2BXUKGjd0gKX+jWAKVC4
h/PXOFJfb3Ca8jxfZ8epA/HfoJidXQiCWmKIiqGaJw95KnWmM7hNOZWftSHz4dvC
Bd4Ot9z8L3EO3l4iAiFVQfCAhw4CHwAX41o/rstmBsmSk7nc5V7kKafhPYrtB1Yi
7soAfRHMuZYZ6RbWknfC5iYJkB/Zs4cz/OIbO6++9LUZ7Jw/D4Lu/nJy3BUVFklO
iNk1xM+hh0X0q/16w/w1I/vMcOm9GbJABRdq/HpyWT0Jv49dJyF9/r8sDqheKpS2
SpwGW+g31kUIQuOoesPODQZrYaGnWmlrc7ymIumfrlwxRVy+pDEF4Bl1sNpunMas
E9liCzeim3hzt8jY8getUSwsxSQp5wI6zm5+BWKkoUcJ1oe3iM5BF1MIJMamGSyN
qiIttWJJmPEbap+3n45xqHQhi0hJLZGTR/3pMGSj+W26nWkMJ8GvtAYxofQ1L971
+gidDadACaawsYecmEqI8260ND40STyko83y6NBKHGZzu+hpWw0=
=f11W
-----END PGP SIGNATURE-----

--Dzs2zDY0zgkG72+7--
