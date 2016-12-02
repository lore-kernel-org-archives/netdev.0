From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/2] can: peak: Add support for PCAN-USB X6 USB interface
Date: Fri,  2 Dec 2016 09:29:31 +0100
Message-ID: <20161202082931.22270-3-mkl@pengutronix.de>
References: <20161202082931.22270-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de,
        Stephane Grosjean <s.grosjean@peak-system.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:44595 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755734AbcLBI3r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 03:29:47 -0500
In-Reply-To: <20161202082931.22270-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephane Grosjean <s.grosjean@peak-system.com>

This adds support for PEAK-System PCAN-USB X6 USB to CAN interface.

The CAN FD adapter PCAN-USB X6 allows the connection of up to 6 CAN FD
or CAN networks to a computer via USB. The interface is installed in an
aluminum profile casing and is shipped in versions with D-Sub connectors
or M12 circular connectors.

The PCAN-USB X6 registers in the USB sub-system as if 3x PCAN-USB-Pro FD
adapters were plugged. So, this patch:

- updates the PEAK_USB entry of the corresponding Kconfig file
- defines and adds the device id. of the PCAN-USB X6 (0x0014) into the
  table of supported device ids
- defines and adds the new software structure implementing the PCAN-USB X6,
  which is obviously a clone of the software structure implementing the
  PCAN-USB Pro FD.

Signed-off-by: Stephane Grosjean <s.grosjean@peak-system.com>
Tested-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/peak_usb/pcan_usb_core.c |  2 +
 drivers/net/can/usb/peak_usb/pcan_usb_core.h |  2 +
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c   | 72 ++++++++++++++++++++++++++++
 3 files changed, 76 insertions(+)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.c b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
index c06382cdfdfe..f3141ca56bc3 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
@@ -39,6 +39,7 @@ static struct usb_device_id peak_usb_table[] = {
 	{USB_DEVICE(PCAN_USB_VENDOR_ID, PCAN_USBPRO_PRODUCT_ID)},
 	{USB_DEVICE(PCAN_USB_VENDOR_ID, PCAN_USBFD_PRODUCT_ID)},
 	{USB_DEVICE(PCAN_USB_VENDOR_ID, PCAN_USBPROFD_PRODUCT_ID)},
+	{USB_DEVICE(PCAN_USB_VENDOR_ID, PCAN_USBX6_PRODUCT_ID)},
 	{} /* Terminating entry */
 };
 
