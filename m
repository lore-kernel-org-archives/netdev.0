From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v3 4/4] can: kvaser_usb: Add support for the Usbcan-II
 family
Date: Thu, 08 Jan 2015 12:53:37 +0100
Message-ID: <54AE6FC1.6050007@pengutronix.de>
References: <20141223154654.GB6460@vivalin-002> <20150105174910.GA6304@linux> <20150105175206.GB6304@linux> <20150105175713.GC6304@linux> <20150105183131.GD6304@linux>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="4BINIseljnhuvuEN4rKCb8DPdEXTf2WcW"
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20150105183131.GD6304@linux>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--4BINIseljnhuvuEN4rKCb8DPdEXTf2WcW
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/05/2015 07:31 PM, Ahmed S. Darwish wrote:
> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>=20
> CAN to USB interfaces sold by the Swedish manufacturer Kvaser are
> divided into two major families: 'Leaf', and 'UsbcanII'.  From an
> Operating System perspective, the firmware of both families behave
> in a not too drastically different fashion.
>=20
> This patch adds support for the UsbcanII family of devices to the
> current Kvaser Leaf-only driver.
>=20
> CAN frames sending, receiving, and error handling paths has been
> tested using the dual-channel "Kvaser USBcan II HS/LS" dongle. It
> should also work nicely with other products in the same category.
>=20
> List of new devices supported by this driver update:
>=20
>          - Kvaser USBcan II HS/HS
>          - Kvaser USBcan II HS/LS
>          - Kvaser USBcan Rugged ("USBcan Rev B")
>          - Kvaser Memorator HS/HS
>          - Kvaser Memorator HS/LS
>          - Scania VCI2 (if you have the Kvaser logo on top)
>=20
> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> ---
>  drivers/net/can/usb/Kconfig      |   8 +-
>  drivers/net/can/usb/kvaser_usb.c | 618 +++++++++++++++++++++++++++++++=
--------
>  2 files changed, 503 insertions(+), 123 deletions(-)
>=20
> ** V2 Changelog:
> - Update Kconfig entries
> - Use actual number of CAN channels (instead of max) where appropriate
> - Rebase over a new set of UsbcanII-independent driver fixes
>=20
> ** V3 Changelog:
> - Fix padding for the usbcan_msg_tx_acknowledge command
> - Remove kvaser_usb->max_channels and the MAX_NET_DEVICES macro
> - Rename commands to CMD_LEAF_xxx and CMD_USBCAN_xxx
> - Apply checkpatch.pl suggestions ('net/' comments, multi-line strings,=
 etc.)
>=20
> diff --git a/drivers/net/can/usb/Kconfig b/drivers/net/can/usb/Kconfig
> index a77db919..f6f5500 100644
> --- a/drivers/net/can/usb/Kconfig
> +++ b/drivers/net/can/usb/Kconfig
> @@ -25,7 +25,7 @@ config CAN_KVASER_USB
>  	tristate "Kvaser CAN/USB interface"
>  	---help---
>  	  This driver adds support for Kvaser CAN/USB devices like Kvaser
> -	  Leaf Light.
> +	  Leaf Light and Kvaser USBcan II.
> =20
>  	  The driver provides support for the following devices:
>  	    - Kvaser Leaf Light
> @@ -46,6 +46,12 @@ config CAN_KVASER_USB
>  	    - Kvaser USBcan R
>  	    - Kvaser Leaf Light v2
>  	    - Kvaser Mini PCI Express HS
> +	    - Kvaser USBcan II HS/HS
> +	    - Kvaser USBcan II HS/LS
> +	    - Kvaser USBcan Rugged ("USBcan Rev B")
> +	    - Kvaser Memorator HS/HS
> +	    - Kvaser Memorator HS/LS
> +	    - Scania VCI2 (if you have the Kvaser logo on top)
> =20
>  	  If unsure, say N.
> =20
> diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kva=
ser_usb.c
> index cc7bfc0..43b3928 100644
> --- a/drivers/net/can/usb/kvaser_usb.c
> +++ b/drivers/net/can/usb/kvaser_usb.c
> @@ -6,10 +6,12 @@
>   * Parts of this driver are based on the following:
>   *  - Kvaser linux leaf driver (version 4.78)
>   *  - CAN driver for esd CAN-USB/2
> + *  - Kvaser linux usbcanII driver (version 5.3)
>   *
>   * Copyright (C) 2002-2006 KVASER AB, Sweden. All rights reserved.
>   * Copyright (C) 2010 Matthias Fuchs <matthias.fuchs@esd.eu>, esd gmbh=

>   * Copyright (C) 2012 Olivier Sobrie <olivier@sobrie.be>
> + * Copyright (C) 2015 Valeo Corporation
>   */
> =20
>  #include <linux/completion.h>
> @@ -21,6 +23,15 @@
>  #include <linux/can/dev.h>
>  #include <linux/can/error.h>
> =20
> +/* Kvaser USB CAN dongles are divided into two major families:
> + * - Leaf: Based on Renesas M32C, running firmware labeled as 'filo'
> + * - UsbcanII: Based on Renesas M16C, running firmware labeled as 'hel=
ios'
> + */
> +enum kvaser_usb_family {
> +	KVASER_LEAF,
> +	KVASER_USBCAN,
> +};
> +
>  #define MAX_TX_URBS			16
>  #define MAX_RX_URBS			4
>  #define START_TIMEOUT			1000 /* msecs */
> @@ -30,8 +41,9 @@
>  #define RX_BUFFER_SIZE			3072
>  #define CAN_USB_CLOCK			8000000
>  #define MAX_NET_DEVICES			3
> +#define MAX_USBCAN_NET_DEVICES		2
> =20
> -/* Kvaser USB devices */
> +/* Leaf USB devices */
>  #define KVASER_VENDOR_ID		0x0bfd
>  #define USB_LEAF_DEVEL_PRODUCT_ID	10
>  #define USB_LEAF_LITE_PRODUCT_ID	11
> @@ -55,6 +67,16 @@
>  #define USB_CAN_R_PRODUCT_ID		39
>  #define USB_LEAF_LITE_V2_PRODUCT_ID	288
>  #define USB_MINI_PCIE_HS_PRODUCT_ID	289
> +#define LEAF_PRODUCT_ID(id)		(id >=3D USB_LEAF_DEVEL_PRODUCT_ID && \
> +					 id <=3D USB_MINI_PCIE_HS_PRODUCT_ID)

Can you please convert both *_PRODUCT_ID() macros into static inline
bool functions.

