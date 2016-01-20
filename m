From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V3 5/5] net: can: ifi: Add IFI CANFD IP support
Date: Wed, 20 Jan 2016 15:39:51 +0100
Message-ID: <569F9C37.60007@pengutronix.de>
References: <569F944A.4090201@pengutronix.de>
 <1453300419-5716-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="02DlCLdD3CCIoKv0PexnbFmENP84NqulV"
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Marek Vasut <marex@denx.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:51879 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932261AbcATOkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 09:40:02 -0500
In-Reply-To: <1453300419-5716-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--02DlCLdD3CCIoKv0PexnbFmENP84NqulV
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/20/2016 03:33 PM, Marek Vasut wrote:
> The patch adds support for IFI CAN/FD controller [1]. This driver
> currently supports sending and receiving both standard CAN and new
> CAN/FD frames. Both ISO and BOSCH variant of CAN/FD is supported.
>=20
> [1] http://www.ifi-pld.de/IP/CANFD/canfd.html
>=20
> Signed-off-by: Marek Vasut <marex@denx.de>
> Cc: Marc Kleine-Budde <mkl@pengutronix.de>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Oliver Hartkopp <socketcan@hartkopp.net>
> Cc: Wolfgang Grandegger <wg@grandegger.com>
> ---
> V2: - Move request_irq()/free_irq() into ifi_canfd_open()/ifi_canfd_clo=
se()
>       just like other drivers do it to prevent crash when reloading mod=
ule.
>     - Fix Woverflow complains on x86_64 and itanium, exactly the same w=
ay
>       as in commit dec23dca5a9ca4b9eb2fb66926f567889028b904 .
>=20
> V3: - Hopefully fix all problems with BIT(31) by adding more u32 casts.=

