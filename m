From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 05/12] vxge: add support for ethtool firmware flashing
Date: Thu, 11 Nov 2010 08:25:57 -0600
Message-ID: <1289485564-8822-6-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:45298 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755973Ab0KKO06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 09:26:58 -0500
Received: by mail-yx0-f174.google.com with SMTP id 8so34940yxk.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 06:26:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ability in the vxge driver to flash firmware via ethtool.

Updated to include comments from Ben Hutchings.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-config.c  |  183 +++++++++++++++++++++++++++++++++++++-
 drivers/net/vxge/vxge-config.h  |   71 ++++++++++++++-
 drivers/net/vxge/vxge-ethtool.c |   20 ++++
 drivers/net/vxge/vxge-main.c    |  190 +++++++++++++++++++++++++++++++++++----
 drivers/net/vxge/vxge-main.h    |    2 +
 drivers/net/vxge/vxge-reg.h     |   29 ++++++-
 drivers/net/vxge/vxge-version.h |   27 ++++++
 7 files changed, 500 insertions(+), 22 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index c822463..7761b9e 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -155,7 +155,6 @@ __vxge_hw_vpath_reset_check(struct __vxge_hw_virtualpath *vpath);
 static enum vxge_hw_status
 __vxge_hw_vpath_sw_reset(struct __vxge_hw_device *devh, u32 vp_id);
 
-
 static enum vxge_hw_status
 __vxge_hw_vpath_mac_configure(struct __vxge_hw_device *devh, u32 vp_id);
 
@@ -322,6 +321,188 @@ out:
 	return status;
 }
 
