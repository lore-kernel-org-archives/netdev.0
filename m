From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH v6 7/7] can: kvaser_usb: Add support for the USBcan-II family
Date: Mon, 26 Jan 2015 07:33:10 +0200
Message-ID: <20150126053310.GH3014@Darwish.PC>
References: <20141223154654.GB6460@vivalin-002>
 <20150126051755.GA3014@Darwish.PC>
 <20150126052039.GB3014@Darwish.PC>
 <20150126052254.GC3014@Darwish.PC>
 <20150126052406.GD3014@Darwish.PC>
 <20150126052543.GE3014@Darwish.PC>
 <20150126052719.GF3014@Darwish.PC>
 <20150126052915.GG3014@Darwish.PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Andri Yngvason <andri.yngvason@marel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150126052915.GG3014@Darwish.PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ahmed S. Darwish <ahmed.darwish@valeo.com>

CAN to USB interfaces sold by the Swedish manufacturer Kvaser are
divided into two major families: 'Leaf', and 'USBcanII'.  From an
Operating System perspective, the firmware of both families behave
in a not too drastically different fashion.

This patch adds support for the USBcanII family of devices to the
current Kvaser Leaf-only driver.

CAN frames sending, receiving, and error handling paths has been
tested using the dual-channel "Kvaser USBcan II HS/LS" dongle. It
should also work nicely with other products in the same category.

List of new devices supported by this driver update:

         - Kvaser USBcan II HS/HS
         - Kvaser USBcan II HS/LS
         - Kvaser USBcan Rugged ("USBcan Rev B")
         - Kvaser Memorator HS/HS
         - Kvaser Memorator HS/LS
         - Scania VCI2 (if you have the Kvaser logo on top)

Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
---
 drivers/net/can/usb/Kconfig      |    8 +-
 drivers/net/can/usb/kvaser_usb.c |  590 ++++++++++++++++++++++++++++++--------
 2 files changed, 474 insertions(+), 124 deletions(-)

** V6 Changelog:
- Revert to the error-active state if the error counters were
  decreased by hardware
- Rebase over a new set of upstream Leaf-driver bugfixes

** V5 Changelog:
- Rebase on the new CAN error state changes added for the Leaf driver
- Add minor changes (remove unused commands, constify poniters, etc.)

** V4 Changelog:
- Use type-safe C methods instead of cpp macros
- Remove defensive checks against non-existing families
- Re-order methods to remove forward declarations
- Smaller stuff spotted by earlier review (function prefexes, etc.)

** V3 Changelog:
- Fix padding for the usbcan_msg_tx_acknowledge command
- Remove kvaser_usb->max_channels and the MAX_NET_DEVICES macro
- Rename commands to CMD_LEAF_xxx and CMD_USBCAN_xxx
- Apply checkpatch.pl suggestions ('net/' comments, multi-line strings, etc.)

** V2 Changelog:
- Update Kconfig entries
- Use actual number of CAN channels (instead of max) where appropriate
- Rebase over a new set of UsbcanII-independent driver fixes

diff --git a/drivers/net/can/usb/Kconfig b/drivers/net/can/usb/Kconfig
index a77db919..f6f5500 100644
--- a/drivers/net/can/usb/Kconfig
+++ b/drivers/net/can/usb/Kconfig
@@ -25,7 +25,7 @@ config CAN_KVASER_USB
 	tristate "Kvaser CAN/USB interface"
 	---help---
 	  This driver adds support for Kvaser CAN/USB devices like Kvaser
-	  Leaf Light.
+	  Leaf Light and Kvaser USBcan II.
 
 	  The driver provides support for the following devices:
 	    - Kvaser Leaf Light
@@ -46,6 +46,12 @@ config CAN_KVASER_USB
 	    - Kvaser USBcan R
 	    - Kvaser Leaf Light v2
 	    - Kvaser Mini PCI Express HS
+	    - Kvaser USBcan II HS/HS
+	    - Kvaser USBcan II HS/LS
+	    - Kvaser USBcan Rugged ("USBcan Rev B")
+	    - Kvaser Memorator HS/HS
+	    - Kvaser Memorator HS/LS
+	    - Scania VCI2 (if you have the Kvaser logo on top)
 
 	  If unsure, say N.
 
diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index ddc2954..17d28d7 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -6,10 +6,12 @@
  * Parts of this driver are based on the following:
  *  - Kvaser linux leaf driver (version 4.78)
  *  - CAN driver for esd CAN-USB/2
+ *  - Kvaser linux usbcanII driver (version 5.3)
  *
  * Copyright (C) 2002-2006 KVASER AB, Sweden. All rights reserved.
  * Copyright (C) 2010 Matthias Fuchs <matthias.fuchs@esd.eu>, esd gmbh
  * Copyright (C) 2012 Olivier Sobrie <olivier@sobrie.be>
+ * Copyright (C) 2015 Valeo A.S.
  */
 
 #include <linux/completion.h>
@@ -30,8 +32,9 @@
 #define RX_BUFFER_SIZE			3072
 #define CAN_USB_CLOCK			8000000
 #define MAX_NET_DEVICES			3
+#define MAX_USBCAN_NET_DEVICES		2
 
-/* Kvaser USB devices */
+/* Kvaser Leaf USB devices */
 #define KVASER_VENDOR_ID		0x0bfd
 #define USB_LEAF_DEVEL_PRODUCT_ID	10
 #define USB_LEAF_LITE_PRODUCT_ID	11
