From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 4/7] can: peak_usb: rename usb option cmds definition and structs
Date: Sun, 22 Mar 2015 20:13:35 +0100
Message-ID: <1427051618-28318-5-git-send-email-mkl@pengutronix.de>
References: <1427051618-28318-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Stephane Grosjean <s.grosjean@peak-system.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1427051618-28318-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephane Grosjean <s.grosjean@peak-system.com>

The PUCAN_CMD_RX_FRAME_(ENABLE|DISABLE) command has extended its purpose
and was therefore renamed to PUCAN_CMD_SET_(EN|DIS)_OPTION.

Signed-off-by: Stephane Grosjean <s.grosjean@peak-system.com>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Tested-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/peak_usb/pcan_ucan.h   | 14 +++++-----
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c | 42 +++++++++++++++---------------
 2 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_ucan.h b/drivers/net/can/usb/peak_usb/pcan_ucan.h
index 1ba7c25002e1..1fb33307be4e 100644
--- a/drivers/net/can/usb/peak_usb/pcan_ucan.h
+++ b/drivers/net/can/usb/peak_usb/pcan_ucan.h
@@ -26,8 +26,8 @@
 #define PUCAN_CMD_FILTER_STD		0x008
 #define PUCAN_CMD_TX_ABORT		0x009
 #define PUCAN_CMD_WR_ERR_CNT		0x00a
-#define PUCAN_CMD_RX_FRAME_ENABLE	0x00b
-#define PUCAN_CMD_RX_FRAME_DISABLE	0x00c
+#define PUCAN_CMD_SET_EN_OPTION		0x00b
+#define PUCAN_CMD_CLR_DIS_OPTION	0x00c
 #define PUCAN_CMD_END_OF_COLLECTION	0x3ff
 
 /* uCAN received messages list */
@@ -101,14 +101,14 @@ struct __packed pucan_wr_err_cnt {
 	u16	unused;
 };
 
-/* uCAN RX_FRAME_ENABLE command fields */
-#define PUCAN_FLTEXT_ERROR		0x0001
-#define PUCAN_FLTEXT_BUSLOAD		0x0002
+/* uCAN SET_EN/CLR_DIS _OPTION command fields */
+#define PUCAN_OPTION_ERROR		0x0001
+#define PUCAN_OPTION_BUSLOAD		0x0002
 
-struct __packed pucan_filter_ext {
+struct __packed pucan_options {
 	__le16	opcode_channel;
 
-	__le16	ext_mask;
+	__le16	options;
 	u32	unused;
 };
 
diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_fd.c b/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
index 0bac0f14edc3..7506a8352edd 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
@@ -110,13 +110,13 @@ struct __packed pcan_ufd_led {
 	u8	unused[5];
 };
 
-/* Extended usage of uCAN commands CMD_RX_FRAME_xxxABLE for PCAN-USB Pro FD */
+/* Extended usage of uCAN commands CMD_xxx_xx_OPTION for PCAN-USB Pro FD */
 #define PCAN_UFD_FLTEXT_CALIBRATION	0x8000
 
-struct __packed pcan_ufd_filter_ext {
+struct __packed pcan_ufd_options {
 	__le16	opcode_channel;
 
-	__le16	ext_mask;
+	__le16	ucan_mask;
 	u16	unused;
 	__le16	usb_mask;
 };
@@ -321,21 +321,21 @@ static int pcan_usb_fd_set_filter_std(struct peak_usb_device *dev, int idx,
 	return pcan_usb_fd_send_cmd(dev, cmd);
 }
 
-/* set/unset notifications filter:
+/* set/unset options
  *
- *	onoff	sets(1)/unset(0) notifications
- *	mask	each bit defines a kind of notification to set/unset
+ *	onoff	set(1)/unset(0) options
+ *	mask	each bit defines a kind of options to set/unset
  */
-static int pcan_usb_fd_set_filter_ext(struct peak_usb_device *dev,
-				      bool onoff, u16 ext_mask, u16 usb_mask)
+static int pcan_usb_fd_set_options(struct peak_usb_device *dev,
+				   bool onoff, u16 ucan_mask, u16 usb_mask)
 {
-	struct pcan_ufd_filter_ext *cmd = pcan_usb_fd_cmd_buffer(dev);
+	struct pcan_ufd_options *cmd = pcan_usb_fd_cmd_buffer(dev);
 
 	cmd->opcode_channel = pucan_cmd_opcode_channel(dev,
-					(onoff) ? PUCAN_CMD_RX_FRAME_ENABLE :
-						  PUCAN_CMD_RX_FRAME_DISABLE);
+					(onoff) ? PUCAN_CMD_SET_EN_OPTION :
+						  PUCAN_CMD_CLR_DIS_OPTION);
 
-	cmd->ext_mask = cpu_to_le16(ext_mask);
+	cmd->ucan_mask = cpu_to_le16(ucan_mask);
 	cmd->usb_mask = cpu_to_le16(usb_mask);
 
 	/* send the command */
@@ -770,9 +770,9 @@ static int pcan_usb_fd_start(struct peak_usb_device *dev)
 				       &pcan_usb_pro_fd);
 
 		/* enable USB calibration messages */
-		err = pcan_usb_fd_set_filter_ext(dev, 1,
-						 PUCAN_FLTEXT_ERROR,
-						 PCAN_UFD_FLTEXT_CALIBRATION);
+		err = pcan_usb_fd_set_options(dev, 1,
+					      PUCAN_OPTION_ERROR,
+					      PCAN_UFD_FLTEXT_CALIBRATION);
 	}
 
 	pdev->usb_if->dev_opened_count++;
@@ -806,9 +806,9 @@ static int pcan_usb_fd_stop(struct peak_usb_device *dev)
 
 	/* turn off special msgs for that interface if no other dev opened */
 	if (pdev->usb_if->dev_opened_count == 1)
-		pcan_usb_fd_set_filter_ext(dev, 0,
-					   PUCAN_FLTEXT_ERROR,
-					   PCAN_UFD_FLTEXT_CALIBRATION);
+		pcan_usb_fd_set_options(dev, 0,
+					PUCAN_OPTION_ERROR,
+					PCAN_UFD_FLTEXT_CALIBRATION);
 	pdev->usb_if->dev_opened_count--;
 
 	return 0;
@@ -937,9 +937,9 @@ static void pcan_usb_fd_exit(struct peak_usb_device *dev)
 	if (dev->ctrl_idx == 0) {
 		/* turn off calibration message if any device were opened */
 		if (pdev->usb_if->dev_opened_count > 0)
-			pcan_usb_fd_set_filter_ext(dev, 0,
-						   PUCAN_FLTEXT_ERROR,
-						   PCAN_UFD_FLTEXT_CALIBRATION);
+			pcan_usb_fd_set_options(dev, 0,
+						PUCAN_OPTION_ERROR,
+						PCAN_UFD_FLTEXT_CALIBRATION);
 
 		/* tell USB adapter that the driver is being unloaded */
 		pcan_usb_fd_drv_loaded(dev, 0);
-- 
2.1.4

