From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 1/17] can: EG20T PCH: Separate Interface
	Register(IF1/IF2)
Date: Fri, 19 Nov 2010 10:26:13 +0100
Message-ID: <4CE642B5.4040305@pengutronix.de>
References: <4CE60E8B.5090104@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2759678096179148204=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CE60E8B.5090104-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
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
--===============2759678096179148204==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigAA7322CF06212125F41272D7"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigAA7322CF06212125F41272D7
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/19/2010 06:43 AM, Tomoya MORINAGA wrote:
> Separate interface register from whole of register structure.
> CAN register of Intel PCH EG20T has 2 sets of interface register.
> To reduce whole of code size, separate interface register.
> As a result, the number of function also can be reduced.

Looks good, use enums for PCH_{RX,TX}_IFREG, here not in a later patch.

cheers, Marc

> Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
> ---
>  drivers/net/can/pch_can.c |  442 ++++++++++++++++++++-----------------=
--------
>  1 files changed, 198 insertions(+), 244 deletions(-)
>=20
> diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
> index 238622a..143f100 100644
> --- a/drivers/net/can/pch_can.c
> +++ b/drivers/net/can/pch_can.c
> @@ -102,6 +102,9 @@
>  #define PCH_MSK_CTRL_IE_SIE_EIE	0x07
>  #define PCH_COUNTER_LIMIT	10
> =20
> +#define PCH_RX_IFREG			0
> +#define PCH_TX_IFREG			1

Please use enum here.
(I know, there's a later patch that fixes this.)

> +
>  #define PCH_CAN_CLK		50000000	/* 50MHz */
> =20
>  /* Define the number of message object.
> @@ -122,6 +125,21 @@ enum pch_can_mode {
>  	PCH_CAN_RUN
>  };
> =20
> +struct pch_can_if_regs {
> +	u32 creq;
> +	u32 cmask;
> +	u32 mask1;
> +	u32 mask2;
> +	u32 id1;
> +	u32 id2;
> +	u32 mcont;
> +	u32 dataa1;
> +	u32 dataa2;
> +	u32 datab1;
> +	u32 datab2;
> +	u32 rsv[13];
> +};
> +
>  struct pch_can_regs {
>  	u32 cont;
>  	u32 stat;
> @@ -130,38 +148,21 @@ struct pch_can_regs {
>  	u32 intr;
>  	u32 opt;
>  	u32 brpe;
> -	u32 reserve1;
> -	u32 if1_creq;
> -	u32 if1_cmask;
> -	u32 if1_mask1;
> -	u32 if1_mask2;
> -	u32 if1_id1;
> -	u32 if1_id2;
> -	u32 if1_mcont;
> -	u32 if1_dataa1;
> -	u32 if1_dataa2;
> -	u32 if1_datab1;
> -	u32 if1_datab2;
> -	u32 reserve2;
> -	u32 reserve3[12];
> -	u32 if2_creq;
> -	u32 if2_cmask;
> -	u32 if2_mask1;
> -	u32 if2_mask2;
> -	u32 if2_id1;
> -	u32 if2_id2;
> -	u32 if2_mcont;
> -	u32 if2_dataa1;
> -	u32 if2_dataa2;
> -	u32 if2_datab1;
> -	u32 if2_datab2;
> -	u32 reserve4;
> -	u32 reserve5[20];
> +	u32 reserve;
> +	struct pch_can_if_regs ifregs[2]; /* [0]=3Dif1  [1]=3Dif2 */
> +	u32 reserve1[8];
>  	u32 treq1;
>  	u32 treq2;
> -	u32 reserve6[2];
> -	u32 reserve7[56];
> -	u32 reserve8[3];
> +	u32 reserve2[6];
> +	u32 data1;
> +	u32 data2;
> +	u32 reserve3[6];
> +	u32 canipend1;
> +	u32 canipend2;
> +	u32 reserve4[6];
> +	u32 canmval1;
> +	u32 canmval2;
> +	u32 reserve5[37];
>  	u32 srst;
>  };
> =20
> @@ -303,143 +304,86 @@ static void pch_can_check_if_busy(u32 __iomem *c=
req_addr, u32 num)
>  		pr_err("%s:IF1 BUSY Flag is set forever.\n", __func__);
>  }
> =20
> -static void pch_can_set_rx_enable(struct pch_can_priv *priv, u32 buff_=
num,
> -				  u32 set)
> +static void pch_can_set_rxtx(struct pch_can_priv *priv, u32 buff_num,
> +				  u32 set, u32 dir)
                                           ^^^

use the enum here, too

