From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v6 1/1] can: c_can: Added support for Bosch
	C_CAN	controller
Date: Wed, 09 Feb 2011 10:27:20 +0100
Message-ID: <4D525DF8.6050409@pengutronix.de>
References: <1297227821-18021-1-git-send-email-bhupesh.sharma@st.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4878447109728268983=="
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1297227821-18021-1-git-send-email-bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
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
--===============4878447109728268983==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig945A6BD8661FDFB5081B9902"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig945A6BD8661FDFB5081B9902
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 02/09/2011 06:03 AM, Bhupesh Sharma wrote:
> Bosch C_CAN controller is a full-CAN implementation which is compliant
> to CAN protocol version 2.0 part A and B. Bosch C_CAN user manual can b=
e
> obtained from:
> http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/
> c_can/users_manual_c_can.pdf
>=20
> This patch adds the support for this controller.
> The following are the design choices made while writing the controller
> driver:
> 1. Interface Register set IF1 has be used only in the current design.
> 2. Out of the 32 Message objects available, 16 are kept aside for RX
>    purposes and the rest for TX purposes.
> 3. NAPI implementation is such that both the TX and RX paths function
>    in polling mode.
>=20
> Signed-off-by: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>

The driver looks quite good, some comments inline, most of them
nitpicking and or style related.

Have a look at the netif_stop_queue(). In the at91 driver there are two
possibilities that to stop the queue. First the next tx mailbox is still
in use, second we have a wrap around. But your hardware is a bit
different. Anyways a second look doesn't harm.

> ---
> Changes since V5:
> 1. Seperated the state change and bus error handling paths.
> 2. Added logic to write LEC value to 0x7 from CPU to check for updates
>    later.
> 3. Corrected the ERROR_WARNING handling logic to correctly send error
>    frames on the bus.
> 						  =20
>  drivers/net/can/Kconfig                |    2 +
>  drivers/net/can/Makefile               |    1 +
>  drivers/net/can/c_can/Kconfig          |   15 +
>  drivers/net/can/c_can/Makefile         |    8 +
>  drivers/net/can/c_can/c_can.c          |  993 ++++++++++++++++++++++++=
++++++++
>  drivers/net/can/c_can/c_can.h          |  230 ++++++++
>  drivers/net/can/c_can/c_can_platform.c |  207 +++++++
>  7 files changed, 1456 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/c_can/Kconfig
>  create mode 100644 drivers/net/can/c_can/Makefile
>  create mode 100644 drivers/net/can/c_can/c_can.c
>  create mode 100644 drivers/net/can/c_can/c_can.h
>  create mode 100644 drivers/net/can/c_can/c_can_platform.c
>=20
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 5dec456..1d699e3 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -115,6 +115,8 @@ source "drivers/net/can/mscan/Kconfig"
> =20
>  source "drivers/net/can/sja1000/Kconfig"
> =20
> +source "drivers/net/can/c_can/Kconfig"
> +
>  source "drivers/net/can/usb/Kconfig"
> =20
>  source "drivers/net/can/softing/Kconfig"
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 53c82a7..24ebfe8 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -13,6 +13,7 @@ obj-y				+=3D softing/
> =20
>  obj-$(CONFIG_CAN_SJA1000)	+=3D sja1000/
>  obj-$(CONFIG_CAN_MSCAN)		+=3D mscan/
> +obj-$(CONFIG_CAN_C_CAN)		+=3D c_can/
>  obj-$(CONFIG_CAN_AT91)		+=3D at91_can.o
>  obj-$(CONFIG_CAN_TI_HECC)	+=3D ti_hecc.o
>  obj-$(CONFIG_CAN_MCP251X)	+=3D mcp251x.o
> diff --git a/drivers/net/can/c_can/Kconfig b/drivers/net/can/c_can/Kcon=
fig
> new file mode 100644
> index 0000000..ffb9773
> --- /dev/null
> +++ b/drivers/net/can/c_can/Kconfig
> @@ -0,0 +1,15 @@
> +menuconfig CAN_C_CAN
> +	tristate "Bosch C_CAN devices"
> +	depends on CAN_DEV && HAS_IOMEM
> +
> +if CAN_C_CAN
> +
> +config CAN_C_CAN_PLATFORM
> +	tristate "Generic Platform Bus based C_CAN driver"
> +	---help---
> +	  This driver adds support for the C_CAN chips connected to
> +	  the "platform bus" (Linux abstraction for directly to the
> +	  processor attached devices) which can be found on various
> +	  boards from ST Microelectronics (http://www.st.com)
> +	  like the SPEAr1310 and SPEAr320 evaluation boards.
> +endif
> diff --git a/drivers/net/can/c_can/Makefile b/drivers/net/can/c_can/Mak=
efile
> new file mode 100644
> index 0000000..9273f6d
> --- /dev/null
> +++ b/drivers/net/can/c_can/Makefile
> @@ -0,0 +1,8 @@
> +#
> +#  Makefile for the Bosch C_CAN controller drivers.
> +#
> +
> +obj-$(CONFIG_CAN_C_CAN) +=3D c_can.o
> +obj-$(CONFIG_CAN_C_CAN_PLATFORM) +=3D c_can_platform.o
> +
> +ccflags-$(CONFIG_CAN_DEBUG_DEVICES) :=3D -DDEBUG
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_ca=
n.c
> new file mode 100644
> index 0000000..7ef4aa9
> --- /dev/null
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -0,0 +1,993 @@
> +/*
> + * CAN bus driver for Bosch C_CAN controller
> + *
> + * Copyright (C) 2010 ST Microelectronics
> + * Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
> + *
> + * Borrowed heavily from the C_CAN driver originally written by:
> + * Copyright (C) 2007
> + * - Sascha Hauer, Marc Kleine-Budde, Pengutronix <s.hauer@pengutronix=
=2Ede>
> + * - Simon Kallweit, intefo AG <simon.kallweit-+G9qxTFKJT/tRgLqZ5aouw@public.gmane.org>
> + *
> + * TX and RX NAPI implementation has been borrowed from at91 CAN drive=
r
> + * written by:
> + * Copyright
> + * (C) 2007 by Hans J. Koch <hjk-vqZO0P4V72/QD6PfKP4TzA@public.gmane.org>
> + * (C) 2008, 2009 by Marc Kleine-Budde <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> + *
> + * Bosch C_CAN controller is compliant to CAN protocol version 2.0 par=
t A and B.
> + * Bosch C_CAN user manual can be obtained from:
> + * http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/c_can/
> + * users_manual_c_can.pdf
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
> +#include <linux/io.h>
> +
> +#include <linux/can.h>
> +#include <linux/can/dev.h>
> +#include <linux/can/error.h>
> +
> +#include "c_can.h"
> +
> +static struct can_bittiming_const c_can_bittiming_const =3D {
> +	.name =3D KBUILD_MODNAME,
> +	.tseg1_min =3D 2,		/* Time segment 1 =3D prop_seg + phase_seg1 */
> +	.tseg1_max =3D 16,
> +	.tseg2_min =3D 1,		/* Time segment 2 =3D phase_seg2 */
> +	.tseg2_max =3D 8,
> +	.sjw_max =3D 4,
> +	.brp_min =3D 1,
> +	.brp_max =3D 1024,	/* 6-bit BRP field + 4-bit BRPE field*/
> +	.brp_inc =3D 1,
> +};
> +
> +static inline int get_tx_next_msg_obj(const struct c_can_priv *priv)
> +{
> +	return (priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) +
> +			C_CAN_MSG_OBJ_TX_FIRST;
> +}
> +
> +static inline int get_tx_echo_msg_obj(const struct c_can_priv *priv)
> +{
> +	return (priv->tx_echo & C_CAN_NEXT_MSG_OBJ_MASK) +
> +			C_CAN_MSG_OBJ_TX_FIRST;
> +}
> +
> +static u32 c_can_read_reg32(struct c_can_priv *priv, void *reg)
> +{
> +	u32 val =3D priv->read_reg(priv, reg);
> +	val |=3D ((u32) priv->read_reg(priv, reg + 2)) << 16;
> +	return val;
> +}
> +
> +static void c_can_enable_all_interrupts(struct c_can_priv *priv,
> +						int enable)
> +{
> +	unsigned int cntrl_save =3D priv->read_reg(priv,
> +						&priv->regs->control);
> +
> +	if (enable)
> +		cntrl_save |=3D (CONTROL_SIE | CONTROL_EIE | CONTROL_IE);
> +	else
> +		cntrl_save &=3D ~(CONTROL_EIE | CONTROL_IE | CONTROL_SIE);
> +
> +	priv->write_reg(priv, &priv->regs->control, cntrl_save);
> +}
> +
> +static inline int c_can_check_busy_status(struct c_can_priv *priv, int=
 iface)
