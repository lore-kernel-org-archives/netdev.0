From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v2] add the driver for Analog Devices Blackfin on-chip
	CAN	controllers
Date: Wed, 09 Dec 2009 13:39:54 +0100
Message-ID: <4B1F9A9A.9060900@pengutronix.de>
References: <1260353277-30902-1-git-send-email-21cnbao@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org,
	wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Barry Song <21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1260353277-30902-1-git-send-email-21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Barry Song wrote:
> Signed-off-by: Barry Song <21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: H.J. Oertel <oe-pJ9TYRvN+WE@public.gmane.org>
> ---
> 	-v2: cleanup according to Wolfgang Grandegger's feedback
> 	1.delete some unnecessary debug print
> 	2.delete ndo_tx_timeout entry as it is not needed in can 
> 	3.use alloc_can_skb, alloc_can_err_skb instead of netdev_alloc_skb
> 	4.add timeout while polling can status
> 	5.rename BFIN_CAN_READ/WRITE_MSG to bfin_can_read/write_data
> 	6.use kernel BIT instead of bit shift
> 	7.use void __iomem * for CAN memory base memory instead of u32
> 	8.delete "dev->last_rx = jiffies" since it is not needed now
> 	9.delete redundant "echo_skb" member in bfin can private data
> 	10.follow can convention to use "_" instead of "-" for file names
> 
>  drivers/net/can/Kconfig    |    9 +
>  drivers/net/can/Makefile   |    1 +
>  drivers/net/can/bfin_can.c |  786 ++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 796 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/bfin_can.c
> 
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index bb803fa..8c485aa 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -54,6 +54,15 @@ config CAN_MCP251X
>  	---help---
>  	  Driver for the Microchip MCP251x SPI CAN controllers.
>  
> +config CAN_BFIN
> +	depends on CAN_DEV && (BF534 || BF536 || BF537 || BF538 || BF539 || BF54x)
> +	tristate "Analog Devices Blackfin on-chip CAN"
> +	---help---
> +	  Driver for the Analog Devices Blackfin on-chip CAN controllers
> +
> +	  To compile this driver as a module, choose M here: the
> +	  module will be called bfin_can.
> +
>  source "drivers/net/can/mscan/Kconfig"
>  
>  source "drivers/net/can/sja1000/Kconfig"
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 56899fe..7a702f2 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -14,5 +14,6 @@ obj-$(CONFIG_CAN_MSCAN)		+= mscan/
>  obj-$(CONFIG_CAN_AT91)		+= at91_can.o
>  obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
>  obj-$(CONFIG_CAN_MCP251X)	+= mcp251x.o
> +obj-$(CONFIG_CAN_BFIN)		+= bfin_can.o
>  
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
> diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
> new file mode 100644
> index 0000000..36a9f8c
> --- /dev/null
> +++ b/drivers/net/can/bfin_can.c
> @@ -0,0 +1,786 @@
> +/*
> + * Blackfin On-Chip CAN Driver
> + *
> + * Copyright 2004-2009 Analog Devices Inc.
> + *
> + * Enter bugs at http://blackfin.uclinux.org/
> + *
> + * Licensed under the GPL-2 or later.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/bitops.h>
> +#include <linux/interrupt.h>
> +#include <linux/errno.h>
> +#include <linux/netdevice.h>
> +#include <linux/skbuff.h>
> +#include <linux/platform_device.h>
> +
> +#include <linux/can.h>
> +#include <linux/can/dev.h>
> +#include <linux/can/error.h>
> +
> +#include <asm/portmux.h>
> +
> +#define DRV_NAME "bfin_can"
> +#define BFIN_CAN_TIMEOUT 100
> +
> +/*
> + * registers offset
> + */
> +#define OFFSET_MB_MASK              0x100
> +#define OFFSET_MASK_AML             0x0
> +#define OFFSET_MASK_AMH             0x4
> +#define OFFSET_MB_OBJ               0x200
> +#define OFFSET_OBJ_DATA             0x0
> +#define OFFSET_OBJ_DLC              0x10
> +#define OFFSET_OBJ_ID0              0x18
> +#define OFFSET_OBJ_ID1              0x1C
> +#define OFFSET_CLOCK                0x80
> +#define OFFSET_TIMING               0x84
> +#define OFFSET_STATUS               0x8C
> +#define OFFSET_CEC                  0x90
> +#define OFFSET_GIS                  0x94
> +#define OFFSET_GIM                  0x98
> +#define OFFSET_CONTROL              0xA0
> +#define OFFSET_INTR                 0xA4
> +#define OFFSET_ESR                  0xB4
> +#define OFFSET_MBIM1                0x28
> +#define OFFSET_MBIM2                0x68
> +#define OFFSET_MC1                  0x0
> +#define OFFSET_MC2                  0x40
> +#define OFFSET_MD1                  0x4
> +#define OFFSET_MD2                  0x44
> +#define OFFSET_TRS2                 0x48
> +#define OFFSET_MBTIF1               0x20
> +#define OFFSET_MBTIF2               0x60
> +#define OFFSET_MBRIF1               0x24
> +#define OFFSET_MBRIF2               0x64
> +
> +/*
> + * transmit and receive channels
> + */
> +#define TRANSMIT_CHL		24
> +#define RECEIVE_STD_CHL 	0
> +#define RECEIVE_EXT_CHL 	4
> +#define RECEIVE_RTR_CHL 	8
> +#define RECEIVE_EXT_RTR_CHL 	12
> +
> +/*
> + * bfin can private data
> + */
> +struct bfin_can_priv {
> +	struct can_priv can;	/* must be the first member */
> +	struct net_device *dev;
> +	void __iomem *membase;
> +	int rx_irq;
> +	int tx_irq;
> +	int err_irq;
> +	unsigned short *pin_list;
> +};
> +
> +/*
> + * read/write CAN registers and messages
> + */
> +#define can_membase(priv)  \
> +	((priv)->membase)
> +#define can_channel_membase(priv, channel) \
> +	((priv)->membase + OFFSET_MB_OBJ + ((channel) << 5))
> +#define can_mask_membase(priv, channel)  \
> +	((priv)->membase + OFFSET_MB_MASK + ((channel) << 3))
> +
> +#define CAN_WRITE_REG(val, addr) \
> +	writew((val), (addr))
> +
> +#define CAN_READ_REG(addr) \
> +	readw((addr))
> +
> +#define CAN_WRITE_CTRL(priv, off, val) \
> +	CAN_WRITE_REG(val, can_membase((priv)) + (off))
> +
> +#define CAN_READ_CTRL(priv, off) \
> +	CAN_READ_REG(can_membase((priv)) + (off))
> +
> +#define CAN_WRITE_AML(priv, channel, aml) \
> +	(CAN_WRITE_REG((aml), can_mask_membase(priv, channel) + OFFSET_MASK_AML))
> +
> +#define CAN_WRITE_AMH(priv, channel, amh) \
> +	(CAN_WRITE_REG((amh), can_mask_membase(priv, channel) + OFFSET_MASK_AMH))
> +
> +#define CAN_WRITE_DLC(priv, channel, length) \
> +	(CAN_WRITE_REG((length), can_channel_membase(priv, channel) + OFFSET_OBJ_DLC))
> +
> +#define CAN_READ_DLC(priv, channel) \
> +	(CAN_READ_REG(can_channel_membase((priv), (channel)) + OFFSET_OBJ_DLC))
> +
> +#define CAN_READ_OID(priv, channel) \
> +	((CAN_READ_REG(can_channel_membase((priv), (channel)) + OFFSET_OBJ_ID1) & 0x1ffc) >> 2)
> +
> +#define CAN_READ_XOID(priv, channel) \
> +	(((CAN_READ_REG(can_channel_membase((priv), (channel)) + OFFSET_OBJ_ID1) & 0x1fff) << 16) \
> +	 + ((CAN_READ_REG(can_channel_membase((priv), (channel)) + OFFSET_OBJ_ID0))))
> +
> +#define CAN_READ_ID1(priv, channel) \
> +	(CAN_READ_REG(can_channel_membase((priv), (channel)) + OFFSET_OBJ_ID1))
> +
> +#define CAN_WRITE_ID0(priv, channel, val) \
> +	CAN_WRITE_REG((val), can_channel_membase((priv), (channel)) + OFFSET_OBJ_ID0)
> +
> +#define CAN_WRITE_OID(priv, channel, id) \
> +	CAN_WRITE_REG(((id) << 2) | AME, can_channel_membase((priv), (channel)) + OFFSET_OBJ_ID1)
> +
> +#define CAN_WRITE_XOID(priv, channel, id)  \
> +	do { \
> +		CAN_WRITE_REG((id), can_channel_membase((priv), (channel)) + OFFSET_OBJ_ID0); \
> +		CAN_WRITE_REG((((id) & 0x1FFF0000) >> 16) + IDE + AME, \
> +				can_channel_membase((priv), (channel)) + OFFSET_OBJ_ID1); \
> +	} while (0)
> +
> +#define CAN_WRITE_OID_RTR(priv, channel, id) \
> +	CAN_WRITE_REG(((id) << 2) | RTR | AME, can_channel_membase((priv), (channel)) + OFFSET_OBJ_ID1)
> +
> +#define CAN_WRITE_XOID_RTR(priv, channel, id)  \
> +	do { \
> +		CAN_WRITE_REG((id), can_channel_membase((priv), (channel)) + OFFSET_OBJ_ID0); \
> +		CAN_WRITE_REG((((id) & 0x1FFF0000) >> 16) + IDE + RTR + AME, \
> +				can_channel_membase((priv), (channel)) + OFFSET_OBJ_ID1); \
> +	} while (0)

If you want to stay to the register offsets, consider converting these
defines into static inline functions. If you put the register offsets
into an enum you also have type checking with sparse.

cheers, Marc
- --
Pengutronix e.K.                         | Marc Kleine-Budde           |
Linux Solutions for Science and Industry | Phone: +49-231-2826-924     |
Vertretung West/Dortmund                 | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686         | http://www.pengutronix.de   |
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAksfmpoACgkQjTAFq1RaXHMKfwCffQJ+spRj42tTDNPyY0pxcyFd
5w8AnjEt4NV0O75AE3CU+RV0sZG7UtJl
=e5G1
-----END PGP SIGNATURE-----
