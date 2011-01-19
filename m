From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 1/4] vxge: cleanup probe error paths
Date: Tue, 18 Jan 2011 19:02:19 -0600
Message-ID: <1295398942-4131-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:57990 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992Ab1ASBC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 20:02:29 -0500
Received: by qyj19 with SMTP id 19so3871582qyj.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 17:02:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reorder the commands to be in the inverse order of their allocations
(instead of the random order they appear to be in), propagate return
code on errors from pci_request_region and register_netdev, reduce the
config_dev_cnt and total_dev_cnt counters on remove, and return the
correct error code for vdev->vpaths kzalloc failures.  Also, prevent
leaking of vdev->vpaths memory and netdev in vxge_probe error path due
to freeing for these not occurring in vxge_device_unregister.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Sivakumar Subramani <sivakumar.subramani@exar.com>
---
 drivers/net/vxge/vxge-main.c |   55 +++++++++++++++++++-----------------------
 1 files changed, 25 insertions(+), 30 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 1ac9b56..cd0698c 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -3348,7 +3348,7 @@ static int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 		vxge_debug_init(VXGE_ERR,
 			"%s: vpath memory allocation failed",
 			vdev->ndev->name);
-		ret = -ENODEV;
+		ret = -ENOMEM;
 		goto _out1;
 	}
 
@@ -3369,11 +3369,11 @@ static int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 	if (vdev->config.gro_enable)
 		ndev->features |= NETIF_F_GRO;
 
-	if (register_netdev(ndev)) {
+	ret = register_netdev(ndev);
+	if (ret) {
 		vxge_debug_init(vxge_hw_device_trace_level_get(hldev),
 			"%s: %s : device registration failed!",
 			ndev->name, __func__);
-		ret = -ENODEV;
 		goto _out2;
 	}
 
@@ -3444,6 +3444,11 @@ static void vxge_device_unregister(struct __vxge_hw_device *hldev)
 	/* in 2.6 will call stop() if device is up */
 	unregister_netdev(dev);
 
+	kfree(vdev->vpaths);
+
+	/* we are safe to free it now */
+	free_netdev(dev);
+
 	vxge_debug_init(vdev->level_trace, "%s: ethernet device unregistered",
 			buf);
 	vxge_debug_entryexit(vdev->level_trace,	"%s: %s:%d  Exiting...", buf,
@@ -4334,10 +4339,10 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 		goto _exit1;
 	}
 
-	if (pci_request_region(pdev, 0, VXGE_DRIVER_NAME)) {
+	ret = pci_request_region(pdev, 0, VXGE_DRIVER_NAME);
+	if (ret) {
 		vxge_debug_init(VXGE_ERR,
 			"%s : request regions failed", __func__);
-		ret = -ENODEV;
 		goto _exit1;
 	}
 
@@ -4642,8 +4647,9 @@ _exit6:
 _exit5:
 	vxge_device_unregister(hldev);
 _exit4:
-	pci_disable_sriov(pdev);
+	pci_set_drvdata(pdev, NULL);
 	vxge_hw_device_terminate(hldev);
+	pci_disable_sriov(pdev);
 _exit3:
 	iounmap(attr.bar0);
 _exit2:
@@ -4654,7 +4660,7 @@ _exit0:
 	kfree(ll_config);
 	kfree(device_config);
 	driver_config->config_dev_cnt--;
-	pci_set_drvdata(pdev, NULL);
+	driver_config->total_dev_cnt--;
 	return ret;
 }
 
@@ -4667,45 +4673,34 @@ _exit0:
 static void __devexit vxge_remove(struct pci_dev *pdev)
 {
 	struct __vxge_hw_device *hldev;
-	struct vxgedev *vdev = NULL;
-	struct net_device *dev;
-	int i = 0;
+	struct vxgedev *vdev;
+	int i;
 
 	hldev = pci_get_drvdata(pdev);
-
 	if (hldev == NULL)
 		return;
 
-	dev = hldev->ndev;
-	vdev = netdev_priv(dev);
+	vdev = netdev_priv(hldev->ndev);
 
 	vxge_debug_entryexit(vdev->level_trace,	"%s:%d", __func__, __LINE__);
-
 	vxge_debug_init(vdev->level_trace, "%s : removing PCI device...",
 			__func__);
-	vxge_device_unregister(hldev);
 
-	for (i = 0; i < vdev->no_of_vpath; i++) {
+	for (i = 0; i < vdev->no_of_vpath; i++)
 		vxge_free_mac_add_list(&vdev->vpaths[i]);
-		vdev->vpaths[i].mcast_addr_cnt = 0;
-		vdev->vpaths[i].mac_addr_cnt = 0;
-	}
-
-	kfree(vdev->vpaths);
 
+	vxge_device_unregister(hldev);
+	pci_set_drvdata(pdev, NULL);
+	/* Do not call pci_disable_sriov here, as it will break child devices */
+	vxge_hw_device_terminate(hldev);
 	iounmap(vdev->bar0);
-
-	/* we are safe to free it now */
-	free_netdev(dev);
+	pci_release_region(pdev, 0);
+	pci_disable_device(pdev);
+	driver_config->config_dev_cnt--;
+	driver_config->total_dev_cnt--;
 
 	vxge_debug_init(vdev->level_trace, "%s:%d Device unregistered",
 			__func__, __LINE__);
-
-	vxge_hw_device_terminate(hldev);
-
-	pci_disable_device(pdev);
-	pci_release_region(pdev, 0);
-	pci_set_drvdata(pdev, NULL);
 	vxge_debug_entryexit(vdev->level_trace,	"%s:%d  Exiting...", __func__,
 			     __LINE__);
 }
-- 
1.7.0.4