> +{
> +	int count =3D MIN_TIMEOUT_VALUE;
> +
> +	while (count && priv->read_reg(priv,
> +				&priv->regs->ifregs[iface].com_req) &
> +				IF_COMR_BUSY) {
> +		count--;
> +		udelay(1);
> +	}
> +
> +	return count;

it's an unusual return value...maybe return 0 on success and -EBUSY
otherwise?

> +}
> +
> +static inline void c_can_object_get(struct net_device *dev,
> +					int iface, int objno, int mask)
> +{
> +	int ret;
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	/*
> +	 * As per specs, after writting the message object number in the
> +	 * IF command request register the transfer b/w interface
> +	 * register and message RAM must be complete in 6 CAN-CLK
> +	 * period.
> +	 */
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].com_mask,
> +			IFX_WRITE_LOW_16BIT(mask));
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].com_req,
> +			IFX_WRITE_LOW_16BIT(objno));
> +
> +	ret =3D c_can_check_busy_status(priv, iface);
> +	if (!ret)
> +		netdev_err(dev, "timed out in object get\n");
> +}
> +
> +static inline void c_can_object_put(struct net_device *dev,
> +					int iface, int objno, int mask)
> +{
> +	int ret;
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	/*
> +	 * As per specs, after writting the message object number in the
> +	 * IF command request register the transfer b/w interface
> +	 * register and message RAM must be complete in 6 CAN-CLK
> +	 * period.
> +	 */
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].com_mask,
> +			(IF_COMM_WR | IFX_WRITE_LOW_16BIT(mask)));
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].com_req,
> +			IFX_WRITE_LOW_16BIT(objno));
> +
> +	ret =3D c_can_check_busy_status(priv, iface);
> +	if (!ret)
> +		netdev_err(dev, "timed out in object put\n");
> +}
> +
> +static void c_can_write_msg_object(struct net_device *dev,
> +			int iface, struct can_frame *frame, int objno)
> +{
> +	int i;
> +	u16 flags =3D 0;
> +	unsigned int id;
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	if (!(frame->can_id & CAN_RTR_FLAG))
> +		flags |=3D IF_ARB_TRANSMIT;
> +
> +	if (frame->can_id & CAN_EFF_FLAG) {
> +		id =3D frame->can_id & CAN_EFF_MASK;
> +		flags |=3D IF_ARB_MSGXTD;
> +	} else
> +		id =3D ((frame->can_id & CAN_SFF_MASK) << 18);
> +
> +	flags |=3D IF_ARB_MSGVAL;
> +
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].arb1,
> +				IFX_WRITE_LOW_16BIT(id));
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].arb2, flags |
> +				IFX_WRITE_HIGH_16BIT(id));
> +
> +	for (i =3D 0; i < frame->can_dlc; i +=3D 2) {
> +		priv->write_reg(priv, &priv->regs->ifregs[iface].data[i / 2],
> +				frame->data[i] | (frame->data[i + 1] << 8));
> +	}
> +
> +	/* enable interrupt for this message object */
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].msg_cntrl,
> +			IF_MCONT_TXIE | IF_MCONT_TXRQST | IF_MCONT_EOB |
> +			(frame->can_dlc & 0xf));
                                        ^^^^^

the masking should not be needed, as you're using can_dropped_invalid_skb=
()