>  {
>  	unsigned long flags;
> +	u32 ie;
> +
> +	if (dir)
> +		ie =3D PCH_IF_MCONT_TXIE;
> +	else
> +		ie =3D PCH_IF_MCONT_RXIE;
> =20
>  	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
>  	/* Reading the receive buffer data from RAM to Interface1 registers *=
/
> -	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> -	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
> +	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);
> =20
>  	/* Setting the IF1MASK1 register to access MsgVal and RxIE bits */
>  	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_ARB | PCH_CMASK_CTRL,
> -		  &priv->regs->if1_cmask);
> +		  &priv->regs->ifregs[dir].cmask);
> =20
>  	if (set =3D=3D PCH_ENABLE) {
>  		/* Setting the MsgVal and RxIE bits */
> -		pch_can_bit_set(&priv->regs->if1_mcont, PCH_IF_MCONT_RXIE);
> -		pch_can_bit_set(&priv->regs->if1_id2, PCH_ID_MSGVAL);
> +		pch_can_bit_set(&priv->regs->ifregs[dir].mcont, ie);
> +		pch_can_bit_set(&priv->regs->ifregs[dir].id2, PCH_ID_MSGVAL);
> =20
>  	} else if (set =3D=3D PCH_DISABLE) {
>  		/* Resetting the MsgVal and RxIE bits */
> -		pch_can_bit_clear(&priv->regs->if1_mcont, PCH_IF_MCONT_RXIE);
> -		pch_can_bit_clear(&priv->regs->if1_id2, PCH_ID_MSGVAL);
> +		pch_can_bit_clear(&priv->regs->ifregs[dir].mcont, ie);
> +		pch_can_bit_clear(&priv->regs->ifregs[dir].id2, PCH_ID_MSGVAL);
>  	}
> =20
> -	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
> +	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);
>  	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
>  }
> =20
> -static void pch_can_rx_enable_all(struct pch_can_priv *priv)
> -{
> -	int i;
> -
> -	/* Traversing to obtain the object configured as receivers. */
> -	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_RX)
> -			pch_can_set_rx_enable(priv, i + 1, PCH_ENABLE);
> -	}
> -}
> =20
> -static void pch_can_rx_disable_all(struct pch_can_priv *priv)
> +static void pch_can_set_rx_all(struct pch_can_priv *priv, u32 set)
>  {
>  	int i;
> =20
>  	/* Traversing to obtain the object configured as receivers. */
>  	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
>  		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_RX)
> -			pch_can_set_rx_enable(priv, i + 1, PCH_DISABLE);
> +			pch_can_set_rxtx(priv, i + 1, set, PCH_RX_IFREG);
>  	}
>  }
> =20
> -static void pch_can_set_tx_enable(struct pch_can_priv *priv, u32 buff_=
num,
> -				 u32 set)
> -{
> -	unsigned long flags;
> -
> -	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -	/* Reading the Msg buffer from Message RAM to Interface2 registers. *=
/
> -	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> -	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
> -
> -	/* Setting the IF2CMASK register for accessing the
> -		MsgVal and TxIE bits */
> -	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_ARB | PCH_CMASK_CTRL,
> -		 &priv->regs->if2_cmask);
> -
> -	if (set =3D=3D PCH_ENABLE) {
> -		/* Setting the MsgVal and TxIE bits */
> -		pch_can_bit_set(&priv->regs->if2_mcont, PCH_IF_MCONT_TXIE);
> -		pch_can_bit_set(&priv->regs->if2_id2, PCH_ID_MSGVAL);
> -	} else if (set =3D=3D PCH_DISABLE) {
> -		/* Resetting the MsgVal and TxIE bits. */
> -		pch_can_bit_clear(&priv->regs->if2_mcont, PCH_IF_MCONT_TXIE);
> -		pch_can_bit_clear(&priv->regs->if2_id2, PCH_ID_MSGVAL);
> -	}
> -
> -	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
> -	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> -}
> -
> -static void pch_can_tx_enable_all(struct pch_can_priv *priv)
> -{
> -	int i;
> -
> -	/* Traversing to obtain the object configured as transmit object. */
> -	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_TX)
> -			pch_can_set_tx_enable(priv, i + 1, PCH_ENABLE);
> -	}
> -}
> -
> -static void pch_can_tx_disable_all(struct pch_can_priv *priv)
> +static void pch_can_set_tx_all(struct pch_can_priv *priv, u32 set)
>  {
>  	int i;
> =20
>  	/* Traversing to obtain the object configured as transmit object. */
>  	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
>  		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_TX)
> -			pch_can_set_tx_enable(priv, i + 1, PCH_DISABLE);
> +			pch_can_set_rxtx(priv, i + 1, set, PCH_ENABLE);
>  	}
>  }
> =20
> -static void pch_can_get_rx_enable(struct pch_can_priv *priv, u32 buff_=
num,
> -				 u32 *enable)
> +static u32 pch_can_get_rxtx_ir(struct pch_can_priv *priv, u32 buff_num=
, u32 dir)
>  {
>  	unsigned long flags;
> +	u32 ie, enable;
> =20
> -	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> -	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
> -
> -	if (((ioread32(&priv->regs->if1_id2)) & PCH_ID_MSGVAL) &&
> -			((ioread32(&priv->regs->if1_mcont)) &
> -			PCH_IF_MCONT_RXIE))
> -		*enable =3D PCH_ENABLE;
> +	if (dir)
> +		ie =3D PCH_IF_MCONT_RXIE;
>  	else
> -		*enable =3D PCH_DISABLE;
> -	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> -}
> -
> -static void pch_can_get_tx_enable(struct pch_can_priv *priv, u32 buff_=
num,
> -				 u32 *enable)
> -{
> -	unsigned long flags;
> +		ie =3D PCH_IF_MCONT_TXIE;
> =20
>  	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> -	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
> +	pch_can_check_if_busy(&priv->regs->ifregs[dir].creq, buff_num);
> =20
> -	if (((ioread32(&priv->regs->if2_id2)) & PCH_ID_MSGVAL) &&
> -			((ioread32(&priv->regs->if2_mcont)) &
> -			PCH_IF_MCONT_TXIE)) {
> -		*enable =3D PCH_ENABLE;
> +	if (((ioread32(&priv->regs->ifregs[dir].id2)) & PCH_ID_MSGVAL) &&
> +			((ioread32(&priv->regs->ifregs[dir].mcont)) & ie)) {
> +		enable =3D PCH_ENABLE;
>  	} else {
> -		*enable =3D PCH_DISABLE;
> +		enable =3D PCH_DISABLE;
>  	}
>  	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> +	return enable;
>  }
> =20
>  static int pch_can_int_pending(struct pch_can_priv *priv)
> @@ -453,15 +397,17 @@ static void pch_can_set_rx_buffer_link(struct pch=
_can_priv *priv,
>  	unsigned long flags;
> =20
>  	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> -	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
> -	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL, &priv->regs->if1_cmask);
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
> +	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);
> +	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
> +		  &priv->regs->ifregs[0].cmask);
>  	if (set =3D=3D PCH_ENABLE)
> -		pch_can_bit_clear(&priv->regs->if1_mcont, PCH_IF_MCONT_EOB);
> +		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
> +				  PCH_IF_MCONT_EOB);
>  	else
> -		pch_can_bit_set(&priv->regs->if1_mcont, PCH_IF_MCONT_EOB);
> +		pch_can_bit_set(&priv->regs->ifregs[0].mcont, PCH_IF_MCONT_EOB);
> =20
> -	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
> +	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);
>  	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
>  }
> =20
> @@ -471,10 +417,10 @@ static void pch_can_get_rx_buffer_link(struct pch=
_can_priv *priv,
>  	unsigned long flags;
> =20
>  	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> -	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
> +	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, buffer_num);
> =20
> -	if (ioread32(&priv->regs->if1_mcont) & PCH_IF_MCONT_EOB)
> +	if (ioread32(&priv->regs->ifregs[0].mcont) & PCH_IF_MCONT_EOB)
>  		*link =3D PCH_DISABLE;
>  	else
>  		*link =3D PCH_ENABLE;
> @@ -486,37 +432,37 @@ static void pch_can_clear_buffers(struct pch_can_=
priv *priv)
>  	int i;
> =20
>  	for (i =3D 0; i < PCH_RX_OBJ_NUM; i++) {
> -		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->if1_cmask);
> -		iowrite32(0xffff, &priv->regs->if1_mask1);
> -		iowrite32(0xffff, &priv->regs->if1_mask2);
> -		iowrite32(0x0, &priv->regs->if1_id1);
> -		iowrite32(0x0, &priv->regs->if1_id2);
> -		iowrite32(0x0, &priv->regs->if1_mcont);
> -		iowrite32(0x0, &priv->regs->if1_dataa1);
> -		iowrite32(0x0, &priv->regs->if1_dataa2);
> -		iowrite32(0x0, &priv->regs->if1_datab1);
> -		iowrite32(0x0, &priv->regs->if1_datab2);
> +		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->ifregs[0].cmask);
> +		iowrite32(0xffff, &priv->regs->ifregs[0].mask1);
> +		iowrite32(0xffff, &priv->regs->ifregs[0].mask2);
> +		iowrite32(0x0, &priv->regs->ifregs[0].id1);
> +		iowrite32(0x0, &priv->regs->ifregs[0].id2);
> +		iowrite32(0x0, &priv->regs->ifregs[0].mcont);
> +		iowrite32(0x0, &priv->regs->ifregs[0].dataa1);
> +		iowrite32(0x0, &priv->regs->ifregs[0].dataa2);
> +		iowrite32(0x0, &priv->regs->ifregs[0].datab1);
> +		iowrite32(0x0, &priv->regs->ifregs[0].datab2);
>  		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
>  			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
> -			  &priv->regs->if1_cmask);
> -		pch_can_check_if_busy(&priv->regs->if1_creq, i+1);
> +			  &priv->regs->ifregs[0].cmask);
> +		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i+1);
>  	}
> =20
>  	for (i =3D i;  i < PCH_OBJ_NUM; i++) {
> -		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->if2_cmask);
> -		iowrite32(0xffff, &priv->regs->if2_mask1);
> -		iowrite32(0xffff, &priv->regs->if2_mask2);
> -		iowrite32(0x0, &priv->regs->if2_id1);
> -		iowrite32(0x0, &priv->regs->if2_id2);
> -		iowrite32(0x0, &priv->regs->if2_mcont);
> -		iowrite32(0x0, &priv->regs->if2_dataa1);
> -		iowrite32(0x0, &priv->regs->if2_dataa2);
> -		iowrite32(0x0, &priv->regs->if2_datab1);
> -		iowrite32(0x0, &priv->regs->if2_datab2);
> +		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->ifregs[1].cmask);
> +		iowrite32(0xffff, &priv->regs->ifregs[1].mask1);
> +		iowrite32(0xffff, &priv->regs->ifregs[1].mask2);
> +		iowrite32(0x0, &priv->regs->ifregs[1].id1);
> +		iowrite32(0x0, &priv->regs->ifregs[1].id2);
> +		iowrite32(0x0, &priv->regs->ifregs[1].mcont);
> +		iowrite32(0x0, &priv->regs->ifregs[1].dataa1);
> +		iowrite32(0x0, &priv->regs->ifregs[1].dataa2);
> +		iowrite32(0x0, &priv->regs->ifregs[1].datab1);
> +		iowrite32(0x0, &priv->regs->ifregs[1].datab2);
>  		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
>  			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
> -			  &priv->regs->if2_cmask);
> -		pch_can_check_if_busy(&priv->regs->if2_creq, i+1);
> +			  &priv->regs->ifregs[1].cmask);
> +		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i+1);
>  	}
>  }
> =20
> @@ -530,58 +476,60 @@ static void pch_can_config_rx_tx_buffers(struct p=
ch_can_priv *priv)
>  	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
>  		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_RX) {
>  			iowrite32(PCH_CMASK_RX_TX_GET,
> -				&priv->regs->if1_cmask);
> -			pch_can_check_if_busy(&priv->regs->if1_creq, i+1);
> +				&priv->regs->ifregs[0].cmask);
> +			pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i+1);
> =20
> -			iowrite32(0x0, &priv->regs->if1_id1);
> -			iowrite32(0x0, &priv->regs->if1_id2);
> +			iowrite32(0x0, &priv->regs->ifregs[0].id1);
> +			iowrite32(0x0, &priv->regs->ifregs[0].id2);
> =20
> -			pch_can_bit_set(&priv->regs->if1_mcont,
> +			pch_can_bit_set(&priv->regs->ifregs[0].mcont,
>  					PCH_IF_MCONT_UMASK);
> =20
>  			/* Set FIFO mode set to 0 except last Rx Obj*/
> -			pch_can_bit_clear(&priv->regs->if1_mcont,
> +			pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
>  					  PCH_IF_MCONT_EOB);
>  			/* In case FIFO mode, Last EoB of Rx Obj must be 1 */
>  			if (i =3D=3D (PCH_RX_OBJ_NUM - 1))
> -				pch_can_bit_set(&priv->regs->if1_mcont,
> +				pch_can_bit_set(&priv->regs->ifregs[0].mcont,
>  						  PCH_IF_MCONT_EOB);
> =20
> -			iowrite32(0, &priv->regs->if1_mask1);
> -			pch_can_bit_clear(&priv->regs->if1_mask2,
> +			iowrite32(0, &priv->regs->ifregs[0].mask1);
> +			pch_can_bit_clear(&priv->regs->ifregs[0].mask2,
>  					  0x1fff | PCH_MASK2_MDIR_MXTD);
> =20
>  			/* Setting CMASK for writing */
>  			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
>  				  PCH_CMASK_ARB | PCH_CMASK_CTRL,
> -				  &priv->regs->if1_cmask);
> +				  &priv->regs->ifregs[0].cmask);
> =20
> -			pch_can_check_if_busy(&priv->regs->if1_creq, i+1);
> +			pch_can_check_if_busy(&priv->regs->ifregs[0].creq, i+1);
>  		} else if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_TX) {
>  			iowrite32(PCH_CMASK_RX_TX_GET,
> -				&priv->regs->if2_cmask);
> -			pch_can_check_if_busy(&priv->regs->if2_creq, i+1);
> +				&priv->regs->ifregs[1].cmask);
> +			pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i+1);
> =20
>  			/* Resetting DIR bit for reception */
> -			iowrite32(0x0, &priv->regs->if2_id1);
> -			iowrite32(0x0, &priv->regs->if2_id2);
> -			pch_can_bit_set(&priv->regs->if2_id2, PCH_ID2_DIR);
> +			iowrite32(0x0, &priv->regs->ifregs[1].id1);
> +			iowrite32(0x0, &priv->regs->ifregs[1].id2);
> +			pch_can_bit_set(&priv->regs->ifregs[1].id2,
> +					PCH_ID2_DIR);
> =20
>  			/* Setting EOB bit for transmitter */
> -			iowrite32(PCH_IF_MCONT_EOB, &priv->regs->if2_mcont);
> +			iowrite32(PCH_IF_MCONT_EOB,
> +				  &priv->regs->ifregs[1].mcont);
> =20
> -			pch_can_bit_set(&priv->regs->if2_mcont,
> +			pch_can_bit_set(&priv->regs->ifregs[1].mcont,
>  					PCH_IF_MCONT_UMASK);
> =20
> -			iowrite32(0, &priv->regs->if2_mask1);
> -			pch_can_bit_clear(&priv->regs->if2_mask2, 0x1fff);
> +			iowrite32(0, &priv->regs->ifregs[1].mask1);
> +			pch_can_bit_clear(&priv->regs->ifregs[1].mask2, 0x1fff);
> =20
>  			/* Setting CMASK for writing */
>  			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
>  				  PCH_CMASK_ARB | PCH_CMASK_CTRL,
> -				  &priv->regs->if2_cmask);
> +				  &priv->regs->ifregs[1].cmask);
> =20
> -			pch_can_check_if_busy(&priv->regs->if2_creq, i+1);
> +			pch_can_check_if_busy(&priv->regs->ifregs[1].creq, i+1);
>  		}
>  	}
>  	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> @@ -611,10 +559,10 @@ static void pch_can_release(struct pch_can_priv *=
priv)
>  	pch_can_set_int_enables(priv, PCH_CAN_NONE);
> =20
>  	/* Disabling all the receive object. */
> -	pch_can_rx_disable_all(priv);
> +	pch_can_set_rx_all(priv, 0);
> =20
>  	/* Disabling all the transmit object. */
> -	pch_can_tx_disable_all(priv);
> +	pch_can_set_tx_all(priv, 0);
>  }
> =20
>  /* This function clears interrupt(s) from the CAN device. */
> @@ -630,31 +578,31 @@ static void pch_can_int_clr(struct pch_can_priv *=
priv, u32 mask)
>  		/* Setting CMASK for clearing interrupts for
>  					 frame transmission. */
>  		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL | PCH_CMASK_ARB,
> -			  &priv->regs->if2_cmask);
> +			  &priv->regs->ifregs[1].cmask);
> =20
>  		/* Resetting the ID registers. */
> -		pch_can_bit_set(&priv->regs->if2_id2,
> +		pch_can_bit_set(&priv->regs->ifregs[1].id2,
>  			       PCH_ID2_DIR | (0x7ff << 2));
> -		iowrite32(0x0, &priv->regs->if2_id1);
> +		iowrite32(0x0, &priv->regs->ifregs[1].id1);
> =20
>  		/* Claring NewDat, TxRqst & IntPnd */
> -		pch_can_bit_clear(&priv->regs->if2_mcont,
> +		pch_can_bit_clear(&priv->regs->ifregs[1].mcont,
>  				  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND |
>  				  PCH_IF_MCONT_TXRQXT);
> -		pch_can_check_if_busy(&priv->regs->if2_creq, mask);
> +		pch_can_check_if_busy(&priv->regs->ifregs[1].creq, mask);
>  	} else if (priv->msg_obj[mask - 1] =3D=3D PCH_MSG_OBJ_RX) {
>  		/* Setting CMASK for clearing the reception interrupts. */
>  		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL | PCH_CMASK_ARB,
> -			  &priv->regs->if1_cmask);
> +			  &priv->regs->ifregs[0].cmask);
> =20
>  		/* Clearing the Dir bit. */
> -		pch_can_bit_clear(&priv->regs->if1_id2, PCH_ID2_DIR);
> +		pch_can_bit_clear(&priv->regs->ifregs[0].id2, PCH_ID2_DIR);
> =20
>  		/* Clearing NewDat & IntPnd */
> -		pch_can_bit_clear(&priv->regs->if1_mcont,
> +		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
>  				  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND);
> =20
> -		pch_can_check_if_busy(&priv->regs->if1_creq, mask);
> +		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, mask);
>  	}
>  }
> =20
> @@ -685,8 +633,8 @@ static void pch_can_error(struct net_device *ndev, =
u32 status)
>  		return;
> =20
>  	if (status & PCH_BUS_OFF) {
> -		pch_can_tx_disable_all(priv);
> -		pch_can_rx_disable_all(priv);
> +		pch_can_set_tx_all(priv, 0);
> +		pch_can_set_rx_all(priv, 0);
>  		state =3D CAN_STATE_BUS_OFF;
>  		cf->can_id |=3D CAN_ERR_BUSOFF;
>  		can_bus_off(ndev);
> @@ -783,22 +731,22 @@ static int pch_can_rx_normal(struct net_device *n=
dev, u32 int_stat)
>  	struct net_device_stats *stats =3D &(priv->ndev->stats);
> =20
>  	/* Reading the messsage object from the Message RAM */
> -	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> -	pch_can_check_if_busy(&priv->regs->if1_creq, int_stat);
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
> +	pch_can_check_if_busy(&priv->regs->ifregs[0].creq, int_stat);
> =20
>  	/* Reading the MCONT register. */
> -	reg =3D ioread32(&priv->regs->if1_mcont);
> +	reg =3D ioread32(&priv->regs->ifregs[0].mcont);
>  	reg &=3D 0xffff;
> =20
>  	for (k =3D int_stat; !(reg & PCH_IF_MCONT_EOB); k++) {
>  		/* If MsgLost bit set. */
>  		if (reg & PCH_IF_MCONT_MSGLOST) {
>  			dev_err(&priv->ndev->dev, "Msg Obj is overwritten.\n");
> -			pch_can_bit_clear(&priv->regs->if1_mcont,
> +			pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
>  					  PCH_IF_MCONT_MSGLOST);
>  			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
> -				  &priv->regs->if1_cmask);
> -			pch_can_check_if_busy(&priv->regs->if1_creq, k);
> +				  &priv->regs->ifregs[0].cmask);
> +			pch_can_check_if_busy(&priv->regs->ifregs[0].creq, k);
> =20
>  			skb =3D alloc_can_err_skb(ndev, &cf);
>  			if (!skb)
> @@ -824,29 +772,30 @@ static int pch_can_rx_normal(struct net_device *n=
dev, u32 int_stat)
>  			return -ENOMEM;
> =20
>  		/* Get Received data */
> -		ide =3D ((ioread32(&priv->regs->if1_id2)) & PCH_ID2_XTD) >> 14;
> +		ide =3D ((ioread32(&priv->regs->ifregs[0].id2)) & PCH_ID2_XTD) >>
> +									     14;
>  		if (ide) {
> -			id =3D (ioread32(&priv->regs->if1_id1) & 0xffff);
> -			id |=3D (((ioread32(&priv->regs->if1_id2)) &
> +			id =3D (ioread32(&priv->regs->ifregs[0].id1) & 0xffff);
> +			id |=3D (((ioread32(&priv->regs->ifregs[0].id2)) &
>  					    0x1fff) << 16);
>  			cf->can_id =3D (id & CAN_EFF_MASK) | CAN_EFF_FLAG;
>  		} else {
> -			id =3D (((ioread32(&priv->regs->if1_id2)) &
> -					  (CAN_SFF_MASK << 2)) >> 2);
> +			id =3D (((ioread32(&priv->regs->ifregs[0].id2)) &
> +						     (CAN_SFF_MASK << 2)) >> 2);
>  			cf->can_id =3D (id & CAN_SFF_MASK);
>  		}
> =20
> -		rtr =3D (ioread32(&priv->regs->if1_id2) &  PCH_ID2_DIR);
> +		rtr =3D (ioread32(&priv->regs->ifregs[0].id2) &  PCH_ID2_DIR);
>  		if (rtr) {
>  			cf->can_dlc =3D 0;
>  			cf->can_id |=3D CAN_RTR_FLAG;
>  		} else {
> -			cf->can_dlc =3D ((ioread32(&priv->regs->if1_mcont)) &
> -						   0x0f);
> +			cf->can_dlc =3D ((ioread32(&priv->regs->ifregs[0].mcont))
> +						 & 0x0f);
>  		}
> =20
>  		for (i =3D 0, j =3D 0; i < cf->can_dlc; j++) {
> -			reg =3D ioread32(&priv->regs->if1_dataa1 + j*4);
> +			reg =3D ioread32(&priv->regs->ifregs[0].dataa1 + j*4);
>  			cf->data[i++] =3D cpu_to_le32(reg & 0xff);
>  			if (i =3D=3D cf->can_dlc)
>  				break;
> @@ -860,15 +809,16 @@ static int pch_can_rx_normal(struct net_device *n=
dev, u32 int_stat)
> =20
>  		if (k < PCH_FIFO_THRESH) {
>  			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL |
> -				  PCH_CMASK_ARB, &priv->regs->if1_cmask);
> +				  PCH_CMASK_ARB, &priv->regs->ifregs[0].cmask);
> =20
>  			/* Clearing the Dir bit. */
> -			pch_can_bit_clear(&priv->regs->if1_id2, PCH_ID2_DIR);
> +			pch_can_bit_clear(&priv->regs->ifregs[0].id2,
> +					  PCH_ID2_DIR);
> =20
>  			/* Clearing NewDat & IntPnd */
> -			pch_can_bit_clear(&priv->regs->if1_mcont,
> +			pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
>  					  PCH_IF_MCONT_INTPND);
> -			pch_can_check_if_busy(&priv->regs->if1_creq, k);
> +			pch_can_check_if_busy(&priv->regs->ifregs[0].creq, k);
>  		} else if (k > PCH_FIFO_THRESH) {
>  			pch_can_int_clr(priv, k);
>  		} else if (k =3D=3D PCH_FIFO_THRESH) {
> @@ -878,9 +828,9 @@ static int pch_can_rx_normal(struct net_device *nde=
v, u32 int_stat)
>  		}
>  RX_NEXT:
>  		/* Reading the messsage object from the Message RAM */
> -		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> -		pch_can_check_if_busy(&priv->regs->if1_creq, k + 1);
> -		reg =3D ioread32(&priv->regs->if1_mcont);
> +		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
> +		pch_can_check_if_busy(&priv->regs->ifregs[0].creq, k + 1);
> +		reg =3D ioread32(&priv->regs->ifregs[0].mcont);
>  	}
> =20
>  	return rcv_pkts;
> @@ -910,8 +860,9 @@ INT_STAT:
> =20
>  		if (reg_stat & PCH_TX_OK) {
>  			spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -			iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> -			pch_can_check_if_busy(&priv->regs->if2_creq,
> +			iowrite32(PCH_CMASK_RX_TX_GET,
> +				  &priv->regs->ifregs[1].cmask);
> +			pch_can_check_if_busy(&priv->regs->ifregs[1].creq,
>  					       ioread32(&priv->regs->intr));
>  			spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
>  			pch_can_bit_clear(&priv->regs->stat, PCH_TX_OK);
> @@ -938,10 +889,11 @@ MSG_OBJ:
>  			can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_NUM - 1);
>  			spin_lock_irqsave(&priv->msgif_reg_lock, flags);
>  			iowrite32(PCH_CMASK_RX_TX_GET | PCH_CMASK_CLRINTPND,
> -				  &priv->regs->if2_cmask);
> -			dlc =3D ioread32(&priv->regs->if2_mcont) &
> +				  &priv->regs->ifregs[1].cmask);
> +			dlc =3D ioread32(&priv->regs->ifregs[1].mcont) &
>  				       PCH_IF_MCONT_DLC;
> -			pch_can_check_if_busy(&priv->regs->if2_creq, int_stat);
> +			pch_can_check_if_busy(&priv->regs->ifregs[1].creq,
> +					      int_stat);
>  			spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
>  			if (dlc > 8)
>  				dlc =3D 8;
> @@ -996,8 +948,8 @@ static void pch_can_start(struct net_device *ndev)
>  	pch_set_bittiming(ndev);
>  	pch_can_set_optmode(priv);
> =20
> -	pch_can_tx_enable_all(priv);
> -	pch_can_rx_enable_all(priv);
> +	pch_can_set_tx_all(priv, 1);
> +	pch_can_set_rx_all(priv, 1);
> =20
>  	/* Setting the CAN to run mode. */
>  	pch_can_set_run_mode(priv, PCH_CAN_RUN);
> @@ -1125,54 +1077,55 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb=
, struct net_device *ndev)
>  	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> =20
>  	/* Reading the Msg Obj from the Msg RAM to the Interface register. */=

