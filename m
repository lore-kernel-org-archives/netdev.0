From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 06/11] vxge: add receive hardware timestamping
Date: Thu, 28 Oct 2010 21:19:41 -0500
Message-ID: <1288318786-12319-6-git-send-email-jon.mason@exar.com>
References: <1288318786-12319-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:37455 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759857Ab0J2CUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 22:20:12 -0400
Received: by gwj21 with SMTP id 21so1712786gwj.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 19:20:11 -0700 (PDT)
In-Reply-To: <1288318786-12319-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for enable/disabling hardware timestamping on receive
packets via ioctl call.  When enabled, the hardware timestamp replaces
the FCS in the payload.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-main.c |  133 ++++++++++++++++++++++++++++++++++++++++--
 drivers/net/vxge/vxge-main.h |    8 ++-
 2 files changed, 132 insertions(+), 9 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 52a48e7..a365784 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -51,6 +51,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/firmware.h>
+#include <linux/net_tstamp.h>
 #include "vxge-main.h"
 #include "vxge-reg.h"
 
@@ -360,7 +361,7 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
 		 u8 t_code, void *userdata)
 {
 	struct vxge_ring *ring = (struct vxge_ring *)userdata;
-	struct  net_device *dev = ring->ndev;
+	struct net_device *dev = ring->ndev;
 	unsigned int dma_sizes;
 	void *first_dtr = NULL;
 	int dtr_cnt = 0;
@@ -504,6 +505,16 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
 		else
 			skb_checksum_none_assert(skb);
 
+
+		if (ring->rx_hwts) {
+			struct skb_shared_hwtstamps *skb_hwts;
+			u32 ns = *(u32 *)(skb->head + pkt_length);
+
+			skb_hwts = skb_hwtstamps(skb);
+			skb_hwts->hwtstamp = ns_to_ktime(ns);
+			skb_hwts->syststamp.tv64 = 0;
+		}
+
 		/* rth_hash_type and rth_it_hit are non-zero regardless of
 		 * whether rss is enabled.  Only the rth_value is zero/non-zero
 		 * if rss is disabled/enabled, so key off of that.
@@ -2026,6 +2037,7 @@ int vxge_open_vpaths(struct vxgedev *vdev)
 				vdev->config.fifo_indicate_max_pkts;
 			vpath->ring.rx_vector_no = 0;
 			vpath->ring.rx_csum = vdev->rx_csum;
+			vpath->ring.rx_hwts = vdev->rx_hwts;
 			vpath->is_open = 1;
 			vdev->vp_handles[i] = vpath->handle;
 			vpath->ring.gro_enable = vdev->config.gro_enable;
@@ -2960,6 +2972,101 @@ vxge_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net_stats)
 	return net_stats;
 }
 
+static enum vxge_hw_status vxge_timestamp_config(struct vxgedev *vdev,
+						 int enable)
+{
+	enum vxge_hw_status status;
+	u64 val64;
+
+	/* Timestamp is passed to the driver via the FCS, therefore we
+	 * must disable the FCS stripping by the adapter.  Since this is
+	 * required for the driver to load (due to a hardware bug),
+	 * there is no need to do anything special here.
+	 */
+	if (enable)
+		val64 = VXGE_HW_XMAC_TIMESTAMP_EN |
+			VXGE_HW_XMAC_TIMESTAMP_USE_LINK_ID(0) |
+			VXGE_HW_XMAC_TIMESTAMP_INTERVAL(0);
+	else
+		val64 = 0;
+
+	status = vxge_hw_mgmt_reg_write(vdev->devh,
+					vxge_hw_mgmt_reg_type_mrpcim,
+					0,
+					offsetof(struct vxge_hw_mrpcim_reg,
+						 xmac_timestamp),
+					val64);
+	vxge_hw_device_flush_io(vdev->devh);
+	return status;
+}
+
+static int vxge_hwtstamp_ioctl(struct vxgedev *vdev, void __user *data)
+{
+	struct hwtstamp_config config;
+	enum vxge_hw_status status;
+	int i;
+
+	if (copy_from_user(&config, data, sizeof(config)))
+		return -EFAULT;
+
+	/* reserved for future extensions */
+	if (config.flags)
+		return -EINVAL;
+
+	/* Transmit HW Timestamp not supported */
+	switch (config.tx_type) {
+	case HWTSTAMP_TX_OFF:
+		break;
+	case HWTSTAMP_TX_ON:
+	default:
+		return -ERANGE;
+	}
+
+	switch (config.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		status = vxge_timestamp_config(vdev, 0);
+		if (status != VXGE_HW_OK)
+			return -EFAULT;
+
+		vdev->rx_hwts = 0;
+		config.rx_filter = HWTSTAMP_FILTER_NONE;
+		break;
+
+	case HWTSTAMP_FILTER_ALL:
+	case HWTSTAMP_FILTER_SOME:
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		status = vxge_timestamp_config(vdev, 1);
+		if (status != VXGE_HW_OK)
+			return -EFAULT;
+
+		vdev->rx_hwts = 1;
+		config.rx_filter = HWTSTAMP_FILTER_ALL;
+		break;
+
+	default:
+		 return -ERANGE;
+	}
+
+	for (i = 0; i < vdev->no_of_vpath; i++)
+		vdev->vpaths[i].ring.rx_hwts = vdev->rx_hwts;
+
+	if (copy_to_user(data, &config, sizeof(config)))
+		return -EFAULT;
+
+	return 0;
+}
+
 /**
  * vxge_ioctl
  * @dev: Device pointer.
@@ -2972,7 +3079,20 @@ vxge_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net_stats)
  */
 static int vxge_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	return -EOPNOTSUPP;
