From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Add Flow
	control,
Date: Mon, 15 Nov 2010 10:37:30 +0100
Message-ID: <4CE0FF5A.3000100@pengutronix.de>
References: <4CE0EFA7.9020007@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5415494044181143001=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CE0EFA7.9020007-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
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
--===============5415494044181143001==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9C61BF3E9DD6C4869BDFDE8F"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9C61BF3E9DD6C4869BDFDE8F
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/15/2010 09:30 AM, Tomoya MORINAGA wrote:
>  * Add Flow control
>  * Fix Data copy issue (endianness)
>  * Add Macro prefix "PCH_"
>  * Separate interface register structure
>  * Some functions are unified.
>  * Change MessageObject indication(PCH_RX_OBJ_START, etc..)
>  * Enumerate LEC macro
>  * Move MSI processing from open/close to probe/remove processing
>  * Use BIT(x)
>  * and more...
>=20
> Signed-off-by: Tomoya MORINAGA <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
> ---
>  drivers/net/can/pch_can.c | 1348 ++++++++++++++++++++-----------------=
--------
>  1 files changed, 595 insertions(+), 753 deletions(-)
>=20
> diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
> index 6727182..6a38593 100644
> --- a/drivers/net/can/pch_can.c
> +++ b/drivers/net/can/pch_can.c
> @@ -1,6 +1,6 @@
>  /*
>   * Copyright (C) 1999 - 2010 Intel Corporation.
> - * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
> + * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
>   *
>   * This program is free software; you can redistribute it and/or modif=
y
>   * it under the terms of the GNU General Public License as published b=
y
> @@ -32,106 +32,109 @@
>  #include <linux/can/dev.h>
>  #include <linux/can/error.h>
> =20
> -#define MAX_MSG_OBJ		32
> -#define MSG_OBJ_RX		0 /* The receive message object flag. */
> -#define MSG_OBJ_TX		1 /* The transmit message object flag. */
> -
> -#define ENABLE			1 /* The enable flag */
> -#define DISABLE			0 /* The disable flag */
> -#define CAN_CTRL_INIT		0x0001 /* The INIT bit of CANCONT register. */
> -#define CAN_CTRL_IE		0x0002 /* The IE bit of CAN control register */
> -#define CAN_CTRL_IE_SIE_EIE	0x000e
> -#define CAN_CTRL_CCE		0x0040
> -#define CAN_CTRL_OPT		0x0080 /* The OPT bit of CANCONT register. */
> -#define CAN_OPT_SILENT		0x0008 /* The Silent bit of CANOPT reg. */
> -#define CAN_OPT_LBACK		0x0010 /* The LoopBack bit of CANOPT reg. */
> -#define CAN_CMASK_RX_TX_SET	0x00f3
> -#define CAN_CMASK_RX_TX_GET	0x0073
> -#define CAN_CMASK_ALL		0xff
> -#define CAN_CMASK_RDWR		0x80
> -#define CAN_CMASK_ARB		0x20
> -#define CAN_CMASK_CTRL		0x10
> -#define CAN_CMASK_MASK		0x40
> -#define CAN_CMASK_NEWDAT	0x04
> -#define CAN_CMASK_CLRINTPND	0x08
> -
> -#define CAN_IF_MCONT_NEWDAT	0x8000
> -#define CAN_IF_MCONT_INTPND	0x2000
> -#define CAN_IF_MCONT_UMASK	0x1000
> -#define CAN_IF_MCONT_TXIE	0x0800
> -#define CAN_IF_MCONT_RXIE	0x0400
> -#define CAN_IF_MCONT_RMTEN	0x0200
> -#define CAN_IF_MCONT_TXRQXT	0x0100
> -#define CAN_IF_MCONT_EOB	0x0080
> -#define CAN_IF_MCONT_DLC	0x000f
> -#define CAN_IF_MCONT_MSGLOST	0x4000
> -#define CAN_MASK2_MDIR_MXTD	0xc000
> -#define CAN_ID2_DIR		0x2000
> -#define CAN_ID_MSGVAL		0x8000
> -
> -#define CAN_STATUS_INT		0x8000
> -#define CAN_IF_CREQ_BUSY	0x8000
> -#define CAN_ID2_XTD		0x4000
> -
> -#define CAN_REC			0x00007f00
> -#define CAN_TEC			0x000000ff
> -
> -#define PCH_RX_OK		0x00000010
> -#define PCH_TX_OK		0x00000008
> -#define PCH_BUS_OFF		0x00000080
> -#define PCH_EWARN		0x00000040
> -#define PCH_EPASSIV		0x00000020
> -#define PCH_LEC0		0x00000001
> -#define PCH_LEC1		0x00000002
> -#define PCH_LEC2		0x00000004
> -#define PCH_LEC_ALL		(PCH_LEC0 | PCH_LEC1 | PCH_LEC2)
> -#define PCH_STUF_ERR		PCH_LEC0
> -#define PCH_FORM_ERR		PCH_LEC1
> -#define PCH_ACK_ERR		(PCH_LEC0 | PCH_LEC1)
> -#define PCH_BIT1_ERR		PCH_LEC2
> -#define PCH_BIT0_ERR		(PCH_LEC0 | PCH_LEC2)
> -#define PCH_CRC_ERR		(PCH_LEC1 | PCH_LEC2)
> +#define PCH_CTRL_INIT		BIT(0) /* The INIT bit of CANCONT register. */
> +#define PCH_CTRL_IE		BIT(1) /* The IE bit of CAN control register */
> +#define PCH_CTRL_IE_SIE_EIE	(BIT(3) | BIT(2) | BIT(1))
> +#define PCH_CTRL_CCE		BIT(6)
> +#define PCH_CTRL_OPT		BIT(7) /* The OPT bit of CANCONT register. */
> +#define PCH_OPT_SILENT		BIT(3) /* The Silent bit of CANOPT reg. */
> +#define PCH_OPT_LBACK		BIT(4) /* The LoopBack bit of CANOPT reg. */
> +
> +#define PCH_CMASK_RX_TX_SET	0x00f3
> +#define PCH_CMASK_RX_TX_GET	0x0073
> +#define PCH_CMASK_ALL		0xff
> +#define PCH_CMASK_NEWDAT	BIT(2)
> +#define PCH_CMASK_CLRINTPND	BIT(3)
> +#define PCH_CMASK_CTRL		BIT(4)
> +#define PCH_CMASK_ARB		BIT(5)
> +#define PCH_CMASK_MASK		BIT(6)
> +#define PCH_CMASK_RDWR		BIT(7)
> +#define PCH_IF_MCONT_NEWDAT	BIT(15)
> +#define PCH_IF_MCONT_MSGLOST	BIT(14)
> +#define PCH_IF_MCONT_INTPND	BIT(13)
> +#define PCH_IF_MCONT_UMASK	BIT(12)
> +#define PCH_IF_MCONT_TXIE	BIT(11)
> +#define PCH_IF_MCONT_RXIE	BIT(10)
> +#define PCH_IF_MCONT_RMTEN	BIT(9)
> +#define PCH_IF_MCONT_TXRQXT	BIT(8)
> +#define PCH_IF_MCONT_EOB	BIT(7)
> +#define PCH_IF_MCONT_DLC	(BIT(0) | BIT(1) | BIT(2) | BIT(3))
> +#define PCH_MASK2_MDIR_MXTD	(BIT(14) | BIT(15))
> +#define PCH_ID2_DIR		BIT(13)
> +#define PCH_ID2_XTD		BIT(14)
> +#define PCH_ID_MSGVAL		BIT(15)
> +#define PCH_IF_CREQ_BUSY	BIT(15)
> +
> +#define PCH_STATUS_INT		0x8000
> +#define PCH_REC			0x00007f00
> +#define PCH_TEC			0x000000ff
> +
> +#define PCH_TX_OK		BIT(3)
> +#define PCH_RX_OK		BIT(4)
> +#define PCH_EPASSIV		BIT(5)
> +#define PCH_EWARN		BIT(6)
> +#define PCH_BUS_OFF		BIT(7)
> =20
>  /* bit position of certain controller bits. */
> -#define BIT_BITT_BRP		0
> -#define BIT_BITT_SJW		6
> -#define BIT_BITT_TSEG1		8
> -#define BIT_BITT_TSEG2		12
> -#define BIT_IF1_MCONT_RXIE	10
> -#define BIT_IF2_MCONT_TXIE	11
> -#define BIT_BRPE_BRPE		6
> -#define BIT_ES_TXERRCNT		0
> -#define BIT_ES_RXERRCNT		8
> -#define MSK_BITT_BRP		0x3f
> -#define MSK_BITT_SJW		0xc0
> -#define MSK_BITT_TSEG1		0xf00
> -#define MSK_BITT_TSEG2		0x7000
> -#define MSK_BRPE_BRPE		0x3c0
> -#define MSK_BRPE_GET		0x0f
> -#define MSK_CTRL_IE_SIE_EIE	0x07
> -#define MSK_MCONT_TXIE		0x08
> -#define MSK_MCONT_RXIE		0x10
> -#define PCH_CAN_NO_TX_BUFF	1
> -#define COUNTER_LIMIT		10
> -
> -#define PCH_CAN_CLK		50000000	/* 50MHz */
> -
> -/* Define the number of message object.
> +#define PCH_BIT_BRP_SHIFT		0
> +#define PCH_BIT_SJW_SHIFT		6
> +#define PCH_BIT_TSEG1_SHIFT		8
> +#define PCH_BIT_TSEG2_SHIFT		12
> +#define PCH_BIT_IF1_MCONT_RXIE_SHIFT	10
> +#define PCH_BIT_IF2_MCONT_TXIE_SHIFT	11
> +#define PCH_BIT_BRPE_BRPE_SHIFT		6
> +
> +#define PCH_MSK_BITT_BRP		0x3f
> +#define PCH_MSK_BRPE_BRPE		0x3c0
> +#define PCH_MSK_CTRL_IE_SIE_EIE		0x07
> +#define PCH_COUNTER_LIMIT		10
> +
> +#define PCH_RX_IFREG			0
> +#define PCH_TX_IFREG			1
> +
> +#define PCH_CAN_CLK			50000000	/* 50MHz */
> +
> +/*
> + * Define the number of message object.
>   * PCH CAN communications are done via Message RAM.
> - * The Message RAM consists of 32 message objects. */
> -#define PCH_RX_OBJ_NUM		26  /* 1~ PCH_RX_OBJ_NUM is Rx*/
> -#define PCH_TX_OBJ_NUM		6  /* PCH_RX_OBJ_NUM is RX ~ Tx*/

