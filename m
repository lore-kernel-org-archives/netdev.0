From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Fri, 17 Dec 2010 22:45:59 +0100
Message-ID: <4D0BDA17.7010009@grandegger.com>
References: <1292407130-19791-1-git-send-email-bhupesh.sharma@st.com>
	<4D0BD744.5030609@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D0BD744.5030609-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

On 12/17/2010 10:33 PM, Marc Kleine-Budde wrote:
> On 12/15/2010 10:58 AM, Bhupesh Sharma wrote:
>> Bosch C_CAN controller is a full-CAN implementation which is compliant
>> to CAN protocol version 2.0 part A and B. Bosch C_CAN user manual can be
>> obtained from:
>> http://www.semiconductors.bosch.de/pdf/Users_Manual_C_CAN.pdf
> =

> No time to do a real review, some comments and lots of nitpicking inline.=
...
> =

> regards, Marc
> =

>>
>> This patch adds the support for this controller.
>> The following are the design choices made while writing the controller d=
river:
>> 1. Interface Register set IF1 has be used only in the current design.
>> 2. Out of the 32 Message objects available, 16 are kept aside for RX pur=
poses
>>    and the rest for TX purposes.
>> 3. NAPI implementation is such that both the TX and RX paths function in
>>    polling mode.
>>
>> Changes since V1:
>> 1. Implemented C_CAN as a platform driver with means of providing the
>>    platform details and register offsets which may vary for different So=
Cs
>>    through platform data struct.
>> 2. Implemented NAPI.
>> 3. Removed memcpy calls globally.
>> 4. Implemented CAN_CTRLMODE_*
>> 5. Implemented and used priv->can.do_get_berr_counter.
>> 6. Implemented c_can registers as a struct instead of enum.
>> 7. Improved the TX path by implementing routines to get next Tx and echo=
 msg
>>    objects.
>>
>> Signed-off-by: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
>> ---
>>  drivers/net/can/Kconfig  |    7 +
>>  drivers/net/can/Makefile |    1 +
>>  drivers/net/can/c_can.c  | 1217 +++++++++++++++++++++++++++++++++++++++=
+++++++
>>  3 files changed, 1225 insertions(+), 0 deletions(-)
>>  create mode 100644 drivers/net/can/c_can.c
>>
>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
>> index 9d9e453..25d9d2e 100644
>> --- a/drivers/net/can/Kconfig
>> +++ b/drivers/net/can/Kconfig
>> @@ -41,6 +41,13 @@ config CAN_AT91
>>  	---help---
>>  	  This is a driver for the SoC CAN controller in Atmel's AT91SAM9263.
>>  =

