From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: add Renesas R-Car CAN driver
Date: Sun, 29 Sep 2013 21:03:45 +0200
Message-ID: <52487991.6000209@pengutronix.de>
References: <201309280211.39068.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="P7s53qIxCA5MTJtcL5tm3KljsmDBUhwEP"
Cc: netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org, linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201309280211.39068.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--P7s53qIxCA5MTJtcL5tm3KljsmDBUhwEP
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/28/2013 12:11 AM, Sergei Shtylyov wrote:
> Add support for the CAN controller found in Renesas R-Car SoCs.

Is there a public available datasheet for the CAN core? What
architecture are the Renesas R-Car SoCs? They're ARM, aren't they?
What's R-Car's status on device tree conversion?

More comments inline

> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>=20
> ---
> The patch is against the 'linux-can-next.git' repo.
>=20
>  drivers/net/can/Kconfig               |    9=20
>  drivers/net/can/Makefile              |    1=20
>  drivers/net/can/rcar_can.c            |  898 +++++++++++++++++++++++++=
+++++++++
>  include/linux/can/platform/rcar_can.h |   15=20
>  4 files changed, 923 insertions(+)
>=20
> Index: linux-can-next/drivers/net/can/Kconfig
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-can-next.orig/drivers/net/can/Kconfig
> +++ linux-can-next/drivers/net/can/Kconfig
> @@ -125,6 +125,15 @@ config CAN_GRCAN
>  	  endian syntheses of the cores would need some modifications on
>  	  the hardware level to work.
> =20
> +config CAN_RCAR
> +	tristate "Renesas R-Car CAN controller"
> +	---help---
> +	  Say Y here if you want to use CAN controller found on Renesas R-Car=

> +	  SoCs.
> +
> +	  To compile this driver as a module, choose M here: the module will
> +	  be called rcar_can.
> +
>  source "drivers/net/can/mscan/Kconfig"
> =20
>  source "drivers/net/can/sja1000/Kconfig"
> Index: linux-can-next/drivers/net/can/Makefile
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-can-next.orig/drivers/net/can/Makefile
> +++ linux-can-next/drivers/net/can/Makefile
> @@ -25,5 +25,6 @@ obj-$(CONFIG_CAN_JANZ_ICAN3)	+=3D janz-ica
>  obj-$(CONFIG_CAN_FLEXCAN)	+=3D flexcan.o
>  obj-$(CONFIG_PCH_CAN)		+=3D pch_can.o
>  obj-$(CONFIG_CAN_GRCAN)		+=3D grcan.o
> +obj-$(CONFIG_CAN_RCAR)		+=3D rcar_can.o
> =20
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) :=3D -DDEBUG
> Index: linux-can-next/drivers/net/can/rcar_can.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- /dev/null
> +++ linux-can-next/drivers/net/can/rcar_can.c
> @@ -0,0 +1,898 @@
> +/*
> + * Renesas R-Car CAN device driver
> + *
> + * Copyright (C) 2013 Cogent Embedded, Inc. <source@cogentembedded.com=
>
> + * Copyright (C) 2013 Renesas Solutions Corp.
> + *
> + * This program is free software; you can redistribute  it and/or modi=
fy it
> + * under  the terms of  the GNU General  Public License as published b=
y the
> + * Free Software Foundation;  either version 2 of the  License, or (at=
 your
> + * option) any later version.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/interrupt.h>
> +#include <linux/errno.h>
> +#include <linux/netdevice.h>
> +#include <linux/platform_device.h>
> +#include <linux/can/led.h>
> +#include <linux/can/dev.h>
> +#include <linux/clk.h>
> +#include <linux/can/platform/rcar_can.h>
> +
> +#define DRV_NAME	"rcar_can"
> +
> +#define RCAR_CAN_MIER1	0x42C	/* CANi Mailbox Interrupt Enable Register=
 1 */
> +#define RCAR_CAN_MKR(n)	((n) < 2 ? 0x430 + 4 * (n) : 0x400 + 4 * ((n) =
- 2))
> +				/* CANi Mask Register */
> +#define RCAR_CAN_MKIVLR0 0x438	/* CANi Mask Invalid Register 0 */
> +#define RCAR_CAN_MIER0	 0x43C	/* CANi Mailbox Interrupt Enable Registe=
r 0 */
> +
> +#define RCAR_CAN_MCTL(n) (0x800 + (n)) /* CANi Message Control Registe=
r */
> +#define RCAR_CAN_CTLR	0x840	/* CANi Control Register */
> +#define RCAR_CAN_STR	0x842	/* CANi Status Register */
> +#define RCAR_CAN_BCR	0x844	/* CANi Bit Configuration Register */
> +#define RCAR_CAN_CLKR	0x847	/* CANi Clock Select Register */
> +#define RCAR_CAN_EIER	0x84C	/* CANi Error Interrupt Enable Register */=

> +#define RCAR_CAN_EIFR	0x84D	/* CANi Err Interrupt Factor Judge Registe=
r */
> +#define RCAR_CAN_RECR	0x84E	/* CANi Receive Error Count Register */
> +#define RCAR_CAN_TECR	0x84F	/* CANi Transmit Error Count Register */
> +#define RCAR_CAN_ECSR	0x850	/* CANi Error Code Store Register */
> +#define RCAR_CAN_MSSR	0x852	/* CANi Mailbox Search Status Register */
> +#define RCAR_CAN_MSMR	0x853	/* CANi Mailbox Search Mode Register */
> +#define RCAR_CAN_TCR	0x858	/* CANi Test Control Register */
> +#define RCAR_CAN_IER	0x860	/* CANi Interrupt Enable Register */
> +#define RCAR_CAN_ISR	0x861	/* CANi Interrupt Status Register */

You might consider using an enum for the register offsets.

> +
> +/* Offsets of RCAR_CAN Mailbox Registers */
> +#define MBX_HDR_OFFSET	0x0
> +#define MBX_DLC_OFFSET	0x5
> +#define MBX_DATA_OFFSET	0x6

