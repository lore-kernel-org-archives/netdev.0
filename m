From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 3/6 net-next-2.6] vxge: Fix multicast issues (corrected)
Date: Thu, 8 Jul 2010 15:06:12 -0500
Message-ID: <20100708200611.GA17272@exar.com>
References: <20100708192213.GC15167@exar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>,
	Ramkrishna Vepa <ramkrishna.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:45628 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217Ab0GHUFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 16:05:35 -0400
Received: by pvc7 with SMTP id 7so460737pvc.19
        for <netdev@vger.kernel.org>; Thu, 08 Jul 2010 13:05:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100708192213.GC15167@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix error in multicast flag check, add calls to restore the status of
multicast and promiscuous mode settings after change_mtu, and style
cleanups to shorten the function calls by using a temporary variable.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
Signed-off-by: Ramkrishna Vepa <ramkrishna.vepa@exar.com>
---
 drivers/net/vxge/vxge-main.c |  270 +++++++++++++++++++++++-------------------
 1 files changed, 146 insertions(+), 124 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index b8eed71..f921196 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -1091,7 +1091,8 @@ static void vxge_set_multicast(struct net_device *dev)
 	struct netdev_hw_addr *ha;
 	struct vxgedev *vdev;
 	int i, mcast_cnt = 0;
-	struct __vxge_hw_device  *hldev;
+	struct __vxge_hw_device *hldev;
+	struct vxge_vpath *vpath;
 	enum vxge_hw_status status = VXGE_HW_OK;
 	struct macInfo mac_info;
 	int vpath_idx = 0;
@@ -1111,46 +1112,48 @@ static void vxge_set_multicast(struct net_device *dev)
 
 	if ((dev->flags & IFF_ALLMULTI) && (!vdev->all_multi_flg)) {
 		for (i = 0; i < vdev->no_of_vpath; i++) {
-			vxge_assert(vdev->vpaths[i].is_open);
-			status = vxge_hw_vpath_mcast_enable(
-						vdev->vpaths[i].handle);
+			vpath = &vdev->vpaths[i];
+			vxge_assert(vpath->is_open);
+			status = vxge_hw_vpath_mcast_enable(vpath->handle);
+			if (status != VXGE_HW_OK)
+				vxge_debug_init(VXGE_ERR, "failed to enable "
+						"multicast, status %d", status);
 			vdev->all_multi_flg = 1;
 		}
-	} else if ((dev->flags & IFF_ALLMULTI) && (vdev->all_multi_flg)) {
+	} else if (!(dev->flags & IFF_ALLMULTI) && (vdev->all_multi_flg)) {
 		for (i = 0; i < vdev->no_of_vpath; i++) {
-			vxge_assert(vdev->vpaths[i].is_open);
-			status = vxge_hw_vpath_mcast_disable(
-						vdev->vpaths[i].handle);
-			vdev->all_multi_flg = 1;
+			vpath = &vdev->vpaths[i];
+			vxge_assert(vpath->is_open);
+			status = vxge_hw_vpath_mcast_disable(vpath->handle);
+			if (status != VXGE_HW_OK)
+				vxge_debug_init(VXGE_ERR, "failed to disable "
+						"multicast, status %d", status);
+			vdev->all_multi_flg = 0;
 		}
 	}
 
