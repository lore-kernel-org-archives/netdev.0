From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net] hyperv: Fix race between probe and open calls
Date: Fri, 20 Dec 2013 16:52:31 -0800
Message-ID: <1387587151-1508-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, jasowang@redhat.com, driverdev-devel@linuxdriverproject.org,
 linux-kernel@vger.kernel.org, haiyangz@microsoft.com
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Moving the register_netdev to the end of probe to prevent
possible open call happens before NetVSP is connected.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |   20 ++++++++------------
 1 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index f813572..71baeb3 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -261,9 +261,7 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 	struct sk_buff *skb;
 
 	net = ((struct netvsc_device *)hv_get_drvdata(device_obj))->ndev;
-	if (!net) {
-		netdev_err(net, "got receive callback but net device"
-			" not initialized yet\n");
+	if (!net || net->reg_state != NETREG_REGISTERED) {
 		packet->status = NVSP_STAT_FAIL;
 		return 0;
 	}
@@ -435,19 +433,11 @@ static int netvsc_probe(struct hv_device *dev,
 	SET_ETHTOOL_OPS(net, &ethtool_ops);
 	SET_NETDEV_DEV(net, &dev->device);
 
-	ret = register_netdev(net);
-	if (ret != 0) {
-		pr_err("Unable to register netdev.\n");
-		free_netdev(net);
-		goto out;
-	}
-
 	/* Notify the netvsc driver of the new device */
 	device_info.ring_size = ring_size;
 	ret = rndis_filter_device_add(dev, &device_info);
 	if (ret != 0) {
 		netdev_err(net, "unable to add netvsc device (ret %d)\n", ret);
-		unregister_netdev(net);
 		free_netdev(net);
 		hv_set_drvdata(dev, NULL);
 		return ret;
@@ -456,7 +446,13 @@ static int netvsc_probe(struct hv_device *dev,
 
 	netif_carrier_on(net);
 
-out:
+	ret = register_netdev(net);
+	if (ret != 0) {
+		pr_err("Unable to register netdev.\n");
+		rndis_filter_device_remove(dev);
+		free_netdev(net);
+	}
+
 	return ret;
 }
 
-- 
1.7.4.1
