From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 38/47] vxge: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:40 +0200
Message-ID: <1311173689-17419-39-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	jdmason@kudzu.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10283 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752280Ab1GTO4H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:56:07 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill vdev->vlgrp and vxge_vlan_rx_register

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/vxge/vxge-main.c |   91 ++++++------------------------------------
 drivers/net/vxge/vxge-main.h |    5 +-
 2 files changed, 16 insertions(+), 80 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 15d878b..178348a2 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -43,6 +43,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/bitops.h>
 #include <linux/if_vlan.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
@@ -308,13 +309,10 @@ vxge_rx_complete(struct vxge_ring *ring, struct sk_buff *skb, u16 vlan,
 		"%s: %s:%d  skb protocol = %d",
 		ring->ndev->name, __func__, __LINE__, skb->protocol);
 
-	if (ring->vlgrp && ext_info->vlan &&
-		(ring->vlan_tag_strip ==
-			VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_ENABLE))
-		vlan_gro_receive(ring->napi_p, ring->vlgrp,
-				ext_info->vlan, skb);
-	else
-		napi_gro_receive(ring->napi_p, skb);
+	if (ext_info->vlan &&
+	    ring->vlan_tag_strip == VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_ENABLE)
+		__vlan_hwaccel_put_tag(skb, ext_info->vlan);
+	napi_gro_receive(ring->napi_p, skb);
 
 	vxge_debug_entryexit(VXGE_TRACE,
 		"%s: %s:%d Exiting...", ring->ndev->name, __func__, __LINE__);
@@ -1489,15 +1487,11 @@ vxge_restore_vpath_vid_table(struct vxge_vpath *vpath)
 	struct vxgedev *vdev = vpath->vdev;
 	u16 vid;
 
-	if (vdev->vlgrp && vpath->is_open) {
+	if (!vpath->is_open)
+		return status;
 
-		for (vid = 0; vid < VLAN_N_VID; vid++) {
-			if (!vlan_group_get_device(vdev->vlgrp, vid))
-				continue;
-			/* Add these vlan to the vid table */
-			status = vxge_hw_vpath_vid_add(vpath->handle, vid);
-		}
-	}
+	for_each_set_bit(vid, vdev->active_vlans, VLAN_N_VID)
+		status = vxge_hw_vpath_vid_add(vpath->handle, vid);
 
 	return status;
 }
@@ -3303,60 +3297,6 @@ static void vxge_tx_watchdog(struct net_device *dev)
 }
 
 /**
- * vxge_vlan_rx_register
- * @dev: net device pointer.
- * @grp: vlan group
- *
- * Vlan group registration
- */
-static void
-vxge_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
-{
-	struct vxgedev *vdev;
-	struct vxge_vpath *vpath;
-	int vp;
-	u64 vid;
-	enum vxge_hw_status status;
-	int i;
-
-	vxge_debug_entryexit(VXGE_TRACE, "%s:%d", __func__, __LINE__);
-
-	vdev = netdev_priv(dev);
-
-	vpath = &vdev->vpaths[0];
-	if ((NULL == grp) && (vpath->is_open)) {
-		/* Get the first vlan */
-		status = vxge_hw_vpath_vid_get(vpath->handle, &vid);
-
-		while (status == VXGE_HW_OK) {
-
-			/* Delete this vlan from the vid table */
-			for (vp = 0; vp < vdev->no_of_vpath; vp++) {
-				vpath = &vdev->vpaths[vp];
-				if (!vpath->is_open)
-					continue;
-
-				vxge_hw_vpath_vid_delete(vpath->handle, vid);
-			}
-
-			/* Get the next vlan to be deleted */
-			vpath = &vdev->vpaths[0];
-			status = vxge_hw_vpath_vid_get(vpath->handle, &vid);
-		}
-	}
-
-	vdev->vlgrp = grp;
-
-	for (i = 0; i < vdev->no_of_vpath; i++) {
-		if (vdev->vpaths[i].is_configured)
-			vdev->vpaths[i].ring.vlgrp = grp;
-	}
-
-	vxge_debug_entryexit(VXGE_TRACE,
-		"%s:%d  Exiting...", __func__, __LINE__);
-}
-
-/**
  * vxge_vlan_rx_add_vid
  * @dev: net device pointer.
  * @vid: vid
@@ -3366,12 +3306,10 @@ vxge_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 static void
 vxge_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 {
-	struct vxgedev *vdev;
+	struct vxgedev *vdev = netdev_priv(dev);
 	struct vxge_vpath *vpath;
 	int vp_id;
 
-	vdev = netdev_priv(dev);
-
 	/* Add these vlan to the vid table */
 	for (vp_id = 0; vp_id < vdev->no_of_vpath; vp_id++) {
 		vpath = &vdev->vpaths[vp_id];
@@ -3379,6 +3317,7 @@ vxge_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 			continue;
 		vxge_hw_vpath_vid_add(vpath->handle, vid);
 	}
+	set_bit(vid, vdev->active_vlans);
 }
 
 /**
@@ -3391,16 +3330,12 @@ vxge_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 static void
 vxge_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 {
-	struct vxgedev *vdev;
+	struct vxgedev *vdev = netdev_priv(dev);
 	struct vxge_vpath *vpath;
 	int vp_id;
 
 	vxge_debug_entryexit(VXGE_TRACE, "%s:%d", __func__, __LINE__);
 
-	vdev = netdev_priv(dev);
-
-	vlan_group_set_device(vdev->vlgrp, vid, NULL);
-
 	/* Delete this vlan from the vid table */
 	for (vp_id = 0; vp_id < vdev->no_of_vpath; vp_id++) {
 		vpath = &vdev->vpaths[vp_id];
@@ -3410,6 +3345,7 @@ vxge_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 	}
 	vxge_debug_entryexit(VXGE_TRACE,
 		"%s:%d  Exiting...", __func__, __LINE__);
+	clear_bit(vid, vdev->active_vlans);
 }
 
 static const struct net_device_ops vxge_netdev_ops = {
@@ -3424,7 +3360,6 @@ static const struct net_device_ops vxge_netdev_ops = {
 	.ndo_change_mtu         = vxge_change_mtu,
 	.ndo_fix_features	= vxge_fix_features,
 	.ndo_set_features	= vxge_set_features,
-	.ndo_vlan_rx_register   = vxge_vlan_rx_register,
 	.ndo_vlan_rx_kill_vid   = vxge_vlan_rx_kill_vid,
 	.ndo_vlan_rx_add_vid	= vxge_vlan_rx_add_vid,
 	.ndo_tx_timeout         = vxge_tx_watchdog,
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
index 66e6de8..f52a42d 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -18,6 +18,8 @@
 #include "vxge-config.h"
 #include "vxge-version.h"
 #include <linux/list.h>
+#include <linux/bitops.h>
+#include <linux/if_vlan.h>
 
 #define VXGE_DRIVER_NAME		"vxge"
 #define VXGE_DRIVER_VENDOR		"Neterion, Inc"
@@ -287,7 +289,6 @@ struct vxge_ring {
 #define VXGE_MAX_MAC_ADDR_COUNT		30
 
 	int vlan_tag_strip;
-	struct vlan_group *vlgrp;
 	u32 rx_vector_no;
 	enum vxge_hw_status last_status;
 
@@ -332,7 +333,7 @@ struct vxgedev {
 	struct net_device	*ndev;
 	struct pci_dev		*pdev;
 	struct __vxge_hw_device *devh;
-	struct vlan_group	*vlgrp;
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	int vlan_tag_strip;
 	struct vxge_config	config;
 	unsigned long	state;
-- 
1.7.6