can you please add the RCAR_ prefix to all defines.

> +
> +#define RCAR_CAN_MBX_SIZE 0x10
> +
> +/* Control Register bits */
> +#define CTLR_SLPM	BIT(10)
> +#define CTLR_HALT	BIT(9)
> +#define CTLR_RESET	BIT(8)
> +#define CTLR_FORCE_RESET (3 << 8)
> +#define CTLR_TPM	BIT(4)	/* Transmission Priority Mode Select Bit */
> +#define CTLR_IDFM_MIXED	BIT(2)	/* Mixed ID mode */
> +
> +/* Message Control Register bits */
> +#define MCTL_TRMREQ	BIT(7)
> +#define MCTL_RECREQ	BIT(6)
> +#define MCTL_ONESHOT	BIT(4)
> +#define MCTL_SENTDATA	BIT(0)
> +#define MCTL_NEWDATA	BIT(0)
> +
> +#define N_RX_MKREGS	2	/* Number of mask registers */
> +				/* for Rx mailboxes 0-31 */
> +
> +/* Bit Configuration Register settings */
> +#define BCR_TSEG1(x)	(((x) & 0x0f) << 28)
> +#define BCR_BPR(x)	(((x) & 0x3ff) << 16)
> +#define BCR_SJW(x)	(((x) & 0x3) << 12)
> +#define BCR_TSEG2(x)	(((x) & 0x07) << 8)
> +
> +/* Mailbox and Mask Registers bits */
> +#define RCAR_CAN_IDE	BIT(31)
> +#define RCAR_CAN_RTR	BIT(30)
> +#define RCAR_CAN_SID_SHIFT 18
> +
> +/* Interrupt Enable Register bits */
> +#define IER_ERSIE	BIT(5)	/* Error (ERS) Interrupt Enable Bit */
> +#define IER_RXM0IE	BIT(2)	/* Mailbox 0 Successful Reception (RXM0) */
> +				/* Interrupt Enable Bit */
> +#define IER_RXM1IE	BIT(1)	/* Mailbox 1 Successful Reception (RXM0) */
> +				/* Interrupt Enable Bit */
> +#define IER_TXMIE	BIT(0)	/* Mailbox 32 to 63 Successful Tx */
> +				/* Interrupt Enable Bit */
> +
> +/* Interrupt Status Register bits */
> +#define ISR_ERSF	BIT(5)	/* Error (ERS) Interrupt Status Bit */
> +#define ISR_RXM0F	BIT(2)	/* Mailbox 0 Successful Reception (RXM0) */
> +				/* Interrupt Status Bit */
> +#define ISR_RXM1F	BIT(1)	/* Mailbox 1 to 63 Successful Reception */
> +				/* (RXM1) Interrupt Status Bit */
> +#define ISR_TXMF	BIT(0)	/* Mailbox 32 to 63 Successful Transmission */=

> +				/* (TXM) Interrupt Status Bit */
> +
> +/* Error Interrupt Enable Register bits */
> +#define EIER_BLIE	BIT(7)	/* Bus Lock Interrupt Enable */
> +#define EIER_OLIE	BIT(6)	/* Overload Frame Transmit Interrupt Enable *=
/
> +#define EIER_ORIE	BIT(5)	/* Receive Overrun Interrupt Enable */
> +#define EIER_BORIE	BIT(4)	/* Bus-Off Recovery Interrupt Enable */
> +
> +#define EIER_BOEIE	BIT(3)	/* Bus-Off Entry Interrupt Enable */
> +#define EIER_EPIE	BIT(2)	/* Error Passive Interrupt Enable */
> +#define EIER_EWIE	BIT(1)	/* Error Warning Interrupt Enable */
> +#define EIER_BEIE	BIT(0)	/* Bus Error Interrupt Enable */
> +
> +/* Error Interrupt Factor Judge Register bits */
> +#define EIFR_BLIF	BIT(7)	/* Bus Lock Detect Flag */
> +#define EIFR_OLIF	BIT(6)	/* Overload Frame Transmission Detect Flag */=

> +#define EIFR_ORIF	BIT(5)	/* Receive Overrun Detect Flag */
> +#define EIFR_BORIF	BIT(4)	/* Bus-Off Recovery Detect Flag */
> +#define EIFR_BOEIF	BIT(3)	/* Bus-Off Entry Detect Flag */
> +#define EIFR_EPIF	BIT(2)	/* Error Passive Detect Flag */
> +#define EIFR_EWIF	BIT(1)	/* Error Warning Detect Flag */
> +#define EIFR_BEIF	BIT(0)	/* Bus Error Detect Flag */
> +
> +/* Error Code Store Register bits */
> +#define ECSR_EDPM	BIT(7)	/* Error Display Mode Select Bit */
> +#define ECSR_ADEF	BIT(6)	/* ACK Delimiter Error Flag */
> +#define ECSR_BE0F	BIT(5)	/* Bit Error (dominant) Flag */
> +#define ECSR_BE1F	BIT(4)	/* Bit Error (recessive) Flag */
> +#define ECSR_CEF	BIT(3)	/* CRC Error Flag */
> +#define ECSR_AEF	BIT(2)	/* ACK Error Flag */
> +#define ECSR_FEF	BIT(1)	/* Form Error Flag */
> +#define ECSR_SEF	BIT(0)	/* Stuff Error Flag */
> +
> +/* Mailbox Search Status Register bits */
> +#define MSSR_SEST	BIT(7)	/* Search Result Status Bit */
> +#define MSSR_MBNST	0x3f	/* Search Result Mailbox Number Status mask */=

