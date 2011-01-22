From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v5 1/1] can: c_can: Added support for Bosch
	C_CAN	controller
Date: Sat, 22 Jan 2011 20:26:30 +0100
Message-ID: <4D3B2F66.8090603@grandegger.com>
References: <1295515238-481-1-git-send-email-bhupesh.sharma@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1295515238-481-1-git-send-email-bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
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

at a closer look, I realized one more issue, apart from some minor ones...

On 01/20/2011 10:20 AM, Bhupesh Sharma wrote:
> Bosch C_CAN controller is a full-CAN implementation which is compliant
> to CAN protocol version 2.0 part A and B. Bosch C_CAN user manual can be
> obtained from:
> http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/
> c_can/users_manual_c_can.pdf
> =

> This patch adds the support for this controller.
> The following are the design choices made while writing the controller
> driver:
> 1. Interface Register set IF1 has be used only in the current design.
> 2. Out of the 32 Message objects available, 16 are kept aside for RX
>    purposes and the rest for TX purposes.
> 3. NAPI implementation is such that both the TX and RX paths function
>    in polling mode.
> =

> Signed-off-by: Bhupesh Sharma <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
> ---
> Changes since V4:
> 	1. Insured correct ISR implementation to allow shared IRQs.
> 	2. To ensure better understanding of message object numbers
> 	   and thierusage modified C_CAN_MSG_OBJ_RX_FIRST value from 0

Typo!

> 	   to 1.
> 	3. Corrected coding style globally.
> 	4. Renamed Interface registers as *ifregs*.
> =

>  drivers/net/can/Kconfig                |    2 +
>  drivers/net/can/Makefile               |    1 +
>  drivers/net/can/c_can/Kconfig          |   15 +
>  drivers/net/can/c_can/Makefile         |    8 +
>  drivers/net/can/c_can/c_can.c          |  958 ++++++++++++++++++++++++++=
++++++
>  drivers/net/can/c_can/c_can.h          |  229 ++++++++
>  drivers/net/can/c_can/c_can_platform.c |  207 +++++++
>  7 files changed, 1420 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/c_can/Kconfig
>  create mode 100644 drivers/net/can/c_can/Makefile
>  create mode 100644 drivers/net/can/c_can/c_can.c
>  create mode 100644 drivers/net/can/c_can/c_can.h
>  create mode 100644 drivers/net/can/c_can/c_can_platform.c
> =

> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 9d9e453..50549b5 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -86,6 +86,8 @@ source "drivers/net/can/mscan/Kconfig"
>  =

>  source "drivers/net/can/sja1000/Kconfig"
>  =

> +source "drivers/net/can/c_can/Kconfig"
> +
>  source "drivers/net/can/usb/Kconfig"
>  =

>  config CAN_DEBUG_DEVICES
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 0057537..c3efeb3 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -11,6 +11,7 @@ obj-y				+=3D usb/
>  =

>  obj-$(CONFIG_CAN_SJA1000)	+=3D sja1000/
>  obj-$(CONFIG_CAN_MSCAN)		+=3D mscan/
> +obj-$(CONFIG_CAN_C_CAN)		+=3D c_can/
>  obj-$(CONFIG_CAN_AT91)		+=3D at91_can.o
>  obj-$(CONFIG_CAN_TI_HECC)	+=3D ti_hecc.o
>  obj-$(CONFIG_CAN_MCP251X)	+=3D mcp251x.o
> diff --git a/drivers/net/can/c_can/Kconfig b/drivers/net/can/c_can/Kconfig
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
> diff --git a/drivers/net/can/c_can/Makefile b/drivers/net/can/c_can/Makef=
ile
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
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
> new file mode 100644
> index 0000000..66a400b
> --- /dev/null
> +++ b/drivers/net/can/c_can/c_can.c

...

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
> +	c_can_object_get(dev, iface, objno, IF_COMM_ALL &
> +						~IF_COMM_TXRQST);

Does fit on one line.

...

> +static void c_can_inval_msg_object(struct net_device *dev, int iface, in=
t objno)
> +{
> +	struct c_can_priv *priv =3D netdev_priv(dev);
> +
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].arb1, 0);
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].arb2, 0);
> +	priv->write_reg(priv, &priv->regs->ifregs[iface].msg_cntrl, 0);
> +
> +	c_can_object_put(dev, iface, objno,
> +				IF_COMM_ARB | IF_COMM_CONTROL);

Ditto

...