>> +config CAN_C_CAN
>> +	tristate "Bosch C_CAN controller"
>> +	depends on CAN_DEV
>> +	---help---
>> +	  If you say yes to this option, support will be included for the
>> +	  Bosch C_CAN controller.
>> +
>>  config CAN_TI_HECC
>>  	depends on CAN_DEV && ARCH_OMAP3
>>  	tristate "TI High End CAN Controller"
>> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
>> index 0057537..b6cbe74 100644
>> --- a/drivers/net/can/Makefile
>> +++ b/drivers/net/can/Makefile
>> @@ -12,6 +12,7 @@ obj-y				+=3D usb/
>>  obj-$(CONFIG_CAN_SJA1000)	+=3D sja1000/
>>  obj-$(CONFIG_CAN_MSCAN)		+=3D mscan/
>>  obj-$(CONFIG_CAN_AT91)		+=3D at91_can.o
>> +obj-$(CONFIG_CAN_C_CAN)		+=3D c_can.o
>>  obj-$(CONFIG_CAN_TI_HECC)	+=3D ti_hecc.o
>>  obj-$(CONFIG_CAN_MCP251X)	+=3D mcp251x.o
>>  obj-$(CONFIG_CAN_BFIN)		+=3D bfin_can.o
>> diff --git a/drivers/net/can/c_can.c b/drivers/net/can/c_can.c
>> new file mode 100644
>> index 0000000..c281c17
>> --- /dev/null
>> +++ b/drivers/net/can/c_can.c
>> @@ -0,0 +1,1217 @@
>> +/*
>> + * CAN bus driver for Bosch C_CAN controller
>> + *
>> + * Copyright (C) 2010 ST Microelectronics
>> + * Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
>> + *
>> + * Borrowed heavily from the C_CAN driver originally written by:
>> + * Copyright (C) 2007
>> + * - Sascha Hauer, Marc Kleine-Budde, Pengutronix <s.hauer@pengutronix.=
de>
>> + * - Simon Kallweit, intefo AG <simon.kallweit-+G9qxTFKJT/tRgLqZ5aouw@public.gmane.org>
>> + *
> =

> I recognize some stuff from the at91_can driver, too :)
> =

>> + * Bosch C_CAN controller is compliant to CAN protocol version 2.0 part=
 A and B.
>> + * Bosch C_CAN user manual can be obtained from:
>> + * http://www.semiconductors.bosch.de/pdf/Users_Manual_C_CAN.pdf
>> + *
>> + * This file is licensed under the terms of the GNU General Public
>> + * License version 2. This program is licensed "as is" without any
>> + * warranty of any kind, whether express or implied.
>> + */
>> +
>> +#include <linux/kernel.h>
>> +#include <linux/version.h>
>> +#include <linux/module.h>
>> +#include <linux/interrupt.h>
>> +#include <linux/delay.h>
>> +#include <linux/netdevice.h>
>> +#include <linux/if_arp.h>
>> +#include <linux/if_ether.h>
>> +#include <linux/list.h>
>> +#include <linux/delay.h>
>> +#include <linux/workqueue.h>
>> +#include <linux/io.h>
>> +#include <linux/platform_device.h>
>> +#include <linux/clk.h>
>> +
>> +#include <linux/can.h>
>> +#include <linux/can/dev.h>
>> +#include <linux/can/error.h>
>> +
>> +#define DRV_NAME "c_can"
> =

> You can use KBUILD_MODNAME, no need to define DRV_NAME.
> =

>> +
>> +/* control register */
>> +#define CONTROL_TEST		(1 << 7)
>> +#define CONTROL_CCE		(1 << 6)
>> +#define CONTROL_DISABLE_AR	(1 << 5)
>> +#define CONTROL_ENABLE_AR	(0 << 5)
>> +#define CONTROL_EIE		(1 << 3)
>> +#define CONTROL_SIE		(1 << 2)
>> +#define CONTROL_IE		(1 << 1)
>> +#define CONTROL_INIT		(1 << 0)
>> +
>> +/* test register */
>> +#define TEST_RX			(1 << 7)
>> +#define TEST_TX1		(1 << 6)
>> +#define TEST_TX2		(1 << 5)
>> +#define TEST_LBACK		(1 << 4)
>> +#define TEST_SILENT		(1 << 3)
>> +#define TEST_BASIC		(1 << 2)
> =

> You can use BIT(n) instead of (1 << n).
> =

>> +
>> +/* status register */
>> +#define STATUS_BOFF		(1 << 7)
>> +#define STATUS_EWARN		(1 << 6)
>> +#define STATUS_EPASS		(1 << 5)
>> +#define STATUS_RXOK		(1 << 4)
>> +#define STATUS_TXOK		(1 << 3)
>> +#define STATUS_LEC_MASK		0x07
>> +#define LEC_STUFF_ERROR		1
>> +#define LEC_FORM_ERROR		2
>> +#define LEC_ACK_ERROR		3
>> +#define LEC_BIT1_ERROR		4
>> +#define LEC_BIT0_ERROR		5
>> +#define LEC_CRC_ERROR		6
>> +
>> +/* error counter register */
>> +#define ERR_COUNTER_TEC_MASK	0xff
>> +#define ERR_COUNTER_TEC_SHIFT	0x0
> =

> nitpick, I'd just use a pure decimal 0 :)
> =

