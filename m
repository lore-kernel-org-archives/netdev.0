From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net v2 3/5] hv_netvsc: reset vf_inject on VF removal
Date: Mon, 15 Aug 2016 17:48:41 +0200
Message-ID: <1471276123-24264-4-git-send-email-vkuznets@redhat.com>
References: <1471276123-24264-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1471276123-24264-1-git-send-email-vkuznets@redhat.com>
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

We reset vf_inject on VF going down (netvsc_vf_down()) but we don't on
VF removal (netvsc_unregister_vf()) so vf_inject stays 'true' while
vf_netdev is already NULL and we're trying to inject packets into NULL
net device in netvsc_recv_callback() causing kernel to crash.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
Acked-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 70317fa..2c90883 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1205,6 +1205,19 @@ static int netvsc_register_vf(struct net_device *vf_netdev)
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
@@ -1227,7 +1240,7 @@ static int netvsc_vf_up(struct net_device *vf_netdev)
 		return NOTIFY_DONE;
 
 	netdev_info(ndev, "VF up: %s\n", vf_netdev->name);
-	net_device_ctx->vf_inject = true;
+	netvsc_inject_enable(net_device_ctx);
 
 	/*
 	 * Open the device before switching data path.
@@ -1270,14 +1283,7 @@ static int netvsc_vf_down(struct net_device *vf_netdev)
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
@@ -1309,7 +1315,7 @@ static int netvsc_unregister_vf(struct net_device *vf_netdev)
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