> +static inline int c_can_has_and_handle_berr(struct c_can_priv *priv)
> +{
> +	return (priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING) &&
> +		(priv->current_status & STATUS_LEC_MASK);
> +}
> +
> +static int c_can_err(struct net_device *dev,
> +				enum c_can_bus_error_types error_type,
> +				enum c_can_lec_type lec_type)
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
> +	if (error_type & C_CAN_ERROR_WARNING) {
> +		/* error warning state */
> +		priv->can.can_stats.error_warning++;
> +		priv->can.state =3D CAN_STATE_ERROR_WARNING;
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		if (bec.rxerr > 96)
> +			cf->data[1] |=3D CAN_ERR_CRTL_RX_WARNING;
> +		if (bec.txerr > 96)
> +			cf->data[1] |=3D CAN_ERR_CRTL_TX_WARNING;
> +	}
> +	if (error_type & C_CAN_ERROR_PASSIVE) {
> +		/* error passive state */
> +		priv->can.can_stats.error_passive++;
> +		priv->can.state =3D CAN_STATE_ERROR_PASSIVE;
> +		cf->can_id |=3D CAN_ERR_CRTL;
> +		if (rx_err_passive)
> +			cf->data[1] |=3D CAN_ERR_CRTL_RX_PASSIVE;
> +		if (bec.txerr > 127)
> +			cf->data[1] |=3D CAN_ERR_CRTL_TX_PASSIVE;
> +	}
> +	if (error_type & C_CAN_BUS_OFF) {
> +		/* bus-off state */
> +		priv->can.state =3D CAN_STATE_BUS_OFF;
> +		cf->can_id |=3D CAN_ERR_BUSOFF;
> +		/*
> +		 * disable all interrupts in bus-off mode to ensure that
> +		 * the CPU is not hogged down
> +		 */
> +		c_can_enable_all_interrupts(priv, DISABLE_ALL_INTERRUPTS);
> +		can_bus_off(dev);
> +	}
> +
> +	/*
> +	 * check for 'last error code' which tells us the
> +	 * type of the last error to occur on the CAN bus
> +	 */
> +
> +	/* common for all type of bus errors */
> +	priv->can.can_stats.bus_error++;

Does a state change always come together with a bus error?

> +	stats->rx_errors++;
> +	cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
> +	cf->data[2] |=3D CAN_ERR_PROT_UNSPEC;
> +
> +	switch (lec_type) {
> +	case LEC_STUFF_ERROR:
> +		netdev_dbg(dev, "stuff error\n");
> +		cf->data[2] |=3D CAN_ERR_PROT_STUFF;
> +		break;
> +
> +	case LEC_FORM_ERROR:
> +		netdev_dbg(dev, "form error\n");
> +		cf->data[2] |=3D CAN_ERR_PROT_FORM;
> +		break;
> +
> +	case LEC_ACK_ERROR:
> +		netdev_dbg(dev, "ack error\n");
> +		cf->data[2] |=3D (CAN_ERR_PROT_LOC_ACK |
> +				CAN_ERR_PROT_LOC_ACK_DEL);
> +		break;
> +
> +	case LEC_BIT1_ERROR:
> +		netdev_dbg(dev, "bit1 error\n");
> +		cf->data[2] |=3D CAN_ERR_PROT_BIT1;
> +		break;
> +
> +	case LEC_BIT0_ERROR:
> +		netdev_dbg(dev, "bit0 error\n");
> +		cf->data[2] |=3D CAN_ERR_PROT_BIT0;
> +		break;
> +
> +	case LEC_CRC_ERROR:
> +		netdev_dbg(dev, "CRC error\n");
> +		cf->data[2] |=3D (CAN_ERR_PROT_LOC_CRC_SEQ |
> +				CAN_ERR_PROT_LOC_CRC_DEL);
> +		break;
> +	}

>From the C_CAN manual:

"The LEC field holds a code which indicates the type of the last error
to occur on the CAN bus. This field will be cleared to =910=92 when a
message has been transferred (reception or transmission) without error.
The unused code =917=92 may be written by the CPU to check for updates."

Not sure if it's necessary to reset the lec at init and after an error
to 0x7 and check it. More below...

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
> +	enum c_can_bus_error_types error_type =3D C_CAN_NO_ERROR;
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
> +		/* handle bus error events */
> +		if (priv->current_status & STATUS_EWARN) {
> +			netdev_dbg(dev,
> +					"entered error warning state\n");

Does fit on one line.

> +			error_type =3D C_CAN_ERROR_WARNING;
> +		}
> +		if ((priv->current_status & STATUS_EPASS) &&
> +				(!(priv->last_status & STATUS_EPASS))) {
> +			netdev_dbg(dev,
> +					"entered error passive state\n");

Ditto.

> +			error_type =3D C_CAN_ERROR_PASSIVE;
> +		}
> +		if ((priv->current_status & STATUS_BOFF) &&
> +				(!(priv->last_status & STATUS_BOFF))) {
> +			netdev_dbg(dev,
> +					"entered bus off state\n");

Ditto.

> +			error_type =3D C_CAN_BUS_OFF;
> +		}
> +
> +		/* handle bus recovery events */
> +		if ((!(priv->current_status & STATUS_EPASS)) &&
> +				(priv->last_status & STATUS_EPASS)) {
> +			netdev_dbg(dev,
> +					"left error passive state\n");

Ditto.

> +			priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +		}
> +		if ((!(priv->current_status & STATUS_BOFF)) &&
> +				(priv->last_status & STATUS_BOFF)) {
> +			netdev_dbg(dev,
> +					"left bus off state\n");
> +			priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> +		}
> +
> +		priv->last_status =3D priv->current_status;
> +
> +		/* handle error on the bus */
> +		lec_type =3D c_can_has_and_handle_berr(priv);
> +		if (lec_type && (error_type !=3D C_CAN_NO_ERROR))
> +			work_done +=3D c_can_err(dev, error_type, lec_type);

State changes are only reported if berr_reporting is enabled and a bus
error occured. This needs to be fixed.

Feel free to send the output of "candump any,0:0,#FFFFFFFF" when sending
messages without cable connected and with a bus error provocuted.

Apart form that the patch looks really good.

Wolfgang.
