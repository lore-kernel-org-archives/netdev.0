From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH] socketcan: add a driver for FlexCAN controllers.
Date: Thu, 17 Jun 2010 16:10:39 +0200
Message-ID: <4C1A2CDF.2040008@pengutronix.de>
References: <20100617105201.GA2015@bluebox.local>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8183999309951663512=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Hans J. Koch" <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100617105201.GA2015-hikPBsva6T+Nj9Bq2fkWzw@public.gmane.org>
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
--===============8183999309951663512==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig85E58980C9AE0554A5431B92"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig85E58980C9AE0554A5431B92
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hey Hans,

Hans J. Koch wrote:
> This adds a driver for FlexCAN based CAN controllers,
> e.g. found in Freescale i.MX35 SoCs.
>=20
> The original version of this driver was posted by Sascha Hauer in July =
2009:
> http://kerneltrap.org/mailarchive/linux-netdev/2009/7/29/6251621
>=20
> I took this version, added NAPI support, and fixed some problems found
> during testing. Well, here is the result. Please review.

I got busy, involved in a $CUSTOMER project, but now I have time to
review your patch...I'm going to send mine, too.

> Thanks,
> Hans
>=20
> Signed-off-by: Hans J. Koch <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> ---
>  drivers/net/can/Kconfig   |    6 +
>  drivers/net/can/Makefile  |    1 +
>  drivers/net/can/flexcan.c |  828 +++++++++++++++++++++++++++++++++++++=
++++++++
>  3 files changed, 835 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/flexcan.c
>=20
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 2c5227c..4250c99 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -73,6 +73,12 @@ config CAN_JANZ_ICAN3
>  	  This driver can also be built as a module. If so, the module will b=
e
>  	  called janz-ican3.ko.
> =20
> +config CAN_FLEXCAN
> +	tristate "Support for Freescale FLEXCAN based chips"
> +	depends on CAN_DEV
> +	---help---
> +	  Driver for Freescale FlexCAN.
> +
>  source "drivers/net/can/mscan/Kconfig"
> =20
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
> =20
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) :=3D -DDEBUG
> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> new file mode 100644
> index 0000000..ab00873
> --- /dev/null
> +++ b/drivers/net/can/flexcan.c
> @@ -0,0 +1,828 @@
> +/*
> + * FLEXCAN CAN controller driver
> + *
> + * Copyright (C) 2005-2006 Varma Electronics Oy
> + * Copyright (C) 2009 Sascha Hauer, Pengutronix
> + * Copyright (C) 2010 Hans J. Koch <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> + *
> + * Based on code originally by Andrey Volkov
> + *
> + * Licensed under the terms of the GPL v2.
> + *
> + */
> +
> +#include <linux/clk.h>
> +#include <linux/delay.h>
> +#include <linux/if_arp.h>
> +#include <linux/if_ether.h>
> +#include <linux/interrupt.h>
> +#include <linux/io.h>
> +#include <linux/kernel.h>
> +#include <linux/list.h>
> +#include <linux/module.h>
> +#include <linux/netdevice.h>
> +#include <linux/platform_device.h>
> +
> +#include <linux/can/dev.h>
> +#include <linux/can/error.h>
> +#include <linux/can/netlink.h>
> +
> +#define DRIVER_NAME "flexcan"
> +
> +#define TX_ECHO_SKB_MAX			1
> +#define FLEXCAN_DEF_NAPI_WEIGHT		6
> +
> +/* FLEXCAN module configuration register (CANMCR) bits */
> +#define CANMCR_MDIS				(1 << 31)
> +#define CANMCR_FRZ				(1 << 30)
> +#define CANMCR_FEN				(1 << 29)
> +#define CANMCR_HALT				(1 << 28)
> +#define CANMCR_NOT_RDY				(1 << 27)
> +#define CANMCR_SOFTRST				(1 << 25)
> +#define CANMCR_FRZACK				(1 << 24)
> +#define CANMCR_SUPV				(1 << 23)
> +#define CANMCR_SRX_DIS				(1 << 17)
> +#define CANMCR_MAXMB(x)				((x) & 0x0f)
> +#define CANMCR_IDAM_A				(0 << 8)
> +#define CANMCR_IDAM_B				(1 << 8)
> +#define CANMCR_IDAM_C				(2 << 8)
> +
> +/* FLEXCAN control register (CANCTRL) bits */
> +#define CANCTRL_PRESDIV(x)			(((x) & 0xff) << 24)
> +#define CANCTRL_RJW(x)				(((x) & 0x03) << 22)
> +#define CANCTRL_PSEG1(x)			(((x) & 0x07) << 19)
> +#define CANCTRL_PSEG2(x)			(((x) & 0x07) << 16)
> +#define CANCTRL_BOFFMSK				(1 << 15)
> +#define CANCTRL_ERRMSK				(1 << 14)
> +#define CANCTRL_CLKSRC				(1 << 13)
> +#define CANCTRL_LPB				(1 << 12)
> +#define CANCTRL_TWRN_MSK			(1 << 11)
> +#define CANCTRL_RWRN_MSK			(1 << 10)
> +#define CANCTRL_SAMP				(1 << 7)
> +#define CANCTRL_BOFFREC				(1 << 6)
> +#define CANCTRL_TSYNC				(1 << 5)
> +#define CANCTRL_LBUF				(1 << 4)
> +#define CANCTRL_LOM				(1 << 3)
> +#define CANCTRL_PROPSEG(x)			((x) & 0x07)
> +
> +/* FLEXCAN error counter register (ERRCNT) bits */
> +#define ERRCNT_REXECTR(x)			(((x) & 0xff) << 8)
> +#define ERRCNT_TXECTR(x)			((x) & 0xff)
> +
> +/* FLEXCAN error and status register (ERRSTAT) bits */
> +#define ERRSTAT_TWRNINT				(1 << 17)
> +#define ERRSTAT_RWRNINT				(1 << 16)
> +#define ERRSTAT_BIT1ERR				(1 << 15)
> +#define ERRSTAT_BIT0ERR				(1 << 14)
> +#define ERRSTAT_ACKERR				(1 << 13)
> +#define ERRSTAT_CRCERR				(1 << 12)
> +#define ERRSTAT_FRMERR				(1 << 11)
> +#define ERRSTAT_STFERR				(1 << 10)
> +#define ERRSTAT_TXWRN				(1 << 9)
> +#define ERRSTAT_RXWRN				(1 << 8)
> +#define ERRSTAT_IDLE				(1 << 7)
> +#define ERRSTAT_TXRX				(1 << 6)
> +#define ERRSTAT_FLTCONF_MASK			(3 << 4)
> +#define ERRSTAT_FLTCONF_ERROR_ACTIVE		(0 << 4)
> +#define ERRSTAT_FLTCONF_ERROR_PASSIVE		(1 << 4)
> +#define ERRSTAT_FLTCONF_ERROR_BUS_OFF		(2 << 4)
> +#define ERRSTAT_BOFFINT				(1 << 2)
> +#define ERRSTAT_ERRINT				(1 << 1)
> +#define ERRSTAT_WAKINT				(1 << 0)
> +#define ERRSTAT_INT	(ERRSTAT_BOFFINT | ERRSTAT_ERRINT | ERRSTAT_TWRNIN=
T | \
> +				ERRSTAT_RWRNINT)
> +
> +/* FLEXCAN interrupt flag register (IFLAG) bits */
> +#define IFLAG_BUF(x)				(1 << (x))
> +#define IFLAG_RX_FIFO_OVERFLOW			(1 << 7)
> +#define IFLAG_RX_FIFO_WARN			(1 << 6)
> +#define IFLAG_RX_FIFO_AVAILABLE			(1 << 5)
> +
> +/* FLEXCAN message buffers */
> +#define MB_CNT_CODE(x)				(((x) & 0xf) << 24)
> +#define MB_CNT_SRR				(1 << 22)
> +#define MB_CNT_IDE				(1 << 21)
> +#define MB_CNT_RTR				(1 << 20)
> +#define MB_CNT_LENGTH(x)			(((x) & 0xf) << 16)
> +#define MB_CNT_TIMESTAMP(x)			((x) & 0xffff)
> +
> +#define MB_ID_STD				(0x7ff << 18)
> +#define MB_ID_EXT				0x1fffffff
> +#define MB_CODE_MASK				0xf0ffffff
> +
> +#define TX_ECHO_SKB_MAX				1
> +
> +/* Structure of the message buffer */
> +struct flexcan_mb {
> +	u32	can_ctrl;
> +	u32	can_id;
> +	u32	data[2];
> +};
> +
> +/* Structure of the hardware registers */
> +struct flexcan_regs {
> +	u32	canmcr;		/* 0x00 */
> +	u32	canctrl;	/* 0x04 */
> +	u32	timer;		/* 0x08 */
> +	u32	reserved1;	/* 0x0c */
> +	u32	rxgmask;	/* 0x10 */
> +	u32	rx14mask;	/* 0x14 */
> +	u32	rx15mask;	/* 0x18 */
> +	u32	errcnt;		/* 0x1c */
> +	u32	errstat;	/* 0x20 */
> +	u32	imask2;		/* 0x24 */
> +	u32	imask1;		/* 0x28 */
> +	u32	iflag2;		/* 0x2c */
> +	u32	iflag1;		/* 0x30 */
> +	u32	reserved4[19];
> +	struct	flexcan_mb cantxfg[64];
> +};
> +
> +struct flexcan_priv {
> +	struct can_priv can;
> +	void __iomem *base;
> +
> +	struct net_device *dev;
> +	struct napi_struct napi;
> +	struct clk *clk;
> +};
> +
> +static struct can_bittiming_const flexcan_bittiming_const =3D {
> +	.name =3D DRIVER_NAME,
> +	.tseg1_min =3D 1,
> +	.tseg1_max =3D 16,
> +	.tseg2_min =3D 2,
> +	.tseg2_max =3D 8,
> +	.sjw_max =3D 4,
> +	.brp_min =3D 1,
> +	.brp_max =3D 256,
> +	.brp_inc =3D 1,
> +};
> +
> +/* Mailboxes 0..7 are for RX FIFO, 8 for TX */
> +#define TX_BUF_ID	8
> +
> +static void disable_mode_on(struct flexcan_regs __iomem *regs)
> +{
> +	u32 reg =3D readl(&regs->canmcr);
> +
> +	writel(reg | CANMCR_MDIS, &regs->canmcr);
> +	udelay(100);
> +}
> +
> +static void disable_mode_off(struct flexcan_regs __iomem *regs)
> +{
> +	u32 reg =3D readl(&regs->canmcr);
> +
> +	writel(reg & ~CANMCR_MDIS, &regs->canmcr);
> +	udelay(100);
> +}
> +
> +static int freeze_mode_on(struct flexcan_regs __iomem *regs)
> +{
> +	u32 reg =3D readl(&regs->canmcr);
> +	int timeout =3D 10000;
> +
> +	if (reg & CANMCR_FRZACK)
> +		return 0;
> +
> +	writel(reg | CANMCR_FRZ, &regs->canmcr);
> +	writel(reg | CANMCR_HALT, &regs->canmcr);
> +	while (!(reg & CANMCR_FRZACK)) {
> +		if (--timeout < 0)
> +			return -EIO;
> +		udelay(10);
> +		reg =3D readl(&regs->canmcr);
> +	}
> +	return 0;
> +}
> +
> +static int freeze_mode_off(struct flexcan_regs __iomem *regs)
> +{
> +	u32 reg =3D readl(&regs->canmcr);
> +	int timeout =3D 10000;
> +
> +	if (!(reg & CANMCR_FRZACK))
> +		return 0;
> +
> +	writel(reg & ~(CANMCR_FRZ | CANMCR_HALT), &regs->canmcr);
> +	while (reg & CANMCR_FRZACK) {
> +		if (--timeout < 0)
> +			return -EIO;
> +		udelay(10);
> +		reg =3D readl(&regs->canmcr);
> +	}
> +	return 0;
> +}
> +
> +static int flexcan_start_xmit(struct sk_buff *skb, struct net_device *=
dev)
> +{
> +	struct can_frame *frame =3D (struct can_frame *)skb->data;
> +	struct flexcan_priv *priv =3D netdev_priv(dev);
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	u32 can_id;
> +	u32 ctrl =3D MB_CNT_CODE(0xc) | (frame->can_dlc << 16);
> +	u32 reg =3D readl(&regs->canctrl);
> +

check for invalid can frames with can_dropped_invalid_skb

> +	reg =3D readl(&regs->cantxfg[TX_BUF_ID].can_ctrl);
> +
> +	if (reg !=3D MB_CNT_CODE(0x8))
> +		writel(MB_CNT_CODE(0x08), &regs->cantxfg[TX_BUF_ID].can_ctrl);
> +
> +	netif_stop_queue(dev);
> +
> +	if (frame->can_id & CAN_EFF_FLAG) {
> +		can_id =3D frame->can_id & CAN_EFF_MASK;
> +		ctrl |=3D MB_CNT_IDE | MB_CNT_SRR;
> +	} else {
> +		can_id =3D (frame->can_id & CAN_SFF_MASK) << 18;
> +	}
> +
> +	if (frame->can_id & CAN_RTR_FLAG)
> +		ctrl |=3D MB_CNT_RTR;
> +
> +	if (frame->can_dlc > 0) {
> +		u32 data;
> +		data =3D frame->data[0] << 24;
> +		data |=3D frame->data[1] << 16;
> +		data |=3D frame->data[2] << 8;
> +		data |=3D frame->data[3];
> +		writel(data, &regs->cantxfg[TX_BUF_ID].data[0]);

we can use cpu_to_be32 here

> +	}
> +	if (frame->can_dlc > 3) {
> +		u32 data;
> +		data =3D frame->data[4] << 24;
> +		data |=3D frame->data[5] << 16;
> +		data |=3D frame->data[6] << 8;
> +		data |=3D frame->data[7];
> +		writel(data, &regs->cantxfg[TX_BUF_ID].data[1]);
> +	}
> +
> +	writel(can_id, &regs->cantxfg[TX_BUF_ID].can_id);
> +	writel(ctrl, &regs->cantxfg[TX_BUF_ID].can_ctrl);
> +
> +	kfree_skb(skb);
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static void flexcan_rx_frame(struct net_device *ndev,
> +		struct flexcan_mb __iomem *mb)
> +{
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	struct sk_buff *skb;
> +	struct can_frame *frame;
> +	int ctrl, length;
> +	u32 id;
> +
> +	ctrl =3D readl(&mb->can_ctrl);
> +	length =3D (ctrl >> 16) & 0x0f;
> +	if (length > 8) {
> +		stats->rx_dropped++;
> +		return;
> +	}

do not drop, use get_can_dlc()

> +
> +	skb =3D dev_alloc_skb(sizeof(struct can_frame));
> +	if (!skb) {
> +		stats->rx_dropped++;
> +		return;
> +	}
> +
> +	frame =3D (struct can_frame *)skb_put(skb,
> +			sizeof(struct can_frame));
> +
> +	frame->can_dlc =3D length;
> +	id =3D readl(&mb->can_id);
> +
> +	if (ctrl & MB_CNT_IDE) {
> +		frame->can_id =3D id & CAN_EFF_MASK;
> +		frame->can_id |=3D CAN_EFF_FLAG;
> +	} else {
> +		frame->can_id  =3D (id >> 18) & CAN_SFF_MASK;
> +	}
> +
> +	if (ctrl & MB_CNT_RTR)
> +		frame->can_id |=3D CAN_RTR_FLAG;
> +
> +	if (length > 0) {
> +		u32 data =3D readl(&mb->data[0]);
> +		frame->data[0] =3D (data >> 24) & 0xff;
> +		frame->data[1] =3D (data >> 16) & 0xff;
> +		frame->data[2] =3D (data >> 8) & 0xff;
> +		frame->data[3] =3D data & 0xff;

we can use be32_to_cpu here

> +	}
> +	if (length > 3) {
> +		u32 data =3D readl(&mb->data[1]);
> +		frame->data[4] =3D (data >> 24) & 0xff;
> +		frame->data[5] =3D (data >> 16) & 0xff;
> +		frame->data[6] =3D (data >> 8) & 0xff;
> +		frame->data[7] =3D data & 0xff;
> +	}
> +
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D frame->can_dlc;

> +	skb->dev =3D ndev;
> +	skb->protocol =3D __constant_htons(ETH_P_CAN);
> +	skb->ip_summed =3D CHECKSUM_UNNECESSARY;

these are not needed

> +
> +	netif_rx(skb);

use 	netif_receive_skb(skb) in napi

> +}
> +
> +static int flexcan_rx_poll(struct napi_struct *napi, int quota)
> +{
> +	struct net_device *ndev =3D napi->dev;
> +	struct flexcan_priv *priv =3D netdev_priv(ndev);
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	u32 iflags, imask;
> +	int num_pkts =3D 0;
> +
> +	if (!netif_running(ndev))
> +		return 0;
> +
> +	iflags =3D readl(&regs->iflag1);
> +
> +	while ((iflags & IFLAG_RX_FIFO_AVAILABLE) && (num_pkts < quota)) {
> +		struct flexcan_mb __iomem *mb =3D &regs->cantxfg[0];
> +
> +		flexcan_rx_frame(ndev, mb);
> +		writel(IFLAG_RX_FIFO_AVAILABLE, &regs->iflag1);
> +		readl(&regs->timer);
> +		num_pkts++;
> +		iflags =3D readl(&regs->iflag1);
> +	}
> +
> +	if (num_pkts < quota) {
> +		napi_complete(napi);
> +		/* Re-enable RX mailbox interrupts */
> +		imask =3D readl(&regs->imask1);
> +		writel(imask | IFLAG_RX_FIFO_AVAILABLE, &regs->imask1);

is this read modify write save without locking against the interrupt
handler?

> +	}
> +
> +	return num_pkts;
> +}
> +
> +static void flexcan_error(struct net_device *ndev, u32 stat)
> +{
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	struct flexcan_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	enum can_state state =3D priv->can.state;
> +	int error_warning =3D 0, rx_errors =3D 0, tx_errors =3D 0;
> +
> +	skb =3D dev_alloc_skb(sizeof(struct can_frame));
> +	if (!skb)
> +		return;
> +
> +	skb->dev =3D ndev;
> +	skb->protocol =3D __constant_htons(ETH_P_CAN);
> +	skb->ip_summed =3D CHECKSUM_UNNECESSARY;
> +
> +	cf =3D (struct can_frame *)skb_put(skb, sizeof(*cf));
> +	memset(cf, 0, sizeof(*cf));
> +
> +	cf->can_id =3D CAN_ERR_FLAG;
> +	cf->can_dlc =3D CAN_ERR_DLC;

use alloc_can_err_skb instead

> +
> +	if (stat & ERRSTAT_RWRNINT) {
> +		error_warning =3D 1;
> +		cf->data[1] |=3D CAN_ERR_CRTL_RX_WARNING;
> +	}
> +
> +	if (stat & ERRSTAT_TWRNINT) {
> +		error_warning =3D 1;
> +		cf->data[1] |=3D CAN_ERR_CRTL_TX_WARNING;
> +	}
> +
> +	switch ((stat >> 4) & 0x3) {
> +	case 0:
> +		state =3D CAN_STATE_ERROR_ACTIVE;
> +		break;
> +	case 1:
> +		state =3D CAN_STATE_ERROR_PASSIVE;
> +		break;
> +	default:
> +		state =3D CAN_STATE_BUS_OFF;
> +		break;
> +	}
> +
> +	if (stat & ERRSTAT_BOFFINT) {
> +		cf->can_id |=3D CAN_ERR_BUSOFF;
> +		state =3D CAN_STATE_BUS_OFF;
> +	}
> +
> +	if (stat & ERRSTAT_BIT1ERR) {
> +		rx_errors =3D 1;
> +		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
> +		cf->data[2] |=3D CAN_ERR_PROT_BIT1;
> +	}
> +
> +	if (stat & ERRSTAT_BIT0ERR) {
> +		rx_errors =3D 1;
> +		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
> +		cf->data[2] |=3D CAN_ERR_PROT_BIT0;
> +	}
> +
> +	if (stat & ERRSTAT_FRMERR) {
> +		rx_errors =3D 1;
> +		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
> +		cf->data[2] |=3D CAN_ERR_PROT_FORM;
> +	}
> +
> +	if (stat & ERRSTAT_STFERR) {
> +		rx_errors =3D 1;
> +		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
> +		cf->data[2] |=3D CAN_ERR_PROT_STUFF;
> +	}
> +
> +
> +	if (stat & ERRSTAT_ACKERR) {
> +		tx_errors =3D 1;
> +		cf->can_id |=3D CAN_ERR_ACK;
> +	}
> +
> +	if (state =3D=3D CAN_STATE_BUS_OFF)
> +		can_bus_off(ndev);
> +	if (error_warning)
> +		priv->can.can_stats.error_warning++;
> +	if (rx_errors)
> +		stats->rx_errors++;
> +	if (tx_errors)
> +		stats->tx_errors++;
> +
> +	priv->can.state =3D state;
> +
> +	netif_rx(skb);
> +
> +	ndev->last_rx =3D jiffies;

IIRC not needed anymore

> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->can_dlc;
> +}
> +
> +static irqreturn_t flexcan_isr(int irq, void *dev_id)
> +{
> +	struct net_device *ndev =3D dev_id;
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	struct flexcan_priv *priv =3D netdev_priv(ndev);
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	u32 iflags, imask, errstat;
> +
> +	errstat =3D readl(&regs->errstat);
> +	if (errstat & ERRSTAT_INT) {
> +		flexcan_error(ndev, errstat);
> +		writel(errstat & ERRSTAT_INT, &regs->errstat);

IMHO the bit errors should be handled in NAPI to avoid IRQ storms.

> +	}
> +
> +	iflags =3D readl(&regs->iflag1);
> +
> +	if (iflags & IFLAG_RX_FIFO_OVERFLOW) {
> +		writel(IFLAG_RX_FIFO_OVERFLOW, &regs->iflag1);
> +		stats->rx_over_errors++;
> +		stats->rx_errors++;
> +	}
> +
> +	if (iflags & (1 << TX_BUF_ID)) {
> +		stats->tx_packets++;
> +		writel((1 << TX_BUF_ID), &regs->iflag1);
> +		netif_wake_queue(ndev);
> +	}
> +
> +	if (iflags & IFLAG_RX_FIFO_AVAILABLE) {
> +		/* disable RX interrupts */
> +		imask =3D readl(&regs->imask1);
> +		writel(imask & ~IFLAG_RX_FIFO_AVAILABLE, &regs->imask1);
> +		/* Let NAPI poll received packets */
> +		napi_schedule(&priv->napi);
> +	}
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static void init_regs(struct flexcan_regs __iomem *regs)
> +{
> +	u32 reg;
> +	int i;
> +
> +	freeze_mode_on(regs);
> +
> +	/* Enable error and bus off interrupt */
> +	reg =3D readl(&regs->canctrl);
> +	reg |=3D CANCTRL_CLKSRC | CANCTRL_ERRMSK | CANCTRL_BOFFMSK |
> +		CANCTRL_BOFFREC | CANCTRL_TWRN_MSK | CANCTRL_TWRN_MSK;
> +	writel(reg, &regs->canctrl);
> +
> +	/* Set lowest buffer transmitted first */
> +	reg |=3D CANCTRL_LBUF;
> +	writel(reg, &regs->canctrl);
> +
> +	for (i =3D 0; i < 64; i++) {
> +		writel(0, &regs->cantxfg[i].can_ctrl);
> +		writel(0, &regs->cantxfg[i].can_id);
> +		writel(0, &regs->cantxfg[i].data[0]);
> +		writel(0, &regs->cantxfg[i].data[1]);
> +
> +		/* Put MB into rx queue */
> +		writel(MB_CNT_CODE(0x04), &regs->cantxfg[i].can_ctrl);
> +	}
> +	writel(MB_CNT_CODE(0x08), &regs->cantxfg[TX_BUF_ID].can_ctrl);
> +
> +	/* acceptance mask/acceptance code (accept everything) */
> +	writel(0x0, &regs->rxgmask);
> +	writel(0x0, &regs->rx14mask);
> +	writel(0x0, &regs->rx15mask);
> +
> +	reg =3D readl(&regs->canmcr) & ~0x0f;
> +	reg |=3D CANMCR_IDAM_C | CANMCR_FEN | CANMCR_MAXMB(TX_BUF_ID);
> +	writel(reg, &regs->canmcr);
> +}
> +
> +static int flexcan_set_bittiming(struct net_device *ndev)
> +{
> +	struct flexcan_priv *priv =3D netdev_priv(ndev);
> +	struct can_bittiming *bt =3D &priv->can.bittiming;
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	u32 reg;
> +
> +	clk_enable(priv->clk);
> +
> +	disable_mode_on(regs);
> +
> +	reg =3D readl(&regs->canctrl);
> +	reg &=3D ~(CANCTRL_SAMP | CANCTRL_PRESDIV(0xff) |
> +			CANCTRL_PSEG1(7) | CANCTRL_PSEG2(7) |
> +			CANCTRL_PROPSEG(7));
> +	reg |=3D CANCTRL_PRESDIV(bt->brp - 1) |
> +		CANCTRL_PSEG1(bt->phase_seg1 - 1) |
> +		CANCTRL_PSEG2(bt->phase_seg2 - 1) |
> +		CANCTRL_RJW(3) |
                            ^

is this intended?

> +		CANCTRL_PROPSEG(bt->prop_seg - 1);
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES)
> +		reg |=3D CANCTRL_SAMP;
> +	writel(reg, &regs->canctrl);
> +
> +	dev_dbg(&ndev->dev, "flexcan_set_bittiming: canctrl=3D0x%08x\n", reg)=
;
> +
> +	clk_disable(priv->clk);
> +
> +	return 0;
> +}
> +
> +static int flexcan_open(struct net_device *ndev)
> +{
> +	int ret;
> +	struct flexcan_priv *priv =3D netdev_priv(ndev);
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +
> +	clk_enable(priv->clk);
> +
> +	ret =3D open_candev(ndev);
> +	if (ret)
> +		return ret;
> +
> +	disable_mode_off(regs);
> +	init_regs(regs);
> +
> +	/* Enable flexcan module */
> +	freeze_mode_off(regs);
> +
> +	/* Enable interrupts */
> +	writel(IFLAG_RX_FIFO_OVERFLOW | IFLAG_RX_FIFO_AVAILABLE |
> +			IFLAG_BUF(TX_BUF_ID),
> +			&regs->imask1);
> +
> +	napi_enable(&priv->napi);
> +	netif_start_queue(ndev);
> +
> +	ret =3D request_irq(ndev->irq, flexcan_isr, 0, DRIVER_NAME, ndev);
> +	if (!ret)
> +		return 0;
> +
> +	close_candev(ndev);
> +	return ret;
> +}
> +
> +static int flexcan_close(struct net_device *ndev)
> +{
> +	struct flexcan_priv *priv =3D netdev_priv(ndev);
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +
> +	netif_stop_queue(ndev);
> +	napi_disable(&priv->napi);
> +
> +	/* Disable all interrupts */
> +	writel(0, &regs->imask1);
> +	free_irq(ndev->irq, ndev);
> +
> +	close_candev(ndev);
> +
> +	/* Disable module */
> +	disable_mode_on(regs);
> +	clk_disable(priv->clk);
> +	return 0;
> +}
> +
> +static int flexcan_set_mode(struct net_device *ndev, enum can_mode mod=
e)
> +{
> +	struct flexcan_priv *priv =3D netdev_priv(ndev);
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	u32 reg;
> +
> +	switch (mode) {
> +	case CAN_MODE_START:
> +		reg =3D readl(&regs->canctrl);
> +		reg &=3D ~CANCTRL_BOFFREC;
> +		writel(reg, &regs->canctrl);
> +		reg |=3D CANCTRL_BOFFREC;
> +		writel(reg, &regs->canctrl);
> +		priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +
> +		if (netif_queue_stopped(ndev))
> +			netif_wake_queue(ndev);
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
> +       .ndo_open		=3D flexcan_open,
> +       .ndo_stop		=3D flexcan_close,
> +       .ndo_start_xmit		=3D flexcan_start_xmit,
> +};
> +
> +static int register_flexcandev(struct net_device *ndev)
> +{
> +	struct flexcan_priv *priv =3D netdev_priv(ndev);
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	u32 reg;
> +
> +	/* Ensure clock is enabled so we can access registers */
> +	clk_enable(priv->clk);
> +	reg =3D readl(&regs->canmcr);
> +	reg &=3D ~CANMCR_MDIS;
> +	reg |=3D CANMCR_FEN;
> +	writel(reg, &regs->canmcr);
> +	init_regs(regs);
> +	udelay(100);
> +
> +	reg =3D readl(&regs->canmcr);
> +	clk_disable(priv->clk);
> +
> +	/* Currently we only support newer versions of this core featuring
> +	 * a RX FIFO. Older cores found on some Coldfire derivates are not
> +	 * yet supported.
> +	 */
> +	if (!(reg & CANMCR_FEN)) {
> +		dev_err(&ndev->dev, "Could not enable RX FIFO, unsupported "
> +				"core");
> +		return -ENODEV;
> +	}
> +
> +	ndev->flags |=3D IFF_ECHO; /* we support local echo in hardware */
> +	ndev->netdev_ops =3D &flexcan_netdev_ops;
> +
> +	return register_candev(ndev);
> +}
> +
> +static void unregister_flexcandev(struct net_device *ndev)
> +{
> +	struct flexcan_priv *priv =3D netdev_priv(ndev);
> +	struct flexcan_regs __iomem *regs =3D priv->base;
> +	u32 reg;
> +
> +	clk_enable(priv->clk);
> +	reg =3D readl(&regs->canmcr);
> +	reg |=3D CANMCR_FRZ | CANMCR_HALT | CANMCR_MDIS;
> +	writel(reg, &regs->canmcr);
> +	clk_disable(priv->clk);
> +
> +	unregister_candev(ndev);
> +}
> +
> +static int __devinit flexcan_probe(struct platform_device *pdev)
> +{
> +	struct resource *mem;
> +	struct net_device *ndev;
> +	struct flexcan_priv *priv;
> +	u32 mem_size;
> +	int ret;
> +
> +	ndev =3D alloc_candev(sizeof(struct flexcan_priv), TX_ECHO_SKB_MAX);
> +	if (!ndev) {
> +		dev_err(&pdev->dev, "flexcan: alloc_candev failed.\n");
> +		return -ENOMEM;
> +	}
> +
> +	priv =3D netdev_priv(ndev);
> +
> +	mem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +
> +	ndev->irq =3D platform_get_irq(pdev, 0);
> +	if (!mem || !ndev->irq) {
> +		dev_err(&pdev->dev, "flexcan: mem || irq failed.\n");
> +		ret =3D -ENODEV;
> +		goto failed_req;
> +	}
> +
> +	mem_size =3D resource_size(mem);
> +
> +	if (!request_mem_region(mem->start, mem_size, DRIVER_NAME)) {
> +		dev_err(&pdev->dev, "flexcan: request_mem_region failed.\n");
> +		ret =3D -EBUSY;
> +		goto failed_req;
> +	}
> +
> +	SET_NETDEV_DEV(ndev, &pdev->dev);
> +
> +	priv->base =3D ioremap(mem->start, mem_size);
> +	if (!priv->base) {
> +		dev_err(&pdev->dev, "flexcan: ioremap failed.\n");
> +		ret =3D -ENOMEM;
> +		goto failed_map;
> +	}
> +
> +	priv->clk =3D clk_get(&pdev->dev, NULL);
> +	if (IS_ERR(priv->clk)) {
> +		dev_err(&pdev->dev, "flexcan: clk_get failed.\n");
> +		ret =3D PTR_ERR(priv->clk);
> +		goto failed_clock;
> +	}
> +	priv->can.clock.freq =3D clk_get_rate(priv->clk);
> +
> +	platform_set_drvdata(pdev, ndev);
> +
> +	priv->can.do_set_bittiming =3D flexcan_set_bittiming;

using this callback is error prone, with respect to 3-sample and
friends, see discussion on socketcan-core.

> +	priv->can.bittiming_const =3D &flexcan_bittiming_const;
> +	priv->can.do_set_mode =3D flexcan_set_mode;
> +	priv->can.restart_ms =3D 500;

should this be set in the driver?

> +
> +	netif_napi_add(ndev, &priv->napi, flexcan_rx_poll,
> +				FLEXCAN_DEF_NAPI_WEIGHT);
> +
> +	ret =3D register_flexcandev(ndev);
> +	if (ret) {
> +		dev_err(&pdev->dev, "flexcan: register_flexcandev failed.\n");
> +		goto failed_register;
> +	}
> +
> +	dev_info(&pdev->dev, "flexcan: probe() succeeded...\n");
> +	return 0;
> +
> +failed_register:
> +	clk_put(priv->clk);
> +failed_clock:
> +	iounmap(priv->base);
> +failed_map:
> +	release_mem_region(mem->start, mem_size);
> +failed_req:
> +	free_candev(ndev);
> +
> +	return ret;
> +}
> +
> +static int __devexit flexcan_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev =3D platform_get_drvdata(pdev);
> +	struct flexcan_priv *priv =3D netdev_priv(ndev);
> +	struct resource *mem;
> +
> +	unregister_flexcandev(ndev);
> +	netif_napi_del(&priv->napi);
> +	platform_set_drvdata(pdev, NULL);
> +	iounmap(priv->base);
> +	clk_put(priv->clk);
> +
> +	mem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	release_mem_region(mem->start, resource_size(mem));
> +	free_candev(ndev);
> +
> +	return 0;
> +}
> +
> +static struct platform_driver flexcan_driver =3D {
> +	.driver =3D {
> +		   .name =3D DRIVER_NAME,
> +		   },
> +	.probe =3D flexcan_probe,
> +	.remove =3D __devexit_p(flexcan_remove),
> +};
> +
> +static int __init flexcan_init(void)
> +{
> +	return platform_driver_register(&flexcan_driver);
> +}
> +
> +static void __exit flexcan_exit(void)
> +{
> +	platform_driver_unregister(&flexcan_driver);
> +}
> +
> +module_init(flexcan_init);
> +module_exit(flexcan_exit);
> +
> +MODULE_AUTHOR("Hans J. Koch <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>");
> +MODULE_LICENSE("GPL v2");
> +MODULE_DESCRIPTION("SocketCAN driver for FlexCAN based chips");

cheers, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig85E58980C9AE0554A5431B92
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkwaLOMACgkQjTAFq1RaXHMBbQCeJFH/m3PyeynA5fpPZVzjoBz1
mpQAoJENa169QIBaC/FoNY8nhheBhqeG
=LFm5
-----END PGP SIGNATURE-----

--------------enig85E58980C9AE0554A5431B92--

--===============8183999309951663512==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============8183999309951663512==--
