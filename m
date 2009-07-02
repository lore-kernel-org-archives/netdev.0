From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 1/9] vxge: Removed ioremap of unused bar addresses
 and their references
Date: Thu, 2 Jul 2009 03:12:23 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10907020309550.13763-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:37775 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749AbZGBH0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 03:26:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Removed ioremap of bar1 address
  Driver needs only bar0 address for register access 
- Removed references to bar1 and bar2 addresses

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN org/drivers/net/vxge/vxge-config.c patch_1/drivers/net/vxge/vxge-config.c
--- org/drivers/net/vxge/vxge-config.c	2009-06-21 23:19:59.000000000 -0700
+++ patch_1/drivers/net/vxge/vxge-config.c	2009-06-21 23:24:12.000000000 -0700
@@ -313,14 +313,6 @@ __vxge_hw_device_reg_addr_get(struct __v
 		hldev->kdfc = (u8 __iomem *)(hldev->bar0 +
 			VXGE_HW_TOC_GET_KDFC_INITIAL_OFFSET(val64));
 		break;
-	case 2:
-		hldev->kdfc = (u8 __iomem *)(hldev->bar1 +
-			VXGE_HW_TOC_GET_KDFC_INITIAL_OFFSET(val64));
-		break;
-	case 4:
-		hldev->kdfc = (u8 __iomem *)(hldev->bar2 +
-			VXGE_HW_TOC_GET_KDFC_INITIAL_OFFSET(val64));
-		break;
 	default:
 		break;
 	}
@@ -831,8 +823,6 @@ vxge_hw_device_initialize(
 		sizeof(struct vxge_hw_device_config));
 
 	hldev->bar0 = attr->bar0;
-	hldev->bar1 = attr->bar1;
-	hldev->bar2 = attr->bar2;
 	hldev->pdev = attr->pdev;
 
 	hldev->uld_callbacks.link_up = attr->uld_callbacks.link_up;
