From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] CAN: Add Flexcan CAN controller driver
Date: Thu, 15 Jul 2010 20:38:33 +0200
Message-ID: <4C3F55A9.8030307@grandegger.com>
References: <1279144811-12251-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1279144811-12251-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

Hi Marc,

On 07/15/2010 12:00 AM, Marc Kleine-Budde wrote:
> From: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> =

> This core is found on some Freescale SoCs and also some Coldfire
> SoCs. Support for Coldfire is missing though at the moment as
> they have an older revision of the core which does not have RX FIFO
> support.
> =

> Signed-off-by: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> ---
> =

> Changes to prev version:
> * The is now GPLv2 (only) as no one complained.
> =

> The patch applies to current net-next-2.6/master.
> If there aren't any objections please consider applying this patch.
> Wolfgang, can I an Acked-by?

I realized a few issues. You can add my "acked-by" when they are fixed.

> =

> Cheers, Marc
> =

> P.S.:
> This patch can be pulled, too:
> =

> The following changes since commit fae88f7eedae42c955075aec7a0cd27545f815=
11:
> =

>   Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/g=
it/linville/wireless-next-2.6 (2010-07-13 14:25:13 -0700)
> =

> are available in the git repository at:
> =

>   git://git.pengutronix.de/git/mkl/linux-2.6.git for-net-next-2.6
> =

> Sascha Hauer (1):
>       CAN: Add Flexcan CAN controller driver
> =

>  drivers/net/can/Kconfig              |    6 +
>  drivers/net/can/Makefile             |    1 +
>  drivers/net/can/flexcan.c            | 1005 ++++++++++++++++++++++++++++=
++++++
>  include/linux/can/platform/flexcan.h |   20 +
>  4 files changed, 1032 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/flexcan.c
>  create mode 100644 include/linux/can/platform/flexcan.h
> =

> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 2c5227c..3f13299 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -73,6 +73,12 @@ config CAN_JANZ_ICAN3
>  	  This driver can also be built as a module. If so, the module will be
>  	  called janz-ican3.ko.
>  =

> +config CAN_FLEXCAN
> +	tristate "Support for Freescale FLEXCAN based chips"
> +	depends on CAN_DEV

Some more arch specific dependencies would be nice.

> +	---help---
> +	  Say Y here if you want to support for Freescale FlexCAN.
> +
>  source "drivers/net/can/mscan/Kconfig"
>  =

>  source "drivers/net/can/sja1000/Kconfig"
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 9047cd0..0057537 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -16,5 +16,6 @@ obj-$(CONFIG_CAN_TI_HECC)	+=3D ti_hecc.o
>  obj-$(CONFIG_CAN_MCP251X)	+=3D mcp251x.o
>  obj-$(CONFIG_CAN_BFIN)		+=3D bfin_can.o
>  obj-$(CONFIG_CAN_JANZ_ICAN3)	+=3D janz-ican3.o
> +obj-$(CONFIG_CAN_FLEXCAN)	+=3D flexcan.o
>  =