@@ -50,6 +51,7 @@ static const struct peak_usb_adapter *const peak_usb_adapters_list[] = {
 	&pcan_usb_pro,
 	&pcan_usb_fd,
 	&pcan_usb_pro_fd,
+	&pcan_usb_x6,
 };
 
 /*
diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.h b/drivers/net/can/usb/peak_usb/pcan_usb_core.h
index 506fe506c9d3..3cbfb069893d 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_core.h
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.h
@@ -27,6 +27,7 @@
 #define PCAN_USBPRO_PRODUCT_ID		0x000d
 #define PCAN_USBPROFD_PRODUCT_ID	0x0011
 #define PCAN_USBFD_PRODUCT_ID		0x0012
+#define PCAN_USBX6_PRODUCT_ID		0x0014
 
 #define PCAN_USB_DRIVER_NAME		"peak_usb"
 
@@ -90,6 +91,7 @@ extern const struct peak_usb_adapter pcan_usb;
 extern const struct peak_usb_adapter pcan_usb_pro;
 extern const struct peak_usb_adapter pcan_usb_fd;
 extern const struct peak_usb_adapter pcan_usb_pro_fd;
+extern const struct peak_usb_adapter pcan_usb_x6;
 
 struct peak_time_ref {
 	struct timeval tv_host_0, tv_host;
diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_fd.c b/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
index 8a316a194cf7..304732550f0a 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
@@ -1132,3 +1132,75 @@ const struct peak_usb_adapter pcan_usb_pro_fd = {
 
 	.do_get_berr_counter = pcan_usb_fd_get_berr_counter,
 };
+
+/* describes the PCAN-USB X6 adapter */
+static const struct can_bittiming_const pcan_usb_x6_const = {
+	.name = "pcan_usb_x6",
+	.tseg1_min = 1,
+	.tseg1_max = (1 << PUCAN_TSLOW_TSGEG1_BITS),
+	.tseg2_min = 1,
+	.tseg2_max = (1 << PUCAN_TSLOW_TSGEG2_BITS),
+	.sjw_max = (1 << PUCAN_TSLOW_SJW_BITS),
+	.brp_min = 1,
+	.brp_max = (1 << PUCAN_TSLOW_BRP_BITS),
+	.brp_inc = 1,
+};
+
+static const struct can_bittiming_const pcan_usb_x6_data_const = {
+	.name = "pcan_usb_x6",
+	.tseg1_min = 1,
+	.tseg1_max = (1 << PUCAN_TFAST_TSGEG1_BITS),
+	.tseg2_min = 1,
+	.tseg2_max = (1 << PUCAN_TFAST_TSGEG2_BITS),
+	.sjw_max = (1 << PUCAN_TFAST_SJW_BITS),
+	.brp_min = 1,
+	.brp_max = (1 << PUCAN_TFAST_BRP_BITS),
+	.brp_inc = 1,
+};
+
+const struct peak_usb_adapter pcan_usb_x6 = {
+	.name = "PCAN-USB X6",
+	.device_id = PCAN_USBX6_PRODUCT_ID,
+	.ctrl_count = PCAN_USBPROFD_CHANNEL_COUNT,
+	.ctrlmode_supported = CAN_CTRLMODE_FD |
+			CAN_CTRLMODE_3_SAMPLES | CAN_CTRLMODE_LISTENONLY,
+	.clock = {
+		.freq = PCAN_UFD_CRYSTAL_HZ,
+	},
+	.bittiming_const = &pcan_usb_x6_const,
+	.data_bittiming_const = &pcan_usb_x6_data_const,
+
+	/* size of device private data */
+	.sizeof_dev_private = sizeof(struct pcan_usb_fd_device),
+
+	/* timestamps usage */
+	.ts_used_bits = 32,
+	.ts_period = 1000000, /* calibration period in ts. */
+	.us_per_ts_scale = 1, /* us = (ts * scale) >> shift */
+	.us_per_ts_shift = 0,
+
+	/* give here messages in/out endpoints */
+	.ep_msg_in = PCAN_USBPRO_EP_MSGIN,
+	.ep_msg_out = {PCAN_USBPRO_EP_MSGOUT_0, PCAN_USBPRO_EP_MSGOUT_1},
+
+	/* size of rx/tx usb buffers */
+	.rx_buffer_size = PCAN_UFD_RX_BUFFER_SIZE,
+	.tx_buffer_size = PCAN_UFD_TX_BUFFER_SIZE,
+
+	/* device callbacks */
+	.intf_probe = pcan_usb_pro_probe,	/* same as PCAN-USB Pro */
+	.dev_init = pcan_usb_fd_init,
+
+	.dev_exit = pcan_usb_fd_exit,
+	.dev_free = pcan_usb_fd_free,
+	.dev_set_bus = pcan_usb_fd_set_bus,
+	.dev_set_bittiming = pcan_usb_fd_set_bittiming_slow,
+	.dev_set_data_bittiming = pcan_usb_fd_set_bittiming_fast,
+	.dev_decode_buf = pcan_usb_fd_decode_buf,
+	.dev_start = pcan_usb_fd_start,
+	.dev_stop = pcan_usb_fd_stop,
+	.dev_restart_async = pcan_usb_fd_restart_async,
+	.dev_encode_msg = pcan_usb_fd_encode_msg,
+
+	.do_get_berr_counter = pcan_usb_fd_get_berr_counter,
+};
-- 
2.10.2
