From: Bhupesh SHARMA <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Subject: RE: [PATCH net-next-2.6 v3 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Tue, 11 Jan 2011 12:50:07 +0800
Message-ID: <D5ECB3C7A6F99444980976A8C6D896384DEAFA2D9D@EAPEX1MAIL1.st.com>
References: <1294135195-9448-1-git-send-email-bhupesh.sharma@st.com>
	<4D2829C5.5020206@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D2829C5.5020206-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Content-Language: en-US
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

Hi Wolfgang,

Thanks for your review.
Please see my comments inline.

> -----Original Message-----
> From: Wolfgang Grandegger [mailto:wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org]
> Hi Bhupesh,
>
> the patch already looks quite good. Just a few more issues...
>
> On 01/04/2011 10:59 AM, Bhupesh Sharma wrote:
> > Bosch C_CAN controller is a full-CAN implementation which is
> compliant
> > to CAN protocol version 2.0 part A and B. Bosch C_CAN user manual can
> be
> > obtained from:
> > http://www.semiconductors.bosch.de/pdf/Users_Manual_C_CAN.pdf
> >
> > This patch adds the support for this controller.
> > The following are the design choices made while writing the
> controller
> > driver:
> > 1. Interface Register set IF1 has be used only in the current design.
> > 2. Out of the 32 Message objects available, 16 are kept aside for RX
> >    purposes and the rest for TX purposes.
> > 3. NAPI implementation is such that both the TX and RX paths function
> >    in polling mode.
> >
> > Changes since V2:
> > 1. Seperately implemented a bus independent interface "c_can.c" and
> >    a bus sensitive driver "c_can_platform.c". The bus sensitive
> driver
> >    essentially caters to the details of registers mapping/arch
> differences
> >    found on different SoCs.
> > 2. Changed RX poll method to allow *in-order packet reception*.
> > 3. Implemeneted LEC (last error code) as an enum.
> > 4. Implemented CAN_CTRLMODE_BERR_REPORTING.
> > 5. Corrected "quota" handling in RX poll routine.
> > 6. Implemented and used priv->can.do_get_berr_counter.
> > 7. Improved timeout-handling while programming IF command request
> >    register.
> > 8. Corrected register offset typecasting to allow the same to work on
> >    64-bit systems.
> >
> > Signed-off-by: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
> > ---
> >  drivers/net/can/Kconfig                |    2 +
> >  drivers/net/can/Makefile               |    1 +
> >  drivers/net/can/c_can/Kconfig          |   15 +
> >  drivers/net/can/c_can/Makefile         |    8 +
> >  drivers/net/can/c_can/c_can.c          |  960
> ++++++++++++++++++++++++++++++++
> >  drivers/net/can/c_can/c_can.h          |  235 ++++++++
> >  drivers/net/can/c_can/c_can_platform.c |  210 +++++++
> >  7 files changed, 1431 insertions(+), 0 deletions(-)
> >  create mode 100644 drivers/net/can/c_can/Kconfig
> >  create mode 100644 drivers/net/can/c_can/Makefile
> >  create mode 100644 drivers/net/can/c_can/c_can.c
> >  create mode 100644 drivers/net/can/c_can/c_can.h
> >  create mode 100644 drivers/net/can/c_can/c_can_platform.c
> >
> > diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> > index 9d9e453..50549b5 100644
> > --- a/drivers/net/can/Kconfig
> > +++ b/drivers/net/can/Kconfig
> > @@ -86,6 +86,8 @@ source "drivers/net/can/mscan/Kconfig"
> >
> >  source "drivers/net/can/sja1000/Kconfig"
> >
> > +source "drivers/net/can/c_can/Kconfig"
> > +
> >  source "drivers/net/can/usb/Kconfig"
> >
> >  config CAN_DEBUG_DEVICES
> > diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> > index 0057537..c3efeb3 100644
> > --- a/drivers/net/can/Makefile
> > +++ b/drivers/net/can/Makefile
> > @@ -11,6 +11,7 @@ obj-y                             += usb/
> >
> >  obj-$(CONFIG_CAN_SJA1000)  += sja1000/
> >  obj-$(CONFIG_CAN_MSCAN)            += mscan/
> > +obj-$(CONFIG_CAN_C_CAN)            += c_can/
> >  obj-$(CONFIG_CAN_AT91)             += at91_can.o
> >  obj-$(CONFIG_CAN_TI_HECC)  += ti_hecc.o
> >  obj-$(CONFIG_CAN_MCP251X)  += mcp251x.o
> > diff --git a/drivers/net/can/c_can/Kconfig
> b/drivers/net/can/c_can/Kconfig
> > new file mode 100644
> > index 0000000..ffb9773
> > --- /dev/null
> > +++ b/drivers/net/can/c_can/Kconfig
> > @@ -0,0 +1,15 @@
> > +menuconfig CAN_C_CAN
> > +   tristate "Bosch C_CAN devices"
> > +   depends on CAN_DEV && HAS_IOMEM
> > +
> > +if CAN_C_CAN
> > +
> > +config CAN_C_CAN_PLATFORM
> > +   tristate "Generic Platform Bus based C_CAN driver"
> > +   ---help---
> > +     This driver adds support for the C_CAN chips connected to
> > +     the "platform bus" (Linux abstraction for directly to the
> > +     processor attached devices) which can be found on various
> > +     boards from ST Microelectronics (http://www.st.com)
> > +     like the SPEAr1310 and SPEAr320 evaluation boards.
> > +endif
>
> > diff --git a/drivers/net/can/c_can/Makefile
> b/drivers/net/can/c_can/Makefile
> > new file mode 100644
> > index 0000000..9273f6d
> > --- /dev/null
> > +++ b/drivers/net/can/c_can/Makefile
> > @@ -0,0 +1,8 @@
> > +#
> > +#  Makefile for the Bosch C_CAN controller drivers.
> > +#
> > +
> > +obj-$(CONFIG_CAN_C_CAN) += c_can.o
> > +obj-$(CONFIG_CAN_C_CAN_PLATFORM) += c_can_platform.o
> > +
> > +ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
> > diff --git a/drivers/net/can/c_can/c_can.c
> b/drivers/net/can/c_can/c_can.c
> > new file mode 100644
> > index 0000000..206e650
> > --- /dev/null
> > +++ b/drivers/net/can/c_can/c_can.c
> > @@ -0,0 +1,960 @@
> > +/*
> > + * CAN bus driver for Bosch C_CAN controller
> > + *
> > + * Copyright (C) 2010 ST Microelectronics
> > + * Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
> > + *
> > + * Borrowed heavily from the C_CAN driver originally written by:
> > + * Copyright (C) 2007
> > + * - Sascha Hauer, Marc Kleine-Budde, Pengutronix
> <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> > + * - Simon Kallweit, intefo AG <simon.kallweit-+G9qxTFKJT/tRgLqZ5aouw@public.gmane.org>
> > + *
> > + * TX and RX NAPI implementation has been borrowed from at91 CAN
> driver
> > + * written by:
> > + * Copyright
> > + * (C) 2007 by Hans J. Koch <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> > + * (C) 2008, 2009 by Marc Kleine-Budde <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> > + *
> > + * Bosch C_CAN controller is compliant to CAN protocol version 2.0
> part A and B.
> > + * Bosch C_CAN user manual can be obtained from:
> > + * http://www.semiconductors.bosch.de/pdf/Users_Manual_C_CAN.pdf
>
> Unfortunately, this link is not valid any more.

Oops..
It seems they have shifted to:
http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/c_can/users_manual_c_can.pdf

> > + *
> > + * This file is licensed under the terms of the GNU General Public
> > + * License version 2. This program is licensed "as is" without any
> > + * warranty of any kind, whether express or implied.
> > + */
> > +
> > +#include <linux/kernel.h>
> > +#include <linux/version.h>
> > +#include <linux/module.h>
> > +#include <linux/interrupt.h>
> > +#include <linux/delay.h>
> > +#include <linux/netdevice.h>
> > +#include <linux/if_arp.h>
> > +#include <linux/if_ether.h>
> > +#include <linux/list.h>
> > +#include <linux/delay.h>
> > +#include <linux/workqueue.h>
>
> Do you need that include?

I will check if this is really required.
Workqueues are no more there..
So, I will try to remove this in V4

> > +#include <linux/io.h>
> > +#include <linux/platform_device.h>
> > +#include <linux/clk.h>
>
> ...and the upper two? They are related to platform code.

Ditto.

> > +#include <linux/can.h>
> > +#include <linux/can/dev.h>
> > +#include <linux/can/error.h>
> > +
> > +#include "c_can.h"
> > +
> > +static struct can_bittiming_const c_can_bittiming_const = {
> > +   .name = KBUILD_MODNAME,
> > +   .tseg1_min = 2,         /* Time segment 1 = prop_seg + phase_seg1
> */
> > +   .tseg1_max = 16,
> > +   .tseg2_min = 1,         /* Time segment 2 = phase_seg2 */
> > +   .tseg2_max = 8,
> > +   .sjw_max = 4,
> > +   .brp_min = 1,
> > +   .brp_max = 1024,        /* 6-bit BRP field + 4-bit BRPE field*/
> > +   .brp_inc = 1,
> > +};
> > +
> > +static inline int get_tx_next_msg_obj(const struct c_can_priv *priv)
> > +{
> > +   return (priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) +
> > +                   C_CAN_MSG_OBJ_TX_FIRST;
> > +}
> > +
> > +static inline int get_tx_echo_msg_obj(const struct c_can_priv *priv)
> > +{
> > +   return (priv->tx_echo & C_CAN_NEXT_MSG_OBJ_MASK) +
> > +                   C_CAN_MSG_OBJ_TX_FIRST;
> > +}
> > +
> > +static u32 c_can_read_reg32(struct c_can_priv *priv, void *reg)
> > +{
> > +   u32 val = priv->read_reg(priv, reg);
> > +   val |= ((u32) priv->read_reg(priv, reg + 2)) << 16;
> > +   return val;
> > +}
> > +
> > +void c_can_enable_all_interrupts(struct c_can_priv *priv,
> > +                                           int enable)
> > +{
> > +   unsigned int cntrl_save = priv->read_reg(priv,
> > +                                           &priv->reg_base->control);
> > +
> > +   if (enable)
> > +           cntrl_save |= (CONTROL_SIE | CONTROL_EIE | CONTROL_IE);
> > +   else
> > +           cntrl_save &= ~(CONTROL_EIE | CONTROL_IE | CONTROL_SIE);
> > +
> > +   priv->write_reg(priv, &priv->reg_base->control, cntrl_save);
> > +}
> > +EXPORT_SYMBOL_GPL(c_can_enable_all_interrupts);
>
> Do you really need to export that function? More later.

Yes. The c_can_platform driver uses this routine to DISABLE
all interrupt sources when __devexit c_can_remove is called.

> > +
> > +static inline void c_can_object_get(struct net_device *dev,
> > +                                   int iface, int objno, int mask)
> > +{
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +   int count = MIN_TIMEOUT_VALUE;
> > +
> > +   /*
> > +    * As per specs, after writting the message object number in the
> > +    * IF command request register the transfer b/w interface
> > +    * register and message RAM must be complete in 6 CAN-CLK
> > +    * period.
> > +    */
> > +
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[iface].com_mask,
> > +                   IFX_WRITE_LOW_16BIT(mask));
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[iface].com_reg,
> > +                   IFX_WRITE_LOW_16BIT(objno + 1));
> > +
> > +   while (count) {
> > +           if (!(priv->read_reg(priv,
> > +                                   &priv->reg_base->ifreg[iface].com_reg) &
> > +                                   IF_COMR_BUSY))
> > +                   break;
>
> Could be shortened to:
>
>       while (count && priv->read_reg(priv,
>                               &priv->reg_base->ifreg[iface].com_reg) &
>                               IF_COMR_BUSY)
>

Ok. V4 will reflect this.

> > +           count--;
> > +           udelay(1);
> > +   }
> > +
> > +   if (!count)
> > +           dev_err(dev->dev.parent, "timed out in object get\n");
> > +}
> > +
> > +static inline void c_can_object_put(struct net_device *dev,
> > +                                   int iface, int objno, int mask)
> > +{
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +   int count = MIN_TIMEOUT_VALUE;
> > +
> > +   /*
> > +    * As per specs, after writting the message object number in the
> > +    * IF command request register the transfer b/w interface
> > +    * register and message RAM must be complete in 6 CAN-CLK
> > +    * period.
> > +    */
> > +
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[iface].com_mask,
> > +                   (IF_COMM_WR | IFX_WRITE_LOW_16BIT(mask)));
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[iface].com_reg,
> > +                   IFX_WRITE_LOW_16BIT(objno + 1));
> > +
> > +   while (count) {
> > +           if (!(priv->read_reg(priv,
> > +                           &priv->reg_base->ifreg[iface].com_reg) &
> > +                           IF_COMR_BUSY))
> > +                   break;
>
> Ditto. Also this is duplicated code. A (inline) function would make
> sense.

I agree. V4 will add a new *inline* function for this.

> > +
> > +           count--;
> > +           udelay(1);
> > +   }
> > +
> > +   if (!count)
> > +           dev_err(dev->dev.parent, "timed out in object put\n");
> > +}
> > +
> > +int c_can_write_msg_object(struct net_device *dev,
> > +                   int iface, struct can_frame *frame, int objno)
> > +{
> > +   int i;
> > +   u16 flags = 0;
> > +   unsigned int id;
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +
> > +   if (frame->can_id & CAN_EFF_FLAG) {
> > +           id = frame->can_id & CAN_EFF_MASK;
> > +           flags |= IF_ARB_MSGXTD;
> > +   } else
> > +           id = ((frame->can_id & CAN_SFF_MASK) << 18);
> > +
> > +   if (!(frame->can_id & CAN_RTR_FLAG))
> > +           flags |= IF_ARB_TRANSMIT;
> > +
> > +   flags |= IF_ARB_MSGVAL;
> > +
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[iface].arb1,
> > +                           IFX_WRITE_LOW_16BIT(id));
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[iface].arb2, flags |
> > +                           IFX_WRITE_HIGH_16BIT(id));
> > +
> > +   for (i = 0; i < frame->can_dlc; i += 2) {
> > +           priv->write_reg(priv, &priv->reg_base->ifreg[iface].data[i
> / 2],
> > +                           frame->data[i] | (frame->data[i + 1] << 8));
> > +   }
> > +
> > +   return frame->can_dlc;
> > +}
> > +
> > +static inline void c_can_mark_rx_msg_obj(struct net_device *dev,
> > +                                           int iface, int ctrl_mask,
> > +                                           int obj)
> > +{
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[iface].msg_cntrl,
> > +                   ctrl_mask & ~(IF_MCONT_MSGLST | IF_MCONT_INTPND));
> > +
> > +   c_can_object_put(dev, iface, obj, IF_COMM_CONTROL);
> > +
>
> Please remove empty line above.

