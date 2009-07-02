From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 6/9] vxge: Fixes in isr routine
Date: Thu, 2 Jul 2009 03:16:37 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10907020315430.13763-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:37654 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbZGBHRl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 03:17:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Fixes in isr routine
   Fixed crash with INTA mode during driver unload. Pass hldev to request_irq 
   instead of vdev.
   Fixed Traffic failure with GRO in INTA mode. Pass the correct napi 
   context to gro functions.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch_5/drivers/net/vxge/vxge-main.c patch_6/drivers/net/vxge/vxge-main.c
--- patch_5/drivers/net/vxge/vxge-main.c	2009-06-26 11:15:59.000000000 +0530
+++ patch_6/drivers/net/vxge/vxge-main.c	2009-06-26 11:23:04.000000000 +0530
@@ -374,10 +374,10 @@ vxge_rx_complete(struct vxge_ring *ring,
 		if (ring->vlgrp && ext_info->vlan &&
 			(ring->vlan_tag_strip ==
 				VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_ENABLE))
-			vlan_gro_receive(&ring->napi, ring->vlgrp,
+			vlan_gro_receive(ring->napi_p, ring->vlgrp,
 					ext_info->vlan, skb);
 		else
-			napi_gro_receive(&ring->napi, skb);
+			napi_gro_receive(ring->napi_p, skb);
 	} else {
 		if (ring->vlgrp && vlan &&
 			(ring->vlan_tag_strip ==
@@ -2132,16 +2132,16 @@ int vxge_open_vpaths(struct vxgedev *vde
  */
 static irqreturn_t vxge_isr_napi(int irq, void *dev_id)
 {
-	struct __vxge_hw_device  *hldev = (struct __vxge_hw_device  *)dev_id;
-	struct vxgedev *vdev;
 	struct net_device *dev;
+	struct __vxge_hw_device *hldev;
 	u64 reason;
 	enum vxge_hw_status status;
+	struct vxgedev *vdev = (struct vxgedev *) dev_id;;
 
 	vxge_debug_intr(VXGE_TRACE, "%s:%d", __func__, __LINE__);
 
-	dev = hldev->ndev;
-	vdev = netdev_priv(dev);
+	dev = vdev->ndev;
+	hldev = (struct __vxge_hw_device *)pci_get_drvdata(vdev->pdev);
 
 	if (pci_channel_offline(vdev->pdev))
 		return IRQ_NONE;
@@ -2412,15 +2412,13 @@ static void vxge_rem_isr(struct vxgedev 
 #endif
 	if (vdev->config.intr_type == INTA) {
 			synchronize_irq(vdev->pdev->irq);
-			free_irq(vdev->pdev->irq, hldev);
+			free_irq(vdev->pdev->irq, vdev);
 	}
 }
 
 static int vxge_add_isr(struct vxgedev *vdev)
 {
 	int ret = 0;
-	struct __vxge_hw_device  *hldev =
-		(struct __vxge_hw_device  *) pci_get_drvdata(vdev->pdev);
 #ifdef CONFIG_PCI_MSI
 	int vp_idx = 0, intr_idx = 0, intr_cnt = 0, msix_idx = 0, irq_req = 0;
 	u64 function_mode = vdev->config.device_hw_info.function_mode;
@@ -2574,7 +2572,7 @@ INTA_MODE:
 	if (vdev->config.intr_type == INTA) {
 		ret = request_irq((int) vdev->pdev->irq,
 			vxge_isr_napi,
-			IRQF_SHARED, vdev->desc[0], hldev);
+			IRQF_SHARED, vdev->desc[0], vdev);
 		if (ret) {
 			vxge_debug_init(VXGE_ERR,
 				"%s %s-%d: ISR registration failed",
@@ -2707,11 +2705,15 @@ vxge_open(struct net_device *dev)
 		netif_napi_add(dev, &vdev->napi, vxge_poll_inta,
 			vdev->config.napi_weight);
 		napi_enable(&vdev->napi);
+		for (i = 0; i < vdev->no_of_vpath; i++)
+			vdev->vpaths[i].ring.napi_p = &vdev->napi;
 	} else {
 		for (i = 0; i < vdev->no_of_vpath; i++) {
 			netif_napi_add(dev, &vdev->vpaths[i].ring.napi,
 			    vxge_poll_msix, vdev->config.napi_weight);
 			napi_enable(&vdev->vpaths[i].ring.napi);
+			vdev->vpaths[i].ring.napi_p =
+				&vdev->vpaths[i].ring.napi;
 		}
 	}
 
diff -urpN patch_5/drivers/net/vxge/vxge-main.h patch_6/drivers/net/vxge/vxge-main.h
--- patch_5/drivers/net/vxge/vxge-main.h	2009-06-26 11:15:59.000000000 +0530
+++ patch_6/drivers/net/vxge/vxge-main.h	2009-06-26 09:46:27.000000000 +0530
@@ -260,6 +260,7 @@ struct vxge_ring {
 	int gro_enable;
 
 	struct napi_struct napi;
+	struct napi_struct *napi_p;
 
 #define VXGE_MAX_MAC_ADDR_COUNT		30
 

