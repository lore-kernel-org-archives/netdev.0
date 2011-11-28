From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [Socketcan-users] [PATCH net-next v2 1/4] can: cc770: add driver
 core for the Bosch CC770 and Intel AN82527
Date: Mon, 28 Nov 2011 12:28:13 +0100
Message-ID: <4ED3704D.5020903@pengutronix.de>
References: <1322214204-1121-1-git-send-email-wg@grandegger.com> <1322214204-1121-2-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB5CF2C263C6237604E67C44A"
Cc: netdev@vger.kernel.org, socketcan-users@lists.berlios.de,
	linux-can@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1322214204-1121-2-git-send-email-wg@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB5CF2C263C6237604E67C44A
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/25/2011 10:43 AM, Wolfgang Grandegger wrote:
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
> ---
>  drivers/net/can/Kconfig            |    2 +
>  drivers/net/can/Makefile           |    1 +
>  drivers/net/can/cc770/Kconfig      |    3 +
>  drivers/net/can/cc770/Makefile     |    7 +
>  drivers/net/can/cc770/cc770.c      |  895 ++++++++++++++++++++++++++++=
++++++++
>  drivers/net/can/cc770/cc770.h      |  234 ++++++++++
>  include/linux/can/platform/cc770.h |   33 ++
>  7 files changed, 1175 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/cc770/Kconfig
>  create mode 100644 drivers/net/can/cc770/Makefile
>  create mode 100644 drivers/net/can/cc770/cc770.c
>  create mode 100644 drivers/net/can/cc770/cc770.h
>  create mode 100644 include/linux/can/platform/cc770.h

I don't know the hardware, but the code looks good to me, some comments:
- The driver doesn't use NAPI, can this be added
- The rx-handlers have a while(1) loop
  For NAPI you have to add accounting, for the non NAPI case it would
  be good, too.
- I think you can move a large number of lines from the .h file into
  the driver. Code that's not used in the different binding drivers.

More comments inline (mostly nitpicking)

Marc
>=20
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index f6c98fb..ab45758 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -116,6 +116,8 @@ source "drivers/net/can/sja1000/Kconfig"
> =20
>  source "drivers/net/can/c_can/Kconfig"
> =20
> +source "drivers/net/can/cc770/Kconfig"
> +
>  source "drivers/net/can/usb/Kconfig"
> =20
>  source "drivers/net/can/softing/Kconfig"
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 24ebfe8..938be37 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -14,6 +14,7 @@ obj-y				+=3D softing/
>  obj-$(CONFIG_CAN_SJA1000)	+=3D sja1000/
>  obj-$(CONFIG_CAN_MSCAN)		+=3D mscan/
>  obj-$(CONFIG_CAN_C_CAN)		+=3D c_can/
> +obj-$(CONFIG_CAN_CC770)		+=3D cc770/
>  obj-$(CONFIG_CAN_AT91)		+=3D at91_can.o
>  obj-$(CONFIG_CAN_TI_HECC)	+=3D ti_hecc.o
>  obj-$(CONFIG_CAN_MCP251X)	+=3D mcp251x.o
> diff --git a/drivers/net/can/cc770/Kconfig b/drivers/net/can/cc770/Kcon=
fig
> new file mode 100644
> index 0000000..225131b
> --- /dev/null
> +++ b/drivers/net/can/cc770/Kconfig
> @@ -0,0 +1,3 @@
> +menuconfig CAN_CC770
> +	tristate "Bosch CC770 and Intel AN82527 devices"
> +	depends on CAN_DEV && HAS_IOMEM
> diff --git a/drivers/net/can/cc770/Makefile b/drivers/net/can/cc770/Mak=
efile
> new file mode 100644
> index 0000000..34e8180
> --- /dev/null
> +++ b/drivers/net/can/cc770/Makefile
> @@ -0,0 +1,7 @@
> +#
> +#  Makefile for the Bosch CC770 CAN controller drivers.
> +#
> +
> +obj-$(CONFIG_CAN_CC770) +=3D cc770.o
> +
> +ccflags-$(CONFIG_CAN_DEBUG_DEVICES) :=3D -DDEBUG
> diff --git a/drivers/net/can/cc770/cc770.c b/drivers/net/can/cc770/cc77=
0.c
> new file mode 100644
> index 0000000..47a6965
> --- /dev/null
> +++ b/drivers/net/can/cc770/cc770.c
> @@ -0,0 +1,895 @@
> +/*
> + * cc770.c - Bosch CC770 and Intel AN82527 network device driver
> + *
> + * Copyright (C) 2009, 2011 Wolfgang Grandegger <wg@grandegger.com>
> + *
> + * Derived from the old Socket-CAN i82527 driver:
> + *
> + * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
> + * All rights reserved.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions
> + * are met:
> + * 1. Redistributions of source code must retain the above copyright
> + *    notice, this list of conditions and the following disclaimer.
> + * 2. Redistributions in binary form must reproduce the above copyrigh=
t
> + *    notice, this list of conditions and the following disclaimer in =
the
> + *    documentation and/or other materials provided with the distribut=
ion.
> + * 3. Neither the name of Volkswagen nor the names of its contributors=

> + *    may be used to endorse or promote products derived from this sof=
tware
> + *    without specific prior written permission.
> + *
> + * Alternatively, provided that this notice is retained in full, this
> + * software may be distributed under the terms of the GNU General
> + * Public License ("GPL") version 2, in which case the provisions of t=
he
> + * GPL apply INSTEAD OF those given above.
> + *
> + * The provided data structures and external interfaces from this code=

> + * are not restricted to be used by modules with a GPL compatible lice=
nse.
> + *
> + * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS=

> + * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
> + * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS F=
OR
> + * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGH=
T
> + * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTA=
L,
> + * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
> + * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF US=
E,
> + * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON A=
NY
> + * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT=

> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE U=
SE
> + * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
> + * DAMAGE.
> + *
> + * Send feedback to <socketcan-users@lists.berlios.de>

please remove :)

> + */
> +
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/kernel.h>
> +#include <linux/sched.h>
> +#include <linux/types.h>
> +#include <linux/fcntl.h>
> +#include <linux/interrupt.h>
> +#include <linux/ptrace.h>
> +#include <linux/string.h>
> +#include <linux/errno.h>
> +#include <linux/netdevice.h>
> +#include <linux/if_arp.h>
> +#include <linux/if_ether.h>
> +#include <linux/skbuff.h>
> +#include <linux/delay.h>
> +
> +#include <linux/can.h>
> +#include <linux/can/dev.h>
> +#include <linux/can/error.h>
> +#include <linux/can/dev.h>
> +#include <linux/can/platform/cc770.h>
> +
> +#include "cc770.h"

Can you move all the definitions that are not needed in the other
drivers (e.g. ISA, etc.) into this .c file?