+	struct vxgedev *vdev = netdev_priv(dev);
+	int ret;
+
+	switch (cmd) {
+	case SIOCSHWTSTAMP:
+		ret = vxge_hwtstamp_ioctl(vdev, rq->ifr_data);
+		if (ret)
+			return ret;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
 }
 
 /**
@@ -3169,6 +3289,7 @@ int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 	vdev->pdev = hldev->pdev;
 	memcpy(&vdev->config, config, sizeof(struct vxge_config));
 	vdev->rx_csum = 1;	/* Enable Rx CSUM by default. */
+	vdev->rx_hwts = 0;
 
 	SET_NETDEV_DEV(ndev, &vdev->pdev->dev);
 
@@ -4303,10 +4424,10 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 	}
 
 	/* if FCS stripping is not disabled in MAC fail driver load */
-	if (vxge_hw_vpath_strip_fcs_check(hldev, vpath_mask) != VXGE_HW_OK) {
-		vxge_debug_init(VXGE_ERR,
-			"%s: FCS stripping is not disabled in MAC"
-			" failing driver load", VXGE_DRIVER_NAME);
+	status = vxge_hw_vpath_strip_fcs_check(hldev, vpath_mask);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR, "%s: FCS stripping is enabled in MAC"
+				" failing driver load", VXGE_DRIVER_NAME);
 		ret = -EINVAL;
 		goto _exit4;
 	}
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
index 1e47319..947893e 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -248,8 +248,9 @@ struct vxge_ring {
 	 */
 	int driver_id;
 
-	 /* copy of the flag indicating whether rx_csum is to be used */
-	u32 rx_csum;
+	/* copy of the flag indicating whether rx_csum is to be used */
+	u32 rx_csum:1,
+	    rx_hwts:1;
 
 	int pkts_processed;
 	int budget;
@@ -327,7 +328,8 @@ struct vxgedev {
 	u16		all_multi_flg;
 
 	 /* A flag indicating whether rx_csum is to be used or not. */
-	u32	rx_csum;
+	u32	rx_csum:1,
+		rx_hwts:1;
 
 	struct vxge_msix_entry *vxge_entries;
 	struct msix_entry *entries;
-- 
1.7.0.4