> +
> +/* Mailbox Search Mode Register values */
> +#define MSMR_TXMB	1	/* Transmit mailbox search mode */
> +#define MSMR_RXMB	0	/* Receive mailbox search mode */
> +
> +/* Mailbox configuration:
> + * mailbox 0 - not used
> + * mailbox 1-31 - Rx
> + * mailbox 32-63 - Tx
> + * no FIFO mailboxes
> + */
> +#define N_MBX		64
> +#define FIRST_TX_MB	32
> +#define RX_MBX_MASK	0xFFFFFFFE
> +
> +#define RCAR_CAN_NAPI_WEIGHT (FIRST_TX_MB - 1)
> +
> +struct rcar_can_priv {
> +	struct can_priv can;	/* Must be the first member! */
> +	struct net_device *ndev;
> +	struct napi_struct napi;
> +	void __iomem *reg_base;
> +	struct clk *clk;
> +	spinlock_t mier_lock;
> +	u8 clock_select;
> +};
> +
> +static const struct can_bittiming_const rcar_can_bittiming_const =3D {=

> +	.name =3D DRV_NAME,
> +	.tseg1_min =3D 4,
> +	.tseg1_max =3D 16,
> +	.tseg2_min =3D 2,
> +	.tseg2_max =3D 8,
> +	.sjw_max =3D 4,
> +	.brp_min =3D 1,
> +	.brp_max =3D 1024,
> +	.brp_inc =3D 1,
> +};
> +

If you use use an enum for the register offsets you can change the int
to that enum in the accessor functions.