diff -urpN org/drivers/net/vxge/vxge-config.h patch_1/drivers/net/vxge/vxge-config.h
--- org/drivers/net/vxge/vxge-config.h	2009-06-21 23:19:59.000000000 -0700
+++ patch_1/drivers/net/vxge/vxge-config.h	2009-06-21 23:25:28.000000000 -0700
@@ -682,8 +682,6 @@ struct __vxge_hw_vpath_handle{
  * @major_revision: PCI Device major revision
  * @minor_revision: PCI Device minor revision
  * @bar0: BAR0 virtual address.
- * @bar1: BAR1 virtual address.
- * @bar2: BAR2 virtual address.
  * @pdev: Physical device handle
  * @config: Confguration passed by the LL driver at initialization
  * @link_state: Link state
@@ -698,8 +696,6 @@ struct __vxge_hw_device {
 	u8				major_revision;
 	u8				minor_revision;
 	void __iomem			*bar0;
-	void __iomem			*bar1;
-	void __iomem			*bar2;
 	struct pci_dev			*pdev;
 	struct net_device		*ndev;
 	struct vxge_hw_device_config	config;
@@ -788,17 +784,13 @@ struct vxge_hw_device_hw_info {
 /**
  * struct vxge_hw_device_attr - Device memory spaces.
  * @bar0: BAR0 virtual address.
- * @bar1: BAR1 virtual address.
- * @bar2: BAR2 virtual address.
  * @pdev: PCI device object.
  *
- * Device memory spaces. Includes configuration, BAR0, BAR1, etc. per device
+ * Device memory spaces. Includes configuration, BAR0 etc. per device
  * mapped memories. Also, includes a pointer to OS-specific PCI device object.
  */
 struct vxge_hw_device_attr {
 	void __iomem		*bar0;
-	void __iomem		*bar1;
-	void __iomem		*bar2;
 	struct pci_dev 		*pdev;
 	struct vxge_hw_uld_cbs	uld_callbacks;
 };
diff -urpN org/drivers/net/vxge/vxge-main.c patch_1/drivers/net/vxge/vxge-main.c
--- org/drivers/net/vxge/vxge-main.c	2009-06-21 23:19:59.000000000 -0700
+++ patch_1/drivers/net/vxge/vxge-main.c	2009-06-21 23:32:44.000000000 -0700
@@ -4152,18 +4152,6 @@ vxge_probe(struct pci_dev *pdev, const s
 		attr.bar0,
 		(unsigned long long)pci_resource_start(pdev, 0));
 
-	attr.bar1 = pci_ioremap_bar(pdev, 2);
-	if (!attr.bar1) {
-		vxge_debug_init(VXGE_ERR,
-			"%s : cannot remap io memory bar2", __func__);
-		ret = -ENODEV;
-		goto _exit3;
-	}
-	vxge_debug_ll_config(VXGE_TRACE,
-		"pci ioremap bar1: %p:0x%llx",
-		attr.bar1,
-		(unsigned long long)pci_resource_start(pdev, 2));
-
 	status = vxge_hw_device_hw_info_get(attr.bar0,
 			&ll_config.device_hw_info);
 	if (status != VXGE_HW_OK) {
@@ -4171,7 +4159,7 @@ vxge_probe(struct pci_dev *pdev, const s
 			"%s: Reading of hardware info failed."
 			"Please try upgrading the firmware.", VXGE_DRIVER_NAME);
 		ret = -EINVAL;
-		goto _exit4;
+		goto _exit3;
 	}
 
 	if (ll_config.device_hw_info.fw_version.major !=
@@ -4181,7 +4169,7 @@ vxge_probe(struct pci_dev *pdev, const s
 			ll_config.device_hw_info.fw_version.major,
 			VXGE_DRIVER_VERSION_MAJOR);
 		ret = -EINVAL;
-		goto _exit4;
+		goto _exit3;
 	}
 
 	vpath_mask = ll_config.device_hw_info.vpath_mask;
@@ -4189,7 +4177,7 @@ vxge_probe(struct pci_dev *pdev, const s
 		vxge_debug_ll_config(VXGE_TRACE,
 			"%s: No vpaths available in device", VXGE_DRIVER_NAME);
 		ret = -EINVAL;
-		goto _exit4;
+		goto _exit3;
 	}
 
 	vxge_debug_ll_config(VXGE_TRACE,
@@ -4222,7 +4210,7 @@ vxge_probe(struct pci_dev *pdev, const s
 		vxge_debug_ll_config(VXGE_ERR,
 			"%s: No more vpaths to configure", VXGE_DRIVER_NAME);
 		ret = 0;
-		goto _exit4;
+		goto _exit3;
 	}
 
 	/* Setting driver callbacks */
@@ -4235,7 +4223,7 @@ vxge_probe(struct pci_dev *pdev, const s
 		vxge_debug_init(VXGE_ERR,
 			"Failed to initialize device (%d)", status);
 			ret = -EINVAL;
-			goto _exit4;
+			goto _exit3;
 	}
 
 	vxge_hw_device_debug_set(hldev, VXGE_ERR, VXGE_COMPONENT_LL);
@@ -4260,7 +4248,7 @@ vxge_probe(struct pci_dev *pdev, const s
 	if (vxge_device_register(hldev, &ll_config, high_dma, no_of_vpath,
 		&vdev)) {
 		ret = -EINVAL;
-		goto _exit5;
+		goto _exit4;
 	}
 
 	vxge_hw_device_debug_set(hldev, VXGE_TRACE, VXGE_COMPONENT_LL);
@@ -4271,7 +4259,6 @@ vxge_probe(struct pci_dev *pdev, const s
 	hldev->ndev = vdev->ndev;
 	vdev->mtu = VXGE_HW_DEFAULT_MTU;
 	vdev->bar0 = attr.bar0;
-	vdev->bar1 = attr.bar1;
 	vdev->max_vpath_supported = max_vpath_supported;
 	vdev->no_of_vpath = no_of_vpath;
 
@@ -4353,7 +4340,7 @@ vxge_probe(struct pci_dev *pdev, const s
 				"%s: mac_addr_list : memory allocation failed",
 				vdev->ndev->name);
 			ret = -EPERM;
-			goto _exit6;
+			goto _exit5;
 		}
 		macaddr = (u8 *)&entry->macaddr;
 		memcpy(macaddr, vdev->ndev->dev_addr, ETH_ALEN);
@@ -4370,16 +4357,14 @@ vxge_probe(struct pci_dev *pdev, const s
 
 	return 0;
 
-_exit6:
+_exit5:
 	for (i = 0; i < vdev->no_of_vpath; i++)
 		vxge_free_mac_add_list(&vdev->vpaths[i]);
 
 	vxge_device_unregister(hldev);
-_exit5:
+_exit4:
 	pci_disable_sriov(pdev);
 	vxge_hw_device_terminate(hldev);
-_exit4:
-	iounmap(attr.bar1);
 _exit3:
 	iounmap(attr.bar0);
 _exit2:
@@ -4438,7 +4423,6 @@ vxge_remove(struct pci_dev *pdev)
 	kfree(vdev->vpaths);
 
 	iounmap(vdev->bar0);
-	iounmap(vdev->bar1);
 
 	pci_disable_sriov(pdev);
 
diff -urpN org/drivers/net/vxge/vxge-main.h patch_1/drivers/net/vxge/vxge-main.h
--- org/drivers/net/vxge/vxge-main.h	2009-06-21 23:19:59.000000000 -0700
+++ patch_1/drivers/net/vxge/vxge-main.h	2009-06-21 23:24:37.000000000 -0700
@@ -363,7 +363,6 @@ struct vxgedev {
 
 	struct __vxge_hw_vpath_handle *vp_handles[VXGE_HW_MAX_VIRTUAL_PATHS];
 	void __iomem *bar0;
-	void __iomem *bar1;
 	struct vxge_sw_stats	stats;
 	int		mtu;
 	/* Below variables are used for vpath selection to transmit a packet */

