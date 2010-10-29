From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix build
	warnings
Date: Fri, 29 Oct 2010 18:23:51 +0200
Message-ID: <4CCAF517.2000409@pengutronix.de>
References: <4CCAA3D4.8070408@dsn.okisemi.com>
	<4CCAC4CD.7000503@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8448738253567117877=="
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Tomoya <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4CCAC4CD.7000503-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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
--===============8448738253567117877==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig8A02DFB078E92D5FF97ED14E"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig8A02DFB078E92D5FF97ED14E
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello,

On 10/29/2010 02:57 PM, Marc Kleine-Budde wrote:
> The driver has already been merged. Please send incremental patches
> against david's net-2.6 branch.

Here a review, find comments inline. Lets talk about my remarks, please
answer inline and don't delete the code.

Can you please explain me your locking sheme? If I understand the
documenation correctly the two message interfaces can be used mutual.
And you use one for rx the other one for tx.

Please use netdev_<level> instead of dev_<level> for debug.

> --- /dev/null
> +++ b/drivers/net/can/pch_can.c
> @@ -0,0 +1,1436 @@
> +/*
> + * Copyright (C) 1999 - 2010 Intel Corporation.
> + * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
> + *
> + * This program is free software; you can redistribute it and/or modif=
y
> + * it under the terms of the GNU General Public License as published b=
y
> + * the Free Software Foundation; version 2 of the License.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-130=
7, USA.
> + */
> +
> +#include <linux/interrupt.h>
> +#include <linux/delay.h>
> +#include <linux/io.h>
> +#include <linux/module.h>
> +#include <linux/sched.h>
> +#include <linux/pci.h>
> +#include <linux/init.h>
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/errno.h>
> +#include <linux/netdevice.h>
> +#include <linux/skbuff.h>
> +#include <linux/can.h>
> +#include <linux/can/dev.h>
> +#include <linux/can/error.h>
> +
> +#define MAX_MSG_OBJ		32
> +#define MSG_OBJ_RX		0 /* The receive message object flag. */
> +#define MSG_OBJ_TX		1 /* The transmit message object flag. */
> +
> +#define CAN_CTRL_INIT		0x0001 /* The INIT bit of CANCONT register. */
> +#define CAN_CTRL_IE		0x0002 /* The IE bit of CAN control register */
> +#define CAN_CTRL_IE_SIE_EIE	0x000e
> +#define CAN_CTRL_CCE		0x0040
> +#define CAN_CTRL_OPT		0x0080 /* The OPT bit of CANCONT register. */
> +#define CAN_OPT_SILENT		0x0008 /* The Silent bit of CANOPT reg. */
> +#define CAN_OPT_LBACK		0x0010 /* The LoopBack bit of CANOPT reg. */
> +#define CAN_CMASK_RX_TX_SET	0x00f3
> +#define CAN_CMASK_RX_TX_GET	0x0073
> +#define CAN_CMASK_ALL		0xff
> +#define CAN_CMASK_RDWR		0x80
> +#define CAN_CMASK_ARB		0x20
> +#define CAN_CMASK_CTRL		0x10
> +#define CAN_CMASK_MASK		0x40
> +#define CAN_CMASK_NEWDAT	0x04
> +#define CAN_CMASK_CLRINTPND	0x08
> +
> +#define CAN_IF_MCONT_NEWDAT	0x8000
> +#define CAN_IF_MCONT_INTPND	0x2000
> +#define CAN_IF_MCONT_UMASK	0x1000
> +#define CAN_IF_MCONT_TXIE	0x0800
> +#define CAN_IF_MCONT_RXIE	0x0400
> +#define CAN_IF_MCONT_RMTEN	0x0200
> +#define CAN_IF_MCONT_TXRQXT	0x0100
> +#define CAN_IF_MCONT_EOB	0x0080
> +#define CAN_IF_MCONT_DLC	0x000f
> +#define CAN_IF_MCONT_MSGLOST	0x4000
> +#define CAN_MASK2_MDIR_MXTD	0xc000
> +#define CAN_ID2_DIR		0x2000
> +#define CAN_ID_MSGVAL		0x8000
> +
> +#define CAN_STATUS_INT		0x8000
> +#define CAN_IF_CREQ_BUSY	0x8000
> +#define CAN_ID2_XTD		0x4000
> +
> +#define CAN_REC			0x00007f00
> +#define CAN_TEC			0x000000ff

A prefix for like PCH_ instead of CAN_ for all those define above would
be fine to avoid namespace clashes and/or confusion with the defines from=
 the socketcan framework.

> +
> +#define PCH_RX_OK		0x00000010
> +#define PCH_TX_OK		0x00000008
> +#define PCH_BUS_OFF		0x00000080
> +#define PCH_EWARN		0x00000040
> +#define PCH_EPASSIV		0x00000020
> +#define PCH_LEC0		0x00000001
> +#define PCH_LEC1		0x00000002
> +#define PCH_LEC2		0x00000004

These are just single set bit, please use BIT()
Consider adding the name of the corresponding register to the define's
name.

> +#define PCH_LEC_ALL		(PCH_LEC0 | PCH_LEC1 | PCH_LEC2)
> +#define PCH_STUF_ERR		PCH_LEC0
> +#define PCH_FORM_ERR		PCH_LEC1
> +#define PCH_ACK_ERR		(PCH_LEC0 | PCH_LEC1)
> +#define PCH_BIT1_ERR		PCH_LEC2
> +#define PCH_BIT0_ERR		(PCH_LEC0 | PCH_LEC2)
> +#define PCH_CRC_ERR		(PCH_LEC1 | PCH_LEC2)
> +
> +/* bit position of certain controller bits. */
> +#define BIT_BITT_BRP		0
> +#define BIT_BITT_SJW		6
> +#define BIT_BITT_TSEG1		8
> +#define BIT_BITT_TSEG2		12
> +#define BIT_IF1_MCONT_RXIE	10
> +#define BIT_IF2_MCONT_TXIE	11
> +#define BIT_BRPE_BRPE		6
> +#define BIT_ES_TXERRCNT		0
> +#define BIT_ES_RXERRCNT		8

these are usually called SHIFT

> +#define MSK_BITT_BRP		0x3f
> +#define MSK_BITT_SJW		0xc0
> +#define MSK_BITT_TSEG1		0xf00
> +#define MSK_BITT_TSEG2		0x7000
> +#define MSK_BRPE_BRPE		0x3c0
> +#define MSK_BRPE_GET		0x0f
> +#define MSK_CTRL_IE_SIE_EIE	0x07
> +#define MSK_MCONT_TXIE		0x08
> +#define MSK_MCONT_RXIE		0x10

MSK or MASK is okay, however the last two are just single bits.

Please add a PCH_ prefix here, too.

> +#define PCH_CAN_NO_TX_BUFF	1
> +#define COUNTER_LIMIT		10

dito

> +
> +#define PCH_CAN_CLK		50000000	/* 50MHz */
> +
> +/*
> + * Define the number of message object.
> + * PCH CAN communications are done via Message RAM.
> + * The Message RAM consists of 32 message objects.
> + */
> +#define PCH_RX_OBJ_NUM		26  /* 1~ PCH_RX_OBJ_NUM is Rx*/
> +#define PCH_TX_OBJ_NUM		6  /* PCH_RX_OBJ_NUM is RX ~ Tx*/
> +#define PCH_OBJ_NUM		(PCH_TX_OBJ_NUM + PCH_RX_OBJ_NUM)

You define MAX_MSG_OBJ earlier, seems like two names for the same value.

