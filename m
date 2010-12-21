From: Bhupesh SHARMA <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Subject: RE: [PATCH net-next-2.6 v2 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Tue, 21 Dec 2010 12:48:39 +0800
Message-ID: <D5ECB3C7A6F99444980976A8C6D896384DEAE481B6@EAPEX1MAIL1.st.com>
References: <1292407130-19791-1-git-send-email-bhupesh.sharma@st.com>
	<4D0BD454.3060503@grandegger.com>
	<D5ECB3C7A6F99444980976A8C6D896384DEAE47E1A@EAPEX1MAIL1.st.com>
	<4D0FBEF6.8020207@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D0FBEF6.8020207-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
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

> Hi Bhupesh,
>
> On 12/20/2010 05:29 AM, Bhupesh SHARMA wrote:
> > Hi Wolfgang,
> >
> > Thanks for the review.
> > Please see my replies in-line:
> >
> >> here comes my first quick preview.
> >> On 12/15/2010 10:58 AM, Bhupesh Sharma wrote:
> >>> Bosch C_CAN controller is a full-CAN implementation which is
> >> compliant
> >>> to CAN protocol version 2.0 part A and B. Bosch C_CAN user manual
> can
> >> be
> >>> obtained from:
> >>> http://www.semiconductors.bosch.de/pdf/Users_Manual_C_CAN.pdf
> >>>
> >>> This patch adds the support for this controller.
> >>> The following are the design choices made while writing the
> >> controller driver:
> >>> 1. Interface Register set IF1 has be used only in the current
> design.
> >>> 2. Out of the 32 Message objects available, 16 are kept aside for
> RX
> >> purposes
> >>>    and the rest for TX purposes.
> >>> 3. NAPI implementation is such that both the TX and RX paths
> function
> >> in
> >>>    polling mode.
> >>>
> >>> Changes since V1:
> >>> 1. Implemented C_CAN as a platform driver with means of providing
> the
> >>>    platform details and register offsets which may vary for
> different
> >> SoCs
> >>>    through platform data struct.
> >>> 2. Implemented NAPI.
> >>> 3. Removed memcpy calls globally.
> >>> 4. Implemented CAN_CTRLMODE_*
> >>> 5. Implemented and used priv->can.do_get_berr_counter.
> >>> 6. Implemented c_can registers as a struct instead of enum.
> >>> 7. Improved the TX path by implementing routines to get next Tx and
> >> echo msg
> >>>    objects.
> >>>
> >>> Signed-off-by: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
> >>> ---
> >>>  drivers/net/can/Kconfig  |    7 +
> >>>  drivers/net/can/Makefile |    1 +
> >>>  drivers/net/can/c_can.c  | 1217
> >> ++++++++++++++++++++++++++++++++++++++++++++++
> >>>  3 files changed, 1225 insertions(+), 0 deletions(-)
> >>>  create mode 100644 drivers/net/can/c_can.c
> >>>
> >>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> >>> index 9d9e453..25d9d2e 100644
> >>> --- a/drivers/net/can/Kconfig
> >>> +++ b/drivers/net/can/Kconfig
> >>> @@ -41,6 +41,13 @@ config CAN_AT91
> >>>     ---help---
> >>>       This is a driver for the SoC CAN controller in Atmel's
> >> AT91SAM9263.
> >>>
> >>> +config CAN_C_CAN
> >>> +   tristate "Bosch C_CAN controller"
> >>> +   depends on CAN_DEV
> >>> +   ---help---
> >>> +     If you say yes to this option, support will be included for
> the
> >>> +     Bosch C_CAN controller.
> >>> +
> >>>  config CAN_TI_HECC
> >>>     depends on CAN_DEV && ARCH_OMAP3
> >>>     tristate "TI High End CAN Controller"
> >>> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> >>> index 0057537..b6cbe74 100644
> >>> --- a/drivers/net/can/Makefile
> >>> +++ b/drivers/net/can/Makefile
> >>> @@ -12,6 +12,7 @@ obj-y                             += usb/
> >>>  obj-$(CONFIG_CAN_SJA1000)  += sja1000/
> >>>  obj-$(CONFIG_CAN_MSCAN)            += mscan/
> >>>  obj-$(CONFIG_CAN_AT91)             += at91_can.o
> >>> +obj-$(CONFIG_CAN_C_CAN)            += c_can.o
> >>>  obj-$(CONFIG_CAN_TI_HECC)  += ti_hecc.o
> >>>  obj-$(CONFIG_CAN_MCP251X)  += mcp251x.o
> >>>  obj-$(CONFIG_CAN_BFIN)             += bfin_can.o
> >>> diff --git a/drivers/net/can/c_can.c b/drivers/net/can/c_can.c
> >>> new file mode 100644
> >>> index 0000000..c281c17
> >>> --- /dev/null
> >>> +++ b/drivers/net/can/c_can.c
> >>> @@ -0,0 +1,1217 @@
> >>> +/*
> >>> + * CAN bus driver for Bosch C_CAN controller
> >>> + *
> >>> + * Copyright (C) 2010 ST Microelectronics
> >>> + * Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
> >>> + *
> >>> + * Borrowed heavily from the C_CAN driver originally written by:
> >>> + * Copyright (C) 2007
> >>> + * - Sascha Hauer, Marc Kleine-Budde, Pengutronix
> >> <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> >>> + * - Simon Kallweit, intefo AG <simon.kallweit-+G9qxTFKJT/tRgLqZ5aouw@public.gmane.org>
> >>> + *
> >>> + * Bosch C_CAN controller is compliant to CAN protocol version 2.0
> >> part A and B.
> >>> + * Bosch C_CAN user manual can be obtained from:
> >>> + * http://www.semiconductors.bosch.de/pdf/Users_Manual_C_CAN.pdf
> >>> + *
> >>> + * This file is licensed under the terms of the GNU General Public
> >>> + * License version 2. This program is licensed "as is" without any
> >>> + * warranty of any kind, whether express or implied.
> >>> + */
> >>> +
> >>> +#include <linux/kernel.h>
> >>> +#include <linux/version.h>
> >>> +#include <linux/module.h>
> >>> +#include <linux/interrupt.h>
> >>> +#include <linux/delay.h>
> >>> +#include <linux/netdevice.h>
> >>> +#include <linux/if_arp.h>
> >>> +#include <linux/if_ether.h>
> >>> +#include <linux/list.h>
> >>> +#include <linux/delay.h>
> >>> +#include <linux/workqueue.h>
> >>> +#include <linux/io.h>
> >>> +#include <linux/platform_device.h>
> >>> +#include <linux/clk.h>
> >>> +
> >>> +#include <linux/can.h>
> >>> +#include <linux/can/dev.h>
> >>> +#include <linux/can/error.h>
> >>> +
> >>> +#define DRV_NAME "c_can"
> >>> +
> >>> +/* control register */
> >>> +#define CONTROL_TEST               (1 << 7)
> >>> +#define CONTROL_CCE                (1 << 6)
> >>> +#define CONTROL_DISABLE_AR (1 << 5)
> >>> +#define CONTROL_ENABLE_AR  (0 << 5)
> >>> +#define CONTROL_EIE                (1 << 3)
> >>> +#define CONTROL_SIE                (1 << 2)
> >>> +#define CONTROL_IE         (1 << 1)
> >>> +#define CONTROL_INIT               (1 << 0)
> >>> +
> >>> +/* test register */
> >>> +#define TEST_RX                    (1 << 7)
> >>> +#define TEST_TX1           (1 << 6)
> >>> +#define TEST_TX2           (1 << 5)
> >>> +#define TEST_LBACK         (1 << 4)
> >>> +#define TEST_SILENT                (1 << 3)
> >>> +#define TEST_BASIC         (1 << 2)
> >>> +
> >>> +/* status register */
> >>> +#define STATUS_BOFF                (1 << 7)
> >>> +#define STATUS_EWARN               (1 << 6)
> >>> +#define STATUS_EPASS               (1 << 5)
> >>> +#define STATUS_RXOK                (1 << 4)
> >>> +#define STATUS_TXOK                (1 << 3)
> >>> +#define STATUS_LEC_MASK            0x07
> >>> +#define LEC_STUFF_ERROR            1
> >>> +#define LEC_FORM_ERROR             2
> >>> +#define LEC_ACK_ERROR              3
> >>> +#define LEC_BIT1_ERROR             4
> >>> +#define LEC_BIT0_ERROR             5
> >>> +#define LEC_CRC_ERROR              6
> >>
> >> Could be an enum!?
> >
> > Yes LEC error types can be defined as enum, but #define also
> > seems fine.
>
> If you use it with switch, an anonymous enumeration seems more
> appropriate for me.

Ok, I get your point.
V3 will implement LEC as an enum.

> ...
> >>> +static inline int c_can_object_put(struct net_device *dev,
> >>> +                                   int iface, int objno, int mask)
> >>> +{
> >>> +   struct c_can_priv *priv = netdev_priv(dev);
> >>> +   int timeout = (6 / priv->can.clock.freq);
> >>
> >> Hm, "timeout = 0" does not look resonable.
> >
> > Let me see if I get your point here.
> > You mean use something like:
> >
> >         count = 6 /* non-zero count at start */
> >         /* write message object no in IF COMM_REQ reg */
> >         while (count) {
> >                 udelay(timeout);
> >                 count--;
> >         }
> >         /* read BUSY status from IF COM reg */
> >         if (busy)
> >                 return -ETIMEDOUT;
>
> Yes, using a larger repeat count with a shorter delay is more
> efficient,
> I think. And an error message would be nice as well, especially if you
> don't handle the return code.

Ok.

> >>> +           return -ETIMEDOUT;
> >>> +   }
> >>
> >> Is the timeout really needed? If yes, re-trying various times would
> >> more
> >> more safe.
> >
> > Yes timeout is needed as per specs. Please see the approach given
> above.
>
> OK, I just asked because it did work with timeout=0!!!

Oh.. that's strange.
However, if the specs says so we must implement timeout.
I will follow the approach you suggested.

> > If you agree the same can be added in V3.
>
> See above.

Ditto..

> >>> +   return 0;
> >>> +}
> ...
>
> >>> +   stats->rx_packets++;
> >>> +   stats->rx_bytes += frame->can_dlc;
> >>> +
> >>> +   return 0;
> >>
> >> The return values are not handled anywhere!
> >
> > Hmm. This is the tricky part. To be honest, a
> > lot of driver's don't handle all the return values.
> > This function is called from an isr / poll-event.
> > Do you think it's useful to handle the return values
> > there?
>
> Well, if you don't handle the return code just use a *void* function
> and
> print an error message instead, if appropriate.

