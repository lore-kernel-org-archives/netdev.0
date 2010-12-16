From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2 1/1] can: c_can: Added support for Bosch
	C_CAN	controller
Date: Thu, 16 Dec 2010 10:11:13 +0100
Message-ID: <4D09D7B1.9080906@grandegger.com>
References: <1292407130-19791-1-git-send-email-bhupesh.sharma@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1292407130-19791-1-git-send-email-bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
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

Hi Bhupesh,

thanks for your contribution.

On 12/15/2010 10:58 AM, Bhupesh Sharma wrote:
> Bosch C_CAN controller is a full-CAN implementation which is compliant
> to CAN protocol version 2.0 part A and B. Bosch C_CAN user manual can be
> obtained from:
> http://www.semiconductors.bosch.de/pdf/Users_Manual_C_CAN.pdf
> 
> This patch adds the support for this controller.
> The following are the design choices made while writing the controller driver:
> 1. Interface Register set IF1 has be used only in the current design.
> 2. Out of the 32 Message objects available, 16 are kept aside for RX purposes
>    and the rest for TX purposes.
> 3. NAPI implementation is such that both the TX and RX paths function in
>    polling mode.
> 
> Changes since V1:
> 1. Implemented C_CAN as a platform driver with means of providing the
>    platform details and register offsets which may vary for different SoCs
>    through platform data struct.
> 2. Implemented NAPI.
> 3. Removed memcpy calls globally.
> 4. Implemented CAN_CTRLMODE_*
> 5. Implemented and used priv->can.do_get_berr_counter.
> 6. Implemented c_can registers as a struct instead of enum.
> 7. Improved the TX path by implementing routines to get next Tx and echo msg
>    objects.
> 
> Signed-off-by: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
> ---
>  drivers/net/can/Kconfig  |    7 +
>  drivers/net/can/Makefile |    1 +
>  drivers/net/can/c_can.c  | 1217 ++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 1225 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/c_can.c
> 
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 9d9e453..25d9d2e 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -41,6 +41,13 @@ config CAN_AT91
>  	---help---
>  	  This is a driver for the SoC CAN controller in Atmel's AT91SAM9263.
>  
> +config CAN_C_CAN
> +	tristate "Bosch C_CAN controller"
> +	depends on CAN_DEV
> +	---help---
> +	  If you say yes to this option, support will be included for the
> +	  Bosch C_CAN controller.
> +
>  config CAN_TI_HECC
>  	depends on CAN_DEV && ARCH_OMAP3
>  	tristate "TI High End CAN Controller"
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 0057537..b6cbe74 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -12,6 +12,7 @@ obj-y				+= usb/
>  obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
>  obj-$(CONFIG_CAN_MSCAN)		+= mscan/
>  obj-$(CONFIG_CAN_AT91)		+= at91_can.o
> +obj-$(CONFIG_CAN_C_CAN)		+= c_can.o
>  obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
>  obj-$(CONFIG_CAN_MCP251X)	+= mcp251x.o
>  obj-$(CONFIG_CAN_BFIN)		+= bfin_can.o
> diff --git a/drivers/net/can/c_can.c b/drivers/net/can/c_can.c
> new file mode 100644
> index 0000000..c281c17
> --- /dev/null
> +++ b/drivers/net/can/c_can.c
> @@ -0,0 +1,1217 @@
> +/*
> + * CAN bus driver for Bosch C_CAN controller
> + *
> + * Copyright (C) 2010 ST Microelectronics
> + * Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
> + *
> + * Borrowed heavily from the C_CAN driver originally written by:
> + * Copyright (C) 2007
> + * - Sascha Hauer, Marc Kleine-Budde, Pengutronix <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> + * - Simon Kallweit, intefo AG <simon.kallweit-+G9qxTFKJT/tRgLqZ5aouw@public.gmane.org>
> + *
> + * Bosch C_CAN controller is compliant to CAN protocol version 2.0 part A and B.
> + * Bosch C_CAN user manual can be obtained from:
> + * http://www.semiconductors.bosch.de/pdf/Users_Manual_C_CAN.pdf
> + *
> + * This file is licensed under the terms of the GNU General Public
> + * License version 2. This program is licensed "as is" without any
> + * warranty of any kind, whether express or implied.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/version.h>
> +#include <linux/module.h>
> +#include <linux/interrupt.h>
> +#include <linux/delay.h>
> +#include <linux/netdevice.h>
> +#include <linux/if_arp.h>
> +#include <linux/if_ether.h>
> +#include <linux/list.h>
> +#include <linux/delay.h>
> +#include <linux/workqueue.h>
> +#include <linux/io.h>
> +#include <linux/platform_device.h>
> +#include <linux/clk.h>
> +
> +#include <linux/can.h>
> +#include <linux/can/dev.h>
> +#include <linux/can/error.h>
> +
> +#define DRV_NAME "c_can"
> +
> +/* control register */
> +#define CONTROL_TEST		(1 << 7)
> +#define CONTROL_CCE		(1 << 6)
> +#define CONTROL_DISABLE_AR	(1 << 5)
> +#define CONTROL_ENABLE_AR	(0 << 5)
> +#define CONTROL_EIE		(1 << 3)
> +#define CONTROL_SIE		(1 << 2)
> +#define CONTROL_IE		(1 << 1)
> +#define CONTROL_INIT		(1 << 0)
> +
> +/* test register */
> +#define TEST_RX			(1 << 7)
> +#define TEST_TX1		(1 << 6)
> +#define TEST_TX2		(1 << 5)
> +#define TEST_LBACK		(1 << 4)
> +#define TEST_SILENT		(1 << 3)
> +#define TEST_BASIC		(1 << 2)
> +
> +/* status register */
> +#define STATUS_BOFF		(1 << 7)
> +#define STATUS_EWARN		(1 << 6)
> +#define STATUS_EPASS		(1 << 5)
> +#define STATUS_RXOK		(1 << 4)
> +#define STATUS_TXOK		(1 << 3)
> +#define STATUS_LEC_MASK		0x07
> +#define LEC_STUFF_ERROR		1
> +#define LEC_FORM_ERROR		2
> +#define LEC_ACK_ERROR		3
> +#define LEC_BIT1_ERROR		4
> +#define LEC_BIT0_ERROR		5
> +#define LEC_CRC_ERROR		6
> +
> +/* error counter register */
> +#define ERR_COUNTER_TEC_MASK	0xff
> +#define ERR_COUNTER_TEC_SHIFT	0x0
> +#define ERR_COUNTER_REC_SHIFT	8
> +#define ERR_COUNTER_REC_MASK	(0x7f << ERR_COUNTER_REC_SHIFT)
> +#define ERR_COUNTER_RP_SHIFT	15
> +#define ERR_COUNTER_RP_MASK	(0x1 << ERR_COUNTER_RP_SHIFT)
> +
> +/* bit-timing register */
> +#define BTR_BRP_MASK		0x3f
> +#define BTR_BRP_SHIFT		0
> +#define BTR_SJW_SHIFT		6
> +#define BTR_SJW_MASK		(0x3 << BTR_SJW_SHIFT)
> +#define BTR_TSEG1_SHIFT		8
> +#define BTR_TSEG1_MASK		(0xf << BTR_TSEG1_SHIFT)
> +#define BTR_TSEG2_SHIFT		12
> +#define BTR_TSEG2_MASK		(0x7 << BTR_TSEG2_SHIFT)
> +
> +/* brp extension register */
> +#define BRP_EXT_BRPE_MASK	0x0f
> +#define BRP_EXT_BRPE_SHIFT	0
> +
> +/* IFx command request */
> +#define IF_COMR_BUSY		(1 << 15)
> +
> +/* IFx command mask */
> +#define IF_COMM_WR		(1 << 7)
> +#define IF_COMM_MASK		(1 << 6)
> +#define IF_COMM_ARB		(1 << 5)
> +#define IF_COMM_CONTROL		(1 << 4)
> +#define IF_COMM_CLR_INT_PND	(1 << 3)
> +#define IF_COMM_TXRQST		(1 << 2)
> +#define IF_COMM_DATAA		(1 << 1)
> +#define IF_COMM_DATAB		(1 << 0)
> +#define IF_COMM_ALL		(IF_COMM_MASK | IF_COMM_ARB | \
> +				IF_COMM_CONTROL | IF_COMM_TXRQST | \
> +				IF_COMM_DATAA | IF_COMM_DATAB)
> +
> +/* IFx arbitration */
> +#define IF_ARB_MSGVAL		(1 << 15)
> +#define IF_ARB_MSGXTD		(1 << 14)
> +#define IF_ARB_TRANSMIT		(1 << 13)
> +
> +/* IFx message control */
> +#define IF_MCONT_NEWDAT		(1 << 15)
> +#define IF_MCONT_MSGLST		(1 << 14)
> +#define IF_MCONT_INTPND		(1 << 13)
> +#define IF_MCONT_UMASK		(1 << 12)
> +#define IF_MCONT_TXIE		(1 << 11)
> +#define IF_MCONT_RXIE		(1 << 10)
> +#define IF_MCONT_RMTEN		(1 << 9)
> +#define IF_MCONT_TXRQST		(1 << 8)
> +#define IF_MCONT_EOB		(1 << 7)
> +
> +/*
> + * IFx register masks:
> + * allow easy operation on 16-bit registers when the
> + * argument is 32-bit instead
> + */
> +#define IFX_WRITE_LOW_16BIT(x)	(x & 0xFFFF)
> +#define IFX_WRITE_HIGH_16BIT(x)	((x & 0xFFFF0000) >> 16)
> +
> +/* message object split */
> +#define C_CAN_NO_OF_OBJECTS	31
> +#define C_CAN_MSG_OBJ_RX_NUM	16
> +#define C_CAN_MSG_OBJ_TX_NUM	16
> +
> +#define C_CAN_MSG_OBJ_RX_FIRST	0
> +#define C_CAN_MSG_OBJ_RX_LAST	(C_CAN_MSG_OBJ_RX_FIRST + \
> +				C_CAN_MSG_OBJ_RX_NUM - 1)
> +
> +#define C_CAN_MSG_OBJ_TX_FIRST	(C_CAN_MSG_OBJ_RX_LAST + 1)
> +#define C_CAN_MSG_OBJ_TX_LAST	(C_CAN_MSG_OBJ_TX_FIRST + \
> +				C_CAN_MSG_OBJ_TX_NUM - 1)
> +#define C_CAN_NEXT_MSG_OBJ_MASK	(C_CAN_MSG_OBJ_TX_NUM - 1)
> +#define RECEIVE_OBJECT_BITS	0x0000ffff
> +
> +/* status interrupt */
> +#define STATUS_INTERRUPT	0x8000
> +
> +/* napi related */
> +#define C_CAN_NAPI_WEIGHT	C_CAN_MSG_OBJ_RX_NUM
> +
> +/* c_can IF registers */
> +struct c_can_if_regs {
> +	u16 com_reg;
> +	u16 com_mask;
> +	u16 mask1;
> +	u16 mask2;
> +	u16 arb1;
> +	u16 arb2;
> +	u16 msg_cntrl;
> +	u16 data_a1;
> +	u16 data_a2;
> +	u16 data_b1;
> +	u16 data_b2;
> +	u16 _reserved[13];
> +};
> +
> +/* c_can hardware registers */
> +struct c_can_regs {
> +	u16 control;
> +	u16 status;
> +	u16 error_counter;
> +	u16 btr;
> +	u16 ir;
> +	u16 test;
> +	u16 brp_ext;
> +	u16 _reserved1;
> +	struct c_can_if_regs ifreg[2]; /* [0] = IF1 and [1] = IF2 */
> +	u16 _reserved2[8];
> +	u16 txrqst1;
> +	u16 txrqst2;
> +	u16 _reserved3[6];
> +	u16 newdat1;
> +	u16 newdat2;
> +	u16 _reserved4[6];
> +	u16 intpnd1;
> +	u16 intpnd2;
> +	u16 _reserved5[6];
> +	u16 msgval1;
> +	u16 msgval2;
> +	u16 _reserved6[6];
> +};

Ah, oh, I just realized that the register layout is almost identical to
the recently accepted *pch_can* driver. Tomoya, does pch_can use a c_can
core? Well, then it makes really sense to have a generic c_can driver
for the SPEAR, PCH, etc. Board specific details are handled via platform
definition. This driver already provides that functionality, IFAICS.

Wolfgang.