I would keep these two and use them to define the PCH_xx_OBJ_END...

> -#define PCH_OBJ_NUM		(PCH_TX_OBJ_NUM + PCH_RX_OBJ_NUM)
> + * The Message RAM consists of 32 message objects.
> + */
> +#define PCH_RX_OBJ_START	1
> +#define PCH_RX_OBJ_END		26
> +#define PCH_TX_OBJ_START	27
                                ^^

Which is (PCH_RX_OBJ_END + 1)

> +#define PCH_TX_OBJ_END		32
> =20
>  #define PCH_FIFO_THRESH		16
> =20
> +enum pch_can_err {
> +	PCH_STUF_ERR =3D 1,
> +	PCH_FORM_ERR,
> +	PCH_ACK_ERR,
> +	PCH_BIT1_ERR,
> +	PCH_BIT0_ERR,
> +	PCH_CRC_ERR,
> +	PCH_LEC_ALL,
> +};
> +
>  enum pch_can_mode {
>  	PCH_CAN_ENABLE,
>  	PCH_CAN_DISABLE,
>  	PCH_CAN_ALL,
>  	PCH_CAN_NONE,
>  	PCH_CAN_STOP,
> -	PCH_CAN_RUN
> +	PCH_CAN_RUN,
> +};
> +
> +struct pch_can_if_regs {
> +	u32 creq;
> +	u32 cmask;
> +	u32 mask1;
> +	u32 mask2;
> +	u32 id1;
> +	u32 id2;
> +	u32 mcont;
> +	u32 data[4];
> +	u32 rsv[13];
>  };
> =20
>  struct pch_can_regs {
> @@ -142,61 +145,44 @@ struct pch_can_regs {
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
>  struct pch_can_priv {
>  	struct can_priv can;
> -	unsigned int can_num;
>  	struct pci_dev *dev;
> -	unsigned int tx_enable[MAX_MSG_OBJ];
> -	unsigned int rx_enable[MAX_MSG_OBJ];
> -	unsigned int rx_link[MAX_MSG_OBJ];
> +	unsigned int tx_enable[PCH_TX_OBJ_END];
> +	unsigned int rx_enable[PCH_TX_OBJ_END];
> +	unsigned int rx_link[PCH_TX_OBJ_END];
>  	unsigned int int_enables;
>  	unsigned int int_stat;
>  	struct net_device *ndev;
> -	spinlock_t msgif_reg_lock; /* Message Interface Registers Access Lock=
*/
> -	unsigned int msg_obj[MAX_MSG_OBJ];
> +	spinlock_t msgif_reg_lock; /* Message Interface Registers Access Lock=
 */
        ^^^^^^^^^^^^^^^^^^^^^^^^^^

is it still used?

> +	unsigned int msg_obj[PCH_TX_OBJ_END];
>  	struct pch_can_regs __iomem *regs;
>  	struct napi_struct napi;
>  	unsigned int tx_obj;	/* Point next Tx Obj index */
>  	unsigned int use_msi;
> +	unsigned int netif_stop;
>  };
> =20
>  static struct can_bittiming_const pch_can_bittiming_const =3D {
> -	.name =3D KBUILD_MODNAME,
> +	.name =3D "pch_can",

I do like the KBUILD_MODNAME more than the string.

>  	.tseg1_min =3D 1,
>  	.tseg1_max =3D 16,
>  	.tseg2_min =3D 1,
> @@ -228,15 +214,15 @@ static void pch_can_set_run_mode(struct pch_can_p=
riv *priv,
>  {
>  	switch (mode) {
>  	case PCH_CAN_RUN:
> -		pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_INIT);
> +		pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_INIT);
>  		break;
> =20
>  	case PCH_CAN_STOP:
> -		pch_can_bit_set(&priv->regs->cont, CAN_CTRL_INIT);
> +		pch_can_bit_set(&priv->regs->cont, PCH_CTRL_INIT);
>  		break;
> =20
>  	default:
> -		dev_err(&priv->ndev->dev, "%s -> Invalid Mode.\n", __func__);
> +		netdev_err(priv->ndev, "%s -> Invalid Mode.\n", __func__);
>  		break;
>  	}
>  }
> @@ -246,357 +232,184 @@ static void pch_can_set_optmode(struct pch_can_=
priv *priv)
>  	u32 reg_val =3D ioread32(&priv->regs->opt);
> =20
>  	if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY)
> -		reg_val |=3D CAN_OPT_SILENT;
> +		reg_val |=3D PCH_OPT_SILENT;
> =20
>  	if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK)
> -		reg_val |=3D CAN_OPT_LBACK;
> +		reg_val |=3D PCH_OPT_LBACK;
> =20
> -	pch_can_bit_set(&priv->regs->cont, CAN_CTRL_OPT);
> +	pch_can_bit_set(&priv->regs->cont, PCH_CTRL_OPT);
>  	iowrite32(reg_val, &priv->regs->opt);
>  }
> =20
> -static void pch_can_set_int_custom(struct pch_can_priv *priv)
> +static void pch_can_rw_msg_obj(void __iomem *creq_addr, u32 num)
>  {
> -	/* Clearing the IE, SIE and EIE bits of Can control register. */
> -	pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_IE_SIE_EIE);
> -
> -	/* Appropriately setting them. */
> -	pch_can_bit_set(&priv->regs->cont,
> -			((priv->int_enables & MSK_CTRL_IE_SIE_EIE) << 1));
> -}
> +	u32 counter =3D PCH_COUNTER_LIMIT;
        ^^^

It's a normal variable, just make it an "int".