> +
> +#define PCH_FIFO_THRESH		16
> +
> +enum pch_can_mode {
> +	PCH_CAN_ENABLE,
> +	PCH_CAN_DISABLE,
> +	PCH_CAN_ALL,
> +	PCH_CAN_NONE,
> +	PCH_CAN_STOP,
> +	PCH_CAN_RUN,
> +};
> +
> +struct pch_can_regs {
> +	u32 cont;
> +	u32 stat;
> +	u32 errc;
> +	u32 bitt;
> +	u32 intr;
> +	u32 opt;
> +	u32 brpe;
> +	u32 reserve1;

VVVV
> +	u32 if1_creq;
> +	u32 if1_cmask;
> +	u32 if1_mask1;
> +	u32 if1_mask2;
> +	u32 if1_id1;
> +	u32 if1_id2;
> +	u32 if1_mcont;
> +	u32 if1_dataa1;
> +	u32 if1_dataa2;
> +	u32 if1_datab1;
> +	u32 if1_datab2;
^^^^

these registers and....

> +	u32 reserve2;
> +	u32 reserve3[12];

=2E..and these

VVVV
> +	u32 if2_creq;
> +	u32 if2_cmask;
> +	u32 if2_mask1;
> +	u32 if2_mask2;
> +	u32 if2_id1;
> +	u32 if2_id2;
> +	u32 if2_mcont;
> +	u32 if2_dataa1;
> +	u32 if2_dataa2;
> +	u32 if2_datab1;
> +	u32 if2_datab2;

^^^^

=2E..are identical. I suggest to make a struct defining a complete
"Message Interface Register Set". If you include the correct number of
reserved bytes in the struct, you can have an array of two of these
structs in the struct pch_can_regs.

> +	u32 reserve4;
> +	u32 reserve5[20];
> +	u32 treq1;
> +	u32 treq2;
> +	u32 reserve6[2];
> +	u32 reserve7[56];
> +	u32 reserve8[3];
> +	u32 srst;
> +};
> +
> +struct pch_can_priv {
> +	struct can_priv can;
> +	struct pci_dev *dev;
> +	unsigned int tx_enable[MAX_MSG_OBJ];
> +	unsigned int rx_enable[MAX_MSG_OBJ];
> +	unsigned int rx_link[MAX_MSG_OBJ];
> +	unsigned int int_enables;
> +	unsigned int int_stat;
> +	struct net_device *ndev;
> +	spinlock_t msgif_reg_lock; /* Message Interface Registers Access Lock=
*/
                                                                         =
   ^^^
please add a whitespace

> +	unsigned int msg_obj[MAX_MSG_OBJ];
> +	struct pch_can_regs __iomem *regs;
> +	struct napi_struct napi;
> +	unsigned int tx_obj;	/* Point next Tx Obj index */
> +	unsigned int use_msi;
> +};
> +
> +static struct can_bittiming_const pch_can_bittiming_const =3D {
> +	.name =3D "pch_can",
> +	.tseg1_min =3D 1,
> +	.tseg1_max =3D 16,
> +	.tseg2_min =3D 1,
> +	.tseg2_max =3D 8,
> +	.sjw_max =3D 4,
> +	.brp_min =3D 1,
> +	.brp_max =3D 1024, /* 6bit + extended 4bit */
> +	.brp_inc =3D 1,
> +};
> +
> +static DEFINE_PCI_DEVICE_TABLE(pch_pci_tbl) =3D {
> +	{PCI_VENDOR_ID_INTEL, 0x8818, PCI_ANY_ID, PCI_ANY_ID,},
> +	{0,}
> +};
> +MODULE_DEVICE_TABLE(pci, pch_pci_tbl);
> +
> +static inline void pch_can_bit_set(u32 *addr, u32 mask)
                                      ^^^^^

that should be an void __iomem *, see mail I've send the other day.
Please use sparse to check for this kinds of errors.
(Compile the driver with C=3D2, i.e.: make drivers/net/can/pch_can.ko C=3D=
2)

> +{
> +	iowrite32(ioread32(addr) | mask, addr);
> +}
> +
> +static inline void pch_can_bit_clear(u32 *addr, u32 mask)
                                        ^^^^^

dito

> +{
> +	iowrite32(ioread32(addr) & ~mask, addr);
> +}
> +
> +static void pch_can_set_run_mode(struct pch_can_priv *priv,
> +				 enum pch_can_mode mode)
> +{
> +	switch (mode) {
> +	case PCH_CAN_RUN:
> +		pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_INIT);
> +		break;
> +
> +	case PCH_CAN_STOP:
> +		pch_can_bit_set(&priv->regs->cont, CAN_CTRL_INIT);
> +		break;
> +
> +	default:
> +		dev_err(&priv->ndev->dev, "%s -> Invalid Mode.\n", __func__);
> +		break;
> +	}
> +}
> +
> +static void pch_can_set_optmode(struct pch_can_priv *priv)
> +{
> +	u32 reg_val =3D ioread32(&priv->regs->opt);
> +
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY)
> +		reg_val |=3D CAN_OPT_SILENT;
> +
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK)
> +		reg_val |=3D CAN_OPT_LBACK;
> +
> +	pch_can_bit_set(&priv->regs->cont, CAN_CTRL_OPT);
> +	iowrite32(reg_val, &priv->regs->opt);
> +}
> +

IMHO the function name is missleading, if I understand the code
correctly, this functions triggers the transmission of the message.
After this it checks for busy, but=20

> +static void pch_can_check_if_busy(u32 __iomem *creq_addr, u32 num)
                                     ^^^^

that should probaby be a void

