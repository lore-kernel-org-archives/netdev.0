From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 4/7] vxge: transmit timeout deadlock
Date: Fri, 10 Dec 2010 18:02:59 -0600
Message-ID: <1292025782-16372-4-git-send-email-jon.mason@exar.com>
References: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:59515 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756503Ab0LKADa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:03:30 -0500
Received: by gyb11 with SMTP id 11so2119446gyb.19
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 16:03:29 -0800 (PST)
In-Reply-To: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a workqueue to handle the device reset during a transmit timeout, as
there can be a deadlock during bringup.  Also, set the netif carrier off
before the watchdog reset is started to prevent the timeout from
reoccurring while still processing the first.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-main.c |   19 ++++++++++++++-----
 drivers/net/vxge/vxge-main.h |    1 +
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index faebffb..3ec8068 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -1606,12 +1606,16 @@ static int do_vxge_reset(struct vxgedev *vdev, int event)
 	}
 
 	if (event == VXGE_LL_FULL_RESET) {
+		netif_carrier_off(vdev->ndev);
+
 		/* wait for all the vpath reset to complete */
 		for (vp_id = 0; vp_id < vdev->no_of_vpath; vp_id++) {
 			while (test_bit(vp_id, &vdev->vp_reset))
 				msleep(50);
 		}
 
+		netif_carrier_on(vdev->ndev);
+
 		/* if execution mode is set to debug, don't reset the adapter */
 		if (unlikely(vdev->exec_mode)) {
 			vxge_debug_init(VXGE_ERR,
@@ -1765,9 +1769,14 @@ out:
  *
  * driver may reset the chip on events of serr, eccerr, etc
  */
-static int vxge_reset(struct vxgedev *vdev)
+static void vxge_reset(struct work_struct *work)
 {
-	return do_vxge_reset(vdev, VXGE_LL_FULL_RESET);
+	struct vxgedev *vdev = container_of(work, struct vxgedev, reset_task);
+
+	if (!netif_running(vdev->ndev))
+		return;
+
+	do_vxge_reset(vdev, VXGE_LL_FULL_RESET);
 }
 
 /**
@@ -3111,8 +3120,7 @@ static int vxge_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
  * This function is triggered if the Tx Queue is stopped
  * for a pre-defined amount of time when the Interface is still up.
  */
-static void
-vxge_tx_watchdog(struct net_device *dev)
+static void vxge_tx_watchdog(struct net_device *dev)
 {
 	struct vxgedev *vdev;
 
@@ -3122,7 +3130,7 @@ vxge_tx_watchdog(struct net_device *dev)
 
 	vdev->cric_err_event = VXGE_HW_EVENT_RESET_START;
 
-	vxge_reset(vdev);
+	schedule_work(&vdev->reset_task);
 	vxge_debug_entryexit(VXGE_TRACE,
 		"%s:%d  Exiting...", __func__, __LINE__);
 }
@@ -3324,6 +3332,7 @@ static int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 	ndev->netdev_ops = &vxge_netdev_ops;
 
 	ndev->watchdog_timeo = VXGE_LL_WATCH_DOG_TIMEOUT;
+	INIT_WORK(&vdev->reset_task, vxge_reset);
 
 	vxge_initialize_ethtool_ops(ndev);
 
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
index 256d5b4..5746fed 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -395,6 +395,7 @@ struct vxgedev {
 	u32 		level_err;
 	u32 		level_trace;
 	char		fw_version[VXGE_HW_FW_STRLEN];
+	struct work_struct reset_task;
 };
 
 struct vxge_rx_priv {
-- 
1.7.0.4