> +	u32 ifx_creq;
> =20
> -/* This function retrieves interrupt enabled for the CAN device. */
> -static void pch_can_get_int_enables(struct pch_can_priv *priv, u32 *en=
ables)
> -{
> -	/* Obtaining the status of IE, SIE and EIE interrupt bits. */
> -	*enables =3D ((ioread32(&priv->regs->cont) & CAN_CTRL_IE_SIE_EIE) >> =
1);
> +	iowrite32(num, creq_addr);
> +	while (counter) {
> +		ifx_creq =3D ioread32(creq_addr) & PCH_IF_CREQ_BUSY;
> +		if (!ifx_creq)
> +			break;
> +		counter--;
> +		udelay(1);
> +	}
> +	if (!counter)
> +		pr_err("%s:IF1 BUSY Flag is set forever.\n", __func__);
>  }
> =20
>  static void pch_can_set_int_enables(struct pch_can_priv *priv,
>  				    enum pch_can_mode interrupt_no)
>  {
>  	switch (interrupt_no) {
> -	case PCH_CAN_ENABLE:
> -		pch_can_bit_set(&priv->regs->cont, CAN_CTRL_IE);
> -		break;
> -
>  	case PCH_CAN_DISABLE:
> -		pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_IE);
> +		pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_IE);
>  		break;
> =20
>  	case PCH_CAN_ALL:
> -		pch_can_bit_set(&priv->regs->cont, CAN_CTRL_IE_SIE_EIE);
> +		pch_can_bit_set(&priv->regs->cont, PCH_CTRL_IE_SIE_EIE);
>  		break;
> =20
>  	case PCH_CAN_NONE:
> -		pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_IE_SIE_EIE);
> +		pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_IE_SIE_EIE);
>  		break;
> =20
>  	default:
> -		dev_err(&priv->ndev->dev, "Invalid interrupt number.\n");
> +		netdev_err(priv->ndev, "Invalid interrupt number.\n");
>  		break;
>  	}
>  }
> =20
> -static void pch_can_check_if_busy(u32 __iomem *creq_addr, u32 num)
> -{
> -	u32 counter =3D COUNTER_LIMIT;
> -	u32 ifx_creq;
> -
> -	iowrite32(num, creq_addr);
> -	while (counter) {
> -		ifx_creq =3D ioread32(creq_addr) & CAN_IF_CREQ_BUSY;
> -		if (!ifx_creq)
> -			break;
> -		counter--;
> -		udelay(1);
> -	}
> -	if (!counter)
> -		pr_err("%s:IF1 BUSY Flag is set forever.\n", __func__);
> -}
> -
> -static void pch_can_set_rx_enable(struct pch_can_priv *priv, u32 buff_=
num,
> -				  u32 set)
> -{
> -	unsigned long flags;
> -
> -	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -	/* Reading the receive buffer data from RAM to Interface1 registers *=
/
> -	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> -	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
> -
> -	/* Setting the IF1MASK1 register to access MsgVal and RxIE bits */
> -	iowrite32(CAN_CMASK_RDWR | CAN_CMASK_ARB | CAN_CMASK_CTRL,
> -		  &priv->regs->if1_cmask);
> -
> -	if (set =3D=3D ENABLE) {
> -		/* Setting the MsgVal and RxIE bits */
> -		pch_can_bit_set(&priv->regs->if1_mcont, CAN_IF_MCONT_RXIE);
> -		pch_can_bit_set(&priv->regs->if1_id2, CAN_ID_MSGVAL);
> -
> -	} else if (set =3D=3D DISABLE) {
> -		/* Resetting the MsgVal and RxIE bits */
> -		pch_can_bit_clear(&priv->regs->if1_mcont, CAN_IF_MCONT_RXIE);
> -		pch_can_bit_clear(&priv->regs->if1_id2, CAN_ID_MSGVAL);
> -	}
> -
> -	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
> -	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> -}
> -
> -static void pch_can_rx_enable_all(struct pch_can_priv *priv)
> -{
> -	int i;
> -
> -	/* Traversing to obtain the object configured as receivers. */
> -	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_RX)
> -			pch_can_set_rx_enable(priv, i + 1, ENABLE);
> -	}
> -}
> -
> -static void pch_can_rx_disable_all(struct pch_can_priv *priv)
> +static void pch_can_set_rxtx(struct pch_can_priv *priv, u32 buff_num,
> +				    u32 set, u32 dir)
>  {
> -	int i;
> -
> -	/* Traversing to obtain the object configured as receivers. */
> -	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_RX)
> -			pch_can_set_rx_enable(priv, i + 1, DISABLE);
> -	}
> -}
> +	u32 ie;
> =20
> -static void pch_can_set_tx_enable(struct pch_can_priv *priv, u32 buff_=
num,
> -				 u32 set)
> -{
> -	unsigned long flags;
> +	if (dir)
> +		ie =3D PCH_IF_MCONT_TXIE;
> +	else
> +		ie =3D PCH_IF_MCONT_RXIE;
> =20
> -	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
>  	/* Reading the Msg buffer from Message RAM to Interface2 registers. *=
/
> -	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> -	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
> +	pch_can_rw_msg_obj(&priv->regs->ifregs[dir].creq, buff_num);
> =20
>  	/* Setting the IF2CMASK register for accessing the
>  		MsgVal and TxIE bits */
> -	iowrite32(CAN_CMASK_RDWR | CAN_CMASK_ARB | CAN_CMASK_CTRL,
> -		 &priv->regs->if2_cmask);
> +	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_ARB | PCH_CMASK_CTRL,
> +		 &priv->regs->ifregs[dir].cmask);
> =20
> -	if (set =3D=3D ENABLE) {
> +	if (set) {
>  		/* Setting the MsgVal and TxIE bits */
> -		pch_can_bit_set(&priv->regs->if2_mcont, CAN_IF_MCONT_TXIE);
> -		pch_can_bit_set(&priv->regs->if2_id2, CAN_ID_MSGVAL);
> -	} else if (set =3D=3D DISABLE) {
> +		pch_can_bit_set(&priv->regs->ifregs[dir].mcont, ie);
> +		pch_can_bit_set(&priv->regs->ifregs[dir].id2, PCH_ID_MSGVAL);
> +	} else {
>  		/* Resetting the MsgVal and TxIE bits. */
> -		pch_can_bit_clear(&priv->regs->if2_mcont, CAN_IF_MCONT_TXIE);
> -		pch_can_bit_clear(&priv->regs->if2_id2, CAN_ID_MSGVAL);
> +		pch_can_bit_clear(&priv->regs->ifregs[dir].mcont, ie);
> +		pch_can_bit_clear(&priv->regs->ifregs[dir].id2, PCH_ID_MSGVAL);
>  	}
> =20
> -	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
> -	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> +	pch_can_rw_msg_obj(&priv->regs->ifregs[dir].creq, buff_num);
>  }
> =20
> -static void pch_can_tx_enable_all(struct pch_can_priv *priv)
> +static void pch_can_set_rx_all(struct pch_can_priv *priv, u32 set)
>  {
>  	int i;
> =20
> -	/* Traversing to obtain the object configured as transmit object. */
> -	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_TX)
> -			pch_can_set_tx_enable(priv, i + 1, ENABLE);
> -	}
> +	/* Traversing to obtain the object configured as receivers. */
> +	for (i =3D PCH_RX_OBJ_START; i <=3D PCH_RX_OBJ_END; i++)
> +		pch_can_set_rxtx(priv, i, set, PCH_RX_IFREG);
>  }
> =20
> -static void pch_can_tx_disable_all(struct pch_can_priv *priv)
> +static void pch_can_set_tx_all(struct pch_can_priv *priv, u32 set)
>  {
>  	int i;
> =20
> -	/* Traversing to obtain the object configured as transmit object. */
> -	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_TX)
> -			pch_can_set_tx_enable(priv, i + 1, DISABLE);
> -	}
> -}
> -
> -static void pch_can_get_rx_enable(struct pch_can_priv *priv, u32 buff_=
num,
> -				 u32 *enable)
> -{
> -	unsigned long flags;
> -
> -	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> -	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
> -
> -	if (((ioread32(&priv->regs->if1_id2)) & CAN_ID_MSGVAL) &&
> -			((ioread32(&priv->regs->if1_mcont)) &
> -			CAN_IF_MCONT_RXIE))
> -		*enable =3D ENABLE;
> -	else
> -		*enable =3D DISABLE;
> -	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> -}
> -
> -static void pch_can_get_tx_enable(struct pch_can_priv *priv, u32 buff_=
num,
> -				 u32 *enable)
> -{
> -	unsigned long flags;
> -
> -	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> -	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
> -
> -	if (((ioread32(&priv->regs->if2_id2)) & CAN_ID_MSGVAL) &&
> -			((ioread32(&priv->regs->if2_mcont)) &
> -			CAN_IF_MCONT_TXIE)) {
> -		*enable =3D ENABLE;
> -	} else {
> -		*enable =3D DISABLE;
> -	}
> -	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> +	/* Traversing to obtain the object configured as receivers. */
> +	for (i =3D PCH_TX_OBJ_START; i <=3D PCH_TX_OBJ_END; i++)
> +		pch_can_set_rxtx(priv, i, set, PCH_TX_IFREG);
>  }
> =20
> -static int pch_can_int_pending(struct pch_can_priv *priv)
> +static u32 pch_can_int_pending(struct pch_can_priv *priv)
>  {
>  	return ioread32(&priv->regs->intr) & 0xffff;
>  }
> =20
> -static void pch_can_set_rx_buffer_link(struct pch_can_priv *priv,
> -				       u32 buffer_num, u32 set)
> -{
> -	unsigned long flags;
> -
> -	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> -	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
> -	iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL, &priv->regs->if1_cmask);
> -	if (set =3D=3D ENABLE)
> -		pch_can_bit_clear(&priv->regs->if1_mcont, CAN_IF_MCONT_EOB);
> -	else
> -		pch_can_bit_set(&priv->regs->if1_mcont, CAN_IF_MCONT_EOB);
> -
> -	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
> -	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> -}
> -
> -static void pch_can_get_rx_buffer_link(struct pch_can_priv *priv,
> -				       u32 buffer_num, u32 *link)
> +static void pch_can_clear_if_buffers(struct pch_can_priv *priv)
>  {
> -	unsigned long flags;
> -
> -	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> -	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
> -
> -	if (ioread32(&priv->regs->if1_mcont) & CAN_IF_MCONT_EOB)
> -		*link =3D DISABLE;
> -	else
> -		*link =3D ENABLE;
> -	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> -}
> -
> -static void pch_can_clear_buffers(struct pch_can_priv *priv)
> -{
> -	int i;
> -
> -	for (i =3D 0; i < PCH_RX_OBJ_NUM; i++) {
> -		iowrite32(CAN_CMASK_RX_TX_SET, &priv->regs->if1_cmask);
> -		iowrite32(0xffff, &priv->regs->if1_mask1);
> -		iowrite32(0xffff, &priv->regs->if1_mask2);
> -		iowrite32(0x0, &priv->regs->if1_id1);
> -		iowrite32(0x0, &priv->regs->if1_id2);
> -		iowrite32(0x0, &priv->regs->if1_mcont);
> -		iowrite32(0x0, &priv->regs->if1_dataa1);
> -		iowrite32(0x0, &priv->regs->if1_dataa2);
> -		iowrite32(0x0, &priv->regs->if1_datab1);
> -		iowrite32(0x0, &priv->regs->if1_datab2);
> -		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK |
> -			  CAN_CMASK_ARB | CAN_CMASK_CTRL,
> -			  &priv->regs->if1_cmask);
> -		pch_can_check_if_busy(&priv->regs->if1_creq, i+1);
> -	}
> -
> -	for (i =3D i;  i < PCH_OBJ_NUM; i++) {
> -		iowrite32(CAN_CMASK_RX_TX_SET, &priv->regs->if2_cmask);
> -		iowrite32(0xffff, &priv->regs->if2_mask1);
> -		iowrite32(0xffff, &priv->regs->if2_mask2);
> -		iowrite32(0x0, &priv->regs->if2_id1);
> -		iowrite32(0x0, &priv->regs->if2_id2);
> -		iowrite32(0x0, &priv->regs->if2_mcont);
> -		iowrite32(0x0, &priv->regs->if2_dataa1);
> -		iowrite32(0x0, &priv->regs->if2_dataa2);
> -		iowrite32(0x0, &priv->regs->if2_datab1);
> -		iowrite32(0x0, &priv->regs->if2_datab2);
> -		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK |
> -			  CAN_CMASK_ARB | CAN_CMASK_CTRL,
> -			  &priv->regs->if2_cmask);
> -		pch_can_check_if_busy(&priv->regs->if2_creq, i+1);
> +	int i; /* Msg Obj ID (1~32) */
> +
> +	for (i =3D PCH_RX_OBJ_START; i <=3D PCH_TX_OBJ_END; i++) {
> +		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->ifregs[0].cmask);
> +		iowrite32(0xffff, &priv->regs->ifregs[0].mask1);
> +		iowrite32(0xffff, &priv->regs->ifregs[0].mask2);
> +		iowrite32(0x0, &priv->regs->ifregs[0].id1);
> +		iowrite32(0x0, &priv->regs->ifregs[0].id2);
> +		iowrite32(0x0, &priv->regs->ifregs[0].mcont);
> +		iowrite32(0x0, &priv->regs->ifregs[0].data[0]);
> +		iowrite32(0x0, &priv->regs->ifregs[0].data[1]);
> +		iowrite32(0x0, &priv->regs->ifregs[0].data[2]);
> +		iowrite32(0x0, &priv->regs->ifregs[0].data[3]);
> +		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
> +			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
> +			  &priv->regs->ifregs[0].cmask);
> +		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, i);
>  	}
>  }
> =20
>  static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
>  {
>  	int i;
> -	unsigned long flags;
> -
> -	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> =20
> -	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_RX) {
> -			iowrite32(CAN_CMASK_RX_TX_GET,
> -				&priv->regs->if1_cmask);
> -			pch_can_check_if_busy(&priv->regs->if1_creq, i+1);
> +	for (i =3D PCH_RX_OBJ_START; i <=3D PCH_RX_OBJ_END; i++) {
> +		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
> +		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, i);
> =20
> -			iowrite32(0x0, &priv->regs->if1_id1);
> -			iowrite32(0x0, &priv->regs->if1_id2);
> +		iowrite32(0x0, &priv->regs->ifregs[0].id1);
> +		iowrite32(0x0, &priv->regs->ifregs[0].id2);
> =20
> -			pch_can_bit_set(&priv->regs->if1_mcont,
> -					CAN_IF_MCONT_UMASK);
> +		pch_can_bit_set(&priv->regs->ifregs[0].mcont,
> +				PCH_IF_MCONT_UMASK);
> =20
> -			/* Set FIFO mode set to 0 except last Rx Obj*/
> -			pch_can_bit_clear(&priv->regs->if1_mcont,
> -					  CAN_IF_MCONT_EOB);
> -			/* In case FIFO mode, Last EoB of Rx Obj must be 1 */
> -			if (i =3D=3D (PCH_RX_OBJ_NUM - 1))
> -				pch_can_bit_set(&priv->regs->if1_mcont,
> -						  CAN_IF_MCONT_EOB);
> +		if (i =3D=3D PCH_RX_OBJ_END)
> +			pch_can_bit_set(&priv->regs->ifregs[0].mcont,
> +					PCH_IF_MCONT_EOB);
> +		else
> +			pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
> +					  PCH_IF_MCONT_EOB);
> =20
> -			iowrite32(0, &priv->regs->if1_mask1);
> -			pch_can_bit_clear(&priv->regs->if1_mask2,
> -					  0x1fff | CAN_MASK2_MDIR_MXTD);
> +		iowrite32(0, &priv->regs->ifregs[0].mask1);
> +		pch_can_bit_clear(&priv->regs->ifregs[0].mask2,
> +				  0x1fff | PCH_MASK2_MDIR_MXTD);
> =20
> -			/* Setting CMASK for writing */
> -			iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK |
> -				  CAN_CMASK_ARB | CAN_CMASK_CTRL,
> -				  &priv->regs->if1_cmask);
> +		/* Setting CMASK for writing */
> +		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK | PCH_CMASK_ARB |
> +			  PCH_CMASK_CTRL, &priv->regs->ifregs[0].cmask);
> =20
> -			pch_can_check_if_busy(&priv->regs->if1_creq, i+1);
> -		} else if (priv->msg_obj[i] =3D=3D MSG_OBJ_TX) {
> -			iowrite32(CAN_CMASK_RX_TX_GET,
> -				&priv->regs->if2_cmask);
> -			pch_can_check_if_busy(&priv->regs->if2_creq, i+1);
> +		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, i);
> +	}
> =20
> -			/* Resetting DIR bit for reception */
> -			iowrite32(0x0, &priv->regs->if2_id1);
> -			iowrite32(0x0, &priv->regs->if2_id2);
> -			pch_can_bit_set(&priv->regs->if2_id2, CAN_ID2_DIR);
> +	for (i =3D PCH_TX_OBJ_START; i <=3D PCH_TX_OBJ_END; i++) {
> +		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[1].cmask);
> +		pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, i);
> =20
> -			/* Setting EOB bit for transmitter */
> -			iowrite32(CAN_IF_MCONT_EOB, &priv->regs->if2_mcont);
> +		/* Resetting DIR bit for reception */
> +		iowrite32(0x0, &priv->regs->ifregs[1].id1);
> +		iowrite32(PCH_ID2_DIR, &priv->regs->ifregs[1].id2);
> =20
> -			pch_can_bit_set(&priv->regs->if2_mcont,
> -					CAN_IF_MCONT_UMASK);
> +		/* Setting EOB bit for transmitter */
> +		iowrite32(PCH_IF_MCONT_EOB | PCH_IF_MCONT_UMASK,
> +			  &priv->regs->ifregs[1].mcont);
> =20
> -			iowrite32(0, &priv->regs->if2_mask1);
> -			pch_can_bit_clear(&priv->regs->if2_mask2, 0x1fff);
> +		iowrite32(0, &priv->regs->ifregs[1].mask1);
> +		pch_can_bit_clear(&priv->regs->ifregs[1].mask2, 0x1fff);
> =20
> -			/* Setting CMASK for writing */
> -			iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK |
> -				  CAN_CMASK_ARB | CAN_CMASK_CTRL,
> -				  &priv->regs->if2_cmask);
> +		/* Setting CMASK for writing */
> +		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK | PCH_CMASK_ARB |
> +			  PCH_CMASK_CTRL, &priv->regs->ifregs[1].cmask);
> =20
> -			pch_can_check_if_busy(&priv->regs->if2_creq, i+1);
> -		}
> +		pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, i);
>  	}
> -	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
>  }
> =20
>  static void pch_can_init(struct pch_can_priv *priv)
> @@ -605,7 +418,7 @@ static void pch_can_init(struct pch_can_priv *priv)=

