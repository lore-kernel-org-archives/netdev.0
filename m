From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 05/11] vxge: add support for ethtool firmware flashing
Date: Thu, 28 Oct 2010 21:19:40 -0500
Message-ID: <1288318786-12319-5-git-send-email-jon.mason@exar.com>
References: <1288318786-12319-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:38349 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759857Ab0J2CUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 22:20:08 -0400
Received: by mail-yw0-f46.google.com with SMTP id 9so1727254ywk.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 19:20:07 -0700 (PDT)
In-Reply-To: <1288318786-12319-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ability in the vxge driver to flash firmware via ethtool.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-config.c  |  185 +++++++++++++++++++++++++++++++++
 drivers/net/vxge/vxge-config.h  |   71 +++++++++++++-
 drivers/net/vxge/vxge-ethtool.c |   38 +++++--
 drivers/net/vxge/vxge-main.c    |  213 +++++++++++++++++++++++++++++++++------
 drivers/net/vxge/vxge-main.h    |    4 +
 drivers/net/vxge/vxge-reg.h     |   30 +++++-
 drivers/net/vxge/vxge-version.h |   27 +++++
 7 files changed, 521 insertions(+), 47 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index e84d787..4a166a3 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -169,6 +169,191 @@ out:
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
+	int ret_code, sec_code, i;
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
+		data0 = data1 = steer_ctrl = 0;
+
+		/* send 16 bytes at a time */
+		for (i = 0; i < VXGE_HW_BYTES_PER_U64; i++) {
+			data0 |= (u64)fwdata[i] << (i * VXGE_HW_BYTES_PER_U64);
+			data1 |= (u64)fwdata[VXGE_HW_BYTES_PER_U64 + i] <<
+				 (i * VXGE_HW_BYTES_PER_U64);
+		}
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
index 2337665..3859d59 100644
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
@@ -2227,7 +2277,22 @@ __vxge_hw_device_is_privilaged(u32 host_type, u32 func_id);
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
index 6194fd9..c5ab375 100644
--- a/drivers/net/vxge/vxge-ethtool.c
+++ b/drivers/net/vxge/vxge-ethtool.c
@@ -11,7 +11,7 @@
  *                 Virtualized Server Adapter.
  * Copyright(c) 2002-2010 Exar Corp.
  ******************************************************************************/
-#include<linux/ethtool.h>
+#include <linux/ethtool.h>
 #include <linux/slab.h>
 #include <linux/pci.h>
 #include <linux/etherdevice.h>
@@ -29,7 +29,6 @@
  * Return value:
  * 0 on success.
  */
-
 static int vxge_ethtool_sset(struct net_device *dev, struct ethtool_cmd *info)
 {
 	/* We currently only support 10Gb/FULL */
@@ -148,8 +147,7 @@ static void vxge_ethtool_gregs(struct net_device *dev,
 static int vxge_ethtool_idnic(struct net_device *dev, u32 data)
 {
 	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
-	struct __vxge_hw_device  *hldev = (struct __vxge_hw_device  *)
-			pci_get_drvdata(vdev->pdev);
+	struct __vxge_hw_device *hldev = vdev->devh;
 
 	vxge_hw_device_flick_link_led(hldev, VXGE_FLICKER_ON);
 	msleep_interruptible(data ? (data * HZ) : VXGE_MAX_FLICKER_TIME);
@@ -168,11 +166,10 @@ static int vxge_ethtool_idnic(struct net_device *dev, u32 data)
  *  void
  */
 static void vxge_ethtool_getpause_data(struct net_device *dev,
-					struct ethtool_pauseparam *ep)
+				       struct ethtool_pauseparam *ep)
 {
 	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
-	struct __vxge_hw_device  *hldev = (struct __vxge_hw_device  *)
-			pci_get_drvdata(vdev->pdev);
+	struct __vxge_hw_device *hldev = vdev->devh;
 
 	vxge_hw_device_getpause_data(hldev, 0, &ep->tx_pause, &ep->rx_pause);
 }
@@ -188,11 +185,10 @@ static void vxge_ethtool_getpause_data(struct net_device *dev,
  * int, returns 0 on Success
  */
 static int vxge_ethtool_setpause_data(struct net_device *dev,
-					struct ethtool_pauseparam *ep)
+				      struct ethtool_pauseparam *ep)
 {
 	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
-	struct __vxge_hw_device  *hldev = (struct __vxge_hw_device  *)
-			pci_get_drvdata(vdev->pdev);
+	struct __vxge_hw_device *hldev = vdev->devh;
 
 	vxge_hw_device_setpause_data(hldev, 0, ep->tx_pause, ep->rx_pause);
 
@@ -211,7 +207,7 @@ static void vxge_get_ethtool_stats(struct net_device *dev,
 	struct vxge_vpath *vpath = NULL;
 
 	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
-	struct __vxge_hw_device  *hldev = vdev->devh;
+	struct __vxge_hw_device *hldev = vdev->devh;
 	struct vxge_hw_xmac_stats *xmac_stats;
 	struct vxge_hw_device_stats_sw_info *sw_stats;
 	struct vxge_hw_device_stats_hw_info *hw_stats;
@@ -1153,6 +1149,25 @@ static int vxge_set_flags(struct net_device *dev, u32 data)
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
+		return -EINVAL;
+	}
+
+	return vxge_fw_upgrade(vdev, parms->data, 1);
+}
+
 static const struct ethtool_ops vxge_ethtool_ops = {
 	.get_settings		= vxge_ethtool_gset,
 	.set_settings		= vxge_ethtool_sset,
@@ -1175,6 +1190,7 @@ static const struct ethtool_ops vxge_ethtool_ops = {
 	.get_sset_count		= vxge_ethtool_get_sset_count,
 	.get_ethtool_stats	= vxge_get_ethtool_stats,
 	.set_flags		= vxge_set_flags,
+	.flash_device		= vxge_fw_flash,
 };
 
 void initialize_ethtool_ops(struct net_device *ndev)
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index d977a63..52a48e7 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -50,6 +50,7 @@
 #include <net/ip.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/firmware.h>
 #include "vxge-main.h"
 #include "vxge-reg.h"
 
@@ -3237,6 +3238,7 @@ int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 		"%s: Ethernet device registered",
 		ndev->name);
 
+	hldev->ndev = ndev;
 	*vdev_out = vdev;
 
 	/* Resetting the Device stats */
@@ -3277,30 +3279,23 @@ vxge_device_unregister(struct __vxge_hw_device *hldev)
 	struct vxgedev *vdev;
 	struct net_device *dev;
 	char buf[IFNAMSIZ];
-#if ((VXGE_DEBUG_INIT & VXGE_DEBUG_MASK) || \
-	(VXGE_DEBUG_ENTRYEXIT & VXGE_DEBUG_MASK))
-	u32 level_trace;
-#endif
 
 	dev = hldev->ndev;
 	vdev = netdev_priv(dev);
-#if ((VXGE_DEBUG_INIT & VXGE_DEBUG_MASK) || \
-	(VXGE_DEBUG_ENTRYEXIT & VXGE_DEBUG_MASK))
-	level_trace = vdev->level_trace;
-#endif
-	vxge_debug_entryexit(level_trace,
-		"%s: %s:%d", vdev->ndev->name, __func__, __LINE__);
+	vxge_debug_entryexit(vdev->level_trace,	"%s: %s:%d", dev->name,
+			     __func__, __LINE__);
 