> +static inline u32 rcar_can_readl(struct rcar_can_priv *priv, int reg)
> +{
> +	return readl(priv->reg_base + reg);
> +}
> +
> +static inline u16 rcar_can_readw(struct rcar_can_priv *priv, int reg)
> +{
> +	return readw(priv->reg_base + reg);
> +}
> +
> +static inline u8 rcar_can_readb(struct rcar_can_priv *priv, int reg)
> +{
> +	return readb(priv->reg_base + reg);
> +}
> +
> +static inline void rcar_can_writel(struct rcar_can_priv *priv, int reg=
, u32 val)
> +{
> +	writel(val, priv->reg_base + reg);
> +}
> +
> +static inline void rcar_can_writew(struct rcar_can_priv *priv, int reg=
, u16 val)
> +{
> +	writew(val, priv->reg_base + reg);
> +}
> +
> +static inline void rcar_can_writeb(struct rcar_can_priv *priv, int reg=
, u8 val)
> +{
> +	writeb(val, priv->reg_base + reg);
> +}
> +
> +static inline u32 rcar_can_mbx_readl(struct rcar_can_priv *priv,
> +				     u32 mbxno, u8 offset)
> +{
> +	return rcar_can_readl(priv, RCAR_CAN_MBX_SIZE * mbxno + offset);

Can you define hide the RCAR_CAN_MBX_SIZE * mbxno into a macro?
Something like:

    RCAR_CAN_MBX(mbxno)

> +}
> +
> +static inline u8 rcar_can_mbx_readb(struct rcar_can_priv *priv,
> +				    u32 mbxno, u8 offset)
> +{
> +	return rcar_can_readb(priv, RCAR_CAN_MBX_SIZE * mbxno + offset);
> +}
> +
> +static inline void rcar_can_mbx_writel(struct rcar_can_priv *priv, u32=
 mbxno,
> +				       u8 offset, u32 val)
> +{
> +	rcar_can_writel(priv, RCAR_CAN_MBX_SIZE * mbxno + offset, val);
> +}
> +
> +static inline void rcar_can_mbx_writeb(struct rcar_can_priv *priv, u32=
 mbxno,
> +				       u8 offset, u8 val)
> +{
> +	rcar_can_writeb(priv, RCAR_CAN_MBX_SIZE * mbxno + offset, val);
> +}
> +
> +static void rcar_can_error(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	u8 eifr;
> +
> +	/* Propagate the error condition to the CAN stack */
> +	skb =3D alloc_can_err_skb(ndev, &cf);
> +	if (!skb) {
> +		if (printk_ratelimit())
> +			netdev_err(priv->ndev,
> +				   "%s: alloc_can_err_skb() failed\n",
> +				   __func__);
> +		return;
> +	}
> +
> +	eifr =3D rcar_can_readb(priv, RCAR_CAN_EIFR);
> +	if (eifr & EIFR_EWIF) {
> +		netdev_dbg(priv->ndev, "Error warning interrupt\n");
> +		priv->can.state =3D CAN_STATE_ERROR_WARNING;
> +		priv->can.can_stats.error_warning++;
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		if (rcar_can_readb(priv, RCAR_CAN_TECR) > 96)
> +			cf->data[1] |=3D CAN_ERR_CRTL_TX_WARNING;
> +		if (rcar_can_readb(priv, RCAR_CAN_RECR) > 96)
> +			cf->data[1] |=3D CAN_ERR_CRTL_RX_WARNING;
> +		/* Clear interrupt condition */
> +		rcar_can_writeb(priv, RCAR_CAN_EIFR, (u8)~EIFR_EWIF);

The cast is not needed.

> +	}
> +	if (eifr & EIFR_EPIF) {
> +		netdev_dbg(priv->ndev, "Error passive interrupt\n");
> +		priv->can.state =3D CAN_STATE_ERROR_PASSIVE;
> +		priv->can.can_stats.error_passive++;
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		if (rcar_can_readb(priv, RCAR_CAN_TECR) > 127)
> +			cf->data[1] |=3D CAN_ERR_CRTL_TX_PASSIVE;
> +		if (rcar_can_readb(priv, RCAR_CAN_RECR) > 127)
> +			cf->data[1] |=3D CAN_ERR_CRTL_RX_PASSIVE;
> +		/* Clear interrupt condition */
> +		rcar_can_writeb(priv, RCAR_CAN_EIFR, (u8)~EIFR_EPIF);
> +	}
> +	if (eifr & EIFR_BOEIF) {
> +		netdev_dbg(priv->ndev, "Bus-off entry interrupt\n");
> +		priv->can.state =3D CAN_STATE_BUS_OFF;
> +		cf->can_id |=3D CAN_ERR_BUSOFF;
> +		/* Clear interrupt condition */
> +		rcar_can_writeb(priv, RCAR_CAN_EIFR, (u8)~EIFR_BOEIF);
> +		/* Disable all interrupts in bus-off to avoid int hog */
> +		rcar_can_writeb(priv, RCAR_CAN_EIER, 0);
> +		rcar_can_writeb(priv, RCAR_CAN_IER, 0);
> +		can_bus_off(ndev);

How does the rcan recover from bus off?

> +	}
> +	if (eifr & EIFR_BEIF) {
> +		int rx_errors =3D 0, tx_errors =3D 0, bus_errors =3D 0;
> +		u8 ecsr;
> +
> +		netdev_dbg(priv->ndev, "Bus error interrupt:\n");
> +		cf->can_id |=3D CAN_ERR_BUSERROR | CAN_ERR_PROT;
> +		cf->data[2] =3D CAN_ERR_PROT_UNSPEC;
> +
> +		ecsr =3D rcar_can_readb(priv, RCAR_CAN_ECSR);
> +		if (ecsr & ECSR_ADEF) {
> +			netdev_dbg(priv->ndev, "ACK Delimiter Error\n");
> +			cf->data[3] |=3D CAN_ERR_PROT_LOC_ACK_DEL;
> +			bus_errors++;
> +			tx_errors++;
> +			rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_ADEF);
> +		}
> +		if (ecsr & ECSR_BE0F) {
> +			netdev_dbg(priv->ndev, "Bit Error (dominant)\n");
> +			cf->data[2] |=3D CAN_ERR_PROT_BIT0;
> +			bus_errors++;
> +			tx_errors++;
> +			rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_BE0F);
> +		}
> +		if (ecsr & ECSR_BE1F) {
> +			netdev_dbg(priv->ndev, "Bit Error (recessive)\n");
> +			cf->data[2] |=3D CAN_ERR_PROT_BIT1;
> +			bus_errors++;
> +			tx_errors++;
> +			rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_BE1F);
> +		}
> +		if (ecsr & ECSR_CEF) {
> +			netdev_dbg(priv->ndev, "CRC Error\n");
> +			cf->data[3] |=3D CAN_ERR_PROT_LOC_CRC_SEQ;
> +			bus_errors++;
> +			rx_errors++;
> +			rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_CEF);
> +		}
> +		if (ecsr & ECSR_AEF) {
> +			netdev_dbg(priv->ndev, "ACK Error\n");
> +			cf->data[3] |=3D CAN_ERR_PROT_LOC_ACK;
> +			bus_errors++;
> +			tx_errors++;
> +			rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_AEF);
> +		}
> +		if (ecsr & ECSR_FEF) {
> +			netdev_dbg(priv->ndev, "Form Error\n");
> +			cf->data[2] |=3D CAN_ERR_PROT_FORM;
> +			bus_errors++;
> +			rx_errors++;
> +			rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_FEF);
> +		}
> +		if (ecsr & ECSR_SEF) {
> +			netdev_dbg(priv->ndev, "Stuff Error\n");
> +			cf->data[2] |=3D CAN_ERR_PROT_STUFF;
> +			bus_errors++;
> +			rx_errors++;
> +			rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_SEF);
> +		}
> +
> +		priv->can.can_stats.bus_error +=3D bus_errors;
> +		ndev->stats.rx_errors +=3D rx_errors;
> +		ndev->stats.tx_errors +=3D tx_errors;
> +		rcar_can_writeb(priv, RCAR_CAN_EIFR, (u8)~EIFR_BEIF);
> +	}
> +	if (eifr & EIFR_ORIF) {
> +		netdev_dbg(priv->ndev, "Receive overrun error interrupt\n");
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		cf->data[1] |=3D CAN_ERR_CRTL_RX_OVERFLOW;
> +		ndev->stats.rx_over_errors++;
> +		ndev->stats.rx_errors++;
> +		rcar_can_writeb(priv, RCAR_CAN_EIFR, (u8)~EIFR_ORIF);
> +	}
> +	if (eifr & EIFR_OLIF) {
> +		netdev_dbg(priv->ndev,
> +			   "Overload Frame Transmission error interrupt\n");
> +		cf->can_id |=3D CAN_ERR_PROT;
> +		cf->data[2] |=3D CAN_ERR_PROT_OVERLOAD;
> +		ndev->stats.rx_over_errors++;
> +		ndev->stats.rx_errors++;
> +		rcar_can_writeb(priv, RCAR_CAN_EIFR, (u8)~EIFR_OLIF);
> +	}
> +
> +	netif_rx(skb);
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->can_dlc;
> +}
> +
> +static irqreturn_t rcar_can_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *ndev =3D (struct net_device *)dev_id;
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	u8 isr;
> +
> +	isr =3D rcar_can_readb(priv, RCAR_CAN_ISR);
> +	if (isr & ISR_ERSF)
> +		rcar_can_error(ndev);
> +
> +	if (isr & ISR_TXMF) {
> +		u32 ie_mask =3D 0;
> +
> +		/* Set Transmit Mailbox Search Mode */
> +		rcar_can_writeb(priv, RCAR_CAN_MSMR, MSMR_TXMB);

Can you please outline how to mailbox search mode works? What happens if
you activate tx mailbox search mode here and rx mailbox search mode below=
?

> +		while (1) {

I presonally don't like while (1) loops in an interrupt handler, can you
rearange the code, so that you have an explizid loop termination?

> +			u8 mctl, mbx;
> +
> +			mbx =3D rcar_can_readb(priv, RCAR_CAN_MSSR);
> +			if (mbx & MSSR_SEST)
> +				break;
> +			mbx &=3D MSSR_MBNST;
> +			mctl =3D rcar_can_readb(priv, RCAR_CAN_MCTL(mbx));
> +			/* Bits SENTDATA and TRMREQ cannot be
> +			 * set to 0 simultaneously
> +			 */
> +			mctl &=3D ~MCTL_TRMREQ;
> +			rcar_can_writeb(priv, RCAR_CAN_MCTL(mbx), mctl);
> +			mctl &=3D ~MCTL_SENTDATA;
> +			/* Clear interrupt */
> +			rcar_can_writeb(priv, RCAR_CAN_MCTL(mbx), mctl);

Can you combine both writes to RCAR_CAN_MCTL(mbx) or does the hardware
require two separate writes?

> +			ie_mask |=3D BIT(mbx - FIRST_TX_MB);
> +			stats->tx_bytes +=3D can_get_echo_skb(ndev,
> +							    mbx - FIRST_TX_MB);

Can you guarantee that you call can_get_echo_skb in the same order the
frames get send?

> +			stats->tx_packets++;
> +			can_led_event(ndev, CAN_LED_EVENT_TX);
> +		}
> +		/* Set receive mailbox search mode */
> +		rcar_can_writeb(priv, RCAR_CAN_MSMR, MSMR_RXMB);
> +		/* Disable mailbox interrupt, mark mailbox as free */
> +		if (ie_mask) {
> +			u32 mier1;
> +
> +			spin_lock(&priv->mier_lock);
> +			mier1 =3D rcar_can_readl(priv, RCAR_CAN_MIER1);
> +			rcar_can_writel(priv, RCAR_CAN_MIER1, mier1 & ~ie_mask);
> +			spin_unlock(&priv->mier_lock);
> +			if (unlikely(netif_queue_stopped(ndev)))
> +				netif_wake_queue(ndev);

You can call netif_wake_queue() unconditionally, it does the check for
queue stopped anyway.

> +		}
> +	}
> +	if (isr & ISR_RXM1F) {
> +		if (napi_schedule_prep(&priv->napi)) {
> +			/* Disable Rx interrupts */
> +			rcar_can_writeb(priv, RCAR_CAN_IER,
> +					rcar_can_readb(priv, RCAR_CAN_IER) &
> +						       ~IER_RXM1IE);
> +			__napi_schedule(&priv->napi);
> +		}
> +	}
> +	return IRQ_HANDLED;