> +{
> +	u32 counter =3D COUNTER_LIMIT;
> +	u32 ifx_creq;
> +
> +	iowrite32(num, creq_addr);
> +	while (counter) {
> +		ifx_creq =3D ioread32(creq_addr) & CAN_IF_CREQ_BUSY;
> +		if (!ifx_creq)
> +			break;
> +		counter--;
> +		udelay(1);
> +	}
> +	if (!counter)
> +		pr_err("%s:IF1 BUSY Flag is set forever.\n", __func__);
> +}
> +
> +static void pch_can_set_int_enables(struct pch_can_priv *priv,
> +				    enum pch_can_mode interrupt_no)
> +{
> +	switch (interrupt_no) {
> +	case PCH_CAN_ENABLE:
> +		pch_can_bit_set(&priv->regs->cont, CAN_CTRL_IE);

noone uses this case.

> +		break;
> +
> +	case PCH_CAN_DISABLE:
> +		pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_IE);
> +		break;
> +
> +	case PCH_CAN_ALL:
> +		pch_can_bit_set(&priv->regs->cont, CAN_CTRL_IE_SIE_EIE);
> +		break;
> +
> +	case PCH_CAN_NONE:
> +		pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_IE_SIE_EIE);
> +		break;
> +
> +	default:
> +		dev_err(&priv->ndev->dev, "Invalid interrupt number.\n");
> +		break;
> +	}
> +}
> +
> +static void pch_can_set_rx_enable(struct pch_can_priv *priv, u32 buff_=
num,
> +				  int set)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> +	/* Reading the receive buffer data from RAM to Interface1 registers *=
/
> +	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> +	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
> +
> +	/* Setting the IF1MASK1 register to access MsgVal and RxIE bits */
> +	iowrite32(CAN_CMASK_RDWR | CAN_CMASK_ARB | CAN_CMASK_CTRL,
> +		  &priv->regs->if1_cmask);
> +
> +	if (set =3D=3D 1) {
> +		/* Setting the MsgVal and RxIE bits */
> +		pch_can_bit_set(&priv->regs->if1_mcont, CAN_IF_MCONT_RXIE);
> +		pch_can_bit_set(&priv->regs->if1_id2, CAN_ID_MSGVAL);
> +
> +	} else if (set =3D=3D 0) {
> +		/* Resetting the MsgVal and RxIE bits */
> +		pch_can_bit_clear(&priv->regs->if1_mcont, CAN_IF_MCONT_RXIE);
> +		pch_can_bit_clear(&priv->regs->if1_id2, CAN_ID_MSGVAL);
> +	}
> +
> +	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
> +	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> +}
> +
> +static void pch_can_rx_enable_all(struct pch_can_priv *priv)
> +{
> +	int i;
> +
> +	/* Traversing to obtain the object configured as receivers. */
> +	for (i =3D 1; i <=3D PCH_RX_OBJ_NUM; i++)
> +		pch_can_set_rx_enable(priv, i, 1);
> +}
> +
> +static void pch_can_rx_disable_all(struct pch_can_priv *priv)
> +{
> +	int i;
> +
> +	/* Traversing to obtain the object configured as receivers. */
> +	for (i =3D 1; i <=3D PCH_RX_OBJ_NUM; i++)
> +		pch_can_set_rx_enable(priv, i, 0);
> +}
> +
> +static void pch_can_set_tx_enable(struct pch_can_priv *priv, u32 buff_=
num,
> +				 u32 set)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> +	/* Reading the Msg buffer from Message RAM to Interface2 registers. *=
/
> +	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> +	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
> +
> +	/* Setting the IF2CMASK register for accessing the
> +		MsgVal and TxIE bits */
> +	iowrite32(CAN_CMASK_RDWR | CAN_CMASK_ARB | CAN_CMASK_CTRL,
> +		 &priv->regs->if2_cmask);
> +
> +	if (set =3D=3D 1) {
> +		/* Setting the MsgVal and TxIE bits */
> +		pch_can_bit_set(&priv->regs->if2_mcont, CAN_IF_MCONT_TXIE);
> +		pch_can_bit_set(&priv->regs->if2_id2, CAN_ID_MSGVAL);
> +	} else if (set =3D=3D 0) {
> +		/* Resetting the MsgVal and TxIE bits. */
> +		pch_can_bit_clear(&priv->regs->if2_mcont, CAN_IF_MCONT_TXIE);
> +		pch_can_bit_clear(&priv->regs->if2_id2, CAN_ID_MSGVAL);
> +	}
> +
> +	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
> +	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> +}
> +
> +static void pch_can_tx_enable_all(struct pch_can_priv *priv)
> +{
> +	int i;
> +
> +	/* Traversing to obtain the object configured as transmit object. */
> +	for (i =3D PCH_RX_OBJ_NUM + 1; i <=3D PCH_OBJ_NUM; i++)
> +		pch_can_set_tx_enable(priv, i, 1);
> +}
> +
> +static void pch_can_tx_disable_all(struct pch_can_priv *priv)
> +{
> +	int i;
> +
> +	/* Traversing to obtain the object configured as transmit object. */
> +	for (i =3D PCH_RX_OBJ_NUM + 1; i <=3D PCH_OBJ_NUM; i++)
> +		pch_can_set_tx_enable(priv, i, 0);
> +}
> +
> +static int pch_can_int_pending(struct pch_can_priv *priv)
          ^^^

make it u32 as it returns a register value, or a u16 as you only use
the 16 lower bits.