I agree.

> ...
> >>> +
> >>> +/*
> >>> + * Configure C_CAN message objects for Tx and Rx purposes:
> >>> + * C_CAN provides a total of 32 message objects that can be
> >> configured
> >>> + * either for Tx or Rx purposes. Here the first 16 message objects
> >> are used as
> >>> + * a reception FIFO. The end of reception FIFO is signified by the
> >> EoB bit
> >>> + * being SET. The remaining 16 message objects are kept aside for
> Tx
> >> purposes.
> >>> + * See user guide document for further details on configuring
> >> message
> >>> + * objects.
> >>> + */
> >>
> >> Did you verify *in-order* transmisson and reception? You could use
> the
> >> canfdtest program from the can-utils.
> >
> > I will check V3 for the same.
> > I also checked Marc's at91 driver and the
> > approach implemented there for in-order rx
> > object reception seems fine to me. If you and Marc agree I can
> > use the same here. Also I need to add credits for the same :)
>
> In-order-transmission and reception is *mandatory*. You can also have a
> look to the pch_can driver. As already mentioned above, the "canfdtest"
> program from the "can-utils" is useful to validate that requirement.

I understand that in-order-transmission and reception is mandatory.
I will check the implementation of at91 and pch CAN drivers for the same.
V3 will ensure in-order RX and TX :)

