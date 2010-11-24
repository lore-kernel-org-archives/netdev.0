From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 6/17 v3] can: EG20T PCH: Fix endianness issue
Date: Wed, 24 Nov 2010 14:31:33 +0100
Message-ID: <4CED13B5.5020309@pengutronix.de>
References: <4CED023E.1070009@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7683812439816048531=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CED023E.1070009-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============7683812439816048531==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigF36C65A1CE5F6BAE3857FD71"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF36C65A1CE5F6BAE3857FD71
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/24/2010 01:17 PM, Tomoya MORINAGA wrote:
> Fix endianness issue.
> there is endianness issue both Tx and Rx.
> Currently, data is set like below.
> Register:
>  MSB--LSB
>  x x D0 D1
>  x x D2 D3
>  x x D4 D5
>  x x D6 D7
>=20
> But Data to be sent must be set like below.
> Register:
>  MSB--LSB
>  x x D1 D0
>  x x D3 D2
>  x x D5 D4
>  x x D7 D6  (x means reserved area.)

The endianess handling looks good now! (the & 0xff can be removed,
though, see linline)
>=20
>=20
> Modify netif_rx() to netif_receive_skb().

Please give a reason, I suppose because the function is used from NAPI.
(Frankly speaking this has nothing to do with endianess issues).

> For easy to read, some sub-functions are created.
>=20
>=20
> Modify complex "goto" to do~while.

What about the next_flag in the rx_normal function? Can you get rid of
it, too?

>=20
> Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
> ---
> From 468cf576aadc0ce26496eaf13fbac4bb2670a9de Mon Sep 17 00:00:00 2001
> From: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
> Date: Thu, 18 Nov 2010 10:23:32 +0900
> Subject: [PATCH] CAN : Improve RxTx processing
>=20
> Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
> ---
>  drivers/net/can/pch_can.c |  306
> +++++++++++++++++++++++----------------------
>  1 files changed, 156 insertions(+), 150 deletions(-)
>=20
> diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
> index 843bbce..fa47707 100644
> --- a/drivers/net/can/pch_can.c
> +++ b/drivers/net/can/pch_can.c
> @@ -133,10 +133,7 @@ struct pch_can_if_regs {
>  	u32 id1;
>  	u32 id2;
>  	u32 mcont;
> -	u32 dataa1;
> -	u32 dataa2;
> -	u32 datab1;
> -	u32 datab2;
> +	u32 data[4];
>  	u32 rsv[13];
>  };
>=20
> @@ -421,10 +418,10 @@ static void pch_can_clear_buffers(struct
> pch_can_priv *priv)
>  		iowrite32(0x0, &priv->regs->ifregs[0].id1);
>  		iowrite32(0x0, &priv->regs->ifregs[0].id2);
>  		iowrite32(0x0, &priv->regs->ifregs[0].mcont);
> -		iowrite32(0x0, &priv->regs->ifregs[0].dataa1);
> -		iowrite32(0x0, &priv->regs->ifregs[0].dataa2);
> -		iowrite32(0x0, &priv->regs->ifregs[0].datab1);
> -		iowrite32(0x0, &priv->regs->ifregs[0].datab2);
> +		iowrite32(0x0, &priv->regs->ifregs[0].data[0]);
> +		iowrite32(0x0, &priv->regs->ifregs[0].data[1]);
> +		iowrite32(0x0, &priv->regs->ifregs[0].data[2]);
> +		iowrite32(0x0, &priv->regs->ifregs[0].data[3]);
>  		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
>  			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
>  			  &priv->regs->ifregs[0].cmask);
> @@ -438,10 +435,10 @@ static void pch_can_clear_buffers(struct
> pch_can_priv *priv)
>  		iowrite32(0x0, &priv->regs->ifregs[1].id1);
>  		iowrite32(0x0, &priv->regs->ifregs[1].id2);
>  		iowrite32(0x0, &priv->regs->ifregs[1].mcont);
> -		iowrite32(0x0, &priv->regs->ifregs[1].dataa1);
> -		iowrite32(0x0, &priv->regs->ifregs[1].dataa2);
> -		iowrite32(0x0, &priv->regs->ifregs[1].datab1);
> -		iowrite32(0x0, &priv->regs->ifregs[1].datab2);
> +		iowrite32(0x0, &priv->regs->ifregs[1].data[0]);
> +		iowrite32(0x0, &priv->regs->ifregs[1].data[1]);
> +		iowrite32(0x0, &priv->regs->ifregs[1].data[2]);
> +		iowrite32(0x0, &priv->regs->ifregs[1].data[3]);
>  		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
>  			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
>  			  &priv->regs->ifregs[1].cmask);
> @@ -683,7 +680,7 @@ static void pch_can_error(struct net_device *ndev,
> u32 status)
>  	cf->data[7] =3D (errc & PCH_REC) >> 8;
>=20
>  	priv->can.state =3D state;
> -	netif_rx(skb);
> +	netif_receive_skb(skb);