> -	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> -	pch_can_check_if_busy(&priv->regs->if2_creq, tx_buffer_avail);
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[1].cmask);
> +	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, tx_buffer_avail);
> =20
>  	/* Setting the CMASK register. */
> -	pch_can_bit_set(&priv->regs->if2_cmask, PCH_CMASK_ALL);
> +	pch_can_bit_set(&priv->regs->ifregs[1].cmask, PCH_CMASK_ALL);
> =20
>  	/* If ID extended is set. */
> -	pch_can_bit_clear(&priv->regs->if2_id1, 0xffff);
> -	pch_can_bit_clear(&priv->regs->if2_id2, 0x1fff | PCH_ID2_XTD);
> +	pch_can_bit_clear(&priv->regs->ifregs[1].id1, 0xffff);
> +	pch_can_bit_clear(&priv->regs->ifregs[1].id2, 0x1fff | PCH_ID2_XTD);
>  	if (cf->can_id & CAN_EFF_FLAG) {
> -		pch_can_bit_set(&priv->regs->if2_id1, cf->can_id & 0xffff);
> -		pch_can_bit_set(&priv->regs->if2_id2,
> +		pch_can_bit_set(&priv->regs->ifregs[1].id1,
> +				cf->can_id & 0xffff);
> +		pch_can_bit_set(&priv->regs->ifregs[1].id2,
>  				((cf->can_id >> 16) & 0x1fff) | PCH_ID2_XTD);
>  	} else {
> -		pch_can_bit_set(&priv->regs->if2_id1, 0);
> -		pch_can_bit_set(&priv->regs->if2_id2,
> +		pch_can_bit_set(&priv->regs->ifregs[1].id1, 0);
> +		pch_can_bit_set(&priv->regs->ifregs[1].id2,
>  				(cf->can_id & CAN_SFF_MASK) << 2);
>  	}
> =20
>  	/* If remote frame has to be transmitted.. */
>  	if (cf->can_id & CAN_RTR_FLAG)
> -		pch_can_bit_clear(&priv->regs->if2_id2, PCH_ID2_DIR);
> +		pch_can_bit_clear(&priv->regs->ifregs[1].id2, PCH_ID2_DIR);
> =20
>  	for (i =3D 0, j =3D 0; i < cf->can_dlc; j++) {
>  		iowrite32(le32_to_cpu(cf->data[i++]),
> -			 (&priv->regs->if2_dataa1) + j*4);
> +			 (&priv->regs->ifregs[1].dataa1) + j*4);
>  		if (i =3D=3D cf->can_dlc)
>  			break;
>  		iowrite32(le32_to_cpu(cf->data[i++] << 8),
> -			 (&priv->regs->if2_dataa1) + j*4);
> +			 (&priv->regs->ifregs[1].dataa1) + j*4);
>  	}
> =20
>  	can_put_echo_skb(skb, ndev, tx_buffer_avail - PCH_RX_OBJ_NUM - 1);
> =20
>  	/* Updating the size of the data. */
> -	pch_can_bit_clear(&priv->regs->if2_mcont, 0x0f);
> -	pch_can_bit_set(&priv->regs->if2_mcont, cf->can_dlc);
> +	pch_can_bit_clear(&priv->regs->ifregs[1].mcont, 0x0f);
> +	pch_can_bit_set(&priv->regs->ifregs[1].mcont, cf->can_dlc);
> =20
>  	/* Clearing IntPend, NewDat & TxRqst */
> -	pch_can_bit_clear(&priv->regs->if2_mcont,
> +	pch_can_bit_clear(&priv->regs->ifregs[1].mcont,
>  			  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND |
>  			  PCH_IF_MCONT_TXRQXT);
> =20
>  	/* Setting NewDat, TxRqst bits */
> -	pch_can_bit_set(&priv->regs->if2_mcont,
> +	pch_can_bit_set(&priv->regs->ifregs[1].mcont,
>  			PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_TXRQXT);
> =20
> -	pch_can_check_if_busy(&priv->regs->if2_creq, tx_buffer_avail);
> +	pch_can_check_if_busy(&priv->regs->ifregs[1].creq, tx_buffer_avail);
> =20
>  	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> =20
> @@ -1234,25 +1187,25 @@ static int pch_can_suspend(struct pci_dev *pdev=
, pm_message_t state)
>  	/* Save Tx buffer enable state */
>  	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
>  		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_TX)
> -			pch_can_get_tx_enable(priv, i + 1,
> -					      &(priv->tx_enable[i]));
> +			priv->tx_enable[i] =3D pch_can_get_rxtx_ir(priv, i + 1,
> +								 PCH_TX_IFREG);
>  	}
> =20
>  	/* Disable all Transmit buffers */
> -	pch_can_tx_disable_all(priv);
> +	pch_can_set_tx_all(priv, 0);
> =20
>  	/* Save Rx buffer enable state */
>  	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
>  		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_RX) {
> -			pch_can_get_rx_enable(priv, i + 1,
> -						&(priv->rx_enable[i]));
> +			priv->rx_enable[i] =3D pch_can_get_rxtx_ir(priv, i + 1,
> +						PCH_RX_IFREG);
>  			pch_can_get_rx_buffer_link(priv, i + 1,
>  						&(priv->rx_link[i]));
>  		}
>  	}
> =20
>  	/* Disable all Receive buffers */
> -	pch_can_rx_disable_all(priv);
> +	pch_can_set_rx_all(priv, 0);
>  	retval =3D pci_save_state(pdev);
>  	if (retval) {
>  		dev_err(&pdev->dev, "pci_save_state failed.\n");
> @@ -1301,10 +1254,9 @@ static int pch_can_resume(struct pci_dev *pdev)
> =20
>  	/* Enabling the transmit buffer. */
>  	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_TX) {
> -			pch_can_set_tx_enable(priv, i + 1,
> -					      priv->tx_enable[i]);
> -		}
> +		if (priv->msg_obj[i] =3D=3D PCH_MSG_OBJ_TX)
> +			pch_can_set_rxtx(priv, i, priv->tx_enable[i],
> +					 PCH_TX_IFREG);
>  	}
> =20
>  	/* Configuring the receive buffer and enabling them. */
> @@ -1315,7 +1267,9 @@ static int pch_can_resume(struct pci_dev *pdev)
>  						   priv->rx_link[i]);
> =20
>  			/* Restore buffer enables */
> -			pch_can_set_rx_enable(priv, i + 1, priv->rx_enable[i]);
> +			pch_can_set_rxtx(priv, i, priv->rx_enable[i],
> +					 PCH_RX_IFREG);
> +
>  		}
>  	}
> =20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigAA7322CF06212125F41272D7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkzmQrgACgkQjTAFq1RaXHNwJACfRGVNN+M6GcpDotiEjbg4Bbe7
escAniKV2IPfJksG252xfVLpCCtglNMk
=TdRp
-----END PGP SIGNATURE-----

--------------enigAA7322CF06212125F41272D7--

--===============2759678096179148204==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============2759678096179148204==--