>  	pch_can_set_run_mode(priv, PCH_CAN_STOP);
> =20
>  	/* Clearing all the message object buffers. */
> -	pch_can_clear_buffers(priv);
> +	pch_can_clear_if_buffers(priv);
> =20
>  	/* Configuring the respective message object as either rx/tx object. =
*/
>  	pch_can_config_rx_tx_buffers(priv);
> @@ -623,57 +436,53 @@ static void pch_can_release(struct pch_can_priv *=
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
>  static void pch_can_int_clr(struct pch_can_priv *priv, u32 mask)
>  {
> -	if (mask =3D=3D CAN_STATUS_INT) {
> -		ioread32(&priv->regs->stat);
> -		return;
> -	}
> -
>  	/* Clear interrupt for transmit object */
> -	if (priv->msg_obj[mask - 1] =3D=3D MSG_OBJ_TX) {
> -		/* Setting CMASK for clearing interrupts for
> -					 frame transmission. */
> -		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL | CAN_CMASK_ARB,
> -			  &priv->regs->if2_cmask);
> -
> -		/* Resetting the ID registers. */
> -		pch_can_bit_set(&priv->regs->if2_id2,
> -			       CAN_ID2_DIR | (0x7ff << 2));
> -		iowrite32(0x0, &priv->regs->if2_id1);
> -
> -		/* Claring NewDat, TxRqst & IntPnd */
> -		pch_can_bit_clear(&priv->regs->if2_mcont,
> -				  CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_INTPND |
> -				  CAN_IF_MCONT_TXRQXT);
> -		pch_can_check_if_busy(&priv->regs->if2_creq, mask);
> -	} else if (priv->msg_obj[mask - 1] =3D=3D MSG_OBJ_RX) {
> +	if ((mask >=3D PCH_RX_OBJ_START) && (mask <=3D PCH_RX_OBJ_END)) {
>  		/* Setting CMASK for clearing the reception interrupts. */
> -		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL | CAN_CMASK_ARB,
> -			  &priv->regs->if1_cmask);
> +		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL | PCH_CMASK_ARB,
> +			  &priv->regs->ifregs[0].cmask);
> =20
>  		/* Clearing the Dir bit. */
> -		pch_can_bit_clear(&priv->regs->if1_id2, CAN_ID2_DIR);
> +		pch_can_bit_clear(&priv->regs->ifregs[0].id2, PCH_ID2_DIR);
> =20
>  		/* Clearing NewDat & IntPnd */
> -		pch_can_bit_clear(&priv->regs->if1_mcont,
> -				  CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_INTPND);
> +		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
> +				  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND);
> +
> +		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, mask);
> +	} else if ((mask >=3D PCH_TX_OBJ_START) && (mask <=3D PCH_TX_OBJ_END)=
) {
> +		/*
> +		 * Setting CMASK for clearing interrupts for frame transmission.
> +		 */
> +		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL | PCH_CMASK_ARB,
> +			  &priv->regs->ifregs[1].cmask);
> +
> +		/* Resetting the ID registers. */
> +		pch_can_bit_set(&priv->regs->ifregs[1].id2,
> +			       PCH_ID2_DIR | (0x7ff << 2));
> +		iowrite32(0x0, &priv->regs->ifregs[1].id1);
> =20
> -		pch_can_check_if_busy(&priv->regs->if1_creq, mask);
> +		/* Claring NewDat, TxRqst & IntPnd */
> +		pch_can_bit_clear(&priv->regs->ifregs[1].mcont,
> +				  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND |
> +				  PCH_IF_MCONT_TXRQXT);
> +		pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, mask);
>  	}
>  }
> =20
> -static int pch_can_get_buffer_status(struct pch_can_priv *priv)
> +static u32 pch_can_get_buffer_status(struct pch_can_priv *priv)
>  {
>  	return (ioread32(&priv->regs->treq1) & 0xffff) |
> -	       ((ioread32(&priv->regs->treq2) & 0xffff) << 16);
> +	       (ioread32(&priv->regs->treq2) << 16);
>  }
> =20
>  static void pch_can_reset(struct pch_can_priv *priv)
> @@ -688,7 +497,7 @@ static void pch_can_error(struct net_device *ndev, =
u32 status)
>  	struct sk_buff *skb;
>  	struct pch_can_priv *priv =3D netdev_priv(ndev);
>  	struct can_frame *cf;
> -	u32 errc;
> +	u32 errc, lec;
>  	struct net_device_stats *stats =3D &(priv->ndev->stats);
>  	enum can_state state =3D priv->can.state;
> =20
> @@ -697,13 +506,11 @@ static void pch_can_error(struct net_device *ndev=
, u32 status)
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
> -		pch_can_set_run_mode(priv, PCH_CAN_RUN);
> -		dev_err(&ndev->dev, "%s -> Bus Off occurres.\n", __func__);
>  	}
> =20
>  	/* Warning interrupt. */
> @@ -712,11 +519,11 @@ static void pch_can_error(struct net_device *ndev=
, u32 status)
>  		priv->can.can_stats.error_warning++;
>  		cf->can_id |=3D CAN_ERR_CRTL;
>  		errc =3D ioread32(&priv->regs->errc);
> -		if (((errc & CAN_REC) >> 8) > 96)
> +		if (((errc & PCH_REC) >> 8) > 96)
>  			cf->data[1] |=3D CAN_ERR_CRTL_RX_WARNING;
> -		if ((errc & CAN_TEC) > 96)
> +		if ((errc & PCH_TEC) > 96)
>  			cf->data[1] |=3D CAN_ERR_CRTL_TX_WARNING;
> -		dev_warn(&ndev->dev,
> +		netdev_dbg(ndev,
>  			"%s -> Error Counter is more than 96.\n", __func__);
>  	}
>  	/* Error passive interrupt. */
> @@ -725,45 +532,52 @@ static void pch_can_error(struct net_device *ndev=
, u32 status)
>  		state =3D CAN_STATE_ERROR_PASSIVE;
>  		cf->can_id |=3D CAN_ERR_CRTL;
>  		errc =3D ioread32(&priv->regs->errc);
> -		if (((errc & CAN_REC) >> 8) > 127)
> +		if (((errc & PCH_REC) >> 8) > 127)
>  			cf->data[1] |=3D CAN_ERR_CRTL_RX_PASSIVE;
> -		if ((errc & CAN_TEC) > 127)
> +		if ((errc & PCH_TEC) > 127)
>  			cf->data[1] |=3D CAN_ERR_CRTL_TX_PASSIVE;
> -		dev_err(&ndev->dev,
> +		netdev_dbg(ndev,
>  			"%s -> CAN controller is ERROR PASSIVE .\n", __func__);
>  	}
> =20
> -	if (status & PCH_LEC_ALL) {
> +	lec =3D status & PCH_LEC_ALL;
> +	switch (lec) {
> +	case PCH_STUF_ERR:
> +		cf->data[2] |=3D CAN_ERR_PROT_STUFF;
>  		priv->can.can_stats.bus_error++;
>  		stats->rx_errors++;
> -		switch (status & PCH_LEC_ALL) {
> -		case PCH_STUF_ERR:
> -			cf->data[2] |=3D CAN_ERR_PROT_STUFF;
> -			break;
> -		case PCH_FORM_ERR:
> -			cf->data[2] |=3D CAN_ERR_PROT_FORM;
> -			break;
> -		case PCH_ACK_ERR:
> -			cf->data[2] |=3D CAN_ERR_PROT_LOC_ACK |
> -				       CAN_ERR_PROT_LOC_ACK_DEL;
> -			break;
> -		case PCH_BIT1_ERR:
> -		case PCH_BIT0_ERR:
> -			cf->data[2] |=3D CAN_ERR_PROT_BIT;
> -			break;
> -		case PCH_CRC_ERR:
> -			cf->data[2] |=3D CAN_ERR_PROT_LOC_CRC_SEQ |
> -				       CAN_ERR_PROT_LOC_CRC_DEL;
> -			break;
> -		default:
> -			iowrite32(status | PCH_LEC_ALL, &priv->regs->stat);
> -			break;
> -		}
> -
> +		break;
> +	case PCH_FORM_ERR:
> +		cf->data[2] |=3D CAN_ERR_PROT_FORM;
> +		priv->can.can_stats.bus_error++;
> +		stats->rx_errors++;
> +		break;
> +	case PCH_ACK_ERR:
> +		cf->can_id |=3D CAN_ERR_ACK;
> +		priv->can.can_stats.bus_error++;
> +		stats->rx_errors++;
> +		break;
> +	case PCH_BIT1_ERR:
> +	case PCH_BIT0_ERR:
> +		cf->data[2] |=3D CAN_ERR_PROT_BIT;
> +		priv->can.can_stats.bus_error++;
> +		stats->rx_errors++;
> +		break;
> +	case PCH_CRC_ERR:
> +		cf->data[2] |=3D CAN_ERR_PROT_LOC_CRC_SEQ |
> +			       CAN_ERR_PROT_LOC_CRC_DEL;
> +		priv->can.can_stats.bus_error++;
> +		stats->rx_errors++;
> +		break;
> +	case PCH_LEC_ALL: /* Written by CPU. No error status */
> +		break;
>  	}
> =20
> +	cf->data[6] =3D ioread32(&priv->regs->errc) & PCH_TEC;
> +	cf->data[7] =3D (ioread32(&priv->regs->errc) & PCH_REC) >> 8;
> +
>  	priv->can.state =3D state;
> -	netif_rx(skb);
> +	netif_receive_skb(skb);
> =20
>  	stats->rx_packets++;
>  	stats->rx_bytes +=3D cf->can_dlc;
> @@ -775,199 +589,214 @@ static irqreturn_t pch_can_interrupt(int irq, v=
oid *dev_id)
>  	struct pch_can_priv *priv =3D netdev_priv(ndev);
> =20
>  	pch_can_set_int_enables(priv, PCH_CAN_NONE);
> -
>  	napi_schedule(&priv->napi);
> =20
>  	return IRQ_HANDLED;
>  }
> =20
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
> +		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, obj_id);
> +	} else if (obj_id > PCH_FIFO_THRESH) {
> +		pch_can_int_clr(priv, obj_id);
> +	} else if (obj_id =3D=3D PCH_FIFO_THRESH) {
> +		int cnt;
> +		for (cnt =3D 0; cnt < PCH_FIFO_THRESH; cnt++)
> +			pch_can_int_clr(priv, cnt+1);
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
> +	pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, obj_id);
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
 quota)