> +{
> +	return ioread32(&priv->regs->intr) & 0xffff;
> +}
> +
> +static void pch_can_clear_buffers(struct pch_can_priv *priv)
> +{
> +	int i; /* Msg Obj ID (1~32) */
> +
> +	for (i =3D 1; i <=3D PCH_RX_OBJ_NUM; i++) {

IMHO the readability would be improved if you define something like
PCH_RX_OBJ_START and PCH_RX_OBJ_END.

> +		iowrite32(CAN_CMASK_RX_TX_SET, &priv->regs->if1_cmask);
> +		iowrite32(0xffff, &priv->regs->if1_mask1);
> +		iowrite32(0xffff, &priv->regs->if1_mask2);
> +		iowrite32(0x0, &priv->regs->if1_id1);
> +		iowrite32(0x0, &priv->regs->if1_id2);
> +		iowrite32(0x0, &priv->regs->if1_mcont);
> +		iowrite32(0x0, &priv->regs->if1_dataa1);
> +		iowrite32(0x0, &priv->regs->if1_dataa2);
> +		iowrite32(0x0, &priv->regs->if1_datab1);
> +		iowrite32(0x0, &priv->regs->if1_datab2);
> +		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK |
> +			  CAN_CMASK_ARB | CAN_CMASK_CTRL,
> +			  &priv->regs->if1_cmask);
> +		pch_can_check_if_busy(&priv->regs->if1_creq, i);
> +	}
> +
> +	for (i =3D PCH_RX_OBJ_NUM + 1; i <=3D PCH_OBJ_NUM; i++) {
                 ^^^^^^^^^^^^^^^^^^
dito for TX objects

> +		iowrite32(CAN_CMASK_RX_TX_SET, &priv->regs->if2_cmask);
> +		iowrite32(0xffff, &priv->regs->if2_mask1);
> +		iowrite32(0xffff, &priv->regs->if2_mask2);
> +		iowrite32(0x0, &priv->regs->if2_id1);
> +		iowrite32(0x0, &priv->regs->if2_id2);
> +		iowrite32(0x0, &priv->regs->if2_mcont);
> +		iowrite32(0x0, &priv->regs->if2_dataa1);
> +		iowrite32(0x0, &priv->regs->if2_dataa2);
> +		iowrite32(0x0, &priv->regs->if2_datab1);
> +		iowrite32(0x0, &priv->regs->if2_datab2);
> +		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK | CAN_CMASK_ARB |
> +			  CAN_CMASK_CTRL, &priv->regs->if2_cmask);
> +		pch_can_check_if_busy(&priv->regs->if2_creq, i);
> +	}
> +}
> +
> +static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
> +{
> +	int i;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> +
> +	for (i =3D 1; i <=3D PCH_RX_OBJ_NUM; i++) {
> +		iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> +		pch_can_check_if_busy(&priv->regs->if1_creq, i);

If I understand the code correctly, the about function triggers a
transfer. Why do you first trigger a transfer, then set the message conte=
nts....
> +
> +		iowrite32(0x0, &priv->regs->if1_id1);
> +		iowrite32(0x0, &priv->regs->if1_id2);
> +
> +		pch_can_bit_set(&priv->regs->if1_mcont, CAN_IF_MCONT_UMASK);

    Why do you set the "Use acceptance mask" bit? We want to receive
    all can messages.

> +
> +		/* Set FIFO mode set to 0 except last Rx Obj*/
> +		pch_can_bit_clear(&priv->regs->if1_mcont, CAN_IF_MCONT_EOB);
> +		/* In case FIFO mode, Last EoB of Rx Obj must be 1 */
> +		if (i =3D=3D (PCH_RX_OBJ_NUM - 1))
> +			pch_can_bit_set(&priv->regs->if1_mcont,
> +					CAN_IF_MCONT_EOB);

    Make it if () { } else { }, please.

> +
> +		iowrite32(0, &priv->regs->if1_mask1);
> +		pch_can_bit_clear(&priv->regs->if1_mask2,
> +				  0x1fff | CAN_MASK2_MDIR_MXTD);
> +
> +		/* Setting CMASK for writing */
> +		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK | CAN_CMASK_ARB |
> +			  CAN_CMASK_CTRL, &priv->regs->if1_cmask);
> +
> +		pch_can_check_if_busy(&priv->regs->if1_creq, i);

=2E..and then trigger the transfer again?

> +	}
> +
> +	for (i =3D PCH_RX_OBJ_NUM + 1; i <=3D PCH_OBJ_NUM; i++) {
> +		iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> +		pch_can_check_if_busy(&priv->regs->if2_creq, i);

same question about triggering the transfer 2 times applied here, too
> +
> +		/* Resetting DIR bit for reception */
> +		iowrite32(0x0, &priv->regs->if2_id1);
> +		iowrite32(0x0, &priv->regs->if2_id2);
> +		pch_can_bit_set(&priv->regs->if2_id2, CAN_ID2_DIR);

Can you combine the two accesses to >if2_id2 into one?

> +
> +		/* Setting EOB bit for transmitter */
> +		iowrite32(CAN_IF_MCONT_EOB, &priv->regs->if2_mcont);
> +
> +		pch_can_bit_set(&priv->regs->if2_mcont,
> +				CAN_IF_MCONT_UMASK);

dito for if2_mcont

> +
> +		iowrite32(0, &priv->regs->if2_mask1);
> +		pch_can_bit_clear(&priv->regs->if2_mask2, 0x1fff);
> +
> +		/* Setting CMASK for writing */
> +		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK | CAN_CMASK_ARB |
> +			  CAN_CMASK_CTRL, &priv->regs->if2_cmask);
> +
> +		pch_can_check_if_busy(&priv->regs->if2_creq, i);
> +	}
> +
> +	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> +}
> +
> +static void pch_can_init(struct pch_can_priv *priv)
> +{
> +	/* Stopping the Can device. */
> +	pch_can_set_run_mode(priv, PCH_CAN_STOP);
> +
> +	/* Clearing all the message object buffers. */
> +	pch_can_clear_buffers(priv);
> +
> +	/* Configuring the respective message object as either rx/tx object. =
*/
> +	pch_can_config_rx_tx_buffers(priv);
> +
> +	/* Enabling the interrupts. */
> +	pch_can_set_int_enables(priv, PCH_CAN_ALL);
> +}
> +
> +static void pch_can_release(struct pch_can_priv *priv)
> +{
> +	/* Stooping the CAN device. */
> +	pch_can_set_run_mode(priv, PCH_CAN_STOP);
> +
> +	/* Disabling the interrupts. */
> +	pch_can_set_int_enables(priv, PCH_CAN_NONE);
> +
> +	/* Disabling all the receive object. */
> +	pch_can_rx_disable_all(priv);
> +
> +	/* Disabling all the transmit object. */
> +	pch_can_tx_disable_all(priv);
> +}
> +
> +/* This function clears interrupt(s) from the CAN device. */
> +static void pch_can_int_clr(struct pch_can_priv *priv, u32 mask)
> +{
> +	if (mask =3D=3D CAN_STATUS_INT) {

is this a valid case?

> +		ioread32(&priv->regs->stat);
> +		return;
> +	}
> +
> +	/* Clear interrupt for transmit object */
> +	if ((mask >=3D 1) && (mask <=3D PCH_RX_OBJ_NUM)) {
> +		/* Setting CMASK for clearing the reception interrupts. */
> +		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL | CAN_CMASK_ARB,
> +			  &priv->regs->if1_cmask);
> +
> +		/* Clearing the Dir bit. */
> +		pch_can_bit_clear(&priv->regs->if1_id2, CAN_ID2_DIR);
> +
> +		/* Clearing NewDat & IntPnd */
> +		pch_can_bit_clear(&priv->regs->if1_mcont,
> +				  CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_INTPND);
> +
> +		pch_can_check_if_busy(&priv->regs->if1_creq, mask);
> +	} else if ((mask > PCH_RX_OBJ_NUM) && (mask <=3D PCH_OBJ_NUM)) {
> +		/* Setting CMASK for clearing interrupts for
> +		   frame transmission. */

/*
 * this is the prefered style of multi line comments,
 * please adjust you comments
 */

> +		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL | CAN_CMASK_ARB,
> +			  &priv->regs->if2_cmask);
> +
> +		/* Resetting the ID registers. */
> +		pch_can_bit_set(&priv->regs->if2_id2,
> +			       CAN_ID2_DIR | (0x7ff << 2));
> +		iowrite32(0x0, &priv->regs->if2_id1);
> +
> +		/* Claring NewDat, TxRqst & IntPnd */
> +		pch_can_bit_clear(&priv->regs->if2_mcont,
> +				  CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_INTPND |
> +				  CAN_IF_MCONT_TXRQXT);
> +		pch_can_check_if_busy(&priv->regs->if2_creq, mask);
> +	}
> +}
> +
> +static u32 pch_can_get_buffer_status(struct pch_can_priv *priv)
> +{
> +	return (ioread32(&priv->regs->treq1) & 0xffff) |
> +	       ((ioread32(&priv->regs->treq2) & 0xffff) << 16);

the second 0xffff is not needed, as the return value is u32 and you shift=
 by 16.

> +}
> +
> +static void pch_can_reset(struct pch_can_priv *priv)
> +{
> +	/* write to sw reset register */
> +	iowrite32(1, &priv->regs->srst);
> +	iowrite32(0, &priv->regs->srst);
> +}
> +
> +static void pch_can_error(struct net_device *ndev, u32 status)
> +{
> +	struct sk_buff *skb;
> +	struct pch_can_priv *priv =3D netdev_priv(ndev);
> +	struct can_frame *cf;
> +	u32 errc;
> +	struct net_device_stats *stats =3D &(priv->ndev->stats);
> +	enum can_state state =3D priv->can.state;
> +
> +	skb =3D alloc_can_err_skb(ndev, &cf);
> +	if (!skb)
> +		return;
> +
> +	if (status & PCH_BUS_OFF) {
> +		pch_can_tx_disable_all(priv);
> +		pch_can_rx_disable_all(priv);
> +		state =3D CAN_STATE_BUS_OFF;
> +		cf->can_id |=3D CAN_ERR_BUSOFF;
> +		can_bus_off(ndev);
> +	}
> +
> +	/* Warning interrupt. */
> +	if (status & PCH_EWARN) {
> +		state =3D CAN_STATE_ERROR_WARNING;
> +		priv->can.can_stats.error_warning++;
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		errc =3D ioread32(&priv->regs->errc);
> +		if (((errc & CAN_REC) >> 8) > 96)
> +			cf->data[1] |=3D CAN_ERR_CRTL_RX_WARNING;
> +		if ((errc & CAN_TEC) > 96)
> +			cf->data[1] |=3D CAN_ERR_CRTL_TX_WARNING;
> +		dev_warn(&ndev->dev,
> +			"%s -> Error Counter is more than 96.\n", __func__);

Please use just "debug" level not warning here. Consider to use
netdev_dbg() instead. IMHO the __func__ can be dropped and the
"official" name for the error is "Error Warning".

> +	}
> +	/* Error passive interrupt. */
> +	if (status & PCH_EPASSIV) {
> +		priv->can.can_stats.error_passive++;
> +		state =3D CAN_STATE_ERROR_PASSIVE;
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		errc =3D ioread32(&priv->regs->errc);
> +		if (((errc & CAN_REC) >> 8) > 127)
> +			cf->data[1] |=3D CAN_ERR_CRTL_RX_PASSIVE;
> +		if ((errc & CAN_TEC) > 127)
> +			cf->data[1] |=3D CAN_ERR_CRTL_TX_PASSIVE;
> +		dev_err(&ndev->dev,
> +			"%s -> CAN controller is ERROR PASSIVE .\n", __func__);

dito

> +	}
> +
> +	if (status & PCH_LEC_ALL) {
> +		priv->can.can_stats.bus_error++;
> +		stats->rx_errors++;
> +		switch (status & PCH_LEC_ALL) {

I suggest to convert to a if-bit-set because there might be more than
one bit set.

> +		case PCH_STUF_ERR:
> +			cf->data[2] |=3D CAN_ERR_PROT_STUFF;
> +			break;
> +		case PCH_FORM_ERR:
> +			cf->data[2] |=3D CAN_ERR_PROT_FORM;
> +			break;
> +		case PCH_ACK_ERR:
> +			cf->data[2] |=3D CAN_ERR_PROT_LOC_ACK |
> +				       CAN_ERR_PROT_LOC_ACK_DEL;
> +			break;
> +		case PCH_BIT1_ERR:
> +		case PCH_BIT0_ERR:
> +			cf->data[2] |=3D CAN_ERR_PROT_BIT;
> +			break;
> +		case PCH_CRC_ERR:
> +			cf->data[2] |=3D CAN_ERR_PROT_LOC_CRC_SEQ |
> +				       CAN_ERR_PROT_LOC_CRC_DEL;
> +			break;
> +		default:
> +			iowrite32(status | PCH_LEC_ALL, &priv->regs->stat);
> +			break;
> +		}
> +
> +	}
> +
> +	priv->can.state =3D state;
> +	netif_receive_skb(skb);
> +
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->can_dlc;
> +}
> +
> +static irqreturn_t pch_can_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *ndev =3D (struct net_device *)dev_id;
> +	struct pch_can_priv *priv =3D netdev_priv(ndev);
> +
> +	pch_can_set_int_enables(priv, PCH_CAN_NONE);
> +	napi_schedule(&priv->napi);
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static void pch_fifo_thresh(struct pch_can_priv *priv, int obj_id)
> +{
> +	if (obj_id < PCH_FIFO_THRESH) {
> +		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL |
> +			  CAN_CMASK_ARB, &priv->regs->if1_cmask);
> +
> +		/* Clearing the Dir bit. */
> +		pch_can_bit_clear(&priv->regs->if1_id2, CAN_ID2_DIR);
> +
> +		/* Clearing NewDat & IntPnd */
> +		pch_can_bit_clear(&priv->regs->if1_mcont,
> +				  CAN_IF_MCONT_INTPND);
> +		pch_can_check_if_busy(&priv->regs->if1_creq, obj_id);
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
> +	dev_err(&priv->ndev->dev, "Msg Obj is overwritten.\n");
> +	pch_can_bit_clear(&priv->regs->if1_mcont,
> +			  CAN_IF_MCONT_MSGLOST);
> +	iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL,
> +		  &priv->regs->if1_cmask);
> +	pch_can_check_if_busy(&priv->regs->if1_creq, obj_id);
> +
> +	skb =3D alloc_can_err_skb(ndev, &cf);
> +	if (!skb)
> +		return -ENOMEM;
> +
> +	priv->can.can_stats.error_passive++;
> +	priv->can.state =3D CAN_STATE_ERROR_PASSIVE;
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
> +{
> +	u32 reg;
> +	canid_t id;
> +	u32 ide;
> +	u32 rtr;
> +	int rcv_pkts =3D 0;
> +	int rtn;
> +	int next_flag =3D 0;
> +	struct sk_buff *skb;
> +	struct can_frame *cf;
> +	struct pch_can_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &(priv->ndev->stats);
> +
> +	/* Reading the messsage object from the Message RAM */
> +	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> +	pch_can_check_if_busy(&priv->regs->if1_creq, obj_num);
> +
> +	/* Reading the MCONT register. */
> +	reg =3D ioread32(&priv->regs->if1_mcont);
> +	reg &=3D 0xffff;
> +
> +	for (; (!(reg & CAN_IF_MCONT_EOB)) && (quota > 0);
> +						obj_num++, next_flag =3D 0) {
> +		/* If MsgLost bit set. */
> +		if (reg & CAN_IF_MCONT_MSGLOST) {
> +			rtn =3D pch_can_rx_msg_lost(ndev, obj_num);
> +			if (!rtn)
> +				return rtn;
> +			rcv_pkts++;
> +			quota--;
> +			next_flag =3D 1;
> +		} else if (!(reg & CAN_IF_MCONT_NEWDAT))
> +			next_flag =3D 1;
> +

after rearanging the code (see below..) you should be able to use a conti=
nue here.

> +		if (!next_flag) {
> +			skb =3D alloc_can_skb(priv->ndev, &cf);
> +			if (!skb)
> +				return -ENOMEM;
> +
> +			/* Get Received data */
> +			ide =3D ((ioread32(&priv->regs->if1_id2)) & CAN_ID2_XTD);
> +			if (ide) {
> +				id =3D (ioread32(&priv->regs->if1_id1) & 0xffff);
> +				id |=3D (((ioread32(&priv->regs->if1_id2)) &
> +						    0x1fff) << 16);
> +				cf->can_id =3D (id & CAN_EFF_MASK) | CAN_EFF_FLAG;
                                              ^^^^^^^^^^^^^^^^^

is the mask needed, you mask the if1_id{1,2} already

> +			} else {
> +				id =3D (((ioread32(&priv->regs->if1_id2)) &
> +						  (CAN_SFF_MASK << 2)) >> 2);
> +				cf->can_id =3D (id & CAN_SFF_MASK);

one mask can go away

> +			}
> +
> +			rtr =3D ioread32(&priv->regs->if1_id2) &  CAN_ID2_DIR;
                                                              ^^

remove one space

> +
> +			if (rtr)
> +				cf->can_id |=3D CAN_RTR_FLAG;
> +
> +			cf->can_dlc =3D get_can_dlc((ioread32(&priv->regs->
> +						   if1_mcont)) & 0xF);
> +			*(u16 *)(cf->data + 0) =3D ioread16(&priv->regs->
> +							  if1_dataa1);
> +			*(u16 *)(cf->data + 2) =3D ioread16(&priv->regs->
> +							  if1_dataa2);
> +			*(u16 *)(cf->data + 4) =3D ioread16(&priv->regs->
> +							  if1_datab1);
> +			*(u16 *)(cf->data + 6) =3D ioread16(&priv->regs->
> +							  if1_datab2);

are you sure, the bytes in the can package a in the correct order.
Please test your pch_can against a non pch_can system.

> +
> +			netif_receive_skb(skb);
> +			rcv_pkts++;
> +			stats->rx_packets++;
> +			quota--;
> +			stats->rx_bytes +=3D cf->can_dlc;
> +
> +			pch_fifo_thresh(priv, obj_num);
> +		}
> +
> +		/* Reading the messsage object from the Message RAM */
> +		iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> +		pch_can_check_if_busy(&priv->regs->if1_creq, obj_num + 1);
> +		reg =3D ioread32(&priv->regs->if1_mcont);

this is almost the same code as before the the loop, can you rearange
the code to avoid duplication?
=20
> +	}
> +
> +	return rcv_pkts;
> +}
> +
> +static void pch_can_tx_complete(struct net_device *ndev, u32 int_stat)=

