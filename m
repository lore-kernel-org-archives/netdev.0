From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v2] can: add Renesas R-Car CAN driver
Date: Fri, 25 Oct 2013 21:28:27 +0200
Message-ID: <526AC65B.5020203@grandegger.com>
References: <201310250303.00695.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, mkl@pengutronix.de,
	linux-can@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201310250303.00695.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/25/2013 01:03 AM, Sergei Shtylyov wrote:
> Add support for the CAN controller found in Renesas R-Car SoCs. 
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
> The patch is against the 'linux-can-next.git' repo.
> 
> Changes in version 2:
> - added function to clean up TX mailboxes after bus error and bus-off;
> - added module parameter to enable hardware recovery from bus-off, added handler
>   for the bus-off recovery interrupt, and set the control register according to
>   the parameter value and the restart timer setting in rcar_can_start();
> - changed the way CAN_ERR_CRTL_[RT]X_{PASSIVE|WARNING} flags are set to a more
>   realicstic one;
> - replaced MBX_* macros and rcar_can_mbx_{read|write}[bl]() functions with
>   'struct rcar_can_mbox_regs', 'struct rcar_can_regs', and {read|write}[bl](),
>   replaced 'reg_base' field of 'struct rcar_can_priv' with 'struct rcar_can_regs
>   __iomem *regs';
> - added 'ier' field to 'struct rcar_can_priv' to cache the current value of the
>   interrupt enable register;
> - added a check for enabled interrupts on entry to rcar_can_interrupt();
> - limited transmit mailbox search loop in rcar_can_interrupt();
> - decoupled  TX byte count increment from can_get_echo_skb() call;
> - removed netif_queue_stopped() call from rcar_can_interrupt();
> - added clk_prepare_enable()/clk_disable_unprepare() to ndo_{open|close}(),
>   do_set_bittiming(), and do_get_berr_counter() methods, removed clk_enable()
>   call from the probe() method and clk_disable() call from the remove() method;
> - allowed rcar_can_set_bittiming() to be called when the device is closed and
>   remove  explicit call to it from rcar_can_start();
> - switched to using mailbox number priority transmit mode, and switched to the
>   sequential mailbox use in ndo_start_xmit() method;
> - stopped reading the message control registers in ndo_start_xmit() method;
> - avoided returning NETDEV_TX_BUSY from ndo_start_xmit() method;
> - stopped reading data when RTR bit is set in the CAN frame;
> - made 'num_pkts' variable *int* and moved its check to the *while* condition in
>   rcar_can_rx_poll();
> - used dev_get_platdata() in the probe() method;
> - enabled bus error interrupt only if CAN_CTRLMODE_BERR_REPORTING flag is set;
> - started reporting CAN_CTRLMODE_BERR_REPORTING support and stopped reporting
>   CAN_CTRLMODE_3_SAMPLES support;
> - set CAN_ERR_ACK flag on ACK error;
> - switched to incrementing bus error counter only once per bus error interrupt;
> - started switching to CAN sleep mode in rcar_can_stop() and stopped switching
>   to it in the remove() method;
> - removed netdev_err() calls on allocation failure in rcar_can_error() and
>   rcar_can_rx_pkt();
> - removed "CANi" from the register offset macro comments.
> 
>  drivers/net/can/Kconfig               |    9 
>  drivers/net/can/Makefile              |    1 
>  drivers/net/can/rcar_can.c            |  920 ++++++++++++++++++++++++++++++++++
>  include/linux/can/platform/rcar_can.h |   15 
>  4 files changed, 945 insertions(+)
> 
> Index: linux-can-next/drivers/net/can/Kconfig
> ===================================================================
> --- linux-can-next.orig/drivers/net/can/Kconfig
> +++ linux-can-next/drivers/net/can/Kconfig
> @@ -125,6 +125,15 @@ config CAN_GRCAN
>  	  endian syntheses of the cores would need some modifications on
>  	  the hardware level to work.
>  
> +config CAN_RCAR
> +	tristate "Renesas R-Car CAN controller"
> +	---help---
> +	  Say Y here if you want to use CAN controller found on Renesas R-Car
> +	  SoCs.
> +
> +	  To compile this driver as a module, choose M here: the module will
> +	  be called rcar_can.
> +
>  source "drivers/net/can/mscan/Kconfig"
>  
>  source "drivers/net/can/sja1000/Kconfig"
> Index: linux-can-next/drivers/net/can/Makefile
> ===================================================================
> --- linux-can-next.orig/drivers/net/can/Makefile
> +++ linux-can-next/drivers/net/can/Makefile
> @@ -25,5 +25,6 @@ obj-$(CONFIG_CAN_JANZ_ICAN3)	+= janz-ica
>  obj-$(CONFIG_CAN_FLEXCAN)	+= flexcan.o
>  obj-$(CONFIG_PCH_CAN)		+= pch_can.o
>  obj-$(CONFIG_CAN_GRCAN)		+= grcan.o
> +obj-$(CONFIG_CAN_RCAR)		+= rcar_can.o
>  
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
> Index: linux-can-next/drivers/net/can/rcar_can.c
> ===================================================================
> --- /dev/null
> +++ linux-can-next/drivers/net/can/rcar_can.c
> @@ -0,0 +1,920 @@
> +/*
> + * Renesas R-Car CAN device driver
> + *
> + * Copyright (C) 2013 Cogent Embedded, Inc. <source@cogentembedded.com>
> + * Copyright (C) 2013 Renesas Solutions Corp.
> + *
> + * This program is free software; you can redistribute  it and/or modify it
> + * under  the terms of  the GNU General  Public License as published by the
> + * Free Software Foundation;  either version 2 of the  License, or (at your
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
> +#define RCAR_CAN_MIER1	0x42C	/* Mailbox Interrupt Enable Register 1 */
> +#define RCAR_CAN_MKR(n)	((n) < 2 ? 0x430 + 4 * (n) : 0x400 + 4 * ((n) - 2))
> +				/* Mask Register */
> +#define RCAR_CAN_MKIVLR0 0x438	/* Mask Invalid Register 0 */
> +#define RCAR_CAN_MIER0	 0x43C	/* Mailbox Interrupt Enable Register 0 */
> +
> +#define RCAR_CAN_MCTL(n) (0x800 + (n)) /* Message Control Register */
> +#define RCAR_CAN_CTLR	0x840	/* Control Register */
> +#define RCAR_CAN_STR	0x842	/* Status Register */
> +#define RCAR_CAN_BCR	0x844	/* Bit Configuration Register */
> +#define RCAR_CAN_CLKR	0x847	/* Clock Select Register */
> +#define RCAR_CAN_EIER	0x84C	/* Error Interrupt Enable Register */
> +#define RCAR_CAN_EIFR	0x84D	/* Err Interrupt Factor Judge Register */
> +#define RCAR_CAN_RECR	0x84E	/* Receive Error Count Register */
> +#define RCAR_CAN_TECR	0x84F	/* Transmit Error Count Register */
> +#define RCAR_CAN_ECSR	0x850	/* Error Code Store Register */
> +#define RCAR_CAN_MSSR	0x852	/* Mailbox Search Status Register */
> +#define RCAR_CAN_MSMR	0x853	/* Mailbox Search Mode Register */
> +#define RCAR_CAN_TCR	0x858	/* Test Control Register */
> +#define RCAR_CAN_IER	0x860	/* Interrupt Enable Register */
> +#define RCAR_CAN_ISR	0x861	/* Interrupt Status Register */
> +
> +/* Control Register bits */
> +#define CTLR_BOM	(3 << 11) /* Bus-Off Recovery Mode Bits */
> +#define CTLR_BOM_ENT	BIT(11)	/* Entry to halt mode at bus-off entry */
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
> +#define ISR_TXMF	BIT(0)	/* Mailbox 32 to 63 Successful Transmission */
> +				/* (TXM) Interrupt Status Bit */
> +
> +/* Error Interrupt Enable Register bits */
> +#define EIER_BLIE	BIT(7)	/* Bus Lock Interrupt Enable */
> +#define EIER_OLIE	BIT(6)	/* Overload Frame Transmit Interrupt Enable */
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
> +#define EIFR_OLIF	BIT(6)	/* Overload Frame Transmission Detect Flag */
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
> +#define MSSR_MBNST	0x3f	/* Search Result Mailbox Number Status mask */
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
> +#define N_TX_MB		(N_MBX - FIRST_TX_MB)
> +#define RX_MBX_MASK	0xFFFFFFFE
> +
> +#define RCAR_CAN_NAPI_WEIGHT (FIRST_TX_MB - 1)
> +
> +static bool autorecovery;
> +module_param(autorecovery, bool, 0644);
> +MODULE_PARM_DESC(autorecovery, "Automatic hardware recovery from bus-off");