+enum vxge_hw_status
+vxge_hw_upgrade_read_version(struct __vxge_hw_device *hldev, u32 *major,
+			     u32 *minor, u32 *build)
+{
+	u64 data0 = 0, data1 = 0, steer_ctrl = 0;
+	struct __vxge_hw_virtualpath *vpath;
+	enum vxge_hw_status status;
+
+	vpath = &hldev->virtual_paths[hldev->first_vp_id];
+
+	status = vxge_hw_vpath_fw_api(vpath,
+				      VXGE_HW_FW_UPGRADE_ACTION,
+				      VXGE_HW_FW_UPGRADE_MEMO,
+				      VXGE_HW_FW_UPGRADE_OFFSET_READ,
+				      &data0, &data1, &steer_ctrl);
+	if (status != VXGE_HW_OK)
+		return status;
+
+	*major = VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_FW_VER_MAJOR(data0);
+	*minor = VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_FW_VER_MINOR(data0);
+	*build = VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_FW_VER_BUILD(data0);
+
+	return status;
+}
+
+enum vxge_hw_status vxge_hw_flash_fw(struct __vxge_hw_device *hldev)
+{
+	u64 data0 = 0, data1 = 0, steer_ctrl = 0;
+	struct __vxge_hw_virtualpath *vpath;
+	enum vxge_hw_status status;
+	u32 ret;
+
+	vpath = &hldev->virtual_paths[hldev->first_vp_id];
+
+	status = vxge_hw_vpath_fw_api(vpath,
+				      VXGE_HW_FW_UPGRADE_ACTION,
+				      VXGE_HW_FW_UPGRADE_MEMO,
+				      VXGE_HW_FW_UPGRADE_OFFSET_COMMIT,
+				      &data0, &data1, &steer_ctrl);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR, "%s: FW upgrade failed", __func__);
+		goto exit;
+	}
+
+	ret = VXGE_HW_RTS_ACCESS_STEER_CTRL_GET_ACTION(steer_ctrl) & 0x7F;
+	if (ret != 1) {
+		vxge_debug_init(VXGE_ERR, "%s: FW commit failed with error %d",
+				__func__, ret);
+		status = VXGE_HW_FAIL;
+	}
+
+exit:
+	return status;
+}
+
+enum vxge_hw_status
+vxge_update_fw_image(struct __vxge_hw_device *hldev, const u8 *fwdata, int size)
+{
+	u64 data0 = 0, data1 = 0, steer_ctrl = 0;
+	struct __vxge_hw_virtualpath *vpath;
+	enum vxge_hw_status status;
+	int ret_code, sec_code;
+
+	vpath = &hldev->virtual_paths[hldev->first_vp_id];
+
+	/* send upgrade start command */
+	status = vxge_hw_vpath_fw_api(vpath,
+				      VXGE_HW_FW_UPGRADE_ACTION,
+				      VXGE_HW_FW_UPGRADE_MEMO,
+				      VXGE_HW_FW_UPGRADE_OFFSET_START,
+				      &data0, &data1, &steer_ctrl);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR, " %s: Upgrade start cmd failed",
+				__func__);
+		return status;
+	}
+
+	/* Transfer fw image to adapter 16 bytes at a time */
+	for (; size > 0; size -= VXGE_HW_FW_UPGRADE_BLK_SIZE) {
+		steer_ctrl = 0;
+
+		/* The next 128bits of fwdata to be loaded onto the adapter */
+		data0 = *((u64 *)fwdata);
+		data1 = *((u64 *)fwdata + 1);
+
+		status = vxge_hw_vpath_fw_api(vpath,
+					      VXGE_HW_FW_UPGRADE_ACTION,
+					      VXGE_HW_FW_UPGRADE_MEMO,
+					      VXGE_HW_FW_UPGRADE_OFFSET_SEND,
+					      &data0, &data1, &steer_ctrl);
+		if (status != VXGE_HW_OK) {
+			vxge_debug_init(VXGE_ERR, "%s: Upgrade send failed",
+					__func__);
+			goto out;
+		}
+
+		ret_code = VXGE_HW_UPGRADE_GET_RET_ERR_CODE(data0);
+		switch (ret_code) {
+		case VXGE_HW_FW_UPGRADE_OK:
+			/* All OK, send next 16 bytes. */
+			break;
+		case VXGE_FW_UPGRADE_BYTES2SKIP:
+			/* skip bytes in the stream */
+			fwdata += (data0 >> 8) & 0xFFFFFFFF;
+			break;
+		case VXGE_HW_FW_UPGRADE_DONE:
+			goto out;
+		case VXGE_HW_FW_UPGRADE_ERR:
+			sec_code = VXGE_HW_UPGRADE_GET_SEC_ERR_CODE(data0);
+			switch (sec_code) {
+			case VXGE_HW_FW_UPGRADE_ERR_CORRUPT_DATA_1:
+			case VXGE_HW_FW_UPGRADE_ERR_CORRUPT_DATA_7:
+				printk(KERN_ERR
+				       "corrupted data from .ncf file\n");
+				break;
+			case VXGE_HW_FW_UPGRADE_ERR_INV_NCF_FILE_3:
+			case VXGE_HW_FW_UPGRADE_ERR_INV_NCF_FILE_4:
+			case VXGE_HW_FW_UPGRADE_ERR_INV_NCF_FILE_5:
+			case VXGE_HW_FW_UPGRADE_ERR_INV_NCF_FILE_6:
+			case VXGE_HW_FW_UPGRADE_ERR_INV_NCF_FILE_8:
+				printk(KERN_ERR "invalid .ncf file\n");
+				break;
+			case VXGE_HW_FW_UPGRADE_ERR_BUFFER_OVERFLOW:
+				printk(KERN_ERR "buffer overflow\n");
+				break;
+			case VXGE_HW_FW_UPGRADE_ERR_FAILED_TO_FLASH:
+				printk(KERN_ERR "failed to flash the image\n");
+				break;
+			case VXGE_HW_FW_UPGRADE_ERR_GENERIC_ERROR_UNKNOWN:
+				printk(KERN_ERR
+				       "generic error. Unknown error type\n");
+				break;
+			default:
+				printk(KERN_ERR "Unknown error of type %d\n",
+				       sec_code);
+				break;
+			}
+			status = VXGE_HW_FAIL;
+			goto out;
+		default:
+			printk(KERN_ERR "Unknown FW error: %d\n", ret_code);
+			status = VXGE_HW_FAIL;
+			goto out;
+		}
+		/* point to next 16 bytes */
+		fwdata += VXGE_HW_FW_UPGRADE_BLK_SIZE;
+	}
+out:
+	return status;
+}
+
+enum vxge_hw_status
+vxge_hw_vpath_eprom_img_ver_get(struct __vxge_hw_device *hldev,
+				struct eprom_image *img)
+{
+	u64 data0 = 0, data1 = 0, steer_ctrl = 0;
+	struct __vxge_hw_virtualpath *vpath;
+	enum vxge_hw_status status;
+	int i;
+
+	vpath = &hldev->virtual_paths[hldev->first_vp_id];
+
+	for (i = 0; i < VXGE_HW_MAX_ROM_IMAGES; i++) {
+		data0 = VXGE_HW_RTS_ACCESS_STEER_ROM_IMAGE_INDEX(i);
+		data1 = steer_ctrl = 0;
+
+		status = vxge_hw_vpath_fw_api(vpath,
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_FW_MEMO,
+			VXGE_HW_FW_API_GET_EPROM_REV,
+			0, &data0, &data1, &steer_ctrl);
+		if (status != VXGE_HW_OK)
+			break;
+
+		img[i].is_valid = VXGE_HW_GET_EPROM_IMAGE_VALID(data0);
+		img[i].index = VXGE_HW_GET_EPROM_IMAGE_INDEX(data0);
+		img[i].type = VXGE_HW_GET_EPROM_IMAGE_TYPE(data0);
+		img[i].version = VXGE_HW_GET_EPROM_IMAGE_REV(data0);
+	}
+
+	return status;
+}
+
 /*
  * __vxge_hw_channel_allocate - Allocate memory for channel
  * This function allocates required memory for the channel and various arrays
diff --git a/drivers/net/vxge/vxge-config.h b/drivers/net/vxge/vxge-config.h
index 6a81014..95230bd 100644
--- a/drivers/net/vxge/vxge-config.h
+++ b/drivers/net/vxge/vxge-config.h
@@ -29,6 +29,15 @@
 #define VXGE_HW_MAX_MTU				9600
 #define VXGE_HW_DEFAULT_MTU			1500
 
+#define VXGE_HW_MAX_ROM_IMAGES			8
+
+struct eprom_image {
+	u8 is_valid:1;
+	u8 index;
+	u8 type;
+	u16 version;
+};
+
 #ifdef VXGE_DEBUG_ASSERT
 /**
  * vxge_assert
@@ -148,6 +157,47 @@ enum vxge_hw_device_link_state {
 };
 
 /**
+ * enum enum vxge_hw_fw_upgrade_code - FW upgrade return codes.
+ * @VXGE_HW_FW_UPGRADE_OK: All OK send next 16 bytes
+ * @VXGE_HW_FW_UPGRADE_DONE:  upload completed
+ * @VXGE_HW_FW_UPGRADE_ERR:  upload error
+ * @VXGE_FW_UPGRADE_BYTES2SKIP:  skip bytes in the stream
+ *
+ */
+enum vxge_hw_fw_upgrade_code {
+	VXGE_HW_FW_UPGRADE_OK		= 0,
+	VXGE_HW_FW_UPGRADE_DONE		= 1,
+	VXGE_HW_FW_UPGRADE_ERR		= 2,
+	VXGE_FW_UPGRADE_BYTES2SKIP	= 3
+};
+
+/**
+ * enum enum vxge_hw_fw_upgrade_err_code - FW upgrade error codes.
+ * @VXGE_HW_FW_UPGRADE_ERR_CORRUPT_DATA_1: corrupt data
+ * @VXGE_HW_FW_UPGRADE_ERR_BUFFER_OVERFLOW: buffer overflow
+ * @VXGE_HW_FW_UPGRADE_ERR_INV_NCF_FILE_3: invalid .ncf file
+ * @VXGE_HW_FW_UPGRADE_ERR_INV_NCF_FILE_4: invalid .ncf file
+ * @VXGE_HW_FW_UPGRADE_ERR_INV_NCF_FILE_5: invalid .ncf file
+ * @VXGE_HW_FW_UPGRADE_ERR_INV_NCF_FILE_6: invalid .ncf file
+ * @VXGE_HW_FW_UPGRADE_ERR_CORRUPT_DATA_7: corrupt data
+ * @VXGE_HW_FW_UPGRADE_ERR_INV_NCF_FILE_8: invalid .ncf file
+ * @VXGE_HW_FW_UPGRADE_ERR_GENERIC_ERROR_UNKNOWN: generic error unknown type
+ * @VXGE_HW_FW_UPGRADE_ERR_FAILED_TO_FLASH: failed to flash image check failed
+ */
+enum vxge_hw_fw_upgrade_err_code {
+	VXGE_HW_FW_UPGRADE_ERR_CORRUPT_DATA_1		= 1,
+	VXGE_HW_FW_UPGRADE_ERR_BUFFER_OVERFLOW		= 2,
+	VXGE_HW_FW_UPGRADE_ERR_INV_NCF_FILE_3		= 3,
+	VXGE_HW_FW_UPGRADE_ERR_INV_NCF_FILE_4		= 4,
+	VXGE_HW_FW_UPGRADE_ERR_INV_NCF_FILE_5		= 5,
+	VXGE_HW_FW_UPGRADE_ERR_INV_NCF_FILE_6		= 6,
+	VXGE_HW_FW_UPGRADE_ERR_CORRUPT_DATA_7		= 7,
+	VXGE_HW_FW_UPGRADE_ERR_INV_NCF_FILE_8		= 8,
+	VXGE_HW_FW_UPGRADE_ERR_GENERIC_ERROR_UNKNOWN	= 9,
+	VXGE_HW_FW_UPGRADE_ERR_FAILED_TO_FLASH		= 10
+};
+
+/**
  * struct vxge_hw_device_date - Date Format
  * @day: Day
  * @month: Month
@@ -454,7 +504,6 @@ struct vxge_hw_device_config {
  * See also: vxge_hw_driver_initialize().
  */
 struct vxge_hw_uld_cbs {
-
 	void (*link_up)(struct __vxge_hw_device *devh);
 	void (*link_down)(struct __vxge_hw_device *devh);
 	void (*crit_err)(struct __vxge_hw_device *devh,
@@ -721,6 +770,7 @@ struct __vxge_hw_device {
 	u32				debug_level;
 	u32				level_err;
 	u32				level_trace;
+	u16 eprom_versions[VXGE_HW_MAX_ROM_IMAGES];
 };
 
 #define VXGE_HW_INFO_LEN	64
@@ -2032,7 +2082,22 @@ __vxge_hw_device_is_privilaged(u32 host_type, u32 func_id);
 #define VXGE_HW_MIN_SUCCESSIVE_IDLE_COUNT 5
 #define VXGE_HW_MAX_POLLING_COUNT 100
 
-int vxge_hw_vpath_wait_receive_idle(struct __vxge_hw_device *hldev, u32 vp_id);
+void
+vxge_hw_device_wait_receive_idle(struct __vxge_hw_device *hldev);
+
+enum vxge_hw_status
+vxge_hw_upgrade_read_version(struct __vxge_hw_device *hldev, u32 *major,
+			     u32 *minor, u32 *build);
+
+enum vxge_hw_status vxge_hw_flash_fw(struct __vxge_hw_device *hldev);
 
-void  vxge_hw_device_wait_receive_idle(struct __vxge_hw_device *hldev);
+enum vxge_hw_status
+vxge_update_fw_image(struct __vxge_hw_device *hldev, const u8 *filebuf,
+		     int size);
+
+enum vxge_hw_status
+vxge_hw_vpath_eprom_img_ver_get(struct __vxge_hw_device *hldev,
+				struct eprom_image *eprom_image_data);
+
+int vxge_hw_vpath_wait_receive_idle(struct __vxge_hw_device *hldev, u32 vp_id);
 #endif
diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/vxge-ethtool.c
index f8fd8da..3d2cd6a 100644
--- a/drivers/net/vxge/vxge-ethtool.c
+++ b/drivers/net/vxge/vxge-ethtool.c
@@ -1153,6 +1153,25 @@ static int vxge_set_flags(struct net_device *dev, u32 data)
 	return 0;
 }
 
+static int vxge_fw_flash(struct net_device *dev, struct ethtool_flash *parms)
+{
+	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
+
+	if (vdev->max_vpath_supported != VXGE_HW_MAX_VIRTUAL_PATHS) {
+		printk(KERN_INFO "Single Function Mode is required to flash the"
+		       " firmware\n");
+		return -EINVAL;
+	}
+
+	if (netif_running(dev)) {
+		printk(KERN_INFO "Interface %s must be down to flash the "
+		       "firmware\n", dev->name);
+		return -EBUSY;
+	}
+
+	return vxge_fw_upgrade(vdev, parms->data, 1);
+}
+
 static const struct ethtool_ops vxge_ethtool_ops = {
 	.get_settings		= vxge_ethtool_gset,
 	.set_settings		= vxge_ethtool_sset,
@@ -1175,6 +1194,7 @@ static const struct ethtool_ops vxge_ethtool_ops = {
 	.get_sset_count		= vxge_ethtool_get_sset_count,
 	.get_ethtool_stats	= vxge_get_ethtool_stats,
 	.set_flags		= vxge_set_flags,
+	.flash_device		= vxge_fw_flash,
 };
 
 void vxge_initialize_ethtool_ops(struct net_device *ndev)
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 53db6a4..10549bd 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -50,6 +50,7 @@
 #include <net/ip.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/firmware.h>
 #include "vxge-main.h"
 #include "vxge-reg.h"
 
@@ -3248,6 +3249,7 @@ static int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 		"%s: Ethernet device registered",
 		ndev->name);
 
+	hldev->ndev = ndev;
 	*vdev_out = vdev;
 
 	/* Resetting the Device stats */
@@ -3935,6 +3937,142 @@ static inline u32 vxge_get_num_vfs(u64 function_mode)
 	return num_functions;
 }
 