>> +#define ERR_COUNTER_REC_SHIFT	8
>> +#define ERR_COUNTER_REC_MASK	(0x7f << ERR_COUNTER_REC_SHIFT)
>> +#define ERR_COUNTER_RP_SHIFT	15
>> +#define ERR_COUNTER_RP_MASK	(0x1 << ERR_COUNTER_RP_SHIFT)
>> +
>> +/* bit-timing register */
>> +#define BTR_BRP_MASK		0x3f
>> +#define BTR_BRP_SHIFT		0
>> +#define BTR_SJW_SHIFT		6
>> +#define BTR_SJW_MASK		(0x3 << BTR_SJW_SHIFT)
>> +#define BTR_TSEG1_SHIFT		8
>> +#define BTR_TSEG1_MASK		(0xf << BTR_TSEG1_SHIFT)
>> +#define BTR_TSEG2_SHIFT		12
>> +#define BTR_TSEG2_MASK		(0x7 << BTR_TSEG2_SHIFT)
>> +
>> +/* brp extension register */
>> +#define BRP_EXT_BRPE_MASK	0x0f
>> +#define BRP_EXT_BRPE_SHIFT	0
>> +
>> +/* IFx command request */
>> +#define IF_COMR_BUSY		(1 << 15)
>> +
>> +/* IFx command mask */
>> +#define IF_COMM_WR		(1 << 7)
>> +#define IF_COMM_MASK		(1 << 6)
>> +#define IF_COMM_ARB		(1 << 5)
>> +#define IF_COMM_CONTROL		(1 << 4)
>> +#define IF_COMM_CLR_INT_PND	(1 << 3)
>> +#define IF_COMM_TXRQST		(1 << 2)
>> +#define IF_COMM_DATAA		(1 << 1)
>> +#define IF_COMM_DATAB		(1 << 0)
>> +#define IF_COMM_ALL		(IF_COMM_MASK | IF_COMM_ARB | \
>> +				IF_COMM_CONTROL | IF_COMM_TXRQST | \
>> +				IF_COMM_DATAA | IF_COMM_DATAB)
>> +
>> +/* IFx arbitration */
>> +#define IF_ARB_MSGVAL		(1 << 15)
>> +#define IF_ARB_MSGXTD		(1 << 14)
>> +#define IF_ARB_TRANSMIT		(1 << 13)
>> +
>> +/* IFx message control */
>> +#define IF_MCONT_NEWDAT		(1 << 15)
>> +#define IF_MCONT_MSGLST		(1 << 14)
>> +#define IF_MCONT_INTPND		(1 << 13)
>> +#define IF_MCONT_UMASK		(1 << 12)
>> +#define IF_MCONT_TXIE		(1 << 11)
>> +#define IF_MCONT_RXIE		(1 << 10)
>> +#define IF_MCONT_RMTEN		(1 << 9)
>> +#define IF_MCONT_TXRQST		(1 << 8)
>> +#define IF_MCONT_EOB		(1 << 7)
>> +
>> +/*
>> + * IFx register masks:
>> + * allow easy operation on 16-bit registers when the
>> + * argument is 32-bit instead
>> + */
>> +#define IFX_WRITE_LOW_16BIT(x)	(x & 0xFFFF)
>> +#define IFX_WRITE_HIGH_16BIT(x)	((x & 0xFFFF0000) >> 16)
>> +
>> +/* message object split */
>> +#define C_CAN_NO_OF_OBJECTS	31
>> +#define C_CAN_MSG_OBJ_RX_NUM	16
>> +#define C_CAN_MSG_OBJ_TX_NUM	16
>> +
>> +#define C_CAN_MSG_OBJ_RX_FIRST	0
>> +#define C_CAN_MSG_OBJ_RX_LAST	(C_CAN_MSG_OBJ_RX_FIRST + \
>> +				C_CAN_MSG_OBJ_RX_NUM - 1)
>> +
>> +#define C_CAN_MSG_OBJ_TX_FIRST	(C_CAN_MSG_OBJ_RX_LAST + 1)
>> +#define C_CAN_MSG_OBJ_TX_LAST	(C_CAN_MSG_OBJ_TX_FIRST + \
>> +				C_CAN_MSG_OBJ_TX_NUM - 1)
>> +#define C_CAN_NEXT_MSG_OBJ_MASK	(C_CAN_MSG_OBJ_TX_NUM - 1)
>> +#define RECEIVE_OBJECT_BITS	0x0000ffff
>> +
>> +/* status interrupt */
>> +#define STATUS_INTERRUPT	0x8000
>> +
>> +/* napi related */
>> +#define C_CAN_NAPI_WEIGHT	C_CAN_MSG_OBJ_RX_NUM
>> +
>> +/* c_can IF registers */
>> +struct c_can_if_regs {
>> +	u16 com_reg;
>> +	u16 com_mask;
>> +	u16 mask1;
>> +	u16 mask2;
>> +	u16 arb1;
>> +	u16 arb2;
>> +	u16 msg_cntrl;
>> +	u16 data_a1;
>> +	u16 data_a2;
>> +	u16 data_b1;
>> +	u16 data_b2;
> =

> The later code _mighy_ be easier to read if you define data as an array
> of u16, but let's see...
> =

>> +	u16 _reserved[13];
>> +};
>> +
>> +/* c_can hardware registers */
>> +struct c_can_regs {
>> +	u16 control;
>> +	u16 status;
>> +	u16 error_counter;
>> +	u16 btr;
>> +	u16 ir;
>> +	u16 test;
>> +	u16 brp_ext;
>> +	u16 _reserved1;
>> +	struct c_can_if_regs ifreg[2]; /* [0] =3D IF1 and [1] =3D IF2 */
>> +	u16 _reserved2[8];
>> +	u16 txrqst1;
>> +	u16 txrqst2;
>> +	u16 _reserved3[6];
>> +	u16 newdat1;
>> +	u16 newdat2;
>> +	u16 _reserved4[6];
>> +	u16 intpnd1;
>> +	u16 intpnd2;
>> +	u16 _reserved5[6];
>> +	u16 msgval1;
>> +	u16 msgval2;
>> +	u16 _reserved6[6];
>> +};
>> +
>> +/*
>> + * c_can error types:
>> + * Bus errors (BUS_OFF, ERROR_WARNING, ERROR_PASSIVE) are supported
>> + */
>> +enum c_can_bus_error_types {
>> +	C_CAN_NO_ERROR =3D 0,
>> +	C_CAN_BUS_OFF,
>> +	C_CAN_ERROR_WARNING,
>> +	C_CAN_ERROR_PASSIVE
>                            ^
> please add a ","
>> +};
>> +
>> +enum c_can_interrupt_mode {
>> +	ENABLE_MODULE_INTERRUPT =3D 0,
>> +	DISABLE_MODULE_INTERRUPT,
>> +	ENABLE_ALL_INTERRUPTS,
>> +	DISABLE_ALL_INTERRUPTS
> same here
>> +};
>> +
>> +/* c_can private data structure */
>> +struct c_can_priv {
>> +	struct can_priv can;	/* must be the first member */
>> +	struct napi_struct napi;
>> +	struct net_device *dev;
>> +	int tx_object;
>> +	int current_status;
>> +	int last_status;
>> +	u16 (*read_reg) (struct c_can_priv *priv, void *reg);
>> +	void (*write_reg) (struct c_can_priv *priv, void *reg, u16 val);
>> +	struct c_can_regs __iomem *reg_base;
>> +	unsigned long irq_flags; /* for request_irq() */
>> +	unsigned int tx_next;
>> +	unsigned int tx_echo;
>> +	struct clk *clk;
>> +};
>> +
>> +static struct can_bittiming_const c_can_bittiming_const =3D {
>> +	.name =3D DRV_NAME,
> =

> use KBUILD_MODNAME here
>> +	.tseg1_min =3D 2,		/* Time segment 1 =3D prop_seg + phase_seg1 */
>> +	.tseg1_max =3D 16,
>> +	.tseg2_min =3D 1,		/* Time segment 2 =3D phase_seg2 */
>> +	.tseg2_max =3D 8,
>> +	.sjw_max =3D 4,
>> +	.brp_min =3D 1,
>> +	.brp_max =3D 1024,	/* 6-bit BRP field + 4-bit BRPE field*/
>> +	.brp_inc =3D 1,
>> +};
>> +
>> +static inline int get_tx_next_msg_obj(const struct c_can_priv *priv)
>> +{
>> +	return (priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) +
>> +			C_CAN_MSG_OBJ_TX_FIRST;
>> +}
>> +
>> +static inline int get_tx_echo_msg_obj(const struct c_can_priv *priv)
>> +{
>> +	return (priv->tx_echo & C_CAN_NEXT_MSG_OBJ_MASK) +
>> +			C_CAN_MSG_OBJ_TX_FIRST;
>> +}
>> +
>> +/* 16-bit c_can registers can be arranged differently in the memory
>> + * architecture of different implementations. For example: 16-bit
>> + * registers can be aligned to a 16-bit boundary or 32-bit boundary etc.
>> + * Handle the same by providing a common read/write interface.
>> + */
> =

