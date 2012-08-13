From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH v3] can: kvaser_usb: Add support for Kvaser CAN/USB devices
Date: Mon, 13 Aug 2012 15:51:56 +0200
Message-ID: <1344865916-17332-1-git-send-email-olivier@sobrie.be>
References: <1343626352-24760-1-git-send-email-olivier@sobrie.be>
Cc: netdev@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-can@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1343626352-24760-1-git-send-email-olivier@sobrie.be>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver provides support for several Kvaser CAN/USB devices.
Such kind of devices supports up to three CAN network interfaces.

It has been tested with a Kvaser USB Leaf Light (one network interface)
connected to a pch_can interface.
The firmware version of the Kvaser device was 2.5.205.

List of Kvaser devices supported by the driver:
  - Kvaser Leaf prototype (P010v2 and v3)
  - Kvaser Leaf Light (P010v3)
  - Kvaser Leaf Professional HS
  - Kvaser Leaf SemiPro HS
  - Kvaser Leaf Professional LS
  - Kvaser Leaf Professional SWC
  - Kvaser Leaf Professional LIN
  - Kvaser Leaf SemiPro LS
  - Kvaser Leaf SemiPro SWC
  - Kvaser Memorator II, Prototype
  - Kvaser Memorator II HS/HS
  - Kvaser USBcan Professional HS/HS
  - Kvaser Leaf Light GI
  - Kvaser Leaf Professional HS (OBD-II connector)
  - Kvaser Memorator Professional HS/LS
  - Kvaser Leaf Light "China"
  - Kvaser BlackBird SemiPro
  - Kvaser OEM Mercury
  - Kvaser OEM Leaf
  - Kvaser USBcan R

Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
---

Changes since v2:
 - update of error handling
 - add method do_get_berr_counter if hardware support it
 - fix race condition in probe function
 - ...

Here is the behavior in case of errors:

Case 1: restart-ms 0 + short-circuit

  t0: short-circuit + cansend can1 123@1122

   (016.731173)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000009)  can1  20000088  [8] 00 00 D0 00 00 00 00 00   ERRORFRAME
   (000.000010)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000005)  can1  20000088  [8] 00 00 D0 00 00 00 00 00   ERRORFRAME
   (000.000006)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000004)  can1  20000088  [8] 00 00 D0 00 00 00 00 00   ERRORFRAME
   (000.000007)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000007)  can1  20000088  [8] 00 00 D0 00 00 00 00 00   ERRORFRAME
   (000.000007)  can1  2000008C  [8] 00 30 90 00 00 00 00 00   ERRORFRAME
   (000.001062)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000011)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000008)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000007)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000978)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000007)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000009)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000008)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.001108)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000007)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000007)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000006)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000007)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.001082)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000046)  can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME

  t1: ip link set can1 type can restart:

   (125.211773)  can1  20000100  [8] 00 00 00 00 00 00 00 00   ERRORFRAME
   (000.020207)  can1  20000088  [8] 00 00 40 00 00 00 00 00   ERRORFRAME

Case 2: short-circuit + restart-ms > 0

  t0: short-circuit + cansend can1 123@1122

   (006.079601)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000091)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000083)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000083)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000082)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000086)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000083)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000082)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000083)  can1  2000008C  [8] 00 30 90 00 00 00 00 00   ERRORFRAME
   (000.000352)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000103)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000106)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000105)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000808)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000125)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000110)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000108)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000106)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000110)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000560)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000104)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000104)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000106)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000123)  can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.010835)  can1  20000188  [8] 00 00 D0 00 00 00 00 00   ERRORFRAME
   (000.000090)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000082)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   ...
   (000.000084)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000082)  can1  2000008C  [8] 00 30 90 00 00 00 00 00   ERRORFRAME
   (000.000431)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   ...
   (000.000105)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000112)  can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.010842)  can1  20000188  [8] 00 00 D0 00 00 00 00 00   ERRORFRAME
   ...
   (000.001118)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000086)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000082)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000084)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000084)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000083)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000082)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000085)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000082)  can1  2000008C  [8] 00 30 90 00 00 00 00 00   ERRORFRAME
   (000.000082)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000349)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000087)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000081)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000082)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000903)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000110)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000093)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000083)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000082)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000755)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000112)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000093)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000084)  can1  20000088  [8] 00 00 90 00 00 00 00 00   ERRORFRAME
   (000.000082)  can1  200000C8  [8] 00 00 90 00 00 00 00 00   ERRORFRAME

  t1: short-circuit removed

   (000.011273)  can1  20000100  [8] 00 00 00 00 00 00 00 00   ERRORFRAME
   (000.000006)  can1  123  [2] 11 22

Case 3: CAN-H and CAN-L disconnected

  t0: CAN-H and CAN-L disconnect + cansend can1 123#1122

   (524.620978)  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
   (000.000978)  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
   (000.001126)  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
   (000.000007)  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
   (000.000996)  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
   (000.000006)  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
   (000.001134)  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
   (000.000006)  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
   (000.001775)  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
   (000.000006)  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
   (000.000310)  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
   (000.000005)  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
   (000.001126)  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
   (000.000005)  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
   (000.001176)  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
   (000.000006)  can1  2000008C  [8] 00 30 80 19 00 00 00 00   ERRORFRAME
   (000.000949)  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
   ...

  t1: CAN-H and CAN-L connected:

   (000.000005)  can1  20000088  [8] 00 00 80 19 00 00 00 00   ERRORFRAME
   (004.270502)  can1  123  [2] 11 22
   (002.242773)  can1  20000088  [8] 00 00 40 00 00 00 00 00   ERRORFRAME

Remarks:
 - With my device the txerr and rxerr always stay equals to 0
   because the hardware doesn't report it... It passes from active state
   to passive and then off.
   With other hardware, i.e. other than Leaf Light, the txerr and rxerr
   are incremented (following Kvaser support)
 - With case 2, sometimes after a bus off event, the hardware doesn't
   report that it's in active state again... This is why when I get an
   acknowledge frame I deduce it's active again...

Kind regards,

Olivier

 drivers/net/can/usb/Kconfig      |   33 +
 drivers/net/can/usb/Makefile     |    1 +
 drivers/net/can/usb/kvaser_usb.c | 1525 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 1559 insertions(+)
 create mode 100644 drivers/net/can/usb/kvaser_usb.c

