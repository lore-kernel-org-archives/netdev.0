From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH 5/6] hv_netvsc: synchronize
 netvsc_change_mtu()/netvsc_set_channels() with netvsc_remove()
Date: Thu, 12 May 2016 14:49:37 +0200
Message-ID: <1463057378-21118-6-git-send-email-vkuznets@redhat.com>
References: <1463057378-21118-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1463057378-21118-1-git-send-email-vkuznets@redhat.com>
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

When netvsc device is removed during mtu change or channels setup we get
into troubles as both paths are trying to remove the device. Synchronize
them with start_remove flag and rtnl lock.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/netvsc_drv.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 393403a..71b9125 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -707,7 +707,7 @@ static int netvsc_set_channels(struct net_device *net,
 	int ret = 0;
 	bool recovering = false;
 
-	if (!nvdev || nvdev->destroy)
+	if (net_device_ctx->start_remove || !nvdev || nvdev->destroy)
 		return -ENODEV;
 
 	num_chn = nvdev->num_chn;
@@ -855,7 +855,7 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	u32 num_chn;
 	int ret = 0;
 
-	if (nvdev == NULL || nvdev->destroy)
+	if (ndevctx->start_remove || !nvdev || nvdev->destroy)
 		return -ENODEV;
 
 	if (nvdev->nvsp_version >= NVSP_PROTOCOL_VERSION_2)
@@ -1206,7 +1206,12 @@ static int netvsc_remove(struct hv_device *dev)
 	ndev_ctx = netdev_priv(net);
 	net_device = ndev_ctx->nvdev;
 
+	/* Avoid racing with netvsc_change_mtu()/netvsc_set_channels()
+	 * removing the device.
+	 */
+	rtnl_lock();
 	ndev_ctx->start_remove = true;
+	rtnl_unlock();
 
 	cancel_delayed_work_sync(&ndev_ctx->dwork);
 	cancel_work_sync(&ndev_ctx->work);
-- 
2.5.5