+int vxge_fw_upgrade(struct vxgedev *vdev, char *fw_name, int override)
+{
+	struct __vxge_hw_device *hldev = vdev->devh;
+	u32 maj, min, bld, cmaj, cmin, cbld;
+	enum vxge_hw_status status;
+	const struct firmware *fw;
+	int ret;
+
+	ret = request_firmware(&fw, fw_name, &vdev->pdev->dev);
+	if (ret) {
+		vxge_debug_init(VXGE_ERR, "%s: Firmware file '%s' not found",
+				VXGE_DRIVER_NAME, fw_name);
+		goto out;
+	}
+
+	/* Load the new firmware onto the adapter */
+	status = vxge_update_fw_image(hldev, fw->data, fw->size);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR,
+				"%s: FW image download to adapter failed '%s'.",
+				VXGE_DRIVER_NAME, fw_name);
+		ret = -EIO;
+		goto out;
+	}
+
+	/* Read the version of the new firmware */
+	status = vxge_hw_upgrade_read_version(hldev, &maj, &min, &bld);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR,
+				"%s: Upgrade read version failed '%s'.",
+				VXGE_DRIVER_NAME, fw_name);
+		ret = -EIO;
+		goto out;
+	}
+
+	cmaj = vdev->config.device_hw_info.fw_version.major;
+	cmin = vdev->config.device_hw_info.fw_version.minor;
+	cbld = vdev->config.device_hw_info.fw_version.build;
+	/* It's possible the version in /lib/firmware is not the latest version.
+	 * If so, we could get into a loop of trying to upgrade to the latest
+	 * and flashing the older version.
+	 */
+	if (VXGE_FW_VER(maj, min, bld) == VXGE_FW_VER(cmaj, cmin, cbld) &&
+	    !override) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	printk(KERN_NOTICE "Upgrade to firmware version %d.%d.%d commencing\n",
+	       maj, min, bld);
+
+	/* Flash the adapter with the new firmware */
+	status = vxge_hw_flash_fw(hldev);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR, "%s: Upgrade commit failed '%s'.",
+				VXGE_DRIVER_NAME, fw_name);
+		ret = -EIO;
+		goto out;
+	}
+
+	printk(KERN_NOTICE "Upgrade of firmware successful!  Adapter must be "
+	       "hard reset before using, thus requiring a system reboot or a "
+	       "hotplug event.\n");
+
+out:
+	return ret;
+}
+
+static int vxge_probe_fw_update(struct vxgedev *vdev)
+{
+	u32 maj, min, bld;
+	int ret, gpxe = 0;
+	char *fw_name;
+
+	maj = vdev->config.device_hw_info.fw_version.major;
+	min = vdev->config.device_hw_info.fw_version.minor;
+	bld = vdev->config.device_hw_info.fw_version.build;
+
+	if (VXGE_FW_VER(maj, min, bld) == VXGE_CERT_FW_VER)
+		return 0;
+
+	/* Ignore the build number when determining if the current firmware is
+	 * "too new" to load the driver
+	 */
+	if (VXGE_FW_VER(maj, min, 0) > VXGE_CERT_FW_VER) {
+		vxge_debug_init(VXGE_ERR, "%s: Firmware newer than last known "
+				"version, unable to load driver\n",
+				VXGE_DRIVER_NAME);
+		return -EINVAL;
+	}
+
+	/* Firmware 1.4.4 and older cannot be upgraded, and is too ancient to
+	 * work with this driver.
+	 */
+	if (VXGE_FW_VER(maj, min, bld) <= VXGE_FW_DEAD_VER) {
+		vxge_debug_init(VXGE_ERR, "%s: Firmware %d.%d.%d cannot be "
+				"upgraded\n", VXGE_DRIVER_NAME, maj, min, bld);
+		return -EINVAL;
+	}
+
+	/* If file not specified, determine gPXE or not */
+	if (VXGE_FW_VER(maj, min, bld) >= VXGE_EPROM_FW_VER) {
+		int i;
+		for (i = 0; i < VXGE_HW_MAX_ROM_IMAGES; i++)
+			if (vdev->devh->eprom_versions[i]) {
+				gpxe = 1;
+				break;
+			}
+	}
+	if (gpxe)
+		fw_name = "vxge/X3fw-pxe.ncf";
+	else
+		fw_name = "vxge/X3fw.ncf";
+
+	ret = vxge_fw_upgrade(vdev, fw_name, 0);
+	/* -EINVAL and -ENOENT are not fatal errors for flashing firmware on
+	 * probe, so ignore them
+	 */
+	if (ret != -EINVAL && ret != -ENOENT)
+		return -EIO;
+	else
+		ret = 0;
+
+	if (VXGE_FW_VER(VXGE_CERT_FW_VER_MAJOR, VXGE_CERT_FW_VER_MINOR, 0) >
+	    VXGE_FW_VER(maj, min, 0)) {
+		vxge_debug_init(VXGE_ERR, "%s: Firmware %d.%d.%d is too old to"
+				" be used with this driver.\n"
+				"Please get the latest version from "
+				"ftp://ftp.s2io.com/pub/X3100-Drivers/FIRMWARE",
+				VXGE_DRIVER_NAME, maj, min, bld);
+		return -EINVAL;
+	}
+
+	return ret;
+}
+
 /**
  * vxge_probe
  * @pdev : structure containing the PCI related information of the device.
@@ -4093,16 +4231,6 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 		goto _exit3;
 	}
 
-	if (ll_config->device_hw_info.fw_version.major !=
-		VXGE_DRIVER_FW_VERSION_MAJOR) {
-		vxge_debug_init(VXGE_ERR,
-			"%s: Incorrect firmware version."
-			"Please upgrade the firmware to version 1.x.x",
-			VXGE_DRIVER_NAME);
-		ret = -EINVAL;
-		goto _exit3;
-	}
-
 	vpath_mask = ll_config->device_hw_info.vpath_mask;
 	if (vpath_mask == 0) {
 		vxge_debug_ll_config(VXGE_TRACE,
@@ -4166,6 +4294,32 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 			goto _exit3;
 	}
 
+	if (VXGE_FW_VER(ll_config->device_hw_info.fw_version.major,
+			ll_config->device_hw_info.fw_version.minor,
+			ll_config->device_hw_info.fw_version.build) >=
+	    VXGE_EPROM_FW_VER) {
+		struct eprom_image img[VXGE_HW_MAX_ROM_IMAGES];
+
+		status = vxge_hw_vpath_eprom_img_ver_get(hldev, img);
+		if (status != VXGE_HW_OK) {
+			vxge_debug_init(VXGE_ERR, "%s: Reading of EPROM failed",
+					VXGE_DRIVER_NAME);
+			/* This is a non-fatal error, continue */
+		}
+
+		for (i = 0; i < VXGE_HW_MAX_ROM_IMAGES; i++) {
+			hldev->eprom_versions[i] = img[i].version;
+			if (!img[i].is_valid)
+				break;
+			vxge_debug_init(VXGE_TRACE, "%s: EPROM %d, version "
+					"%d.%d.%d.%d\n", VXGE_DRIVER_NAME, i,
+					VXGE_EPROM_IMG_MAJOR(img[i].version),
+					VXGE_EPROM_IMG_MINOR(img[i].version),
+					VXGE_EPROM_IMG_FIX(img[i].version),
+					VXGE_EPROM_IMG_BUILD(img[i].version));
+		}
+	}
+
 	/* if FCS stripping is not disabled in MAC fail driver load */
 	if (vxge_hw_vpath_strip_fcs_check(hldev, vpath_mask) != VXGE_HW_OK) {
 		vxge_debug_init(VXGE_ERR,
@@ -4194,18 +4348,22 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 	ll_config->tx_pause_enable = VXGE_PAUSE_CTRL_ENABLE;
 	ll_config->rx_pause_enable = VXGE_PAUSE_CTRL_ENABLE;
 
-	if (vxge_device_register(hldev, ll_config, high_dma, no_of_vpath,
-		&vdev)) {
+	ret = vxge_device_register(hldev, ll_config, high_dma, no_of_vpath,
+				   &vdev);
+	if (ret) {
 		ret = -EINVAL;
 		goto _exit4;
 	}
 
+	ret = vxge_probe_fw_update(vdev);
+	if (ret)
+		goto _exit5;
+
 	vxge_hw_device_debug_set(hldev, VXGE_TRACE, VXGE_COMPONENT_LL);
 	VXGE_COPY_DEBUG_INFO_TO_LL(vdev, vxge_hw_device_error_level_get(hldev),
 		vxge_hw_device_trace_level_get(hldev));
 
 	/* set private HW device info */
-	hldev->ndev = vdev->ndev;
 	vdev->mtu = VXGE_HW_DEFAULT_MTU;
 	vdev->bar0 = attr.bar0;
 	vdev->max_vpath_supported = max_vpath_supported;
@@ -4307,7 +4465,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 				"%s: mac_addr_list : memory allocation failed",
 				vdev->ndev->name);
 			ret = -EPERM;
-			goto _exit5;
+			goto _exit6;
 		}
 		macaddr = (u8 *)&entry->macaddr;
 		memcpy(macaddr, vdev->ndev->dev_addr, ETH_ALEN);
@@ -4347,10 +4505,10 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 	kfree(ll_config);
 	return 0;
 
-_exit5:
+_exit6:
 	for (i = 0; i < vdev->no_of_vpath; i++)
 		vxge_free_mac_add_list(&vdev->vpaths[i]);
-
+_exit5:
 	vxge_device_unregister(hldev);
 _exit4:
 	pci_disable_sriov(pdev);
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
index 3845e62..1699d75 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -397,6 +397,8 @@ struct vxge_tx_priv {
 extern void vxge_initialize_ethtool_ops(struct net_device *ndev);
 enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev);
 
+int vxge_fw_upgrade(struct vxgedev *vdev, char *fw_name, int override);
+
 /**
  * #define VXGE_DEBUG_INIT: debug for initialization functions
  * #define VXGE_DEBUG_TX	 : debug transmit related functions
diff --git a/drivers/net/vxge/vxge-reg.h b/drivers/net/vxge/vxge-reg.h
index 93fd752..0df52db 100644
--- a/drivers/net/vxge/vxge-reg.h
+++ b/drivers/net/vxge/vxge-reg.h
@@ -49,6 +49,30 @@
 #define VXGE_HW_TITAN_VPMGMT_REG_SPACES			17
 #define VXGE_HW_TITAN_VPATH_REG_SPACES			17
 
+#define VXGE_HW_FW_API_GET_EPROM_REV			31
+
+#define VXGE_EPROM_IMG_MAJOR(val)		(u32) vxge_bVALn(val, 48, 4)
+#define VXGE_EPROM_IMG_MINOR(val)		(u32) vxge_bVALn(val, 52, 4)
+#define VXGE_EPROM_IMG_FIX(val)			(u32) vxge_bVALn(val, 56, 4)
+#define VXGE_EPROM_IMG_BUILD(val)		(u32) vxge_bVALn(val, 60, 4)
+
+#define VXGE_HW_GET_EPROM_IMAGE_INDEX(val)		vxge_bVALn(val, 16, 8)
+#define VXGE_HW_GET_EPROM_IMAGE_VALID(val)		vxge_bVALn(val, 31, 1)
+#define VXGE_HW_GET_EPROM_IMAGE_TYPE(val)		vxge_bVALn(val, 40, 8)
+#define VXGE_HW_GET_EPROM_IMAGE_REV(val)		vxge_bVALn(val, 48, 16)
+#define VXGE_HW_RTS_ACCESS_STEER_ROM_IMAGE_INDEX(val)	vxge_vBIT(val, 16, 8)
+
+#define VXGE_HW_FW_UPGRADE_MEMO				13
+#define VXGE_HW_FW_UPGRADE_ACTION			16
+#define VXGE_HW_FW_UPGRADE_OFFSET_START			2
+#define VXGE_HW_FW_UPGRADE_OFFSET_SEND			3
+#define VXGE_HW_FW_UPGRADE_OFFSET_COMMIT		4
+#define VXGE_HW_FW_UPGRADE_OFFSET_READ			5
+
+#define VXGE_HW_FW_UPGRADE_BLK_SIZE			16
+#define VXGE_HW_UPGRADE_GET_RET_ERR_CODE(val)		(val & 0xff)
+#define VXGE_HW_UPGRADE_GET_SEC_ERR_CODE(val)		((val >> 8) & 0xff)
+
 #define VXGE_HW_ASIC_MODE_RESERVED				0
 #define VXGE_HW_ASIC_MODE_NO_IOV				1
 #define VXGE_HW_ASIC_MODE_SR_IOV				2
@@ -165,13 +189,13 @@
 #define	VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_ETYPE		2
 #define	VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_PN		3
 #define	VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_RTH_GEN_CFG	5
-#define	VXGE_HW_RTS_ACS_STEER_CTRL_DATA_STRUCT_SEL_RTH_SOLO_IT	6
+#define	VXGE_HW_RTS_ACS_STEER_CTRL_DATA_STRUCT_SEL_RTH_SOLO_IT		6
 #define	VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_RTH_JHASH_CFG	7
 #define	VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_RTH_MASK		8
 #define	VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_RTH_KEY		9
 #define	VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_QOS		10
 #define	VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_DS		11
-#define	VXGE_HW_RTS_ACS_STEER_CTRL_DATA_STRUCT_SEL_RTH_MULTI_IT	12
+#define	VXGE_HW_RTS_ACS_STEER_CTRL_DATA_STRUCT_SEL_RTH_MULTI_IT		12
 #define	VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_FW_MEMO		13
 
 #define	VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_DA_MAC_ADDR(bits) \
@@ -437,6 +461,7 @@
 #define VXGE_HW_RTS_ACCESS_STEER_DATA1_GET_FLASH_VER_BUILD(bits) \
 							vxge_bVALn(bits, 48, 16)
 #define VXGE_HW_RTS_ACCESS_STEER_DATA1_FLASH_VER_BUILD vxge_vBIT(val, 48, 16)
+#define VXGE_HW_RTS_ACCESS_STEER_CTRL_GET_ACTION(bits) vxge_bVALn(bits, 0, 8)
 
 #define	VXGE_HW_SRPCIM_TO_VPATH_ALARM_REG_GET_PPIF_SRPCIM_TO_VPATH_ALARM(bits)\
 							vxge_bVALn(bits, 0, 18)
diff --git a/drivers/net/vxge/vxge-version.h b/drivers/net/vxge/vxge-version.h
index 53fefe1..b4eced1 100644
--- a/drivers/net/vxge/vxge-version.h
+++ b/drivers/net/vxge/vxge-version.h
@@ -19,4 +19,31 @@
 #define VXGE_VERSION_FIX	"9"
 #define VXGE_VERSION_BUILD	"20840"
 #define VXGE_VERSION_FOR	"k"
+
+#define VXGE_FW_VER(maj, min, bld) (((maj) << 16) + ((min) << 8) + (bld))
+
+#define VXGE_DEAD_FW_VER_MAJOR	1
+#define VXGE_DEAD_FW_VER_MINOR	4
+#define VXGE_DEAD_FW_VER_BUILD	4
+
+#define VXGE_FW_DEAD_VER VXGE_FW_VER(VXGE_DEAD_FW_VER_MAJOR, \
+				     VXGE_DEAD_FW_VER_MINOR, \
+				     VXGE_DEAD_FW_VER_BUILD)
+
+#define VXGE_EPROM_FW_VER_MAJOR	1
+#define VXGE_EPROM_FW_VER_MINOR	6
+#define VXGE_EPROM_FW_VER_BUILD	1
+
+#define VXGE_EPROM_FW_VER VXGE_FW_VER(VXGE_EPROM_FW_VER_MAJOR, \
+				      VXGE_EPROM_FW_VER_MINOR, \
+				      VXGE_EPROM_FW_VER_BUILD)
+
+#define VXGE_CERT_FW_VER_MAJOR	1
+#define VXGE_CERT_FW_VER_MINOR	8
+#define VXGE_CERT_FW_VER_BUILD	1
+
+#define VXGE_CERT_FW_VER VXGE_FW_VER(VXGE_CERT_FW_VER_MAJOR, \
+				     VXGE_CERT_FW_VER_MINOR, \
+				     VXGE_CERT_FW_VER_BUILD)
+
 #endif
-- 
1.7.0.4