This is an unrelated fix. Please split into separate patch.

>=20
>  	stats->rx_packets++;
>  	stats->rx_bytes +=3D cf->can_dlc;
> @@ -701,190 +698,202 @@ static irqreturn_t pch_can_interrupt(int irq,
> void *dev_id)
>  	return IRQ_HANDLED;
>  }
>=20
> -static int pch_can_rx_normal(struct net_device *ndev, u32 int_stat)
> +static void pch_fifo_thresh(struct pch_can_priv *priv, int obj_id)
> +{
> +	if (obj_id < PCH_FIFO_THRESH) {
> +		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL |
> +			  PCH_CMASK_ARB, &priv->regs->ifregs[0].cmask);
> +
> +		/* Clearing the Dir bit. */
> +		pch_can_bit_clear(&priv->regs->ifregs[0].id2, PCH_ID2_DIR);
> +
> +		/* Clearing NewDat & IntPnd */
> +		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
> +				  PCH_IF_MCONT_INTPND);
> +		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, obj_id);
> +	} else if (obj_id > PCH_FIFO_THRESH) {
> +		pch_can_int_clr(priv, obj_id);
> +	} else if (obj_id =3D=3D PCH_FIFO_THRESH) {
> +		int cnt;
> +		for (cnt =3D 0; cnt < PCH_FIFO_THRESH; cnt++)
> +			pch_can_int_clr(priv, cnt+1);
                                              ^^^^^

nitpick: there should be spaces around the "+".

> +	}
> +}
> +
> +static int pch_can_rx_msg_lost(struct net_device *ndev, int obj_id)
> +{
> +	struct pch_can_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &(priv->ndev->stats);
> +	struct sk_buff *skb;
> +	struct can_frame *cf;
> +
> +	netdev_dbg(priv->ndev, "Msg Obj is overwritten.\n");
> +	pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
> +			  PCH_IF_MCONT_MSGLOST);
> +	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
> +		  &priv->regs->ifregs[0].cmask);
> +	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, obj_id);
> +
> +	skb =3D alloc_can_err_skb(ndev, &cf);
> +	if (!skb)
> +		return -ENOMEM;
> +
> +	cf->can_id |=3D CAN_ERR_CRTL;
> +	cf->data[1] =3D CAN_ERR_CRTL_RX_OVERFLOW;
> +	stats->rx_over_errors++;
> +	stats->rx_errors++;
> +
> +	netif_receive_skb(skb);
> +
> +	return 0;
> +}
> +
> +static int pch_can_rx_normal(struct net_device *ndev, u32 obj_num, int=

> quota)
>  {
>  	u32 reg;
>  	canid_t id;
> -	u32 ide;
> -	u32 rtr;
> -	int i, j, k;
>  	int rcv_pkts =3D 0;
> +	int rtn;
> +	int next_flag =3D 0;
>  	struct sk_buff *skb;
>  	struct can_frame *cf;
>  	struct pch_can_priv *priv =3D netdev_priv(ndev);
>  	struct net_device_stats *stats =3D &(priv->ndev->stats);
> +	int i;
> +	u32 id2;
> +	u16 data_reg;
>=20
> -	/* Reading the messsage object from the Message RAM */
> -	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
> -	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, int_stat);
> +	do {
> +		/* Reading the messsage object from the Message RAM */
> +		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
> +		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, obj_num);
>=20
> -	/* Reading the MCONT register. */
> -	reg =3D ioread32(&priv->regs->ifregs[0].mcont);
> -	reg &=3D 0xffff;
> +		/* Reading the MCONT register. */
> +		reg =3D ioread32(&priv->regs->ifregs[0].mcont);
> +
> +		if (reg & PCH_IF_MCONT_EOB)
> +			break;
>=20
> -	for (k =3D int_stat; !(reg & PCH_IF_MCONT_EOB); k++) {
>  		/* If MsgLost bit set. */
>  		if (reg & PCH_IF_MCONT_MSGLOST) {
> -			dev_err(&priv->ndev->dev, "Msg Obj is overwritten.\n");
> -			pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
> -					  PCH_IF_MCONT_MSGLOST);
> -			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
> -				  &priv->regs->ifregs[0].cmask);
> -			pch_can_check_if_busy(&priv->regs->ifregs[0].creq, k);
> -
> -			skb =3D alloc_can_err_skb(ndev, &cf);
> +			rtn =3D pch_can_rx_msg_lost(ndev, obj_num);
> +			if (!rtn)
> +				return rtn;