>     - Drop struct device from struct ifi_canfd_priv .
>=20
> NOTE: The driver is surprisingly similar to m_can, but the register
>       layout of the IFI core is completely different, so it's clear
>       that those are two different IP cores.
> ---
>  drivers/net/can/Kconfig               |   2 +
>  drivers/net/can/Makefile              |   1 +
>  drivers/net/can/ifi_canfd/Kconfig     |   8 +
>  drivers/net/can/ifi_canfd/Makefile    |   5 +
>  drivers/net/can/ifi_canfd/ifi_canfd.c | 917 ++++++++++++++++++++++++++=
++++++++
>  5 files changed, 933 insertions(+)
>  create mode 100644 drivers/net/can/ifi_canfd/Kconfig
>  create mode 100644 drivers/net/can/ifi_canfd/Makefile
>  create mode 100644 drivers/net/can/ifi_canfd/ifi_canfd.c
>=20
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index ca49d15..20be638 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -151,6 +151,8 @@ source "drivers/net/can/c_can/Kconfig"
> =20
>  source "drivers/net/can/cc770/Kconfig"
> =20
> +source "drivers/net/can/ifi_canfd/Kconfig"
> +
>  source "drivers/net/can/m_can/Kconfig"
> =20
>  source "drivers/net/can/mscan/Kconfig"
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 4f85c2b..e3db0c8 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -20,6 +20,7 @@ obj-$(CONFIG_CAN_CC770)		+=3D cc770/
>  obj-$(CONFIG_CAN_C_CAN)		+=3D c_can/
>  obj-$(CONFIG_CAN_FLEXCAN)	+=3D flexcan.o
>  obj-$(CONFIG_CAN_GRCAN)		+=3D grcan.o
> +obj-$(CONFIG_CAN_IFI_CANFD)	+=3D ifi_canfd/
>  obj-$(CONFIG_CAN_JANZ_ICAN3)	+=3D janz-ican3.o
>  obj-$(CONFIG_CAN_MSCAN)		+=3D mscan/
>  obj-$(CONFIG_CAN_M_CAN)		+=3D m_can/
> diff --git a/drivers/net/can/ifi_canfd/Kconfig b/drivers/net/can/ifi_ca=
nfd/Kconfig
> new file mode 100644
> index 0000000..9e8934f
> --- /dev/null
> +++ b/drivers/net/can/ifi_canfd/Kconfig
> @@ -0,0 +1,8 @@
> +config CAN_IFI_CANFD
> +	depends on HAS_IOMEM
> +	tristate "IFI CAN_FD IP"
> +	---help---
> +	  This driver adds support for the I/F/I CAN_FD soft IP block
> +	  connected to the "platform bus" (Linux abstraction for directly
> +	  to the processor attached devices). The CAN_FD is most often
> +	  synthesised into an FPGA or CPLD.
> diff --git a/drivers/net/can/ifi_canfd/Makefile b/drivers/net/can/ifi_c=
anfd/Makefile
> new file mode 100644
> index 0000000..b229960
> --- /dev/null
> +++ b/drivers/net/can/ifi_canfd/Makefile
> @@ -0,0 +1,5 @@
> +#
> +#  Makefile for the IFI CANFD controller driver.
> +#
> +
> +obj-$(CONFIG_CAN_IFI_CANFD) +=3D ifi_canfd.o
> diff --git a/drivers/net/can/ifi_canfd/ifi_canfd.c b/drivers/net/can/if=
i_canfd/ifi_canfd.c
> new file mode 100644
> index 0000000..639868b
> --- /dev/null
> +++ b/drivers/net/can/ifi_canfd/ifi_canfd.c
> @@ -0,0 +1,917 @@
> +/*
> + * CAN bus driver for IFI CANFD controller
> + *
> + * Copyright (C) 2016 Marek Vasut <marex@denx.de>
> + *
> + * Details about this controller can be found at
> + * http://www.ifi-pld.de/IP/CANFD/canfd.html
> + *
> + * This file is licensed under the terms of the GNU General Public
> + * License version 2. This program is licensed "as is" without any
> + * warranty of any kind, whether express or implied.
> + */
> +
> +#include <linux/clk.h>
> +#include <linux/delay.h>
> +#include <linux/interrupt.h>
> +#include <linux/io.h>
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/netdevice.h>
> +#include <linux/of.h>
> +#include <linux/of_device.h>
> +#include <linux/platform_device.h>
> +
> +#include <linux/can/dev.h>
> +
> +#define IFI_CANFD_STCMD				0x0
> +#define IFI_CANFD_STCMD_HARDRESET		0xDEADCAFD
> +#define IFI_CANFD_STCMD_ENABLE			BIT(0)
> +#define IFI_CANFD_STCMD_ERROR_ACTIVE		BIT(2)
> +#define IFI_CANFD_STCMD_ERROR_PASSIVE		BIT(3)
> +#define IFI_CANFD_STCMD_BUSOFF			BIT(4)
> +#define IFI_CANFD_STCMD_BUSMONITOR		BIT(16)
> +#define IFI_CANFD_STCMD_LOOPBACK		BIT(18)
> +#define IFI_CANFD_STCMD_DISABLE_CANFD		BIT(24)
> +#define IFI_CANFD_STCMD_ENABLE_ISO		BIT(25)
> +#define IFI_CANFD_STCMD_NORMAL_MODE		((u32)BIT(31))
> +
> +#define IFI_CANFD_RXSTCMD			0x4
> +#define IFI_CANFD_RXSTCMD_REMOVE_MSG		BIT(0)
> +#define IFI_CANFD_RXSTCMD_RESET			BIT(7)
> +#define IFI_CANFD_RXSTCMD_EMPTY			BIT(8)
> +#define IFI_CANFD_RXSTCMD_OVERFLOW		BIT(13)
> +
> +#define IFI_CANFD_TXSTCMD			0x8
> +#define IFI_CANFD_TXSTCMD_ADD_MSG		BIT(0)
> +#define IFI_CANFD_TXSTCMD_HIGH_PRIO		BIT(1)
> +#define IFI_CANFD_TXSTCMD_RESET			BIT(7)
> +#define IFI_CANFD_TXSTCMD_EMPTY			BIT(8)
> +#define IFI_CANFD_TXSTCMD_FULL			BIT(12)
> +#define IFI_CANFD_TXSTCMD_OVERFLOW		BIT(13)
> +
> +#define IFI_CANFD_INTERRUPT			0xc
> +#define IFI_CANFD_INTERRUPT_ERROR_WARNING	BIT(1)
> +#define IFI_CANFD_INTERRUPT_TXFIFO_EMPTY	BIT(16)
> +#define IFI_CANFD_INTERRUPT_TXFIFO_REMOVE	BIT(22)
> +#define IFI_CANFD_INTERRUPT_RXFIFO_NEMPTY	BIT(24)
> +#define IFI_CANFD_INTERRUPT_RXFIFO_NEMPTY_PER	BIT(25)
> +#define IFI_CANFD_INTERRUPT_SET_IRQ		((u32)BIT(31))
> +
> +#define IFI_CANFD_IRQMASK			0x10
> +#define IFI_CANFD_IRQMASK_SET_ERR		BIT(7)
> +#define IFI_CANFD_IRQMASK_SET_TS		BIT(15)
> +#define IFI_CANFD_IRQMASK_TXFIFO_EMPTY		BIT(16)
> +#define IFI_CANFD_IRQMASK_SET_TX		BIT(23)
> +#define IFI_CANFD_IRQMASK_RXFIFO_NEMPTY		BIT(24)
> +#define IFI_CANFD_IRQMASK_SET_RX		((u32)BIT(31))
> +
> +#define IFI_CANFD_TIME				0x14
> +#define IFI_CANFD_FTIME				0x18
> +#define IFI_CANFD_TIME_TIMEB_OFF		0
> +#define IFI_CANFD_TIME_TIMEA_OFF		8
> +#define IFI_CANFD_TIME_PRESCALE_OFF		16
> +#define IFI_CANFD_TIME_SJW_OFF_ISO		25
> +#define IFI_CANFD_TIME_SJW_OFF_BOSCH		28
> +#define IFI_CANFD_TIME_SET_SJW_BOSCH		BIT(6)
> +#define IFI_CANFD_TIME_SET_TIMEB_BOSCH		BIT(7)
> +#define IFI_CANFD_TIME_SET_PRESC_BOSCH		BIT(14)
> +#define IFI_CANFD_TIME_SET_TIMEA_BOSCH		BIT(15)
> +
> +#define IFI_CANFD_TDELAY			0x1c
> +
> +#define IFI_CANFD_ERROR				0x20
> +#define IFI_CANFD_ERROR_TX_OFFSET		0
> +#define IFI_CANFD_ERROR_TX_MASK			0xff
> +#define IFI_CANFD_ERROR_RX_OFFSET		16
> +#define IFI_CANFD_ERROR_RX_MASK			0xff
> +
> +#define IFI_CANFD_ERRCNT			0x24
> +
> +#define IFI_CANFD_SUSPEND			0x28
> +
> +#define IFI_CANFD_REPEAT			0x2c
> +
> +#define IFI_CANFD_TRAFFIC			0x30
> +
> +#define IFI_CANFD_TSCONTROL			0x34
> +
> +#define IFI_CANFD_TSC				0x38
> +
> +#define IFI_CANFD_TST				0x3c
> +
> +#define IFI_CANFD_RES1				0x40
> +
> +#define IFI_CANFD_RES2				0x44
> +
> +#define IFI_CANFD_PAR				0x48
> +
> +#define IFI_CANFD_CANCLOCK			0x4c
> +
> +#define IFI_CANFD_SYSCLOCK			0x50
> +
> +#define IFI_CANFD_VER				0x54
> +
> +#define IFI_CANFD_IP_ID				0x58
> +#define IFI_CANFD_IP_ID_VALUE			0xD073CAFD
> +
> +#define IFI_CANFD_TEST				0x5c
> +
> +#define IFI_CANFD_RXFIFO_TS_63_32		0x60
> +
> +#define IFI_CANFD_RXFIFO_TS_31_0		0x64
> +
> +#define IFI_CANFD_RXFIFO_DLC			0x68
> +#define IFI_CANFD_RXFIFO_DLC_DLC_OFFSET		0
> +#define IFI_CANFD_RXFIFO_DLC_DLC_MASK		0xf
> +#define IFI_CANFD_RXFIFO_DLC_RTR		BIT(4)
> +#define IFI_CANFD_RXFIFO_DLC_EDL		BIT(5)
> +#define IFI_CANFD_RXFIFO_DLC_BRS		BIT(6)
> +#define IFI_CANFD_RXFIFO_DLC_ESI		BIT(7)
> +#define IFI_CANFD_RXFIFO_DLC_OBJ_OFFSET		8
> +#define IFI_CANFD_RXFIFO_DLC_OBJ_MASK		0x1ff
> +#define IFI_CANFD_RXFIFO_DLC_FNR_OFFSET		24
> +#define IFI_CANFD_RXFIFO_DLC_FNR_MASK		0xff
> +
> +#define IFI_CANFD_RXFIFO_ID			0x6c
> +#define IFI_CANFD_RXFIFO_ID_ID_OFFSET		0
> +#define IFI_CANFD_RXFIFO_ID_ID_STD_MASK		0x3ff
> +#define IFI_CANFD_RXFIFO_ID_ID_XTD_MASK		0x1fffffff
> +#define IFI_CANFD_RXFIFO_ID_IDE			BIT(29)
> +
> +#define IFI_CANFD_RXFIFO_DATA			0x70	/* 0x70..0xac */
> +
> +#define IFI_CANFD_TXFIFO_SUSPEND_US		0xb0
> +
> +#define IFI_CANFD_TXFIFO_REPEATCOUNT		0xb4
> +
> +#define IFI_CANFD_TXFIFO_DLC			0xb8
> +#define IFI_CANFD_TXFIFO_DLC_DLC_OFFSET		0
> +#define IFI_CANFD_TXFIFO_DLC_DLC_MASK		0xf
> +#define IFI_CANFD_TXFIFO_DLC_RTR		BIT(4)
> +#define IFI_CANFD_TXFIFO_DLC_EDL		BIT(5)
> +#define IFI_CANFD_TXFIFO_DLC_BRS		BIT(6)
> +#define IFI_CANFD_TXFIFO_DLC_FNR_OFFSET		24
> +#define IFI_CANFD_TXFIFO_DLC_FNR_MASK		0xff
> +
> +#define IFI_CANFD_TXFIFO_ID			0xbc
> +#define IFI_CANFD_TXFIFO_ID_ID_OFFSET		0
> +#define IFI_CANFD_TXFIFO_ID_ID_STD_MASK		0x3ff
> +#define IFI_CANFD_TXFIFO_ID_ID_XTD_MASK		0x1fffffff
> +#define IFI_CANFD_TXFIFO_ID_IDE			BIT(29)
> +
> +#define IFI_CANFD_TXFIFO_DATA			0xc0	/* 0xb0..0xfc */
> +
> +#define IFI_CANFD_FILTER_MASK(n)		(0x800 + ((n) * 8) + 0)
> +#define IFI_CANFD_FILTER_MASK_EXT		BIT(29)
> +#define IFI_CANFD_FILTER_MASK_EDL		BIT(30)
> +#define IFI_CANFD_FILTER_MASK_VALID		((u32)BIT(31))
> +
> +#define IFI_CANFD_FILTER_IDENT(n)		(0x800 + ((n) * 8) + 4)
> +#define IFI_CANFD_FILTER_IDENT_IDE		BIT(29)
> +#define IFI_CANFD_FILTER_IDENT_CANFD		BIT(30)
> +#define IFI_CANFD_FILTER_IDENT_VALID		((u32)BIT(31))
> +
> +/* IFI CANFD private data structure */
> +struct ifi_canfd_priv {
> +	struct can_priv		can;	/* must be the first member */
> +	struct napi_struct	napi;
> +	struct net_device	*ndev;
> +	void __iomem		*base;
> +};
> +
> +static void ifi_canfd_irq_enable(struct net_device *ndev, bool enable)=

