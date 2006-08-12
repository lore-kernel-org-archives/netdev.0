From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Firmware version vs bootcode version mismatch handling
Date: Sat, 12 Aug 2006 17:59:59 +0100 (BST)
Message-ID: <20060812165959.6C8858E776C@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:43788 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S932568AbWHLQ74 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 12:59:56 -0400
To: linville@tuxdriver.com
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is needed for my G220F, otherwise it fails to initialize after the
existing firmware upload routine.

The vendor driver actually does more than what I have done here: it
downloads the firmware + boot code, modifies it, and uploads it again
(really messy). I have not copied that part over, as my device can get
on its feet without it.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.h
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_chip.h
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -638,6 +638,7 @@ enum {
 	LOAD_CODE_SIZE			= 0xe, /* words */
 	LOAD_VECT_SIZE			= 0x10000 - 0xfff7, /* words */
 	EEPROM_REGS_OFFSET		= LOAD_CODE_SIZE + LOAD_VECT_SIZE,
+	EEPROM_REGS_SIZE		= 0x7e, /* words */
 	E2P_BASE_OFFSET			= EEPROM_START_OFFSET +
 		                          EEPROM_REGS_OFFSET,
 };
Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -16,6 +16,7 @@
  */
 
 #include <asm/unaligned.h>
+#include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/firmware.h>
@@ -269,6 +270,39 @@ static char *get_fw_name(char *buffer, s
 	return buffer;
 }
 
+static int handle_version_mismatch(struct usb_device *udev, u8 device_type,
+	const struct firmware *ub_fw)
+{
+	const struct firmware *ur_fw = NULL;
+	int offset;
+	int r = 0;
+	char fw_name[128];
+
+	r = request_fw_file(&ur_fw,
+		get_fw_name(fw_name, sizeof(fw_name), device_type, "ur"),
+		&udev->dev);
+	if (r)
+		goto error;
+
+	r = upload_code(udev, ur_fw->data, ur_fw->size, FW_START_OFFSET,
+		REBOOT);
+	if (r)
+		goto error;
+
+	offset = ((EEPROM_REGS_OFFSET + EEPROM_REGS_SIZE) * sizeof(u16));
+	r = upload_code(udev, ub_fw->data + offset, ub_fw->size - offset,
+		E2P_BASE_OFFSET + EEPROM_REGS_SIZE, REBOOT);
+
+	/* At this point, the vendor driver downloads the whole firmware
+	 * image, hacks around with version IDs, and uploads it again,
+	 * completely overwriting the boot code. We do not do this here as
+	 * it is not required on any tested devices, and it is suspected to
+	 * cause problems. */
+error:
+	release_firmware(ur_fw);
+	return r;
+}
+
 static int upload_firmware(struct usb_device *udev, u8 device_type)
 {
 	int r;
@@ -288,15 +322,17 @@ static int upload_firmware(struct usb_de
 
 	fw_bcdDevice = get_word(ub_fw->data, EEPROM_REGS_OFFSET);
 
-	/* FIXME: do we have any reason to perform the kludge that the vendor
-	 * driver does when there is a version mismatch? (their driver uploads
-	 * different firmwares and stuff)
-	 */
 	if (fw_bcdDevice != bcdDevice) {
 		dev_info(&udev->dev,
-			"firmware device id %#06x and actual device id "
-			"%#06x differ, continuing anyway\n",
-			fw_bcdDevice, bcdDevice);
+			"firmware version %#06x and device bootcode version "
+			"%#06x differ\n", fw_bcdDevice, bcdDevice);
+		if (bcdDevice <= 0x4313)
+			dev_warn(&udev->dev, "device has old bootcode, please "
+				"report success or failure\n");
+
+		r = handle_version_mismatch(udev, device_type, ub_fw);
+		if (r)
+			goto error;
 	} else {
 		dev_dbg_f(&udev->dev,
 			"firmware device id %#06x is equal to the "