>  {
>  	u32 reg;
>  	canid_t id;
>  	u32 ide;
>  	u32 rtr;
> -	int i, j, k;
>  	int rcv_pkts =3D 0;
> +	int rtn;
> +	int next_flag =3D 0;
>  	struct sk_buff *skb;
>  	struct can_frame *cf;
>  	struct pch_can_priv *priv =3D netdev_priv(ndev);
>  	struct net_device_stats *stats =3D &(priv->ndev->stats);
> +	u8 *can_data;
> +	int i;
> =20
> -	/* Reading the messsage object from the Message RAM */
> -	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> -	pch_can_check_if_busy(&priv->regs->if1_creq, int_stat);
> +	do {
> +		/* Reading the messsage object from the Message RAM */
> +		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
> +		pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, obj_num);
> =20
> -	/* Reading the MCONT register. */
> -	reg =3D ioread32(&priv->regs->if1_mcont);
> -	reg &=3D 0xffff;
> +		/* Reading the MCONT register. */
> +		reg =3D ioread32(&priv->regs->ifregs[0].mcont);
> +
> +		if (reg & PCH_IF_MCONT_EOB)
> +			break;
> =20
> -	for (k =3D int_stat; !(reg & CAN_IF_MCONT_EOB); k++) {
>  		/* If MsgLost bit set. */
> -		if (reg & CAN_IF_MCONT_MSGLOST) {
> -			dev_err(&priv->ndev->dev, "Msg Obj is overwritten.\n");
> -			pch_can_bit_clear(&priv->regs->if1_mcont,
> -					  CAN_IF_MCONT_MSGLOST);
> -			iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL,
> -				  &priv->regs->if1_cmask);
> -			pch_can_check_if_busy(&priv->regs->if1_creq, k);
> -
> -			skb =3D alloc_can_err_skb(ndev, &cf);
> +		if (reg & PCH_IF_MCONT_MSGLOST) {
> +			rtn =3D pch_can_rx_msg_lost(ndev, obj_num);
> +			if (!rtn)
> +				return rtn;
> +			rcv_pkts++;
> +			quota--;
> +			next_flag =3D 1;
> +		} else if (!(reg & PCH_IF_MCONT_NEWDAT))
> +			next_flag =3D 1;
> +
> +		if (!next_flag) {
> +			skb =3D alloc_can_skb(priv->ndev, &cf);
>  			if (!skb)
>  				return -ENOMEM;
> =20
> -			priv->can.can_stats.error_passive++;
> -			priv->can.state =3D CAN_STATE_ERROR_PASSIVE;
> -			cf->can_id |=3D CAN_ERR_CRTL;
> -			cf->data[1] |=3D CAN_ERR_CRTL_RX_OVERFLOW;
> -			cf->data[2] |=3D CAN_ERR_PROT_OVERLOAD;
> -			stats->rx_packets++;
> -			stats->rx_bytes +=3D cf->can_dlc;
> +			/* Get Received data */
> +			ide =3D ((ioread32(&priv->regs->ifregs[0].id2)) &
> +					 PCH_ID2_XTD);
> +			if (ide) {
> +				id =3D (ioread32(&priv->regs->ifregs[0].id1) &
> +					       0xffff);
> +				id |=3D (((ioread32(&priv->regs->ifregs[0].id2)) &
> +						  0x1fff) << 16);
> +				cf->can_id =3D id | CAN_EFF_FLAG;
> +			} else {
> +				id =3D (((ioread32(&priv->regs->ifregs[0].id2)) &
> +						(CAN_SFF_MASK << 2)) >> 2);
> +				cf->can_id =3D id;
> +			}
> +
> +			rtr =3D ioread32(&priv->regs->ifregs[0].id2) &
> +					PCH_ID2_DIR;

Try to minimize the ioread to "id2". I suggest to read id2 only _once_
and use it multiple times.

> +
> +			if (rtr)
> +				cf->can_id |=3D CAN_RTR_FLAG;
> +
> +			cf->can_dlc =3D get_can_dlc((ioread32(&priv->regs->
> +						   ifregs[0].mcont)) & 0xF);
> +
> +			can_data =3D (u8 *)&priv->regs->ifregs[0].data[0];
> +			for (i =3D 0; i < cf->can_dlc; i +=3D 2, can_data +=3D 4) {
> +				cf->data[i] =3D ioread8(can_data);
> +				cf->data[i+1] =3D ioread8(can_data + 1);
                                         ^^^

codingstyle: "i + 1", please use checkpatch.pl.

> +			}

Either use ioread8 or ioread16 in both the rx and tx path.

> =20
>  			netif_receive_skb(skb);
>  			rcv_pkts++;
> -			goto RX_NEXT;
> -		}
> -		if (!(reg & CAN_IF_MCONT_NEWDAT))
> -			goto RX_NEXT;
> -
> -		skb =3D alloc_can_skb(priv->ndev, &cf);
> -		if (!skb)
> -			return -ENOMEM;
> -
> -		/* Get Received data */
> -		ide =3D ((ioread32(&priv->regs->if1_id2)) & CAN_ID2_XTD) >> 14;
> -		if (ide) {
> -			id =3D (ioread32(&priv->regs->if1_id1) & 0xffff);
> -			id |=3D (((ioread32(&priv->regs->if1_id2)) &
> -					    0x1fff) << 16);
> -			cf->can_id =3D (id & CAN_EFF_MASK) | CAN_EFF_FLAG;
> -		} else {
> -			id =3D (((ioread32(&priv->regs->if1_id2)) &
> -					  (CAN_SFF_MASK << 2)) >> 2);
> -			cf->can_id =3D (id & CAN_SFF_MASK);
> -		}
> +			stats->rx_packets++;
> +			quota--;
> +			stats->rx_bytes +=3D cf->can_dlc;
> =20
> -		rtr =3D (ioread32(&priv->regs->if1_id2) &  CAN_ID2_DIR);
> -		if (rtr) {
> -			cf->can_dlc =3D 0;
> -			cf->can_id |=3D CAN_RTR_FLAG;
> -		} else {
> -			cf->can_dlc =3D ((ioread32(&priv->regs->if1_mcont)) &
> -						   0x0f);
> +			pch_fifo_thresh(priv, obj_num);
>  		}
> +		obj_num++;
> +		next_flag =3D 0;
> +	} while (quota > 0);
> =20
> -		for (i =3D 0, j =3D 0; i < cf->can_dlc; j++) {
> -			reg =3D ioread32(&priv->regs->if1_dataa1 + j*4);
> -			cf->data[i++] =3D cpu_to_le32(reg & 0xff);
> -			if (i =3D=3D cf->can_dlc)
> -				break;
> -			cf->data[i++] =3D cpu_to_le32((reg >> 8) & 0xff);
> -		}
> +	return rcv_pkts;
> +}
> =20
> -		netif_receive_skb(skb);
> -		rcv_pkts++;
> -		stats->rx_packets++;
> -		stats->rx_bytes +=3D cf->can_dlc;
> -
> -		if (k < PCH_FIFO_THRESH) {
> -			iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL |
> -				  CAN_CMASK_ARB, &priv->regs->if1_cmask);
> -
> -			/* Clearing the Dir bit. */
> -			pch_can_bit_clear(&priv->regs->if1_id2, CAN_ID2_DIR);
> -
> -			/* Clearing NewDat & IntPnd */
> -			pch_can_bit_clear(&priv->regs->if1_mcont,
> -					  CAN_IF_MCONT_INTPND);
> -			pch_can_check_if_busy(&priv->regs->if1_creq, k);
> -		} else if (k > PCH_FIFO_THRESH) {
> -			pch_can_int_clr(priv, k);
> -		} else if (k =3D=3D PCH_FIFO_THRESH) {
> -			int cnt;
> -			for (cnt =3D 0; cnt < PCH_FIFO_THRESH; cnt++)
> -				pch_can_int_clr(priv, cnt+1);
> -		}
> -RX_NEXT:
> -		/* Reading the messsage object from the Message RAM */
> -		iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> -		pch_can_check_if_busy(&priv->regs->if1_creq, k + 1);
> -		reg =3D ioread32(&priv->regs->if1_mcont);
> -	}
> +static void pch_can_tx_complete(struct net_device *ndev, u32 int_stat)=