> +
> +#define DRV_NAME  "cc770"
> +
> +MODULE_AUTHOR("Wolfgang Grandegger <wg@grandegger.com>");
> +MODULE_LICENSE("GPL v2");
> +MODULE_DESCRIPTION(DRV_NAME "CAN netdevice driver");
> +
> +/*
> + * The CC770 is a CAN controller from Bosch, which is 100% compatible
> + * with the AN82527 from Intel, but with "bugs" being fixed and some
> + * additional functionality, mainly:
> + *
> + * 1. RX and TX error counters are readable.
> + * 2. Support of silent (listen-only) mode.
> + * 3. Message object 15 can receive all types of frames, also RTR and =
EFF.
> + *
> + * Details are available from Bosch's "CC770_Product_Info_2007-01.pdf"=
,
> + * which explains in detail the compatibility between the CC770 and th=
e
> + * 82527. This driver use the additional functionality 3. on real CC77=
0
> + * devices. Unfortunately, the CC770 does still not store the message
> + * identifier of received remote transmission request frames and
> + * therefore it's set to 0.
> + *
> + * The message objects 1..14 can be used for TX and RX while the messa=
ge
> + * objects 15 is optimized for RX. It has a shadow register for reliab=
le
> + * data receiption under heavy bus load. Therefore it makes sense to u=
se
> + * this message object for the needed use case. The frame type (EFF/SF=
F)
> + * for the message object 15 can be defined via kernel module paramete=
r
> + * "msgobj15_eff". If not equal 0, it will receive 29-bit EFF frames,
> + * otherwise 11 bit SFF messages.
> + */
> +static int msgobj15_eff;
> +module_param(msgobj15_eff, int, S_IRUGO);
> +MODULE_PARM_DESC(msgobj15_eff, "Extended 29-bit frames for message obj=
ect 15 "
> +		 "(default: 11-bit standard frames)");
> +
> +static int i82527_compat;
> +module_param(i82527_compat, int, S_IRUGO);
> +MODULE_PARM_DESC(i82527_compat, "Strict Intel 82527 comptibility mode =
"
> +		 "without using additional functions");
> +
> +/*
> + * This driver uses the last 5 message objects 11..15. The definitions=

> + * and structure below allows to configure and assign them to the real=

> + * message object.
> + */
> +static unsigned char cc770_obj_flags[CC770_OBJ_MAX] =3D {
> +	[CC770_OBJ_RX0] =3D CC770_OBJ_FLAG_RX,
> +	[CC770_OBJ_RX1] =3D CC770_OBJ_FLAG_RX | CC770_OBJ_FLAG_EFF,
> +	[CC770_OBJ_RX_RTR0] =3D CC770_OBJ_FLAG_RX | CC770_OBJ_FLAG_RTR,
> +	[CC770_OBJ_RX_RTR1] =3D CC770_OBJ_FLAG_RX | CC770_OBJ_FLAG_RTR |
> +			      CC770_OBJ_FLAG_EFF,
> +	[CC770_OBJ_TX] =3D 0,
> +};

Is is worth the trouble making this a per device instance option? In a
OF-Tree world should this become an "attribute" (or what's the correct
of-tree word for it?)

