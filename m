From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH V2 5/5] net: can: ifi: Add IFI CANFD IP support
Date: Wed, 20 Jan 2016 11:39:00 +0100
Message-ID: <569F63C4.4070708@pengutronix.de>
References: <1452538083-7331-5-git-send-email-marex@denx.de>
 <1452643156-7291-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="BreaOAnIm2rOCQVT2pUFLtEAqSTcaLh7e"
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Mark Rutland <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Marek Vasut <marex@denx.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:35735 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934498AbcATKjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 05:39:13 -0500
In-Reply-To: <1452643156-7291-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--BreaOAnIm2rOCQVT2pUFLtEAqSTcaLh7e
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/13/2016 12:59 AM, Marek Vasut wrote:
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
> NOTE: The driver is surprisingly similar to m_can, but the register
>       layout of the IFI core is completely different, so it's clear
>       that those are two different IP cores.
> ---
>  drivers/net/can/Kconfig               |   2 +
>  drivers/net/can/Makefile              |   1 +
>  drivers/net/can/ifi_canfd/Kconfig     |   8 +
>  drivers/net/can/ifi_canfd/Makefile    |   5 +
>  drivers/net/can/ifi_canfd/ifi_canfd.c | 919 ++++++++++++++++++++++++++=
++++++++
>  5 files changed, 935 insertions(+)
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
> index 0000000..094c36b
> --- /dev/null
> +++ b/drivers/net/can/ifi_canfd/ifi_canfd.c
> @@ -0,0 +1,919 @@
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
> +#define IFI_CANFD_STCMD_NORMAL_MODE		BIT(31)
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
> +#define IFI_CANFD_INTERRUPT_SET_IRQ		BIT(31)
> +
> +#define IFI_CANFD_IRQMASK			0x10
> +#define IFI_CANFD_IRQMASK_SET_ERR		BIT(7)
> +#define IFI_CANFD_IRQMASK_SET_TS		BIT(15)
> +#define IFI_CANFD_IRQMASK_TXFIFO_EMPTY		BIT(16)
> +#define IFI_CANFD_IRQMASK_SET_TX		BIT(23)
> +#define IFI_CANFD_IRQMASK_RXFIFO_NEMPTY		BIT(24)
> +#define IFI_CANFD_IRQMASK_SET_RX		BIT(31)
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
> +#define IFI_CANFD_FILTER_MASK_VALID		BIT(31)
> +
> +#define IFI_CANFD_FILTER_IDENT(n)		(0x800 + ((n) * 8) + 4)
> +#define IFI_CANFD_FILTER_IDENT_IDE		BIT(29)
> +#define IFI_CANFD_FILTER_IDENT_CANFD		BIT(30)
> +#define IFI_CANFD_FILTER_IDENT_VALID		BIT(31)
> +
> +/* IFI CANFD private data structure */
> +struct ifi_canfd_priv {
> +	struct can_priv		can;	/* must be the first member */
> +	struct napi_struct	napi;
> +	struct net_device	*ndev;
> +	struct device		*device;

Nitpick: This variable is write only, correct? I can fix this while
applying the patch.

> +	void __iomem		*base;
> +};

Otherweise looks good.

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--BreaOAnIm2rOCQVT2pUFLtEAqSTcaLh7e
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWn2PFAAoJEP5prqPJtc/HLekH+wSkR/Lww9m6g+P6S/6FTF8d
1goln/jQccaBTa/kVPD9wfMqOO1HfcUqDq74guHSyiKyouGUr6gOQzZAdzfX+m86
vPQRsum1cZrEuKFTDiyV6Hk5UERG49YGNAA0TMZQCkgJBGxHgJmu2/1sWnvxk5eG
CeEFpJA5ib89bqGa8OTR2/mZE+4Rv5AKRzmj54fauIZt67CvXQ80gc9dteZuFZ8Q
fdgjlyC0b8Nm4XUfW82DTOra2g+PCsSfUuwsRMisW6bCaX5L5tAM6OpvfEoZJWvo
kYhtrn7liQm/vAfmKHIJvlLk2CL72yxN7JyMbvVQ0tzBvFLX2U1jV36MSsvAg5w=
=1fWk
-----END PGP SIGNATURE-----

--BreaOAnIm2rOCQVT2pUFLtEAqSTcaLh7e--
