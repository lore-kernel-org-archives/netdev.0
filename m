From: Olivier Sobrie <olivier@sobrie.be>
Subject: Re: [PATCH v4 3/4] can: kvaser_usb: Add support for the Usbcan-II
 family
Date: Mon, 12 Jan 2015 14:53:02 +0100
Message-ID: <20150112135302.GB18351@hposo>
References: <20141223154654.GB6460@vivalin-002>
 <20150111200544.GA8855@linux>
 <20150111201116.GB8855@linux>
 <20150111201519.GC8855@linux>
 <20150111203612.GA8999@linux>
Reply-To: Olivier Sobrie <olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150111203612.GA8999@linux>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Sun, Jan 11, 2015 at 03:36:12PM -0500, Ahmed S. Darwish wrote:
> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> 
> CAN to USB interfaces sold by the Swedish manufacturer Kvaser are
> divided into two major families: 'Leaf', and 'UsbcanII'.  From an
> Operating System perspective, the firmware of both families behave
> in a not too drastically different fashion.
> 
> This patch adds support for the UsbcanII family of devices to the
> current Kvaser Leaf-only driver.
> 
> CAN frames sending, receiving, and error handling paths has been
> tested using the dual-channel "Kvaser USBcan II HS/LS" dongle. It
> should also work nicely with other products in the same category.
> 
> List of new devices supported by this driver update:
> 
>          - Kvaser USBcan II HS/HS
>          - Kvaser USBcan II HS/LS
>          - Kvaser USBcan Rugged ("USBcan Rev B")
>          - Kvaser Memorator HS/HS
>          - Kvaser Memorator HS/LS
>          - Scania VCI2 (if you have the Kvaser logo on top)
> 
> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>

Just two small remarks below.
Thanks,

Olivier

> ---
>  drivers/net/can/usb/Kconfig      |   8 +-
>  drivers/net/can/usb/kvaser_usb.c | 612 ++++++++++++++++++++++++++++++---------
>  2 files changed, 487 insertions(+), 133 deletions(-)
> 
> ** V4 Changelog:
> - Use type-safe C methods instead of cpp macros
> - Further clarify the code and comments on error events channel arbitration
> - Remove defensive checks against non-existing families
> - Re-order methods to remove forward declarations
> - Smaller stuff spotted by earlier review (function prefexes, etc.)
> 
> ** V3 Changelog:
> - Fix padding for the usbcan_msg_tx_acknowledge command
> - Remove kvaser_usb->max_channels and the MAX_NET_DEVICES macro
> - Rename commands to CMD_LEAF_xxx and CMD_USBCAN_xxx
> - Apply checkpatch.pl suggestions ('net/' comments, multi-line strings, etc.)
> 
> ** V2 Changelog:
> - Update Kconfig entries
> - Use actual number of CAN channels (instead of max) where appropriate
> - Rebase over a new set of UsbcanII-independent driver fixes
> 
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
>  
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
>  
>  	  If unsure, say N.
>  
> diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
> index 0eb870b..da47d17 100644
> --- a/drivers/net/can/usb/kvaser_usb.c
> +++ b/drivers/net/can/usb/kvaser_usb.c
> @@ -6,10 +6,12 @@
>   * Parts of this driver are based on the following:
>   *  - Kvaser linux leaf driver (version 4.78)
>   *  - CAN driver for esd CAN-USB/2
> + *  - Kvaser linux usbcanII driver (version 5.3)
>   *
>   * Copyright (C) 2002-2006 KVASER AB, Sweden. All rights reserved.
>   * Copyright (C) 2010 Matthias Fuchs <matthias.fuchs@esd.eu>, esd gmbh
>   * Copyright (C) 2012 Olivier Sobrie <olivier@sobrie.be>
> + * Copyright (C) 2015 Valeo Corporation
>   */
>  
>  #include <linux/completion.h>
> @@ -21,6 +23,15 @@
>  #include <linux/can/dev.h>
>  #include <linux/can/error.h>
>  
> +/* Kvaser USB CAN dongles are divided into two major families:
> + * - Leaf: Based on Renesas M32C, running firmware labeled as 'filo'
> + * - UsbcanII: Based on Renesas M16C, running firmware labeled as 'helios'
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
>  
> -/* Kvaser USB devices */
> +/* Leaf USB devices */
>  #define KVASER_VENDOR_ID		0x0bfd
>  #define USB_LEAF_DEVEL_PRODUCT_ID	10
>  #define USB_LEAF_LITE_PRODUCT_ID	11
> @@ -56,6 +68,24 @@
>  #define USB_LEAF_LITE_V2_PRODUCT_ID	288
>  #define USB_MINI_PCIE_HS_PRODUCT_ID	289
>  
> +static inline bool kvaser_is_leaf(const struct usb_device_id *id)
> +{
> +	return id->idProduct >= USB_LEAF_DEVEL_PRODUCT_ID &&
> +	       id->idProduct <= USB_MINI_PCIE_HS_PRODUCT_ID;
> +}
> +
> +/* USBCANII devices */
> +#define USB_USBCAN_REVB_PRODUCT_ID	2
> +#define USB_VCI2_PRODUCT_ID		3
> +#define USB_USBCAN2_PRODUCT_ID		4
> +#define USB_MEMORATOR_PRODUCT_ID	5
> +
> +static inline bool kvaser_is_usbcan(const struct usb_device_id *id)
> +{
> +	return id->idProduct >= USB_USBCAN_REVB_PRODUCT_ID &&
> +	       id->idProduct <= USB_MEMORATOR_PRODUCT_ID;
> +}
> +
>  /* USB devices features */
>  #define KVASER_HAS_SILENT_MODE		BIT(0)
>  #define KVASER_HAS_TXRX_ERRORS		BIT(1)
> @@ -73,7 +103,7 @@
>  #define MSG_FLAG_TX_ACK			BIT(6)
>  #define MSG_FLAG_TX_REQUEST		BIT(7)
>  
> -/* Can states */
> +/* Can states (M16C CxSTRH register) */
>  #define M16C_STATE_BUS_RESET		BIT(0)
>  #define M16C_STATE_BUS_ERROR		BIT(4)
>  #define M16C_STATE_BUS_PASSIVE		BIT(5)
> @@ -98,7 +128,13 @@
>  #define CMD_START_CHIP_REPLY		27
>  #define CMD_STOP_CHIP			28
>  #define CMD_STOP_CHIP_REPLY		29
> -#define CMD_GET_CARD_INFO2		32
> +#define CMD_READ_CLOCK			30
> +#define CMD_READ_CLOCK_REPLY		31

