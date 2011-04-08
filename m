From: Jon Mason <jdmason@kudzu.us>
Subject: [net-next PATCH 1/3] vxge: always enable hardware time stamp
Date: Fri,  8 Apr 2011 16:11:21 -0500
Message-ID: <1302297083-22665-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:50924 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753401Ab1DHVL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 17:11:27 -0400
Received: by gwaa18 with SMTP id a18so1393272gwa.19
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2011 14:11:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardware time stamp calculation can only be enabled by the privileged
function. Enable it always by default and simply use the ethtool
interface to set a flag to indicate whether or not the respective
function driver should indicate the timestamp along with the received
packet.

Also, make certain fields in vxge_hw_device_config bit-fields to reduce
the size of the struct.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/vxge/vxge-config.h  |   70 ++++++++++++++++++++------------------
 drivers/net/vxge/vxge-main.c    |   43 ++++++++++++++---------
 drivers/net/vxge/vxge-traffic.h |    2 +-
 3 files changed, 64 insertions(+), 51 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.h b/drivers/net/vxge/vxge-config.h
index 3c53aa7..359b9b9 100644
--- a/drivers/net/vxge/vxge-config.h
+++ b/drivers/net/vxge/vxge-config.h
@@ -412,44 +412,48 @@ struct vxge_hw_vp_config {
  * See also: struct vxge_hw_tim_intr_config{}.
  */
 struct vxge_hw_device_config {
-	u32				dma_blockpool_initial;
-	u32				dma_blockpool_max;
-#define VXGE_HW_MIN_DMA_BLOCK_POOL_SIZE			0
-#define VXGE_HW_INITIAL_DMA_BLOCK_POOL_SIZE		0
-#define VXGE_HW_INCR_DMA_BLOCK_POOL_SIZE		4
-#define VXGE_HW_MAX_DMA_BLOCK_POOL_SIZE			4096
-
-#define        VXGE_HW_MAX_PAYLOAD_SIZE_512		2
-
-	u32				intr_mode;
-#define VXGE_HW_INTR_MODE_IRQLINE			0
-#define VXGE_HW_INTR_MODE_MSIX				1
-#define VXGE_HW_INTR_MODE_MSIX_ONE_SHOT			2
-
-#define VXGE_HW_INTR_MODE_DEF				0
-
-	u32				rth_en;
-#define VXGE_HW_RTH_DISABLE				0
-#define VXGE_HW_RTH_ENABLE				1
-#define VXGE_HW_RTH_DEFAULT				0
-
-	u32				rth_it_type;
-#define VXGE_HW_RTH_IT_TYPE_SOLO_IT			0
-#define VXGE_HW_RTH_IT_TYPE_MULTI_IT			1
-#define VXGE_HW_RTH_IT_TYPE_DEFAULT			0
-
-	u32				rts_mac_en;
+	u32					device_poll_millis;
+#define VXGE_HW_MIN_DEVICE_POLL_MILLIS		1
+#define VXGE_HW_MAX_DEVICE_POLL_MILLIS		100000
+#define VXGE_HW_DEF_DEVICE_POLL_MILLIS		1000
+
+	u32					dma_blockpool_initial;
+	u32					dma_blockpool_max;
+#define VXGE_HW_MIN_DMA_BLOCK_POOL_SIZE		0
+#define VXGE_HW_INITIAL_DMA_BLOCK_POOL_SIZE	0
+#define VXGE_HW_INCR_DMA_BLOCK_POOL_SIZE	4
+#define VXGE_HW_MAX_DMA_BLOCK_POOL_SIZE		4096
+
+#define	VXGE_HW_MAX_PAYLOAD_SIZE_512		2
+
+	u32					intr_mode:2,
+#define VXGE_HW_INTR_MODE_IRQLINE		0
+#define VXGE_HW_INTR_MODE_MSIX			1
+#define VXGE_HW_INTR_MODE_MSIX_ONE_SHOT		2
+
+#define VXGE_HW_INTR_MODE_DEF			0
+
+						rth_en:1,
+#define VXGE_HW_RTH_DISABLE			0
+#define VXGE_HW_RTH_ENABLE			1
+#define VXGE_HW_RTH_DEFAULT			0
+
+						rth_it_type:1,
+#define VXGE_HW_RTH_IT_TYPE_SOLO_IT		0
+#define VXGE_HW_RTH_IT_TYPE_MULTI_IT		1
+#define VXGE_HW_RTH_IT_TYPE_DEFAULT		0
+
+						rts_mac_en:1,
 #define VXGE_HW_RTS_MAC_DISABLE			0
 #define VXGE_HW_RTS_MAC_ENABLE			1
 #define VXGE_HW_RTS_MAC_DEFAULT			0
 
-	struct vxge_hw_vp_config	vp_config[VXGE_HW_MAX_VIRTUAL_PATHS];
-
-	u32				device_poll_millis;
-#define VXGE_HW_MIN_DEVICE_POLL_MILLIS			1
-#define VXGE_HW_MAX_DEVICE_POLL_MILLIS			100000
-#define VXGE_HW_DEF_DEVICE_POLL_MILLIS			1000
+						hwts_en:1;
+#define	VXGE_HW_HWTS_DISABLE			0
+#define	VXGE_HW_HWTS_ENABLE			1
+#define	VXGE_HW_HWTS_DEFAULT			1
 
+	struct vxge_hw_vp_config vp_config[VXGE_HW_MAX_VIRTUAL_PATHS];
 };
 
 /**
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 395423a..f145293 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -3112,8 +3112,7 @@ vxge_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net_stats)
 	return net_stats;
 }
 
-static enum vxge_hw_status vxge_timestamp_config(struct vxgedev *vdev,
-						 int enable)
+static enum vxge_hw_status vxge_timestamp_config(struct __vxge_hw_device *devh)
 {
 	enum vxge_hw_status status;
 	u64 val64;
@@ -3123,27 +3122,24 @@ static enum vxge_hw_status vxge_timestamp_config(struct vxgedev *vdev,
 	 * required for the driver to load (due to a hardware bug),
 	 * there is no need to do anything special here.
 	 */
-	if (enable)
-		val64 = VXGE_HW_XMAC_TIMESTAMP_EN |
-			VXGE_HW_XMAC_TIMESTAMP_USE_LINK_ID(0) |
-			VXGE_HW_XMAC_TIMESTAMP_INTERVAL(0);
-	else
-		val64 = 0;
+	val64 = VXGE_HW_XMAC_TIMESTAMP_EN |
+		VXGE_HW_XMAC_TIMESTAMP_USE_LINK_ID(0) |
+		VXGE_HW_XMAC_TIMESTAMP_INTERVAL(0);
 
-	status = vxge_hw_mgmt_reg_write(vdev->devh,
+	status = vxge_hw_mgmt_reg_write(devh,
 					vxge_hw_mgmt_reg_type_mrpcim,
 					0,
 					offsetof(struct vxge_hw_mrpcim_reg,
 						 xmac_timestamp),
 					val64);
-	vxge_hw_device_flush_io(vdev->devh);
+	vxge_hw_device_flush_io(devh);
+	devh->config.hwts_en = VXGE_HW_HWTS_ENABLE;
 	return status;
 }
 
 static int vxge_hwtstamp_ioctl(struct vxgedev *vdev, void __user *data)
 {
 	struct hwtstamp_config config;
-	enum vxge_hw_status status;
 	int i;
 
 	if (copy_from_user(&config, data, sizeof(config)))
@@ -3164,10 +3160,6 @@ static int vxge_hwtstamp_ioctl(struct vxgedev *vdev, void __user *data)
 
 	switch (config.rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
-		status = vxge_timestamp_config(vdev, 0);
-		if (status != VXGE_HW_OK)
-			return -EFAULT;
-
 		vdev->rx_hwts = 0;
 		config.rx_filter = HWTSTAMP_FILTER_NONE;
 		break;
@@ -3186,8 +3178,7 @@ static int vxge_hwtstamp_ioctl(struct vxgedev *vdev, void __user *data)
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
-		status = vxge_timestamp_config(vdev, 1);
-		if (status != VXGE_HW_OK)
+		if (vdev->devh->config.hwts_en != VXGE_HW_HWTS_ENABLE)
 			return -EFAULT;
 
 		vdev->rx_hwts = 1;
@@ -4575,6 +4566,24 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 		goto _exit4;
 	}
 
+	/* Always enable HWTS.  This will always cause the FCS to be invalid,
+	 * due to the fact that HWTS is using the FCS as the location of the
+	 * timestamp.  The HW FCS checking will still correctly determine if
+	 * there is a valid checksum, and the FCS is being removed by the driver
+	 * anyway.  So no fucntionality is being lost.  Since it is always
+	 * enabled, we now simply use the ioctl call to set whether or not the
+	 * driver should be paying attention to the HWTS.
+	 */
+	if (is_privileged == VXGE_HW_OK) {
+		status = vxge_timestamp_config(hldev);
+		if (status != VXGE_HW_OK) {
+			vxge_debug_init(VXGE_ERR, "%s: HWTS enable failed",
+					VXGE_DRIVER_NAME);
+			ret = -EFAULT;
+			goto _exit4;
+		}
+	}
+
 	vxge_hw_device_debug_set(hldev, VXGE_ERR, VXGE_COMPONENT_LL);
 
 	/* set private device info */
diff --git a/drivers/net/vxge/vxge-traffic.h b/drivers/net/vxge/vxge-traffic.h
index 9d9dfda..c11f72a 100644
--- a/drivers/net/vxge/vxge-traffic.h
+++ b/drivers/net/vxge/vxge-traffic.h
@@ -240,7 +240,7 @@ struct vxge_hw_tim_intr_config {
 	u32				btimer_val;
 #define VXGE_HW_MIN_TIM_BTIMER_VAL				0
 #define VXGE_HW_MAX_TIM_BTIMER_VAL				67108864
-#define VXGE_HW_USE_FLASH_DEFAULT				0xffffffff
+#define VXGE_HW_USE_FLASH_DEFAULT				(~0)
 
 	u32				timer_ac_en;
 #define VXGE_HW_TIM_TIMER_AC_ENABLE				1
-- 
1.7.0.4

