From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] vxge: make function table const
Date: Fri, 16 Sep 2011 14:10:01 -0700
Message-ID: <20110916141001.2d4ca61d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jon Mason <jdmason@kudzu.us>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42707 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755475Ab1IPVK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 17:10:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


All tables of function pointers should be const.
The pre-existing code has lots of needless indirection...

Inspired by similar change in PAX.
Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/ethernet/neterion/vxge/vxge-config.c  |   11 +++++------
 drivers/net/ethernet/neterion/vxge/vxge-config.h  |    4 ++--
 drivers/net/ethernet/neterion/vxge/vxge-main.c    |   10 +++++++---
 drivers/net/ethernet/neterion/vxge/vxge-traffic.c |   12 ++++++------
 4 files changed, 20 insertions(+), 17 deletions(-)

--- a/drivers/net/ethernet/neterion/vxge/vxge-config.c	2011-09-16 13:12:56.529369674 -0700
+++ b/drivers/net/ethernet/neterion/vxge/vxge-config.c	2011-09-16 13:21:30.925393238 -0700
@@ -1342,9 +1342,7 @@ vxge_hw_device_initialize(
 	hldev->bar0 = attr->bar0;
 	hldev->pdev = attr->pdev;
 
-	hldev->uld_callbacks.link_up = attr->uld_callbacks.link_up;
-	hldev->uld_callbacks.link_down = attr->uld_callbacks.link_down;
-	hldev->uld_callbacks.crit_err = attr->uld_callbacks.crit_err;
+	hldev->uld_callbacks = attr->uld_callbacks;
 
 	__vxge_hw_device_pci_e_init(hldev);
 
@@ -2633,7 +2631,7 @@ __vxge_hw_mempool_create(struct __vxge_h
 			 u32 items_priv_size,
 			 u32 items_initial,
 			 u32 items_max,
-			 struct vxge_hw_mempool_cbs *mp_callback,
+			 const struct vxge_hw_mempool_cbs *mp_callback,
 			 void *userdata)
 {
 	enum vxge_hw_status status = VXGE_HW_OK;
@@ -2817,7 +2815,9 @@ __vxge_hw_ring_create(struct __vxge_hw_v
 	struct vxge_hw_ring_config *config;
 	struct __vxge_hw_device *hldev;
 	u32 vp_id;
-	struct vxge_hw_mempool_cbs ring_mp_callback;
+	static const struct vxge_hw_mempool_cbs ring_mp_callback = {
+		.item_func_alloc = __vxge_hw_ring_mempool_item_alloc,
+	};
 
 	if ((vp == NULL) || (attr == NULL)) {
 		status = VXGE_HW_FAIL;
@@ -2872,7 +2872,6 @@ __vxge_hw_ring_create(struct __vxge_hw_v
 
 	/* calculate actual RxD block private size */
 	ring->rxdblock_priv_size = ring->rxd_priv_size * ring->rxds_per_block;
-	ring_mp_callback.item_func_alloc = __vxge_hw_ring_mempool_item_alloc;
 	ring->mempool = __vxge_hw_mempool_create(hldev,
 				VXGE_HW_BLOCK_SIZE,
 				VXGE_HW_BLOCK_SIZE,
--- a/drivers/net/ethernet/neterion/vxge/vxge-config.h	2011-09-16 13:12:56.529369674 -0700
+++ b/drivers/net/ethernet/neterion/vxge/vxge-config.h	2011-09-16 13:21:30.925393238 -0700
@@ -740,7 +740,7 @@ struct __vxge_hw_device {
 	struct vxge_hw_device_config	config;
 	enum vxge_hw_device_link_state	link_state;
 
-	struct vxge_hw_uld_cbs		uld_callbacks;
+	const struct vxge_hw_uld_cbs	*uld_callbacks;
 
 	u32				host_type;
 	u32				func_id;
@@ -840,7 +840,7 @@ struct vxge_hw_device_hw_info {
 struct vxge_hw_device_attr {
 	void __iomem		*bar0;
 	struct pci_dev 		*pdev;
-	struct vxge_hw_uld_cbs	uld_callbacks;
+	const struct vxge_hw_uld_cbs *uld_callbacks;
 };
 
 #define VXGE_HW_DEVICE_LINK_STATE_SET(hldev, ls)	(hldev->link_state = ls)
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c	2011-09-16 13:12:56.529369674 -0700
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c	2011-09-16 13:21:30.925393238 -0700
@@ -4284,6 +4284,12 @@ static int __devinit is_sriov_initialize
 	return 0;
 }
 
+static const struct vxge_hw_uld_cbs vxge_callbacks = {
+	.link_up = vxge_callback_link_up,
+	.link_down = vxge_callback_link_down,
+	.crit_err = vxge_callback_crit_err,
+};
+
 /**
  * vxge_probe
  * @pdev : structure containing the PCI related information of the device.
@@ -4494,9 +4500,7 @@ vxge_probe(struct pci_dev *pdev, const s
 	}
 
 	/* Setting driver callbacks */
-	attr.uld_callbacks.link_up = vxge_callback_link_up;
-	attr.uld_callbacks.link_down = vxge_callback_link_down;
-	attr.uld_callbacks.crit_err = vxge_callback_crit_err;
+	attr.uld_callbacks = &vxge_callbacks;
 
 	status = vxge_hw_device_initialize(&hldev, &attr, device_config);
 	if (status != VXGE_HW_OK) {
--- a/drivers/net/ethernet/neterion/vxge/vxge-traffic.c	2011-09-16 13:12:56.533369674 -0700
+++ b/drivers/net/ethernet/neterion/vxge/vxge-traffic.c	2011-09-16 13:21:30.925393238 -0700
@@ -532,8 +532,8 @@ __vxge_hw_device_handle_error(struct __v
 	}
 
 	/* notify driver */
-	if (hldev->uld_callbacks.crit_err)
-		hldev->uld_callbacks.crit_err(
+	if (hldev->uld_callbacks->crit_err)
+		hldev->uld_callbacks->crit_err(
 			(struct __vxge_hw_device *)hldev,
 			type, vp_id);
 out:
@@ -560,8 +560,8 @@ __vxge_hw_device_handle_link_down_ind(st
 	hldev->link_state = VXGE_HW_LINK_DOWN;
 
 	/* notify driver */
-	if (hldev->uld_callbacks.link_down)
-		hldev->uld_callbacks.link_down(hldev);
+	if (hldev->uld_callbacks->link_down)
+		hldev->uld_callbacks->link_down(hldev);
 exit:
 	return VXGE_HW_OK;
 }
@@ -585,8 +585,8 @@ __vxge_hw_device_handle_link_up_ind(stru
 	hldev->link_state = VXGE_HW_LINK_UP;
 
 	/* notify driver */
-	if (hldev->uld_callbacks.link_up)
-		hldev->uld_callbacks.link_up(hldev);
+	if (hldev->uld_callbacks->link_up)
+		hldev->uld_callbacks->link_up(hldev);
 exit:
 	return VXGE_HW_OK;
 }
