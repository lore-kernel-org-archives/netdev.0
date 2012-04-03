From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] vxge: Convert macro to inline function
Date: Tue, 03 Apr 2012 15:14:31 -0700
Message-ID: <1333491271.2695.20.camel@joe2Laptop>
References: <1333489992.2695.17.camel@joe2Laptop>
	 <20120403.175837.1897033408784057713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jdmason@kudzu.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:41618 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754953Ab2DCWOd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 18:14:33 -0400
In-Reply-To: <20120403.175837.1897033408784057713.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the macro to inline function to check the arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
> Longer term I'd much rather see this turned into an inline
> function with proper type checking etc.

Something like this?

 drivers/net/ethernet/neterion/vxge/vxge-main.c |    6 +++---
 drivers/net/ethernet/neterion/vxge/vxge-main.h |   15 +++++++++------
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index ef76725..95fb611 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -2860,12 +2860,12 @@ static int vxge_open(struct net_device *dev)
 		vdev->config.rx_pause_enable);
 
 	if (vdev->vp_reset_timer.function == NULL)
-		vxge_os_timer(vdev->vp_reset_timer,
-			vxge_poll_vp_reset, vdev, (HZ/2));
+		vxge_os_timer(&vdev->vp_reset_timer, vxge_poll_vp_reset, vdev,
+			      HZ / 2);
 
 	/* There is no need to check for RxD leak and RxD lookup on Titan1A */
 	if (vdev->titan1 && vdev->vp_lockup_timer.function == NULL)
-		vxge_os_timer(vdev->vp_lockup_timer, vxge_poll_vp_lockup, vdev,
+		vxge_os_timer(&vdev->vp_lockup_timer, vxge_poll_vp_lockup, vdev,
 			      HZ / 2);
 
 	set_bit(__VXGE_STATE_CARD_UP, &vdev->state);
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.h b/drivers/net/ethernet/neterion/vxge/vxge-main.h
index f52a42d..35f3e75 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.h
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.h
@@ -416,12 +416,15 @@ struct vxge_tx_priv {
 	static int p = val; \
 	module_param(p, int, 0)
 
-#define vxge_os_timer(timer, handle, arg, exp) do { \
-		init_timer(&timer); \
-		timer.function = handle; \
-		timer.data = (unsigned long) arg; \
-		mod_timer(&timer, (jiffies + exp)); \
-	} while (0)
+static inline
+void vxge_os_timer(struct timer_list *timer, void (*func)(unsigned long data),
+		   struct vxgedev *vdev, unsigned long timeout)
+{
+	init_timer(timer);
+	timer->function = func;
+	timer->data = (unsigned long)vdev;
+	mod_timer(timer, jiffies + timeout);
+}
 
 void vxge_initialize_ethtool_ops(struct net_device *ndev);
 enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev);