These two defines are not used.

> +
> +#define CMD_LEAF_GET_CARD_INFO2		32
> +#define CMD_USBCAN_RESET_CLOCK		32
> +#define CMD_USBCAN_CLOCK_OVERFLOW_EVENT	33
> +
>  #define CMD_GET_CARD_INFO		34
>  #define CMD_GET_CARD_INFO_REPLY		35
>  #define CMD_GET_SOFTWARE_INFO		38
> @@ -108,8 +144,9 @@
>  #define CMD_RESET_ERROR_COUNTER		49
>  #define CMD_TX_ACKNOWLEDGE		50
>  #define CMD_CAN_ERROR_EVENT		51
> -#define CMD_USB_THROTTLE		77
> -#define CMD_LOG_MESSAGE			106
> +
> +#define CMD_LEAF_USB_THROTTLE		77
> +#define CMD_LEAF_LOG_MESSAGE		106
>  
>  /* error factors */
>  #define M16C_EF_ACKE			BIT(0)
> @@ -121,6 +158,14 @@
>  #define M16C_EF_RCVE			BIT(6)
>  #define M16C_EF_TRE			BIT(7)
>  
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
> @@ -137,7 +182,7 @@
>  #define KVASER_CTRL_MODE_SELFRECEPTION	3
>  #define KVASER_CTRL_MODE_OFF		4
>  
> -/* log message */
> +/* Extended CAN identifier flag */
>  #define KVASER_EXTENDED_FRAME		BIT(31)
>  
>  struct kvaser_msg_simple {
> @@ -148,30 +193,55 @@ struct kvaser_msg_simple {
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
>  
>  struct kvaser_msg_cardinfo2 {
>  	u8 tid;
> -	u8 channel;
> +	u8 reserved;
>  	u8 pcb_id[24];
>  	__le32 oem_unlock_code;
>  } __packed;
>  
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
>  
>  struct kvaser_msg_busparams {
> @@ -188,36 +258,86 @@ struct kvaser_msg_tx_can {
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
> +} __packed;
> +
> +struct kvaser_msg_rx_can_header {
> +	u8 channel;
> +	u8 flag;
>  } __packed;
>  
> -struct kvaser_msg_rx_can {
> +struct leaf_msg_rx_can {
>  	u8 channel;
>  	u8 flag;
> +
>  	__le16 time[3];
>  	u8 msg[14];
>  } __packed;
>  
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
>  	u8 status;
>  	u8 padding[3];
>  } __packed;
>  
> -struct kvaser_msg_tx_acknowledge {
> +struct usbcan_msg_chip_state_event {
> +	u8 tid;
> +	u8 channel;
> +
> +	u8 tx_errors_count;
> +	u8 rx_errors_count;
> +	__le16 time;
> +
> +	u8 status;
> +	u8 padding[3];
> +} __packed;
> +
> +struct kvaser_msg_tx_acknowledge_header {
> +	u8 channel;
> +	u8 tid;
> +};

Is this struct really needed? Can't you simply use
leaf_msg_tx_acknowledge or usbcan_msg_tx_acknowledge
structures to read the header.
Same for kvaser_msg_rx_can_header.

> +
> +struct leaf_msg_tx_acknowledge {
>  	u8 channel;
>  	u8 tid;
> +
>  	__le16 time[3];
>  	u8 flags;
>  	u8 time_offset;
>  } __packed;
>  
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
> @@ -229,6 +349,18 @@ struct kvaser_msg_error_event {
>  	u8 error_factor;
>  } __packed;
>  
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
> @@ -243,7 +375,7 @@ struct kvaser_msg_flush_queue {
>  	u8 padding[3];
>  } __packed;
>  
> -struct kvaser_msg_log_message {
> +struct leaf_msg_log_message {
>  	u8 channel;
>  	u8 flags;
>  	__le16 time[3];
> @@ -260,19 +392,57 @@ struct kvaser_msg {
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
>  
> +/* Summary of a kvaser error event, for a unified Leaf/Usbcan error
> + * handling. Some discrepancies between the two families exist:
> + *
> + * - USBCAN firmware does not report M16C "error factors"
> + * - USBCAN controllers has difficulties reporting if the raised error
> + *   event is for ch0 or ch1. They leave such arbitration to the OS
> + *   driver by letting it compare error counters with previous values
> + *   and decide the error event's channel. Thus for USBCAN, the channel
> + *   field is only advisory.
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
> @@ -288,6 +458,7 @@ struct kvaser_usb {
>  
>  	u32 fw_version;
>  	unsigned int nchannels;
> +	enum kvaser_usb_family family;
>  
>  	bool rxinitdone;
>  	void *rxbuf[MAX_RX_URBS];
> @@ -311,6 +482,7 @@ struct kvaser_usb_net_priv {
>  };
>  
>  static const struct usb_device_id kvaser_usb_table[] = {
> +	/* Leaf family IDs */
>  	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_DEVEL_PRODUCT_ID) },
>  	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_LITE_PRODUCT_ID) },
>  	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_PRO_PRODUCT_ID),
> @@ -360,6 +532,17 @@ static const struct usb_device_id kvaser_usb_table[] = {
>  		.driver_info = KVASER_HAS_TXRX_ERRORS },
>  	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_LITE_V2_PRODUCT_ID) },
>  	{ USB_DEVICE(KVASER_VENDOR_ID, USB_MINI_PCIE_HS_PRODUCT_ID) },
> +
> +	/* USBCANII family IDs */
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_USBCAN2_PRODUCT_ID),
> +		.driver_info = KVASER_HAS_TXRX_ERRORS },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_USBCAN_REVB_PRODUCT_ID),
> +		.driver_info = KVASER_HAS_TXRX_ERRORS },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_MEMORATOR_PRODUCT_ID),
> +		.driver_info = KVASER_HAS_TXRX_ERRORS },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_VCI2_PRODUCT_ID),
> +		.driver_info = KVASER_HAS_TXRX_ERRORS },
> +
>  	{ }
>  };
>  MODULE_DEVICE_TABLE(usb, kvaser_usb_table);
> @@ -463,7 +646,14 @@ static int kvaser_usb_get_software_info(struct kvaser_usb *dev)
>  	if (err)
>  		return err;
>  
> -	dev->fw_version = le32_to_cpu(msg.u.softinfo.fw_version);
> +	switch (dev->family) {
> +	case KVASER_LEAF:
> +		dev->fw_version = le32_to_cpu(msg.u.leaf.softinfo.fw_version);
> +		break;
> +	case KVASER_USBCAN:
> +		dev->fw_version = le32_to_cpu(msg.u.usbcan.softinfo.fw_version);
> +		break;
> +	}
>  
>  	return 0;
>  }
> @@ -482,7 +672,9 @@ static int kvaser_usb_get_card_info(struct kvaser_usb *dev)
>  		return err;
>  
>  	dev->nchannels = msg.u.cardinfo.nchannels;
> -	if (dev->nchannels > MAX_NET_DEVICES)
> +	if ((dev->nchannels > MAX_NET_DEVICES) ||
> +	    (dev->family == KVASER_USBCAN &&
> +	     dev->nchannels > MAX_USBCAN_NET_DEVICES))
>  		return -EINVAL;
>  
>  	return 0;
> @@ -496,8 +688,10 @@ static void kvaser_usb_tx_acknowledge(const struct kvaser_usb *dev,
>  	struct kvaser_usb_net_priv *priv;
>  	struct sk_buff *skb;
>  	struct can_frame *cf;
> -	u8 channel = msg->u.tx_acknowledge.channel;
> -	u8 tid = msg->u.tx_acknowledge.tid;
> +	u8 channel, tid;
> +
> +	channel = msg->u.tx_acknowledge_header.channel;
> +	tid = msg->u.tx_acknowledge_header.tid;
>  
>  	if (channel >= dev->nchannels) {
>  		dev_err(dev->udev->dev.parent,
> @@ -616,53 +810,24 @@ static void kvaser_usb_unlink_tx_urbs(struct kvaser_usb_net_priv *priv)
>  }
>  
>  static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
> -				const struct kvaser_msg *msg)
> +				struct kvaser_error_summary *es)
>  {
>  	struct can_frame *cf;
>  	struct sk_buff *skb;
>  	struct net_device_stats *stats;
>  	struct kvaser_usb_net_priv *priv;
>  	unsigned int new_state;
> -	u8 channel, status, txerr, rxerr, error_factor;
> -
> -	switch (msg->id) {
> -	case CMD_CAN_ERROR_EVENT:
> -		channel = msg->u.error_event.channel;
> -		status =  msg->u.error_event.status;
> -		txerr = msg->u.error_event.tx_errors_count;
> -		rxerr = msg->u.error_event.rx_errors_count;
> -		error_factor = msg->u.error_event.error_factor;
> -		break;
> -	case CMD_LOG_MESSAGE:
> -		channel = msg->u.log_message.channel;
> -		status = msg->u.log_message.data[0];
> -		txerr = msg->u.log_message.data[2];
> -		rxerr = msg->u.log_message.data[3];
> -		error_factor = msg->u.log_message.data[1];
> -		break;
> -	case CMD_CHIP_STATE_EVENT:
> -		channel = msg->u.chip_state_event.channel;
> -		status =  msg->u.chip_state_event.status;
> -		txerr = msg->u.chip_state_event.tx_errors_count;
> -		rxerr = msg->u.chip_state_event.rx_errors_count;
> -		error_factor = 0;
> -		break;
> -	default:
> -		dev_err(dev->udev->dev.parent, "Invalid msg id (%d)\n",
> -			msg->id);
> -		return;
> -	}
>  
> -	if (channel >= dev->nchannels) {
> +	if (es->channel >= dev->nchannels) {
>  		dev_err(dev->udev->dev.parent,
> -			"Invalid channel number (%d)\n", channel);
> +			"Invalid channel number (%d)\n", es->channel);
>  		return;
>  	}
>  
> -	priv = dev->nets[channel];
> +	priv = dev->nets[es->channel];
>  	stats = &priv->netdev->stats;
>  
> -	if (status & M16C_STATE_BUS_RESET) {
> +	if (es->status & M16C_STATE_BUS_RESET) {
>  		kvaser_usb_unlink_tx_urbs(priv);
>  		return;
>  	}
> @@ -675,9 +840,9 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>  
>  	new_state = priv->can.state;
>  
> -	netdev_dbg(priv->netdev, "Error status: 0x%02x\n", status);
> +	netdev_dbg(priv->netdev, "Error status: 0x%02x\n", es->status);
>  
> -	if (status & M16C_STATE_BUS_OFF) {
> +	if (es->status & M16C_STATE_BUS_OFF) {
>  		cf->can_id |= CAN_ERR_BUSOFF;
>  
>  		priv->can.can_stats.bus_off++;
> @@ -687,12 +852,12 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>  		netif_carrier_off(priv->netdev);
>  
>  		new_state = CAN_STATE_BUS_OFF;
> -	} else if (status & M16C_STATE_BUS_PASSIVE) {
> +	} else if (es->status & M16C_STATE_BUS_PASSIVE) {
>  		if (priv->can.state != CAN_STATE_ERROR_PASSIVE) {
>  			cf->can_id |= CAN_ERR_CRTL;
>  
> -			if (txerr || rxerr)
> -				cf->data[1] = (txerr > rxerr)
> +			if (es->txerr || es->rxerr)
> +				cf->data[1] = (es->txerr > es->rxerr)
>  						? CAN_ERR_CRTL_TX_PASSIVE
>  						: CAN_ERR_CRTL_RX_PASSIVE;
>  			else
> @@ -703,13 +868,11 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>  		}
>  
>  		new_state = CAN_STATE_ERROR_PASSIVE;
> -	}
> -
> -	if (status == M16C_STATE_BUS_ERROR) {
> +	} else if (es->status & M16C_STATE_BUS_ERROR) {
>  		if ((priv->can.state < CAN_STATE_ERROR_WARNING) &&
> -		    ((txerr >= 96) || (rxerr >= 96))) {
> +		    ((es->txerr >= 96) || (es->rxerr >= 96))) {
>  			cf->can_id |= CAN_ERR_CRTL;
> -			cf->data[1] = (txerr > rxerr)
> +			cf->data[1] = (es->txerr > es->rxerr)
>  					? CAN_ERR_CRTL_TX_WARNING
>  					: CAN_ERR_CRTL_RX_WARNING;
>  
> @@ -723,7 +886,7 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>  		}
>  	}
>  
> -	if (!status) {
> +	if (!es->status) {
>  		cf->can_id |= CAN_ERR_PROT;
>  		cf->data[2] = CAN_ERR_PROT_ACTIVE;
>  
> @@ -739,34 +902,48 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>  		priv->can.can_stats.restarts++;
>  	}
>  
> -	if (error_factor) {
> -		priv->can.can_stats.bus_error++;
> -		stats->rx_errors++;
> -
> -		cf->can_id |= CAN_ERR_BUSERROR | CAN_ERR_PROT;
> -
> -		if (error_factor & M16C_EF_ACKE)
> -			cf->data[3] |= (CAN_ERR_PROT_LOC_ACK);
> -		if (error_factor & M16C_EF_CRCE)
> -			cf->data[3] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
> -					CAN_ERR_PROT_LOC_CRC_DEL);
> -		if (error_factor & M16C_EF_FORME)
> -			cf->data[2] |= CAN_ERR_PROT_FORM;
> -		if (error_factor & M16C_EF_STFE)
> -			cf->data[2] |= CAN_ERR_PROT_STUFF;
> -		if (error_factor & M16C_EF_BITE0)
> -			cf->data[2] |= CAN_ERR_PROT_BIT0;
> -		if (error_factor & M16C_EF_BITE1)
> -			cf->data[2] |= CAN_ERR_PROT_BIT1;
> -		if (error_factor & M16C_EF_TRE)
> -			cf->data[2] |= CAN_ERR_PROT_TX;
> +	switch (dev->family) {
> +	case KVASER_LEAF:
> +		if (es->leaf.error_factor) {
> +			priv->can.can_stats.bus_error++;
> +			stats->rx_errors++;
> +
> +			cf->can_id |= CAN_ERR_BUSERROR | CAN_ERR_PROT;
> +
> +			if (es->leaf.error_factor & M16C_EF_ACKE)
> +				cf->data[3] |= (CAN_ERR_PROT_LOC_ACK);
> +			if (es->leaf.error_factor & M16C_EF_CRCE)
> +				cf->data[3] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
> +						CAN_ERR_PROT_LOC_CRC_DEL);
> +			if (es->leaf.error_factor & M16C_EF_FORME)
> +				cf->data[2] |= CAN_ERR_PROT_FORM;
> +			if (es->leaf.error_factor & M16C_EF_STFE)
> +				cf->data[2] |= CAN_ERR_PROT_STUFF;
> +			if (es->leaf.error_factor & M16C_EF_BITE0)
> +				cf->data[2] |= CAN_ERR_PROT_BIT0;
> +			if (es->leaf.error_factor & M16C_EF_BITE1)
> +				cf->data[2] |= CAN_ERR_PROT_BIT1;
> +			if (es->leaf.error_factor & M16C_EF_TRE)
> +				cf->data[2] |= CAN_ERR_PROT_TX;
> +		}
> +		break;
> +	case KVASER_USBCAN:
> +		if (es->usbcan.error_state & USBCAN_ERROR_STATE_TX_ERROR)
> +			stats->tx_errors++;
> +		if (es->usbcan.error_state & USBCAN_ERROR_STATE_RX_ERROR)
> +			stats->rx_errors++;
> +		if (es->usbcan.error_state & USBCAN_ERROR_STATE_BUSERROR) {
> +			priv->can.can_stats.bus_error++;
> +			cf->can_id |= CAN_ERR_BUSERROR;
> +		}
> +		break;
>  	}
>  
> -	cf->data[6] = txerr;
> -	cf->data[7] = rxerr;
> +	cf->data[6] = es->txerr;
> +	cf->data[7] = es->rxerr;
>  
> -	priv->bec.txerr = txerr;
> -	priv->bec.rxerr = rxerr;
> +	priv->bec.txerr = es->txerr;
> +	priv->bec.rxerr = es->rxerr;
>  
>  	priv->can.state = new_state;
>  
> @@ -775,6 +952,124 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>  	netif_rx(skb);
>  }
>  
> +/* For USBCAN, report error to userspace iff the channels's errors counter
> + * has increased, or we're the only channel seeing a bus error state.
> + */
> +static void kvaser_usbcan_conditionally_rx_error(const struct kvaser_usb *dev,
> +						 struct kvaser_error_summary *es)
> +{
> +	struct kvaser_usb_net_priv *priv;
> +	int channel;
> +	bool report_error;
> +
> +	channel = es->channel;
> +	if (channel >= dev->nchannels) {
> +		dev_err(dev->udev->dev.parent,
> +			"Invalid channel number (%d)\n", channel);
> +		return;
> +	}
> +
> +	priv = dev->nets[channel];
> +	report_error = false;
> +
> +	if (es->txerr > priv->bec.txerr) {
> +		es->usbcan.error_state |= USBCAN_ERROR_STATE_TX_ERROR;
> +		report_error = true;
> +	}
> +	if (es->rxerr > priv->bec.rxerr) {
> +		es->usbcan.error_state |= USBCAN_ERROR_STATE_RX_ERROR;
> +		report_error = true;
> +	}
> +	if ((es->status & M16C_STATE_BUS_ERROR) &&
> +	    !(es->usbcan.other_ch_status & M16C_STATE_BUS_ERROR)) {
> +		es->usbcan.error_state |= USBCAN_ERROR_STATE_BUSERROR;
> +		report_error = true;
> +	}
> +
> +	if (report_error)
> +		kvaser_usb_rx_error(dev, es);
> +}
> +
> +static void kvaser_usbcan_rx_error(const struct kvaser_usb *dev,
> +				   const struct kvaser_msg *msg)
> +{
> +	struct kvaser_error_summary es = { };
> +
> +	switch (msg->id) {
> +	/* Sometimes errors are sent as unsolicited chip state events */
> +	case CMD_CHIP_STATE_EVENT:
> +		es.channel = msg->u.usbcan.chip_state_event.channel;
> +		es.status =  msg->u.usbcan.chip_state_event.status;
> +		es.txerr = msg->u.usbcan.chip_state_event.tx_errors_count;
> +		es.rxerr = msg->u.usbcan.chip_state_event.rx_errors_count;
> +		kvaser_usbcan_conditionally_rx_error(dev, &es);
> +		break;
> +
> +	case CMD_CAN_ERROR_EVENT:
> +		es.channel = 0;
> +		es.status = msg->u.usbcan.error_event.status_ch0;
> +		es.txerr = msg->u.usbcan.error_event.tx_errors_count_ch0;
> +		es.rxerr = msg->u.usbcan.error_event.rx_errors_count_ch0;
> +		es.usbcan.other_ch_status =
> +			msg->u.usbcan.error_event.status_ch1;
> +		kvaser_usbcan_conditionally_rx_error(dev, &es);
> +
> +		/* The USBCAN firmware does not support more than 2 channels.
> +		 * Now that ch0 was checked, check if ch1 has any errors.
> +		 */
> +		if (dev->nchannels == MAX_USBCAN_NET_DEVICES) {
> +			es.channel = 1;
> +			es.status = msg->u.usbcan.error_event.status_ch1;
> +			es.txerr = msg->u.usbcan.error_event.tx_errors_count_ch1;
> +			es.rxerr = msg->u.usbcan.error_event.rx_errors_count_ch1;
> +			es.usbcan.other_ch_status =
> +				msg->u.usbcan.error_event.status_ch0;
> +			kvaser_usbcan_conditionally_rx_error(dev, &es);
> +		}
> +		break;
> +
> +	default:
> +		dev_err(dev->udev->dev.parent, "Invalid msg id (%d)\n",
> +			msg->id);
> +	}
> +}
> +
> +static void kvaser_leaf_rx_error(const struct kvaser_usb *dev,
> +				 const struct kvaser_msg *msg)
> +{
> +	struct kvaser_error_summary es = { };
> +
> +	switch (msg->id) {
> +	case CMD_CAN_ERROR_EVENT:
> +		es.channel = msg->u.leaf.error_event.channel;
> +		es.status =  msg->u.leaf.error_event.status;
> +		es.txerr = msg->u.leaf.error_event.tx_errors_count;
> +		es.rxerr = msg->u.leaf.error_event.rx_errors_count;
> +		es.leaf.error_factor = msg->u.leaf.error_event.error_factor;
> +		break;
> +	case CMD_LEAF_LOG_MESSAGE:
> +		es.channel = msg->u.leaf.log_message.channel;
> +		es.status = msg->u.leaf.log_message.data[0];
> +		es.txerr = msg->u.leaf.log_message.data[2];
> +		es.rxerr = msg->u.leaf.log_message.data[3];
> +		es.leaf.error_factor = msg->u.leaf.log_message.data[1];
> +		break;
> +	case CMD_CHIP_STATE_EVENT:
> +		es.channel = msg->u.leaf.chip_state_event.channel;
> +		es.status =  msg->u.leaf.chip_state_event.status;
> +		es.txerr = msg->u.leaf.chip_state_event.tx_errors_count;
> +		es.rxerr = msg->u.leaf.chip_state_event.rx_errors_count;
> +		es.leaf.error_factor = 0;
> +		break;
> +	default:
> +		dev_err(dev->udev->dev.parent, "Invalid msg id (%d)\n",
> +			msg->id);
> +		return;
> +	}
> +
> +	kvaser_usb_rx_error(dev, &es);
> +}
> +
>  static void kvaser_usb_rx_can_err(const struct kvaser_usb_net_priv *priv,
>  				  const struct kvaser_msg *msg)
>  {
> @@ -782,16 +1077,16 @@ static void kvaser_usb_rx_can_err(const struct kvaser_usb_net_priv *priv,
>  	struct sk_buff *skb;
>  	struct net_device_stats *stats = &priv->netdev->stats;
>  
> -	if (msg->u.rx_can.flag & (MSG_FLAG_ERROR_FRAME |
> +	if (msg->u.rx_can_header.flag & (MSG_FLAG_ERROR_FRAME |
>  					 MSG_FLAG_NERR)) {
>  		netdev_err(priv->netdev, "Unknow error (flags: 0x%02x)\n",
> -			   msg->u.rx_can.flag);
> +			   msg->u.rx_can_header.flag);
>  
>  		stats->rx_errors++;
>  		return;
>  	}
>  
> -	if (msg->u.rx_can.flag & MSG_FLAG_OVERRUN) {
> +	if (msg->u.rx_can_header.flag & MSG_FLAG_OVERRUN) {
>  		stats->rx_over_errors++;
>  		stats->rx_errors++;
>  
> @@ -817,7 +1112,8 @@ static void kvaser_usb_rx_can_msg(const struct kvaser_usb *dev,
>  	struct can_frame *cf;
>  	struct sk_buff *skb;
>  	struct net_device_stats *stats;
> -	u8 channel = msg->u.rx_can.channel;
> +	u8 channel = msg->u.rx_can_header.channel;
> +	const u8 *rx_msg;
>  
>  	if (channel >= dev->nchannels) {
>  		dev_err(dev->udev->dev.parent,
> @@ -828,19 +1124,32 @@ static void kvaser_usb_rx_can_msg(const struct kvaser_usb *dev,
>  	priv = dev->nets[channel];
>  	stats = &priv->netdev->stats;
>  
> -	if ((msg->u.rx_can.flag & MSG_FLAG_ERROR_FRAME) &&
> -	    (msg->id == CMD_LOG_MESSAGE)) {
> -		kvaser_usb_rx_error(dev, msg);
> +	if ((msg->u.rx_can_header.flag & MSG_FLAG_ERROR_FRAME) &&
> +	    (dev->family == KVASER_LEAF && msg->id == CMD_LEAF_LOG_MESSAGE)) {
> +		kvaser_leaf_rx_error(dev, msg);
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
> +		rx_msg = msg->u.leaf.rx_can.msg;
> +		break;
> +	case KVASER_USBCAN:
> +		rx_msg = msg->u.usbcan.rx_can.msg;
> +		break;
> +	default:
> +		dev_err(dev->udev->dev.parent,
> +			"Invalid device family (%d)\n", dev->family);
>  		return;
>  	}
>  
> @@ -850,38 +1159,37 @@ static void kvaser_usb_rx_can_msg(const struct kvaser_usb *dev,
>  		return;
>  	}
>  
> -	if (msg->id == CMD_LOG_MESSAGE) {
> -		cf->can_id = le32_to_cpu(msg->u.log_message.id);
> +	if (dev->family == KVASER_LEAF && msg->id == CMD_LEAF_LOG_MESSAGE) {
> +		cf->can_id = le32_to_cpu(msg->u.leaf.log_message.id);
>  		if (cf->can_id & KVASER_EXTENDED_FRAME)
>  			cf->can_id &= CAN_EFF_MASK | CAN_EFF_FLAG;
>  		else
>  			cf->can_id &= CAN_SFF_MASK;
>  
> -		cf->can_dlc = get_can_dlc(msg->u.log_message.dlc);
> +		cf->can_dlc = get_can_dlc(msg->u.leaf.log_message.dlc);
>  
> -		if (msg->u.log_message.flags & MSG_FLAG_REMOTE_FRAME)
> +		if (msg->u.leaf.log_message.flags & MSG_FLAG_REMOTE_FRAME)
>  			cf->can_id |= CAN_RTR_FLAG;
>  		else
> -			memcpy(cf->data, &msg->u.log_message.data,
> +			memcpy(cf->data, &msg->u.leaf.log_message.data,
>  			       cf->can_dlc);
>  	} else {
> -		cf->can_id = ((msg->u.rx_can.msg[0] & 0x1f) << 6) |
> -			     (msg->u.rx_can.msg[1] & 0x3f);
> +		cf->can_id = ((rx_msg[0] & 0x1f) << 6) | (rx_msg[1] & 0x3f);
>  
>  		if (msg->id == CMD_RX_EXT_MESSAGE) {
>  			cf->can_id <<= 18;
> -			cf->can_id |= ((msg->u.rx_can.msg[2] & 0x0f) << 14) |
> -				      ((msg->u.rx_can.msg[3] & 0xff) << 6) |
> -				      (msg->u.rx_can.msg[4] & 0x3f);
> +			cf->can_id |= ((rx_msg[2] & 0x0f) << 14) |
> +				      ((rx_msg[3] & 0xff) << 6) |
> +				      (rx_msg[4] & 0x3f);
>  			cf->can_id |= CAN_EFF_FLAG;
>  		}
>  
> -		cf->can_dlc = get_can_dlc(msg->u.rx_can.msg[5]);
> +		cf->can_dlc = get_can_dlc(rx_msg[5]);
>  
> -		if (msg->u.rx_can.flag & MSG_FLAG_REMOTE_FRAME)
> +		if (msg->u.rx_can_header.flag & MSG_FLAG_REMOTE_FRAME)
>  			cf->can_id |= CAN_RTR_FLAG;
>  		else
> -			memcpy(cf->data, &msg->u.rx_can.msg[6],
> +			memcpy(cf->data, &rx_msg[6],
>  			       cf->can_dlc);
>  	}
>  
> @@ -944,21 +1252,35 @@ static void kvaser_usb_handle_message(const struct kvaser_usb *dev,
>  
>  	case CMD_RX_STD_MESSAGE:
>  	case CMD_RX_EXT_MESSAGE:
> -	case CMD_LOG_MESSAGE:
> +		kvaser_usb_rx_can_msg(dev, msg);
> +		break;
> +
> +	case CMD_LEAF_LOG_MESSAGE:
> +		if (dev->family != KVASER_LEAF)
> +			goto warn;
>  		kvaser_usb_rx_can_msg(dev, msg);
>  		break;
>  
>  	case CMD_CHIP_STATE_EVENT:
>  	case CMD_CAN_ERROR_EVENT:
> -		kvaser_usb_rx_error(dev, msg);
> +		if (dev->family == KVASER_LEAF)
> +			kvaser_leaf_rx_error(dev, msg);
> +		else
> +			kvaser_usbcan_rx_error(dev, msg);
>  		break;
>  
>  	case CMD_TX_ACKNOWLEDGE:
>  		kvaser_usb_tx_acknowledge(dev, msg);
>  		break;
>  
> +	/* Ignored messages */
> +	case CMD_USBCAN_CLOCK_OVERFLOW_EVENT:
> +		if (dev->family != KVASER_USBCAN)
> +			goto warn;
> +		break;
> +
>  	default:
> -		dev_warn(dev->udev->dev.parent,
> +warn:		dev_warn(dev->udev->dev.parent,
>  			 "Unhandled message (%d)\n", msg->id);
>  		break;
>  	}
> @@ -1178,7 +1500,7 @@ static void kvaser_usb_unlink_all_urbs(struct kvaser_usb *dev)
>  				  dev->rxbuf[i],
>  				  dev->rxbuf_dma[i]);
>  
> -	for (i = 0; i < MAX_NET_DEVICES; i++) {
> +	for (i = 0; i < dev->nchannels; i++) {
>  		struct kvaser_usb_net_priv *priv = dev->nets[i];
>  
>  		if (priv)
> @@ -1286,6 +1608,7 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
>  	struct kvaser_msg *msg;
>  	int i, err;
>  	int ret = NETDEV_TX_OK;
> +	uint8_t *msg_tx_can_flags;
>  
>  	if (can_dropped_invalid_skb(netdev, skb))
>  		return NETDEV_TX_OK;
> @@ -1307,9 +1630,23 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
>  
>  	msg = buf;
>  	msg->len = MSG_HEADER_LEN + sizeof(struct kvaser_msg_tx_can);
> -	msg->u.tx_can.flags = 0;
>  	msg->u.tx_can.channel = priv->channel;
>  
> +	switch (dev->family) {
> +	case KVASER_LEAF:
> +		msg_tx_can_flags = &msg->u.tx_can.leaf.flags;
> +		break;
> +	case KVASER_USBCAN:
> +		msg_tx_can_flags = &msg->u.tx_can.usbcan.flags;
> +		break;
> +	default:
> +		dev_err(dev->udev->dev.parent,
> +			"Invalid device family (%d)\n", dev->family);
> +		goto releasebuf;
> +	}
> +
> +	*msg_tx_can_flags = 0;
> +
>  	if (cf->can_id & CAN_EFF_FLAG) {
>  		msg->id = CMD_TX_EXT_MESSAGE;
>  		msg->u.tx_can.msg[0] = (cf->can_id >> 24) & 0x1f;
> @@ -1327,7 +1664,7 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
>  	memcpy(&msg->u.tx_can.msg[6], cf->data, cf->can_dlc);
>  
>  	if (cf->can_id & CAN_RTR_FLAG)
> -		msg->u.tx_can.flags |= MSG_FLAG_REMOTE_FRAME;
> +		*msg_tx_can_flags |= MSG_FLAG_REMOTE_FRAME;
>  
>  	for (i = 0; i < ARRAY_SIZE(priv->tx_contexts); i++) {
>  		if (priv->tx_contexts[i].echo_index == MAX_TX_URBS) {
> @@ -1596,6 +1933,17 @@ static int kvaser_usb_probe(struct usb_interface *intf,
>  	if (!dev)
>  		return -ENOMEM;
>  
> +	if (kvaser_is_leaf(id)) {
> +		dev->family = KVASER_LEAF;
> +	} else if (kvaser_is_usbcan(id)) {
> +		dev->family = KVASER_USBCAN;
> +	} else {
> +		dev_err(&intf->dev,
> +			"Product ID (%d) does not belong to any known Kvaser USB family",
> +			id->idProduct);
> +		return -ENODEV;
> +	}
> +
>  	err = kvaser_usb_get_endpoints(intf, &dev->bulk_in, &dev->bulk_out);
>  	if (err) {
>  		dev_err(&intf->dev, "Cannot get usb endpoint(s)");
> -- 
> 1.9.1
> 