@@ -56,6 +59,24 @@
 #define USB_LEAF_LITE_V2_PRODUCT_ID	288
 #define USB_MINI_PCIE_HS_PRODUCT_ID	289
 
+static inline bool kvaser_is_leaf(const struct usb_device_id *id)
+{
+	return id->idProduct >= USB_LEAF_DEVEL_PRODUCT_ID &&
+	       id->idProduct <= USB_MINI_PCIE_HS_PRODUCT_ID;
+}
+
+/* Kvaser USBCan-II devices */
+#define USB_USBCAN_REVB_PRODUCT_ID	2
+#define USB_VCI2_PRODUCT_ID		3
+#define USB_USBCAN2_PRODUCT_ID		4
+#define USB_MEMORATOR_PRODUCT_ID	5
+
+static inline bool kvaser_is_usbcan(const struct usb_device_id *id)
+{
+	return id->idProduct >= USB_USBCAN_REVB_PRODUCT_ID &&
+	       id->idProduct <= USB_MEMORATOR_PRODUCT_ID;
+}
+
 /* USB devices features */
 #define KVASER_HAS_SILENT_MODE		BIT(0)
 #define KVASER_HAS_TXRX_ERRORS		BIT(1)
@@ -73,7 +94,7 @@
 #define MSG_FLAG_TX_ACK			BIT(6)
 #define MSG_FLAG_TX_REQUEST		BIT(7)
 
-/* Can states */
+/* Can states (M16C CxSTRH register) */
 #define M16C_STATE_BUS_RESET		BIT(0)
 #define M16C_STATE_BUS_ERROR		BIT(4)
 #define M16C_STATE_BUS_PASSIVE		BIT(5)
@@ -98,7 +119,11 @@
 #define CMD_START_CHIP_REPLY		27
 #define CMD_STOP_CHIP			28
 #define CMD_STOP_CHIP_REPLY		29
-#define CMD_GET_CARD_INFO2		32
+
+#define CMD_LEAF_GET_CARD_INFO2		32
+#define CMD_USBCAN_RESET_CLOCK		32
+#define CMD_USBCAN_CLOCK_OVERFLOW_EVENT	33
+
 #define CMD_GET_CARD_INFO		34
 #define CMD_GET_CARD_INFO_REPLY		35
 #define CMD_GET_SOFTWARE_INFO		38
@@ -108,8 +133,9 @@
 #define CMD_RESET_ERROR_COUNTER		49
 #define CMD_TX_ACKNOWLEDGE		50
 #define CMD_CAN_ERROR_EVENT		51
-#define CMD_USB_THROTTLE		77
-#define CMD_LOG_MESSAGE			106
+
+#define CMD_LEAF_USB_THROTTLE		77
+#define CMD_LEAF_LOG_MESSAGE		106
 
 /* error factors */
 #define M16C_EF_ACKE			BIT(0)
@@ -121,6 +147,14 @@
 #define M16C_EF_RCVE			BIT(6)
 #define M16C_EF_TRE			BIT(7)
 
+/* Only Leaf-based devices can report M16C error factors,
+ * thus define our own error status flags for USBCANII
+ */
+#define USBCAN_ERROR_STATE_NONE		0
+#define USBCAN_ERROR_STATE_TX_ERROR	BIT(0)
+#define USBCAN_ERROR_STATE_RX_ERROR	BIT(1)
+#define USBCAN_ERROR_STATE_BUSERROR	BIT(2)
+
 /* bittiming parameters */
 #define KVASER_USB_TSEG1_MIN		1
 #define KVASER_USB_TSEG1_MAX		16
@@ -137,9 +171,18 @@
 #define KVASER_CTRL_MODE_SELFRECEPTION	3
 #define KVASER_CTRL_MODE_OFF		4
 
-/* log message */
+/* Extended CAN identifier flag */
 #define KVASER_EXTENDED_FRAME		BIT(31)
 
