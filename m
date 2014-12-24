From: Olivier Sobrie <olivier@sobrie.be>
Subject: Re: [PATCH] can: kvaser_usb: Add support for the Usbcan-II family
Date: Wed, 24 Dec 2014 13:36:27 +0100
Message-ID: <CAEM=fMqNnq9QYLiR8WXJ0wN2V=1B1TouxaLB_JLrYOtKvwxBkA@mail.gmail.com>
References: <20141223154654.GB6460@vivalin-002> <20141223155311.GA5997@vivalin-002>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
In-Reply-To: <20141223155311.GA5997@vivalin-002>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Ahmed,

On Tue, Dec 23, 2014 at 05:53:11PM +0200, Ahmed S. Darwish wrote:
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

Good, thank you :-) I'll try to test the patch during the next
week-end. Small remarks below.

>
> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> ---
>  drivers/net/can/usb/kvaser_usb.c | 630 +++++++++++++++++++++++++++++++--------
>  1 file changed, 505 insertions(+), 125 deletions(-)
>
>  (Generated over 3.19.0-rc1 + generic bugfix at
>   can-kvaser_usb-Don-t-free-packets-when-tight-on-URBs.patch)
>
> diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
> index 34c35d8..e7076da 100644
> --- a/drivers/net/can/usb/kvaser_usb.c
> +++ b/drivers/net/can/usb/kvaser_usb.c
> @@ -6,12 +6,15 @@
>   * Parts of this driver are based on the following:
>   *  - Kvaser linux leaf driver (version 4.78)
>   *  - CAN driver for esd CAN-USB/2
> + *  - Kvaser linux usbcanII driver (version 5.3)
>   *
>   * Copyright (C) 2002-2006 KVASER AB, Sweden. All rights reserved.
>   * Copyright (C) 2010 Matthias Fuchs <matthias.fuchs@esd.eu>, esd gmbh
>   * Copyright (C) 2012 Olivier Sobrie <olivier@sobrie.be>
> + * Copyright (C) 2014 Valeo Corporation
>   */
>
> +#include <linux/kernel.h>
>  #include <linux/completion.h>
>  #include <linux/module.h>
>  #include <linux/netdevice.h>
> @@ -21,6 +24,18 @@
>  #include <linux/can/dev.h>
>  #include <linux/can/error.h>
>
> +#define MAX(a, b) ((a) > (b) ? (a) : (b))

There is a max(a, b) macro in <linux/kernel.h>.

