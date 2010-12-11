From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 2/7] vxge: fix crash of VF when unloading PF
Date: Fri, 10 Dec 2010 18:02:57 -0600
Message-ID: <1292025782-16372-2-git-send-email-jon.mason@exar.com>
References: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:45252 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756532Ab0LKADQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:03:16 -0500
Received: by mail-yw0-f46.google.com with SMTP id 5so2401509ywl.19
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 16:03:16 -0800 (PST)
In-Reply-To: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling pci_disable_sriov when unloading a SR-IOV physical function
driver from a host when a guest is using a virtual function from that
device can cause a host crash or VM crash.  The crash is caused by the
virtual config space no longer being present when PF is removed (due to
the pci_disable_sriov).  This can be avoided by not calling
pci_disable_sriov to disable the PCI space when shutting down the PF.
Each function in the X3100 operates independently and in this case will
operate properly in the absence of the PF.

Also, added improved logic in the detection of SR-IOV initialization.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-main.c |   25 ++++++++++++++++++-------
 1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 70c3279..9c68c60 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -4182,6 +4182,20 @@ static int vxge_probe_fw_update(struct vxgedev *vdev)
 	return ret;
 }
 
+static int __devinit is_sriov_initialized(struct pci_dev *pdev)
+{
+	int pos;
+	u16 ctrl;
+
+	pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_SRIOV);
+	if (pos) {
+		pci_read_config_word(pdev, pos + PCI_SRIOV_CTRL, &ctrl);
+		if (ctrl & PCI_SRIOV_CTRL_VFE)
+			return 1;
+	}
+	return 0;
+}
+
 /**
  * vxge_probe
  * @pdev : structure containing the PCI related information of the device.
@@ -4370,14 +4384,13 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 		num_vfs = vxge_get_num_vfs(function_mode) - 1;
 
 	/* Enable SRIOV mode, if firmware has SRIOV support and if it is a PF */
-	if (is_sriov(function_mode) && (max_config_dev > 1) &&
-		(ll_config->intr_type != INTA) &&
-		(is_privileged == VXGE_HW_OK)) {
-		ret = pci_enable_sriov(pdev, ((max_config_dev - 1) < num_vfs)
-			? (max_config_dev - 1) : num_vfs);
+	if (is_sriov(function_mode) && !is_sriov_initialized(pdev) &&
+	   (ll_config->intr_type != INTA)) {
+		ret = pci_enable_sriov(pdev, num_vfs);
 		if (ret)
 			vxge_debug_ll_config(VXGE_ERR,
 				"Failed in enabling SRIOV mode: %d\n", ret);
+			/* No need to fail out, as an error here is non-fatal */
 	}
 
 	/*
@@ -4673,8 +4686,6 @@ static void __devexit vxge_remove(struct pci_dev *pdev)
 
 	iounmap(vdev->bar0);
 
-	pci_disable_sriov(pdev);
-
 	/* we are safe to free it now */
 	free_netdev(dev);
 
-- 
1.7.0.4