+/* Kvaser USB CAN dongles are divided into two major families:
+ * - Leaf: Based on Renesas M32C, running firmware labeled as 'filo'
+ * - UsbcanII: Based on Renesas M16C, running firmware labeled as 'helios'
+ */
+enum kvaser_usb_family {
+	KVASER_LEAF,
+	KVASER_USBCAN,
+};
+
 struct kvaser_msg_simple {
 	u8 tid;
 	u8 channel;
@@ -148,30 +191,55 @@ struct kvaser_msg_simple {
 struct kvaser_msg_cardinfo {
 	u8 tid;
 	u8 nchannels;
-	__le32 serial_number;
-	__le32 padding;
+	union {
+		struct {
+			__le32 serial_number;
+			__le32 padding;
+		} __packed leaf0;
+		struct {
+			__le32 serial_number_low;
+			__le32 serial_number_high;
+		} __packed usbcan0;
+	} __packed;
 	__le32 clock_resolution;
 	__le32 mfgdate;
 	u8 ean[8];
 	u8 hw_revision;
-	u8 usb_hs_mode;
-	__le16 padding2;
+	union {
+		struct {
+			u8 usb_hs_mode;
+		} __packed leaf1;
+		struct {
+			u8 padding;
+		} __packed usbcan1;
+	} __packed;
+	__le16 padding;
 } __packed;
 
 struct kvaser_msg_cardinfo2 {
 	u8 tid;
-	u8 channel;
+	u8 reserved;
 	u8 pcb_id[24];
 	__le32 oem_unlock_code;
 } __packed;
 
-struct kvaser_msg_softinfo {
+struct leaf_msg_softinfo {
 	u8 tid;
-	u8 channel;
+	u8 padding0;
 	__le32 sw_options;
 	__le32 fw_version;
 	__le16 max_outstanding_tx;
-	__le16 padding[9];
+	__le16 padding1[9];
+} __packed;
+
+struct usbcan_msg_softinfo {
+	u8 tid;
+	u8 fw_name[5];
+	__le16 max_outstanding_tx;
+	u8 padding[6];
+	__le32 fw_version;
+	__le16 checksum;
+	__le16 sw_options;
 } __packed;
 
 struct kvaser_msg_busparams {
@@ -188,36 +256,86 @@ struct kvaser_msg_tx_can {
 	u8 channel;
 	u8 tid;
 	u8 msg[14];
-	u8 padding;
-	u8 flags;
+	union {
+		struct {
+			u8 padding;
+			u8 flags;
+		} __packed leaf;
+		struct {
+			u8 flags;
+			u8 padding;
+		} __packed usbcan;
+	} __packed;
+} __packed;
+
+struct kvaser_msg_rx_can_header {
+	u8 channel;
+	u8 flag;
 } __packed;
 
-struct kvaser_msg_rx_can {
+struct leaf_msg_rx_can {
 	u8 channel;
 	u8 flag;
+
 	__le16 time[3];
 	u8 msg[14];
 } __packed;
 
-struct kvaser_msg_chip_state_event {
+struct usbcan_msg_rx_can {
+	u8 channel;
+	u8 flag;
+
+	u8 msg[14];
+	__le16 time;
+} __packed;
+
+struct leaf_msg_chip_state_event {
 	u8 tid;
 	u8 channel;
+
 	__le16 time[3];
 	u8 tx_errors_count;
 	u8 rx_errors_count;
+
+	u8 status;
+	u8 padding[3];
+} __packed;
+
+struct usbcan_msg_chip_state_event {
+	u8 tid;
+	u8 channel;
+
+	u8 tx_errors_count;
+	u8 rx_errors_count;
+	__le16 time;
+
 	u8 status;
 	u8 padding[3];
 } __packed;
 
-struct kvaser_msg_tx_acknowledge {
+struct kvaser_msg_tx_acknowledge_header {
 	u8 channel;
 	u8 tid;
+} __packed;
+
+struct leaf_msg_tx_acknowledge {
+	u8 channel;
+	u8 tid;
+
 	__le16 time[3];
 	u8 flags;
 	u8 time_offset;
 } __packed;
 
-struct kvaser_msg_error_event {
+struct usbcan_msg_tx_acknowledge {
+	u8 channel;
+	u8 tid;
+
+	__le16 time;
+	__le16 padding;
+} __packed;
+
+struct leaf_msg_error_event {
 	u8 tid;
 	u8 flags;
 	__le16 time[3];
@@ -229,6 +347,18 @@ struct kvaser_msg_error_event {
 	u8 error_factor;
 } __packed;
 
+struct usbcan_msg_error_event {
+	u8 tid;
+	u8 padding;
+	u8 tx_errors_count_ch0;
+	u8 rx_errors_count_ch0;
+	u8 tx_errors_count_ch1;
+	u8 rx_errors_count_ch1;
+	u8 status_ch0;
+	u8 status_ch1;
+	__le16 time;
+} __packed;
+
 struct kvaser_msg_ctrl_mode {
 	u8 tid;
 	u8 channel;
@@ -243,7 +373,7 @@ struct kvaser_msg_flush_queue {
 	u8 padding[3];
 } __packed;
 
-struct kvaser_msg_log_message {
+struct leaf_msg_log_message {
 	u8 channel;
 	u8 flags;
 	__le16 time[3];
@@ -260,21 +390,55 @@ struct kvaser_msg {
 		struct kvaser_msg_simple simple;
 		struct kvaser_msg_cardinfo cardinfo;
 		struct kvaser_msg_cardinfo2 cardinfo2;
-		struct kvaser_msg_softinfo softinfo;
 		struct kvaser_msg_busparams busparams;
+
+		struct kvaser_msg_rx_can_header rx_can_header;
+		struct kvaser_msg_tx_acknowledge_header tx_acknowledge_header;
+
+		union {
+			struct leaf_msg_softinfo softinfo;
+			struct leaf_msg_rx_can rx_can;
+			struct leaf_msg_chip_state_event chip_state_event;
+			struct leaf_msg_tx_acknowledge tx_acknowledge;
+			struct leaf_msg_error_event error_event;
+			struct leaf_msg_log_message log_message;
+		} __packed leaf;
+
+		union {
+			struct usbcan_msg_softinfo softinfo;
+			struct usbcan_msg_rx_can rx_can;
+			struct usbcan_msg_chip_state_event chip_state_event;
+			struct usbcan_msg_tx_acknowledge tx_acknowledge;
+			struct usbcan_msg_error_event error_event;
+		} __packed usbcan;
+
 		struct kvaser_msg_tx_can tx_can;
-		struct kvaser_msg_rx_can rx_can;
-		struct kvaser_msg_chip_state_event chip_state_event;
-		struct kvaser_msg_tx_acknowledge tx_acknowledge;
-		struct kvaser_msg_error_event error_event;
 		struct kvaser_msg_ctrl_mode ctrl_mode;
 		struct kvaser_msg_flush_queue flush_queue;
-		struct kvaser_msg_log_message log_message;
 	} u;
 } __packed;
 
+/* Summary of a kvaser error event, for a unified Leaf/Usbcan error
+ * handling. Some discrepancies between the two families exist:
+ *
+ * - USBCAN firmware does not report M16C "error factors"
+ * - USBCAN controllers has difficulties reporting if the raised error
+ *   event is for ch0 or ch1. They leave such arbitration to the OS
+ *   driver by letting it compare error counters with previous values
+ *   and decide the error event's channel. Thus for USBCAN, the channel
+ *   field is only advisory.
+ */
 struct kvaser_usb_error_summary {
-	u8 channel, status, txerr, rxerr, error_factor;
+	u8 channel, status, txerr, rxerr;
+	union {
+		struct {
+			u8 error_factor;
+		} leaf;
+		struct {
+			u8 other_ch_status;
+			u8 error_state;
+		} usbcan;
+	};
 };
 
 struct kvaser_usb_tx_urb_context {
@@ -292,6 +456,7 @@ struct kvaser_usb {
 
 	u32 fw_version;
 	unsigned int nchannels;
+	enum kvaser_usb_family family;
 
 	bool rxinitdone;
 	void *rxbuf[MAX_RX_URBS];
@@ -315,6 +480,7 @@ struct kvaser_usb_net_priv {
 };
 
 static const struct usb_device_id kvaser_usb_table[] = {
+	/* Leaf family IDs */
 	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_DEVEL_PRODUCT_ID) },
 	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_LITE_PRODUCT_ID) },
 	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_PRO_PRODUCT_ID),
@@ -364,6 +530,17 @@ static const struct usb_device_id kvaser_usb_table[] = {
 		.driver_info = KVASER_HAS_TXRX_ERRORS },
 	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_LITE_V2_PRODUCT_ID) },
 	{ USB_DEVICE(KVASER_VENDOR_ID, USB_MINI_PCIE_HS_PRODUCT_ID) },
+
+	/* USBCANII family IDs */
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_USBCAN2_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_USBCAN_REVB_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_MEMORATOR_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_VCI2_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS },
+
 	{ }
 };
 MODULE_DEVICE_TABLE(usb, kvaser_usb_table);
@@ -467,7 +644,14 @@ static int kvaser_usb_get_software_info(struct kvaser_usb *dev)
 	if (err)
 		return err;
 
-	dev->fw_version = le32_to_cpu(msg.u.softinfo.fw_version);
+	switch (dev->family) {
+	case KVASER_LEAF:
+		dev->fw_version = le32_to_cpu(msg.u.leaf.softinfo.fw_version);
+		break;
+	case KVASER_USBCAN:
+		dev->fw_version = le32_to_cpu(msg.u.usbcan.softinfo.fw_version);
+		break;
+	}
 
 	return 0;
 }
@@ -486,7 +670,9 @@ static int kvaser_usb_get_card_info(struct kvaser_usb *dev)
 		return err;
 
 	dev->nchannels = msg.u.cardinfo.nchannels;
-	if (dev->nchannels > MAX_NET_DEVICES)
+	if ((dev->nchannels > MAX_NET_DEVICES) ||
+	    (dev->family == KVASER_USBCAN &&
+	     dev->nchannels > MAX_USBCAN_NET_DEVICES))
 		return -EINVAL;
 
 	return 0;
@@ -500,8 +686,10 @@ static void kvaser_usb_tx_acknowledge(const struct kvaser_usb *dev,
 	struct kvaser_usb_net_priv *priv;
 	struct sk_buff *skb;
 	struct can_frame *cf;
-	u8 channel = msg->u.tx_acknowledge.channel;
-	u8 tid = msg->u.tx_acknowledge.tid;
+	u8 channel, tid;
+
+	channel = msg->u.tx_acknowledge_header.channel;
+	tid = msg->u.tx_acknowledge_header.tid;
 
 	if (channel >= dev->nchannels) {
 		dev_err(dev->udev->dev.parent,
@@ -623,12 +811,12 @@ static void kvaser_usb_rx_error_update_can_state(struct kvaser_usb_net_priv *pri
 						 const struct kvaser_usb_error_summary *es,
 						 struct can_frame *cf)
 {
-	struct net_device_stats *stats;
+	struct kvaser_usb *dev = priv->dev;
+	struct net_device_stats *stats = &priv->netdev->stats;
 	enum can_state cur_state, new_state, tx_state, rx_state;
 
 	netdev_dbg(priv->netdev, "Error status: 0x%02x\n", es->status);
 
-	stats = &priv->netdev->stats;
 	new_state = cur_state = priv->can.state;
 
 	if (es->status & (M16C_STATE_BUS_OFF | M16C_STATE_BUS_RESET))
@@ -662,9 +850,22 @@ static void kvaser_usb_rx_error_update_can_state(struct kvaser_usb_net_priv *pri
 		priv->can.can_stats.restarts++;
 	}
 
-	if (es->error_factor) {
-		priv->can.can_stats.bus_error++;
-		stats->rx_errors++;
+	switch (dev->family) {
+	case KVASER_LEAF:
+		if (es->leaf.error_factor) {
+			priv->can.can_stats.bus_error++;
+			stats->rx_errors++;
+		}
+		break;
+	case KVASER_USBCAN:
+		if (es->usbcan.error_state & USBCAN_ERROR_STATE_TX_ERROR)
+			stats->tx_errors++;
+		if (es->usbcan.error_state & USBCAN_ERROR_STATE_RX_ERROR)
+			stats->rx_errors++;
+		if (es->usbcan.error_state & USBCAN_ERROR_STATE_BUSERROR) {
+			priv->can.can_stats.bus_error++;
+		}
+		break;
 	}
 
 	priv->bec.txerr = es->txerr;
@@ -672,50 +873,21 @@ static void kvaser_usb_rx_error_update_can_state(struct kvaser_usb_net_priv *pri
 }
 
 static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
-				const struct kvaser_msg *msg)
+				const struct kvaser_usb_error_summary *es)
 {
 	struct can_frame *cf, tmp_cf = { .can_id = CAN_ERR_FLAG, .can_dlc = CAN_ERR_DLC };
 	struct sk_buff *skb;
 	struct net_device_stats *stats;
 	struct kvaser_usb_net_priv *priv;
-	struct kvaser_usb_error_summary es = { };
 	enum can_state old_state, new_state;
 
-	switch (msg->id) {
-	case CMD_CAN_ERROR_EVENT:
-		es.channel = msg->u.error_event.channel;
-		es.status =  msg->u.error_event.status;
-		es.txerr = msg->u.error_event.tx_errors_count;
-		es.rxerr = msg->u.error_event.rx_errors_count;
-		es.error_factor = msg->u.error_event.error_factor;
-		break;
-	case CMD_LOG_MESSAGE:
-		es.channel = msg->u.log_message.channel;
-		es.status = msg->u.log_message.data[0];
-		es.txerr = msg->u.log_message.data[2];
-		es.rxerr = msg->u.log_message.data[3];
-		es.error_factor = msg->u.log_message.data[1];
-		break;
-	case CMD_CHIP_STATE_EVENT:
-		es.channel = msg->u.chip_state_event.channel;
-		es.status =  msg->u.chip_state_event.status;
-		es.txerr = msg->u.chip_state_event.tx_errors_count;
-		es.rxerr = msg->u.chip_state_event.rx_errors_count;
-		es.error_factor = 0;
-		break;
-	default:
-		dev_err(dev->udev->dev.parent, "Invalid msg id (%d)\n",
-			msg->id);
-		return;
-	}
-
-	if (es.channel >= dev->nchannels) {
+	if (es->channel >= dev->nchannels) {
 		dev_err(dev->udev->dev.parent,
-			"Invalid channel number (%d)\n", es.channel);
+			"Invalid channel number (%d)\n", es->channel);
 		return;
 	}
 
-	priv = dev->nets[es.channel];
+	priv = dev->nets[es->channel];
 	stats = &priv->netdev->stats;
 
 	/* Update all of the can interface's state and error counters before
@@ -729,7 +901,7 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
 	 * frame ID and data to userspace. Remove stack allocation afterwards.
 	 */
 	old_state = priv->can.state;
-	kvaser_usb_rx_error_update_can_state(priv, &es, &tmp_cf);
+	kvaser_usb_rx_error_update_can_state(priv, es, &tmp_cf);
 	new_state = priv->can.state;
 
 	skb = alloc_can_err_skb(priv->netdev, &cf);
@@ -740,7 +912,7 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
 	memcpy(cf, &tmp_cf, sizeof(*cf));
 
 	if (new_state != old_state) {
-		if (es.status &
+		if (es->status &
 		    (M16C_STATE_BUS_OFF | M16C_STATE_BUS_RESET)) {
 			if (!priv->can.restart_ms)
 				kvaser_usb_simple_msg_async(priv, CMD_STOP_CHIP);
@@ -755,34 +927,161 @@ static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
 		}
 	}
 
-	if (es.error_factor) {
-		cf->can_id |= CAN_ERR_BUSERROR | CAN_ERR_PROT;
-
-		if (es.error_factor & M16C_EF_ACKE)
-			cf->data[3] |= (CAN_ERR_PROT_LOC_ACK);
-		if (es.error_factor & M16C_EF_CRCE)
-			cf->data[3] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
-					CAN_ERR_PROT_LOC_CRC_DEL);
-		if (es.error_factor & M16C_EF_FORME)
-			cf->data[2] |= CAN_ERR_PROT_FORM;
-		if (es.error_factor & M16C_EF_STFE)
-			cf->data[2] |= CAN_ERR_PROT_STUFF;
-		if (es.error_factor & M16C_EF_BITE0)
-			cf->data[2] |= CAN_ERR_PROT_BIT0;
-		if (es.error_factor & M16C_EF_BITE1)
-			cf->data[2] |= CAN_ERR_PROT_BIT1;
-		if (es.error_factor & M16C_EF_TRE)
-			cf->data[2] |= CAN_ERR_PROT_TX;
+	switch (dev->family) {
+	case KVASER_LEAF:
+		if (es->leaf.error_factor) {
+			cf->can_id |= CAN_ERR_BUSERROR | CAN_ERR_PROT;
+
+			if (es->leaf.error_factor & M16C_EF_ACKE)
+				cf->data[3] |= (CAN_ERR_PROT_LOC_ACK);
+			if (es->leaf.error_factor & M16C_EF_CRCE)
+				cf->data[3] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
+						CAN_ERR_PROT_LOC_CRC_DEL);
+			if (es->leaf.error_factor & M16C_EF_FORME)
+				cf->data[2] |= CAN_ERR_PROT_FORM;
+			if (es->leaf.error_factor & M16C_EF_STFE)
+				cf->data[2] |= CAN_ERR_PROT_STUFF;
+			if (es->leaf.error_factor & M16C_EF_BITE0)
+				cf->data[2] |= CAN_ERR_PROT_BIT0;
+			if (es->leaf.error_factor & M16C_EF_BITE1)
+				cf->data[2] |= CAN_ERR_PROT_BIT1;
+			if (es->leaf.error_factor & M16C_EF_TRE)
+				cf->data[2] |= CAN_ERR_PROT_TX;
+		}
+		break;
+	case KVASER_USBCAN:
+		if (es->usbcan.error_state & USBCAN_ERROR_STATE_BUSERROR) {
+			cf->can_id |= CAN_ERR_BUSERROR;
+		}
+		break;
 	}
 
-	cf->data[6] = es.txerr;
-	cf->data[7] = es.rxerr;
+	cf->data[6] = es->txerr;
+	cf->data[7] = es->rxerr;
 
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
 	netif_rx(skb);
 }
 
+/* For USBCAN, report error to userspace iff the channels's errors counter
+ * has changed, or we're the only channel seeing a bus error state.
+ */
+static void kvaser_usbcan_conditionally_rx_error(const struct kvaser_usb *dev,
+						 struct kvaser_usb_error_summary *es)
+{
+	struct kvaser_usb_net_priv *priv;
+	int channel;
+	bool report_error;
+
+	channel = es->channel;
+	if (channel >= dev->nchannels) {
+		dev_err(dev->udev->dev.parent,
+			"Invalid channel number (%d)\n", channel);
+		return;
+	}
+
+	priv = dev->nets[channel];
+	report_error = false;
+
+	if (es->txerr != priv->bec.txerr) {
+		es->usbcan.error_state |= USBCAN_ERROR_STATE_TX_ERROR;
+		report_error = true;
+	}
+	if (es->rxerr != priv->bec.rxerr) {
+		es->usbcan.error_state |= USBCAN_ERROR_STATE_RX_ERROR;
+		report_error = true;
+	}
+	if ((es->status & M16C_STATE_BUS_ERROR) &&
+	    !(es->usbcan.other_ch_status & M16C_STATE_BUS_ERROR)) {
+		es->usbcan.error_state |= USBCAN_ERROR_STATE_BUSERROR;
+		report_error = true;
+	}
+
+	if (report_error)
+		kvaser_usb_rx_error(dev, es);
+}
+
+static void kvaser_usbcan_rx_error(const struct kvaser_usb *dev,
+				   const struct kvaser_msg *msg)
+{
+	struct kvaser_usb_error_summary es = { };
+
+	switch (msg->id) {
+	/* Sometimes errors are sent as unsolicited chip state events */
+	case CMD_CHIP_STATE_EVENT:
+		es.channel = msg->u.usbcan.chip_state_event.channel;
+		es.status =  msg->u.usbcan.chip_state_event.status;
+		es.txerr = msg->u.usbcan.chip_state_event.tx_errors_count;
+		es.rxerr = msg->u.usbcan.chip_state_event.rx_errors_count;
+		kvaser_usbcan_conditionally_rx_error(dev, &es);
+		break;
+
+	case CMD_CAN_ERROR_EVENT:
+		es.channel = 0;
+		es.status = msg->u.usbcan.error_event.status_ch0;
+		es.txerr = msg->u.usbcan.error_event.tx_errors_count_ch0;
+		es.rxerr = msg->u.usbcan.error_event.rx_errors_count_ch0;
+		es.usbcan.other_ch_status =
+			msg->u.usbcan.error_event.status_ch1;
+		kvaser_usbcan_conditionally_rx_error(dev, &es);
+
+		/* The USBCAN firmware supports up to 2 channels.
+		 * Now that ch0 was checked, check if ch1 has any errors.
+		 */
+		if (dev->nchannels == MAX_USBCAN_NET_DEVICES) {
+			es.channel = 1;
+			es.status = msg->u.usbcan.error_event.status_ch1;
+			es.txerr = msg->u.usbcan.error_event.tx_errors_count_ch1;
+			es.rxerr = msg->u.usbcan.error_event.rx_errors_count_ch1;
+			es.usbcan.other_ch_status =
+				msg->u.usbcan.error_event.status_ch0;
+			kvaser_usbcan_conditionally_rx_error(dev, &es);
+		}
+		break;
+
+	default:
+		dev_err(dev->udev->dev.parent, "Invalid msg id (%d)\n",
+			msg->id);
+	}
+}
+
+static void kvaser_leaf_rx_error(const struct kvaser_usb *dev,
+				 const struct kvaser_msg *msg)
+{
+	struct kvaser_usb_error_summary es = { };
+
+	switch (msg->id) {
+	case CMD_CAN_ERROR_EVENT:
+		es.channel = msg->u.leaf.error_event.channel;
+		es.status =  msg->u.leaf.error_event.status;
+		es.txerr = msg->u.leaf.error_event.tx_errors_count;
+		es.rxerr = msg->u.leaf.error_event.rx_errors_count;
+		es.leaf.error_factor = msg->u.leaf.error_event.error_factor;
+		break;
+	case CMD_LEAF_LOG_MESSAGE:
+		es.channel = msg->u.leaf.log_message.channel;
+		es.status = msg->u.leaf.log_message.data[0];
+		es.txerr = msg->u.leaf.log_message.data[2];
+		es.rxerr = msg->u.leaf.log_message.data[3];
+		es.leaf.error_factor = msg->u.leaf.log_message.data[1];
+		break;
+	case CMD_CHIP_STATE_EVENT:
+		es.channel = msg->u.leaf.chip_state_event.channel;
+		es.status =  msg->u.leaf.chip_state_event.status;
+		es.txerr = msg->u.leaf.chip_state_event.tx_errors_count;
+		es.rxerr = msg->u.leaf.chip_state_event.rx_errors_count;
+		es.leaf.error_factor = 0;
+		break;
+	default:
+		dev_err(dev->udev->dev.parent, "Invalid msg id (%d)\n",
+			msg->id);
+		return;
+	}
+
+	kvaser_usb_rx_error(dev, &es);
+}
+
 static void kvaser_usb_rx_can_err(const struct kvaser_usb_net_priv *priv,
 				  const struct kvaser_msg *msg)
 {
@@ -790,16 +1089,16 @@ static void kvaser_usb_rx_can_err(const struct kvaser_usb_net_priv *priv,
 	struct sk_buff *skb;
 	struct net_device_stats *stats = &priv->netdev->stats;
 
-	if (msg->u.rx_can.flag & (MSG_FLAG_ERROR_FRAME |
+	if (msg->u.rx_can_header.flag & (MSG_FLAG_ERROR_FRAME |
 					 MSG_FLAG_NERR)) {
 		netdev_err(priv->netdev, "Unknow error (flags: 0x%02x)\n",
-			   msg->u.rx_can.flag);
+			   msg->u.rx_can_header.flag);
 
 		stats->rx_errors++;
 		return;
 	}
 
-	if (msg->u.rx_can.flag & MSG_FLAG_OVERRUN) {
+	if (msg->u.rx_can_header.flag & MSG_FLAG_OVERRUN) {
 		stats->rx_over_errors++;
 		stats->rx_errors++;
 
@@ -825,7 +1124,8 @@ static void kvaser_usb_rx_can_msg(const struct kvaser_usb *dev,
 	struct can_frame *cf;
 	struct sk_buff *skb;
 	struct net_device_stats *stats;
-	u8 channel = msg->u.rx_can.channel;
+	u8 channel = msg->u.rx_can_header.channel;
+	const u8 *rx_msg = NULL;	/* GCC */
 
 	if (channel >= dev->nchannels) {
 		dev_err(dev->udev->dev.parent,
@@ -836,60 +1136,68 @@ static void kvaser_usb_rx_can_msg(const struct kvaser_usb *dev,
 	priv = dev->nets[channel];
 	stats = &priv->netdev->stats;
 
-	if ((msg->u.rx_can.flag & MSG_FLAG_ERROR_FRAME) &&
-	    (msg->id == CMD_LOG_MESSAGE)) {
-		kvaser_usb_rx_error(dev, msg);
+	if ((msg->u.rx_can_header.flag & MSG_FLAG_ERROR_FRAME) &&
+	    (dev->family == KVASER_LEAF && msg->id == CMD_LEAF_LOG_MESSAGE)) {
+		kvaser_leaf_rx_error(dev, msg);
 		return;
-	} else if (msg->u.rx_can.flag & (MSG_FLAG_ERROR_FRAME |
-					 MSG_FLAG_NERR |
-					 MSG_FLAG_OVERRUN)) {
+	} else if (msg->u.rx_can_header.flag & (MSG_FLAG_ERROR_FRAME |
+						MSG_FLAG_NERR |
+						MSG_FLAG_OVERRUN)) {
 		kvaser_usb_rx_can_err(priv, msg);
 		return;
-	} else if (msg->u.rx_can.flag & ~MSG_FLAG_REMOTE_FRAME) {
+	} else if (msg->u.rx_can_header.flag & ~MSG_FLAG_REMOTE_FRAME) {
 		netdev_warn(priv->netdev,
 			    "Unhandled frame (flags: 0x%02x)",
-			    msg->u.rx_can.flag);
+			    msg->u.rx_can_header.flag);
 		return;
 	}
 
+	switch (dev->family) {
+	case KVASER_LEAF:
+		rx_msg = msg->u.leaf.rx_can.msg;
+		break;
+	case KVASER_USBCAN:
+		rx_msg = msg->u.usbcan.rx_can.msg;
+		break;
+	}
+
 	skb = alloc_can_skb(priv->netdev, &cf);
 	if (!skb) {
 		stats->tx_dropped++;
 		return;
 	}
 
-	if (msg->id == CMD_LOG_MESSAGE) {
-		cf->can_id = le32_to_cpu(msg->u.log_message.id);
+	if (dev->family == KVASER_LEAF && msg->id == CMD_LEAF_LOG_MESSAGE) {
+		cf->can_id = le32_to_cpu(msg->u.leaf.log_message.id);
 		if (cf->can_id & KVASER_EXTENDED_FRAME)
 			cf->can_id &= CAN_EFF_MASK | CAN_EFF_FLAG;
 		else
 			cf->can_id &= CAN_SFF_MASK;
 
-		cf->can_dlc = get_can_dlc(msg->u.log_message.dlc);
+		cf->can_dlc = get_can_dlc(msg->u.leaf.log_message.dlc);
 
-		if (msg->u.log_message.flags & MSG_FLAG_REMOTE_FRAME)
+		if (msg->u.leaf.log_message.flags & MSG_FLAG_REMOTE_FRAME)
 			cf->can_id |= CAN_RTR_FLAG;
 		else
-			memcpy(cf->data, &msg->u.log_message.data,
+			memcpy(cf->data, &msg->u.leaf.log_message.data,
 			       cf->can_dlc);
 	} else {
-		cf->can_id = ((msg->u.rx_can.msg[0] & 0x1f) << 6) |
-			     (msg->u.rx_can.msg[1] & 0x3f);
+		cf->can_id = ((rx_msg[0] & 0x1f) << 6) | (rx_msg[1] & 0x3f);
 
 		if (msg->id == CMD_RX_EXT_MESSAGE) {
 			cf->can_id <<= 18;
-			cf->can_id |= ((msg->u.rx_can.msg[2] & 0x0f) << 14) |
-				      ((msg->u.rx_can.msg[3] & 0xff) << 6) |
-				      (msg->u.rx_can.msg[4] & 0x3f);
+			cf->can_id |= ((rx_msg[2] & 0x0f) << 14) |
+				      ((rx_msg[3] & 0xff) << 6) |
+				      (rx_msg[4] & 0x3f);
 			cf->can_id |= CAN_EFF_FLAG;
 		}
 
-		cf->can_dlc = get_can_dlc(msg->u.rx_can.msg[5]);
+		cf->can_dlc = get_can_dlc(rx_msg[5]);
 
-		if (msg->u.rx_can.flag & MSG_FLAG_REMOTE_FRAME)
+		if (msg->u.rx_can_header.flag & MSG_FLAG_REMOTE_FRAME)
 			cf->can_id |= CAN_RTR_FLAG;
 		else
-			memcpy(cf->data, &msg->u.rx_can.msg[6],
+			memcpy(cf->data, &rx_msg[6],
 			       cf->can_dlc);
 	}
 
@@ -952,21 +1260,35 @@ static void kvaser_usb_handle_message(const struct kvaser_usb *dev,
 
 	case CMD_RX_STD_MESSAGE:
 	case CMD_RX_EXT_MESSAGE:
-	case CMD_LOG_MESSAGE:
+		kvaser_usb_rx_can_msg(dev, msg);
+		break;
+
+	case CMD_LEAF_LOG_MESSAGE:
+		if (dev->family != KVASER_LEAF)
+			goto warn;
 		kvaser_usb_rx_can_msg(dev, msg);
 		break;
 
 	case CMD_CHIP_STATE_EVENT:
 	case CMD_CAN_ERROR_EVENT:
-		kvaser_usb_rx_error(dev, msg);
+		if (dev->family == KVASER_LEAF)
+			kvaser_leaf_rx_error(dev, msg);
+		else
+			kvaser_usbcan_rx_error(dev, msg);
 		break;
 
 	case CMD_TX_ACKNOWLEDGE:
 		kvaser_usb_tx_acknowledge(dev, msg);
 		break;
 
+	/* Ignored messages */
+	case CMD_USBCAN_CLOCK_OVERFLOW_EVENT:
+		if (dev->family != KVASER_USBCAN)
+			goto warn;
+		break;
+
 	default:
-		dev_warn(dev->udev->dev.parent,
+warn:		dev_warn(dev->udev->dev.parent,
 			 "Unhandled message (%d)\n", msg->id);
 		break;
 	}
@@ -1186,7 +1508,7 @@ static void kvaser_usb_unlink_all_urbs(struct kvaser_usb *dev)
 				  dev->rxbuf[i],
 				  dev->rxbuf_dma[i]);
 
-	for (i = 0; i < MAX_NET_DEVICES; i++) {
+	for (i = 0; i < dev->nchannels; i++) {
 		struct kvaser_usb_net_priv *priv = dev->nets[i];
 
 		if (priv)
@@ -1294,6 +1616,7 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 	struct kvaser_msg *msg;
 	int i, err;
 	int ret = NETDEV_TX_OK;
+	u8 *msg_tx_can_flags = NULL;		/* GCC */
 
 	if (can_dropped_invalid_skb(netdev, skb))
 		return NETDEV_TX_OK;
@@ -1315,9 +1638,19 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 
 	msg = buf;
 	msg->len = MSG_HEADER_LEN + sizeof(struct kvaser_msg_tx_can);
-	msg->u.tx_can.flags = 0;
 	msg->u.tx_can.channel = priv->channel;
 
+	switch (dev->family) {
+	case KVASER_LEAF:
+		msg_tx_can_flags = &msg->u.tx_can.leaf.flags;
+		break;
+	case KVASER_USBCAN:
+		msg_tx_can_flags = &msg->u.tx_can.usbcan.flags;
+		break;
+	}
+
+	*msg_tx_can_flags = 0;
+
 	if (cf->can_id & CAN_EFF_FLAG) {
 		msg->id = CMD_TX_EXT_MESSAGE;
 		msg->u.tx_can.msg[0] = (cf->can_id >> 24) & 0x1f;
@@ -1335,7 +1668,7 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 	memcpy(&msg->u.tx_can.msg[6], cf->data, cf->can_dlc);
 
 	if (cf->can_id & CAN_RTR_FLAG)
-		msg->u.tx_can.flags |= MSG_FLAG_REMOTE_FRAME;
+		*msg_tx_can_flags |= MSG_FLAG_REMOTE_FRAME;
 
 	for (i = 0; i < ARRAY_SIZE(priv->tx_contexts); i++) {
 		if (priv->tx_contexts[i].echo_index == MAX_TX_URBS) {
@@ -1604,6 +1937,17 @@ static int kvaser_usb_probe(struct usb_interface *intf,
 	if (!dev)
 		return -ENOMEM;
 
+	if (kvaser_is_leaf(id)) {
+		dev->family = KVASER_LEAF;
+	} else if (kvaser_is_usbcan(id)) {
+		dev->family = KVASER_USBCAN;
+	} else {
+		dev_err(&intf->dev,
+			"Product ID (%d) does not belong to any known Kvaser USB family",
+			id->idProduct);
+		return -ENODEV;
+	}
+
 	err = kvaser_usb_get_endpoints(intf, &dev->bulk_in, &dev->bulk_out);
 	if (err) {
 		dev_err(&intf->dev, "Cannot get usb endpoint(s)");
-- 
1.7.7.6