> +{
> +	struct pch_can_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &(priv->ndev->stats);
> +	u32 dlc;
> =20
> -	return rcv_pkts;
> +	can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_END - 1);
> +	iowrite32(PCH_CMASK_RX_TX_GET | PCH_CMASK_CLRINTPND,
> +		  &priv->regs->ifregs[1].cmask);
> +	dlc =3D get_can_dlc(ioread32(&priv->regs->ifregs[1].mcont) &
> +			  PCH_IF_MCONT_DLC);
> +	pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, int_stat);
> +	stats->tx_bytes +=3D dlc;
> +	stats->tx_packets++;
> +	if ((int_stat =3D=3D PCH_TX_OBJ_END) && (priv->netif_stop =3D=3D 1)) =
{

No need for the netif_stop variable. netif_wake_queue does the check anyw=
ay.

> +		netif_wake_queue(ndev);
> +		priv->netif_stop =3D 0;
> +	}
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
> -	unsigned long flags;
> =20
>  	int_stat =3D pch_can_int_pending(priv);
>  	if (!int_stat)
> -		return 0;
> +		goto end;
> =20
> -INT_STAT:
> -	if (int_stat =3D=3D CAN_STATUS_INT) {
> +	if ((int_stat =3D=3D PCH_STATUS_INT) && (quota > 0)) {
>  		reg_stat =3D ioread32(&priv->regs->stat);
>  		if (reg_stat & (PCH_BUS_OFF | PCH_LEC_ALL)) {
> -			if ((reg_stat & PCH_LEC_ALL) !=3D PCH_LEC_ALL)
> +			if ((reg_stat & PCH_LEC_ALL) !=3D PCH_LEC_ALL) {
>  				pch_can_error(ndev, reg_stat);
> +				quota--;
> +			}
>  		}
> =20
> -		if (reg_stat & PCH_TX_OK) {
> -			spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -			iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> -			pch_can_check_if_busy(&priv->regs->if2_creq,
> -					       ioread32(&priv->regs->intr));
> -			spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> +		if (reg_stat & PCH_TX_OK)
>  			pch_can_bit_clear(&priv->regs->stat, PCH_TX_OK);
> -		}
> =20
>  		if (reg_stat & PCH_RX_OK)
>  			pch_can_bit_clear(&priv->regs->stat, PCH_RX_OK);
> =20
>  		int_stat =3D pch_can_int_pending(priv);
> -		if (int_stat =3D=3D CAN_STATUS_INT)
> -			goto INT_STAT;
>  	}
> =20
> -MSG_OBJ:
> -	if ((int_stat >=3D 1) && (int_stat <=3D PCH_RX_OBJ_NUM)) {
> -		spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -		rcv_pkts =3D pch_can_rx_normal(ndev, int_stat);
> -		spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> -		if (rcv_pkts < 0)
> -			return 0;
> -	} else if ((int_stat > PCH_RX_OBJ_NUM) && (int_stat <=3D PCH_OBJ_NUM)=
) {
> -		if (priv->msg_obj[int_stat - 1] =3D=3D MSG_OBJ_TX) {
> -			/* Handle transmission interrupt */
> -			can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_NUM - 1);
> -			spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -			iowrite32(CAN_CMASK_RX_TX_GET | CAN_CMASK_CLRINTPND,
> -				  &priv->regs->if2_cmask);
> -			dlc =3D ioread32(&priv->regs->if2_mcont) &
> -				       CAN_IF_MCONT_DLC;
> -			pch_can_check_if_busy(&priv->regs->if2_creq, int_stat);
> -			spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> -			if (dlc > 8)
> -				dlc =3D 8;
> -			stats->tx_bytes +=3D dlc;
> -			stats->tx_packets++;
> -		}
> +	if (quota =3D=3D 0)
> +		goto end;
> +
> +	if ((int_stat >=3D PCH_RX_OBJ_START) && (int_stat <=3D PCH_RX_OBJ_END=
)) {
> +		rcv_pkts +=3D pch_can_rx_normal(ndev, int_stat, quota);
> +		quota -=3D rcv_pkts;
> +		if (quota < 0)
> +			goto end;
> +	} else if ((int_stat >=3D PCH_TX_OBJ_START) &&
> +		   (int_stat <=3D PCH_TX_OBJ_END)) {
> +		/* Handle transmission interrupt */
> +		pch_can_tx_complete(ndev, int_stat);
>  	}
> =20
> -	int_stat =3D pch_can_int_pending(priv);
> -	if (int_stat =3D=3D CAN_STATUS_INT)
> -		goto INT_STAT;
> -	else if (int_stat >=3D 1 && int_stat <=3D 32)
> -		goto MSG_OBJ;
> -
> +end:
>  	napi_complete(napi);
>  	pch_can_set_int_enables(priv, PCH_CAN_ALL);
> =20
> @@ -980,20 +809,18 @@ static int pch_set_bittiming(struct net_device *n=
dev)
>  	const struct can_bittiming *bt =3D &priv->can.bittiming;
>  	u32 canbit;
>  	u32 bepe;
> -	u32 brp;
> =20
>  	/* Setting the CCE bit for accessing the Can Timing register. */
> -	pch_can_bit_set(&priv->regs->cont, CAN_CTRL_CCE);
> -
> -	brp =3D (bt->tq) / (1000000000/PCH_CAN_CLK) - 1;
> -	canbit =3D brp & MSK_BITT_BRP;
> -	canbit |=3D (bt->sjw - 1) << BIT_BITT_SJW;
> -	canbit |=3D (bt->phase_seg1 + bt->prop_seg - 1) << BIT_BITT_TSEG1;
> -	canbit |=3D (bt->phase_seg2 - 1) << BIT_BITT_TSEG2;
> -	bepe =3D (brp & MSK_BRPE_BRPE) >> BIT_BRPE_BRPE;
> +	pch_can_bit_set(&priv->regs->cont, PCH_CTRL_CCE);
> +
> +	canbit =3D (bt->brp - 1) & PCH_MSK_BITT_BRP;
> +	canbit |=3D (bt->sjw - 1) << PCH_BIT_SJW_SHIFT;
> +	canbit |=3D (bt->phase_seg1 + bt->prop_seg - 1) << PCH_BIT_TSEG1_SHIF=
T;
> +	canbit |=3D (bt->phase_seg2 - 1) << PCH_BIT_TSEG2_SHIFT;
> +	bepe =3D ((bt->brp - 1) & PCH_MSK_BRPE_BRPE) >> PCH_BIT_BRPE_BRPE_SHI=
FT;
>  	iowrite32(canbit, &priv->regs->bitt);
>  	iowrite32(bepe, &priv->regs->brpe);
> -	pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_CCE);
> +	pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_CCE);
> =20
>  	return 0;
>  }
> @@ -1008,8 +835,8 @@ static void pch_can_start(struct net_device *ndev)=

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
> @@ -1041,27 +868,18 @@ static int pch_can_open(struct net_device *ndev)=

