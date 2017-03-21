From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [v5,net-next,2/9] net: stmmac: configure mtl rx and tx algorithms
Date: Tue, 21 Mar 2017 12:58:04 +0100
Message-ID: <20170321115804.GA5377@ulmo.ba.sec>
References: <aa027812f1ab084c3d1e578369cd35c3be3b7f96.1489169213.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="DocE+STaALJfprDB"
Cc: davem@davemloft.net, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, niklas.cassel@axis.com,
        netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35343 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756511AbdCUL66 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 07:58:58 -0400
Received: by mail-wm0-f67.google.com with SMTP id z133so2489799wmb.2
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 04:58:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <aa027812f1ab084c3d1e578369cd35c3be3b7f96.1489169213.git.jpinto@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 10, 2017 at 06:24:52PM +0000, Joao Pinto wrote:
> This patch adds the RX and TX scheduling algorithms programming.
> It introduces the multiple queues configuration function
> (stmmac_mtl_configuration) in stmmac_main.
>=20
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
> Changes v4->v5:
> - patch title update (stmicro replaced by stmmac)
> Changes v3->v4:
> - Just to keep up with patch-set version
> Changes v2->v3:
> - Switch statements with a tab
> Changes v1->v2:
> - Just to keep up with patch-set version
>=20
>  drivers/net/ethernet/stmicro/stmmac/common.h      |  4 ++
>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h      | 10 +++++
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 48 +++++++++++++++++=
++++++
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 31 +++++++++++++--
>  4 files changed, 90 insertions(+), 3 deletions(-)

This patch breaks backwards-compatibility with DTBs that don't have an
of the multiple queue properties.

See below...

> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/e=
thernet/stmicro/stmmac/common.h
> index 04d9245..5a0a781 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -455,6 +455,10 @@ struct stmmac_ops {
>  	int (*rx_ipc)(struct mac_device_info *hw);
>  	/* Enable RX Queues */
>  	void (*rx_queue_enable)(struct mac_device_info *hw, u32 queue);
> +	/* Program RX Algorithms */
> +	void (*prog_mtl_rx_algorithms)(struct mac_device_info *hw, u32 rx_alg);
> +	/* Program TX Algorithms */
> +	void (*prog_mtl_tx_algorithms)(struct mac_device_info *hw, u32 tx_alg);
>  	/* Dump MAC registers */
>  	void (*dump_regs)(struct mac_device_info *hw, u32 *reg_space);
>  	/* Handle extra events on specific interrupts hw dependent */
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/e=
thernet/stmicro/stmmac/dwmac4.h
> index db45134..748ab6f 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> @@ -161,6 +161,16 @@ enum power_event {
>  #define GMAC_HI_REG_AE			BIT(31)
> =20
>  /*  MTL registers */
> +#define MTL_OPERATION_MODE		0x00000c00
> +#define MTL_OPERATION_SCHALG_MASK	GENMASK(6, 5)
> +#define MTL_OPERATION_SCHALG_WRR	(0x0 << 5)
> +#define MTL_OPERATION_SCHALG_WFQ	(0x1 << 5)
> +#define MTL_OPERATION_SCHALG_DWRR	(0x2 << 5)
> +#define MTL_OPERATION_SCHALG_SP		(0x3 << 5)
> +#define MTL_OPERATION_RAA		BIT(2)
> +#define MTL_OPERATION_RAA_SP		(0x0 << 2)
> +#define MTL_OPERATION_RAA_WSP		(0x1 << 2)
> +
>  #define MTL_INT_STATUS			0x00000c20
>  #define MTL_INT_Q0			BIT(0)
> =20
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/=
net/ethernet/stmicro/stmmac/dwmac4_core.c
> index 1e79e65..f966755 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> @@ -70,6 +70,52 @@ static void dwmac4_rx_queue_enable(struct mac_device_i=
nfo *hw, u32 queue)
>  	writel(value, ioaddr + GMAC_RXQ_CTRL0);
>  }
> =20
> +static void dwmac4_prog_mtl_rx_algorithms(struct mac_device_info *hw,
> +					  u32 rx_alg)
> +{
> +	void __iomem *ioaddr =3D hw->pcsr;
> +	u32 value =3D readl(ioaddr + MTL_OPERATION_MODE);
> +
> +	value &=3D ~MTL_OPERATION_RAA;
> +	switch (rx_alg) {
> +	case MTL_RX_ALGORITHM_SP:
> +		value |=3D MTL_OPERATION_RAA_SP;
> +		break;
> +	case MTL_RX_ALGORITHM_WSP:
> +		value |=3D MTL_OPERATION_RAA_WSP;
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	writel(value, ioaddr + MTL_OPERATION_MODE);
> +}
> +
> +static void dwmac4_prog_mtl_tx_algorithms(struct mac_device_info *hw,
> +					  u32 tx_alg)
> +{
> +	void __iomem *ioaddr =3D hw->pcsr;
> +	u32 value =3D readl(ioaddr + MTL_OPERATION_MODE);
> +
> +	value &=3D ~MTL_OPERATION_SCHALG_MASK;
> +	switch (tx_alg) {
> +	case MTL_TX_ALGORITHM_WRR:
> +		value |=3D MTL_OPERATION_SCHALG_WRR;
> +		break;
> +	case MTL_TX_ALGORITHM_WFQ:
> +		value |=3D MTL_OPERATION_SCHALG_WFQ;
> +		break;
> +	case MTL_TX_ALGORITHM_DWRR:
> +		value |=3D MTL_OPERATION_SCHALG_DWRR;
> +		break;
> +	case MTL_TX_ALGORITHM_SP:
> +		value |=3D MTL_OPERATION_SCHALG_SP;
> +		break;
> +	default:
> +		break;
> +	}
> +}
> +
>  static void dwmac4_dump_regs(struct mac_device_info *hw, u32 *reg_space)
>  {
>  	void __iomem *ioaddr =3D hw->pcsr;
> @@ -457,6 +503,8 @@ static const struct stmmac_ops dwmac4_ops =3D {
>  	.core_init =3D dwmac4_core_init,
>  	.rx_ipc =3D dwmac4_rx_ipc_enable,
>  	.rx_queue_enable =3D dwmac4_rx_queue_enable,
> +	.prog_mtl_rx_algorithms =3D dwmac4_prog_mtl_rx_algorithms,
> +	.prog_mtl_tx_algorithms =3D dwmac4_prog_mtl_tx_algorithms,
>  	.dump_regs =3D dwmac4_dump_regs,
>  	.host_irq_status =3D dwmac4_irq_status,
>  	.flow_ctrl =3D dwmac4_flow_ctrl,
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/=
net/ethernet/stmicro/stmmac/stmmac_main.c
> index 4498a38..af57f8d 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1645,6 +1645,31 @@ static void stmmac_init_tx_coalesce(struct stmmac_=
priv *priv)
>  }
> =20
>  /**
> + *  stmmac_mtl_configuration - Configure MTL
> + *  @priv: driver private structure
> + *  Description: It is used for configurring MTL
> + */
> +static void stmmac_mtl_configuration(struct stmmac_priv *priv)
> +{
> +	u32 rx_queues_count =3D priv->plat->rx_queues_to_use;
> +	u32 tx_queues_count =3D priv->plat->tx_queues_to_use;
> +
> +	/* Configure MTL RX algorithms */
> +	if (rx_queues_count > 1 && priv->hw->mac->prog_mtl_rx_algorithms)
> +		priv->hw->mac->prog_mtl_rx_algorithms(priv->hw,
> +						priv->plat->rx_sched_algorithm);
> +
> +	/* Configure MTL TX algorithms */
> +	if (tx_queues_count > 1 && priv->hw->mac->prog_mtl_tx_algorithms)
> +		priv->hw->mac->prog_mtl_tx_algorithms(priv->hw,
> +						priv->plat->tx_sched_algorithm);
> +
> +	/* Enable MAC RX Queues */
> +	if (rx_queues_count > 1 && priv->hw->mac->rx_queue_enable)
> +		stmmac_mac_enable_rx_queues(priv);

This is almost equivalent to the code removed from stmmac_hw_setup()
which happens to be the key for this driver to work for me. However, the
code above adds an additional check for rx_queues_count > 1 which is
going to be false for any existing DTB, because it is derived from the
values retrieved from new device tree properties.

So I think for backwards compatibility we'd need something like this:

	if ((rx_queue_count =3D=3D 0 || rx_queue_count > 1) &&
	    priv->hw->mac->rx_queue_enable)

But then I'm beginning to think maybe we don't need a check here at all
because it would only prevent RX queue setup for rx_queue_count =3D=3D 1 and
I think it would still be legitimate to set it up even then.

stmmac_mac_enable_rx_queues() already checks for rx_count =3D=3D 1, but that
is derived from the number of RX queues derived from the feature
registers and therefore refers to the number of queues that the hardware
supports as opposed to the number of queues configured in device tree.

I can follow up with a patch to restore backwards-compatibility.

Thierry

--DocE+STaALJfprDB
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiOrDCAFJzPfAjcif3SOs138+s6EFAljRFUkACgkQ3SOs138+
s6HZ+BAAtiZ+A8mdqM1P8sCRQGlaRqkDnQMxJHPg2oiqjVcxhBJKlS9dwKgPH/Re
qttggfejoc0LO2EkijUTMX7s3ZT5+ei8ZpbkFoVDRdw/TtIKPYUjo/7oyRuEfmwR
VA5XSmho+u9c8EaMoqYTH/e25i+EpUh42n5HV7iR+THwo8pIsg9ODxR1D5Ee2YEM
GWIg1XaY20u8uZy2ViF3Lo6Qyr+W/Rijfb6rtL4Wg4eKImRETlg7D32jhELNCWLg
pfyoGWOAjzWva5y0NPYLufJgFBj3H2PbqVm6YDPn32rA299VsW04RqLeDbbZclbU
78G6UOD21vF9CL6Bmxo3koL6A2rFiWVRUrMyu0h7FQHiFq9NXoS7jy3PXdXRfCFr
1s7cOMVAkzGaW5TebYcea3XulH6h9PTkweLhrFdCTLvarEzOhz5RNdKVqjRXmh2l
z4Ip3+INt0qwL3zSH33CV9ei0V0ITc1EedisMznWsoyP/NBFwcgmkF5WhdlVBN1v
pwJl9e0cWCsuCPQQTnYmGOkzQjSL4giuyEWlbQ8up+qmRDT8g57a+H9h4DeU7cMc
hmu180IXitdnOBjuC+bFsu1FtEnx9SZKhHp9t/mOe+Wa//GuSyOiNKZRoA0a7+18
l9OoJONs9ffWqyQ6HG3rkTfw6lJCmO0m9J0pGerGph3rTrsSsNo=
=9uhZ
-----END PGP SIGNATURE-----

--DocE+STaALJfprDB--
