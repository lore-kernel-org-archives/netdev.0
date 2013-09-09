From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 01/16] c_can_platform: add FlexCard D-CAN support
Date: Mon, 09 Sep 2013 10:22:39 +0200
Message-ID: <522D854F.2030207@pengutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de> <1378711513-2548-2-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="sP0JJEvXa4Q6lrrReQaOI2X183FB2km1h"
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:51616 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122Ab3IIIWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 04:22:51 -0400
In-Reply-To: <1378711513-2548-2-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--sP0JJEvXa4Q6lrrReQaOI2X183FB2km1h
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2013 09:24 AM, Benedikt Spranger wrote:
> FlexCard supports up to 8 D-CAN devices with a shared DMA-capable recei=
ve
> function. Add support for FlexCard D-CAN.
>=20
> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>

What are the prerequisites for this series? This doesn't compile against
current net-next/master (e7d33bb lockref: add ability to mark lockrefs
"dead").

More Comments inline.
Marc

> ---
>  drivers/net/can/c_can/c_can.h          |   1 +
>  drivers/net/can/c_can/c_can_platform.c | 149 +++++++++++++++++++++++++=
+++++++-
>  2 files changed, 148 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_ca=
n.h
> index d2e1c21..d2e2d20 100644
> --- a/drivers/net/can/c_can/c_can.h
> +++ b/drivers/net/can/c_can/c_can.h
> @@ -148,6 +148,7 @@ enum c_can_dev_id {
>  	BOSCH_C_CAN_PLATFORM,
>  	BOSCH_C_CAN,
>  	BOSCH_D_CAN,
> +	BOSCH_D_CAN_FLEXCARD,
>  };
> =20
>  /* c_can private data structure */
> diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c=
_can/c_can_platform.c
> index c6f838d..43a3e3f 100644
> --- a/drivers/net/can/c_can/c_can_platform.c
> +++ b/drivers/net/can/c_can/c_can_platform.c
> @@ -32,6 +32,7 @@
>  #include <linux/clk.h>
>  #include <linux/of.h>
>  #include <linux/of_device.h>
> +#include <linux/flexcard.h>
> =20
>  #include <linux/can/dev.h>
> =20
> @@ -81,6 +82,112 @@ static void c_can_hw_raminit(const struct c_can_pri=
v *priv, bool enable)
>  	writel(val, priv->raminit_ctrlreg);
>  }
> =20
> +static int c_can_rx_pkt(void *p, void *data, size_t len)
> +{

Why are the first two arguments a void *, why do we have len, that's
never used? Has the length already been checked, is it guaranteed >=3D
sizeof(struct fc_packet_buf)?

> +	struct net_device *dev =3D p;
> +	struct net_device_stats *stats =3D &dev->stats;
> +	struct fc_packet_buf *pb =3D data;
> +	union fc_packet_types *pt =3D &pb->packet;
> +	struct can_frame *frame;
> +	struct sk_buff *skb;
> +	u32 flags, id, state, type;
> +
> +	switch (le32_to_cpu(pb->header.type)) {
> +	case fc_packet_type_can:
> +		skb =3D alloc_can_skb(dev, &frame);
> +		if (!skb) {
> +			stats->rx_dropped++;
> +			return -ENOMEM;
> +		}
> +
> +		id =3D le32_to_cpu(pt->can_packet.id);
> +		flags =3D le32_to_cpu(pt->can_packet.flags);
> +
> +		if (id & BIT(29))
> +			frame->can_id =3D (id & CAN_EFF_MASK) | CAN_EFF_FLAG;
> +		else
> +			frame->can_id =3D id & CAN_SFF_MASK;
> +
> +		if (flags & BIT(13))
> +			frame->can_id |=3D CAN_RTR_FLAG;
> +		frame->can_dlc =3D (flags >> 8) & 0xf;

please use get_can_dlc((flags >> 8) & 0xf)

> +		memcpy(frame->data, pt->can_packet.data, frame->can_dlc);

Please don't copy data if you receive an RTR frame. What about the
endianess of the data?

> +		netif_receive_skb(skb);
> +
> +		stats->rx_packets++;
> +		stats->rx_bytes +=3D frame->can_dlc;
> +		break;
> +
> +	case fc_packet_type_can_error:
> +		stats->rx_errors++;
> +
> +		skb =3D alloc_can_err_skb(dev, &frame);
> +		if (!skb)
> +			return -ENOMEM;
> +
> +		type =3D le32_to_cpu(pt->can_error_packet.type);
> +		state =3D le32_to_cpu(pt->can_error_packet.state);
> +
> +		switch (state) {
> +		case fc_can_state_warning:
> +			frame->data[1] |=3D CAN_ERR_CRTL_RX_WARNING;
> +			frame->data[1] |=3D CAN_ERR_CRTL_TX_WARNING;
> +			frame->can_id |=3D CAN_ERR_CRTL;
> +			break;
> +		case fc_can_state_error_passive:
> +			frame->data[1] |=3D CAN_ERR_CRTL_RX_PASSIVE;
> +			frame->data[1] |=3D CAN_ERR_CRTL_TX_PASSIVE;
> +			frame->can_id |=3D CAN_ERR_CRTL;
> +			break;
> +		case fc_can_state_bus_off:
> +			frame->can_id |=3D CAN_ERR_BUSOFF;
> +			break;
> +		}
> +
> +		switch (type) {
> +		case fc_can_error_stuff:
> +			frame->data[2] |=3D CAN_ERR_PROT_STUFF;
> +			frame->can_id |=3D CAN_ERR_PROT;
> +			break;
> +		case fc_can_error_form:
> +			frame->data[2] |=3D CAN_ERR_PROT_FORM;
> +			frame->can_id |=3D CAN_ERR_PROT;
> +			break;
> +		case fc_can_error_acknowledge:
> +			frame->can_id |=3D CAN_ERR_ACK;
> +			break;
> +		case fc_can_error_bit1:
> +			frame->data[2] |=3D CAN_ERR_PROT_BIT1;
> +			frame->can_id |=3D CAN_ERR_PROT;
> +			break;
> +		case fc_can_error_bit0:
> +			frame->data[2] |=3D CAN_ERR_PROT_BIT0;
> +			frame->can_id |=3D CAN_ERR_PROT;
> +			break;
> +		case fc_can_error_crc:
> +			frame->data[3] |=3D CAN_ERR_PROT_LOC_CRC_SEQ;
> +			frame->can_id |=3D CAN_ERR_PROT;
> +			break;
> +		case fc_can_error_parity:
> +			frame->data[1] |=3D CAN_ERR_PROT_UNSPEC;
> +			frame->can_id |=3D CAN_ERR_CRTL;
> +			break;
> +		}
> +		frame->data[5] =3D pt->can_error_packet.rx_error_counter;
> +		frame->data[6] =3D pt->can_error_packet.tx_error_counter;
> +
> +		stats->rx_bytes +=3D frame->can_dlc;
> +		stats->rx_packets++;
> +
> +		netif_receive_skb(skb);
> +		break;
> +	default:
> +		return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
>  static struct platform_device_id c_can_id_table[] =3D {
>  	[BOSCH_C_CAN_PLATFORM] =3D {
>  		.name =3D KBUILD_MODNAME,
> @@ -93,6 +200,10 @@ static struct platform_device_id c_can_id_table[] =3D=
 {
>  	[BOSCH_D_CAN] =3D {
>  		.name =3D "d_can",
>  		.driver_data =3D BOSCH_D_CAN,
> +	},
> +	[BOSCH_D_CAN_FLEXCARD] =3D {
> +		.name =3D "flexcard-d_can",
> +		.driver_data =3D BOSCH_D_CAN_FLEXCARD,
>  	}, {
>  	}
>  };
> @@ -108,7 +219,7 @@ MODULE_DEVICE_TABLE(of, c_can_of_table);
>  static int c_can_plat_probe(struct platform_device *pdev)
>  {
>  	int ret;
> -	void __iomem *addr;
> +	void __iomem *addr, *reset_reg;
>  	struct net_device *dev;
>  	struct c_can_priv *priv;
>  	const struct of_device_id *match;
> @@ -167,6 +278,8 @@ static int c_can_plat_probe(struct platform_device =
*pdev)
>  	}
> =20
>  	priv =3D netdev_priv(dev);
> +	priv->can.clock.freq =3D clk_get_rate(clk);
> +
>  	switch (id->driver_data) {
>  	case BOSCH_C_CAN:
>  		priv->regs =3D reg_map_c_can;
> @@ -199,7 +312,26 @@ static int c_can_plat_probe(struct platform_device=
 *pdev)
>  			dev_info(&pdev->dev, "control memory is not used for raminit\n");
>  		else
>  			priv->raminit =3D c_can_hw_raminit;
> +

Please remove

>  		break;
> +	case BOSCH_D_CAN_FLEXCARD:
> +		priv->regs =3D reg_map_d_can;
> +		priv->can.ctrlmode_supported |=3D CAN_CTRLMODE_3_SAMPLES;
> +		priv->read_reg =3D c_can_plat_read_reg_aligned_to_16bit;
> +		priv->write_reg =3D c_can_plat_write_reg_aligned_to_16bit;
> +		priv->instance =3D pdev->id;
> +
> +		res =3D platform_get_resource(pdev, IORESOURCE_MEM, 1);
> +		reset_reg =3D ioremap(res->start, resource_size(res));
> +		if (!reset_reg || priv->instance < 0) {

priv->instance in unsinged

> +			dev_info(&pdev->dev, "Can't reset device.\n");
> +		} else {
> +			writel(1 << (4 + priv->instance), addr);
> +			udelay(100);
> +		}
> +		iounmap(reset_reg);
> +		priv->can.clock.freq =3D 16000000;
> +
>  	default:
>  		ret =3D -EINVAL;
>  		goto exit_free_device;
> @@ -208,7 +340,6 @@ static int c_can_plat_probe(struct platform_device =
*pdev)
>  	dev->irq =3D irq;
>  	priv->base =3D addr;
>  	priv->device =3D &pdev->dev;
> -	priv->can.clock.freq =3D clk_get_rate(clk);
>  	priv->priv =3D clk;
>  	priv->type =3D id->driver_data;
> =20
> @@ -222,10 +353,22 @@ static int c_can_plat_probe(struct platform_devic=
e *pdev)
>  		goto exit_free_device;
>  	}
> =20
> +	if (id->driver_data =3D=3D BOSCH_D_CAN_FLEXCARD) {
> +		ret =3D fc_register_rx_pkt(FC_CANIF_OFFSET + pdev->id,
> +				dev, c_can_rx_pkt);
> +		if (ret) {
> +			dev_err(&pdev->dev,
> +					"registering RX-CB failed %d\n", ret);
> +			goto exit_unregister_device;
> +		}
> +	}
> +
>  	dev_info(&pdev->dev, "%s device registered (regs=3D%p, irq=3D%d)\n",
>  		 KBUILD_MODNAME, priv->base, dev->irq);
>  	return 0;
> =20
> +exit_unregister_device:
> +	unregister_c_can_dev(dev);
>  exit_free_device:
>  	free_c_can_dev(dev);
>  exit_iounmap:
> @@ -246,6 +389,8 @@ static int c_can_plat_remove(struct platform_device=
 *pdev)
>  	struct c_can_priv *priv =3D netdev_priv(dev);
>  	struct resource *mem;
> =20
> +	if (priv->type =3D=3D BOSCH_D_CAN_FLEXCARD)
> +		fc_unregister_rx_pkt(FC_CANIF_OFFSET + priv->instance);
>  	unregister_c_can_dev(dev);
> =20
>  	free_c_can_dev(dev);
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--sP0JJEvXa4Q6lrrReQaOI2X183FB2km1h
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlIthU8ACgkQjTAFq1RaXHOqIQCdFYW9PO4gwtCBI/iY5s/fy4w3
zf4AnRjcNG7/xLDu6ZCwcAi99B686/ic
=wIiD
-----END PGP SIGNATURE-----

--sP0JJEvXa4Q6lrrReQaOI2X183FB2km1h--