Software recovery is the preferred solution. No need to support
automatic recovery by the hardware.

> +
> +/* Mailbox registers structure */
> +struct rcar_can_mbox_regs {
> +	u32 id;		/* IDE and RTR bits, SID and EID */
> +	u8 stub;	/* Not used */
> +	u8 dlc;		/* Data Length Code - bits [0..3] */
> +	u8 data[8];	/* Data Bytes */
> +	u8 tsh;		/* Time Stamp Higher Byte */
> +	u8 tsl;		/* Time Stamp Lower Byte */

I would add padding bytes here to ensure alignment.

> +};
> +
> +struct rcar_can_regs {
> +	struct rcar_can_mbox_regs mb[N_MBX];
> +};

Where are the other registers? Using a mix of struct and #define offsets
is really ugly.

> +struct rcar_can_priv {
> +	struct can_priv can;	/* Must be the first member! */
> +	struct net_device *ndev;
> +	struct napi_struct napi;
> +	struct rcar_can_regs __iomem *regs;
> +	struct clk *clk;
> +	spinlock_t mier_lock;
> +	u8 clock_select;
> +	u8 ier;

s/ier/ier_shadow/ ?

> +};
> +
> +static const struct can_bittiming_const rcar_can_bittiming_const = {
> +	.name = DRV_NAME,
> +	.tseg1_min = 4,
> +	.tseg1_max = 16,
> +	.tseg2_min = 2,
> +	.tseg2_max = 8,
> +	.sjw_max = 4,
> +	.brp_min = 1,
> +	.brp_max = 1024,
> +	.brp_inc = 1,
> +};
> +
> +static inline u32 rcar_can_readl(struct rcar_can_priv *priv, int reg)
> +{
> +	return readl((void __iomem *)priv->regs + reg);
> +}
> +
> +static inline u16 rcar_can_readw(struct rcar_can_priv *priv, int reg)
> +{
> +	return readw((void __iomem *)priv->regs + reg);
> +}
> +
> +static inline u8 rcar_can_readb(struct rcar_can_priv *priv, int reg)
> +{
> +	return readb((void __iomem *)priv->regs + reg);
> +}
> +
> +static inline void rcar_can_writel(struct rcar_can_priv *priv, int reg, u32 val)
> +{
> +	writel(val, (void __iomem *)priv->regs + reg);
> +}
> +
> +static inline void rcar_can_writew(struct rcar_can_priv *priv, int reg, u16 val)
> +{
> +	writew(val, (void __iomem *)priv->regs + reg);
> +}
> +
> +static inline void rcar_can_writeb(struct rcar_can_priv *priv, int reg, u8 val)
> +{
> +	writeb(val, (void __iomem *)priv->regs + reg);
> +}