>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) :=3D -DDEBUG
> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> new file mode 100644
> index 0000000..a3180ba
> --- /dev/null
> +++ b/drivers/net/can/flexcan.c
> @@ -0,0 +1,1005 @@
> +/*
> + * flexcan.c - FLEXCAN CAN controller driver
> + *
> + * Copyright (c) 2005-2006 Varma Electronics Oy
> + * Copyright (c) 2009 Sascha Hauer, Pengutronix
> + * Copyright (c) 2010 Marc Kleine-Budde, Pengutronix
> + *
> + * Based on code originally by Andrey Volkov <avolkov-ppI4tVfbJvJWk0Htik3J/w@public.gmane.org>
> + *
> + * LICENCE:
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License as
> + * published by the Free Software Foundation version 2.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + */
> +
> +#include <linux/netdevice.h>
> +#include <linux/can.h>
> +#include <linux/can/dev.h>
> +#include <linux/can/error.h>
> +#include <linux/can/platform/flexcan.h>
> +#include <linux/clk.h>
> +#include <linux/delay.h>
> +#include <linux/if_arp.h>
> +#include <linux/if_ether.h>
> +#include <linux/interrupt.h>
> +#include <linux/io.h>
> +#include <linux/kernel.h>
> +#include <linux/list.h>
> +#include <linux/module.h>
> +#include <linux/platform_device.h>
> +
> +
> +#include <mach/clock.h>
> +
> +#define DRV_NAME		"flexcan"
> +#define FLEXCAN_NAPI_WEIGHT	8
> +
> +
> +/* FLEXCAN module configuration register (CANMCR) bits */
> +#define FLEXCAN_MCR_MDIS		BIT(31)
> +#define FLEXCAN_MCR_FRZ			BIT(30)
> +#define FLEXCAN_MCR_FEN			BIT(29)
> +#define FLEXCAN_MCR_HALT		BIT(28)
> +#define FLEXCAN_MCR_NOT_RDY		BIT(27)
> +#define FLEXCAN_MCR_WAK_MSK		BIT(26)
> +#define FLEXCAN_MCR_SOFTRST		BIT(25)
> +#define FLEXCAN_MCR_FRZ_ACK		BIT(24)
> +#define FLEXCAN_MCR_SUPV		BIT(23)
> +#define FLEXCAN_MCR_SLF_WAK		BIT(22)
> +#define FLEXCAN_MCR_WRN_EN		BIT(21)
> +#define FLEXCAN_MCR_LPM_ACK		BIT(20)
> +#define FLEXCAN_MCR_WAK_SRC		BIT(19)
> +#define FLEXCAN_MCR_DOZE		BIT(18)
> +#define FLEXCAN_MCR_SRX_DIS		BIT(17)
> +#define FLEXCAN_MCR_BCC			BIT(16)
> +#define FLEXCAN_MCR_LPRIO_EN		BIT(13)
> +#define FLEXCAN_MCR_AEN			BIT(12)
> +#define FLEXCAN_MCR_MAXMB(x)		((x) & 0xf)
> +#define FLEXCAN_MCR_IDAM_A		(0 << 8)
> +#define FLEXCAN_MCR_IDAM_B		(1 << 8)
> +#define FLEXCAN_MCR_IDAM_C		(2 << 8)
> +#define FLEXCAN_MCR_IDAM_D		(3 << 8)
> +
> +/* FLEXCAN control register (CANCTRL) bits */
> +#define FLEXCAN_CTRL_PRESDIV(x)		(((x) & 0xff) << 24)
> +#define FLEXCAN_CTRL_RJW(x)		(((x) & 0x03) << 22)
> +#define FLEXCAN_CTRL_PSEG1(x)		(((x) & 0x07) << 19)
> +#define FLEXCAN_CTRL_PSEG2(x)		(((x) & 0x07) << 16)
> +#define FLEXCAN_CTRL_BOFF_MSK		BIT(15)
> +#define FLEXCAN_CTRL_ERR_MSK		BIT(14)
> +#define FLEXCAN_CTRL_CLK_SRC		BIT(13)
> +#define FLEXCAN_CTRL_LPB		BIT(12)
> +#define FLEXCAN_CTRL_TWRN_MSK		BIT(11)
> +#define FLEXCAN_CTRL_RWRN_MSK		BIT(10)
> +#define FLEXCAN_CTRL_SMP		BIT(7)
> +#define FLEXCAN_CTRL_BOFF_REC		BIT(6)
> +#define FLEXCAN_CTRL_TSYNC		BIT(5)
> +#define FLEXCAN_CTRL_LBUF		BIT(4)
> +#define FLEXCAN_CTRL_LOM		BIT(3)
> +#define FLEXCAN_CTRL_PROPSEG(x)		((x) & 0x07)
> +
> +/* FLEXCAN error and status register (ESR) bits */
> +#define FLEXCAN_ESR_TWRN_INT		BIT(17)
> +#define FLEXCAN_ESR_RWRN_INT		BIT(16)
> +#define FLEXCAN_ESR_BIT1_ERR		BIT(15)
> +#define FLEXCAN_ESR_BIT0_ERR		BIT(14)
> +#define FLEXCAN_ESR_ACK_ERR		BIT(13)
> +#define FLEXCAN_ESR_CRC_ERR		BIT(12)
> +#define FLEXCAN_ESR_FRM_ERR		BIT(11)
> +#define FLEXCAN_ESR_STF_ERR		BIT(10)
> +#define FLEXCAN_ESR_TX_WRN		BIT(9)
> +#define FLEXCAN_ESR_RX_WRN		BIT(8)
> +#define FLEXCAN_ESR_IDLE		BIT(7)
> +#define FLEXCAN_ESR_TXRX		BIT(6)
> +#define FLEXCAN_EST_FLT_CONF_SHIFT	(4)
> +#define FLEXCAN_ESR_FLT_CONF_MASK	(0x2 << FLEXCAN_EST_FLT_CONF_SHIFT)
> +#define FLEXCAN_ESR_FLT_CONF_ACTIVE	(0x0 << FLEXCAN_EST_FLT_CONF_SHIFT)
> +#define FLEXCAN_ESR_FLT_CONF_PASSIVE	(0x1 << FLEXCAN_EST_FLT_CONF_SHIFT)
> +#define FLEXCAN_ESR_BOFF_INT		BIT(2)
> +#define FLEXCAN_ESR_ERR_INT		BIT(1)
> +#define FLEXCAN_ESR_WAK_INT		BIT(0)
> +#define FLEXCAN_ESR_ERR_FRAME \
> +	(FLEXCAN_ESR_BIT1_ERR | FLEXCAN_ESR_BIT0_ERR | \
> +	 FLEXCAN_ESR_ACK_ERR | FLEXCAN_ESR_CRC_ERR | \
> +	 FLEXCAN_ESR_FRM_ERR | FLEXCAN_ESR_STF_ERR)
> +#define FLEXCAN_ESR_ERR_LINE \
> +	(FLEXCAN_ESR_TWRN_INT | FLEXCAN_ESR_RWRN_INT | FLEXCAN_ESR_BOFF_INT)
> +
> +/* FLEXCAN interrupt flag register (IFLAG) bits */
> +#define FLEXCAN_TX_BUF_ID		8
> +#define FLEXCAN_IFLAG_BUF(x)		BIT(x)
> +#define FLEXCAN_IFLAG_RX_FIFO_OVERFLOW	BIT(7)
> +#define FLEXCAN_IFLAG_RX_FIFO_WARN	BIT(6)
> +#define FLEXCAN_IFLAG_RX_FIFO_AVAILABLE	BIT(5)
> +#define FLEXCAN_IFLAG_DEFAULT \
> +	(FLEXCAN_IFLAG_RX_FIFO_OVERFLOW | FLEXCAN_IFLAG_RX_FIFO_AVAILABLE | \
> +	 FLEXCAN_IFLAG_BUF(FLEXCAN_TX_BUF_ID))
> +
> +/* FLEXCAN message buffers */
> +#define FLEXCAN_MB_CNT_CODE(x)		(((x) & 0xf) << 24)
> +#define FLEXCAN_MB_CNT_SRR		BIT(22)
> +#define FLEXCAN_MB_CNT_IDE		BIT(21)
> +#define FLEXCAN_MB_CNT_RTR		BIT(20)
> +#define FLEXCAN_MB_CNT_LENGTH(x)	(((x) & 0xf) << 16)
> +#define FLEXCAN_MB_CNT_TIMESTAMP(x)	((x) & 0xffff)
> +
> +#define FLEXCAN_MB_CODE_MASK		(0xf0ffffff)
> +
> +/* Structure of the message buffer */
> +struct flexcan_mb {
> +	u32 can_ctrl;
> +	u32 can_id;
> +	u32 data[2];
> +};
> +
> +/* Structure of the hardware registers */
> +struct flexcan_regs {
> +	u32 mcr;		/* 0x00 */
> +	u32 ctrl;		/* 0x04 */
> +	u32 timer;		/* 0x08 */
> +	u32 _reserved1;		/* 0x0c */
> +	u32 rxgmask;		/* 0x10 */
> +	u32 rx14mask;		/* 0x14 */
> +	u32 rx15mask;		/* 0x18 */
> +	u32 ecr;		/* 0x1c */
> +	u32 esr;		/* 0x20 */
> +	u32 imask2;		/* 0x24 */
> +	u32 imask1;		/* 0x28 */
> +	u32 iflag2;		/* 0x2c */
> +	u32 iflag1;		/* 0x30 */
> +	u32 _reserved2[19];
> +	struct flexcan_mb cantxfg[64];
> +};
> +
> +struct flexcan_priv {
> +	struct can_priv can;
> +	struct net_device *dev;
> +	struct napi_struct napi;
> +
> +	void __iomem *base;
> +	u32 reg_esr;
> +	u32 reg_ctrl_default;
> +
> +	struct clk *clk;
> +	struct flexcan_platform_data *pdata;
> +};
> +
> +static struct can_bittiming_const flexcan_bittiming_const =3D {
> +	.name =3D DRV_NAME,
> +	.tseg1_min =3D 4,
> +	.tseg1_max =3D 16,
> +	.tseg2_min =3D 2,
> +	.tseg2_max =3D 8,
> +	.sjw_max =3D 4,
> +	.brp_min =3D 1,
> +	.brp_max =3D 256,
> +	.brp_inc =3D 1,
> +};
> +
> +/*
> + * Swtich transceiver on or off
> + */
> +static void flexcan_transceiver_switch(const struct flexcan_priv *priv, =
int on)
> +{
> +	if (priv->pdata && priv->pdata->transceiver_switch)
> +		priv->pdata->transceiver_switch(on);
> +}
> +
> +static inline void flexcan_chip_enable(struct flexcan_priv *priv)
> +{
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	u32 reg;
> +
> +	reg =3D readl(&regs->mcr);
> +	reg &=3D ~FLEXCAN_MCR_MDIS;
> +	writel(reg, &regs->mcr);
> +
> +	udelay(10);
> +}
> +
> +static inline void flexcan_chip_disable(struct flexcan_priv *priv)
> +{
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	u32 reg;
> +
> +	reg =3D readl(&regs->mcr);
> +	reg |=3D FLEXCAN_MCR_MDIS;
> +	writel(reg, &regs->mcr);
> +}
> +
> +static int flexcan_get_berr_counter(const struct net_device *dev,
> +				    struct can_berr_counter *bec)
> +{
> +	const struct flexcan_priv *priv =3D netdev_priv(dev);
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	u32 reg =3D readl(&regs->ecr);
> +
> +	bec->txerr =3D (reg >> 0) & 0xff;
> +	bec->rxerr =3D (reg >> 8) & 0xff;
> +
> +	return 0;
> +}
> +
> +
> +static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *de=
v)
> +{
> +	const struct flexcan_priv *priv =3D netdev_priv(dev);
> +	struct net_device_stats *stats =3D &dev->stats;
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	struct can_frame *frame =3D (struct can_frame *)skb->data;
> +	u32 can_id;
> +	u32 ctrl =3D FLEXCAN_MB_CNT_CODE(0xc) | (frame->can_dlc << 16);
> +
> +	if (can_dropped_invalid_skb(dev, skb))
> +		return NETDEV_TX_OK;
> +
> +	netif_stop_queue(dev);
> +
> +	if (frame->can_id & CAN_EFF_FLAG) {
> +		can_id =3D frame->can_id & CAN_EFF_MASK;
> +		ctrl |=3D FLEXCAN_MB_CNT_IDE | FLEXCAN_MB_CNT_SRR;
> +	} else {
> +		can_id =3D (frame->can_id & CAN_SFF_MASK) << 18;
> +	}
> +
> +	if (frame->can_id & CAN_RTR_FLAG)
> +		ctrl |=3D FLEXCAN_MB_CNT_RTR;
> +
> +	if (frame->can_dlc > 0) {
> +		u32 data;
> +		data =3D frame->data[0] << 24;
> +		data |=3D frame->data[1] << 16;
> +		data |=3D frame->data[2] << 8;
> +		data |=3D frame->data[3];
> +		writel(data, &regs->cantxfg[FLEXCAN_TX_BUF_ID].data[0]);
> +	}

IIRC, in your review of J=FCrgens patch you suggested to use be32_to_cpu he=
re.

> +	if (frame->can_dlc > 3) {
> +		u32 data;
> +		data =3D frame->data[4] << 24;
> +		data |=3D frame->data[5] << 16;
> +		data |=3D frame->data[6] << 8;
> +		data |=3D frame->data[7];
> +		writel(data, &regs->cantxfg[FLEXCAN_TX_BUF_ID].data[1]);
> +	}

Ditto.

> +	writel(can_id, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_id);
> +	writel(ctrl, &regs->cantxfg[FLEXCAN_TX_BUF_ID].can_ctrl);
> +
> +	kfree_skb(skb);
> +
> +	stats->tx_bytes +=3D frame->can_dlc;
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +
> +static void flexcan_poll_err_frame(struct net_device *dev,
> +				   struct can_frame *cf, u32 reg_esr)
> +{
> +	struct flexcan_priv *priv =3D netdev_priv(dev);
> +	int error_warning =3D 0, rx_errors =3D 0, tx_errors =3D 0;
> +
> +	if (reg_esr & FLEXCAN_ESR_BIT1_ERR) {
> +		rx_errors =3D 1;
> +		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
> +		cf->data[2] |=3D CAN_ERR_PROT_BIT1;
> +	}
> +
> +	if (reg_esr & FLEXCAN_ESR_BIT0_ERR) {
> +		rx_errors =3D 1;
> +		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
> +		cf->data[2] |=3D CAN_ERR_PROT_BIT0;
> +	}
> +
> +	if (reg_esr & FLEXCAN_ESR_FRM_ERR) {
> +		rx_errors =3D 1;
> +		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
> +		cf->data[2] |=3D CAN_ERR_PROT_FORM;
> +	}
> +
> +	if (reg_esr & FLEXCAN_ESR_STF_ERR) {
> +		rx_errors =3D 1;
> +		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
> +		cf->data[2] |=3D CAN_ERR_PROT_STUFF;
> +	}
> +
> +
> +	if (reg_esr & FLEXCAN_ESR_ACK_ERR) {
> +		tx_errors =3D 1;
> +		cf->can_id |=3D CAN_ERR_ACK;

This is a bus-error as well. Therefore I think it should be:

	if (reg_esr & FLEXCAN_ESR_ACK_ERR) {
		tx_errors =3D 1;
		cf->can_id |=3D CAN_ERR_ACK;
		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
		cf->data[3] |=3D CAN_ERR_PROT_LOC_ACK; /* ACK slot */
	}

I need to check what CAN_ERR_ACK is intended for. Then, cf->can_id could
be preset with "CAN_ERR_PROT | CAN_ERR_BUSERROR" at the beginning.

> +	}
> +
> +	if (error_warning)
> +		priv->can.can_stats.error_warning++;

Hm, error_warning is always 0 !?

> +	if (rx_errors)
> +		dev->stats.rx_errors++;
> +	if (tx_errors)
> +		dev->stats.tx_errors++;
> +
> +}
> +
> +static void flexcan_poll_err(struct net_device *dev, u32 reg_esr)
> +{
> +	struct sk_buff *skb;
> +	struct can_frame *cf;
> +
> +	skb =3D alloc_can_err_skb(dev, &cf);
> +	if (unlikely(!skb))
> +		return;
> +
> +	flexcan_poll_err_frame(dev, cf, reg_esr);
> +	netif_receive_skb(skb);
> +
> +	dev->stats.rx_packets++;
> +	dev->stats.rx_bytes +=3D cf->can_dlc;
> +}
> +
> +static void flexcan_read_fifo(const struct net_device *dev, struct can_f=
rame *cf)
> +{
> +	const struct flexcan_priv *priv =3D netdev_priv(dev);
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	struct flexcan_mb __iomem *mb =3D &regs->cantxfg[0];
> +	u32 reg_ctrl, reg_id;
> +
> +	reg_ctrl =3D readl(&mb->can_ctrl);
> +	reg_id =3D readl(&mb->can_id);
> +	if (reg_ctrl & FLEXCAN_MB_CNT_IDE)
> +		cf->can_id =3D ((reg_id >> 0) & CAN_EFF_MASK) | CAN_EFF_FLAG;
> +	else
> +		cf->can_id =3D (reg_id >> 18) & CAN_SFF_MASK;
> +
> +	if (reg_ctrl & FLEXCAN_MB_CNT_RTR)
> +		cf->can_id |=3D CAN_RTR_FLAG;
> +	cf->can_dlc =3D get_can_dlc((reg_ctrl >> 16) & 0xf);
> +
> +	*(__be32 *)(cf->data + 0) =3D cpu_to_be32(readl(&mb->data[0]));
> +	*(__be32 *)(cf->data + 4) =3D cpu_to_be32(readl(&mb->data[1]));
> +
> +	/* mark as read */
> +	writel(FLEXCAN_IFLAG_RX_FIFO_AVAILABLE, &regs->iflag1);
> +	readl(&regs->timer);
> +}
> +
> +static void flexcan_read_frame(struct net_device *dev)
> +{
> +	struct net_device_stats *stats =3D &dev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +
> +	skb =3D alloc_can_skb(dev, &cf);
> +	if (unlikely(!skb)) {
> +		stats->rx_dropped++;
> +		return;
> +	}
> +
> +	flexcan_read_fifo(dev, cf);
> +	netif_receive_skb(skb);
> +
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->can_dlc;
> +}
> +
> +static int flexcan_poll(struct napi_struct *napi, int quota)
> +{
> +	struct net_device *dev =3D napi->dev;
> +	const struct flexcan_priv *priv =3D netdev_priv(dev);
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	u32 reg_iflag1, reg_esr;
> +	int work_done =3D 0;
> +
> +	reg_iflag1 =3D readl(&regs->iflag1);
> +
> +	/* first handle RX-FIFO */
> +	while (reg_iflag1 & FLEXCAN_IFLAG_RX_FIFO_AVAILABLE &&
> +	       work_done < quota) {
> +		flexcan_read_frame(dev);
> +
> +		work_done++;
> +		reg_iflag1 =3D readl(&regs->iflag1);
> +	}
> +
> +	/*
> +	 * The error bits are clear on read,
> +	 * so use saved value from irq handler.
> +	 */
> +	reg_esr =3D readl(&regs->esr) | priv->reg_esr;

Re-reading reg_esr may cause lost of state changes.

> +	if (work_done < quota) {
> +		flexcan_poll_err(dev, reg_esr);

An error frame is created here for each call of flexcan_poll(), not only
in case of errors.

> +		work_done++;
> +	}
> +
> +	if (work_done < quota) {
> +		napi_complete(napi);
> +		/* enable IRQs */
> +		writel(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
> +		writel(priv->reg_ctrl_default, &regs->ctrl);
> +	}
> +
> +	return work_done;
> +}
> +
> +static void flexcan_irq_err_state(struct net_device *dev,
> +				  struct can_frame *cf, enum can_state new_state)
> +{
> +	struct flexcan_priv *priv =3D netdev_priv(dev);
> +	struct can_berr_counter bec;
> +
> +	flexcan_get_berr_counter(dev, &bec);
> +
> +	switch (priv->can.state) {
> +	case CAN_STATE_ERROR_ACTIVE:
> +		/*
> +		 * from: ERROR_ACTIVE
> +		 * to  : ERROR_WARNING, ERROR_PASSIVE, BUS_OFF
> +		 * =3D>  : there was a warning int
> +		 */
> +		if (new_state >=3D CAN_STATE_ERROR_WARNING &&
> +		    new_state <=3D CAN_STATE_BUS_OFF) {
> +			dev_dbg(dev->dev.parent, "Error Warning IRQ\n");
> +			priv->can.can_stats.error_warning++;
> +
> +			cf->can_id |=3D CAN_ERR_CRTL;
> +			cf->data[1] =3D (bec.txerr > bec.rxerr) ?
> +				CAN_ERR_CRTL_TX_WARNING :
> +				CAN_ERR_CRTL_RX_WARNING;
> +		}
> +	case CAN_STATE_ERROR_WARNING:	/* fallthrough */
> +		/*
> +		 * from: ERROR_ACTIVE, ERROR_WARNING
> +		 * to  : ERROR_PASSIVE, BUS_OFF
> +		 * =3D>  : error passive int
> +		 */
> +		if (new_state >=3D CAN_STATE_ERROR_PASSIVE &&
> +		    new_state <=3D CAN_STATE_BUS_OFF) {
> +			dev_dbg(dev->dev.parent, "Error Passive IRQ\n");
> +			priv->can.can_stats.error_passive++;
> +
> +			cf->can_id |=3D CAN_ERR_CRTL;
> +			cf->data[1] =3D (bec.txerr > bec.rxerr) ?
> +				CAN_ERR_CRTL_TX_PASSIVE :
> +				CAN_ERR_CRTL_RX_PASSIVE;
> +		}
> +		break;
> +	case CAN_STATE_BUS_OFF:
> +		dev_err(dev->dev.parent,
> +			"BUG! hardware recovered automatically from BUS_OFF\n");
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	/* process state changes depending on the new state */
> +	switch (new_state) {
> +	case CAN_STATE_BUS_OFF:
> +		cf->can_id |=3D CAN_ERR_BUSOFF;
> +		can_bus_off(dev);
> +		break;
> +	default:
> +		break;
> +	}
> +}
> +
> +static void flexcan_irq_err(struct net_device *dev)
> +{
> +	struct flexcan_priv *priv =3D netdev_priv(dev);
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	struct sk_buff *skb;
> +	struct can_frame *cf;
> +	enum can_state new_state;
> +	u32 reg_esr;
> +	int flt;
> +
> +	reg_esr =3D readl(&regs->esr);

As discussed, reg_esr is re-read here. Should probably be passed via
function argument.

> +	writel(reg_esr, &regs->esr);
> +
> +	flt =3D reg_esr & FLEXCAN_ESR_FLT_CONF_MASK;
> +	if (likely(flt =3D=3D FLEXCAN_ESR_FLT_CONF_ACTIVE)) {
> +		if (likely(!(reg_esr & (FLEXCAN_ESR_TX_WRN |
> +					FLEXCAN_ESR_RX_WRN))))
> +			new_state =3D CAN_STATE_ERROR_ACTIVE;
> +		else
> +			new_state =3D CAN_STATE_ERROR_WARNING;
> +	} else if (unlikely(flt =3D=3D FLEXCAN_ESR_FLT_CONF_PASSIVE))
> +		new_state =3D CAN_STATE_ERROR_PASSIVE;
> +	else
> +		new_state =3D CAN_STATE_BUS_OFF;
> +
> +	/* state hasn't changed */
> +	if (likely(new_state =3D=3D priv->can.state))
> +		return;
> +
> +	skb =3D alloc_can_err_skb(dev, &cf);
> +	if (unlikely(!skb))
> +		return;
> +
> +	flexcan_irq_err_state(dev, cf, new_state);
> +	netif_rx(skb);
> +
> +	dev->stats.rx_packets++;
> +	dev->stats.rx_bytes +=3D cf->can_dlc;
> +
> +	priv->can.state =3D new_state;
> +}
> +
> +static irqreturn_t flexcan_irq(int irq, void *dev_id)
> +{
> +	struct net_device *dev =3D dev_id;
> +	struct net_device_stats *stats =3D &dev->stats;
> +	struct flexcan_priv *priv =3D netdev_priv(dev);
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	u32 reg_iflag1, reg_esr;
> +
> +	reg_iflag1 =3D readl(&regs->iflag1);
> +	reg_esr =3D readl(&regs->esr);
> +
> +	/* receive or error interrupt -> napi */
> +	if ((reg_iflag1 & FLEXCAN_IFLAG_RX_FIFO_AVAILABLE) ||
> +	    (reg_esr & FLEXCAN_ESR_ERR_FRAME)) {
> +		/*
> +		 * The error bits are cleared on read,
> +		 * save for later use.
> +		 */
> +		priv->reg_esr =3D reg_esr;
> +		writel(FLEXCAN_IFLAG_DEFAULT & ~FLEXCAN_IFLAG_RX_FIFO_AVAILABLE,
> +		       &regs->imask1);
> +		writel(priv->reg_ctrl_default & ~FLEXCAN_CTRL_ERR_MSK,
> +		       &regs->ctrl);
> +		napi_schedule(&priv->napi);
> +	}
> +
> +	/* FIFO overflow */
> +	if (reg_iflag1 & FLEXCAN_IFLAG_RX_FIFO_OVERFLOW) {
> +		writel(FLEXCAN_IFLAG_RX_FIFO_OVERFLOW, &regs->iflag1);
> +		dev->stats.rx_over_errors++;
> +		dev->stats.rx_errors++;
> +	}
> +
> +	/* transmission complete interrupt */
> +	if (reg_iflag1 & (1 << FLEXCAN_TX_BUF_ID)) {
> +		stats->tx_packets++;

Where is stats->tx_bytes incremented?

> +		writel((1 << FLEXCAN_TX_BUF_ID), &regs->iflag1);
> +		netif_wake_queue(dev);
> +	}
> +
> +	/* handle state changes */
> +	flexcan_irq_err(dev);

This does create and send an error message for *each* interrupt, even
for non-error interrupts (RX and TX).

Also, state changes are handled in the hard-irq context, while the
errors are handle in the soft-irq context. This looks tricky and error
prune to me as both are derived from the esr register. State changes and
errors might not be realized in the correct order, etc. It might be
saver to handle both in the poll routine by a common function.

> +
> +	return IRQ_HANDLED;
> +}
> +
> +static void flexcan_set_bittiming(struct net_device *dev)
> +{
> +	const struct flexcan_priv *priv =3D netdev_priv(dev);
> +	const struct can_bittiming *bt =3D &priv->can.bittiming;
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	u32 reg;
> +
> +	reg =3D readl(&regs->ctrl);
> +	reg &=3D ~(FLEXCAN_CTRL_PRESDIV(0xff) |
> +		 FLEXCAN_CTRL_RJW(0x3) |
> +		 FLEXCAN_CTRL_PSEG1(0x7) |
> +		 FLEXCAN_CTRL_PSEG2(0x7) |
> +		 FLEXCAN_CTRL_PROPSEG(0x7) |
> +		 FLEXCAN_CTRL_LPB |
> +		 FLEXCAN_CTRL_SMP |
> +		 FLEXCAN_CTRL_LOM);
> +
> +	reg |=3D FLEXCAN_CTRL_PRESDIV(bt->brp - 1) |
> +		FLEXCAN_CTRL_PSEG1(bt->phase_seg1 - 1) |
> +		FLEXCAN_CTRL_PSEG2(bt->phase_seg2 - 1) |
> +		FLEXCAN_CTRL_RJW(bt->sjw - 1) |
> +		FLEXCAN_CTRL_PROPSEG(bt->prop_seg - 1);
> +
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK)
> +		reg |=3D FLEXCAN_CTRL_LPB;
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY)
> +		reg |=3D FLEXCAN_CTRL_LOM;
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES)
> +		reg |=3D FLEXCAN_CTRL_SMP;
> +
> +	dev_info(dev->dev.parent, "writing ctrl=3D0x%08x\n", reg);
> +	writel(reg, &regs->ctrl);
> +
> +	/* print chip status */
> +	dev_dbg(dev->dev.parent, "%s: mcr=3D0x%08x ctrl=3D0x%08x\n", __func__,
> +		readl(&regs->mcr), readl(&regs->ctrl));

This seems especially useful for development. Please check the other
dev_dbg's as well.

> +}
> +
> +/*
> + * flexcan_chip_start
> + *
> + * this functions is entered with clocks enabled
> + *
> + */
> +static int flexcan_chip_start(struct net_device *dev)
> +{
> +	struct flexcan_priv *priv =3D netdev_priv(dev);
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	unsigned int i;
> +	int err;
> +	u32 reg_mcr, reg_ctrl;
> +
> +	/* enable module */
> +	flexcan_chip_enable(priv);
> +
> +	/* soft reset */
> +	writel(FLEXCAN_MCR_SOFTRST, &regs->mcr);
> +	udelay(10);
> +
> +	reg_mcr =3D readl(&regs->mcr);
> +	if (reg_mcr & FLEXCAN_MCR_SOFTRST) {
> +		dev_err(dev->dev.parent,
> +			"Failed to softreset can module (mcr=3D0x%08x)\n", reg_mcr);
> +		err =3D -ENODEV;
> +		goto out;
> +	}
> +
> +	flexcan_set_bittiming(dev);
> +
> +	/*
> +	 * MCR
> +	 *
> +	 * enable freeze
> +	 * enable fifo
> +	 * halt now
> +	 * only supervisor access
> +	 * enable warning int
> +	 * choose format C
> +	 *
> +	 */
> +	reg_mcr =3D readl(&regs->mcr);
> +	reg_mcr |=3D FLEXCAN_MCR_FRZ | FLEXCAN_MCR_FEN | FLEXCAN_MCR_HALT |
> +		FLEXCAN_MCR_SUPV | FLEXCAN_MCR_WRN_EN |
> +		FLEXCAN_MCR_IDAM_C;
> +	dev_dbg(dev->dev.parent, "%s: writing mcr=3D0x%08x", __func__, reg_mcr);
> +	writel(reg_mcr, &regs->mcr);
> +
> +	/*
> +	 * CTRL
> +	 *
> +	 * enable bus off interrupt
> +	 * disable auto busoff recovery
> +	 * enable tx and rx warning interrupt
> +	 * transmit lowest buffer first
> +	 */
> +	reg_ctrl =3D readl(&regs->ctrl);
> +	reg_ctrl |=3D FLEXCAN_CTRL_BOFF_MSK |FLEXCAN_CTRL_BOFF_REC |
> +		FLEXCAN_CTRL_TWRN_MSK | FLEXCAN_CTRL_RWRN_MSK |
> +		FLEXCAN_CTRL_LBUF;
> +	/*
> +	 * TODO: for now turn on the error interrupt, otherwise we
> +	 * don't get any warning or bus passive interrupts.
> +	 */
> +	reg_ctrl |=3D FLEXCAN_CTRL_ERR_MSK;
> +
> +	/* save for later use */
> +	priv->reg_ctrl_default =3D reg_ctrl;
> +	dev_dbg(dev->dev.parent, "%s: writing ctrl=3D0x%08x", __func__, reg_ctr=
l);
> +	writel(reg_ctrl, &regs->ctrl);
> +
> +	for (i =3D 0; i < ARRAY_SIZE(regs->cantxfg); i++) {
> +		writel(0, &regs->cantxfg[i].can_ctrl);
> +		writel(0, &regs->cantxfg[i].can_id);
> +		writel(0, &regs->cantxfg[i].data[0]);
> +		writel(0, &regs->cantxfg[i].data[1]);
> +
> +		/* put MB into rx queue */
> +		writel(FLEXCAN_MB_CNT_CODE(0x4), &regs->cantxfg[i].can_ctrl);
> +	}
> +
> +	/* acceptance mask/acceptance code (accept everything) */
> +	writel(0x0, &regs->rxgmask);
> +	writel(0x0, &regs->rx14mask);
> +	writel(0x0, &regs->rx15mask);
> +
> +	flexcan_transceiver_switch(priv, 1);
> +
> +	/* synchronize with the can bus */
> +	reg_mcr =3D readl(&regs->mcr);
> +	reg_mcr &=3D ~FLEXCAN_MCR_HALT;
> +	writel(reg_mcr, &regs->mcr);
> +
> +	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +
> +	/* enable FIFO interrupts */
> +	writel(FLEXCAN_IFLAG_DEFAULT, &regs->imask1);
> +
> +	/* print chip status */
> +	dev_dbg(dev->dev.parent, "%s: mcr=3D0x%08x ctrl=3D0x%08x\n", __func__,
> +		readl(&regs->mcr), readl(&regs->ctrl));
> +
> +	return 0;
> +
> + out:
> +	flexcan_chip_disable(priv);
> +	return err;
> +}
> +
> +/*
> + * flexcan_chip_stop
> + *
> + * this functions is entered with clocks enabled
> + *
> + */
> +static void flexcan_chip_stop(struct net_device *dev)
> +{
> +	struct flexcan_priv *priv =3D netdev_priv(dev);
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	u32 reg;
> +
> +	/* Disable all interrupts */
> +	writel(0, &regs->imask1);
> +
> +	/* Disable + halt module */
> +	reg =3D readl(&regs->mcr);
> +	reg |=3D FLEXCAN_MCR_MDIS | FLEXCAN_MCR_HALT;
> +	writel(reg, &regs->mcr);
> +
> +	flexcan_transceiver_switch(priv, 0);
> +	priv->can.state =3D CAN_STATE_STOPPED;
> +
> +	return;
> +}
> +
> +static int flexcan_open(struct net_device *dev)
> +{
> +	struct flexcan_priv *priv =3D netdev_priv(dev);
> +	int err;
> +
> +	clk_enable(priv->clk);
> +
> +	err =3D open_candev(dev);
> +	if (err)
> +		goto out;
> +
> +	err =3D request_irq(dev->irq, flexcan_irq, IRQF_SHARED, dev->name, dev);
> +	if (err)
> +		goto out_close;
> +
> +	/* start chip and queuing */
> +	err =3D flexcan_chip_start(dev);
> +	if (err)
> +		goto out_close;
> +	napi_enable(&priv->napi);
> +	netif_start_queue(dev);
> +
> +	return 0;
> +
> + out_close:
> +	close_candev(dev);
> + out:
> +	clk_disable(priv->clk);
> +
> +	return err;
> +}
> +
> +static int flexcan_close(struct net_device *dev)
> +{
> +	struct flexcan_priv *priv =3D netdev_priv(dev);
> +
> +	netif_stop_queue(dev);
> +	napi_disable(&priv->napi);
> +	flexcan_chip_stop(dev);
> +
> +	free_irq(dev->irq, dev);
> +	clk_disable(priv->clk);
> +
> +	close_candev(dev);
> +
> +	return 0;
> +}
> +
> +static int flexcan_set_mode(struct net_device *dev, enum can_mode mode)
> +{
> +	int err;
> +
> +	switch (mode) {
> +	case CAN_MODE_START:
> +		err =3D flexcan_chip_start(dev);
> +		if (err)
> +			return err;
> +
> +		netif_wake_queue(dev);
> +		break;
> +
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +
> +	return 0;
> +}
> +
> +static const struct net_device_ops flexcan_netdev_ops =3D {
> +	.ndo_open	=3D flexcan_open,
> +	.ndo_stop	=3D flexcan_close,
> +	.ndo_start_xmit	=3D flexcan_start_xmit,
> +};
> +
> +static int __devinit register_flexcandev(struct net_device *dev)
> +{
> +	struct flexcan_priv *priv =3D netdev_priv(dev);
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	u32 reg, err;
> +
> +	clk_enable(priv->clk);
> +
> +	/* select "bus clock", chip must be disabled */
> +	flexcan_chip_disable(priv);
> +	reg =3D readl(&regs->ctrl);
> +	reg |=3D FLEXCAN_CTRL_CLK_SRC;
> +	writel(reg, &regs->ctrl);
> +
> +	flexcan_chip_enable(priv);
> +
> +	/* set freeze, halt and activate FIFO, restrict register access */
> +	reg =3D readl(&regs->mcr);
> +	reg |=3D FLEXCAN_MCR_FRZ | FLEXCAN_MCR_HALT |
> +		FLEXCAN_MCR_FEN | FLEXCAN_MCR_SUPV;
> +	writel(reg, &regs->mcr);
> +
> +	/*
> +	 * Currently we only support newer versions of this core
> +	 * featuring a RX FIFO. Older cores found on some Coldfire
> +	 * derivates are not yet supported.
> +	 */
> +	reg =3D readl(&regs->mcr);
> +	if (!(reg & FLEXCAN_MCR_FEN)) {
> +		dev_err(dev->dev.parent,
> +			"Could not enable RX FIFO, unsupported core\n");
> +		err =3D -ENODEV;
> +		goto out;
> +	}
> +
> +	err =3D register_candev(dev);
> +
> + out:
> +	/* disable core and turn off clocks */
> +	flexcan_chip_disable(priv);
> +	clk_disable(priv->clk);
> +
> +	return err;
> +}
> +
> +static void __devexit unregister_flexcandev(struct net_device *dev)
> +{
> +	unregister_candev(dev);
> +}
> +
> +static int __devinit flexcan_probe(struct platform_device *pdev)
> +{
> +	struct net_device *dev;
> +	struct flexcan_priv *priv;
> +	struct resource *mem;
> +	struct clk *clk;
> +	void __iomem *base;
> +	resource_size_t mem_size;
> +	int err, irq;
> +
> +	clk =3D clk_get(&pdev->dev, NULL);
> +	if (IS_ERR(clk)) {
> +		dev_err(&pdev->dev, "no clock defined\n");
> +		err =3D PTR_ERR(clk);
> +		goto failed_clock;
> +	}
> +
> +	mem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	irq =3D platform_get_irq(pdev, 0);
> +	if (!mem || irq <=3D 0) {
> +		err =3D -ENODEV;
> +		goto failed_get;
> +	}
> +
> +	mem_size =3D resource_size(mem);
> +	if (!request_mem_region(mem->start, mem_size, pdev->name)) {
> +		err =3D -EBUSY;
> +		goto failed_req;
> +	}
> +
> +	base =3D ioremap(mem->start, mem_size);
> +	if (!base) {
> +		err =3D -ENOMEM;
> +		goto failed_map;
> +	}
> +
> +	dev =3D alloc_candev(sizeof(struct flexcan_priv), 0);
> +	if (!dev) {
> +		err =3D -ENOMEM;
> +		goto failed_alloc;
> +	}
> +
> +	dev->netdev_ops =3D &flexcan_netdev_ops;
> +	dev->irq =3D irq;
> +	dev->flags |=3D IFF_ECHO; /* we support local echo in hardware */
> +
> +	priv =3D netdev_priv(dev);
> +	priv->can.clock.freq =3D clk_get_rate(clk);
> +	priv->can.bittiming_const =3D &flexcan_bittiming_const;
> +	priv->can.do_set_mode =3D flexcan_set_mode;
> +	priv->can.do_get_berr_counter =3D flexcan_get_berr_counter;
> +	priv->can.ctrlmode_supported =3D CAN_CTRLMODE_LOOPBACK |
> +		CAN_CTRLMODE_LISTENONLY	| CAN_CTRLMODE_3_SAMPLES;
> +	priv->base =3D base;
> +	priv->dev =3D dev;
> +	priv->clk =3D clk;
> +	priv->pdata =3D pdev->dev.platform_data;
> +
> +	netif_napi_add(dev, &priv->napi, flexcan_poll, FLEXCAN_NAPI_WEIGHT);
> +
> +	dev_set_drvdata(&pdev->dev, dev);
> +	SET_NETDEV_DEV(dev, &pdev->dev);
> +
> +	err =3D register_flexcandev(dev);
> +	if (err) {
> +		dev_err(&pdev->dev, "registering netdev failed\n");
> +		goto failed_register;
> +	}
> +
> +	dev_info(&pdev->dev, "device registered (reg_base=3D%p, irq=3D%d)\n",
> +		 priv->base, dev->irq);
> +
> +	return 0;
> +
> + failed_register:
> +	free_candev(dev);
> + failed_alloc:
> +	iounmap(base);
> + failed_map:
> +	release_mem_region(mem->start, mem_size);
> + failed_req:
> +	clk_put(clk);
> + failed_get:
> + failed_clock:
> +	return err;
> +}
> +
> +static int __devexit flexcan_remove(struct platform_device *pdev)
> +{
> +	struct net_device *dev =3D platform_get_drvdata(pdev);
> +	struct flexcan_priv *priv =3D netdev_priv(dev);
> +	struct resource *mem;
> +
> +	unregister_flexcandev(dev);
> +	platform_set_drvdata(pdev, NULL);
> +	free_candev(dev);
> +	iounmap(priv->base);
> +
> +	mem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	release_mem_region(mem->start, resource_size(mem));
> +
> +	clk_put(priv->clk);
> +
> +	return 0;
> +}
> +
> +static struct platform_driver flexcan_driver =3D {
> +	.driver.name =3D DRV_NAME,
> +	.probe =3D flexcan_probe,
> +	.remove =3D __devexit_p(flexcan_remove),
> +};
> +
> +static int __init flexcan_init(void)
> +{
> +	pr_info("%s netdevice driver\n", DRV_NAME);
> +	return platform_driver_register(&flexcan_driver);
> +}
> +
> +static void __exit flexcan_exit(void)
> +{
> +	platform_driver_unregister(&flexcan_driver);
> +	pr_info("%s: driver removed\n", DRV_NAME);
> +}
> +
> +module_init(flexcan_init);
> +module_exit(flexcan_exit);
> +
> +MODULE_AUTHOR("Sascha Hauer <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, "
> +	      "Marc Kleine-Budde <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>");
> +MODULE_LICENSE("GPL v2");
> +MODULE_DESCRIPTION("CAN port driver for flexcan based chip");
> diff --git a/include/linux/can/platform/flexcan.h b/include/linux/can/pla=
tform/flexcan.h
> new file mode 100644
> index 0000000..72b713a
> --- /dev/null
> +++ b/include/linux/can/platform/flexcan.h
> @@ -0,0 +1,20 @@
> +/*
> + * Copyright (C) 2010 Marc Kleine-Budde <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> + *
> + * This file is released under the GPLv2
> + *
> + */
> +
> +#ifndef __CAN_PLATFORM_FLEXCAN_H
> +#define __CAN_PLATFORM_FLEXCAN_H
> +
> +/**
> + * struct flexcan_platform_data - flex CAN controller platform data
> + * @transceiver_enable:         - called to power on/off the transceiver
> + *
> + */
> +struct flexcan_platform_data {
> +	void (*transceiver_switch)(int enable);
> +};
> +
> +#endif /* __CAN_PLATFORM_FLEXCAN_H */

Wolfgang.
