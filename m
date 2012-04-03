From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] ARM: OMAP: AM33XX: CAN: d_can: Add support for Bosch
 D_CAN controller
Date: Tue, 03 Apr 2012 14:44:55 +0200
Message-ID: <4F7AF0C7.7020506@grandegger.com>
References: <1333456339-9372-1-git-send-email-anilkumar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: socketcan@hartkopp.net, m.kleine-budde@pengutronix.de,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	anantgole@ti.com, nsekhar@ti.com
To: AnilKumar Ch <anilkumar@ti.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1333456339-9372-1-git-send-email-anilkumar@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/03/2012 02:32 PM, AnilKumar Ch wrote:
> This patch adds the support for Bosch D_CAN controller.
> 
> Bosch D_CAN controller is a full-CAN implementation compliant to
> CAN protocol version 2.0 part A and B. Bosch D_CAN user manual
> can be obtained from: http://www.semiconductors.bosch.de/media/
> en/pdf/ipmodules_1/can/d_can_users_manual_111.pdf
> 
> D_CAN device is used on many SoCs like AM335x, DM8148 and DM813x
> EVMs from TI, D_CAN details on AM335x can be accessed from:
> http://www.ti.com/lit/ug/spruh73c/spruh73c.pdf
> 
> D_CAN can be configurable for 16, 32, 64 and 128 message objects.
> The driver implementation is based on 64 message objects.
> 
> Following are the design choices made while writing the controller
> driver:
> 1. Interface Register set IF0 has be used for receive and IF1 is
>    used for transmit message objects.
> 2. Out of the total Message objects available, half of it are kept
>    aside for RX purposes and the rest for TX purposes.
> 3. NAPI implementation is such that both the TX and RX paths
>    functions in polling mode.
> 
> Signed-off-by: AnilKumar Ch <anilkumar@ti.com>

Please explain why this CAN controller cannot be handled by the existing
C_CAN driver, eventually with some extensions. The register layout seems
almost identical, at least.

Wolfgang.




