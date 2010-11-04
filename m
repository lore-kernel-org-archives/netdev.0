From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 07/11] vxge: Handle errors in vxge_hw_vpath_fw_api
Date: Thu,  4 Nov 2010 17:51:58 -0500
Message-ID: <1288911122-28669-7-git-send-email-jon.mason@exar.com>
References: <1288911122-28669-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:64769 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430Ab0KDWwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Nov 2010 18:52:47 -0400
Received: by mail-gy0-f174.google.com with SMTP id 4so1850811gyh.19
        for <netdev@vger.kernel.org>; Thu, 04 Nov 2010 15:52:47 -0700 (PDT)
In-Reply-To: <1288911122-28669-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Propagate the return code of the call to vxge_hw_vpath_fw_api and
__vxge_hw_vpath_pci_func_mode_get.  This enables the proper handling of
error conditions when querying the function mode of the device during
probe.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-config.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index bc7cc16..15623ca 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -955,8 +955,9 @@ __vxge_hw_vpath_card_info_get(struct __vxge_hw_virtualpath *vpath,
  * __vxge_hw_vpath_pci_func_mode_get - Get the pci mode
  * Returns pci function mode
  */
-static u64
-__vxge_hw_vpath_pci_func_mode_get(struct __vxge_hw_virtualpath *vpath)
+static enum vxge_hw_status
+__vxge_hw_vpath_pci_func_mode_get(struct __vxge_hw_virtualpath *vpath,
+				  struct vxge_hw_device_hw_info *hw_info)
 {
 	u64 data0, data1 = 0, steer_ctrl = 0;
 	enum vxge_hw_status status;
@@ -967,8 +968,11 @@ __vxge_hw_vpath_pci_func_mode_get(struct __vxge_hw_virtualpath *vpath)
 			VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_READ_MEMO_ENTRY,
 			VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_FW_MEMO,
 			0, &data0, &data1, &steer_ctrl);
+	if (status != VXGE_HW_OK)
+		return status;
 
-	return data0;
+	hw_info->function_mode = data0;
+	return status;
 }
 
 /*
@@ -1083,8 +1087,9 @@ vxge_hw_device_hw_info_get(void __iomem *bar0,
 			       (bar0 + val64);
 		vpath.vp_open = 0;
 
-		hw_info->function_mode =
-			__vxge_hw_vpath_pci_func_mode_get(&vpath);
+		status = __vxge_hw_vpath_pci_func_mode_get(&vpath, hw_info);
+		if (status != VXGE_HW_OK)
+			goto exit;
 
 		status = __vxge_hw_vpath_fw_ver_get(&vpath, hw_info);
 		if (status != VXGE_HW_OK)
-- 
1.7.0.4

