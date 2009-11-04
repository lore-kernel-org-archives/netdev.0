From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/3 02/13] wimax/i6x50: add Intel WiFi/WiMAX Link 6050 Series support
Date: Wed,  4 Nov 2009 13:39:53 -0800
Message-ID: <7329012e673231dee9a21567cfb9881f5ea462ba.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Cc: Dirk Brandewie <dirk.j.brandewie@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20707 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932730AbZKDVmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:04 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dirk Brandewie <dirk.j.brandewie@intel.com>

Add support for the WiMAX device in the Intel WiFi/WiMAX Link 6050
Series; this involves:

 - adding the device ID to bind to and an endpoint mapping for the
   driver to use.

 - at probe() time, some things are set depending on the device id:

   + the list of firmware names to try

   + mapping of endpoints

Signed-off-by: Dirk Brandewie <dirk.j.brandewie@intel.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/fw.c         |    3 +++
 drivers/net/wimax/i2400m/i2400m-usb.h |    3 +++
 drivers/net/wimax/i2400m/usb.c        |   26 +++++++++++++++++++-------
 include/linux/wimax/i2400m.h          |    1 +
 4 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 84a39c3..5719f4a 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -277,6 +277,9 @@ int i2400m_barker_db_known_barkers(void)
 	result = i2400m_barker_db_add(I2400M_SBOOT_BARKER);
 	if (result < 0)
 		goto error_add;
+	result = i2400m_barker_db_add(I2400M_SBOOT_BARKER_6050);
+	if (result < 0)
+		goto error_add;
 error_add:
        return result;
 }
diff --git a/drivers/net/wimax/i2400m/i2400m-usb.h b/drivers/net/wimax/i2400m/i2400m-usb.h
index f73a067..5cc0f27 100644
--- a/drivers/net/wimax/i2400m/i2400m-usb.h
+++ b/drivers/net/wimax/i2400m/i2400m-usb.h
@@ -148,6 +148,9 @@ enum {
 	I2400MU_MAX_NOTIFICATION_LEN = 256,
 	I2400MU_BLK_SIZE = 16,
 	I2400MU_PL_SIZE_MAX = 0x3EFF,
+
+	/* Device IDs */
+	USB_DEVICE_ID_I6050 = 0x0186,
 };
 
 
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 0634222..77d08d9 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -80,11 +80,16 @@ MODULE_PARM_DESC(debug,
 		 "initial debug value to set.");
 
 /* Our firmware file name */
-static const char *i2400mu_bus_fw_names[] = {
+static const char *i2400mu_bus_fw_names_5x50[] = {
 #define I2400MU_FW_FILE_NAME_v1_4 "i2400m-fw-usb-1.4.sbcf"
 	I2400MU_FW_FILE_NAME_v1_4,
-#define I2400MU_FW_FILE_NAME_v1_3 "i2400m-fw-usb-1.3.sbcf"
-	I2400MU_FW_FILE_NAME_v1_3,
+	NULL,
+};
+
+
+static const char *i2400mu_bus_fw_names_6050[] = {
+#define I6050U_FW_FILE_NAME_v1_5 "i6050-fw-usb-1.5.sbcf"
+	I6050U_FW_FILE_NAME_v1_5,
 	NULL,
 };
 
@@ -418,10 +423,16 @@ int i2400mu_probe(struct usb_interface *iface,
 	i2400m->bus_bm_retries = I2400M_USB_BOOT_RETRIES;
 	i2400m->bus_bm_cmd_send = i2400mu_bus_bm_cmd_send;
 	i2400m->bus_bm_wait_for_ack = i2400mu_bus_bm_wait_for_ack;
-	i2400m->bus_fw_names = i2400mu_bus_fw_names;
 	i2400m->bus_bm_mac_addr_impaired = 0;
 
-	{
+	if (id->idProduct == USB_DEVICE_ID_I6050) {
+		i2400m->bus_fw_names = i2400mu_bus_fw_names_6050;
+		i2400mu->endpoint_cfg.bulk_out = 0;
+		i2400mu->endpoint_cfg.notification = 3;
+		i2400mu->endpoint_cfg.reset_cold = 2;
+		i2400mu->endpoint_cfg.bulk_in = 1;
+	} else {
+		i2400m->bus_fw_names = i2400mu_bus_fw_names_5x50;
 		i2400mu->endpoint_cfg.bulk_out = 0;
 		i2400mu->endpoint_cfg.notification = 1;
 		i2400mu->endpoint_cfg.reset_cold = 2;
@@ -614,6 +625,7 @@ out:
 
 static
 struct usb_device_id i2400mu_id_table[] = {
+	{ USB_DEVICE(0x8086, USB_DEVICE_ID_I6050) },
 	{ USB_DEVICE(0x8086, 0x0181) },
 	{ USB_DEVICE(0x8086, 0x1403) },
 	{ USB_DEVICE(0x8086, 0x1405) },
@@ -656,7 +668,7 @@ void __exit i2400mu_driver_exit(void)
 module_exit(i2400mu_driver_exit);
 
 MODULE_AUTHOR("Intel Corporation <linux-wimax@intel.com>");
-MODULE_DESCRIPTION("Intel 2400M WiMAX networking for USB");
+MODULE_DESCRIPTION("Driver for USB based Intel Wireless WiMAX Connection 2400M "
+		   "(5x50 & 6050)");
 MODULE_LICENSE("GPL");
 MODULE_FIRMWARE(I2400MU_FW_FILE_NAME_v1_4);
-MODULE_FIRMWARE(I2400MU_FW_FILE_NAME_v1_3);
diff --git a/include/linux/wimax/i2400m.h b/include/linux/wimax/i2400m.h
index fd5af05..62d3561 100644
--- a/include/linux/wimax/i2400m.h
+++ b/include/linux/wimax/i2400m.h
@@ -266,6 +266,7 @@ enum {
 	I2400M_WARM_RESET_BARKER = 0x50f750f7,
 	I2400M_NBOOT_BARKER = 0xdeadbeef,
 	I2400M_SBOOT_BARKER = 0x0ff1c1a1,
+	I2400M_SBOOT_BARKER_6050 = 0x80000001,
 	I2400M_ACK_BARKER = 0xfeedbabe,
 	I2400M_D2H_MSG_BARKER = 0xbeefbabe,
 };
-- 
1.6.2.5

