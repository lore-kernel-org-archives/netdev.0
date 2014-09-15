From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: [Patch v4 net-next 04/12] net: fec: parser max queue number
 from dt file
Date: Mon, 15 Sep 2014 09:39:26 +0200
Message-ID: <20140915093926.11bdbc32@ipc1.ka-ro>
References: <1410555657-10744-1-git-send-email-Frank.Li@freescale.com>
	<1410555657-10744-5-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>,
	devicetree@vger.kernel.org, linux@arm.linux.org.uk,
	shawn.guo@linaro.org, linux-arm-kernel@lists.infradead.org
To: <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:55002 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753328AbaIOHjr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 03:39:47 -0400
In-Reply-To: <1410555657-10744-5-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

=46rank.Li@freescale.com wrote:
> From: Fugang Duan <B38611@freescale.com>
>=20
> By default, the tx/rx queue number is 1, user can config the queue nu=
mber
> at DTS file like this:
> 	fsl,num-tx-queues=3D<3>;
> 	fsl,num-rx-queues=3D<3>
>=20
> Since i.MX6SX enet-AVB IP support multi queues, so use multi queues
> interface to allocate and set up an Ethernet device.
>=20
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> Signed-off-by: Frank Li <Frank.Li@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec.h      |  2 ++
>  drivers/net/ethernet/freescale/fec_main.c | 46 +++++++++++++++++++++=
+++++++++-
>  2 files changed, 47 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ether=
net/freescale/fec.h
> index b2b91f8..72fb90f 100644
> --- a/drivers/net/ethernet/freescale/fec.h
> +++ b/drivers/net/ethernet/freescale/fec.h
> @@ -356,6 +356,8 @@ struct fec_enet_private {
> =20
>  	bool ptp_clk_on;
>  	struct mutex ptp_clk_mutex;
> +	unsigned int num_tx_queues;
> +	unsigned int num_rx_queues;
> =20
>  	/* The saved address of a sent-in-place packet/buffer, for skfree()=
=2E */
>  	struct fec_enet_priv_tx_q *tx_queue[FEC_ENET_MAX_TX_QS];
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/=
ethernet/freescale/fec_main.c
> index 4c0d2ee..2240df0 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -2709,6 +2709,42 @@ static void fec_reset_phy(struct platform_devi=
ce *pdev)
>  }
>  #endif /* CONFIG_OF */
> =20
> +static void
> +fec_enet_get_queue_num(struct platform_device *pdev, int *num_tx, in=
t *num_rx)
> +{
> +	struct device_node *np =3D pdev->dev.of_node;
> +	int err;
> +
> +	*num_tx =3D *num_rx =3D 1;
> +
> +	if (!np || !of_device_is_available(np))
> +		return;
> +
> +	/* parse the num of tx and rx queues */
> +	err =3D of_property_read_u32(np, "fsl,num-tx-queues", num_tx);
> +	err |=3D of_property_read_u32(np, "fsl,num-rx-queues", num_rx);
> +	if (err) {
> +		*num_tx =3D 1;
> +		*num_rx =3D 1;
Shouldn't these be handled seperately? So that if only one of those
properties is given in DT the specified value for that property should
be used?

> +		return;
> +	}
> +
> +	if (*num_tx < 1 || *num_tx > FEC_ENET_MAX_TX_QS) {
> +		dev_err(&pdev->dev, "Invalidate num_tx(=3D%d), fail back to 1\n",
>
s/Invalidate/Invalid/
s/fail/fall/
If the problem is fixed up by the driver rather than leading to an
error exit it should be dev_warn() rather than dev_err().

> +			*num_tx);
> +		*num_tx =3D 1;
> +		return;
> +	}
> +
> +	if (*num_rx < 1 || *num_rx > FEC_ENET_MAX_RX_QS) {
> +		dev_err(&pdev->dev, "Invalidate num_rx(=3D%d), fail back to 1\n",
dto.

> +			*num_rx);
> +		*num_rx =3D 1;
> +		return;
> +	}
> +
> +}
> +
>  static int
>  fec_probe(struct platform_device *pdev)
>  {
> @@ -2720,13 +2756,18 @@ fec_probe(struct platform_device *pdev)
>  	const struct of_device_id *of_id;
>  	static int dev_id;
>  	struct device_node *np =3D pdev->dev.of_node, *phy_node;
> +	int num_tx_qs =3D 1;
> +	int num_rx_qs =3D 1;
> =20
useless initialization. These variables are initialized in
fec_enet_get_queue_num() anyway.

>  	of_id =3D of_match_device(fec_dt_ids, &pdev->dev);
>  	if (of_id)
>  		pdev->id_entry =3D of_id->data;
> =20
> +	fec_enet_get_queue_num(pdev, &num_tx_qs, &num_rx_qs);
> +


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
