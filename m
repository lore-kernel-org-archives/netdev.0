From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net 2/4] hv_netvsc: reset vf_inject on VF removal
Date: Thu, 11 Aug 2016 12:58:55 +0200
Message-ID: <1470913137-29167-3-git-send-email-vkuznets@redhat.com>
References: <1470913137-29167-1-git-send-email-vkuznets@redhat.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"K. Y. Srinivasan" <kys@microsoft.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470913137-29167-1-git-send-email-vkuznets@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We reset vf_inject on VF going down (netvsc_vf_down()) but we don't on
VF removal (netvsc_unregister_vf()) so vf_inject stays 'true' while
vf_netdev is already NULL and we're trying to inject packets into NULL
net device in netvsc_recv_callback() causing kernel to crash.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/netvsc_drv.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 794139b..b3c31e3 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1216,6 +1216,19 @@ static int netvsc_register_vf(struct net_device *vf_netdev)
 	return NOTIFY_OK;
 }
 
+static void netvsc_inject_enable(struct net_device_context *net_device_ctx)
+{
+	net_device_ctx->vf_inject = true;
+}
+
+static void netvsc_inject_disable(struct net_device_context *net_device_ctx)
+{
+	net_device_ctx->vf_inject = false;
+
+	/* Wait for currently active users to drain out. */
+	while (atomic_read(&net_device_ctx->vf_use_cnt) != 0)
+		udelay(50);
+}
 
 static int netvsc_vf_up(struct net_device *vf_netdev)
 {
@@ -1238,7 +1251,7 @@ static int netvsc_vf_up(struct net_device *vf_netdev)
 		return NOTIFY_DONE;
 
 	netdev_info(ndev, "VF up: %s\n", vf_netdev->name);
-	net_device_ctx->vf_inject = true;
+	netvsc_inject_enable(net_device_ctx);
 
 	/*
 	 * Open the device before switching data path.
@@ -1288,14 +1301,7 @@ static int netvsc_vf_down(struct net_device *vf_netdev)
 		return NOTIFY_DONE;
 
 	netdev_info(ndev, "VF down: %s\n", vf_netdev->name);
-	net_device_ctx->vf_inject = false;
-	/*
-	 * Wait for currently active users to
-	 * drain out.
-	 */
-
-	while (atomic_read(&net_device_ctx->vf_use_cnt) != 0)
-		udelay(50);
+	netvsc_inject_disable(net_device_ctx);
 	netvsc_switch_datapath(ndev, false);
 	netdev_info(ndev, "Data path switched from VF: %s\n", vf_netdev->name);
 	rndis_filter_close(netvsc_dev);
@@ -1331,7 +1337,7 @@ static int netvsc_unregister_vf(struct net_device *vf_netdev)
 	if (netvsc_dev == NULL)
 		return NOTIFY_DONE;
 	netdev_info(ndev, "VF unregistering: %s\n", vf_netdev->name);
-
+	netvsc_inject_disable(net_device_ctx);
 	net_device_ctx->vf_netdev = NULL;
 	module_put(THIS_MODULE);
 	return NOTIFY_OK;
-- 
2.7.4
