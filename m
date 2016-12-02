From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/2] can: peak: Fix bittiming fields size in bits
Date: Fri,  2 Dec 2016 09:29:30 +0100
Message-ID: <20161202082931.22270-2-mkl@pengutronix.de>
References: <20161202082931.22270-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de,
        Stephane Grosjean <s.grosjean@peak-system.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:51483 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755694AbcLBI3r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 03:29:47 -0500
In-Reply-To: <20161202082931.22270-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephane Grosjean <s.grosjean@peak-system.com>

This fixes the bitimings fields ranges supported by all the CAN-FD USB
interfaces of the PEAK-System CAN-FD adapters.

Very first development versions of the IP core API defined smaller TSGEx
and SJW fields for both nominal and data bittimings records than the
production versions. This patch fixes them by enlarging their sizes to
the actual values:

field:           old size:    fixed size:
nominal TSGEG1   6            8
nominal TSGEG2   4            7
nominal SJW      4            7
data TSGEG1      4            5
data TSGEG2      3            4
data SJW         2            4

Note that this has no other consequences than offering larger choice to
bitrate encoding.

Signed-off-by: Stephane Grosjean <s.grosjean@peak-system.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/peak_usb/pcan_ucan.h   | 37 +++++++++++++++++++++++-------
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c | 32 +++++++++++++-------------
 2 files changed, 45 insertions(+), 24 deletions(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_ucan.h b/drivers/net/can/usb/peak_usb/pcan_ucan.h
index e8fc4952c6b0..2147678f0225 100644
--- a/drivers/net/can/usb/peak_usb/pcan_ucan.h
+++ b/drivers/net/can/usb/peak_usb/pcan_ucan.h
@@ -43,11 +43,22 @@ struct __packed pucan_command {
 	u16	args[3];
 };
 
+#define PUCAN_TSLOW_BRP_BITS		10
+#define PUCAN_TSLOW_TSGEG1_BITS		8
+#define PUCAN_TSLOW_TSGEG2_BITS		7
+#define PUCAN_TSLOW_SJW_BITS		7
+
+#define PUCAN_TSLOW_BRP_MASK		((1 << PUCAN_TSLOW_BRP_BITS) - 1)
+#define PUCAN_TSLOW_TSEG1_MASK		((1 << PUCAN_TSLOW_TSGEG1_BITS) - 1)
+#define PUCAN_TSLOW_TSEG2_MASK		((1 << PUCAN_TSLOW_TSGEG2_BITS) - 1)
+#define PUCAN_TSLOW_SJW_MASK		((1 << PUCAN_TSLOW_SJW_BITS) - 1)
+
 /* uCAN TIMING_SLOW command fields */
-#define PUCAN_TSLOW_SJW_T(s, t)		(((s) & 0xf) | ((!!(t)) << 7))
-#define PUCAN_TSLOW_TSEG2(t)		((t) & 0xf)
-#define PUCAN_TSLOW_TSEG1(t)		((t) & 0x3f)
-#define PUCAN_TSLOW_BRP(b)		((b) & 0x3ff)
+#define PUCAN_TSLOW_SJW_T(s, t)		(((s) & PUCAN_TSLOW_SJW_MASK) | \
+								((!!(t)) << 7))
+#define PUCAN_TSLOW_TSEG2(t)		((t) & PUCAN_TSLOW_TSEG2_MASK)
+#define PUCAN_TSLOW_TSEG1(t)		((t) & PUCAN_TSLOW_TSEG1_MASK)
+#define PUCAN_TSLOW_BRP(b)		((b) & PUCAN_TSLOW_BRP_MASK)
 
 struct __packed pucan_timing_slow {
 	__le16	opcode_channel;
@@ -60,11 +71,21 @@ struct __packed pucan_timing_slow {
 	__le16	brp;		/* BaudRate Prescaler */
 };
 
+#define PUCAN_TFAST_BRP_BITS		10
+#define PUCAN_TFAST_TSGEG1_BITS		5
+#define PUCAN_TFAST_TSGEG2_BITS		4
+#define PUCAN_TFAST_SJW_BITS		4
+
+#define PUCAN_TFAST_BRP_MASK		((1 << PUCAN_TFAST_BRP_BITS) - 1)
+#define PUCAN_TFAST_TSEG1_MASK		((1 << PUCAN_TFAST_TSGEG1_BITS) - 1)
+#define PUCAN_TFAST_TSEG2_MASK		((1 << PUCAN_TFAST_TSGEG2_BITS) - 1)
+#define PUCAN_TFAST_SJW_MASK		((1 << PUCAN_TFAST_SJW_BITS) - 1)
+
 /* uCAN TIMING_FAST command fields */
-#define PUCAN_TFAST_SJW(s)		((s) & 0x3)
-#define PUCAN_TFAST_TSEG2(t)		((t) & 0x7)
-#define PUCAN_TFAST_TSEG1(t)		((t) & 0xf)
-#define PUCAN_TFAST_BRP(b)		((b) & 0x3ff)
+#define PUCAN_TFAST_SJW(s)		((s) & PUCAN_TFAST_SJW_MASK)
+#define PUCAN_TFAST_TSEG2(t)		((t) & PUCAN_TFAST_TSEG2_MASK)
+#define PUCAN_TFAST_TSEG1(t)		((t) & PUCAN_TFAST_TSEG1_MASK)
+#define PUCAN_TFAST_BRP(b)		((b) & PUCAN_TFAST_BRP_MASK)
 
 struct __packed pucan_timing_fast {
 	__le16	opcode_channel;
diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_fd.c b/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
index ce44a033f63b..8a316a194cf7 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
@@ -993,24 +993,24 @@ static void pcan_usb_fd_free(struct peak_usb_device *dev)
 static const struct can_bittiming_const pcan_usb_fd_const = {
 	.name = "pcan_usb_fd",
 	.tseg1_min = 1,
-	.tseg1_max = 64,
+	.tseg1_max = (1 << PUCAN_TSLOW_TSGEG1_BITS),
 	.tseg2_min = 1,
-	.tseg2_max = 16,
-	.sjw_max = 16,
+	.tseg2_max = (1 << PUCAN_TSLOW_TSGEG2_BITS),
+	.sjw_max = (1 << PUCAN_TSLOW_SJW_BITS),
 	.brp_min = 1,
-	.brp_max = 1024,
+	.brp_max = (1 << PUCAN_TSLOW_BRP_BITS),
 	.brp_inc = 1,
 };
 
 static const struct can_bittiming_const pcan_usb_fd_data_const = {
 	.name = "pcan_usb_fd",
 	.tseg1_min = 1,
-	.tseg1_max = 16,
+	.tseg1_max = (1 << PUCAN_TFAST_TSGEG1_BITS),
 	.tseg2_min = 1,
-	.tseg2_max = 8,
-	.sjw_max = 4,
+	.tseg2_max = (1 << PUCAN_TFAST_TSGEG2_BITS),
+	.sjw_max = (1 << PUCAN_TFAST_SJW_BITS),
 	.brp_min = 1,
-	.brp_max = 1024,
+	.brp_max = (1 << PUCAN_TFAST_BRP_BITS),
 	.brp_inc = 1,
 };
 
@@ -1065,24 +1065,24 @@ const struct peak_usb_adapter pcan_usb_fd = {
 static const struct can_bittiming_const pcan_usb_pro_fd_const = {
 	.name = "pcan_usb_pro_fd",
 	.tseg1_min = 1,
-	.tseg1_max = 64,
+	.tseg1_max = (1 << PUCAN_TSLOW_TSGEG1_BITS),
 	.tseg2_min = 1,
-	.tseg2_max = 16,
-	.sjw_max = 16,
+	.tseg2_max = (1 << PUCAN_TSLOW_TSGEG2_BITS),
+	.sjw_max = (1 << PUCAN_TSLOW_SJW_BITS),
 	.brp_min = 1,
-	.brp_max = 1024,
+	.brp_max = (1 << PUCAN_TSLOW_BRP_BITS),
 	.brp_inc = 1,
 };
 
 static const struct can_bittiming_const pcan_usb_pro_fd_data_const = {
 	.name = "pcan_usb_pro_fd",
 	.tseg1_min = 1,
-	.tseg1_max = 16,
+	.tseg1_max = (1 << PUCAN_TFAST_TSGEG1_BITS),
 	.tseg2_min = 1,
-	.tseg2_max = 8,
-	.sjw_max = 4,
+	.tseg2_max = (1 << PUCAN_TFAST_TSGEG2_BITS),
+	.sjw_max = (1 << PUCAN_TFAST_SJW_BITS),
 	.brp_min = 1,
-	.brp_max = 1024,
+	.brp_max = (1 << PUCAN_TFAST_BRP_BITS),
 	.brp_inc = 1,
 };
 
-- 
2.10.2