> /*
>  * this is the preferred multi-line comment style,
>  * please adjust
>  */
>> +static u16 c_can_read_reg_aligned_to_16bit(void *reg)
>> +{
>> +	return readw(reg);
>> +}
>> +
>> +static void c_can_write_reg_aligned_to_16bit(void *reg, u16 val)
>> +{
>> +	writew(val, reg);
>> +}
>> +
>> +static u16 c_can_read_reg_aligned_to_32bit(struct c_can_priv *priv, voi=
d *reg)
>> +{
>> +	return readw(reg + (u32)reg - (u32)priv->reg_base);
> =

> as Wolfgang said not 64 bit safe.....what about casting the reg_base to
> void __iomem *?

You will get.

error: invalid operands to binary + (have =91void *=92 and =91void *=92)

>> +}
>> +
>> +static void c_can_write_reg_aligned_to_32bit(struct c_can_priv *priv,
>> +					void *reg, u16 val)
>> +{
>> +	writew(val, reg + (u32)reg - (u32)priv->reg_base);
>> +}
>> +
>> +static u32 c_can_read_reg32(struct c_can_priv *priv, void *reg)
>> +{
>> +	u32 val =3D priv->read_reg(priv, reg);
>> +	val |=3D ((u32) priv->read_reg(priv, reg + 2)) << 16;
>> +	return val;
>> +}
>> +
>> +static inline int c_can_configure_interrupts(struct c_can_priv *priv,
>> +					enum c_can_interrupt_mode intr_mode)
>> +{
>> +	unsigned int cntrl_save =3D priv->read_reg(priv,
>> +						&priv->reg_base->control);
>> +
>> +	switch (intr_mode) {
>> +	case ENABLE_MODULE_INTERRUPT:
>> +		cntrl_save |=3D CONTROL_IE;
>> +		break;
>> +	case DISABLE_MODULE_INTERRUPT:
>> +		cntrl_save &=3D ~CONTROL_IE;
>> +		break;
>> +	case ENABLE_ALL_INTERRUPTS:
>> +		cntrl_save |=3D (CONTROL_SIE | CONTROL_EIE | CONTROL_IE);
>> +		break;
>> +	case DISABLE_ALL_INTERRUPTS:
>> +		cntrl_save &=3D ~(CONTROL_EIE | CONTROL_IE | CONTROL_SIE);
>> +		break;
>> +	default:
>> +		return -EOPNOTSUPP;
>> +	}
>> +
>> +	priv->write_reg(priv, &priv->reg_base->control, cntrl_save);
>> +
>> +	return 0;
>> +}
>> +
>> +static inline int c_can_object_get(struct net_device *dev,
>> +					int iface, int objno, int mask)
>> +{
>> +	struct c_can_priv *priv =3D netdev_priv(dev);
>> +	int timeout =3D (6 / priv->can.clock.freq);
>> +
>> +	priv->write_reg(priv, &priv->reg_base->ifreg[iface].com_mask,
>> +			IFX_WRITE_LOW_16BIT(mask));
>> +	priv->write_reg(priv, &priv->reg_base->ifreg[iface].com_reg,
>> +			IFX_WRITE_LOW_16BIT(objno + 1));
>> +
>> +	/* as per specs, after writting the message object number in the
>> +	 * IF command request register the transfer b/w interface
>> +	 * register and message RAM must be complete in 6 CAN-CLK
>> +	 * period. The delay accounts for the same
>> +	 */
>> +	udelay(timeout);
>> +	if ((priv->read_reg(priv, &priv->reg_base->ifreg[iface].com_reg)) &
>> +			IF_COMR_BUSY) {
>> +		dev_info(dev->dev.parent, "timed out in object get\n");
>> +		return -ETIMEDOUT;
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>> +static inline int c_can_object_put(struct net_device *dev,
>> +					int iface, int objno, int mask)
>> +{
>> +	struct c_can_priv *priv =3D netdev_priv(dev);
>> +	int timeout =3D (6 / priv->can.clock.freq);
>> +
>> +	priv->write_reg(priv, &priv->reg_base->ifreg[iface].com_mask,
>> +			(IF_COMM_WR | IFX_WRITE_LOW_16BIT(mask)));
>> +	priv->write_reg(priv, &priv->reg_base->ifreg[iface].com_reg,
>> +			IFX_WRITE_LOW_16BIT(objno + 1));
>> +
>> +	/* as per specs, after writting the message object number in the
>> +	 * IF command request register the transfer b/w interface
>> +	 * register and message RAM must be complete in 6 CAN-CLK
>> +	 * period. The delay accounts for the same
>> +	 */
>> +	udelay(timeout);
>> +	if ((priv->read_reg(priv, &priv->reg_base->ifreg[iface].com_reg)) &
>> +			IF_COMR_BUSY) {
>> +		dev_info(dev->dev.parent, "timed out in object put\n");
>> +		return -ETIMEDOUT;
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>> +int c_can_write_msg_object(struct net_device *dev,
>> +			int iface, struct can_frame *frame, int objno)
>> +{
>> +	u16 flags =3D 0;
>> +	unsigned int id;
>> +	struct c_can_priv *priv =3D netdev_priv(dev);
>> +
>> +	if (frame->can_id & CAN_EFF_FLAG) {
>> +		id =3D frame->can_id & CAN_EFF_MASK;
>> +		flags |=3D IF_ARB_MSGXTD;
>> +	} else
>> +		id =3D ((frame->can_id & CAN_SFF_MASK) << 18);
>> +
>> +	if (!(frame->can_id & CAN_RTR_FLAG))
>> +		flags |=3D IF_ARB_TRANSMIT;
>> +
>> +	flags |=3D IF_ARB_MSGVAL;
>> +
>> +	priv->write_reg(priv, &priv->reg_base->ifreg[iface].arb1,
>> +				IFX_WRITE_LOW_16BIT(id));
>> +	priv->write_reg(priv, &priv->reg_base->ifreg[iface].arb2, flags |
>> +				IFX_WRITE_HIGH_16BIT(id));
>> +
>> +	priv->write_reg(priv, &priv->reg_base->ifreg[iface].data_a1,
>> +			(*(u16 *)(frame->data)));
>> +	priv->write_reg(priv, &priv->reg_base->ifreg[iface].data_a2,
>> +			(*(u32 *)(frame->data)) >> 16);
>> +
>> +	if (frame->can_dlc > 4) {
>> +		priv->write_reg(priv, &priv->reg_base->ifreg[iface].data_b1,
>> +			(*(u16 *)(frame->data + 4)));
>> +		priv->write_reg(priv, &priv->reg_base->ifreg[iface].data_b2,
>> +			(*(u32 *)(frame->data + 4)) >> 16);
>> +	} else
>> +		*(u32 *)(frame->data + 4) =3D 0;
> =

> look at the pch can driver, it uses an array for ifreg->data and is
> endianess safe.

Marc, you did review the pch_can driver. Do you think as well that the
CAN core used for the PCH is C_CAN?

Wolfgang.