Do not return IRQ_HANDLED unconditionally. You should return IRQ_HANDLED
only if there really was a interrupt for your device.

> +}
> +
> +static int rcar_can_set_bittiming(struct net_device *dev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(dev);
> +	struct can_bittiming *bt =3D &priv->can.bittiming;
> +	u32 bcr;
> +	u16 ctlr;
> +	u8 clkr;
> +
> +	ctlr =3D rcar_can_readw(priv, RCAR_CAN_CTLR);
> +	if (ctlr & CTLR_SLPM) {
> +		/* Write to BCR in CAN reset mode or CAN halt mode */
> +		return -EBUSY;

The framework guarantees that set_bittiming is only called when the
interface is down.

> +	}
> +	/* Don't overwrite CLKR with 32-bit BCR access */
> +	/* CLKR has 8-bit access */
> +	clkr =3D rcar_can_readb(priv, RCAR_CAN_CLKR);
> +	bcr =3D BCR_TSEG1(bt->phase_seg1 + bt->prop_seg - 1) |
> +	      BCR_BPR(bt->brp - 1) | BCR_SJW(bt->sjw - 1) |
> +	      BCR_TSEG2(bt->phase_seg2 - 1);
> +	rcar_can_writel(priv, RCAR_CAN_BCR, bcr);
> +	rcar_can_writeb(priv, RCAR_CAN_CLKR, clkr);
> +	return 0;
> +}
> +
> +static void rcar_can_start(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	u16 ctlr, n;
> +
> +	/* Set controller to known mode:
> +	 * - normal mailbox mode (no FIFO);

Does the controller support FIFO?

> +	 * - accept all messages (no filter).
> +	 * CAN is in sleep mode after MCU hardware or software reset.
> +	 */
> +	ctlr =3D rcar_can_readw(priv, RCAR_CAN_CTLR);
> +	ctlr &=3D ~CTLR_SLPM;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	/* Go to reset mode */
> +	ctlr |=3D CTLR_FORCE_RESET;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	ctlr |=3D CTLR_IDFM_MIXED;	/* Select mixed ID mode */
> +	ctlr &=3D ~CTLR_TPM;		/* Set ID priority transmit mode */
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +
> +	rcar_can_writeb(priv, RCAR_CAN_CLKR, priv->clock_select);
> +
> +	/* Accept all SID and EID */
> +	for (n =3D 0; n < N_RX_MKREGS; n++)
> +		rcar_can_writel(priv, RCAR_CAN_MKR(n), 0);
> +	rcar_can_writel(priv, RCAR_CAN_MKIVLR0, 0);
> +
> +	rcar_can_set_bittiming(ndev);
> +
> +	/* Initial value of MIER1 undefined.  Mark all Tx mailboxes as free. =
*/
> +	rcar_can_writel(priv, RCAR_CAN_MIER1, 0);
> +
> +	rcar_can_writeb(priv, RCAR_CAN_IER, IER_TXMIE | IER_ERSIE | IER_RXM1I=
E);
> +
> +	/* Accumulate error codes */
> +	rcar_can_writeb(priv, RCAR_CAN_ECSR, ECSR_EDPM);
> +	/* Enable error interrupts */
> +	rcar_can_writeb(priv, RCAR_CAN_EIER,
> +			EIER_EWIE | EIER_EPIE | EIER_BOEIE | EIER_BEIE |
> +			EIER_ORIE | EIER_OLIE);
> +	/* Enable interrupts for RX mailboxes */
> +	rcar_can_writel(priv, RCAR_CAN_MIER0, RX_MBX_MASK);
> +	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +
> +	/* Write to the CiMCTLj register in CAN
> +	 * operation mode or CAN halt mode.
> +	 * Configure mailboxes 0-31 as Rx mailboxes.
> +	 * Configure mailboxes 32-63 as Tx mailboxes.
> +	 */
> +	/* Go to halt mode */
> +	ctlr |=3D CTLR_HALT;
> +	ctlr &=3D ~CTLR_RESET;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	for (n =3D 0; n < FIRST_TX_MB; n++) {
> +		/* According to documentation we should clear MCTL
> +		 * register before configuring mailbox.
> +		 */
> +		rcar_can_writeb(priv, RCAR_CAN_MCTL(n), 0);
> +		rcar_can_writeb(priv, RCAR_CAN_MCTL(n), MCTL_RECREQ);
> +		rcar_can_writeb(priv, RCAR_CAN_MCTL(FIRST_TX_MB + n), 0);
> +	}
> +	/* Go to operation mode */
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr & ~CTLR_FORCE_RESET);
> +}
> +
> +static int rcar_can_open(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	int err;
> +
> +	err =3D open_candev(ndev);
> +	if (err) {
> +		netdev_err(ndev, "open_candev() failed %d\n", err);
> +		goto out;
> +	}
> +	napi_enable(&priv->napi);
> +	err =3D request_irq(ndev->irq, rcar_can_interrupt, 0, ndev->name, nde=
v);
> +	if (err) {
> +		netdev_err(ndev, "error requesting interrupt %x\n", ndev->irq);
> +		goto out_close;
> +	}
> +	can_led_event(ndev, CAN_LED_EVENT_OPEN);
> +	rcar_can_start(ndev);
> +	netif_start_queue(ndev);
> +	return 0;
> +out_close:
> +	napi_disable(&priv->napi);
> +	close_candev(ndev);
> +out:
> +	return err;
> +}
> +
> +static void rcar_can_stop(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	u16 ctlr;
> +
> +	/* Go to (force) reset mode */
> +	ctlr =3D rcar_can_readw(priv, RCAR_CAN_CTLR);
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr | CTLR_FORCE_RESET);
> +	rcar_can_writel(priv, RCAR_CAN_MIER0, 0);
> +	rcar_can_writel(priv, RCAR_CAN_MIER1, 0);
> +	rcar_can_writeb(priv, RCAR_CAN_IER, 0);
> +	rcar_can_writeb(priv, RCAR_CAN_EIER, 0);
> +	priv->can.state =3D CAN_STATE_STOPPED;
> +}
> +
> +static int rcar_can_close(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +
> +	netif_stop_queue(ndev);
> +	rcar_can_stop(ndev);
> +	free_irq(ndev->irq, ndev);
> +	napi_disable(&priv->napi);
> +	close_candev(ndev);
> +	can_led_event(ndev, CAN_LED_EVENT_STOP);
> +	return 0;
> +}
> +
> +static netdev_tx_t rcar_can_start_xmit(struct sk_buff *skb,
> +				       struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	struct can_frame *cf =3D (struct can_frame *)skb->data;
> +	u32 data, mier1, mbxno, i;
> +	unsigned long flags;
> +	u8 mctl;
> +
> +	if (can_dropped_invalid_skb(ndev, skb))
> +		return NETDEV_TX_OK;
> +
> +	spin_lock_irqsave(&priv->mier_lock, flags);
> +	mier1 =3D rcar_can_readl(priv, RCAR_CAN_MIER1);
> +	if (unlikely(mier1 =3D=3D ~0U)) {
> +		spin_unlock_irqrestore(&priv->mier_lock, flags);
> +		netif_stop_queue(ndev);
> +		return NETDEV_TX_BUSY;
> +	}
> +	rcar_can_writel(priv, RCAR_CAN_MIER1, mier1 | (mier1 + 1));
> +	spin_unlock_irqrestore(&priv->mier_lock, flags);
> +	mbxno =3D ffz(mier1) + FIRST_TX_MB;

This smells fishy, for several reasons:
The driver should guarantee that the frames are send in the same order
as this function is called. If you pick the first free mailbox I suspect
the hardware send the first mailbox ready to send. I don't know the
hardware, but several CAN controllers I've worked with, function in that
way.
Then you should rethink your flow control. You should call
netif_stop_queue if all your hardware buffers are full, then the above
NETDEV_TX_BUSY should not happen.

> +
> +	if (cf->can_id & CAN_EFF_FLAG) {
> +		/* Extended frame format */
> +		data =3D (cf->can_id & CAN_EFF_MASK) | RCAR_CAN_IDE;
> +	} else {
> +		/* Standard frame format */
> +		data =3D (cf->can_id & CAN_SFF_MASK) << RCAR_CAN_SID_SHIFT;
> +	}
> +	if (cf->can_id & CAN_RTR_FLAG) {
> +		/* Remote transmission request */
> +		data |=3D RCAR_CAN_RTR;
> +	}
> +	rcar_can_mbx_writel(priv, mbxno, MBX_HDR_OFFSET, data);
> +
> +	rcar_can_mbx_writeb(priv, mbxno, MBX_DLC_OFFSET, cf->can_dlc);
> +
> +	for (i =3D 0; i < cf->can_dlc; i++)
> +		rcar_can_mbx_writeb(priv, mbxno,
> +				    MBX_DATA_OFFSET + i, cf->data[i]);
> +
> +	can_put_echo_skb(skb, ndev, mbxno - FIRST_TX_MB);
> +
> +	rcar_can_writeb(priv, RCAR_CAN_IER,
> +			rcar_can_readb(priv, RCAR_CAN_IER) | IER_TXMIE);
> +
> +	mctl =3D rcar_can_readb(priv, RCAR_CAN_MCTL(mbxno));

Do you have to read mctl here?

> +	if (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT)
> +		mctl |=3D MCTL_ONESHOT;
> +	else
> +		mctl &=3D ~MCTL_ONESHOT;
> +	/* Start TX */
> +	mctl |=3D MCTL_TRMREQ;
> +	rcar_can_writeb(priv, RCAR_CAN_MCTL(mbxno), mctl);
> +	return NETDEV_TX_OK;
> +}
> +
> +static const struct net_device_ops rcar_can_netdev_ops =3D {
> +	.ndo_open =3D rcar_can_open,
> +	.ndo_stop =3D rcar_can_close,
> +	.ndo_start_xmit =3D rcar_can_start_xmit,
> +};
> +
> +static void rcar_can_rx_pkt(struct rcar_can_priv *priv, int mbx)
> +{
> +	struct net_device_stats *stats =3D &priv->ndev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	u32 data;
> +	u8 dlc;
> +
> +	skb =3D alloc_can_skb(priv->ndev, &cf);
> +	if (!skb) {
> +		stats->rx_dropped++;
> +		if (printk_ratelimit())
> +			netdev_err(priv->ndev,
> +				   "%s: alloc_can_skb() failed\n", __func__);
> +		return;
> +	}
> +
> +	data =3D rcar_can_mbx_readl(priv, mbx, MBX_HDR_OFFSET);
> +	if (data & RCAR_CAN_IDE)
> +		cf->can_id =3D (data & CAN_EFF_MASK) | CAN_EFF_FLAG;
> +	else
> +		cf->can_id =3D (data >> RCAR_CAN_SID_SHIFT) & CAN_SFF_MASK;
> +	if (data & RCAR_CAN_RTR)
> +		cf->can_id |=3D CAN_RTR_FLAG;
> +
> +	dlc =3D rcar_can_mbx_readb(priv, mbx, MBX_DLC_OFFSET);
> +	cf->can_dlc =3D get_can_dlc(dlc);

Please don't copy data on received RTR frames.

> +	for (dlc =3D 0; dlc < cf->can_dlc; dlc++)
> +		cf->data[dlc] =3D rcar_can_mbx_readb(priv, mbx,
> +						   MBX_DATA_OFFSET + dlc);
> +
> +	can_led_event(priv->ndev, CAN_LED_EVENT_RX);
> +
> +	netif_receive_skb(skb);
> +	stats->rx_bytes +=3D cf->can_dlc;
> +	stats->rx_packets++;
> +}
> +
> +static int rcar_can_rx_poll(struct napi_struct *napi, int quota)
> +{
> +	struct rcar_can_priv *priv =3D container_of(napi,
> +						  struct rcar_can_priv, napi);
> +	u32 num_pkts =3D 0;

please make it an int
> +
> +	/* Find mailbox */
> +	while (1) {

please put the quota check into the while()

> +		u8 mctl, mbx;
> +
> +		mbx =3D rcar_can_readb(priv, RCAR_CAN_MSSR);
> +		if (mbx & MSSR_SEST || num_pkts >=3D quota)
> +			break;
> +		mbx &=3D MSSR_MBNST;
> +		mctl =3D rcar_can_readb(priv, RCAR_CAN_MCTL(mbx));
> +		/* Clear interrupt */
> +		rcar_can_writeb(priv, RCAR_CAN_MCTL(mbx),
> +				mctl & ~MCTL_NEWDATA);
> +		rcar_can_rx_pkt(priv, mbx);

Which instruction reenables the mailbox?

> +		++num_pkts;
> +	}
> +	/* All packets processed */
> +	if (num_pkts < quota) {
> +		u8 ier;
> +
> +		napi_complete(napi);
> +		ier =3D rcar_can_readb(priv, RCAR_CAN_IER);
> +		rcar_can_writeb(priv, RCAR_CAN_IER, ier | IER_RXM1IE);

I the hardware doesn't modify the IER register, you can work on a shadow
copy and only write, but never need to read from the hardware.

> +	}
> +	return num_pkts;
> +}
> +
> +static int rcar_can_do_set_mode(struct net_device *ndev, enum can_mode=
 mode)