> ...
> >>> +/*
> >>> + * Configure C_CAN chip:
> >>> + * - enable/disable auto-retransmission
> >>> + * - set operating mode
> >>> + * - configure message objects
> >>> + */
> >>> +static int c_can_chip_config(struct net_device *dev)
> >>> +{
> >>> +   struct c_can_priv *priv = netdev_priv(dev);
> >>> +
> >>> +   if (priv->can.ctrlmode & CAN_CTRLMODE_ONE_SHOT)
> >>> +           /* disable automatic retransmission */
> >>> +           priv->write_reg(priv, &priv->reg_base->control,
> >>> +                           CONTROL_DISABLE_AR);
> >>> +   else
> >>> +           /* enable automatic retransmission */
> >>> +           priv->write_reg(priv, &priv->reg_base->control,
> >>> +                           CONTROL_ENABLE_AR);
> >>> +
> >>> +   if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
> >>> +           /* loopback mode : useful for self-test function */
> >>> +           priv->write_reg(priv, &priv->reg_base->control,
> >> (CONTROL_EIE |
> >>> +                           CONTROL_SIE | CONTROL_IE |
> CONTROL_TEST));
> >>> +           priv->write_reg(priv, &priv->reg_base->test,
> TEST_LBACK);
> >>> +   } else if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY) {
> >>> +           /* silent mode : bus-monitoring mode */
> >>> +           priv->write_reg(priv, &priv->reg_base->control,
> >> (CONTROL_EIE |
> >>> +                           CONTROL_SIE | CONTROL_IE |
> CONTROL_TEST));
> >>> +           priv->write_reg(priv, &priv->reg_base->test,
> TEST_SILENT);
> >>> +   } else if (priv->can.ctrlmode & (CAN_CTRLMODE_LISTENONLY &
> >>> +                                   CAN_CTRLMODE_LOOPBACK)) {
> >>
> >> As I see it, this case is never entered.
> >
> > You are right. But as we discussed during the review of V1,
> > as the c_can core supports this mode (loopback + listen-only)
> > we should support the same in the driver as well.
>
> Yes, and therefore you need to check the bits first, otherwise it will
> not work.

Ah.. Right.

> >
> >>> +           /* loopback + silent mode : useful for hot self-test */
> >>> +           priv->write_reg(priv, &priv->reg_base->control,
> >> (CONTROL_EIE |
> >>> +                           CONTROL_SIE | CONTROL_IE |
> CONTROL_TEST));
> >>> +           priv->write_reg(priv, &priv->reg_base->test,
> >>> +                           (TEST_LBACK | TEST_SILENT));
> >>> +   } else
> >>> +           /* normal mode*/
> >>> +           priv->write_reg(priv, &priv->reg_base->control,
> >>> +                           (CONTROL_EIE | CONTROL_SIE |
> CONTROL_IE));
> >>> +
> >>> +   /* configure message objects */
> >>> +   c_can_configure_msg_objects(dev);
> >>> +
> >>> +   return 0;
> >>> +}
>
> ...
>
> >>> +/*
> >>> + * c_can_do_rx_poll - read multiple CAN messages from message
> >> objects
> >>> + */
> >>> +static int c_can_do_rx_poll(struct net_device *dev, int quota)
> >>> +{
> >>> +   u32 num_rx_pkts = 0;
> >>> +   unsigned int msg_obj;
> >>> +   struct c_can_priv *priv = netdev_priv(dev);
> >>> +   u32 val = c_can_read_reg32(priv, &priv->reg_base->newdat1);
> >>> +
> >>> +   while (val & RECEIVE_OBJECT_BITS) {
> >>> +           for (msg_obj = C_CAN_MSG_OBJ_RX_FIRST;
> >>> +                           msg_obj <= C_CAN_MSG_OBJ_RX_LAST;
> msg_obj++) {
> >>> +                   if (val & (1 << msg_obj)) {
> >>> +                           c_can_read_msg_object(dev, 0, msg_obj);
> >>> +                           num_rx_pkts++;
> >>> +                           quota--;
> >>
> >> Where do you handle quota?
> >
> > Sorry but I didn't get your meaning here.
> > Everytime the rx_poll function is called quota is
> > decremented and num of rx packets received is incremented.
> > Am I missing something here?
>
> You should not handle more than "quota" messages in this function. This
> means that it shoud return if quota==0 is reached.

After writing this comment I realized that quota should be checked
against 0 here. V3 will implement the same.

> ...
>
> >>> +   /* check for 'last error code' which tells us the
> >>> +    * type of the last error to occur on the CAN bus
> >>> +    */
> >>> +   if (lec_type) {
> >>> +           /* common for all type of bus errors */
> >>> +           priv->can.can_stats.bus_error++;
> >>> +           stats->rx_errors++;
> >>> +           cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
> >>> +           cf->data[2] |= CAN_ERR_PROT_UNSPEC;
> >>> +
> >>> +           if (lec_type & LEC_STUFF_ERROR) {
> >>> +                   dev_info(dev->dev.parent, "stuff error\n");
> >>> +                   cf->data[2] |= CAN_ERR_PROT_STUFF;
> >>> +           }
> >>> +           if (lec_type & LEC_FORM_ERROR) {
> >>> +                   dev_info(dev->dev.parent, "form error\n");
> >>> +                   cf->data[2] |= CAN_ERR_PROT_FORM;
> >>> +           }
> >>> +           if (lec_type & LEC_ACK_ERROR) {
> >>> +                   dev_info(dev->dev.parent, "ack error\n");
> >>> +                   cf->data[2] |= (CAN_ERR_PROT_LOC_ACK |
> >>> +                                   CAN_ERR_PROT_LOC_ACK_DEL);
> >>> +           }
> >>> +           if (lec_type & LEC_BIT1_ERROR) {
> >>> +                   dev_info(dev->dev.parent, "bit1 error\n");
> >>> +                   cf->data[2] |= CAN_ERR_PROT_BIT1;
> >>> +           }
> >>> +           if (lec_type & LEC_BIT0_ERROR) {
> >>> +                   dev_info(dev->dev.parent, "bit0 error\n");
> >>> +                   cf->data[2] |= CAN_ERR_PROT_BIT0;
> >>> +           }
> >>> +           if (lec_type & LEC_CRC_ERROR) {
> >>> +                   dev_info(dev->dev.parent, "CRC error\n");
> >>
> >> Please use dev_dbg() here and above
> >
> > Ok.
> >
> >>> +                   cf->data[2] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
> >>> +                                   CAN_ERR_PROT_LOC_CRC_DEL);
> >>> +           }
> >>> +   }
> >>
> >> The lec should be handled by a switch statement. Also, please use
> >> dev_dbg in favor of dev_info.
> >
> > But as I have seen on the board, there can be multiple lec bits
> > set at a time (e.g. shorting CAN TX and RX lines). In such cases the
> > multiple-if structure handles the same. Do you agree?
>
> No. Testing the individual bits of an enumeration value does not make
> sense. I just speak about the last error code (lec_type).

Ok.

> >>> +   netif_receive_skb(skb);
> >>> +   stats->rx_packets++;
> >>> +   stats->rx_bytes += cf->can_dlc;
> >>> +
> >>> +   return 1;
> >>> +}
> >>> +
> ...
> >>> +   priv->can.ctrlmode_supported = CAN_CTRLMODE_ONE_SHOT |
> >>> +                                   CAN_CTRLMODE_LOOPBACK |
> >>> +                                   CAN_CTRLMODE_LISTENONLY |
> >>> +                                   CAN_CTRLMODE_BERR_REPORTING;
> >>
> >> Where is CAN_CTRLMODE_BERR_REPORTING implemented? Note that it has
> >> nothing to do with do_get_berr_counter. Please check the SJA1000
> >> driver:
> >>
> >>
> http://lxr.linux.no/#linux+v2.6.36/drivers/net/can/sja1000/sja1000.c#L1
> >> 46
> >>
> >> Bus error handling can be requested by the user via netlink
> interface.
> >>
> >>  # ip link set canX type can ... berr-reporting on
> >>
> >> The driver then usually enables the bus error interrupts. I just
> >> realize
> >> that Documentation/networking/can.txt is not up-to-date. I will
> provide
> >> a patch a.s.a.p.
> >
> > Yes, I have seen the sja1000 implementation before preparing V2.
> > But unfortunately the c_can core does not also only the bus-error-
> reporting
> > to be masked/unmasked. There are three interrupt masks available in
> the
> > Control register:
> >
> > a) Error Interrupt Enable
> > If Enabled - A change in the bits BOff or EWarn in the Status
> Register will
> > generate an interrupt.
> > b) Status Change Interrupt Enable
> > If Enabled - An interrupt will be generated when a message transfer
> is
> > successfully completed or a CAN bus error is detected.
> > c) Module Interrupt Enable
> > If Enabled - Interrupts will set IRQ_B to LOW.
>
> OK, then you should handle it like the flexcan driver. See:
>
> http://lxr.linux.no/#linux+v2.6.36/drivers/net/can/flexcan.c#L533