Ok.

> > +}
> > +
> > +static inline void c_can_activate_all_lower_rx_msg_obj(struct
> net_device *dev,
> > +                                           int iface,
> > +                                           int ctrl_mask)
> > +{
> > +   int i;
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +
> > +   for (i = 0; i < C_CAN_MSG_RX_LOW_LAST; i++) {
> > +           priv->write_reg(priv, &priv->reg_base-
> >ifreg[iface].msg_cntrl,
> > +                           ctrl_mask & ~(IF_MCONT_MSGLST |
> > +                                   IF_MCONT_INTPND | IF_MCONT_NEWDAT));
> > +           c_can_object_put(dev, iface, i + 1, IF_COMM_CONTROL);
> > +   }
> > +}
> > +
> > +static inline void c_can_activate_rx_msg_obj(struct net_device *dev,
> > +                                           int iface, int ctrl_mask,
> > +                                           int obj)
> > +{
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[iface].msg_cntrl,
> > +                   ctrl_mask & ~(IF_MCONT_MSGLST |
> > +                           IF_MCONT_INTPND | IF_MCONT_NEWDAT));
> > +
> > +   c_can_object_put(dev, iface, obj, IF_COMM_CONTROL);
>
> Ditto.

Ok.

> > +}
> > +
> > +static void c_can_handle_lost_msg_obj(struct net_device *dev,
> > +                                   int iface, int objno)
> > +{
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +   struct net_device_stats *stats = &dev->stats;
> > +   struct sk_buff *skb;
> > +   struct can_frame *frame;
> > +
> > +   dev_err(dev->dev.parent, "msg lost in buffer %d\n", objno);
> > +
> > +   c_can_object_get(dev, iface, objno, IF_COMM_ALL &
> > +                                           ~IF_COMM_TXRQST);
> > +
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[iface].msg_cntrl,
> > +                   IF_MCONT_CLR_MSGLST);
> > +
> > +   c_can_object_put(dev, 0, objno, IF_COMM_CONTROL);
> > +
> > +   /* create an error msg */
> > +   skb = alloc_can_err_skb(dev, &frame);
> > +   if (unlikely(!skb))
> > +           return;
> > +
> > +   frame->can_id |= CAN_ERR_CRTL;
> > +   frame->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
> > +   stats->rx_errors++;
> > +   stats->rx_over_errors++;
> > +
> > +   netif_receive_skb(skb);
> > +}
> > +
> > +static int c_can_read_msg_object(struct net_device *dev, int iface,
> int ctrl,
> > +                           int objno)
> > +{
> > +   u16 flags, data;
> > +   int i;
> > +   unsigned int val;
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +   struct net_device_stats *stats = &dev->stats;
> > +   struct sk_buff *skb;
> > +   struct can_frame *frame;
> > +
> > +   skb = alloc_can_skb(dev, &frame);
> > +   if (!skb) {
> > +           stats->rx_dropped++;
> > +           return -ENOMEM;
> > +   }
> > +
> > +   frame->can_dlc = get_can_dlc(ctrl & 0x0F);
> > +
> > +   for (i = 0; i < frame->can_dlc; i += 2) {
> > +           data = priv->read_reg(priv,
> > +                           &priv->reg_base->ifreg[iface].data[i / 2]);
> > +           frame->data[i] = data;
> > +           frame->data[i + 1] = data >> 8;
> > +   }
> > +
> > +   flags = priv->read_reg(priv, &priv->reg_base-
> >ifreg[iface].arb2);
> > +   val = priv->read_reg(priv, &priv->reg_base->ifreg[iface].arb1) |
> > +           (flags << 16);
> > +
> > +   if (flags & IF_ARB_MSGXTD)
> > +           frame->can_id = (val & CAN_EFF_MASK) | CAN_EFF_FLAG;
> > +   else
> > +           frame->can_id = (val >> 18) & CAN_SFF_MASK;
> > +
> > +   if (flags & IF_ARB_TRANSMIT)
> > +           frame->can_id |= CAN_RTR_FLAG;
> > +
> > +   netif_receive_skb(skb);
> > +
> > +   stats->rx_packets++;
> > +   stats->rx_bytes += frame->can_dlc;
> > +
> > +   return 0;
> > +}
> > +
> > +static void c_can_setup_receive_object(struct net_device *dev, int
> iface,
> > +                                   int objno, unsigned int mask,
> > +                                   unsigned int id, unsigned int mcont)
> > +{
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[iface].mask1,
> > +                   IFX_WRITE_LOW_16BIT(mask));
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[iface].mask2,
> > +                   IFX_WRITE_HIGH_16BIT(mask));
> > +
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[iface].arb1,
> > +                   IFX_WRITE_LOW_16BIT(id));
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[iface].arb2,
> > +                   (IF_ARB_MSGVAL | IFX_WRITE_HIGH_16BIT(id)));
> > +
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[iface].msg_cntrl,
> mcont);
> > +   c_can_object_put(dev, iface, objno, IF_COMM_ALL &
> > +                                           ~IF_COMM_TXRQST);
>
> Should fit on one line.