> +{
> +	struct pch_can_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &(priv->ndev->stats);
> +	unsigned long flags;
> +	u32 dlc;
> +
> +	can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_NUM - 1);
> +	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> +	iowrite32(CAN_CMASK_RX_TX_GET | CAN_CMASK_CLRINTPND,
> +		  &priv->regs->if2_cmask);
> +	dlc =3D ioread32(&priv->regs->if2_mcont) & CAN_IF_MCONT_DLC;
> +	pch_can_check_if_busy(&priv->regs->if2_creq, int_stat);
> +	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> +	if (dlc > 8)
> +		dlc =3D 8;

use get_can_dlc

> +	stats->tx_bytes +=3D dlc;
> +	stats->tx_packets++;
> +}
> +
> +static int pch_can_rx_poll(struct napi_struct *napi, int quota)
> +{
> +	struct net_device *ndev =3D napi->dev;
> +	struct pch_can_priv *priv =3D netdev_priv(ndev);
> +	u32 int_stat;
> +	int rcv_pkts =3D 0;
> +	u32 reg_stat;
> +	unsigned long flags;
> +
> +	int_stat =3D pch_can_int_pending(priv);
> +	if (!int_stat)
> +		goto END;
> +
> +	if ((int_stat =3D=3D CAN_STATUS_INT) && (quota > 0)) {
> +		reg_stat =3D ioread32(&priv->regs->stat);
> +		if (reg_stat & (PCH_BUS_OFF | PCH_LEC_ALL)) {
> +			if ((reg_stat & PCH_LEC_ALL) !=3D PCH_LEC_ALL) {
> +				pch_can_error(ndev, reg_stat);
> +				quota--;
> +			}
> +		}
> +
> +		if (reg_stat & PCH_TX_OK) {
> +			spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> +			iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> +			pch_can_check_if_busy(&priv->regs->if2_creq,
> +					       ioread32(&priv->regs->intr));
                                               ^^^^^^^^^^^^^^^^^^^^^^^^^^=
^

Isn't this "int_stat". Might it be possilbe that regs->intr changes
between the pch_can_int_pending and here?

What should this transfer do?

> +			spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> +			pch_can_bit_clear(&priv->regs->stat, PCH_TX_OK);
> +		}
> +
> +		if (reg_stat & PCH_RX_OK)
> +			pch_can_bit_clear(&priv->regs->stat, PCH_RX_OK);
> +
> +		int_stat =3D pch_can_int_pending(priv);
> +	}
> +
> +	if (quota =3D=3D 0)
> +		goto END;
> +
> +	if ((int_stat >=3D 1) && (int_stat <=3D PCH_RX_OBJ_NUM)) {
> +		spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> +		rcv_pkts +=3D pch_can_rx_normal(ndev, int_stat, quota);
> +		spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> +		quota -=3D rcv_pkts;
> +		if (rcv_pkts < 0)

how can this happen?

> +			goto END;
> +	} else if ((int_stat > PCH_RX_OBJ_NUM) && (int_stat <=3D PCH_OBJ_NUM)=
) {
> +		/* Handle transmission interrupt */
> +		pch_can_tx_complete(ndev, int_stat);
> +	}
> +
> +END:
> +	napi_complete(napi);
> +	pch_can_set_int_enables(priv, PCH_CAN_ALL);
> +
> +	return rcv_pkts;
> +}
> +
> +static int pch_set_bittiming(struct net_device *ndev)
> +{
> +	struct pch_can_priv *priv =3D netdev_priv(ndev);
> +	const struct can_bittiming *bt =3D &priv->can.bittiming;
> +	u32 canbit;
> +	u32 bepe;
> +
> +	/* Setting the CCE bit for accessing the Can Timing register. */
> +	pch_can_bit_set(&priv->regs->cont, CAN_CTRL_CCE);
> +
> +	canbit =3D (bt->brp - 1) & MSK_BITT_BRP;
> +	canbit |=3D (bt->sjw - 1) << BIT_BITT_SJW;
> +	canbit |=3D (bt->phase_seg1 + bt->prop_seg - 1) << BIT_BITT_TSEG1;
> +	canbit |=3D (bt->phase_seg2 - 1) << BIT_BITT_TSEG2;
> +	bepe =3D ((bt->brp - 1) & MSK_BRPE_BRPE) >> BIT_BRPE_BRPE;
> +	iowrite32(canbit, &priv->regs->bitt);
> +	iowrite32(bepe, &priv->regs->brpe);
> +	pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_CCE);
> +
> +	return 0;
> +}
> +
> +static void pch_can_start(struct net_device *ndev)
> +{
> +	struct pch_can_priv *priv =3D netdev_priv(ndev);
> +
> +	if (priv->can.state !=3D CAN_STATE_STOPPED)
> +		pch_can_reset(priv);
> +
> +	pch_set_bittiming(ndev);
> +	pch_can_set_optmode(priv);
> +
> +	pch_can_tx_enable_all(priv);
> +	pch_can_rx_enable_all(priv);
> +
> +	/* Setting the CAN to run mode. */
> +	pch_can_set_run_mode(priv, PCH_CAN_RUN);
> +
> +	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +
> +	return;
> +}
> +
> +static int pch_can_do_set_mode(struct net_device *ndev, enum can_mode =
mode)
> +{
> +	int ret =3D 0;
> +
> +	switch (mode) {
> +	case CAN_MODE_START:
> +		pch_can_start(ndev);
> +		netif_wake_queue(ndev);
> +		break;
> +	default:
> +		ret =3D -EOPNOTSUPP;
> +		break;
> +	}
> +
> +	return ret;
> +}
> +
> +static int pch_can_open(struct net_device *ndev)
> +{
> +	struct pch_can_priv *priv =3D netdev_priv(ndev);
> +	int retval;
> +
> +	/* Regsitering the interrupt. */
> +	retval =3D request_irq(priv->dev->irq, pch_can_interrupt, IRQF_SHARED=
,
> +			     ndev->name, ndev);
> +	if (retval) {
> +		dev_err(&ndev->dev, "request_irq failed.\n");
> +		goto req_irq_err;
> +	}
> +
> +	/* Open common can device */
> +	retval =3D open_candev(ndev);
> +	if (retval) {
> +		dev_err(ndev->dev.parent, "open_candev() failed %d\n", retval);
> +		goto err_open_candev;
> +	}
> +
> +	pch_can_init(priv);
> +	pch_can_start(ndev);
> +	napi_enable(&priv->napi);
> +	netif_start_queue(ndev);
> +
> +	return 0;
> +
> +err_open_candev:
> +	free_irq(priv->dev->irq, ndev);
> +req_irq_err:
> +	pch_can_release(priv);
> +
> +	return retval;
> +}
> +
> +static int pch_close(struct net_device *ndev)
> +{
> +	struct pch_can_priv *priv =3D netdev_priv(ndev);
> +
> +	netif_stop_queue(ndev);
> +	napi_disable(&priv->napi);
> +	pch_can_release(priv);
> +	free_irq(priv->dev->irq, ndev);
> +	close_candev(ndev);
> +	priv->can.state =3D CAN_STATE_STOPPED;
> +	return 0;
> +}
> +
> +static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *nd=
ev)
> +{
> +	unsigned long flags;
> +	struct pch_can_priv *priv =3D netdev_priv(ndev);
> +	struct can_frame *cf =3D (struct can_frame *)skb->data;
> +	int tx_buffer_avail =3D 0;

What I'm totally missing is the TX flow controll. Your driver has to
ensure that the package leave the controller in the order that come
into the xmit function. Further you have to stop your xmit queue if
you're out of tx objects and reenable if you have a object free.

Use netif_stop_queue() and netif_wake_queue() for this.

> +
> +	if (can_dropped_invalid_skb(ndev, skb))
> +		return NETDEV_TX_OK;
> +
> +	if (priv->tx_obj =3D=3D (PCH_OBJ_NUM + 1)) { /* Point tail Obj + 1 */=

> +		while (ioread32(&priv->regs->treq2) & 0xfc00)
> +			udelay(1);

please no (possible) infinite delays!

> +		priv->tx_obj =3D PCH_RX_OBJ_NUM + 1; /* Point head of Tx Obj ID */
> +	}

> +
> +	tx_buffer_avail =3D priv->tx_obj;

why has the "object" become a "buffer" now? :)