> +
> +static struct can_bittiming_const cc770_bittiming_const =3D {
> +	.name =3D DRV_NAME,
> +	.tseg1_min =3D 1,
> +	.tseg1_max =3D 16,
> +	.tseg2_min =3D 1,
> +	.tseg2_max =3D 8,
> +	.sjw_max =3D 4,
> +	.brp_min =3D 1,
> +	.brp_max =3D 64,
> +	.brp_inc =3D 1,
> +};
> +
> +static inline int intid2obj(unsigned int intid)
> +{
> +	if (intid =3D=3D 2)
> +		return 0;
> +	else
> +		return MSGOBJ_LAST + 2 - intid;
> +}
> +
> +static void enable_all_objs(const struct net_device *dev)
> +{
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +	u8 msgcfg;
> +	unsigned char obj_flags;
> +	unsigned int o, mo;
> +
> +	for (o =3D 0; o <  CC770_OBJ_MAX; o++) {
                         ^^^^^^^^^^^^^

what about ARRAY_SIZE(priv->obj_flags)

nitpick:
o is probalby short for object, but usually we use "i" for a for loop

> +		obj_flags =3D priv->obj_flags[o];
> +		mo =3D obj2msgobj(o);
> +
> +		if (obj_flags & CC770_OBJ_FLAG_RX) {
> +			/*
> +			 * We don't need extra objects for RTR and EFF if
> +			 * the additional CC770 functions are enabled.
> +			 */
> +			if (priv->control_normal_mode & CTRL_EAF) {
> +				if (o > 0)
> +					continue;
> +				netdev_dbg(dev, "Message object %d for "
> +					   "RX data, RTR, SFF and EFF\n", mo);
> +			} else {
> +				netdev_dbg(dev,
> +					   "Message object %d for RX %s %s\n",
> +					   mo, obj_flags & CC770_OBJ_FLAG_RTR ?
> +					   "RTR" : "data",
> +					   obj_flags & CC770_OBJ_FLAG_EFF ?
> +					   "EFF" : "SFF");
> +			}
> +
> +			if (obj_flags & CC770_OBJ_FLAG_EFF)
> +				msgcfg =3D MSGCFG_XTD;
> +			else
> +				msgcfg =3D 0;
> +			if (obj_flags & CC770_OBJ_FLAG_RTR)
> +				msgcfg |=3D MSGCFG_DIR;
> +
> +			cc770_write_reg(priv, msgobj[mo].config, msgcfg);
> +			cc770_write_reg(priv, msgobj[mo].ctrl0,
> +					MSGVAL_SET | TXIE_RES |
> +					RXIE_SET | INTPND_RES);
> +
> +			if (obj_flags & CC770_OBJ_FLAG_RTR)
> +				cc770_write_reg(priv, msgobj[mo].ctrl1,
> +						NEWDAT_RES | CPUUPD_SET |
> +						TXRQST_RES | RMTPND_RES);
> +			else
> +				cc770_write_reg(priv, msgobj[mo].ctrl1,
> +						NEWDAT_RES | MSGLST_RES |
> +						TXRQST_RES | RMTPND_RES);
> +		} else {
> +			netdev_dbg(dev, "Message object %d for "
> +				   "TX data, RTR, SFF and EFF\n", mo);
> +
> +			cc770_write_reg(priv, msgobj[mo].ctrl1,
> +					RMTPND_RES | TXRQST_RES |
> +					CPUUPD_RES | NEWDAT_RES);
> +			cc770_write_reg(priv, msgobj[mo].ctrl0,
> +					MSGVAL_RES | TXIE_RES |
> +					RXIE_RES | INTPND_RES);
> +		}
> +	}
> +}
> +
> +static void disable_all_objs(const struct cc770_priv *priv)
> +{
> +	int i, mo;

here you use "i"

> +
> +	for (i =3D 0; i <  CC770_OBJ_MAX; i++) {

ARRAY_SIZE?

> +		mo =3D obj2msgobj(i);
> +
> +		if (priv->obj_flags[i] & CC770_OBJ_FLAG_RX) {
> +			if (i > 0 && priv->control_normal_mode & CTRL_EAF)
> +				continue;
> +
> +			cc770_write_reg(priv, msgobj[mo].ctrl1,
> +					NEWDAT_RES | MSGLST_RES |
> +					TXRQST_RES | RMTPND_RES);
> +			cc770_write_reg(priv, msgobj[mo].ctrl0,
> +					MSGVAL_RES | TXIE_RES |
> +					RXIE_RES | INTPND_RES);
> +		} else {
> +			/* Clear message object for send */
> +			cc770_write_reg(priv, msgobj[mo].ctrl1,
> +					RMTPND_RES | TXRQST_RES |
> +					CPUUPD_RES | NEWDAT_RES);
> +			cc770_write_reg(priv, msgobj[mo].ctrl0,
> +					MSGVAL_RES | TXIE_RES |
> +					RXIE_RES | INTPND_RES);
> +		}
> +	}
> +}
> +
> +static void set_reset_mode(struct net_device *dev)
> +{
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +
> +	/* Enable configuration and puts chip in bus-off, disable interrupts =
*/
> +	cc770_write_reg(priv, control, CTRL_CCE | CTRL_INI);
> +
> +	priv->can.state =3D CAN_STATE_STOPPED;
> +
> +	/* Clear interrupts */
> +	cc770_read_reg(priv, interrupt);
> +
> +	/* Clear status register */
> +	cc770_write_reg(priv, status, 0);
> +
> +	/* Disable all used message objects */
> +	disable_all_objs(priv);
> +}
> +
> +static void set_normal_mode(struct net_device *dev)
> +{
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +
> +	/* Clear interrupts */
> +	cc770_read_reg(priv, interrupt);
> +
> +	/* Clear status register and pre-set last error code */
> +	cc770_write_reg(priv, status, STAT_LEC_MASK);
> +
> +	/* Enable all used message objects*/
> +	enable_all_objs(dev);
> +
> +	/*
> +	 * Clear bus-off, interrupts only for errors,
> +	 * not for status change
> +	 */
> +	cc770_write_reg(priv, control, priv->control_normal_mode);
> +
> +	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +}
> +
> +static void chipset_init(struct cc770_priv *priv)
> +{
> +	int mo, id, data;
> +
> +	/* Enable configuration and put chip in bus-off, disable interrupts *=
/
> +	cc770_write_reg(priv, control, (CTRL_CCE | CTRL_INI));
> +
> +	/* Set CLKOUT divider and slew rates */
> +	cc770_write_reg(priv, clkout, priv->clkout);
> +
> +	/* Configure CPU interface / CLKOUT enable */
> +	cc770_write_reg(priv, cpu_interface, priv->cpu_interface);
> +
> +	/* Set bus configuration  */
> +	cc770_write_reg(priv, bus_config, priv->bus_config);
> +
> +	/* Clear interrupts */
> +	cc770_read_reg(priv, interrupt);
> +
> +	/* Clear status register */
> +	cc770_write_reg(priv, status, 0);
> +
> +	/* Clear and invalidate message objects */
> +	for (mo =3D MSGOBJ_FIRST; mo <=3D MSGOBJ_LAST; mo++) {
> +		cc770_write_reg(priv, msgobj[mo].ctrl0,
> +				INTPND_UNC | RXIE_RES |
> +				TXIE_RES | MSGVAL_RES);
> +		cc770_write_reg(priv, msgobj[mo].ctrl0,
> +				INTPND_RES | RXIE_RES |
> +				TXIE_RES | MSGVAL_RES);
> +		cc770_write_reg(priv, msgobj[mo].ctrl1,
> +				NEWDAT_RES | MSGLST_RES |
> +				TXRQST_RES | RMTPND_RES);
> +		for (data =3D 0; data < 8; data++)
> +			cc770_write_reg(priv, msgobj[mo].data[data], 0);
> +		for (id =3D 0; id < 4; id++)
> +			cc770_write_reg(priv, msgobj[mo].id[id], 0);
> +		cc770_write_reg(priv, msgobj[mo].config, 0);
> +	}
> +
> +	/* Set all global ID masks to "don't care" */
> +	cc770_write_reg(priv, global_mask_std[0], 0);
> +	cc770_write_reg(priv, global_mask_std[1], 0);
> +	cc770_write_reg(priv, global_mask_ext[0], 0);
> +	cc770_write_reg(priv, global_mask_ext[1], 0);
> +	cc770_write_reg(priv, global_mask_ext[2], 0);
> +	cc770_write_reg(priv, global_mask_ext[3], 0);
> +
> +}
> +
> +static int cc770_probe_chip(struct net_device *dev)

nitpick: This chip returns 1 on success and 0 on failure, IMHO unusual
return value. Why not make it return -ENODEV in case of failure?