> +{
> +	switch (mode) {
> +	case CAN_MODE_START:
> +		rcar_can_start(ndev);
> +		netif_wake_queue(ndev);
> +		return 0;
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +}
> +
> +static int rcar_can_get_berr_counter(const struct net_device *dev,
> +				     struct can_berr_counter *bec)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(dev);
> +
> +	bec->txerr =3D rcar_can_readb(priv, RCAR_CAN_TECR);
> +	bec->rxerr =3D rcar_can_readb(priv, RCAR_CAN_RECR);
> +	return 0;
> +}
> +
> +static int rcar_can_probe(struct platform_device *pdev)
> +{
> +	struct rcar_can_platform_data *pdata;
> +	struct rcar_can_priv *priv;
> +	struct net_device *ndev;
> +	struct resource *mem;
> +	void __iomem *addr;
> +	int err =3D -ENODEV;
> +	int irq;
> +
> +	pdata =3D pdev->dev.platform_data;

please use dev_get_platdata()

> +	if (!pdata) {
> +		dev_err(&pdev->dev, "No platform data provided!\n");
> +		goto fail;
> +	}
> +
> +	irq =3D platform_get_irq(pdev, 0);
> +	if (!irq) {
> +		dev_err(&pdev->dev, "No IRQ resource\n");
> +		goto fail;
> +	}
> +
> +	mem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	addr =3D devm_ioremap_resource(&pdev->dev, mem);
> +	if (IS_ERR(addr)) {
> +		err =3D PTR_ERR(addr);
> +		goto fail;
> +	}
> +
> +	ndev =3D alloc_candev(sizeof(struct rcar_can_priv), N_MBX - FIRST_TX_=
MB);
> +	if (!ndev) {
> +		dev_err(&pdev->dev, "alloc_candev failed\n");
> +		err =3D -ENOMEM;
> +		goto fail;
> +	}
> +
> +	priv =3D netdev_priv(ndev);
> +
> +	priv->clk =3D devm_clk_get(&pdev->dev, NULL);
> +	if (IS_ERR(priv->clk)) {
> +		err =3D PTR_ERR(priv->clk);
> +		dev_err(&pdev->dev, "cannot get clock: %d\n", err);
> +		goto fail_clk;
> +	}
> +	clk_enable(priv->clk);

You are missing the clock's prepare step. You should call
clk_prepare_enable(). Please move clock_prepare_enable() to the open()
(and the disable_unprepare() to the close() function) so tha the core is
not powered as long as the interface is down. You might have to enable
the clock in the rcar_can_get_berr_counter() as it may be called if the
interface is still down.

> +
> +	ndev->netdev_ops =3D &rcar_can_netdev_ops;
> +	ndev->irq =3D irq;
> +	ndev->flags |=3D IFF_ECHO;
> +	priv->ndev =3D ndev;
> +	priv->reg_base =3D addr;
> +	priv->clock_select =3D pdata->clock_select;
> +	priv->can.clock.freq =3D clk_get_rate(priv->clk);
> +	priv->can.bittiming_const =3D &rcar_can_bittiming_const;
> +	priv->can.do_set_bittiming =3D rcar_can_set_bittiming;

No need to set this callback, as you're calling rcar_can_set_bittiming
explizidly.

> +	priv->can.do_set_mode =3D rcar_can_do_set_mode;
> +	priv->can.do_get_berr_counter =3D rcar_can_get_berr_counter;
> +	priv->can.ctrlmode_supported =3D CAN_CTRLMODE_3_SAMPLES |
> +				       CAN_CTRLMODE_ONE_SHOT;

You don't handle 3_SAMPLES. Have you tested your driver in ONE_SHOT
mode? How does the controller react if a frame cannot be send? Do you
clear the skb that has previously been can_put_echo_skb()?


> +	platform_set_drvdata(pdev, ndev);
> +	SET_NETDEV_DEV(ndev, &pdev->dev);
> +	spin_lock_init(&priv->mier_lock);
> +
> +	netif_napi_add(ndev, &priv->napi, rcar_can_rx_poll,
> +		       RCAR_CAN_NAPI_WEIGHT);
> +	err =3D register_candev(ndev);
> +	if (err) {
> +		dev_err(&pdev->dev, "register_candev() failed\n");
> +		goto fail_candev;
> +	}
> +
> +	devm_can_led_init(ndev);
> +
> +	dev_info(&pdev->dev, "device registered (reg_base=3D%p, irq=3D%u)\n",=

> +		 priv->reg_base, ndev->irq);
> +
> +	return 0;
> +fail_candev:
> +	netif_napi_del(&priv->napi);
> +fail_clk:
> +	free_candev(ndev);
> +fail:
> +	return err;
> +}
> +
> +static int rcar_can_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev =3D platform_get_drvdata(pdev);
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	u16 ctlr;
> +
> +	unregister_candev(ndev);
> +	netif_napi_del(&priv->napi);
> +	/* Go to sleep mode */
> +	ctlr =3D rcar_can_readw(priv, RCAR_CAN_CTLR);
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr | CTLR_SLPM);