> +{
> +	struct ifi_canfd_priv *priv =3D netdev_priv(ndev);
> +	u32 enirq =3D 0;
> +
> +	if (enable) {
> +		enirq =3D IFI_CANFD_IRQMASK_TXFIFO_EMPTY |
> +			IFI_CANFD_IRQMASK_RXFIFO_NEMPTY;
> +	}
> +
> +	writel(IFI_CANFD_IRQMASK_SET_ERR |
> +	       IFI_CANFD_IRQMASK_SET_TS |
> +	       IFI_CANFD_IRQMASK_SET_TX |
> +	       IFI_CANFD_IRQMASK_SET_RX | enirq,
> +	       priv->base + IFI_CANFD_IRQMASK);
> +}
> +
> +static void ifi_canfd_read_fifo(struct net_device *ndev)
> +{
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	struct ifi_canfd_priv *priv =3D netdev_priv(ndev);
> +	struct canfd_frame *cf;
> +	struct sk_buff *skb;
> +	const u32 rx_irq_mask =3D IFI_CANFD_INTERRUPT_RXFIFO_NEMPTY |
> +				IFI_CANFD_INTERRUPT_RXFIFO_NEMPTY_PER;
> +	u32 rxdlc, rxid;
> +	u32 dlc, id;
> +	int i;
> +
> +	rxdlc =3D readl(priv->base + IFI_CANFD_RXFIFO_DLC);
> +	if (rxdlc & IFI_CANFD_RXFIFO_DLC_EDL)
> +		skb =3D alloc_canfd_skb(ndev, &cf);
> +	else
> +		skb =3D alloc_can_skb(ndev, (struct can_frame **)&cf);
> +
> +	if (!skb) {
> +		stats->rx_dropped++;
> +		return;
> +	}
> +
> +	dlc =3D (rxdlc >> IFI_CANFD_RXFIFO_DLC_DLC_OFFSET) &
> +	      IFI_CANFD_RXFIFO_DLC_DLC_MASK;
> +	if (rxdlc & IFI_CANFD_RXFIFO_DLC_EDL)
> +		cf->len =3D can_dlc2len(dlc);
> +	else
> +		cf->len =3D get_can_dlc(dlc);
> +
> +	rxid =3D readl(priv->base + IFI_CANFD_RXFIFO_ID);
> +	id =3D (rxid >> IFI_CANFD_RXFIFO_ID_ID_OFFSET);
> +	if (id & IFI_CANFD_RXFIFO_ID_IDE)
> +		id &=3D IFI_CANFD_RXFIFO_ID_ID_XTD_MASK;
> +	else
> +		id &=3D IFI_CANFD_RXFIFO_ID_ID_STD_MASK;
> +	cf->can_id =3D id;
> +
> +	if (rxdlc & IFI_CANFD_RXFIFO_DLC_ESI) {
> +		cf->flags |=3D CANFD_ESI;
> +		netdev_dbg(ndev, "ESI Error\n");
> +	}
> +
> +	if (!(rxdlc & IFI_CANFD_RXFIFO_DLC_EDL) &&
> +	    (rxdlc & IFI_CANFD_RXFIFO_DLC_RTR)) {
> +		cf->can_id |=3D CAN_RTR_FLAG;
> +	} else {
> +		if (rxdlc & IFI_CANFD_RXFIFO_DLC_BRS)
> +			cf->flags |=3D CANFD_BRS;
> +
> +		for (i =3D 0; i < cf->len; i +=3D 4) {
> +			*(u32 *)(cf->data + i) =3D
> +				readl(priv->base + IFI_CANFD_RXFIFO_DATA + i);
> +		}
> +	}
> +
> +	/* Remove the packet from FIFO */
> +	writel(IFI_CANFD_RXSTCMD_REMOVE_MSG, priv->base + IFI_CANFD_RXSTCMD);=

> +	writel(rx_irq_mask, priv->base + IFI_CANFD_INTERRUPT);
> +
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->len;
> +
> +	netif_receive_skb(skb);
> +}
> +
> +static int ifi_canfd_do_rx_poll(struct net_device *ndev, int quota)
> +{
> +	struct ifi_canfd_priv *priv =3D netdev_priv(ndev);
> +	u32 pkts =3D 0;
> +	u32 rxst;
> +
> +	rxst =3D readl(priv->base + IFI_CANFD_RXSTCMD);
> +	if (rxst & IFI_CANFD_RXSTCMD_EMPTY) {
> +		netdev_dbg(ndev, "No messages in RX FIFO\n");
> +		return 0;
> +	}
> +
> +	for (;;) {
> +		if (rxst & IFI_CANFD_RXSTCMD_EMPTY)
> +			break;
> +		if (quota <=3D 0)
> +			break;
> +
> +		ifi_canfd_read_fifo(ndev);
> +		quota--;
> +		pkts++;
> +		rxst =3D readl(priv->base + IFI_CANFD_RXSTCMD);
> +	}
> +
> +	if (pkts)
> +		can_led_event(ndev, CAN_LED_EVENT_RX);
> +
> +	return pkts;
> +}
> +
> +static int ifi_canfd_handle_lost_msg(struct net_device *ndev)
> +{
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	struct sk_buff *skb;
> +	struct can_frame *frame;
> +
> +	netdev_err(ndev, "RX FIFO overflow, message(s) lost.\n");
> +
> +	stats->rx_errors++;
> +	stats->rx_over_errors++;
> +
> +	skb =3D alloc_can_err_skb(ndev, &frame);
> +	if (unlikely(!skb))
> +		return 0;
> +
> +	frame->can_id |=3D CAN_ERR_CRTL;
> +	frame->data[1] =3D CAN_ERR_CRTL_RX_OVERFLOW;
> +
> +	netif_receive_skb(skb);
> +
> +	return 1;
> +}
> +
> +static int ifi_canfd_get_berr_counter(const struct net_device *ndev,
> +				      struct can_berr_counter *bec)
> +{
> +	struct ifi_canfd_priv *priv =3D netdev_priv(ndev);
> +	u32 err;
> +
> +	err =3D readl(priv->base + IFI_CANFD_ERROR);
> +	bec->rxerr =3D (err >> IFI_CANFD_ERROR_RX_OFFSET) &
> +		     IFI_CANFD_ERROR_RX_MASK;
> +	bec->txerr =3D (err >> IFI_CANFD_ERROR_TX_OFFSET) &
> +		     IFI_CANFD_ERROR_TX_MASK;
> +
> +	return 0;
> +}
> +
> +static int ifi_canfd_handle_state_change(struct net_device *ndev,
> +					 enum can_state new_state)
> +{
> +	struct ifi_canfd_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	struct can_berr_counter bec;
> +
> +	switch (new_state) {
> +	case CAN_STATE_ERROR_ACTIVE:
> +		/* error warning state */
> +		priv->can.can_stats.error_warning++;
> +		priv->can.state =3D CAN_STATE_ERROR_WARNING;
> +		break;
> +	case CAN_STATE_ERROR_PASSIVE:
> +		/* error passive state */
> +		priv->can.can_stats.error_passive++;
> +		priv->can.state =3D CAN_STATE_ERROR_PASSIVE;
> +		break;
> +	case CAN_STATE_BUS_OFF:
> +		/* bus-off state */
> +		priv->can.state =3D CAN_STATE_BUS_OFF;
> +		ifi_canfd_irq_enable(ndev, 0);
> +		priv->can.can_stats.bus_off++;
> +		can_bus_off(ndev);
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	/* propagate the error condition to the CAN stack */
> +	skb =3D alloc_can_err_skb(ndev, &cf);
> +	if (unlikely(!skb))
> +		return 0;
> +
> +	ifi_canfd_get_berr_counter(ndev, &bec);
> +
> +	switch (new_state) {
> +	case CAN_STATE_ERROR_ACTIVE:
> +		/* error warning state */
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		cf->data[1] =3D (bec.txerr > bec.rxerr) ?
> +			CAN_ERR_CRTL_TX_WARNING :
> +			CAN_ERR_CRTL_RX_WARNING;
> +		cf->data[6] =3D bec.txerr;
> +		cf->data[7] =3D bec.rxerr;
> +		break;
> +	case CAN_STATE_ERROR_PASSIVE:
> +		/* error passive state */
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		cf->data[1] |=3D CAN_ERR_CRTL_RX_PASSIVE;
> +		if (bec.txerr > 127)
> +			cf->data[1] |=3D CAN_ERR_CRTL_TX_PASSIVE;
> +		cf->data[6] =3D bec.txerr;
> +		cf->data[7] =3D bec.rxerr;
> +		break;
> +	case CAN_STATE_BUS_OFF:
> +		/* bus-off state */
> +		cf->can_id |=3D CAN_ERR_BUSOFF;
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->can_dlc;
> +	netif_receive_skb(skb);
> +
> +	return 1;
> +}
> +
> +static int ifi_canfd_handle_state_errors(struct net_device *ndev, u32 =
stcmd)
> +{
> +	struct ifi_canfd_priv *priv =3D netdev_priv(ndev);
> +	int work_done =3D 0;
> +	u32 isr;
> +
> +	/*
> +	 * The ErrWarn condition is a little special, since the bit is
> +	 * located in the INTERRUPT register instead of STCMD register.
> +	 */
> +	isr =3D readl(priv->base + IFI_CANFD_INTERRUPT);
> +	if ((isr & IFI_CANFD_INTERRUPT_ERROR_WARNING) &&
> +	    (priv->can.state !=3D CAN_STATE_ERROR_WARNING)) {
> +		/* Clear the interrupt */
> +		writel(IFI_CANFD_INTERRUPT_ERROR_WARNING,
> +		       priv->base + IFI_CANFD_INTERRUPT);
> +		netdev_dbg(ndev, "Error, entered warning state\n");
> +		work_done +=3D ifi_canfd_handle_state_change(ndev,
> +						CAN_STATE_ERROR_WARNING);
> +	}
> +
> +	if ((stcmd & IFI_CANFD_STCMD_ERROR_PASSIVE) &&
> +	    (priv->can.state !=3D CAN_STATE_ERROR_PASSIVE)) {
> +		netdev_dbg(ndev, "Error, entered passive state\n");
> +		work_done +=3D ifi_canfd_handle_state_change(ndev,
> +						CAN_STATE_ERROR_PASSIVE);
> +	}
> +
> +	if ((stcmd & IFI_CANFD_STCMD_BUSOFF) &&
> +	    (priv->can.state !=3D CAN_STATE_BUS_OFF)) {
> +		netdev_dbg(ndev, "Error, entered bus-off state\n");
> +		work_done +=3D ifi_canfd_handle_state_change(ndev,
> +						CAN_STATE_BUS_OFF);
> +	}
> +
> +	return work_done;
> +}
> +
> +static int ifi_canfd_poll(struct napi_struct *napi, int quota)
> +{
> +	struct net_device *ndev =3D napi->dev;
> +	struct ifi_canfd_priv *priv =3D netdev_priv(ndev);
> +	const u32 stcmd_state_mask =3D IFI_CANFD_STCMD_ERROR_PASSIVE |
> +				     IFI_CANFD_STCMD_BUSOFF;
> +	int work_done =3D 0;
> +
> +	u32 stcmd =3D readl(priv->base + IFI_CANFD_STCMD);
> +	u32 rxstcmd =3D readl(priv->base + IFI_CANFD_STCMD);
> +
> +	/* Handle bus state changes */
> +	if ((stcmd & stcmd_state_mask) ||
> +	    ((stcmd & IFI_CANFD_STCMD_ERROR_ACTIVE) =3D=3D 0))
> +		work_done +=3D ifi_canfd_handle_state_errors(ndev, stcmd);
> +
> +	/* Handle lost messages on RX */
> +	if (rxstcmd & IFI_CANFD_RXSTCMD_OVERFLOW)
> +		work_done +=3D ifi_canfd_handle_lost_msg(ndev);
> +
> +	/* Handle normal messages on RX */
> +	if (!(rxstcmd & IFI_CANFD_RXSTCMD_EMPTY))
> +		work_done +=3D ifi_canfd_do_rx_poll(ndev, quota - work_done);
> +
> +	if (work_done < quota) {
> +		napi_complete(napi);
> +		ifi_canfd_irq_enable(ndev, 1);
> +	}
> +
> +	return work_done;
> +}
> +
> +static irqreturn_t ifi_canfd_isr(int irq, void *dev_id)
> +{
> +	struct net_device *ndev =3D (struct net_device *)dev_id;
> +	struct ifi_canfd_priv *priv =3D netdev_priv(ndev);
> +	struct net_device_stats *stats =3D &ndev->stats;
> +	const u32 rx_irq_mask =3D IFI_CANFD_INTERRUPT_RXFIFO_NEMPTY |
> +				IFI_CANFD_INTERRUPT_RXFIFO_NEMPTY_PER;
> +	const u32 tx_irq_mask =3D IFI_CANFD_INTERRUPT_TXFIFO_EMPTY |
> +				IFI_CANFD_INTERRUPT_TXFIFO_REMOVE;
> +	const u32 clr_irq_mask =3D (u32)(~(IFI_CANFD_INTERRUPT_SET_IRQ |
> +					 IFI_CANFD_INTERRUPT_ERROR_WARNING));

I've squashed:

>> -       const u32 clr_irq_mask =3D (u32)(~(IFI_CANFD_INTERRUPT_SET_IRQ=
 |
>> -                                        IFI_CANFD_INTERRUPT_ERROR_WAR=
NING));
>> +       const u32 clr_irq_mask =3D ~(IFI_CANFD_INTERRUPT_SET_IRQ |
>> +                                  IFI_CANFD_INTERRUPT_ERROR_WARNING);=


and the driver compiles without warnings.

Applied to can-next.

thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--02DlCLdD3CCIoKv0PexnbFmENP84NqulV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWn5w3AAoJEP5prqPJtc/Hm9sH/3UDcR9aWBEBp2wOx/VMhhYr
QL8+eN11DfSopFiz14r8CYb36S1U5n2rmKLylOYTSuZ/H2rzslyh6707VlymAsiM
8SI7+VbeM7ffOyHs6ewHPFYM4SVluo7UHXuAHFXN/b5ss7153dWCJVTtQ2EgM8nq
ggY1CR3GZwaY18jQOwv/J3aDwVhgJGBho083M+mGejbeYzP0ZtwulLc0PTm3Ik3D
C9gUuPs2BbQdJagQRxq9ycNOHwxocSdqFlvFfx+cpg9oRGjbOttiC6FD3phBdXKf
v6iqP/7SXPk+1hugiCffGJuFVil/1N+/GP2OemFmMxjjzmrZVv5IvhdW4P/R8Sc=
=M9YC
-----END PGP SIGNATURE-----

--02DlCLdD3CCIoKv0PexnbFmENP84NqulV--
