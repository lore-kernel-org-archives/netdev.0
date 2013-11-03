From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3] can: add Renesas R-Car CAN driver
Date: Sun, 03 Nov 2013 21:11:34 +0100
Message-ID: <5276ADF6.9050309@pengutronix.de>
References: <201311020240.13354.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="7abDFLKbGIOcEL5EuD1Nn9rkrAFkIXeef"
Cc: netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org, linux-sh@vger.kernel.org,
	vksavl@gmail.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201311020240.13354.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--7abDFLKbGIOcEL5EuD1Nn9rkrAFkIXeef
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/02/2013 12:40 AM, Sergei Shtylyov wrote:
> Add support for the CAN controller found in Renesas R-Car SoCs.=20
>=20
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

See comment inline.

>=20
> ---
> The patch is against the 'linux-can-next.git' repo.
>=20
> Changes in version 3:
> - replaced the register #define's with 'struct rcar_can_regs' fields, r=
eplaced
>   rcar_can_{read|write}[bwl]() with mere {read|write}[bwl]();
> - removed hardware bus-off recovery support which allowed to also remov=
e
>   rcar_can_start() prototype;
> - added RX/TX error count to error data frame for error warning/passive=
;
> - moved TX completion interrupt handling into separate function;
> - removed unneeded type cast in the probe() method.
>=20
> Changes in version 2:
> - added function to clean up TX mailboxes after bus error and bus-off;
> - added module parameter to enable hardware recovery from bus-off, adde=
d handler
>   for the bus-off recovery interrupt, and set the control register acco=
rding to
>   the parameter value and the restart timer setting in rcar_can_start()=
;
> - changed the way CAN_ERR_CRTL_[RT]X_{PASSIVE|WARNING} flags are set to=
 a more
>   realicstic one;
> - replaced MBX_* macros and rcar_can_mbx_{read|write}[bl]() functions w=
ith
>   'struct rcar_can_mbox_regs', 'struct rcar_can_regs', and {read|write}=
[bl](),
>   replaced 'reg_base' field of 'struct rcar_can_priv' with 'struct rcar=
_can_regs
>   __iomem *regs';
> - added 'ier' field to 'struct rcar_can_priv' to cache the current valu=
e of the
>   interrupt enable register;
> - added a check for enabled interrupts on entry to rcar_can_interrupt()=
;
> - limited transmit mailbox search loop in rcar_can_interrupt();
> - decoupled  TX byte count increment from can_get_echo_skb() call;
> - removed netif_queue_stopped() call from rcar_can_interrupt();
> - added clk_prepare_enable()/clk_disable_unprepare() to ndo_{open|close=
}(),
>   do_set_bittiming(), and do_get_berr_counter() methods, removed clk_en=
able()
>   call from the probe() method and clk_disable() call from the remove()=
 method;
> - allowed rcar_can_set_bittiming() to be called when the device is clos=
ed and
>   remove  explicit call to it from rcar_can_start();
> - switched to using mailbox number priority transmit mode, and switched=
 to the
>   sequential mailbox use in ndo_start_xmit() method;
> - stopped reading the message control registers in ndo_start_xmit() met=
hod;
> - avoided returning NETDEV_TX_BUSY from ndo_start_xmit() method;
> - stopped reading data when RTR bit is set in the CAN frame;
> - made 'num_pkts' variable *int* and moved its check to the *while* con=
dition in
>   rcar_can_rx_poll();
> - used dev_get_platdata() in the probe() method;
> - enabled bus error interrupt only if CAN_CTRLMODE_BERR_REPORTING flag =
is set;
> - started reporting CAN_CTRLMODE_BERR_REPORTING support and stopped rep=
orting
>   CAN_CTRLMODE_3_SAMPLES support;
> - set CAN_ERR_ACK flag on ACK error;
> - switched to incrementing bus error counter only once per bus error in=
terrupt;
> - started switching to CAN sleep mode in rcar_can_stop() and stopped sw=
itching
>   to it in the remove() method;
> - removed netdev_err() calls on allocation failure in rcar_can_error() =
and
>   rcar_can_rx_pkt();
> - removed "CANi" from the register offset macro comments.
>=20
>  drivers/net/can/Kconfig               |    9=20
>  drivers/net/can/Makefile              |    1=20
>  drivers/net/can/rcar_can.c            |  893 +++++++++++++++++++++++++=
+++++++++
>  include/linux/can/platform/rcar_can.h |   15=20
>  4 files changed, 918 insertions(+)
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
> @@ -0,0 +1,893 @@
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
> +/* Mailbox configuration:
> + * mailbox 0 - not used
> + * mailbox 1-31 - Rx
> + * mailbox 32-63 - Tx
> + * no FIFO mailboxes
> + */
> +#define N_MBX		64
> +#define FIRST_TX_MB	32
> +#define N_TX_MB		(N_MBX - FIRST_TX_MB)
> +#define RX_MBX_MASK	0xFFFFFFFE

