From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH] vxge: fix memory leak in vxge_alloc_msix() error path
Date: Thu, 24 Jun 2010 16:13:44 +0200
Message-ID: <20100624161344.0847a7ca@leela>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753666Ab0FXONt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jun 2010 10:13:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When pci_enable_msix() returned ret<0, entries and vxge_entries were leaked.
While at it, use the centralized exit idiom in the function.

Not tested. It compiles OK.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/vxge/vxge-main.c |   29 ++++++++++++++++++++---------
 1 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 45c5dc2..8b9e73b 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -2262,7 +2262,8 @@ start:
 		vxge_debug_init(VXGE_ERR,
 			"%s: memory allocation failed",
 			VXGE_DRIVER_NAME);
-		return  -ENOMEM;
+		ret = -ENOMEM;
+		goto alloc_entries_failed;
 	}
 
 	vdev->vxge_entries =
@@ -2271,8 +2272,8 @@ start:
 	if (!vdev->vxge_entries) {
 		vxge_debug_init(VXGE_ERR, "%s: memory allocation failed",
 			VXGE_DRIVER_NAME);
-		kfree(vdev->entries);
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto alloc_vxge_entries_failed;
 	}
 
 	for (i = 0, j = 0; i < vdev->no_of_vpath; i++) {
@@ -2303,22 +2304,32 @@ start:
 		vxge_debug_init(VXGE_ERR,
 			"%s: MSI-X enable failed for %d vectors, ret: %d",
 			VXGE_DRIVER_NAME, vdev->intr_cnt, ret);
+		if ((max_config_vpath != VXGE_USE_DEFAULT) || (ret < 3)) {
+			ret = -ENODEV;
+			goto enable_msix_failed;
+		}
+
 		kfree(vdev->entries);
 		kfree(vdev->vxge_entries);
 		vdev->entries = NULL;
 		vdev->vxge_entries = NULL;
-
-		if ((max_config_vpath != VXGE_USE_DEFAULT) || (ret < 3))
-			return -ENODEV;
 		/* Try with less no of vector by reducing no of vpaths count */
 		temp = (ret - 1)/2;
 		vxge_close_vpaths(vdev, temp);
 		vdev->no_of_vpath = temp;
 		goto start;
-	} else if (ret < 0)
-		return -ENODEV;
-
+	} else if (ret < 0) {
+		ret = -ENODEV;
+		goto enable_msix_failed;
+	}
 	return 0;
+
+enable_msix_failed:
+	kfree(vdev->vxge_entries);
+alloc_vxge_entries_failed:
+	kfree(vdev->entries);
+alloc_entries_failed:
+	return ret;
 }
 
 static int vxge_enable_msix(struct vxgedev *vdev)
-- 
1.7.1

