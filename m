From: Neel Patel <neepatel@cisco.com>
Subject: [net-next PATCH 2/3] enic: Check firmware capability before issuing
	firmware commands
Date: Fri, 03 Feb 2012 10:25:19 -0800
Message-ID: <20120203182519.9156.96565.stgit@savbu-pc100.cisco.com>
References: <20120203182439.9156.37052.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:29823 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757451Ab2BCSet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 13:34:49 -0500
In-Reply-To: <20120203182439.9156.37052.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neel Patel <neepatel@cisco.com>

Check if firmware supports a particular command by first checking capability
using devcmd CMD_CAPABILITY.

Signed-off-by: Neel Patel <neepatel@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Nishank Trivedi <nistrive@cisco.com>
--
 drivers/net/ethernet/cisco/enic/enic.h     |    2 -
 drivers/net/ethernet/cisco/enic/vnic_dev.c |   58 +++++++++++++++-------------
 2 files changed, 32 insertions(+), 28 deletions(-)


diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 24bb088..54fd9c3 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.32"
+#define DRV_VERSION		"2.1.1.33"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index 31e7f9b..298ad6f 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -439,11 +439,12 @@ int vnic_dev_fw_info(struct vnic_dev *vdev,
 		a1 = sizeof(struct vnic_devcmd_fw_info);
 
 		/* only get fw_info once and cache it */
-		err = vnic_dev_cmd(vdev, CMD_MCPU_FW_INFO, &a0, &a1, wait);
-		if (err == ERR_ECMDUNKNOWN) {
+		if (vnic_dev_capable(vdev, CMD_MCPU_FW_INFO))
+			err = vnic_dev_cmd(vdev, CMD_MCPU_FW_INFO,
+				&a0, &a1, wait);
+		else
 			err = vnic_dev_cmd(vdev, CMD_MCPU_FW_INFO_OLD,
 				&a0, &a1, wait);
-		}
 	}
 
 	*fw_info = vdev->fw_info;
@@ -504,13 +505,11 @@ int vnic_dev_enable_wait(struct vnic_dev *vdev)
 {
 	u64 a0 = 0, a1 = 0;
 	int wait = 1000;
-	int err;
 
-	err = vnic_dev_cmd(vdev, CMD_ENABLE_WAIT, &a0, &a1, wait);
-	if (err == ERR_ECMDUNKNOWN)
+	if (vnic_dev_capable(vdev, CMD_ENABLE_WAIT))
+		return vnic_dev_cmd(vdev, CMD_ENABLE_WAIT, &a0, &a1, wait);
+	else
 		return vnic_dev_cmd(vdev, CMD_ENABLE, &a0, &a1, wait);
-
-	return err;
 }
 
 int vnic_dev_disable(struct vnic_dev *vdev)
@@ -574,16 +573,15 @@ int vnic_dev_hang_reset(struct vnic_dev *vdev, int arg)
 	int wait = 1000;
 	int err;
 
-	err = vnic_dev_cmd(vdev, CMD_HANG_RESET, &a0, &a1, wait);
-	if (err == ERR_ECMDUNKNOWN) {
+	if (vnic_dev_capable(vdev, CMD_HANG_RESET)) {
+		return vnic_dev_cmd(vdev, CMD_HANG_RESET,
+				&a0, &a1, wait);
+	} else {
 		err = vnic_dev_soft_reset(vdev, arg);
 		if (err)
 			return err;
-
 		return vnic_dev_init(vdev, 0);
 	}
-
-	return err;
 }
 
 int vnic_dev_hang_reset_done(struct vnic_dev *vdev, int *done)
@@ -594,11 +592,13 @@ int vnic_dev_hang_reset_done(struct vnic_dev *vdev, int *done)
 
 	*done = 0;
 
-	err = vnic_dev_cmd(vdev, CMD_HANG_RESET_STATUS, &a0, &a1, wait);
-	if (err) {
-		if (err == ERR_ECMDUNKNOWN)
-			return vnic_dev_soft_reset_done(vdev, done);
-		return err;
+	if (vnic_dev_capable(vdev, CMD_HANG_RESET_STATUS)) {
+		err = vnic_dev_cmd(vdev, CMD_HANG_RESET_STATUS,
+				&a0, &a1, wait);
+		if (err)
+			return err;
+	} else {
+		return vnic_dev_soft_reset_done(vdev, done);
 	}
 
 	*done = (a0 == 0);
@@ -691,13 +691,12 @@ int vnic_dev_set_ig_vlan_rewrite_mode(struct vnic_dev *vdev,
 {
 	u64 a0 = ig_vlan_rewrite_mode, a1 = 0;
 	int wait = 1000;
-	int err;
 
-	err = vnic_dev_cmd(vdev, CMD_IG_VLAN_REWRITE_MODE, &a0, &a1, wait);
-	if (err == ERR_ECMDUNKNOWN)
+	if (vnic_dev_capable(vdev, CMD_IG_VLAN_REWRITE_MODE))
+		return vnic_dev_cmd(vdev, CMD_IG_VLAN_REWRITE_MODE,
+				&a0, &a1, wait);
+	else
 		return 0;
-
-	return err;
 }
 
 static int vnic_dev_notify_setcmd(struct vnic_dev *vdev,
@@ -835,7 +834,10 @@ int vnic_dev_intr_coal_timer_info(struct vnic_dev *vdev)
 
 	memset(vdev->args, 0, sizeof(vdev->args));
 
-	err = _vnic_dev_cmd(vdev, CMD_INTR_COAL_CONVERT, wait);
+	if (vnic_dev_capable(vdev, CMD_INTR_COAL_CONVERT))
+		err = _vnic_dev_cmd(vdev, CMD_INTR_COAL_CONVERT, wait);
+	else
+		err = ERR_ECMDUNKNOWN;
 
 	/* Use defaults when firmware doesn't support the devcmd at all or
 	 * supports it for only specific hardware
@@ -848,9 +850,11 @@ int vnic_dev_intr_coal_timer_info(struct vnic_dev *vdev)
 		return 0;
 	}
 
-	vdev->intr_coal_timer_info.mul = (u32) vdev->args[0];
-	vdev->intr_coal_timer_info.div = (u32) vdev->args[1];
-	vdev->intr_coal_timer_info.max_usec = (u32) vdev->args[2];
+	if (!err) {
+		vdev->intr_coal_timer_info.mul = (u32) vdev->args[0];
+		vdev->intr_coal_timer_info.div = (u32) vdev->args[1];
+		vdev->intr_coal_timer_info.max_usec = (u32) vdev->args[2];
+	}
 
 	return err;
 }