> +	c_can_object_put(dev, iface, objno, IF_COMM_ALL);
> +}
> +
> +static inline void c_can_mark_rx_msg_obj(struct net_device *dev,
> +						int iface, int ctrl_mask,
> +						int obj)
> +{
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].msg_cntrl,
> +			ctrl_mask & ~(IF_MCONT_MSGLST | IF_MCONT_INTPND));
> +	c_can_object_put(dev, iface, obj, IF_COMM_CONTROL);
> +
> +}
> +
> +static inline void c_can_activate_all_lower_rx_msg_obj(struct net_devi=
ce *dev,
> +						int iface,
> +						int ctrl_mask)
> +{
> +	int i;
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	for (i =3D C_CAN_MSG_OBJ_RX_FIRST; i <=3D C_CAN_MSG_RX_LOW_LAST; i++)=
 {
> +		priv->write_reg(priv, &priv->regs->ifregs[iface].msg_cntrl,
> +				ctrl_mask & ~(IF_MCONT_MSGLST |
> +					IF_MCONT_INTPND | IF_MCONT_NEWDAT));
> +		c_can_object_put(dev, iface, i, IF_COMM_CONTROL);
> +	}
> +}
> +
> +static inline void c_can_activate_rx_msg_obj(struct net_device *dev,
> +						int iface, int ctrl_mask,
> +						int obj)
> +{
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].msg_cntrl,
> +			ctrl_mask & ~(IF_MCONT_MSGLST |
> +				IF_MCONT_INTPND | IF_MCONT_NEWDAT));
> +	c_can_object_put(dev, iface, obj, IF_COMM_CONTROL);
> +}
> +
> +static void c_can_handle_lost_msg_obj(struct net_device *dev,
> +					int iface, int objno)
> +{
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +	struct net_device_stats *stats =3D &dev->stats;
> +	struct sk_buff *skb;
> +	struct can_frame *frame;
> +
> +	netdev_err(dev, "msg lost in buffer %d\n", objno);
> +
> +	c_can_object_get(dev, iface, objno, IF_COMM_ALL & ~IF_COMM_TXRQST);
> +
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].msg_cntrl,
> +			IF_MCONT_CLR_MSGLST);
> +
> +	c_can_object_put(dev, 0, objno, IF_COMM_CONTROL);
> +
> +	/* create an error msg */
> +	skb =3D alloc_can_err_skb(dev, &frame);
> +	if (unlikely(!skb))
> +		return;
> +
> +	frame->can_id |=3D CAN_ERR_CRTL;
> +	frame->data[1] =3D CAN_ERR_CRTL_RX_OVERFLOW;
> +	stats->rx_errors++;
> +	stats->rx_over_errors++;
> +
> +	netif_receive_skb(skb);
> +}
> +
> +static int c_can_read_msg_object(struct net_device *dev, int iface, in=
t ctrl)
> +{
> +	u16 flags, data;
> +	int i;
> +	unsigned int val;
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +	struct net_device_stats *stats =3D &dev->stats;
> +	struct sk_buff *skb;
> +	struct can_frame *frame;
> +
> +	skb =3D alloc_can_skb(dev, &frame);
> +	if (!skb) {
> +		stats->rx_dropped++;
> +		return -ENOMEM;
> +	}
> +
> +	frame->can_dlc =3D get_can_dlc(ctrl & 0x0F);
> +
> +	for (i =3D 0; i < frame->can_dlc; i +=3D 2) {
> +		data =3D priv->read_reg(priv,
> +				&priv->regs->ifregs[iface].data[i / 2]);
> +		frame->data[i] =3D data;
> +		frame->data[i + 1] =3D data >> 8;
> +	}
> +
> +	flags =3D	priv->read_reg(priv, &priv->regs->ifregs[iface].arb2);
> +	val =3D priv->read_reg(priv, &priv->regs->ifregs[iface].arb1) |
> +		(flags << 16);
> +
> +	if (flags & IF_ARB_MSGXTD)
> +		frame->can_id =3D (val & CAN_EFF_MASK) | CAN_EFF_FLAG;
> +	else
> +		frame->can_id =3D (val >> 18) & CAN_SFF_MASK;
> +
> +	if (flags & IF_ARB_TRANSMIT)
> +		frame->can_id |=3D CAN_RTR_FLAG;

Can you please only copy the data to the frame if the rtr flag isn't
set. Not all driver do this yet, but we've agreed to do so.

> +
> +	netif_receive_skb(skb);
> +
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D frame->can_dlc;
> +
> +	return 0;
> +}
> +
> +static void c_can_setup_receive_object(struct net_device *dev, int ifa=
ce,
> +					int objno, unsigned int mask,
> +					unsigned int id, unsigned int mcont)
> +{
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].mask1,
> +			IFX_WRITE_LOW_16BIT(mask));
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].mask2,
> +			IFX_WRITE_HIGH_16BIT(mask));
> +
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].arb1,
> +			IFX_WRITE_LOW_16BIT(id));
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].arb2,
> +			(IF_ARB_MSGVAL | IFX_WRITE_HIGH_16BIT(id)));
> +
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].msg_cntrl, mcont);
> +	c_can_object_put(dev, iface, objno, IF_COMM_ALL & ~IF_COMM_TXRQST);
> +
> +	netdev_dbg(dev, "obj no:%d, msgval:0x%08x\n", objno,
> +			c_can_read_reg32(priv, &priv->regs->msgval1));
> +}
> +
> +static void c_can_inval_msg_object(struct net_device *dev, int iface, =
int objno)
> +{
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].arb1, 0);
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].arb2, 0);
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].msg_cntrl, 0);
> +
> +	c_can_object_put(dev, iface, objno, IF_COMM_ARB | IF_COMM_CONTROL);
> +
> +	netdev_dbg(dev, "obj no:%d, msgval:0x%08x\n", objno,
> +			c_can_read_reg32(priv, &priv->regs->msgval1));
> +}
> +
> +static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
> +					struct net_device *dev)
> +{
> +	u32 msg_obj_no;
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +	struct can_frame *frame =3D (struct can_frame *)skb->data;
> +
> +	if (can_dropped_invalid_skb(dev, skb))
> +		return NETDEV_TX_OK;
> +
> +	msg_obj_no =3D get_tx_next_msg_obj(priv);
> +
> +	/* prepare message object for transmission */
> +	c_can_write_msg_object(dev, 0, frame, msg_obj_no);
> +	can_put_echo_skb(skb, dev, msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
> +
> +	priv->tx_next++;
> +	if ((priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) =3D=3D 0)
> +		netif_stop_queue(dev);

It it possible, that the "tx_next" object isn't available, yet?
Understanding your code right. It's not possible, because you have a
wrap around (which is handled above) first.

> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static int c_can_set_bittiming(struct net_device *dev)
> +{
> +	unsigned int reg_btr, reg_brpe, ctrl_save;
> +	u8 brp, brpe, sjw, tseg1, tseg2;
> +	u32 ten_bit_brp;
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +	const struct can_bittiming *bt =3D &priv->can.bittiming;
> +
> +	/* c_can provides a 6-bit brp and 4-bit brpe fields */
> +	ten_bit_brp =3D bt->brp - 1;
> +	brp =3D ten_bit_brp & BTR_BRP_MASK;
> +	brpe =3D ten_bit_brp >> 6;
> +
> +	sjw =3D bt->sjw - 1;
> +	tseg1 =3D bt->prop_seg + bt->phase_seg1 - 1;
> +	tseg2 =3D bt->phase_seg2 - 1;
> +	reg_btr =3D brp | (sjw << BTR_SJW_SHIFT) | (tseg1 << BTR_TSEG1_SHIFT)=
 |
> +			(tseg2 << BTR_TSEG2_SHIFT);
> +	reg_brpe =3D brpe & BRP_EXT_BRPE_MASK;
> +
> +	netdev_info(dev,
> +		"setting BTR=3D%04x BRPE=3D%04x\n", reg_btr, reg_brpe);
> +
> +	ctrl_save =3D priv->read_reg(priv, &priv->regs->control);
> +	priv->write_reg(priv, &priv->regs->control,
> +			ctrl_save | CONTROL_CCE | CONTROL_INIT);
> +	priv->write_reg(priv, &priv->regs->btr, reg_btr);
> +	priv->write_reg(priv, &priv->regs->brp_ext, reg_brpe);
> +	priv->write_reg(priv, &priv->regs->control, ctrl_save);
> +
> +	return 0;
> +}
> +
> +/*
> + * Configure C_CAN message objects for Tx and Rx purposes:
> + * C_CAN provides a total of 32 message objects that can be configured=

> + * either for Tx or Rx purposes. Here the first 16 message objects are=
 used as
> + * a reception FIFO. The end of reception FIFO is signified by the EoB=
 bit
> + * being SET. The remaining 16 message objects are kept aside for Tx p=
urposes.
> + * See user guide document for further details on configuring message
> + * objects.
> + */
> +static void c_can_configure_msg_objects(struct net_device *dev)
> +{
> +	int i;
> +
> +	/* first invalidate all message objects */
> +	for (i =3D C_CAN_MSG_OBJ_RX_FIRST; i <=3D C_CAN_NO_OF_OBJECTS; i++)
> +		c_can_inval_msg_object(dev, 0, i);
> +
> +	/* setup receive message objects */
> +	for (i =3D C_CAN_MSG_OBJ_RX_FIRST; i < C_CAN_MSG_OBJ_RX_LAST; i++)
> +		c_can_setup_receive_object(dev, 0, i, 0, 0,
> +			(IF_MCONT_RXIE | IF_MCONT_UMASK) & ~IF_MCONT_EOB);
> +
> +	c_can_setup_receive_object(dev, 0, C_CAN_MSG_OBJ_RX_LAST, 0, 0,
> +			IF_MCONT_EOB | IF_MCONT_RXIE | IF_MCONT_UMASK);
> +}
> +
> +/*
> + * Configure C_CAN chip:
> + * - enable/disable auto-retransmission
> + * - set operating mode
> + * - configure message objects
> + */
> +static void c_can_chip_config(struct net_device *dev)
> +{
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	if (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT)
> +		/* disable automatic retransmission */
> +		priv->write_reg(priv, &priv->regs->control,
> +				CONTROL_DISABLE_AR);
> +	else
> +		/* enable automatic retransmission */
> +		priv->write_reg(priv, &priv->regs->control,
> +				CONTROL_ENABLE_AR);
> +
> +	if (priv->can.ctrlmode & (CAN_CTRLMODE_LISTENONLY &
> +					CAN_CTRLMODE_LOOPBACK)) {
> +		/* loopback + silent mode : useful for hot self-test */
> +		priv->write_reg(priv, &priv->regs->control, CONTROL_EIE |
> +				CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
> +		priv->write_reg(priv, &priv->regs->test,
> +				TEST_LBACK | TEST_SILENT);
> +	} else if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
> +		/* loopback mode : useful for self-test function */
> +		priv->write_reg(priv, &priv->regs->control, CONTROL_EIE |
> +				CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
> +		priv->write_reg(priv, &priv->regs->test, TEST_LBACK);
> +	} else if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY) {
> +		/* silent mode : bus-monitoring mode */
> +		priv->write_reg(priv, &priv->regs->control, CONTROL_EIE |
> +				CONTROL_SIE | CONTROL_IE | CONTROL_TEST);
> +		priv->write_reg(priv, &priv->regs->test, TEST_SILENT);
> +	} else
> +		/* normal mode*/
> +		priv->write_reg(priv, &priv->regs->control,
> +				CONTROL_EIE | CONTROL_SIE | CONTROL_IE);
> +
> +	/* configure message objects */
> +	c_can_configure_msg_objects(dev);
> +
> +	/* set a `lec` value so that we can check for updates later */
> +	priv->write_reg(priv, &priv->regs->status, LEC_UNUSED);
> +}
> +
> +static void c_can_start(struct net_device *dev)
> +{
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	/* enable status change, error and module interrupts */
> +	c_can_enable_all_interrupts(priv, ENABLE_ALL_INTERRUPTS);
> +
> +	/* basic c_can configuration */
> +	c_can_chip_config(dev);
> +
> +	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +
> +	/* reset tx helper pointers */
> +	priv->tx_next =3D priv->tx_echo =3D 0;
> +}
> +
> +static void c_can_stop(struct net_device *dev)
> +{
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	/* disable all interrupts */
> +	c_can_enable_all_interrupts(priv, DISABLE_ALL_INTERRUPTS);
> +
> +	/* set the state as STOPPED */
> +	priv->can.state =3D CAN_STATE_STOPPED;
> +}
> +
> +static int c_can_set_mode(struct net_device *dev, enum can_mode mode)
> +{
> +	switch (mode) {
> +	case CAN_MODE_START:
> +		c_can_start(dev);
> +		netif_wake_queue(dev);
> +		break;
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +
> +	return 0;
> +}
> +
> +static int c_can_get_berr_counter(const struct net_device *dev,
> +					struct can_berr_counter *bec)
> +{
> +	unsigned int reg_err_counter;
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	reg_err_counter =3D priv->read_reg(priv, &priv->regs->err_cnt);
> +	bec->rxerr =3D (reg_err_counter & ERR_CNT_REC_MASK) >>
> +				ERR_CNT_REC_SHIFT;
> +	bec->txerr =3D reg_err_counter & ERR_CNT_TEC_MASK;
> +
> +	return 0;
> +}
> +
> +/*
> + * theory of operation:
> + *
> + * priv->tx_echo holds the number of the oldest can_frame put for
> + * transmission into the hardware, but not yet ACKed by the CAN tx
> + * complete IRQ.
> + *
> + * We iterate from priv->tx_echo to priv->tx_next and check if the
> + * packet has been transmitted, echo it back to the CAN framework.
> + * If we discover a not yet transmitted package, stop looking for more=
=2E
> + */
> +static void c_can_do_tx(struct net_device *dev)
> +{
> +	u32 val;
> +	u32 msg_obj_no;
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +	struct net_device_stats *stats =3D &dev->stats;
> +
> +	for (/* nix */; (priv->tx_next - priv->tx_echo) > 0; priv->tx_echo++)=
 {
> +		msg_obj_no =3D get_tx_echo_msg_obj(priv);
> +		c_can_inval_msg_object(dev, 0, msg_obj_no);
> +		val =3D c_can_read_reg32(priv, &priv->regs->txrqst1);
> +		if (!(val & (1 << msg_obj_no))) {
> +			can_get_echo_skb(dev,
> +					msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
> +			stats->tx_bytes +=3D priv->read_reg(priv,
> +					&priv->regs->ifregs[0].msg_cntrl)
> +					& IF_MCONT_DLC_MASK;
> +			stats->tx_packets++;
> +		}
> +	}
> +
> +	/* restart queue if wrap-up or if queue stalled on last pkt */
> +	if (((priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) !=3D 0) ||
> +			((priv->tx_echo & C_CAN_NEXT_MSG_OBJ_MASK) =3D=3D 0))
> +		netif_wake_queue(dev);
> +}
> +
> +/*
> + * theory of operation:
> + *
> + * c_can core saves a received CAN message into the first free message=

> + * object it finds free (starting with the lowest). Bits NEWDAT and
> + * INTPND are set for this message object indicating that a new messag=
e
> + * has arrived. To work-around this issue, we keep two groups of messa=
ge
> + * objects whose partitioning is defined by C_CAN_MSG_OBJ_RX_SPLIT.
> + *
> + * To ensure in-order frame reception we use the following
> + * approach while re-activating a message object to receive further
> + * frames:
> + * - if the current message object number is lower than
> + *   C_CAN_MSG_RX_LOW_LAST, do not clear the NEWDAT bit while clearing=

> + *   the INTPND bit.
> + * - if the current message object number is equal to
> + *   C_CAN_MSG_RX_LOW_LAST then clear the NEWDAT bit of all lower
> + *   receive message objects.
> + * - if the current message object number is greater than
> + *   C_CAN_MSG_RX_LOW_LAST then clear the NEWDAT bit of
> + *   only this message object.
> + */
> +static int c_can_do_rx_poll(struct net_device *dev, int quota)
> +{
> +	u32 num_rx_pkts =3D 0;
> +	unsigned int msg_obj, msg_ctrl_save;
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +	u32 val =3D c_can_read_reg32(priv, &priv->regs->intpnd1);
> +
> +	for (msg_obj =3D C_CAN_MSG_OBJ_RX_FIRST;
> +			msg_obj <=3D C_CAN_MSG_OBJ_RX_LAST && quota > 0;
> +			val =3D c_can_read_reg32(priv, &priv->regs->intpnd1),
> +			msg_obj++) {
> +		/*
> +		 * as interrupt pending register's bit n-1 corresponds to
> +		 * message object n, we need to handle the same properly.
> +		 */
> +		if (val & (1 << (msg_obj - 1))) {
> +			c_can_object_get(dev, 0, msg_obj, IF_COMM_ALL &
> +					~IF_COMM_TXRQST);
> +			msg_ctrl_save =3D priv->read_reg(priv,
> +					&priv->regs->ifregs[0].msg_cntrl);
> +
> +			if (msg_ctrl_save & IF_MCONT_EOB)
> +				return num_rx_pkts;
> +
> +			if (msg_ctrl_save & IF_MCONT_MSGLST) {
> +				c_can_handle_lost_msg_obj(dev, 0, msg_obj);
> +				num_rx_pkts++;
> +				quota--;
> +				continue;
> +			}
> +
> +			if (!(msg_ctrl_save & IF_MCONT_NEWDAT))
> +				continue;
> +
> +			/* read the data from the message object */
> +			c_can_read_msg_object(dev, 0, msg_ctrl_save);
> +
> +			if (msg_obj < C_CAN_MSG_RX_LOW_LAST)
> +				c_can_mark_rx_msg_obj(dev, 0,
> +						msg_ctrl_save, msg_obj);
> +			else if (msg_obj > C_CAN_MSG_RX_LOW_LAST)
> +				/* activate this msg obj */
> +				c_can_activate_rx_msg_obj(dev, 0,
> +						msg_ctrl_save, msg_obj);
> +			else if (msg_obj =3D=3D C_CAN_MSG_RX_LOW_LAST)
> +				/* activate all lower message objects */
> +				c_can_activate_all_lower_rx_msg_obj(dev,
> +						0, msg_ctrl_save);
> +
> +			num_rx_pkts++;
> +			quota--;
> +		}
> +	}
> +
> +	return num_rx_pkts;
> +}
> +
> +static inline int c_can_has_and_handle_berr(struct c_can_priv *priv)
> +{
> +	return (priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING) &&
> +		(priv->current_status & LEC_UNUSED);
> +}
> +
> +static int c_can_handle_state_change(struct net_device *dev,
> +				enum c_can_bus_error_types error_type)
> +{
> +	unsigned int reg_err_counter;
> +	unsigned int rx_err_passive;
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +	struct net_device_stats *stats =3D &dev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	struct can_berr_counter bec;
> +
> +	/* propogate the error condition to the CAN stack */
> +	skb =3D alloc_can_err_skb(dev, &cf);
> +	if (unlikely(!skb))
> +		return 0;
> +
> +	c_can_get_berr_counter(dev, &bec);
> +	reg_err_counter =3D priv->read_reg(priv, &priv->regs->err_cnt);
> +	rx_err_passive =3D (reg_err_counter & ERR_CNT_RP_MASK) >>
> +				ERR_CNT_RP_SHIFT;
> +
> +	switch (error_type) {
> +	case C_CAN_ERROR_WARNING:
> +		/* error warning state */
> +		priv->can.can_stats.error_warning++;
> +		priv->can.state =3D CAN_STATE_ERROR_WARNING;
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		cf->data[1] =3D (bec.txerr > bec.rxerr) ?
> +			CAN_ERR_CRTL_TX_WARNING :
> +			CAN_ERR_CRTL_RX_WARNING;
> +		cf->data[6] =3D bec.txerr;
> +		cf->data[7] =3D bec.rxerr;
> +
> +		break;
> +	case C_CAN_ERROR_PASSIVE:
> +		/* error passive state */
> +		priv->can.can_stats.error_passive++;
> +		priv->can.state =3D CAN_STATE_ERROR_PASSIVE;
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		if (rx_err_passive)
> +			cf->data[1] |=3D CAN_ERR_CRTL_RX_PASSIVE;
> +		if (bec.txerr > 127)
> +			cf->data[1] |=3D CAN_ERR_CRTL_TX_PASSIVE;
> +
> +		cf->data[6] =3D bec.txerr;
> +		cf->data[7] =3D bec.rxerr;
> +		break;
> +	case C_CAN_BUS_OFF:
> +		/* bus-off state */
> +		priv->can.state =3D CAN_STATE_BUS_OFF;
> +		cf->can_id |=3D CAN_ERR_BUSOFF;
> +		/*
> +		 * disable all interrupts in bus-off mode to ensure that
> +		 * the CPU is not hogged down
> +		 */
> +		c_can_enable_all_interrupts(priv, DISABLE_ALL_INTERRUPTS);
> +		can_bus_off(dev);
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	netif_receive_skb(skb);
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->can_dlc;
> +
> +	return 1;
> +}
> +
> +static int c_can_handle_bus_err(struct net_device *dev,
> +				enum c_can_lec_type lec_type)
> +{
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +	struct net_device_stats *stats =3D &dev->stats;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +
> +	/*
> +	 * early exit if no lec update or no error.
> +	 * no lec update means that no CAN bus event has been detected
> +	 * since CPU wrote 0x7 value to status reg.
> +	 */
> +	if (lec_type =3D=3D LEC_UNUSED || lec_type =3D=3D LEC_NO_ERROR)
> +		return 0;
> +
> +	/* propogate the error condition to the CAN stack */
> +	skb =3D alloc_can_err_skb(dev, &cf);
> +	if (unlikely(!skb))
> +		return 0;
> +
> +	/*
> +	 * check for 'last error code' which tells us the
> +	 * type of the last error to occur on the CAN bus
> +	 */
> +
> +	/* common for all type of bus errors */
> +	priv->can.can_stats.bus_error++;
> +	stats->rx_errors++;
> +	cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
> +	cf->data[2] |=3D CAN_ERR_PROT_UNSPEC;
> +
> +	switch (lec_type) {
> +	case LEC_STUFF_ERROR:
> +		netdev_dbg(dev, "stuff error\n");
> +		cf->data[2] |=3D CAN_ERR_PROT_STUFF;
> +		break;
> +	case LEC_FORM_ERROR:
> +		netdev_dbg(dev, "form error\n");
> +		cf->data[2] |=3D CAN_ERR_PROT_FORM;
> +		break;
> +	case LEC_ACK_ERROR:
> +		netdev_dbg(dev, "ack error\n");
> +		cf->data[2] |=3D (CAN_ERR_PROT_LOC_ACK |
> +				CAN_ERR_PROT_LOC_ACK_DEL);
> +		break;
> +	case LEC_BIT1_ERROR:
> +		netdev_dbg(dev, "bit1 error\n");
> +		cf->data[2] |=3D CAN_ERR_PROT_BIT1;
> +		break;
> +	case LEC_BIT0_ERROR:
> +		netdev_dbg(dev, "bit0 error\n");
> +		cf->data[2] |=3D CAN_ERR_PROT_BIT0;
> +		break;
> +	case LEC_CRC_ERROR:
> +		netdev_dbg(dev, "CRC error\n");
> +		cf->data[2] |=3D (CAN_ERR_PROT_LOC_CRC_SEQ |
> +				CAN_ERR_PROT_LOC_CRC_DEL);
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	/* set a `lec` value so that we can check for updates later */
> +	priv->write_reg(priv, &priv->regs->status, LEC_UNUSED);
> +
> +	netif_receive_skb(skb);
> +	stats->rx_packets++;
> +	stats->rx_bytes +=3D cf->can_dlc;
> +
> +	return 1;
> +}
> +
> +static int c_can_poll(struct napi_struct *napi, int quota)
> +{
> +	u16 irqstatus;
> +	int lec_type =3D 0;
> +	int work_done =3D 0;
> +	struct net_device *dev =3D napi->dev;
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	irqstatus =3D priv->read_reg(priv, &priv->regs->interrupt);
> +	if (!irqstatus)
> +		goto end;
> +
> +	/* status events have the highest priority */
> +	if (irqstatus =3D=3D STATUS_INTERRUPT) {
> +		priv->current_status =3D priv->read_reg(priv,
> +					&priv->regs->status);
> +
> +		/* handle Tx/Rx events */
> +		if (priv->current_status & STATUS_TXOK)
> +			priv->write_reg(priv, &priv->regs->status,
> +					priv->current_status & ~STATUS_TXOK);
> +
> +		if (priv->current_status & STATUS_RXOK)
> +			priv->write_reg(priv, &priv->regs->status,
> +					priv->current_status & ~STATUS_RXOK);
> +
> +		/* handle state changes */
> +		if ((priv->current_status & STATUS_EWARN) &&
> +				(!(priv->last_status & STATUS_EWARN))) {
> +			netdev_dbg(dev, "entered error warning state\n");
> +			work_done +=3D c_can_handle_state_change(dev,
> +						C_CAN_ERROR_WARNING);
> +		}
> +		if ((priv->current_status & STATUS_EPASS) &&
> +				(!(priv->last_status & STATUS_EPASS))) {
> +			netdev_dbg(dev, "entered error passive state\n");
> +			work_done +=3D c_can_handle_state_change(dev,
> +						C_CAN_ERROR_PASSIVE);
> +		}
> +		if ((priv->current_status & STATUS_BOFF) &&
> +				(!(priv->last_status & STATUS_BOFF))) {
> +			netdev_dbg(dev, "entered bus off state\n");
> +			work_done +=3D c_can_handle_state_change(dev,
> +						C_CAN_BUS_OFF);
> +		}
> +
> +		/* handle bus recovery events */
> +		if ((!(priv->current_status & STATUS_BOFF)) &&
> +				(priv->last_status & STATUS_BOFF)) {
> +			netdev_dbg(dev, "left bus off state\n");
> +			priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +		}
> +		if ((!(priv->current_status & STATUS_EPASS)) &&
> +				(priv->last_status & STATUS_EPASS)) {
> +			netdev_dbg(dev, "left error passive state\n");
> +			priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +		}
> +
> +		priv->last_status =3D priv->current_status;
> +
> +		/* handle lec errors on the bus */
> +		lec_type =3D c_can_has_and_handle_berr(priv);
> +		if (lec_type)
> +			work_done +=3D c_can_handle_bus_err(dev, lec_type);
> +	} else if ((irqstatus >=3D C_CAN_MSG_OBJ_RX_FIRST) &&
> +			(irqstatus <=3D C_CAN_MSG_OBJ_RX_LAST)) {
> +		/* handle events corresponding to receive message objects */
> +		work_done +=3D c_can_do_rx_poll(dev, (quota - work_done));
> +	} else if ((irqstatus >=3D C_CAN_MSG_OBJ_TX_FIRST) &&
> +			(irqstatus <=3D C_CAN_MSG_OBJ_TX_LAST)) {
> +		/* handle events corresponding to transmit message objects */
> +		c_can_do_tx(dev);
> +	}
> +
> +end:
> +	if (work_done < quota) {
> +		napi_complete(napi);
> +		/* enable all IRQs */
> +		c_can_enable_all_interrupts(priv, ENABLE_ALL_INTERRUPTS);
> +	}
> +
> +	return work_done;
> +}
> +
> +static irqreturn_t c_can_isr(int irq, void *dev_id)
> +{
> +	u16 irqstatus;
> +	struct net_device *dev =3D (struct net_device *)dev_id;
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	irqstatus =3D priv->read_reg(priv, &priv->regs->interrupt);
> +	if (!irqstatus)
> +		return IRQ_NONE;
> +
> +	/* disable all interrupts and schedule the NAPI */
> +	c_can_enable_all_interrupts(priv, DISABLE_ALL_INTERRUPTS);
> +	napi_schedule(&priv->napi);
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static int c_can_open(struct net_device *dev)
> +{
> +	int err;
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	/* open the can device */
> +	err =3D open_candev(dev);
> +	if (err) {
> +		netdev_err(dev, "failed to open can device\n");
> +		return err;
> +	}
> +
> +	/* register interrupt handler */
> +	err =3D request_irq(dev->irq, &c_can_isr, IRQF_SHARED, dev->name,
> +				dev);
> +	if (err < 0) {
> +		netdev_err(dev, "failed to request interrupt\n");
> +		goto exit_irq_fail;
> +	}
> +
> +	/* start the c_can controller */
> +	c_can_start(dev);
> +
> +	napi_enable(&priv->napi);
> +	netif_start_queue(dev);
> +
> +	return 0;
> +
> +exit_irq_fail:
> +	close_candev(dev);
> +	return err;
> +}
> +
> +static int c_can_close(struct net_device *dev)
> +{
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	netif_stop_queue(dev);
> +	napi_disable(&priv->napi);
> +	c_can_stop(dev);
> +	free_irq(dev->irq, dev);
> +	close_candev(dev);
> +
> +	return 0;
> +}
> +
> +struct net_device *alloc_c_can_dev(void)
> +{
> +	struct net_device *dev;
> +	struct c_can_priv *priv;
> +
> +	dev =3D alloc_candev(sizeof(struct c_can_priv), C_CAN_MSG_OBJ_TX_NUM)=
;
> +	if (!dev)
> +		return NULL;
> +
> +	priv =3D netdev_priv(dev);
> +	netif_napi_add(dev, &priv->napi, c_can_poll, C_CAN_NAPI_WEIGHT);
> +
> +	priv->dev =3D dev;
> +	priv->can.bittiming_const =3D &c_can_bittiming_const;
> +	priv->can.do_set_bittiming =3D c_can_set_bittiming;

Please move the set_bittiming to the _open() or the _start() function.
See b156fd0483c8f18b3cc544d9c400fe454458e16a. So we can get rid of the
can.do_set_bittiming sooner or later.

> +	priv->can.do_set_mode =3D c_can_set_mode;
> +	priv->can.do_get_berr_counter =3D c_can_get_berr_counter;
> +	priv->can.ctrlmode_supported =3D CAN_CTRLMODE_ONE_SHOT |
> +					CAN_CTRLMODE_LOOPBACK |
> +					CAN_CTRLMODE_LISTENONLY |
> +					CAN_CTRLMODE_BERR_REPORTING;
> +
> +	return dev;
> +}
> +EXPORT_SYMBOL_GPL(alloc_c_can_dev);
> +
> +void free_c_can_dev(struct net_device *dev)
> +{
> +	free_candev(dev);
> +}
> +EXPORT_SYMBOL_GPL(free_c_can_dev);
> +
> +static const struct net_device_ops c_can_netdev_ops =3D {
> +	.ndo_open =3D c_can_open,
> +	.ndo_stop =3D c_can_close,
> +	.ndo_start_xmit =3D c_can_start_xmit,
> +};
> +
> +int register_c_can_dev(struct net_device *dev)
> +{
> +	dev->flags |=3D IFF_ECHO;	/* we support local echo */
> +	dev->netdev_ops =3D &c_can_netdev_ops;
> +
> +	return register_candev(dev);
> +}
> +EXPORT_SYMBOL_GPL(register_c_can_dev);
> +
> +void unregister_c_can_dev(struct net_device *dev)
> +{
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	/* disable all interrupts */
> +	c_can_enable_all_interrupts(priv, DISABLE_ALL_INTERRUPTS);
> +
> +	unregister_candev(dev);
> +}
> +EXPORT_SYMBOL_GPL(unregister_c_can_dev);
> +
> +MODULE_AUTHOR("Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>");
> +MODULE_LICENSE("GPL v2");
> +MODULE_DESCRIPTION("CAN bus driver for Bosch C_CAN controller");
> diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_ca=
n.h
> new file mode 100644
> index 0000000..bd094e6
> --- /dev/null
> +++ b/drivers/net/can/c_can/c_can.h
> @@ -0,0 +1,230 @@
> +/*
> + * CAN bus driver for Bosch C_CAN controller
> + *
> + * Copyright (C) 2010 ST Microelectronics
> + * Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
> + *
> + * Borrowed heavily from the C_CAN driver originally written by:
> + * Copyright (C) 2007
> + * - Sascha Hauer, Marc Kleine-Budde, Pengutronix <s.hauer@pengutronix=
=2Ede>
> + * - Simon Kallweit, intefo AG <simon.kallweit-+G9qxTFKJT/tRgLqZ5aouw@public.gmane.org>
> + *
> + * Bosch C_CAN controller is compliant to CAN protocol version 2.0 par=
t A and B.
> + * Bosch C_CAN user manual can be obtained from:
> + * http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/c_can/
> + * users_manual_c_can.pdf
> + *
> + * This file is licensed under the terms of the GNU General Public
> + * License version 2. This program is licensed "as is" without any
> + * warranty of any kind, whether express or implied.
> + */
> +
> +#ifndef C_CAN_H
> +#define C_CAN_H
> +
> +/* control register */
> +#define CONTROL_TEST		BIT(7)
> +#define CONTROL_CCE		BIT(6)
> +#define CONTROL_DISABLE_AR	BIT(5)
> +#define CONTROL_ENABLE_AR	(0 << 5)
> +#define CONTROL_EIE		BIT(3)
> +#define CONTROL_SIE		BIT(2)
> +#define CONTROL_IE		BIT(1)
> +#define CONTROL_INIT		BIT(0)
> +
> +/* test register */
> +#define TEST_RX			BIT(7)
> +#define TEST_TX1		BIT(6)
> +#define TEST_TX2		BIT(5)
> +#define TEST_LBACK		BIT(4)
> +#define TEST_SILENT		BIT(3)
> +#define TEST_BASIC		BIT(2)
> +
> +/* status register */
> +#define STATUS_BOFF		BIT(7)
> +#define STATUS_EWARN		BIT(6)
> +#define STATUS_EPASS		BIT(5)
> +#define STATUS_RXOK		BIT(4)
> +#define STATUS_TXOK		BIT(3)
> +
> +/* error counter register */
> +#define ERR_CNT_TEC_MASK	0xff
> +#define ERR_CNT_TEC_SHIFT	0
> +#define ERR_CNT_REC_SHIFT	8
> +#define ERR_CNT_REC_MASK	(0x7f << ERR_CNT_REC_SHIFT)
> +#define ERR_CNT_RP_SHIFT	15
> +#define ERR_CNT_RP_MASK		(0x1 << ERR_CNT_RP_SHIFT)
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
> +#define IF_COMR_BUSY		BIT(15)
> +
> +/* IFx command mask */
> +#define IF_COMM_WR		BIT(7)
> +#define IF_COMM_MASK		BIT(6)
> +#define IF_COMM_ARB		BIT(5)
> +#define IF_COMM_CONTROL		BIT(4)
> +#define IF_COMM_CLR_INT_PND	BIT(3)
> +#define IF_COMM_TXRQST		BIT(2)
> +#define IF_COMM_DATAA		BIT(1)
> +#define IF_COMM_DATAB		BIT(0)
> +#define IF_COMM_ALL		(IF_COMM_MASK | IF_COMM_ARB | \
> +				IF_COMM_CONTROL | IF_COMM_TXRQST | \
> +				IF_COMM_DATAA | IF_COMM_DATAB)
> +
> +/* IFx arbitration */
> +#define IF_ARB_MSGVAL		BIT(15)
> +#define IF_ARB_MSGXTD		BIT(14)
> +#define IF_ARB_TRANSMIT		BIT(13)
> +
> +/* IFx message control */
> +#define IF_MCONT_NEWDAT		BIT(15)
> +#define IF_MCONT_MSGLST		BIT(14)
> +#define IF_MCONT_CLR_MSGLST	(0 << 14)
> +#define IF_MCONT_INTPND		BIT(13)
> +#define IF_MCONT_UMASK		BIT(12)
> +#define IF_MCONT_TXIE		BIT(11)
> +#define IF_MCONT_RXIE		BIT(10)
> +#define IF_MCONT_RMTEN		BIT(9)
> +#define IF_MCONT_TXRQST		BIT(8)
> +#define IF_MCONT_EOB		BIT(7)
> +#define IF_MCONT_DLC_MASK	0xf
> +
> +/*
> + * IFx register masks:
> + * allow easy operation on 16-bit registers when the
> + * argument is 32-bit instead
> + */
> +#define IFX_WRITE_LOW_16BIT(x)	((x) & 0xFFFF)
> +#define IFX_WRITE_HIGH_16BIT(x)	(((x) & 0xFFFF0000) >> 16)
> +
> +/* message object split */
> +#define C_CAN_NO_OF_OBJECTS	32
> +#define C_CAN_MSG_OBJ_RX_NUM	16
> +#define C_CAN_MSG_OBJ_TX_NUM	16
> +
> +#define C_CAN_MSG_OBJ_RX_FIRST	1
> +#define C_CAN_MSG_OBJ_RX_LAST	(C_CAN_MSG_OBJ_RX_FIRST + \
> +				C_CAN_MSG_OBJ_RX_NUM - 1)
> +
> +#define C_CAN_MSG_OBJ_TX_FIRST	(C_CAN_MSG_OBJ_RX_LAST + 1)
> +#define C_CAN_MSG_OBJ_TX_LAST	(C_CAN_MSG_OBJ_TX_FIRST + \
> +				C_CAN_MSG_OBJ_TX_NUM - 1)
> +
> +#define C_CAN_MSG_OBJ_RX_SPLIT	9
> +#define C_CAN_MSG_RX_LOW_LAST	(C_CAN_MSG_OBJ_RX_SPLIT - 1)
> +
> +#define C_CAN_NEXT_MSG_OBJ_MASK	(C_CAN_MSG_OBJ_TX_NUM - 1)
> +#define RECEIVE_OBJECT_BITS	0x0000ffff
> +
> +/* status interrupt */
> +#define STATUS_INTERRUPT	0x8000
> +
> +/* global interrupt masks */
> +#define ENABLE_ALL_INTERRUPTS	1
> +#define DISABLE_ALL_INTERRUPTS	0
> +
> +/* minimum timeout for checking BUSY status */
> +#define MIN_TIMEOUT_VALUE	6
> +
> +/* napi related */
> +#define C_CAN_NAPI_WEIGHT	C_CAN_MSG_OBJ_RX_NUM
> +
> +/* c_can IF registers */
> +struct c_can_if_regs {
> +	u16 com_req;
> +	u16 com_mask;
> +	u16 mask1;
> +	u16 mask2;
> +	u16 arb1;
> +	u16 arb2;
> +	u16 msg_cntrl;
> +	u16 data[4];
> +	u16 _reserved[13];
> +};
> +
> +/* c_can hardware registers */
> +struct c_can_regs {
> +	u16 control;
> +	u16 status;
> +	u16 err_cnt;
> +	u16 btr;
> +	u16 interrupt;
> +	u16 test;
> +	u16 brp_ext;
> +	u16 _reserved1;
> +	struct c_can_if_regs ifregs[2]; /* [0] =3D IF1 and [1] =3D IF2 */
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
> +
> +/* c_can lec values */
> +enum c_can_lec_type {
> +	LEC_NO_ERROR =3D 0,
> +	LEC_STUFF_ERROR,
> +	LEC_FORM_ERROR,
> +	LEC_ACK_ERROR,
> +	LEC_BIT1_ERROR,
> +	LEC_BIT0_ERROR,
> +	LEC_CRC_ERROR,
> +	LEC_UNUSED,
> +};
> +
> +/*
> + * c_can error types:
> + * Bus errors (BUS_OFF, ERROR_WARNING, ERROR_PASSIVE) are supported
> + */
> +enum c_can_bus_error_types {
> +	C_CAN_NO_ERROR =3D 0,
> +	C_CAN_BUS_OFF,
> +	C_CAN_ERROR_WARNING,
> +	C_CAN_ERROR_PASSIVE,
> +};

nitpick: are the defines, enums and structs needed in more than one c
file? If not, please move them into the c-file where they are used.

> +
> +/* c_can private data structure */
> +struct c_can_priv {
> +	struct can_priv can;	/* must be the first member */
> +	struct napi_struct napi;
> +	struct net_device *dev;
> +	int tx_object;
> +	int current_status;
> +	int last_status;
> +	u16 (*read_reg) (struct c_can_priv *priv, void *reg);
> +	void (*write_reg) (struct c_can_priv *priv, void *reg, u16 val);
> +	struct c_can_regs __iomem *regs;
> +	unsigned long irq_flags; /* for request_irq() */
> +	unsigned int tx_next;
> +	unsigned int tx_echo;
> +	void *priv;		/* for board-specific data */
> +};
> +
> +struct net_device *alloc_c_can_dev(void);
> +void free_c_can_dev(struct net_device *dev);
> +int register_c_can_dev(struct net_device *dev);
> +void unregister_c_can_dev(struct net_device *dev);
> +
> +#endif /* C_CAN_H */
> diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c=
_can/c_can_platform.c
> new file mode 100644
> index 0000000..0fc314e
> --- /dev/null
> +++ b/drivers/net/can/c_can/c_can_platform.c
> @@ -0,0 +1,207 @@
> +/*
> + * Platform CAN bus driver for Bosch C_CAN controller
> + *
> + * Copyright (C) 2010 ST Microelectronics
> + * Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
> + *
> + * Borrowed heavily from the C_CAN driver originally written by:
> + * Copyright (C) 2007
> + * - Sascha Hauer, Marc Kleine-Budde, Pengutronix <s.hauer@pengutronix=
=2Ede>
> + * - Simon Kallweit, intefo AG <simon.kallweit-+G9qxTFKJT/tRgLqZ5aouw@public.gmane.org>
> + *
> + * Bosch C_CAN controller is compliant to CAN protocol version 2.0 par=
t A and B.
> + * Bosch C_CAN user manual can be obtained from:
> + * http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/c_can/
> + * users_manual_c_can.pdf
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
> +#include <linux/io.h>
> +#include <linux/platform_device.h>
> +#include <linux/clk.h>
> +
> +#include <linux/can/dev.h>
> +
> +#include "c_can.h"
> +
> +/*
> + * 16-bit c_can registers can be arranged differently in the memory
> + * architecture of different implementations. For example: 16-bit
> + * registers can be aligned to a 16-bit boundary or 32-bit boundary et=
c.
> + * Handle the same by providing a common read/write interface.
> + */
> +static u16 c_can_plat_read_reg_aligned_to_16bit(struct c_can_priv *pri=
v,
> +						void *reg)
> +{
> +	return readw(reg);
> +}
> +
> +static void c_can_plat_write_reg_aligned_to_16bit(struct c_can_priv *p=
riv,
> +						void *reg, u16 val)
> +{
> +	writew(val, reg);
> +}
> +
> +static u16 c_can_plat_read_reg_aligned_to_32bit(struct c_can_priv *pri=
v,
> +						void *reg)
> +{
> +	return readw(reg + (long)reg - (long)priv->regs);
> +}
> +
> +static void c_can_plat_write_reg_aligned_to_32bit(struct c_can_priv *p=
riv,
> +						void *reg, u16 val)
> +{
> +	writew(val, reg + (long)reg - (long)priv->regs);
> +}
> +
> +static int __devinit c_can_plat_probe(struct platform_device *pdev)
> +{
> +	int ret;
> +	void __iomem *addr;
> +	struct net_device *dev;
> +	struct c_can_priv *priv;
> +	struct resource *mem, *irq;
> +	struct clk *clk;
> +
> +	/* get the appropriate clk */
> +	clk =3D clk_get(&pdev->dev, NULL);
> +	if (IS_ERR(clk)) {
> +		dev_err(&pdev->dev, "no clock defined\n");
> +		ret =3D -ENODEV;
> +		goto exit;
> +	}
> +
> +	/* get the platform data */
> +	mem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	irq =3D platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> +	if (!mem || (irq <=3D 0)) {
> +		ret =3D -ENODEV;
> +		goto exit_free_clk;
> +	}
> +
> +	if (!request_mem_region(mem->start, resource_size(mem),
> +				KBUILD_MODNAME)) {
> +		dev_err(&pdev->dev, "resource unavailable\n");
> +		ret =3D -ENODEV;
> +		goto exit_free_clk;
> +	}
> +
> +	addr =3D ioremap(mem->start, resource_size(mem));
> +	if (!addr) {
> +		dev_err(&pdev->dev, "failed to map can port\n");
> +		ret =3D -ENOMEM;
> +		goto exit_release_mem;
> +	}
> +
> +	/* allocate the c_can device */
> +	dev =3D alloc_c_can_dev();
> +	if (!dev) {
> +		ret =3D -ENOMEM;
> +		goto exit_iounmap;
> +	}
> +
> +	priv =3D netdev_priv(dev);
> +
> +	dev->irq =3D irq->start;
> +	priv->regs =3D addr;
> +	priv->can.clock.freq =3D clk_get_rate(clk);
> +	priv->priv =3D clk;
> +
> +	switch (mem->flags & IORESOURCE_MEM_TYPE_MASK) {
> +	case IORESOURCE_MEM_32BIT:
> +		priv->read_reg =3D c_can_plat_read_reg_aligned_to_32bit;
> +		priv->write_reg =3D c_can_plat_write_reg_aligned_to_32bit;
> +		break;
> +	case IORESOURCE_MEM_16BIT:
> +	default:
> +		priv->read_reg =3D c_can_plat_read_reg_aligned_to_16bit;
> +		priv->write_reg =3D c_can_plat_write_reg_aligned_to_16bit;
> +		break;
> +	}
> +
> +	platform_set_drvdata(pdev, dev);
> +	SET_NETDEV_DEV(dev, &pdev->dev);
> +
> +	ret =3D register_c_can_dev(dev);
> +	if (ret) {
> +		dev_err(&pdev->dev, "registering %s failed (err=3D%d)\n",
> +			KBUILD_MODNAME, ret);
> +		goto exit_free_device;
> +	}
> +
> +	dev_info(&pdev->dev, "%s device registered (regs=3D%p, irq=3D%d)\n",
> +		 KBUILD_MODNAME, priv->regs, dev->irq);
> +	return 0;
> +
> +exit_free_device:
> +	platform_set_drvdata(pdev, NULL);
> +	free_c_can_dev(dev);
> +exit_iounmap:
> +	iounmap(addr);
> +exit_release_mem:
> +	release_mem_region(mem->start, resource_size(mem));
> +exit_free_clk:
> +	clk_put(clk);
> +exit:
> +	dev_err(&pdev->dev, "probe failed\n");
> +
> +	return ret;
> +}
> +
> +static int __devexit c_can_plat_remove(struct platform_device *pdev)
> +{
> +	struct net_device *dev =3D platform_get_drvdata(pdev);
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +	struct resource *mem;
> +
> +	unregister_c_can_dev(dev);
> +	platform_set_drvdata(pdev, NULL);
> +
> +	free_c_can_dev(dev);
> +	iounmap(priv->regs);
> +
> +	mem =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	release_mem_region(mem->start, resource_size(mem));
> +
> +	clk_put(priv->priv);
> +
> +	return 0;
> +}
> +
> +static struct platform_driver c_can_plat_driver =3D {
> +	.driver =3D {
> +		.name =3D KBUILD_MODNAME,
> +		.owner =3D THIS_MODULE,
> +	},
> +	.probe =3D c_can_plat_probe,
> +	.remove =3D __devexit_p(c_can_plat_remove),
> +};
> +
> +static int __init c_can_plat_init(void)
> +{
> +	return platform_driver_register(&c_can_plat_driver);
> +}
> +module_init(c_can_plat_init);
> +
> +static void __exit c_can_plat_exit(void)
> +{
> +	platform_driver_unregister(&c_can_plat_driver);
> +}
> +module_exit(c_can_plat_exit);
> +
> +MODULE_AUTHOR("Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>");
> +MODULE_LICENSE("GPL v2");
> +MODULE_DESCRIPTION("Platform CAN bus driver for Bosch C_CAN controller=
");

regards, Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig945A6BD8661FDFB5081B9902
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk1SXfwACgkQjTAFq1RaXHPBoACeMJ1f+JIB+yt1gLP6sV/bdi0m
580AoIYNu8PcZaDwczvNUgPbPH+TyVr1
=hjTU
-----END PGP SIGNATURE-----

--------------enig945A6BD8661FDFB5081B9902--

--===============4878447109728268983==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Socketcan-core mailing list
Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
https://lists.berlios.de/mailman/listinfo/socketcan-core

--===============4878447109728268983==--