> ---
>  drivers/net/can/Kconfig            |   14 +
>  drivers/net/can/Makefile           |    1 +
>  drivers/net/can/d_can.c            | 1487 ++++++++++++++++++++++++++++++++++++
>  include/linux/can/platform/d_can.h |   40 +
>  4 files changed, 1542 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/d_can.c
>  create mode 100644 include/linux/can/platform/d_can.h
> 
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index bb709fd..2529cba 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -68,6 +68,20 @@ config CAN_TI_HECC
>  	  Driver for TI HECC (High End CAN Controller) module found on many
>  	  TI devices. The device specifications are available from www.ti.com
>  
> +config CAN_D_CAN
> +	tristate "Bosch D_CAN Controller"
> +	depends on CAN_DEV
> +	---help---
> +	  This driver adds support for the D_CAN device found in
> +	  many SoCs like am335x, dm814x and dm813x boards from TI.
> +
> +	  The device user guide can be accessed from
> +	  http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/
> +	  can/d_can_users_manual_111.pdf
> +
> +	  To compile this driver as a module, choose M here: the
> +	  module will be called d_can.
> +
>  config CAN_MCP251X
>  	tristate "Microchip MCP251x SPI CAN controllers"
>  	depends on CAN_DEV && SPI && HAS_DMA
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 938be37..4bd3a87 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -17,6 +17,7 @@ obj-$(CONFIG_CAN_C_CAN)		+= c_can/
>  obj-$(CONFIG_CAN_CC770)		+= cc770/
>  obj-$(CONFIG_CAN_AT91)		+= at91_can.o
>  obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
> +obj-$(CONFIG_CAN_D_CAN)		+= d_can.o
>  obj-$(CONFIG_CAN_MCP251X)	+= mcp251x.o
>  obj-$(CONFIG_CAN_BFIN)		+= bfin_can.o
>  obj-$(CONFIG_CAN_JANZ_ICAN3)	+= janz-ican3.o
> diff --git a/drivers/net/can/d_can.c b/drivers/net/can/d_can.c
> new file mode 100644
> index 0000000..51e2986
> --- /dev/null
> +++ b/drivers/net/can/d_can.c
> @@ -0,0 +1,1487 @@
> +/*
> + * CAN bus driver for Bosch D_CAN controller
> + *
> + * Copyright (C) 2012 Texas Instruments Incorporated - http://www.ti.com/
> + *
> + * Borrowed from C_CAN driver
> + * Copyright (C) 2010 ST Microelectronics
> + * - Bhupesh Sharma <bhupesh.sharma@st.com>
> + *
> + * Borrowed heavily from the C_CAN driver originally written by:
> + * Copyright (C) 2007
> + * - Sascha Hauer, Marc Kleine-Budde, Pengutronix <s.hauer@pengutronix.de>
> + * - Simon Kallweit, intefo AG <simon.kallweit@intefo.ch>
> + *
> + * Bosch D_CAN controller is compliant to CAN protocol version 2.0 part A and B.
> + * Bosch D_CAN user manual can be obtained from:
> + * http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/can/
> + * d_can_users_manual_111.pdf
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License as
> + * published by the Free Software Foundation version 2.
> + *
> + * This program is distributed "as is" WITHOUT ANY WARRANTY of any
> + * kind, whether express or implied; without even the implied warranty
> + * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/interrupt.h>
> +#include <linux/netdevice.h>
> +#include <linux/errno.h>
> +#include <linux/skbuff.h>
> +#include <linux/jiffies.h>
> +#include <linux/pm_runtime.h>
> +#include <linux/platform_device.h>
> +#include <linux/clk.h>
> +#include <linux/io.h>
> +
> +#include <linux/can/dev.h>
> +#include <linux/can/error.h>
> +#include <linux/can/platform/d_can.h>
> +
> +#define D_CAN_DRV_NAME	"d_can"
> +#define D_CAN_VERSION	"1.0"
> +#define D_CAN_DRV_DESC	"CAN bus driver for Bosch D_CAN controller " \
> +			D_CAN_VERSION
> +
> +/* TI D_CAN module registers */
> +#define D_CAN_CTL		0x0	/* CAN control register */
> +#define D_CAN_ES		0x4	/* Error and status */
> +#define D_CAN_PARITYERR_EOI	0x4	/* Parity error EOI */
> +#define D_CAN_ERRC		0x8	/* Error counter */
> +#define D_CAN_BTR		0xC	/* Bit timing */
> +#define D_CAN_INT		0x10	/* Interrupt register */
> +#define D_CAN_TEST		0x14	/* Test register */
> +#define D_CAN_PERR		0x1C	/* Parity Error Code */
> +#define D_CAN_ABOTR		0x80	/* Auto-Bus-On Time */
> +#define D_CAN_TXRQ_X		0x84	/* Transmission Request X */
> +#define D_CAN_TXRQ(n)		(0x88 + ((n) * 4)) /* Transmission request */
> +#define D_CAN_NWDAT_X		0x98	/* New data X register */
> +#define D_CAN_NWDAT(n)		(0x9C + ((n) * 4)) /* New data */
> +#define D_CAN_INTPND_X		0xAC	/* Interrupt Pending X */
> +#define D_CAN_INTPND(n)		(0xB0 + ((n) * 4)) /* Interrupt Pending */
> +#define D_CAN_MSGVAL_X		0xC0		/* Message Valid X */
> +#define D_CAN_MSGVAL(n)		(0xC4 + ((n) * 4)) /* Message Valid */
> +#define D_CAN_INTMUX(n)		(0xD8 + ((n) * 4)) /* Interrupt Multiplexer */
> +#define D_CAN_IFCMD(n)		(0x100 + ((n) * 0x20)) /* Command */
> +#define D_CAN_IFMSK(n)		(0x104 + ((n) * 0x20)) /* Mask */
> +#define D_CAN_IFARB(n)		(0x108 + ((n) * 0x20)) /* Arbitration */
> +#define D_CAN_IFMCTL(n)		(0x10c + ((n) * 0x20)) /* Message ctl */
> +#define D_CAN_IFDATA(n)		(0x110 + ((n) * 0x20)) /* DATA A */
> +#define D_CAN_IFDATB(n)		(0x114 + ((n) * 0x20)) /* DATA B */
> +#define D_CAN_IF3OBS		0x140	/* IF3 Observation */
> +#define D_CAN_IF3UPD(n)		(0x160 + ((n) * 4)) /* Update enable */
> +#define D_CAN_TIOC		0x1E0	/* CAN TX IO Control */
> +#define D_CAN_RIOC		0x1E4	/* CAN RX IO Control */
> +
> +/* Control register Bit fields */
> +#define D_CAN_CTL_WUBA		BIT(26)	/* Automatic wake-up on bus activity */
> +#define D_CAN_CTL_PDR		BIT(24)	/* Request for local low power mode */
> +#define D_CAN_CTL_DE3		BIT(20)	/* Enable DMA request line for IF3 */
> +#define D_CAN_CTL_DE2		BIT(19)	/* Enable DMA request line for IF2 */
> +#define D_CAN_CTL_DE1		BIT(18)	/* Enable DMA request line for IF1 */
> +#define D_CAN_CTL_IE1		BIT(17)	/* Interrupt line 1 enable */
> +#define D_CAN_CTL_INITDBG	BIT(16)	/* Init state for debug access */
> +#define D_CAN_CTL_SWR		BIT(15)	/* S/W reset enable */
> +#define D_CAN_CTL_PMD		(0xF << 10)	/* Parity on/off */
> +#define D_CAN_CTL_ABO		BIT(9)	/* Auto bus on enable */
> +#define D_CAN_CTL_IDS		BIT(8)	/* Interruption debug support enable */
> +#define D_CAN_CTL_TEST		BIT(7)	/* Test mode enable */
> +#define D_CAN_CTL_CCE		BIT(6)	/* Configuration change enable */
> +#define D_CAN_CTL_DISABLE_AR	BIT(5)	/* Disable automatic retransmission */
> +#define D_CAN_CTL_EIE		BIT(3)	/* Error interrupt enable */
> +#define D_CAN_CTL_SIE		BIT(2)	/* Status change int enable */
> +#define D_CAN_CTL_IE0		BIT(1)	/* Interrupt line 0 enable */
> +#define D_CAN_CTL_INIT		BIT(0)	/* D_CAN initialization mode */
> +
> +/* D_CAN Error and Status and Parity Error EOI reg bit fields */
> +#define D_CAN_ES_PDA		BIT(10)	/* Local power-down ACK */
> +#define D_CAN_ES_WUP		BIT(9)	/* Wkae up pending */
> +#define D_CAN_ES_PER		BIT(8)	/* Parity error detected */
> +#define D_CAN_ES_BOFF		BIT(7)	/* Bus off state */
> +#define D_CAN_ES_EWARN		BIT(6)	/* Warning state */
> +#define D_CAN_ES_EPASS		BIT(5)	/* Error passive state */
> +#define D_CAN_ES_RXOK		BIT(4)	/* Received a msg successfully */
> +#define D_CAN_ES_TXOK		BIT(3)	/* Transmitted a msg successfully */
> +#define D_CAN_ES_LEC_MASK	0x7	/* Last error code */
> +
> +/* Error counter reg bit fields */
> +#define D_CAN_ERRC_RP_MASK	BIT(15)		/* Receive error passive */
> +#define D_CAN_ERRC_REC_SHIFT	8
> +#define D_CAN_ERRC_REC_MASK	(0x7F << 8)	/* Receive err counter */
> +#define D_CAN_ERRC_TEC_MASK	(0xFF << 0)	/* Transmit err counter */
> +
> +/* Bit timing reg bit fields */
> +#define D_CAN_BTR_BRPE_SHIFT	16		/* Baud rate prescaler ext */
> +#define D_CAN_BTR_TSEG2_SHIFT	12		/* Time seg after smpl point */
> +#define D_CAN_BTR_TSEG1_SHIFT	8		/* Time seg before smpl point */
> +#define D_CAN_BTR_SJW_SHIFT	6		/* Syncronization jump width */
> +#define D_CAN_BTR_BRP_SHIFT	0		/* Baud rate prescaler */
> +
> +/* D_CAN Test register bit fields */
> +#define D_CAN_TEST_RDA		BIT(9)	/* RAM direct access enable */
> +#define D_CAN_TEST_EXL		BIT(8)	/* External loopback mode */
> +#define D_CAN_TEST_RX		BIT(7)	/* Monitors the reveive pin */
> +#define D_CAN_TEST_TX		(0x3 << 5)	/* Control of CAN_TX pin */
> +#define D_CAN_TEST_LBACK	BIT(4)	/* Loopback mode */
> +#define D_CAN_TEST_SILENT	BIT(3)	/* Silent mdoe */
> +
> +/* D_CAN IF command reg bit fields */
> +#define D_CAN_IF_CMD_WR		BIT(23)	/* Write/read */
> +#define D_CAN_IF_CMD_MASK	BIT(22)	/* Access to mask bits */
> +#define D_CAN_IF_CMD_ARB	BIT(21)	/* Access to arbitration bits */
> +#define D_CAN_IF_CMD_CONTROL	BIT(20)	/* Acess to control bits */
> +#define D_CAN_IF_CMD_CIP	BIT(19)	/* Clear int pending */
> +#define D_CAN_IF_CMD_TXRQST	BIT(18)	/* Access transmission request */
> +#define D_CAN_IF_CMD_DATAA	BIT(17)	/* Access to Data Bytes 0-3 */
> +#define D_CAN_IF_CMD_DATAB	BIT(16)	/* Access to Data Bytes 4-7 */
> +#define D_CAN_IF_CMD_BUSY	BIT(15)	/* Busy flag */
> +#define D_CAN_IF_CMD_DAM	BIT(14)	/* Activation of DMA */
> +#define D_CAN_IF_CMD_MN_MASK	0xFF	/* No. of msg's used for DMA T/F */
> +#define D_CAN_IF_CMD_ALL	(D_CAN_IF_CMD_MASK | D_CAN_IF_CMD_ARB | \
> +				D_CAN_IF_CMD_CONTROL | D_CAN_IF_CMD_TXRQST | \
> +				D_CAN_IF_CMD_DATAA | D_CAN_IF_CMD_DATAB)
> +
> +/* D_CAN IF mask reg bit fields */
> +#define D_CAN_IF_MASK_MX	BIT(31)	/* Mask Extended Identifier */
> +#define D_CAN_IF_MASK_MD	BIT(30)	/* Mask Message direction */
> +
> +/* D_CAN IF Arbitration */
> +#define D_CAN_IF_ARB_MSGVAL	BIT(31)	/* Message Vaild */
> +#define D_CAN_IF_ARB_MSGXTD	BIT(30)	/* Extended Identifier 0-11 1-29 */
> +#define D_CAN_IF_ARB_DIR_XMIT	BIT(29) /* Message direction 0-R 1-T */
> +
> +/* D_CAN IF Message control */
> +#define D_CAN_IF_MCTL_NEWDAT	BIT(15)	/* New data available */
> +#define D_CAN_IF_MCTL_MSGLST	BIT(14)	/* Message lost, only for receive */
> +#define D_CAN_IF_MCTL_INTPND	BIT(13)	/* Interrupt pending */
> +#define D_CAN_IF_MCTL_UMASK	BIT(12)	/* Use acceptance mask */
> +#define D_CAN_IF_MCTL_TXIE	BIT(11)	/* Transmit int enable */
> +#define D_CAN_IF_MCTL_RXIE	BIT(10)	/* Receive int enable */
> +#define D_CAN_IF_MCTL_RMTEN	BIT(9)	/* Remote enable */
> +#define D_CAN_IF_MCTL_TXRQST	BIT(8)	/* Transmit request */
> +#define D_CAN_IF_MCTL_EOB	BIT(7)	/* Data frames */
> +#define D_CAN_IF_MCTL_DLC_MASK	0xF	/* Data length code */
> +
> +/* D_CAN IF3 Observation reg bit fields */
> +#define D_CAN_IF3OBS_UP		BIT(15)	/* Update data status */
> +#define D_CAN_IF3OBS_SDB	BIT(12)	/* DataB read out status */
> +#define D_CAN_IF3OBS_SDA	BIT(11)	/* DataA read out status */
> +#define D_CAN_IF3OBS_SC		BIT(10)	/* Contol bits read out status */
> +#define D_CAN_IF3OBS_SA		BIT(9)	/* Arbitration read out status */
> +#define D_CAN_IF3OBS_SM		BIT(8)	/* Mask bits read out status */
> +#define D_CAN_IF3OBS_DB		BIT(4)	/* Data B read observation */
> +#define D_CAN_IF3OBS_DA		BIT(3)	/* Data A read observation */
> +#define D_CAN_IF3OBS_CTL	BIT(2)	/* Control read observation */
> +#define D_CAN_IF3OBS_ARB	BIT(1)	/* Arbitration data read observation */
> +#define D_CAN_IF3OBS_MASK	BIT(0)	/* Mask data read observation */
> +
> +/* D_CAN TX I/O reg bit fields */
> +#define D_CAN_TIOC_PU		BIT(18)	/* CAN_TX pull up/down select */
> +#define D_CAN_TIOC_PD		BIT(17)	/* CAN_TX pull disable */
> +#define D_CAN_TIOC_OD		BIT(16)	/* CAN_TX open drain enable */
> +#define D_CAN_TIOC_FUNC		BIT(3)	/* CAN_TX function */
> +#define D_CAN_TIOC_DIR		BIT(2)	/* CAN_TX data direction */
> +#define D_CAN_TIOC_OUT		BIT(1)	/* CAN_TX data out write */
> +#define D_CAN_TIOC_IN		BIT(0)	/* CAN_TX data in */
> +
> +/* D_CAN RX I/O reg bit fields */
> +#define D_CAN_RIOC_PU		BIT(18)	/* CAN_RX pull up/down select */
> +#define D_CAN_RIOC_PD		BIT(17)	/* CAN_RX pull disable */
> +#define D_CAN_RIOC_OD		BIT(16)	/* CAN_RX open drain enable */
> +#define D_CAN_RIOC_FUNC		BIT(3)	/* CAN_RX function */
> +#define D_CAN_RIOC_DIR		BIT(2)	/* CAN_RX data direction */
> +#define D_CAN_RIOC_OUT		BIT(1)	/* CAN_RX data out write */
> +#define D_CAN_RIOC_IN		BIT(0)	/* CAN_RX data in */
> +
> +/* IF register masks */
> +#define IFX_WRITE_IDR(x)		((x) & 0x1FFFFFFF)
> +#define IFX_CMD_BITS(x)			((x) & 0xFFFFFF00)
> +#define IFX_CMD_MSG_NUMBER(x)		((x) & 0xFF)
> +
> +/* Message objects split */
> +#define D_CAN_NUM_MSG_OBJECTS		64
> +#define D_CAN_NUM_RX_MSG_OBJECTS	32
> +#define D_CAN_NUM_TX_MSG_OBJECTS	32
> +
> +#define D_CAN_MSG_OBJ_RX_FIRST		1
> +#define D_CAN_MSG_OBJ_RX_LAST		(D_CAN_MSG_OBJ_RX_FIRST + \
> +					D_CAN_NUM_RX_MSG_OBJECTS - 1)
> +
> +#define D_CAN_MSG_OBJ_TX_FIRST		(D_CAN_MSG_OBJ_RX_LAST + 1)
> +#define D_CAN_MSG_OBJ_TX_LAST		(D_CAN_MSG_OBJ_TX_FIRST + \
> +					D_CAN_NUM_TX_MSG_OBJECTS - 1)
> +
> +#define D_CAN_MSG_OBJ_RX_SPLIT		17
> +#define D_CAN_MSG_OBJ_RX_LOW_LAST	(D_CAN_MSG_OBJ_RX_SPLIT - 1)
> +
> +#define D_CAN_NEXT_MSG_OBJ_MASK		(D_CAN_NUM_TX_MSG_OBJECTS - 1)
> +
> +/* global interrupt masks */
> +#define D_CAN_ENABLE_ALL_INTERRUPTS	1
> +#define D_CAN_DISABLE_ALL_INTERRUPTS	0
> +
> +/* status interrupt */
> +#define D_CAN_STATUS_INTERRUPT		0x8000
> +
> +#define D_CAN_BUSY_TIMEOUT		14
> +#define D_CAN_TIMEOUT_MS		1000
> +
> +/* Interface register bank number */
> +#define D_CAN_IF_RX_NUM			0
> +#define D_CAN_IF_TX_NUM			1
> +
> +#define D_CAN_GET_XREG_NUM(priv, reg)	(__ffs(d_can_read(priv, reg)) >> 2)
> +
> +/* d_can private data structure */
> +struct d_can_priv {
> +	struct can_priv can;	/* must be the first member */
> +	struct napi_struct napi;
> +	struct net_device *dev;
> +	struct platform_device *pdev;
> +	unsigned int tx_next;
> +	unsigned int tx_echo;
> +	u32 current_status;
> +	u32 last_status;
> +	u32 irqstatus;
> +	bool is_opened;
> +	void __iomem *base;
> +	void (*ram_init) (unsigned int, unsigned int);
> +};
> +
> +/* CAN Bittiming constants as per D_CAN specs */
> +static struct can_bittiming_const d_can_bittiming_const = {
> +	.name		= D_CAN_DRV_NAME,
> +	.tseg1_min	= 1,	/* Time segment 1 = prop_seg + phase_seg1 */
> +	.tseg1_max	= 16,
> +	.tseg2_min	= 1,	/* Time segment 2 = phase_seg2 */
> +	.tseg2_max	= 8,
> +	.sjw_max	= 4,
> +	.brp_min	= 1,
> +	.brp_max	= 1024,	/* 6-bit BRP field + 4-bit BRPE field*/
> +	.brp_inc	= 1,
> +};
> +
> +/* d_can last error code (lec) values */
> +enum d_can_lec_type {
> +	LEC_NO_ERROR = 0,
> +	LEC_STUFF_ERROR,
> +	LEC_FORM_ERROR,
> +	LEC_ACK_ERROR,
> +	LEC_BIT1_ERROR,
> +	LEC_BIT0_ERROR,
> +	LEC_CRC_ERROR,
> +	LEC_UNUSED,
> +};
> +
> +/* d_can error types */
> +enum d_can_bus_error_types {
> +	NO_ERROR = 0,
> +	BUS_OFF,
> +	ERROR_WARNING,
> +	ERROR_PASSIVE,
> +};
> +
> +static inline void d_can_write(struct d_can_priv *priv, u32 reg, u32 val)
> +{
> +	writel(val, priv->base + reg);
> +}
> +
> +static inline u32 d_can_read(struct d_can_priv *priv, u32 reg)
> +{
> +	return readl(priv->base + reg);
> +}
> +
> +static inline void d_can_set_bit(struct d_can_priv *priv, u32 reg, u32 bitmask)
> +{
> +	d_can_write(priv, reg, d_can_read(priv, reg) | bitmask);
> +}
> +
> +static inline u32 d_can_get_bit(struct d_can_priv *priv, u32 reg, u32 bitmask)
> +{
> +	return (d_can_read(priv, reg) & bitmask) ? 1 : 0;
> +}
> +
> +static inline void d_can_clear_bit(struct d_can_priv *priv, u32 reg,
> +							u32 bitmask)
> +{
> +	d_can_write(priv, reg, d_can_read(priv, reg) & ~bitmask);
> +}
> +
> +static inline int get_tx_next_msg_obj(const struct d_can_priv *priv)
> +{
> +	return (priv->tx_next & D_CAN_NEXT_MSG_OBJ_MASK) +
> +			D_CAN_MSG_OBJ_TX_FIRST;
> +}
> +
> +static inline int get_tx_echo_msg_obj(const struct d_can_priv *priv)
> +{
> +	return (priv->tx_echo & D_CAN_NEXT_MSG_OBJ_MASK) +
> +			D_CAN_MSG_OBJ_TX_FIRST;
> +}
> +
> +static void d_can_interrupts(struct d_can_priv *priv, unsigned int enable)
> +{
> +	unsigned int cntrl_save = d_can_read(priv, D_CAN_CTL);
> +
> +	if (enable)
> +		cntrl_save |= (D_CAN_CTL_IE1 | D_CAN_CTL_EIE |
> +				D_CAN_CTL_SIE | D_CAN_CTL_IE0);
> +	else
> +		cntrl_save &= ~(D_CAN_CTL_IE1 | D_CAN_CTL_EIE |
> +				D_CAN_CTL_SIE | D_CAN_CTL_IE0);
> +
> +	d_can_write(priv, D_CAN_CTL, cntrl_save);
> +}
> +
> +static inline int d_can_msg_obj_is_busy(struct d_can_priv *priv, u32 iface)
> +{
> +	unsigned long time_out = jiffies + msecs_to_jiffies(D_CAN_BUSY_TIMEOUT);
> +
> +	/* Check the status of busy bit */
> +	while (d_can_get_bit(priv, D_CAN_IFCMD(iface), D_CAN_IF_CMD_BUSY) &&
> +					time_after(time_out, jiffies))
> +		cpu_relax();
> +
> +	if (time_after(jiffies, time_out))
> +		return -ETIMEDOUT;
> +
> +	return 0;
> +}
> +
> +static inline void d_can_object_get(struct net_device *dev,
> +				u32 iface, u32 objno, u32 mask)
> +{
> +	struct d_can_priv *priv = netdev_priv(dev);
> +
> +	d_can_write(priv, D_CAN_IFCMD(iface), IFX_CMD_BITS(mask) |
> +					IFX_CMD_MSG_NUMBER(objno));
> +
> +	/*
> +	 * As per specs, after writing the message object number in the
> +	 * IF command register the transfer b/w interface register and
> +	 * message RAM must be complete in 4 - 14 CAN-CLK period.
> +	 */
> +	if (d_can_msg_obj_is_busy(priv, iface))
> +		netdev_err(dev, "timed out in object get\n");
> +}
> +
> +static inline void d_can_object_put(struct net_device *dev,
> +				u32 iface, u32 objno, u32 mask)
> +{
> +	struct d_can_priv *priv = netdev_priv(dev);
> +
> +	d_can_write(priv, D_CAN_IFCMD(iface), D_CAN_IF_CMD_WR |
> +		IFX_CMD_BITS(mask) | IFX_CMD_MSG_NUMBER(objno));
> +
> +	/*
> +	 * As per specs, after writing the message object number in the
> +	 * IF command register the transfer b/w interface register and
> +	 * message RAM must be complete in 4 - 14 CAN-CLK period.
> +	 */
> +	if (d_can_msg_obj_is_busy(priv, iface))
> +		netdev_err(dev, "timed out in object put\n");
> +}
> +
> +static void d_can_write_msg_object(struct net_device *dev, u32 iface,
> +				struct can_frame *frame, u32 objno)
> +{
> +	struct d_can_priv *priv = netdev_priv(dev);
> +	unsigned int id;
> +	u32 flags = 0;
> +
> +	if (!(frame->can_id & CAN_RTR_FLAG))
> +		flags |= D_CAN_IF_ARB_DIR_XMIT;
> +
> +	if (frame->can_id & CAN_EFF_FLAG) {
> +		id = frame->can_id & CAN_EFF_MASK;
> +		flags |= D_CAN_IF_ARB_MSGXTD;
> +	} else
> +		id = ((frame->can_id & CAN_SFF_MASK) << 18);
> +
> +	flags |= D_CAN_IF_ARB_MSGVAL;
> +	d_can_write(priv, D_CAN_IFARB(iface), IFX_WRITE_IDR(id) | flags);
> +
> +	/* Writing lower 4bytes to DATAA IF register */
> +	d_can_write(priv, D_CAN_IFDATA(iface),
> +				le32_to_cpu(*(u32 *)(frame->data)));
> +
> +	/* Writing higher 4bytes to DATAB IF register */
> +	if (frame->can_dlc > 4)
> +		d_can_write(priv, D_CAN_IFDATB(iface),
> +				le32_to_cpu(*(u32 *)(frame->data + 4)));
> +
> +	/* enable TX interrupt for this message object */
> +	d_can_write(priv, D_CAN_IFMCTL(iface),
> +			D_CAN_IF_MCTL_TXIE | D_CAN_IF_MCTL_EOB |
> +			D_CAN_IF_MCTL_TXRQST | D_CAN_IF_MCTL_NEWDAT |
> +			frame->can_dlc);
> +
> +	/* Put message data into message RAM */
> +	d_can_object_put(dev, iface, objno, D_CAN_IF_CMD_ALL);
> +}
> +
> +/*
> + * Mark that this particular message object is received and clearing
> + * the interrupt pending register value.
> + */
> +static inline void d_can_mark_rx_msg_obj(struct net_device *dev,
> +			u32 iface, u32 ctrl_mask, u32 objno)
> +{
> +	struct d_can_priv *priv = netdev_priv(dev);
> +
> +	d_can_write(priv, D_CAN_IFMCTL(iface), ctrl_mask &
> +			~(D_CAN_IF_MCTL_MSGLST | D_CAN_IF_MCTL_INTPND));
> +	d_can_object_put(dev, iface, objno, D_CAN_IF_CMD_CONTROL);
> +}
> +
> +static inline void d_can_activate_all_lower_rx_msg_objs(struct net_device *dev,
> +						u32 iface, u32 ctrl_mask)
> +{
> +	unsigned int i;
> +	struct d_can_priv *priv = netdev_priv(dev);
> +
> +	for (i = D_CAN_MSG_OBJ_RX_FIRST; i <= D_CAN_MSG_OBJ_RX_LOW_LAST; i++) {
> +		d_can_write(priv, D_CAN_IFMCTL(iface), ctrl_mask &
> +				~(D_CAN_IF_MCTL_MSGLST | D_CAN_IF_MCTL_INTPND |
> +				D_CAN_IF_MCTL_NEWDAT));
> +		d_can_object_put(dev, iface, i, D_CAN_IF_CMD_CONTROL);
> +	}
> +}
> +
> +static inline void d_can_activate_rx_msg_obj(struct net_device *dev,
> +				u32 iface, u32 ctrl_mask, u32 objno)
> +{
> +	struct d_can_priv *priv = netdev_priv(dev);
> +
> +	d_can_write(priv, D_CAN_IFMCTL(iface), ctrl_mask &
> +			~(D_CAN_IF_MCTL_MSGLST | D_CAN_IF_MCTL_INTPND |
> +			D_CAN_IF_MCTL_NEWDAT));
> +	d_can_object_put(dev, iface, objno, D_CAN_IF_CMD_CONTROL);
> +}
> +
> +static void d_can_handle_lost_msg_obj(struct net_device *dev,
> +					u32 iface, u32 objno)
> +{
> +	struct d_can_priv *priv = netdev_priv(dev);
> +	struct net_device_stats *stats = &dev->stats;
> +	struct sk_buff *skb;
> +	struct can_frame *frame;
> +
> +	netdev_err(dev, "msg lost in buffer %d\n", objno);
> +	d_can_object_get(dev, iface, objno, D_CAN_IF_CMD_ALL &
> +					~D_CAN_IF_CMD_TXRQST);
> +	d_can_clear_bit(priv, D_CAN_IFMCTL(iface), D_CAN_IF_MCTL_MSGLST);
> +	d_can_object_put(dev, iface, objno, D_CAN_IF_CMD_CONTROL);
> +
> +	/* create an error msg */
> +	skb = alloc_can_err_skb(dev, &frame);
> +	if (unlikely(!skb))
> +		return;
> +
> +	frame->can_id |= CAN_ERR_CRTL;
> +	frame->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
> +	stats->rx_errors++;
> +	stats->rx_over_errors++;
> +
> +	netif_receive_skb(skb);
> +}
> +
> +static int d_can_read_msg_object(struct net_device *dev, u32 iface, u32 ctrl)
> +{
> +	unsigned int arb_val, mctl_val;
> +	struct d_can_priv *priv = netdev_priv(dev);
> +	struct net_device_stats *stats = &dev->stats;
> +	struct can_frame *frame;
> +	struct sk_buff *skb;
> +	u32 data = 0;
> +
> +	skb = alloc_can_skb(dev, &frame);
> +	if (!skb) {
> +		stats->rx_dropped++;
> +		return -ENOMEM;
> +	}
> +
> +	frame->can_dlc = get_can_dlc(ctrl & 0x0F);
> +	arb_val = d_can_read(priv, D_CAN_IFARB(iface));
> +	mctl_val = d_can_read(priv, D_CAN_IFMCTL(iface));
> +
> +	if (arb_val & D_CAN_IF_ARB_MSGXTD)
> +		frame->can_id = (arb_val & CAN_EFF_MASK) | CAN_EFF_FLAG;
> +	else
> +		frame->can_id = (arb_val >> 18) & CAN_SFF_MASK;
> +
> +	if (mctl_val & D_CAN_IF_MCTL_RMTEN)
> +		frame->can_id |= CAN_RTR_FLAG;
> +	else {
> +		data = d_can_read(priv, D_CAN_IFDATA(iface));
> +		/* Writing MO lower 4 data bytes to skb */
> +		*(u32 *)(frame->data) = cpu_to_le32(data);
> +
> +		/* Writing MO higher 4 data bytes to skb */
> +		if (frame->can_dlc > 4) {
> +			data = d_can_read(priv, D_CAN_IFDATB(iface));
> +			*(u32 *)(frame->data + 4) = cpu_to_le32(data);
> +		} else
> +			*(u32 *)(frame->data + 4) = 0;
> +	}
> +
> +	netif_receive_skb(skb);
> +	stats->rx_packets++;
> +	stats->rx_bytes += frame->can_dlc;
> +
> +	return 0;
> +}
> +
> +static void d_can_setup_receive_object(struct net_device *dev, u32 iface,
> +				u32 objno, u32 mask, u32 id, u32 mcont)
> +{
> +	struct d_can_priv *priv = netdev_priv(dev);
> +
> +	d_can_write(priv, D_CAN_IFMCTL(iface), mcont);
> +	d_can_write(priv, D_CAN_IFMSK(iface), IFX_WRITE_IDR(mask));
> +	d_can_write(priv, D_CAN_IFARB(iface), IFX_WRITE_IDR(id) |
> +						D_CAN_IF_ARB_MSGVAL);
> +	d_can_object_put(dev, iface, objno, D_CAN_IF_CMD_ALL &
> +					~D_CAN_IF_CMD_TXRQST);
> +
> +	netdev_dbg(dev, "obj no:%d, msgval:0x%08x\n", objno, d_can_read(priv,
> +		D_CAN_MSGVAL(D_CAN_GET_XREG_NUM(priv, D_CAN_MSGVAL_X))));
> +}
> +
> +static void d_can_inval_msg_object(struct net_device *dev, u32 iface, u32 objno)
> +{
> +	struct d_can_priv *priv = netdev_priv(dev);
> +
> +	d_can_write(priv, D_CAN_IFARB(iface), 0);
> +	d_can_write(priv, D_CAN_IFMCTL(iface), 0);
> +	d_can_object_put(dev, iface, objno, D_CAN_IF_CMD_ARB |
> +					D_CAN_IF_CMD_CONTROL);
> +
> +	netdev_dbg(dev, "obj no:%d, msgval:0x%08x\n", objno, d_can_read(priv,
> +		D_CAN_MSGVAL(D_CAN_GET_XREG_NUM(priv, D_CAN_MSGVAL_X))));
> +}
> +
> +static inline int d_can_is_next_tx_obj_busy(struct d_can_priv *priv, u32 objno)
> +{
> +	u32 txrq_x_reg_val = D_CAN_GET_XREG_NUM(priv, D_CAN_TXRQ_X);
> +
> +	/* Transmission request register's bit n-1 corresponds to
> +	 * message object n, we need to handle the same properly */
> +	if (d_can_read(priv, D_CAN_TXRQ(txrq_x_reg_val)) &
> +			(1 << (objno - D_CAN_MSG_OBJ_TX_FIRST)))
> +		return 1;
> +
> +	return 0;
> +}
> +
> +static netdev_tx_t d_can_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	u32 msg_obj_no;
> +	struct d_can_priv *priv = netdev_priv(dev);
> +	struct can_frame *frame = (struct can_frame *)skb->data;
> +
> +	if (can_dropped_invalid_skb(dev, skb))
> +		return NETDEV_TX_OK;
> +
> +	msg_obj_no = get_tx_next_msg_obj(priv);
> +
> +	/* prepare message object for transmission */
> +	d_can_write_msg_object(dev, D_CAN_IF_TX_NUM, frame, msg_obj_no);
> +	can_put_echo_skb(skb, dev, msg_obj_no - D_CAN_MSG_OBJ_TX_FIRST);
> +
> +	/*
> +	 * we have to stop the queue in case of a wrap around or
> +	 * if the next TX message object is still in use
> +	 */
> +	priv->tx_next++;
> +	if (d_can_is_next_tx_obj_busy(priv, get_tx_next_msg_obj(priv)) ||
> +		((priv->tx_next & D_CAN_NEXT_MSG_OBJ_MASK) == 0))
> +		netif_stop_queue(dev);
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static void d_can_set_bittiming(struct net_device *dev)
> +{
> +	struct d_can_priv *priv = netdev_priv(dev);
> +	const struct can_bittiming *bt = &priv->can.bittiming;
> +	u32 can_btc;
> +
> +	can_btc = ((bt->phase_seg2 - 1) & 0x7) << D_CAN_BTR_TSEG2_SHIFT;
> +	can_btc |= ((bt->phase_seg1 + bt->prop_seg - 1) & 0xF) <<
> +						D_CAN_BTR_TSEG1_SHIFT;
> +	can_btc |= ((bt->sjw - 1) & 0x3) << D_CAN_BTR_SJW_SHIFT;
> +	/* Ten bits contains the BRP, 6 bits for BRP and upper 4 bits for brpe*/
> +	can_btc |= ((bt->brp - 1) & 0x3F) << D_CAN_BTR_BRP_SHIFT;
> +	can_btc |= ((((bt->brp - 1) >> 6) & 0xF) << D_CAN_BTR_BRPE_SHIFT);
> +
> +	d_can_write(priv, D_CAN_BTR, can_btc);
> +	netdev_info(dev, "setting CAN BT = %#x\n", can_btc);
> +}
> +
> +/*
> + * Configure D_CAN message objects for Tx and Rx purposes:
> + * D_CAN provides a total of 64 message objects that can be configured
> + * either for Tx or Rx purposes. In this driver first 32 message objects
> + * are used as a reception FIFO and the reception FIFO is signified by the
> + * EoB bit being SET. The remaining 32 message objects are kept aside for
> + * Tx purposes. See user guide document for further details on configuring
> + * message objects.
> + */
> +static void d_can_configure_msg_objects(struct net_device *dev)
> +{
> +	unsigned int i;
> +
> +	/* first invalidate all message objects */
> +	for (i = D_CAN_MSG_OBJ_RX_FIRST; i <= D_CAN_NUM_MSG_OBJECTS; i++)
> +		d_can_inval_msg_object(dev, D_CAN_IF_RX_NUM, i);
> +
> +	/* setup receive message objects */
> +	for (i = D_CAN_MSG_OBJ_RX_FIRST; i < D_CAN_MSG_OBJ_RX_LAST; i++)
> +		d_can_setup_receive_object(dev, D_CAN_IF_RX_NUM, i, 0, 0,
> +			(D_CAN_IF_MCTL_RXIE | D_CAN_IF_MCTL_UMASK) &
> +			~D_CAN_IF_MCTL_EOB);
> +
> +	/* Last object EoB bit should be 1 for terminate */
> +	d_can_setup_receive_object(dev, D_CAN_IF_RX_NUM, D_CAN_MSG_OBJ_RX_LAST,
> +			0, 0, D_CAN_IF_MCTL_RXIE | D_CAN_IF_MCTL_UMASK |
> +			D_CAN_IF_MCTL_EOB);
> +}
> +
> +static void d_can_test_mode(struct net_device *dev)
> +{
> +	struct d_can_priv *priv = netdev_priv(dev);
> +
> +	/* Test mode is enabled in this step & the specific TEST bits
> +	 * are enabled accordingly */
> +	d_can_write(priv, D_CAN_CTL, D_CAN_CTL_EIE |
> +			D_CAN_CTL_IE1 |	D_CAN_CTL_IE0 | D_CAN_CTL_TEST);
> +
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY)
> +		/* silent mode : bus-monitoring mode */
> +		d_can_write(priv, D_CAN_TEST, D_CAN_TEST_SILENT);
> +	else if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK)
> +		/* loopback mode : useful for self-test function */
> +		d_can_write(priv, D_CAN_TEST, D_CAN_TEST_LBACK);
> +	else
> +		/* loopback + silent mode : useful for hot self-test */
> +		d_can_write(priv, D_CAN_TEST, D_CAN_TEST_LBACK |
> +				D_CAN_TEST_SILENT);
> +}
> +
> +/*
> + * Configure D_CAN chip:
> + * - enable/disable auto-retransmission
> + * - set operating mode
> + * - configure message objects
> + */
> +static void d_can_init(struct net_device *dev)
> +{
> +	struct d_can_priv *priv = netdev_priv(dev);
> +	unsigned long time_out;
> +
> +	netdev_dbg(dev, "resetting d_can ...\n");
> +	d_can_set_bit(priv, D_CAN_CTL, D_CAN_CTL_SWR);
> +
> +	/* Enter initialization mode by setting the Init bit */
> +	d_can_set_bit(priv, D_CAN_CTL, D_CAN_CTL_INIT);
> +
> +	/* enable automatic retransmission */
> +	d_can_clear_bit(priv, D_CAN_CTL, D_CAN_CTL_DISABLE_AR);
> +
> +	/* Set the Configure Change Enable ( CCE) bit */
> +	d_can_set_bit(priv, D_CAN_CTL, D_CAN_CTL_CCE);
> +
> +	/* Wait for the Init bit to get set */
> +	time_out = jiffies + msecs_to_jiffies(D_CAN_TIMEOUT_MS);
> +	while (!d_can_get_bit(priv, D_CAN_CTL, D_CAN_CTL_INIT) &&
> +					time_after(time_out, jiffies))
> +		cpu_relax();
> +
> +	if (time_after(jiffies, time_out)) {
> +		netdev_err(dev, "timedout, D_CAN INIT bit is not set\n");
> +		return;
> +	}
> +
> +	/* set bittiming params */
> +	d_can_set_bittiming(dev);
> +
> +	d_can_clear_bit(priv, D_CAN_CTL, D_CAN_CTL_INIT | D_CAN_CTL_CCE);
> +
> +	/* Wait for the Init bit to get clear */
> +	time_out = jiffies + msecs_to_jiffies(D_CAN_TIMEOUT_MS);
> +	while (d_can_get_bit(priv, D_CAN_CTL, D_CAN_CTL_INIT) &&
> +					time_after(time_out, jiffies))
> +		cpu_relax();
> +
> +	if (time_after(jiffies, time_out)) {
> +		netdev_err(dev, "timedout, D_CAN INIT bit is not cleared\n");
> +		return;
> +	}
> +
> +	if (priv->can.ctrlmode & (CAN_CTRLMODE_LOOPBACK |
> +				CAN_CTRLMODE_LISTENONLY))
> +		d_can_test_mode(dev);
> +	else
> +		d_can_write(priv, D_CAN_CTL, D_CAN_CTL_EIE | D_CAN_CTL_IE1 |
> +					D_CAN_CTL_SIE | D_CAN_CTL_IE0);
> +
> +	/* Enable TX and RX I/O Control pins */
> +	d_can_write(priv, D_CAN_TIOC, D_CAN_TIOC_FUNC);
> +	d_can_write(priv, D_CAN_RIOC, D_CAN_RIOC_FUNC);
> +
> +	/* configure message objects */
> +	d_can_configure_msg_objects(dev);
> +
> +	/* set a LEC value so that we can check for updates later */
> +	d_can_write(priv, D_CAN_ES, LEC_UNUSED);
> +}
> +
> +static void d_can_start(struct net_device *dev)
> +{
> +	struct d_can_priv *priv = netdev_priv(dev);
> +
> +	/* basic d_can initialization */
> +	d_can_init(dev);
> +
> +	priv->can.state = CAN_STATE_ERROR_ACTIVE;
> +
> +	/* reset tx helper pointers */
> +	priv->tx_next = priv->tx_echo = 0;
> +
> +	/* enable status change, error and module interrupts */
> +	d_can_interrupts(priv, D_CAN_ENABLE_ALL_INTERRUPTS);
> +}
> +
> +static void d_can_stop(struct net_device *dev)
> +{
> +	struct d_can_priv *priv = netdev_priv(dev);
> +
> +	d_can_interrupts(priv, D_CAN_DISABLE_ALL_INTERRUPTS);
> +
> +	/* set the state as STOPPED */
> +	priv->can.state = CAN_STATE_STOPPED;
> +}
> +
> +static int d_can_set_mode(struct net_device *dev, enum can_mode mode)
> +{
> +	switch (mode) {
> +	case CAN_MODE_START:
> +		d_can_start(dev);
> +		netif_wake_queue(dev);
> +		break;
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +
> +	return 0;
> +}
> +
> +static int d_can_get_berr_counter(const struct net_device *dev,
> +					struct can_berr_counter *bec)
> +{
> +	unsigned int err_cnt;
> +	struct d_can_priv *priv = netdev_priv(dev);
> +
> +	err_cnt = d_can_read(priv, D_CAN_ERRC);
> +	bec->rxerr = (err_cnt & D_CAN_ERRC_REC_MASK) >> D_CAN_ERRC_REC_SHIFT;
> +	bec->txerr = err_cnt & D_CAN_ERRC_TEC_MASK;
> +
> +	return 0;
> +}
> +
> +/*
> + * priv->tx_echo holds the number of the oldest can_frame put for
> + * transmission into the hardware, but not yet ACKed by the CAN tx
> + * complete IRQ.
> + * We iterate from priv->tx_echo to priv->tx_next and check if the
> + * packet has been transmitted, echo it back to the CAN framework.
> + * If we discover a not yet transmitted packet, stop looking for more.
> + */
> +static void d_can_do_tx(struct net_device *dev)
> +{
> +	u32 msg_obj_no;
> +	struct d_can_priv *priv = netdev_priv(dev);
> +	struct net_device_stats *stats = &dev->stats;
> +	u32 txrq_x_reg_val;
> +	u32 txrq_reg_val;
> +
> +	for (/* nix */; (priv->tx_next - priv->tx_echo) > 0; priv->tx_echo++) {
> +		msg_obj_no = get_tx_echo_msg_obj(priv);
> +		txrq_x_reg_val = D_CAN_GET_XREG_NUM(priv, D_CAN_TXRQ_X);
> +		txrq_reg_val = d_can_read(priv, D_CAN_TXRQ(txrq_x_reg_val));
> +		if (!(txrq_reg_val & (1 << (msg_obj_no -
> +						D_CAN_MSG_OBJ_TX_FIRST)))) {
> +			can_get_echo_skb(dev,
> +					msg_obj_no - D_CAN_MSG_OBJ_TX_FIRST);
> +			stats->tx_bytes += d_can_read(priv,
> +					D_CAN_IFMCTL(D_CAN_IF_TX_NUM)) &
> +					D_CAN_IF_MCTL_DLC_MASK;
> +			stats->tx_packets++;
> +			d_can_inval_msg_object(dev, D_CAN_IF_TX_NUM,
> +					msg_obj_no);
> +		} else
> +			break;
> +	}
> +
> +	/* restart queue if wrap-up or if queue stalled on last pkt */
> +	if (((priv->tx_next & D_CAN_NEXT_MSG_OBJ_MASK) != 0) ||
> +		((priv->tx_echo & D_CAN_NEXT_MSG_OBJ_MASK) == 0))
> +		netif_wake_queue(dev);
> +}
> +
> +/*
> + * d_can core saves a received CAN message into the first free message
> + * object it finds free (starting with the lowest). Bits NEWDAT and
> + * INTPND are set for this message object indicating that a new message
> + * has arrived. To work-around this issue, we keep two groups of message
> + * objects whose partitioning is defined by D_CAN_MSG_OBJ_RX_SPLIT.
> + *
> + * To ensure in-order frame reception we use the following
> + * approach while re-activating a message object to receive further
> + * frames:
> + * - if the current message object number is lower than
> + *   D_CAN_MSG_RX_LOW_LAST, do not clear the NEWDAT bit while clearing
> + *   the INTPND bit.
> + * - if the current message object number is equal to
> + *   D_CAN_MSG_RX_LOW_LAST then clear the NEWDAT bit of all lower
> + *   receive message objects.
> + * - if the current message object number is greater than
> + *   D_CAN_MSG_RX_LOW_LAST then clear the NEWDAT bit of
> + *   only this message object.
> + */
> +static int d_can_do_rx_poll(struct net_device *dev, int quota)
> +{
> +	struct d_can_priv *priv = netdev_priv(dev);
> +	unsigned int msg_obj, mctrl_reg_val;
> +	u32 num_rx_pkts = 0;
> +	u32 intpnd_x_reg_val;
> +	u32 intpnd_reg_val;
> +
> +	for (msg_obj = D_CAN_MSG_OBJ_RX_FIRST;
> +		msg_obj <= D_CAN_MSG_OBJ_RX_LAST && quota > 0; msg_obj++) {
> +
> +		intpnd_x_reg_val = D_CAN_GET_XREG_NUM(priv, D_CAN_INTPND_X);
> +		intpnd_reg_val = d_can_read(priv,
> +					D_CAN_INTPND(intpnd_x_reg_val));
> +
> +		/*
> +		 * as interrupt pending register's bit n-1 corresponds to
> +		 * message object n, we need to handle the same properly.
> +		 */
> +		if (intpnd_reg_val & (1 << (msg_obj - 1))) {
> +
> +			d_can_object_get(dev, D_CAN_IF_RX_NUM, msg_obj,
> +					D_CAN_IF_CMD_ALL &
> +					~D_CAN_IF_CMD_TXRQST);
> +
> +			mctrl_reg_val = d_can_read(priv,
> +					D_CAN_IFMCTL(D_CAN_IF_RX_NUM));
> +
> +			if (!(mctrl_reg_val & D_CAN_IF_MCTL_NEWDAT))
> +				continue;
> +
> +			/* read the data from the message object */
> +			d_can_read_msg_object(dev, D_CAN_IF_RX_NUM,
> +						mctrl_reg_val);
> +
> +			if (mctrl_reg_val & D_CAN_IF_MCTL_EOB)
> +				d_can_setup_receive_object(dev, D_CAN_IF_RX_NUM,
> +					D_CAN_MSG_OBJ_RX_LAST, 0, 0,
> +					D_CAN_IF_MCTL_RXIE |
> +					D_CAN_IF_MCTL_UMASK |
> +					D_CAN_IF_MCTL_EOB);
> +
> +			if (mctrl_reg_val & D_CAN_IF_MCTL_MSGLST) {
> +				d_can_handle_lost_msg_obj(dev, D_CAN_IF_RX_NUM,
> +					msg_obj);
> +				num_rx_pkts++;
> +				quota--;
> +				continue;
> +			}
> +
> +			if (msg_obj < D_CAN_MSG_OBJ_RX_LOW_LAST)
> +				d_can_mark_rx_msg_obj(dev, D_CAN_IF_RX_NUM,
> +						mctrl_reg_val, msg_obj);
> +			else if (msg_obj > D_CAN_MSG_OBJ_RX_LOW_LAST)
> +				/* activate this msg obj */
> +				d_can_activate_rx_msg_obj(dev, D_CAN_IF_RX_NUM,
> +						mctrl_reg_val, msg_obj);
> +			else if (msg_obj == D_CAN_MSG_OBJ_RX_LOW_LAST)
> +				/* activate all lower message objects */
> +				d_can_activate_all_lower_rx_msg_objs(dev,
> +						D_CAN_IF_RX_NUM, mctrl_reg_val);
> +
> +			num_rx_pkts++;
> +			quota--;
> +		}
> +	}
> +	return num_rx_pkts;
> +}
> +
> +static inline int d_can_has_handle_berr(struct d_can_priv *priv)
> +{
> +	return (priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING) &&
> +		(priv->current_status & LEC_UNUSED);
> +}
> +
> +static int d_can_handle_state_change(struct net_device *dev,
> +				enum d_can_bus_error_types error_type)
> +{
> +	unsigned int err_cnt;
> +	unsigned int rx_epass;
> +	struct d_can_priv *priv = netdev_priv(dev);
> +	struct net_device_stats *stats = &dev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	struct can_berr_counter bec;
> +
> +	/* propagate the error condition to the CAN stack */
> +	skb = alloc_can_err_skb(dev, &cf);
> +	if (unlikely(!skb))
> +		return 0;
> +
> +	d_can_get_berr_counter(dev, &bec);
> +	err_cnt = d_can_read(priv, D_CAN_ERRC);
> +	rx_epass = err_cnt & D_CAN_ERRC_RP_MASK;
> +
> +	switch (error_type) {
> +	case ERROR_WARNING:
> +		/* error warning state */
> +		priv->can.can_stats.error_warning++;
> +		priv->can.state = CAN_STATE_ERROR_WARNING;
> +		cf->can_id |= CAN_ERR_CRTL;
> +		cf->data[1] = (bec.txerr > bec.rxerr) ?
> +			CAN_ERR_CRTL_TX_WARNING :
> +			CAN_ERR_CRTL_RX_WARNING;
> +		cf->data[6] = bec.txerr;
> +		cf->data[7] = bec.rxerr;
> +
> +		break;
> +	case ERROR_PASSIVE:
> +		/* error passive state */
> +		priv->can.can_stats.error_passive++;
> +		priv->can.state = CAN_STATE_ERROR_PASSIVE;
> +		cf->can_id |= CAN_ERR_CRTL;
> +		if (rx_epass)
> +			cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
> +		if (bec.txerr > 127)
> +			cf->data[1] |= CAN_ERR_CRTL_TX_PASSIVE;
> +
> +		cf->data[6] = bec.txerr;
> +		cf->data[7] = bec.rxerr;
> +		break;
> +	case BUS_OFF:
> +		/* bus-off state */
> +		priv->can.state = CAN_STATE_BUS_OFF;
> +		cf->can_id |= CAN_ERR_BUSOFF;
> +		/*
> +		 * disable all interrupts in bus-off mode to ensure that
> +		 * the CPU is not hogged down
> +		 */
> +		d_can_interrupts(priv, D_CAN_DISABLE_ALL_INTERRUPTS);
> +		can_bus_off(dev);
> +		break;
> +	default:
> +		break;
> +	}
> +	netif_receive_skb(skb);
> +	stats->rx_packets++;
> +	stats->rx_bytes += cf->can_dlc;
> +
> +	return 1;
> +}
> +
> +static int d_can_handle_bus_err(struct net_device *dev,
> +				enum d_can_lec_type lec_type)
> +{
> +	struct d_can_priv *priv = netdev_priv(dev);
> +	struct net_device_stats *stats = &dev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +
> +	/*
> +	 * early exit if no lec update or no error.
> +	 * no lec update means that no CAN bus event has been detected
> +	 * since CPU wrote 0x7 value to status reg.
> +	 */
> +	if (lec_type == LEC_UNUSED || lec_type == LEC_NO_ERROR)
> +		return 0;
> +
> +	/* propagate the error condition to the CAN stack */
> +	skb = alloc_can_err_skb(dev, &cf);
> +	if (unlikely(!skb))
> +		return 0;
> +
> +	/* common for all type of bus errors */
> +	priv->can.can_stats.bus_error++;
> +	stats->rx_errors++;
> +	cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
> +	cf->data[2] |= CAN_ERR_PROT_UNSPEC;
> +
> +	switch (lec_type) {
> +	case LEC_STUFF_ERROR:
> +		netdev_dbg(dev, "stuff error\n");
> +		cf->data[2] |= CAN_ERR_PROT_STUFF;
> +		break;
> +	case LEC_FORM_ERROR:
> +		netdev_dbg(dev, "form error\n");
> +		cf->data[2] |= CAN_ERR_PROT_FORM;
> +		break;
> +	case LEC_ACK_ERROR:
> +		netdev_dbg(dev, "ack error\n");
> +		cf->data[2] |= (CAN_ERR_PROT_LOC_ACK |
> +				CAN_ERR_PROT_LOC_ACK_DEL);
> +		break;
> +	case LEC_BIT1_ERROR:
> +		netdev_dbg(dev, "bit1 error\n");
> +		cf->data[2] |= CAN_ERR_PROT_BIT1;
> +		break;
> +	case LEC_BIT0_ERROR:
> +		netdev_dbg(dev, "bit0 error\n");
> +		cf->data[2] |= CAN_ERR_PROT_BIT0;
> +		break;
> +	case LEC_CRC_ERROR:
> +		netdev_dbg(dev, "CRC error\n");
> +		cf->data[2] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
> +				CAN_ERR_PROT_LOC_CRC_DEL);
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	/* set a LEC value so that we can check for updates later */
> +	d_can_write(priv, D_CAN_ES, LEC_UNUSED);
> +
> +	netif_receive_skb(skb);
> +	stats->rx_packets++;
> +	stats->rx_bytes += cf->can_dlc;
> +
> +	return 1;
> +}
> +
> +static int d_can_poll(struct napi_struct *napi, int quota)
> +{
> +	int work_done = 0;
> +	int lec_type = 0;
> +	struct net_device *dev = napi->dev;
> +	struct d_can_priv *priv = netdev_priv(dev);
> +
> +	if (!priv->irqstatus)
> +		goto end;
> +
> +	/* status events have the highest priority */
> +	if (priv->irqstatus == D_CAN_STATUS_INTERRUPT) {
> +		priv->current_status = d_can_read(priv, D_CAN_ES);
> +
> +		/* handle Tx/Rx events */
> +		if (priv->current_status & D_CAN_ES_TXOK)
> +			d_can_write(priv, D_CAN_ES,
> +					priv->current_status & ~D_CAN_ES_TXOK);
> +
> +		if (priv->current_status & D_CAN_ES_RXOK)
> +			d_can_write(priv, D_CAN_ES,
> +					priv->current_status & ~D_CAN_ES_RXOK);
> +
> +		/* handle state changes */
> +		if ((priv->current_status & D_CAN_ES_EWARN) &&
> +				(!(priv->last_status & D_CAN_ES_EWARN))) {
> +			netdev_dbg(dev, "entered error warning state\n");
> +			work_done += d_can_handle_state_change(dev,
> +						ERROR_WARNING);
> +		}
> +		if ((priv->current_status & D_CAN_ES_EPASS) &&
> +				(!(priv->last_status & D_CAN_ES_EPASS))) {
> +			netdev_dbg(dev, "entered error passive state\n");
> +			work_done += d_can_handle_state_change(dev,
> +						ERROR_PASSIVE);
> +		}
> +		if ((priv->current_status & D_CAN_ES_BOFF) &&
> +				(!(priv->last_status & D_CAN_ES_BOFF))) {
> +			netdev_dbg(dev, "entered bus off state\n");
> +			work_done += d_can_handle_state_change(dev, BUS_OFF);
> +		}
> +
> +		/* handle bus recovery events */
> +		if ((!(priv->current_status & D_CAN_ES_BOFF)) &&
> +				(priv->last_status & D_CAN_ES_BOFF)) {
> +			netdev_dbg(dev, "left bus off state\n");
> +			priv->can.state = CAN_STATE_ERROR_ACTIVE;
> +		}
> +		if ((!(priv->current_status & D_CAN_ES_EPASS)) &&
> +				(priv->last_status & D_CAN_ES_EPASS)) {
> +			netdev_dbg(dev, "left error passive state\n");
> +			priv->can.state = CAN_STATE_ERROR_ACTIVE;
> +		}
> +		priv->last_status = priv->current_status;
> +
> +		/* handle lec errors on the bus */
> +		lec_type = d_can_has_handle_berr(priv);
> +		if (lec_type)
> +			work_done += d_can_handle_bus_err(dev, lec_type);
> +	} else if ((priv->irqstatus >= D_CAN_MSG_OBJ_RX_FIRST) &&
> +			(priv->irqstatus <= D_CAN_MSG_OBJ_RX_LAST)) {
> +		/* handle events corresponding to receive message objects */
> +		work_done += d_can_do_rx_poll(dev, (quota - work_done));
> +	} else if ((priv->irqstatus >= D_CAN_MSG_OBJ_TX_FIRST) &&
> +			(priv->irqstatus <= D_CAN_MSG_OBJ_TX_LAST)) {
> +		/* handle events corresponding to transmit message objects */
> +		d_can_do_tx(dev);
> +	}
> +end:
> +	if (work_done < quota) {
> +		napi_complete(napi);
> +		d_can_interrupts(priv, D_CAN_ENABLE_ALL_INTERRUPTS);
> +	}
> +	return work_done;
> +}
> +
> +static irqreturn_t d_can_isr(int irq, void *dev_id)
> +{
> +	struct net_device *dev = (struct net_device *)dev_id;
> +	struct d_can_priv *priv = netdev_priv(dev);
> +
> +	priv->irqstatus = d_can_read(priv, D_CAN_INT);
> +	if (!priv->irqstatus)
> +		return IRQ_NONE;
> +
> +	/* disable all interrupts and schedule the NAPI */
> +	d_can_interrupts(priv, D_CAN_DISABLE_ALL_INTERRUPTS);
> +	napi_schedule(&priv->napi);
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static int d_can_open(struct net_device *ndev)
> +{
> +	int err;
> +	struct d_can_priv *priv = netdev_priv(ndev);
> +
> +	/* Open common can device */
> +	err = open_candev(ndev);
> +	if (err) {
> +		netdev_err(ndev, "open_candev() failed %d\n", err);
> +		return err;
> +	}
> +
> +	err = request_irq(ndev->irq, &d_can_isr, IRQF_SHARED, ndev->name,
> +				ndev);
> +	if (err) {
> +		netdev_err(ndev, "failed to request MO_ES interrupt\n");
> +		goto exit_close_candev;
> +	}
> +
> +	/* start the d_can controller */
> +	d_can_start(ndev);
> +	napi_enable(&priv->napi);
> +	netif_start_queue(ndev);
> +	priv->is_opened = true;
> +
> +	return 0;
> +exit_close_candev:
> +	close_candev(ndev);
> +	return err;
> +}
> +
> +static int d_can_close(struct net_device *ndev)
> +{
> +	struct d_can_priv *priv = netdev_priv(ndev);
> +
> +	netif_stop_queue(ndev);
> +	napi_disable(&priv->napi);
> +	d_can_stop(ndev);
> +	free_irq(ndev->irq, ndev);
> +	close_candev(ndev);
> +	priv->is_opened = false;
> +
> +	return 0;
> +}
> +
> +static void d_can_reset_ram(struct d_can_priv *d_can, unsigned int instance,
> +					unsigned int enable)
> +{
> +	if (d_can->ram_init)
> +		d_can->ram_init(instance, enable);
> +	/* Give some time delay for DCAN RAM initialization */
> +	udelay(1);
> +}
> +
> +static struct net_device *alloc_d_can_dev(unsigned int num_objs)
> +{
> +	struct net_device *dev;
> +	struct d_can_priv *priv;
> +
> +	dev = alloc_candev(sizeof(struct d_can_priv), num_objs/2);
> +	if (!dev)
> +		return NULL;
> +
> +	priv = netdev_priv(dev);
> +	netif_napi_add(dev, &priv->napi, d_can_poll, num_objs/2);
> +
> +	priv->dev = dev;
> +	priv->can.bittiming_const = &d_can_bittiming_const;
> +	priv->can.do_set_mode = d_can_set_mode;
> +	priv->can.do_get_berr_counter = d_can_get_berr_counter;
> +	priv->can.ctrlmode_supported = (CAN_CTRLMODE_LOOPBACK |
> +					CAN_CTRLMODE_LISTENONLY |
> +					CAN_CTRLMODE_BERR_REPORTING |
> +					CAN_CTRLMODE_3_SAMPLES);
> +	return dev;
> +}
> +
> +static void free_d_can_dev(struct net_device *dev)
> +{
> +	free_candev(dev);
> +}
> +
> +static const struct net_device_ops d_can_netdev_ops = {
> +	.ndo_open	= d_can_open,
> +	.ndo_stop	= d_can_close,
> +	.ndo_start_xmit	= d_can_start_xmit,
> +};
> +
> +static int register_d_can_dev(struct net_device *dev)
> +{
> +	/* we support local echo */
> +	dev->flags |= IFF_ECHO;
> +	dev->netdev_ops = &d_can_netdev_ops;
> +	return register_candev(dev);
> +}
> +
> +static void unregister_d_can_dev(struct net_device *dev)
> +{
> +	struct d_can_priv *priv = netdev_priv(dev);
> +
> +	d_can_interrupts(priv, D_CAN_DISABLE_ALL_INTERRUPTS);
> +	unregister_candev(dev);
> +}
> +
> +static int __devinit d_can_plat_probe(struct platform_device *pdev)
> +{
> +	int ret = 0;
> +	void __iomem *addr;
> +	struct net_device *ndev;
> +	struct d_can_priv *priv;
> +	struct resource *mem, *irq;
> +	struct d_can_platform_data *pdata;
> +	struct clk *fck;
> +
> +	pdata = pdev->dev.platform_data;
> +	if (!pdata) {
> +		dev_err(&pdev->dev, "No platform data\n");
> +		goto exit;
> +	}
> +
> +	/* get the platform data */
> +	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	if (!mem) {
> +		ret = -ENODEV;
> +		dev_err(&pdev->dev, "No mem resource\n");
> +		goto exit;
> +	}
> +	irq = platform_get_resource_byname(pdev, IORESOURCE_IRQ, "d_can_ms");
> +	if (!irq) {
> +		dev_err(&pdev->dev, "No irq resource\n");
> +		goto exit;
> +	}
> +	if (!request_mem_region(mem->start, resource_size(mem),
> +				D_CAN_DRV_NAME)) {
> +		dev_err(&pdev->dev, "resource unavailable\n");
> +		ret = -EBUSY;
> +		goto exit;
> +	}
> +	addr = ioremap(mem->start, resource_size(mem));
> +	if (!addr) {
> +		dev_err(&pdev->dev, "ioremap failed\n");
> +		ret = -ENOMEM;
> +		goto exit_release_mem;
> +	}
> +
> +	/* allocate the d_can device */
> +	ndev = alloc_d_can_dev(pdata->num_of_msg_objs);
> +	if (!ndev) {
> +		dev_err(&pdev->dev, "alloc_d_can_dev failed\n");
> +		ret = -ENOMEM;
> +		goto exit_iounmap;
> +	}
> +	fck = clk_get(&pdev->dev, "fck");
> +	if (IS_ERR(fck)) {
> +		dev_err(&pdev->dev, "fck is not found\n");
> +		ret = -ENODEV;
> +		goto exit_free_ndev;
> +	}
> +
> +	priv = netdev_priv(ndev);
> +	priv->base = addr;
> +	priv->can.clock.freq = clk_get_rate(fck);
> +	priv->ram_init = pdata->ram_init;
> +	priv->is_opened = false;
> +
> +	ndev->irq = irq->start;
> +	platform_set_drvdata(pdev, ndev);
> +	SET_NETDEV_DEV(ndev, &pdev->dev);
> +
> +	pm_runtime_enable(&pdev->dev);
> +	pm_runtime_get_sync(&pdev->dev);
> +
> +	ret = register_d_can_dev(ndev);
> +	if (ret) {
> +		dev_err(&pdev->dev, "registering %s failed (err = %d)\n",
> +				D_CAN_DRV_NAME, ret);
> +		goto exit_free_device;
> +	}
> +
> +	/* Initialize DCAN RAM */
> +	d_can_reset_ram(priv, pdev->id, 1);
> +
> +	dev_info(&pdev->dev, "device registered (irq = %d)\n", ndev->irq);
> +	return 0;
> +exit_free_device:
> +	platform_set_drvdata(pdev, NULL);
> +	pm_runtime_disable(&pdev->dev);
> +	clk_put(fck);
> +exit_free_ndev:
> +	free_d_can_dev(ndev);
> +exit_iounmap:
> +	iounmap(addr);
> +exit_release_mem:
> +	release_mem_region(mem->start, resource_size(mem));
> +exit:
> +	dev_err(&pdev->dev, "probe failed\n");
> +	return ret;
> +}
> +
> +static int __devexit d_can_plat_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev = platform_get_drvdata(pdev);
> +	struct d_can_priv *priv = netdev_priv(ndev);
> +	struct resource *mem;
> +
> +	d_can_reset_ram(priv, pdev->id, 0);
> +
> +	unregister_d_can_dev(ndev);
> +	platform_set_drvdata(pdev, NULL);
> +
> +	free_d_can_dev(ndev);
> +	iounmap(priv->base);
> +
> +	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	release_mem_region(mem->start, resource_size(mem));
> +
> +	pm_runtime_put_sync(&pdev->dev);
> +	pm_runtime_disable(&pdev->dev);
> +
> +	return 0;
> +}
> +
> +#ifdef CONFIG_PM
> +static int d_can_suspend(struct platform_device *pdev, pm_message_t state)
> +{
> +	unsigned long time_out;
> +	struct net_device *ndev = platform_get_drvdata(pdev);
> +	struct d_can_priv *priv = netdev_priv(ndev);
> +
> +	if (netif_running(ndev)) {
> +		netif_stop_queue(ndev);
> +		netif_device_detach(ndev);
> +	}
> +
> +	d_can_set_bit(priv, D_CAN_CTL, D_CAN_CTL_PDR);
> +
> +	/* PDA bit will become high only when all the pending
> +	 * transfers are completed */
> +	time_out = jiffies + msecs_to_jiffies(D_CAN_TIMEOUT_MS);
> +	while (!d_can_get_bit(priv, D_CAN_ES, D_CAN_ES_PDA) &&
> +				time_after(time_out, jiffies))
> +		cpu_relax();
> +
> +	if (time_after(jiffies, time_out)) {
> +		netdev_err(ndev, "Not entered power down mode\n");
> +		return -ETIMEDOUT;
> +	}
> +
> +	if (priv->is_opened)
> +		d_can_stop(ndev);
> +
> +	priv->can.state = CAN_STATE_SLEEPING;
> +	/* De-initialize DCAN RAM */
> +	d_can_reset_ram(priv, pdev->id, 0);
> +	/* Disable the module */
> +	pm_runtime_put_sync(&pdev->dev);
> +	return 0;
> +}
> +
> +static int d_can_resume(struct platform_device *pdev)
> +{
> +	unsigned long time_out;
> +	struct net_device *ndev = platform_get_drvdata(pdev);
> +	struct d_can_priv *priv = netdev_priv(ndev);
> +
> +	/* Enable the module */
> +	pm_runtime_get_sync(&pdev->dev);
> +	/* Initialize DCAN RAM */
> +	d_can_reset_ram(priv, pdev->id, 1);
> +
> +	/* Brought back from power down mode */
> +	d_can_clear_bit(priv, D_CAN_CTL, D_CAN_CTL_PDR);
> +	d_can_clear_bit(priv, D_CAN_CTL, D_CAN_CTL_INIT);
> +
> +	/* Wait for the PDA bit to get clear */
> +	time_out = jiffies + msecs_to_jiffies(D_CAN_TIMEOUT_MS);
> +	while (d_can_get_bit(priv, D_CAN_ES, D_CAN_ES_PDA) &&
> +				time_after(time_out, jiffies))
> +		cpu_relax();
> +
> +	if (time_after(jiffies, time_out)) {
> +		netdev_err(ndev, "Not came out from power down mode\n");
> +		return -ETIMEDOUT;
> +	}
> +
> +	if (priv->is_opened)
> +		d_can_start(ndev);
> +
> +	priv->can.state = CAN_STATE_ERROR_ACTIVE;
> +
> +	if (netif_running(ndev)) {
> +		netif_device_attach(ndev);
> +		netif_start_queue(ndev);
> +	}
> +	return 0;
> +}
> +#else
> +#define d_can_suspend NULL
> +#define d_can_resume NULL
> +#endif
> +
> +static struct platform_driver d_can_plat_driver = {
> +	.driver = {
> +		.name	= D_CAN_DRV_NAME,
> +		.owner	= THIS_MODULE,
> +	},
> +	.probe		= d_can_plat_probe,
> +	.remove		= __devexit_p(d_can_plat_remove),
> +	.suspend	= d_can_suspend,
> +	.resume		= d_can_resume,
> +};
> +
> +static int __init d_can_plat_init(void)
> +{
> +	return platform_driver_register(&d_can_plat_driver);
> +}
> +module_init(d_can_plat_init);
> +
> +static void __exit d_can_plat_exit(void)
> +{
> +	platform_driver_unregister(&d_can_plat_driver);
> +}
> +module_exit(d_can_plat_exit);
> +
> +MODULE_AUTHOR("AnilKumar Ch <anilkumar@ti.com>");
> +MODULE_LICENSE("GPL v2");
> +MODULE_VERSION(D_CAN_VERSION);
> +MODULE_DESCRIPTION(D_CAN_DRV_DESC);
> diff --git a/include/linux/can/platform/d_can.h b/include/linux/can/platform/d_can.h
> new file mode 100644
> index 0000000..b6f2a3f
> --- /dev/null
> +++ b/include/linux/can/platform/d_can.h
> @@ -0,0 +1,40 @@
> +/*
> + * D_CAN controller driver platform header
> + *
> + * Copyright (C) 2012 Texas Instruments Incorporated - http://www.ti.com/
> + *
> + * Bosch D_CAN controller is compliant to CAN protocol version 2.0 part A and B.
> + * Bosch D_CAN user manual can be obtained from:
> + * http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/can/
> + * d_can_users_manual_111.pdf
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License as
> + * published by the Free Software Foundation version 2.
> + *
> + * This program is distributed "as is" WITHOUT ANY WARRANTY of any
> + * kind, whether express or implied; without even the implied warranty
> + * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +#ifndef __CAN_PLATFORM_TI_D_CAN_H__
> +#define __CAN_PLATFORM_TI_D_CAN_H__
> +
> +/**
> + * struct d_can_platform_data - DCAN Platform Data
> + *
> + * @num_of_msg_objs:	Number of message objects
> + * @dma_support:	DMA support is required/not
> + * @ram_init:		DCAN RAM initialization
> + *
> + * Platform data structure to get all platform specific settings.
> + * this structure also accounts the fact that the IP may have different
> + * RAM and mailbox offsets for different SOC's
> + */
> +struct d_can_platform_data {
> +	unsigned int num_of_msg_objs;
> +	bool dma_support;
> +	void (*ram_init) (unsigned int instance, unsigned int eanble);
> +};
> +#endif