See my comment above.

> +static void tx_failure_cleanup(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv = netdev_priv(ndev);
> +	u32 mier1;
> +	u8 mbx;
> +
> +	spin_lock(&priv->mier_lock);
> +	mier1 = rcar_can_readl(priv, RCAR_CAN_MIER1);
> +	for (mbx = FIRST_TX_MB; mbx < N_MBX; mbx++) {
> +		if (mier1 & BIT(mbx - FIRST_TX_MB)) {
> +			rcar_can_writeb(priv, RCAR_CAN_MCTL(mbx), 0);
> +			can_free_echo_skb(ndev, mbx - FIRST_TX_MB);
> +		}
> +	}
> +	rcar_can_writel(priv, RCAR_CAN_MIER1, 0);
> +	spin_unlock(&priv->mier_lock);
> +}
> +
> +static void rcar_can_start(struct net_device *ndev);

Forward declarations should be avoided.

> +
> +static void rcar_can_error(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv = netdev_priv(ndev);
> +	struct net_device_stats *stats = &ndev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	u8 eifr, txerr = 0, rxerr = 0;
> +
> +	/* Propagate the error condition to the CAN stack */
> +	skb = alloc_can_err_skb(ndev, &cf);
> +	if (!skb)
> +		return;
> +	eifr = rcar_can_readb(priv, RCAR_CAN_EIFR);
> +	if (eifr & (EIFR_EWIF | EIFR_EPIF)) {
> +		cf->can_id |= CAN_ERR_CRTL;
> +		txerr = rcar_can_readb(priv, RCAR_CAN_TECR);
> +		rxerr = rcar_can_readb(priv, RCAR_CAN_RECR);

Could you please add these values to data[6..7] as shown here:

http://lxr.free-electrons.com/source/drivers/net/can/sja1000/sja1000.c#L475

> +	}
> +	if (eifr & EIFR_BEIF) {
> +		int rx_errors = 0, tx_errors = 0;
> +		u8 ecsr;
> +
> +		if (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT)
> +			tx_failure_cleanup(ndev);
> +		netdev_dbg(priv->ndev, "Bus error interrupt:\n");
> +		cf->can_id |= CAN_ERR_BUSERROR | CAN_ERR_PROT;
> +		cf->data[2] = CAN_ERR_PROT_UNSPEC;
> +
> +		ecsr = rcar_can_readb(priv, RCAR_CAN_ECSR);
> +		if (ecsr & ECSR_ADEF) {
> +			netdev_dbg(priv->ndev, "ACK Delimiter Error\n");
> +			cf->data[3] |= CAN_ERR_PROT_LOC_ACK_DEL;
> +			tx_errors++;
> +			rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_ADEF);

Please avoid casts here and below.

> +		}
> +		if (ecsr & ECSR_BE0F) {
> +			netdev_dbg(priv->ndev, "Bit Error (dominant)\n");
> +			cf->data[2] |= CAN_ERR_PROT_BIT0;
> +			tx_errors++;
> +			rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_BE0F);
> +		}
> +		if (ecsr & ECSR_BE1F) {
> +			netdev_dbg(priv->ndev, "Bit Error (recessive)\n");
> +			cf->data[2] |= CAN_ERR_PROT_BIT1;
> +			tx_errors++;
> +			rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_BE1F);
> +		}
> +		if (ecsr & ECSR_CEF) {
> +			netdev_dbg(priv->ndev, "CRC Error\n");
> +			cf->data[3] |= CAN_ERR_PROT_LOC_CRC_SEQ;
> +			rx_errors++;
> +			rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_CEF);
> +		}
> +		if (ecsr & ECSR_AEF) {
> +			netdev_dbg(priv->ndev, "ACK Error\n");
> +			cf->can_id |= CAN_ERR_ACK;
> +			cf->data[3] |= CAN_ERR_PROT_LOC_ACK;
> +			tx_errors++;
> +			rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_AEF);
> +		}
> +		if (ecsr & ECSR_FEF) {
> +			netdev_dbg(priv->ndev, "Form Error\n");
> +			cf->data[2] |= CAN_ERR_PROT_FORM;
> +			rx_errors++;
> +			rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_FEF);
> +		}
> +		if (ecsr & ECSR_SEF) {
> +			netdev_dbg(priv->ndev, "Stuff Error\n");
> +			cf->data[2] |= CAN_ERR_PROT_STUFF;
> +			rx_errors++;
> +			rcar_can_writeb(priv, RCAR_CAN_ECSR, (u8)~ECSR_SEF);
> +		}
> +
> +		priv->can.can_stats.bus_error++;
> +		ndev->stats.rx_errors += rx_errors;
> +		ndev->stats.tx_errors += tx_errors;
> +		rcar_can_writeb(priv, RCAR_CAN_EIFR, (u8)~EIFR_BEIF);
> +	}
> +	if (eifr & EIFR_EWIF) {
> +		netdev_dbg(priv->ndev, "Error warning interrupt\n");
> +		priv->can.state = CAN_STATE_ERROR_WARNING;
> +		priv->can.can_stats.error_warning++;
> +		cf->data[1] |= txerr > rxerr ? CAN_ERR_CRTL_TX_WARNING :
> +					       CAN_ERR_CRTL_RX_WARNING;
> +		/* Clear interrupt condition */
> +		rcar_can_writeb(priv, RCAR_CAN_EIFR, (u8)~EIFR_EWIF);
> +	}
> +	if (eifr & EIFR_EPIF) {
> +		netdev_dbg(priv->ndev, "Error passive interrupt\n");
> +		priv->can.state = CAN_STATE_ERROR_PASSIVE;
> +		priv->can.can_stats.error_passive++;
> +		cf->data[1] |= txerr > rxerr ? CAN_ERR_CRTL_TX_PASSIVE :
> +					       CAN_ERR_CRTL_RX_PASSIVE;
> +		/* Clear interrupt condition */
> +		rcar_can_writeb(priv, RCAR_CAN_EIFR, (u8)~EIFR_EPIF);
> +	}
> +	if (eifr & EIFR_BOEIF) {
> +		netdev_dbg(priv->ndev, "Bus-off entry interrupt\n");
> +		tx_failure_cleanup(ndev);
> +		priv->ier = IER_ERSIE;
> +		rcar_can_writeb(priv, RCAR_CAN_IER, priv->ier);
> +		priv->can.state = CAN_STATE_BUS_OFF;
> +		cf->can_id |= CAN_ERR_BUSOFF;
> +		/* Clear interrupt condition */
> +		rcar_can_writeb(priv, RCAR_CAN_EIFR, (u8)~EIFR_BOEIF);
> +		can_bus_off(ndev);
> +	}