-	if (status != VXGE_HW_OK)
-		vxge_debug_init(VXGE_ERR,
-			"failed to %s multicast, status %d",
-			dev->flags & IFF_ALLMULTI ?
-			"enable" : "disable", status);
 
 	if (!vdev->config.addr_learn_en) {
-		if (dev->flags & IFF_PROMISC) {
-			for (i = 0; i < vdev->no_of_vpath; i++) {
-				vxge_assert(vdev->vpaths[i].is_open);
+		for (i = 0; i < vdev->no_of_vpath; i++) {
+			vpath = &vdev->vpaths[i];
+			vxge_assert(vpath->is_open);
+
+			if (dev->flags & IFF_PROMISC)
 				status = vxge_hw_vpath_promisc_enable(
-						vdev->vpaths[i].handle);
-			}
-		} else {
-			for (i = 0; i < vdev->no_of_vpath; i++) {
-				vxge_assert(vdev->vpaths[i].is_open);
+					vpath->handle);
+			else
 				status = vxge_hw_vpath_promisc_disable(
-						vdev->vpaths[i].handle);
-			}
+					vpath->handle);
+			if (status != VXGE_HW_OK)
+				vxge_debug_init(VXGE_ERR, "failed to %s promisc"
+					", status %d", dev->flags&IFF_PROMISC ?
+					"enable" : "disable", status);
 		}
 	}
 
 	memset(&mac_info, 0, sizeof(struct macInfo));
 	/* Update individual M_CAST address list */
 	if ((!vdev->all_multi_flg) && netdev_mc_count(dev)) {
-
 		mcast_cnt = vdev->vpaths[0].mcast_addr_cnt;
 		list_head = &vdev->vpaths[0].mac_addr_list;
 		if ((netdev_mc_count(dev) +
@@ -1160,14 +1163,7 @@ static void vxge_set_multicast(struct net_device *dev)
 
 		/* Delete previous MC's */
 		for (i = 0; i < mcast_cnt; i++) {
-			if (!list_empty(list_head))
-				mac_entry = (struct vxge_mac_addrs *)
-					list_first_entry(list_head,
-						struct vxge_mac_addrs,
-						item);
-
 			list_for_each_safe(entry, next, list_head) {
-
 				mac_entry = (struct vxge_mac_addrs *) entry;
 				/* Copy the mac address to delete */
 				mac_address = (u8 *)&mac_entry->macaddr;
@@ -1210,9 +1206,7 @@ _set_all_mcast:
 		mcast_cnt = vdev->vpaths[0].mcast_addr_cnt;
 		/* Delete previous MC's */
 		for (i = 0; i < mcast_cnt; i++) {
-
 			list_for_each_safe(entry, next, list_head) {
-
 				mac_entry = (struct vxge_mac_addrs *) entry;
 				/* Copy the mac address to delete */
 				mac_address = (u8 *)&mac_entry->macaddr;
@@ -1232,9 +1226,10 @@ _set_all_mcast:
 
 		/* Enable all multicast */
 		for (i = 0; i < vdev->no_of_vpath; i++) {
-			vxge_assert(vdev->vpaths[i].is_open);
-			status = vxge_hw_vpath_mcast_enable(
-						vdev->vpaths[i].handle);
+			vpath = &vdev->vpaths[i];
+			vxge_assert(vpath->is_open);
+
+			status = vxge_hw_vpath_mcast_enable(vpath->handle);
 			if (status != VXGE_HW_OK) {
 				vxge_debug_init(VXGE_ERR,
 					"%s:%d Enabling all multicasts failed",
@@ -1395,6 +1390,7 @@ void vxge_vpath_intr_disable(struct vxgedev *vdev, int vp_id)
 static int vxge_reset_vpath(struct vxgedev *vdev, int vp_id)
 {
 	enum vxge_hw_status status = VXGE_HW_OK;
+	struct vxge_vpath *vpath = &vdev->vpaths[vp_id];
 	int ret = 0;
 
 	/* check if device is down already */
@@ -1405,12 +1401,10 @@ static int vxge_reset_vpath(struct vxgedev *vdev, int vp_id)
 	if (test_bit(__VXGE_STATE_RESET_CARD, &vdev->state))
 		return 0;
 
-	if (vdev->vpaths[vp_id].handle) {
-		if (vxge_hw_vpath_reset(vdev->vpaths[vp_id].handle)
-				== VXGE_HW_OK) {
+	if (vpath->handle) {
+		if (vxge_hw_vpath_reset(vpath->handle) == VXGE_HW_OK) {
 			if (is_vxge_card_up(vdev) &&
-				vxge_hw_vpath_recover_from_reset(
-					vdev->vpaths[vp_id].handle)
+				vxge_hw_vpath_recover_from_reset(vpath->handle)
 					!= VXGE_HW_OK) {
 				vxge_debug_init(VXGE_ERR,
 					"vxge_hw_vpath_recover_from_reset"
@@ -1426,11 +1420,20 @@ static int vxge_reset_vpath(struct vxgedev *vdev, int vp_id)
 	} else
 		return VXGE_HW_FAIL;
 
-	vxge_restore_vpath_mac_addr(&vdev->vpaths[vp_id]);
-	vxge_restore_vpath_vid_table(&vdev->vpaths[vp_id]);
+	vxge_restore_vpath_mac_addr(vpath);
+	vxge_restore_vpath_vid_table(vpath);
 
 	/* Enable all broadcast */
-	vxge_hw_vpath_bcast_enable(vdev->vpaths[vp_id].handle);
+	vxge_hw_vpath_bcast_enable(vpath->handle);
+
+	/* Enable all multicast */
+	if (vdev->all_multi_flg) {
+		status = vxge_hw_vpath_mcast_enable(vpath->handle);
+		if (status != VXGE_HW_OK)
+			vxge_debug_init(VXGE_ERR,
+				"%s:%d Enabling multicast failed",
+				__func__, __LINE__);
+	}
 
 	/* Enable the interrupts */
 	vxge_vpath_intr_enable(vdev, vp_id);
@@ -1438,17 +1441,17 @@ static int vxge_reset_vpath(struct vxgedev *vdev, int vp_id)
 	smp_wmb();
 
 	/* Enable the flow of traffic through the vpath */
-	vxge_hw_vpath_enable(vdev->vpaths[vp_id].handle);
+	vxge_hw_vpath_enable(vpath->handle);
 
 	smp_wmb();
-	vxge_hw_vpath_rx_doorbell_init(vdev->vpaths[vp_id].handle);
-	vdev->vpaths[vp_id].ring.last_status = VXGE_HW_OK;
+	vxge_hw_vpath_rx_doorbell_init(vpath->handle);
+	vpath->ring.last_status = VXGE_HW_OK;
 
 	/* Vpath reset done */
 	clear_bit(vp_id, &vdev->vp_reset);
 
 	/* Start the vpath queue */
-	vxge_wake_tx_queue(&vdev->vpaths[vp_id].fifo);
+	vxge_wake_tx_queue(&vpath->fifo);
 
 	return ret;
 }
@@ -1482,9 +1485,9 @@ static int do_vxge_reset(struct vxgedev *vdev, int event)
 			vxge_debug_init(VXGE_ERR,
 				"%s: execution mode is debug, returning..",
 				vdev->ndev->name);
-		clear_bit(__VXGE_STATE_CARD_UP, &vdev->state);
-		netif_tx_stop_all_queues(vdev->ndev);
-		return 0;
+			clear_bit(__VXGE_STATE_CARD_UP, &vdev->state);
+			netif_tx_stop_all_queues(vdev->ndev);
+			return 0;
 		}
 	}
 
@@ -1631,8 +1634,7 @@ out:
  */
 int vxge_reset(struct vxgedev *vdev)
 {
-	do_vxge_reset(vdev, VXGE_LL_FULL_RESET);
-	return 0;
+	return do_vxge_reset(vdev, VXGE_LL_FULL_RESET);
 }
 
 /**
@@ -1995,17 +1997,17 @@ enum vxge_hw_status vxge_restore_vpath_mac_addr(struct vxge_vpath *vpath)
 /* reset vpaths */
 enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev)
 {
-	int i;
 	enum vxge_hw_status status = VXGE_HW_OK;
+	struct vxge_vpath *vpath;
+	int i;
 
-	for (i = 0; i < vdev->no_of_vpath; i++)
-		if (vdev->vpaths[i].handle) {
-			if (vxge_hw_vpath_reset(vdev->vpaths[i].handle)
-					== VXGE_HW_OK) {
+	for (i = 0; i < vdev->no_of_vpath; i++) {
+		vpath = &vdev->vpaths[i];
+		if (vpath->handle) {
+			if (vxge_hw_vpath_reset(vpath->handle) == VXGE_HW_OK) {
 				if (is_vxge_card_up(vdev) &&
 					vxge_hw_vpath_recover_from_reset(
-						vdev->vpaths[i].handle)
-						!= VXGE_HW_OK) {
+						vpath->handle) != VXGE_HW_OK) {
 					vxge_debug_init(VXGE_ERR,
 						"vxge_hw_vpath_recover_"
 						"from_reset failed for vpath: "
@@ -2019,83 +2021,87 @@ enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev)
 					return status;
 			}
 		}
+	}
+
 	return status;
 }
 
 /* close vpaths */
 void vxge_close_vpaths(struct vxgedev *vdev, int index)
 {
+	struct vxge_vpath *vpath;
 	int i;
+
 	for (i = index; i < vdev->no_of_vpath; i++) {
-		if (vdev->vpaths[i].handle && vdev->vpaths[i].is_open) {
-			vxge_hw_vpath_close(vdev->vpaths[i].handle);
+		vpath = &vdev->vpaths[i];
+
+		if (vpath->handle && vpath->is_open) {
+			vxge_hw_vpath_close(vpath->handle);
 			vdev->stats.vpaths_open--;
 		}
-		vdev->vpaths[i].is_open = 0;
-		vdev->vpaths[i].handle  = NULL;
+		vpath->is_open = 0;
+		vpath->handle = NULL;
 	}
 }
 
 /* open vpaths */
 int vxge_open_vpaths(struct vxgedev *vdev)
 {
+	struct vxge_hw_vpath_attr attr;
 	enum vxge_hw_status status;
-	int i;
+	struct vxge_vpath *vpath;
 	u32 vp_id = 0;
-	struct vxge_hw_vpath_attr attr;
+	int i;
 
 	for (i = 0; i < vdev->no_of_vpath; i++) {
-		vxge_assert(vdev->vpaths[i].is_configured);
-		attr.vp_id = vdev->vpaths[i].device_id;
+		vpath = &vdev->vpaths[i];
+
+		vxge_assert(vpath->is_configured);
+		attr.vp_id = vpath->device_id;
 		attr.fifo_attr.callback = vxge_xmit_compl;
 		attr.fifo_attr.txdl_term = vxge_tx_term;
 		attr.fifo_attr.per_txdl_space = sizeof(struct vxge_tx_priv);
-		attr.fifo_attr.userdata = (void *)&vdev->vpaths[i].fifo;
+		attr.fifo_attr.userdata = &vpath->fifo;
 
 		attr.ring_attr.callback = vxge_rx_1b_compl;
 		attr.ring_attr.rxd_init = vxge_rx_initial_replenish;
 		attr.ring_attr.rxd_term = vxge_rx_term;
 		attr.ring_attr.per_rxd_space = sizeof(struct vxge_rx_priv);
-		attr.ring_attr.userdata = (void *)&vdev->vpaths[i].ring;
+		attr.ring_attr.userdata = &vpath->ring;
 
-		vdev->vpaths[i].ring.ndev = vdev->ndev;
-		vdev->vpaths[i].ring.pdev = vdev->pdev;
-		status = vxge_hw_vpath_open(vdev->devh, &attr,
-				&(vdev->vpaths[i].handle));
+		vpath->ring.ndev = vdev->ndev;
+		vpath->ring.pdev = vdev->pdev;
+		status = vxge_hw_vpath_open(vdev->devh, &attr, &vpath->handle);
 		if (status == VXGE_HW_OK) {
-			vdev->vpaths[i].fifo.handle =
+			vpath->fifo.handle =
 			    (struct __vxge_hw_fifo *)attr.fifo_attr.userdata;
-			vdev->vpaths[i].ring.handle =
+			vpath->ring.handle =
 			    (struct __vxge_hw_ring *)attr.ring_attr.userdata;
-			vdev->vpaths[i].fifo.tx_steering_type =
+			vpath->fifo.tx_steering_type =
 				vdev->config.tx_steering_type;
-			vdev->vpaths[i].fifo.ndev = vdev->ndev;
-			vdev->vpaths[i].fifo.pdev = vdev->pdev;
-			vdev->vpaths[i].fifo.indicate_max_pkts =
+			vpath->fifo.ndev = vdev->ndev;
+			vpath->fifo.pdev = vdev->pdev;
+			vpath->fifo.indicate_max_pkts =
 				vdev->config.fifo_indicate_max_pkts;
-			vdev->vpaths[i].ring.rx_vector_no = 0;
-			vdev->vpaths[i].ring.rx_csum = vdev->rx_csum;
-			vdev->vpaths[i].is_open = 1;
-			vdev->vp_handles[i] = vdev->vpaths[i].handle;
-			vdev->vpaths[i].ring.gro_enable =
-						vdev->config.gro_enable;
-			vdev->vpaths[i].ring.vlan_tag_strip =
-						vdev->vlan_tag_strip;
+			vpath->ring.rx_vector_no = 0;
+			vpath->ring.rx_csum = vdev->rx_csum;
+			vpath->is_open = 1;
+			vdev->vp_handles[i] = vpath->handle;
+			vpath->ring.gro_enable = vdev->config.gro_enable;
+			vpath->ring.vlan_tag_strip = vdev->vlan_tag_strip;
 			vdev->stats.vpaths_open++;
 		} else {
 			vdev->stats.vpath_open_fail++;
 			vxge_debug_init(VXGE_ERR,
 				"%s: vpath: %d failed to open "
 				"with status: %d",
-			    vdev->ndev->name, vdev->vpaths[i].device_id,
+			    vdev->ndev->name, vpath->device_id,
 				status);
 			vxge_close_vpaths(vdev, 0);
 			return -EPERM;
 		}
 
-		vp_id =
-		  ((struct __vxge_hw_vpath_handle *)vdev->vpaths[i].handle)->
-		  vpath->vp_id;
+		vp_id = vpath->handle->vpath->vp_id;
 		vdev->vpaths_deployed |= vxge_mBIT(vp_id);
 	}
 	return VXGE_HW_OK;
@@ -2269,7 +2275,6 @@ start:
 	vdev->vxge_entries[j].in_use = 0;
 
 	ret = pci_enable_msix(vdev->pdev, vdev->entries, vdev->intr_cnt);
-
 	if (ret > 0) {
 		vxge_debug_init(VXGE_ERR,
 			"%s: MSI-X enable failed for %d vectors, ret: %d",
@@ -2315,17 +2320,16 @@ static int vxge_enable_msix(struct vxgedev *vdev)
 	ret = vxge_alloc_msix(vdev);
 	if (!ret) {
 		for (i = 0; i < vdev->no_of_vpath; i++) {
+			struct vxge_vpath *vpath = &vdev->vpaths[i];
 
-			/* If fifo or ring are not enabled
-			   the MSIX vector for that should be set to 0
-			   Hence initializeing this array to all 0s.
-			*/
-			vdev->vpaths[i].ring.rx_vector_no =
-				(vdev->vpaths[i].device_id *
-					VXGE_HW_VPATH_MSIX_ACTIVE) + 1;
+			/* If fifo or ring are not enabled, the MSIX vector for
+			 * it should be set to 0.
+			 */
+			vpath->ring.rx_vector_no = (vpath->device_id *
+						VXGE_HW_VPATH_MSIX_ACTIVE) + 1;
 
-			vxge_hw_vpath_msix_set(vdev->vpaths[i].handle,
-					tim_msix_id, VXGE_ALARM_MSIX_ID);
+			vxge_hw_vpath_msix_set(vpath->handle, tim_msix_id,
+					       VXGE_ALARM_MSIX_ID);
 		}
 	}
 
@@ -2540,9 +2544,10 @@ static void vxge_poll_vp_reset(unsigned long data)
 static void vxge_poll_vp_lockup(unsigned long data)
 {
 	struct vxgedev *vdev = (struct vxgedev *)data;
-	int i;
-	struct vxge_ring *ring;
 	enum vxge_hw_status status = VXGE_HW_OK;
+	struct vxge_vpath *vpath;
+	struct vxge_ring *ring;
+	int i;
 
 	for (i = 0; i < vdev->no_of_vpath; i++) {
 		ring = &vdev->vpaths[i].ring;
@@ -2556,13 +2561,13 @@ static void vxge_poll_vp_lockup(unsigned long data)
 
 				/* schedule vpath reset */
 				if (!test_and_set_bit(i, &vdev->vp_reset)) {
+					vpath = &vdev->vpaths[i];
 
 					/* disable interrupts for this vpath */
 					vxge_vpath_intr_disable(vdev, i);
 
 					/* stop the queue for this vpath */
-					vxge_stop_tx_queue(&vdev->vpaths[i].
-								fifo);
+					vxge_stop_tx_queue(&vpath->fifo);
 					continue;
 				}
 			}
@@ -2591,6 +2596,7 @@ vxge_open(struct net_device *dev)
 	enum vxge_hw_status status;
 	struct vxgedev *vdev;
 	struct __vxge_hw_device *hldev;
+	struct vxge_vpath *vpath;
 	int ret = 0;
 	int i;
 	u64 val64, function_mode;
@@ -2629,15 +2635,17 @@ vxge_open(struct net_device *dev)
 		netif_napi_add(dev, &vdev->napi, vxge_poll_inta,
 			vdev->config.napi_weight);
 		napi_enable(&vdev->napi);
-		for (i = 0; i < vdev->no_of_vpath; i++)
-			vdev->vpaths[i].ring.napi_p = &vdev->napi;
+		for (i = 0; i < vdev->no_of_vpath; i++) {
+			vpath = &vdev->vpaths[i];
+			vpath->ring.napi_p = &vdev->napi;
+		}
 	} else {
 		for (i = 0; i < vdev->no_of_vpath; i++) {
-			netif_napi_add(dev, &vdev->vpaths[i].ring.napi,
+			vpath = &vdev->vpaths[i];
+			netif_napi_add(dev, &vpath->ring.napi,
 			    vxge_poll_msix, vdev->config.napi_weight);
-			napi_enable(&vdev->vpaths[i].ring.napi);
-			vdev->vpaths[i].ring.napi_p =
-				&vdev->vpaths[i].ring.napi;
+			napi_enable(&vpath->ring.napi);
+			vpath->ring.napi_p = &vpath->ring.napi;
 		}
 	}
 
@@ -2654,9 +2662,10 @@ vxge_open(struct net_device *dev)
 	}
 
 	for (i = 0; i < vdev->no_of_vpath; i++) {
+		vpath = &vdev->vpaths[i];
+
 		/* set initial mtu before enabling the device */
-		status = vxge_hw_vpath_mtu_set(vdev->vpaths[i].handle,
-						vdev->mtu);
+		status = vxge_hw_vpath_mtu_set(vpath->handle, vdev->mtu);
 		if (status != VXGE_HW_OK) {
 			vxge_debug_init(VXGE_ERR,
 				"%s: fatal: can not set new MTU", dev->name);
@@ -2670,10 +2679,21 @@ vxge_open(struct net_device *dev)
 		"%s: MTU is %d", vdev->ndev->name, vdev->mtu);
 	VXGE_DEVICE_DEBUG_LEVEL_SET(VXGE_ERR, VXGE_COMPONENT_LL, vdev);
 
-	/* Reprogram the DA table with populated mac addresses */
-	for (i = 0; i < vdev->no_of_vpath; i++) {
-		vxge_restore_vpath_mac_addr(&vdev->vpaths[i]);
-		vxge_restore_vpath_vid_table(&vdev->vpaths[i]);
+	/* Restore the DA, VID table and also multicast and promiscuous mode
+	 * states
+	 */
+	if (vdev->all_multi_flg) {
+		for (i = 0; i < vdev->no_of_vpath; i++) {
+			vpath = &vdev->vpaths[i];
+			vxge_restore_vpath_mac_addr(vpath);
+			vxge_restore_vpath_vid_table(vpath);
+
+			status = vxge_hw_vpath_mcast_enable(vpath->handle);
+			if (status != VXGE_HW_OK)
+				vxge_debug_init(VXGE_ERR,
+					"%s:%d Enabling multicast failed",
+					__func__, __LINE__);
+		}
 	}
 
 	/* Enable vpath to sniff all unicast/multicast traffic that not
@@ -2702,14 +2722,14 @@ vxge_open(struct net_device *dev)
 
 	/* Enabling Bcast and mcast for all vpath */
 	for (i = 0; i < vdev->no_of_vpath; i++) {
-		status = vxge_hw_vpath_bcast_enable(vdev->vpaths[i].handle);
+		vpath = &vdev->vpaths[i];
+		status = vxge_hw_vpath_bcast_enable(vpath->handle);
 		if (status != VXGE_HW_OK)
 			vxge_debug_init(VXGE_ERR,
 				"%s : Can not enable bcast for vpath "
 				"id %d", dev->name, i);
 		if (vdev->config.addr_learn_en) {
-			status =
-			    vxge_hw_vpath_mcast_enable(vdev->vpaths[i].handle);
+			status = vxge_hw_vpath_mcast_enable(vpath->handle);
 			if (status != VXGE_HW_OK)
 				vxge_debug_init(VXGE_ERR,
 					"%s : Can not enable mcast for vpath "
@@ -2744,9 +2764,11 @@ vxge_open(struct net_device *dev)
 	smp_wmb();
 
 	for (i = 0; i < vdev->no_of_vpath; i++) {
-		vxge_hw_vpath_enable(vdev->vpaths[i].handle);
+		vpath = &vdev->vpaths[i];
+
+		vxge_hw_vpath_enable(vpath->handle);
 		smp_wmb();
-		vxge_hw_vpath_rx_doorbell_init(vdev->vpaths[i].handle);
+		vxge_hw_vpath_rx_doorbell_init(vpath->handle);
 	}
 
 	netif_tx_start_all_queues(vdev->ndev);