> +
> +/*
> + * Kvaser USB CAN dongles are divided into two major families:
> + * - Leaf: Based on Renesas M32C, running firmware labeled as 'filo'
> + * - UsbcanII: Based on Renesas M16C, running firmware labeled as 'helios'
> + */
> +enum kvaser_usb_family {
> + KVASER_LEAF,
> + KVASER_USBCAN,
> +};
> +
>  #define MAX_TX_URBS 16
>  #define MAX_RX_URBS 4
>  #define START_TIMEOUT 1000 /* msecs */
> @@ -29,9 +44,12 @@
>  #define USB_RECV_TIMEOUT 1000 /* msecs */
>  #define RX_BUFFER_SIZE 3072
>  #define CAN_USB_CLOCK 8000000
> -#define MAX_NET_DEVICES 3
> +#define LEAF_MAX_NET_DEVICES 3
> +#define USBCAN_MAX_NET_DEVICES 2
> +#define MAX_NET_DEVICES MAX(LEAF_MAX_NET_DEVICES, \
> +    USBCAN_MAX_NET_DEVICES)
>
> -/* Kvaser USB devices */
> +/* Leaf USB devices */
>  #define KVASER_VENDOR_ID 0x0bfd
>  #define USB_LEAF_DEVEL_PRODUCT_ID 10
>  #define USB_LEAF_LITE_PRODUCT_ID 11
> @@ -55,6 +73,16 @@
>  #define USB_CAN_R_PRODUCT_ID 39
>  #define USB_LEAF_LITE_V2_PRODUCT_ID 288
>  #define USB_MINI_PCIE_HS_PRODUCT_ID 289
> +#define LEAF_PRODUCT_ID(id) (id >= USB_LEAF_DEVEL_PRODUCT_ID && \
> + id <= USB_MINI_PCIE_HS_PRODUCT_ID)
> +
> +/* USBCANII devices */
> +#define USB_USBCAN_REVB_PRODUCT_ID 2
> +#define USB_VCI2_PRODUCT_ID 3
> +#define USB_USBCAN2_PRODUCT_ID 4
> +#define USB_MEMORATOR_PRODUCT_ID 5
> +#define USBCAN_PRODUCT_ID(id) (id >= USB_USBCAN_REVB_PRODUCT_ID && \
> + id <= USB_MEMORATOR_PRODUCT_ID)
>
>  /* USB devices features */
>  #define KVASER_HAS_SILENT_MODE BIT(0)
> @@ -73,7 +101,7 @@
>  #define MSG_FLAG_TX_ACK BIT(6)
>  #define MSG_FLAG_TX_REQUEST BIT(7)
>
> -/* Can states */
> +/* Can states (M16C CxSTRH register) */
>  #define M16C_STATE_BUS_RESET BIT(0)
>  #define M16C_STATE_BUS_ERROR BIT(4)
>  #define M16C_STATE_BUS_PASSIVE BIT(5)
> @@ -98,7 +126,13 @@
>  #define CMD_START_CHIP_REPLY 27
>  #define CMD_STOP_CHIP 28
>  #define CMD_STOP_CHIP_REPLY 29
> -#define CMD_GET_CARD_INFO2 32
> +#define CMD_READ_CLOCK 30
> +#define CMD_READ_CLOCK_REPLY 31
> +
> +#define LEAF_CMD_GET_CARD_INFO2 32
> +#define USBCAN_CMD_RESET_CLOCK 32
> +#define USBCAN_CMD_CLOCK_OVERFLOW_EVENT 33
> +
>  #define CMD_GET_CARD_INFO 34
>  #define CMD_GET_CARD_INFO_REPLY 35
>  #define CMD_GET_SOFTWARE_INFO 38
> @@ -108,8 +142,9 @@
>  #define CMD_RESET_ERROR_COUNTER 49
>  #define CMD_TX_ACKNOWLEDGE 50
>  #define CMD_CAN_ERROR_EVENT 51
> -#define CMD_USB_THROTTLE 77
> -#define CMD_LOG_MESSAGE 106
> +
> +#define LEAF_CMD_USB_THROTTLE 77
> +#define LEAF_CMD_LOG_MESSAGE 106
>
>  /* error factors */
>  #define M16C_EF_ACKE BIT(0)
> @@ -121,6 +156,13 @@
>  #define M16C_EF_RCVE BIT(6)
>  #define M16C_EF_TRE BIT(7)
>
> +/* Only Leaf-based devices can report M16C error factors,
> + * thus define our own error status flags for USBCAN */
> +#define USBCAN_ERROR_STATE_NONE 0
> +#define USBCAN_ERROR_STATE_TX_ERROR BIT(0)
> +#define USBCAN_ERROR_STATE_RX_ERROR BIT(1)
> +#define USBCAN_ERROR_STATE_BUSERROR BIT(2)
> +
>  /* bittiming parameters */
>  #define KVASER_USB_TSEG1_MIN 1
>  #define KVASER_USB_TSEG1_MAX 16
> @@ -137,7 +179,7 @@
>  #define KVASER_CTRL_MODE_SELFRECEPTION 3
>  #define KVASER_CTRL_MODE_OFF 4
>
> -/* log message */
> +/* Extended CAN identifier flag */
>  #define KVASER_EXTENDED_FRAME BIT(31)
>
>  struct kvaser_msg_simple {
> @@ -148,30 +190,55 @@ struct kvaser_msg_simple {
>  struct kvaser_msg_cardinfo {
>   u8 tid;
>   u8 nchannels;
> - __le32 serial_number;
> - __le32 padding;
> + union {
> + struct {
> + __le32 serial_number;
> + __le32 padding;
> + } __packed leaf0;
> + struct {
> + __le32 serial_number_low;
> + __le32 serial_number_high;
> + } __packed usbcan0;
> + } __packed;
>   __le32 clock_resolution;
>   __le32 mfgdate;
>   u8 ean[8];
>   u8 hw_revision;
> - u8 usb_hs_mode;
> - __le16 padding2;
> + union {
> + struct {
> + u8 usb_hs_mode;
> + } __packed leaf1;
> + struct {
> + u8 padding;
> + } __packed usbcan1;
> + } __packed;
> + __le16 padding;
>  } __packed;
>
>  struct kvaser_msg_cardinfo2 {
>   u8 tid;
> - u8 channel;
> + u8 reserved;
>   u8 pcb_id[24];
>   __le32 oem_unlock_code;
>  } __packed;
>
> -struct kvaser_msg_softinfo {
> +struct leaf_msg_softinfo {
>   u8 tid;
> - u8 channel;
> + u8 padding0;
>   __le32 sw_options;
>   __le32 fw_version;
>   __le16 max_outstanding_tx;
> - __le16 padding[9];
> + __le16 padding1[9];
> +} __packed;
> +
> +struct usbcan_msg_softinfo {
> + u8 tid;
> + u8 fw_name[5];
> + __le16 max_outstanding_tx;
> + u8 padding[6];
> + __le32 fw_version;
> + __le16 checksum;
> + __le16 sw_options;
>  } __packed;
>
>  struct kvaser_msg_busparams {
> @@ -188,36 +255,86 @@ struct kvaser_msg_tx_can {
>   u8 channel;
>   u8 tid;
>   u8 msg[14];
> - u8 padding;
> - u8 flags;
> + union {
> + struct {
> + u8 padding;
> + u8 flags;
> + } __packed leaf;
> + struct {
> + u8 flags;
> + u8 padding;
> + } __packed usbcan;
> + } __packed;
> +} __packed;
> +
> +struct kvaser_msg_rx_can_header {
> + u8 channel;
> + u8 flag;
>  } __packed;
>
> -struct kvaser_msg_rx_can {
> +struct leaf_msg_rx_can {
>   u8 channel;
>   u8 flag;
> +
>   __le16 time[3];
>   u8 msg[14];
>  } __packed;
>
> -struct kvaser_msg_chip_state_event {
> +struct usbcan_msg_rx_can {
> + u8 channel;
> + u8 flag;
> +
> + u8 msg[14];
> + __le16 time;
> +} __packed;
> +
> +struct leaf_msg_chip_state_event {
>   u8 tid;
>   u8 channel;
> +
>   __le16 time[3];
>   u8 tx_errors_count;
>   u8 rx_errors_count;
> +
>   u8 status;
>   u8 padding[3];
>  } __packed;
>
> -struct kvaser_msg_tx_acknowledge {
> +struct usbcan_msg_chip_state_event {
> + u8 tid;
> + u8 channel;
> +
> + u8 tx_errors_count;
> + u8 rx_errors_count;
> + __le16 time;
> +
> + u8 status;
> + u8 padding[3];
> +} __packed;
> +
> +struct kvaser_msg_tx_acknowledge_header {
> + u8 channel;
> + u8 tid;
> +};
> +
> +struct leaf_msg_tx_acknowledge {
>   u8 channel;
>   u8 tid;
> +
>   __le16 time[3];
>   u8 flags;
>   u8 time_offset;
>  } __packed;
>
> -struct kvaser_msg_error_event {
> +struct usbcan_msg_tx_acknowledge {
> + u8 channel;
> + u8 tid;
> +
> + __le16 time;
> + __le16 padding;
> +} __packed;
> +
> +struct leaf_msg_error_event {
>   u8 tid;
>   u8 flags;
>   __le16 time[3];
> @@ -229,6 +346,18 @@ struct kvaser_msg_error_event {
>   u8 error_factor;
>  } __packed;
>
> +struct usbcan_msg_error_event {
> + u8 tid;
> + u8 padding;
> + u8 tx_errors_count_ch0;
> + u8 rx_errors_count_ch0;
> + u8 tx_errors_count_ch1;
> + u8 rx_errors_count_ch1;
> + u8 status_ch0;
> + u8 status_ch1;
> + __le16 time;
> +} __packed;
> +
>  struct kvaser_msg_ctrl_mode {
>   u8 tid;
>   u8 channel;
> @@ -243,7 +372,7 @@ struct kvaser_msg_flush_queue {
>   u8 padding[3];
>  } __packed;
>
> -struct kvaser_msg_log_message {
> +struct leaf_msg_log_message {
>   u8 channel;
>   u8 flags;
>   __le16 time[3];
> @@ -260,19 +389,49 @@ struct kvaser_msg {
>   struct kvaser_msg_simple simple;
>   struct kvaser_msg_cardinfo cardinfo;
>   struct kvaser_msg_cardinfo2 cardinfo2;
> - struct kvaser_msg_softinfo softinfo;
>   struct kvaser_msg_busparams busparams;
> +
> + struct kvaser_msg_rx_can_header rx_can_header;
> + struct kvaser_msg_tx_acknowledge_header tx_acknowledge_header;
> +
> + union {
> + struct leaf_msg_softinfo softinfo;
> + struct leaf_msg_rx_can rx_can;
> + struct leaf_msg_chip_state_event chip_state_event;
> + struct leaf_msg_tx_acknowledge tx_acknowledge;
> + struct leaf_msg_error_event error_event;
> + struct leaf_msg_log_message log_message;
> + } __packed leaf;
> +
> + union {
> + struct usbcan_msg_softinfo softinfo;
> + struct usbcan_msg_rx_can rx_can;
> + struct usbcan_msg_chip_state_event chip_state_event;
> + struct usbcan_msg_tx_acknowledge tx_acknowledge;
> + struct usbcan_msg_error_event error_event;
> + } __packed usbcan;
> +
>   struct kvaser_msg_tx_can tx_can;
> - struct kvaser_msg_rx_can rx_can;
> - struct kvaser_msg_chip_state_event chip_state_event;
> - struct kvaser_msg_tx_acknowledge tx_acknowledge;
> - struct kvaser_msg_error_event error_event;
>   struct kvaser_msg_ctrl_mode ctrl_mode;
>   struct kvaser_msg_flush_queue flush_queue;
> - struct kvaser_msg_log_message log_message;
>   } u;
>  } __packed;
>
> +/* Leaf/USBCAN-agnostic summary of an error event.
> + * No M16C error factors for USBCAN-based devices. */
> +struct kvaser_error_summary {
> + u8 channel, status, txerr, rxerr;
> + union {
> + struct {
> + u8 error_factor;
> + } leaf;
> + struct {
> + u8 other_ch_status;
> + u8 error_state;
> + } usbcan;
> + };
> +};
> +
>  struct kvaser_usb_tx_urb_context {
>   struct kvaser_usb_net_priv *priv;
>   u32 echo_index;
> @@ -288,6 +447,8 @@ struct kvaser_usb {
>
>   u32 fw_version;
>   unsigned int nchannels;
> + enum kvaser_usb_family family;
> + unsigned int max_channels;
>
>   bool rxinitdone;
>   void *rxbuf[MAX_RX_URBS];
> @@ -311,6 +472,7 @@ struct kvaser_usb_net_priv {
>  };
>
>  static const struct usb_device_id kvaser_usb_table[] = {
> + /* Leaf family IDs */
>   { USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_DEVEL_PRODUCT_ID) },
>   { USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_LITE_PRODUCT_ID) },
>   { USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_PRO_PRODUCT_ID),
> @@ -360,6 +522,17 @@ static const struct usb_device_id kvaser_usb_table[] = {
>   .driver_info = KVASER_HAS_TXRX_ERRORS },
>   { USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_LITE_V2_PRODUCT_ID) },
>   { USB_DEVICE(KVASER_VENDOR_ID, USB_MINI_PCIE_HS_PRODUCT_ID) },
> +
> + /* USBCANII family IDs */
> + { USB_DEVICE(KVASER_VENDOR_ID, USB_USBCAN2_PRODUCT_ID),
> + .driver_info = KVASER_HAS_TXRX_ERRORS },
> + { USB_DEVICE(KVASER_VENDOR_ID, USB_USBCAN_REVB_PRODUCT_ID),
> + .driver_info = KVASER_HAS_TXRX_ERRORS },
> + { USB_DEVICE(KVASER_VENDOR_ID, USB_MEMORATOR_PRODUCT_ID),
> + .driver_info = KVASER_HAS_TXRX_ERRORS },
> + { USB_DEVICE(KVASER_VENDOR_ID, USB_VCI2_PRODUCT_ID),
> + .driver_info = KVASER_HAS_TXRX_ERRORS },
> +
>   { }
>  };
>  MODULE_DEVICE_TABLE(usb, kvaser_usb_table);
> @@ -463,7 +636,18 @@ static int kvaser_usb_get_software_info(struct kvaser_usb *dev)
>   if (err)
>   return err;
>
> - dev->fw_version = le32_to_cpu(msg.u.softinfo.fw_version);
> + switch (dev->family) {
> + case KVASER_LEAF:
> + dev->fw_version = le32_to_cpu(msg.u.leaf.softinfo.fw_version);
> + break;
> + case KVASER_USBCAN:
> + dev->fw_version = le32_to_cpu(msg.u.usbcan.softinfo.fw_version);
> + break;
> + default:
> + dev_err(dev->udev->dev.parent,
> + "Invalid device family (%d)\n", dev->family);
> + return -EINVAL;
> + }
>
>   return 0;
>  }
> @@ -482,7 +666,7 @@ static int kvaser_usb_get_card_info(struct kvaser_usb *dev)
>   return err;
>
>   dev->nchannels = msg.u.cardinfo.nchannels;
> - if (dev->nchannels > MAX_NET_DEVICES)
> + if (dev->nchannels > dev->max_channels)
>   return -EINVAL;

IMHO, you can keep MAX_NET_DEVICES here.

>
>   return 0;
> @@ -496,8 +680,10 @@ static void kvaser_usb_tx_acknowledge(const struct kvaser_usb *dev,
>   struct kvaser_usb_net_priv *priv;
>   struct sk_buff *skb;
>   struct can_frame *cf;
> - u8 channel = msg->u.tx_acknowledge.channel;
> - u8 tid = msg->u.tx_acknowledge.tid;
> + u8 channel, tid;
> +
> + channel = msg->u.tx_acknowledge_header.channel;
> + tid = msg->u.tx_acknowledge_header.tid;
>
>   if (channel >= dev->nchannels) {
>   dev_err(dev->udev->dev.parent,
> @@ -615,37 +801,83 @@ static void kvaser_usb_unlink_tx_urbs(struct kvaser_usb_net_priv *priv)
>   priv->tx_contexts[i].echo_index = MAX_TX_URBS;
>  }
>
> -static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
> - const struct kvaser_msg *msg)
> +static void kvaser_report_error_event(const struct kvaser_usb *dev,
> +      struct kvaser_error_summary *es);
> +
> +/*
> + * Report error to userspace iff the controller's errors counter has
> + * increased, or we're the only channel seeing the bus error state.
> + *
> + * As reported by USBCAN sheets, "the CAN controller has difficulties
> + * to tell whether an error frame arrived on channel 1 or on channel 2."
> + * Thus, error counters are compared with their earlier values to
> + * determine which channel was responsible for the error event.
> + */
> +static void usbcan_report_error_if_applicable(const struct kvaser_usb *dev,
> +      struct kvaser_error_summary *es)
>  {
> - struct can_frame *cf;
> - struct sk_buff *skb;
> - struct net_device_stats *stats;
>   struct kvaser_usb_net_priv *priv;
> - unsigned int new_state;
> - u8 channel, status, txerr, rxerr, error_factor;
> + int old_tx_err_count, old_rx_err_count, channel, report_error;
> +
> + channel = es->channel;
> + if (channel >= dev->nchannels) {
> + dev_err(dev->udev->dev.parent,
> + "Invalid channel number (%d)\n", channel);
> + return;
> + }
> +
> + priv = dev->nets[channel];
> + old_tx_err_count = priv->bec.txerr;
> + old_rx_err_count = priv->bec.rxerr;
> +
> + report_error = 0;
> + if (es->txerr > old_tx_err_count) {
> + es->usbcan.error_state |= USBCAN_ERROR_STATE_TX_ERROR;
> + report_error = 1;
> + }
> + if (es->rxerr > old_rx_err_count) {
> + es->usbcan.error_state |= USBCAN_ERROR_STATE_RX_ERROR;
> + report_error = 1;
> + }
> + if ((es->status & M16C_STATE_BUS_ERROR) &&
> +    !(es->usbcan.other_ch_status & M16C_STATE_BUS_ERROR)) {
> + es->usbcan.error_state |= USBCAN_ERROR_STATE_BUSERROR;
> + report_error = 1;
> + }
> +
> + if (report_error)
> + kvaser_report_error_event(dev, es);
> +}
> +
> +/*
> + * Extract error summary from a Leaf-based device error message
> + */
> +static void leaf_extract_error_from_msg(const struct kvaser_usb *dev,
> + const struct kvaser_msg *msg)
> +{
> + struct kvaser_error_summary es = { 0, };
>
>   switch (msg->id) {
>   case CMD_CAN_ERROR_EVENT:
> - channel = msg->u.error_event.channel;
> - status =  msg->u.error_event.status;
> - txerr = msg->u.error_event.tx_errors_count;
> - rxerr = msg->u.error_event.rx_errors_count;
> - error_factor = msg->u.error_event.error_factor;
> + es.channel = msg->u.leaf.error_event.channel;
> + es.status =  msg->u.leaf.error_event.status;
> + es.txerr = msg->u.leaf.error_event.tx_errors_count;
> + es.rxerr = msg->u.leaf.error_event.rx_errors_count;
> + es.leaf.error_factor = msg->u.leaf.error_event.error_factor;
>   break;
> - case CMD_LOG_MESSAGE:
> - channel = msg->u.log_message.channel;
> - status = msg->u.log_message.data[0];
> - txerr = msg->u.log_message.data[2];
> - rxerr = msg->u.log_message.data[3];
> - error_factor = msg->u.log_message.data[1];
> + case LEAF_CMD_LOG_MESSAGE:
> + es.channel = msg->u.leaf.log_message.channel;
> + es.status = msg->u.leaf.log_message.data[0];
> + es.txerr = msg->u.leaf.log_message.data[2];
> + es.rxerr = msg->u.leaf.log_message.data[3];
> + es.leaf.error_factor = msg->u.leaf.log_message.data[1];
>   break;
>   case CMD_CHIP_STATE_EVENT:
> - channel = msg->u.chip_state_event.channel;
> - status =  msg->u.chip_state_event.status;
> - txerr = msg->u.chip_state_event.tx_errors_count;
> - rxerr = msg->u.chip_state_event.rx_errors_count;
> - error_factor = 0;
> + es.channel = msg->u.leaf.chip_state_event.channel;
> + es.status =  msg->u.leaf.chip_state_event.status;
> + es.txerr = msg->u.leaf.chip_state_event.tx_errors_count;
> + es.rxerr = msg->u.leaf.chip_state_event.rx_errors_count;
> + es.leaf.error_factor = 0;
>   break;
>   default:
>   dev_err(dev->udev->dev.parent, "Invalid msg id (%d)\n",
> @@ -653,16 +885,92 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>   return;
>   }
>
> - if (channel >= dev->nchannels) {
> + kvaser_report_error_event(dev, &es);
> +}
> +
> +/*
> + * Extract summary from a USBCANII-based device error message.
> + */
> +static void usbcan_extract_error_from_msg(const struct kvaser_usb *dev,
> + const struct kvaser_msg *msg)
> +{
> + struct kvaser_error_summary es = { 0, };
> +
> + switch (msg->id) {
> +
> + /* Sometimes errors are sent as unsolicited chip state events */
> + case CMD_CHIP_STATE_EVENT:
> + es.channel = msg->u.usbcan.chip_state_event.channel;
> + es.status =  msg->u.usbcan.chip_state_event.status;
> + es.txerr = msg->u.usbcan.chip_state_event.tx_errors_count;
> + es.rxerr = msg->u.usbcan.chip_state_event.rx_errors_count;
> + usbcan_report_error_if_applicable(dev, &es);
> + break;
> +
> + case CMD_CAN_ERROR_EVENT:
> + es.channel = 0;
> + es.status = msg->u.usbcan.error_event.status_ch0;
> + es.txerr = msg->u.usbcan.error_event.tx_errors_count_ch0;
> + es.rxerr = msg->u.usbcan.error_event.rx_errors_count_ch0;
> + es.usbcan.other_ch_status =
> + msg->u.usbcan.error_event.status_ch1;
> + usbcan_report_error_if_applicable(dev, &es);
> +
> + /* For error events, the USBCAN firmware does not support
> + * more than 2 channels: ch0, and ch1. */
> + if (dev->nchannels > 1) {
> + es.channel = 1;
> + es.status = msg->u.usbcan.error_event.status_ch1;
> + es.txerr = msg->u.usbcan.error_event.tx_errors_count_ch1;
> + es.rxerr = msg->u.usbcan.error_event.rx_errors_count_ch1;
> + es.usbcan.other_ch_status =
> + msg->u.usbcan.error_event.status_ch0;
> + usbcan_report_error_if_applicable(dev, &es);
> + }
> + break;
> +
> + default:
> + dev_err(dev->udev->dev.parent, "Invalid msg id (%d)\n",
> + msg->id);
> + }
> +}
> +
> +static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
> + const struct kvaser_msg *msg)
> +{
> + switch (dev->family) {
> + case KVASER_LEAF:
> + leaf_extract_error_from_msg(dev, msg);
> + break;
> + case KVASER_USBCAN:
> + usbcan_extract_error_from_msg(dev, msg);
> + break;
> + default:
>   dev_err(dev->udev->dev.parent,
> - "Invalid channel number (%d)\n", channel);
> + "Invalid device family (%d)\n", dev->family);
>   return;
>   }
> +}
>
> - priv = dev->nets[channel];
> +static void kvaser_report_error_event(const struct kvaser_usb *dev,
> +      struct kvaser_error_summary *es)
> +{
> + struct can_frame *cf;
> + struct sk_buff *skb;
> + struct net_device_stats *stats;
> + struct kvaser_usb_net_priv *priv;
> + unsigned int new_state;
> +
> + if (es->channel >= dev->nchannels) {
> + dev_err(dev->udev->dev.parent,
> + "Invalid channel number (%d)\n", es->channel);
> + return;
> + }
> +
> + priv = dev->nets[es->channel];
>   stats = &priv->netdev->stats;
>
> - if (status & M16C_STATE_BUS_RESET) {
> + if (es->status & M16C_STATE_BUS_RESET) {
>   kvaser_usb_unlink_tx_urbs(priv);
>   return;
>   }
> @@ -675,9 +983,9 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>
>   new_state = priv->can.state;
>
> - netdev_dbg(priv->netdev, "Error status: 0x%02x\n", status);
> + netdev_dbg(priv->netdev, "Error status: 0x%02x\n", es->status);
>
> - if (status & M16C_STATE_BUS_OFF) {
> + if (es->status & M16C_STATE_BUS_OFF) {
>   cf->can_id |= CAN_ERR_BUSOFF;
>
>   priv->can.can_stats.bus_off++;
> @@ -687,12 +995,12 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>   netif_carrier_off(priv->netdev);
>
>   new_state = CAN_STATE_BUS_OFF;
> - } else if (status & M16C_STATE_BUS_PASSIVE) {
> + } else if (es->status & M16C_STATE_BUS_PASSIVE) {
>   if (priv->can.state != CAN_STATE_ERROR_PASSIVE) {
>   cf->can_id |= CAN_ERR_CRTL;
>
> - if (txerr || rxerr)
> - cf->data[1] = (txerr > rxerr)
> + if (es->txerr || es->rxerr)
> + cf->data[1] = (es->txerr > es->rxerr)
>   ? CAN_ERR_CRTL_TX_PASSIVE
>   : CAN_ERR_CRTL_RX_PASSIVE;
>   else
> @@ -703,13 +1011,11 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>   }
>
>   new_state = CAN_STATE_ERROR_PASSIVE;
> - }
> -
> - if (status == M16C_STATE_BUS_ERROR) {
> + } else if (es->status & M16C_STATE_BUS_ERROR) {
>   if ((priv->can.state < CAN_STATE_ERROR_WARNING) &&
> -    ((txerr >= 96) || (rxerr >= 96))) {
> +    ((es->txerr >= 96) || (es->rxerr >= 96))) {
>   cf->can_id |= CAN_ERR_CRTL;
> - cf->data[1] = (txerr > rxerr)
> + cf->data[1] = (es->txerr > es->rxerr)
>   ? CAN_ERR_CRTL_TX_WARNING
>   : CAN_ERR_CRTL_RX_WARNING;
>
> @@ -723,7 +1029,7 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>   }
>   }
>
> - if (!status) {
> + if (!es->status) {
>   cf->can_id |= CAN_ERR_PROT;
>   cf->data[2] = CAN_ERR_PROT_ACTIVE;
>
> @@ -739,34 +1045,52 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>   priv->can.can_stats.restarts++;
>   }
>
> - if (error_factor) {
> - priv->can.can_stats.bus_error++;
> - stats->rx_errors++;
> -
> - cf->can_id |= CAN_ERR_BUSERROR | CAN_ERR_PROT;
> -
> - if (error_factor & M16C_EF_ACKE)
> - cf->data[3] |= (CAN_ERR_PROT_LOC_ACK);
> - if (error_factor & M16C_EF_CRCE)
> - cf->data[3] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
> - CAN_ERR_PROT_LOC_CRC_DEL);
> - if (error_factor & M16C_EF_FORME)
> - cf->data[2] |= CAN_ERR_PROT_FORM;
> - if (error_factor & M16C_EF_STFE)
> - cf->data[2] |= CAN_ERR_PROT_STUFF;
> - if (error_factor & M16C_EF_BITE0)
> - cf->data[2] |= CAN_ERR_PROT_BIT0;
> - if (error_factor & M16C_EF_BITE1)
> - cf->data[2] |= CAN_ERR_PROT_BIT1;
> - if (error_factor & M16C_EF_TRE)
> - cf->data[2] |= CAN_ERR_PROT_TX;
> + switch (dev->family) {
> + case KVASER_LEAF:
> + if (es->leaf.error_factor) {
> + priv->can.can_stats.bus_error++;
> + stats->rx_errors++;
> +
> + cf->can_id |= CAN_ERR_BUSERROR | CAN_ERR_PROT;
> +
> + if (es->leaf.error_factor & M16C_EF_ACKE)
> + cf->data[3] |= (CAN_ERR_PROT_LOC_ACK);
> + if (es->leaf.error_factor & M16C_EF_CRCE)
> + cf->data[3] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
> + CAN_ERR_PROT_LOC_CRC_DEL);
> + if (es->leaf.error_factor & M16C_EF_FORME)
> + cf->data[2] |= CAN_ERR_PROT_FORM;
> + if (es->leaf.error_factor & M16C_EF_STFE)
> + cf->data[2] |= CAN_ERR_PROT_STUFF;
> + if (es->leaf.error_factor & M16C_EF_BITE0)
> + cf->data[2] |= CAN_ERR_PROT_BIT0;
> + if (es->leaf.error_factor & M16C_EF_BITE1)
> + cf->data[2] |= CAN_ERR_PROT_BIT1;
> + if (es->leaf.error_factor & M16C_EF_TRE)
> + cf->data[2] |= CAN_ERR_PROT_TX;
> + }
> + break;
> + case KVASER_USBCAN:
> + if (es->usbcan.error_state & USBCAN_ERROR_STATE_TX_ERROR)
> + stats->tx_errors++;
> + if (es->usbcan.error_state & USBCAN_ERROR_STATE_RX_ERROR)
> + stats->rx_errors++;
> + if (es->usbcan.error_state & USBCAN_ERROR_STATE_BUSERROR) {
> + priv->can.can_stats.bus_error++;
> + cf->can_id |= CAN_ERR_BUSERROR;
> + }
> + break;
> + default:
> + dev_err(dev->udev->dev.parent,
> + "Invalid device family (%d)\n", dev->family);
> + goto err;
>   }
>
> - cf->data[6] = txerr;
> - cf->data[7] = rxerr;
> + cf->data[6] = es->txerr;
> + cf->data[7] = es->rxerr;
>
> - priv->bec.txerr = txerr;
> - priv->bec.rxerr = rxerr;
> + priv->bec.txerr = es->txerr;
> + priv->bec.rxerr = es->rxerr;
>
>   priv->can.state = new_state;
>
> @@ -774,6 +1098,11 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
>
>   stats->rx_packets++;
>   stats->rx_bytes += cf->can_dlc;
> +
> + return;
> +
> +err:
> + dev_kfree_skb(skb);
>  }
>
>  static void kvaser_usb_rx_can_err(const struct kvaser_usb_net_priv *priv,
> @@ -783,16 +1112,16 @@ static void kvaser_usb_rx_can_err(const struct kvaser_usb_net_priv *priv,
>   struct sk_buff *skb;
>   struct net_device_stats *stats = &priv->netdev->stats;
>
> - if (msg->u.rx_can.flag & (MSG_FLAG_ERROR_FRAME |
> + if (msg->u.rx_can_header.flag & (MSG_FLAG_ERROR_FRAME |
>   MSG_FLAG_NERR)) {
>   netdev_err(priv->netdev, "Unknow error (flags: 0x%02x)\n",
> -   msg->u.rx_can.flag);
> +   msg->u.rx_can_header.flag);
>
>   stats->rx_errors++;
>   return;
>   }
>
> - if (msg->u.rx_can.flag & MSG_FLAG_OVERRUN) {
> + if (msg->u.rx_can_header.flag & MSG_FLAG_OVERRUN) {
>   skb = alloc_can_err_skb(priv->netdev, &cf);
>   if (!skb) {
>   stats->rx_dropped++;
> @@ -819,7 +1148,8 @@ static void kvaser_usb_rx_can_msg(const struct kvaser_usb *dev,
>   struct can_frame *cf;
>   struct sk_buff *skb;
>   struct net_device_stats *stats;
> - u8 channel = msg->u.rx_can.channel;
> + u8 channel = msg->u.rx_can_header.channel;
> + const u8 *rx_msg;
>
>   if (channel >= dev->nchannels) {
>   dev_err(dev->udev->dev.parent,
> @@ -830,19 +1160,32 @@ static void kvaser_usb_rx_can_msg(const struct kvaser_usb *dev,
>   priv = dev->nets[channel];
>   stats = &priv->netdev->stats;
>
> - if ((msg->u.rx_can.flag & MSG_FLAG_ERROR_FRAME) &&
> -    (msg->id == CMD_LOG_MESSAGE)) {
> + if ((msg->u.rx_can_header.flag & MSG_FLAG_ERROR_FRAME) &&
> +    (dev->family == KVASER_LEAF && msg->id == LEAF_CMD_LOG_MESSAGE)) {
>   kvaser_usb_rx_error(dev, msg);
>   return;
> - } else if (msg->u.rx_can.flag & (MSG_FLAG_ERROR_FRAME |
> - MSG_FLAG_NERR |
> - MSG_FLAG_OVERRUN)) {
> + } else if (msg->u.rx_can_header.flag & (MSG_FLAG_ERROR_FRAME |
> + MSG_FLAG_NERR |
> + MSG_FLAG_OVERRUN)) {
>   kvaser_usb_rx_can_err(priv, msg);
>   return;
> - } else if (msg->u.rx_can.flag & ~MSG_FLAG_REMOTE_FRAME) {
> + } else if (msg->u.rx_can_header.flag & ~MSG_FLAG_REMOTE_FRAME) {
>   netdev_warn(priv->netdev,
>      "Unhandled frame (flags: 0x%02x)",
> -    msg->u.rx_can.flag);
> +    msg->u.rx_can_header.flag);
> + return;
> + }
> +
> + switch (dev->family) {
> + case KVASER_LEAF:
> + rx_msg = msg->u.leaf.rx_can.msg;
> + break;
> + case KVASER_USBCAN:
> + rx_msg = msg->u.usbcan.rx_can.msg;
> + break;
> + default:
> + dev_err(dev->udev->dev.parent,
> + "Invalid device family (%d)\n", dev->family);
>   return;
>   }
>
> @@ -852,38 +1195,37 @@ static void kvaser_usb_rx_can_msg(const struct kvaser_usb *dev,
>   return;
>   }
>
> - if (msg->id == CMD_LOG_MESSAGE) {
> - cf->can_id = le32_to_cpu(msg->u.log_message.id);
> + if (dev->family == KVASER_LEAF && msg->id == LEAF_CMD_LOG_MESSAGE) {
> + cf->can_id = le32_to_cpu(msg->u.leaf.log_message.id);
>   if (cf->can_id & KVASER_EXTENDED_FRAME)
>   cf->can_id &= CAN_EFF_MASK | CAN_EFF_FLAG;
>   else
>   cf->can_id &= CAN_SFF_MASK;
>
> - cf->can_dlc = get_can_dlc(msg->u.log_message.dlc);
> + cf->can_dlc = get_can_dlc(msg->u.leaf.log_message.dlc);
>
> - if (msg->u.log_message.flags & MSG_FLAG_REMOTE_FRAME)
> + if (msg->u.leaf.log_message.flags & MSG_FLAG_REMOTE_FRAME)
>   cf->can_id |= CAN_RTR_FLAG;
>   else
> - memcpy(cf->data, &msg->u.log_message.data,
> + memcpy(cf->data, &msg->u.leaf.log_message.data,
>         cf->can_dlc);
>   } else {
> - cf->can_id = ((msg->u.rx_can.msg[0] & 0x1f) << 6) |
> -     (msg->u.rx_can.msg[1] & 0x3f);
> + cf->can_id = ((rx_msg[0] & 0x1f) << 6) | (rx_msg[1] & 0x3f);
>
>   if (msg->id == CMD_RX_EXT_MESSAGE) {
>   cf->can_id <<= 18;
> - cf->can_id |= ((msg->u.rx_can.msg[2] & 0x0f) << 14) |
> -      ((msg->u.rx_can.msg[3] & 0xff) << 6) |
> -      (msg->u.rx_can.msg[4] & 0x3f);
> + cf->can_id |= ((rx_msg[2] & 0x0f) << 14) |
> +      ((rx_msg[3] & 0xff) << 6) |
> +      (rx_msg[4] & 0x3f);
>   cf->can_id |= CAN_EFF_FLAG;
>   }
>
> - cf->can_dlc = get_can_dlc(msg->u.rx_can.msg[5]);
> + cf->can_dlc = get_can_dlc(rx_msg[5]);
>
> - if (msg->u.rx_can.flag & MSG_FLAG_REMOTE_FRAME)
> + if (msg->u.rx_can_header.flag & MSG_FLAG_REMOTE_FRAME)
>   cf->can_id |= CAN_RTR_FLAG;
>   else
> - memcpy(cf->data, &msg->u.rx_can.msg[6],
> + memcpy(cf->data, &rx_msg[6],
>         cf->can_dlc);
>   }
>
> @@ -947,7 +1289,12 @@ static void kvaser_usb_handle_message(const struct kvaser_usb *dev,
>
>   case CMD_RX_STD_MESSAGE:
>   case CMD_RX_EXT_MESSAGE:
> - case CMD_LOG_MESSAGE:
> + kvaser_usb_rx_can_msg(dev, msg);
> + break;
> +
> + case LEAF_CMD_LOG_MESSAGE:
> + if (dev->family != KVASER_LEAF)
> + goto warn;
>   kvaser_usb_rx_can_msg(dev, msg);
>   break;
>
> @@ -960,8 +1307,14 @@ static void kvaser_usb_handle_message(const struct kvaser_usb *dev,
>   kvaser_usb_tx_acknowledge(dev, msg);
>   break;
>
> + /* Ignored messages */
> + case USBCAN_CMD_CLOCK_OVERFLOW_EVENT:
> + if (dev->family != KVASER_USBCAN)
> + goto warn;
> + break;
> +
>   default:
> - dev_warn(dev->udev->dev.parent,
> +warn: dev_warn(dev->udev->dev.parent,
>   "Unhandled message (%d)\n", msg->id);
>   break;
>   }
> @@ -1181,7 +1534,7 @@ static void kvaser_usb_unlink_all_urbs(struct kvaser_usb *dev)
>    dev->rxbuf[i],
>    dev->rxbuf_dma[i]);
>
> - for (i = 0; i < MAX_NET_DEVICES; i++) {
> + for (i = 0; i < dev->max_channels; i++) {

here too... or replace it by nchannels.

>   struct kvaser_usb_net_priv *priv = dev->nets[i];
>
>   if (priv)
> @@ -1286,6 +1639,7 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
>   struct kvaser_msg *msg;
>   int i, err;
>   int ret = NETDEV_TX_OK;
> + uint8_t *msg_tx_can_flags;
>   bool kfree_skb_on_error = true;
>
>   if (can_dropped_invalid_skb(netdev, skb))
> @@ -1306,9 +1660,23 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
>
>   msg = buf;
>   msg->len = MSG_HEADER_LEN + sizeof(struct kvaser_msg_tx_can);
> - msg->u.tx_can.flags = 0;
>   msg->u.tx_can.channel = priv->channel;
>
> + switch (dev->family) {
> + case KVASER_LEAF:
> + msg_tx_can_flags = &msg->u.tx_can.leaf.flags;
> + break;
> + case KVASER_USBCAN:
> + msg_tx_can_flags = &msg->u.tx_can.usbcan.flags;
> + break;
> + default:
> + dev_err(dev->udev->dev.parent,
> + "Invalid device family (%d)\n", dev->family);
> + goto releasebuf;
> + }
> +
> + *msg_tx_can_flags = 0;
> +
>   if (cf->can_id & CAN_EFF_FLAG) {
>   msg->id = CMD_TX_EXT_MESSAGE;
>   msg->u.tx_can.msg[0] = (cf->can_id >> 24) & 0x1f;
> @@ -1326,7 +1694,7 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
>   memcpy(&msg->u.tx_can.msg[6], cf->data, cf->can_dlc);
>
>   if (cf->can_id & CAN_RTR_FLAG)
> - msg->u.tx_can.flags |= MSG_FLAG_REMOTE_FRAME;
> + *msg_tx_can_flags |= MSG_FLAG_REMOTE_FRAME;
>
>   for (i = 0; i < ARRAY_SIZE(priv->tx_contexts); i++) {
>   if (priv->tx_contexts[i].echo_index == MAX_TX_URBS) {
> @@ -1596,6 +1964,18 @@ static int kvaser_usb_probe(struct usb_interface *intf,
>   if (!dev)
>   return -ENOMEM;
>
> + if (LEAF_PRODUCT_ID(id->idProduct)) {
> + dev->family = KVASER_LEAF;
> + dev->max_channels = LEAF_MAX_NET_DEVICES;
> + } else if (USBCAN_PRODUCT_ID(id->idProduct)) {
> + dev->family = KVASER_USBCAN;
> + dev->max_channels = USBCAN_MAX_NET_DEVICES;
> + } else {
> + dev_err(&intf->dev, "Product ID (%d) does not belong to any "
> +    "known Kvaser USB family", id->idProduct);
> + return -ENODEV;
> + }

Is it really required to keep max_channels in the kvaser_usb structure?
If I looked correctly, you use this variable as a replacement for
MAX_NET_DEVICES in the code and MAX_NET_DEVICES is only used in probe
and disconnect functions. I think it can even be replaced by nchannels
in the disconnect path. So I also think that it don't need to be in the
kvaser_usb structure.

> +
>   err = kvaser_usb_get_endpoints(intf, &dev->bulk_in, &dev->bulk_out);
>   if (err) {
>   dev_err(&intf->dev, "Cannot get usb endpoint(s)");
> @@ -1608,7 +1988,7 @@ static int kvaser_usb_probe(struct usb_interface *intf,
>
>   usb_set_intfdata(intf, dev);
>
> - for (i = 0; i < MAX_NET_DEVICES; i++)
> + for (i = 0; i < dev->max_channels; i++)
>   kvaser_usb_send_simple_msg(dev, CMD_RESET_CHIP, i);

Someone reported me that recent leaf firmwares go in trouble when
you send a command for a channel that does not exist. Instead of
max_channels, you can use nchannels here and move the reset command
in the kvaser_usb_init_one() function.
I've a patch for this but It is not tested yet. I'll send it next week-end after
I did some tests.

>
>   err = kvaser_usb_get_software_info(dev);

Thank you,

-- 
Olivier