Ok.

> > +
> > +   dev_dbg(dev->dev.parent, "obj no:%d, msgval:0x%08x\n", objno,
> > +                   c_can_read_reg32(priv, &priv->reg_base->msgval1));
>
> Please remove empty line above.

Ok.

> > +}
> > +
> > +static void c_can_inval_msg_object(struct net_device *dev, int
> iface, int objno)
> > +{
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[iface].arb1, 0);
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[iface].arb2, 0);
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[iface].msg_cntrl,
> 0);
> > +
> > +   c_can_object_put(dev, iface, objno,
> > +                           IF_COMM_ARB | IF_COMM_CONTROL);
> > +
> > +   dev_dbg(dev->dev.parent, "obj no:%d, msgval:0x%08x\n", objno,
> > +                   c_can_read_reg32(priv, &priv->reg_base->msgval1));
>
> Ditto.

Ok.

> > +}
> > +
> > +static netdev_tx_t c_can_start_xmit(struct sk_buff *skb,
> > +                                   struct net_device *dev)
> > +{
> > +   u32 val;
> > +   u32 msg_obj_no;
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +   struct can_frame *frame = (struct can_frame *)skb->data;
> > +
> > +   if (can_dropped_invalid_skb(dev, skb))
> > +           return NETDEV_TX_OK;
> > +
> > +   msg_obj_no = get_tx_next_msg_obj(priv);
> > +
> > +   /* prepare message object for transmission */
> > +   val = c_can_write_msg_object(dev, 0, frame, msg_obj_no);
> > +
> > +   /* enable interrupt for this message object */
> > +   priv->write_reg(priv, &priv->reg_base->ifreg[0].msg_cntrl,
> > +                   IF_MCONT_TXIE | IF_MCONT_TXRQST | IF_MCONT_EOB |
> > +                   (val & 0xf));
> > +   c_can_object_put(dev, 0, msg_obj_no, IF_COMM_ALL);
> > +
> > +   can_put_echo_skb(skb, dev, msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
> > +
> > +   priv->tx_next++;
> > +   if ((priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) == 0)
> > +           netif_stop_queue(dev);
> > +
> > +   return NETDEV_TX_OK;
> > +}
> > +
> > +static int c_can_set_bittiming(struct net_device *dev)
> > +{
> > +   unsigned int reg_btr, reg_brpe, ctrl_save;
> > +   u8 brp, brpe, sjw, tseg1, tseg2;
> > +   u32 ten_bit_brp;
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +   const struct can_bittiming *bt = &priv->can.bittiming;
> > +
> > +   /* c_can provides a 6-bit brp and 4-bit brpe fields */
> > +   ten_bit_brp = bt->brp - 1;
> > +   brp = ten_bit_brp & BTR_BRP_MASK;
> > +   brpe = ten_bit_brp >> 6;
> > +
> > +   sjw = bt->sjw - 1;
> > +   tseg1 = bt->prop_seg + bt->phase_seg1 - 1;
> > +   tseg2 = bt->phase_seg2 - 1;
> > +
> > +   reg_btr = ((brp) | (sjw << BTR_SJW_SHIFT) | (tseg1 <<
> BTR_TSEG1_SHIFT) |
> > +                   (tseg2 << BTR_TSEG2_SHIFT));
>
> The outer brackets are not needed.

Ok.

> > +   reg_brpe = brpe & BRP_EXT_BRPE_MASK;
> > +
> > +   dev_info(dev->dev.parent,
> > +           "setting BTR=%04x BRPE=%04x\n", reg_btr, reg_brpe);
> > +
> > +   ctrl_save = priv->read_reg(priv, &priv->reg_base->control);
> > +   priv->write_reg(priv, &priv->reg_base->control,
> > +                   ctrl_save | CONTROL_CCE | CONTROL_INIT);
> > +   priv->write_reg(priv, &priv->reg_base->btr, reg_btr);
> > +   priv->write_reg(priv, &priv->reg_base->brp_ext, reg_brpe);
> > +   priv->write_reg(priv, &priv->reg_base->control, ctrl_save);
> > +
> > +   return 0;
> > +}
> > +
> > +/*
> > + * Configure C_CAN message objects for Tx and Rx purposes:
> > + * C_CAN provides a total of 32 message objects that can be
> configured
> > + * either for Tx or Rx purposes. Here the first 16 message objects
> are used as
> > + * a reception FIFO. The end of reception FIFO is signified by the
> EoB bit
> > + * being SET. The remaining 16 message objects are kept aside for Tx
> purposes.
> > + * See user guide document for further details on configuring
> message
> > + * objects.
> > + */
> > +static void c_can_configure_msg_objects(struct net_device *dev)
> > +{
> > +   int i;
> > +
> > +   /* first invalidate all message objects */
> > +   for (i = 0; i <= C_CAN_NO_OF_OBJECTS; i++)
> > +           c_can_inval_msg_object(dev, 0, i);
> > +
> > +   /* setup receive message objects */
> > +   for (i = C_CAN_MSG_OBJ_RX_FIRST + 1 ; i < C_CAN_MSG_OBJ_RX_LAST;
> i++)
> > +           c_can_setup_receive_object(dev, 0, i, 0, 0,
> > +                   ((IF_MCONT_RXIE | IF_MCONT_UMASK) & ~IF_MCONT_EOB));
>
> Ditto.

Ok.

> > +   c_can_setup_receive_object(dev, 0, C_CAN_MSG_OBJ_RX_LAST, 0, 0,
> > +                   IF_MCONT_EOB | IF_MCONT_RXIE | IF_MCONT_UMASK);
> > +}
> > +
> > +/*
> > + * Configure C_CAN chip:
> > + * - enable/disable auto-retransmission
> > + * - set operating mode
> > + * - configure message objects
> > + */
> > +static void c_can_chip_config(struct net_device *dev)
> > +{
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +
> > +   if (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT)
> > +           /* disable automatic retransmission */
> > +           priv->write_reg(priv, &priv->reg_base->control,
> > +                           CONTROL_DISABLE_AR);
> > +   else
> > +           /* enable automatic retransmission */
> > +           priv->write_reg(priv, &priv->reg_base->control,
> > +                           CONTROL_ENABLE_AR);
> > +
> > +   if (priv->can.ctrlmode & (CAN_CTRLMODE_LISTENONLY &
> > +                                   CAN_CTRLMODE_LOOPBACK)) {
> > +           /* loopback + silent mode : useful for hot self-test */
> > +           priv->write_reg(priv, &priv->reg_base->control,
> (CONTROL_EIE |
> > +                           CONTROL_SIE | CONTROL_IE | CONTROL_TEST));
>
> Outer brackets are not needed.

Ok.

> > +           priv->write_reg(priv, &priv->reg_base->test,
> > +                           (TEST_LBACK | TEST_SILENT));
> > +   } else if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
> > +           /* loopback mode : useful for self-test function */
> > +           priv->write_reg(priv, &priv->reg_base->control,
> (CONTROL_EIE |
> > +                           CONTROL_SIE | CONTROL_IE | CONTROL_TEST));
>
> Ditto.

Ok.

> > +           priv->write_reg(priv, &priv->reg_base->test, TEST_LBACK);
> > +   } else if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY) {
> > +           /* silent mode : bus-monitoring mode */
> > +           priv->write_reg(priv, &priv->reg_base->control,
> (CONTROL_EIE |
> > +                           CONTROL_SIE | CONTROL_IE | CONTROL_TEST));
>
> Ditto.

Ok.

> > +           priv->write_reg(priv, &priv->reg_base->test, TEST_SILENT);
> > +   } else
> > +           /* normal mode*/
> > +           priv->write_reg(priv, &priv->reg_base->control,
> > +                           (CONTROL_EIE | CONTROL_SIE | CONTROL_IE));
>
> Ditto.