>  	struct pch_can_priv *priv =3D netdev_priv(ndev);
>  	int retval;
> =20
> -	retval =3D pci_enable_msi(priv->dev);
> -	if (retval) {
> -		dev_info(&ndev->dev, "PCH CAN opened without MSI\n");
> -		priv->use_msi =3D 0;
> -	} else {
> -		dev_info(&ndev->dev, "PCH CAN opened with MSI\n");
> -		priv->use_msi =3D 1;
> -	}
> -
> -	/* Regsitering the interrupt. */
> +	/* Regstering the interrupt. */
>  	retval =3D request_irq(priv->dev->irq, pch_can_interrupt, IRQF_SHARED=
,
>  			     ndev->name, ndev);
>  	if (retval) {
> -		dev_err(&ndev->dev, "request_irq failed.\n");
> +		netdev_err(ndev, "request_irq failed.\n");
>  		goto req_irq_err;
>  	}
> =20
>  	/* Open common can device */
>  	retval =3D open_candev(ndev);
>  	if (retval) {
> -		dev_err(ndev->dev.parent, "open_candev() failed %d\n", retval);
> +		netdev_err(ndev, "open_candev() failed %d\n", retval);
>  		goto err_open_candev;
>  	}
> =20
> @@ -1075,9 +893,6 @@ static int pch_can_open(struct net_device *ndev)
>  err_open_candev:
>  	free_irq(priv->dev->irq, ndev);
>  req_irq_err:
> -	if (priv->use_msi)
> -		pci_disable_msi(priv->dev);
> -
>  	pch_can_release(priv);
> =20
>  	return retval;
> @@ -1091,102 +906,70 @@ static int pch_close(struct net_device *ndev)
>  	napi_disable(&priv->napi);
>  	pch_can_release(priv);
>  	free_irq(priv->dev->irq, ndev);
> -	if (priv->use_msi)
> -		pci_disable_msi(priv->dev);
>  	close_candev(ndev);
>  	priv->can.state =3D CAN_STATE_STOPPED;
>  	return 0;
>  }
> =20
> -static int pch_get_msg_obj_sts(struct net_device *ndev, u32 obj_id)
> -{
> -	u32 buffer_status =3D 0;
> -	struct pch_can_priv *priv =3D netdev_priv(ndev);
> -
> -	/* Getting the message object status. */
> -	buffer_status =3D (u32) pch_can_get_buffer_status(priv);
> -
> -	return buffer_status & obj_id;
> -}
> -
> -
>  static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *nd=
ev)
>  {
> -	int i, j;
> -	unsigned long flags;
>  	struct pch_can_priv *priv =3D netdev_priv(ndev);
>  	struct can_frame *cf =3D (struct can_frame *)skb->data;
> -	int tx_buffer_avail =3D 0;
> +	int tx_obj_no =3D 0;
> +	int i;
> =20
>  	if (can_dropped_invalid_skb(ndev, skb))
>  		return NETDEV_TX_OK;
> =20
> -	if (priv->tx_obj =3D=3D (PCH_OBJ_NUM + 1)) { /* Point tail Obj */
> -		while (pch_get_msg_obj_sts(ndev, (((1 << PCH_TX_OBJ_NUM)-1) <<
> -					   PCH_RX_OBJ_NUM)))
> -			udelay(500);
> -
> -		priv->tx_obj =3D PCH_RX_OBJ_NUM + 1; /* Point head of Tx Obj ID */
> -		tx_buffer_avail =3D priv->tx_obj; /* Point Tail of Tx Obj */
> +	if (priv->tx_obj =3D=3D PCH_TX_OBJ_END) {
> +		if (ioread32(&priv->regs->treq2) & 0xfc00) {

what does this if check?

> +			netif_stop_queue(ndev);
> +			priv->netif_stop =3D 1;
> +		}
> +		tx_obj_no =3D priv->tx_obj;
> +		priv->tx_obj =3D PCH_TX_OBJ_START;
>  	} else {
> -		tx_buffer_avail =3D priv->tx_obj;
> +		tx_obj_no =3D priv->tx_obj;
> +		priv->tx_obj++;
>  	}
> -	priv->tx_obj++;
> -
> -	/* Attaining the lock. */
> -	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> -
> -	/* Reading the Msg Obj from the Msg RAM to the Interface register. */=

> -	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> -	pch_can_check_if_busy(&priv->regs->if2_creq, tx_buffer_avail);
> =20
> -	/* Setting the CMASK register. */
> -	pch_can_bit_set(&priv->regs->if2_cmask, CAN_CMASK_ALL);
> +	/* Setting the CMASK register to set value */
> +	iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->ifregs[1].cmask);
> =20
>  	/* If ID extended is set. */
> -	pch_can_bit_clear(&priv->regs->if2_id1, 0xffff);
> -	pch_can_bit_clear(&priv->regs->if2_id2, 0x1fff | CAN_ID2_XTD);
>  	if (cf->can_id & CAN_EFF_FLAG) {
> -		pch_can_bit_set(&priv->regs->if2_id1, cf->can_id & 0xffff);
> -		pch_can_bit_set(&priv->regs->if2_id2,
> -				((cf->can_id >> 16) & 0x1fff) | CAN_ID2_XTD);
> +		iowrite32(cf->can_id & 0xffff, &priv->regs->ifregs[1].id1);
> +		iowrite32(((cf->can_id >> 16) & 0x1fff) | PCH_ID2_XTD,
> +			    &priv->regs->ifregs[1].id2);
>  	} else {
> -		pch_can_bit_set(&priv->regs->if2_id1, 0);
> -		pch_can_bit_set(&priv->regs->if2_id2,
> -				(cf->can_id & CAN_SFF_MASK) << 2);
> +		iowrite32(0, &priv->regs->ifregs[1].id1);
> +		iowrite32((cf->can_id & CAN_SFF_MASK) << 2,
> +			   &priv->regs->ifregs[1].id2);
>  	}
> =20
> +	pch_can_bit_set(&priv->regs->ifregs[1].id2, PCH_ID_MSGVAL);

Please don't read-modify-write the id2 register. Prepare the value for
id2, then write it to hardware!

> +
> +	/* If remote frame has to be transmitted.. */
> +	if (!(cf->can_id & CAN_RTR_FLAG))
> +		pch_can_bit_set(&priv->regs->ifregs[1].id2, PCH_ID2_DIR);

dito

> +
>  	/* If remote frame has to be transmitted.. */
>  	if (cf->can_id & CAN_RTR_FLAG)
> -		pch_can_bit_clear(&priv->regs->if2_id2, CAN_ID2_DIR);
> +		pch_can_bit_clear(&priv->regs->ifregs[1].id2, PCH_ID2_DIR);

dito

> =20
> -	for (i =3D 0, j =3D 0; i < cf->can_dlc; j++) {
> -		iowrite32(le32_to_cpu(cf->data[i++]),
> -			 (&priv->regs->if2_dataa1) + j*4);
> -		if (i =3D=3D cf->can_dlc)
> -			break;
> -		iowrite32(le32_to_cpu(cf->data[i++] << 8),
> -			 (&priv->regs->if2_dataa1) + j*4);
> +	/* Copy data to register */
> +	for (i =3D 0; i < cf->can_dlc; i +=3D 2) {
> +		iowrite16(cf->data[i] | (cf->data[i+1] << 8),
                                                  ^^^
> +			  &priv->regs->ifregs[1].data[i/2]);
                                                      ^^^
codingstyle
>  	}
> =20
> -	can_put_echo_skb(skb, ndev, tx_buffer_avail - PCH_RX_OBJ_NUM - 1);
> +	can_put_echo_skb(skb, ndev, tx_obj_no - PCH_RX_OBJ_END - 1);
> =20
> -	/* Updating the size of the data. */
> -	pch_can_bit_clear(&priv->regs->if2_mcont, 0x0f);
> -	pch_can_bit_set(&priv->regs->if2_mcont, cf->can_dlc);
> +	/* Set the size of the data. Update if2_mcont*/
> +	iowrite32(cf->can_dlc | PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_TXRQXT |
> +		  PCH_IF_MCONT_TXIE, &priv->regs->ifregs[1].mcont);
> =20
> -	/* Clearing IntPend, NewDat & TxRqst */
> -	pch_can_bit_clear(&priv->regs->if2_mcont,
> -			  CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_INTPND |
> -			  CAN_IF_MCONT_TXRQXT);
> -
> -	/* Setting NewDat, TxRqst bits */
> -	pch_can_bit_set(&priv->regs->if2_mcont,
> -			CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_TXRQXT);
> -
> -	pch_can_check_if_busy(&priv->regs->if2_creq, tx_buffer_avail);
> -
> -	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> +	pch_can_rw_msg_obj(&priv->regs->ifregs[1].creq, tx_obj_no);
> =20
>  	return NETDEV_TX_OK;
>  }
> @@ -1203,21 +986,90 @@ static void __devexit pch_can_remove(struct pci_=
dev *pdev)
>  	struct pch_can_priv *priv =3D netdev_priv(ndev);
> =20
>  	unregister_candev(priv->ndev);
> -	free_candev(priv->ndev);
>  	pci_iounmap(pdev, priv->regs);
> +	if (priv->use_msi)
> +		pci_disable_msi(priv->dev);
>  	pci_release_regions(pdev);
>  	pci_disable_device(pdev);
>  	pci_set_drvdata(pdev, NULL);
>  	pch_can_reset(priv);
> +	free_candev(priv->ndev);
>  }
> =20
>  #ifdef CONFIG_PM
> +static void pch_can_set_int_custom(struct pch_can_priv *priv)
> +{
> +	/* Clearing the IE, SIE and EIE bits of Can control register. */
> +	pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_IE_SIE_EIE);
> +
> +	/* Appropriately setting them. */
> +	pch_can_bit_set(&priv->regs->cont,
> +			((priv->int_enables & PCH_MSK_CTRL_IE_SIE_EIE) << 1));
> +}
> +
> +/* This function retrieves interrupt enabled for the CAN device. */
> +static u32 pch_can_get_int_enables(struct pch_can_priv *priv)
> +{
> +	/* Obtaining the status of IE, SIE and EIE interrupt bits. */
> +	return (ioread32(&priv->regs->cont) & PCH_CTRL_IE_SIE_EIE) >> 1;
> +}
> +
> +static u32 pch_can_get_rxtx_ir(struct pch_can_priv *priv, u32 buff_num=
, u32 dir)
> +{
> +	u32 ie, enable;
> +
> +	if (dir)
> +		ie =3D PCH_IF_MCONT_RXIE;
> +	else
> +		ie =3D PCH_IF_MCONT_TXIE;
> +
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[dir].cmask);
> +	pch_can_rw_msg_obj(&priv->regs->ifregs[dir].creq, buff_num);
> +
> +	if (((ioread32(&priv->regs->ifregs[dir].id2)) & PCH_ID_MSGVAL) &&
> +			((ioread32(&priv->regs->ifregs[dir].mcont)) & ie))
> +		enable =3D 1;
> +	else
> +		enable =3D 0;
> +	return enable;
> +}
> +
> +static void pch_can_set_rx_buffer_link(struct pch_can_priv *priv,
> +				       u32 buffer_num, u32 set)
> +{
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
> +	pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, buffer_num);
> +	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
> +		  &priv->regs->ifregs[0].cmask);
> +	if (set)
> +		pch_can_bit_clear(&priv->regs->ifregs[0].mcont,
> +				  PCH_IF_MCONT_EOB);
> +	else
> +		pch_can_bit_set(&priv->regs->ifregs[0].mcont, PCH_IF_MCONT_EOB);
> +
> +	pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, buffer_num);
> +}
> +
> +static u32 pch_can_get_rx_buffer_link(struct pch_can_priv *priv, u32 b=
uffer_num)
> +{
> +	u32 link;
> +
> +	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->ifregs[0].cmask);
> +	pch_can_rw_msg_obj(&priv->regs->ifregs[0].creq, buffer_num);
> +
> +	if (ioread32(&priv->regs->ifregs[0].mcont) & PCH_IF_MCONT_EOB)
> +		link =3D 0;
> +	else
> +		link =3D 1;
> +	return link;
> +}
> +
>  static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
>  {
> -	int i;			/* Counter variable. */
> -	int retval;		/* Return value. */
> +	int i;
> +	int retval;
>  	u32 buf_stat;	/* Variable for reading the transmit buffer status. */
> -	u32 counter =3D 0xFFFFFF;
> +	u32 counter =3D PCH_COUNTER_LIMIT;
> =20
>  	struct net_device *dev =3D pci_get_drvdata(pdev);
>  	struct pch_can_priv *priv =3D netdev_priv(dev);
> @@ -1226,7 +1078,7 @@ static int pch_can_suspend(struct pci_dev *pdev, =
pm_message_t state)
>  	pch_can_set_run_mode(priv, PCH_CAN_STOP);
> =20
>  	/* Indicate that we are aboutto/in suspend */
> -	priv->can.state =3D CAN_STATE_SLEEPING;
> +	priv->can.state =3D CAN_STATE_STOPPED;
> =20
>  	/* Waiting for all transmission to complete. */
>  	while (counter) {
> @@ -1240,31 +1092,24 @@ static int pch_can_suspend(struct pci_dev *pdev=
, pm_message_t state)
>  		dev_err(&pdev->dev, "%s -> Transmission time out.\n", __func__);
> =20
>  	/* Save interrupt configuration and then disable them */
> -	pch_can_get_int_enables(priv, &(priv->int_enables));
> +	priv->int_enables =3D pch_can_get_int_enables(priv);
>  	pch_can_set_int_enables(priv, PCH_CAN_DISABLE);
> =20
>  	/* Save Tx buffer enable state */
> -	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_TX)
> -			pch_can_get_tx_enable(priv, i + 1,
> -					      &(priv->tx_enable[i]));
> -	}
> +	for (i =3D PCH_TX_OBJ_START; i <=3D PCH_TX_OBJ_END; i++)
> +		priv->tx_enable[i] =3D pch_can_get_rxtx_ir(priv, i, PCH_TX_IFREG);
> =20
>  	/* Disable all Transmit buffers */
> -	pch_can_tx_disable_all(priv);
> +	pch_can_set_tx_all(priv, 0);
> =20
>  	/* Save Rx buffer enable state */
> -	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_RX) {
> -			pch_can_get_rx_enable(priv, i + 1,
> -						&(priv->rx_enable[i]));
> -			pch_can_get_rx_buffer_link(priv, i + 1,
> -						&(priv->rx_link[i]));
> -		}
> +	for (i =3D PCH_RX_OBJ_START; i <=3D PCH_RX_OBJ_END; i++) {
> +		priv->rx_enable[i] =3D pch_can_get_rxtx_ir(priv, i, PCH_RX_IFREG);
> +		priv->rx_link[i] =3D pch_can_get_rx_buffer_link(priv, i);
>  	}
> =20
>  	/* Disable all Receive buffers */
> -	pch_can_rx_disable_all(priv);
> +	pch_can_set_rx_all(priv, 0);
>  	retval =3D pci_save_state(pdev);
>  	if (retval) {
>  		dev_err(&pdev->dev, "pci_save_state failed.\n");
> @@ -1279,8 +1124,8 @@ static int pch_can_suspend(struct pci_dev *pdev, =
pm_message_t state)
> =20
>  static int pch_can_resume(struct pci_dev *pdev)
>  {
> -	int i;			/* Counter variable. */
> -	int retval;		/* Return variable. */
> +	int i;
> +	int retval;
>  	struct net_device *dev =3D pci_get_drvdata(pdev);
>  	struct pch_can_priv *priv =3D netdev_priv(dev);
> =20
> @@ -1312,23 +1157,16 @@ static int pch_can_resume(struct pci_dev *pdev)=

>  	pch_can_set_optmode(priv);
> =20
>  	/* Enabling the transmit buffer. */
> -	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_TX) {
> -			pch_can_set_tx_enable(priv, i + 1,
> -					      priv->tx_enable[i]);
> -		}
> -	}
> +	for (i =3D PCH_RX_OBJ_START; i <=3D PCH_RX_OBJ_END; i++)
> +		pch_can_set_rxtx(priv, i, priv->tx_enable[i], PCH_TX_IFREG);
> =20
>  	/* Configuring the receive buffer and enabling them. */
> -	for (i =3D 0; i < PCH_OBJ_NUM; i++) {
> -		if (priv->msg_obj[i] =3D=3D MSG_OBJ_RX) {
> -			/* Restore buffer link */
> -			pch_can_set_rx_buffer_link(priv, i + 1,
> -						   priv->rx_link[i]);
> -
> -			/* Restore buffer enables */
> -			pch_can_set_rx_enable(priv, i + 1, priv->rx_enable[i]);
> -		}
> +	for (i =3D PCH_TX_OBJ_START; i <=3D PCH_TX_OBJ_END; i++) {
> +		/* Restore buffer link */
> +		pch_can_set_rx_buffer_link(priv, i, priv->rx_link[i]);
> +
> +		/* Restore buffer enables */
> +		pch_can_set_rxtx(priv, i, priv->rx_enable[i], PCH_RX_IFREG);
>  	}
> =20
>  	/* Enable CAN Interrupts */
> @@ -1349,8 +1187,8 @@ static int pch_can_get_berr_counter(const struct =
net_device *dev,
>  {
>  	struct pch_can_priv *priv =3D netdev_priv(dev);
> =20
> -	bec->txerr =3D ioread32(&priv->regs->errc) & CAN_TEC;
> -	bec->rxerr =3D (ioread32(&priv->regs->errc) & CAN_REC) >> 8;
> +	bec->txerr =3D ioread32(&priv->regs->errc) & PCH_TEC;
> +	bec->rxerr =3D (ioread32(&priv->regs->errc) & PCH_REC) >> 8;
> =20
>  	return 0;
>  }
> @@ -1361,7 +1199,6 @@ static int __devinit pch_can_probe(struct pci_dev=
 *pdev,
>  	struct net_device *ndev;
>  	struct pch_can_priv *priv;
>  	int rc;
> -	int index;
>  	void __iomem *addr;
> =20
>  	rc =3D pci_enable_device(pdev);
> @@ -1383,7 +1220,8 @@ static int __devinit pch_can_probe(struct pci_dev=
 *pdev,
>  		goto probe_exit_ipmap;
>  	}
> =20
> -	ndev =3D alloc_candev(sizeof(struct pch_can_priv), PCH_TX_OBJ_NUM);
                                                         ^^^^^^^^^^^^^^

I like that define....

> +	ndev =3D alloc_candev(sizeof(struct pch_can_priv),
> +			    PCH_TX_OBJ_END - PCH_TX_OBJ_START + 1);

more readable than this     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

>  	if (!ndev) {
>  		rc =3D -ENOMEM;
>  		dev_err(&pdev->dev, "Failed alloc_candev\n");
> @@ -1399,7 +1237,7 @@ static int __devinit pch_can_probe(struct pci_dev=
 *pdev,
>  	priv->can.do_get_berr_counter =3D pch_can_get_berr_counter;
>  	priv->can.ctrlmode_supported =3D CAN_CTRLMODE_LISTENONLY |
>  				       CAN_CTRLMODE_LOOPBACK;
> -	priv->tx_obj =3D PCH_RX_OBJ_NUM + 1; /* Point head of Tx Obj */
> +	priv->tx_obj =3D PCH_TX_OBJ_START; /* Point head of Tx Obj */
> =20
>  	ndev->irq =3D pdev->irq;
>  	ndev->flags |=3D IFF_ECHO;
> @@ -1407,15 +1245,18 @@ static int __devinit pch_can_probe(struct pci_d=
ev *pdev,
>  	pci_set_drvdata(pdev, ndev);
>  	SET_NETDEV_DEV(ndev, &pdev->dev);
>  	ndev->netdev_ops =3D &pch_can_netdev_ops;
> -
>  	priv->can.clock.freq =3D PCH_CAN_CLK; /* Hz */
> -	for (index =3D 0; index < PCH_RX_OBJ_NUM;)
> -		priv->msg_obj[index++] =3D MSG_OBJ_RX;
> =20
> -	for (index =3D index;  index < PCH_OBJ_NUM;)
> -		priv->msg_obj[index++] =3D MSG_OBJ_TX;
> +	netif_napi_add(ndev, &priv->napi, pch_can_rx_poll, PCH_RX_OBJ_END);
> =20
> -	netif_napi_add(ndev, &priv->napi, pch_can_rx_poll, PCH_RX_OBJ_NUM);
> +	rc =3D pci_enable_msi(priv->dev);
> +	if (rc) {
> +		dev_info(&ndev->dev, "PCH CAN opened without MSI\n");
> +		priv->use_msi =3D 0;
> +	} else {
> +		dev_info(&ndev->dev, "PCH CAN opened with MSI\n");
> +		priv->use_msi =3D 1;
> +	}
> =20
>  	rc =3D register_candev(ndev);
>  	if (rc) {
> @@ -1426,7 +1267,8 @@ static int __devinit pch_can_probe(struct pci_dev=
 *pdev,
>  	return 0;
> =20
>  probe_exit_reg_candev:
> -	free_candev(ndev);
> +	if (priv->use_msi)
> +		pci_disable_msi(priv->dev);
>  probe_exit_alloc_candev:
>  	pci_iounmap(pdev, addr);
>  probe_exit_ipmap:
> @@ -1458,6 +1300,6 @@ static void __exit pch_can_pci_exit(void)
>  }
>  module_exit(pch_can_pci_exit);
> =20
> -MODULE_DESCRIPTION("Controller Area Network Driver");
> +MODULE_DESCRIPTION("Intel EG20T PCH CAN(Controller Area Network) Drive=
r");
>  MODULE_LICENSE("GPL v2");
>  MODULE_VERSION("0.94");

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig9C61BF3E9DD6C4869BDFDE8F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkzg/14ACgkQjTAFq1RaXHOdUQCcCcp497jvHJdeeS6nbuUIncTf
NlsAn2Y/aqMvL6FeospW0ICA88rGIkA4
=32Rm
-----END PGP SIGNATURE-----

--------------enig9C61BF3E9DD6C4869BDFDE8F--

--===============5415494044181143001==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============5415494044181143001==--