You should not call this function in case of automatic recovery. Anyway,
as suggested above there is no need to support automatic recovery.

> +	if (eifr & EIFR_BORIF) {
> +		netdev_dbg(priv->ndev, "Bus-off recovery interrupt\n");
> +		priv->can.state = CAN_STATE_ERROR_ACTIVE;
> +		cf->can_id |= CAN_ERR_RESTARTED;

Does this interrupt come when Bus-off recovery has compeleted (back to
error-active?) CAN_ERR_RESTARTED should be reported when the bus-off
recovery has been triggered. It takes some time before it is really
completed.

> +		rcar_can_start(priv->ndev);
> +		priv->can.can_stats.restarts++;
> +		netif_carrier_on(ndev);
> +		netif_wake_queue(ndev);
> +	}
> +	if (eifr & EIFR_ORIF) {
> +		netdev_dbg(priv->ndev, "Receive overrun error interrupt\n");
> +		cf->can_id |= CAN_ERR_CRTL;
> +		cf->data[1] |= CAN_ERR_CRTL_RX_OVERFLOW;
> +		ndev->stats.rx_over_errors++;
> +		ndev->stats.rx_errors++;
> +		rcar_can_writeb(priv, RCAR_CAN_EIFR, (u8)~EIFR_ORIF);
> +	}
> +	if (eifr & EIFR_OLIF) {
> +		netdev_dbg(priv->ndev,
> +			   "Overload Frame Transmission error interrupt\n");
> +		cf->can_id |= CAN_ERR_PROT;
> +		cf->data[2] |= CAN_ERR_PROT_OVERLOAD;
> +		ndev->stats.rx_over_errors++;
> +		ndev->stats.rx_errors++;
> +		rcar_can_writeb(priv, RCAR_CAN_EIFR, (u8)~EIFR_OLIF);

No unnecessary casts please.

> +	}
> +
> +	netif_rx(skb);
> +	stats->rx_packets++;
> +	stats->rx_bytes += cf->can_dlc;
> +}
> +
> +static irqreturn_t rcar_can_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *ndev = (struct net_device *)dev_id;
> +	struct rcar_can_priv *priv = netdev_priv(ndev);
> +	struct net_device_stats *stats = &ndev->stats;
> +	u8 isr;
> +
> +	isr = rcar_can_readb(priv, RCAR_CAN_ISR);
> +	if (!(isr & priv->ier))
> +		return IRQ_NONE;
> +
> +	if (isr & ISR_ERSF)
> +		rcar_can_error(ndev);
> +
> +	if (isr & ISR_TXMF) {
> +		u32 ie_mask = 0;
> +		int i;
> +
> +		/* Set Transmit Mailbox Search Mode */
> +		rcar_can_writeb(priv, RCAR_CAN_MSMR, MSMR_TXMB);
> +		for (i = 0; i < N_TX_MB; i++) {
> +			u8 mctl, mbx;
> +
> +			mbx = rcar_can_readb(priv, RCAR_CAN_MSSR);
> +			if (mbx & MSSR_SEST)
> +				break;
> +			mbx &= MSSR_MBNST;
> +			stats->tx_bytes += readb(&priv->regs->mb[mbx].dlc);
> +			stats->tx_packets++;
> +			mctl = rcar_can_readb(priv, RCAR_CAN_MCTL(mbx));
> +			/* Bits SENTDATA and TRMREQ cannot be
> +			 * set to 0 simultaneously
> +			 */
> +			mctl &= ~MCTL_TRMREQ;
> +			rcar_can_writeb(priv, RCAR_CAN_MCTL(mbx), mctl);
> +			mctl &= ~MCTL_SENTDATA;
> +			/* Clear interrupt */
> +			rcar_can_writeb(priv, RCAR_CAN_MCTL(mbx), mctl);
> +			ie_mask |= BIT(mbx - FIRST_TX_MB);
> +			can_get_echo_skb(ndev, mbx - FIRST_TX_MB);
> +			can_led_event(ndev, CAN_LED_EVENT_TX);
> +		}
> +		/* Set receive mailbox search mode */
> +		rcar_can_writeb(priv, RCAR_CAN_MSMR, MSMR_RXMB);
> +		/* Disable mailbox interrupt, mark mailbox as free */
> +		if (ie_mask) {
> +			u32 mier1;
> +
> +			spin_lock(&priv->mier_lock);
> +			mier1 = rcar_can_readl(priv, RCAR_CAN_MIER1);
> +			rcar_can_writel(priv, RCAR_CAN_MIER1, mier1 & ~ie_mask);
> +			spin_unlock(&priv->mier_lock);
> +			netif_wake_queue(ndev);
> +		}
> +	}

