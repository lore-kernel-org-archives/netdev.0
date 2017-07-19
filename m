From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/8] netvsc: add some rtnl_dereference annotations
Date: Wed, 19 Jul 2017 11:53:13 -0700
Message-ID: <20170719185319.25871-3-sthemmin@microsoft.com>
References: <20170719185319.25871-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170719185319.25871-1-sthemmin@microsoft.com>
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

In a couple places RTNL is held, and the netvsc_device pointer
is acquired without annotation.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c     | 5 +++--
 drivers/net/hyperv/netvsc_drv.c | 7 ++++---
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 0a9167dd72fb..e202ec5d6f63 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -41,7 +41,7 @@ void netvsc_switch_datapath(struct net_device *ndev, bool vf)
 {
 	struct net_device_context *net_device_ctx = netdev_priv(ndev);
 	struct hv_device *dev = net_device_ctx->device_ctx;
-	struct netvsc_device *nv_dev = net_device_ctx->nvdev;
+	struct netvsc_device *nv_dev = rtnl_dereference(net_device_ctx->nvdev);
 	struct nvsp_message *init_pkt = &nv_dev->channel_init_pkt;
 
 	memset(init_pkt, 0, sizeof(struct nvsp_message));
@@ -549,7 +549,8 @@ void netvsc_device_remove(struct hv_device *device)
 {
 	struct net_device *ndev = hv_get_drvdata(device);
 	struct net_device_context *net_device_ctx = netdev_priv(ndev);
-	struct netvsc_device *net_device = net_device_ctx->nvdev;
+	struct netvsc_device *net_device
+		= rtnl_dereference(net_device_ctx->nvdev);
 	int i;
 
 	netvsc_disconnect_vsp(device);
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 09b07ca9e69a..e8e82a6a4b1a 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -69,7 +69,7 @@ static void netvsc_set_multicast_list(struct net_device *net)
 static int netvsc_open(struct net_device *net)
 {
 	struct net_device_context *ndev_ctx = netdev_priv(net);
-	struct netvsc_device *nvdev = ndev_ctx->nvdev;
+	struct netvsc_device *nvdev = rtnl_dereference(ndev_ctx->nvdev);
 	struct rndis_device *rdev;
 	int ret = 0;
 
@@ -1364,7 +1364,7 @@ static struct net_device *get_netvsc_byref(struct net_device *vf_netdev)
 			continue;	/* not a netvsc device */
 
 		net_device_ctx = netdev_priv(dev);
-		if (net_device_ctx->nvdev == NULL)
+		if (!rtnl_dereference(net_device_ctx->nvdev))
 			continue;	/* device is removed */
 
 		if (rtnl_dereference(net_device_ctx->vf_netdev) == vf_netdev)
@@ -1589,7 +1589,8 @@ static int netvsc_remove(struct hv_device *dev)
 	 * removed. Also blocks mtu and channel changes.
 	 */
 	rtnl_lock();
-	rndis_filter_device_remove(dev, ndev_ctx->nvdev);
+	rndis_filter_device_remove(dev,
+				   rtnl_dereference(ndev_ctx->nvdev));
 	rtnl_unlock();
 
 	unregister_netdev(net);
-- 
2.11.0