Ok, I will go through the details give in the flexcan driver

> In the meantime I compared the CAN chapter of the PCH manual with the
> C_CAN manual. The paragraphs I checked are *identical*. This makes
> clear, that the "pch_can" is a clone of the  C_CAN CAN controller, with
> a few extensions, though. Therefore it would make sense, to implement a
> bus sensitive interface like for the SJA1000 allowing to handle both
> CAN
> controllers with one driver sooner than later. Therefore, could you
> please implement:
>
>   drivers/net/can/c_can/c_can.c
>                        /c_can_platform.c
>
> Then an interface to the PCI based PCH CAN controller could be added
> easily, e.g. as "pch_pci.c". You already had something similar in your
> RFC version of the patch, IIRC.

This was the approach I initially proposed in my RFC V1 patch :)
But unfortunately we could not agree to it.
So, please let me reiterate what I understood and what was present
in RFC version of the patch. Please add your comments/views:

        - drivers/net/can/c_can/c_can.c (similar on lines of sja1000.c)
        i.e. a)no *probe* / *remove* functions here,
             b)register read/write implemented here.

        - drivers/net/can/c_can/c_can_platform.c (similar on lines of sja1000_platform.c)
        i.e. *probe* / *remove* implemented here,

Marc and Tomoya can also add their suggestions so that I can finalize V3 a.s.a.p.

> Thanks,
>
> Wolfgang.

Regards,
Bhupesh