The function return "0" on success or -ENOMEM. The logic seems inverted.
IMHO just keep going if you had an OOM situation.

> +			rcv_pkts++;
> +			quota--;
> +			next_flag =3D 1;
> +		} else if (!(reg & PCH_IF_MCONT_NEWDAT))
> +			next_flag =3D 1;

Please get rid of the next_flag, rearrange your code and use "continue".

> +		if (!next_flag) {
> +			skb =3D alloc_can_skb(priv->ndev, &cf);
>  			if (!skb)
>  				return -ENOMEM;
>=20
> -			priv->can.can_stats.error_passive++;
> -			priv->can.state =3D CAN_STATE_ERROR_PASSIVE;
> -			cf->can_id |=3D CAN_ERR_CRTL;
> -			cf->data[1] |=3D CAN_ERR_CRTL_RX_OVERFLOW;
> -			cf->data[2] |=3D CAN_ERR_PROT_OVERLOAD;
> -			stats->rx_packets++;
> -			stats->rx_bytes +=3D cf->can_dlc;
> +			/* Get Received data */
> +			id2 =3D ioread32(&priv->regs->ifregs[0].id2);
> +			if (id2 & PCH_ID2_XTD) {
> +				id =3D (ioread32(&priv->regs->ifregs[0].id1) &
> +					       0xffff);
> +				id |=3D (((id2) & 0x1fff) << 16);
> +				cf->can_id =3D id | CAN_EFF_FLAG;
> +			} else {
> +				id =3D ((id2 & (CAN_SFF_MASK << 2)) >> 2);
> +				cf->can_id =3D id;
> +			}
> +
> +			if (id2 & PCH_ID2_DIR)
> +				cf->can_id |=3D CAN_RTR_FLAG;
> +
> +			cf->can_dlc =3D get_can_dlc((ioread32(&priv->regs->
> +						   ifregs[0].mcont)) & 0xF);
> +
> +			for (i =3D 0; i < cf->can_dlc; i +=3D 2) {
> +				data_reg =3D ioread16(&priv->regs->ifregs[0].
> +						    data[i / 2]);
> +				cf->data[i] =3D data_reg & 0xff;
> +				cf->data[i + 1] =3D (data_reg >> 8) & 0xff;

the & 0xff are not needed, cf->data[] is 8bit only.

> +			}
>=20
>  			netif_receive_skb(skb);
>  			rcv_pkts++;
> -			goto RX_NEXT;
> -		}
> -		if (!(reg & PCH_IF_MCONT_NEWDAT))
> -			goto RX_NEXT;
> -
> -		skb =3D alloc_can_skb(priv->ndev, &cf);
> -		if (!skb)
> -			return -ENOMEM;
> -
> -		/* Get Received data */
> -		ide =3D ((ioread32(&priv->regs->ifregs[0].id2)) & PCH_ID2_XTD) >>
> -									     14;
> -		if (ide) {
> -			id =3D (ioread32(&priv->regs->ifregs[0].id1) & 0xffff);
> -			id |=3D (((ioread32(&priv->regs->ifregs[0].id2)) &
> -					    0x1fff) << 16);
> -			cf->can_id =3D (id & CAN_EFF_MASK) | CAN_EFF_FLAG;
> -		} else {
> -			id =3D (((ioread32(&priv->regs->ifregs[0].id2)) &
> -						     (CAN_SFF_MASK << 2)) >> 2);
> -			cf->can_id =3D (id & CAN_SFF_MASK);
> -		}
> +			stats->rx_packets++;
> +			quota--;
> +			stats->rx_bytes +=3D cf->can_dlc;
>=20
> -		rtr =3D (ioread32(&priv->regs->ifregs[0].id2) &  PCH_ID2_DIR);
> -		if (rtr) {
> -			cf->can_dlc =3D 0;
> -			cf->can_id |=3D CAN_RTR_FLAG;
> -		} else {
> -			cf->can_dlc =3D
> -			      ((ioread32(&priv->regs->ifregs[0].mcont)) & 0x0f);
> +			pch_fifo_thresh(priv, obj_num);
>  		}
> +		obj_num++;
> +		next_flag =3D 0;
> +	} while (quota > 0);
>=20
> -		for (i =3D 0, j =3D 0; i < cf->can_dlc; j++) {
> -			reg =3D ioread32(&priv->regs->ifregs[0].dataa1 + j*4);
> -			cf->data[i++] =3D cpu_to_le32(reg & 0xff);
> -			if (i =3D=3D cf->can_dlc)
> -				break;
> -			cf->data[i++] =3D cpu_to_le32((reg >> 8) & 0xff);
> -		}
> +	return rcv_pkts;
> +}
>=20
> -		netif_receive_skb(skb);
> -		rcv_pkts++;
> -		stats->rx_packets++;
> -		stats->rx_bytes +=3D cf->can_dlc;
> -
> -		if (k < PCH_FIFO_THRESH) {
> -			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL |
> -				  PCH_CMASK_ARB, &priv->regs->ifregs[0].cmask);
> -
> -			/* Clearing the Dir bit. */
> -			pch_can_bit_clear(&priv->regs->ifregs[0].id2,
> -					  PCH_ID2_DIR);
> -
> -			/* Clearing NewDat & IntPnd */
> -			pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
> -					  PCH_IF_MCONT_INTPND);
> -			pch_can_check_if_busy(&priv->regs->ifregs[0].creq, k);
> -		} else if (k > PCH_FIFO_THRESH) {
> -			pch_can_int_clr(priv, k);
> -		} else if (k =3D=3D PCH_FIFO_THRESH) {
> -			int cnt;
> -			for (cnt =3D 0; cnt < PCH_FIFO_THRESH; cnt++)
> -				pch_can_int_clr(priv, cnt+1);
> -		}
> -RX_NEXT:
> -		/* Reading the messsage object from the Message RAM */
> -		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
> -		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, k);
> -		reg =3D ioread32(&priv->regs->ifregs[0].mcont);
> -	}
> +static void pch_can_tx_complete(struct net_device *ndev, u32 int_stat)=

