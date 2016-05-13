From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next v2 2/6] hv_netvsc: use start_remove flag to protect
 netvsc_link_change()
Date: Fri, 13 May 2016 13:55:21 +0200
Message-ID: <1463140525-27338-3-git-send-email-vkuznets@redhat.com>
References: <1463140525-27338-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org, Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1463140525-27338-1-git-send-email-vkuznets@redhat.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

netvsc_link_change() can race with netvsc_change_mtu() or
netvsc_set_channels() as these functions destroy struct netvsc_device and
rndis filter. Use start_remove flag for syncronization. As
netvsc_change_mtu()/netvsc_set_channels() are called with rtnl lock held
we need to take it before checking start_remove value in
netvsc_link_change().

Reported-by: Haiyang Zhang <haiyangz@microsoft.com>
Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/netvsc_drv.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index b3fa2cd..01de2dc 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -838,6 +838,8 @@ static int netvsc_set_channels(struct net_device *net,
  out:
 	netvsc_open(net);
 	net_device_ctx->start_remove = false;
+	/* We may have missed link change notifications */
+	schedule_delayed_work(&net_device_ctx->dwork, 0);
 
 	return ret;
 
@@ -946,6 +948,9 @@ out:
 	netvsc_open(ndev);
 	ndevctx->start_remove = false;
 
+	/* We may have missed link change notifications */
+	schedule_delayed_work(&ndevctx->dwork, 0);
+
 	return ret;
 }
 
@@ -1066,6 +1071,11 @@ static void netvsc_link_change(struct work_struct *w)
 	unsigned long flags, next_reconfig, delay;
 
 	ndev_ctx = container_of(w, struct net_device_context, dwork.work);
+
+	rtnl_lock();
+	if (ndev_ctx->start_remove)
+		goto out_unlock;
+
 	net_device = hv_get_drvdata(ndev_ctx->device_ctx);
 	rdev = net_device->extension;
 	net = net_device->ndev;
@@ -1079,7 +1089,7 @@ static void netvsc_link_change(struct work_struct *w)
 		delay = next_reconfig - jiffies;
 		delay = delay < LINKCHANGE_INT ? delay : LINKCHANGE_INT;
 		schedule_delayed_work(&ndev_ctx->dwork, delay);
-		return;
+		goto out_unlock;
 	}
 	ndev_ctx->last_reconfig = jiffies;
 
@@ -1093,9 +1103,7 @@ static void netvsc_link_change(struct work_struct *w)
 	spin_unlock_irqrestore(&ndev_ctx->lock, flags);
 
 	if (!event)
-		return;
-
-	rtnl_lock();
+		goto out_unlock;
 
 	switch (event->event) {
 		/* Only the following events are possible due to the check in
@@ -1144,6 +1152,11 @@ static void netvsc_link_change(struct work_struct *w)
 	 */
 	if (reschedule)
 		schedule_delayed_work(&ndev_ctx->dwork, LINKCHANGE_INT);
+
+	return;
+
+out_unlock:
+	rtnl_unlock();
 }
 
 static void netvsc_free_netdev(struct net_device *netdev)
-- 
2.5.5
