From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 2/3] can: m_can: add bus error handling
Date: Tue, 01 Jul 2014 12:37:07 +0200
Message-ID: <53B28F53.7010403@pengutronix.de>
References: <1403863246-18822-1-git-send-email-b29396@freescale.com> <1403863246-18822-3-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="XjqxDXr1fvlB7TXxRhuVshBWOi5JSMhS6"
Cc: netdev@vger.kernel.org, wg@grandegger.com,
	devicetree@vger.kernel.org
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1403863246-18822-3-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--XjqxDXr1fvlB7TXxRhuVshBWOi5JSMhS6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 06/27/2014 12:00 PM, Dong Aisheng wrote:
> Add bus error, state change, lost message handling mechanism.
>=20
> Signed-off-by: Dong Aisheng <b29396@freescale.com>
> ---
>  drivers/net/can/m_can.c |  271 +++++++++++++++++++++++++++++++++++++++=
++------
>  1 files changed, 240 insertions(+), 31 deletions(-)
>=20
> diff --git a/drivers/net/can/m_can.c b/drivers/net/can/m_can.c
> index 61e9a8e..e4aed71 100644
> --- a/drivers/net/can/m_can.c
> +++ b/drivers/net/can/m_can.c
> @@ -83,6 +83,18 @@ enum m_can_reg {
>  	M_CAN_TXEFA	=3D 0xf8,
>  };
> =20
> +/* m_can lec values */
> +enum m_can_lec_type {
> +	LEC_NO_ERROR =3D 0,
> +	LEC_STUFF_ERROR,
> +	LEC_FORM_ERROR,
> +	LEC_ACK_ERROR,
> +	LEC_BIT1_ERROR,
> +	LEC_BIT0_ERROR,
> +	LEC_CRC_ERROR,
> +	LEC_UNUSED,
> +};
> +
>  /* CC Control Register(CCCR) */
>  #define CCCR_CCE	BIT(1)
>  #define CCCR_INIT	BIT(0)
> @@ -97,6 +109,19 @@ enum m_can_reg {
>  #define BTR_SJW_SHIFT		0
>  #define BTR_SJW_MASK		0xf
> =20
> +/* Error Counter Register(ECR) */
> +#define ECR_RP			BIT(15)
> +#define ECR_REC_SHIFT		8
> +#define ECR_REC_MASK		(0x7f << ECR_REC_SHIFT)
> +#define ECR_TEC_SHIFT		0
> +#define ECR_TEC_MASK		0xff
> +
> +/* Protocol Status Register(PSR) */
> +#define PSR_BO		BIT(7)
> +#define PSR_EW		BIT(6)
> +#define PSR_EP		BIT(5)
> +#define PSR_LEC_MASK	0x7
> +
>  /* Interrupt Register(IR) */
>  #define IR_ALL_INT	0xffffffff
>  #define IR_STE		BIT(31)
> @@ -131,10 +156,11 @@ enum m_can_reg {
>  #define IR_RF0F		BIT(2)
>  #define IR_RF0W		BIT(1)
>  #define IR_RF0N		BIT(0)
> -#define IR_ERR_ALL	(IR_STE	| IR_FOE | IR_ACKE | IR_BE | IR_CRCE | \
> -		IR_WDI | IR_BO | IR_EW | IR_EP | IR_ELO | IR_BEU | \
> -		IR_BEC | IR_TOO | IR_MRAF | IR_TSW | IR_TEFL | IR_RF1L | \
> -		IR_RF0L)
> +#define IR_ERR_STATE	(IR_BO | IR_EW | IR_EP)
> +#define IR_ERR_BUS	(IR_STE	| IR_FOE | IR_ACKE | IR_BE | IR_CRCE | \
> +		IR_WDI | IR_ELO | IR_BEU | IR_BEC | IR_TOO | IR_MRAF | \
> +		IR_TSW | IR_TEFL | IR_RF1L | IR_RF0L)
> +#define IR_ERR_ALL	(IR_ERR_STATE | IR_ERR_BUS)
> =20
>  /* Rx FIFO 0/1 Configuration (RXF0C/RXF1C) */
>  #define RXFC_FWM_OFF	24
> @@ -320,12 +346,175 @@ static int m_can_do_rx_poll(struct net_device *d=
ev, int quota)
>  	return num_rx_pkts;
>  }
> =20
> +static int m_can_handle_lost_msg(struct net_device *dev)
> +{
> +	struct net_device_stats *stats =3D &dev->stats;
> +	struct sk_buff *skb;
> +	struct can_frame *frame;
> +
> +	netdev_err(dev, "msg lost in rxf0\n");
> +
> +	skb =3D alloc_can_err_skb(dev, &frame);
> +	if (unlikely(!skb))
> +		return 0;

Please rearrange this function differently, so that the stats are
updated, even if alloc_can_err_skb() fails.

> +
> +	frame->can_id |=3D CAN_ERR_CRTL;
> +	frame->data[1] =3D CAN_ERR_CRTL_RX_OVERFLOW;
> +	stats->rx_errors++;
> +	stats->rx_over_errors++;
> +
> +	netif_receive_skb(skb);
> +
> +	return 1;
> +}
> +
> +static int m_can_handle_bus_err(struct net_device *dev,
> +				enum m_can_lec_type lec_type)
> +{
> +	struct m_can_priv *priv =3D netdev_priv(dev);
> +	struct net_device_stats *stats =3D &dev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +
> +	/* early exit if no lec update */
> +	if (lec_type =3D=3D LEC_UNUSED)
> +		return 0;
> +
> +	/* propagate the error condition to the CAN stack */
> +	skb =3D alloc_can_err_skb(dev, &cf);
> +	if (unlikely(!skb))
> +		return 0;

same here

> +
> +	/*
> +	 * check for 'last error code' which tells us the
> +	 * type of the last error to occur on the CAN bus
> +	 */
> +	priv->can.can_stats.bus_error++;
> +	stats->rx_errors++;
> +	cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
> +	cf->data[2] |=3D CAN_ERR_PROT_UNSPEC;
> +
> +	switch (lec_type) {
> +	case LEC_STUFF_ERROR:
> +		netdev_dbg(dev, "stuff error\n");
> +		cf->data[2] |=3D CAN_ERR_PROT_STUFF;
> +		break;
> +	case LEC_FORM_ERROR:
> +		netdev_dbg(dev, "form error\n");
> +		cf->data[2] |=3D CAN_ERR_PROT_FORM;
> +		break;
> +	case LEC_ACK_ERROR:
> +		netdev_dbg(dev, "ack error\n");
> +		cf->data[3] |=3D (CAN_ERR_PROT_LOC_ACK |
> +				CAN_ERR_PROT_LOC_ACK_DEL);
> +		break;
> +	case LEC_BIT1_ERROR:
> +		netdev_dbg(dev, "bit1 error\n");
> +		cf->data[2] |=3D CAN_ERR_PROT_BIT1;
> +		break;
> +	case LEC_BIT0_ERROR:
> +		netdev_dbg(dev, "bit0 error\n");
> +		cf->data[2] |=3D CAN_ERR_PROT_BIT0;
> +		break;
> +	case LEC_CRC_ERROR:
> +		netdev_dbg(dev, "CRC error\n");
> +		cf->data[3] |=3D (CAN_ERR_PROT_LOC_CRC_SEQ |
> +				CAN_ERR_PROT_LOC_CRC_DEL);
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	netif_receive_skb(skb);
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->can_dlc;
> +
> +	return 1;
> +}
> +
> +static int m_can_get_berr_counter(const struct net_device *dev,
> +				  struct can_berr_counter *bec)
> +{
> +	struct m_can_priv *priv =3D netdev_priv(dev);
> +	unsigned int ecr;

This function might be called, even if the interface is down. You might
have to enable the clock(s) here.

> +	ecr =3D m_can_read(priv, M_CAN_ECR);
> +	bec->rxerr =3D (ecr & ECR_REC_MASK) >> ECR_REC_SHIFT;
> +	bec->txerr =3D ecr & ECR_TEC_MASK;
> +
> +	return 0;
> +}
> +
> +static int m_can_handle_state_change(struct net_device *dev,
> +				enum can_state new_state)
> +{
> +	struct m_can_priv *priv =3D netdev_priv(dev);
> +	struct net_device_stats *stats =3D &dev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	struct can_berr_counter bec;
> +	unsigned int ecr;
> +
> +	/* propagate the error condition to the CAN stack */
> +	skb =3D alloc_can_err_skb(dev, &cf);
> +	if (unlikely(!skb))
> +		return 0;

Please rearrange the function, so that the stats and more important
bus-off are handled correctly, even if this fails.

> +
> +	m_can_get_berr_counter(dev, &bec);
> +
> +	switch (new_state) {
> +	case CAN_STATE_ERROR_ACTIVE:
> +		/* error warning state */
> +		priv->can.can_stats.error_warning++;
> +		priv->can.state =3D CAN_STATE_ERROR_WARNING;
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		cf->data[1] =3D (bec.txerr > bec.rxerr) ?
> +			CAN_ERR_CRTL_TX_WARNING :
> +			CAN_ERR_CRTL_RX_WARNING;
> +		cf->data[6] =3D bec.txerr;
> +		cf->data[7] =3D bec.rxerr;
> +		break;
> +	case CAN_STATE_ERROR_PASSIVE:
> +		/* error passive state */
> +		priv->can.can_stats.error_passive++;
> +		priv->can.state =3D CAN_STATE_ERROR_PASSIVE;
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		ecr =3D m_can_read(priv, M_CAN_ECR);
> +		if (ecr & ECR_RP)
> +			cf->data[1] |=3D CAN_ERR_CRTL_RX_PASSIVE;
> +		if (bec.txerr > 127)
> +			cf->data[1] |=3D CAN_ERR_CRTL_TX_PASSIVE;
> +		cf->data[6] =3D bec.txerr;
> +		cf->data[7] =3D bec.rxerr;
> +		break;
> +	case CAN_STATE_BUS_OFF:
> +		/* bus-off state */
> +		priv->can.state =3D CAN_STATE_BUS_OFF;
> +		cf->can_id |=3D CAN_ERR_BUSOFF;
> +		/*
> +		 * disable all interrupts in bus-off mode to ensure that
> +		 * the CPU is not hogged down
> +		 */
> +		m_can_enable_all_interrupts(priv, false);
> +		can_bus_off(dev);
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	netif_receive_skb(skb);
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->can_dlc;

don't acces "cf" after netif_receive_sb();

> +
> +	return 1;
> +}
> +
>  static int m_can_poll(struct napi_struct *napi, int quota)
>  {
>  	struct net_device *dev =3D napi->dev;
>  	struct m_can_priv *priv =3D netdev_priv(dev);
>  	u32 work_done =3D 0;
> -	u32 irqstatus;
> +	u32 irqstatus, psr;
> =20
>  	irqstatus =3D m_can_read(priv, M_CAN_IR);
>  	if (irqstatus)
> @@ -337,6 +526,48 @@ static int m_can_poll(struct napi_struct *napi, in=
t quota)
>  	if (!irqstatus)
>  		goto end;
> =20
> +	psr =3D m_can_read(priv, M_CAN_PSR);
> +	if (irqstatus & IR_ERR_STATE) {
> +		if ((psr & PSR_EW) &&
> +			(priv->can.state !=3D CAN_STATE_ERROR_WARNING)) {
> +			netdev_dbg(dev, "entered error warning state\n");
> +			work_done +=3D m_can_handle_state_change(dev,
> +					CAN_STATE_ERROR_WARNING);
> +		}
> +
> +		if ((psr & PSR_EP) &&
> +			(priv->can.state !=3D CAN_STATE_ERROR_PASSIVE)) {
> +			netdev_dbg(dev, "entered error warning state\n");
> +			work_done +=3D m_can_handle_state_change(dev,
> +					CAN_STATE_ERROR_PASSIVE);
> +		}
> +
> +		if ((psr & PSR_BO) &&
> +			(priv->can.state !=3D CAN_STATE_BUS_OFF)) {
> +			netdev_dbg(dev, "entered error warning state\n");
> +			work_done +=3D m_can_handle_state_change(dev,
> +					CAN_STATE_BUS_OFF);
> +		}

You might want to push this into a seperate function.

> +	}
> +
> +	if (irqstatus & IR_ERR_BUS) {
> +		if (irqstatus & IR_RF0L)
> +			work_done +=3D m_can_handle_lost_msg(dev);
> +
> +		/* handle lec errors on the bus */
> +		if (psr & LEC_UNUSED)
> +			work_done +=3D m_can_handle_bus_err(dev,
> +					psr & LEC_UNUSED);
> +
> +		/* other unproccessed error interrupts */
> +		if (irqstatus & IR_WDI)
> +			netdev_err(dev, "Message RAM Watchdog event due to missing READY\n"=
);
> +		if (irqstatus & IR_TOO)
> +			netdev_err(dev, "Timeout reached\n");
> +		if (irqstatus & IR_MRAF)
> +			netdev_err(dev, "Message RAM access failure occurred\n");

same here
> +	}
> +
>  	if (irqstatus & IR_RF0N)
>  		/* handle events corresponding to receive message objects */
>  		work_done +=3D m_can_do_rx_poll(dev, (quota - work_done));
> @@ -369,31 +600,18 @@ static irqreturn_t m_can_isr(int irq, void *dev_i=
d)
>  	if (ir & IR_ALL_INT)
>  		m_can_write(priv, M_CAN_IR, ir);
> =20
> -	if (ir & IR_ERR_ALL) {
> -		netdev_dbg(dev, "bus error\n");
> -		/* TODO: handle bus error */
> -	}
> -
> -	/* save irqstatus for later using */
> -	priv->irqstatus =3D ir;
> -
>  	/*
>  	 * schedule NAPI in case of
>  	 * - rx IRQ
> -	 * - state change IRQ(TODO)
> -	 * - bus error IRQ and bus error reporting (TODO)
> +	 * - state change IRQ
> +	 * - bus error IRQ and bus error reporting
>  	 */
> -	if (ir & IR_RF0N) {
> +	if ((ir & IR_RF0N) || (ir & IR_ERR_ALL)) {
> +		priv->irqstatus =3D ir;
>  		m_can_enable_all_interrupts(priv, false);
>  		napi_schedule(&priv->napi);
>  	}
> =20
> -	/* FIFO overflow */
> -	if (ir & IR_RF0L) {
> -		dev->stats.rx_over_errors++;
> -		dev->stats.rx_errors++;
> -	}
> -
>  	/* transmission complete interrupt */
>  	if (ir & IR_TC) {
>  		netdev_dbg(dev, "tx complete\n");
> @@ -446,7 +664,6 @@ static int m_can_set_bittiming(struct net_device *d=
ev)
>   * - setup bittiming
>   * - TODO:
>   *   1) other working modes support like monitor, loopback...
> - *   2) lec error status report enable
>   */
>  static void m_can_chip_config(struct net_device *dev)
>  {
> @@ -515,14 +732,6 @@ static int m_can_set_mode(struct net_device *dev, =
enum can_mode mode)
>  	return 0;
>  }
> =20
> -static int m_can_get_berr_counter(const struct net_device *dev,
> -				  struct can_berr_counter *bec)
> -{
> -	/* TODO */
> -
> -	return 0;
> -}
> -
>  static void free_m_can_dev(struct net_device *dev)
>  {
>  	free_candev(dev);
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--XjqxDXr1fvlB7TXxRhuVshBWOi5JSMhS6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlOyj1MACgkQjTAFq1RaXHOR1QCeNMt3C51PO5XnFOlpMUeF+92U
l8sAnjcY5V5JcSZlEhSI2Nw0cQgcSmQP
=9mNq
-----END PGP SIGNATURE-----

--XjqxDXr1fvlB7TXxRhuVshBWOi5JSMhS6--