Would be nice to have this in an (inline) function, like for the error
handling above.

> +	if (isr & ISR_RXM1F) {
> +		if (napi_schedule_prep(&priv->napi)) {
> +			/* Disable Rx interrupts */
> +			priv->ier &= ~IER_RXM1IE;
> +			rcar_can_writeb(priv, RCAR_CAN_IER, priv->ier);
> +			__napi_schedule(&priv->napi);
> +		}
> +	}
> +	return IRQ_HANDLED;
> +}
> +
> +static int rcar_can_set_bittiming(struct net_device *dev)
> +{
> +	struct rcar_can_priv *priv = netdev_priv(dev);
> +	struct can_bittiming *bt = &priv->can.bittiming;
> +	u32 bcr;
> +	u16 ctlr;
> +	u8 clkr;
> +
> +	clk_prepare_enable(priv->clk);
> +	/* rcar_can_set_bittiming() is called in CAN sleep mode.
> +	 * Can write to BCR  in CAN reset mode or CAN halt mode.
> +	 * Cannot write to CLKR in halt mode, so go to reset mode.
> +	 */
> +	ctlr = rcar_can_readw(priv, RCAR_CAN_CTLR);
> +	ctlr &= ~CTLR_SLPM;
> +	ctlr |= CTLR_FORCE_RESET;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	/* Don't overwrite CLKR with 32-bit BCR access */
> +	/* CLKR has 8-bit access */
> +	clkr = rcar_can_readb(priv, RCAR_CAN_CLKR);
> +	bcr = BCR_TSEG1(bt->phase_seg1 + bt->prop_seg - 1) |
> +	      BCR_BPR(bt->brp - 1) | BCR_SJW(bt->sjw - 1) |
> +	      BCR_TSEG2(bt->phase_seg2 - 1);
> +	rcar_can_writel(priv, RCAR_CAN_BCR, bcr);
> +	rcar_can_writeb(priv, RCAR_CAN_CLKR, clkr);
> +	ctlr |= CTLR_SLPM;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	clk_disable_unprepare(priv->clk);
> +	return 0;
> +}
> +
> +static void rcar_can_start(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv = netdev_priv(ndev);
> +	u16 ctlr, n;
> +
> +	/* Set controller to known mode:
> +	 * - normal mailbox mode (no FIFO);
> +	 * - accept all messages (no filter).
> +	 * CAN is in sleep mode after MCU hardware or software reset.
> +	 */
> +	ctlr = rcar_can_readw(priv, RCAR_CAN_CTLR);
> +	ctlr &= ~CTLR_SLPM;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	/* Go to reset mode */
> +	ctlr |= CTLR_FORCE_RESET;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	ctlr |= CTLR_IDFM_MIXED; /* Select mixed ID mode */
> +	ctlr |= CTLR_TPM;	/* Set mailbox number priority transmit mode */
> +	ctlr &= ~CTLR_BOM;	/* Automatic recovery */
> +				/* compliant with ISO11898-1 */
> +	if (!autorecovery || priv->can.restart_ms)
> +		ctlr |= CTLR_BOM_ENT;	/* Entry to halt mode automatically */
> +					/* at bus-off */
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +
> +	rcar_can_writeb(priv, RCAR_CAN_CLKR, priv->clock_select);
> +
> +	/* Accept all SID and EID */
> +	for (n = 0; n < N_RX_MKREGS; n++)
> +		rcar_can_writel(priv, RCAR_CAN_MKR(n), 0);
> +	rcar_can_writel(priv, RCAR_CAN_MKIVLR0, 0);
> +
> +	/* Initial value of MIER1 undefined.  Mark all Tx mailboxes as free. */
> +	rcar_can_writel(priv, RCAR_CAN_MIER1, 0);
> +
> +	priv->ier = IER_TXMIE | IER_ERSIE | IER_RXM1IE;
> +	rcar_can_writeb(priv, RCAR_CAN_IER, priv->ier);
> +
> +	/* Accumulate error codes */
> +	rcar_can_writeb(priv, RCAR_CAN_ECSR, ECSR_EDPM);
> +	/* Enable error interrupts */
> +	rcar_can_writeb(priv, RCAR_CAN_EIER,
> +			EIER_EWIE | EIER_EPIE | EIER_BOEIE |
> +			(priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING ?
> +			EIER_BEIE : 0) | EIER_ORIE | EIER_OLIE | EIER_BORIE);
> +	/* Enable interrupts for RX mailboxes */
> +	rcar_can_writel(priv, RCAR_CAN_MIER0, RX_MBX_MASK);
> +	priv->can.state = CAN_STATE_ERROR_ACTIVE;
> +
> +	/* Write to the CiMCTLj register in CAN
> +	 * operation mode or CAN halt mode.
> +	 * Configure mailboxes 0-31 as Rx mailboxes.
> +	 * Configure mailboxes 32-63 as Tx mailboxes.
> +	 */
> +	/* Go to halt mode */
> +	ctlr |= CTLR_HALT;
> +	ctlr &= ~CTLR_RESET;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	for (n = 0; n < FIRST_TX_MB; n++) {
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
> +	struct rcar_can_priv *priv = netdev_priv(ndev);
> +	int err;
> +
> +	clk_prepare_enable(priv->clk);
> +	err = open_candev(ndev);
> +	if (err) {
> +		netdev_err(ndev, "open_candev() failed %d\n", err);
> +		goto out;
> +	}
> +	napi_enable(&priv->napi);
> +	err = request_irq(ndev->irq, rcar_can_interrupt, 0, ndev->name, ndev);
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
> +	struct rcar_can_priv *priv = netdev_priv(ndev);
> +	u16 ctlr;
> +
> +	/* Go to (force) reset mode */
> +	ctlr = rcar_can_readw(priv, RCAR_CAN_CTLR);
> +	ctlr |=  CTLR_FORCE_RESET;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	rcar_can_writel(priv, RCAR_CAN_MIER0, 0);
> +	rcar_can_writel(priv, RCAR_CAN_MIER1, 0);
> +	rcar_can_writeb(priv, RCAR_CAN_IER, 0);
> +	rcar_can_writeb(priv, RCAR_CAN_EIER, 0);
> +	/* Go to sleep mode */
> +	ctlr |= CTLR_SLPM;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	priv->can.state = CAN_STATE_STOPPED;
> +}
> +
> +static int rcar_can_close(struct net_device *ndev)
> +{
> +	struct rcar_can_priv *priv = netdev_priv(ndev);
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
> +	struct rcar_can_priv *priv = netdev_priv(ndev);
> +	struct can_frame *cf = (struct can_frame *)skb->data;
> +	u32 data, mier1, mbxno, i;
> +	unsigned long flags;
> +	u8 mctl = 0;
> +
> +	if (can_dropped_invalid_skb(ndev, skb))
> +		return NETDEV_TX_OK;
> +
> +	spin_lock_irqsave(&priv->mier_lock, flags);
> +	mier1 = rcar_can_readl(priv, RCAR_CAN_MIER1);
> +	if (mier1) {
> +		i = __builtin_clz(mier1);
> +		mbxno = i ? N_MBX - i : FIRST_TX_MB;
> +	} else {
> +		mbxno = FIRST_TX_MB;
> +	}
> +	mier1 |= BIT(mbxno - FIRST_TX_MB);
> +	rcar_can_writel(priv, RCAR_CAN_MIER1, mier1);
> +	spin_unlock_irqrestore(&priv->mier_lock, flags);
> +	if (unlikely(mier1 == 0xffffffff))
> +		netif_stop_queue(ndev);
> +
> +	if (cf->can_id & CAN_EFF_FLAG) {
> +		/* Extended frame format */
> +		data = (cf->can_id & CAN_EFF_MASK) | RCAR_CAN_IDE;
> +	} else {
> +		/* Standard frame format */
> +		data = (cf->can_id & CAN_SFF_MASK) << RCAR_CAN_SID_SHIFT;
> +	}
> +	if (cf->can_id & CAN_RTR_FLAG) {
> +		/* Remote transmission request */
> +		data |= RCAR_CAN_RTR;
> +	}
> +	writel(data, &priv->regs->mb[mbxno].id);
> +
> +	writeb(cf->can_dlc, &priv->regs->mb[mbxno].dlc);
> +
> +	for (i = 0; i < cf->can_dlc; i++)
> +		writeb(cf->data[i], &priv->regs->mb[mbxno].data[i]);
> +
> +	can_put_echo_skb(skb, ndev, mbxno - FIRST_TX_MB);
> +
> +	priv->ier |= IER_TXMIE;
> +	rcar_can_writeb(priv, RCAR_CAN_IER, priv->ier);
> +
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT)
> +		mctl |= MCTL_ONESHOT;
> +
> +	/* Start TX */
> +	mctl |= MCTL_TRMREQ;
> +	rcar_can_writeb(priv, RCAR_CAN_MCTL(mbxno), mctl);
> +	return NETDEV_TX_OK;
> +}
> +
> +static const struct net_device_ops rcar_can_netdev_ops = {
> +	.ndo_open = rcar_can_open,
> +	.ndo_stop = rcar_can_close,
> +	.ndo_start_xmit = rcar_can_start_xmit,
> +};
> +
> +static void rcar_can_rx_pkt(struct rcar_can_priv *priv, int mbx)
> +{
> +	struct net_device_stats *stats = &priv->ndev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	u32 data;
> +	u8 dlc;
> +
> +	skb = alloc_can_skb(priv->ndev, &cf);
> +	if (!skb) {
> +		stats->rx_dropped++;
> +		return;
> +	}
> +
> +	data = readl(&priv->regs->mb[mbx].id);
> +	if (data & RCAR_CAN_IDE)
> +		cf->can_id = (data & CAN_EFF_MASK) | CAN_EFF_FLAG;
> +	else
> +		cf->can_id = (data >> RCAR_CAN_SID_SHIFT) & CAN_SFF_MASK;
> +
> +	dlc = readb(&priv->regs->mb[mbx].dlc);
> +	cf->can_dlc = get_can_dlc(dlc);
> +	if (data & RCAR_CAN_RTR) {
> +		cf->can_id |= CAN_RTR_FLAG;
> +	} else {
> +		for (dlc = 0; dlc < cf->can_dlc; dlc++)
> +			cf->data[dlc] = readb(&priv->regs->mb[mbx].data[dlc]);
> +	}
> +
> +	can_led_event(priv->ndev, CAN_LED_EVENT_RX);
> +
> +	netif_receive_skb(skb);
> +	stats->rx_bytes += cf->can_dlc;
> +	stats->rx_packets++;
> +}
> +
> +static int rcar_can_rx_poll(struct napi_struct *napi, int quota)
> +{
> +	struct rcar_can_priv *priv = container_of(napi,
> +						  struct rcar_can_priv, napi);
> +	int num_pkts = 0;
> +
> +	/* Find mailbox */
> +	while (num_pkts < quota) {
> +		u8 mctl, mbx;
> +
> +		mbx = rcar_can_readb(priv, RCAR_CAN_MSSR);
> +		if (mbx & MSSR_SEST)
> +			break;
> +		mbx &= MSSR_MBNST;
> +		mctl = rcar_can_readb(priv, RCAR_CAN_MCTL(mbx));
> +		/* Clear interrupt */
> +		rcar_can_writeb(priv, RCAR_CAN_MCTL(mbx),
> +				mctl & ~MCTL_NEWDATA);
> +		rcar_can_rx_pkt(priv, mbx);
> +		++num_pkts;
> +	}
> +	/* All packets processed */
> +	if (num_pkts < quota) {
> +		napi_complete(napi);
> +		priv->ier |= IER_RXM1IE;
> +		rcar_can_writeb(priv, RCAR_CAN_IER, priv->ier);
> +	}
> +	return num_pkts;
> +}
> +
> +static int rcar_can_do_set_mode(struct net_device *ndev, enum can_mode mode)
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
> +	struct rcar_can_priv *priv = netdev_priv(dev);
> +
> +	clk_prepare_enable(priv->clk);
> +	bec->txerr = rcar_can_readb(priv, RCAR_CAN_TECR);
> +	bec->rxerr = rcar_can_readb(priv, RCAR_CAN_RECR);
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
> +	int err = -ENODEV;
> +	int irq;
> +
> +	pdata = dev_get_platdata(&pdev->dev);
> +	if (!pdata) {
> +		dev_err(&pdev->dev, "No platform data provided!\n");
> +		goto fail;
> +	}
> +
> +	irq = platform_get_irq(pdev, 0);
> +	if (!irq) {
> +		dev_err(&pdev->dev, "No IRQ resource\n");
> +		goto fail;
> +	}
> +
> +	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	addr = devm_ioremap_resource(&pdev->dev, mem);
> +	if (IS_ERR(addr)) {
> +		err = PTR_ERR(addr);
> +		goto fail;
> +	}
> +
> +	ndev = alloc_candev(sizeof(struct rcar_can_priv), N_MBX - FIRST_TX_MB);
> +	if (!ndev) {
> +		dev_err(&pdev->dev, "alloc_candev failed\n");
> +		err = -ENOMEM;
> +		goto fail;
> +	}
> +
> +	priv = netdev_priv(ndev);
> +
> +	priv->clk = devm_clk_get(&pdev->dev, NULL);
> +	if (IS_ERR(priv->clk)) {
> +		err = PTR_ERR(priv->clk);
> +		dev_err(&pdev->dev, "cannot get clock: %d\n", err);
> +		goto fail_clk;
> +	}
> +
> +	ndev->netdev_ops = &rcar_can_netdev_ops;
> +	ndev->irq = irq;
> +	ndev->flags |= IFF_ECHO;
> +	priv->ndev = ndev;
> +	priv->regs = (struct rcar_can_regs *)addr;

