From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 5/7] can: peak_usb_fd: add support for ISO / non-ISO mode switching
Date: Sun, 22 Mar 2015 20:13:36 +0100
Message-ID: <1427051618-28318-6-git-send-email-mkl@pengutronix.de>
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

The PCAN USB (pro) FD adapters with firmware versions > 2.x support the
switching between ISO (default) and non-ISO conform bitstreams on the CAN bus.
The setting for the 2.x firmware adapters can be modified with the 'ip' tool
from the iproute2 package (option: fd-non-iso [on|off]).

Signed-off-by: Stephane Grosjean <s.grosjean@peak-system.com>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Tested-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/peak_usb/pcan_ucan.h   |  1 +
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c | 31 ++++++++++++++++++++++++++++--
 2 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_ucan.h b/drivers/net/can/usb/peak_usb/pcan_ucan.h
index 1fb33307be4e..e8fc4952c6b0 100644
--- a/drivers/net/can/usb/peak_usb/pcan_ucan.h
+++ b/drivers/net/can/usb/peak_usb/pcan_ucan.h
@@ -104,6 +104,7 @@ struct __packed pucan_wr_err_cnt {
 /* uCAN SET_EN/CLR_DIS _OPTION command fields */
 #define PUCAN_OPTION_ERROR		0x0001
 #define PUCAN_OPTION_BUSLOAD		0x0002
+#define PUCAN_OPTION_CANDFDISO		0x0004
 
 struct __packed pucan_options {
 	__le16	opcode_channel;
diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_fd.c b/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
index 7506a8352edd..a9221ad9f1a0 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_fd.c
@@ -251,6 +251,27 @@ static int pcan_usb_fd_build_restart_cmd(struct peak_usb_device *dev, u8 *buf)
 	/* moves the pointer forward */
 	pc += sizeof(struct pucan_wr_err_cnt);
 
+	/* add command to switch from ISO to non-ISO mode, if fw allows it */
+	if (dev->can.ctrlmode_supported & CAN_CTRLMODE_FD_NON_ISO) {
+		struct pucan_options *puo = (struct pucan_options *)pc;
+
+		puo->opcode_channel =
+			(dev->can.ctrlmode & CAN_CTRLMODE_FD_NON_ISO) ?
+			pucan_cmd_opcode_channel(dev,
+						 PUCAN_CMD_CLR_DIS_OPTION) :
+			pucan_cmd_opcode_channel(dev, PUCAN_CMD_SET_EN_OPTION);
+
+		puo->options = cpu_to_le16(PUCAN_OPTION_CANDFDISO);
+
+		/* to be sure that no other extended bits will be taken into
+		 * account
+		 */
+		puo->unused = 0;
+
+		/* moves the pointer forward */
+		pc += sizeof(struct pucan_options);
+	}
+
 	/* next, go back to operational mode */
 	cmd = (struct pucan_command *)pc;
 	cmd->opcode_channel = pucan_cmd_opcode_channel(dev,
@@ -860,8 +881,14 @@ static int pcan_usb_fd_init(struct peak_usb_device *dev)
 			 pdev->usb_if->fw_info.fw_version[2],
 			 dev->adapter->ctrl_count);
 
-		/* the currently supported hw is non-ISO */
-		dev->can.ctrlmode = CAN_CTRLMODE_FD_NON_ISO;
+		/* check for ability to switch between ISO/non-ISO modes */
+		if (pdev->usb_if->fw_info.fw_version[0] >= 2) {
+			/* firmware >= 2.x supports ISO/non-ISO switching */
+			dev->can.ctrlmode_supported |= CAN_CTRLMODE_FD_NON_ISO;
+		} else {
+			/* firmware < 2.x only supports fixed(!) non-ISO */
+			dev->can.ctrlmode |= CAN_CTRLMODE_FD_NON_ISO;
+		}
 
 		/* tell the hardware the can driver is running */
 		err = pcan_usb_fd_drv_loaded(dev, 1);
-- 
2.1.4