-	memcpy(buf, vdev->ndev->name, IFNAMSIZ);
+	memcpy(buf, dev->name, IFNAMSIZ);
 
 	/* in 2.6 will call stop() if device is up */
 	unregister_netdev(dev);
 
 	flush_scheduled_work();
 
-	vxge_debug_init(level_trace, "%s: ethernet device unregistered", buf);
-	vxge_debug_entryexit(level_trace,
-		"%s: %s:%d  Exiting...", buf, __func__, __LINE__);
+	vxge_debug_init(vdev->level_trace, "%s: ethernet device unregistered",
+			buf);
+	vxge_debug_entryexit(vdev->level_trace,	"%s: %s:%d  Exiting...", buf,
+			     __func__, __LINE__);
 }
 
 /*
@@ -3924,6 +3919,142 @@ static inline u32 vxge_get_num_vfs(u64 function_mode)
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
+		ret = -EFAULT;
+		goto out;
+	}
+
+	/* Read the version of the new firmware */
+	status = vxge_hw_upgrade_read_version(hldev, &maj, &min, &bld);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR,
+				"%s: Upgrade read version failed '%s'.",
+				VXGE_DRIVER_NAME, fw_name);
+		ret = -EFAULT;
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
+		ret = -EFAULT;
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
+		return -EFAULT;
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
@@ -3938,7 +4069,7 @@ static inline u32 vxge_get_num_vfs(u64 function_mode)
 static int __devinit
 vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 {
-	struct __vxge_hw_device  *hldev;
+	struct __vxge_hw_device *hldev;
 	enum vxge_hw_status status;
 	int ret;
 	int high_dma = 0;
@@ -4082,16 +4213,6 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
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
@@ -4155,6 +4276,32 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
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
@@ -4183,18 +4330,22 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
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
@@ -4296,7 +4447,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 				"%s: mac_addr_list : memory allocation failed",
 				vdev->ndev->name);
 			ret = -EPERM;
-			goto _exit5;
+			goto _exit6;
 		}
 		macaddr = (u8 *)&entry->macaddr;
 		memcpy(macaddr, vdev->ndev->dev_addr, ETH_ALEN);
@@ -4336,10 +4487,10 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
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
index 411732d..1e47319 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -451,7 +451,11 @@ enum vxge_hw_status vxge_restore_vpath_mac_addr(struct vxge_vpath *vpath);
 enum vxge_hw_status vxge_restore_vpath_vid_table(struct vxge_vpath *vpath);
 
 int do_vxge_close(struct net_device *dev, int do_io);
+
 extern void initialize_ethtool_ops(struct net_device *ndev);
+
+int vxge_fw_upgrade(struct vxgedev *vdev, char *fw_name, int override);
+
 /**
  * #define VXGE_DEBUG_INIT: debug for initialization functions
  * #define VXGE_DEBUG_TX	 : debug transmit related functions
diff --git a/drivers/net/vxge/vxge-reg.h b/drivers/net/vxge/vxge-reg.h
index 93fd752..f9ac574 100644
--- a/drivers/net/vxge/vxge-reg.h
+++ b/drivers/net/vxge/vxge-reg.h
@@ -49,6 +49,31 @@
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
+#define VXGE_HW_BYTES_PER_U64				8
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
@@ -165,13 +190,13 @@
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
@@ -437,6 +462,7 @@
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