Is this cast needed?

> +	priv->clock_select = pdata->clock_select;
> +	priv->can.clock.freq = clk_get_rate(priv->clk);
> +	priv->can.bittiming_const = &rcar_can_bittiming_const;
> +	priv->can.do_set_bittiming = rcar_can_set_bittiming;
> +	priv->can.do_set_mode = rcar_can_do_set_mode;
> +	priv->can.do_get_berr_counter = rcar_can_get_berr_counter;
> +	priv->can.ctrlmode_supported = CAN_CTRLMODE_BERR_REPORTING |
> +				       CAN_CTRLMODE_ONE_SHOT;
> +	platform_set_drvdata(pdev, ndev);
> +	SET_NETDEV_DEV(ndev, &pdev->dev);
> +	spin_lock_init(&priv->mier_lock);
> +
> +	netif_napi_add(ndev, &priv->napi, rcar_can_rx_poll,
> +		       RCAR_CAN_NAPI_WEIGHT);
> +	err = register_candev(ndev);
> +	if (err) {
> +		dev_err(&pdev->dev, "register_candev() failed\n");
> +		goto fail_candev;
> +	}
> +
> +	devm_can_led_init(ndev);
> +
> +	dev_info(&pdev->dev, "device registered (reg_base=%p, irq=%u)\n",
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
> +	struct net_device *ndev = platform_get_drvdata(pdev);
> +	struct rcar_can_priv *priv = netdev_priv(ndev);
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
> +	struct net_device *ndev = dev_get_drvdata(dev);
> +	struct rcar_can_priv *priv = netdev_priv(ndev);
> +	u16 ctlr;
> +
> +	if (netif_running(ndev)) {
> +		netif_stop_queue(ndev);
> +		netif_device_detach(ndev);
> +	}
> +	ctlr = rcar_can_readw(priv, RCAR_CAN_CTLR);
> +	ctlr |= CTLR_HALT;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	ctlr |= CTLR_SLPM;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	priv->can.state = CAN_STATE_SLEEPING;
> +
> +	clk_disable(priv->clk);
> +	return 0;
> +}
> +
> +static int rcar_can_resume(struct device *dev)
> +{
> +	struct net_device *ndev = dev_get_drvdata(dev);
> +	struct rcar_can_priv *priv = netdev_priv(ndev);
> +	u16 ctlr;
> +
> +	clk_enable(priv->clk);
> +
> +	ctlr = rcar_can_readw(priv, RCAR_CAN_CTLR);
> +	ctlr &= ~CTLR_SLPM;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	ctlr &= ~CTLR_FORCE_RESET;
> +	rcar_can_writew(priv, RCAR_CAN_CTLR, ctlr);
> +	priv->can.state = CAN_STATE_ERROR_ACTIVE;
> +
> +	if (netif_running(ndev)) {
> +		netif_device_attach(ndev);
> +		netif_start_queue(ndev);
> +	}
> +	return 0;
> +}
> +#endif
> +
> +static SIMPLE_DEV_PM_OPS(rcar_can_pm_ops, rcar_can_suspend, rcar_can_resume);
> +
> +static struct platform_driver rcar_can_driver = {
> +	.driver = {
> +		.name = DRV_NAME,
> +		.owner = THIS_MODULE,
> +		.pm = &rcar_can_pm_ops,
> +	},
> +	.probe = rcar_can_probe,
> +	.remove = rcar_can_remove,
> +};
> +
> +module_platform_driver(rcar_can_driver);
> +
> +MODULE_AUTHOR("Cogent Embedded, Inc.");
> +MODULE_LICENSE("GPL");
> +MODULE_DESCRIPTION("CAN driver for Renesas R-Car SoC");
> +MODULE_ALIAS("platform:" DRV_NAME);
> Index: linux-can-next/include/linux/can/platform/rcar_can.h
> ===================================================================
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

Wolfgang.