> +
> +/* USBCANII devices */
> +#define USB_USBCAN_REVB_PRODUCT_ID	2
> +#define USB_VCI2_PRODUCT_ID		3
> +#define USB_USBCAN2_PRODUCT_ID		4
> +#define USB_MEMORATOR_PRODUCT_ID	5
> +#define USBCAN_PRODUCT_ID(id)		(id >=3D USB_USBCAN_REVB_PRODUCT_ID && =
\
> +					 id <=3D USB_MEMORATOR_PRODUCT_ID)
> =20
>  /* USB devices features */
>  #define KVASER_HAS_SILENT_MODE		BIT(0)
> @@ -73,7 +95,7 @@
>  #define MSG_FLAG_TX_ACK			BIT(6)
>  #define MSG_FLAG_TX_REQUEST		BIT(7)
> =20
> -/* Can states */
> +/* Can states (M16C CxSTRH register) */
>  #define M16C_STATE_BUS_RESET		BIT(0)
>  #define M16C_STATE_BUS_ERROR		BIT(4)
>  #define M16C_STATE_BUS_PASSIVE		BIT(5)
> @@ -98,7 +120,13 @@
>  #define CMD_START_CHIP_REPLY		27
>  #define CMD_STOP_CHIP			28
>  #define CMD_STOP_CHIP_REPLY		29
> -#define CMD_GET_CARD_INFO2		32
> +#define CMD_READ_CLOCK			30
> +#define CMD_READ_CLOCK_REPLY		31
> +
> +#define CMD_LEAF_GET_CARD_INFO2		32
> +#define CMD_USBCAN_RESET_CLOCK		32
> +#define CMD_USBCAN_CLOCK_OVERFLOW_EVENT	33
> +
>  #define CMD_GET_CARD_INFO		34
>  #define CMD_GET_CARD_INFO_REPLY		35
>  #define CMD_GET_SOFTWARE_INFO		38
> @@ -108,8 +136,9 @@
>  #define CMD_RESET_ERROR_COUNTER		49
>  #define CMD_TX_ACKNOWLEDGE		50
>  #define CMD_CAN_ERROR_EVENT		51
> -#define CMD_USB_THROTTLE		77
> -#define CMD_LOG_MESSAGE			106
> +
> +#define CMD_LEAF_USB_THROTTLE		77
> +#define CMD_LEAF_LOG_MESSAGE		106
> =20
>  /* error factors */
>  #define M16C_EF_ACKE			BIT(0)
> @@ -121,6 +150,14 @@
>  #define M16C_EF_RCVE			BIT(6)
>  #define M16C_EF_TRE			BIT(7)
> =20
> +/* Only Leaf-based devices can report M16C error factors,
> + * thus define our own error status flags for USBCANII
> + */
> +#define USBCAN_ERROR_STATE_NONE		0
> +#define USBCAN_ERROR_STATE_TX_ERROR	BIT(0)
> +#define USBCAN_ERROR_STATE_RX_ERROR	BIT(1)
> +#define USBCAN_ERROR_STATE_BUSERROR	BIT(2)
> +
>  /* bittiming parameters */
>  #define KVASER_USB_TSEG1_MIN		1
>  #define KVASER_USB_TSEG1_MAX		16
> @@ -137,7 +174,7 @@
>  #define KVASER_CTRL_MODE_SELFRECEPTION	3
>  #define KVASER_CTRL_MODE_OFF		4
> =20
> -/* log message */
> +/* Extended CAN identifier flag */
>  #define KVASER_EXTENDED_FRAME		BIT(31)
> =20
>  struct kvaser_msg_simple {
> @@ -148,30 +185,55 @@ struct kvaser_msg_simple {
>  struct kvaser_msg_cardinfo {
>  	u8 tid;
>  	u8 nchannels;
> -	__le32 serial_number;
> -	__le32 padding;
> +	union {
> +		struct {
> +			__le32 serial_number;
> +			__le32 padding;
> +		} __packed leaf0;
> +		struct {
> +			__le32 serial_number_low;
> +			__le32 serial_number_high;
> +		} __packed usbcan0;
> +	} __packed;
>  	__le32 clock_resolution;
>  	__le32 mfgdate;
>  	u8 ean[8];
>  	u8 hw_revision;
> -	u8 usb_hs_mode;
> -	__le16 padding2;
> +	union {
> +		struct {
> +			u8 usb_hs_mode;
> +		} __packed leaf1;
> +		struct {
> +			u8 padding;
> +		} __packed usbcan1;
> +	} __packed;
> +	__le16 padding;
>  } __packed;
> =20
>  struct kvaser_msg_cardinfo2 {
>  	u8 tid;
> -	u8 channel;
> +	u8 reserved;
>  	u8 pcb_id[24];
>  	__le32 oem_unlock_code;
>  } __packed;
> =20
> -struct kvaser_msg_softinfo {
> +struct leaf_msg_softinfo {
>  	u8 tid;
> -	u8 channel;
> +	u8 padding0;
>  	__le32 sw_options;
>  	__le32 fw_version;
>  	__le16 max_outstanding_tx;
> -	__le16 padding[9];
> +	__le16 padding1[9];
> +} __packed;
> +
> +struct usbcan_msg_softinfo {
> +	u8 tid;
> +	u8 fw_name[5];
> +	__le16 max_outstanding_tx;
> +	u8 padding[6];
> +	__le32 fw_version;
> +	__le16 checksum;
> +	__le16 sw_options;
>  } __packed;
> =20
>  struct kvaser_msg_busparams {
> @@ -188,36 +250,86 @@ struct kvaser_msg_tx_can {
>  	u8 channel;
>  	u8 tid;
>  	u8 msg[14];
> -	u8 padding;
> -	u8 flags;
> +	union {
> +		struct {
> +			u8 padding;
> +			u8 flags;
> +		} __packed leaf;
> +		struct {
> +			u8 flags;
> +			u8 padding;
> +		} __packed usbcan;
> +	} __packed;
>  } __packed;
> =20
> -struct kvaser_msg_rx_can {
> +struct kvaser_msg_rx_can_header {
>  	u8 channel;
>  	u8 flag;
> +} __packed;
> +
> +struct leaf_msg_rx_can {
> +	u8 channel;
> +	u8 flag;
> +
>  	__le16 time[3];
>  	u8 msg[14];
>  } __packed;
> =20
> -struct kvaser_msg_chip_state_event {
> +struct usbcan_msg_rx_can {
> +	u8 channel;
> +	u8 flag;
> +
> +	u8 msg[14];
> +	__le16 time;
> +} __packed;
> +
> +struct leaf_msg_chip_state_event {
>  	u8 tid;
>  	u8 channel;
> +
>  	__le16 time[3];
>  	u8 tx_errors_count;
>  	u8 rx_errors_count;
> +
> +	u8 status;
> +	u8 padding[3];
> +} __packed;
> +
> +struct usbcan_msg_chip_state_event {
> +	u8 tid;
> +	u8 channel;
> +
> +	u8 tx_errors_count;
> +	u8 rx_errors_count;
> +	__le16 time;
> +
>  	u8 status;
>  	u8 padding[3];
>  } __packed;
> =20
> -struct kvaser_msg_tx_acknowledge {
> +struct kvaser_msg_tx_acknowledge_header {
> +	u8 channel;
> +	u8 tid;
> +};
> +
> +struct leaf_msg_tx_acknowledge {
>  	u8 channel;
>  	u8 tid;
> +
>  	__le16 time[3];
>  	u8 flags;
>  	u8 time_offset;
>  } __packed;
> =20
> -struct kvaser_msg_error_event {
> +struct usbcan_msg_tx_acknowledge {
> +	u8 channel;
> +	u8 tid;
> +
> +	__le16 time;
> +	__le16 padding;
> +} __packed;
> +
> +struct leaf_msg_error_event {
>  	u8 tid;
>  	u8 flags;
>  	__le16 time[3];
> @@ -229,6 +341,18 @@ struct kvaser_msg_error_event {
>  	u8 error_factor;
>  } __packed;
> =20
> +struct usbcan_msg_error_event {
> +	u8 tid;
> +	u8 padding;
> +	u8 tx_errors_count_ch0;
> +	u8 rx_errors_count_ch0;
> +	u8 tx_errors_count_ch1;
> +	u8 rx_errors_count_ch1;
> +	u8 status_ch0;
> +	u8 status_ch1;
> +	__le16 time;
> +} __packed;
> +
>  struct kvaser_msg_ctrl_mode {
>  	u8 tid;
>  	u8 channel;
> @@ -243,7 +367,7 @@ struct kvaser_msg_flush_queue {
>  	u8 padding[3];
>  } __packed;
> =20
> -struct kvaser_msg_log_message {
> +struct leaf_msg_log_message {
>  	u8 channel;
>  	u8 flags;
>  	__le16 time[3];
> @@ -260,19 +384,50 @@ struct kvaser_msg {
>  		struct kvaser_msg_simple simple;
>  		struct kvaser_msg_cardinfo cardinfo;
>  		struct kvaser_msg_cardinfo2 cardinfo2;
> -		struct kvaser_msg_softinfo softinfo;
>  		struct kvaser_msg_busparams busparams;
> +
> +		struct kvaser_msg_rx_can_header rx_can_header;
> +		struct kvaser_msg_tx_acknowledge_header tx_acknowledge_header;
> +
> +		union {
> +			struct leaf_msg_softinfo softinfo;
> +			struct leaf_msg_rx_can rx_can;
> +			struct leaf_msg_chip_state_event chip_state_event;
> +			struct leaf_msg_tx_acknowledge tx_acknowledge;
> +			struct leaf_msg_error_event error_event;
> +			struct leaf_msg_log_message log_message;
> +		} __packed leaf;
> +
> +		union {
> +			struct usbcan_msg_softinfo softinfo;
> +			struct usbcan_msg_rx_can rx_can;
> +			struct usbcan_msg_chip_state_event chip_state_event;
> +			struct usbcan_msg_tx_acknowledge tx_acknowledge;
> +			struct usbcan_msg_error_event error_event;
> +		} __packed usbcan;
> +
>  		struct kvaser_msg_tx_can tx_can;
> -		struct kvaser_msg_rx_can rx_can;
> -		struct kvaser_msg_chip_state_event chip_state_event;
> -		struct kvaser_msg_tx_acknowledge tx_acknowledge;
> -		struct kvaser_msg_error_event error_event;
>  		struct kvaser_msg_ctrl_mode ctrl_mode;
>  		struct kvaser_msg_flush_queue flush_queue;
> -		struct kvaser_msg_log_message log_message;
>  	} u;
>  } __packed;
> =20
> +/* Leaf/USBCAN-agnostic summary of an error event.
> + * No M16C error factors for USBCAN-based devices.
> + */
> +struct kvaser_error_summary {
> +	u8 channel, status, txerr, rxerr;
> +	union {
> +		struct {
> +			u8 error_factor;
> +		} leaf;
> +		struct {
> +			u8 other_ch_status;
> +			u8 error_state;
> +		} usbcan;
> +	};
> +};
> +
>  struct kvaser_usb_tx_urb_context {
>  	struct kvaser_usb_net_priv *priv;
>  	u32 echo_index;
> @@ -288,6 +443,7 @@ struct kvaser_usb {
> =20
>  	u32 fw_version;
>  	unsigned int nchannels;
> +	enum kvaser_usb_family family;
> =20
>  	bool rxinitdone;
>  	void *rxbuf[MAX_RX_URBS];
> @@ -311,6 +467,7 @@ struct kvaser_usb_net_priv {
>  };
> =20
>  static const struct usb_device_id kvaser_usb_table[] =3D {
> +	/* Leaf family IDs */
>  	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_DEVEL_PRODUCT_ID) },
>  	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_LITE_PRODUCT_ID) },
>  	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_PRO_PRODUCT_ID),
> @@ -360,6 +517,17 @@ static const struct usb_device_id kvaser_usb_table=
[] =3D {
>  		.driver_info =3D KVASER_HAS_TXRX_ERRORS },
>  	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_LITE_V2_PRODUCT_ID) },
>  	{ USB_DEVICE(KVASER_VENDOR_ID, USB_MINI_PCIE_HS_PRODUCT_ID) },
> +
> +	/* USBCANII family IDs */
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_USBCAN2_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_USBCAN_REVB_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_MEMORATOR_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_VCI2_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS },
> +
>  	{ }
>  };
>  MODULE_DEVICE_TABLE(usb, kvaser_usb_table);
> @@ -463,7 +631,18 @@ static int kvaser_usb_get_software_info(struct kva=
ser_usb *dev)
>  	if (err)
>  		return err;
> =20
> -	dev->fw_version =3D le32_to_cpu(msg.u.softinfo.fw_version);
> +	switch (dev->family) {
> +	case KVASER_LEAF:
> +		dev->fw_version =3D le32_to_cpu(msg.u.leaf.softinfo.fw_version);
> +		break;
> +	case KVASER_USBCAN:
> +		dev->fw_version =3D le32_to_cpu(msg.u.usbcan.softinfo.fw_version);
> +		break;
> +	default:
> +		dev_err(dev->udev->dev.parent,
> +			"Invalid device family (%d)\n", dev->family);
> +		return -EINVAL;

The default case should not happen. I think you can remove it.

> +	}
> =20
>  	return 0;
>  }
> @@ -484,6 +663,9 @@ static int kvaser_usb_get_card_info(struct kvaser_u=
sb *dev)
>  	dev->nchannels =3D msg.u.cardinfo.nchannels;
>  	if (dev->nchannels > MAX_NET_DEVICES)
>  		return -EINVAL;
> +	if (dev->family =3D=3D KVASER_USBCAN &&
> +	    dev->nchannels > MAX_USBCAN_NET_DEVICES)
> +		return -EINVAL;

Nitpick, as the new "if" also does a test on nchannels, why no extend
the existing "if" with an "||"?

> =20
>  	return 0;
>  }
> @@ -496,8 +678,10 @@ static void kvaser_usb_tx_acknowledge(const struct=
 kvaser_usb *dev,
>  	struct kvaser_usb_net_priv *priv;
>  	struct sk_buff *skb;
>  	struct can_frame *cf;
> -	u8 channel =3D msg->u.tx_acknowledge.channel;
> -	u8 tid =3D msg->u.tx_acknowledge.tid;
> +	u8 channel, tid;
> +
> +	channel =3D msg->u.tx_acknowledge_header.channel;
> +	tid =3D msg->u.tx_acknowledge_header.tid;
> =20
>  	if (channel >=3D dev->nchannels) {
>  		dev_err(dev->udev->dev.parent,
> @@ -615,37 +799,80 @@ static void kvaser_usb_unlink_tx_urbs(struct kvas=
er_usb_net_priv *priv)
>  		priv->tx_contexts[i].echo_index =3D MAX_TX_URBS;
>  }
> =20
> -static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
> -				const struct kvaser_msg *msg)
> +static void kvaser_report_error_event(const struct kvaser_usb *dev,
> +				      struct kvaser_error_summary *es);

Please rearange your code that forward declarations are not needed (if
possible - I haven't checked, though).

> +
> +/* Report error to userspace iff the controller's errors counter has
> + * increased, or we're the only channel seeing the bus error state.
> + *
> + * As reported by USBCAN sheets, "the CAN controller has difficulties
> + * to tell whether an error frame arrived on channel 1 or on channel 2=
=2E"
> + * Thus, error counters are compared with their earlier values to
> + * determine which channel was responsible for the error event.

Your code doesn't match this comment. You compare the error counters
against the old values to tell if it's a rx or tx error, the channel
information from the struct kvaser_error_summary is used directly.

> + */
> +static void usbcan_report_error_if_applicable(const struct kvaser_usb =
*dev,
> +					      struct kvaser_error_summary *es)

Nitpick: can you please add a "kvaser_" prefix to the all usbcan_* and
leaf_* functions.

>  {
> -	struct can_frame *cf;
> -	struct sk_buff *skb;
> -	struct net_device_stats *stats;
>  	struct kvaser_usb_net_priv *priv;
> -	unsigned int new_state;
> -	u8 channel, status, txerr, rxerr, error_factor;
> +	int old_tx_err_count, old_rx_err_count, channel, report_error;

bool report_error;

> +
> +	channel =3D es->channel;
> +	if (channel >=3D dev->nchannels) {
> +		dev_err(dev->udev->dev.parent,
> +			"Invalid channel number (%d)\n", channel);
> +		return;
> +	}
> +
> +	priv =3D dev->nets[channel];
> +	old_tx_err_count =3D priv->bec.txerr;
> +	old_rx_err_count =3D priv->bec.rxerr;

Why do you make a copy of priv->bec, AFAICS you can use
priv->bec.{r,t}xerr directly?

> +
> +	report_error =3D 0;
> +	if (es->txerr > old_tx_err_count) {
> +		es->usbcan.error_state |=3D USBCAN_ERROR_STATE_TX_ERROR;
> +		report_error =3D 1;
> +	}
> +	if (es->rxerr > old_rx_err_count) {
> +		es->usbcan.error_state |=3D USBCAN_ERROR_STATE_RX_ERROR;
> +		report_error =3D 1;
> +	}
> +	if ((es->status & M16C_STATE_BUS_ERROR) &&
> +	    !(es->usbcan.other_ch_status & M16C_STATE_BUS_ERROR)) {
> +		es->usbcan.error_state |=3D USBCAN_ERROR_STATE_BUSERROR;
> +		report_error =3D 1;
> +	}
> +
> +	if (report_error)
> +		kvaser_report_error_event(dev, es);
> +}
> +
> +/* Extract error summary from a Leaf-based device error message */
> +static void leaf_extract_error_from_msg(const struct kvaser_usb *dev,
> +					const struct kvaser_msg *msg)
> +{
> +	struct kvaser_error_summary es =3D { 0, };

IIRC "es =3D { };" should be sufficient.

> =20
>  	switch (msg->id) {
>  	case CMD_CAN_ERROR_EVENT:
> -		channel =3D msg->u.error_event.channel;
> -		status =3D  msg->u.error_event.status;
> -		txerr =3D msg->u.error_event.tx_errors_count;
> -		rxerr =3D msg->u.error_event.rx_errors_count;
> -		error_factor =3D msg->u.error_event.error_factor;
> +		es.channel =3D msg->u.leaf.error_event.channel;
> +		es.status =3D  msg->u.leaf.error_event.status;
> +		es.txerr =3D msg->u.leaf.error_event.tx_errors_count;
> +		es.rxerr =3D msg->u.leaf.error_event.rx_errors_count;
> +		es.leaf.error_factor =3D msg->u.leaf.error_event.error_factor;
>  		break;
> -	case CMD_LOG_MESSAGE:
> -		channel =3D msg->u.log_message.channel;
> -		status =3D msg->u.log_message.data[0];
> -		txerr =3D msg->u.log_message.data[2];
> -		rxerr =3D msg->u.log_message.data[3];
> -		error_factor =3D msg->u.log_message.data[1];
> +	case CMD_LEAF_LOG_MESSAGE:
> +		es.channel =3D msg->u.leaf.log_message.channel;
> +		es.status =3D msg->u.leaf.log_message.data[0];
> +		es.txerr =3D msg->u.leaf.log_message.data[2];
> +		es.rxerr =3D msg->u.leaf.log_message.data[3];
> +		es.leaf.error_factor =3D msg->u.leaf.log_message.data[1];
>  		break;
>  	case CMD_CHIP_STATE_EVENT:
> -		channel =3D msg->u.chip_state_event.channel;
> -		status =3D  msg->u.chip_state_event.status;
> -		txerr =3D msg->u.chip_state_event.tx_errors_count;
> -		rxerr =3D msg->u.chip_state_event.rx_errors_count;
> -		error_factor =3D 0;
> +		es.channel =3D msg->u.leaf.chip_state_event.channel;
> +		es.status =3D  msg->u.leaf.chip_state_event.status;
> +		es.txerr =3D msg->u.leaf.chip_state_event.tx_errors_count;
> +		es.rxerr =3D msg->u.leaf.chip_state_event.rx_errors_count;
> +		es.leaf.error_factor =3D 0;
>  		break;
>  	default:
>  		dev_err(dev->udev->dev.parent, "Invalid msg id (%d)\n",
> @@ -653,16 +880,92 @@ static void kvaser_usb_rx_error(const struct kvas=
er_usb *dev,
>  		return;
>  	}
> =20
> -	if (channel >=3D dev->nchannels) {
> +	kvaser_report_error_event(dev, &es);
> +}
> +
> +/* Extract error summary from a USBCANII-based device error message */=

> +static void usbcan_extract_error_from_msg(const struct kvaser_usb *dev=
,
> +					  const struct kvaser_msg *msg)
> +{
> +	struct kvaser_error_summary es =3D { 0, };

same here.

> +
> +	switch (msg->id) {
> +	/* Sometimes errors are sent as unsolicited chip state events */
> +	case CMD_CHIP_STATE_EVENT:
> +		es.channel =3D msg->u.usbcan.chip_state_event.channel;
> +		es.status =3D  msg->u.usbcan.chip_state_event.status;
> +		es.txerr =3D msg->u.usbcan.chip_state_event.tx_errors_count;
> +		es.rxerr =3D msg->u.usbcan.chip_state_event.rx_errors_count;
> +		usbcan_report_error_if_applicable(dev, &es);
> +		break;
> +
> +	case CMD_CAN_ERROR_EVENT:
> +		es.channel =3D 0;
> +		es.status =3D msg->u.usbcan.error_event.status_ch0;
> +		es.txerr =3D msg->u.usbcan.error_event.tx_errors_count_ch0;
> +		es.rxerr =3D msg->u.usbcan.error_event.rx_errors_count_ch0;
> +		es.usbcan.other_ch_status =3D
> +			msg->u.usbcan.error_event.status_ch1;
> +		usbcan_report_error_if_applicable(dev, &es);
> +
> +		/* For error events, the USBCAN firmware does not support
> +		 * more than 2 channels: ch0, and ch1.
> +		 */
> +		if (dev->nchannels > 1) {
> +			es.channel =3D 1;

Why is channel =3D=3D 1 if the device has more than 1 channel?

> +			es.status =3D msg->u.usbcan.error_event.status_ch1;
> +			es.txerr =3D
> +				msg->u.usbcan.error_event.tx_errors_count_ch1;
> +			es.rxerr =3D
> +				msg->u.usbcan.error_event.rx_errors_count_ch1;
> +			es.usbcan.other_ch_status =3D
> +				msg->u.usbcan.error_event.status_ch0;
> +			usbcan_report_error_if_applicable(dev, &es);
> +		}
> +		break;
> +
> +	default:
> +		dev_err(dev->udev->dev.parent, "Invalid msg id (%d)\n",
> +			msg->id);
> +	}
> +}
> +
> +static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
> +				const struct kvaser_msg *msg)
> +{
> +	switch (dev->family) {
> +	case KVASER_LEAF:
> +		leaf_extract_error_from_msg(dev, msg);
> +		break;
> +	case KVASER_USBCAN:
> +		usbcan_extract_error_from_msg(dev, msg);
> +		break;
> +	default:
should not happen.
>  		dev_err(dev->udev->dev.parent,
> -			"Invalid channel number (%d)\n", channel);
> +			"Invalid device family (%d)\n", dev->family);
>  		return;
>  	}
> +}
> =20
> -	priv =3D dev->nets[channel];
> +static void kvaser_report_error_event(const struct kvaser_usb *dev,
> +				      struct kvaser_error_summary *es)
> +{
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	struct net_device_stats *stats;
> +	struct kvaser_usb_net_priv *priv;
> +	unsigned int new_state;
> +
> +	if (es->channel >=3D dev->nchannels) {
> +		dev_err(dev->udev->dev.parent,
> +			"Invalid channel number (%d)\n", es->channel);
> +		return;
> +	}
> +
> +	priv =3D dev->nets[es->channel];
>  	stats =3D &priv->netdev->stats;
> =20
> -	if (status & M16C_STATE_BUS_RESET) {
> +	if (es->status & M16C_STATE_BUS_RESET) {
>  		kvaser_usb_unlink_tx_urbs(priv);
>  		return;
>  	}
> @@ -675,9 +978,9 @@ static void kvaser_usb_rx_error(const struct kvaser=
_usb *dev,
> =20
>  	new_state =3D priv->can.state;
> =20
> -	netdev_dbg(priv->netdev, "Error status: 0x%02x\n", status);
> +	netdev_dbg(priv->netdev, "Error status: 0x%02x\n", es->status);
> =20
> -	if (status & M16C_STATE_BUS_OFF) {
> +	if (es->status & M16C_STATE_BUS_OFF) {
>  		cf->can_id |=3D CAN_ERR_BUSOFF;
> =20
>  		priv->can.can_stats.bus_off++;
> @@ -687,12 +990,12 @@ static void kvaser_usb_rx_error(const struct kvas=
er_usb *dev,
>  		netif_carrier_off(priv->netdev);
> =20
>  		new_state =3D CAN_STATE_BUS_OFF;
> -	} else if (status & M16C_STATE_BUS_PASSIVE) {
> +	} else if (es->status & M16C_STATE_BUS_PASSIVE) {
>  		if (priv->can.state !=3D CAN_STATE_ERROR_PASSIVE) {
>  			cf->can_id |=3D CAN_ERR_CRTL;
> =20
> -			if (txerr || rxerr)
> -				cf->data[1] =3D (txerr > rxerr)
> +			if (es->txerr || es->rxerr)
> +				cf->data[1] =3D (es->txerr > es->rxerr)
>  						? CAN_ERR_CRTL_TX_PASSIVE
>  						: CAN_ERR_CRTL_RX_PASSIVE;
>  			else
> @@ -703,13 +1006,11 @@ static void kvaser_usb_rx_error(const struct kva=
ser_usb *dev,
>  		}
> =20
>  		new_state =3D CAN_STATE_ERROR_PASSIVE;
> -	}
> -
> -	if (status =3D=3D M16C_STATE_BUS_ERROR) {
> +	} else if (es->status & M16C_STATE_BUS_ERROR) {
>  		if ((priv->can.state < CAN_STATE_ERROR_WARNING) &&
> -		    ((txerr >=3D 96) || (rxerr >=3D 96))) {
> +		    ((es->txerr >=3D 96) || (es->rxerr >=3D 96))) {
>  			cf->can_id |=3D CAN_ERR_CRTL;
> -			cf->data[1] =3D (txerr > rxerr)
> +			cf->data[1] =3D (es->txerr > es->rxerr)
>  					? CAN_ERR_CRTL_TX_WARNING
>  					: CAN_ERR_CRTL_RX_WARNING;
> =20
> @@ -723,7 +1024,7 @@ static void kvaser_usb_rx_error(const struct kvase=
r_usb *dev,
>  		}
>  	}
> =20
> -	if (!status) {
> +	if (!es->status) {
>  		cf->can_id |=3D CAN_ERR_PROT;
>  		cf->data[2] =3D CAN_ERR_PROT_ACTIVE;
> =20
> @@ -739,34 +1040,52 @@ static void kvaser_usb_rx_error(const struct kva=
ser_usb *dev,
>  		priv->can.can_stats.restarts++;
>  	}
> =20
> -	if (error_factor) {
> -		priv->can.can_stats.bus_error++;
> -		stats->rx_errors++;
> -
> -		cf->can_id |=3D CAN_ERR_BUSERROR | CAN_ERR_PROT;
> -
> -		if (error_factor & M16C_EF_ACKE)
> -			cf->data[3] |=3D (CAN_ERR_PROT_LOC_ACK);
> -		if (error_factor & M16C_EF_CRCE)
> -			cf->data[3] |=3D (CAN_ERR_PROT_LOC_CRC_SEQ |
> -					CAN_ERR_PROT_LOC_CRC_DEL);
> -		if (error_factor & M16C_EF_FORME)
> -			cf->data[2] |=3D CAN_ERR_PROT_FORM;
> -		if (error_factor & M16C_EF_STFE)
> -			cf->data[2] |=3D CAN_ERR_PROT_STUFF;
> -		if (error_factor & M16C_EF_BITE0)
> -			cf->data[2] |=3D CAN_ERR_PROT_BIT0;
> -		if (error_factor & M16C_EF_BITE1)
> -			cf->data[2] |=3D CAN_ERR_PROT_BIT1;
> -		if (error_factor & M16C_EF_TRE)
> -			cf->data[2] |=3D CAN_ERR_PROT_TX;
> +	switch (dev->family) {
> +	case KVASER_LEAF:
> +		if (es->leaf.error_factor) {
> +			priv->can.can_stats.bus_error++;
> +			stats->rx_errors++;
> +
> +			cf->can_id |=3D CAN_ERR_BUSERROR | CAN_ERR_PROT;
> +
> +			if (es->leaf.error_factor & M16C_EF_ACKE)
> +				cf->data[3] |=3D (CAN_ERR_PROT_LOC_ACK);
> +			if (es->leaf.error_factor & M16C_EF_CRCE)
> +				cf->data[3] |=3D (CAN_ERR_PROT_LOC_CRC_SEQ |
> +						CAN_ERR_PROT_LOC_CRC_DEL);
> +			if (es->leaf.error_factor & M16C_EF_FORME)
> +				cf->data[2] |=3D CAN_ERR_PROT_FORM;
> +			if (es->leaf.error_factor & M16C_EF_STFE)
> +				cf->data[2] |=3D CAN_ERR_PROT_STUFF;
> +			if (es->leaf.error_factor & M16C_EF_BITE0)
> +				cf->data[2] |=3D CAN_ERR_PROT_BIT0;
> +			if (es->leaf.error_factor & M16C_EF_BITE1)
> +				cf->data[2] |=3D CAN_ERR_PROT_BIT1;
> +			if (es->leaf.error_factor & M16C_EF_TRE)
> +				cf->data[2] |=3D CAN_ERR_PROT_TX;
> +		}
> +		break;
> +	case KVASER_USBCAN:
> +		if (es->usbcan.error_state & USBCAN_ERROR_STATE_TX_ERROR)
> +			stats->tx_errors++;
> +		if (es->usbcan.error_state & USBCAN_ERROR_STATE_RX_ERROR)
> +			stats->rx_errors++;
> +		if (es->usbcan.error_state & USBCAN_ERROR_STATE_BUSERROR) {
> +			priv->can.can_stats.bus_error++;
> +			cf->can_id |=3D CAN_ERR_BUSERROR;
> +		}
> +		break;
> +	default:
> +		dev_err(dev->udev->dev.parent,
> +			"Invalid device family (%d)\n", dev->family);
> +		goto err;

should not happen.

>  	}
> =20
> -	cf->data[6] =3D txerr;
> -	cf->data[7] =3D rxerr;
> +	cf->data[6] =3D es->txerr;
> +	cf->data[7] =3D es->rxerr;
> =20
> -	priv->bec.txerr =3D txerr;
> -	priv->bec.rxerr =3D rxerr;
> +	priv->bec.txerr =3D es->txerr;
> +	priv->bec.rxerr =3D es->rxerr;
> =20
>  	priv->can.state =3D new_state;
> =20
> @@ -774,6 +1093,11 @@ static void kvaser_usb_rx_error(const struct kvas=
er_usb *dev,
> =20
>  	stats->rx_packets++;
>  	stats->rx_bytes +=3D cf->can_dlc;
> +
> +	return;
> +
> +err:
> +	dev_kfree_skb(skb);
>  }
> =20
>  static void kvaser_usb_rx_can_err(const struct kvaser_usb_net_priv *pr=
iv,
> @@ -783,16 +1107,16 @@ static void kvaser_usb_rx_can_err(const struct k=
vaser_usb_net_priv *priv,
>  	struct sk_buff *skb;
>  	struct net_device_stats *stats =3D &priv->netdev->stats;
> =20
> -	if (msg->u.rx_can.flag & (MSG_FLAG_ERROR_FRAME |
> +	if (msg->u.rx_can_header.flag & (MSG_FLAG_ERROR_FRAME |
>  					 MSG_FLAG_NERR)) {
>  		netdev_err(priv->netdev, "Unknow error (flags: 0x%02x)\n",
> -			   msg->u.rx_can.flag);
> +			   msg->u.rx_can_header.flag);
> =20
>  		stats->rx_errors++;
>  		return;
>  	}
> =20
> -	if (msg->u.rx_can.flag & MSG_FLAG_OVERRUN) {
> +	if (msg->u.rx_can_header.flag & MSG_FLAG_OVERRUN) {
>  		skb =3D alloc_can_err_skb(priv->netdev, &cf);
> 		if (!skb) {
> 			stats->rx_dropped++;
> 			return;
> 		}

Can you prepare a (seperate) patch that does the stats, even in case of O=
OM here. Same for kvaser_report_error_event()

>=20
> 		cf->can_id |=3D CAN_ERR_CRTL;
> 		cf->data[1] =3D CAN_ERR_CRTL_RX_OVERFLOW;
>=20
> 		stats->rx_over_errors++;
> 		stats->rx_errors++;
>=20
> 		netif_rx(skb);
>=20
> 		stats->rx_packets++;
> 		stats->rx_bytes +=3D cf->can_dlc;

Another patch would be not to touch cf after netif_rx(), please move the =
stats handling before calling netif_rx(). Same applies to the kvaser_usb_=
rx_can_msg() function.

> 	}

> @@ -819,7 +1143,8 @@ static void kvaser_usb_rx_can_msg(const struct kva=
ser_usb *dev,
>  	struct can_frame *cf;
>  	struct sk_buff *skb;
>  	struct net_device_stats *stats;
> -	u8 channel =3D msg->u.rx_can.channel;
> +	u8 channel =3D msg->u.rx_can_header.channel;
> +	const u8 *rx_msg;
> =20
>  	if (channel >=3D dev->nchannels) {
>  		dev_err(dev->udev->dev.parent,
> @@ -830,19 +1155,32 @@ static void kvaser_usb_rx_can_msg(const struct k=
vaser_usb *dev,
>  	priv =3D dev->nets[channel];
>  	stats =3D &priv->netdev->stats;
> =20
> -	if ((msg->u.rx_can.flag & MSG_FLAG_ERROR_FRAME) &&
> -	    (msg->id =3D=3D CMD_LOG_MESSAGE)) {
> +	if ((msg->u.rx_can_header.flag & MSG_FLAG_ERROR_FRAME) &&
> +	    (dev->family =3D=3D KVASER_LEAF && msg->id =3D=3D CMD_LEAF_LOG_ME=
SSAGE)) {
>  		kvaser_usb_rx_error(dev, msg);
>  		return;
> -	} else if (msg->u.rx_can.flag & (MSG_FLAG_ERROR_FRAME |
> -					 MSG_FLAG_NERR |
> -					 MSG_FLAG_OVERRUN)) {
> +	} else if (msg->u.rx_can_header.flag & (MSG_FLAG_ERROR_FRAME |
> +						MSG_FLAG_NERR |
> +						MSG_FLAG_OVERRUN)) {
>  		kvaser_usb_rx_can_err(priv, msg);
>  		return;
> -	} else if (msg->u.rx_can.flag & ~MSG_FLAG_REMOTE_FRAME) {
> +	} else if (msg->u.rx_can_header.flag & ~MSG_FLAG_REMOTE_FRAME) {
>  		netdev_warn(priv->netdev,
>  			    "Unhandled frame (flags: 0x%02x)",
> -			    msg->u.rx_can.flag);
> +			    msg->u.rx_can_header.flag);
> +		return;
> +	}
> +
> +	switch (dev->family) {
> +	case KVASER_LEAF:
> +		rx_msg =3D msg->u.leaf.rx_can.msg;
> +		break;
> +	case KVASER_USBCAN:
> +		rx_msg =3D msg->u.usbcan.rx_can.msg;
> +		break;
> +	default:
> +		dev_err(dev->udev->dev.parent,
> +			"Invalid device family (%d)\n", dev->family);
>  		return;
>  	}
> =20
> @@ -852,38 +1190,37 @@ static void kvaser_usb_rx_can_msg(const struct k=
vaser_usb *dev,
>  		return;
>  	}
> =20
> -	if (msg->id =3D=3D CMD_LOG_MESSAGE) {
> -		cf->can_id =3D le32_to_cpu(msg->u.log_message.id);
> +	if (dev->family =3D=3D KVASER_LEAF && msg->id =3D=3D CMD_LEAF_LOG_MES=
SAGE) {
> +		cf->can_id =3D le32_to_cpu(msg->u.leaf.log_message.id);
>  		if (cf->can_id & KVASER_EXTENDED_FRAME)
>  			cf->can_id &=3D CAN_EFF_MASK | CAN_EFF_FLAG;
>  		else
>  			cf->can_id &=3D CAN_SFF_MASK;
> =20
> -		cf->can_dlc =3D get_can_dlc(msg->u.log_message.dlc);
> +		cf->can_dlc =3D get_can_dlc(msg->u.leaf.log_message.dlc);
> =20
> -		if (msg->u.log_message.flags & MSG_FLAG_REMOTE_FRAME)
> +		if (msg->u.leaf.log_message.flags & MSG_FLAG_REMOTE_FRAME)
>  			cf->can_id |=3D CAN_RTR_FLAG;
>  		else
> -			memcpy(cf->data, &msg->u.log_message.data,
> +			memcpy(cf->data, &msg->u.leaf.log_message.data,
>  			       cf->can_dlc);
>  	} else {
> -		cf->can_id =3D ((msg->u.rx_can.msg[0] & 0x1f) << 6) |
> -			     (msg->u.rx_can.msg[1] & 0x3f);
> +		cf->can_id =3D ((rx_msg[0] & 0x1f) << 6) | (rx_msg[1] & 0x3f);
> =20
>  		if (msg->id =3D=3D CMD_RX_EXT_MESSAGE) {
>  			cf->can_id <<=3D 18;
> -			cf->can_id |=3D ((msg->u.rx_can.msg[2] & 0x0f) << 14) |
> -				      ((msg->u.rx_can.msg[3] & 0xff) << 6) |
> -				      (msg->u.rx_can.msg[4] & 0x3f);
> +			cf->can_id |=3D ((rx_msg[2] & 0x0f) << 14) |
> +				      ((rx_msg[3] & 0xff) << 6) |
> +				      (rx_msg[4] & 0x3f);
>  			cf->can_id |=3D CAN_EFF_FLAG;
>  		}
> =20
> -		cf->can_dlc =3D get_can_dlc(msg->u.rx_can.msg[5]);
> +		cf->can_dlc =3D get_can_dlc(rx_msg[5]);
> =20
> -		if (msg->u.rx_can.flag & MSG_FLAG_REMOTE_FRAME)
> +		if (msg->u.rx_can_header.flag & MSG_FLAG_REMOTE_FRAME)
>  			cf->can_id |=3D CAN_RTR_FLAG;
>  		else
> -			memcpy(cf->data, &msg->u.rx_can.msg[6],
> +			memcpy(cf->data, &rx_msg[6],
>  			       cf->can_dlc);
>  	}
> =20
> @@ -947,7 +1284,12 @@ static void kvaser_usb_handle_message(const struc=
t kvaser_usb *dev,
> =20
>  	case CMD_RX_STD_MESSAGE:
>  	case CMD_RX_EXT_MESSAGE:
> -	case CMD_LOG_MESSAGE:
> +		kvaser_usb_rx_can_msg(dev, msg);
> +		break;
> +
> +	case CMD_LEAF_LOG_MESSAGE:
> +		if (dev->family !=3D KVASER_LEAF)
> +			goto warn;
>  		kvaser_usb_rx_can_msg(dev, msg);
>  		break;
> =20
> @@ -960,8 +1302,14 @@ static void kvaser_usb_handle_message(const struc=
t kvaser_usb *dev,
>  		kvaser_usb_tx_acknowledge(dev, msg);
>  		break;
> =20
> +	/* Ignored messages */
> +	case CMD_USBCAN_CLOCK_OVERFLOW_EVENT:
> +		if (dev->family !=3D KVASER_USBCAN)
> +			goto warn;
> +		break;
> +
>  	default:
> -		dev_warn(dev->udev->dev.parent,
> +warn:		dev_warn(dev->udev->dev.parent,
>  			 "Unhandled message (%d)\n", msg->id);
>  		break;
>  	}
> @@ -1181,7 +1529,7 @@ static void kvaser_usb_unlink_all_urbs(struct kva=
ser_usb *dev)
>  				  dev->rxbuf[i],
>  				  dev->rxbuf_dma[i]);
> =20
> -	for (i =3D 0; i < MAX_NET_DEVICES; i++) {
> +	for (i =3D 0; i < dev->nchannels; i++) {
>  		struct kvaser_usb_net_priv *priv =3D dev->nets[i];
> =20
>  		if (priv)
> @@ -1289,6 +1637,7 @@ static netdev_tx_t kvaser_usb_start_xmit(struct s=
k_buff *skb,
>  	struct kvaser_msg *msg;
>  	int i, err;
>  	int ret =3D NETDEV_TX_OK;
> +	uint8_t *msg_tx_can_flags;
> =20
>  	if (can_dropped_invalid_skb(netdev, skb))
>  		return NETDEV_TX_OK;
> @@ -1310,9 +1659,23 @@ static netdev_tx_t kvaser_usb_start_xmit(struct =
sk_buff *skb,
> =20
>  	msg =3D buf;
>  	msg->len =3D MSG_HEADER_LEN + sizeof(struct kvaser_msg_tx_can);
> -	msg->u.tx_can.flags =3D 0;
>  	msg->u.tx_can.channel =3D priv->channel;
> =20
> +	switch (dev->family) {
> +	case KVASER_LEAF:
> +		msg_tx_can_flags =3D &msg->u.tx_can.leaf.flags;
> +		break;
> +	case KVASER_USBCAN:
> +		msg_tx_can_flags =3D &msg->u.tx_can.usbcan.flags;
> +		break;
> +	default:
> +		dev_err(dev->udev->dev.parent,
> +			"Invalid device family (%d)\n", dev->family);
> +		goto releasebuf;
> +	}
> +
> +	*msg_tx_can_flags =3D 0;
> +
>  	if (cf->can_id & CAN_EFF_FLAG) {
>  		msg->id =3D CMD_TX_EXT_MESSAGE;
>  		msg->u.tx_can.msg[0] =3D (cf->can_id >> 24) & 0x1f;
> @@ -1330,7 +1693,7 @@ static netdev_tx_t kvaser_usb_start_xmit(struct s=
k_buff *skb,
>  	memcpy(&msg->u.tx_can.msg[6], cf->data, cf->can_dlc);
> =20
>  	if (cf->can_id & CAN_RTR_FLAG)
> -		msg->u.tx_can.flags |=3D MSG_FLAG_REMOTE_FRAME;
> +		*msg_tx_can_flags |=3D MSG_FLAG_REMOTE_FRAME;
> =20
>  	for (i =3D 0; i < ARRAY_SIZE(priv->tx_contexts); i++) {
>  		if (priv->tx_contexts[i].echo_index =3D=3D MAX_TX_URBS) {
> @@ -1599,6 +1962,17 @@ static int kvaser_usb_probe(struct usb_interface=
 *intf,
>  	if (!dev)
>  		return -ENOMEM;
> =20
> +	if (LEAF_PRODUCT_ID(id->idProduct)) {
> +		dev->family =3D KVASER_LEAF;
> +	} else if (USBCAN_PRODUCT_ID(id->idProduct)) {
> +		dev->family =3D KVASER_USBCAN;
> +	} else {
> +		dev_err(&intf->dev,
> +			"Product ID (%d) does not belong to any known Kvaser USB family",
> +			id->idProduct);
> +		return -ENODEV;
> +	}
> +
>  	err =3D kvaser_usb_get_endpoints(intf, &dev->bulk_in, &dev->bulk_out)=
;
>  	if (err) {
>  		dev_err(&intf->dev, "Cannot get usb endpoint(s)");

regards,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--4BINIseljnhuvuEN4rKCb8DPdEXTf2WcW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUrm/EAAoJECte4hHFiupUTOQP/1sZuniHxr93UiO+eSD+hJXI
QAGRFMOHjbk8RlVH4LGmntJai2PnzjQcQWchTDIWTJDeczb5W0ywokIHkcg61rqU
iNOvFjgfTIlm8PfWJaFeT0VtJHFVCQUwnEgdm9Lx48440/TOSOj6Eb4qb6eIVnqA
CsvzdyGIaPOzFtgq7hAkXcPR6gIh9K5i6ZcHlAfPrhRLNqs0zd6xrs6ExeWsyCIi
yxkW3FxcJYOQLzRIDKRyVmI+jB2lJ+CCryQMQrBKJ5MFMvNgSP6Zxn7hncG4trim
8vGdnbt5r4t2SoAeBcAKt+ccQngUy3oE8ppi+3QcHW8L2HX+MjHELnrVNmgoxy73
WhlvpLDUx8ofGsYxq2CxQzxD2yfX1IrlQ5Eri+c2TxgZFATaXnr/RUmsgKLaG1bc
79DYn+w7g69rYbwx+2b/+CEadrYIHoC1bJ/EZG0DPbZo8HxrNuvjdvgnzjgQCUZM
NWvDUhElkdDldj6OFCcAjEwVpixX0UovLd4mwE+h9WHRNtouRAFZIaJUjtaf0PV4
MZhwLe/GfPj990jWGctixoiT3dNHk/gf4kE/2Q9yyfih7plSVCH84dUISXzqwjq4
T3yOtbUPfyZx3osiaP8H/9NdgWICdmAIztP4N5OsR17mqpv2P6xPwn5WJqrOASkw
i5HPNOhY+8atwRBtGpXP
=WkQC
-----END PGP SIGNATURE-----

--4BINIseljnhuvuEN4rKCb8DPdEXTf2WcW--