> +{
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +
> +	/* Enable configuration, put chip in bus-off, disable ints */
> +	cc770_write_reg(priv, control, CTRL_CCE | CTRL_EAF | CTRL_INI);
> +	/* Configure cpu interface / CLKOUT disable */
> +	cc770_write_reg(priv, cpu_interface, priv->cpu_interface);
> +
> +	/*
> +	 * Check if hardware reset is still inactive or maybe there
> +	 * is no chip in this address space
> +	 */
> +	if (cc770_read_reg(priv, cpu_interface) & CPUIF_RST) {
> +		netdev_info(dev, "probing @0x%p failed (reset)\n",
> +			    priv->reg_base);
> +		return 0;
> +	}
> +
> +	/* Write and read back test pattern */

Are these Hex numbers arbitrary values?

> +	cc770_write_reg(priv, msgobj[1].data[1], 0x25);
> +	cc770_write_reg(priv, msgobj[2].data[3], 0x52);
> +	cc770_write_reg(priv, msgobj[10].data[6], 0xc3);
> +	if ((cc770_read_reg(priv, msgobj[1].data[1]) !=3D 0x25) ||
> +	    (cc770_read_reg(priv, msgobj[2].data[3]) !=3D 0x52) ||
> +	    (cc770_read_reg(priv, msgobj[10].data[6]) !=3D 0xc3)) {
> +		netdev_info(dev, "probing @0x%p failed (pattern)\n",
> +			    priv->reg_base);
> +		return 0;
> +	}
> +
> +	/* Check if this chip is a CC770 supporting additional functions */
> +	if (cc770_read_reg(priv, control) & CTRL_EAF)
> +		priv->control_normal_mode |=3D CTRL_EAF;
> +
> +	return 1;
> +}
> +
> +static void cc770_start(struct net_device *dev)
> +{
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +
> +	/* leave reset mode */
> +	if (priv->can.state !=3D CAN_STATE_STOPPED)
> +		set_reset_mode(dev);
> +
> +	/* leave reset mode */
> +	set_normal_mode(dev);
> +}
> +
> +static int cc770_set_mode(struct net_device *dev, enum can_mode mode)
> +{
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +
> +	if (!priv->open_time)
> +		return -EINVAL;
> +
> +	switch (mode) {
> +	case CAN_MODE_START:
> +		cc770_start(dev);
> +		if (netif_queue_stopped(dev))
> +			netif_wake_queue(dev);

The "if (netif_queue_stopped(dev))" is not needed.

> +		break;
> +
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +
> +	return 0;
> +}
> +
> +static int cc770_set_bittiming(struct net_device *dev)
> +{
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +	struct can_bittiming *bt =3D &priv->can.bittiming;
> +	u8 btr0, btr1;
> +
> +	btr0 =3D ((bt->brp - 1) & 0x3f) | (((bt->sjw - 1) & 0x3) << 6);
> +	btr1 =3D ((bt->prop_seg + bt->phase_seg1 - 1) & 0xf) |
> +		(((bt->phase_seg2 - 1) & 0x7) << 4);
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES)
> +		btr1 |=3D 0x80;
> +
> +	netdev_info(dev, "setting BTR0=3D0x%02x BTR1=3D0x%02x\n", btr0, btr1)=
;
> +
> +	cc770_write_reg(priv, bit_timing_0, btr0);
> +	cc770_write_reg(priv, bit_timing_1, btr1);
> +
> +	return 0;
> +}
> +
> +static netdev_tx_t cc770_start_xmit(struct sk_buff *skb, struct net_de=
vice *dev)
> +{
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +	struct net_device_stats *stats =3D &dev->stats;
> +	struct can_frame *cf =3D (struct can_frame *)skb->data;
> +	unsigned int mo =3D obj2msgobj(CC770_OBJ_TX);
> +	u8 dlc, rtr;
> +	u32 id;
> +	int i;
> +
> +	if (can_dropped_invalid_skb(dev, skb))
> +		return NETDEV_TX_OK;
> +
> +	if ((cc770_read_reg(priv,
> +			    msgobj[mo].ctrl1) & TXRQST_UNC) =3D=3D TXRQST_SET) {
> +		netdev_err(dev, "TX register is still occupied!\n");
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	netif_stop_queue(dev);
> +
> +	dlc =3D cf->can_dlc;
> +	id =3D cf->can_id;
> +	if (cf->can_id & CAN_RTR_FLAG)
> +		rtr =3D 0;
> +	else
> +		rtr =3D MSGCFG_DIR;
> +	cc770_write_reg(priv, msgobj[mo].ctrl1,
> +			RMTPND_RES | TXRQST_RES | CPUUPD_SET | NEWDAT_RES);
> +	cc770_write_reg(priv, msgobj[mo].ctrl0,
> +			MSGVAL_SET | TXIE_SET | RXIE_RES | INTPND_RES);
> +	if (id & CAN_EFF_FLAG) {
> +		id &=3D CAN_EFF_MASK;
> +		cc770_write_reg(priv, msgobj[mo].config,
> +				(dlc << 4) + rtr + MSGCFG_XTD);

+ is the same as | here, but IMHO bitwise or is more common coding styele=
=2E

> +		cc770_write_reg(priv, msgobj[mo].id[3],
> +				(id << 3) & 0xFFU);
> +		cc770_write_reg(priv, msgobj[mo].id[2],
> +				(id >> 5) & 0xFFU);
> +		cc770_write_reg(priv, msgobj[mo].id[1],
> +				(id >> 13) & 0xFFU);
> +		cc770_write_reg(priv, msgobj[mo].id[0],
> +				(id >> 21) & 0xFFU);

msgobj[].id[] is an u8, so & 0xff is not needed.

> +	} else {
> +		id &=3D CAN_SFF_MASK;
> +		cc770_write_reg(priv, msgobj[mo].config,
> +				(dlc << 4) + rtr);
> +		cc770_write_reg(priv, msgobj[mo].id[0],
> +				(id >> 3) & 0xFFU);
> +		cc770_write_reg(priv, msgobj[mo].id[1],
> +				(id << 5) & 0xFFU);
dito
> +	}
> +
> +	dlc &=3D 0x0f;		/* restore length only */

is this needed? The dlc should be valid.

> +	for (i =3D 0; i < dlc; i++)
> +		cc770_write_reg(priv, msgobj[mo].data[i], cf->data[i]);
> +
> +	cc770_write_reg(priv, msgobj[mo].ctrl1,
> +			RMTPND_RES | TXRQST_SET | CPUUPD_RES | NEWDAT_UNC);
> +
> +	stats->tx_bytes +=3D dlc;
> +
> +	can_put_echo_skb(skb, dev, 0);
> +
> +	/*
> +	 * HM: We had some cases of repeated IRQs so make sure the

Who is HM?

> +	 * INT is acknowledged I know it's already further up, but
> +	 * doing again fixed the issue
> +	 */
> +	cc770_write_reg(priv, msgobj[mo].ctrl0,
> +			MSGVAL_UNC | TXIE_UNC | RXIE_UNC | INTPND_RES);
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static void cc770_rx(struct net_device *dev, unsigned int mo, u8 ctrl1=
)
> +{
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +	struct net_device_stats *stats =3D &dev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	u8 config;
> +	u32 id;
> +	int i;
> +
> +	skb =3D alloc_can_skb(dev, &cf);
> +	if (skb =3D=3D NULL)
!skb
> +		return;
> +
> +	config =3D cc770_read_reg(priv, msgobj[mo].config);
> +
> +	if (ctrl1 & RMTPND_SET) {
> +		/*
> +		 * Unfortunately, the chip does not store the real message
> +		 * identifier of the received remote transmission request
> +		 * frame. Therefore we set it to 0.

What a bug!

> +		 */
> +		cf->can_id =3D CAN_RTR_FLAG;
> +		if (config & MSGCFG_XTD)
> +			cf->can_id |=3D CAN_EFF_FLAG;
> +		cf->can_dlc =3D 0;
> +	} else {
> +		if (config & MSGCFG_XTD) {
> +			id =3D cc770_read_reg(priv, msgobj[mo].id[3]);
> +			id |=3D cc770_read_reg(priv, msgobj[mo].id[2]) << 8;
> +			id |=3D cc770_read_reg(priv, msgobj[mo].id[1]) << 16;
> +			id |=3D cc770_read_reg(priv, msgobj[mo].id[0]) << 24;
> +			id >>=3D 3;
> +			id |=3D CAN_EFF_FLAG;
> +		} else {
> +			id =3D cc770_read_reg(priv, msgobj[mo].id[1]);
> +			id |=3D cc770_read_reg(priv, msgobj[mo].id[0]) << 8;
> +			id >>=3D 5;
> +		}
> +
> +		cf->can_id =3D id;
> +		cf->can_dlc =3D get_can_dlc((config & 0xf0) >> 4);
> +		for (i =3D 0; i < cf->can_dlc; i++)
> +			cf->data[i] =3D cc770_read_reg(priv, msgobj[mo].data[i]);
> +	}
> +	netif_rx(skb);
> +
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->can_dlc;
> +}
> +
> +static int cc770_err(struct net_device *dev, u8 status)
> +{
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +	struct net_device_stats *stats =3D &dev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	u8 lec;
> +
> +	netdev_dbg(dev, "status interrupt (%#x)\n", status);
> +
> +	skb =3D alloc_can_err_skb(dev, &cf);
> +	if (skb =3D=3D NULL)
!skb
> +		return -ENOMEM;
> +
> +	if (status & STAT_BOFF) {
> +		/* Disable interrupts */
> +		cc770_write_reg(priv, control, CTRL_INI);
> +		cf->can_id |=3D CAN_ERR_BUSOFF;
> +		priv->can.state =3D CAN_STATE_BUS_OFF;
> +		can_bus_off(dev);
> +	} else if (status & STAT_WARN) {
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		cf->data[1] =3D CAN_ERR_CRTL_RX_WARNING | CAN_ERR_CRTL_TX_WARNING;
> +		priv->can.state =3D CAN_STATE_ERROR_WARNING;
> +		priv->can.can_stats.error_warning++;
> +	}
> +
> +	lec =3D status & STAT_LEC_MASK;
> +	if (lec < 7 && lec > 0) {
> +		if (lec =3D=3D STAT_LEC_ACK) {
> +			cf->can_id |=3D CAN_ERR_ACK;
> +		} else {
> +			cf->can_id |=3D CAN_ERR_PROT;
> +			switch (lec) {
> +			case STAT_LEC_STUFF:
> +				cf->data[2] |=3D CAN_ERR_PROT_STUFF;
> +				break;
> +			case STAT_LEC_FORM:
> +				cf->data[2] |=3D CAN_ERR_PROT_FORM;
> +				break;
> +			case STAT_LEC_BIT1:
> +				cf->data[2] |=3D CAN_ERR_PROT_BIT1;
> +				break;
> +			case STAT_LEC_BIT0:
> +				cf->data[2] |=3D CAN_ERR_PROT_BIT0;
> +				break;
> +			case STAT_LEC_CRC:
> +				cf->data[3] |=3D CAN_ERR_PROT_LOC_CRC_SEQ;
> +				break;
> +			}
> +		}
> +	}
> +
> +	netif_rx(skb);
> +
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->can_dlc;
> +
> +	return 0;
> +}
> +
> +static int cc770_status_interrupt(struct net_device *dev)
> +{
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +	u8 status;
> +
> +	status =3D cc770_read_reg(priv, status);
> +	/* Reset the status register including RXOK and TXOK */
> +	cc770_write_reg(priv, status, STAT_LEC_MASK);
> +
> +	if (status & (STAT_WARN | STAT_BOFF) ||
> +	    (status & STAT_LEC_MASK) !=3D STAT_LEC_MASK) {
> +		cc770_err(dev, status);
> +		return status & STAT_BOFF;
> +	}
> +
> +	return 0;
> +}
> +
> +static void cc770_rx_interrupt(struct net_device *dev, unsigned int o)=

> +{
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +	struct net_device_stats *stats =3D &dev->stats;
> +	unsigned int mo =3D obj2msgobj(o);
> +	u8 ctrl1;
> +
> +	while (1) {

What about limiting this?

> +		ctrl1 =3D cc770_read_reg(priv, msgobj[mo].ctrl1);
> +
> +		if (!(ctrl1 & NEWDAT_SET))  {
> +			/* Check for RTR if additional functions are enabled */
> +			if (priv->control_normal_mode & CTRL_EAF) {
> +				if (!(cc770_read_reg(priv, msgobj[mo].ctrl0) &
> +				      INTPND_SET))
> +					break;
> +			} else {
> +				break;
> +			}
> +		}
> +
> +		if (ctrl1 & MSGLST_SET) {
> +			stats->rx_over_errors++;
> +			stats->rx_errors++;
> +		}
> +		if (mo < MSGOBJ_LAST)
> +			cc770_write_reg(priv, msgobj[mo].ctrl1,
> +					NEWDAT_RES | MSGLST_RES |
> +					TXRQST_UNC | RMTPND_UNC);
> +		cc770_rx(dev, mo, ctrl1);
> +
> +		cc770_write_reg(priv, msgobj[mo].ctrl0,
> +				MSGVAL_SET | TXIE_RES |
> +				RXIE_SET | INTPND_RES);
> +		cc770_write_reg(priv, msgobj[mo].ctrl1,
> +				NEWDAT_RES | MSGLST_RES |
> +				TXRQST_RES | RMTPND_RES);
> +	}
> +}
> +
> +static void cc770_rtr_interrupt(struct net_device *dev, unsigned int o=
)
> +{
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +	unsigned int mo =3D obj2msgobj(o);
> +	u8 ctrl0, ctrl1;
> +
> +	while (1) {

dito...?

> +		ctrl0 =3D cc770_read_reg(priv, msgobj[mo].ctrl0);
> +		if (!(ctrl0 & INTPND_SET))
> +			break;
> +
> +		ctrl1 =3D cc770_read_reg(priv, msgobj[mo].ctrl1);
> +		cc770_rx(dev, mo, ctrl1);
> +
> +		cc770_write_reg(priv, msgobj[mo].ctrl0,
> +				MSGVAL_SET | TXIE_RES |
> +				RXIE_SET | INTPND_RES);
> +		cc770_write_reg(priv, msgobj[mo].ctrl1,
> +				NEWDAT_RES | CPUUPD_SET |
> +				TXRQST_RES | RMTPND_RES);
> +	}
> +}
> +
> +static void cc770_tx_interrupt(struct net_device *dev, unsigned int o)=

> +{
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +	struct net_device_stats *stats =3D &dev->stats;
> +	unsigned int mo =3D obj2msgobj(o);
> +
> +	/* Nothing more to send, switch off interrupts */
> +	cc770_write_reg(priv, msgobj[mo].ctrl0,
> +			MSGVAL_RES | TXIE_RES | RXIE_RES | INTPND_RES);
> +	/*
> +	 * We had some cases of repeated IRQ so make sure the
> +	 * INT is acknowledged
> +	 */
> +	cc770_write_reg(priv, msgobj[mo].ctrl0,
> +			MSGVAL_UNC | TXIE_UNC | RXIE_UNC | INTPND_RES);
> +
> +	stats->tx_packets++;
> +	can_get_echo_skb(dev, 0);
> +	netif_wake_queue(dev);
> +}
> +
> +irqreturn_t cc770_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *dev =3D (struct net_device *)dev_id;
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +	u8 intid;
> +	int o, n =3D 0;
> +
> +	/* Shared interrupts and IRQ off? */
> +	if (priv->can.state =3D=3D CAN_STATE_STOPPED)
> +		return IRQ_NONE;
> +
> +	if (priv->pre_irq)
> +		priv->pre_irq(priv);
> +
> +	while (n < CC770_MAX_IRQ) {
> +		/* Read the highest pending interrupt request */
> +		intid =3D cc770_read_reg(priv, interrupt);
> +		if (!intid)
> +			break;
> +		n++;
> +
> +		if (intid =3D=3D 1) {
> +			/* Exit in case of bus-off */
> +			if (cc770_status_interrupt(dev))
> +				break;
> +		} else {
> +			o =3D intid2obj(intid);
> +
> +			if (o >=3D CC770_OBJ_MAX) {
> +				netdev_err(dev, "Unexpected interrupt id %d\n",
> +					   intid);
> +				continue;
> +			}
> +
> +			if (priv->obj_flags[o] & CC770_OBJ_FLAG_RTR)
> +				cc770_rtr_interrupt(dev, o);
> +			else if (priv->obj_flags[o] & CC770_OBJ_FLAG_RX)
> +				cc770_rx_interrupt(dev, o);
> +			else
> +				cc770_tx_interrupt(dev, o);
> +		}
> +	}
> +
> +	if (priv->post_irq)
> +		priv->post_irq(priv);
> +
> +	if (n >=3D CC770_MAX_IRQ)
> +		netdev_dbg(dev, "%d messages handled in ISR", n);
> +
> +	return (n) ? IRQ_HANDLED : IRQ_NONE;
> +}
> +
> +static int cc770_open(struct net_device *dev)
> +{
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +	int err;
> +
> +	/* set chip into reset mode */
> +	set_reset_mode(dev);
> +
> +	/* common open */
> +	err =3D open_candev(dev);
> +	if (err)
> +		return err;
> +
> +	err =3D request_irq(dev->irq, &cc770_interrupt, priv->irq_flags,
> +			  dev->name, (void *)dev);

the (void *) cast ist not needed

> +	if (err) {
> +		close_candev(dev);
> +		return -EAGAIN;
> +	}
> +
> +	/* init and start chip */
> +	cc770_start(dev);
> +	priv->open_time =3D jiffies;

open_time is used to track if the netdev is open, right? Can we use
"ndev->flags & IFF_UP" instead?

> +
> +	netif_start_queue(dev);
> +
> +	return 0;
> +}
> +
> +static int cc770_close(struct net_device *dev)
> +{
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +
> +	netif_stop_queue(dev);
> +	set_reset_mode(dev);
> +
> +	free_irq(dev->irq, (void *)dev);
cast not needed
> +	close_candev(dev);
> +
> +	priv->open_time =3D 0;
> +
> +	return 0;
> +}
> +
> +struct net_device *alloc_cc770dev(int sizeof_priv)
> +{
> +	struct net_device *dev;
> +	struct cc770_priv *priv;
> +
> +	dev =3D alloc_candev(sizeof(struct cc770_priv) + sizeof_priv,
> +			   CC770_ECHO_SKB_MAX);
> +	if (!dev)
> +		return NULL;
> +
> +	priv =3D netdev_priv(dev);
> +
> +	priv->dev =3D dev;
> +	priv->can.bittiming_const =3D &cc770_bittiming_const;
> +	priv->can.do_set_bittiming =3D cc770_set_bittiming;
> +	priv->can.do_set_mode =3D cc770_set_mode;
> +	priv->can.ctrlmode_supported =3D CAN_CTRLMODE_3_SAMPLES;
> +
> +	memcpy(priv->obj_flags, cc770_obj_flags, sizeof(cc770_obj_flags));
> +
> +	if (sizeof_priv)
> +		priv->priv =3D (void *)priv + sizeof(struct cc770_priv);
> +
> +	return dev;
> +}
> +EXPORT_SYMBOL_GPL(alloc_cc770dev);
> +
> +void free_cc770dev(struct net_device *dev)
> +{
> +	free_candev(dev);
> +}
> +EXPORT_SYMBOL_GPL(free_cc770dev);
> +
> +static const struct net_device_ops cc770_netdev_ops =3D {
> +	.ndo_open =3D cc770_open,
> +	.ndo_stop =3D cc770_close,
> +	.ndo_start_xmit =3D cc770_start_xmit,
> +};
> +
> +int register_cc770dev(struct net_device *dev)
> +{
> +	struct cc770_priv *priv =3D netdev_priv(dev);
> +
> +	if (!cc770_probe_chip(dev))
> +		return -ENODEV;
> +
> +	dev->netdev_ops =3D &cc770_netdev_ops;
> +
> +	dev->flags |=3D IFF_ECHO;	/* we support local echo */
> +
> +	/* Should we use additional functions? */
> +	if (!i82527_compat && priv->control_normal_mode & CTRL_EAF) {
> +		priv->control_normal_mode =3D CTRL_IE | CTRL_EAF | CTRL_EIE;
> +		netdev_dbg(dev, "i82527 mode with additional functions\n");
> +	} else {
> +		priv->control_normal_mode =3D CTRL_IE | CTRL_EIE;
> +		netdev_dbg(dev, "strict i82527 compatibility mode\n");
> +	}
> +
> +	chipset_init(priv);
> +	set_reset_mode(dev);
> +
> +	return register_candev(dev);
> +}
> +EXPORT_SYMBOL_GPL(register_cc770dev);
> +
> +void unregister_cc770dev(struct net_device *dev)
> +{
> +	set_reset_mode(dev);
> +	unregister_candev(dev);
> +}
> +EXPORT_SYMBOL_GPL(unregister_cc770dev);
> +
> +static __init int cc770_init(void)
> +{
> +	if (msgobj15_eff) {
> +		cc770_obj_flags[CC770_OBJ_RX0] |=3D CC770_OBJ_FLAG_EFF;
> +		cc770_obj_flags[CC770_OBJ_RX1] &=3D ~CC770_OBJ_FLAG_EFF;
> +	}
> +
> +	pr_info("%s CAN netdevice driver\n", DRV_NAME);

You can add a #define pr_fmt(fmt), to get rid of the "%s", DRV_NAME.

> +
> +	return 0;
> +}
> +module_init(cc770_init);
> +
> +static __exit void cc770_exit(void)
> +{
> +	pr_info("%s: driver removed\n", DRV_NAME);
> +}
> +module_exit(cc770_exit);
> diff --git a/drivers/net/can/cc770/cc770.h b/drivers/net/can/cc770/cc77=
0.h
> new file mode 100644
> index 0000000..c6b5800
> --- /dev/null
> +++ b/drivers/net/can/cc770/cc770.h
> @@ -0,0 +1,234 @@
> +/*
> + * cc770.h - Bosch CC770 and Intel AN82527 network device driver
> + *
> + * Copyright (C) 2009, 2011 Wolfgang Grandegger <wg@grandegger.com>
> + *
> + * Derived from the old Socket-CAN i82527 driver:
> + *
> + * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
> + * All rights reserved.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions
> + * are met:
> + * 1. Redistributions of source code must retain the above copyright
> + *    notice, this list of conditions and the following disclaimer.
> + * 2. Redistributions in binary form must reproduce the above copyrigh=
t
> + *    notice, this list of conditions and the following disclaimer in =
the
> + *    documentation and/or other materials provided with the distribut=
ion.
> + * 3. Neither the name of Volkswagen nor the names of its contributors=

> + *    may be used to endorse or promote products derived from this sof=
tware
> + *    without specific prior written permission.
> + *
> + * Alternatively, provided that this notice is retained in full, this
> + * software may be distributed under the terms of the GNU General
> + * Public License ("GPL") version 2, in which case the provisions of t=
he
> + * GPL apply INSTEAD OF those given above.
> + *
> + * The provided data structures and external interfaces from this code=

> + * are not restricted to be used by modules with a GPL compatible lice=
nse.
> + *
> + * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS=

> + * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
> + * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS F=
OR
> + * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGH=
T
> + * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTA=
L,
> + * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
> + * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF US=
E,
> + * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON A=
NY
> + * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT=

> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE U=
SE
> + * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
> + * DAMAGE.
> + *
> + * Send feedback to <socketcan-users@lists.berlios.de>

please remove

> + */
> +
> +#ifndef CC770_DEV_H
> +#define CC770_DEV_H
> +
> +#include <linux/can/dev.h>
> +
> +struct cc770_msgobj {
> +	u8 ctrl0;
> +	u8 ctrl1;
> +	u8 id[4];
> +	u8 config;
> +	u8 data[8];
> +	u8 dontuse;		/* padding */
> +} __attribute__ ((packed));
> +
> +struct cc770_regs {
> +	union {
> +		struct cc770_msgobj msgobj[16]; /* Message object 1..15 */
> +		struct {
> +			u8 control;		/* Control Register */
> +			u8 status;		/* Status Register */
> +			u8 cpu_interface;	/* CPU Interface Register */
> +			u8 dontuse1;
> +			u8 high_speed_read[2];	/* High Speed Read */
> +			u8 global_mask_std[2];	/* Standard Global Mask */
> +			u8 global_mask_ext[4];	/* Extended Global Mask */
> +			u8 msg15_mask[4];	/* Message 15 Mask */
> +			u8 dontuse2[15];
> +			u8 clkout;		/* Clock Out Register */
> +			u8 dontuse3[15];
> +			u8 bus_config;		/* Bus Configuration Register */
> +			u8 dontuse4[15];
> +			u8 bit_timing_0;	/* Bit Timing Register byte 0 */
> +			u8 dontuse5[15];
> +			u8 bit_timing_1;	/* Bit Timing Register byte 1 */
> +			u8 dontuse6[15];
> +			u8 interrupt;		/* Interrupt Register */
> +			u8 dontuse7[15];
> +			u8 rx_error_counter;	/* Receive Error Counter */
> +			u8 dontuse8[15];
> +			u8 tx_error_counter;	/* Transmit Error Counter */
> +			u8 dontuse9[31];
> +			u8 p1_conf;
> +			u8 dontuse10[15];
> +			u8 p2_conf;
> +			u8 dontuse11[15];
> +			u8 p1_in;
> +			u8 dontuse12[15];
> +			u8 p2_in;
> +			u8 dontuse13[15];
> +			u8 p1_out;
> +			u8 dontuse14[15];
> +			u8 p2_out;
> +			u8 dontuse15[15];
> +			u8 serial_reset_addr;
> +		};
> +	};
> +} __attribute__ ((packed));
> +
> +/* Control Register (0x00) */
> +#define CTRL_INI	0x01	/* Initialization */
> +#define CTRL_IE		0x02	/* Interrupt Enable */
> +#define CTRL_SIE	0x04	/* Status Interrupt Enable */
> +#define CTRL_EIE	0x08	/* Error Interrupt Enable */
> +#define CTRL_EAF	0x20	/* Enable additional functions */
> +#define CTRL_CCE	0x40	/* Change Configuration Enable */
> +
> +/* Status Register (0x01) */
> +#define STAT_LEC_STUFF	0x01	/* Stuff error */
> +#define STAT_LEC_FORM	0x02	/* Form error */
> +#define STAT_LEC_ACK	0x03	/* Acknowledgement error */
> +#define STAT_LEC_BIT1	0x04	/* Bit1 error */
> +#define STAT_LEC_BIT0	0x05	/* Bit0 error */
> +#define STAT_LEC_CRC	0x06	/* CRC error */
> +#define STAT_LEC_MASK	0x07	/* Last Error Code mask */
> +#define STAT_TXOK	0x08	/* Transmit Message Successfully */
> +#define STAT_RXOK	0x10	/* Receive Message Successfully */
> +#define STAT_WAKE	0x20	/* Wake Up Status */
> +#define STAT_WARN	0x40	/* Warning Status */
> +#define STAT_BOFF	0x80	/* Bus Off Status */
> +
> +/*
> + * CPU Interface Register (0x02)
> + * Clock Out Register (0x1f)
> + * Bus Configuration Register (0x2f)
> + *
> + * see include/linux/can/platform/cc770.h
> + */
> +
> +/* Message Control Register 0 (Base Address + 0x0) */
> +#define INTPND_RES	0x01	/* No Interrupt pending */
> +#define INTPND_SET	0x02	/* Interrupt pending */
> +#define INTPND_UNC	0x03
> +#define RXIE_RES	0x04	/* Receive Interrupt Disable */
> +#define RXIE_SET	0x08	/* Receive Interrupt Enable */
> +#define RXIE_UNC	0x0c
> +#define TXIE_RES	0x10	/* Transmit Interrupt Disable */
> +#define TXIE_SET	0x20	/* Transmit Interrupt Enable */
> +#define TXIE_UNC	0x30
> +#define MSGVAL_RES	0x40	/* Message Invalid */
> +#define MSGVAL_SET	0x80	/* Message Valid */
> +#define MSGVAL_UNC	0xc0
> +
> +/* Message Control Register 1 (Base Address + 0x01) */
> +#define NEWDAT_RES	0x01	/* No New Data */
> +#define NEWDAT_SET	0x02	/* New Data */
> +#define NEWDAT_UNC	0x03
> +#define MSGLST_RES	0x04	/* No Message Lost */
> +#define MSGLST_SET	0x08	/* Message Lost */
> +#define MSGLST_UNC	0x0c
> +#define CPUUPD_RES	0x04	/* No CPU Updating */
> +#define CPUUPD_SET	0x08	/* CPU Updating */
> +#define CPUUPD_UNC	0x0c
> +#define TXRQST_RES	0x10	/* No Transmission Request */
> +#define TXRQST_SET	0x20	/* Transmission Request */
> +#define TXRQST_UNC	0x30
> +#define RMTPND_RES	0x40	/* No Remote Request Pending */
> +#define RMTPND_SET	0x80	/* Remote Request Pending */
> +#define RMTPND_UNC	0xc0
> +
> +/* Message Configuration Register (Base Address + 0x06) */
> +#define MSGCFG_XTD	0x04	/* Extended Identifier */
> +#define MSGCFG_DIR	0x08	/* Direction is Transmit */
> +
> +#define MSGOBJ_FIRST	1
> +#define MSGOBJ_LAST	15
> +
> +#define CC770_IO_SIZE	0x100
> +#define CC770_MAX_IRQ	20	/* max. number of interrupts handled in ISR *=
/
> +
> +#define CC770_ECHO_SKB_MAX	1
> +
> +#define cc770_read_reg(priv, member)					\
> +	priv->read_reg(priv, offsetof(struct cc770_regs, member))
> +
> +#define cc770_write_reg(priv, member, value)				\
> +	priv->write_reg(priv, offsetof(struct cc770_regs, member), value)
> +
> +/*
> + * Message objects and flags used by this driver
> + */
> +#define CC770_OBJ_FLAG_RX 	0x01
> +#define CC770_OBJ_FLAG_RTR	0x02
> +#define CC770_OBJ_FLAG_EFF	0x04
> +
> +enum {
> +	CC770_OBJ_RX0 =3D 0,	/* for receiving normal messages */
> +	CC770_OBJ_RX1,		/* for receiving normal messages */
> +	CC770_OBJ_RX_RTR0,	/* for receiving remote transmission requests */
> +	CC770_OBJ_RX_RTR1,	/* for receiving remote transmission requests */
> +	CC770_OBJ_TX,		/* for sending messages */
> +	CC770_OBJ_MAX
> +};
> +
> +#define obj2msgobj(o)	(MSGOBJ_LAST - (o)) /* message object 11..15 */
> +
> +/*
> + * CC770 private data structure
> + */
> +struct cc770_priv {
> +	struct can_priv can;	/* must be the first member */
> +	int open_time;
> +	struct sk_buff *echo_skb;
> +
> +	/* the lower-layer is responsible for appropriate locking */
> +	u8 (*read_reg)(const struct cc770_priv *priv, int reg);
> +	void (*write_reg)(const struct cc770_priv *priv, int reg, u8 val);
> +	void (*pre_irq)(const struct cc770_priv *priv);
> +	void (*post_irq)(const struct cc770_priv *priv);
> +
> +	void *priv;		/* for board-specific data */
> +	struct net_device *dev;
> +
> +	void __iomem *reg_base;	/* ioremap'ed address to registers */
> +	unsigned long irq_flags;	/* for request_irq() */
> +
> +	unsigned char obj_flags[CC770_OBJ_MAX];
> +	u8 control_normal_mode;	/* Control register for normal mode */
> +	u8 cpu_interface;	/* CPU interface register */
> +	u8 clkout;		/* Clock out register */
> +	u8 bus_config;		/* Bus conffiguration register */
> +};
> +
> +struct net_device *alloc_cc770dev(int sizeof_priv);
> +void free_cc770dev(struct net_device *dev);
> +int register_cc770dev(struct net_device *dev);
> +void unregister_cc770dev(struct net_device *dev);
> +
> +#endif /* CC770_DEV_H */
> diff --git a/include/linux/can/platform/cc770.h b/include/linux/can/pla=
tform/cc770.h
> new file mode 100644
> index 0000000..c4ed994
> --- /dev/null
> +++ b/include/linux/can/platform/cc770.h
> @@ -0,0 +1,33 @@
> +#ifndef _CAN_PLATFORM_CC770_H_
> +#define _CAN_PLATFORM_CC770_H_
> +
> +/* CPU Interface Register (0x02) */
> +#define CPUIF_CEN	0x01	/* Clock Out Enable */
> +#define CPUIF_MUX	0x04	/* Multiplex */
> +#define CPUIF_SLP	0x08	/* Sleep */
> +#define CPUIF_PWD	0x10	/* Power Down Mode */
> +#define CPUIF_DMC	0x20	/* Divide Memory Clock */
> +#define CPUIF_DSC	0x40	/* Divide System Clock */
> +#define CPUIF_RST	0x80	/* Hardware Reset Status */
> +
> +/* Clock Out Register (0x1f) */
> +#define CLKOUT_CD_MASK  0x0f	/* Clock Divider mask */
> +#define CLKOUT_SL_MASK	0x30	/* Slew Rate mask */
> +#define CLKOUT_SL_SHIFT	4
> +
> +/* Bus Configuration Register (0x2f) */
> +#define BUSCFG_DR0	0x01	/* Disconnect RX0 Input / Select RX input */
> +#define BUSCFG_DR1	0x02	/* Disconnect RX1 Input / Silent mode */
> +#define BUSCFG_DT1	0x08	/* Disconnect TX1 Output */
> +#define BUSCFG_POL	0x20	/* Polarity dominant or recessive */
> +#define BUSCFG_CBY	0x40	/* Input Comparator Bypass */
> +
> +struct cc770_platform_data {
> +	u32 osc_freq;	/* CAN bus oscillator frequency in Hz */
> +
> +	u8 cir;	 	/* CPU Interface Register */
> +	u8 cor;		/* Clock Out Register */
> +	u8 bcr;		/* Bus Configuration Register */
> +};
> +
> +#endif	/* !_CAN_PLATFORM_CC770_H_ */


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigB5CF2C263C6237604E67C44A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk7TcFAACgkQjTAFq1RaXHMbNQCfVM6u8OSVC9lKVe0mcu7Wu7yu
0NAAnRTPIzbWL6cwlYu+2E3+EH6cITqB
=JsxA
-----END PGP SIGNATURE-----

--------------enigB5CF2C263C6237604E67C44A--