Ok.

> > +   /* configure message objects */
> > +   c_can_configure_msg_objects(dev);
> > +}
> > +
> > +static void c_can_start(struct net_device *dev)
> > +{
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +
> > +   /* enable status change, error and module interrupts */
> > +   c_can_enable_all_interrupts(priv, ENABLE_ALL_INTERRUPTS);
> > +
> > +   /* basic c_can configuration */
> > +   c_can_chip_config(dev);
> > +
> > +   priv->can.state = CAN_STATE_ERROR_ACTIVE;
> > +
> > +   /* reset tx helper pointers */
> > +   priv->tx_next = priv->tx_echo = 0;
> > +}
> > +
> > +static void c_can_stop(struct net_device *dev)
> > +{
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +
> > +   /* disable all interrupts */
> > +   c_can_enable_all_interrupts(priv, DISABLE_ALL_INTERRUPTS);
> > +
> > +   /* set the state as STOPPED */
> > +   priv->can.state = CAN_STATE_STOPPED;
> > +}
> > +
> > +static int c_can_set_mode(struct net_device *dev, enum can_mode
> mode)
> > +{
> > +   switch (mode) {
> > +   case CAN_MODE_START:
> > +           c_can_start(dev);
> > +           netif_wake_queue(dev);
> > +           break;
> > +   default:
> > +           return -EOPNOTSUPP;
> > +   }
> > +
> > +   return 0;
> > +}
> > +
> > +static int c_can_get_berr_counter(const struct net_device *dev,
> > +                                   struct can_berr_counter *bec)
> > +{
> > +   unsigned int reg_err_counter;
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +
> > +   reg_err_counter = priv->read_reg(priv, &priv->reg_base-
> >error_counter);
> > +   bec->rxerr = ((reg_err_counter & ERR_COUNTER_REC_MASK) >>
> > +                           ERR_COUNTER_REC_SHIFT);
>
> You don't need the out brackets.

Ok.

> > +   bec->txerr = (reg_err_counter & ERR_COUNTER_TEC_MASK);
>
> Ditto.

Ok.

> > +   return 0;
> > +}
> > +
> > +/*
> > + * theory of operation:
> > + *
> > + * priv->tx_echo holds the number of the oldest can_frame put for
> > + * transmission into the hardware, but not yet ACKed by the CAN tx
> > + * complete IRQ.
> > + *
> > + * We iterate from priv->tx_echo to priv->tx_next and check if the
> > + * packet has been transmitted, echo it back to the CAN framework.
> > + * If we discover a not yet transmitted package, stop looking for
> more.
> > + */
> > +static void c_can_do_tx(struct net_device *dev)
> > +{
> > +   u32 val;
> > +   u32 msg_obj_no;
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +   struct net_device_stats *stats = &dev->stats;
> > +
> > +   for (/* nix */; (priv->tx_next - priv->tx_echo) > 0; priv-
> >tx_echo++) {
> > +           msg_obj_no = get_tx_echo_msg_obj(priv);
> > +           c_can_inval_msg_object(dev, 0, msg_obj_no);
> > +           val = c_can_read_reg32(priv, &priv->reg_base->txrqst1);
> > +           if (!(val & (1 << msg_obj_no))) {
> > +                   can_get_echo_skb(dev,
> > +                                   msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
> > +                   stats->tx_bytes += priv->read_reg(priv,
> > +                                   &priv->reg_base->ifreg[0].msg_cntrl)
> > +                                   & IF_MCONT_DLC_MASK;
> > +                   stats->tx_packets++;
> > +           }
> > +   }
> > +
> > +   /* restart queue if wrap-up or if queue stalled on last pkt */
> > +   if (((priv->tx_next & C_CAN_NEXT_MSG_OBJ_MASK) != 0) ||
> > +                   ((priv->tx_echo & C_CAN_NEXT_MSG_OBJ_MASK) == 0))
> > +           netif_wake_queue(dev);
> > +}
> > +
> > +/*
> > + * theory of operation:
> > + *
> > + * c_can core saves a received CAN message into the first free
> message
> > + * object it finds free (starting with the lowest). Bits NEWDAT and
> > + * INTPND are set for this message object indicating that a new
> message
> > + * has arrived. To work-around this issue, we keep two groups of
> message
> > + * objects whose partitioning is defined by C_CAN_MSG_OBJ_RX_SPLIT.
> > + *
> > + * To ensure in-order frame reception we use the following
> > + * approach while re-activating a message object to receive further
> > + * frames:
> > + * - if the current message object number is lower than
> > + *   C_CAN_MSG_RX_LOW_LAST, do not clear the NEWDAT bit while
> clearing
> > + *   the INTPND bit.
> > + * - if the current message object number is equal to
> > + *   C_CAN_MSG_RX_LOW_LAST then clear the NEWDAT bit of all lower
> > + *   receive message objects.
> > + * - if the current message object number is greater than
> > + *   C_CAN_MSG_RX_LOW_LAST then clear the NEWDAT bit of
> > + *   only this message object.
> > + */
> > +static int c_can_do_rx_poll(struct net_device *dev, int quota)
> > +{
> > +   u32 num_rx_pkts = 0;
> > +   unsigned int msg_obj, msg_ctrl_save;
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +   u32 val = c_can_read_reg32(priv, &priv->reg_base->intpnd1);
> > +
> > +   for (msg_obj = C_CAN_MSG_OBJ_RX_FIRST;
> > +                   msg_obj <= C_CAN_MSG_OBJ_RX_LAST && quota > 0;
> > +                   msg_obj++) {
> > +           if (val & (1 << msg_obj)) {
> > +                   c_can_object_get(dev, 0, msg_obj, IF_COMM_ALL &
> > +                                   ~IF_COMM_TXRQST);
> > +                   msg_ctrl_save = priv->read_reg(priv,
> > +                                   &priv->reg_base->ifreg[0].msg_cntrl);
> > +
> > +                   if (msg_ctrl_save & IF_MCONT_EOB)
> > +                           return num_rx_pkts;
> > +
> > +                   if (msg_ctrl_save & IF_MCONT_MSGLST) {
> > +                           c_can_handle_lost_msg_obj(dev, 0, msg_obj);
> > +                           num_rx_pkts++;
> > +                           quota--;
> > +                           continue;
> > +                   }
> > +
> > +                   if (!(msg_ctrl_save & IF_MCONT_NEWDAT))
> > +                           continue;
> > +
> > +                   /* read the data from the message object */
> > +                   c_can_read_msg_object(dev, 0, msg_ctrl_save,
> msg_obj);
> > +
> > +                   if (msg_obj < C_CAN_MSG_RX_LOW_LAST)
> > +                           c_can_mark_rx_msg_obj(dev, 0,
> > +                                           msg_ctrl_save, msg_obj);
> > +                   else if (msg_obj > C_CAN_MSG_RX_LOW_LAST)
> > +                           /* activate this msg obj */
> > +                           c_can_activate_rx_msg_obj(dev, 0,
> > +                                           msg_ctrl_save, msg_obj);
> > +                   else if (msg_obj == C_CAN_MSG_RX_LOW_LAST)
> > +                           /* activate all lower message objects */
> > +                           c_can_activate_all_lower_rx_msg_obj(dev,
> > +                                           0, msg_ctrl_save);
> > +
> > +                   num_rx_pkts++;
> > +                   quota--;
> > +           }
> > +           val = c_can_read_reg32(priv, &priv->reg_base->intpnd1);
> > +   }
> > +
> > +   return num_rx_pkts;
> > +}
> > +
> > +static inline int c_can_has_and_handle_berr(struct c_can_priv *priv)
> > +{
> > +   return (priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING) &&
> > +           (priv->current_status & STATUS_LEC_MASK);
> > +}
> > +
> > +static int c_can_err(struct net_device *dev,
> > +                           enum c_can_bus_error_types error_type,
> > +                           enum c_can_lec_type lec_type)
> > +{
> > +   unsigned int reg_err_counter;
> > +   unsigned int rx_err_passive;
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +   struct net_device_stats *stats = &dev->stats;
> > +   struct can_frame *cf;
> > +   struct sk_buff *skb;
> > +   struct can_berr_counter bec;
> > +
> > +   /* propogate the error condition to the CAN stack */
> > +   skb = alloc_can_err_skb(dev, &cf);
> > +   if (unlikely(!skb))
> > +           return 0;
> > +
> > +   c_can_get_berr_counter(dev, &bec);
> > +   reg_err_counter = priv->read_reg(priv, &priv->reg_base-
> >error_counter);
> > +   rx_err_passive = ((reg_err_counter & ERR_COUNTER_RP_MASK) >>
> > +                           ERR_COUNTER_RP_SHIFT);
>
> Outer brackset?

Ok. Will be removed in V4.

> > +   if (error_type & C_CAN_ERROR_WARNING) {
> > +           /* error warning state */
> > +           priv->can.can_stats.error_warning++;
> > +           priv->can.state = CAN_STATE_ERROR_WARNING;
> > +           cf->can_id |= CAN_ERR_CRTL;
> > +           if (bec.rxerr > 96)
> > +                   cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
> > +           if (bec.txerr > 96)
> > +                   cf->data[1] |= CAN_ERR_CRTL_TX_WARNING;
> > +   }
> > +   if (error_type & C_CAN_ERROR_PASSIVE) {
> > +           /* error passive state */
> > +           priv->can.can_stats.error_passive++;
> > +           priv->can.state = CAN_STATE_ERROR_PASSIVE;
> > +           cf->can_id |= CAN_ERR_CRTL;
> > +           if (rx_err_passive)
> > +                   cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
> > +           if (bec.txerr > 127)
> > +                   cf->data[1] |= CAN_ERR_CRTL_TX_PASSIVE;
> > +   }
> > +   if (error_type & C_CAN_BUS_OFF) {
> > +           /* bus-off state */
> > +           priv->can.state = CAN_STATE_BUS_OFF;
> > +           cf->can_id |= CAN_ERR_BUSOFF;
> > +           /* disable all interrupts in bus-off mode to ensure that
> > +            * the CPU is not hogged down
> > +            */
>
> Please use the following style:
>
>       /*
>        * Comment
>        */

Ok.

> > +           c_can_enable_all_interrupts(priv, DISABLE_ALL_INTERRUPTS);
> > +           can_bus_off(dev);
> > +   }
> > +
> > +   /*
> > +    * check for 'last error code' which tells us the
> > +    * type of the last error to occur on the CAN bus
> > +    */
> > +   switch (lec_type) {
> > +           /* common for all type of bus errors */
> > +           priv->can.can_stats.bus_error++;
> > +           stats->rx_errors++;
> > +           cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
> > +           cf->data[2] |= CAN_ERR_PROT_UNSPEC;
>
> Are you sure that this part is ever executed? I wonder why the compile
> does
> not complain.

I did not get any compilation error.
But I will check if the program flow enters this part or not.

> > +   case LEC_STUFF_ERROR:
> > +           dev_dbg(dev->dev.parent, "stuff error\n");
> > +           cf->data[2] |= CAN_ERR_PROT_STUFF;
> > +           break;
> > +
> > +   case LEC_FORM_ERROR:
> > +           dev_dbg(dev->dev.parent, "form error\n");
> > +           cf->data[2] |= CAN_ERR_PROT_FORM;
> > +           break;
> > +
> > +   case LEC_ACK_ERROR:
> > +           dev_dbg(dev->dev.parent, "ack error\n");
> > +           cf->data[2] |= (CAN_ERR_PROT_LOC_ACK |
> > +                           CAN_ERR_PROT_LOC_ACK_DEL);
> > +           break;
> > +
> > +   case LEC_BIT1_ERROR:
> > +           dev_dbg(dev->dev.parent, "bit1 error\n");
> > +           cf->data[2] |= CAN_ERR_PROT_BIT1;
> > +           break;
> > +
> > +   case LEC_BIT0_ERROR:
> > +           dev_dbg(dev->dev.parent, "bit0 error\n");
> > +           cf->data[2] |= CAN_ERR_PROT_BIT0;
> > +           break;
> > +
> > +   case LEC_CRC_ERROR:
> > +           dev_dbg(dev->dev.parent, "CRC error\n");
> > +           cf->data[2] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
> > +                           CAN_ERR_PROT_LOC_CRC_DEL);
> > +           break;
> > +   }
> > +
> > +   netif_receive_skb(skb);
> > +   stats->rx_packets++;
> > +   stats->rx_bytes += cf->can_dlc;
> > +
> > +   return 1;
> > +}
> > +
> > +static int c_can_poll(struct napi_struct *napi, int quota)
> > +{
> > +   u16 irqstatus;
> > +   int lec_type = 0;
> > +   int work_done = 0;
> > +   struct net_device *dev = napi->dev;
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +   enum c_can_bus_error_types error_type = C_CAN_NO_ERROR;
> > +
> > +   irqstatus = priv->read_reg(priv, &priv->reg_base->ir);
> > +
> > +   /* status events have the highest priority */
> > +   if (irqstatus == STATUS_INTERRUPT) {
> > +           priv->current_status = priv->read_reg(priv,
> > +                                   &priv->reg_base->status);
> > +
> > +           /* handle Tx/Rx events */
> > +           if (priv->current_status & STATUS_TXOK)
> > +                   priv->write_reg(priv, &priv->reg_base->status,
> > +                                   (priv->current_status & ~STATUS_TXOK));
>
> Outer bracket are not needed. Here and in similar expressions below.

Ok. I will check for redundant outer-bracket usage globally.

> > +
> > +           if (priv->current_status & STATUS_RXOK)
> > +                   priv->write_reg(priv, &priv->reg_base->status,
> > +                                   (priv->current_status & ~STATUS_RXOK));
> > +
> > +           /* handle bus error events */
> > +           if (priv->current_status & STATUS_EWARN) {
> > +                   dev_dbg(dev->dev.parent,
> > +                                   "entered error warning state\n");
> > +                   error_type = C_CAN_ERROR_WARNING;
> > +           }
> > +           if ((priv->current_status & STATUS_EPASS) &&
> > +                           (!(priv->last_status & STATUS_EPASS))) {
> > +                   dev_dbg(dev->dev.parent,
> > +                                   "entered error passive state\n");
> > +                   error_type = C_CAN_ERROR_PASSIVE;
> > +           }
> > +           if ((priv->current_status & STATUS_BOFF) &&
> > +                           (!(priv->last_status & STATUS_BOFF))) {
> > +                   dev_dbg(dev->dev.parent,
> > +                                   "entered bus off state\n");
> > +                   error_type = C_CAN_BUS_OFF;
> > +           }
> > +
> > +           /* handle bus recovery events */
> > +           if ((!(priv->current_status & STATUS_EPASS)) &&
> > +                           (priv->last_status & STATUS_EPASS)) {
> > +                   dev_dbg(dev->dev.parent,
> > +                                   "left error passive state\n");
> > +                   priv->can.state = CAN_STATE_ERROR_ACTIVE;
> > +           }
> > +           if ((!(priv->current_status & STATUS_BOFF)) &&
> > +                           (priv->last_status & STATUS_BOFF)) {
> > +                   dev_dbg(dev->dev.parent,
> > +                                   "left bus off state\n");
> > +                   priv->can.state = CAN_STATE_ERROR_ACTIVE;
> > +           }
> > +
> > +           priv->last_status = priv->current_status;
> > +
> > +           /* handle error on the bus */
> > +           lec_type = c_can_has_and_handle_berr(priv);
> > +           if (lec_type && (error_type != C_CAN_NO_ERROR))
> > +                   work_done += c_can_err(dev, error_type, lec_type);
> > +   } else if ((irqstatus > C_CAN_MSG_OBJ_RX_FIRST) &&
> > +                   (irqstatus <= C_CAN_MSG_OBJ_RX_LAST)) {
> > +           /* handle events corresponding to receive message objects
> */
> > +           work_done += c_can_do_rx_poll(dev, (quota - work_done));
> > +   } else if ((irqstatus > C_CAN_MSG_OBJ_TX_FIRST) &&
> > +                   (irqstatus <= C_CAN_MSG_OBJ_TX_LAST)) {
> > +           /* handle events corresponding to transmit message objects
> */
> > +           c_can_do_tx(dev);
> > +   }
> > +
> > +   if (work_done < quota) {
> > +           napi_complete(napi);
> > +           /* enable all IRQs */
> > +           c_can_enable_all_interrupts(priv, ENABLE_ALL_INTERRUPTS);
> > +   }
> > +
> > +   return work_done;
> > +}
> > +
> > +static irqreturn_t c_can_isr(int irq, void *dev_id)
> > +{
> > +   struct net_device *dev = (struct net_device *)dev_id;
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +
> > +   /* disable all interrupts and schedule the NAPI */
> > +   c_can_enable_all_interrupts(priv, DISABLE_ALL_INTERRUPTS);
> > +   napi_schedule(&priv->napi);
> > +
> > +   return IRQ_HANDLED;
> > +}
> > +
> > +static int c_can_open(struct net_device *dev)
> > +{
> > +   int err;
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +
> > +   /* open the can device */
> > +   err = open_candev(dev);
> > +   if (err) {
> > +           dev_err(dev->dev.parent, "failed to open can device\n");
> > +           return err;
> > +   }
> > +
> > +   /* register interrupt handler */
> > +   err = request_irq(dev->irq, &c_can_isr, priv->irq_flags, dev-
> >name,
> > +                           dev);
> > +   if (err < 0) {
> > +           dev_err(dev->dev.parent, "failed to attach interrupt\n");
>
> s/attach/request/ ?

Ok.

> > +           goto exit_irq_fail;
> > +   }
> > +
> > +   /* start the c_can controller */
> > +   c_can_start(dev);
> > +
> > +   napi_enable(&priv->napi);
> > +   netif_start_queue(dev);
> > +
> > +   return 0;
> > +
> > +exit_irq_fail:
> > +   close_candev(dev);
> > +   return err;
> > +}
> > +
> > +static int c_can_close(struct net_device *dev)
> > +{
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +
> > +   netif_stop_queue(dev);
> > +   napi_disable(&priv->napi);
> > +   c_can_stop(dev);
> > +   free_irq(dev->irq, dev);
> > +   close_candev(dev);
> > +
> > +   return 0;
> > +}
> > +
> > +struct net_device *alloc_c_can_dev(void)
> > +{
> > +   struct net_device *dev;
> > +   struct c_can_priv *priv;
> > +
> > +   dev = alloc_candev(sizeof(struct c_can_priv),
> C_CAN_MSG_OBJ_TX_NUM);
> > +   if (!dev)
> > +           return NULL;
> > +
> > +   priv = netdev_priv(dev);
> > +   netif_napi_add(dev, &priv->napi, c_can_poll, C_CAN_NAPI_WEIGHT);
> > +
> > +   priv->dev = dev;
> > +   priv->can.bittiming_const = &c_can_bittiming_const;
> > +   priv->can.do_set_bittiming = c_can_set_bittiming;
> > +   priv->can.do_set_mode = c_can_set_mode;
> > +   priv->can.do_get_berr_counter = c_can_get_berr_counter;
> > +   priv->can.ctrlmode_supported = CAN_CTRLMODE_ONE_SHOT |
> > +                                   CAN_CTRLMODE_LOOPBACK |
> > +                                   CAN_CTRLMODE_LISTENONLY |
> > +                                   CAN_CTRLMODE_BERR_REPORTING;
> > +
> > +   return dev;
> > +}
> > +EXPORT_SYMBOL_GPL(alloc_c_can_dev);
> > +
> > +void free_c_can_dev(struct net_device *dev)
> > +{
> > +   free_candev(dev);
> > +}
> > +EXPORT_SYMBOL_GPL(free_c_can_dev);
> > +
> > +static const struct net_device_ops c_can_netdev_ops = {
> > +   .ndo_open = c_can_open,
> > +   .ndo_stop = c_can_close,
> > +   .ndo_start_xmit = c_can_start_xmit,
> > +};
> > +
> > +int register_c_can_dev(struct net_device *dev)
> > +{
> > +   dev->flags |= IFF_ECHO; /* we support local echo */
> > +   dev->netdev_ops = &c_can_netdev_ops;
> > +
> > +   return register_candev(dev);
> > +}
> > +EXPORT_SYMBOL_GPL(register_c_can_dev);
> > +
> > +void unregister_c_can_dev(struct net_device *dev)
> > +{
> > +   unregister_candev(dev);
> > +}
> > +EXPORT_SYMBOL_GPL(unregister_c_can_dev);
> > +
> > +MODULE_AUTHOR("Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>");
> > +MODULE_LICENSE("GPL v2");
> > +MODULE_DESCRIPTION("CAN bus driver for Bosch C_CAN controller");
> > diff --git a/drivers/net/can/c_can/c_can.h
> b/drivers/net/can/c_can/c_can.h
> > new file mode 100644
> > index 0000000..fafc5e6
> > --- /dev/null
> > +++ b/drivers/net/can/c_can/c_can.h
> > @@ -0,0 +1,235 @@
> > +/*
> > + * CAN bus driver for Bosch C_CAN controller
> > + *
> > + * Copyright (C) 2010 ST Microelectronics
> > + * Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
> > + *
> > + * Borrowed heavily from the C_CAN driver originally written by:
> > + * Copyright (C) 2007
> > + * - Sascha Hauer, Marc Kleine-Budde, Pengutronix
> <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> > + * - Simon Kallweit, intefo AG <simon.kallweit-+G9qxTFKJT/tRgLqZ5aouw@public.gmane.org>
> > + *
> > + * TX and RX NAPI implementation has been borrowed from at91 CAN
> driver
> > + * written by:
> > + * Copyright
> > + * (C) 2007 by Hans J. Koch <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> > + * (C) 2008, 2009 by Marc Kleine-Budde <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> > + *
> > + * Bosch C_CAN controller is compliant to CAN protocol version 2.0
> part A and B.
> > + * Bosch C_CAN user manual can be obtained from:
> > + * http://www.semiconductors.bosch.de/pdf/Users_Manual_C_CAN.pdf
> > + *
> > + * This file is licensed under the terms of the GNU General Public
> > + * License version 2. This program is licensed "as is" without any
> > + * warranty of any kind, whether express or implied.
> > + */
> > +
> > +#ifndef C_CAN_H
> > +#define C_CAN_H
> > +
> > +/* control register */
> > +#define CONTROL_TEST               BIT(7)
> > +#define CONTROL_CCE                BIT(6)
> > +#define CONTROL_DISABLE_AR BIT(5)
> > +#define CONTROL_ENABLE_AR  (0 << 5)
> > +#define CONTROL_EIE                BIT(3)
> > +#define CONTROL_SIE                BIT(2)
> > +#define CONTROL_IE         BIT(1)
> > +#define CONTROL_INIT               BIT(0)
> > +
> > +/* test register */
> > +#define TEST_RX                    BIT(7)
> > +#define TEST_TX1           BIT(6)
> > +#define TEST_TX2           BIT(5)
> > +#define TEST_LBACK         BIT(4)
> > +#define TEST_SILENT                BIT(3)
> > +#define TEST_BASIC         BIT(2)
> > +
> > +/* status register */
> > +#define STATUS_BOFF                BIT(7)
> > +#define STATUS_EWARN               BIT(6)
> > +#define STATUS_EPASS               BIT(5)
> > +#define STATUS_RXOK                BIT(4)
> > +#define STATUS_TXOK                BIT(3)
> > +#define STATUS_LEC_MASK            0x07
> > +
> > +/* error counter register */
> > +#define ERR_COUNTER_TEC_MASK       0xff
> > +#define ERR_COUNTER_TEC_SHIFT      0
> > +#define ERR_COUNTER_REC_SHIFT      8
> > +#define ERR_COUNTER_REC_MASK       (0x7f << ERR_COUNTER_REC_SHIFT)
> > +#define ERR_COUNTER_RP_SHIFT       15
> > +#define ERR_COUNTER_RP_MASK        (0x1 << ERR_COUNTER_RP_SHIFT)
> > +
> > +/* bit-timing register */
> > +#define BTR_BRP_MASK               0x3f
> > +#define BTR_BRP_SHIFT              0
> > +#define BTR_SJW_SHIFT              6
> > +#define BTR_SJW_MASK               (0x3 << BTR_SJW_SHIFT)
> > +#define BTR_TSEG1_SHIFT            8
> > +#define BTR_TSEG1_MASK             (0xf << BTR_TSEG1_SHIFT)
> > +#define BTR_TSEG2_SHIFT            12
> > +#define BTR_TSEG2_MASK             (0x7 << BTR_TSEG2_SHIFT)
> > +
> > +/* brp extension register */
> > +#define BRP_EXT_BRPE_MASK  0x0f
> > +#define BRP_EXT_BRPE_SHIFT 0
> > +
> > +/* IFx command request */
> > +#define IF_COMR_BUSY               BIT(15)
> > +
> > +/* IFx command mask */
> > +#define IF_COMM_WR         BIT(7)
> > +#define IF_COMM_MASK               BIT(6)
> > +#define IF_COMM_ARB                BIT(5)
> > +#define IF_COMM_CONTROL            BIT(4)
> > +#define IF_COMM_CLR_INT_PND        BIT(3)
> > +#define IF_COMM_TXRQST             BIT(2)
> > +#define IF_COMM_DATAA              BIT(1)
> > +#define IF_COMM_DATAB              BIT(0)
> > +#define IF_COMM_ALL                (IF_COMM_MASK | IF_COMM_ARB | \
> > +                           IF_COMM_CONTROL | IF_COMM_TXRQST | \
> > +                           IF_COMM_DATAA | IF_COMM_DATAB)
> > +
> > +/* IFx arbitration */
> > +#define IF_ARB_MSGVAL              BIT(15)
> > +#define IF_ARB_MSGXTD              BIT(14)
> > +#define IF_ARB_TRANSMIT            BIT(13)
> > +
> > +/* IFx message control */
> > +#define IF_MCONT_NEWDAT            BIT(15)
> > +#define IF_MCONT_MSGLST            BIT(14)
> > +#define IF_MCONT_CLR_MSGLST        (0 << 14)
> > +#define IF_MCONT_INTPND            BIT(13)
> > +#define IF_MCONT_UMASK             BIT(12)
> > +#define IF_MCONT_TXIE              BIT(11)
> > +#define IF_MCONT_RXIE              BIT(10)
> > +#define IF_MCONT_RMTEN             BIT(9)
> > +#define IF_MCONT_TXRQST            BIT(8)
> > +#define IF_MCONT_EOB               BIT(7)
> > +#define IF_MCONT_DLC_MASK  0xf
> > +
> > +/*
> > + * IFx register masks:
> > + * allow easy operation on 16-bit registers when the
> > + * argument is 32-bit instead
> > + */
> > +#define IFX_WRITE_LOW_16BIT(x)     ((x) & 0xFFFF)
> > +#define IFX_WRITE_HIGH_16BIT(x)    (((x) & 0xFFFF0000) >> 16)
> > +
> > +/* message object split */
> > +#define C_CAN_NO_OF_OBJECTS        31
> > +#define C_CAN_MSG_OBJ_RX_NUM       16
> > +#define C_CAN_MSG_OBJ_TX_NUM       16
> > +
> > +#define C_CAN_MSG_OBJ_RX_FIRST     0
> > +#define C_CAN_MSG_OBJ_RX_LAST      (C_CAN_MSG_OBJ_RX_FIRST + \
> > +                           C_CAN_MSG_OBJ_RX_NUM - 1)
> > +
> > +#define C_CAN_MSG_OBJ_TX_FIRST     (C_CAN_MSG_OBJ_RX_LAST + 1)
> > +#define C_CAN_MSG_OBJ_TX_LAST      (C_CAN_MSG_OBJ_TX_FIRST + \
> > +                           C_CAN_MSG_OBJ_TX_NUM - 1)
> > +
> > +#define C_CAN_MSG_OBJ_RX_SPLIT     8
> > +#define C_CAN_MSG_RX_LOW_LAST      (C_CAN_MSG_OBJ_RX_SPLIT - 1)
> > +
> > +#define C_CAN_NEXT_MSG_OBJ_MASK    (C_CAN_MSG_OBJ_TX_NUM - 1)
> > +#define RECEIVE_OBJECT_BITS        0x0000ffff
> > +
> > +/* status interrupt */
> > +#define STATUS_INTERRUPT   0x8000
> > +
> > +/* global interrupt masks */
> > +#define ENABLE_ALL_INTERRUPTS      1
> > +#define DISABLE_ALL_INTERRUPTS     0
> > +
> > +/* minimum timeout for checking BUSY status */
> > +#define MIN_TIMEOUT_VALUE  6
> > +
> > +/* napi related */
> > +#define C_CAN_NAPI_WEIGHT  C_CAN_MSG_OBJ_RX_NUM
> > +
> > +/* c_can IF registers */
> > +struct c_can_if_regs {
> > +   u16 com_reg;
> > +   u16 com_mask;
> > +   u16 mask1;
> > +   u16 mask2;
> > +   u16 arb1;
> > +   u16 arb2;
> > +   u16 msg_cntrl;
> > +   u16 data[4];
> > +   u16 _reserved[13];
> > +};
> > +
> > +/* c_can hardware registers */
> > +struct c_can_regs {
> > +   u16 control;
> > +   u16 status;
> > +   u16 error_counter;
> > +   u16 btr;
> > +   u16 ir;
> > +   u16 test;
> > +   u16 brp_ext;
> > +   u16 _reserved1;
> > +   struct c_can_if_regs ifreg[2]; /* [0] = IF1 and [1] = IF2 */
>
> Why not just "if" instead of "ifreg"? That would also nicely shorten
> many log expressions.

Hmm.. Ok

> > +   u16 _reserved2[8];
> > +   u16 txrqst1;
> > +   u16 txrqst2;
> > +   u16 _reserved3[6];
> > +   u16 newdat1;
> > +   u16 newdat2;
> > +   u16 _reserved4[6];
> > +   u16 intpnd1;
> > +   u16 intpnd2;
> > +   u16 _reserved5[6];
> > +   u16 msgval1;
> > +   u16 msgval2;
> > +   u16 _reserved6[6];
> > +};
>
> Above you use both, rather long and heavily abbreviated names, e.g.
> "error_counter" vs. "ir". Something in between would be nice.

