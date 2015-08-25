From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: pcan_usb: don't provide CAN FD bittimings by non-FD adapters
Date: Tue, 25 Aug 2015 08:55:46 +0200
Message-ID: <1440485746-28027-2-git-send-email-mkl@pengutronix.de>
References: <1440485746-28027-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Marc Kleine-Budde <mkl@pengutronix.de>,
	linux-stable <stable@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1440485746-28027-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CAN FD data bittiming constants are provided via netlink only when there
are valid CAN FD constants available in priv->data_bittiming_const.

Due to the indirection of pointer assignments in the peak_usb driver the
priv->data_bittiming_const never becomes NULL - not even for non-FD adapters.

The data_bittiming_const points to zero'ed data which leads to this result
when running 'ip -details link show can0':

35: can0: <NOARP,ECHO> mtu 16 qdisc noop state DOWN mode DEFAULT group default qlen 10
    link/can  promiscuity 0
    can state STOPPED restart-ms 0
	  pcan_usb: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
	  : dtseg1 0..0 dtseg2 0..0 dsjw 1..0 dbrp 0..0 dbrp-inc 0  <== BROKEN!
	  clock 8000000

This patch changes the struct peak_usb_adapter::bittiming_const and struct
peak_usb_adapter::data_bittiming_const to pointers to fix the assignemnt
problems.