> +{
> +	struct pch_can_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &(priv->ndev->stats);
> +	u32 dlc;
>=20
> -	return rcv_pkts;
> +	can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_END - 1);
> +	iowrite32(PCH_CMASK_RX_TX_GET | PCH_CMASK_CLRINTPND,
> +		  &priv->regs->ifregs[1].cmask);
> +	dlc =3D get_can_dlc(ioread32(&priv->regs->ifregs[1].mcont) &
> +			  PCH_IF_MCONT_DLC);
> +	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, int_stat);

This is the TX-Complete interrupt handler, right? What does the
pch_can_check_if_busy trigger here?

> +	stats->tx_bytes +=3D dlc;
> +	stats->tx_packets++;
> +	if (int_stat =3D=3D PCH_TX_OBJ_END)
> +		netif_wake_queue(ndev);
>  }
> +
>  static int pch_can_rx_poll(struct napi_struct *napi, int quota)
>  {
>  	struct net_device *ndev =3D napi->dev;
>  	struct pch_can_priv *priv =3D netdev_priv(ndev);
> -	struct net_device_stats *stats =3D &(priv->ndev->stats);
> -	u32 dlc;
>  	u32 int_stat;
>  	int rcv_pkts =3D 0;
>  	u32 reg_stat;
>=20
>  	int_stat =3D pch_can_int_pending(priv);
>  	if (!int_stat)
> -		return 0;
> +		goto end;
>=20
> -INT_STAT:
> -	if (int_stat =3D=3D PCH_STATUS_INT) {
> +	if ((int_stat =3D=3D PCH_STATUS_INT) && (quota > 0)) {
>  		reg_stat =3D ioread32(&priv->regs->stat);
>  		if (reg_stat & (PCH_BUS_OFF | PCH_LEC_ALL)) {
> -			if ((reg_stat & PCH_LEC_ALL) !=3D PCH_LEC_ALL)
> +			if (reg_stat & PCH_BUS_OFF ||
> +			   (reg_stat & PCH_LEC_ALL) !=3D PCH_LEC_ALL) {
>  				pch_can_error(ndev, reg_stat);
> +				quota--;
> +			}
>  		}
>=20
> -		if (reg_stat & PCH_TX_OK) {
> -			iowrite32(PCH_CMASK_RX_TX_GET,
> -				  &priv->regs->ifregs[1].cmask);
> -			pch_can_check_if_busy(&priv->regs->ifregs[1].creq,
> -					       ioread32(&priv->regs->intr));
> +		if (reg_stat & PCH_TX_OK)
>  			pch_can_bit_clear(&priv->regs->stat, PCH_TX_OK);
> -		}
>=20
>  		if (reg_stat & PCH_RX_OK)
>  			pch_can_bit_clear(&priv->regs->stat, PCH_RX_OK);
>=20
>  		int_stat =3D pch_can_int_pending(priv);
> -		if (int_stat =3D=3D PCH_STATUS_INT)
> -			goto INT_STAT;
>  	}
>=20
> -MSG_OBJ:
> +	if (quota =3D=3D 0)
> +		goto end;
> +
>  	if ((int_stat >=3D PCH_RX_OBJ_START) && (int_stat <=3D PCH_RX_OBJ_END=
)) {
> -		rcv_pkts =3D pch_can_rx_normal(ndev, int_stat);
> -		if (rcv_pkts < 0)
> -			return 0;
> +		rcv_pkts +=3D pch_can_rx_normal(ndev, int_stat, quota);
> +		quota -=3D rcv_pkts;
> +		if (quota < 0)
> +			goto end;
>  	} else if ((int_stat >=3D PCH_TX_OBJ_START) &&
>  		   (int_stat <=3D PCH_TX_OBJ_END)) {
>  		/* Handle transmission interrupt */
> -		can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_END - 1);
> -		iowrite32(PCH_CMASK_RX_TX_GET | PCH_CMASK_CLRINTPND,
> -			  &priv->regs->ifregs[1].cmask);
> -		dlc =3D ioread32(&priv->regs->ifregs[1].mcont) &
> -			       PCH_IF_MCONT_DLC;
> -		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, int_stat);
> -		if (dlc > 8)
> -			dlc =3D 8;
> -		stats->tx_bytes +=3D dlc;
> -		stats->tx_packets++;
> -		if (int_stat =3D=3D PCH_TX_OBJ_END)
> -			netif_wake_queue(ndev);
> +		pch_can_tx_complete(ndev, int_stat);
>  	}
>=20
> -	int_stat =3D pch_can_int_pending(priv);
> -	if (int_stat =3D=3D PCH_STATUS_INT)
> -		goto INT_STAT;
> -	else if (int_stat >=3D 1 && int_stat <=3D 32)
> -		goto MSG_OBJ;
> -
> +end:
>  	napi_complete(napi);
>  	pch_can_set_int_enables(priv, PCH_CAN_ALL);
>=20
> @@ -1017,10 +1026,10 @@ static int pch_close(struct net_device *ndev)
>=20
>  static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *nd=
ev)
>  {
> -	int i, j;
>  	struct pch_can_priv *priv =3D netdev_priv(ndev);
>  	struct can_frame *cf =3D (struct can_frame *)skb->data;
>  	int tx_obj_no =3D 0;
> +	int i;
>=20
>  	if (can_dropped_invalid_skb(ndev, skb))
>  		return NETDEV_TX_OK;
> @@ -1061,13 +1070,10 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb=
,
> struct net_device *ndev)
>  	if (cf->can_id & CAN_RTR_FLAG)
>  		pch_can_bit_clear(&priv->regs->ifregs[1].id2, PCH_ID2_DIR);
>=20
> -	for (i =3D 0, j =3D 0; i < cf->can_dlc; j++) {
> -		iowrite32(le32_to_cpu(cf->data[i++]),
> -			 (&priv->regs->ifregs[1].dataa1) + j*4);
> -		if (i =3D=3D cf->can_dlc)
> -			break;
> -		iowrite32(le32_to_cpu(cf->data[i++] << 8),
> -			 (&priv->regs->ifregs[1].dataa1) + j*4);
> +	/* Copy data to register */
> +	for (i =3D 0; i < cf->can_dlc; i +=3D 2) {
> +		iowrite16(cf->data[i] | (cf->data[i + 1] << 8),
> +			  &priv->regs->ifregs[1].data[i / 2]);
>  	}
>=20
>  	can_put_echo_skb(skb, ndev, tx_obj_no - PCH_RX_OBJ_END - 1);

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigF36C65A1CE5F6BAE3857FD71
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkztE7gACgkQjTAFq1RaXHOBlQCfRJvevx8DwGk+fARuR0ag3i53
jjQAoJOHCUEB/hhqejFX0n99y2lXTUjw
=Ydo1
-----END PGP SIGNATURE-----

--------------enigF36C65A1CE5F6BAE3857FD71--

--===============7683812439816048531==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============7683812439816048531==--