> +	priv->tx_obj++;
> +
> +	/* Attaining the lock. */
> +	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> +
> +	/* Setting the CMASK register to set value*/
                                                 ^^^

pleas add a whitespace

> +	iowrite32(CAN_CMASK_RX_TX_SET, &priv->regs->if2_cmask);
> +
> +	/* If ID extended is set. */
> +	if (cf->can_id & CAN_EFF_FLAG) {
> +		iowrite32(cf->can_id & 0xffff, &priv->regs->if2_id1);
> +		iowrite32(((cf->can_id >> 16) & 0x1fff) | CAN_ID2_XTD,
> +			    &priv->regs->if2_id2);
> +	} else {
> +		iowrite32(0, &priv->regs->if2_id1);
> +		iowrite32((cf->can_id & CAN_SFF_MASK) << 2,
> +			   &priv->regs->if2_id2);
> +	}
> +
> +	pch_can_bit_set(&priv->regs->if2_id2, CAN_ID_MSGVAL);

Do you need to do a read-modify-write of the hardware register? Please
prepare the values you want to write to hardware, then do it.

> +
> +	/* If remote frame has to be transmitted.. */
> +	if (!(cf->can_id & CAN_RTR_FLAG))
> +		pch_can_bit_set(&priv->regs->if2_id2, CAN_ID2_DIR);
dito
> +	/* If remote frame has to be transmitted.. */
> +	if (cf->can_id & CAN_RTR_FLAG)
> +		pch_can_bit_clear(&priv->regs->if2_id2, CAN_ID2_DIR);
dito
> +
> +	/* Copy data to register */
> +	if (cf->can_dlc > 0) {
> +		u32 data1 =3D *((u16 *)&cf->data[0]);
> +		iowrite32(data1, &priv->regs->if2_dataa1);

do you think you send the bytes in correct order?

> +	}
> +	if (cf->can_dlc > 2) {
> +		u32 data1 =3D *((u16 *)&cf->data[2]);
> +		iowrite32(data1, &priv->regs->if2_dataa2);
> +	}
> +	if (cf->can_dlc > 4) {
> +		u32 data1 =3D *((u16 *)&cf->data[4]);
> +		iowrite32(data1, &priv->regs->if2_datab1);
> +	}
> +	if (cf->can_dlc > 6) {
> +		u32 data1 =3D *((u16 *)&cf->data[6]);
> +		iowrite32(data1, &priv->regs->if2_datab2);
> +	}
> +
> +	can_put_echo_skb(skb, ndev, tx_buffer_avail - PCH_RX_OBJ_NUM - 1);
> +
> +	/* Set the size of the data. */
> +	iowrite32(cf->can_dlc, &priv->regs->if2_mcont);
> +
> +	/* Update if2_mcont */
> +	pch_can_bit_set(&priv->regs->if2_mcont,
> +			CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_TXRQXT |
> +			CAN_IF_MCONT_TXIE);