Please use a common prefix for all defines.

> +
> +/* Mailbox registers structure */
> +struct rcar_can_mbox_regs {
> +	u32 id;		/* IDE and RTR bits, SID and EID */
> +	u8 stub;	/* Not used */
> +	u8 dlc;		/* Data Length Code - bits [0..3] */
> +	u8 data[8];	/* Data Bytes */
> +	u8 tsh;		/* Time Stamp Higher Byte */
> +	u8 tsl;		/* Time Stamp Lower Byte */
> +} __packed;
> +
> +struct rcar_can_regs {
> +	struct rcar_can_mbox_regs mb[N_MBX]; /* Mailbox registers */
> +	u32 mkr_2_9[8];	/* Mask Registers 2-9 */
> +	u32 fidcr[2];	/* FIFO Received ID Compare Register */
> +	u32 mkivlr1;	/* Mask Invalid Register 1 */
> +	u32 mier1;	/* Mailbox Interrupt Enable Register 1 */
> +	u32 mkr_0_1[2];	/* Mask Registers 0-1 */
> +	u32 mkivlr0;    /* Mask Invalid Register 0*/
> +	u32 mier0;      /* Mailbox Interrupt Enable Register 0 */
> +	u8 pad_440[0x3c0];
> +	u8 mctl[64];	/* Message Control Registers */
> +	u16 ctlr;	/* Control Register */
> +	u16 str;	/* Status register */
> +	u8 bcr[3];	/* Bit Configuration Register */
> +	u8 clkr;	/* Clock Select Register */
> +	u8 rfcr;	/* Receive FIFO Control Register */
> +	u8 rfpcr;	/* Receive FIFO Pointer Control Register */
> +	u8 tfcr;	/* Transmit FIFO Control Register */
> +	u8 tfpcr;       /* Transmit FIFO Pointer Control Register */
> +	u8 eier;	/* Error Interrupt Enable Register */
> +	u8 eifr;	/* Error Interrupt Factor Judge Register */
> +	u8 recr;	/* Receive Error Count Register */
> +	u8 tecr;        /* Transmit Error Count Register */
> +	u8 ecsr;	/* Error Code Store Register */
> +	u8 cssr;	/* Channel Search Support Register */
> +	u8 mssr;	/* Mailbox Search Status Register */
> +	u8 msmr;	/* Mailbox Search Mode Register */
> +	u16 tsr;	/* Time Stamp Register */
> +	u8 afsr;	/* Acceptance Filter Support Register */
> +	u8 pad_857;
> +	u8 tcr;		/* Test Control Register */
> +	u8 pad_859[7];
> +	u8 ier;		/* Interrupt Enable Register */
> +	u8 isr;		/* Interrupt Status Register */
> +	u8 pad_862;
> +	u8 mbsmr;	/* Mailbox Search Mask Register */
> +} __packed;
> +
> +struct rcar_can_priv {
> +	struct can_priv can;	/* Must be the first member! */
> +	struct net_device *ndev;
> +	struct napi_struct napi;
> +	struct rcar_can_regs __iomem *regs;
> +	struct clk *clk;
> +	spinlock_t mier_lock;
> +	u8 clock_select;
> +	u8 ier;
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
> +/* Control Register bits */
> +#define CTLR_BOM	(3 << 11) /* Bus-Off Recovery Mode Bits */
> +#define CTLR_BOM_ENT	BIT(11)	/* Entry to halt mode at bus-off entry */=

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
> +#define RCAR_CAN_NAPI_WEIGHT (FIRST_TX_MB - 1)
> +
> +static void tx_failure_cleanup(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	u32 mier1;
> +	u8 mbx;
> +
> +	spin_lock(&priv->mier_lock);
> +	mier1 =3D readl(&priv->regs->mier1);
> +	for (mbx =3D FIRST_TX_MB; mbx < N_MBX; mbx++) {
> +		if (mier1 & BIT(mbx - FIRST_TX_MB)) {
> +			writeb(0, &priv->regs->mctl[mbx]);
> +			can_free_echo_skb(ndev, mbx - FIRST_TX_MB);
> +		}
> +	}
> +	writel(0, &priv->regs->mier1);
> +	spin_unlock(&priv->mier_lock);
> +}
> +
> +static void rcar_can_error(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	u8 eifr, txerr =3D 0, rxerr =3D 0;
> +
> +	/* Propagate the error condition to the CAN stack */
> +	skb =3D alloc_can_err_skb(ndev, &cf);
> +	if (!skb)
> +		return;
> +
> +	eifr =3D readb(&priv->regs->eifr);
> +	if (eifr & (EIFR_EWIF | EIFR_EPIF)) {
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		txerr =3D readb(&priv->regs->tecr);
> +		rxerr =3D readb(&priv->regs->recr);
> +		cf->data[6] =3D txerr;
> +		cf->data[7] =3D rxerr;
> +	}
> +	if (eifr & EIFR_BEIF) {
> +		int rx_errors =3D 0, tx_errors =3D 0;
> +		u8 ecsr;
> +
> +		if (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT)
> +			tx_failure_cleanup(ndev);
> +		netdev_dbg(priv->ndev, "Bus error interrupt:\n");
> +		cf->can_id |=3D CAN_ERR_BUSERROR | CAN_ERR_PROT;
> +		cf->data[2] =3D CAN_ERR_PROT_UNSPEC;
> +
> +		ecsr =3D readb(&priv->regs->ecsr);
> +		if (ecsr & ECSR_ADEF) {
> +			netdev_dbg(priv->ndev, "ACK Delimiter Error\n");
> +			cf->data[3] |=3D CAN_ERR_PROT_LOC_ACK_DEL;
> +			tx_errors++;
> +			writeb((u8)~ECSR_ADEF, &priv->regs->ecsr);
> +		}
> +		if (ecsr & ECSR_BE0F) {
> +			netdev_dbg(priv->ndev, "Bit Error (dominant)\n");
> +			cf->data[2] |=3D CAN_ERR_PROT_BIT0;
> +			tx_errors++;
> +			writeb((u8)~ECSR_BE0F, &priv->regs->ecsr);
> +		}
> +		if (ecsr & ECSR_BE1F) {
> +			netdev_dbg(priv->ndev, "Bit Error (recessive)\n");
> +			cf->data[2] |=3D CAN_ERR_PROT_BIT1;
> +			tx_errors++;
> +			writeb((u8)~ECSR_BE1F, &priv->regs->ecsr);
> +		}
> +		if (ecsr & ECSR_CEF) {
> +			netdev_dbg(priv->ndev, "CRC Error\n");
> +			cf->data[3] |=3D CAN_ERR_PROT_LOC_CRC_SEQ;
> +			rx_errors++;
> +			writeb((u8)~ECSR_CEF, &priv->regs->ecsr);
> +		}
> +		if (ecsr & ECSR_AEF) {
> +			netdev_dbg(priv->ndev, "ACK Error\n");
> +			cf->can_id |=3D CAN_ERR_ACK;
> +			cf->data[3] |=3D CAN_ERR_PROT_LOC_ACK;
> +			tx_errors++;
> +			writeb((u8)~ECSR_AEF, &priv->regs->ecsr);
> +		}
> +		if (ecsr & ECSR_FEF) {
> +			netdev_dbg(priv->ndev, "Form Error\n");
> +			cf->data[2] |=3D CAN_ERR_PROT_FORM;
> +			rx_errors++;
> +			writeb((u8)~ECSR_FEF, &priv->regs->ecsr);
> +		}
> +		if (ecsr & ECSR_SEF) {
> +			netdev_dbg(priv->ndev, "Stuff Error\n");
> +			cf->data[2] |=3D CAN_ERR_PROT_STUFF;
> +			rx_errors++;
> +			writeb((u8)~ECSR_SEF, &priv->regs->ecsr);
> +		}
> +
> +		priv->can.can_stats.bus_error++;
> +		ndev->stats.rx_errors +=3D rx_errors;
> +		ndev->stats.tx_errors +=3D tx_errors;
> +		writeb((u8)~EIFR_BEIF, &priv->regs->eifr);
> +	}
> +	if (eifr & EIFR_EWIF) {
> +		netdev_dbg(priv->ndev, "Error warning interrupt\n");
> +		priv->can.state =3D CAN_STATE_ERROR_WARNING;
> +		priv->can.can_stats.error_warning++;
> +		cf->data[1] |=3D txerr > rxerr ? CAN_ERR_CRTL_TX_WARNING :
> +					       CAN_ERR_CRTL_RX_WARNING;
> +		/* Clear interrupt condition */
> +		writeb((u8)~EIFR_EWIF, &priv->regs->eifr);
> +	}
> +	if (eifr & EIFR_EPIF) {
> +		netdev_dbg(priv->ndev, "Error passive interrupt\n");
> +		priv->can.state =3D CAN_STATE_ERROR_PASSIVE;
> +		priv->can.can_stats.error_passive++;
> +		cf->data[1] |=3D txerr > rxerr ? CAN_ERR_CRTL_TX_PASSIVE :
> +					       CAN_ERR_CRTL_RX_PASSIVE;
> +		/* Clear interrupt condition */
> +		writeb((u8)~EIFR_EPIF, &priv->regs->eifr);
> +	}
> +	if (eifr & EIFR_BOEIF) {
> +		netdev_dbg(priv->ndev, "Bus-off entry interrupt\n");
> +		tx_failure_cleanup(ndev);
> +		priv->ier =3D IER_ERSIE;
> +		writeb(priv->ier, &priv->regs->ier);
> +		priv->can.state =3D CAN_STATE_BUS_OFF;
> +		cf->can_id |=3D CAN_ERR_BUSOFF;
> +		/* Clear interrupt condition */
> +		writeb((u8)~EIFR_BOEIF, &priv->regs->eifr);
> +		can_bus_off(ndev);
> +	}
> +	if (eifr & EIFR_ORIF) {
> +		netdev_dbg(priv->ndev, "Receive overrun error interrupt\n");
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		cf->data[1] |=3D CAN_ERR_CRTL_RX_OVERFLOW;
> +		ndev->stats.rx_over_errors++;
> +		ndev->stats.rx_errors++;
> +		writeb((u8)~EIFR_ORIF, &priv->regs->eifr);
> +	}
> +	if (eifr & EIFR_OLIF) {
> +		netdev_dbg(priv->ndev,
> +			   "Overload Frame Transmission error interrupt\n");
> +		cf->can_id |=3D CAN_ERR_PROT;
> +		cf->data[2] |=3D CAN_ERR_PROT_OVERLOAD;
> +		ndev->stats.rx_over_errors++;
> +		ndev->stats.rx_errors++;
> +		writeb((u8)~EIFR_OLIF, &priv->regs->eifr);
> +	}
> +
> +	netif_rx(skb);
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->can_dlc;
> +}
> +
> +static void rcar_can_tx_done(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	u32 ie_mask =3D 0;
> +	int i;
> +
> +	/* Set Transmit Mailbox Search Mode */
> +	writeb(MSMR_TXMB, &priv->regs->msmr);
> +	for (i =3D 0; i < N_TX_MB; i++) {
> +		u8 mctl, mbx;
> +
> +		mbx =3D readb(&priv->regs->mssr);
> +		if (mbx & MSSR_SEST)
> +			break;
> +		mbx &=3D MSSR_MBNST;
> +		stats->tx_bytes +=3D readb(&priv->regs->mb[mbx].dlc);
> +		stats->tx_packets++;
> +		mctl =3D readb(&priv->regs->mctl[mbx]);
> +		/* Bits SENTDATA and TRMREQ cannot be
> +		 * set to 0 simultaneously
> +		 */
> +		mctl &=3D ~MCTL_TRMREQ;
> +		writeb(mctl, &priv->regs->mctl[mbx]);
> +		mctl &=3D ~MCTL_SENTDATA;
> +		/* Clear interrupt */
> +		writeb(mctl, &priv->regs->mctl[mbx]);
> +		ie_mask |=3D BIT(mbx - FIRST_TX_MB);
> +		can_get_echo_skb(ndev, mbx - FIRST_TX_MB);
> +		can_led_event(ndev, CAN_LED_EVENT_TX);
> +	}
> +	/* Set receive mailbox search mode */
> +	writeb(MSMR_RXMB, &priv->regs->msmr);
> +	/* Disable mailbox interrupt, mark mailbox as free */
> +	if (ie_mask) {
> +		u32 mier1;
> +
> +		spin_lock(&priv->mier_lock);
> +		mier1 =3D readl(&priv->regs->mier1);
> +		writel(mier1 & ~ie_mask, &priv->regs->mier1);
> +		spin_unlock(&priv->mier_lock);
> +		netif_wake_queue(ndev);
> +	}
> +}
> +
> +static irqreturn_t rcar_can_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *ndev =3D (struct net_device *)dev_id;
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	u8 isr;
> +
> +	isr =3D readb(&priv->regs->isr);
> +	if (!(isr & priv->ier))
> +		return IRQ_NONE;
> +
> +	if (isr & ISR_ERSF)
> +		rcar_can_error(ndev);
> +
> +	if (isr & ISR_TXMF)
> +		rcar_can_tx_done(ndev);
> +
> +	if (isr & ISR_RXM1F) {
> +		if (napi_schedule_prep(&priv->napi)) {
> +			/* Disable Rx interrupts */
> +			priv->ier &=3D ~IER_RXM1IE;
> +			writeb(priv->ier, &priv->regs->ier);
> +			__napi_schedule(&priv->napi);
> +		}
> +	}
> +
> +	return IRQ_HANDLED;
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
> +	clk_prepare_enable(priv->clk);
> +	/* rcar_can_set_bittiming() is called in CAN sleep mode.
> +	 * Can write to BCR  in CAN reset mode or CAN halt mode.
> +	 * Cannot write to CLKR in halt mode, so go to reset mode.
> +	 */
> +	ctlr =3D readw(&priv->regs->ctlr);
> +	ctlr &=3D ~CTLR_SLPM;
> +	ctlr |=3D CTLR_FORCE_RESET;
> +	writew(ctlr, &priv->regs->ctlr);
> +	/* Don't overwrite CLKR with 32-bit BCR access */
> +	/* CLKR has 8-bit access */
> +	clkr =3D readb(&priv->regs->clkr);
> +	bcr =3D BCR_TSEG1(bt->phase_seg1 + bt->prop_seg - 1) |
> +	      BCR_BPR(bt->brp - 1) | BCR_SJW(bt->sjw - 1) |
> +	      BCR_TSEG2(bt->phase_seg2 - 1);
> +	writel(bcr, &priv->regs->bcr);
> +	writeb(clkr, &priv->regs->clkr);
> +	ctlr |=3D CTLR_SLPM;
> +	writew(ctlr, &priv->regs->ctlr);
> +	clk_disable_unprepare(priv->clk);
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
> +	 * - accept all messages (no filter).
> +	 * CAN is in sleep mode after MCU hardware or software reset.
> +	 */
> +	ctlr =3D readw(&priv->regs->ctlr);
> +	ctlr &=3D ~CTLR_SLPM;
> +	writew(ctlr, &priv->regs->ctlr);
> +	/* Go to reset mode */
> +	ctlr |=3D CTLR_FORCE_RESET;
> +	writew(ctlr, &priv->regs->ctlr);
> +	ctlr |=3D CTLR_IDFM_MIXED; /* Select mixed ID mode */
> +	ctlr |=3D CTLR_TPM;	/* Set mailbox number priority transmit mode */
> +	ctlr |=3D CTLR_BOM_ENT;	/* Entry to halt mode automatically */
> +				/* at bus-off */
> +	writew(ctlr, &priv->regs->ctlr);
> +
> +	writeb(priv->clock_select, &priv->regs->clkr);
> +
> +	/* Accept all SID and EID */
> +	for (n =3D 0; n < N_RX_MKREGS; n++)
> +		writel(0, &priv->regs->mkr_0_1[n]);
> +	writel(0, &priv->regs->mkivlr0);
> +
> +	/* Initial value of MIER1 undefined.  Mark all Tx mailboxes as free. =
*/
> +	writel(0, &priv->regs->mier1);
> +
> +	priv->ier =3D IER_TXMIE | IER_ERSIE | IER_RXM1IE;
> +	writeb(priv->ier, &priv->regs->ier);
> +
> +	/* Accumulate error codes */
> +	writeb(ECSR_EDPM, &priv->regs->ecsr);
> +	/* Enable error interrupts */
> +	writeb(EIER_EWIE | EIER_EPIE | EIER_BOEIE |
> +	       (priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING ?
> +	       EIER_BEIE : 0) | EIER_ORIE | EIER_OLIE,
> +	       &priv->regs->eier);
> +	/* Enable interrupts for RX mailboxes */
> +	writel(RX_MBX_MASK, &priv->regs->mier0);
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
> +	writew(ctlr, &priv->regs->ctlr);
> +	for (n =3D 0; n < FIRST_TX_MB; n++) {
> +		/* According to documentation we should clear MCTL
> +		 * register before configuring mailbox.
> +		 */
> +		writeb(0, &priv->regs->mctl[n]);
> +		writeb(MCTL_RECREQ, &priv->regs->mctl[n]);
> +		writeb(0, &priv->regs->mctl[FIRST_TX_MB + n]);
> +	}
> +	/* Go to operation mode */
> +	writew(ctlr & ~CTLR_FORCE_RESET, &priv->regs->ctlr);
> +}
> +
> +static int rcar_can_open(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv =3D netdev_priv(ndev);
> +	int err;
> +
> +	clk_prepare_enable(priv->clk);
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
> +	clk_disable_unprepare(priv->clk);
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
> +	ctlr =3D readw(&priv->regs->ctlr);
> +	ctlr |=3D  CTLR_FORCE_RESET;
> +	writew(ctlr, &priv->regs->ctlr);
> +	writel(0, &priv->regs->mier0);
> +	writel(0, &priv->regs->mier1);
> +	writeb(0, &priv->regs->ier);
> +	writeb(0, &priv->regs->eier);
> +	/* Go to sleep mode */
> +	ctlr |=3D CTLR_SLPM;
> +	writew(ctlr, &priv->regs->ctlr);
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
> +	clk_disable_unprepare(priv->clk);
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
> +	u8 mctl =3D 0;
> +
> +	if (can_dropped_invalid_skb(ndev, skb))
> +		return NETDEV_TX_OK;
> +
> +	spin_lock_irqsave(&priv->mier_lock, flags);
> +	mier1 =3D readl(&priv->regs->mier1);
> +	if (mier1) {
> +		i =3D __builtin_clz(mier1);
> +		mbxno =3D i ? N_MBX - i : FIRST_TX_MB;
> +	} else {
> +		mbxno =3D FIRST_TX_MB;
> +	}

Can you explain how the hardware arbitration works, and you do you
guarantee the CAN frames are send by the hardware in the same order you
put them into the hardware.

> +	mier1 |=3D BIT(mbxno - FIRST_TX_MB);
> +	writel(mier1, &priv->regs->mier1);
> +	spin_unlock_irqrestore(&priv->mier_lock, flags);
> +	if (unlikely(mier1 =3D=3D 0xffffffff))
> +		netif_stop_queue(ndev);
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
> +	writel(data, &priv->regs->mb[mbxno].id);
> +
> +	writeb(cf->can_dlc, &priv->regs->mb[mbxno].dlc);
> +
> +	for (i =3D 0; i < cf->can_dlc; i++)
> +		writeb(cf->data[i], &priv->regs->mb[mbxno].data[i]);
> +
> +	can_put_echo_skb(skb, ndev, mbxno - FIRST_TX_MB);
> +
> +	priv->ier |=3D IER_TXMIE;
> +	writeb(priv->ier, &priv->regs->ier);
> +
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT)
> +		mctl |=3D MCTL_ONESHOT;
> +
> +	/* Start TX */
> +	mctl |=3D MCTL_TRMREQ;
> +	writeb(mctl, &priv->regs->mctl[mbxno]);
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
> +		return;
> +	}
> +
> +	data =3D readl(&priv->regs->mb[mbx].id);
> +	if (data & RCAR_CAN_IDE)
> +		cf->can_id =3D (data & CAN_EFF_MASK) | CAN_EFF_FLAG;
> +	else
> +		cf->can_id =3D (data >> RCAR_CAN_SID_SHIFT) & CAN_SFF_MASK;
> +
> +	dlc =3D readb(&priv->regs->mb[mbx].dlc);
> +	cf->can_dlc =3D get_can_dlc(dlc);
> +	if (data & RCAR_CAN_RTR) {
> +		cf->can_id |=3D CAN_RTR_FLAG;
> +	} else {
> +		for (dlc =3D 0; dlc < cf->can_dlc; dlc++)
> +			cf->data[dlc] =3D readb(&priv->regs->mb[mbx].data[dlc]);
> +	}
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
> +	int num_pkts =3D 0;
> +
> +	/* Find mailbox */
> +	while (num_pkts < quota) {
> +		u8 mctl, mbx;
> +
> +		mbx =3D readb(&priv->regs->mssr);

How does the RX work? Is it a hardware FIFO?

> +		if (mbx & MSSR_SEST)
> +			break;
> +		mbx &=3D MSSR_MBNST;
> +		mctl =3D readb(&priv->regs->mctl[mbx]);
> +		/* Clear interrupt */
> +		writeb(mctl & ~MCTL_NEWDATA, &priv->regs->mctl[mbx]);
> +		rcar_can_rx_pkt(priv, mbx);
> +		++num_pkts;
> +	}
> +	/* All packets processed */
> +	if (num_pkts < quota) {
> +		napi_complete(napi);
> +		priv->ier |=3D IER_RXM1IE;
> +		writeb(priv->ier, &priv->regs->ier);
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
> +	clk_prepare_enable(priv->clk);
> +	bec->txerr =3D readb(&priv->regs->tecr);
> +	bec->rxerr =3D readb(&priv->regs->recr);
> +	clk_disable_unprepare(priv->clk);
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
> +	pdata =3D dev_get_platdata(&pdev->dev);
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
> +
> +	ndev->netdev_ops =3D &rcar_can_netdev_ops;
> +	ndev->irq =3D irq;
> +	ndev->flags |=3D IFF_ECHO;
> +	priv->ndev =3D ndev;
> +	priv->regs =3D addr;
> +	priv->clock_select =3D pdata->clock_select;
> +	priv->can.clock.freq =3D clk_get_rate(priv->clk);
> +	priv->can.bittiming_const =3D &rcar_can_bittiming_const;
> +	priv->can.do_set_bittiming =3D rcar_can_set_bittiming;

Please call this function directly during the open() function.

> +	priv->can.do_set_mode =3D rcar_can_do_set_mode;
> +	priv->can.do_get_berr_counter =3D rcar_can_get_berr_counter;
> +	priv->can.ctrlmode_supported =3D CAN_CTRLMODE_BERR_REPORTING |
> +				       CAN_CTRLMODE_ONE_SHOT;
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

> +		 priv->regs, ndev->irq);
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
> +
> +	unregister_candev(ndev);
> +	netif_napi_del(&priv->napi);
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
> +	ctlr =3D readw(&priv->regs->ctlr);
> +	ctlr |=3D CTLR_HALT;
> +	writew(ctlr, &priv->regs->ctlr);
> +	ctlr |=3D CTLR_SLPM;
> +	writew(ctlr, &priv->regs->ctlr);
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
> +	ctlr =3D readw(&priv->regs->ctlr);
> +	ctlr &=3D ~CTLR_SLPM;
> +	writew(ctlr, &priv->regs->ctlr);
> +	ctlr &=3D ~CTLR_FORCE_RESET;
> +	writew(ctlr, &priv->regs->ctlr);
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

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--7abDFLKbGIOcEL5EuD1Nn9rkrAFkIXeef
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlJ2rfoACgkQjTAFq1RaXHNbJgCgkf/ifcBLdziRsLkK7jdYGcbA
HuYAnRbGjRg68oiR3Ty2r/furasCGB3Z
=TydZ
-----END PGP SIGNATURE-----

--7abDFLKbGIOcEL5EuD1Nn9rkrAFkIXeef--