Cc: linux-stable <stable@vger.kernel.org> # >= 4.0
Reported-by: Oliver Hartkopp <socketcan@hartkopp.net>
Tested-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/peak_usb/pcan_usb.c      | 24 +++----
 drivers/net/can/usb/peak_usb/pcan_usb_core.c |  4 +-
 drivers/net/can/usb/peak_usb/pcan_usb_core.h |  4 +-
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c   | 96 +++++++++++++++-------------
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c  | 24 +++----
 5 files changed, 82 insertions(+), 70 deletions(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb.c b/drivers/net/can/usb/peak_usb/pcan_usb.c
index 6b94007ae052..838545ce468d 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb.c
@@ -854,6 +854,18 @@ static int pcan_usb_probe(struct usb_interface *intf)
 /*
  * describe the PCAN-USB adapter
  */
+static const struct can_bittiming_const pcan_usb_const = {
+	.name = "pcan_usb",
+	.tseg1_min = 1,
+	.tseg1_max = 16,
+	.tseg2_min = 1,
+	.tseg2_max = 8,
+	.sjw_max = 4,
+	.brp_min = 1,
+	.brp_max = 64,
+	.brp_inc = 1,
+};
+
 const struct peak_usb_adapter pcan_usb = {
 	.name = "PCAN-USB",
 	.device_id = PCAN_USB_PRODUCT_ID,
@@ -862,17 +874,7 @@ const struct peak_usb_adapter pcan_usb = {
 	.clock = {
 		.freq = PCAN_USB_CRYSTAL_HZ / 2 ,
 	},
-	.bittiming_const = {
-		.name = "pcan_usb",
-		.tseg1_min = 1,
-		.tseg1_max = 16,
-		.tseg2_min = 1,
-		.tseg2_max = 8,
-		.sjw_max = 4,
-		.brp_min = 1,
-		.brp_max = 64,
-		.brp_inc = 1,
-	},
+	.bittiming_const = &pcan_usb_const,
 
 	/* size of device private data */
 	.sizeof_dev_private = sizeof(struct pcan_usb),
diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.c b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
index 7921cff93a63..5a2e341a6d1e 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
@@ -792,9 +792,9 @@ static int peak_usb_create_dev(const struct peak_usb_adapter *peak_usb_adapter,
 	dev->ep_msg_out = peak_usb_adapter->ep_msg_out[ctrl_idx];
 
 	dev->can.clock = peak_usb_adapter->clock;
-	dev->can.bittiming_const = &peak_usb_adapter->bittiming_const;
+	dev->can.bittiming_const = peak_usb_adapter->bittiming_const;
 	dev->can.do_set_bittiming = peak_usb_set_bittiming;
-	dev->can.data_bittiming_const = &peak_usb_adapter->data_bittiming_const;
+	dev->can.data_bittiming_const = peak_usb_adapter->data_bittiming_const;
 	dev->can.do_set_data_bittiming = peak_usb_set_data_bittiming;
 	dev->can.do_set_mode = peak_usb_set_mode;
 	dev->can.do_get_berr_counter = peak_usb_adapter->do_get_berr_counter;
diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.h b/drivers/net/can/usb/peak_usb/pcan_usb_core.h
index 9e624f05ad4d..506fe506c9d3 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_core.h
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.h
@@ -48,8 +48,8 @@ struct peak_usb_adapter {
 	u32 device_id;
 	u32 ctrlmode_supported;
 	struct can_clock clock;
-	const struct can_bittiming_const bittiming_const;
-	const struct can_bittiming_const data_bittiming_const;
+	const struct can_bittiming_const * const bittiming_const;
+	const struct can_bittiming_const * const data_bittiming_const;
 	unsigned int ctrl_count;
 
 	int (*intf_probe)(struct usb_interface *intf);
diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_fd.c b/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
index 09d14e70abd7..ce44a033f63b 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
@@ -990,6 +990,30 @@ static void pcan_usb_fd_free(struct peak_usb_device *dev)
 }
 
 /* describes the PCAN-USB FD adapter */
+static const struct can_bittiming_const pcan_usb_fd_const = {
+	.name = "pcan_usb_fd",
+	.tseg1_min = 1,
+	.tseg1_max = 64,
+	.tseg2_min = 1,
+	.tseg2_max = 16,
+	.sjw_max = 16,
+	.brp_min = 1,
+	.brp_max = 1024,
+	.brp_inc = 1,
+};
+
+static const struct can_bittiming_const pcan_usb_fd_data_const = {
+	.name = "pcan_usb_fd",
+	.tseg1_min = 1,
+	.tseg1_max = 16,
+	.tseg2_min = 1,
+	.tseg2_max = 8,
+	.sjw_max = 4,
+	.brp_min = 1,
+	.brp_max = 1024,
+	.brp_inc = 1,
+};
+
 const struct peak_usb_adapter pcan_usb_fd = {
 	.name = "PCAN-USB FD",
 	.device_id = PCAN_USBFD_PRODUCT_ID,
@@ -999,28 +1023,8 @@ const struct peak_usb_adapter pcan_usb_fd = {
 	.clock = {
 		.freq = PCAN_UFD_CRYSTAL_HZ,
 	},
-	.bittiming_const = {
-		.name = "pcan_usb_fd",
-		.tseg1_min = 1,
-		.tseg1_max = 64,
-		.tseg2_min = 1,
-		.tseg2_max = 16,
-		.sjw_max = 16,
-		.brp_min = 1,
-		.brp_max = 1024,
-		.brp_inc = 1,
-	},
-	.data_bittiming_const = {
-		.name = "pcan_usb_fd",
-		.tseg1_min = 1,
-		.tseg1_max = 16,
-		.tseg2_min = 1,
-		.tseg2_max = 8,
-		.sjw_max = 4,
-		.brp_min = 1,
-		.brp_max = 1024,
-		.brp_inc = 1,
-	},
+	.bittiming_const = &pcan_usb_fd_const,
+	.data_bittiming_const = &pcan_usb_fd_data_const,
 
 	/* size of device private data */
 	.sizeof_dev_private = sizeof(struct pcan_usb_fd_device),
@@ -1058,6 +1062,30 @@ const struct peak_usb_adapter pcan_usb_fd = {
 };
 
 /* describes the PCAN-USB Pro FD adapter */
+static const struct can_bittiming_const pcan_usb_pro_fd_const = {
+	.name = "pcan_usb_pro_fd",
+	.tseg1_min = 1,
+	.tseg1_max = 64,
+	.tseg2_min = 1,
+	.tseg2_max = 16,
+	.sjw_max = 16,
+	.brp_min = 1,
+	.brp_max = 1024,
+	.brp_inc = 1,
+};
+
+static const struct can_bittiming_const pcan_usb_pro_fd_data_const = {
+	.name = "pcan_usb_pro_fd",
+	.tseg1_min = 1,
+	.tseg1_max = 16,
+	.tseg2_min = 1,
+	.tseg2_max = 8,
+	.sjw_max = 4,
+	.brp_min = 1,
+	.brp_max = 1024,
+	.brp_inc = 1,
+};
+
 const struct peak_usb_adapter pcan_usb_pro_fd = {
 	.name = "PCAN-USB Pro FD",
 	.device_id = PCAN_USBPROFD_PRODUCT_ID,
@@ -1067,28 +1095,8 @@ const struct peak_usb_adapter pcan_usb_pro_fd = {
 	.clock = {
 		.freq = PCAN_UFD_CRYSTAL_HZ,
 	},
-	.bittiming_const = {
-		.name = "pcan_usb_pro_fd",
-		.tseg1_min = 1,
-		.tseg1_max = 64,
-		.tseg2_min = 1,
-		.tseg2_max = 16,
-		.sjw_max = 16,
-		.brp_min = 1,
-		.brp_max = 1024,
-		.brp_inc = 1,
-	},
-	.data_bittiming_const = {
-		.name = "pcan_usb_pro_fd",
-		.tseg1_min = 1,
-		.tseg1_max = 16,
-		.tseg2_min = 1,
-		.tseg2_max = 8,
-		.sjw_max = 4,
-		.brp_min = 1,
-		.brp_max = 1024,
-		.brp_inc = 1,
-	},
+	.bittiming_const = &pcan_usb_pro_fd_const,
+	.data_bittiming_const = &pcan_usb_pro_fd_data_const,
 
 	/* size of device private data */
 	.sizeof_dev_private = sizeof(struct pcan_usb_fd_device),
diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
index 7d61b3279798..bbdd6058cd2f 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_pro.c
@@ -1004,6 +1004,18 @@ int pcan_usb_pro_probe(struct usb_interface *intf)
 /*
  * describe the PCAN-USB Pro adapter
  */
+static const struct can_bittiming_const pcan_usb_pro_const = {
+	.name = "pcan_usb_pro",
+	.tseg1_min = 1,
+	.tseg1_max = 16,
+	.tseg2_min = 1,
+	.tseg2_max = 8,
+	.sjw_max = 4,
+	.brp_min = 1,
+	.brp_max = 1024,
+	.brp_inc = 1,
+};
+
 const struct peak_usb_adapter pcan_usb_pro = {
 	.name = "PCAN-USB Pro",
 	.device_id = PCAN_USBPRO_PRODUCT_ID,
@@ -1012,17 +1024,7 @@ const struct peak_usb_adapter pcan_usb_pro = {
 	.clock = {
 		.freq = PCAN_USBPRO_CRYSTAL_HZ,
 	},
-	.bittiming_const = {
-		.name = "pcan_usb_pro",
-		.tseg1_min = 1,
-		.tseg1_max = 16,
-		.tseg2_min = 1,
-		.tseg2_max = 8,
-		.sjw_max = 4,
-		.brp_min = 1,
-		.brp_max = 1024,
-		.brp_inc = 1,
-	},
+	.bittiming_const = &pcan_usb_pro_const,
 
 	/* size of device private data */
 	.sizeof_dev_private = sizeof(struct pcan_usb_pro_device),
-- 
2.5.0