pleae first perpare your value, then write to hardware.

> +
> +	if (tx_buffer_avail =3D=3D PCH_RX_OBJ_NUM) /* If points tail of FIFO =
 */
> +		pch_can_bit_set(&priv->regs->if2_mcont, CAN_IF_MCONT_EOB);

dito

Is EOB relevant for TX objects?

> +	pch_can_check_if_busy(&priv->regs->if2_creq, tx_buffer_avail);
> +	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static const struct net_device_ops pch_can_netdev_ops =3D {
> +	.ndo_open		=3D pch_can_open,
> +	.ndo_stop		=3D pch_close,
> +	.ndo_start_xmit		=3D pch_xmit,
> +};
> +
> +static void __devexit pch_can_remove(struct pci_dev *pdev)
> +{
> +	struct net_device *ndev =3D pci_get_drvdata(pdev);
> +	struct pch_can_priv *priv =3D netdev_priv(ndev);
> +
> +	unregister_candev(priv->ndev);
> +	pci_iounmap(pdev, priv->regs);
> +	if (priv->use_msi)
> +		pci_disable_msi(priv->dev);
> +	pci_release_regions(pdev);
> +	pci_disable_device(pdev);
> +	pci_set_drvdata(pdev, NULL);
> +	free_candev(priv->ndev);
> +}
> +
> +#ifdef CONFIG_PM
> +static void pch_can_set_int_custom(struct pch_can_priv *priv)
> +{
> +	/* Clearing the IE, SIE and EIE bits of Can control register. */
> +	pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_IE_SIE_EIE);
> +
> +	/* Appropriately setting them. */
> +	pch_can_bit_set(&priv->regs->cont,
> +			((priv->int_enables & MSK_CTRL_IE_SIE_EIE) << 1));
> +}
> +
> +/* This function retrieves interrupt enabled for the CAN device. */
> +static u32 pch_can_get_int_enables(struct pch_can_priv *priv)
> +{
> +	/* Obtaining the status of IE, SIE and EIE interrupt bits. */
> +	return (ioread32(&priv->regs->cont) & CAN_CTRL_IE_SIE_EIE) >> 1;
> +}
> +
> +static u32 pch_can_get_rx_enable(struct pch_can_priv *priv, u32 buff_n=
um)
> +{
> +	unsigned long flags;
> +	u32 enable;
> +
> +	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> +	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> +	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
> +
> +	if (((ioread32(&priv->regs->if1_id2)) & CAN_ID_MSGVAL) &&
> +			((ioread32(&priv->regs->if1_mcont)) &
> +			CAN_IF_MCONT_RXIE))
> +		enable =3D 1;
> +	else
> +		enable =3D 0;
> +	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> +	return enable;
> +}
> +
> +static u32 pch_can_get_tx_enable(struct pch_can_priv *priv, u32 buff_n=
um)
> +{
> +	unsigned long flags;
> +	u32 enable;
> +
> +	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> +
> +	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> +	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
> +	if (((ioread32(&priv->regs->if2_id2)) & CAN_ID_MSGVAL) &&
> +			((ioread32(&priv->regs->if2_mcont)) &
> +			CAN_IF_MCONT_TXIE)) {
> +		enable =3D 1;
> +	} else {
> +		enable =3D 0;
> +	}
> +	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> +
> +	return enable;
> +}
> +
> +static void pch_can_set_rx_buffer_link(struct pch_can_priv *priv,
> +				       u32 buffer_num, u32 set)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> +	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> +	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
> +	iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL, &priv->regs->if1_cmask);
> +	if (set =3D=3D 1)
> +		pch_can_bit_clear(&priv->regs->if1_mcont, CAN_IF_MCONT_EOB);
> +	else
> +		pch_can_bit_set(&priv->regs->if1_mcont, CAN_IF_MCONT_EOB);
> +
> +	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
> +	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> +}
> +
> +static u32 pch_can_get_rx_buffer_link(struct pch_can_priv *priv, u32 b=
uffer_num)
> +{
> +	unsigned long flags;
> +	u32 link;
> +
> +	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> +	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> +	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
> +
> +	if (ioread32(&priv->regs->if1_mcont) & CAN_IF_MCONT_EOB)
> +		link =3D 0;
> +	else
> +		link =3D 1;
> +	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> +	return link;
> +}
> +
> +static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
> +{
> +	int i;
> +	int retval;
> +	u32 buf_stat;	/* Variable for reading the transmit buffer status. */
> +	u32 counter =3D COUNTER_LIMIT;
> +
> +	struct net_device *dev =3D pci_get_drvdata(pdev);
> +	struct pch_can_priv *priv =3D netdev_priv(dev);
> +
> +	/* Stop the CAN controller */
> +	pch_can_set_run_mode(priv, PCH_CAN_STOP);
> +
> +	/* Indicate that we are aboutto/in suspend */
> +	priv->can.state =3D CAN_STATE_STOPPED;
> +
> +	/* Waiting for all transmission to complete. */
> +	while (counter) {
> +		buf_stat =3D pch_can_get_buffer_status(priv);
> +		if (!buf_stat)
> +			break;
> +		counter--;
> +		udelay(1);
> +	}
> +	if (!counter)
> +		dev_err(&pdev->dev, "%s -> Transmission time out.\n", __func__);
> +
> +	/* Save interrupt configuration and then disable them */
> +	priv->int_enables =3D pch_can_get_int_enables(priv);
> +	pch_can_set_int_enables(priv, PCH_CAN_DISABLE);
> +
> +	/* Save Tx buffer enable state */
> +	for (i =3D PCH_RX_OBJ_NUM + 1; i <=3D PCH_OBJ_NUM; i++)
> +		priv->tx_enable[i] =3D pch_can_get_tx_enable(priv, i);
> +
> +	/* Disable all Transmit buffers */
> +	pch_can_tx_disable_all(priv);
> +
> +	/* Save Rx buffer enable state */
> +	for (i =3D 1; i <=3D PCH_RX_OBJ_NUM; i++) {
> +		priv->rx_enable[i] =3D pch_can_get_rx_enable(priv, i);
> +		priv->rx_link[i] =3D pch_can_get_rx_buffer_link(priv, i);
> +	}
> +
> +	/* Disable all Receive buffers */
> +	pch_can_rx_disable_all(priv);
> +	retval =3D pci_save_state(pdev);
> +	if (retval) {
> +		dev_err(&pdev->dev, "pci_save_state failed.\n");
> +	} else {
> +		pci_enable_wake(pdev, PCI_D3hot, 0);
> +		pci_disable_device(pdev);
> +		pci_set_power_state(pdev, pci_choose_state(pdev, state));
> +	}
> +
> +	return retval;
> +}
> +
> +static int pch_can_resume(struct pci_dev *pdev)
> +{
> +	int i;
> +	int retval;
> +	struct net_device *dev =3D pci_get_drvdata(pdev);
> +	struct pch_can_priv *priv =3D netdev_priv(dev);
> +
> +	pci_set_power_state(pdev, PCI_D0);
> +	pci_restore_state(pdev);
> +	retval =3D pci_enable_device(pdev);
> +	if (retval) {
> +		dev_err(&pdev->dev, "pci_enable_device failed.\n");
> +		return retval;
> +	}
> +
> +	pci_enable_wake(pdev, PCI_D3hot, 0);
> +
> +	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +
> +	/* Disabling all interrupts. */
> +	pch_can_set_int_enables(priv, PCH_CAN_DISABLE);
> +
> +	/* Setting the CAN device in Stop Mode. */
> +	pch_can_set_run_mode(priv, PCH_CAN_STOP);
> +
> +	/* Configuring the transmit and receive buffers. */
> +	pch_can_config_rx_tx_buffers(priv);
> +
> +	/* Restore the CAN state */
> +	pch_set_bittiming(dev);
> +
> +	/* Listen/Active */
> +	pch_can_set_optmode(priv);
> +
> +	/* Enabling the transmit buffer. */
> +	for (i =3D 1; i <=3D PCH_RX_OBJ_NUM; i++)
> +		pch_can_set_tx_enable(priv, i, priv->tx_enable[i]);
> +
> +	/* Configuring the receive buffer and enabling them. */
> +	for (i =3D PCH_RX_OBJ_NUM + 1; i <=3D PCH_OBJ_NUM; i++) {
> +		/* Restore buffer link */
> +		pch_can_set_rx_buffer_link(priv, i, priv->rx_link[i]);
> +
> +		/* Restore buffer enables */
> +		pch_can_set_rx_enable(priv, i, priv->rx_enable[i]);
> +	}
> +
> +	/* Enable CAN Interrupts */
> +	pch_can_set_int_custom(priv);
> +
> +	/* Restore Run Mode */
> +	pch_can_set_run_mode(priv, PCH_CAN_RUN);
> +
> +	return retval;
> +}
> +#else
> +#define pch_can_suspend NULL
> +#define pch_can_resume NULL
> +#endif
> +
> +static int pch_can_get_berr_counter(const struct net_device *dev,
> +				    struct can_berr_counter *bec)
> +{
> +	struct pch_can_priv *priv =3D netdev_priv(dev);
> +
> +	bec->txerr =3D ioread32(&priv->regs->errc) & CAN_TEC;
> +	bec->rxerr =3D (ioread32(&priv->regs->errc) & CAN_REC) >> 8;
> +
> +	return 0;
> +}
> +
> +static int __devinit pch_can_probe(struct pci_dev *pdev,
> +				   const struct pci_device_id *id)
> +{
> +	struct net_device *ndev;
> +	struct pch_can_priv *priv;
> +	int rc;
> +	void __iomem *addr;
> +
> +	rc =3D pci_enable_device(pdev);
> +	if (rc) {
> +		dev_err(&pdev->dev, "Failed pci_enable_device %d\n", rc);
> +		goto probe_exit_endev;
> +	}
> +
> +	rc =3D pci_request_regions(pdev, KBUILD_MODNAME);
> +	if (rc) {
> +		dev_err(&pdev->dev, "Failed pci_request_regions %d\n", rc);
> +		goto probe_exit_pcireq;
> +	}
> +
> +	addr =3D pci_iomap(pdev, 1, 0);
> +	if (!addr) {
> +		rc =3D -EIO;
> +		dev_err(&pdev->dev, "Failed pci_iomap\n");
> +		goto probe_exit_ipmap;
> +	}
> +
> +	ndev =3D alloc_candev(sizeof(struct pch_can_priv), PCH_TX_OBJ_NUM);
> +	if (!ndev) {
> +		rc =3D -ENOMEM;
> +		dev_err(&pdev->dev, "Failed alloc_candev\n");
> +		goto probe_exit_alloc_candev;
> +	}
> +
> +	priv =3D netdev_priv(ndev);
> +	priv->ndev =3D ndev;
> +	priv->regs =3D addr;
> +	priv->dev =3D pdev;
> +	priv->can.bittiming_const =3D &pch_can_bittiming_const;
> +	priv->can.do_set_mode =3D pch_can_do_set_mode;
> +	priv->can.do_get_berr_counter =3D pch_can_get_berr_counter;
> +	priv->can.ctrlmode_supported =3D CAN_CTRLMODE_LISTENONLY |
> +				       CAN_CTRLMODE_LOOPBACK;
> +	priv->tx_obj =3D PCH_RX_OBJ_NUM + 1; /* Point head of Tx Obj */
> +
> +	ndev->irq =3D pdev->irq;
> +	ndev->flags |=3D IFF_ECHO;
> +
> +	pci_set_drvdata(pdev, ndev);
> +	SET_NETDEV_DEV(ndev, &pdev->dev);
> +	ndev->netdev_ops =3D &pch_can_netdev_ops;
> +	priv->can.clock.freq =3D PCH_CAN_CLK; /* Hz */
> +
> +	netif_napi_add(ndev, &priv->napi, pch_can_rx_poll, PCH_RX_OBJ_NUM);
> +
> +	rc =3D pci_enable_msi(priv->dev);
> +	if (rc) {
> +		dev_info(&ndev->dev, "PCH CAN opened without MSI\n");
> +		priv->use_msi =3D 0;
> +	} else {
> +		dev_info(&ndev->dev, "PCH CAN opened with MSI\n");
> +		priv->use_msi =3D 1;
> +	}
> +
> +	rc =3D register_candev(ndev);
> +	if (rc) {
> +		dev_err(&pdev->dev, "Failed register_candev %d\n", rc);
> +		goto probe_exit_reg_candev;
> +	}
> +
> +	return 0;
> +
> +probe_exit_reg_candev:
> +	free_candev(ndev);
> +probe_exit_alloc_candev:
> +	pci_iounmap(pdev, addr);
> +probe_exit_ipmap:
> +	pci_release_regions(pdev);
> +probe_exit_pcireq:
> +	pci_disable_device(pdev);
> +probe_exit_endev:
> +	return rc;
> +}
> +
> +static struct pci_driver pch_can_pcidev =3D {
> +	.name =3D "pch_can",
> +	.id_table =3D pch_pci_tbl,
> +	.probe =3D pch_can_probe,
> +	.remove =3D __devexit_p(pch_can_remove),
> +	.suspend =3D pch_can_suspend,
> +	.resume =3D pch_can_resume,
> +};
> +
> +static int __init pch_can_pci_init(void)
> +{
> +	return pci_register_driver(&pch_can_pcidev);
> +}
> +module_init(pch_can_pci_init);
> +
> +static void __exit pch_can_pci_exit(void)
> +{
> +	pci_unregister_driver(&pch_can_pcidev);
> +}
> +module_exit(pch_can_pci_exit);
> +
> +MODULE_DESCRIPTION("Intel EG20T PCH CAN(Controller Area Network) Drive=
r");
> +MODULE_LICENSE("GPL v2");
> +MODULE_VERSION("0.94");

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig8A02DFB078E92D5FF97ED14E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkzK9RsACgkQjTAFq1RaXHOwRgCfc6hsrtZShfWHqQHOyqOo02ju
+kwAmwSroQMJu05ZqQshGt1Wl6Nyf4Si
=Kgl3
-----END PGP SIGNATURE-----

--------------enig8A02DFB078E92D5FF97ED14E--

--===============8448738253567117877==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============8448738253567117877==--