I agree. V4 will take care of these.

> > +/* c_can lec values */
> > +enum c_can_lec_type {
> > +   LEC_STUFF_ERROR = 1,
> > +   LEC_FORM_ERROR,
> > +   LEC_ACK_ERROR,
> > +   LEC_BIT1_ERROR,
> > +   LEC_BIT0_ERROR,
> > +   LEC_CRC_ERROR,
> > +};
> > +
> > +/*
> > + * c_can error types:
> > + * Bus errors (BUS_OFF, ERROR_WARNING, ERROR_PASSIVE) are supported
> > + */
> > +enum c_can_bus_error_types {
> > +   C_CAN_NO_ERROR = 0,
> > +   C_CAN_BUS_OFF,
> > +   C_CAN_ERROR_WARNING,
> > +   C_CAN_ERROR_PASSIVE,
> > +};
> > +
> > +/* c_can private data structure */
> > +struct c_can_priv {
> > +   struct can_priv can;    /* must be the first member */
> > +   struct napi_struct napi;
> > +   struct net_device *dev;
> > +   int tx_object;
> > +   int current_status;
> > +   int last_status;
> > +   u16 (*read_reg) (struct c_can_priv *priv, void *reg);
> > +   void (*write_reg) (struct c_can_priv *priv, void *reg, u16 val);
> > +   struct c_can_regs __iomem *reg_base;
>
> s/reg_base/regs/ seems more logical to me. reg_base sounds like a "void
> *"
> member.

Ok.

> > +   unsigned long irq_flags; /* for request_irq() */
> > +   unsigned int tx_next;
> > +   unsigned int tx_echo;
> > +   struct clk *clk;
>
> clk is a platform specific variable, e.g. a PCI based drive will not
> need it.
> Therefore a member "priv" would make sense. Also it would nicely
> shorten
> many log expressions.

Ok.

> > +};
> > +
> > +void c_can_enable_all_interrupts(struct c_can_priv *priv, int
> enable);
> > +struct net_device *alloc_c_can_dev(void);
> > +void free_c_can_dev(struct net_device *dev);
> > +int register_c_can_dev(struct net_device *dev);
> > +void unregister_c_can_dev(struct net_device *dev);
> > +
> > +#endif /* C_CAN_H */
> > diff --git a/drivers/net/can/c_can/c_can_platform.c
> b/drivers/net/can/c_can/c_can_platform.c
> > new file mode 100644
> > index 0000000..482a57e
> > --- /dev/null
> > +++ b/drivers/net/can/c_can/c_can_platform.c
> > @@ -0,0 +1,210 @@
> > +/*
> > + * Platform CAN bus driver for Bosch C_CAN controller
> > + *
> > + * Copyright (C) 2010 ST Microelectronics
> > + * Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
> > + *
> > + * Borrowed heavily from the C_CAN driver originally written by:
> > + * Copyright (C) 2007
> > + * - Sascha Hauer, Marc Kleine-Budde, Pengutronix
> <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> > + * - Simon Kallweit, intefo AG <simon.kallweit-+G9qxTFKJT/tRgLqZ5aouw@public.gmane.org>
> > + *
> > + * Bosch C_CAN controller is compliant to CAN protocol version 2.0
> part A and B.
> > + * Bosch C_CAN user manual can be obtained from:
> > + * http://www.semiconductors.bosch.de/pdf/Users_Manual_C_CAN.pdf
> > + *
> > + * This file is licensed under the terms of the GNU General Public
> > + * License version 2. This program is licensed "as is" without any
> > + * warranty of any kind, whether express or implied.
> > + */
> > +
> > +#include <linux/kernel.h>
> > +#include <linux/version.h>
> > +#include <linux/module.h>
> > +#include <linux/interrupt.h>
> > +#include <linux/delay.h>
> > +#include <linux/netdevice.h>
> > +#include <linux/if_arp.h>
> > +#include <linux/if_ether.h>
> > +#include <linux/list.h>
> > +#include <linux/delay.h>
> > +#include <linux/io.h>
> > +#include <linux/platform_device.h>
> > +#include <linux/clk.h>
> > +
> > +#include <linux/can/dev.h>
> > +
> > +#include "c_can.h"
> > +
> > +/*
> > + * 16-bit c_can registers can be arranged differently in the memory
> > + * architecture of different implementations. For example: 16-bit
> > + * registers can be aligned to a 16-bit boundary or 32-bit boundary
> etc.
> > + * Handle the same by providing a common read/write interface.
> > + */
> > +static u16 c_can_plat_read_reg_aligned_to_16bit(struct c_can_priv
> *priv,
> > +                                           void *reg)
> > +{
> > +   return readw(reg);
> > +}
> > +
> > +static void c_can_plat_write_reg_aligned_to_16bit(struct c_can_priv
> *priv,
> > +                                           void *reg, u16 val)
> > +{
> > +   writew(val, reg);
> > +}
> > +
> > +static u16 c_can_plat_read_reg_aligned_to_32bit(struct c_can_priv
> *priv,
> > +                                           void *reg)
> > +{
> > +   return readw(reg + (long)reg - (long)priv->reg_base);
> > +}
> > +
> > +static void c_can_plat_write_reg_aligned_to_32bit(struct c_can_priv
> *priv,
> > +                                           void *reg, u16 val)
> > +{
> > +   writew(val, reg + (long)reg - (long)priv->reg_base);
> > +}
> > +
> > +static int __devinit c_can_plat_probe(struct platform_device *pdev)
> > +{
> > +   int ret;
> > +   void __iomem *addr;
> > +   struct net_device *dev;
> > +   struct c_can_priv *priv;
> > +   struct resource *mem, *irq;
> > +   struct clk *clk;
> > +
> > +   /* get the appropriate clk */
> > +   clk = clk_get(&pdev->dev, NULL);
> > +   if (IS_ERR(clk)) {
> > +           dev_err(&pdev->dev, "no clock defined\n");
> > +           ret = -ENODEV;
> > +           goto exit;
> > +   }
> > +
> > +   /* get the platform data */
> > +   mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> > +   irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> > +   if (!mem || (irq <= 0)) {
> > +           ret = -ENODEV;
> > +           goto exit_free_clk;
> > +   }
> > +
> > +   if (!request_mem_region(mem->start, resource_size(mem),
> > +                           KBUILD_MODNAME)) {
> > +           dev_err(&pdev->dev, "resource unavailable\n");
> > +           ret = -ENODEV;
> > +           goto exit_free_clk;
> > +   }
> > +
> > +   addr = ioremap(mem->start, resource_size(mem));
> > +   if (!addr) {
> > +           dev_err(&pdev->dev, "failed to map can port\n");
> > +           ret = -ENOMEM;
> > +           goto exit_release_mem;
> > +   }
> > +
> > +   /* allocate the c_can device */
> > +   dev = alloc_c_can_dev();
> > +   if (!dev) {
> > +           ret = -ENOMEM;
> > +           goto exit_iounmap;
> > +   }
> > +
> > +   priv = netdev_priv(dev);
> > +
> > +   dev->irq = irq->start;
> > +   priv->irq_flags = irq->flags;
> > +   priv->reg_base = addr;
> > +   priv->can.clock.freq = clk_get_rate(clk);
> > +   priv->clk = clk;
> > +
> > +   switch (mem->flags & IORESOURCE_MEM_TYPE_MASK) {
> > +   case IORESOURCE_MEM_32BIT:
> > +           priv->read_reg = c_can_plat_read_reg_aligned_to_32bit;
> > +           priv->write_reg = c_can_plat_write_reg_aligned_to_32bit;
> > +           break;
> > +   case IORESOURCE_MEM_16BIT:
> > +   default:
> > +           priv->read_reg = c_can_plat_read_reg_aligned_to_16bit;
> > +           priv->write_reg = c_can_plat_write_reg_aligned_to_16bit;
> > +           break;
> > +   }
> > +
> > +   platform_set_drvdata(pdev, dev);
> > +   SET_NETDEV_DEV(dev, &pdev->dev);
> > +
> > +   ret = register_c_can_dev(dev);
> > +   if (ret) {
> > +           dev_err(&pdev->dev, "registering %s failed (err=%d)\n",
> > +                   KBUILD_MODNAME, ret);
> > +           goto exit_free_device;
> > +   }
> > +
> > +   dev_info(&pdev->dev, "%s device registered (reg_base=%p,
> irq=%d)\n",
> > +            KBUILD_MODNAME, priv->reg_base, dev->irq);
> > +   return 0;
> > +
> > +exit_free_device:
> > +   platform_set_drvdata(pdev, NULL);
> > +   free_c_can_dev(dev);
> > +exit_iounmap:
> > +   iounmap(addr);
> > +exit_release_mem:
> > +   release_mem_region(mem->start, resource_size(mem));
> > +exit_free_clk:
> > +   clk_put(clk);
> > +exit:
> > +   dev_err(&pdev->dev, "probe failed\n");
> > +
> > +   return ret;
> > +}
> > +
> > +static int __devexit c_can_plat_remove(struct platform_device *pdev)
> > +{
> > +   struct net_device *dev = platform_get_drvdata(pdev);
> > +   struct c_can_priv *priv = netdev_priv(dev);
> > +   struct resource *mem;
> > +
> > +   /* disable all interrupts */
> > +   c_can_enable_all_interrupts(priv, DISABLE_ALL_INTERRUPTS);
>
> To avoid exportign that function, couldn't it be done at the beginning
> of
> unregister_c_can_dev()?

Yes this can be done.
But, IMHO *disabling* interrupts seems more logical as part of __devexit
Code.

> > +
> > +   unregister_c_can_dev(dev);
> > +   platform_set_drvdata(pdev, NULL);
> > +
> > +   free_c_can_dev(dev);
> > +   iounmap(priv->reg_base);
> > +
> > +   mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> > +   release_mem_region(mem->start, resource_size(mem));
> > +
> > +   clk_put(priv->clk);
> > +
> > +   return 0;
> > +}
> > +
> > +static struct platform_driver c_can_plat_driver = {
> > +   .driver = {
> > +           .name = KBUILD_MODNAME,
> > +           .owner = THIS_MODULE,
> > +   },
> > +   .probe = c_can_plat_probe,
> > +   .remove = __devexit_p(c_can_plat_remove),
> > +};
> > +
> > +static int __init c_can_plat_init(void)
> > +{
> > +   return platform_driver_register(&c_can_plat_driver);
> > +}
> > +module_init(c_can_plat_init);
> > +
> > +static void __exit c_can_plat_exit(void)
> > +{
> > +   platform_driver_unregister(&c_can_plat_driver);
> > +}
> > +module_exit(c_can_plat_exit);
> > +
> > +MODULE_AUTHOR("Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>");
> > +MODULE_LICENSE("GPL v2");
> > +MODULE_DESCRIPTION("Platform CAN bus driver for Bosch C_CAN
> controller");
>
> Thanks for your contribution.
>
> Wolfgang.

Regards,
Bhupesh