diff --git a/drivers/net/can/usb/Kconfig b/drivers/net/can/usb/Kconfig
index 0a68768..578955f 100644
--- a/drivers/net/can/usb/Kconfig
+++ b/drivers/net/can/usb/Kconfig
@@ -13,6 +13,39 @@ config CAN_ESD_USB2
           This driver supports the CAN-USB/2 interface
           from esd electronic system design gmbh (http://www.esd.eu).
 
+config CAN_KVASER_USB
+	tristate "Kvaser CAN/USB interface"
+	---help---
+	  This driver adds support for Kvaser CAN/USB devices like Kvaser
+	  Leaf Light.
+
+	  The driver gives support for the following devices:
+	    - Kvaser Leaf prototype (P010v2 and v3)
+	    - Kvaser Leaf Light (P010v3)
+	    - Kvaser Leaf Professional HS
+	    - Kvaser Leaf SemiPro HS
+	    - Kvaser Leaf Professional LS
+	    - Kvaser Leaf Professional SWC
+	    - Kvaser Leaf Professional LIN
+	    - Kvaser Leaf SemiPro LS
+	    - Kvaser Leaf SemiPro SWC
+	    - Kvaser Memorator II, Prototype
+	    - Kvaser Memorator II HS/HS
+	    - Kvaser USBcan Professional HS/HS
+	    - Kvaser Leaf Light GI
+	    - Kvaser Leaf Professional HS (OBD-II connector)
+	    - Kvaser Memorator Professional HS/LS
+	    - Kvaser Leaf Light "China"
+	    - Kvaser BlackBird SemiPro
+	    - Kvaser OEM Mercury
+	    - Kvaser OEM Leaf
+	    - Kvaser USBcan R
+
+	  If unsure, say N.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called kvaser_usb.
+
 config CAN_PEAK_USB
 	tristate "PEAK PCAN-USB/USB Pro interfaces"
 	---help---
diff --git a/drivers/net/can/usb/Makefile b/drivers/net/can/usb/Makefile
index da6d1d3..80a2ee4 100644
--- a/drivers/net/can/usb/Makefile
+++ b/drivers/net/can/usb/Makefile
@@ -4,6 +4,7 @@
 
 obj-$(CONFIG_CAN_EMS_USB) += ems_usb.o
 obj-$(CONFIG_CAN_ESD_USB2) += esd_usb2.o
+obj-$(CONFIG_CAN_KVASER_USB) += kvaser_usb.o
 obj-$(CONFIG_CAN_PEAK_USB) += peak_usb/
 
 ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
new file mode 100644
index 0000000..938f188
--- /dev/null
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -0,0 +1,1525 @@
+/*
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation version 2.
+ *
+ * Parts of this driver are based on the following:
+ *  - Kvaser linux leaf driver (version 4.78)
+ *  - CAN driver for esd CAN-USB/2
+ *
+ * Copyright (C) 2002-2006 KVASER AB, Sweden. All rights reserved.
+ * Copyright (C) 2010 Matthias Fuchs <matthias.fuchs@esd.eu>, esd gmbh
+ * Copyright (C) 2012 Olivier Sobrie <olivier@sobrie.be>
+ */
+
+#include <linux/init.h>
+#include <linux/completion.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/usb.h>
+
+#include <linux/can.h>
+#include <linux/can/dev.h>
+#include <linux/can/error.h>
+
+#define MAX_TX_URBS			16
+#define MAX_RX_URBS			4
+#define START_TIMEOUT			1000 /* msecs */
+#define STOP_TIMEOUT			1000 /* msecs */
+#define USB_SEND_TIMEOUT		1000 /* msecs */
+#define USB_RECV_TIMEOUT		1000 /* msecs */
+#define RX_BUFFER_SIZE			3072
+#define CAN_USB_CLOCK			8000000
+#define MAX_NET_DEVICES			3
+
+/* Kvaser USB devices */
+#define KVASER_VENDOR_ID		0x0bfd
+#define USB_LEAF_DEVEL_PRODUCT_ID	10
+#define USB_LEAF_LITE_PRODUCT_ID	11
+#define USB_LEAF_PRO_PRODUCT_ID		12
+#define USB_LEAF_SPRO_PRODUCT_ID	14
+#define USB_LEAF_PRO_LS_PRODUCT_ID	15
+#define USB_LEAF_PRO_SWC_PRODUCT_ID	16
+#define USB_LEAF_PRO_LIN_PRODUCT_ID	17
+#define USB_LEAF_SPRO_LS_PRODUCT_ID	18
+#define USB_LEAF_SPRO_SWC_PRODUCT_ID	19
+#define USB_MEMO2_DEVEL_PRODUCT_ID	22
+#define USB_MEMO2_HSHS_PRODUCT_ID	23
+#define USB_UPRO_HSHS_PRODUCT_ID	24
+#define USB_LEAF_LITE_GI_PRODUCT_ID	25
+#define USB_LEAF_PRO_OBDII_PRODUCT_ID	26
+#define USB_MEMO2_HSLS_PRODUCT_ID	27
+#define USB_LEAF_LITE_CH_PRODUCT_ID	28
+#define USB_BLACKBIRD_SPRO_PRODUCT_ID	29
+#define USB_OEM_MERCURY_PRODUCT_ID	34
+#define USB_OEM_LEAF_PRODUCT_ID		35
+#define USB_CAN_R_PRODUCT_ID		39
+
+/* USB devices features */
+#define KVASER_HAS_SILENT_MODE		BIT(0)
+#define KVASER_HAS_TXRX_ERRORS		BIT(1)
+
+/* Message header size */
+#define MSG_HEADER_LEN			2
+
+/* Can message flags */
+#define MSG_FLAG_ERROR_FRAME		BIT(0)
+#define MSG_FLAG_OVERRUN		BIT(1)
+#define MSG_FLAG_NERR			BIT(2)
+#define MSG_FLAG_WAKEUP			BIT(3)
+#define MSG_FLAG_REMOTE_FRAME		BIT(4)
+#define MSG_FLAG_RESERVED		BIT(5)
+#define MSG_FLAG_TX_ACK			BIT(6)
+#define MSG_FLAG_TX_REQUEST		BIT(7)
+
+/* Can states */
+#define M16C_STATE_BUS_RESET		BIT(0)
+#define M16C_STATE_BUS_ERROR		BIT(4)
+#define M16C_STATE_BUS_PASSIVE		BIT(5)
+#define M16C_STATE_BUS_OFF		BIT(6)
+
+/* Can msg ids */
+#define CMD_RX_STD_MESSAGE		12
+#define CMD_TX_STD_MESSAGE		13
+#define CMD_RX_EXT_MESSAGE		14
+#define CMD_TX_EXT_MESSAGE		15
+#define CMD_SET_BUS_PARAMS		16
+#define CMD_GET_BUS_PARAMS		17
+#define CMD_GET_BUS_PARAMS_REPLY	18
+#define CMD_GET_CHIP_STATE		19
+#define CMD_CHIP_STATE_EVENT		20
+#define CMD_SET_CTRL_MODE		21
+#define CMD_GET_CTRL_MODE		22
+#define CMD_GET_CTRL_MODE_REPLY		23
+#define CMD_RESET_CHIP			24
+#define CMD_RESET_CARD			25
+#define CMD_START_CHIP			26
+#define CMD_START_CHIP_REPLY		27
+#define CMD_STOP_CHIP			28
+#define CMD_STOP_CHIP_REPLY		29
+#define CMD_GET_CARD_INFO2		32
+#define CMD_GET_CARD_INFO		34
+#define CMD_GET_CARD_INFO_REPLY		35
+#define CMD_GET_SOFTWARE_INFO		38
+#define CMD_GET_SOFTWARE_INFO_REPLY	39
+#define CMD_ERROR_EVENT			45
+#define CMD_FLUSH_QUEUE			48
+#define CMD_RESET_ERROR_COUNTER		49
+#define CMD_TX_ACKNOWLEDGE		50
+#define CMD_CAN_ERROR_EVENT		51
+#define CMD_USB_THROTTLE		77
+
+/* error factors */
+#define M16C_EF_ACKE			BIT(0)
+#define M16C_EF_CRCE			BIT(1)
+#define M16C_EF_FORME			BIT(2)
+#define M16C_EF_STFE			BIT(3)
+#define M16C_EF_BITE0			BIT(4)
+#define M16C_EF_BITE1			BIT(5)
+#define M16C_EF_RCVE			BIT(6)
+#define M16C_EF_TRE			BIT(7)
+
+/* bittiming parameters */
+#define KVASER_USB_TSEG1_MIN		1
+#define KVASER_USB_TSEG1_MAX		16
+#define KVASER_USB_TSEG2_MIN		1
+#define KVASER_USB_TSEG2_MAX		8
+#define KVASER_USB_SJW_MAX		4
+#define KVASER_USB_BRP_MIN		1
+#define KVASER_USB_BRP_MAX		64
+#define KVASER_USB_BRP_INC		1
+
+/* ctrl modes */
+#define KVASER_CTRL_MODE_NORMAL		1
+#define KVASER_CTRL_MODE_SILENT		2
+#define KVASER_CTRL_MODE_SELFRECEPTION	3
+#define KVASER_CTRL_MODE_OFF		4
+
+struct kvaser_msg_simple {
+	u8 tid;
+	u8 channel;
+} __packed;
+
+struct kvaser_msg_cardinfo {
+	u8 tid;
+	u8 nchannels;
+	__le32 serial_number;
+	__le32 padding;
+	__le32 clock_resolution;
+	__le32 mfgdate;
+	u8 ean[8];
+	u8 hw_revision;
+	u8 usb_hs_mode;
+	__le16 padding2;
+} __packed;
+
+struct kvaser_msg_cardinfo2 {
+	u8 tid;
+	u8 channel;
+	u8 pcb_id[24];
+	__le32 oem_unlock_code;
+} __packed;
+
+struct kvaser_msg_softinfo {
+	u8 tid;
+	u8 channel;
+	__le32 sw_options;
+	__le32 fw_version;
+	__le16 max_outstanding_tx;
+	__le16 padding[9];
+} __packed;
+
+struct kvaser_msg_busparams {
+	u8 tid;
+	u8 channel;
+	__le32 bitrate;
+	u8 tseg1;
+	u8 tseg2;
+	u8 sjw;
+	u8 no_samp;
+} __packed;
+
+struct kvaser_msg_tx_can {
+	u8 channel;
+	u8 tid;
+	u8 msg[14];
+	u8 padding;
+	u8 flags;
+} __packed;
+
+struct kvaser_msg_rx_can {
+	u8 channel;
+	u8 flag;
+	__le16 time[3];
+	u8 msg[14];
+} __packed;
+
+struct kvaser_msg_chip_state_event {
+	u8 tid;
+	u8 channel;
+	__le16 time[3];
+	u8 tx_errors_count;
+	u8 rx_errors_count;
+	u8 status;
+	u8 padding[3];
+} __packed;
+
+struct kvaser_msg_tx_acknowledge {
+	u8 channel;
+	u8 tid;
+	__le16 time[3];
+	u8 flags;
+	u8 time_offset;
+} __packed;
+
+struct kvaser_msg_error_event {
+	u8 tid;
+	u8 flags;
+	__le16 time[3];
+	u8 channel;
+	u8 padding;
+	u8 tx_errors_count;
+	u8 rx_errors_count;
+	u8 status;
+	u8 error_factor;
+} __packed;
+
+struct kvaser_msg_ctrl_mode {
+	u8 tid;
+	u8 channel;
+	u8 ctrl_mode;
+	u8 padding[3];
+} __packed;
+
+struct kvaser_msg_flush_queue {
+	u8 tid;
+	u8 channel;
+	u8 flags;
+	u8 padding[3];
+} __packed;
+
+struct kvaser_msg {
+	u8 len;
+	u8 id;
+	union	{
+		struct kvaser_msg_simple simple;
+		struct kvaser_msg_cardinfo cardinfo;
+		struct kvaser_msg_cardinfo2 cardinfo2;
+		struct kvaser_msg_softinfo softinfo;
+		struct kvaser_msg_busparams busparams;
+		struct kvaser_msg_tx_can tx_can;
+		struct kvaser_msg_rx_can rx_can;
+		struct kvaser_msg_chip_state_event chip_state_event;
+		struct kvaser_msg_tx_acknowledge tx_acknowledge;
+		struct kvaser_msg_error_event error_event;
+		struct kvaser_msg_ctrl_mode ctrl_mode;
+		struct kvaser_msg_flush_queue flush_queue;
+	} u;
+} __packed;
+
+struct kvaser_usb_tx_urb_context {
+	struct kvaser_usb_net_priv *priv;
+	u32 echo_index;
+	int dlc;
+};
+
+struct kvaser_usb {
+	struct usb_device *udev;
+	struct kvaser_usb_net_priv *nets[MAX_NET_DEVICES];
+
+	struct usb_endpoint_descriptor *bulk_in, *bulk_out;
+	struct usb_anchor rx_submitted;
+
+	u32 fw_version;
+	unsigned int nchannels;
+
+	bool rxinitdone;
+	void *rxbuf[MAX_RX_URBS];
+	dma_addr_t rxbuf_dma[MAX_RX_URBS];
+};
+
+struct kvaser_usb_net_priv {
+	struct can_priv can;
+
+	atomic_t active_tx_urbs;
+	struct usb_anchor tx_submitted;
+	struct kvaser_usb_tx_urb_context tx_contexts[MAX_TX_URBS];
+
+	struct completion start_comp, stop_comp;
+
+	struct kvaser_usb *dev;
+	struct net_device *netdev;
+	int channel;
+
+	struct can_berr_counter bec;
+};
+
+static struct usb_device_id kvaser_usb_table[] = {
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_DEVEL_PRODUCT_ID) },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_LITE_PRODUCT_ID) },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_PRO_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS |
+			       KVASER_HAS_SILENT_MODE },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_SPRO_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS |
+			       KVASER_HAS_SILENT_MODE },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_PRO_LS_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS |
+			       KVASER_HAS_SILENT_MODE },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_PRO_SWC_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS |
+			       KVASER_HAS_SILENT_MODE },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_PRO_LIN_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS |
+			       KVASER_HAS_SILENT_MODE },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_SPRO_LS_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS |
+			       KVASER_HAS_SILENT_MODE },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_SPRO_SWC_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS |
+			       KVASER_HAS_SILENT_MODE },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_MEMO2_DEVEL_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS |
+			       KVASER_HAS_SILENT_MODE },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_MEMO2_HSHS_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS |
+			       KVASER_HAS_SILENT_MODE },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_UPRO_HSHS_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_LITE_GI_PRODUCT_ID) },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_PRO_OBDII_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS |
+			       KVASER_HAS_SILENT_MODE },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_MEMO2_HSLS_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_LITE_CH_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_BLACKBIRD_SPRO_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_OEM_MERCURY_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_OEM_LEAF_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_CAN_R_PRODUCT_ID),
+		.driver_info = KVASER_HAS_TXRX_ERRORS },
+	{ }
+};
+MODULE_DEVICE_TABLE(usb, kvaser_usb_table);
+
+static inline int kvaser_usb_send_msg(const struct kvaser_usb *dev,
+				      struct kvaser_msg *msg)
+{
+	int actual_len;
+
+	return usb_bulk_msg(dev->udev,
+			    usb_sndbulkpipe(dev->udev,
+					dev->bulk_out->bEndpointAddress),
+			    msg, msg->len, &actual_len,
+			    USB_SEND_TIMEOUT);
+}
+
+static int kvaser_usb_wait_msg(const struct kvaser_usb *dev, u8 id,
+			       struct kvaser_msg *msg)
+{
+	struct kvaser_msg *tmp;
+	void *buf;
+	int actual_len;
+	int err;
+	int pos = 0;
+
+	buf = kzalloc(RX_BUFFER_SIZE, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	err = usb_bulk_msg(dev->udev,
+			   usb_rcvbulkpipe(dev->udev,
+					   dev->bulk_in->bEndpointAddress),
+			   buf, RX_BUFFER_SIZE, &actual_len,
+			   USB_RECV_TIMEOUT);
+	if (err < 0)
+		goto end;
+
+	while (pos <= actual_len - MSG_HEADER_LEN) {
+		tmp = buf + pos;
+
+		if (!tmp->len)
+			break;
+
+		if (pos + tmp->len > actual_len) {
+			dev_err(dev->udev->dev.parent, "Format error\n");
+			break;
+		}
+
+		if (tmp->id == id) {
+			memcpy(msg, tmp, tmp->len);
+			goto end;
+		}
+
+		pos += tmp->len;
+	}
+
+	err = -EINVAL;
+
+end:
+	kfree(buf);
+
+	return err;
+}
+
+static int kvaser_usb_send_simple_msg(const struct kvaser_usb *dev,
+				      u8 msg_id, int channel)
+{
+	struct kvaser_msg msg = {
+		.len = MSG_HEADER_LEN + sizeof(struct kvaser_msg_simple),
+		.id = msg_id,
+		.u.simple.channel = channel,
+		.u.simple.tid = 0xff,
+	};
+
+	return kvaser_usb_send_msg(dev, &msg);
+}
+
+static int kvaser_usb_get_software_info(struct kvaser_usb *dev)
+{
+	struct kvaser_msg msg;
+	int err;
+
+	err = kvaser_usb_send_simple_msg(dev, CMD_GET_SOFTWARE_INFO, 0);
+	if (err)
+		return err;
+
+	err = kvaser_usb_wait_msg(dev, CMD_GET_SOFTWARE_INFO_REPLY, &msg);
+	if (err)
+		return err;
+
+	dev->fw_version = le32_to_cpu(msg.u.softinfo.fw_version);
+
+	return 0;
+}
+
+static int kvaser_usb_get_card_info(struct kvaser_usb *dev)
+{
+	struct kvaser_msg msg;
+	int err;
+
+	err = kvaser_usb_send_simple_msg(dev, CMD_GET_CARD_INFO, 0);
+	if (err)
+		return err;
+
+	err = kvaser_usb_wait_msg(dev, CMD_GET_CARD_INFO_REPLY, &msg);
+	if (err)
+		return err;
+
+	dev->nchannels = msg.u.cardinfo.nchannels;
+
+	return 0;
+}
+
+static void kvaser_usb_tx_acknowledge(const struct kvaser_usb *dev,
+				      const struct kvaser_msg *msg)
+{
+	struct net_device_stats *stats;
+	struct kvaser_usb_tx_urb_context *context;
+	struct kvaser_usb_net_priv *priv;
+	struct sk_buff *skb;
+	struct can_frame *cf;
+	u8 channel = msg->u.tx_acknowledge.channel;
+	u8 tid = msg->u.tx_acknowledge.tid;
+
+	if (channel >= dev->nchannels) {
+		dev_err(dev->udev->dev.parent,
+			"Invalid channel number (%d)\n", channel);
+		return;
+	}
+
+	priv = dev->nets[channel];
+
+	if (!netif_device_present(priv->netdev))
+		return;
+
+	stats = &priv->netdev->stats;
+
+	context = &priv->tx_contexts[tid % MAX_TX_URBS];
+
+	/* Sometimes the state change doesn't come after a bus-off event */
+	if (priv->can.restart_ms &&
+	    (priv->can.state >= CAN_STATE_BUS_OFF)) {
+		skb = alloc_can_err_skb(priv->netdev, &cf);
+		if (skb) {
+			cf->can_id |= CAN_ERR_RESTARTED;
+			netif_rx(skb);
+
+			stats->rx_packets++;
+			stats->rx_bytes += cf->can_dlc;
+		} else {
+			netdev_err(priv->netdev,
+				   "No memory left for err_skb\n");
+		}
+
+		priv->can.can_stats.restarts++;
+		netif_carrier_on(priv->netdev);
+
+		priv->can.state = CAN_STATE_ERROR_ACTIVE;
+	}
+
+	stats->tx_packets++;
+	stats->tx_bytes += context->dlc;
+	can_get_echo_skb(priv->netdev, context->echo_index);
+
+	context->echo_index = MAX_TX_URBS;
+	atomic_dec(&priv->active_tx_urbs);
+
+	netif_wake_queue(priv->netdev);
+}
+
+static void kvaser_usb_simple_msg_callback(struct urb *urb)
+{
+	struct net_device *netdev = urb->context;
+
+	kfree(urb->transfer_buffer);
+
+	if (urb->status)
+		netdev_warn(netdev, "urb status received: %d\n",
+			    urb->status);
+}
+
+static int kvaser_usb_simple_msg_async(struct kvaser_usb_net_priv *priv,
+				       u8 msg_id)
+{
+	struct kvaser_usb *dev = priv->dev;
+	struct net_device *netdev = priv->netdev;
+	struct kvaser_msg *msg;
+	struct urb *urb;
+	void *buf;
+	int err;
+
+	urb = usb_alloc_urb(0, GFP_ATOMIC);
+	if (!urb) {
+		netdev_err(netdev, "No memory left for URBs\n");
+		return -ENOMEM;
+	}
+
+	buf = kmalloc(sizeof(struct kvaser_msg), GFP_ATOMIC);
+	if (!buf) {
+		netdev_err(netdev, "No memory left for USB buffer\n");
+		return -ENOMEM;
+	}
+
+	msg = (struct kvaser_msg *)buf;
+	msg->len = MSG_HEADER_LEN + sizeof(struct kvaser_msg_simple);
+	msg->id = msg_id;
+	msg->u.simple.channel = priv->channel;
+
+	usb_fill_bulk_urb(urb, dev->udev,
+			  usb_sndbulkpipe(dev->udev,
+					  dev->bulk_out->bEndpointAddress),
+			  buf, msg->len,
+			  kvaser_usb_simple_msg_callback, priv);
+	usb_anchor_urb(urb, &priv->tx_submitted);
+
+	err = usb_submit_urb(urb, GFP_ATOMIC);
+	if (err) {
+		netdev_err(netdev, "Error transmitting URB\n");
+		usb_unanchor_urb(urb);
+		kfree(buf);
+		return err;
+	}
+
+	usb_free_urb(urb);
+
+	return 0;
+}
+
+static void kvaser_usb_unlink_tx_urbs(struct kvaser_usb_net_priv *priv)
+{
+	int i;
+
+	usb_kill_anchored_urbs(&priv->tx_submitted);
+	atomic_set(&priv->active_tx_urbs, 0);
+
+	for (i = 0; i < MAX_TX_URBS; i++)
+		priv->tx_contexts[i].echo_index = MAX_TX_URBS;
+}
+
+static void kvaser_usb_rx_error(const struct kvaser_usb *dev,
+				const struct kvaser_msg *msg)
+{
+	struct can_frame *cf;
+	struct sk_buff *skb;
+	struct net_device_stats *stats;
+	struct kvaser_usb_net_priv *priv;
+	unsigned int new_state;
+	u8 channel, status, txerr, rxerr;
+
+	if (msg->id == CMD_CAN_ERROR_EVENT) {
+		channel = msg->u.error_event.channel;
+		status =  msg->u.error_event.status;
+		txerr = msg->u.error_event.tx_errors_count;
+		rxerr = msg->u.error_event.rx_errors_count;
+	} else {
+		channel = msg->u.chip_state_event.channel;
+		status =  msg->u.chip_state_event.status;
+		txerr = msg->u.chip_state_event.tx_errors_count;
+		rxerr = msg->u.chip_state_event.rx_errors_count;
+	}
+
+	if (channel >= dev->nchannels) {
+		dev_err(dev->udev->dev.parent,
+			"Invalid channel number (%d)\n", channel);
+		return;
+	}
+
+	priv = dev->nets[channel];
+	stats = &priv->netdev->stats;
+
+	if (status & M16C_STATE_BUS_RESET) {
+		kvaser_usb_unlink_tx_urbs(priv);
+		return;
+	}
+
+	skb = alloc_can_err_skb(priv->netdev, &cf);
+	if (!skb) {
+		stats->rx_dropped++;
+		return;
+	}
+
+	cf->can_id |= CAN_ERR_BUSERROR;
+
+	new_state = priv->can.state;
+
+	netdev_dbg(priv->netdev, "Error status: 0x%02x\n", status);
+
+	if (status & M16C_STATE_BUS_OFF) {
+		cf->can_id |= CAN_ERR_BUSOFF;
+
+		priv->can.can_stats.bus_off++;
+		if (!priv->can.restart_ms)
+			kvaser_usb_simple_msg_async(priv, CMD_STOP_CHIP);
+
+		netif_carrier_off(priv->netdev);
+
+		new_state = CAN_STATE_BUS_OFF;
+	}
+
+	if (status & M16C_STATE_BUS_PASSIVE) {
+		if (priv->can.state != CAN_STATE_ERROR_PASSIVE) {
+			cf->can_id |= CAN_ERR_CRTL;
+
+			if ((txerr > 0) || (rxerr > 0))
+				cf->data[1] = (txerr > rxerr)
+						? CAN_ERR_CRTL_TX_PASSIVE
+						: CAN_ERR_CRTL_RX_PASSIVE;
+			else
+				cf->data[1] = CAN_ERR_CRTL_TX_PASSIVE |
+					      CAN_ERR_CRTL_RX_PASSIVE;
+
+			priv->can.can_stats.error_passive++;
+		}
+
+		new_state = CAN_STATE_ERROR_PASSIVE;
+	}
+
+	if (status == M16C_STATE_BUS_ERROR) {
+		if ((priv->can.state < CAN_STATE_ERROR_WARNING) &&
+		    ((txerr > 96) || (rxerr > 96))) {
+			cf->can_id |= CAN_ERR_CRTL;
+			cf->data[1] = (txerr > rxerr)
+					? CAN_ERR_CRTL_TX_WARNING
+					: CAN_ERR_CRTL_RX_WARNING;
+
+			priv->can.can_stats.error_warning++;
+			new_state = CAN_STATE_ERROR_WARNING;
+		} else if (priv->can.state > CAN_STATE_ERROR_ACTIVE) {
+			cf->can_id |= CAN_ERR_PROT;
+			cf->data[2] = CAN_ERR_PROT_ACTIVE;
+
+			new_state = CAN_STATE_ERROR_ACTIVE;
+		}
+	}
+
+	if (!status) {
+		cf->can_id |= CAN_ERR_PROT;
+		cf->data[2] = CAN_ERR_PROT_ACTIVE;
+
+		new_state = CAN_STATE_ERROR_ACTIVE;
+	}
+
+	if (priv->can.restart_ms &&
+	    (priv->can.state >= CAN_STATE_BUS_OFF) &&
+	    (new_state < CAN_STATE_BUS_OFF)) {
+		cf->can_id |= CAN_ERR_RESTARTED;
+		netif_carrier_on(priv->netdev);
+
+		priv->can.can_stats.restarts++;
+	}
+
+	if (msg->id == CMD_CAN_ERROR_EVENT) {
+		u8 error_factor = msg->u.error_event.error_factor;
+
+		priv->can.can_stats.bus_error++;
+		stats->rx_errors++;
+
+		if (error_factor)
+			cf->can_id |= CAN_ERR_PROT;
+
+		if (error_factor & M16C_EF_ACKE)
+			cf->data[3] |= (CAN_ERR_PROT_LOC_ACK);
+		if (error_factor & M16C_EF_CRCE)
+			cf->data[3] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
+					CAN_ERR_PROT_LOC_CRC_DEL);
+		if (error_factor & M16C_EF_FORME)
+			cf->data[2] |= CAN_ERR_PROT_FORM;
+		if (error_factor & M16C_EF_STFE)
+			cf->data[2] |= CAN_ERR_PROT_STUFF;
+		if (error_factor & M16C_EF_BITE0)
+			cf->data[2] |= CAN_ERR_PROT_BIT0;
+		if (error_factor & M16C_EF_BITE1)
+			cf->data[2] |= CAN_ERR_PROT_BIT1;
+		if (error_factor & M16C_EF_TRE)
+			cf->data[2] |= CAN_ERR_PROT_TX;
+	}
+
+	cf->data[6] = txerr;
+	cf->data[7] = rxerr;
+
+	priv->bec.txerr = txerr;
+	priv->bec.rxerr = rxerr;
+
+	priv->can.state = new_state;
+
+	netif_rx(skb);
+
+	stats->rx_packets++;
+	stats->rx_bytes += cf->can_dlc;
+}
+
+static void kvaser_usb_rx_can_msg(const struct kvaser_usb *dev,
+				  const struct kvaser_msg *msg)
+{
+	struct kvaser_usb_net_priv *priv;
+	struct can_frame *cf;
+	struct sk_buff *skb;
+	struct net_device_stats *stats;
+	u8 channel = msg->u.rx_can.channel;
+
+	if (channel >= dev->nchannels) {
+		dev_err(dev->udev->dev.parent,
+			"Invalid channel number (%d)\n", channel);
+		return;
+	}
+
+	priv = dev->nets[channel];
+	stats = &priv->netdev->stats;
+
+	skb = alloc_can_skb(priv->netdev, &cf);
+	if (!skb) {
+		stats->tx_dropped++;
+		return;
+	}
+
+	cf->can_id = ((msg->u.rx_can.msg[0] & 0x1f) << 6) |
+		     (msg->u.rx_can.msg[1] & 0x3f);
+	cf->can_dlc = get_can_dlc(msg->u.rx_can.msg[5]);
+
+	if (msg->id == CMD_RX_EXT_MESSAGE) {
+		cf->can_id <<= 18;
+		cf->can_id |= ((msg->u.rx_can.msg[2] & 0x0f) << 14) |
+			      ((msg->u.rx_can.msg[3] & 0xff) << 6) |
+			      (msg->u.rx_can.msg[4] & 0x3f);
+		cf->can_id |= CAN_EFF_FLAG;
+	}
+
+	if (msg->u.rx_can.flag & MSG_FLAG_REMOTE_FRAME) {
+		cf->can_id |= CAN_RTR_FLAG;
+	} else if (msg->u.rx_can.flag & (MSG_FLAG_ERROR_FRAME |
+					 MSG_FLAG_NERR)) {
+		cf->can_id |= CAN_ERR_FLAG;
+		cf->can_dlc = CAN_ERR_DLC;
+
+		netdev_err(priv->netdev, "Unknow error (flags: 0x%02x)\n",
+			   msg->u.rx_can.flag);
+
+		stats->rx_errors++;
+	} else if (msg->u.rx_can.flag & MSG_FLAG_OVERRUN) {
+		cf->can_id = CAN_ERR_FLAG | CAN_ERR_CRTL;
+		cf->can_dlc = CAN_ERR_DLC;
+		cf->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
+
+		stats->rx_over_errors++;
+		stats->rx_errors++;
+	} else if (!msg->u.rx_can.flag) {
+		memcpy(cf->data, &msg->u.rx_can.msg[6], cf->can_dlc);
+	} else {
+		kfree_skb(skb);
+		return;
+	}
+
+	netif_rx(skb);
+
+	stats->rx_packets++;
+	stats->rx_bytes += cf->can_dlc;
+}
+
+static void kvaser_usb_start_chip_reply(const struct kvaser_usb *dev,
+					const struct kvaser_msg *msg)
+{
+	struct kvaser_usb_net_priv *priv;
+	u8 channel = msg->u.simple.channel;
+
+	if (channel >= dev->nchannels) {
+		dev_err(dev->udev->dev.parent,
+			"Invalid channel number (%d)\n", channel);
+		return;
+	}
+
+	priv = dev->nets[channel];
+
+	if (completion_done(&priv->start_comp) &&
+	    netif_queue_stopped(priv->netdev)) {
+		netif_wake_queue(priv->netdev);
+	} else {
+		netif_start_queue(priv->netdev);
+		complete(&priv->start_comp);
+	}
+}
+
+static void kvaser_usb_stop_chip_reply(const struct kvaser_usb *dev,
+				       const struct kvaser_msg *msg)
+{
+	struct kvaser_usb_net_priv *priv;
+	u8 channel = msg->u.simple.channel;
+
+	if (channel >= dev->nchannels) {
+		dev_err(dev->udev->dev.parent,
+			"Invalid channel number (%d)\n", channel);
+		return;
+	}
+
+	priv = dev->nets[channel];
+
+	complete(&priv->stop_comp);
+}
+
+static void kvaser_usb_handle_message(const struct kvaser_usb *dev,
+				      const struct kvaser_msg *msg)
+{
+	switch (msg->id) {
+	case CMD_START_CHIP_REPLY:
+		kvaser_usb_start_chip_reply(dev, msg);
+		break;
+
+	case CMD_STOP_CHIP_REPLY:
+		kvaser_usb_stop_chip_reply(dev, msg);
+		break;
+
+	case CMD_RX_STD_MESSAGE:
+	case CMD_RX_EXT_MESSAGE:
+		kvaser_usb_rx_can_msg(dev, msg);
+		break;
+
+	case CMD_CHIP_STATE_EVENT:
+	case CMD_CAN_ERROR_EVENT:
+		kvaser_usb_rx_error(dev, msg);
+		break;
+
+	case CMD_TX_ACKNOWLEDGE:
+		kvaser_usb_tx_acknowledge(dev, msg);
+		break;
+
+	default:
+		dev_warn(dev->udev->dev.parent,
+			 "Unhandled message (%d)\n", msg->id);
+		break;
+	}
+}
+
+static void kvaser_usb_read_bulk_callback(struct urb *urb)
+{
+	struct kvaser_usb *dev = urb->context;
+	struct kvaser_msg *msg;
+	int pos = 0;
+	int err, i;
+
+	switch (urb->status) {
+	case 0:
+		break;
+	case -ENOENT:
+	case -ESHUTDOWN:
+		return;
+	default:
+		dev_info(dev->udev->dev.parent, "Rx URB aborted (%d)\n",
+			 urb->status);
+		goto resubmit_urb;
+	}
+
+	while (pos <= urb->actual_length - MSG_HEADER_LEN) {
+		msg = urb->transfer_buffer + pos;
+
+		if (!msg->len)
+			break;
+
+		if (pos + msg->len > urb->actual_length) {
+			dev_err(dev->udev->dev.parent, "Format error\n");
+			break;
+		}
+
+		kvaser_usb_handle_message(dev, msg);
+
+		pos += msg->len;
+	}
+
+resubmit_urb:
+	usb_fill_bulk_urb(urb, dev->udev,
+			  usb_rcvbulkpipe(dev->udev,
+					  dev->bulk_in->bEndpointAddress),
+			  urb->transfer_buffer, RX_BUFFER_SIZE,
+			  kvaser_usb_read_bulk_callback, dev);
+
+	err = usb_submit_urb(urb, GFP_ATOMIC);
+	if (err == -ENODEV) {
+		for (i = 0; i < dev->nchannels; i++) {
+			if (!dev->nets[i])
+				continue;
+
+			netif_device_detach(dev->nets[i]->netdev);
+		}
+	} else if (err) {
+		dev_err(dev->udev->dev.parent,
+			"Failed resubmitting read bulk urb: %d\n", err);
+	}
+
+	return;
+}
+
+static int kvaser_usb_setup_rx_urbs(struct kvaser_usb *dev)
+{
+	int i, err = 0;
+
+	if (dev->rxinitdone)
+		return 0;
+
+	for (i = 0; i < MAX_RX_URBS; i++) {
+		struct urb *urb = NULL;
+		u8 *buf = NULL;
+		dma_addr_t buf_dma;
+
+		urb = usb_alloc_urb(0, GFP_KERNEL);
+		if (!urb) {
+			dev_warn(dev->udev->dev.parent,
+				 "No memory left for URBs\n");
+			err = -ENOMEM;
+			break;
+		}
+
+		buf = usb_alloc_coherent(dev->udev, RX_BUFFER_SIZE,
+					 GFP_KERNEL, &buf_dma);
+		if (!buf) {
+			dev_warn(dev->udev->dev.parent,
+				 "No memory left for USB buffer\n");
+			usb_free_urb(urb);
+			err = -ENOMEM;
+			break;
+		}
+
+		usb_fill_bulk_urb(urb, dev->udev,
+				  usb_rcvbulkpipe(dev->udev,
+					  dev->bulk_in->bEndpointAddress),
+				  buf, RX_BUFFER_SIZE,
+				  kvaser_usb_read_bulk_callback,
+				  dev);
+		urb->transfer_dma = buf_dma;
+		urb->transfer_flags |= URB_NO_TRANSFER_DMA_MAP;
+		usb_anchor_urb(urb, &dev->rx_submitted);
+
+		err = usb_submit_urb(urb, GFP_KERNEL);
+		if (err) {
+			usb_unanchor_urb(urb);
+			usb_free_coherent(dev->udev, RX_BUFFER_SIZE, buf,
+					  buf_dma);
+			break;
+		}
+
+		dev->rxbuf[i] = buf;
+		dev->rxbuf_dma[i] = buf_dma;
+
+		usb_free_urb(urb);
+	}
+
+	if (i == 0) {
+		dev_warn(dev->udev->dev.parent,
+			 "Cannot setup read URBs, error %d\n", err);
+		return err;
+	} else if (i < MAX_RX_URBS) {
+		dev_warn(dev->udev->dev.parent,
+			 "RX performances may be slow\n");
+	}
+
+	dev->rxinitdone = true;
+
+	return 0;
+}
+
+static int kvaser_usb_set_opt_mode(const struct kvaser_usb_net_priv *priv)
+{
+	struct kvaser_msg msg = {
+		.id = CMD_SET_CTRL_MODE,
+		.len = MSG_HEADER_LEN +
+		       sizeof(struct kvaser_msg_ctrl_mode),
+		.u.ctrl_mode.tid = 0xff,
+		.u.ctrl_mode.channel = priv->channel,
+	};
+
+	if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY)
+		msg.u.ctrl_mode.ctrl_mode = KVASER_CTRL_MODE_SILENT;
+	else
+		msg.u.ctrl_mode.ctrl_mode = KVASER_CTRL_MODE_NORMAL;
+
+	return kvaser_usb_send_msg(priv->dev, &msg);
+}
+
+static int kvaser_usb_start_chip(struct kvaser_usb_net_priv *priv)
+{
+	int err;
+
+	init_completion(&priv->start_comp);
+
+	err = kvaser_usb_send_simple_msg(priv->dev, CMD_START_CHIP,
+					 priv->channel);
+	if (err)
+		return err;
+
+	if (!wait_for_completion_timeout(&priv->start_comp,
+					 msecs_to_jiffies(START_TIMEOUT)))
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int kvaser_usb_open(struct net_device *netdev)
+{
+	struct kvaser_usb_net_priv *priv = netdev_priv(netdev);
+	struct kvaser_usb *dev = priv->dev;
+	int err;
+
+	err = open_candev(netdev);
+	if (err)
+		return err;
+
+	err = kvaser_usb_setup_rx_urbs(dev);
+	if (err)
+		goto error;
+
+	err = kvaser_usb_set_opt_mode(priv);
+	if (err)
+		goto error;
+
+	err = kvaser_usb_start_chip(priv);
+	if (err) {
+		netdev_warn(netdev, "Cannot start device, error %d\n", err);
+		goto error;
+	}
+
+	priv->can.state = CAN_STATE_ERROR_ACTIVE;
+
+	return 0;
+
+error:
+	close_candev(netdev);
+	return err;
+}
+
+static void kvaser_usb_unlink_all_urbs(struct kvaser_usb *dev)
+{
+	int i;
+
+	usb_kill_anchored_urbs(&dev->rx_submitted);
+
+	for (i = 0; i < MAX_RX_URBS; i++)
+		usb_free_coherent(dev->udev, RX_BUFFER_SIZE,
+				  dev->rxbuf[i],
+				  dev->rxbuf_dma[i]);
+
+	for (i = 0; i < MAX_NET_DEVICES; i++) {
+		struct kvaser_usb_net_priv *priv = dev->nets[i];
+
+		if (priv)
+			kvaser_usb_unlink_tx_urbs(priv);
+	}
+}
+
+static int kvaser_usb_stop_chip(struct kvaser_usb_net_priv *priv)
+{
+	int err;
+
+	init_completion(&priv->stop_comp);
+
+	err = kvaser_usb_send_simple_msg(priv->dev, CMD_STOP_CHIP,
+					 priv->channel);
+	if (err)
+		return err;
+
+	if (!wait_for_completion_timeout(&priv->stop_comp,
+					 msecs_to_jiffies(STOP_TIMEOUT)))
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int kvaser_usb_flush_queue(struct kvaser_usb_net_priv *priv)
+{
+	struct kvaser_msg msg = {
+		.id = CMD_FLUSH_QUEUE,
+		.len = MSG_HEADER_LEN +
+		       sizeof(struct kvaser_msg_flush_queue),
+		.u.flush_queue.channel = priv->channel,
+		.u.flush_queue.flags = 0x00,
+	};
+
+	return kvaser_usb_send_msg(priv->dev, &msg);
+}
+
+static int kvaser_usb_close(struct net_device *netdev)
+{
+	struct kvaser_usb_net_priv *priv = netdev_priv(netdev);
+	struct kvaser_usb *dev = priv->dev;
+	int err;
+
+	netif_stop_queue(netdev);
+
+	err = kvaser_usb_flush_queue(priv);
+	if (err)
+		netdev_warn(netdev, "Cannot flush queue, error %d\n", err);
+
+	if (kvaser_usb_send_simple_msg(dev, CMD_RESET_CHIP, priv->channel))
+		netdev_warn(netdev, "Cannot reset card, error %d\n", err);
+
+	err = kvaser_usb_stop_chip(priv);
+	if (err)
+		netdev_warn(netdev, "Cannot stop device, error %d\n", err);
+
+	priv->can.state = CAN_STATE_STOPPED;
+	close_candev(priv->netdev);
+
+	return 0;
+}
+
+static void kvaser_usb_write_bulk_callback(struct urb *urb)
+{
+	struct kvaser_usb_tx_urb_context *context = urb->context;
+	struct kvaser_usb_net_priv *priv;
+	struct net_device *netdev;
+
+	if (WARN_ON(!context))
+		return;
+
+	priv = context->priv;
+	netdev = priv->netdev;
+
+	kfree(urb->transfer_buffer);
+
+	if (!netif_device_present(netdev))
+		return;
+
+	if (urb->status)
+		netdev_info(netdev, "Tx URB aborted (%d)\n", urb->status);
+}
+
+static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
+					 struct net_device *netdev)
+{
+	struct kvaser_usb_net_priv *priv = netdev_priv(netdev);
+	struct kvaser_usb *dev = priv->dev;
+	struct net_device_stats *stats = &netdev->stats;
+	struct can_frame *cf = (struct can_frame *)skb->data;
+	struct kvaser_usb_tx_urb_context *context = NULL;
+	struct urb *urb;
+	void *buf;
+	struct kvaser_msg *msg;
+	int i, err;
+	int ret = NETDEV_TX_OK;
+
+	if (can_dropped_invalid_skb(netdev, skb))
+		return NETDEV_TX_OK;
+
+	urb = usb_alloc_urb(0, GFP_ATOMIC);
+	if (!urb) {
+		netdev_err(netdev, "No memory left for URBs\n");
+		stats->tx_dropped++;
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
+	buf = kmalloc(sizeof(struct kvaser_msg), GFP_ATOMIC);
+	if (!buf) {
+		netdev_err(netdev, "No memory left for USB buffer\n");
+		stats->tx_dropped++;
+		dev_kfree_skb(skb);
+		goto nobufmem;
+	}
+
+	msg = (struct kvaser_msg *)buf;
+	msg->len = MSG_HEADER_LEN + sizeof(struct kvaser_msg_tx_can);
+	msg->u.tx_can.flags = 0;
+	msg->u.tx_can.channel = priv->channel;
+
+	if (cf->can_id & CAN_EFF_FLAG) {
+		msg->id = CMD_TX_EXT_MESSAGE;
+		msg->u.tx_can.msg[0] = (cf->can_id >> 24) & 0x1f;
+		msg->u.tx_can.msg[1] = (cf->can_id >> 18) & 0x3f;
+		msg->u.tx_can.msg[2] = (cf->can_id >> 14) & 0x0f;
+		msg->u.tx_can.msg[3] = (cf->can_id >> 6) & 0xff;
+		msg->u.tx_can.msg[4] = cf->can_id & 0x3f;
+	} else {
+		msg->id = CMD_TX_STD_MESSAGE;
+		msg->u.tx_can.msg[0] = (cf->can_id >> 6) & 0x1f;
+		msg->u.tx_can.msg[1] = cf->can_id & 0x3f;
+	}
+
+	msg->u.tx_can.msg[5] = cf->can_dlc;
+	memcpy(&msg->u.tx_can.msg[6], cf->data, cf->can_dlc);
+
+	if (cf->can_id & CAN_RTR_FLAG)
+		msg->u.tx_can.flags |= MSG_FLAG_REMOTE_FRAME;
+
+	for (i = 0; i < ARRAY_SIZE(priv->tx_contexts); i++) {
+		if (priv->tx_contexts[i].echo_index == MAX_TX_URBS) {
+			context = &priv->tx_contexts[i];
+			break;
+		}
+	}
+
+	if (!context) {
+		netdev_warn(netdev, "cannot find free context\n");
+		ret =  NETDEV_TX_BUSY;
+		goto releasebuf;
+	}
+
+	context->priv = priv;
+	context->echo_index = i;
+	context->dlc = cf->can_dlc;
+
+	msg->u.tx_can.tid = context->echo_index;
+
+	usb_fill_bulk_urb(urb, dev->udev,
+			  usb_sndbulkpipe(dev->udev,
+					  dev->bulk_out->bEndpointAddress),
+			  buf, msg->len,
+			  kvaser_usb_write_bulk_callback, context);
+	usb_anchor_urb(urb, &priv->tx_submitted);
+
+	can_put_echo_skb(skb, netdev, context->echo_index);
+
+	atomic_inc(&priv->active_tx_urbs);
+
+	if (atomic_read(&priv->active_tx_urbs) >= MAX_TX_URBS)
+		netif_stop_queue(netdev);
+
+	err = usb_submit_urb(urb, GFP_ATOMIC);
+	if (unlikely(err)) {
+		can_free_echo_skb(netdev, context->echo_index);
+
+		atomic_dec(&priv->active_tx_urbs);
+		usb_unanchor_urb(urb);
+
+		stats->tx_dropped++;
+
+		if (err == -ENODEV)
+			netif_device_detach(netdev);
+		else
+			netdev_warn(netdev, "Failed tx_urb %d\n", err);
+
+		goto releasebuf;
+	}
+
+	netdev->trans_start = jiffies;
+
+	usb_free_urb(urb);
+
+	return NETDEV_TX_OK;
+
+releasebuf:
+	kfree(buf);
+nobufmem:
+	usb_free_urb(urb);
+	return ret;
+}
+
+static const struct net_device_ops kvaser_usb_netdev_ops = {
+	.ndo_open = kvaser_usb_open,
+	.ndo_stop = kvaser_usb_close,
+	.ndo_start_xmit = kvaser_usb_start_xmit,
+};
+
+static struct can_bittiming_const kvaser_usb_bittiming_const = {
+	.name = "kvaser_usb",
+	.tseg1_min = KVASER_USB_TSEG1_MIN,
+	.tseg1_max = KVASER_USB_TSEG1_MAX,
+	.tseg2_min = KVASER_USB_TSEG2_MIN,
+	.tseg2_max = KVASER_USB_TSEG2_MAX,
+	.sjw_max = KVASER_USB_SJW_MAX,
+	.brp_min = KVASER_USB_BRP_MIN,
+	.brp_max = KVASER_USB_BRP_MAX,
+	.brp_inc = KVASER_USB_BRP_INC,
+};
+
+static int kvaser_usb_set_bittiming(struct net_device *netdev)
+{
+	struct kvaser_usb_net_priv *priv = netdev_priv(netdev);
+	struct can_bittiming *bt = &priv->can.bittiming;
+	struct kvaser_usb *dev = priv->dev;
+	struct kvaser_msg msg = {
+		.id = CMD_SET_BUS_PARAMS,
+		.len = MSG_HEADER_LEN +
+		       sizeof(struct kvaser_msg_busparams),
+		.u.busparams.channel = priv->channel,
+		.u.busparams.tid = 0xff,
+		.u.busparams.bitrate = cpu_to_le32(bt->bitrate),
+		.u.busparams.sjw = bt->sjw,
+		.u.busparams.tseg1 = bt->prop_seg + bt->phase_seg1,
+		.u.busparams.tseg2 = bt->phase_seg2,
+	};
+
+	if (priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES)
+		msg.u.busparams.no_samp = 3;
+	else
+		msg.u.busparams.no_samp = 1;
+
+	return kvaser_usb_send_msg(dev, &msg);
+}
+
+static int kvaser_usb_set_mode(struct net_device *netdev,
+			       enum can_mode mode)
+{
+	struct kvaser_usb_net_priv *priv = netdev_priv(netdev);
+	int err;
+
+	switch (mode) {
+	case CAN_MODE_START:
+		err = kvaser_usb_simple_msg_async(priv, CMD_START_CHIP);
+		if (err)
+			return err;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static int kvaser_usb_get_berr_counter(const struct net_device *netdev,
+				       struct can_berr_counter *bec)
+{
+	struct kvaser_usb_net_priv *priv = netdev_priv(netdev);
+
+	*bec = priv->bec;
+
+	return 0;
+}
+
+static int kvaser_usb_init_one(struct usb_interface *intf,
+			       const struct usb_device_id *id, int channel)
+{
+	struct kvaser_usb *dev = usb_get_intfdata(intf);
+	struct net_device *netdev;
+	struct kvaser_usb_net_priv *priv;
+	int i, err;
+
+	netdev = alloc_candev(sizeof(*priv), MAX_TX_URBS);
+	if (!netdev) {
+		dev_err(&intf->dev, "Cannot alloc candev\n");
+		return -ENOMEM;
+	}
+
+	priv = netdev_priv(netdev);
+
+	init_completion(&priv->start_comp);
+	init_completion(&priv->stop_comp);
+
+	init_usb_anchor(&priv->tx_submitted);
+	atomic_set(&priv->active_tx_urbs, 0);
+
+	for (i = 0; i < ARRAY_SIZE(priv->tx_contexts); i++)
+		priv->tx_contexts[i].echo_index = MAX_TX_URBS;
+
+	priv->dev = dev;
+	priv->netdev = netdev;
+	priv->channel = channel;
+
+	priv->can.state = CAN_STATE_STOPPED;
+	priv->can.clock.freq = CAN_USB_CLOCK;
+	priv->can.bittiming_const = &kvaser_usb_bittiming_const;
+	priv->can.do_set_bittiming = kvaser_usb_set_bittiming;
+	priv->can.do_set_mode = kvaser_usb_set_mode;
+	if (id->driver_info & KVASER_HAS_TXRX_ERRORS)
+		priv->can.do_get_berr_counter = kvaser_usb_get_berr_counter;
+	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES;
+	if (id->driver_info & KVASER_HAS_SILENT_MODE)
+		priv->can.ctrlmode_supported |= CAN_CTRLMODE_LISTENONLY;
+
+	netdev->flags |= IFF_ECHO;
+
+	netdev->netdev_ops = &kvaser_usb_netdev_ops;
+
+	SET_NETDEV_DEV(netdev, &intf->dev);
+
+	dev->nets[channel] = priv;
+
+	err = register_candev(netdev);
+	if (err) {
+		dev_err(&intf->dev, "Failed to register can device\n");
+		free_candev(netdev);
+		return err;
+	}
+
+	netdev_dbg(netdev, "device registered\n");
+
+	return 0;
+}
+
+static void kvaser_usb_get_endpoints(const struct usb_interface *intf,
+				     struct usb_endpoint_descriptor **in,
+				     struct usb_endpoint_descriptor **out)
+{
+	const struct usb_host_interface *iface_desc;
+	struct usb_endpoint_descriptor *endpoint;
+	int i;
+
+	iface_desc = &intf->altsetting[0];
+
+	for (i = 0; i < iface_desc->desc.bNumEndpoints; ++i) {
+		endpoint = &iface_desc->endpoint[i].desc;
+
+		if (usb_endpoint_is_bulk_in(endpoint))
+			*in = endpoint;
+
+		if (usb_endpoint_is_bulk_out(endpoint))
+			*out = endpoint;
+	}
+}
+
+static int kvaser_usb_probe(struct usb_interface *intf,
+			    const struct usb_device_id *id)
+{
+	struct kvaser_usb *dev;
+	int err = -ENOMEM;
+	int i;
+
+	dev = devm_kzalloc(&intf->dev, sizeof(*dev), GFP_KERNEL);
+	if (!dev)
+		return -ENOMEM;
+
+	kvaser_usb_get_endpoints(intf, &dev->bulk_in, &dev->bulk_out);
+	if (!dev->bulk_in || !dev->bulk_out) {
+		dev_err(&intf->dev, "Cannot get usb endpoint(s)");
+		return err;
+	}
+
+	dev->udev = interface_to_usbdev(intf);
+
+	init_usb_anchor(&dev->rx_submitted);
+
+	usb_set_intfdata(intf, dev);
+
+	for (i = 0; i < MAX_NET_DEVICES; i++)
+		kvaser_usb_send_simple_msg(dev, CMD_RESET_CHIP, i);
+
+	err = kvaser_usb_get_software_info(dev);
+	if (err) {
+		dev_err(&intf->dev,
+			"Cannot get software infos, error %d\n", err);
+		return err;
+	}
+
+	err = kvaser_usb_get_card_info(dev);
+	if (err) {
+		dev_err(&intf->dev,
+			"Cannot get card infos, error %d\n", err);
+		return err;
+	}
+
+	dev_dbg(&intf->dev, "Firmware version: %d.%d.%d\n",
+		((dev->fw_version >> 24) & 0xff),
+		((dev->fw_version >> 16) & 0xff),
+		(dev->fw_version & 0xffff));
+
+	for (i = 0; i < dev->nchannels; i++)
+		kvaser_usb_init_one(intf, id, i);
+
+	return 0;
+}
+
+static void kvaser_usb_disconnect(struct usb_interface *intf)
+{
+	struct kvaser_usb *dev = usb_get_intfdata(intf);
+	int i;
+
+	usb_set_intfdata(intf, NULL);
+
+	if (!dev)
+		return;
+
+	for (i = 0; i < dev->nchannels; i++) {
+		if (!dev->nets[i])
+			continue;
+
+		unregister_netdev(dev->nets[i]->netdev);
+	}
+
+	kvaser_usb_unlink_all_urbs(dev);
+
+	for (i = 0; i < dev->nchannels; i++)
+		free_candev(dev->nets[i]->netdev);
+}
+
+static struct usb_driver kvaser_usb_driver = {
+	.name = "kvaser_usb",
+	.probe = kvaser_usb_probe,
+	.disconnect = kvaser_usb_disconnect,
+	.id_table = kvaser_usb_table
+};
+
+module_usb_driver(kvaser_usb_driver);
+
+MODULE_AUTHOR("Olivier Sobrie <olivier@sobrie.be>");
+MODULE_DESCRIPTION("CAN driver for Kvaser CAN/USB devices");
+MODULE_LICENSE("GPL v2");
-- 
1.7.9.5