You should put the controller in to sleep mode in close()

> +	clk_disable(priv->clk);
> +	free_candev(ndev);
> +	return 0;
> +}
> +
> +#ifdef CONFIG_PM_SLEEP
> +static int rcar_can_suspend(struct device *dev)
> +{
> +	struct net_device *ndev =3D dev_get_drvdata(dev);
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	u16 ctlr;
> +
> +	if (netif_running(ndev)) {
> +		netif_stop_queue(ndev);
> +		netif_device_detach(ndev);
> +	}
> +	ctlr =3D rcar_can_readw(priv, RCAR_CAN_CTLR);
> +	ctlr |=3D CTLR_HALT;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	ctlr |=3D CTLR_SLPM;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	priv->can.state =3D CAN_STATE_SLEEPING;
> +
> +	clk_disable(priv->clk);
> +	return 0;
> +}
> +
> +static int rcar_can_resume(struct device *dev)
> +{
> +	struct net_device *ndev =3D dev_get_drvdata(dev);
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	u16 ctlr;
> +
> +	clk_enable(priv->clk);
> +
> +	ctlr =3D rcar_can_readw(priv, RCAR_CAN_CTLR);
> +	ctlr &=3D ~CTLR_SLPM;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	ctlr &=3D ~CTLR_FORCE_RESET;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +
> +	if (netif_running(ndev)) {
> +		netif_device_attach(ndev);
> +		netif_start_queue(ndev);
> +	}
> +	return 0;
> +}
> +#endif
> +
> +static SIMPLE_DEV_PM_OPS(rcar_can_pm_ops, rcar_can_suspend, rcar_can_r=
esume);
> +
> +static struct platform_driver rcar_can_driver =3D {
> +	.driver =3D {
> +		.name =3D DRV_NAME,
> +		.owner =3D THIS_MODULE,
> +		.pm =3D &rcar_can_pm_ops,
> +	},
> +	.probe =3D rcar_can_probe,
> +	.remove =3D rcar_can_remove,
> +};
> +
> +module_platform_driver(rcar_can_driver);
> +
> +MODULE_AUTHOR("Cogent Embedded, Inc.");
> +MODULE_LICENSE("GPL");
> +MODULE_DESCRIPTION("CAN driver for Renesas R-Car SoC");
> +MODULE_ALIAS("platform:" DRV_NAME);
> Index: linux-can-next/include/linux/can/platform/rcar_can.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- /dev/null
> +++ linux-can-next/include/linux/can/platform/rcar_can.h
> @@ -0,0 +1,15 @@
> +#ifndef _CAN_PLATFORM_RCAR_CAN_H_
> +#define _CAN_PLATFORM_RCAR_CAN_H_
> +
> +#include <linux/types.h>
> +
> +/* Clock Select Register settings */
> +#define CLKR_CLKEXT	3	/* Externally input clock */
> +#define CLKR_CLKP2	1	/* Peripheral clock (clkp2) */
> +#define CLKR_CLKP1	0	/* Peripheral clock (clkp1) */

Can this be handled by the clock framework and or Device Tree?

> +
> +struct rcar_can_platform_data {
> +	u8 clock_select;	/* Clock source select */
> +};
> +
> +#endif	/* !_CAN_PLATFORM_RCAR_CAN_H_ */
> --
> To unsubscribe from this list: send the line "unsubscribe linux-can" in=

> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--P7s53qIxCA5MTJtcL5tm3KljsmDBUhwEP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlJIeZEACgkQjTAFq1RaXHMXTwCeO7pHuAVeeHdL81mxdjl8AKQj
DTwAnRieCS5PFC4DWrgPyNkHDtxf/cIU
=HMBR
-----END PGP SIGNATURE-----

--P7s53qIxCA5MTJtcL5tm3KljsmDBUhwEP--
